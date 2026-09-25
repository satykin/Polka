import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// Хранилище настроек приложения (ключ-значение) на базе Hive.
class SettingsStorage {
  static const String _boxName = 'settings';
  static const String _onboardingKey = 'onboardingShown';
  static const String _themeKey = 'themeMode';

  /// Открывает коробку настроек. Вызывать после инициализации Hive.
  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  /// Показана ли уже подсказка при первом запуске.
  bool isOnboardingShown() {
    return Hive.box(_boxName).get(_onboardingKey, defaultValue: false) as bool;
  }

  /// Отметить подсказку показанной.
  Future<void> setOnboardingShown(bool value) async {
    await Hive.box(_boxName).put(_onboardingKey, value);
  }

  /// Выбранный режим темы. По умолчанию — системный.
  ThemeMode themeMode() {
    final name =
        Hive.box(_boxName).get(_themeKey, defaultValue: 'system') as String;
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => ThemeMode.system,
    );
  }

  /// Сохранить выбранный режим темы.
  Future<void> setThemeMode(ThemeMode mode) async {
    await Hive.box(_boxName).put(_themeKey, mode.name);
  }
}
