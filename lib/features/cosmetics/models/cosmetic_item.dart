import 'package:polka/features/cosmetics/models/cosmetic_category.dart';

/// Основная модель косметического средства
class CosmeticItem {
  /// Уникальный идентификатор (UUID)
  final String id;

  /// Название средства
  final String name;

  /// Категория средства
  final CosmeticCategory category;

  /// Цена (может быть неизвестна)
  final double? price;

  /// Цена является примерной
  final bool priceIsApproximate;

  /// Дата покупки (может быть неизвестна)
  final DateTime? purchasedAt;

  /// Дата открытия (может быть неизвестна)
  final DateTime? openedAt;

  /// Срок использования после открытия в месяцах (PAO)
  final int? paoMonths;

  /// Дата последнего использования (может быть неизвестна)
  final DateTime? lastUsedAt;

  /// Дата создания записи
  final DateTime createdAt;

  /// Дата последнего обновления
  final DateTime updatedAt;

  const CosmeticItem({
    required this.id,
    required this.name,
    required this.category,
    this.price,
    this.priceIsApproximate = false,
    this.purchasedAt,
    this.openedAt,
    this.paoMonths,
    this.lastUsedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Создаёт копию объекта с изменёнными полями
  CosmeticItem copyWith({
    String? name,
    CosmeticCategory? category,
    double? price,
    bool? priceIsApproximate,
    DateTime? purchasedAt,
    DateTime? openedAt,
    int? paoMonths,
    DateTime? lastUsedAt,
    DateTime? updatedAt,
  }) {
    return CosmeticItem(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      priceIsApproximate: priceIsApproximate ?? this.priceIsApproximate,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      openedAt: openedAt ?? this.openedAt,
      paoMonths: paoMonths ?? this.paoMonths,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
