import 'package:flutter/material.dart';
import 'package:polka/features/cosmetics/models/cosmetic_category.dart';
import 'package:polka/features/cosmetics/models/cosmetic_item.dart';

/// Главный экран приложения — список косметических средств.
class CosmeticsListScreen extends StatelessWidget {
  const CosmeticsListScreen({super.key});

  /// Статические тестовые данные для демонстрации UI.
  /// Позже будут заменены на реальные данные из репозитория.
  static final List<CosmeticItem> _mockItems = [
    CosmeticItem(
      id: '1',
      name: 'Увлажняющий крем',
      category: CosmeticCategory.face,
      openedAt: DateTime(2026, 8, 1),
      paoMonths: 12,
      lastUsedAt: DateTime(2026, 9, 8),
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 9, 8),
    ),
    CosmeticItem(
      id: '2',
      name: 'Тушь для ресниц',
      category: CosmeticCategory.makeup,
      openedAt: DateTime(2026, 5, 15),
      paoMonths: 3,
      lastUsedAt: DateTime(2026, 9, 7),
      createdAt: DateTime(2026, 5, 15),
      updatedAt: DateTime(2026, 9, 7),
    ),
    CosmeticItem(
      id: '3',
      name: 'Шампунь',
      category: CosmeticCategory.hair,
      openedAt: DateTime(2026, 7, 10),
      paoMonths: 18,
      createdAt: DateTime(2026, 7, 10),
      updatedAt: DateTime(2026, 7, 10),
    ),
    CosmeticItem(
      id: '4',
      name: 'Солнцезащитный крем',
      category: CosmeticCategory.sunCare,
      createdAt: DateTime(2026, 6, 1),
      updatedAt: DateTime(2026, 6, 1),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Полка'),
      ),
      body: _mockItems.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _mockItems.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return _CosmeticListItem(item: _mockItems[index]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Заглушка — добавление средства добавим позже
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Виджет пустого состояния (когда средств ещё нет).
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.spa_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Полка пуста',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Добавьте своё первое средство',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
          ),
        ],
      ),
    );
  }
}

/// Элемент списка косметического средства.
class _CosmeticListItem extends StatelessWidget {
  final CosmeticItem item;

  const _CosmeticListItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        child: Icon(
          _iconForCategory(item.category),
          color: colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(
        item.name,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        item.category.displayName,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Скоро',
          style: TextStyle(
            color: colorScheme.onSecondaryContainer,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  IconData _iconForCategory(CosmeticCategory category) {
    switch (category) {
      case CosmeticCategory.face:
        return Icons.face;
      case CosmeticCategory.makeup:
        return Icons.brush;
      case CosmeticCategory.hair:
        return Icons.content_cut;
      case CosmeticCategory.body:
        return Icons.spa;
      case CosmeticCategory.sunCare:
        return Icons.wb_sunny;
      case CosmeticCategory.other:
        return Icons.inventory_2;
    }
  }
}