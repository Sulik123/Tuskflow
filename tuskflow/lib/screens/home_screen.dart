import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../theme/app_theme.dart';
import 'add_task_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filter = 'all';
  int _selectedIndex = 0;

  List<Widget> get _pages => [
        _buildHomeContent(),
        const CalendarScreen(),
        const ProfileScreen(),
        const StatsScreen(),
      ];

  List<Task> _getFilteredTasks(TaskProvider provider) {
    switch (_filter) {
      case 'active':
        return provider.tasks.where((t) => !t.isDone).toList();
      case 'completed':
        return provider.tasks.where((t) => t.isDone).toList();
      default:
        return provider.tasks;
    }
  }

  Widget _buildHomeContent() {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        final filteredTasks = _getFilteredTasks(provider);

        return Column(
          children: [
            // Статистика
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Сегодня',
                      '${provider.todayTasks.length} задач',
                      Icons.today,
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Выполнено',
                      '${provider.completedTasks.length} задач',
                      Icons.check_circle,
                      AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),

            // Фильтры
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip('Все', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Активные', 'active'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Выполненные', 'completed'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Список задач
            Expanded(
              child: filteredTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Нет задач',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Нажмите + чтобы добавить',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['TaskFlow', 'Календарь', 'Профиль', 'Статистика'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  onPressed: () {
                    setState(() => _selectedIndex = 2); // Перейти в профиль
                  },
                ),
              ]
            : null,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Календарь'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Статистика'),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddTaskScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textLight,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}