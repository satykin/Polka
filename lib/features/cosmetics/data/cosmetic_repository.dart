import 'package:polka/features/cosmetics/models/cosmetic_item.dart';

/// Абстрактный интерфейс репозитория косметических средств.
///
/// Реализации:
/// - HiveCosmeticRepository — постоянное хранение на устройстве;
/// - InMemoryCosmeticRepository — хранение в памяти (для тестов).
abstract class CosmeticRepository {
  /// Получить все средства
  Future<List<CosmeticItem>> getAll();

  /// Добавить новое средство
  Future<void> add(CosmeticItem item);

  /// Обновить существующее средство
  Future<void> update(CosmeticItem item);

  /// Удалить средство по его ID
  Future<void> delete(String id);
}
