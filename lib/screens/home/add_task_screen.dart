
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/enums/task_priority.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/priority_chip.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _dueDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 10),
      helpText: 'Select task due date',
    );

    if (selectedDate != null && mounted) {
      setState(() => _dueDate = selectedDate);
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _firestoreService.addTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _dueDate,
        priority: _selectedPriority.name,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task created successfully!'),
          backgroundColor: AppConstants.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not save task: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: AppConstants.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Task',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppConstants.screenPadding),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.add_task_rounded,
                      color: AppConstants.primaryColor,
                      size: 32,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Plan something great',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppConstants.primaryTextColor,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Add the details and keep your day organized.',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: AppConstants.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              const Text(
                'Task title *',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                autofocus: true,
                maxLength: AppConstants.maxTaskTitleLength,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'e.g. Complete assignment',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title.';
                  }
                  if (value.trim().length < 3) {
                    return 'Title must contain at least 3 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),

              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                minLines: 4,
                maxLines: 5,
                maxLength: 1000,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Add task details (optional)...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 22),

              const Text(
                'Priority',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: TaskPriority.values.map((priority) {
                  final isSelected = _selectedPriority == priority;

                  return InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      setState(() => _selectedPriority = priority);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isSelected
                              ? AppConstants.primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: PriorityChip(priority: priority),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              const Text(
                'Due date',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDueDate,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppConstants.borderColor),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        color: AppConstants.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _dueDate == null
                              ? 'Choose a due date (optional)'
                              : DateFormat('dd MMM yyyy').format(_dueDate!),
                          style: TextStyle(
                            color: _dueDate == null
                                ? AppConstants.secondaryTextColor
                                : AppConstants.primaryTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (_dueDate != null)
                        IconButton(
                          tooltip: 'Remove due date',
                          onPressed: () {
                            setState(() => _dueDate = null);
                          },
                          icon: const Icon(Icons.close_rounded),
                        )
                      else
                        const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: 'Create Task',
                icon: Icons.check_rounded,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _saveTask,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.buttonRadius,
                    ),
                  ),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
