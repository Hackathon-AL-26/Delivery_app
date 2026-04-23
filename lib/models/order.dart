import 'enums/order_status.dart';

class Order {
  final String id;
  final int? packageAmount;
  final String? storeUuid;
  final String? deliveryDate;
  final double? price;
  final OrderStatus status;
  final DateTime? createdAt;

  const Order({
    required this.id,
    this.packageAmount,
    this.storeUuid,
    this.deliveryDate,
    this.price,
    this.status = OrderStatus.pending,
    this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'] as String?;
    final rawCreatedAt = json['createdAt'] ?? json['created_at'];

    return Order(
      id: json['id'] as String,
      packageAmount: _asInt(json['package_amount'] ?? json['packageAmount']),
      storeUuid: _asString(json['store_uuid'] ?? json['storeUuid']),
      deliveryDate: _asString(json['delivery_date'] ?? json['deliveryDate']),
      price: _asDouble(json['price'] ?? json['montant']),
      status: rawStatus != null
          ? OrderStatus.fromJson(rawStatus)
          : OrderStatus.pending,
      createdAt: _asDateTime(rawCreatedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'packageAmount': packageAmount,
      'storeUuid': storeUuid,
      'deliveryDate': deliveryDate,
      'price': price,
      'status': status.toJson(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Order copyWith({
    String? id,
    int? packageAmount,
    String? storeUuid,
    String? deliveryDate,
    double? price,
    OrderStatus? status,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      packageAmount: packageAmount ?? this.packageAmount,
      storeUuid: storeUuid ?? this.storeUuid,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      price: price ?? this.price,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

String? _asString(dynamic value) {
  if (value == null || value is Map || value is List) return null;
  return value.toString();
}

int? _asInt(dynamic value) {
  if (value == null || value is Map || value is List) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _asDouble(dynamic value) {
  if (value == null || value is Map || value is List) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

DateTime? _asDateTime(dynamic value) {
  final text = _asString(value);
  return text == null ? null : DateTime.tryParse(text);
}
