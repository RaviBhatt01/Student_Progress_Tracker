import 'package:equatable/equatable.dart';

import 'task_entity.dart';

enum TaskSortOption { dueDate, priority, createdAt }

class TaskFilter extends Equatable {
  final Set<TaskStatus> statuses;
  final Set<TaskPriority> priorities;
  final String? category; // null = all categories
  final TaskSortOption sortBy;
  final bool sortAscending;

  const TaskFilter({
    this.statuses = const {}, // empty = no filter (show all)
    this.priorities = const {}, // empty = no filter (show all)
    this.category,
    this.sortBy = TaskSortOption.createdAt,
    this.sortAscending = false,
  });

  /// Returns true if any filter is active (i.e. not showing everything)
  bool get isActive =>
      statuses.isNotEmpty || priorities.isNotEmpty || category != null;

  /// How many filter chips are active — used for the badge count on the button
  int get activeCount =>
      (statuses.isNotEmpty ? 1 : 0) +
      (priorities.isNotEmpty ? 1 : 0) +
      (category != null ? 1 : 0);

  TaskFilter copyWith({
    Set<TaskStatus>? statuses,
    Set<TaskPriority>? priorities,
    String? Function()? category, // use () => null to explicitly clear
    TaskSortOption? sortBy,
    bool? sortAscending,
  }) {
    return TaskFilter(
      statuses: statuses ?? this.statuses,
      priorities: priorities ?? this.priorities,
      category: category != null ? category() : this.category,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  /// Applies filter + sort to a raw task list.
  /// Called inside the Cubit — never in the UI.
  List<TaskEntity> apply(List<TaskEntity> tasks) {
    var result = tasks.where((t) {
      if (statuses.isNotEmpty && !statuses.contains(t.status)) return false;
      if (priorities.isNotEmpty && !priorities.contains(t.priority)) {
        return false;
      }
      if (category != null && t.category != category) return false;
      return true;
    }).toList();

    result.sort((a, b) {
      int cmp;
      switch (sortBy) {
        case TaskSortOption.dueDate:
          // Tasks with no due date go to the end
          if (a.dueDate == null && b.dueDate == null)
            cmp = 0;
          else if (a.dueDate == null)
            cmp = 1;
          else if (b.dueDate == null)
            cmp = -1;
          else
            cmp = a.dueDate!.compareTo(b.dueDate!);
        case TaskSortOption.priority:
          cmp = b.priority.index.compareTo(a.priority.index); // high first
        case TaskSortOption.createdAt:
          cmp = a.createdAt.compareTo(b.createdAt);
      }
      return sortAscending ? cmp : -cmp;
    });

    return result;
  }

  @override
  List<Object?> get props => [
    statuses,
    priorities,
    category,
    sortBy,
    sortAscending,
  ];
}
