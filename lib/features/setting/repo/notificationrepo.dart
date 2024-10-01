import 'package:shared_preferences/shared_preferences.dart';

class NotificationRepo {
  Future<bool> returnNotificationStatus() async {
    final sp = await SharedPreferences.getInstance();
    if (sp.containsKey('notifications')) {
      return sp.getBool('notifications')!;
    } else {
      sp.setBool('notifications', true);
      return true;
    }
  }

  Future<void> saveNotificationData(value) async {
    final sp = await SharedPreferences.getInstance();
    sp.setBool('notifications', value);
  }
}