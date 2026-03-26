import 'package:flutter/material.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final String priority; // high, medium, low
  final DateTime dueDate;
  final String category;
  bool isDone;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.priority = 'medium',
    required this.dueDate,
    required this.category,
    this.isDone = false,
  });

  // Цвет приоритета
  Color get priorityColor {
    switch (priority) {
      case 'high': return const Color(0xFFDC2626);
      case 'medium': return const Color(0xFFF59E0B);
      case 'low': return const Color(0xFF10B981);
      default: return Colors.grey;
    }
  }

  // Текст приоритета
  String get priorityText {
    switch (priority) {
      case 'high': return 'Высокий';
      case 'medium': return 'Средний';
      case 'low': return 'Низкий';
      default: return 'Средний';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'priority': priority,
    'dueDate': dueDate.toIso8601String(),
    'category': category,
    'isDone': isDone,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    description: json['description'] ?? '',
    priority: json['priority'] ?? 'medium',
    dueDate: DateTime.parse(json['dueDate']),
    category: json['category'],
    isDone: json['isDone'] ?? false,
  );
}