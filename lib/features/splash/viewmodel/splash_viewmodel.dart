import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../continue/Repository/name_storing repo.dart';
import '../../continue/model/ConitnueModel.dart';

part 'splash_viewmodel.g.dart';

@riverpod
class SplashViewModel extends _$SplashViewModel {
  NameStoringRepo nameRepo = NameStoringRepo();
  @override
  Future<bool> build() async {
    bool isSaved = await nameRepo.checkName();
    return isSaved;
  }
}
