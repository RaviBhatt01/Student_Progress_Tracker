import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../../router/app_router.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_filter.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/task_card.dart';

@RoutePage()
class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  @override
  void initState() {
    super.initState();
    // Cubit is provided at app level — just trigger the load
    context.read<TaskCubit>().loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return const _TaskListView();
  }
}

class _TaskListView extends StatelessWidget {
  const _TaskListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          // Filter button with active-filter badge
          BlocBuilder<TaskCubit, TaskState>(
            builder: (context, state) {
              final filter = switch (state) {
                TaskLoaded(:final filter) => filter,
                TaskMutating(:final filter) => filter,
                TaskError(:final filter) => filter,
                _ => const TaskFilter(),
              };
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.tune_rounded),
                    onPressed: () => showFilterSheet(context),
                    tooltip: 'Filter & Sort',
                  ),
                  if (filter.isActive)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${filter.activeCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Logout
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => context.read<AuthCubit>().logout().then(
              (_) => context.router.replaceAll([LoginRoute()]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTaskSheet(context),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
      body: BlocConsumer<TaskCubit, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final filter = switch (state) {
            TaskLoaded(:final filter) => filter,
            TaskMutating(:final filter) => filter,
            TaskError(:final filter) => filter,
            _ => const TaskFilter(),
          };

          return switch (state) {
            TaskInitial() ||
            TaskLoading() => const Center(child: CircularProgressIndicator()),
            TaskLoaded(:final tasks) ||
            TaskMutating(:final tasks) ||
            TaskError(:final tasks) => Column(
              children: [
                // Active filter chips row
                if (filter.isActive)
                  _ActiveFilterBar(
                    filter: filter,
                    onClear: () => context.read<TaskCubit>().clearFilter(),
                  ),
                Expanded(
                  child: tasks.isEmpty
                      ? _EmptyState(
                          isMutating: state is TaskMutating,
                          isFiltered: filter.isActive,
                          onClearFilter: () =>
                              context.read<TaskCubit>().clearFilter(),
                        )
                      : Stack(
                          children: [
                            RefreshIndicator(
                              onRefresh: () =>
                                  context.read<TaskCubit>().loadTasks(),
                              child: ListView.builder(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  bottom: 100,
                                ),
                                itemCount: tasks.length,
                                itemBuilder: (_, i) {
                                  final task = tasks[i];
                                  return TaskCard(
                                    task: task,
                                    onTap: () => context.router.push(
                                      TaskDetailRoute(task: task),
                                    ),
                                    onToggleStatus: () => context
                                        .read<TaskCubit>()
                                        .toggleTaskStatus(task),
                                    onDelete: () =>
                                        _confirmDelete(context, task),
                                  );
                                },
                              ),
                            ),
                            if (state is TaskMutating)
                              const Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: LinearProgressIndicator(
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          };
        },
      ),
    );
  }

  void _showCreateTaskSheet(BuildContext context) {
    // Capture cubit before async gap
    final cubit = context.read<TaskCubit>();

    final form = FormGroup({
      'title': FormControl<String>(
        validators: [Validators.required, Validators.minLength(2)],
      ),
      'description': FormControl<String>(),
      'priority': FormControl<TaskPriority>(
        value: TaskPriority.medium,
        validators: [Validators.required],
      ),
      'category': FormControl<String>(),
      'dueDate': FormControl<DateTime>(),
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: ReactiveForm(
          formGroup: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Task', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),

              // Title
              ReactiveTextField<String>(
                formControlName: 'title',
                decoration: const InputDecoration(labelText: 'Title'),
                validationMessages: {
                  ValidationMessage.required: (_) => 'Title is required',
                },
              ),
              const SizedBox(height: 12),

              // Description
              ReactiveTextField<String>(
                formControlName: 'description',
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              // Priority dropdown
              ReactiveDropdownField<TaskPriority>(
                formControlName: 'priority',
                decoration: const InputDecoration(labelText: 'Priority'),
                items: const [
                  DropdownMenuItem(value: TaskPriority.low, child: Text('Low')),
                  DropdownMenuItem(
                    value: TaskPriority.medium,
                    child: Text('Medium'),
                  ),
                  DropdownMenuItem(
                    value: TaskPriority.high,
                    child: Text('High'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Category
              ReactiveTextField<String>(
                formControlName: 'category',
                decoration: const InputDecoration(
                  labelText: 'Category (optional)',
                ),
              ),
              const SizedBox(height: 12),

              // Due date picker
              ReactiveDatePicker<DateTime>(
                formControlName: 'dueDate',
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                builder: (context, picker, child) {
                  return ReactiveTextField<DateTime>(
                    formControlName: 'dueDate',
                    readOnly: true,
                    onTap: (_) => picker.showPicker(),
                    decoration: InputDecoration(
                      labelText: 'Due Date (optional)',
                      suffixIcon: const Icon(Icons.calendar_today_outlined),
                      hintText: picker.value != null
                          ? DateFormat('MMM d, y').format(picker.value!)
                          : 'Pick a date',
                    ),
                    valueAccessor: DateTimeValueAccessor(
                      dateTimeFormat: DateFormat('MMM d, y'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Submit
              ReactiveFormConsumer(
                builder: (context, f, _) => ElevatedButton(
                  onPressed: f.invalid
                      ? null
                      : () {
                          cubit.createTask(
                            title: f.control('title').value,
                            description: f.control('description').value,
                            priority: f.control('priority').value,
                            category: f.control('category').value,
                            dueDate: f.control('dueDate').value,
                          );
                          Navigator.pop(context);
                        },
                  child: const Text('Create Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, TaskEntity task) {
    final cubit = context.read<TaskCubit>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Delete "${task.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              cubit.deleteTask(task.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isMutating;
  final bool isFiltered;
  final VoidCallback onClearFilter;

  const _EmptyState({
    required this.isMutating,
    required this.isFiltered,
    required this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFiltered ? Icons.search_off_rounded : Icons.checklist_rounded,
            size: 64,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? 'No tasks match your filters' : 'No tasks yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered
                ? 'Try adjusting or clearing your filters'
                : 'Tap + New Task to get started',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (isFiltered) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onClearFilter,
              child: const Text('Clear filters'),
            ),
          ],
          if (isMutating) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ],
      ),
    );
  }
}

/// A compact scrollable row of chips showing active filters,
/// with an X on each to remove it individually.
class _ActiveFilterBar extends StatelessWidget {
  final TaskFilter filter;
  final VoidCallback onClear;

  const _ActiveFilterBar({required this.filter, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryLight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.tune_rounded, size: 14, color: AppTheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final status in filter.statuses)
                    _FilterChip(label: _statusLabel(status)),
                  for (final priority in filter.priorities)
                    _FilterChip(label: _priorityLabel(priority)),
                  if (filter.category != null)
                    _FilterChip(label: filter.category!),
                  _FilterChip(
                    label:
                        '${_sortLabel(filter.sortBy)} '
                        '${filter.sortAscending ? '↑' : '↓'}',
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(TaskStatus s) => switch (s) {
    TaskStatus.pending => 'Pending',
    TaskStatus.inProgress => 'In Progress',
    TaskStatus.completed => 'Completed',
  };

  String _priorityLabel(TaskPriority p) => switch (p) {
    TaskPriority.high => 'High',
    TaskPriority.medium => 'Medium',
    TaskPriority.low => 'Low',
  };

  String _sortLabel(TaskSortOption s) => switch (s) {
    TaskSortOption.createdAt => 'Created',
    TaskSortOption.dueDate => 'Due date',
    TaskSortOption.priority => 'Priority',
  };
}

class _FilterChip extends StatelessWidget {
  final String label;
  const _FilterChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.primary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
