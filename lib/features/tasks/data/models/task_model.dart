import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/task_entity.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

@freezed
abstract class TaskModel with _$TaskModel {
  const TaskModel._(); // needed to add custom methods to freezed class

  const factory TaskModel({
    required String id,
    required String title,
    String? description,
    required String priority, // 'low' | 'medium' | 'high'
    required String status, // 'pending' | 'in_progress' | 'completed'
    String? category,
    @JsonKey(name: 'due_date') String? dueDate,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  /// Maps the API model to a domain entity.
  /// Isolates the app from API field/value naming changes.
  TaskEntity toEntity() => TaskEntity(
    id: id,
    title: title,
    description: description,
    priority: _parsePriority(priority),
    status: _parseStatus(status),
    category: category,
    dueDate: dueDate != null ? DateTime.tryParse(dueDate!) : null,
    createdAt: DateTime.parse(createdAt),
  );

  static TaskPriority _parsePriority(String value) => switch (value) {
    'high' => TaskPriority.high,
    'medium' => TaskPriority.medium,
    _ => TaskPriority.low,
  };

  static TaskStatus _parseStatus(String value) => switch (value) {
    'in_progress' => TaskStatus.inProgress,
    'completed' => TaskStatus.completed,
    _ => TaskStatus.pending,
  };
}

/// Converts a domain entity back to JSON for POST/PUT requests.
Map<String, dynamic> taskEntityToJson(TaskEntity entity) => {
  'title': entity.title,
  'description': entity.description,
  'priority': entity.priority.name,
  'status': switch (entity.status) {
    TaskStatus.inProgress => 'in_progress',
    TaskStatus.completed => 'completed',
    TaskStatus.pending => 'pending',
  },
  'category': entity.category,
  'due_date': entity.dueDate?.toIso8601String(),
};
