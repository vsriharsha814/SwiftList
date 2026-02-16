import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:to_do_flutter_app/core/settings/app_settings.dart';
import 'package:to_do_flutter_app/core/theme/app_colors.dart';
import 'package:to_do_flutter_app/main.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          Consumer<AppSettings>(
            builder: (context, settings, _) => ListTile(
              title: const Text('Theme'),
              subtitle: Text(
                settings.themeMode == ThemeModePreference.system
                    ? 'Follow system setting'
                    : settings.themeMode == ThemeModePreference.light
                        ? 'Light'
                        : 'Dark',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              trailing: PopupMenuButton<ThemeModePreference>(
                icon: const Icon(Icons.arrow_drop_down),
                onSelected: (value) => settings.setThemeMode(value),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: ThemeModePreference.system,
                    child: Row(
                      children: [
                        if (settings.themeMode == ThemeModePreference.system)
                          const Icon(Icons.check, size: 20),
                        if (settings.themeMode == ThemeModePreference.system)
                          const SizedBox(width: 8),
                        const Text('System'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: ThemeModePreference.light,
                    child: Row(
                      children: [
                        if (settings.themeMode == ThemeModePreference.light)
                          const Icon(Icons.check, size: 20),
                        if (settings.themeMode == ThemeModePreference.light)
                          const SizedBox(width: 8),
                        const Text('Light'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: ThemeModePreference.dark,
                    child: Row(
                      children: [
                        if (settings.themeMode == ThemeModePreference.dark)
                          const Icon(Icons.check, size: 20),
                        if (settings.themeMode == ThemeModePreference.dark)
                          const SizedBox(width: 8),
                        const Text('Dark'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Consumer<AppSettings>(
            builder: (context, settings, _) => SwitchListTile(
              title: const Text('Keep done tasks in archive'),
              subtitle: Text(
                settings.archiveCompletedTasks
                    ? 'Completed tasks are hidden from the list'
                    : 'Completed tasks stay visible in the list',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              value: settings.archiveCompletedTasks,
              onChanged: (value) => settings.setArchiveCompletedTasks(value),
              activeColor: AppColors.actionAccent,
            ),
          ),
          const Divider(height: 24),
          ListTile(
            title: const Text('Privacy Policy'),
            leading: const Icon(Icons.privacy_tip),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
              );
            },
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FilledButton(
              onPressed: () async {
                await _handleNotificationPermission(context);
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Test Notification'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNotificationPermission(BuildContext context) async {
    if (!context.mounted) return;
    PermissionStatus status = await Permission.notification.status;
    if (!context.mounted) return;

    if (status.isGranted) {
      _showTestNotification(context);
    } else if (status.isDenied) {
      PermissionStatus requestStatus = await Permission.notification.request();
      if (!context.mounted) return;
      if (requestStatus.isGranted) {
        _showTestNotification(context);
      } else {
        _showPermissionDeniedDialog(context);
      }
    } else if (status.isPermanentlyDenied) {
      _showPermissionSettingsDialog(context);
    }
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text('Notification permission is required to show reminders.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _handleNotificationPermission(context);
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showPermissionSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enable Notifications'),
        content: const Text(
          'Notifications are disabled for this app. Please enable them in the system settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTestNotification(BuildContext context) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
        final ctx = navigatorKey.currentContext;
        if (ctx != null && ctx.mounted) {
          showDialog(
            context: ctx,
            builder: (BuildContext dialogContext) => AlertDialog(
              title: Text(title ?? ''),
              content: Text(body ?? ''),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
              ],
            ),
          );
        }
      },
    );

    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const IOSNotificationDetails iosDetails = IOSNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Test Notification',
      'This is a test notification!',
      platformDetails,
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepCharcoal,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppColors.deepCharcoal,
        foregroundColor: AppColors.textPrimary,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            '''Privacy Policy  

Last updated: February 06, 2025

This Privacy Policy describes Our policies and procedures on the collection, use, and disclosure of Your information when You use the Service.

1. Information Collection and Use
We only store your task data locally on your device. We do not collect, share, or transmit any personal data to external servers.

2. Data Security
Since all data is stored locally, you have complete control over your information.

3. Changes to This Policy
We may update our Privacy Policy from time to time. We will notify you of any changes by updating this page.

4. Contact Us
If you have any questions, please contact us at srva5218@colorado.edu.
            ''',
            style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
