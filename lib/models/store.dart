class Store {
  final String uuid;
  final String? name;
  final String? email;
  final double? lng;
  final double? lat;
  final String? deliveryHours;

  const Store({
    required this.uuid,
    this.name,
    this.email,
    this.lng,
    this.lat,
    this.deliveryHours,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      uuid: json['uuid'] as String,
      name: _asString(json['name']),
      email: _asString(json['email']),
      lng: _asDouble(json['lng']),
      lat: _asDouble(json['lat']),
      deliveryHours: _asString(json['delivery_hours'] ?? json['deliveryHours']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'email': email,
      'lng': lng,
      'lat': lat,
      'deliveryHours': deliveryHours,
    };
  }

  Store copyWith({
    String? uuid,
    String? name,
    String? email,
    double? lng,
    double? lat,
    String? deliveryHours,
  }) {
    return Store(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      email: email ?? this.email,
      lng: lng ?? this.lng,
      lat: lat ?? this.lat,
      deliveryHours: deliveryHours ?? this.deliveryHours,
    );
  }
}

String? _asString(dynamic value) {
  if (value == null || value is Map || value is List) return null;
  return value.toString();
}

double? _asDouble(dynamic value) {
  if (value == null || value is Map || value is List) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
