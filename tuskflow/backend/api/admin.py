from django.contrib import admin
from .models import Category, Task, Subtask


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'color', 'user', 'is_default']
    list_filter = ['is_default', 'user']
    search_fields = ['name']


@admin.register(Task)
class TaskAdmin(admin.ModelAdmin):
    list_display = ['title', 'completed', 'priority', 'category', 'user', 'due_date']
    list_filter = ['completed', 'priority', 'category', 'user', 'due_date']
    search_fields = ['title', 'description']
    date_hierarchy = 'due_date'


@admin.register(Subtask)
class SubtaskAdmin(admin.ModelAdmin):
    list_display = ['title', 'completed', 'task']
    list_filter = ['completed', 'task__category', 'task__user']
    search_fields = ['title', 'task__title']