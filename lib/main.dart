import 'package:flutter/material.dart';
import 'package:polka/core/storage/settings_storage.dart';
import 'package:polka/core/theme/app_theme.dart';
import 'package:polka/features/cosmetics/data/cosmetic_repository.dart';
import 'package:polka/features/cosmetics/data/hive_cosmetic_repository.dart';
import 'package:polka/features/cosmetics/logic/item_status_calculator.dart';
import 'package:polka/features/cosmetics/models/cosmetic_category.dart';
import 'package:polka/features/cosmetics/models/cosmetic_item.dart';
import 'package:polka/features/cosmetics/presentation/home_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем локальную базу данных (Hive)
  final repository = HiveCosmeticRepository();
  await repository.init();

  // Открываем хранилище настроек приложения
  final settings = SettingsStorage();
  await settings.init();

  // Добавляем демо-средства, только если полка ещё пуста
  await seedDemoDataIfNeeded(repository);

  final calculator = ItemStatusCalculator();

  runApp(
    PolkaApp(
      repository: repository,
      calculator: calculator,
      settings: settings,
    ),
  );
}

/// Добавляет демо-средства при самом первом запуске.
/// Если в базе уже есть данные — ничего не добавляет.
Future<void> seedDemoDataIfNeeded(CosmeticRepository repository) async {
  final existing = await repository.getAll();
  if (existing.isNotEmpty) {
    return;
  }

  final now = DateTime.now();

  await repository.add(
    CosmeticItem(
      id: '1',
      name: 'Увлажняющий крем',
      category: CosmeticCategory.face,
      openedAt: now.subtract(const Duration(days: 40)),
      paoMonths: 12,
      lastUsedAt: now.subtract(const Duration(days: 2)),
      createdAt: now,
      updatedAt: now,
    ),
  );

  await repository.add(
    CosmeticItem(
      id: '2',
      name: 'Тушь для ресниц',
      category: CosmeticCategory.makeup,
      openedAt: now.subtract(const Duration(days: 120)),
      paoMonths: 3,
      lastUsedAt: now.subtract(const Duration(days: 5)),
      createdAt: now,
      updatedAt: now,
    ),
  );

  await repository.add(
    CosmeticItem(
      id: '3',
      name: 'Шампунь',
      category: CosmeticCategory.hair,
      openedAt: now.subtract(const Duration(days: 60)),
      paoMonths: 18,
      createdAt: now,
      updatedAt: now,
    ),
  );

  await repository.add(
    CosmeticItem(
      id: '4',
      name: 'Солнцезащитный крем',
      category: CosmeticCategory.sunCare,
      createdAt: now,
      updatedAt: now,
    ),
  );
}

class PolkaApp extends StatefulWidget {
  final CosmeticRepository repository;
  final ItemStatusCalculator calculator;
  final SettingsStorage settings;

  const PolkaApp({
    super.key,
    required this.repository,
    required this.calculator,
    required this.settings,
  });

  @override
  State<PolkaApp> createState() => _PolkaAppState();
}

class _PolkaAppState extends State<PolkaApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.settings.themeMode();
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    setState(() {
      _themeMode = mode;
    });
    await widget.settings.setThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Полка',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: HomeShell(
        repository: widget.repository,
        calculator: widget.calculator,
        settings: widget.settings,
        themeMode: _themeMode,
        onThemeModeChanged: _setThemeMode,
      ),
    );
  }
}
