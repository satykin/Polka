# Полка 2.0 — архитектура

## 1. Архитектурный принцип
MVP должен быть простым, локальным и расширяемым без преждевременной сложности.

Подход:
- Flutter + Dart;
- feature-first;
- внутри крупных feature: data / domain / presentation;
- Riverpod;
- Hive для локального хранения.

## 2. Структура

```text
lib/
├── main.dart
├── app/
│   └── app.dart
├── core/
│   ├── constants/
│   ├── theme/
│   └── utils/
├── features/
│   ├── onboarding/
│   │   └── presentation/
│   ├── dashboard/
│   │   └── presentation/
│   ├── items/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── settings/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── shared/
    └── widgets/
```

Не создавать отдельные top-level `storage/`, `analytics/`, `shelf/` или `cosmetics/` в MVP без реальной необходимости.

## 3. Items feature

### Domain
- CosmeticItem
- CosmeticCategory
- ItemStatus
- StatusCalculator
- ItemsRepository contract

### Data
- Hive model / adapter
- ItemsRepository implementation

### Presentation
- ShelfScreen
- AddItemScreen
- EditItemScreen
- ItemDetailsScreen
- ForgottenItemsScreen
- ExpiringSoonScreen
- Riverpod providers/controllers

## 4. CosmeticItem

```dart
class CosmeticItem {
  final String id;
  final String name;
  final CosmeticCategory category;
  final double? price;
  final bool priceIsApproximate;
  final DateTime? purchasedAt;
  final DateTime? openedAt;
  final int? paoMonths;
  final DateTime? lastUsedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

`brand`, `volume`, `expirationDate` и manufacturer expiration не входят в MVP.

## 5. Category

```text
face
makeup
hair
body
sunCare
other
```

## 6. Status

```text
active
idle
expiringSoon
expired
unopened
```

Статус вычисляется через `StatusCalculator`.

Единый приоритет:

```text
expired
→ expiringSoon
→ unopened
→ active
→ idle
```

## 7. Логика PAO

Если есть:
- `openedAt`
- `paoMonths`

то:

```text
paoExpiration = openedAt + paoMonths
```

Если дата прошла — `expired`.

Если до неё осталось меньше настраиваемого порога — `expiringSoon`.

## 8. Локальное хранение
Hive скрыт за Repository.

UI и domain не должны напрямую работать с Hive API.

```text
Presentation
    ↓
Controller / Provider
    ↓
Repository
    ↓
Hive
```

## 9. Riverpod
Riverpod используется для:
- списка средств;
- CRUD;
- пересчёта UI;
- настроек;
- состояния онбординга.

Не создавать сложные state machines, если достаточно простого provider/controller.

## 10. Настройки
Настройки хранятся локально отдельно от косметики.

Минимальные параметры:
- onboarding completed;
- idle threshold;
- expiring soon threshold.

## 11. Удаление
В MVP используется физическое удаление через repository.

Soft delete появится только при появлении синхронизации или другой реальной необходимости.

## 12. Навигация
Минимальный маршрут:

```text
Onboarding
   ↓
Shelf
   ├── Add Item
   ├── Item Details
   ├── Dashboard
   ├── Forgotten
   ├── Expiring Soon
   └── Settings
```

## 13. Тесты
Обязательно тестировать:
- StatusCalculator;
- PAO calculation;
- приоритет статусов;
- repository CRUD;
- ключевые пользовательские сценарии.

## 14. Правило расширения
Будущие функции добавляются отдельными feature или расширением существующих только после продуктового решения.
