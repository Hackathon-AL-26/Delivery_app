enum TruckStatus {
  free('free'),
  inUse('in_use'),
  maintenance('maintenance');

  final String value;
  const TruckStatus(this.value);

  factory TruckStatus.fromString(String s) {
    return TruckStatus.values.firstWhere((e) => e.value == s, orElse: () => TruckStatus.free);
  }

  String toJson() => value;
  static TruckStatus fromJson(String s) => TruckStatus.fromString(s);

  @override
  String toString() => value;
}