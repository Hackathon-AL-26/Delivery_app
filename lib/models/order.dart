import 'enums/order_status.dart';

class Order {
  final String id;
  final int? packageAmount;
  final String? storeUuid;
  final String? deliveryDate;
  final int? montant;
  final OrderStatus status;

  const Order({
    required this.id,
    this.packageAmount,
    this.storeUuid,
    this.deliveryDate,
    this.montant,
    this.status = OrderStatus.pending,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      packageAmount: json['package_amount'] as int?,
      storeUuid: json['store_uuid'] as String?,
      deliveryDate: json['delivery_date'] as String?,
      montant: json['montant'] as int?,
      status: json['status'] != null
          ? OrderStatus.fromJson(json['status'] as String)
          : OrderStatus.pending,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'package_amount': packageAmount,
      'store_uuid': storeUuid,
      'delivery_date': deliveryDate,
      'montant': montant,
      'status': status.toJson(),
    };
  }

  Order copyWith({
    String? id,
    int? packageAmount,
    String? storeUuid,
    String? deliveryDate,
    int? montant,
    OrderStatus? status,
  }) {
    return Order(
      id: id ?? this.id,
      packageAmount: packageAmount ?? this.packageAmount,
      storeUuid: storeUuid ?? this.storeUuid,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      montant: montant ?? this.montant,
      status: status ?? this.status,
    );
  }
}
