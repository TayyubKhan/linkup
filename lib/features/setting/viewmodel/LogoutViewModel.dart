import 'package:linkup/features/continue/Repository/name_storing%20repo.dart';
import 'package:linkup/features/continue/viewModel/ContinueViewModel.dart';
import 'package:linkup/features/setting/viewmodel/setting_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'LogoutViewModel.g.dart';

@riverpod
class Logoutviewmodel extends _$Logoutviewmodel {
  @override
  build() {
    return 0;
  }

  void signOut() {
    ref.onDispose(NameStoringRepo().removeName);
    ref.invalidate(continueViewModelProvider);
    ref.invalidate(notificationSwitchProvider);
  }
}
