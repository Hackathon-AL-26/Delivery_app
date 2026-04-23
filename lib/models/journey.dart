import 'enums/journey_status.dart';

class Journey {
  final String uuid;
  final String? truckId;
  final String? driverEmail;
  final JourneyStatus status;
  final DateTime? startTime;
  final DateTime? endTime;

  const Journey({
    required this.uuid,
    this.truckId,
    this.driverEmail,
    this.status = JourneyStatus.planned,
    this.startTime,
    this.endTime,
  });

  factory Journey.fromJson(Map<String, dynamic> json) {
    return Journey(
      uuid: json['uuid'] as String,
      truckId: json['truck_id'] as String?,
      driverEmail: json['driver_email'] as String?,
      status: json['status'] != null
          ? JourneyStatus.fromJson(json['status'] as String)
          : JourneyStatus.planned,
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time'] as String) : null,
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'truck_id': truckId,
      'driver_email': driverEmail,
      'status': status.toJson(),
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
    };
  }

  Journey copyWith({
    String? uuid,
    String? truckId,
    String? driverEmail,
    JourneyStatus? status,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return Journey(
      uuid: uuid ?? this.uuid,
      truckId: truckId ?? this.truckId,
      driverEmail: driverEmail ?? this.driverEmail,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
