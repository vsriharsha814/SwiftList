import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

/// Tasks table: hierarchical nodes with optional recurrence and deadline.
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get parentId => text().nullable().references(Tasks, #id)();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get rrule => text().nullable()();
  DateTimeColumn get deadline => dateTime().nullable()();
  IntColumn get weight => integer().withDefault(const Constant(1))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get projectName => text().nullable()();
  IntColumn get countdownMinutes => integer().nullable()(); // Pomodoro default e.g. 25
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Time entries logged when a timer is stopped (countdown complete or stopwatch paused).
class TimeLogs extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text().references(Tasks, #id)();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  IntColumn get durationSeconds => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Exception dates for recurring tasks: "skip this occurrence only".
class Exdates extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text().references(Tasks, #id)();
  DateTimeColumn get exceptionDate => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Log when a task is completed, with optional comment. Used for Pulse "completion notes".
class CompletionLogs extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text()();
  TextColumn get taskTitle => text()();
  DateTimeColumn get completedAt => dateTime()();
  TextColumn get comment => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Tasks, TimeLogs, Exdates, CompletionLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.addColumn(tasks, tasks.description);
          }
          if (from < 3) {
            await migrator.createTable(completionLogs);
          }
          if (from < 4) {
            await migrator.addColumn(tasks, tasks.isArchived);
          }
          if (from < 5) {
            await migrator.addColumn(tasks, tasks.completedAt);
          }
        },
      );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'zen_studio.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }

  // --- Tasks ---
  Future<List<Task>> get allTasks => select(tasks).get();
  Future<List<Task>> get rootTasks => (select(tasks)..where((t) => t.parentId.isNull())).get();
  Stream<List<Task>> watchRootTasks() => (select(tasks)..where((t) => t.parentId.isNull())).watch();

  Future<List<Task>> childrenOf(String? parentId) {
    if (parentId == null || parentId.isEmpty) return rootTasks;
    return (select(tasks)..where((t) => t.parentId.equals(parentId))).get();
  }

  Stream<List<Task>> watchChildrenOf(String? parentId) {
    if (parentId == null || parentId.isEmpty) return watchRootTasks();
    return (select(tasks)..where((t) => t.parentId.equals(parentId))).watch();
  }

  /// All tasks (for main page: root + subtasks sorted by date added).
  Stream<List<Task>> watchAllTasks() => select(tasks).watch();

  Future<Task?> getTaskById(String id) => (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Stream of a single task by id (for detail page).
  Stream<Task?> watchTaskById(String id) =>
      (select(tasks)..where((t) => t.id.equals(id))).watch().map((list) => list.isNotEmpty ? list.first : null);

  /// Stream of completed task count (for milestones).
  Stream<int> watchCompletedTaskCount() =>
      (select(tasks)..where((t) => t.isCompleted.equals(true))).watch().map((list) => list.length);

  /// Returns task IDs that have at least one child (for showing drill-down chevron).
  Future<Set<String>> getTaskIdsWithChildren(List<Task> taskList) async {
    if (taskList.isEmpty) return {};
    final ids = taskList.map((t) => t.id).toSet();
    final parents = await (select(tasks)..where((t) => t.parentId.isIn(ids))).get();
    return parents.map((t) => t.parentId!).toSet();
  }

  /// For each parent id in [parentIds], returns (completedCount, totalCount) of direct children.
  Future<Map<String, ({int completed, int total})>> getSubtaskProgress(Set<String> parentIds) async {
    if (parentIds.isEmpty) return {};
    final children = await (select(tasks)..where((t) => t.parentId.isIn(parentIds))).get();
    final map = <String, ({int completed, int total})>{};
    for (final parentId in parentIds) {
      final list = children.where((c) => c.parentId == parentId).toList();
      final completed = list.where((c) => c.isCompleted).length;
      map[parentId] = (completed: completed, total: list.length);
    }
    return map;
  }
  Future<void> insertTask(TasksCompanion c) => into(tasks).insert(c);
  Future<int> updateTaskById(String id, TasksCompanion c) =>
      (update(tasks)..where((t) => t.id.equals(id))).write(c);
  Future<int> deleteTaskById(String id) => (delete(tasks)..where((t) => t.id.equals(id))).go();

  /// Deletes a task and its time logs, exdates, and completion logs (use when task has no children).
  Future<void> deleteTaskAndDependencies(String id) async {
    await (delete(timeLogs)..where((t) => t.taskId.equals(id))).go();
    await (delete(exdates)..where((e) => e.taskId.equals(id))).go();
    await deleteCompletionLogsForTask(id);
    await deleteTaskById(id);
  }

  /// Inserts the next occurrence for a recurring task (call after completing one).
  Future<void> insertNextRecurrence(Task completed, DateTime nextDeadline) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await into(tasks).insert(TasksCompanion(
      id: Value(id),
      title: Value(completed.title),
      description: Value(completed.description),
      parentId: Value(completed.parentId),
      rrule: Value(completed.rrule),
      deadline: Value(nextDeadline),
      createdAt: Value(DateTime.now()),
    ));
  }

  // --- Completion logs (for Pulse) ---
  Future<void> insertCompletionLog(CompletionLogsCompanion c) => into(completionLogs).insert(c);
  Stream<List<CompletionLog>> watchCompletionLogs({int limit = 50}) =>
      (select(completionLogs)..orderBy([(t) => OrderingTerm.desc(t.completedAt)])..limit(limit)).watch();

  /// Latest completion log for a task (for adding/editing comment on task detail).
  Stream<CompletionLog?> watchLatestCompletionLogForTask(String taskId) =>
      (select(completionLogs)
            ..where((c) => c.taskId.equals(taskId))
            ..orderBy([(t) => OrderingTerm.desc(t.completedAt)])
            ..limit(1))
          .watch()
          .map((list) => list.isNotEmpty ? list.first : null);

  Future<int> updateCompletionLogComment(String logId, String? comment) =>
      (update(completionLogs)..where((c) => c.id.equals(logId)))
          .write(CompletionLogsCompanion(comment: Value(comment)));

  // --- Time logs ---
  Future<void> insertTimeLog(TimeLogsCompanion c) => into(timeLogs).insert(c);
  Future<List<TimeLog>> getTimeLogsForTask(String taskId) =>
      (select(timeLogs)..where((t) => t.taskId.equals(taskId))).get();
  Stream<List<TimeLog>> watchAllTimeLogs() => select(timeLogs).watch();

  // --- Exdates ---
  Future<void> insertExdate(ExdatesCompanion c) => into(exdates).insert(c);
  Future<List<Exdate>> getExdatesForTask(String taskId) =>
      (select(exdates)..where((e) => e.taskId.equals(taskId))).get();
  Future<int> deleteExdate(String id) => (delete(exdates)..where((e) => e.id.equals(id))).go();

  // --- Completion logs (delete when task is deleted) ---
  Future<void> deleteCompletionLogsForTask(String taskId) =>
      (delete(completionLogs)..where((c) => c.taskId.equals(taskId))).go();
}
