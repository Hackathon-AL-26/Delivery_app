import 'enums/journey_status.dart';
import 'journey_order.dart';

class Journey {
  final String uuid;
  final String? truckId;
  final String? driverEmail;
  final JourneyStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<JourneyOrder> journeyOrders;

  const Journey({
    required this.uuid,
    this.truckId,
    this.driverEmail,
    this.status = JourneyStatus.planned,
    this.startTime,
    this.endTime,
    this.journeyOrders = const [],
  });


  factory Journey.fromJson(Map<String, dynamic> json) {
    final uuidRaw = json['journeyUuid'] ?? json['uuid'];
    if (uuidRaw == null) {
      throw Exception('Missing required field "uuid" in Journey JSON: $json');
    }
    final uuid = uuidRaw.toString();

    final rawStatus = json['status'] as String?;
    final rawStartTime = json['start_time'] ?? json['startTime'];
    final rawEndTime = json['end_time'] ?? json['endTime'];
    final rawJourneyOrders = json['journey_orders'] ?? json['journeyOrders'];

    return Journey(
      uuid: uuid,
      truckId: _asString(json['truck_id'] ?? json['truckId']),
      driverEmail: _asString(json['driver_email'] ?? json['driverEmail']),
      status: rawStatus != null ? JourneyStatus.fromJson(rawStatus) : JourneyStatus.planned,
      startTime: _asDateTime(rawStartTime),
      endTime: _asDateTime(rawEndTime),
      journeyOrders: rawJourneyOrders is List
          ? rawJourneyOrders.whereType<Map<String, dynamic>>().map(JourneyOrder.fromJson).toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'truckId': truckId,
      'driverEmail': driverEmail,
      'status': status.toJson(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'journeyOrders': journeyOrders.map((item) => item.toJson()).toList(),
    };
  }

  Journey copyWith({
    String? uuid,
    String? truckId,
    String? driverEmail,
    JourneyStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    List<JourneyOrder>? journeyOrders,
  }) {
    return Journey(
      uuid: uuid ?? this.uuid,
      truckId: truckId ?? this.truckId,
      driverEmail: driverEmail ?? this.driverEmail,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      journeyOrders: journeyOrders ?? this.journeyOrders,
    );
  }
}

String? _asString(dynamic value) {
  if (value == null || value is Map || value is List) return null;
  return value.toString();
}

DateTime? _asDateTime(dynamic value) {
  final text = _asString(value);
  return text == null ? null : DateTime.tryParse(text);
}
