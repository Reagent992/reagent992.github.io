+++
date = '2024-06-07T15:08:45+03:00'
draft = false
title = 'Как создать уведомления в Django(DRF) с помощью библиотек django-notifications-hq и django-dirtyfields'
tags = ["django"]
author = "Sadykov Miron"
description = "Это моя первая статья, я написал её после попытки внедрить уведомления на своём первом хакатоне."
+++
---

links: [django-notifications](https://github.com/django-notifications/django-notifications), [django-dirtyfields](https://django-dirtyfields.readthedocs.io/en/stable/index.html), [drf](https://www.django-rest-framework.org/)

---

> Представим, что мы создаём API для сайта, где авторы могут публиковать свои книги. Наши пользователи могут подписываться на авторов и получать уведомления о каждой новой книге любимого автора.

## Установка

```python
# установка библиотек
pip install django-notifications-hq django-dirtyfields djangorestframework
# settings.py
INSTALLED_APPS = [
    ...
    'django.contrib.auth',
    'rest_framework',
    'notifications',
    ...
]
# создание таблицы уведомлений в БД
python manage.py migrate
```

## Модели

У нас есть несколько стандартных примеров моделей:

```python
class Author(models.Model, DirtyFieldsMixin):
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)

class Book(models.Model, DirtyFieldsMixin):
    title = models.CharField(max_length=200)
    author = models.ForeignKey(Author, on_delete=models.CASCADE)
```

**DirtyFieldsMixin** — это миксин из библиотеки django-dirtyfields.
*«Грязное означает, что значение поля в памяти отличается от сохранённого значения в базе данных»*. Это позволяет определить, какие поля были изменены.

## Сигналы

Как создать уведомление, когда создаётся новый объект Book?
Самый простой способ — использовать [Django Signals](https://docs.djangoproject.com/en/5.0/topics/signals/):

- Создадим приложение notifications.
- Затем signals.py
- Зарегистрируем signals.py в apps.py

```python
from django.apps import AppConfig


class NotificationsConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "notifications"

    def ready(self):
        """Добавляем signals.py."""
        try:
            import notifications.signals  # noqa
        except ImportError:
            pass
```

Внутри signals.py мы будем ловить сигнал post_save, который создаётся при сохранении модели Book.

```python
from django.db.models.signals import post_save
from django.dispatch import receiver
from notifications.signals import notify

from books.models import Book


@receiver(post_save, sender=Book)
def create_book_notification(sender, instance, created, **kwargs):
    """Создаём уведомление о новой книге."""
    if created:
        notify.send(
            sender=instance.creator,
            recipient=instance.author.subscribers.all(),
            verb=(f"Вышла новая книга: {instance.title} от"
                  f"{instance.author},"),
            target=instance,
        )

    elif instance.is_dirty():
        if "text" in instance.get_dirty_fields():
            notify.send(
                sender=instance.creator,
                recipient=instance.author.subscribers.all(),
                verb=(f"Новая глава вышла: {instance.title}"
                      f" от {instance.author}"),
                target=instance,
            )
```

## DRF

Теперь создадим API эндпоинты для этих уведомлений.

## Viewset

`notifications_view.py`

```python
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from api.v1.serializers.notifications_serializer import (
    MarkAllAsReadSerializer,
    NotificationSerializer,
    UnseenSerializer,
)

class NotificationViewSet(viewsets.ModelViewSet):
    serializer_class = NotificationSerializer
    http_method_names = ("get", "patch", "head", "options")

    def get_queryset(self):
        return self.request.user.notifications.unread()

    def partial_update(self, request, pk):
        """Пометить уведомление как прочитанное."""
        notification = self.get_object()
        if request.user != notification.recipient:
            return Response(
                {"message": "Уведомление не принадлежит пользователю."},
                status=status.HTTP_403_FORBIDDEN,
            )
        notification.mark_as_read()
        serializer = self.get_serializer(notification)
        return Response(serializer.data)

    @action(
        methods=["get"],
        detail=False,
        serializer_class=MarkAllAsReadSerializer
    )
    def mark_all_as_read(self, request):
        """Пометить все уведомления как прочитанные."""
        request.user.notifications.mark_all_as_read()
        serializer = self.get_serializer({})
        return Response(serializer.data)

    @action(methods=["get"], detail=False, serializer_class=UnseenSerializer)
    def unseen(self, request):
        """Количество непрочитанных уведомлений."""
        unread_count = self.request.user.notifications.unread().count()
        serializer = self.get_serializer({"unseen": unread_count})
        return Response(serializer.data)
```

## Сериализаторы

`notifications_serializer.py`

```python
from notifications.models import Notification
from rest_framework import serializers


class NotificationSerializer(serializers.ModelSerializer):
    recipient_id = serializers.IntegerField(
        read_only=True, source="recipient.id"
    )
    actor_id = serializers.IntegerField(read_only=True, source="actor.id")
    target_content_type = serializers.CharField(
        source="target.__class__.__name__", read_only=True
    )
    target_object_id = serializers.IntegerField(read_only=True)

    class Meta:
        model = Notification
        fields = (
            "id",
            "verb",
            "unread",
            "target_object_id",
            "target_content_type",
            "timestamp",
            "recipient_id",
            "actor_id",
        )


class UnseenSerializer(serializers.Serializer):
    unseen = serializers.IntegerField()


class MarkAllAsReadSerializer(serializers.Serializer):
    message = serializers.CharField(
        default="Все уведомления помечены как прочитанные."
    )
```

## Спасибо за чтение
