class ContinueModel {
  String? name;
  ContinueModel({this.name = ''});
  ContinueModel copyWith({String? name}) {
    return ContinueModel(name: name ?? this.name);
  }
}
