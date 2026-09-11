import 'package:polka/features/cosmetics/data/cosmetic_repository.dart';
import 'package:polka/features/cosmetics/models/cosmetic_item.dart';

/// Репозиторий, хранящий данные в оперативной памяти.
/// Используется в тестах.
class InMemoryCosmeticRepository implements CosmeticRepository {
  final List<CosmeticItem> _items = [];

  @override
  Future<List<CosmeticItem>> getAll() async {
    return List.unmodifiable(_items);
  }

  @override
  Future<void> add(CosmeticItem item) async {
    _items.add(item);
  }

  @override
  Future<void> update(CosmeticItem item) async {
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      _items[index] = item;
    }
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((e) => e.id == id);
  }
}
