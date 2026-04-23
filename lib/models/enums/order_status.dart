enum OrderStatus {
  pending('pending'),
  planned('planned'),
  inDelivery('in_delivery'),
  delivered('delivered'),
  cancelled('cancelled');

  final String value;
  const OrderStatus(this.value);

  factory OrderStatus.fromString(String s) {
    return OrderStatus.values.firstWhere((e) => e.value == s, orElse: () => OrderStatus.pending);
  }

  String toJson() => value;
  static OrderStatus fromJson(String s) => OrderStatus.fromString(s);

  @override
  String toString() => value;
}