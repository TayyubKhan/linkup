import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'setting_viewmodel.g.dart';

@riverpod
class NotificationSwitch extends _$NotificationSwitch {
  @override
  bool build() {
    return state;
  }

  void changeNotification() {
    state = !state;
  }
}
