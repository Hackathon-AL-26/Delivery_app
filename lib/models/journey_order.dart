import 'enums/journey_order_status.dart';

class JourneyOrder {
  final String journeyUuid;
  final String orderId;
  final int? deliveryOrder;
  final JourneyOrderStatus status;

  const JourneyOrder({
    required this.journeyUuid,
    required this.orderId,
    this.deliveryOrder,
    required this.status,
  });

  factory JourneyOrder.fromJson(Map<String, dynamic> json) {
    return JourneyOrder(
      journeyUuid: json['journey_uuid'] as String,
      orderId: json['order_id'] as String,
      deliveryOrder: json['delivery_order'] as int?,
      status: JourneyOrderStatus.fromJson(json['status'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'delivery_order': deliveryOrder,
      'journey_uuid': journeyUuid,
      'order_id': orderId,
      'status': status.toJson(),
    };
  }

  JourneyOrder copyWith({
    String? journeyUuid,
    String? orderId,
    int? deliveryOrder,
    JourneyOrderStatus? status,
  }) {
    return JourneyOrder(
      journeyUuid: journeyUuid ?? this.journeyUuid,
      orderId: orderId ?? this.orderId,
      deliveryOrder: deliveryOrder ?? this.deliveryOrder,
      status: status ?? this.status,
    );
  }
}
