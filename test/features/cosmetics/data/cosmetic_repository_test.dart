import 'package:flutter_test/flutter_test.dart';
import 'package:polka/features/cosmetics/data/in_memory_cosmetic_repository.dart';
import 'package:polka/features/cosmetics/models/cosmetic_category.dart';
import 'package:polka/features/cosmetics/models/cosmetic_item.dart';

void main() {
  group('InMemoryCosmeticRepository', () {
    late InMemoryCosmeticRepository repository;
    final now = DateTime(2026, 9, 9);

    setUp(() {
      repository = InMemoryCosmeticRepository();
    });

    CosmeticItem createItem(String id) {
      return CosmeticItem(
        id: id,
        name: 'Test Item $id',
        category: CosmeticCategory.face,
        createdAt: now,
        updatedAt: now,
      );
    }

    test('add — adds an item to the list', () async {
      final item = createItem('1');
      await repository.add(item);

      final items = await repository.getAll();
      expect(items.length, 1);
      expect(items.first.id, '1');
    });

    test('update — updates an existing item', () async {
      final item = createItem('2');
      await repository.add(item);

      final updatedItem = item.copyWith(name: 'Updated Name');
      await repository.update(updatedItem);

      final items = await repository.getAll();
      expect(items.length, 1);
      expect(items.first.name, 'Updated Name');
    });

    test('delete — removes an item by ID', () async {
      final item = createItem('3');
      await repository.add(item);

      await repository.delete('3');

      final items = await repository.getAll();
      expect(items.isEmpty, true);
    });

    test('getAll — returns an unmodifiable list', () async {
      final item = createItem('4');
      await repository.add(item);

      final items = await repository.getAll();

      // Attempting to modify the returned list should throw an error
      expect(
        () => items.add(createItem('5')),
        throwsA(isA<UnsupportedError>()),
      );

      // The original list in the repository should remain unchanged
      final originalItems = await repository.getAll();
      expect(originalItems.length, 1);
    });
  });
}
