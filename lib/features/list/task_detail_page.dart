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

  static final GlobalKey<_TaskDetailContentState> _contentKey = GlobalKey<_TaskDetailContentState>();

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
          return _TaskDetailContent(key: _contentKey, task: task, db: db);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _contentKey.currentState?.saveChanges(),
        backgroundColor: AppColors.actionAccent,
        child: const Icon(Icons.check, color: Colors.white),
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
  bool _titleDirty = false;
  bool _descDirty = false;

  /// Called by the FAB to persist title and description.
  void saveChanges() {
    _saveTitle();
    _saveDescription();
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description ?? '');
    _addSubtaskController = TextEditingController();
    _titleController.addListener(() => setState(() => _titleDirty = true));
    _descController.addListener(() => setState(() => _descDirty = true));
  }

  @override
  void didUpdateWidget(_TaskDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.id != widget.task.id ||
        oldWidget.task.title != widget.task.title ||
        oldWidget.task.description != widget.task.description) {
      if (!_titleDirty) _titleController.text = widget.task.title;
      if (!_descDirty) _descController.text = widget.task.description ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _addSubtaskController.dispose();
    super.dispose();
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
    setState(() => _titleDirty = false);
  }

  Future<void> _saveDescription() async {
    final desc = _descController.text.trim();
    await widget.db.updateTaskById(widget.task.id, TasksCompanion(description: Value(desc.isEmpty ? null : desc)));
    setState(() => _descDirty = false);
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
  static const double _spaceBlock = 24;
  static const double _spaceRow = 16;
  static const double _minTouchTarget = 44;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // —— Task Details card ——
          _SectionCard(
            title: 'Task Details',
            colorScheme: colorScheme,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                TextField(
                  controller: _titleController,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: 'New Task Title',
                    hintStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onSubmitted: (_) => _saveTitle(),
                ),
                const SizedBox(height: 16),
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
                  onSubmitted: (_) => _saveDescription(),
                ),
              ],
            ),
          ),
          const SizedBox(height: _spaceSection),
          // —— Time & Schedule card ——
          _SectionCard(
            title: 'Time & Schedule',
            colorScheme: colorScheme,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: _spaceBlock),
                // Due date row (value as pill with icon when set)
                _ScheduleRow(
                  label: 'Due date',
                  valueWidget: widget.task.deadline != null
                      ? _DueDatePill(
                          dateTime: widget.task.deadline!,
                          colorScheme: colorScheme,
                        )
                      : Text('Not set', style: TextStyle(color: colorScheme.onSurface, fontSize: 15)),
                  colorScheme: colorScheme,
                  minTouchTarget: _minTouchTarget,
                  actions: [
                    _ScheduleIconButton(icon: Icons.edit_outlined, onPressed: _pickDeadline, colorScheme: colorScheme),
                    if (widget.task.deadline != null)
                      _ScheduleIconButton(icon: Icons.close, onPressed: () => _saveDeadline(null), colorScheme: colorScheme),
                  ],
                ),
                  // Reminders only when due date is set
                  if (widget.task.deadline != null) ...[
                    const SizedBox(height: _spaceRow),
                    Text(
                      'Reminders',
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final now = DateTime.now();
                        final minutesUntilDeadline = widget.task.deadline!.difference(now).inMinutes;
                        final relevantOptions = kReminderOptions.where((minutes) => minutesUntilDeadline >= minutes).toList();
                        if (relevantOptions.isEmpty) {
                          return Text(
                            'Due too soon for reminders',
                            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                          );
                        }
                        return Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: relevantOptions.map((minutes) {
                            final selected = parseReminderMinutes(widget.task.reminderMinutesBefore).contains(minutes);
                            final label = kReminderLabels[minutes] ?? '${minutes}m';
                            return FilterChip(
                              label: Text(label, style: TextStyle(fontSize: 12, color: selected ? colorScheme.onPrimary : colorScheme.onSurface)),
                              selected: selected,
                              onSelected: (v) async {
                                final current = parseReminderMinutes(widget.task.reminderMinutesBefore).toSet();
                                if (v) current.add(minutes); else current.remove(minutes);
                                await _saveReminders(current.toList()..sort());
                              },
                              selectedColor: AppColors.actionAccent,
                              checkmarkColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: _spaceRow),
                  ],
                const SizedBox(height: _spaceRow),
                _ScheduleRow(
                  label: 'Repeat',
                  valueWidget: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.repeat, size: 18, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(
                        RepeatRule.parse(widget.task.rrule)?.toSummary() ?? 'None',
                        style: TextStyle(color: colorScheme.onSurface, fontSize: 15),
                      ),
                    ],
                  ),
                  colorScheme: colorScheme,
                  minTouchTarget: _minTouchTarget,
                  actions: [
                    _ScheduleIconButton(
                      icon: Icons.edit_outlined,
                      onPressed: () async {
                        final rule = await showRepeatEditorSheet(context, initial: RepeatRule.parse(widget.task.rrule));
                        if (!context.mounted) return;
                        final value = rule?.toStorage();
                        await _saveRepeat(value == null || value.isEmpty ? null : value);
                      },
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: _spaceSection),
          _SectionCard(
            title: 'Subtasks',
            colorScheme: colorScheme,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _addSubtaskController,
                        decoration: InputDecoration(
                          hintText: 'Add a subtask...',
                          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                const SizedBox(height: 16),
                StreamBuilder<List<Task>>(
                  stream: widget.db.watchChildrenOf(widget.task.id),
                  builder: (context, snap) {
                    final list = snap.data ?? [];
                    final completed = list.where((t) => t.isCompleted).length;
                    if (list.isNotEmpty) {
                      return Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(bottom: 8),
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
                      children: subtasks.map((t) => _SubtaskTile(
                        task: t,
                        parentTitle: widget.task.title,
                        onToggle: () => _onSubtaskToggle(context, t),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskDetailPage(taskId: t.id),
                          ),
                        ),
                        onDelete: () => _deleteSubtask(context, t),
                      )).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
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
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w600,
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
        const SizedBox(width: 8),
        ...actions.expand((w) => [w, const SizedBox(width: 8)]).toList()..removeLast(),
      ],
    );
  }
}

/// Rounded pill showing calendar icon + date and time on two lines so both are fully visible.
class _DueDatePill extends StatelessWidget {
  final DateTime dateTime;
  final ColorScheme colorScheme;

  const _DueDatePill({required this.dateTime, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('MMM d, yyyy').format(dateTime);
    final timeText = DateFormat('h:mm a').format(dateTime);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateText,
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 2),
                Text(
                  timeText,
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Section card with title (Task Details, Time & Schedule, Subtasks).
class _SectionCard extends StatelessWidget {
  final String title;
  final ColorScheme colorScheme;
  final Widget child;

  const _SectionCard({required this.title, required this.colorScheme, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            child,
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

/// Section to add or edit the completion note for this task (shown when task is completed).
class _SubtaskTile extends StatelessWidget {
  final Task task;
  final String parentTitle;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SubtaskTile({
    required this.task,
    required this.parentTitle,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: SizedBox(
          width: 28,
          height: 28,
          child: Checkbox(
            value: task.isCompleted,
            onChanged: (_) => onToggle(),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Subtask of $parentTitle',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.deadline != null)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(Icons.schedule_outlined, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 22),
              onPressed: onDelete,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
        onTap: onTap,
      ),
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
