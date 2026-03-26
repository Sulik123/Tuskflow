import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Календарь'),
        elevation: 0,
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Навигация по месяцам
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month - 1,
                          );
                        });
                      },
                    ),
                    Text(
                      DateFormat('MMMM yyyy', 'ru').format(_currentMonth),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month + 1,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Дни недели
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
                      .map((day) => Expanded(
                            child: Text(
                              day,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),

              const SizedBox(height: 8),

              // Сетка календаря
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: 42,
                  itemBuilder: (context, index) {
                    return _buildCalendarDay(index, provider);
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Заголовок задач на выбранный день
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Задачи на ${DateFormat('d MMMM', 'ru').format(_selectedDate)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_getTasksForDate(provider, _selectedDate).length}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Список задач на выбранный день
              Expanded(
                child: _getTasksForDate(provider, _selectedDate).isEmpty
                    ? Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Нет задач на этот день',
                              style: TextStyle(
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _getTasksForDate(provider, _selectedDate).length,
                        itemBuilder: (context, index) {
                          final task = _getTasksForDate(provider, _selectedDate)[index];
                          return TaskCard(
                            task: task,
                            onTap: () {},
                            onToggle: () => provider.toggleTask(task.id),
                            onDelete: () => provider.deleteTask(task.id),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendarDay(int index, TaskProvider provider) {
    // Вычисляем первый день месяца
    DateTime firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    int firstWeekday = firstDay.weekday; // 1 = понедельник, 7 = воскресенье
    
    // Сдвигаем так, чтобы понедельник был первым
    int offset = firstWeekday - 1;
    
    // Вычисляем дату для этой ячейки
    DateTime dayDate = firstDay.add(Duration(days: index - offset));
    
    bool isCurrentMonth = dayDate.month == _currentMonth.month;
    bool isSelected = dayDate.year == _selectedDate.year &&
                      dayDate.month == _selectedDate.month &&
                      dayDate.day == _selectedDate.day;
    bool hasTasks = _getTasksForDate(provider, dayDate).isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (isCurrentMonth) {
          setState(() {
            _selectedDate = dayDate;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isCurrentMonth ? Colors.white : Colors.grey[100]),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isCurrentMonth ? AppColors.border : Colors.transparent),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              dayDate.day.toString(),
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isCurrentMonth ? AppColors.text : Colors.grey),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (hasTasks && !isSelected)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Task> _getTasksForDate(TaskProvider provider, DateTime date) {
    return provider.tasks.where((task) {
      return task.dueDate.year == date.year &&
             task.dueDate.month == date.month &&
             task.dueDate.day == date.day;
    }).toList();
  }
}