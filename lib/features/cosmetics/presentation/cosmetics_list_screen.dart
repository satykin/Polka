import 'package:flutter/material.dart';
import 'package:polka/features/cosmetics/data/cosmetic_repository.dart';
import 'package:polka/features/cosmetics/logic/item_status_calculator.dart';
import 'package:polka/features/cosmetics/models/cosmetic_category.dart';
import 'package:polka/features/cosmetics/models/cosmetic_item.dart';
import 'package:polka/features/cosmetics/models/item_status.dart';
import 'package:polka/features/cosmetics/presentation/add_cosmetic_screen.dart';

/// Главный экран приложения — список косметических средств.
class CosmeticsListScreen extends StatefulWidget {
  final CosmeticRepository repository;
  final ItemStatusCalculator calculator;

  const CosmeticsListScreen({
    super.key,
    required this.repository,
    required this.calculator,
  });

  @override
  State<CosmeticsListScreen> createState() => _CosmeticsListScreenState();
}

class _CosmeticsListScreenState extends State<CosmeticsListScreen> {
  late Future<List<CosmeticItem>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _itemsFuture = widget.repository.getAll();
    });
  }

  Future<void> _openAddScreen() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddCosmeticScreen(repository: widget.repository),
      ),
    );

    // Если новый экран вернул true, обновляем список
    if (result == true) {
      _refreshList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Полка')),
      body: FutureBuilder<List<CosmeticItem>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async => _refreshList(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                final status = widget.calculator.calculate(item);
                return _CosmeticListItem(item: item, status: status);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddScreen,
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
            color: Theme.of(context).colorScheme.onSurface
                .withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Полка пуста',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Добавьте своё первое средство',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface
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
  final ItemStatus status;

  const _CosmeticListItem({required this.item, required this.status});

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
      title: Text(item.name, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(
        item.category.displayName,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      trailing: _StatusBadge(status: status),
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

/// Цветной бейдж статуса средства.
class _StatusBadge extends StatelessWidget {
  final ItemStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;

    switch (status) {
      case ItemStatus.expired:
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
      case ItemStatus.expiringSoon:
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
      case ItemStatus.active:
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
      case ItemStatus.idle:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
      case ItemStatus.unopened:
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
