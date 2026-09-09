/// Категории косметических средств
enum CosmeticCategory {
  face,
  makeup,
  hair,
  body,
  sunCare,
  other;

  /// Русское название категории для отображения в UI
  String get displayName {
    switch (this) {
      case CosmeticCategory.face:
        return 'Лицо';
      case CosmeticCategory.makeup:
        return 'Макияж';
      case CosmeticCategory.hair:
        return 'Волосы';
      case CosmeticCategory.body:
        return 'Тело';
      case CosmeticCategory.sunCare:
        return 'Солнцезащита';
      case CosmeticCategory.other:
        return 'Другое';
    }
  }
}
