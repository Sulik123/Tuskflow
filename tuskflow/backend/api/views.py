from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db.models import Count, Q
from django.utils import timezone
from .models import Category, Task, Subtask
from .serializers import (
    CategorySerializer, TaskSerializer, TaskCreateSerializer,
    SubtaskSerializer, SyncTaskSerializer
)


class CategoryViewSet(viewsets.ModelViewSet):
    """
    ViewSet для категорий задач
    """
    serializer_class = CategorySerializer

    def get_queryset(self):
        # Возвращаем категории пользователя или системные
        user = self.request.user
        if user.is_authenticated:
            return Category.objects.filter(Q(user=user) | Q(is_default=True))
        return Category.objects.filter(is_default=True)

    def perform_create(self, serializer):
        # Автоматически устанавливаем пользователя
        if self.request.user.is_authenticated:
            serializer.save(user=self.request.user)
        else:
            serializer.save()


class TaskViewSet(viewsets.ModelViewSet):
    """
    ViewSet для задач
    """
    def get_serializer_class(self):
        if self.action in ['create', 'update', 'partial_update']:
            return TaskCreateSerializer
        return TaskSerializer

    def get_queryset(self):
        user = self.request.user
        if user.is_authenticated:
            return Task.objects.filter(user=user)
        # Для гостевого режима возвращаем задачи без пользователя
        return Task.objects.filter(user__isnull=True)

    def perform_create(self, serializer):
        if self.request.user.is_authenticated:
            serializer.save(user=self.request.user)
        else:
            serializer.save()

    @action(detail=False, methods=['post'])
    def sync(self, request):
        """
        Синхронизация задач между клиентом и сервером
        """
        serializer = SyncTaskSerializer(data=request.data)
        if serializer.is_valid():
            tasks_data = serializer.validated_data['tasks']
            last_sync = serializer.validated_data.get('last_sync')

            # Получаем задачи пользователя
            user = request.user if request.user.is_authenticated else None
            queryset = Task.objects.filter(user=user)

            # Если указан last_sync, фильтруем по дате изменения
            if last_sync:
                queryset = queryset.filter(updated_at__gt=last_sync)

            # Сериализуем существующие задачи
            existing_serializer = TaskSerializer(queryset, many=True)

            # Создаем/обновляем задачи от клиента
            created_tasks = []
            for task_data in tasks_data:
                task_data_copy = task_data.copy()
                task_data_copy['user'] = user
                task, created = Task.objects.update_or_create(
                    local_id=task_data_copy.get('local_id'),
                    defaults=task_data_copy
                )
                if created:
                    created_tasks.append(task)

            return Response({
                'server_tasks': existing_serializer.data,
                'created_count': len(created_tasks)
            })

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class SubtaskViewSet(viewsets.ModelViewSet):
    """
    ViewSet для подзадач
    """
    serializer_class = SubtaskSerializer

    def get_queryset(self):
        user = self.request.user
        if user.is_authenticated:
            return Subtask.objects.filter(task__user=user)
        return Subtask.objects.filter(task__user__isnull=True)


class StatisticsViewSet(viewsets.ViewSet):
    """
    ViewSet для статистики
    """

    @action(detail=False, methods=['get'])
    def overview(self, request):
        """
        Общая статистика задач
        """
        user = request.user if request.user.is_authenticated else None
        queryset = Task.objects.filter(user=user)

        total_tasks = queryset.count()
        completed_tasks = queryset.filter(completed=True).count()
        overdue_tasks = queryset.filter(
            due_date__lt=timezone.now(),
            completed=False
        ).count()

        # Статистика по приоритетам
        priority_stats = queryset.values('priority').annotate(
            count=Count('priority')
        ).order_by('priority')

        # Статистика по категориям
        category_stats = queryset.values('category__name').annotate(
            count=Count('category')
        ).exclude(category__isnull=True).order_by('category__name')

        return Response({
            'total_tasks': total_tasks,
            'completed_tasks': completed_tasks,
            'overdue_tasks': overdue_tasks,
            'completion_rate': (completed_tasks / total_tasks * 100) if total_tasks > 0 else 0,
            'priority_stats': list(priority_stats),
            'category_stats': list(category_stats),
        })