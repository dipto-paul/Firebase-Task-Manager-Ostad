
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _tasksCollection {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please sign in to manage your tasks.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks');
  }

  String get _currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please sign in to manage your tasks.');
    }

    return user.uid;
  }

  // Listen to the current user's tasks in real time.
  Stream<List<TaskModel>> getTasks() {
    return _tasksCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(TaskModel.fromFirestore)
          .toList(),
    );
  }

  // Add a new task.
  Future<String> addTask({
    required String title,
    required String description,
    required DateTime? dueDate,
    required String priority,
  }) async {
    final now = DateTime.now();

    final document = await _tasksCollection.add({
      'userId': _currentUserId,
      'title': title.trim(),
      'description': description.trim(),
      'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate),
      'priority': priority.toLowerCase(),
      'isCompleted': false,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });

    return document.id;
  }

  // Update an existing task.
  Future<void> updateTask(TaskModel task) async {
    await _tasksCollection.doc(task.id).update({
      ...task.toMap(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Mark a task as completed or pending.
  Future<void> toggleTaskCompletion({
    required String taskId,
    required bool isCompleted,
  }) async {
    await _tasksCollection.doc(taskId).update({
      'isCompleted': isCompleted,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Delete a task.
  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  // Get one task by ID.
  Future<TaskModel?> getTaskById(String taskId) async {
    final document = await _tasksCollection.doc(taskId).get();

    if (!document.exists) {
      return null;
    }

    return TaskModel.fromFirestore(document);
  }

  // Search tasks by title or description.
  Future<List<TaskModel>> searchTasks(String query) async {
    final snapshot = await _tasksCollection
        .orderBy('createdAt', descending: true)
        .get();

    final tasks = snapshot.docs.map(TaskModel.fromFirestore).toList();
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return tasks;
    }

    return tasks.where((task) {
      return task.title.toLowerCase().contains(normalizedQuery) ||
          task.description.toLowerCase().contains(normalizedQuery);
    }).toList();
  }
}
