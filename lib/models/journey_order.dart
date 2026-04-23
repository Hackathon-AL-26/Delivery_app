import 'enums/journey_order_status.dart';
import 'order.dart';
import 'store.dart';

class JourneyOrder {
  final String journeyUuid;
  final String orderId;
  final int? deliveryOrder;
  final JourneyOrderStatus status;
  final Order? order;
  final Store? store;

  const JourneyOrder({
    required this.journeyUuid,
    required this.orderId,
    this.deliveryOrder,
    required this.status,
    this.order,
    this.store,
  });

  factory JourneyOrder.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'] as String?;

    return JourneyOrder(
      journeyUuid: (json['journey_uuid'] ?? json['journeyUuid']) as String,
      orderId: (json['order_id'] ?? json['orderId']) as String,
      deliveryOrder: _asInt(json['delivery_order'] ?? json['deliveryOrder']),
      status: rawStatus != null
          ? JourneyOrderStatus.fromJson(rawStatus)
          : JourneyOrderStatus.planned,
      order: json['order'] is Map<String, dynamic>
          ? Order.fromJson(json['order'] as Map<String, dynamic>)
          : null,
      store: json['store'] is Map<String, dynamic>
          ? Store.fromJson(json['store'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deliveryOrder': deliveryOrder,
      'journeyUuid': journeyUuid,
      'orderId': orderId,
      'status': status.toJson(),
      'order': order?.toJson(),
      'store': store?.toJson(),
    };
  }

  JourneyOrder copyWith({
    String? journeyUuid,
    String? orderId,
    int? deliveryOrder,
    JourneyOrderStatus? status,
    Order? order,
    Store? store,
  }) {
    return JourneyOrder(
      journeyUuid: journeyUuid ?? this.journeyUuid,
      orderId: orderId ?? this.orderId,
      deliveryOrder: deliveryOrder ?? this.deliveryOrder,
      status: status ?? this.status,
      order: order ?? this.order,
      store: store ?? this.store,
    );
  }
}

int? _asInt(dynamic value) {
  if (value == null || value is Map || value is List) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
