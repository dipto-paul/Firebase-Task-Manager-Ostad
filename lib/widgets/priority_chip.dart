
import 'package:flutter/material.dart';

import '../core/enums/task_priority.dart';

class PriorityChip extends StatelessWidget {
  final TaskPriority priority;

  const PriorityChip({
    super.key,
    required this.priority,
  });

  Color get _backgroundColor {
    switch (priority) {
      case TaskPriority.low:
        return const Color(0xFFDCFCE7);
      case TaskPriority.medium:
        return const Color(0xFFFEF3C7);
      case TaskPriority.high:
        return const Color(0xFFFEE2E2);
    }
  }

  Color get _foregroundColor {
    switch (priority) {
      case TaskPriority.low:
        return const Color(0xFF15803D);
      case TaskPriority.medium:
        return const Color(0xFFB45309);
      case TaskPriority.high:
        return const Color(0xFFB91C1C);
    }
  }

  IconData get _icon {
    switch (priority) {
      case TaskPriority.low:
        return Icons.keyboard_arrow_down_rounded;
      case TaskPriority.medium:
        return Icons.remove_rounded;
      case TaskPriority.high:
        return Icons.keyboard_arrow_up_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _icon,
            size: 16,
            color: _foregroundColor,
          ),
          const SizedBox(width: 4),
          Text(
            priority.label,
            style: TextStyle(
              color: _foregroundColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
