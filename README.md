# Полка 2.0

Локальное Flutter-приложение для домашнего аудита косметики.

## Быстрый статус MVP

Первая фаза:
- Flutter;
- Dart;
- Hive;
- Riverpod;
- реальный Android-телефон Realme GT 5 Neo;
- без обязательного Android Studio.

Нет:
- сервера;
- SQL;
- аккаунтов;
- синхронизации;
- облака.

## Документы

- `POLKA_2_0.md` — что создаём.
- `ARCHITECTURE.md` — как создаём.
- `AGENTS.md` — как работает Qwen AI / AI-разработчик.
- `TASKS.md` — что делать по шагам.
- `README.md` — запуск и рабочий процесс.

## 1. Проверить Flutter

```bash
flutter --version
flutter doctor
```

## 2. Настроить телефон

На Realme:
1. Открыть настройки.
2. Найти «О телефоне».
3. Включить режим разработчика.
4. Включить USB debugging / Отладку по USB.
5. Подключить телефон кабелем передачи данных.
6. Разрешить отладку на телефоне.

Проверить:

```bash
adb devices
```

Ожидается устройство со статусом:

```text
device
```

Затем:

```bash
flutter devices
```

Телефон должен появиться в списке.

## Если unauthorized

Разблокировать телефон и подтвердить разрешение USB debugging.

## Если устройство не видно

Проверить:
- кабель поддерживает передачу данных;
- включена USB debugging;
- телефон разблокирован;
- разрешение подтверждено.

Перезапустить ADB:

```bash
adb kill-server
adb start-server
adb devices
```

## 3. Создать проект

```bash
cd C:\Projects
flutter create polka
cd polka
```

## 4. Первый запуск

```bash
flutter run
```

Приложение должно запуститься на Realme GT 5 Neo.

## 5. Hot Reload

Во время `flutter run`:

```text
r
```

— Hot Reload.

```text
R
```

— Hot Restart.

## 6. Git

```bash
git init
git add .
git commit -m "Initial project"
```

## 7. Перед работой с Qwen

Поместить пять MD-файлов в корень проекта.

Первый запрос Qwen:

```text
Прочитай:
POLKA_2_0.md
ARCHITECTURE.md
AGENTS.md
TASKS.md
README.md

Не меняй код.

Изучи проект и дай:
1. текущий статус;
2. выполненные задачи;
3. следующую задачу;
4. краткий план;
5. список файлов, которые потребуется изменить.

После анализа остановись и жди подтверждения.
```

## 8. Ежедневный цикл

```bash
adb devices
flutter devices
flutter run
```

После изменений:

```bash
flutter format .
flutter analyze
flutter test
```

Если менялся UI — проверить на реальном телефоне.

## 9. Git после задачи

```bash
git status
git diff
git add .
git commit -m "feat: ..."
```

## 10. Главное правило

Одна задача за раз.

Не просить Qwen:
> «Сделай всё приложение».

Работать по TASKS.md.

## 11. Если Android Studio не запускается

Это не блокирует первый этап.

Для текущего MVP основной путь:
- Flutter SDK;
- Android SDK / platform tools;
- ADB;
- реальный Realme GT 5 Neo.

Android Studio можно восстановить или установить позже, когда появится необходимость в удобной инспекции Android SDK или нативного кода.

## 12. После MVP

Не начинать автоматически:
- сервер;
- аккаунты;
- синхронизацию;
- AI.

Сначала проверить, пользуются ли люди приложением и какие функции им действительно нужны.
