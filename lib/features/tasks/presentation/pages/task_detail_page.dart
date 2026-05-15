import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/task_entity.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import '../widgets/priority_badge.dart';

@RoutePage()
class TaskDetailPage extends StatelessWidget {
  // AutoRoute passes this via the route — no manual constructor wiring needed
  final TaskEntity task;

  const TaskDetailPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<TaskCubit, TaskState>(
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
        // Always show the latest version of this task from the cubit state
        final currentTask = switch (state) {
          TaskLoaded(:final tasks) ||
          TaskMutating(:final tasks) ||
          TaskError(
            :final tasks,
          ) => tasks.firstWhere((t) => t.id == task.id, orElse: () => task),
          _ => task,
        };

        final isMutating = state is TaskMutating;

        return Scaffold(
          appBar: AppBar(
            leading: const AutoLeadingButton(),
            title: const Text('Task Detail'),
            actions: [
              if (isMutating)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(currentTask.title, style: theme.textTheme.headlineMedium),
                const SizedBox(height: 12),

                // Badges row
                Wrap(
                  spacing: 8,
                  children: [
                    PriorityBadge(priority: currentTask.priority),
                    _StatusBadge(status: currentTask.status),
                    if (currentTask.category != null)
                      _InfoChip(
                        icon: Icons.label_outline,
                        label: currentTask.category!,
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Description
                if (currentTask.description != null &&
                    currentTask.description!.isNotEmpty) ...[
                  Text('Description', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Text(
                    currentTask.description!,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                ],

                // Due date
                if (currentTask.dueDate != null) ...[
                  Text('Due Date', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  _InfoChip(
                    icon: Icons.calendar_today_outlined,
                    label: DateFormat(
                      'EEEE, MMM d y',
                    ).format(currentTask.dueDate!),
                    color: currentTask.isOverdue
                        ? AppTheme.error
                        : AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 24),
                ],

                // Created at
                Text('Created', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                _InfoChip(
                  icon: Icons.access_time_outlined,
                  label: DateFormat(
                    'MMM d y, HH:mm',
                  ).format(currentTask.createdAt),
                ),
                const SizedBox(height: 40),

                const Divider(),
                const SizedBox(height: 24),

                // Quick actions
                Text('Actions', style: theme.textTheme.labelLarge),
                const SizedBox(height: 12),

                // Cycle status
                OutlinedButton.icon(
                  onPressed: isMutating
                      ? null
                      : () => context.read<TaskCubit>().toggleTaskStatus(
                          currentTask,
                        ),
                  icon: const Icon(Icons.sync_outlined),
                  label: Text(
                    currentTask.status == TaskStatus.completed
                        ? 'Mark as Pending'
                        : currentTask.status == TaskStatus.pending
                        ? 'Mark as In Progress'
                        : 'Mark as Completed',
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Delete
                OutlinedButton.icon(
                  onPressed: isMutating
                      ? null
                      : () => _confirmDelete(context, currentTask),
                  icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                  label: const Text(
                    'Delete Task',
                    style: TextStyle(color: AppTheme.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: const BorderSide(color: AppTheme.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
              context.router.pop();
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

class _StatusBadge extends StatelessWidget {
  final TaskStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color get _color => switch (status) {
    TaskStatus.completed => AppTheme.secondary,
    TaskStatus.inProgress => AppTheme.primary,
    TaskStatus.pending => AppTheme.textSecondary,
  };

  String get _label => switch (status) {
    TaskStatus.completed => 'Completed',
    TaskStatus.inProgress => 'In Progress',
    TaskStatus.pending => 'Pending',
  };
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color = AppTheme.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 13, color: color)),
      ],
    );
  }
}
