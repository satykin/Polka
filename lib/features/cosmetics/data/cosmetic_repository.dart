import 'package:polka/features/cosmetics/models/cosmetic_item.dart';

/// Репозиторий для работы с косметическими средствами.
///
/// Сейчас это простая in-memory реализация (данные хранятся в оперативной
/// памяти и теряются при закрытии приложения). В будущем внутренности
/// будут заменены на Hive, но интерфейс (методы) останется тем же.
class CosmeticRepository {
  /// Внутренний список всех средств
  final List<CosmeticItem> _items = [];

  /// Получить все средства
  Future<List<CosmeticItem>> getAll() async {
    // Возвращаем неизменяемую копию, чтобы снаружи нельзя было
    // случайно изменить внутренний список репозитория
    return List.unmodifiable(_items);
  }

  /// Добавить новое средство
  Future<void> add(CosmeticItem item) async {
    _items.add(item);
  }

  /// Обновить существующее средство
  Future<void> update(CosmeticItem item) async {
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      _items[index] = item;
    }
  }

  /// Удалить средство по его ID
  Future<void> delete(String id) async {
    _items.removeWhere((e) => e.id == id);
  }
}
