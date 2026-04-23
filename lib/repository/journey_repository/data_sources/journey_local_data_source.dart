import 'dart:async';

import '../../../models/enums/journey_status.dart';
import '../../../models/enums/truck_type.dart';
import '../../../models/enums/truck_status.dart';
import '../../../models/journey.dart';
import '../../../models/truck.dart';
import 'journey_data_source.dart';

class JourneyLocalDataSource implements JourneyDataSource {
  final List<Journey> _journeys = [
    Journey(
      uuid: 'journey-1',
      truckId: 'truck-2',
      driverEmail: 'driver1@logistics.com',
      status: JourneyStatus.loading,
      startTime: DateTime(2026, 4, 25, 8, 0),
      endTime: DateTime(2026, 4, 25, 14, 0),
    ),
    Journey(
      uuid: 'journey-2',
      truckId: 'truck-3',
      driverEmail: 'driver2@logistics.com',
      status: JourneyStatus.planned,
      startTime: DateTime(2026, 4, 25, 9, 0),
      endTime: DateTime(2026, 4, 25, 18, 0),
    ),
    Journey(
      uuid: 'journey-3',
      truckId: 'truck-1',
      driverEmail: 'driver1@logistics.com',
      status: JourneyStatus.inDelivery,
      startTime: DateTime(2026, 4, 26, 7, 30),
      endTime: DateTime(2026, 4, 26, 12, 30),
    ),
    Journey(
      uuid: 'journey-4',
      truckId: 'truck-2',
      driverEmail: 'driver1@logistics.com',
      status: JourneyStatus.completed,
      startTime: DateTime(2026, 4, 24, 6, 45),
      endTime: DateTime(2026, 4, 24, 11, 15),
    ),
    Journey(
      uuid: 'journey-5',
      truckId: 'truck-3',
      driverEmail: 'driver2@logistics.com',
      status: JourneyStatus.loading,
      startTime: DateTime(2026, 4, 26, 13, 15),
      endTime: DateTime(2026, 4, 26, 19, 0),
    ),
    Journey(
      uuid: 'journey-6',
      truckId: 'truck-1',
      driverEmail: 'driver2@logistics.com',
      status: JourneyStatus.planned,
      startTime: DateTime(2026, 4, 27, 8, 30),
      endTime: DateTime(2026, 4, 27, 15, 45),
    ),
  ];

  final List<Truck> _trucks = [
    Truck(id: 'truck-1', name: 'Petit camion', type: TruckType.small, status: TruckStatus.inUse),
    Truck(id: 'truck-2', name: 'Camion moyen', type: TruckType.medium, status: TruckStatus.inUse),
    Truck(id: 'truck-3', name: 'Semi-remorque', type: TruckType.big, status: TruckStatus.inUse),
  ];

  final _controller = StreamController<List<Journey>>.broadcast();

  List<Journey> _journeysForDriver(String driverId) {
    final journeysForDriver = _journeys
        .where((journey) => journey.driverEmail == driverId)
        .toList();

    if (journeysForDriver.isEmpty) {
      return List.unmodifiable(_journeys.take(3));
    }

    return List.unmodifiable(journeysForDriver);
  }

  Truck? _truckById(String truckId) {
    final index = _trucks.indexWhere((t) => t.id == truckId);
    return index == -1 ? null : _trucks[index];
  }

  void _notify() {
    _controller.add(List.unmodifiable(_journeys));
  }

  @override
  Stream<List<Journey>> watchJourney() async* {
    yield List.unmodifiable(_journeys);
    yield* _controller.stream;
  }

  @override
  Stream<List<Journey>> watchDriverJourney({required String driverId}) async* {
    yield _journeysForDriver(driverId);
    yield* _controller.stream.map(
      (_) => _journeysForDriver(driverId),
    );
  }

  @override
  Stream<Truck?> watchTruck({required String truckId}) async* {
    yield _truckById(truckId);
    yield* _controller.stream.map((_) => _truckById(truckId));
  }

  @override
  Future<void> updateDeliveryStatus({
    required String deliveryUuid,
    required String newStatus,
  }) async {
    final index = _journeys.indexWhere((j) => j.uuid == deliveryUuid);
    if (index == -1) return;

    _journeys[index] = _journeys[index].copyWith(
      status: JourneyStatus.fromString(newStatus),
    );
    _notify();
  }

  @override
  Future<void> updateJourneyOrderStatus({required String journeyUuid, required String orderId, required String newStatus}) {
    // TODO: implement updateJourneyOrderStatus
    throw UnimplementedError();
  }

  @override
  Future<void> updateJourneyStatus({required String journeyUuid, required String newStatus}) {
    // TODO: implement updateJourneyStatus
    throw UnimplementedError();
  }

  @override
  Stream<Journey?> watchMyJourney() {
    // TODO: implement watchMyJourney
    throw UnimplementedError();
  }

  @override
  Future<void> advanceNextStep({required Map<String, dynamic> body}) {
    // TODO: implement advanceNextStep
    throw UnimplementedError();
  }

  @override
  Future<Journey?> fetchMyJourney() {
    // TODO: implement fetchMyJourney
    throw UnimplementedError();
  }
}
