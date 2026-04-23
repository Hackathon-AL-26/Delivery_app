enum TruckType {
  small('small'),
  medium('medium'),
  big('big');

  final String value;
  const TruckType(this.value);

  factory TruckType.fromString(String s) {
    return TruckType.values.firstWhere((e) => e.value == s, orElse: () => TruckType.small);
  }

  String toJson() => value;
  static TruckType fromJson(String s) => TruckType.fromString(s);

  @override
  String toString() => value;
}