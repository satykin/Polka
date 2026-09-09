import 'package:polka/features/cosmetics/models/cosmetic_item.dart';
import 'package:polka/features/cosmetics/models/item_status.dart';

/// Калькулятор статусов косметических средств
class ItemStatusCalculator {
  /// Порог для определения "скоро истекает" (в днях)
  static const int expiringSoonDays = 30;

  /// Порог для определения "активное" (в днях)
  static const int activeDays = 30;

  /// Порог для определения "простаивает" (в днях)
  static const int idleDays = 30;

  /// Рассчитывает статус средства
  ///
  /// Приоритет статусов:
  /// 1. expired
  /// 2. expiringSoon
  /// 3. unopened
  /// 4. active
  /// 5. idle
  ItemStatus calculate(CosmeticItem item, {DateTime? now}) {
    final currentDate = now ?? DateTime.now();

    // Если средство не открыто — unopened
    if (item.openedAt == null) {
      return ItemStatus.unopened;
    }

    // Если есть PAO — проверяем срок годности
    if (item.paoMonths != null) {
      final paoExpiration = _addMonths(item.openedAt!, item.paoMonths!);

      // Если PAO истёк — expired
      if (currentDate.isAfter(paoExpiration)) {
        return ItemStatus.expired;
      }

      // Если до конца PAO осталось меньше 30 дней — expiringSoon
      final daysUntilExpiration = paoExpiration.difference(currentDate).inDays;
      if (daysUntilExpiration <= expiringSoonDays) {
        return ItemStatus.expiringSoon;
      }
    }

    // Если есть дата последнего использования
    if (item.lastUsedAt != null) {
      final daysSinceLastUse = currentDate.difference(item.lastUsedAt!).inDays;

      // Если использовалось в последние 30 дней — active
      if (daysSinceLastUse <= activeDays) {
        return ItemStatus.active;
      }

      // Если давно не использовалось — idle
      if (daysSinceLastUse > idleDays) {
        return ItemStatus.idle;
      }
    }

    // Если средство открыто, но никогда не использовалось — idle
    return ItemStatus.idle;
  }

  /// Добавляет месяцы к дате
  DateTime _addMonths(DateTime date, int months) {
    return DateTime(date.year, date.month + months, date.day);
  }
}
