from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import CategoryViewSet, TaskViewSet, SubtaskViewSet, StatisticsViewSet

# Создаем роутер для API
router = DefaultRouter()
router.register(r'categories', CategoryViewSet)
router.register(r'tasks', TaskViewSet)
router.register(r'subtasks', SubtaskViewSet)
router.register(r'statistics', StatisticsViewSet, basename='statistics')

urlpatterns = [
    path('', include(router.urls)),
]