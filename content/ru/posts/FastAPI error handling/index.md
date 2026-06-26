+++
date = '2026-06-09T17:00:18+03:00'
draft = true
title = 'FastAPI Error Handling'
author = "Sadykov Miron"
toc = true
tags = ["fastapi", "python", "pydantic", "layered architecture"]
description = 'Система обработки ошибок в FastAPI проекте использующем сервисный слой'
+++

## Система обработки ошибок в FastAPI проекте использующем сервисный слой

- Статья подразумевает базовые знания Python, FastAPI ~0.136.3, Pydantic.

## Вводные

### Задача

- Написать эндпоинт создания экземпляра `Book`.
- У `Book` должна быть валидация входящих значений:
  - Валидация через Pydantic схему - суммарное название(название книги и ФИО автора) должно быть до 254 символов.
  - Валидация подразумевающая использование Базы данных - книга должна быть уникальной для БД(ISBN код книги должен быть новым для БД).
  - Такая валидация имитирует бизнес логику и требует от нас явное использование ошибок.
- В случае ошибки валидации, API должен вернуть ее в формате схожем со стандартной ошибкой возвращаемой FastAPI с Pydantic.
- А конкретно:
  -

    ```json
    {
      "detail": [
        {
          "type": "author_not_found", # type ошибки
          "msg": "Author not found",  # Человеко-читаемый текст ошибки
        }
      ]
    }
    ```
  - `type` нам нужен как **машинное значение** указывающее на конкретную, специфичную ошибку.
    Например его может использовать фронтенд для локализации текстов ошибок или завязывать логику обработки ошибок именно на машинное значение, а не на `msg`.
- В OpenAPI схеме(a.k.a. SwaggerUI), которую генерирует FastAPI, нам надо вывести информацию о том какие ошибки может возвращать наш API, т.е. примеры и описание этих ошибок.

### Почему просто не использовать `HTTPException`?

1. Структура `HTTPException` не соответствует структуре которую возвращает Pydantic по умолчанию.

Такой эндпоинт

```python
@app.post("")
async def foo():
    raise HTTPException(
        status_code=400,
        detail="текст ошибки",
    )
```

Вернет такую ошибку

```json
{
  "detail": "текст ошибки"
}
```

Она будет отличаться по структуре и формату от других ошибок, которые автоматически генерирует FastAPI+Pydantic.

1. Мы не можем использовать `HTTPException` в сервисном слое т.к. сервисный слой может быть вызван не из HTTP эндпоинта, нам надо иметь возможность поймать ошибку которую возвращает сервисный слой.

### Что такое сервисный слой

- В контексте статьи - это просто вынесение кода из эндпоинта в отдельное место, которое называется сервисом.
- Это может быть нужно когда:
  - Этот код будет вызван не только из эндпоинта. Например это может быть cli, или PRC(входящий вызов из другого микросервиса).
  - Для удобства тестирования этого кода. Чтобы написать юниттест для валидации - не нужен тестовый http клиент.

### Для чего это все делается

Валидация бизнес-логики(требующая запросов в БД) будет происходить в сервисном слое, а не в эндпоинте, значит там и будут подниматься ошибки валидации.

- В сервисном слое нельзя просто поднимать стандартную `HTTPException`:
  - Раз этот слой может быть вызван не только из эндпоинта, то нам нужна возможность поймать ошибку которая будет поднята в нем.
- В итоге главная задача минимизировать ручную обработку ошибок и генерацию примеров для OpenAPI(SwaggerUI).

## Реализация

### 1. Эндпоинт

```python
# book_endpoints.py

@app.post("/")
async def create_book(
    book: Annotated[BookCreate, Body()],                  # Тело входящего запроса
    session: Annotated[FooService, Depends(get_session)], # Получение сессии(соединения) с Базой Данных
) -> FooResponse:
    book_service = BookService(session)                   # Экземпляр сервиса для работы с книгами
    created_book = await service.create_book(book)        # Создание книги в сервисе
    return BookResponse.model_validate(created_book)      # Преобразование созданной книги в API ответ(SQLAlchemy объекта в Pydantic схему)
```

#### Pydantic схемы для входящего и исходящего запроса

```python
# book_models.py

class BookCreate(BaseModel):
    """Модель тела входящего запроса, для нашего эндпоинта создания Book."""
    name: str
    author_name: str
    isbn: str

    @model_validator(mode="after")
    def validate_values(self):
        if len(self.name + self.author_name) > 254:
            raise PydanticCustomError(
              error_type=...,                             # Сюда нам надо передать тип ошибки
              message_template=...,                       # Сюда нам надо передать текст ошибки.
            )
        return self

class BookResponse(BaseModel):
    """Модель которой ответит наш эндпоинт после создания Book."""
    id: int
    name: str
    author_name: str
    isbn: str
```

- `PydanticCustomError` используется т.к. он позволяет передать `type` ошибки помимо текстового описания ошибки.

### 2. Сервис

- Репозиторий - это паттерн который предлагает выносить весь код непосредственно выполняющий операции с БД в одно место.
  Т.е. вынести все `select`, `update`, и т.д. от SQLAlchemy в одно место.

```python
# book_service.py

class BookService:
    def __init__(self, session):
        self.repository = BookRepository(session)         # Репозиторий отвечающий за взаимодействие с БД.

    async def create_book(self, book: BookCreate):
        if await self.repository.get_by_isbn(book.isbn):  # Если такой isbn уже есть в бд
            raise BookAlreadyExistsError                  # то поднимаем свою ошибку об этом
```

- В классической ситуации нам надо было бы использовать `try`, `except` в эндпоинте, чтобы поймать эту ошибку.
  И вернуть HTTP статус 400 со своим текстом и типом ошибки.

### 3. Свои ошибки

- Тут мы объявим базовые классы для своих ошибок.

```python
# base_errors.py

class BaseError(Exception):
    """Основная ошибка приложения."""

    def __init__(self, message):
        self.message = message or self.message
        super().__init__(self.message)

# Основная ошибка нам нужна чтобы все наши ошибки имели общую иерархию
# От нее мы будет наследоваться в случае если ошибка не связана с HTTP запросом клиента

class BaseAPIError(BaseError):
    """Основа ошибки для ответов API."""

                         # При создание своих ошибок вроде BookAlreadyExistsError
    message = "error"    # мы переопределим message на человеко-читаемое сообщение
    status_code = 500    # а тут мы напишем какой HTTP статус код должен вернуться с этой ошибкой

    @classmethod
    def type(cls) -> str:
        """Создание типа ошибки из имени класса.

        - Этот метод класса позволит нам использовать имя ошибки для создания
          поля type в HTTP ответе
        - Например класс с названием FooBarError -> foo_bar
        """
        return snakecase(cls.__name__.replace("Error", ""))

class HTTP400Error(BaseAPIError):
    """Ошибка с HTTP статусом 400."""

    status_code: int = status.HTTP_400_BAD_REQUEST
```

```python
# book_errors.py

class BookAlreadyExistsError(BaseAPIError):
    ...
```

### 4. Регистрируем обработчик своих ошибок в FastAPI

### 5. Примеры для OpenAPI

```python
class BaseAPIError(BaseError):
    ... # предыдущее содержимое класса

    def get_schema(self: Self) -> BaseAPIErrorSchema:
        """Получить схему ошибки."""
        return BaseAPIErrorSchema(type=self.type(), msg=self.message)

    @classmethod
    def build_example(
        cls,
        summary: str,
        msg: str | None = None,
    ) -> dict[str, object]:
        """Собрать OpenAPI-пример ошибки."""
        return {
            "summary": summary,
            "value": {
                "detail": [
                    {
                        "type": cls.type(),
                        "msg": msg or cls.message,
                    },
                ],
            },
        }
```

## Источники

- Я не оригинальный автор этого подхода, я почерпнул это из этих источников и немного изменил под свои нужды.
- Перевод на английский выполнен LLM.
- [FastAPI docs - handling errors](https://fastapi.tiangolo.com/tutorial/handling-errors/#override-the-default-exception-handlers)
- [Русскоязычный доклад с PiterPy](https://youtu.be/5j2hgieRstQ?si=zrg0RJZw1HyuKiHh)
- [GitHub repo докладчика с видео](https://github.com/Luferov/fast-clean) я использовал основную идею от туда, и немного изменил ее под свои нужды.
