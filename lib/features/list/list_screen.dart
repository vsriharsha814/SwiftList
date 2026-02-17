import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:to_do_flutter_app/core/theme/app_colors.dart';
import 'package:to_do_flutter_app/data/database/app_database.dart';
import 'package:to_do_flutter_app/util/repeat_rule.dart';
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
  bool _showingArchive = false;
  final Set<String> _selectedTaskIds = {};
  final _quickAddController = TextEditingController();

  bool get _selectionMode => _selectedTaskIds.isNotEmpty;

  void _exitSelectionMode() {
    setState(() => _selectedTaskIds.clear());
  }

  void _toggleTaskSelection(String taskId) {
    setState(() {
      if (_selectedTaskIds.contains(taskId)) {
        _selectedTaskIds.remove(taskId);
      } else {
        _selectedTaskIds.add(taskId);
      }
    });
  }

  void _selectTaskOnLongPress(String taskId) {
    setState(() {
      _selectedTaskIds.add(taskId);
    });
  }

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

  /// Sort by date added (createdAt), oldest first.
  static List<Task> sortByDateAdded(List<Task> tasks) {
    final sorted = List<Task>.from(tasks);
    sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return sorted;
  }

  /// Incomplete first (by createdAt), then completed at bottom in order they were checked off (completedAt ascending).
  static List<Task> sortIncompleteFirstThenCompletedByCheckedOff(List<Task> tasks) {
    final sorted = List<Task>.from(tasks);
    sorted.sort((a, b) {
      if (!a.isCompleted && b.isCompleted) return -1;
      if (a.isCompleted && !b.isCompleted) return 1;
      if (!a.isCompleted && !b.isCompleted) return a.createdAt.compareTo(b.createdAt);
      // Both completed: by completedAt (null = treat as oldest, so first)
      final aAt = a.completedAt ?? DateTime(0);
      final bAt = b.completedAt ?? DateTime(0);
      return aAt.compareTo(bAt);
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectionMode
              ? '${_selectedTaskIds.length} selected'
              : (_showingArchive ? 'Archive' : (_parentTitle ?? 'Tasks')),
        ),
        leading: _selectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Cancel',
                onPressed: _exitSelectionMode,
              )
            : _showingArchive
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => setState(() => _showingArchive = false),
                  )
                : _currentParentId != null
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => _navigateToParentLevel(db),
                      )
                    : null,
        actions: [
          if (_selectionMode) ...[
            IconButton(
              icon: Icon(_showingArchive ? Icons.unarchive_outlined : Icons.archive_outlined),
              tooltip: _showingArchive ? 'Unarchive selected' : 'Archive selected',
              onPressed: () => _showingArchive ? _unarchiveSelectedTasks(context, db) : _archiveSelectedTasks(context, db),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete selected',
              onPressed: () => _deleteSelectedTasks(context, db),
            ),
          ] else ...[
            IconButton(
              icon: Icon(_showingArchive ? Icons.inbox_outlined : Icons.archive_outlined),
              tooltip: _showingArchive ? 'Back to tasks' : 'View archive',
              onPressed: () => setState(() => _showingArchive = !_showingArchive),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ),
            ),
          ],
        ],
      ),
      body: StreamBuilder<List<Task>>(
        stream: _currentParentId == null
            ? db.watchAllTasks()
            : db.watchChildrenOf(_currentParentId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.actionAccent));
          }
          final rawTasks = snapshot.data!;
          // On main page: show root tasks + their direct subtasks. In drill-down: show only children.
          final tasks = _currentParentId == null
              ? () {
                  final rootIds = rawTasks.where((t) => t.parentId == null).map((t) => t.id).toSet();
                  return rawTasks
                      .where((t) => t.parentId == null || rootIds.contains(t.parentId))
                      .toList();
                }()
              : rawTasks;
          final showingArchive = _showingArchive;
          // Main list: show all non-archived tasks (completed stay visible until user archives). Archive view: show archived only.
          final displayTasks = showingArchive
                  ? tasks.where((t) => t.isArchived).toList()
                  : () {
                      if (_currentParentId != null) {
                        return tasks.where((t) => !t.isArchived).toList();
                      }
                      final visibleRootIds = tasks
                          .where((t) => t.parentId == null && !t.isArchived)
                          .map((t) => t.id)
                          .toSet();
                      return tasks
                          .where((t) =>
                              t.parentId == null
                                  ? !t.isArchived
                                  : visibleRootIds.contains(t.parentId) && !t.isArchived)
                          .toList();
                    }();
              final sortedTasks = sortIncompleteFirstThenCompletedByCheckedOff(displayTasks);
              // Progress: incomplete, non-archived tasks only.
              final activeTasks = tasks.where((t) => !t.isCompleted && !t.isArchived).toList();
              final progress = !showingArchive && activeTasks.isNotEmpty
                  ? weightedProgress(activeTasks)
                  : 0.0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!showingArchive)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.actionAccent),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${(progress * 100).round()}%',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 12,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (showingArchive && displayTasks.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Text(
                        '${displayTasks.length} archived',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  Expanded(
                    child: displayTasks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  showingArchive ? Icons.archive_outlined : Icons.inbox_outlined,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  showingArchive
                                      ? 'No archived tasks'
                                      : _currentParentId == null
                                          ? 'No tasks yet'
                                          : 'No subtasks',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 18),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  showingArchive
                                      ? 'No archived tasks'
                                      : tasks.isNotEmpty
                                          ? 'All tasks are archived'
                                          : _currentParentId == null
                                              ? 'Type below to add a task'
                                              : 'Type below to add a subtask',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8), fontSize: 14),
                                ),
                              ],
                            ),
                          )
                        : FutureBuilder<(Set<String>, Map<String, ({int completed, int total})>)>(
                            future: db.getTaskIdsWithChildren(sortedTasks).then((ids) async {
                              final prog = await db.getSubtaskProgress(ids);
                              return (ids, prog);
                            }),
                            builder: (context, listSnapshot) {
                              final idsWithChildren = listSnapshot.data?.$1 ?? {};
                              final subtaskProgress = listSnapshot.data?.$2 ?? {};
                              final idToTask = {for (var t in sortedTasks) t.id: t};
                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                itemCount: sortedTasks.length,
                                itemBuilder: (context, index) {
                                  final task = sortedTasks[index];
                                  final hasChildren = idsWithChildren.contains(task.id);
                                  final progressInfo = hasChildren ? subtaskProgress[task.id] : null;
                                  final parentTitleForCard = _currentParentId != null
                                      ? _parentTitle
                                      : (task.parentId != null ? idToTask[task.parentId]?.title : null);
                                  final inSelectionMode = _selectionMode;
                                  return _TaskCard(
                                    task: task,
                                    parentTitle: parentTitleForCard,
                                    onTap: inSelectionMode
                                        ? () => _toggleTaskSelection(task.id)
                                        : () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => TaskDetailPage(taskId: task.id),
                                              ),
                                            ),
                                    onDrillDown: inSelectionMode
                                        ? null
                                        : hasChildren
                                            ? () => setState(() {
                                                  _currentParentId = task.id;
                                                  _parentTitle = task.title;
                                                })
                                            : null,
                                    onToggleComplete: () async {
                                      if (task.isCompleted) {
                                        await db.updateTaskById(task.id, const TasksCompanion(isCompleted: Value(false), completedAt: Value(null)));
                                      } else {
                                        await _markTaskComplete(context, db, task);
                                      }
                                    },
                                    hasChildren: hasChildren,
                                    subtaskCompleted: progressInfo?.completed,
                                    subtaskTotal: progressInfo?.total,
                                    isSelectionMode: inSelectionMode,
                                    isSelected: _selectedTaskIds.contains(task.id),
                                    onLongPress: () => _selectTaskOnLongPress(task.id),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                  if (!showingArchive)
                    _QuickAddBar(
                      controller: _quickAddController,
                      hintText: _currentParentId == null ? 'Add a task...' : 'Add a subtask...',
                      onAdd: () => _quickAddTask(db),
                    ),
                ],
              );
        },
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

  Future<void> _archiveSelectedTasks(BuildContext context, AppDatabase db) async {
    if (_selectedTaskIds.isEmpty) return;
    final count = _selectedTaskIds.length;
    for (final id in _selectedTaskIds) {
      await db.updateTaskById(id, const TasksCompanion(isArchived: Value(true)));
    }
    setState(() => _selectedTaskIds.clear());
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(count == 1 ? 'Task archived' : '$count tasks archived')),
      );
    }
  }

  Future<void> _unarchiveSelectedTasks(BuildContext context, AppDatabase db) async {
    if (_selectedTaskIds.isEmpty) return;
    final count = _selectedTaskIds.length;
    for (final id in _selectedTaskIds) {
      await db.updateTaskById(id, const TasksCompanion(isArchived: Value(false)));
    }
    setState(() => _selectedTaskIds.clear());
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(count == 1 ? 'Task restored' : '$count tasks restored')),
      );
    }
  }

  Future<void> _deleteSelectedTasks(BuildContext context, AppDatabase db) async {
    if (_selectedTaskIds.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete selected?'),
        content: Text('Delete ${_selectedTaskIds.length} task(s)? This cannot be undone.'),
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
    if (!context.mounted || confirmed != true) return;
    int deleted = 0;
    int skipped = 0;
    for (final id in _selectedTaskIds) {
      final children = await db.childrenOf(id);
      if (children.isNotEmpty) {
        skipped++;
      } else {
        await db.deleteTaskAndDependencies(id);
        deleted++;
      }
    }
    setState(() => _selectedTaskIds.clear());
    if (!context.mounted) return;
    if (skipped > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted $deleted. $skipped have subtasks and were not deleted.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(deleted == 1 ? 'Task deleted' : '$deleted tasks deleted')),
      );
    }
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
                    Text('Repeat', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: _repeatOptions.entries.map((e) {
                        final isSelected = selectedRepeat == e.value;
                        final colorScheme = Theme.of(context).colorScheme;
                        return ChoiceChip(
                          label: Text(
                            e.key,
                            style: TextStyle(
                              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) => setDialogState(() => selectedRepeat = e.value),
                          selectedColor: colorScheme.primary,
                          checkmarkColor: colorScheme.onPrimary,
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
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : Theme.of(context).colorScheme.onSurface,
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

  /// Marks task complete and spawns next if recurring.
  Future<void> _markTaskComplete(BuildContext context, AppDatabase db, Task task) async {
    final now = DateTime.now();
    await db.updateTaskById(task.id, TasksCompanion(isCompleted: const Value(true), completedAt: Value(now)));
    if (task.rrule != null && task.rrule!.isNotEmpty) {
      final from = task.deadline != null && task.deadline!.isAfter(now) ? task.deadline! : now;
      final next = getNextOccurrenceFromRrule(task.rrule, from);
      if (next != null) await db.insertNextRecurrence(task, next);
    }
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final String? parentTitle;
  final VoidCallback onTap;
  final VoidCallback? onDrillDown;
  final VoidCallback onToggleComplete;
  final bool? hasChildren;
  final int? subtaskCompleted;
  final int? subtaskTotal;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onLongPress;

  const _TaskCard({
    required this.task,
    required this.parentTitle,
    required this.onTap,
    this.onDrillDown,
    required this.onToggleComplete,
    this.hasChildren,
    this.subtaskCompleted,
    this.subtaskTotal,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isOverdue = !task.isCompleted &&
        task.deadline != null &&
        task.deadline!.isBefore(now);

    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isOverdue
          ? colorScheme.errorContainer.withOpacity(0.5)
          : (isSelected ? colorScheme.primaryContainer.withOpacity(0.5) : null),
      child: InkWell(
        onTap: onTap,
        onLongPress: isSelectionMode ? null : onLongPress,
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
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 16,
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        if (hasChildren == true)
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            icon: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 24),
                            onPressed: onDrillDown,
                            tooltip: 'View subtasks',
                          ),
                      ],
                    ),
                    if (parentTitle != null && parentTitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Subtask of $parentTitle',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                    if (hasChildren == true && subtaskTotal != null && subtaskTotal! > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '$subtaskCompleted/$subtaskTotal subtasks',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 12,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: (subtaskCompleted ?? 0) / subtaskTotal!,
                                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                            color: isOverdue ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOverdue
                                ? 'Overdue · ${DateFormat('MMM d, h:mm a').format(task.deadline!)}'
                                : 'Due ${DateFormat('MMM d, h:mm a').format(task.deadline!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isOverdue ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant,
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
                          Icon(Icons.repeat, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            'Repeats ${RepeatRule.parse(task.rrule)?.toSummary() ?? task.rrule!.toLowerCase()}',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelectionMode)
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => onTap(),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: false,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.4), width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                isDense: true,
              ),
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              onSubmitted: (_) => onAdd(),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.add, color: colorScheme.onPrimary, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
