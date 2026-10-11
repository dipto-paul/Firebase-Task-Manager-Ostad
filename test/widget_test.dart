
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_task_manager/core/enums/task_priority.dart';

void main() {
  group('TaskPriority', () {
    test('should provide the correct labels', () {
      expect(TaskPriority.low.label, 'Low');
      expect(TaskPriority.medium.label, 'Medium');
      expect(TaskPriority.high.label, 'High');
    });

    test('should provide the correct levels', () {
      expect(TaskPriority.low.level, 1);
      expect(TaskPriority.medium.level, 2);
      expect(TaskPriority.high.level, 3);
    });

    test('should parse priority strings', () {
      expect(TaskPriority.fromString('low'), TaskPriority.low);
      expect(TaskPriority.fromString('HIGH'), TaskPriority.high);
      expect(TaskPriority.fromString('medium'), TaskPriority.medium);
    });

    test('should default to medium for unknown values', () {
      expect(TaskPriority.fromString('unknown'), TaskPriority.medium);
      expect(TaskPriority.fromString(null), TaskPriority.medium);
    });
  });
}
