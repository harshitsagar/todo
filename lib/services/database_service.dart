import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class DatabaseService {
  static const String _baseUrl =
      'https://YOUR-PROJECT-ID.firebaseio.com'; // Replace with your URL
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user's tasks
  Future<List<Task>> getTasks() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await http.get(
      Uri.parse('$_baseUrl/users/${user.uid}/tasks.json'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data == null) return [];

      List<Task> tasks = [];
      data.forEach((key, value) {
        tasks.add(Task.fromJson(value));
      });

      // Sort by createdAt descending (newest first)
      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tasks;
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  // Add task
  Future<void> addTask(Task task) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await http.post(
      Uri.parse('$_baseUrl/users/${user.uid}/tasks.json'),
      body: json.encode(task.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add task');
    }
  }

  // Update task
  Future<void> updateTask(Task task) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get all tasks to find the key
    final tasks = await http.get(
      Uri.parse('$_baseUrl/users/${user.uid}/tasks.json'),
    );

    if (tasks.statusCode == 200) {
      final data = json.decode(tasks.body);
      if (data != null) {
        String? taskKey;
        data.forEach((key, value) {
          if (value['id'] == task.id) {
            taskKey = key;
          }
        });

        if (taskKey != null) {
          final response = await http.put(
            Uri.parse('$_baseUrl/users/${user.uid}/tasks/$taskKey.json'),
            body: json.encode(task.toJson()),
          );

          if (response.statusCode != 200) {
            throw Exception('Failed to update task');
          }
        }
      }
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get all tasks to find the key
    final tasks = await http.get(
      Uri.parse('$_baseUrl/users/${user.uid}/tasks.json'),
    );

    if (tasks.statusCode == 200) {
      final data = json.decode(tasks.body);
      if (data != null) {
        String? taskKey;
        data.forEach((key, value) {
          if (value['id'] == taskId) {
            taskKey = key;
          }
        });

        if (taskKey != null) {
          final response = await http.delete(
            Uri.parse('$_baseUrl/users/${user.uid}/tasks/$taskKey.json'),
          );

          if (response.statusCode != 200) {
            throw Exception('Failed to delete task');
          }
        }
      }
    }
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(Task task) async {
    await updateTask(task.copyWith(isCompleted: !task.isCompleted));
  }
}