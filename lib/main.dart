import 'package:flutter/material.dart';
import 'package:polka/core/theme/app_theme.dart';
import 'package:polka/features/cosmetics/data/cosmetic_repository.dart';
import 'package:polka/features/cosmetics/logic/item_status_calculator.dart';
import 'package:polka/features/cosmetics/models/cosmetic_category.dart';
import 'package:polka/features/cosmetics/models/cosmetic_item.dart';
import 'package:polka/features/cosmetics/presentation/cosmetics_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Создаём экземпляры наших сервисов
  final repository = CosmeticRepository();
  final calculator = ItemStatusCalculator();

  // Наполняем репозиторий тестовыми данными
  await repository.add(
    CosmeticItem(
      id: '1',
      name: 'Увлажняющий крем',
      category: CosmeticCategory.face,
      openedAt: DateTime(2026, 8, 1),
      paoMonths: 12,
      lastUsedAt: DateTime(2026, 9, 8), // Использовалось недавно
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 9, 8),
    ),
  );

  await repository.add(
    CosmeticItem(
      id: '2',
      name: 'Тушь для ресниц',
      category: CosmeticCategory.makeup,
      openedAt: DateTime(2026, 5, 15),
      paoMonths: 3, // Срок 3 месяца истёк ещё в августе!
      lastUsedAt: DateTime(2026, 9, 7),
      createdAt: DateTime(2026, 5, 15),
      updatedAt: DateTime(2026, 9, 7),
    ),
  );

  await repository.add(
    CosmeticItem(
      id: '3',
      name: 'Шампунь',
      category: CosmeticCategory.hair,
      openedAt: DateTime(2026, 7, 10),
      paoMonths: 18,
      // Не указан lastUsedAt, будет считаться простаивающим
      createdAt: DateTime(2026, 7, 10),
      updatedAt: DateTime(2026, 7, 10),
    ),
  );

  await repository.add(
    CosmeticItem(
      id: '4',
      name: 'Солнцезащитный крем',
      category: CosmeticCategory.sunCare,
      // Не указан openedAt
      createdAt: DateTime(2026, 6, 1),
      updatedAt: DateTime(2026, 6, 1),
    ),
  );

  runApp(PolkaApp(repository: repository, calculator: calculator));
}

class PolkaApp extends StatelessWidget {
  final CosmeticRepository repository;
  final ItemStatusCalculator calculator;

  const PolkaApp({
    super.key,
    required this.repository,
    required this.calculator,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Полка',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: CosmeticsListScreen(repository: repository, calculator: calculator),
    );
  }
}
