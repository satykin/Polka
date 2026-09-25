import 'package:hive/hive.dart';

/// Хранилище настроек приложения (ключ-значение) на базе Hive.
class SettingsStorage {
  static const String _boxName = 'settings';
  static const String _onboardingKey = 'onboardingShown';

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
}
