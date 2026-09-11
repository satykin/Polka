import 'package:hive_flutter/hive_flutter.dart';
import 'package:polka/features/cosmetics/data/cosmetic_item_adapter.dart';
import 'package:polka/features/cosmetics/data/cosmetic_repository.dart';
import 'package:polka/features/cosmetics/models/cosmetic_item.dart';

/// Репозиторий с постоянным хранением данных на устройстве (Hive).
class HiveCosmeticRepository implements CosmeticRepository {
  static const String boxName = 'cosmetics';

  /// Инициализация базы данных. Вызывать один раз при старте приложения.
  Future<void> init() async {
    await Hive.initFlutter();

    final adapter = CosmeticItemAdapter();
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }

    await Hive.openBox<CosmeticItem>(boxName);
  }

  Box<CosmeticItem> get _box => Hive.box<CosmeticItem>(boxName);

  @override
  Future<List<CosmeticItem>> getAll() async {
    return _box.values.toList();
  }

  @override
  Future<void> add(CosmeticItem item) async {
    await _box.put(item.id, item);
  }

  @override
  Future<void> update(CosmeticItem item) async {
    await _box.put(item.id, item);
  }

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
