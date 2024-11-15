+++
date = '2024-06-07T15:08:45+03:00'
draft = false
title = 'How to create notifications in Django(DRF) by using the django-notifications-hq and django-dirtyfields libraries.'
tags = "django"
author = "Sadykov Miron"
description = "It's my first article, i wrote it after tying to implement notifications on my first hackathon."
+++
---

links: [django-notifications](https://github.com/django-notifications/django-notifications), [django-dirtyfields](https://django-dirtyfields.readthedocs.io/en/stable/index.html), [drf](https://www.django-rest-framework.org/)

---

> Let’s imagine we are creating an API for a website where authors can publish their books. Our users can follow authors and they will be notified about every new book published by their favorite author.


# Installation

```python
# install libs
pip install django-notifications-hq django-dirtyfields djangorestframework
# settings.py
INSTALLED_APPS = [
    ...
    'django.contrib.auth',
    'rest_framework',
    'notifications',
    ...
]
# create notifications db table 
python manage.py migrate
```

# Models

We have some default example models:

```python
class Author(models.Model, DirtyFieldsMixin):
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)

class Book(models.Model, DirtyFieldsMixin):
    title = models.CharField(max_length=200)
    author = models.ForeignKey(Author, on_delete=models.CASCADE)
```

**DirtyFieldsMixin** — it’s a mixin from django-dirtyfields library.
*“Dirty means that a field’s in-memory value is different to the saved value in the database”*. It allows us to identify which fields were modified.

# Signals

How to create a notification when a new Book object is created?
The simplest way is to use [Django Signals](https://docs.djangoproject.com/en/5.0/topics/signals/):

- For example we will create a notifications app.
- Then signals.py
- Then register our signals.py in apps.py

```python
from django.apps import AppConfig


class NotificationsConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "notifications"

    def ready(self):
        """Add signals.py."""
        try:
            import notifications.signals  # noqa
        except ImportError:
            pass
```

Inside signals.py we will catch post_save signal which is created by saving Book-model object.

```python
from django.db.models.signals import post_save
from django.dispatch import receiver
from notifications.signals import notify

from books.models import Book


@receiver(post_save, sender=Book)
def create_book_notification(sender, instance, created, **kwargs):
    """Create a notification about the new book."""
    if created:
        notify.send(
            # Who is sending this notification?
            # You may want to add a link to the author's profile
            # inside the notification.
            sender=instance.creator,

            # We are passing a Queryset of subscribers (list of User objects).
            # However, it may also be a User Group or a single User.
            recipient=instance.author.subscribers.all(),

            # A message we would like to send to users.
            verb=(f"A new book released: {instance.title} by"
                  f"{instance.author},"),

            # We will likely want to send a link to the new book to our users.
            # "Target" is GenericForeignKey. In the database, 
            # it is stored as the ContentType ID and the object ID. 
            target=instance,

            # There are several other fields,
            # please refer to the documentation for more information.
        )

    # Let's assume that we want to notify users about 
    # the release of a new chapter in book.
    # The author is allowed to add only new chapters to the text field.
    elif instance.is_dirty():
        # is_dirty - is a method from the DirtyFieldsMixin class.
        # Allowing us to verify whether or not any changes
        # have been made to an object.
        
        # Check if the text field has changed.
        if "text" in instance.get_dirty_fields():
        # get_dirty_fields() - is also a method of the DirtyFieldsMixin class.
        # That allows us to access data that has been changed.
            notify.send(
                sender=instance.creator,
                recipient=instance.author.subscribers.all(),
                # We are creating an almost identical notification,
                # with the only difference being that
                # the notification message has been changed.
                verb=(f"New chapter relesed: {instance.title}"
                      f" by {instance.author}"),
                target=instance,
            )
```
# DRF

Now we want to create API endpoints for these notifications.

## Viewset:

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
        """Personalized unread notification list output."""
        return self.request.user.notifications.unread()

    # empty PATCH request to ./notification/<id>/
    def partial_update(self, request, pk):
        """Mark the notification as read."""
        notification = self.get_object()
        if request.user != notification.recipient:
            return Response(
                {"message": "The notification does not belong to the user."},
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
        """Mark all user notifications as read."""
        request.user.notifications.mark_all_as_read()
        serializer = self.get_serializer({})
        return Response(serializer.data)
    # Instead of creating notifications via websockets,
    # we can make regular requests to ./notification/unseen/
    # to get to know about the new notification.
    @action(methods=["get"], detail=False, serializer_class=UnseenSerializer)
    def unseen(self, request):
        """The number of unread notifications."""
        unread_count = self.request.user.notifications.unread().count()
        serializer = self.get_serializer({"unseen": unread_count})
        return Response(serializer.data)
```

## Serializers:
`notifications_serializer.py`

```python
from notifications.models import Notification
from rest_framework import serializers


class NotificationSerializer(serializers.ModelSerializer):
    """Notification Serializer."""
    # Notification recipient User id.
    recipient_id = serializers.IntegerField(
        read_only=True, source="recipient.id"
    )
    # Notification sender User id.
    actor_id = serializers.IntegerField(read_only=True, source="actor.id")

    # This notification about a book is marked using the class name 'Book'.
    target_content_type = serializers.CharField(
        source="target.__class__.__name__", read_only=True
    )
    # Book id
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
    """Serializer of the number of unread notifications."""

    unseen = serializers.IntegerField()


class MarkAllAsReadSerializer(serializers.Serializer):
    """Serialiser to mark all user notifications as read."""

    message = serializers.CharField(
        default="All notifications are marked as read."
    )
```

# Thanks for reading!