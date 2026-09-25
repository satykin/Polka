import 'package:flutter/material.dart';
import 'package:polka/features/cosmetics/data/cosmetic_repository.dart';
import 'package:polka/features/cosmetics/logic/item_status_calculator.dart';
import 'package:polka/features/cosmetics/models/cosmetic_item.dart';
import 'package:polka/features/cosmetics/models/item_status.dart';

/// Экран статистики «Обзор».
class StatsScreen extends StatelessWidget {
  final CosmeticRepository repository;
  final ItemStatusCalculator calculator;

  const StatsScreen({
    super.key,
    required this.repository,
    required this.calculator,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Обзор')),
      body: FutureBuilder<List<CosmeticItem>>(
        future: repository.getAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Пока нет данных для статистики.\nДобавьте первое средство на вкладке «Полка».',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }

          final counts = <ItemStatus, int>{
            for (final status in ItemStatus.values) status: 0,
          };
          var totalSpent = 0.0;
          var hasApprox = false;
          for (final item in items) {
            final status = calculator.calculate(item);
            counts[status] = (counts[status] ?? 0) + 1;
            if (item.price != null) {
              totalSpent += item.price!;
              if (item.priceIsApproximate) {
                hasApprox = true;
              }
            }
          }

          final expiring = items
              .where((item) => calculator.expirationDate(item) != null)
              .toList();
          expiring.sort(
            (a, b) => (calculator.daysLeft(a) ?? 0).compareTo(
              calculator.daysLeft(b) ?? 0,
            ),
          );
          final top = expiring.take(3).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _TotalCard(count: items.length),
              if (totalSpent > 0) ...[
                const SizedBox(height: 16),
                _SpentCard(total: totalSpent, hasApprox: hasApprox),
              ],
              const SizedBox(height: 16),
              _StatusGrid(counts: counts),
              const SizedBox(height: 24),
              Text(
                'Ближе всего к истечению',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (top.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Нет средств с известным сроком',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              else
                ...top.map(
                  (item) => _ExpiringTile(item: item, calculator: calculator),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Сетка карточек статусов: по две в ряд, ширина каждой — ровно половина.
/// Высота каждой карточки определяется её содержимым,
/// поэтому переполнение и схлопывание невозможны на любом экране.
class _StatusGrid extends StatelessWidget {
  final Map<ItemStatus, int> counts;

  const _StatusGrid({required this.counts});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatusCard(
        label: 'Просрочено',
        count: counts[ItemStatus.expired] ?? 0,
        color: Colors.red,
      ),
      _StatusCard(
        label: 'Скоро истекает',
        count: counts[ItemStatus.expiringSoon] ?? 0,
        color: Colors.orange,
      ),
      _StatusCard(
        label: 'Используется',
        count: counts[ItemStatus.active] ?? 0,
        color: Colors.green,
      ),
      _StatusCard(
        label: 'Не открыто',
        count: counts[ItemStatus.unopened] ?? 0,
        color: Colors.blue,
      ),
      _StatusCard(
        label: 'Простаивает',
        count: counts[ItemStatus.idle] ?? 0,
        color: Colors.grey,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final card in cards) SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }
}

/// Карточка общего количества средств.
class _TotalCard extends StatelessWidget {
  final int count;

  const _TotalCard({required this.count});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2,
            size: 40,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                'Всего средств на полке',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onPrimaryContainer),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Карточка общей суммы потраченного.
class _SpentCard extends StatelessWidget {
  final double total;
  final bool hasApprox;

  const _SpentCard({required this.total, required this.hasApprox});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            Icons.payments,
            size: 40,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${hasApprox ? '≈ ' : ''}${_formatMoney(total)} ₽',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              Text(
                'Всего потрачено',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSecondaryContainer),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatMoney(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
  }
}

/// Цветная карточка количества средств одного статуса.
class _StatusCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatusCard({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// Строка списка «ближе всего к истечению».
class _ExpiringTile extends StatelessWidget {
  final CosmeticItem item;
  final ItemStatusCalculator calculator;

  const _ExpiringTile({required this.item, required this.calculator});

  @override
  Widget build(BuildContext context) {
    final left = calculator.daysLeft(item) ?? 0;
    final expiration = calculator.expirationDate(item);

    final Color color;
    final String daysText;
    if (left < 0) {
      color = Colors.red.shade900;
      daysText = 'просрочено ${_pluralDays(-left)} назад';
    } else if (left == 0) {
      color = Colors.orange.shade900;
      daysText = 'истекает сегодня';
    } else if (left <= 30) {
      color = Colors.orange.shade900;
      daysText = 'осталось ${_pluralDays(left)}';
    } else {
      color = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
      daysText = 'осталось ${_pluralDays(left)}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                if (expiration != null)
                  Text(
                    'истекает ${_formatDate(expiration)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          Text(
            daysText,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  String _pluralDays(int n) {
    final abs = n.abs();
    final mod10 = abs % 10;
    final mod100 = abs % 100;
    if (mod10 == 1 && mod100 != 11) return '$n день';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return '$n дня';
    }
    return '$n дней';
  }
}
