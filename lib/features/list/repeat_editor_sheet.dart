import 'package:flutter/material.dart';
import 'package:to_do_flutter_app/util/repeat_rule.dart';

/// Modal sheet to edit repeat rule (Google Calendar–style options).
Future<RepeatRule?> showRepeatEditorSheet(BuildContext context, {RepeatRule? initial}) async {
  return showModalBottomSheet<RepeatRule?>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _RepeatEditorSheet(initial: initial),
  );
}

class _RepeatEditorSheet extends StatefulWidget {
  const _RepeatEditorSheet({this.initial});

  final RepeatRule? initial;

  @override
  State<_RepeatEditorSheet> createState() => _RepeatEditorSheetState();
}

class _RepeatEditorSheetState extends State<_RepeatEditorSheet> {
  String? _freq;
  final Set<int> _days = {};
  int? _dayOfMonth;
  RepeatEnd _end = RepeatEnd.never;
  DateTime? _endDate;
  int? _endCount;
  final _endCountController = TextEditingController();

  static const _weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    final r = widget.initial;
    if (r != null) {
      _freq = r.freq;
      if (r.days != null) _days.addAll(r.days!);
      _dayOfMonth = r.dayOfMonth;
      _end = r.end;
      _endDate = r.endDate;
      _endCount = r.endCount;
      if (r.endCount != null) _endCountController.text = r.endCount.toString();
    }
  }

  @override
  void dispose() {
    _endCountController.dispose();
    super.dispose();
  }

  RepeatRule? _buildRule() {
    if (_freq == null) return null;
    final count = _end == RepeatEnd.after ? (int.tryParse(_endCountController.text) ?? _endCount ?? 1) : null;
    return RepeatRule(
      freq: _freq,
      days: _freq == 'W' && _days.isNotEmpty ? (List<int>.from(_days)..sort()) : null,
      dayOfMonth: _freq == 'M' ? (_dayOfMonth ?? 1) : null,
      end: _end,
      endDate: _end == RepeatEnd.until ? _endDate : null,
      endCount: count,
    );
  }

  void _save() {
    Navigator.pop(context, _buildRule());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('Repeat'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  TextButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ],
              ),
              Flexible(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Frequency', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip('None', null),
                        _chip('Daily', 'D'),
                        _chip('Weekly', 'W'),
                        _chip('Monthly', 'M'),
                      ],
                    ),
                    if (_freq == 'W') ...[
                      const SizedBox(height: 20),
                      Text('On days', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: List.generate(7, (i) {
                          final day = i + 1;
                          final selected = _days.contains(day);
                          return FilterChip(
                            label: Text(_weekdayLabels[i], style: TextStyle(color: selected ? colorScheme.onPrimary : colorScheme.onSurface)),
                            selected: selected,
                            onSelected: (v) => setState(() {
                              if (v) _days.add(day); else _days.remove(day);
                            }),
                            selectedColor: colorScheme.primary,
                            checkmarkColor: colorScheme.onPrimary,
                          );
                        }),
                      ),
                    ],
                    if (_freq == 'M') ...[
                      const SizedBox(height: 20),
                      Text('Day of month', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _dayOfMonth ?? 1,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: [
                          const DropdownMenuItem(value: 0, child: Text('First day of month')),
                          const DropdownMenuItem(value: 32, child: Text('Last day of month')),
                          ...List.generate(31, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
                        ],
                        onChanged: (v) => setState(() => _dayOfMonth = v),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text('Ends', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    RadioListTile<RepeatEnd>(
                      title: const Text('Never'),
                      value: RepeatEnd.never,
                      groupValue: _end,
                      onChanged: (v) => setState(() => _end = RepeatEnd.never),
                    ),
                    RadioListTile<RepeatEnd>(
                      title: const Text('On date'),
                      value: RepeatEnd.until,
                      groupValue: _end,
                      onChanged: (v) => setState(() => _end = RepeatEnd.until),
                    ),
                    if (_end == RepeatEnd.until)
                      Padding(
                        padding: const EdgeInsets.only(left: 48, right: 16, bottom: 8),
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text(_endDate != null ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}' : 'Pick date'),
                          onPressed: () async {
                            final d = await showDatePicker(context: context, initialDate: _endDate ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100));
                            if (d != null) setState(() => _endDate = d);
                          },
                        ),
                      ),
                    RadioListTile<RepeatEnd>(
                      title: const Text('After number of times'),
                      value: RepeatEnd.after,
                      groupValue: _end,
                      onChanged: (v) => setState(() => _end = RepeatEnd.after),
                    ),
                    if (_end == RepeatEnd.after)
                      Padding(
                        padding: const EdgeInsets.only(left: 48, right: 16, bottom: 8),
                        child: TextField(
                          controller: _endCountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Number of times',
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onChanged: (s) => setState(() => _endCount = int.tryParse(s)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(String label, String? value) {
    final selected = _freq == value;
    final colorScheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label, style: TextStyle(color: selected ? colorScheme.onPrimary : colorScheme.onSurface, fontWeight: selected ? FontWeight.w600 : FontWeight.w500)),
      selected: selected,
      onSelected: (_) => setState(() => _freq = value),
      selectedColor: colorScheme.primary,
      checkmarkColor: colorScheme.onPrimary,
    );
  }
}
