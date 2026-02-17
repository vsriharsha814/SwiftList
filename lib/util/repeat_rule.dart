import 'dart:convert';

/// Recurrence rule for a task. Stored as JSON in task.rrule when using extended options.
/// Legacy: rrule can also be "DAILY" | "WEEKLY" | "MONTHLY" for simple recurrence.
/// Month ordinal for "second Tuesday": 1=first, 2=second, 3=third, 4=fourth, 5=last.
const int monthOrdinalLast = 5;

class RepeatRule {
  RepeatRule({
    this.freq,
    this.days,
    this.dayOfMonth,
    this.monthOrdinal,
    this.monthWeekday,
    this.end = RepeatEnd.never,
    this.endDate,
    this.endCount,
  });

  /// D = daily, W = weekly, M = monthly. null = no repeat.
  final String? freq;
  /// For weekly: 1 = Monday .. 7 = Sunday.
  final List<int>? days;
  /// For monthly (by day): 0 = first day, 1-31 = that day, 32 = last day of month.
  final int? dayOfMonth;
  /// For monthly (by weekday): 1=first, 2=second, 3=third, 4=fourth, 5=last week of month.
  final int? monthOrdinal;
  /// For monthly (by weekday): 1 = Monday .. 7 = Sunday. Used with [monthOrdinal].
  final int? monthWeekday;
  final RepeatEnd end;
  final DateTime? endDate;
  final int? endCount;

  static const String keyFreq = 'f';
  static const String keyDays = 'd';
  static const String keyDayOfMonth = 'dom';
  static const String keyMonthOrdinal = 'mo';
  static const String keyMonthWeekday = 'mw';
  static const String keyEnd = 'e';
  static const String keyEndDate = 'ed';
  static const String keyEndCount = 'ec';

  Map<String, dynamic> toJson() => {
    if (freq != null) keyFreq: freq,
    if (days != null && days!.isNotEmpty) keyDays: days,
    if (dayOfMonth != null) keyDayOfMonth: dayOfMonth,
    if (monthOrdinal != null) keyMonthOrdinal: monthOrdinal,
    if (monthWeekday != null) keyMonthWeekday: monthWeekday,
    keyEnd: end.name,
    if (endDate != null) keyEndDate: endDate!.toIso8601String(),
    if (endCount != null) keyEndCount: endCount,
  };

  static RepeatRule? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    RepeatEnd e = RepeatEnd.never;
    if (json[keyEnd] != null) {
      switch (json[keyEnd].toString()) {
        case 'until': e = RepeatEnd.until; break;
        case 'after': e = RepeatEnd.after; break;
        default: e = RepeatEnd.never;
      }
    }
    List<int>? d;
    if (json[keyDays] != null) {
      final list = json[keyDays];
      if (list is List) d = list.map((e) => (e is int) ? e : int.tryParse(e.toString()) ?? 0).where((e) => e >= 1 && e <= 7).toList();
    }
    DateTime? ed;
    if (json[keyEndDate] != null) ed = DateTime.tryParse(json[keyEndDate].toString());
    int? dom;
    if (json[keyDayOfMonth] != null) {
      final n = int.tryParse(json[keyDayOfMonth].toString());
      if (n != null && n >= 0 && n <= 32) dom = n;
    }
    int? mo;
    if (json[keyMonthOrdinal] != null) {
      final n = int.tryParse(json[keyMonthOrdinal].toString());
      if (n != null && n >= 1 && n <= 5) mo = n;
    }
    int? mw;
    if (json[keyMonthWeekday] != null) {
      final n = int.tryParse(json[keyMonthWeekday].toString());
      if (n != null && n >= 1 && n <= 7) mw = n;
    }
    return RepeatRule(
      freq: json[keyFreq]?.toString(),
      days: d?.isEmpty == true ? null : d,
      dayOfMonth: dom,
      monthOrdinal: mo,
      monthWeekday: mw,
      end: e,
      endDate: ed,
      endCount: json[keyEndCount] != null ? int.tryParse(json[keyEndCount].toString()) : null,
    );
  }

  /// Parse task.rrule string: legacy "DAILY"/"WEEKLY"/"MONTHLY" or JSON.
  static RepeatRule? parse(String? rrule) {
    if (rrule == null || rrule.isEmpty) return null;
    if (rrule == 'DAILY') return RepeatRule(freq: 'D');
    if (rrule == 'WEEKLY') return RepeatRule(freq: 'W');
    if (rrule == 'MONTHLY') return RepeatRule(freq: 'M');
    try {
      final map = jsonDecode(rrule) as Map<String, dynamic>?;
      return fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Serialize to string for task.rrule. Uses legacy format when possible.
  String toStorage() {
    if (freq == null) return '';
    final monthlyExtended = freq == 'M' && (dayOfMonth != null || (monthOrdinal != null && monthWeekday != null));
    final useExtended = (freq == 'W' && days != null && days!.isNotEmpty) ||
        monthlyExtended ||
        end != RepeatEnd.never;
    if (!useExtended) {
      if (freq == 'D') return 'DAILY';
      if (freq == 'W') return 'WEEKLY';
      if (freq == 'M') return 'MONTHLY';
    }
    return jsonEncode(toJson());
  }

  /// Human-readable summary.
  String toSummary() {
    if (freq == null) return 'None';
    if (freq == 'D') return _endSuffix('Daily');
    if (freq == 'W') {
      if (days != null && days!.isNotEmpty) {
        const names = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final s = days!.map((d) => names[d]).join(', ');
        return _endSuffix('Weekly on $s');
      }
      return _endSuffix('Weekly');
    }
    if (freq == 'M') {
      if (monthOrdinal != null && monthWeekday != null) {
        const ordinals = ['', 'First', 'Second', 'Third', 'Fourth', 'Last'];
        const weekdays = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final o = ordinals[monthOrdinal!.clamp(1, 5)];
        final w = weekdays[monthWeekday!.clamp(1, 7)];
        return _endSuffix('Monthly on the $o $w');
      }
      if (dayOfMonth != null) {
        if (dayOfMonth == 0) return _endSuffix('Monthly on first day');
        if (dayOfMonth == 32) return _endSuffix('Monthly on last day');
        return _endSuffix('Monthly on day $dayOfMonth');
      }
      return _endSuffix('Monthly');
    }
    return _endSuffix('Custom');
  }

  String _endSuffix(String base) {
    if (end == RepeatEnd.until && endDate != null) return '$base • ends ${_fmtDate(endDate!)}';
    if (end == RepeatEnd.after && endCount != null) return '$base • $endCount times';
    return base;
  }

  static String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

enum RepeatEnd { never, until, after }

/// Returns the date of the nth occurrence of [weekday] (1=Mon..7=Sun) in [year]/[month].
/// [ordinal] 1=first, 2=second, 3=third, 4=fourth, 5=last. Uses [hour] and [minute] for time.
DateTime? _nthWeekdayInMonth(int year, int month, int ordinal, int weekday, int hour, int minute) {
  final lastDay = DateTime(year, month + 1, 0).day;
  final matches = <DateTime>[];
  for (var d = 1; d <= lastDay; d++) {
    final dt = DateTime(year, month, d);
    if (dt.weekday == weekday) matches.add(dt);
  }
  if (matches.isEmpty) return null;
  if (ordinal == monthOrdinalLast) return DateTime(year, month, matches.last.day, hour, minute);
  if (ordinal < 1 || ordinal > matches.length) return null;
  final d = matches[ordinal - 1].day;
  return DateTime(year, month, d, hour, minute);
}

/// Compute next occurrence from a rule and current reference time.
DateTime? getNextOccurrence(RepeatRule? rule, DateTime from) {
  if (rule == null || rule.freq == null) return null;
  if (rule.end == RepeatEnd.after && rule.endCount != null && rule.endCount! <= 0) return null;
  if (rule.end == RepeatEnd.until && rule.endDate != null && from.isAfter(rule.endDate!)) return null;

  DateTime next = from;
  if (rule.freq == 'D') {
    next = next.add(const Duration(days: 1));
  } else if (rule.freq == 'W') {
    final currentWeekday = next.weekday;
    final allowed = rule.days ?? [currentWeekday];
    int daysToAdd = 7;
    for (final d in allowed) {
      int diff = d - currentWeekday;
      if (diff <= 0) diff += 7;
      if (diff < daysToAdd) daysToAdd = diff;
    }
    next = next.add(Duration(days: daysToAdd));
  } else if (rule.freq == 'M') {
    if (rule.monthOrdinal != null && rule.monthWeekday != null) {
      // Monthly by weekday: e.g. "second Tuesday", "last Friday".
      var year = next.year;
      var month = next.month;
      DateTime? candidate;
      while (true) {
        candidate = _nthWeekdayInMonth(year, month, rule.monthOrdinal!, rule.monthWeekday!, next.hour, next.minute);
        if (candidate != null && !candidate.isBefore(from) && !candidate.isAtSameMomentAs(from)) break;
        month++;
        if (month > 12) {
          month = 1;
          year++;
        }
      }
      next = candidate;
    } else {
      final rawDay = rule.dayOfMonth ?? next.day;
      final lastDayThisMonth = DateTime(next.year, next.month + 1, 0).day;
      final effectiveDay = rawDay == 0 ? 1 : (rawDay == 32 ? lastDayThisMonth : rawDay.clamp(1, lastDayThisMonth));
      var candidate = DateTime(next.year, next.month, effectiveDay, next.hour, next.minute);
      if (candidate.isBefore(from) || candidate.isAtSameMomentAs(from)) {
        final lastDayNextMonth = DateTime(next.year, next.month + 2, 0).day;
        final nextEffectiveDay = rawDay == 0 ? 1 : (rawDay == 32 ? lastDayNextMonth : rawDay.clamp(1, lastDayNextMonth));
        candidate = DateTime(next.year, next.month + 1, nextEffectiveDay, next.hour, next.minute);
      }
      next = candidate;
    }
  }

  if (rule.end == RepeatEnd.until && rule.endDate != null && next.isAfter(rule.endDate!)) return null;
  return next;
}

/// Legacy: get next occurrence from raw rrule string (supports "DAILY"/"WEEKLY"/"MONTHLY" or JSON).
DateTime? getNextOccurrenceFromRrule(String? rrule, DateTime from) {
  final rule = RepeatRule.parse(rrule);
  if (rule == null) return null;
  if (rule.freq == null) return null;
  if (rule.freq == 'D' || (rule.freq == 'W' && (rule.days == null || rule.days!.isEmpty)) || (rule.freq == 'M' && rule.dayOfMonth == null)) {
    return getNextOccurrence(rule, from);
  }
  return getNextOccurrence(rule, from);
}
