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
        title: const Text('Task'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSubtask(context, db),
        child: const Icon(Icons.add),
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

  const _TaskDetailContent({required this.task, required this.db});

  @override
  State<_TaskDetailContent> createState() => _TaskDetailContentState();
}

class _TaskDetailContentState extends State<_TaskDetailContent> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  bool _titleDirty = false;
  bool _descDirty = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description ?? '');
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
    super.dispose();
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
    await widget.db.updateTaskById(widget.task.id, TasksCompanion(deadline: Value(deadline)));
    if (deadline == null) {
      await cancelTaskReminders(widget.task.id);
    } else {
      final minutes = parseReminderMinutes(widget.task.reminderMinutesBefore);
      if (minutes.isNotEmpty) {
        await scheduleTaskReminders(
          taskId: widget.task.id,
          title: widget.task.title,
          deadline: deadline,
          minutesBefore: minutes,
        );
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
      await scheduleTaskReminders(
        taskId: widget.task.id,
        title: widget.task.title,
        deadline: widget.task.deadline!,
        minutesBefore: minutes,
      );
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
          await scheduleTaskReminders(taskId: newId, title: t.title, deadline: next, minutesBefore: reminderMins);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _titleController,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'Task title',
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              border: InputBorder.none,
              isDense: true,
            ),
            onSubmitted: (_) => _saveTitle(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Due date', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.task.deadline != null
                      ? DateFormat('MMM d, yyyy · h:mm a').format(widget.task.deadline!)
                      : 'Not set',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                ),
              ),
              TextButton(
                onPressed: _pickDeadline,
                child: const Text('Edit'),
              ),
              if (widget.task.deadline != null)
                TextButton(
                  onPressed: () => _saveDeadline(null),
                  child: const Text('Clear'),
                ),
            ],
          ),
          if (widget.task.deadline != null) ...[
            const SizedBox(height: 12),
            Text('Reminders', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final now = DateTime.now();
                final minutesUntilDeadline = widget.task.deadline!.difference(now).inMinutes;
                final relevantOptions = kReminderOptions.where((minutes) => minutesUntilDeadline >= minutes).toList();
                if (relevantOptions.isEmpty) {
                  return Text(
                    'Due too soon for reminders',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                  );
                }
                return Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: relevantOptions.map((minutes) {
                    final selected = parseReminderMinutes(widget.task.reminderMinutesBefore).contains(minutes);
                    final label = kReminderLabels[minutes] ?? '${minutes}m';
                    return FilterChip(
                      label: Text(label, style: TextStyle(fontSize: 12, color: selected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface)),
                      selected: selected,
                      onSelected: (v) async {
                        final current = parseReminderMinutes(widget.task.reminderMinutesBefore).toSet();
                        if (v) current.add(minutes); else current.remove(minutes);
                        await _saveReminders(current.toList()..sort());
                      },
                      selectedColor: Theme.of(context).colorScheme.primary,
                      checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 16),
          Text(
            'Description',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _descController,
            maxLines: 4,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Add a description...',
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) => _saveDescription(),
          ),
          if (_titleDirty || _descDirty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton(
                onPressed: () async {
                  await _saveTitle();
                  await _saveDescription();
                },
                child: const Text('Save changes'),
              ),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text('Repeat', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  RepeatRule.parse(widget.task.rrule)?.toSummary() ?? 'None',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final rule = await showRepeatEditorSheet(context, initial: RepeatRule.parse(widget.task.rrule));
                  if (!context.mounted) return;
                  final value = rule?.toStorage();
                  await _saveRepeat(value == null || value.isEmpty ? null : value);
                },
                child: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Subtasks',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              StreamBuilder<List<Task>>(
                stream: widget.db.watchChildrenOf(widget.task.id),
                builder: (context, snap) {
                  final list = snap.data ?? [];
                  final completed = list.where((t) => t.isCompleted).length;
                  if (list.isEmpty) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$completed/${list.length}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 13,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<Task>>(
            stream: widget.db.watchChildrenOf(widget.task.id),
            builder: (context, snapshot) {
              final subtasks = snapshot.data ?? [];
              if (subtasks.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No subtasks yet. Tap + to add one.',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
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
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 22),
          onPressed: onDelete,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
