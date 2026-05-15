import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks();
  Future<TaskModel> createTask(Map<String, dynamic> body);
  Future<TaskModel> updateTask(String id, Map<String, dynamic> body);
  Future<void> deleteTask(String id);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio _dio;

  TaskRemoteDataSourceImpl(DioClient dioClient) : _dio = dioClient.dio;

  @override
  Future<List<TaskModel>> getTasks() async {
    final response = await _dio.get('/tasks');
    // API returns { "data": [...] }
    final List data = response.data['data'] as List;
    return data.map((e) => TaskModel.fromJson(e)).toList();
  }

  @override
  Future<TaskModel> createTask(Map<String, dynamic> body) async {
    final response = await _dio.post('/tasks', data: body);
    return TaskModel.fromJson(response.data['data']);
  }

  @override
  Future<TaskModel> updateTask(String id, Map<String, dynamic> body) async {
    final response = await _dio.put('/tasks/$id', data: body);
    return TaskModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _dio.delete('/tasks/$id');
  }
}
