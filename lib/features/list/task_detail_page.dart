import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:to_do_flutter_app/core/settings/app_settings.dart';
import 'package:to_do_flutter_app/core/theme/app_colors.dart';
import 'package:to_do_flutter_app/data/database/app_database.dart';

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
        backgroundColor: AppColors.cardBackground,
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete task?'),
        content: const Text('This cannot be undone.'),
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

  Future<void> _onSubtaskToggle(BuildContext context, Task t) async {
    if (t.isCompleted) {
      await widget.db.updateTaskById(t.id, const TasksCompanion(isCompleted: Value(false)));
      return;
    }
    final comment = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final c = TextEditingController();
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: const Text('Subtask completed'),
          content: TextField(
            controller: c,
            maxLines: 2,
            decoration: const InputDecoration(hintText: 'Add a comment (optional)', labelText: 'Comment'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Skip')),
            FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('Done')),
          ],
        );
      },
    );
    if (!context.mounted) return;
    await widget.db.updateTaskById(t.id, const TasksCompanion(isCompleted: Value(true)));
    final logId = DateTime.now().millisecondsSinceEpoch.toString();
    await widget.db.insertCompletionLog(CompletionLogsCompanion(
      id: Value(logId),
      taskId: Value(t.id),
      taskTitle: Value(t.title),
      completedAt: Value(DateTime.now()),
      comment: Value(comment != null && comment.isNotEmpty ? comment : null),
    ));
    if (t.rrule != null && t.rrule!.isNotEmpty) {
      final now = DateTime.now();
      DateTime next = t.deadline != null && t.deadline!.isAfter(now) ? t.deadline! : now;
      switch (t.rrule!) {
        case 'DAILY':
          next = next.add(const Duration(days: 1));
          break;
        case 'WEEKLY':
          next = next.add(const Duration(days: 7));
          break;
        case 'MONTHLY':
          next = DateTime(next.year, next.month + 1, next.day, next.hour, next.minute);
          break;
        default:
          next = next.add(const Duration(days: 1));
      }
      await widget.db.insertNextRecurrence(t, next);
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
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              hintText: 'Task title',
              hintStyle: TextStyle(color: AppColors.textSecondary),
              border: InputBorder.none,
              isDense: true,
            ),
            onSubmitted: (_) => _saveTitle(),
          ),
          if (widget.task.deadline != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'Due ${DateFormat('MMM d, yyyy · h:mm a').format(widget.task.deadline!)}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'Description',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _descController,
            maxLines: 4,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Add a description...',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.slateGray,
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
          const Text('Repeat', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              _RepeatChip(label: 'None', value: null, current: widget.task.rrule, onTap: () => _saveRepeat(null)),
              _RepeatChip(label: 'Daily', value: 'DAILY', current: widget.task.rrule, onTap: () => _saveRepeat('DAILY')),
              _RepeatChip(label: 'Weekly', value: 'WEEKLY', current: widget.task.rrule, onTap: () => _saveRepeat('WEEKLY')),
              _RepeatChip(label: 'Monthly', value: 'MONTHLY', current: widget.task.rrule, onTap: () => _saveRepeat('MONTHLY')),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text(
                'Subtasks',
                style: TextStyle(
                  color: AppColors.textPrimary,
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
                      color: AppColors.slateGray,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$completed/${list.length}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontFeatures: [FontFeature.tabularFigures()],
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
              return Consumer<AppSettings>(
                builder: (context, settings, _) {
                  final displaySubtasks = settings.archiveCompletedTasks
                      ? subtasks.where((t) => !t.isCompleted).toList()
                      : subtasks;
                  if (displaySubtasks.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        subtasks.isEmpty
                            ? 'No subtasks yet. Tap + to add one.'
                            : 'All subtasks done and archived.',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                    );
                  }
                  return Column(
                    children: displaySubtasks.map((t) => _SubtaskTile(
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Delete subtask?'),
        content: Text('Delete "${t.title}"?'),
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
            color: AppColors.textPrimary,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Subtask of $parentTitle',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 22),
          onPressed: onDelete,
          color: AppColors.textSecondary,
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
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.actionAccent.withOpacity(0.3),
    );
  }
}
