
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/enums/task_priority.dart';

class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data() ?? <String, dynamic>{};

    return TaskModel(
      id: document.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      dueDate: _readDate(data['dueDate']),
      priority: TaskPriority.fromString(
        data['priority'] as String?,
      ),
      isCompleted: data['isCompleted'] as bool? ?? false,
      createdAt: _readDate(data['createdAt']) ?? DateTime.now(),
      updatedAt: _readDate(data['updatedAt']) ?? DateTime.now(),
    );
  }

  factory TaskModel.fromMap(
      Map<String, dynamic> data, {
        required String id,
      }) {
    return TaskModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      dueDate: _readDate(data['dueDate']),
      priority: TaskPriority.fromString(
        data['priority'] as String?,
      ),
      isCompleted: data['isCompleted'] as bool? ?? false,
      createdAt: _readDate(data['createdAt']) ?? DateTime.now(),
      updatedAt: _readDate(data['updatedAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title.trim(),
      'description': description.trim(),
      'dueDate': dueDate == null
          ? null
          : Timestamp.fromDate(dueDate!),
      'priority': priority.name,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  TaskModel copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    bool clearDueDate = false,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
