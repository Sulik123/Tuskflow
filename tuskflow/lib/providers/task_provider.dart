import 'package:flutter/foundation.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  
  List<Task> get tasks => _tasks;
  
  List<Task> get todayTasks {
    final now = DateTime.now();
    return _tasks.where((task) {
      return task.dueDate.year == now.year &&
             task.dueDate.month == now.month &&
             task.dueDate.day == now.day;
    }).toList();
  }
  
  List<Task> get completedTasks => _tasks.where((t) => t.isDone).toList();
  List<Task> get activeTasks => _tasks.where((t) => !t.isDone).toList();
  
  int get totalTasks => _tasks.length;
  int get completedCount => completedTasks.length;
  int get productivity => totalTasks > 0 ? ((completedCount / totalTasks) * 100).toInt() : 0;
  
  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }
  
  void toggleTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].isDone = !_tasks[index].isDone;
      notifyListeners();
    }
  }
  
  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }
  
  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }
  
  Map<String, int> getPriorityStats() {
    return {
      'high': _tasks.where((t) => t.priority == 'high').length,
      'medium': _tasks.where((t) => t.priority == 'medium').length,
      'low': _tasks.where((t) => t.priority == 'low').length,
    };
  }
  
  Map<String, int> getCategoryStats() {
    final stats = <String, int>{};
    for (final task in _tasks) {
      stats[task.category] = (stats[task.category] ?? 0) + 1;
    }
    return stats;
  }

  List<Task> getTasksByDate(DateTime date) {
    return _tasks.where((t) {
      return t.dueDate.year == date.year &&
             t.dueDate.month == date.month &&
             t.dueDate.day == date.day;
    }).toList();
  }
  
  void clearAll() {
    _tasks.clear();
    notifyListeners();
  }
} 