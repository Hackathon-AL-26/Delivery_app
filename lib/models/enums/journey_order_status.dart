enum JourneyOrderStatus {
  planned('planned'),
  loaded('loaded'),
  inDelivery('in_delivery'),
  delivered('delivered');

  final String value;
  const JourneyOrderStatus(this.value);

  factory JourneyOrderStatus.fromString(String s) {
    return JourneyOrderStatus.values.firstWhere((e) => e.value == s, orElse: () => JourneyOrderStatus.planned);
  }

  String toJson() => value;
  static JourneyOrderStatus fromJson(String s) => JourneyOrderStatus.fromString(s);

  @override
  String toString() => value;
}