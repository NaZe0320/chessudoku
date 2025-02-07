enum LoginType {
  guest,
  google;

  String toJson() => name;

  static LoginType fromJson(String json) => LoginType.values.firstWhere((type) => type.name == json);
}
