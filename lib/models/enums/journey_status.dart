enum JourneyStatus {
  planned('planned'),
  loading('loading'),
  inDelivery('in_delivery'),
  completed('completed');

  final String value;
  const JourneyStatus(this.value);

  factory JourneyStatus.fromString(String s) {
    return JourneyStatus.values.firstWhere((e) => e.value == s, orElse: () => JourneyStatus.planned);
  }

  String toJson() => value;
  static JourneyStatus fromJson(String s) => JourneyStatus.fromString(s);

  @override
  String toString() => value;
}