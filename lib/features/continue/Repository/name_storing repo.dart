import 'package:shared_preferences/shared_preferences.dart';

class NameStoringRepo {
  Future<void> setName(String name) async {
    final sp = await SharedPreferences.getInstance();
    sp.setString('name', name);
  }

  Future<String> getName() async {
    final sp = await SharedPreferences.getInstance();
    String name = sp.getString('name')!;
    return name;
  }

  Future<bool> checkName() async {
    final sp = await SharedPreferences.getInstance();
    return sp.containsKey('name');
  }

  Future<bool> removeName() async {
    final sp = await SharedPreferences.getInstance();
    return sp.remove('name');
  }
}
