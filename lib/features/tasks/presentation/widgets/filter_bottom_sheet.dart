import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_filter.dart';
import '../cubit/task_cubit.dart';

/// Opens the filter sheet and returns when dismissed.
void showFilterSheet(BuildContext context) {
  final cubit = context.read<TaskCubit>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => BlocProvider.value(
      // Share the same cubit instance — changes apply immediately
      value: cubit,
      child: const _FilterSheet(),
    ),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet();

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  // Local draft — only applied when user taps "Apply"
  late TaskFilter _draft;
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<TaskCubit>();
    _draft = cubit.currentFilter;
    _categories = cubit.availableCategories;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text('Filter & Sort', style: theme.textTheme.titleLarge),
              const Spacer(),
              if (_draft.isActive)
                TextButton(
                  onPressed: () => setState(() => _draft = const TaskFilter()),
                  child: const Text('Clear all'),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Status
          Text('Status', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: TaskStatus.values.map((s) {
              final selected = _draft.statuses.contains(s);
              return FilterChip(
                label: Text(_statusLabel(s)),
                selected: selected,
                onSelected: (val) => setState(() {
                  final updated = Set<TaskStatus>.from(_draft.statuses);
                  val ? updated.add(s) : updated.remove(s);
                  _draft = _draft.copyWith(statuses: updated);
                }),
                selectedColor: AppTheme.primaryLight,
                checkmarkColor: AppTheme.primary,
                labelStyle: TextStyle(
                  color: selected ? AppTheme.primary : AppTheme.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Priority
          Text('Priority', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: TaskPriority.values.map((p) {
              final selected = _draft.priorities.contains(p);
              return FilterChip(
                label: Text(_priorityLabel(p)),
                selected: selected,
                onSelected: (val) => setState(() {
                  final updated = Set<TaskPriority>.from(_draft.priorities);
                  val ? updated.add(p) : updated.remove(p);
                  _draft = _draft.copyWith(priorities: updated);
                }),
                selectedColor: _priorityColor(p).withOpacity(0.15),
                checkmarkColor: _priorityColor(p),
                labelStyle: TextStyle(
                  color: selected ? _priorityColor(p) : AppTheme.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),

          // Category (only shown if tasks have categories)
          if (_categories.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Category', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              value: _draft.category,
              decoration: const InputDecoration(hintText: 'All categories'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All')),
                ..._categories.map(
                  (c) => DropdownMenuItem(value: c, child: Text(c)),
                ),
              ],
              onChanged: (val) =>
                  setState(() => _draft = _draft.copyWith(category: () => val)),
            ),
          ],

          const SizedBox(height: 16),

          // Sort
          Text('Sort by', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<TaskSortOption>(
                  value: _draft.sortBy,
                  items: const [
                    DropdownMenuItem(
                      value: TaskSortOption.createdAt,
                      child: Text('Date created'),
                    ),
                    DropdownMenuItem(
                      value: TaskSortOption.dueDate,
                      child: Text('Due date'),
                    ),
                    DropdownMenuItem(
                      value: TaskSortOption.priority,
                      child: Text('Priority'),
                    ),
                  ],
                  onChanged: (val) =>
                      setState(() => _draft = _draft.copyWith(sortBy: val)),
                ),
              ),
              const SizedBox(width: 12),
              // Ascending / descending toggle
              IconButton.outlined(
                onPressed: () => setState(
                  () => _draft = _draft.copyWith(
                    sortAscending: !_draft.sortAscending,
                  ),
                ),
                icon: Icon(
                  _draft.sortAscending
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: AppTheme.primary,
                ),
                tooltip: _draft.sortAscending ? 'Ascending' : 'Descending',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Apply button
          ElevatedButton(
            onPressed: () {
              context.read<TaskCubit>().applyFilter(_draft);
              Navigator.pop(context);
            },
            child: Text(
              _draft.isActive
                  ? 'Apply (${_draft.activeCount} active)'
                  : 'Apply',
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

  Color _priorityColor(TaskPriority p) => switch (p) {
    TaskPriority.high => AppTheme.priorityHigh,
    TaskPriority.medium => AppTheme.priorityMedium,
    TaskPriority.low => AppTheme.priorityLow,
  };
}
