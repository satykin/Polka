import 'package:flutter/material.dart';
import 'package:polka/features/cosmetics/data/cosmetic_repository.dart';
import 'package:polka/features/cosmetics/logic/item_status_calculator.dart';
import 'package:polka/features/cosmetics/models/cosmetic_category.dart';
import 'package:polka/features/cosmetics/models/cosmetic_item.dart';
import 'package:polka/features/cosmetics/models/item_status.dart';
import 'package:polka/features/cosmetics/presentation/add_cosmetic_screen.dart';
import 'package:polka/features/cosmetics/presentation/edit_cosmetic_screen.dart';

/// Запас снизу, чтобы последнее средство не пряталось под кнопкой «+»:
/// 56 высота кнопки + 16 её отступ от края + 16 воздуха.
const double _fabClearance = 88;

/// Главный экран приложения — список косметических средств.
class CosmeticsListScreen extends StatefulWidget {
  final CosmeticRepository repository;
  final ItemStatusCalculator calculator;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const CosmeticsListScreen({
    super.key,
    required this.repository,
    required this.calculator,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<CosmeticsListScreen> createState() => _CosmeticsListScreenState();
}

class _CosmeticsListScreenState extends State<CosmeticsListScreen> {
  late Future<List<CosmeticItem>> _itemsFuture;

  /// Выбранный фильтр. null = показать все.
  ItemStatus? _selectedFilter;

  /// Поиск по названию.
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshList() {
    setState(() {
      _itemsFuture = widget.repository.getAll();
    });
  }

  void _openSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _closeSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _searchQuery = '';
    });
  }

  /// Иконка текущего режима темы.
  IconData get _themeIcon {
    switch (widget.themeMode) {
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  /// Окно выбора темы оформления.
  Future<void> _showThemeDialog() async {
    final result = await showDialog<ThemeMode>(
      context: context,
      builder: (context) => RadioGroup<ThemeMode>(
        groupValue: widget.themeMode,
        onChanged: (value) {
          if (value != null) {
            Navigator.of(context).pop(value);
          }
        },
        child: SimpleDialog(
          title: const Text('Тема оформления'),
          children: const [
            RadioListTile<ThemeMode>(
              title: Text('Системная'),
              value: ThemeMode.system,
            ),
            RadioListTile<ThemeMode>(
              title: Text('Светлая'),
              value: ThemeMode.light,
            ),
            RadioListTile<ThemeMode>(
              title: Text('Тёмная'),
              value: ThemeMode.dark,
            ),
          ],
        ),
      ),
    );
    if (result != null) {
      widget.onThemeModeChanged(result);
    }
  }

  /// Сортирует средства по приоритету статуса, а при равенстве —
  /// по алфавиту названия.
  List<CosmeticItem> _sortItems(List<CosmeticItem> items) {
    final copy = List<CosmeticItem>.from(items);
    copy.sort((a, b) {
      final statusA = widget.calculator.calculate(a);
      final statusB = widget.calculator.calculate(b);
      final priorityA = _statusPriority(statusA);
      final priorityB = _statusPriority(statusB);
      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return copy;
  }

  /// Применяет фильтр по статусу, затем поиск по названию,
  /// затем сортировку.
  List<CosmeticItem> _filterAndSortItems(List<CosmeticItem> items) {
    var result = items;

    if (_selectedFilter != null) {
      result = result
          .where((item) => widget.calculator.calculate(item) == _selectedFilter)
          .toList();
    }

    final query = _searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result
          .where((item) => item.name.toLowerCase().contains(query))
          .toList();
    }

    return _sortItems(result);
  }

  /// Чем меньше число — тем выше средство в списке.
  int _statusPriority(ItemStatus status) {
    switch (status) {
      case ItemStatus.expired:
        return 0;
      case ItemStatus.expiringSoon:
        return 1;
      case ItemStatus.active:
        return 2;
      case ItemStatus.unopened:
        return 3;
      case ItemStatus.idle:
        return 4;
    }
  }

  Future<void> _openAddScreen() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddCosmeticScreen(repository: widget.repository),
      ),
    );

    if (result == true) {
      _refreshList();
    }
  }

  Future<void> _openEditScreen(CosmeticItem item) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) =>
            EditCosmeticScreen(repository: widget.repository, item: item),
      ),
    );

    if (result == true) {
      _refreshList();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Изменения сохранены')));
      }
    }
  }

  Future<void> _markAsUsed(CosmeticItem item) async {
    final now = DateTime.now();
    final updatedItem = item.copyWith(lastUsedAt: now, updatedAt: now);
    await widget.repository.update(updatedItem);
    _refreshList();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('«${item.name}» отмечено как использованное')),
      );
    }
  }

  Future<void> _deleteItem(CosmeticItem item) async {
    await widget.repository.delete(item.id);
    _refreshList();
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('«${item.name}» удалено')));
    }
  }

  /// Подсчёт количества средств для каждого статуса.
  Map<ItemStatus, int> _countByStatus(List<CosmeticItem> items) {
    final counts = <ItemStatus, int>{};
    for (final status in ItemStatus.values) {
      counts[status] = 0;
    }
    for (final item in items) {
      final status = widget.calculator.calculate(item);
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Поиск по названию...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary
                        .withValues(alpha: 0.7),
                  ),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : const Text('Полка'),
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _closeSearch,
              )
            : null,
        actions: [
          if (!_isSearching)
            IconButton(icon: Icon(_themeIcon), onPressed: _showThemeDialog),
          if (!_isSearching)
            IconButton(icon: const Icon(Icons.search), onPressed: _openSearch),
        ],
      ),
      // Системные отступы снизу обрабатывает нижняя панель оболочки,
      // поэтому SafeArea здесь не нужен.
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

          final counts = _countByStatus(items);
          final displayedItems = _filterAndSortItems(items);
          final actionExtent = MediaQuery.of(context).size.width * 0.22;

          return Column(
            children: [
              _FilterChips(
                selectedFilter: _selectedFilter,
                counts: counts,
                onSelected: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
              ),
              Expanded(
                child: displayedItems.isEmpty
                    ? const _EmptyFilterState()
                    : RefreshIndicator(
                        onRefresh: () async => _refreshList(),
                        child: ListView.separated(
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: _fabClearance,
                          ),
                          itemCount: displayedItems.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = displayedItems[index];
                            final status = widget.calculator.calculate(item);
                            return _SwipeTile(
                              itemId: item.id,
                              actionExtent: actionExtent,
                              onMarkUsed: () => _markAsUsed(item),
                              onDelete: () => _deleteItem(item),
                              onTap: () => _openEditScreen(item),
                              child: _CosmeticListItem(
                                item: item,
                                status: status,
                                calculator: widget.calculator,
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
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

/// Плитка со свайпами и «фильтром намерения»: сдвигается только после
/// уверенного горизонтального движения пальца, поэтому покачивания
/// при вертикальной прокрутке никогда не открывают кнопки.
class _SwipeTile extends StatefulWidget {
  final String itemId;
  final double actionExtent;
  final Widget child;
  final VoidCallback onMarkUsed;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _SwipeTile({
    required this.itemId,
    required this.actionExtent,
    required this.child,
    required this.onMarkUsed,
    required this.onDelete,
    required this.onTap,
  });

  @override
  State<_SwipeTile> createState() => _SwipeTileState();
}

class _SwipeTileState extends State<_SwipeTile>
    with SingleTickerProviderStateMixin {
  /// Какая плитка сейчас открыта — чтобы открыта была только одна.
  static final ValueNotifier<String?> _openId = ValueNotifier<String?>(null);

  /// Минимальное горизонтальное смещение, после которого свайп «оживает».
  static const double _engageThreshold = 32;

  /// Насколько горизонтальное движение должно перевешивать вертикальное.
  static const double _directionRatio = 2.5;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  double _offset = 0;
  double _animFrom = 0;
  double _animTo = 0;
  double _accumDx = 0;
  double _accumDy = 0;
  bool _engaged = false;
  bool _openTarget = false;

  @override
  void initState() {
    super.initState();
    _openId.addListener(_handleOpenChanged);
    _controller.addListener(() {
      setState(() {
        final t = Curves.easeOut.transform(_controller.value);
        _offset = _animFrom + (_animTo - _animFrom) * t;
      });
    });
  }

  void _handleOpenChanged() {
    if (!mounted) return;
    if (_openId.value != widget.itemId && _openTarget) {
      _openTarget = false;
      _animateTo(0);
    }
  }

  @override
  void dispose() {
    _openId.removeListener(_handleOpenChanged);
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(double target) {
    _animFrom = _offset;
    _animTo = target;
    _controller.forward(from: 0);
  }

  void _close() {
    if (_openId.value == widget.itemId) {
      _openId.value = null;
    }
    _openTarget = false;
    _animateTo(0);
  }

  void _onDragDown(DragDownDetails details) {
    _accumDx = 0;
    _accumDy = 0;
    _engaged = false;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_engaged) {
      _accumDx += details.delta.dx;
      _accumDy += details.delta.dy;
      // Фильтр намерения: палец явно едет вбок, а не вверх-вниз.
      if (_accumDx.abs() > _engageThreshold &&
          _accumDx.abs() > _accumDy.abs() * _directionRatio) {
        _engaged = true;
        _controller.stop();
      } else {
        return;
      }
    }
    setState(() {
      _offset = (_offset + details.delta.dx).clamp(
        -widget.actionExtent,
        widget.actionExtent,
      );
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_engaged) return;
    final half = widget.actionExtent / 2;
    if (_offset > half) {
      _openTarget = true;
      _openId.value = widget.itemId;
      _animateTo(widget.actionExtent);
    } else if (_offset < -half) {
      _openTarget = true;
      _openId.value = widget.itemId;
      _animateTo(-widget.actionExtent);
    } else {
      _close();
    }
  }

  void _onDragCancel() {
    if (_engaged) {
      _close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final openWidth = _offset.abs().clamp(0.0, widget.actionExtent);

    return Stack(
      children: [
        // Зелёная зона слева (отметить как использованное).
        if (_offset > 0)
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: openWidth,
                child: ColoredBox(
                  color: Colors.green,
                  child: GestureDetector(
                    onTap: () {
                      _close();
                      widget.onMarkUsed();
                    },
                    child: const Center(
                      child: Icon(Icons.check, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        // Красная зона справа (удалить).
        if (_offset < 0)
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: openWidth,
                child: ColoredBox(
                  color: Colors.red,
                  child: GestureDetector(
                    onTap: widget.onDelete,
                    child: const Center(
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        GestureDetector(
          onHorizontalDragDown: _onDragDown,
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          onHorizontalDragCancel: _onDragCancel,
          onTap: () {
            if (_openTarget) {
              _close();
            } else {
              widget.onTap();
            }
          },
          child: Transform.translate(
            offset: Offset(_offset, 0),
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

/// Горизонтальная полоса с chips-фильтрами.
class _FilterChips extends StatelessWidget {
  final ItemStatus? selectedFilter;
  final Map<ItemStatus, int> counts;
  final ValueChanged<ItemStatus?> onSelected;

  const _FilterChips({
    required this.selectedFilter,
    required this.counts,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final total = counts.values.fold(0, (a, b) => a + b);
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          _FilterChipWidget(
            label: 'Все',
            count: total,
            isSelected: selectedFilter == null,
            color: Theme.of(context).colorScheme.primary,
            onTap: () => onSelected(null),
          ),
          const SizedBox(width: 8),
          _FilterChipWidget(
            label: 'Просрочено',
            count: counts[ItemStatus.expired] ?? 0,
            isSelected: selectedFilter == ItemStatus.expired,
            color: Colors.red,
            onTap: () => onSelected(ItemStatus.expired),
          ),
          const SizedBox(width: 8),
          _FilterChipWidget(
            label: 'Скоро',
            count: counts[ItemStatus.expiringSoon] ?? 0,
            isSelected: selectedFilter == ItemStatus.expiringSoon,
            color: Colors.orange,
            onTap: () => onSelected(ItemStatus.expiringSoon),
          ),
          const SizedBox(width: 8),
          _FilterChipWidget(
            label: 'Используется',
            count: counts[ItemStatus.active] ?? 0,
            isSelected: selectedFilter == ItemStatus.active,
            color: Colors.green,
            onTap: () => onSelected(ItemStatus.active),
          ),
          const SizedBox(width: 8),
          _FilterChipWidget(
            label: 'Не открыто',
            count: counts[ItemStatus.unopened] ?? 0,
            isSelected: selectedFilter == ItemStatus.unopened,
            color: Colors.blue,
            onTap: () => onSelected(ItemStatus.unopened),
          ),
          const SizedBox(width: 8),
          _FilterChipWidget(
            label: 'Простаивает',
            count: counts[ItemStatus.idle] ?? 0,
            isSelected: selectedFilter == ItemStatus.idle,
            color: Colors.grey,
            onTap: () => onSelected(ItemStatus.idle),
          ),
        ],
      ),
    );
  }
}

/// Один chip-фильтр.
class _FilterChipWidget extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChipWidget({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade400),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
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

/// Виджет пустого результата при фильтре или поиске.
class _EmptyFilterState extends StatelessWidget {
  const _EmptyFilterState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_list_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface
                .withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Ничего не найдено',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Попробуйте изменить фильтры или запрос',
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
  final ItemStatusCalculator calculator;

  const _CosmeticListItem({
    required this.item,
    required this.status,
    required this.calculator,
  });

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
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.category.displayName,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 2),
          Text(
            _infoText(),
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: _infoColor(context)),
          ),
        ],
      ),
      trailing: _StatusBadge(status: status),
    );
  }

  /// Вторая строка: дата открытия и сколько осталось до истечения.
  String _infoText() {
    final openedAt = item.openedAt;
    if (openedAt == null) {
      return 'Не открыто';
    }

    final expiration = calculator.expirationDate(item);
    if (expiration == null) {
      return 'Открыто ${_formatDate(openedAt)}';
    }

    final left = calculator.daysLeft(item) ?? 0;
    if (left > 0) {
      return 'Открыто ${_formatDate(openedAt)} · осталось ${_pluralDays(left)}';
    }
    if (left == 0) {
      return 'Истекает сегодня';
    }
    return 'Просрочено ${_pluralDays(-left)} назад';
  }

  /// Цвет второй строки: красный для просрочки, оранжевый для «скоро».
  Color _infoColor(BuildContext context) {
    switch (status) {
      case ItemStatus.expired:
        return Colors.red.shade900;
      case ItemStatus.expiringSoon:
        return Colors.orange.shade900;
      default:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  /// Правильное склонение: «1 день», «2 дня», «5 дней».
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
