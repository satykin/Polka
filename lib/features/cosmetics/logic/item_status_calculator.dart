import 'package:polka/features/cosmetics/models/cosmetic_item.dart';
import 'package:polka/features/cosmetics/models/item_status.dart';

/// Калькулятор статусов косметических средств.
///
/// Единственный источник правды о сроках: и статус, и дата истечения
/// считаются здесь, чтобы UI и логика никогда не противоречили друг другу.
class ItemStatusCalculator {
  /// За сколько дней до истечения PAO средство считается «скоро истекающим».
  static const int expiringSoonThresholdDays = 30;

  /// Сколько дней без использования означает «простаивает».
  static const int idleThresholdDays = 30;

  /// Рассчитывает статус средства на момент [now] (по умолчанию — сейчас).
  ItemStatus calculate(CosmeticItem item, {DateTime? now}) {
    final moment = now ?? DateTime.now();

    final openedAt = item.openedAt;
    if (openedAt == null) {
      return ItemStatus.unopened;
    }

    final expiration = expirationDate(item);
    if (expiration != null && !moment.isBefore(expiration)) {
      return ItemStatus.expired;
    }

    if (expiration != null) {
      final left = daysLeft(item, now: moment);
      if (left != null && left <= expiringSoonThresholdDays) {
        return ItemStatus.expiringSoon;
      }
    }

    final lastUsedAt = item.lastUsedAt;
    if (lastUsedAt == null) {
      return ItemStatus.idle;
    }

    final daysSinceUse = daysBetween(lastUsedAt, moment);
    if (daysSinceUse <= idleThresholdDays) {
      return ItemStatus.active;
    }
    return ItemStatus.idle;
  }

  /// Дата истечения средства: дата открытия + PAO в месяцах.
  /// Null, если средство не открыто или PAO не указан.
  DateTime? expirationDate(CosmeticItem item) {
    final openedAt = item.openedAt;
    final paoMonths = item.paoMonths;
    if (openedAt == null || paoMonths == null) {
      return null;
    }
    return addMonths(openedAt, paoMonths);
  }

  /// Сколько дней осталось до истечения срока.
  /// Отрицательное число — средство просрочено.
  /// Null, если дату истечения рассчитать нельзя.
  int? daysLeft(CosmeticItem item, {DateTime? now}) {
    final moment = now ?? DateTime.now();
    final expiration = expirationDate(item);
    if (expiration == null) {
      return null;
    }
    return daysBetween(moment, expiration);
  }

  /// Добавляет [months] месяцев к дате, ограничивая день последним
  /// днём целевого месяца (31.01 + 1 месяц = 28.02).
  static DateTime addMonths(DateTime date, int months) {
    final totalMonths = date.month - 1 + months;
    final year = date.year + totalMonths ~/ 12;
    final month = totalMonths % 12 + 1;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final day = date.day > daysInMonth ? daysInMonth : date.day;
    return DateTime(year, month, day);
  }

  /// Целое число дней между двумя датами (без учёта времени суток).
  static int daysBetween(DateTime from, DateTime to) {
    final fromDate = DateTime(from.year, from.month, from.day);
    final toDate = DateTime(to.year, to.month, to.day);
    return toDate.difference(fromDate).inDays;
  }
}
