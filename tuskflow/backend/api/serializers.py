from rest_framework import serializers
from .models import Category, Task, Subtask


class CategorySerializer(serializers.ModelSerializer):
    """
    Сериализатор для категории задач
    """
    class Meta:
        model = Category
        fields = ['id', 'name', 'color', 'user', 'is_default']
        read_only_fields = ['user']  # Пользователь устанавливается автоматически


class SubtaskSerializer(serializers.ModelSerializer):
    """
    Сериализатор для подзадачи
    """
    class Meta:
        model = Subtask
        fields = ['id', 'title', 'completed', 'task', 'created_at']
        read_only_fields = ['created_at']


class TaskSerializer(serializers.ModelSerializer):
    """
    Сериализатор для задачи
    """
    subtasks = SubtaskSerializer(many=True, read_only=True)
    category_name = serializers.CharField(source='category.name', read_only=True)
    category_color = serializers.CharField(source='category.color', read_only=True)

    class Meta:
        model = Task
        fields = [
            'id', 'title', 'description', 'due_date', 'completed',
            'priority', 'category', 'category_name', 'category_color',
            'user', 'local_id', 'created_at', 'updated_at', 'subtasks'
        ]
        read_only_fields = ['user', 'created_at', 'updated_at']


class TaskCreateSerializer(serializers.ModelSerializer):
    """
    Сериализатор для создания задачи (с подзадачами)
    """
    subtasks = SubtaskSerializer(many=True, required=False)

    class Meta:
        model = Task
        fields = [
            'id', 'title', 'description', 'due_date', 'completed',
            'priority', 'category', 'user', 'local_id', 'subtasks'
        ]
        read_only_fields = ['user']

    def create(self, validated_data):
        subtasks_data = validated_data.pop('subtasks', [])
        task = Task.objects.create(**validated_data)
        for subtask_data in subtasks_data:
            Subtask.objects.create(task=task, **subtask_data)
        return task

    def update(self, instance, validated_data):
        subtasks_data = validated_data.pop('subtasks', [])
        instance = super().update(instance, validated_data)

        # Удаляем старые подзадачи и создаем новые
        instance.subtasks.all().delete()
        for subtask_data in subtasks_data:
            Subtask.objects.create(task=instance, **subtask_data)

        return instance


class SyncTaskSerializer(serializers.Serializer):
    """
    Сериализатор для синхронизации задач
    """
    tasks = TaskCreateSerializer(many=True)
    last_sync = serializers.DateTimeField(required=False)