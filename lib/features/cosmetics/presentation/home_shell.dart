import 'package:flutter/material.dart';
import 'package:polka/features/cosmetics/data/cosmetic_repository.dart';
import 'package:polka/features/cosmetics/logic/item_status_calculator.dart';
import 'package:polka/features/cosmetics/presentation/cosmetics_list_screen.dart';
import 'package:polka/features/cosmetics/presentation/stats_screen.dart';

/// Оболочка приложения с нижней панелью из двух вкладок.
class HomeShell extends StatefulWidget {
  final CosmeticRepository repository;
  final ItemStatusCalculator calculator;

  const HomeShell({
    super.key,
    required this.repository,
    required this.calculator,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

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
