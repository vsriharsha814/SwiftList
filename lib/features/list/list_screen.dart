import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:to_do_flutter_app/core/settings/app_settings.dart';
import 'package:to_do_flutter_app/core/theme/app_colors.dart';
import 'package:to_do_flutter_app/data/database/app_database.dart';
import 'package:to_do_flutter_app/features/list/task_detail_page.dart';
import 'package:to_do_flutter_app/pages/settings_page.dart';

/// Pillar 1: The Infinite List — hierarchical tasks, one level at a time.
class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  String? _currentParentId;
  String? _parentTitle;
  final _quickAddController = TextEditingController();

  @override
  void dispose() {
    _quickAddController.dispose();
    super.dispose();
  }

  /// Weighted progress for a list of tasks: sum(weight where completed) / sum(weight).
  static double weightedProgress(List<Task> tasks) {
    if (tasks.isEmpty) return 0;
    final totalWeight = tasks.fold<int>(0, (s, t) => s + t.weight);
    if (totalWeight == 0) return 0;
    final completedWeight = tasks.where((t) => t.isCompleted).fold<int>(0, (s, t) => s + t.weight);
    return completedWeight / totalWeight;
  }

  /// Sort: overdue incomplete first, then soonest deadline, then no deadline, then completed.
  static List<Task> sortByDeadline(List<Task> tasks) {
    final now = DateTime.now();
    final sorted = List<Task>.from(tasks);
    sorted.sort((a, b) {
      if (a.isCompleted && !b.isCompleted) return 1;
      if (!a.isCompleted && b.isCompleted) return -1;
      if (a.isCompleted && b.isCompleted) return 0;
      final aOverdue = a.deadline != null && a.deadline!.isBefore(now);
      final bOverdue = b.deadline != null && b.deadline!.isBefore(now);
      if (aOverdue && !bOverdue) return -1;
      if (!aOverdue && bOverdue) return 1;
      if (aOverdue && bOverdue) return a.deadline!.compareTo(b.deadline!);
      if (a.deadline == null && b.deadline == null) return 0;
      if (a.deadline == null) return 1;
      if (b.deadline == null) return -1;
      return a.deadline!.compareTo(b.deadline!);
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      appBar: AppBar(
        title: Text(_parentTitle ?? 'Tasks'),
        leading: _currentParentId != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _navigateToParentLevel(db),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _QuickAddBar(
            controller: _quickAddController,
            hintText: _currentParentId == null ? 'Add a task...' : 'Add a subtask...',
            onAdd: () => _quickAddTask(db),
          ),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: db.watchChildrenOf(_currentParentId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.actionAccent));
                }
                final tasks = snapshot.data!;
                return Consumer<AppSettings>(
            builder: (context, settings, _) {
              final displayTasks = settings.archiveCompletedTasks
                  ? tasks.where((t) => !t.isCompleted).toList()
                  : tasks;
              if (displayTasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inbox_outlined, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        _currentParentId == null ? 'No tasks yet' : 'No subtasks',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        settings.archiveCompletedTasks && tasks.isNotEmpty
                            ? 'All tasks are done and archived'
                            : _currentParentId == null
                                ? 'Type above to add a task'
                                : 'Type above to add a subtask',
                        style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 14),
                      ),
                    ],
                  ),
                );
              }
              final sortedTasks = sortByDeadline(displayTasks);
              final progress = weightedProgress(displayTasks);
          final combinedFuture = db.getTaskIdsWithChildren(sortedTasks).then((ids) async {
            final prog = await db.getSubtaskProgress(ids);
            return (ids, prog);
          });
          return FutureBuilder<(Set<String>, Map<String, ({int completed, int total})>)>(
            future: combinedFuture,
            builder: (context, snapshot) {
              final idsWithChildren = snapshot.data?.$1 ?? {};
              final subtaskProgress = snapshot.data?.$2 ?? {};
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AppColors.slateGray,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.actionAccent),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${(progress * 100).round()}%',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: sortedTasks.length,
                      itemBuilder: (context, index) {
                        final task = sortedTasks[index];
                        final hasChildren = idsWithChildren.contains(task.id);
                        final progressInfo = hasChildren ? subtaskProgress[task.id] : null;
                        return _TaskCard(
                          task: task,
                          parentTitle: _currentParentId != null ? _parentTitle : null,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TaskDetailPage(taskId: task.id),
                            ),
                          ),
                          onDrillDown: hasChildren
                              ? () => setState(() {
                                    _currentParentId = task.id;
                                    _parentTitle = task.title;
                                  })
                              : null,
                          onToggleComplete: () async {
                            if (task.isCompleted) {
                              await db.updateTaskById(task.id, const TasksCompanion(isCompleted: Value(false)));
                            } else {
                              await _markTaskComplete(context, db, task);
                            }
                          },
                          onDelete: () => _deleteTask(context, db, task, hasChildren),
                          hasChildren: hasChildren,
                          subtaskCompleted: progressInfo?.completed,
                          subtaskTotal: progressInfo?.total,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
            },
          );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _quickAddTask(AppDatabase db) async {
    final title = _quickAddController.text.trim();
    if (title.isEmpty) return;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await db.insertTask(TasksCompanion(
      id: Value(id),
      title: Value(title),
      parentId: Value(_currentParentId),
      createdAt: Value(DateTime.now()),
    ));
    _quickAddController.clear();
  }

  void _navigateToParentLevel(AppDatabase db) async {
    if (_currentParentId == null) return;
    final current = await db.getTaskById(_currentParentId!);
    final newParentId = current?.parentId;
    if (newParentId == null) {
      setState(() {
        _currentParentId = null;
        _parentTitle = null;
      });
      return;
    }
    final newParent = await db.getTaskById(newParentId);
    setState(() {
      _currentParentId = newParentId;
      _parentTitle = newParent?.title;
    });
  }

  Future<void> _deleteTask(BuildContext context, AppDatabase db, Task task, bool hasChildren) async {
    if (hasChildren) {
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
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await db.deleteTaskAndDependencies(task.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted')),
        );
      }
    }
  }

  static const _repeatOptions = {'None': null, 'Daily': 'DAILY', 'Weekly': 'WEEKLY', 'Monthly': 'MONTHLY'};

  void _showAddTask(BuildContext context, AppDatabase db) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime? selectedDeadline;
    String? selectedRepeat;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.cardBackground,
              title: Text(_currentParentId == null ? 'New task' : 'New subtask'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Task title',
                        labelText: 'Title',
                      ),
                      onSubmitted: (_) => _saveTask(context, db, titleController, descController, selectedDeadline, selectedRepeat),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Description (optional)',
                        labelText: 'Description',
                        alignLabelWithHint: true,
                      ),
                      onSubmitted: (_) => _saveTask(context, db, titleController, descController, selectedDeadline, selectedRepeat),
                    ),
                    const SizedBox(height: 16),
                    const Text('Repeat', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: _repeatOptions.entries.map((e) {
                        final isSelected = selectedRepeat == e.value;
                        return ChoiceChip(
                          label: Text(e.key),
                          selected: isSelected,
                          onSelected: (_) => setDialogState(() => selectedRepeat = e.value),
                          selectedColor: AppColors.actionAccent.withOpacity(0.3),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (date != null && context.mounted) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setDialogState(() {
                              selectedDeadline = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        }
                      },
                      icon: Icon(
                        selectedDeadline == null ? Icons.calendar_today : Icons.edit_calendar,
                        size: 20,
                        color: AppColors.actionAccent,
                      ),
                      label: Text(
                        selectedDeadline == null
                            ? 'Set due date & time (optional)'
                            : DateFormat('MMM d, yyyy · h:mm a').format(selectedDeadline!),
                        style: TextStyle(
                          color: selectedDeadline == null
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => _saveTask(context, db, titleController, descController, selectedDeadline, selectedRepeat),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveTask(
    BuildContext context,
    AppDatabase db,
    TextEditingController titleController,
    TextEditingController descController, [
    DateTime? deadline,
    String? repeat,
  ]) async {
    final title = titleController.text.trim();
    if (title.isEmpty) return;
    final description = descController.text.trim();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await db.insertTask(TasksCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description.isEmpty ? null : description),
      parentId: Value(_currentParentId),
      deadline: Value(deadline),
      rrule: Value(repeat),
      createdAt: Value(DateTime.now()),
    ));
    if (context.mounted) Navigator.pop(context);
  }

  /// Marks task complete, optionally asks for comment, logs completion, and spawns next if recurring.
  Future<void> _markTaskComplete(BuildContext context, AppDatabase db, Task task) async {
    final comment = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final c = TextEditingController();
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: const Text('Task completed'),
          content: TextField(
            controller: c,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Add a comment (optional)',
              labelText: 'Comment',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Skip'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, c.text.trim()),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
    if (!context.mounted) return;
    await db.updateTaskById(task.id, const TasksCompanion(isCompleted: Value(true)));
    final logId = DateTime.now().millisecondsSinceEpoch.toString();
    await db.insertCompletionLog(CompletionLogsCompanion(
      id: Value(logId),
      taskId: Value(task.id),
      taskTitle: Value(task.title),
      completedAt: Value(DateTime.now()),
      comment: Value(comment != null && comment.isNotEmpty ? comment : null),
    ));
    if (task.rrule != null && task.rrule!.isNotEmpty) {
      final now = DateTime.now();
      DateTime next = task.deadline != null && task.deadline!.isAfter(now)
          ? task.deadline!
          : now;
      switch (task.rrule!) {
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
      await db.insertNextRecurrence(task, next);
    }
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final String? parentTitle;
  final VoidCallback onTap;
  final VoidCallback? onDrillDown;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;
  final bool? hasChildren;
  final int? subtaskCompleted;
  final int? subtaskTotal;

  const _TaskCard({
    required this.task,
    required this.parentTitle,
    required this.onTap,
    this.onDrillDown,
    required this.onToggleComplete,
    required this.onDelete,
    this.hasChildren,
    this.subtaskCompleted,
    this.subtaskTotal,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isOverdue = !task.isCompleted &&
        task.deadline != null &&
        task.deadline!.isBefore(now);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isOverdue ? AppColors.slateGray.withOpacity(0.8) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: Checkbox(
                  value: task.isCompleted,
                  onChanged: (_) => onToggleComplete(),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        if (hasChildren == true)
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 24),
                            onPressed: onDrillDown,
                            tooltip: 'View subtasks',
                          ),
                      ],
                    ),
                    if (parentTitle != null && parentTitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Subtask of $parentTitle',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                    if (hasChildren == true && subtaskTotal != null && subtaskTotal! > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '$subtaskCompleted/$subtaskTotal subtasks',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: (subtaskCompleted ?? 0) / subtaskTotal!,
                                backgroundColor: AppColors.slateGray,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.actionAccent),
                                minHeight: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (task.deadline != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: isOverdue ? Colors.red : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOverdue
                                ? 'Overdue · ${DateFormat('MMM d, h:mm a').format(task.deadline!)}'
                                : 'Due ${DateFormat('MMM d, h:mm a').format(task.deadline!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isOverdue ? Colors.red : AppColors.textSecondary,
                              fontWeight: isOverdue ? FontWeight.w600 : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (task.rrule != null && task.rrule!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.repeat, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            'Repeats ${task.rrule!.toLowerCase()}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAddBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onAdd;

  const _QuickAddBar({
    required this.controller,
    required this.hintText,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.slateGray,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: false,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: AppColors.textSecondary),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
              onSubmitted: (_) => onAdd(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.actionAccent),
            onPressed: onAdd,
            tooltip: 'Add task',
          ),
        ],
      ),
    );
  }
}
