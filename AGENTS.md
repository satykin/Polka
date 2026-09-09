# AGENTS.md — правила для Qwen AI / AI-разработчика

## 1. Роль
AI-разработчик работает над проектом «Полка 2.0» поэтапно.

Основной инструмент текущей разработки — Qwen AI / Qwen Code. Правила также применимы к другому AI-инструменту, если он используется вместо Qwen.

## 2. Порядок приоритетов
При конфликте:

```text
POLKA_2_0.md
↓
ARCHITECTURE.md
↓
TASKS.md
↓
README.md
```

Если документы противоречат друг другу — не угадывать и не молча выбирать. Сообщить о конфликте.

## 3. Перед любой задачей
1. Прочитать связанную задачу.
2. Прочитать релевантные разделы POLKA_2_0.md.
3. Прочитать ARCHITECTURE.md.
4. Изучить существующий код.
5. Составить краткий план.
6. Выполнять только текущую задачу.

## 4. Главные ограничения MVP
Не добавлять без подтверждения:
- backend;
- API;
- SQL;
- аккаунты;
- авторизацию;
- синхронизацию;
- облако;
- AI;
- OCR;
- фото-распознавание;
- платежи;
- подписки.

## 5. YAGNI
Не добавлять поля, классы, сервисы и библиотеки «на будущее».

Не добавлять в CosmeticItem:
- brand;
- volume;
- expirationDate;
- manufacturerExpirationDate;
- deletedAt.

если текущая задача и POLKA_2_0.md этого не требуют.

## 6. CosmeticItem
Единый набор MVP:

```text
id
name
category
price
priceIsApproximate
purchasedAt
openedAt
paoMonths
lastUsedAt
createdAt
updatedAt
```

## 7. Categories

```text
face
makeup
hair
body
sunCare
other
```

## 8. Status

```text
active
idle
expiringSoon
expired
unopened
```

Приоритет:

```text
expired
→ expiringSoon
→ unopened
→ active
→ idle
```

«Forgotten» — название экрана/выборки, а не enum status.

## 9. Архитектура
Следовать ARCHITECTURE.md.

Не создавать альтернативную структуру папок без согласования.

Не переносить Hive в top-level storage.

Не создавать отдельный shelf feature, если это просто экран items.

## 10. Зависимости
Перед добавлением новой зависимости:
1. объяснить проблему;
2. объяснить альтернативы;
3. объяснить место использования;
4. дождаться подтверждения, если зависимость не предусмотрена текущей задачей.

## 11. Изменения
Не делать массовый рефакторинг ради текущей небольшой задачи.

Если требуется изменить много файлов — сначала объяснить почему.

## 12. Проверка
После реализации:
```bash
flutter format .
flutter analyze
flutter test
```

Если менялся UI — проверить на реальном Realme GT 5 Neo.

## 13. Git
Одна законченная задача — один логичный commit.

Формат:
- feat:
- fix:
- refactor:
- test:
- docs:

## 14. DONE REPORT
После задачи сообщить:

```text
TASK:
STATUS:
CHANGED FILES:
WHAT CHANGED:
CHECKS:
MANUAL PHONE CHECK:
RISKS / NOTES:
NEXT TASK:
```

## 15. Запрет на самовольное продолжение
После завершения текущей задачи не переходить к следующей автоматически.
