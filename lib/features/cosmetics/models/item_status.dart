/// Статусы косметических средств
enum ItemStatus {
  active,
  idle,
  expiringSoon,
  expired,
  unopened;

  /// Русское название статуса для отображения в UI
  String get displayName {
    switch (this) {
      case ItemStatus.active:
        return 'Используется';
      case ItemStatus.idle:
        return 'Простаивает';
      case ItemStatus.expiringSoon:
        return 'Скоро истекает';
      case ItemStatus.expired:
        return 'Просрочено';
      case ItemStatus.unopened:
        return 'Не открыто';
    }
  }
}
