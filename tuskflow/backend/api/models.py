from django.db import models
from django.contrib.auth.models import User


class Category(models.Model):
    """
    Модель категории задач
    """
    PRIORITY_CHOICES = [
        ('low', 'Низкий'),
        ('medium', 'Средний'),
        ('high', 'Высокий'),
    ]

    name = models.CharField(max_length=100, verbose_name='Название категории')
    color = models.CharField(max_length=7, default='#6B46C1', verbose_name='Цвет категории')  # Hex цвет
    user = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True, verbose_name='Пользователь')
    is_default = models.BooleanField(default=False, verbose_name='Системная категория')

    class Meta:
        verbose_name = 'Категория'
        verbose_name_plural = 'Категории'
        ordering = ['name']

    def __str__(self):
        return self.name


class Task(models.Model):
    """
    Модель задачи
    """
    PRIORITY_CHOICES = [
        ('low', 'Низкий'),
        ('medium', 'Средний'),
        ('high', 'Высокий'),
    ]

    title = models.CharField(max_length=200, verbose_name='Заголовок задачи')
    description = models.TextField(blank=True, verbose_name='Описание задачи')
    due_date = models.DateTimeField(null=True, blank=True, verbose_name='Срок выполнения')
    completed = models.BooleanField(default=False, verbose_name='Выполнена')
    priority = models.CharField(max_length=10, choices=PRIORITY_CHOICES, default='medium', verbose_name='Приоритет')
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, blank=True, verbose_name='Категория')
    user = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True, verbose_name='Пользователь')
    local_id = models.CharField(max_length=50, blank=True, verbose_name='Локальный ID для синхронизации')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Дата создания')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='Дата обновления')

    class Meta:
        verbose_name = 'Задача'
        verbose_name_plural = 'Задачи'
        ordering = ['-created_at']

    def __str__(self):
        return self.title


class Subtask(models.Model):
    """
    Модель подзадачи
    """
    title = models.CharField(max_length=200, verbose_name='Заголовок подзадачи')
    completed = models.BooleanField(default=False, verbose_name='Выполнена')
    task = models.ForeignKey(Task, on_delete=models.CASCADE, related_name='subtasks', verbose_name='Основная задача')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='Дата создания')

    class Meta:
        verbose_name = 'Подзадача'
        verbose_name_plural = 'Подзадачи'
        ordering = ['created_at']

    def __str__(self):
        return f'{self.task.title} - {self.title}'