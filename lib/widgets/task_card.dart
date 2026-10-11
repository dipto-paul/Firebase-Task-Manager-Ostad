
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_constants.dart';
import '../models/task_model.dart';
import 'priority_chip.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final ValueChanged<bool> onCompletionChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onCompletionChanged,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
  });

  String _formatDueDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  bool get _isOverdue {
    if (task.dueDate == null || task.isCompleted) return false;

    final now = DateTime.now();
    final dueDate = task.dueDate!;

    return DateTime(dueDate.year, dueDate.month, dueDate.day)
        .isBefore(DateTime(now.year, now.month, now.day));
  }

  @override
  Widget build(BuildContext context) {
    final titleColor = task.isCompleted
        ? AppConstants.secondaryTextColor
        : AppConstants.primaryTextColor;

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        side: const BorderSide(color: AppConstants.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) {
                      if (value != null) {
                        onCompletionChanged(value);
                      }
                    },
                    activeColor: AppConstants.successColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Task options',
                    icon: const Icon(
                      Icons.more_horiz_rounded,
                      color: AppConstants.secondaryTextColor,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 19),
                            SizedBox(width: 10),
                            Text('Edit task'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              color: AppConstants.errorColor,
                              size: 19,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Delete task',
                              style: TextStyle(
                                color: AppConstants.errorColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (task.description.trim().isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 48),
                  child: Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppConstants.secondaryTextColor,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    PriorityChip(priority: task.priority),
                    if (task.dueDate != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _isOverdue
                              ? const Color(0xFFFEE2E2)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: _isOverdue
                                  ? AppConstants.errorColor
                                  : AppConstants.secondaryTextColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _isOverdue
                                  ? 'Overdue · ${_formatDueDate(task.dueDate!)}'
                                  : _formatDueDate(task.dueDate!),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _isOverdue
                                    ? AppConstants.errorColor
                                    : AppConstants.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
