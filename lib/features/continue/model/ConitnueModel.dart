class ContinueModel {
  String? name;
  bool? isSaved;
  ContinueModel({this.name = '', this.isSaved = false});
  ContinueModel copyWith({String? name, bool? isSaved}) {
    return ContinueModel(
      name: name ?? this.name,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
