import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_10y.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

/// Reminder offsets in minutes: 10 min, 30 min, 1 hr, 1 day before.
const List<int> kReminderOptions = [10, 30, 60, 1440];

/// Labels for reminder options (short for one-line layout).
const Map<int, String> kReminderLabels = {
  10: '10 min',
  30: '30 min',
  60: '1 hr',
  1440: '1 day',
};

/// Parse reminder minutes from task.reminderMinutesBefore (JSON array string).
List<int> parseReminderMinutes(String? json) {
  if (json == null || json.isEmpty) return [];
  try {
    final list = jsonDecode(json);
    if (list is! List) return [];
    return list.map((e) => int.tryParse(e.toString())).whereType<int>().toList();
  } catch (_) {
    return [];
  }
}

/// Serialize reminder minutes to JSON string for storage.
String serializeReminderMinutes(List<int> minutes) {
  return jsonEncode(minutes);
}

FlutterLocalNotificationsPlugin? _plugin;
bool _initialized = false;

Future<FlutterLocalNotificationsPlugin> _getPlugin() async {
  if (_plugin != null) return _plugin!;
  _plugin = FlutterLocalNotificationsPlugin();
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = IOSInitializationSettings(requestAlertPermission: true);
  await _plugin!.initialize(
    const InitializationSettings(android: android, iOS: ios),
  );
  return _plugin!;
}

Future<void> _ensureTimezone() async {
  if (_initialized) return;
  tz_data.initializeTimeZones();
  try {
    final name = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(name));
  } catch (_) {
    tz.setLocalLocation(tz.UTC);
  }
  _initialized = true;
}

/// Generate a stable notification id for (taskId, minutesBefore).
int _notificationId(String taskId, int minutesBefore) {
  final h = (taskId.hashCode.abs() * 31 + minutesBefore) & 0x7FFFFFFF;
  return h == 0 ? 1 : h;
}

const String _channelId = 'task_reminders';
const String _channelName = 'Task reminders';

/// Schedules reminder notifications for a task. Call when task has deadline and reminderMinutesBefore set.
/// Cancels any existing reminders for this task first, then schedules new ones.
Future<void> scheduleTaskReminders({
  required String taskId,
  required String title,
  required DateTime deadline,
  required List<int> minutesBefore,
}) async {
  if (minutesBefore.isEmpty || deadline.isBefore(DateTime.now())) return;
  await _ensureTimezone();
  final plugin = await _getPlugin();
  await cancelTaskReminders(taskId);

  const androidDetails = AndroidNotificationDetails(
    _channelId,
    _channelName,
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );
  const iosDetails = IOSNotificationDetails();
  const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

  final deadlineTz = tz.TZDateTime.from(deadline, tz.local);
  for (final minutes in minutesBefore) {
    final remindAt = deadlineTz.subtract(Duration(minutes: minutes));
    if (remindAt.isBefore(tz.TZDateTime.now(tz.local))) continue;
    final id = _notificationId(taskId, minutes);
    await plugin.zonedSchedule(
      id,
      'Reminder: $title',
      'Due in $minutes min',
      remindAt,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

/// Cancels all scheduled reminders for a task.
Future<void> cancelTaskReminders(String taskId) async {
  final plugin = await _getPlugin();
  for (final minutes in kReminderOptions) {
    final id = _notificationId(taskId, minutes);
    await plugin.cancel(id);
  }
}
