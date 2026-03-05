import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:to_do_flutter_app/core/theme/app_colors.dart';
import 'package:to_do_flutter_app/data/database/app_database.dart';
import 'package:to_do_flutter_app/features/list/repeat_editor_sheet.dart';
import 'package:to_do_flutter_app/util/repeat_rule.dart';
import 'package:to_do_flutter_app/util/reminder_service.dart';

/// Task detail: title, description, and subtasks. Subtasks added here appear on the main list.
class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, db),
          ),
        ],
      ),
      body: StreamBuilder<Task?>(
        stream: db.watchTaskById(taskId),
        builder: (context, taskSnapshot) {
          if (!taskSnapshot.hasData && !taskSnapshot.hasError) {
            return const Center(child: CircularProgressIndicator(color: AppColors.actionAccent));
          }
          final task = taskSnapshot.data;
          if (task == null) {
            return const Center(child: Text('Task not found'));
          }
          return _TaskDetailContent(task: task, db: db);
        },
      ),
    );
  }

  void _showAddSubtask(BuildContext context, AppDatabase db) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New subtask'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Subtask title'),
          onSubmitted: (_) => _addSubtask(ctx, db, controller),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => _addSubtask(ctx, db, controller),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addSubtask(BuildContext context, AppDatabase db, TextEditingController controller) async {
    final title = controller.text.trim();
    if (title.isEmpty) return;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await db.insertTask(TasksCompanion(
      id: Value(id),
      title: Value(title),
      parentId: Value(taskId),
      createdAt: Value(DateTime.now()),
    ));
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _confirmDelete(BuildContext context, AppDatabase db) async {
    final children = await db.childrenOf(taskId);
    if (children.isNotEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Remove or complete subtasks first')),
        );
      }
      return;
    }
    final task = await db.getTaskById(taskId);
    final title = task?.title ?? 'this task';
    final isRepeating = task != null && task.rrule != null && task.rrule!.isNotEmpty;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text(
          isRepeating
              ? 'Delete "$title"? This is a repeating task. This occurrence will be removed and no future occurrences will be created. This cannot be undone.'
              : 'Permanently delete "$title"? This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (confirmed == true) {
      await cancelTaskReminders(taskId);
      await db.deleteTaskAndDependencies(taskId);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class _TaskDetailContent extends StatefulWidget {
  final Task task;
  final AppDatabase db;

  const _TaskDetailContent({super.key, required this.task, required this.db});

  @override
  State<_TaskDetailContent> createState() => _TaskDetailContentState();
}

class _TaskDetailContentState extends State<_TaskDetailContent> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _addSubtaskController;
  late final ScrollController _scrollController;
  final GlobalKey _subtasksSectionKey = GlobalKey();
  final GlobalKey _subtaskEditKey = GlobalKey();
  String? _editingSubtaskId;
  Timer? _titleDebounce;
  Timer? _descDebounce;
  String _lastSubtaskText = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description ?? '');
    _addSubtaskController = TextEditingController();
     _scrollController = ScrollController();
    _titleController.addListener(_onTitleChanged);
    _descController.addListener(_onDescChanged);
     _addSubtaskController.addListener(_onSubtaskTextChanged);
  }

  @override
  void didUpdateWidget(_TaskDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.id != widget.task.id) {
      _titleController.text = widget.task.title;
      _descController.text = widget.task.description ?? '';
      _addSubtaskController.clear();
      _lastSubtaskText = '';
      _editingSubtaskId = null;
    }
  }

  @override
  void dispose() {
    _titleDebounce?.cancel();
    _descDebounce?.cancel();
    _scrollController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _addSubtaskController.dispose();
    super.dispose();
  }

  void _onTitleChanged() {
    _titleDebounce?.cancel();
    _titleDebounce = Timer(const Duration(milliseconds: 500), _saveTitle);
  }

  void _onDescChanged() {
    _descDebounce?.cancel();
    _descDebounce = Timer(const Duration(milliseconds: 500), _saveDescription);
  }

  void _onSubtaskTextChanged() {
    final current = _addSubtaskController.text;
    if (_lastSubtaskText.isEmpty && current.isNotEmpty) {
      _scrollToSubtasks();
    }
    _lastSubtaskText = current;
  }

  void _scrollToSubtasks() {
    // Delay so keyboard can open first; scroll so "Subtasks" title has a little space above it
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      final context = _subtasksSectionKey.currentContext;
      if (context == null) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        alignment: 0.06,
      );
    });
  }

  Future<void> _addSubtaskInline() async {
    final title = _addSubtaskController.text.trim();
    if (title.isEmpty) return;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await widget.db.insertTask(TasksCompanion(
      id: Value(id),
      title: Value(title),
      parentId: Value(widget.task.id),
      createdAt: Value(DateTime.now()),
    ));
    _addSubtaskController.clear();
    setState(() {});
  }

  Future<void> _saveTitle() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    await widget.db.updateTaskById(widget.task.id, TasksCompanion(title: Value(title)));
  }

  Future<void> _saveDescription() async {
    final desc = _descController.text.trim();
    await widget.db.updateTaskById(widget.task.id, TasksCompanion(description: Value(desc.isEmpty ? null : desc)));
  }

  Future<void> _saveRepeat(String? rrule) async {
    await widget.db.updateTaskById(widget.task.id, TasksCompanion(rrule: Value(rrule)));
  }

  Future<void> _saveDeadline(DateTime? deadline) async {
    await widget.db.updateTaskById(
      widget.task.id,
      TasksCompanion(
        deadline: Value(deadline),
        reminderMinutesBefore: deadline == null ? const Value(null) : const Value.absent(),
      ),
    );
    if (deadline == null) {
      await cancelTaskReminders(widget.task.id);
    } else {
      final minutes = parseReminderMinutes(widget.task.reminderMinutesBefore);
      if (minutes.isNotEmpty) {
        final ok = await scheduleTaskReminders(
          taskId: widget.task.id,
          title: widget.task.title,
          deadline: deadline,
          minutesBefore: minutes,
        );
        if (mounted && !ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enable notifications in Settings to get reminders')),
          );
        }
      }
    }
  }

  Future<void> _saveReminders(List<int> minutes) async {
    final json = minutes.isEmpty ? null : serializeReminderMinutes(minutes);
    await widget.db.updateTaskById(
      widget.task.id,
      TasksCompanion(reminderMinutesBefore: Value(json)),
    );
    if (widget.task.deadline != null && minutes.isNotEmpty) {
      final ok = await scheduleTaskReminders(
        taskId: widget.task.id,
        title: widget.task.title,
        deadline: widget.task.deadline!,
        minutesBefore: minutes,
      );
      if (mounted && !ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enable notifications in Settings to get reminders')),
        );
      }
    } else {
      await cancelTaskReminders(widget.task.id);
    }
  }

  Future<void> _pickDeadline() async {
    if (widget.task.deadline != null) {
      // Show dialog with options: Set Date & Time, Clear Date
      final action = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Due Date'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Set Date & Time'),
                onTap: () => Navigator.pop(context, 'set'),
              ),
              ListTile(
                leading: const Icon(Icons.clear),
                title: const Text('Clear Date'),
                onTap: () => Navigator.pop(context, 'clear'),
              ),
            ],
          ),
        ),
      );
      if (!mounted) return;
      if (action == 'clear') {
        await _saveDeadline(null);
        return;
      }
      if (action != 'set') return;
    }
    // Proceed with date/time picker
    final date = await showDatePicker(
      context: context,
      initialDate: widget.task.deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (!mounted || date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: widget.task.deadline != null
          ? TimeOfDay(hour: widget.task.deadline!.hour, minute: widget.task.deadline!.minute)
          : TimeOfDay.now(),
    );
    if (!mounted || time == null) return;
    final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    await _saveDeadline(combined);
  }

  Future<void> _onSubtaskToggle(BuildContext context, Task t) async {
    if (t.isCompleted) {
      await widget.db.updateTaskById(t.id, const TasksCompanion(isCompleted: Value(false), completedAt: Value(null)));
      return;
    }
    final now = DateTime.now();
    await widget.db.updateTaskById(t.id, TasksCompanion(isCompleted: const Value(true), completedAt: Value(now)));
    if (t.rrule != null && t.rrule!.isNotEmpty) {
      final from = t.deadline != null && t.deadline!.isAfter(now) ? t.deadline! : now;
      final next = getNextOccurrenceFromRrule(t.rrule, from);
      if (next != null) {
        final newId = await widget.db.insertNextRecurrence(t, next);
        final reminderMins = parseReminderMinutes(t.reminderMinutesBefore);
        if (reminderMins.isNotEmpty) {
          final ok = await scheduleTaskReminders(taskId: newId, title: t.title, deadline: next, minutesBefore: reminderMins);
          if (mounted && !ok) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Enable notifications in Settings to get reminders')),
            );
          }
        }
      }
    }
  }

  static const double _spaceSection = 32;
  static const double _spaceBlock = 18;
  static const double _spaceRow = 16;
  static const double _minTouchTarget = 44;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title: single scrollable line, blends into page (no filled background)
          TextField(
            controller: _titleController,
            maxLines: 1,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            decoration: const InputDecoration(
              hintText: 'New task title',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descController,
            maxLines: 3,
            style: TextStyle(color: colorScheme.onSurface, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Add a description...',
              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: _spaceSection),
          // —— Time & Schedule card (collapsible) ——
          _CollapsibleSectionCard(
            icon: Icons.schedule_rounded,
            title: 'Time & Schedule',
            colorScheme: colorScheme,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: _spaceBlock),
                // Due date row (tap value to edit)
                _ScheduleRow(
                  label: 'Due date',
                  valueWidget: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _pickDeadline,
                      borderRadius: BorderRadius.circular(12),
                      child: widget.task.deadline != null
                          ? _DueDatePill(
                              dateTime: widget.task.deadline!,
                              colorScheme: colorScheme,
                            )
                          : _ScheduleButton(
                              colorScheme: colorScheme,
                              child: Text(
                                'Not set',
                                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                    ),
                  ),
                  colorScheme: colorScheme,
                  minTouchTarget: _minTouchTarget,
                  actions: const [],
                ),
                  // Reminders only when due date is set (label + chips on one line)
                  if (widget.task.deadline != null) ...[
                    const SizedBox(height: _spaceRow),
                    Builder(
                      builder: (context) {
                        final now = DateTime.now();
                        final minutesUntilDeadline = widget.task.deadline!.difference(now).inMinutes;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 88,
                              child: Text(
                                'Reminders',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant.withOpacity(0.85),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: kReminderOptions.map((minutes) {
                                    final selected = parseReminderMinutes(widget.task.reminderMinutesBefore).contains(minutes);
                                    final enabled = minutesUntilDeadline >= minutes;
                                    final label = kReminderLabels[minutes] ?? '${minutes}m';
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: FilterChip(
                                        label: Text(
                                          label,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: enabled
                                                ? (selected ? colorScheme.onPrimary : colorScheme.onSurface)
                                                : colorScheme.onSurfaceVariant.withOpacity(0.6),
                                          ),
                                        ),
                                        selected: selected,
                                        onSelected: enabled
                                            ? (v) async {
                                                final current = parseReminderMinutes(widget.task.reminderMinutesBefore).toSet();
                                                if (v) {
                                                  current.add(minutes);
                                                } else {
                                                  current.remove(minutes);
                                                }
                                                await _saveReminders(current.toList()..sort());
                                              }
                                            : null,
                                        selectedColor: AppColors.actionAccent,
                                        showCheckmark: false,
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                const SizedBox(height: _spaceRow),
                _ScheduleRow(
                  label: 'Repeat',
                  valueWidget: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        final rule = await showRepeatEditorSheet(context, initial: RepeatRule.parse(widget.task.rrule));
                        if (!context.mounted) return;
                        final value = rule?.toStorage();
                        await _saveRepeat(value == null || value.isEmpty ? null : value);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: _ScheduleButton(
                        colorScheme: colorScheme,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.repeat, size: 16, color: colorScheme.onSurfaceVariant),
                            const SizedBox(width: 8),
                            Text(
                              RepeatRule.parse(widget.task.rrule)?.toSummary() ?? 'None',
                              style: TextStyle(color: colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  colorScheme: colorScheme,
                  minTouchTarget: _minTouchTarget,
                  actions: const [],
                ),
              ],
            ),
          ),
          // Subtasks: only for root tasks (one level of subtasking)
          if (widget.task.parentId == null) ...[
            const SizedBox(height: _spaceSection),
            Column(
              key: _subtasksSectionKey,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
            Row(
              children: [
                Icon(Icons.checklist_rounded, size: 22, color: AppColors.actionAccent),
                const SizedBox(width: 10),
                Text(
                  'Subtasks',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addSubtaskController,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Add a subtask...',
                      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onSubmitted: (_) => _addSubtaskInline(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addSubtaskInline,
                  icon: const Icon(Icons.add, size: 22),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.actionAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<Task>>(
              stream: widget.db.watchChildrenOf(widget.task.id),
              builder: (context, snap) {
                final list = snap.data ?? [];
                final completed = list.where((t) => t.isCompleted).length;
                if (list.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '$completed/${list.length}',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            StreamBuilder<List<Task>>(
              stream: widget.db.watchChildrenOf(widget.task.id),
              builder: (context, snapshot) {
                final subtasks = snapshot.data ?? [];
                if (subtasks.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No subtasks yet.',
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
                    ),
                  );
                }
                return Column(
                  children: subtasks.map((t) {
                    final isEditing = _editingSubtaskId == t.id;
                    return _SubtaskTile(
                      key: isEditing ? _subtaskEditKey : ValueKey(t.id),
                      task: t,
                      isEditing: isEditing,
                      onToggle: () => _onSubtaskToggle(context, t),
                      onTap: () => _startEditingSubtask(t),
                      onDelete: () => _deleteSubtask(context, t),
                      onSaveTitle: (title) => _saveSubtaskTitle(t.id, title),
                      onCancelEdit: _cancelEditingSubtask,
                    );
                  }).toList(),
                );
              },
            ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _deleteSubtask(BuildContext context, Task t) async {
    final children = await widget.db.childrenOf(t.id);
    if (children.isNotEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Remove subtasks first')),
        );
      }
      return;
    }
    final isRepeating = t.rrule != null && t.rrule!.isNotEmpty;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete subtask?'),
        content: Text(
          isRepeating
              ? 'Delete "${t.title}"? This repeating subtask will be removed and no future occurrences will be created. This cannot be undone.'
              : 'Permanently delete "${t.title}"? This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (ok == true) await widget.db.deleteTaskAndDependencies(t.id);
  }

  void _startEditingSubtask(Task subtask) {
    setState(() => _editingSubtaskId = subtask.id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _editingSubtaskId != subtask.id) return;
      final ctx = _subtaskEditKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          alignment: 0.2,
        );
      }
    });
  }

  Future<void> _saveSubtaskTitle(String subtaskId, String newTitle) async {
    final trimmed = newTitle.trim();
    if (trimmed.isNotEmpty) {
      await widget.db.updateTaskById(
        subtaskId,
        TasksCompanion(title: Value(trimmed)),
      );
    }
    if (mounted) setState(() => _editingSubtaskId = null);
  }

  void _cancelEditingSubtask() {
    setState(() => _editingSubtaskId = null);
  }
}

/// One row in the Time & Schedule card: label, value or valueWidget, and actions.
class _ScheduleRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final ColorScheme colorScheme;
  final double minTouchTarget;
  final List<Widget> actions;

  const _ScheduleRow({
    required this.label,
    this.value,
    this.valueWidget,
    required this.colorScheme,
    required this.minTouchTarget,
    required this.actions,
  }) : assert(value != null || valueWidget != null);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 88,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Expanded(
          child: valueWidget ?? Text(
            value!,
            style: TextStyle(color: colorScheme.onSurface, fontSize: 15),
          ),
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(width: 8),
          ...actions.expand((w) => [w, const SizedBox(width: 8)]).toList()..removeLast(),
        ],
      ],
    );
  }
}

/// Button-style container for schedule row values (due date, repeat).
class _ScheduleButton extends StatelessWidget {
  final ColorScheme colorScheme;
  final Widget child;

  const _ScheduleButton({required this.colorScheme, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.4), width: 1.5),
      ),
      child: child,
    );
  }
}

/// Due date in a button-style box (tap to edit).
class _DueDatePill extends StatelessWidget {
  final DateTime dateTime;
  final ColorScheme colorScheme;

  const _DueDatePill({required this.dateTime, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final text = DateFormat('MMM d, yy · h:mm a').format(dateTime);
    return _ScheduleButton(
      colorScheme: colorScheme,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Collapsible section card with icon + title; tap header to expand/collapse.
class _CollapsibleSectionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final ColorScheme colorScheme;
  final Widget child;

  const _CollapsibleSectionCard({
    required this.icon,
    required this.title,
    required this.colorScheme,
    required this.child,
  });

  @override
  State<_CollapsibleSectionCard> createState() => _CollapsibleSectionCardState();
}

class _CollapsibleSectionCardState extends State<_CollapsibleSectionCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: widget.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      size: 22,
                      color: AppColors.actionAccent,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          color: widget.colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0 : 0.5,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.expand_more,
                        size: 24,
                        color: widget.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _expanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: widget.child,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small icon-only action for schedule rows (edit pencil, clear X).
class _ScheduleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final ColorScheme colorScheme;

  const _ScheduleIconButton({required this.icon, required this.onPressed, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        foregroundColor: colorScheme.onSurfaceVariant,
        minimumSize: const Size(32, 32),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

/// Inline-editable subtask row: tap to edit title, scroll brings it into view.
class _SubtaskTile extends StatefulWidget {
  final Task task;
  final bool isEditing;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final void Function(String title) onSaveTitle;
  final VoidCallback onCancelEdit;

  const _SubtaskTile({
    super.key,
    required this.task,
    required this.isEditing,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
    required this.onSaveTitle,
    required this.onCancelEdit,
  });

  @override
  State<_SubtaskTile> createState() => _SubtaskTileState();
}

class _SubtaskTileState extends State<_SubtaskTile> {
  TextEditingController? _controller;
  FocusNode? _focusNode;

  void _attachEditingControllers() {
    _controller = TextEditingController(text: widget.task.title);
    _focusNode = FocusNode();
    _focusNode!.addListener(_onFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode?.requestFocus();
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) _attachEditingControllers();
  }

  @override
  void didUpdateWidget(_SubtaskTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isEditing && widget.isEditing) {
      if (_controller == null) _attachEditingControllers();
    } else if (oldWidget.isEditing && !widget.isEditing) {
      _focusNode?.removeListener(_onFocusChange);
      _controller?.dispose();
      _focusNode?.dispose();
      _controller = null;
      _focusNode = null;
    } else if (widget.isEditing && oldWidget.task.id != widget.task.id) {
      _controller?.text = widget.task.title;
    }
  }

  void _onFocusChange() {
    if (_focusNode?.hasFocus == false) _commitEdit();
  }

  void _commitEdit() {
    final text = _controller?.text.trim() ?? '';
    widget.onSaveTitle(text.isEmpty ? widget.task.title : text);
  }

  @override
  void dispose() {
    _focusNode?.removeListener(_onFocusChange);
    _controller?.dispose();
    _focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final task = widget.task;
    final isEditing = widget.isEditing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEditing ? null : widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: Checkbox(
                        value: task.isCompleted,
                        onChanged: (_) => widget.onToggle(),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: isEditing && _controller != null && _focusNode != null
                        ? TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            maxLines: null,
                            minLines: 1,
                            cursorColor: colorScheme.primary,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 15,
                              height: 1.35,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: Theme.of(context).scaffoldBackgroundColor,
                              contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            onSubmitted: (_) => _commitEdit(),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                task.title,
                                maxLines: null,
                                softWrap: true,
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 15,
                                  height: 1.35,
                                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isEditing)
                        IconButton(
                          icon: const Icon(Icons.check, size: 22),
                          onPressed: _commitEdit,
                          color: colorScheme.primary,
                          style: IconButton.styleFrom(
                            minimumSize: const Size(44, 44),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                      else ...[
                        if (task.deadline != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(Icons.schedule_outlined, size: 18, color: colorScheme.onSurfaceVariant),
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 22),
                          onPressed: widget.onDelete,
                          color: colorScheme.onSurfaceVariant,
                          style: IconButton.styleFrom(
                            minimumSize: const Size(44, 44),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RepeatChip extends StatelessWidget {
  final String label;
  final String? value;
  final String? current;
  final VoidCallback onTap;

  const _RepeatChip({required this.label, required this.value, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selected = current == value;
    final colorScheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: colorScheme.primary,
      checkmarkColor: colorScheme.onPrimary,
      side: BorderSide(color: selected ? colorScheme.primary : colorScheme.outline),
    );
  }
}
