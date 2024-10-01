import 'package:linkup/features/setting/repo/notificationrepo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'setting_viewmodel.g.dart';

@riverpod
class NotificationSwitch extends _$NotificationSwitch {
  NotificationRepo repo = NotificationRepo();

  @override
  Future<bool> build() async {
    final value = await repo.returnNotificationStatus();
    return value;
  }

  Future<void> changeNotification() async {
    final value = state.valueOrNull;
    repo.saveNotificationData(!value!);
    state = AsyncData(!value);
  }
}
