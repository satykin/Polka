import 'package:flutter/material.dart';
import 'package:polka/core/storage/settings_storage.dart';
import 'package:polka/features/cosmetics/data/cosmetic_repository.dart';
import 'package:polka/features/cosmetics/logic/item_status_calculator.dart';
import 'package:polka/features/cosmetics/presentation/cosmetics_list_screen.dart';
import 'package:polka/features/cosmetics/presentation/onboarding_dialog.dart';
import 'package:polka/features/cosmetics/presentation/stats_screen.dart';

/// Оболочка приложения с нижней панелью из двух вкладок.
class HomeShell extends StatefulWidget {
  final CosmeticRepository repository;
  final ItemStatusCalculator calculator;
  final SettingsStorage settings;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const HomeShell({
    super.key,
    required this.repository,
    required this.calculator,
    required this.settings,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Показываем обучающую подсказку после первого кадра,
    // но только один раз за всё время жизни приложения.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOnboardingIfNeeded();
    });
  }

  Future<void> _showOnboardingIfNeeded() async {
    if (!mounted) return;
    if (widget.settings.isOnboardingShown()) return;
    await showDialog<void>(
      context: context,
      builder: (context) => const OnboardingDialog(),
    );
    if (!mounted) return;
    await widget.settings.setOnboardingShown(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack сохраняет состояние обеих вкладок
      // (прокрутка списка, фильтры и поиск не сбрасываются).
      body: IndexedStack(
        index: _index,
        children: [
          CosmeticsListScreen(
            repository: widget.repository,
            calculator: widget.calculator,
            themeMode: widget.themeMode,
            onThemeModeChanged: widget.onThemeModeChanged,
          ),
          StatsScreen(
            repository: widget.repository,
            calculator: widget.calculator,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) {
          setState(() {
            _index = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Полка',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Обзор',
          ),
        ],
      ),
    );
  }
}
