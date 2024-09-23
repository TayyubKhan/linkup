import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../Repository/name_storing repo.dart';
import '../model/ConitnueModel.dart';

part 'ContinueViewModel.g.dart';

@riverpod
class ContinueViewModel extends _$ContinueViewModel {
  NameStoringRepo nameRepo = NameStoringRepo();
  @override
  Future<ContinueModel> build() async {
    String name = await nameRepo.getName();
    bool isSaved = await nameRepo.checkName();
    return ContinueModel().copyWith(name: name, isSaved: isSaved);
  }

  Future<void> setName(String name) async {
    await nameRepo.setName(name);
    state = AsyncData(ContinueModel().copyWith(name: name)); // Update the state
  }

  Future<String> refreshName() async {
    String name = await nameRepo.getName();
    state = AsyncData(ContinueModel().copyWith(name: name)); // Update the state
    return name;
  }
}
