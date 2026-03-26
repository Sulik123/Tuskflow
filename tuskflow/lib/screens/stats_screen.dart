import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          final stats = provider.getPriorityStats();
          final categories = provider.getCategoryStats();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Основная статистика
              GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard(
                    'Всего задач',
                    provider.totalTasks.toString(),
                    isDark,
                  ),
                  _buildStatCard(
                    'Выполнено',
                    provider.completedCount.toString(),
                    isDark,
                  ),
                  _buildStatCard(
                    'Активных',
                    provider.activeTasks.length.toString(),
                    isDark,
                  ),
                  _buildStatCard(
                    'Продуктивность',
                    '${provider.productivity}%',
                    isDark,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // По приоритетам
              Text(
                'По приоритетам',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surfaceLight,
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
                child: Column(
                  children: stats.entries.map((e) {
                    final color = e.key == 'High'
                        ? AppColors.priorityHigh
                        : e.key == 'Medium'
                            ? AppColors.priorityMedium
                            : AppColors.priorityLow;
                    final percentage = provider.totalTasks > 0
                        ? (e.value / provider.totalTasks * 100).toInt()
                        : 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key),
                              Text('${e.value}'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              minHeight: 6,
                              backgroundColor:
                                  isDark ? Colors.grey[800] : Colors.grey[300],
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              // По категориям
              Text(
                'По категориям',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surfaceLight,
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
                child: Column(
                  children: categories.entries.isEmpty
                      ? [
                          Text(
                            'Нет данных',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[600],
                            ),
                          ),
                        ]
                      : categories.entries.map((e) {
                          final percentage = provider.totalTasks > 0
                              ? (e.value / provider.totalTasks * 100).toInt()
                              : 0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(e.key),
                                    Text('${e.value}'),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  child: LinearProgressIndicator(
                                    value: percentage / 100,
                                    minHeight: 6,
                                    backgroundColor: isDark
                                        ? Colors.grey[800]
                                        : Colors.grey[300],
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceLight,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[400] : AppColors.textTertiary,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
