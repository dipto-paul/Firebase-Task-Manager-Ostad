
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../models/task_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/task_card.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';

enum TaskFilter {
  all,
  pending,
  completed,
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  TaskFilter _selectedFilter = TaskFilter.all;
  String _searchQuery = '';
  bool _isSigningOut = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TaskModel> _filterTasks(List<TaskModel> tasks) {
    return tasks.where((task) {
      final matchesSearch = task.title
          .toLowerCase()
          .contains(_searchQuery.toLowerCase()) ||
          task.description
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      final matchesFilter = switch (_selectedFilter) {
        TaskFilter.all => true,
        TaskFilter.pending => !task.isCompleted,
        TaskFilter.completed => task.isCompleted,
      };

      return matchesSearch && matchesFilter;
    }).toList();
  }

  Future<void> _openAddTask() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const AddTaskScreen(),
      ),
    );
  }

  Future<void> _openEditTask(TaskModel task) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => EditTaskScreen(task: task),
      ),
    );
  }

  Future<void> _toggleCompletion(
      TaskModel task,
      bool isCompleted,
      ) async {
    try {
      await _firestoreService.toggleTaskCompletion(
        taskId: task.id,
        isCompleted: isCompleted,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCompleted
                ? 'Task marked as completed.'
                : 'Task moved back to pending.',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update task: $e'),
          backgroundColor: AppConstants.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmDelete(TaskModel task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: AppConstants.errorColor,
            size: 36,
          ),
          title: const Text('Delete task?'),
          content: Text(
            'Are you sure you want to delete "${task.title}"? '
                'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppConstants.errorColor,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    try {
      await _firestoreService.deleteTask(task.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task deleted successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not delete task: $e'),
          backgroundColor: AppConstants.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmSignOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'Are you sure you want to sign out of your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut != true || !mounted) return;

    setState(() => _isSigningOut = true);

    try {
      await _authService.signOut();
      // AuthGate in main.dart automatically shows LoginScreen.
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not sign out: $e'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }

  Widget _buildFilterButton(TaskFilter filter, String label) {
    final isSelected = _selectedFilter == filter;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedFilter = filter),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected
                ? AppConstants.primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : AppConstants.secondaryTextColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSearching = _searchQuery.isNotEmpty;

    final String title;
    final String subtitle;
    final IconData icon;

    if (isSearching) {
      title = 'No matching tasks';
      subtitle = 'Try searching with another keyword.';
      icon = Icons.search_off_rounded;
    } else if (_selectedFilter == TaskFilter.completed) {
      title = 'No completed tasks yet';
      subtitle = 'Completed tasks will appear here.';
      icon = Icons.task_alt_rounded;
    } else if (_selectedFilter == TaskFilter.pending) {
      title = 'You are all caught up!';
      subtitle = 'There are no pending tasks right now.';
      icon = Icons.check_circle_outline_rounded;
    } else {
      title = 'Your task list is empty';
      subtitle = 'Create your first task and get organized.';
      icon = Icons.add_task_rounded;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 88,
              width: 88,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                icon,
                size: 42,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppConstants.primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppConstants.secondaryTextColor,
              ),
            ),
            if (!isSearching && _selectedFilter == TaskFilter.all) ...[
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: _openAddTask,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create First Task'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName?.trim();
    final greetingName = displayName != null && displayName.isNotEmpty
        ? displayName.split(' ').first
        : 'there';

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(
              Icons.task_alt_rounded,
              color: AppConstants.primaryColor,
              size: 28,
            ),
            SizedBox(width: 10),
            Text(
              'Task Manager',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: _isSigningOut ? null : _confirmSignOut,
            icon: _isSigningOut
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTask,
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Task',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $greetingName 👋',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: AppConstants.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Let’s make today productive.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppConstants.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value.trim());
                    },
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.close_rounded),
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEEF5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _buildFilterButton(TaskFilter.all, 'All Tasks'),
                        _buildFilterButton(TaskFilter.pending, 'Pending'),
                        _buildFilterButton(TaskFilter.completed, 'Completed'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<TaskModel>>(
                stream: _firestoreService.getTasks(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off_rounded,
                              size: 48,
                              color: AppConstants.errorColor,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Could not load tasks',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppConstants.secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () => setState(() {}),
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final allTasks = snapshot.data ?? <TaskModel>[];
                  final completedCount =
                      allTasks.where((task) => task.isCompleted).length;
                  final pendingCount = allTasks.length - completedCount;
                  final visibleTasks = _filterTasks(allTasks);

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            _buildStat(
                              'Total',
                              allTasks.length.toString(),
                              const Color(0xFF635BFF),
                            ),
                            const SizedBox(width: 10),
                            _buildStat(
                              'Pending',
                              pendingCount.toString(),
                              const Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 10),
                            _buildStat(
                              'Completed',
                              completedCount.toString(),
                              const Color(0xFF16A34A),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: visibleTasks.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            4,
                            20,
                            100,
                          ),
                          itemCount: visibleTasks.length,
                          itemBuilder: (context, index) {
                            final task = visibleTasks[index];

                            return TaskCard(
                              key: ValueKey(task.id),
                              task: task,
                              onCompletionChanged: (value) =>
                                  _toggleCompletion(task, value),
                              onEdit: () => _openEditTask(task),
                              onDelete: () => _confirmDelete(task),
                              onTap: () => _openEditTask(task),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppConstants.borderColor),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppConstants.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
