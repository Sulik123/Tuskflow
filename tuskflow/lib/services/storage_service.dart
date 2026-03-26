import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class StorageService {
  static const String _tasksKey = 'tasks';
  static const String _categoriesKey = 'categories';

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_tasksKey, json);
  }

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_tasksKey);
    if (json == null) return [];
    
    final list = jsonDecode(json) as List;
    return list.map((item) => Task.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> saveCategories(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_categoriesKey, categories);
  }

  Future<List<String>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_categoriesKey) ?? ['Учеба', 'Работа', 'Личное'];
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
