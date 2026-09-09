import 'package:flutter_test/flutter_test.dart';
import 'package:polka/features/cosmetics/logic/item_status_calculator.dart';
import 'package:polka/features/cosmetics/models/cosmetic_category.dart';
import 'package:polka/features/cosmetics/models/cosmetic_item.dart';
import 'package:polka/features/cosmetics/models/item_status.dart';

void main() {
  group('ItemStatusCalculator', () {
    final calculator = ItemStatusCalculator();
    final now = DateTime(2026, 9, 9);

    test('expired — PAO истёк', () {
      final item = CosmeticItem(
        id: '1',
        name: 'Крем',
        category: CosmeticCategory.face,
        openedAt: DateTime(2026, 1, 1),
        paoMonths: 6,
        createdAt: now,
        updatedAt: now,
      );

      final status = calculator.calculate(item, now: now);

      expect(status, ItemStatus.expired);
    });

    test('expiringSoon — до конца PAO осталось 15 дней', () {
      final item = CosmeticItem(
        id: '2',
        name: 'Тоник',
        category: CosmeticCategory.face,
        openedAt: DateTime(2026, 3, 24),
        paoMonths: 6,
        createdAt: now,
        updatedAt: now,
      );

      final status = calculator.calculate(item, now: now);

      expect(status, ItemStatus.expiringSoon);
    });

    test('unopened — средство не открыто', () {
      final item = CosmeticItem(
        id: '3',
        name: 'Сыворотка',
        category: CosmeticCategory.face,
        createdAt: now,
        updatedAt: now,
      );

      final status = calculator.calculate(item, now: now);

      expect(status, ItemStatus.unopened);
    });

    test('active — использовалось 5 дней назад', () {
      final item = CosmeticItem(
        id: '4',
        name: 'Пенка',
        category: CosmeticCategory.face,
        openedAt: DateTime(2026, 6, 1),
        lastUsedAt: DateTime(2026, 9, 4),
        createdAt: now,
        updatedAt: now,
      );

      final status = calculator.calculate(item, now: now);

      expect(status, ItemStatus.active);
    });

    test('idle — использовалось 60 дней назад', () {
      final item = CosmeticItem(
        id: '5',
        name: 'Маска',
        category: CosmeticCategory.face,
        openedAt: DateTime(2026, 3, 1),
        lastUsedAt: DateTime(2026, 7, 10),
        createdAt: now,
        updatedAt: now,
      );

      final status = calculator.calculate(item, now: now);

      expect(status, ItemStatus.idle);
    });

    test('edge case — нет PAO и нет lastUsedAt', () {
      final item = CosmeticItem(
        id: '6',
        name: 'Лосьон',
        category: CosmeticCategory.body,
        openedAt: DateTime(2026, 6, 1),
        createdAt: now,
        updatedAt: now,
      );

      final status = calculator.calculate(item, now: now);

      expect(status, ItemStatus.idle);
    });
  });
}
