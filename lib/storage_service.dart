import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _subKey = 'user_subscription_type';

  // Сохранение типа подписки
  static Future<void> saveSubscription(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_subKey, type);
  }

  // Чтение типа подписки
  static Future<String?> getSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_subKey);
  }
}