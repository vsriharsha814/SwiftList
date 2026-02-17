// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tasks (id)'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _rruleMeta = const VerificationMeta('rrule');
  @override
  late final GeneratedColumn<String> rrule = GeneratedColumn<String>(
      'rrule', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deadlineMeta =
      const VerificationMeta('deadline');
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
      'deadline', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _reminderMinutesBeforeMeta =
      const VerificationMeta('reminderMinutesBefore');
  @override
  late final GeneratedColumn<String> reminderMinutesBefore =
      GeneratedColumn<String>('reminder_minutes_before', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<int> weight = GeneratedColumn<int>(
      'weight', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _projectNameMeta =
      const VerificationMeta('projectName');
  @override
  late final GeneratedColumn<String> projectName = GeneratedColumn<String>(
      'project_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _countdownMinutesMeta =
      const VerificationMeta('countdownMinutes');
  @override
  late final GeneratedColumn<int> countdownMinutes = GeneratedColumn<int>(
      'countdown_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        parentId,
        title,
        description,
        rrule,
        deadline,
        reminderMinutesBefore,
        weight,
        isCompleted,
        isArchived,
        completedAt,
        projectName,
        countdownMinutes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<Task> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('rrule')) {
      context.handle(
          _rruleMeta, rrule.isAcceptableOrUnknown(data['rrule']!, _rruleMeta));
    }
    if (data.containsKey('deadline')) {
      context.handle(_deadlineMeta,
          deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta));
    }
    if (data.containsKey('reminder_minutes_before')) {
      context.handle(
          _reminderMinutesBeforeMeta,
          reminderMinutesBefore.isAcceptableOrUnknown(
              data['reminder_minutes_before']!, _reminderMinutesBeforeMeta));
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('project_name')) {
      context.handle(
          _projectNameMeta,
          projectName.isAcceptableOrUnknown(
              data['project_name']!, _projectNameMeta));
    }
    if (data.containsKey('countdown_minutes')) {
      context.handle(
          _countdownMinutesMeta,
          countdownMinutes.isAcceptableOrUnknown(
              data['countdown_minutes']!, _countdownMinutesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      rrule: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rrule']),
      deadline: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deadline']),
      reminderMinutesBefore: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}reminder_minutes_before']),
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}weight'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      projectName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_name']),
      countdownMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}countdown_minutes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final String id;
  final String? parentId;
  final String title;
  final String? description;
  final String? rrule;
  final DateTime? deadline;

  /// JSON array of minutes before deadline to remind, e.g. "[10,30,60,1440]" for 10min, 30min, 1hr, 1day.
  final String? reminderMinutesBefore;
  final int weight;
  final bool isCompleted;
  final bool isArchived;
  final DateTime? completedAt;
  final String? projectName;
  final int? countdownMinutes;
  final DateTime createdAt;
  const Task(
      {required this.id,
      this.parentId,
      required this.title,
      this.description,
      this.rrule,
      this.deadline,
      this.reminderMinutesBefore,
      required this.weight,
      required this.isCompleted,
      required this.isArchived,
      this.completedAt,
      this.projectName,
      this.countdownMinutes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || rrule != null) {
      map['rrule'] = Variable<String>(rrule);
    }
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    if (!nullToAbsent || reminderMinutesBefore != null) {
      map['reminder_minutes_before'] = Variable<String>(reminderMinutesBefore);
    }
    map['weight'] = Variable<int>(weight);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['is_archived'] = Variable<bool>(isArchived);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || projectName != null) {
      map['project_name'] = Variable<String>(projectName);
    }
    if (!nullToAbsent || countdownMinutes != null) {
      map['countdown_minutes'] = Variable<int>(countdownMinutes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      rrule:
          rrule == null && nullToAbsent ? const Value.absent() : Value(rrule),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      reminderMinutesBefore: reminderMinutesBefore == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderMinutesBefore),
      weight: Value(weight),
      isCompleted: Value(isCompleted),
      isArchived: Value(isArchived),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      projectName: projectName == null && nullToAbsent
          ? const Value.absent()
          : Value(projectName),
      countdownMinutes: countdownMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(countdownMinutes),
      createdAt: Value(createdAt),
    );
  }

  factory Task.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      rrule: serializer.fromJson<String?>(json['rrule']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
      reminderMinutesBefore:
          serializer.fromJson<String?>(json['reminderMinutesBefore']),
      weight: serializer.fromJson<int>(json['weight']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      projectName: serializer.fromJson<String?>(json['projectName']),
      countdownMinutes: serializer.fromJson<int?>(json['countdownMinutes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'parentId': serializer.toJson<String?>(parentId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'rrule': serializer.toJson<String?>(rrule),
      'deadline': serializer.toJson<DateTime?>(deadline),
      'reminderMinutesBefore':
          serializer.toJson<String?>(reminderMinutesBefore),
      'weight': serializer.toJson<int>(weight),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'isArchived': serializer.toJson<bool>(isArchived),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'projectName': serializer.toJson<String?>(projectName),
      'countdownMinutes': serializer.toJson<int?>(countdownMinutes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Task copyWith(
          {String? id,
          Value<String?> parentId = const Value.absent(),
          String? title,
          Value<String?> description = const Value.absent(),
          Value<String?> rrule = const Value.absent(),
          Value<DateTime?> deadline = const Value.absent(),
          Value<String?> reminderMinutesBefore = const Value.absent(),
          int? weight,
          bool? isCompleted,
          bool? isArchived,
          Value<DateTime?> completedAt = const Value.absent(),
          Value<String?> projectName = const Value.absent(),
          Value<int?> countdownMinutes = const Value.absent(),
          DateTime? createdAt}) =>
      Task(
        id: id ?? this.id,
        parentId: parentId.present ? parentId.value : this.parentId,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        rrule: rrule.present ? rrule.value : this.rrule,
        deadline: deadline.present ? deadline.value : this.deadline,
        reminderMinutesBefore: reminderMinutesBefore.present
            ? reminderMinutesBefore.value
            : this.reminderMinutesBefore,
        weight: weight ?? this.weight,
        isCompleted: isCompleted ?? this.isCompleted,
        isArchived: isArchived ?? this.isArchived,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        projectName: projectName.present ? projectName.value : this.projectName,
        countdownMinutes: countdownMinutes.present
            ? countdownMinutes.value
            : this.countdownMinutes,
        createdAt: createdAt ?? this.createdAt,
      );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      rrule: data.rrule.present ? data.rrule.value : this.rrule,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      reminderMinutesBefore: data.reminderMinutesBefore.present
          ? data.reminderMinutesBefore.value
          : this.reminderMinutesBefore,
      weight: data.weight.present ? data.weight.value : this.weight,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      projectName:
          data.projectName.present ? data.projectName.value : this.projectName,
      countdownMinutes: data.countdownMinutes.present
          ? data.countdownMinutes.value
          : this.countdownMinutes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('rrule: $rrule, ')
          ..write('deadline: $deadline, ')
          ..write('reminderMinutesBefore: $reminderMinutesBefore, ')
          ..write('weight: $weight, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isArchived: $isArchived, ')
          ..write('completedAt: $completedAt, ')
          ..write('projectName: $projectName, ')
          ..write('countdownMinutes: $countdownMinutes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      parentId,
      title,
      description,
      rrule,
      deadline,
      reminderMinutesBefore,
      weight,
      isCompleted,
      isArchived,
      completedAt,
      projectName,
      countdownMinutes,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.parentId == this.parentId &&
          other.title == this.title &&
          other.description == this.description &&
          other.rrule == this.rrule &&
          other.deadline == this.deadline &&
          other.reminderMinutesBefore == this.reminderMinutesBefore &&
          other.weight == this.weight &&
          other.isCompleted == this.isCompleted &&
          other.isArchived == this.isArchived &&
          other.completedAt == this.completedAt &&
          other.projectName == this.projectName &&
          other.countdownMinutes == this.countdownMinutes &&
          other.createdAt == this.createdAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<String?> parentId;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> rrule;
  final Value<DateTime?> deadline;
  final Value<String?> reminderMinutesBefore;
  final Value<int> weight;
  final Value<bool> isCompleted;
  final Value<bool> isArchived;
  final Value<DateTime?> completedAt;
  final Value<String?> projectName;
  final Value<int?> countdownMinutes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.parentId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.rrule = const Value.absent(),
    this.deadline = const Value.absent(),
    this.reminderMinutesBefore = const Value.absent(),
    this.weight = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.projectName = const Value.absent(),
    this.countdownMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    this.parentId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.rrule = const Value.absent(),
    this.deadline = const Value.absent(),
    this.reminderMinutesBefore = const Value.absent(),
    this.weight = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.projectName = const Value.absent(),
    this.countdownMinutes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        createdAt = Value(createdAt);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<String>? parentId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? rrule,
    Expression<DateTime>? deadline,
    Expression<String>? reminderMinutesBefore,
    Expression<int>? weight,
    Expression<bool>? isCompleted,
    Expression<bool>? isArchived,
    Expression<DateTime>? completedAt,
    Expression<String>? projectName,
    Expression<int>? countdownMinutes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (parentId != null) 'parent_id': parentId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (rrule != null) 'rrule': rrule,
      if (deadline != null) 'deadline': deadline,
      if (reminderMinutesBefore != null)
        'reminder_minutes_before': reminderMinutesBefore,
      if (weight != null) 'weight': weight,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (isArchived != null) 'is_archived': isArchived,
      if (completedAt != null) 'completed_at': completedAt,
      if (projectName != null) 'project_name': projectName,
      if (countdownMinutes != null) 'countdown_minutes': countdownMinutes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith(
      {Value<String>? id,
      Value<String?>? parentId,
      Value<String>? title,
      Value<String?>? description,
      Value<String?>? rrule,
      Value<DateTime?>? deadline,
      Value<String?>? reminderMinutesBefore,
      Value<int>? weight,
      Value<bool>? isCompleted,
      Value<bool>? isArchived,
      Value<DateTime?>? completedAt,
      Value<String?>? projectName,
      Value<int?>? countdownMinutes,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return TasksCompanion(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      title: title ?? this.title,
      description: description ?? this.description,
      rrule: rrule ?? this.rrule,
      deadline: deadline ?? this.deadline,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      weight: weight ?? this.weight,
      isCompleted: isCompleted ?? this.isCompleted,
      isArchived: isArchived ?? this.isArchived,
      completedAt: completedAt ?? this.completedAt,
      projectName: projectName ?? this.projectName,
      countdownMinutes: countdownMinutes ?? this.countdownMinutes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rrule.present) {
      map['rrule'] = Variable<String>(rrule.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (reminderMinutesBefore.present) {
      map['reminder_minutes_before'] =
          Variable<String>(reminderMinutesBefore.value);
    }
    if (weight.present) {
      map['weight'] = Variable<int>(weight.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (projectName.present) {
      map['project_name'] = Variable<String>(projectName.value);
    }
    if (countdownMinutes.present) {
      map['countdown_minutes'] = Variable<int>(countdownMinutes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('rrule: $rrule, ')
          ..write('deadline: $deadline, ')
          ..write('reminderMinutesBefore: $reminderMinutesBefore, ')
          ..write('weight: $weight, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isArchived: $isArchived, ')
          ..write('completedAt: $completedAt, ')
          ..write('projectName: $projectName, ')
          ..write('countdownMinutes: $countdownMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimeLogsTable extends TimeLogs with TableInfo<$TimeLogsTable, TimeLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimeLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
      'task_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tasks (id)'));
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, taskId, startTime, endTime, durationSeconds];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'time_logs';
  @override
  VerificationContext validateIntegrity(Insertable<TimeLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimeLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimeLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_id'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time'])!,
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds'])!,
    );
  }

  @override
  $TimeLogsTable createAlias(String alias) {
    return $TimeLogsTable(attachedDatabase, alias);
  }
}

class TimeLog extends DataClass implements Insertable<TimeLog> {
  final String id;
  final String taskId;
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;
  const TimeLog(
      {required this.id,
      required this.taskId,
      required this.startTime,
      required this.endTime,
      required this.durationSeconds});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['start_time'] = Variable<DateTime>(startTime);
    map['end_time'] = Variable<DateTime>(endTime);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    return map;
  }

  TimeLogsCompanion toCompanion(bool nullToAbsent) {
    return TimeLogsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      startTime: Value(startTime),
      endTime: Value(endTime),
      durationSeconds: Value(durationSeconds),
    );
  }

  factory TimeLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimeLog(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime>(json['endTime']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime>(endTime),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
    };
  }

  TimeLog copyWith(
          {String? id,
          String? taskId,
          DateTime? startTime,
          DateTime? endTime,
          int? durationSeconds}) =>
      TimeLog(
        id: id ?? this.id,
        taskId: taskId ?? this.taskId,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        durationSeconds: durationSeconds ?? this.durationSeconds,
      );
  TimeLog copyWithCompanion(TimeLogsCompanion data) {
    return TimeLog(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimeLog(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationSeconds: $durationSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, taskId, startTime, endTime, durationSeconds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimeLog &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.durationSeconds == this.durationSeconds);
}

class TimeLogsCompanion extends UpdateCompanion<TimeLog> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<DateTime> startTime;
  final Value<DateTime> endTime;
  final Value<int> durationSeconds;
  final Value<int> rowid;
  const TimeLogsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimeLogsCompanion.insert({
    required String id,
    required String taskId,
    required DateTime startTime,
    required DateTime endTime,
    required int durationSeconds,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        taskId = Value(taskId),
        startTime = Value(startTime),
        endTime = Value(endTime),
        durationSeconds = Value(durationSeconds);
  static Insertable<TimeLog> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? durationSeconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimeLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? taskId,
      Value<DateTime>? startTime,
      Value<DateTime>? endTime,
      Value<int>? durationSeconds,
      Value<int>? rowid}) {
    return TimeLogsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimeLogsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExdatesTable extends Exdates with TableInfo<$ExdatesTable, Exdate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExdatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
      'task_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tasks (id)'));
  static const VerificationMeta _exceptionDateMeta =
      const VerificationMeta('exceptionDate');
  @override
  late final GeneratedColumn<DateTime> exceptionDate =
      GeneratedColumn<DateTime>('exception_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, taskId, exceptionDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exdates';
  @override
  VerificationContext validateIntegrity(Insertable<Exdate> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('exception_date')) {
      context.handle(
          _exceptionDateMeta,
          exceptionDate.isAcceptableOrUnknown(
              data['exception_date']!, _exceptionDateMeta));
    } else if (isInserting) {
      context.missing(_exceptionDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exdate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exdate(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_id'])!,
      exceptionDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}exception_date'])!,
    );
  }

  @override
  $ExdatesTable createAlias(String alias) {
    return $ExdatesTable(attachedDatabase, alias);
  }
}

class Exdate extends DataClass implements Insertable<Exdate> {
  final String id;
  final String taskId;
  final DateTime exceptionDate;
  const Exdate(
      {required this.id, required this.taskId, required this.exceptionDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['exception_date'] = Variable<DateTime>(exceptionDate);
    return map;
  }

  ExdatesCompanion toCompanion(bool nullToAbsent) {
    return ExdatesCompanion(
      id: Value(id),
      taskId: Value(taskId),
      exceptionDate: Value(exceptionDate),
    );
  }

  factory Exdate.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exdate(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      exceptionDate: serializer.fromJson<DateTime>(json['exceptionDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'exceptionDate': serializer.toJson<DateTime>(exceptionDate),
    };
  }

  Exdate copyWith({String? id, String? taskId, DateTime? exceptionDate}) =>
      Exdate(
        id: id ?? this.id,
        taskId: taskId ?? this.taskId,
        exceptionDate: exceptionDate ?? this.exceptionDate,
      );
  Exdate copyWithCompanion(ExdatesCompanion data) {
    return Exdate(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      exceptionDate: data.exceptionDate.present
          ? data.exceptionDate.value
          : this.exceptionDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exdate(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('exceptionDate: $exceptionDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, taskId, exceptionDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exdate &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.exceptionDate == this.exceptionDate);
}

class ExdatesCompanion extends UpdateCompanion<Exdate> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<DateTime> exceptionDate;
  final Value<int> rowid;
  const ExdatesCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.exceptionDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExdatesCompanion.insert({
    required String id,
    required String taskId,
    required DateTime exceptionDate,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        taskId = Value(taskId),
        exceptionDate = Value(exceptionDate);
  static Insertable<Exdate> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<DateTime>? exceptionDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (exceptionDate != null) 'exception_date': exceptionDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExdatesCompanion copyWith(
      {Value<String>? id,
      Value<String>? taskId,
      Value<DateTime>? exceptionDate,
      Value<int>? rowid}) {
    return ExdatesCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      exceptionDate: exceptionDate ?? this.exceptionDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (exceptionDate.present) {
      map['exception_date'] = Variable<DateTime>(exceptionDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExdatesCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('exceptionDate: $exceptionDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompletionLogsTable extends CompletionLogs
    with TableInfo<$CompletionLogsTable, CompletionLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompletionLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
      'task_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _taskTitleMeta =
      const VerificationMeta('taskTitle');
  @override
  late final GeneratedColumn<String> taskTitle = GeneratedColumn<String>(
      'task_title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _commentMeta =
      const VerificationMeta('comment');
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
      'comment', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, taskId, taskTitle, completedAt, comment];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'completion_logs';
  @override
  VerificationContext validateIntegrity(Insertable<CompletionLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('task_title')) {
      context.handle(_taskTitleMeta,
          taskTitle.isAcceptableOrUnknown(data['task_title']!, _taskTitleMeta));
    } else if (isInserting) {
      context.missing(_taskTitleMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('comment')) {
      context.handle(_commentMeta,
          comment.isAcceptableOrUnknown(data['comment']!, _commentMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompletionLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompletionLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_id'])!,
      taskTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_title'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at'])!,
      comment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}comment']),
    );
  }

  @override
  $CompletionLogsTable createAlias(String alias) {
    return $CompletionLogsTable(attachedDatabase, alias);
  }
}

class CompletionLog extends DataClass implements Insertable<CompletionLog> {
  final String id;
  final String taskId;
  final String taskTitle;
  final DateTime completedAt;
  final String? comment;
  const CompletionLog(
      {required this.id,
      required this.taskId,
      required this.taskTitle,
      required this.completedAt,
      this.comment});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['task_title'] = Variable<String>(taskTitle);
    map['completed_at'] = Variable<DateTime>(completedAt);
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    return map;
  }

  CompletionLogsCompanion toCompanion(bool nullToAbsent) {
    return CompletionLogsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      taskTitle: Value(taskTitle),
      completedAt: Value(completedAt),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
    );
  }

  factory CompletionLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompletionLog(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      taskTitle: serializer.fromJson<String>(json['taskTitle']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      comment: serializer.fromJson<String?>(json['comment']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'taskTitle': serializer.toJson<String>(taskTitle),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'comment': serializer.toJson<String?>(comment),
    };
  }

  CompletionLog copyWith(
          {String? id,
          String? taskId,
          String? taskTitle,
          DateTime? completedAt,
          Value<String?> comment = const Value.absent()}) =>
      CompletionLog(
        id: id ?? this.id,
        taskId: taskId ?? this.taskId,
        taskTitle: taskTitle ?? this.taskTitle,
        completedAt: completedAt ?? this.completedAt,
        comment: comment.present ? comment.value : this.comment,
      );
  CompletionLog copyWithCompanion(CompletionLogsCompanion data) {
    return CompletionLog(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      taskTitle: data.taskTitle.present ? data.taskTitle.value : this.taskTitle,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      comment: data.comment.present ? data.comment.value : this.comment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompletionLog(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('taskTitle: $taskTitle, ')
          ..write('completedAt: $completedAt, ')
          ..write('comment: $comment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, taskId, taskTitle, completedAt, comment);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompletionLog &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.taskTitle == this.taskTitle &&
          other.completedAt == this.completedAt &&
          other.comment == this.comment);
}

class CompletionLogsCompanion extends UpdateCompanion<CompletionLog> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<String> taskTitle;
  final Value<DateTime> completedAt;
  final Value<String?> comment;
  final Value<int> rowid;
  const CompletionLogsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.taskTitle = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.comment = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompletionLogsCompanion.insert({
    required String id,
    required String taskId,
    required String taskTitle,
    required DateTime completedAt,
    this.comment = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        taskId = Value(taskId),
        taskTitle = Value(taskTitle),
        completedAt = Value(completedAt);
  static Insertable<CompletionLog> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? taskTitle,
    Expression<DateTime>? completedAt,
    Expression<String>? comment,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (taskTitle != null) 'task_title': taskTitle,
      if (completedAt != null) 'completed_at': completedAt,
      if (comment != null) 'comment': comment,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompletionLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? taskId,
      Value<String>? taskTitle,
      Value<DateTime>? completedAt,
      Value<String?>? comment,
      Value<int>? rowid}) {
    return CompletionLogsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      completedAt: completedAt ?? this.completedAt,
      comment: comment ?? this.comment,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (taskTitle.present) {
      map['task_title'] = Variable<String>(taskTitle.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompletionLogsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('taskTitle: $taskTitle, ')
          ..write('completedAt: $completedAt, ')
          ..write('comment: $comment, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $TimeLogsTable timeLogs = $TimeLogsTable(this);
  late final $ExdatesTable exdates = $ExdatesTable(this);
  late final $CompletionLogsTable completionLogs = $CompletionLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [tasks, timeLogs, exdates, completionLogs];
}

typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  Value<String?> parentId,
  required String title,
  Value<String?> description,
  Value<String?> rrule,
  Value<DateTime?> deadline,
  Value<String?> reminderMinutesBefore,
  Value<int> weight,
  Value<bool> isCompleted,
  Value<bool> isArchived,
  Value<DateTime?> completedAt,
  Value<String?> projectName,
  Value<int?> countdownMinutes,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String?> parentId,
  Value<String> title,
  Value<String?> description,
  Value<String?> rrule,
  Value<DateTime?> deadline,
  Value<String?> reminderMinutesBefore,
  Value<int> weight,
  Value<bool> isCompleted,
  Value<bool> isArchived,
  Value<DateTime?> completedAt,
  Value<String?> projectName,
  Value<int?> countdownMinutes,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _parentIdTable(_$AppDatabase db) => db.tasks
      .createAlias($_aliasNameGenerator(db.tasks.parentId, db.tasks.id));

  $$TasksTableProcessedTableManager? get parentId {
    if ($_item.parentId == null) return null;
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.id($_item.parentId!));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TimeLogsTable, List<TimeLog>> _timeLogsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.timeLogs,
          aliasName: $_aliasNameGenerator(db.tasks.id, db.timeLogs.taskId));

  $$TimeLogsTableProcessedTableManager get timeLogsRefs {
    final manager = $$TimeLogsTableTableManager($_db, $_db.timeLogs)
        .filter((f) => f.taskId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_timeLogsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ExdatesTable, List<Exdate>> _exdatesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.exdates,
          aliasName: $_aliasNameGenerator(db.tasks.id, db.exdates.taskId));

  $$ExdatesTableProcessedTableManager get exdatesRefs {
    final manager = $$ExdatesTableTableManager($_db, $_db.exdates)
        .filter((f) => f.taskId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_exdatesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rrule => $composableBuilder(
      column: $table.rrule, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reminderMinutesBefore => $composableBuilder(
      column: $table.reminderMinutesBefore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectName => $composableBuilder(
      column: $table.projectName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get countdownMinutes => $composableBuilder(
      column: $table.countdownMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$TasksTableFilterComposer get parentId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> timeLogsRefs(
      Expression<bool> Function($$TimeLogsTableFilterComposer f) f) {
    final $$TimeLogsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.timeLogs,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TimeLogsTableFilterComposer(
              $db: $db,
              $table: $db.timeLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> exdatesRefs(
      Expression<bool> Function($$ExdatesTableFilterComposer f) f) {
    final $$ExdatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.exdates,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExdatesTableFilterComposer(
              $db: $db,
              $table: $db.exdates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rrule => $composableBuilder(
      column: $table.rrule, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reminderMinutesBefore => $composableBuilder(
      column: $table.reminderMinutesBefore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectName => $composableBuilder(
      column: $table.projectName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get countdownMinutes => $composableBuilder(
      column: $table.countdownMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$TasksTableOrderingComposer get parentId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableOrderingComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get rrule =>
      $composableBuilder(column: $table.rrule, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<String> get reminderMinutesBefore => $composableBuilder(
      column: $table.reminderMinutesBefore, builder: (column) => column);

  GeneratedColumn<int> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<String> get projectName => $composableBuilder(
      column: $table.projectName, builder: (column) => column);

  GeneratedColumn<int> get countdownMinutes => $composableBuilder(
      column: $table.countdownMinutes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TasksTableAnnotationComposer get parentId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> timeLogsRefs<T extends Object>(
      Expression<T> Function($$TimeLogsTableAnnotationComposer a) f) {
    final $$TimeLogsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.timeLogs,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TimeLogsTableAnnotationComposer(
              $db: $db,
              $table: $db.timeLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> exdatesRefs<T extends Object>(
      Expression<T> Function($$ExdatesTableAnnotationComposer a) f) {
    final $$ExdatesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.exdates,
        getReferencedColumn: (t) => t.taskId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExdatesTableAnnotationComposer(
              $db: $db,
              $table: $db.exdates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, $$TasksTableReferences),
    Task,
    PrefetchHooks Function(
        {bool parentId, bool timeLogsRefs, bool exdatesRefs})> {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> parentId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> rrule = const Value.absent(),
            Value<DateTime?> deadline = const Value.absent(),
            Value<String?> reminderMinutesBefore = const Value.absent(),
            Value<int> weight = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<String?> projectName = const Value.absent(),
            Value<int?> countdownMinutes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion(
            id: id,
            parentId: parentId,
            title: title,
            description: description,
            rrule: rrule,
            deadline: deadline,
            reminderMinutesBefore: reminderMinutesBefore,
            weight: weight,
            isCompleted: isCompleted,
            isArchived: isArchived,
            completedAt: completedAt,
            projectName: projectName,
            countdownMinutes: countdownMinutes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> parentId = const Value.absent(),
            required String title,
            Value<String?> description = const Value.absent(),
            Value<String?> rrule = const Value.absent(),
            Value<DateTime?> deadline = const Value.absent(),
            Value<String?> reminderMinutesBefore = const Value.absent(),
            Value<int> weight = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<String?> projectName = const Value.absent(),
            Value<int?> countdownMinutes = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion.insert(
            id: id,
            parentId: parentId,
            title: title,
            description: description,
            rrule: rrule,
            deadline: deadline,
            reminderMinutesBefore: reminderMinutesBefore,
            weight: weight,
            isCompleted: isCompleted,
            isArchived: isArchived,
            completedAt: completedAt,
            projectName: projectName,
            countdownMinutes: countdownMinutes,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TasksTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {parentId = false, timeLogsRefs = false, exdatesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (timeLogsRefs) db.timeLogs,
                if (exdatesRefs) db.exdates
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (parentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.parentId,
                    referencedTable: $$TasksTableReferences._parentIdTable(db),
                    referencedColumn:
                        $$TasksTableReferences._parentIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (timeLogsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$TasksTableReferences._timeLogsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TasksTableReferences(db, table, p0).timeLogsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.taskId == item.id),
                        typedResults: items),
                  if (exdatesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$TasksTableReferences._exdatesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TasksTableReferences(db, table, p0).exdatesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.taskId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, $$TasksTableReferences),
    Task,
    PrefetchHooks Function(
        {bool parentId, bool timeLogsRefs, bool exdatesRefs})>;
typedef $$TimeLogsTableCreateCompanionBuilder = TimeLogsCompanion Function({
  required String id,
  required String taskId,
  required DateTime startTime,
  required DateTime endTime,
  required int durationSeconds,
  Value<int> rowid,
});
typedef $$TimeLogsTableUpdateCompanionBuilder = TimeLogsCompanion Function({
  Value<String> id,
  Value<String> taskId,
  Value<DateTime> startTime,
  Value<DateTime> endTime,
  Value<int> durationSeconds,
  Value<int> rowid,
});

final class $$TimeLogsTableReferences
    extends BaseReferences<_$AppDatabase, $TimeLogsTable, TimeLog> {
  $$TimeLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) => db.tasks
      .createAlias($_aliasNameGenerator(db.timeLogs.taskId, db.tasks.id));

  $$TasksTableProcessedTableManager get taskId {
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.id($_item.taskId));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TimeLogsTableFilterComposer
    extends Composer<_$AppDatabase, $TimeLogsTable> {
  $$TimeLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TimeLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $TimeLogsTable> {
  $$TimeLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableOrderingComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TimeLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimeLogsTable> {
  $$TimeLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TimeLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TimeLogsTable,
    TimeLog,
    $$TimeLogsTableFilterComposer,
    $$TimeLogsTableOrderingComposer,
    $$TimeLogsTableAnnotationComposer,
    $$TimeLogsTableCreateCompanionBuilder,
    $$TimeLogsTableUpdateCompanionBuilder,
    (TimeLog, $$TimeLogsTableReferences),
    TimeLog,
    PrefetchHooks Function({bool taskId})> {
  $$TimeLogsTableTableManager(_$AppDatabase db, $TimeLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimeLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimeLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimeLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> taskId = const Value.absent(),
            Value<DateTime> startTime = const Value.absent(),
            Value<DateTime> endTime = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TimeLogsCompanion(
            id: id,
            taskId: taskId,
            startTime: startTime,
            endTime: endTime,
            durationSeconds: durationSeconds,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String taskId,
            required DateTime startTime,
            required DateTime endTime,
            required int durationSeconds,
            Value<int> rowid = const Value.absent(),
          }) =>
              TimeLogsCompanion.insert(
            id: id,
            taskId: taskId,
            startTime: startTime,
            endTime: endTime,
            durationSeconds: durationSeconds,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TimeLogsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (taskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.taskId,
                    referencedTable: $$TimeLogsTableReferences._taskIdTable(db),
                    referencedColumn:
                        $$TimeLogsTableReferences._taskIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TimeLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TimeLogsTable,
    TimeLog,
    $$TimeLogsTableFilterComposer,
    $$TimeLogsTableOrderingComposer,
    $$TimeLogsTableAnnotationComposer,
    $$TimeLogsTableCreateCompanionBuilder,
    $$TimeLogsTableUpdateCompanionBuilder,
    (TimeLog, $$TimeLogsTableReferences),
    TimeLog,
    PrefetchHooks Function({bool taskId})>;
typedef $$ExdatesTableCreateCompanionBuilder = ExdatesCompanion Function({
  required String id,
  required String taskId,
  required DateTime exceptionDate,
  Value<int> rowid,
});
typedef $$ExdatesTableUpdateCompanionBuilder = ExdatesCompanion Function({
  Value<String> id,
  Value<String> taskId,
  Value<DateTime> exceptionDate,
  Value<int> rowid,
});

final class $$ExdatesTableReferences
    extends BaseReferences<_$AppDatabase, $ExdatesTable, Exdate> {
  $$ExdatesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) => db.tasks
      .createAlias($_aliasNameGenerator(db.exdates.taskId, db.tasks.id));

  $$TasksTableProcessedTableManager get taskId {
    final manager = $$TasksTableTableManager($_db, $_db.tasks)
        .filter((f) => f.id($_item.taskId));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ExdatesTableFilterComposer
    extends Composer<_$AppDatabase, $ExdatesTable> {
  $$ExdatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get exceptionDate => $composableBuilder(
      column: $table.exceptionDate, builder: (column) => ColumnFilters(column));

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExdatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExdatesTable> {
  $$ExdatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get exceptionDate => $composableBuilder(
      column: $table.exceptionDate,
      builder: (column) => ColumnOrderings(column));

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableOrderingComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExdatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExdatesTable> {
  $$ExdatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get exceptionDate => $composableBuilder(
      column: $table.exceptionDate, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.taskId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TasksTableAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExdatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExdatesTable,
    Exdate,
    $$ExdatesTableFilterComposer,
    $$ExdatesTableOrderingComposer,
    $$ExdatesTableAnnotationComposer,
    $$ExdatesTableCreateCompanionBuilder,
    $$ExdatesTableUpdateCompanionBuilder,
    (Exdate, $$ExdatesTableReferences),
    Exdate,
    PrefetchHooks Function({bool taskId})> {
  $$ExdatesTableTableManager(_$AppDatabase db, $ExdatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExdatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExdatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExdatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> taskId = const Value.absent(),
            Value<DateTime> exceptionDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExdatesCompanion(
            id: id,
            taskId: taskId,
            exceptionDate: exceptionDate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String taskId,
            required DateTime exceptionDate,
            Value<int> rowid = const Value.absent(),
          }) =>
              ExdatesCompanion.insert(
            id: id,
            taskId: taskId,
            exceptionDate: exceptionDate,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ExdatesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (taskId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.taskId,
                    referencedTable: $$ExdatesTableReferences._taskIdTable(db),
                    referencedColumn:
                        $$ExdatesTableReferences._taskIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ExdatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExdatesTable,
    Exdate,
    $$ExdatesTableFilterComposer,
    $$ExdatesTableOrderingComposer,
    $$ExdatesTableAnnotationComposer,
    $$ExdatesTableCreateCompanionBuilder,
    $$ExdatesTableUpdateCompanionBuilder,
    (Exdate, $$ExdatesTableReferences),
    Exdate,
    PrefetchHooks Function({bool taskId})>;
typedef $$CompletionLogsTableCreateCompanionBuilder = CompletionLogsCompanion
    Function({
  required String id,
  required String taskId,
  required String taskTitle,
  required DateTime completedAt,
  Value<String?> comment,
  Value<int> rowid,
});
typedef $$CompletionLogsTableUpdateCompanionBuilder = CompletionLogsCompanion
    Function({
  Value<String> id,
  Value<String> taskId,
  Value<String> taskTitle,
  Value<DateTime> completedAt,
  Value<String?> comment,
  Value<int> rowid,
});

class $$CompletionLogsTableFilterComposer
    extends Composer<_$AppDatabase, $CompletionLogsTable> {
  $$CompletionLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taskId => $composableBuilder(
      column: $table.taskId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taskTitle => $composableBuilder(
      column: $table.taskTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get comment => $composableBuilder(
      column: $table.comment, builder: (column) => ColumnFilters(column));
}

class $$CompletionLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $CompletionLogsTable> {
  $$CompletionLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taskId => $composableBuilder(
      column: $table.taskId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taskTitle => $composableBuilder(
      column: $table.taskTitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get comment => $composableBuilder(
      column: $table.comment, builder: (column) => ColumnOrderings(column));
}

class $$CompletionLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompletionLogsTable> {
  $$CompletionLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get taskTitle =>
      $composableBuilder(column: $table.taskTitle, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);
}

class $$CompletionLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CompletionLogsTable,
    CompletionLog,
    $$CompletionLogsTableFilterComposer,
    $$CompletionLogsTableOrderingComposer,
    $$CompletionLogsTableAnnotationComposer,
    $$CompletionLogsTableCreateCompanionBuilder,
    $$CompletionLogsTableUpdateCompanionBuilder,
    (
      CompletionLog,
      BaseReferences<_$AppDatabase, $CompletionLogsTable, CompletionLog>
    ),
    CompletionLog,
    PrefetchHooks Function()> {
  $$CompletionLogsTableTableManager(
      _$AppDatabase db, $CompletionLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompletionLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompletionLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompletionLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> taskId = const Value.absent(),
            Value<String> taskTitle = const Value.absent(),
            Value<DateTime> completedAt = const Value.absent(),
            Value<String?> comment = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CompletionLogsCompanion(
            id: id,
            taskId: taskId,
            taskTitle: taskTitle,
            completedAt: completedAt,
            comment: comment,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String taskId,
            required String taskTitle,
            required DateTime completedAt,
            Value<String?> comment = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CompletionLogsCompanion.insert(
            id: id,
            taskId: taskId,
            taskTitle: taskTitle,
            completedAt: completedAt,
            comment: comment,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CompletionLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CompletionLogsTable,
    CompletionLog,
    $$CompletionLogsTableFilterComposer,
    $$CompletionLogsTableOrderingComposer,
    $$CompletionLogsTableAnnotationComposer,
    $$CompletionLogsTableCreateCompanionBuilder,
    $$CompletionLogsTableUpdateCompanionBuilder,
    (
      CompletionLog,
      BaseReferences<_$AppDatabase, $CompletionLogsTable, CompletionLog>
    ),
    CompletionLog,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$TimeLogsTableTableManager get timeLogs =>
      $$TimeLogsTableTableManager(_db, _db.timeLogs);
  $$ExdatesTableTableManager get exdates =>
      $$ExdatesTableTableManager(_db, _db.exdates);
  $$CompletionLogsTableTableManager get completionLogs =>
      $$CompletionLogsTableTableManager(_db, _db.completionLogs);
}
