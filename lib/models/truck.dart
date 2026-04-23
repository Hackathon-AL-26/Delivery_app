import 'enums/truck_type.dart';
import 'enums/truck_status.dart';

class Truck {
  final String id;
  final String? name;
  final TruckType type;
  final TruckStatus status;

  const Truck({
    required this.id,
    this.name,
    required this.type,
    required this.status,
  });

  factory Truck.fromJson(Map<String, dynamic> json) {
    return Truck(
      id: json['id'] as String,
      name: json['name'] as String?,
      type: TruckType.fromJson(json['type'] as String),
      status: TruckStatus.fromJson(json['status'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toJson(),
      'status': status.toJson(),
    };
  }

  Truck copyWith({
    String? id,
    String? name,
    TruckType? type,
    TruckStatus? status,
  }) {
    return Truck(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
    );
  }
}