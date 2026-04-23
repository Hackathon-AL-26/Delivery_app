import 'dart:async';

import '../../../models/enums/journey_order_status.dart';
import '../../../models/enums/journey_status.dart';
import '../../../models/enums/order_status.dart';
import '../../../models/enums/truck_type.dart';
import '../../../models/enums/truck_status.dart';
import '../../../models/journey.dart';
import '../../../models/journey_order.dart';
import '../../../models/order.dart';
import '../../../models/truck.dart';
import 'journey_detail_data_source.dart';

class JourneyDetailLocalDataSource implements JourneyDetailDataSource {
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
  ];

  final List<Truck> _trucks = [
    Truck(id: 'truck-1', name: 'Petit camion', type: TruckType.small, status: TruckStatus.inUse),
    Truck(id: 'truck-2', name: 'Camion moyen', type: TruckType.medium, status: TruckStatus.inUse),
    Truck(id: 'truck-3', name: 'Semi-remorque', type: TruckType.big, status: TruckStatus.inUse),
  ];

  final List<Order> _orders = [
    Order(id: 'order-1', packageAmount: 20, storeUuid: 'store-1', deliveryDate: '2026-04-25', montant: 200, status: OrderStatus.planned),
    Order(id: 'order-2', packageAmount: 50, storeUuid: 'store-2', deliveryDate: '2026-04-25', montant: 500, status: OrderStatus.planned),
    Order(id: 'order-3', packageAmount: 80, storeUuid: 'store-3', deliveryDate: '2026-04-25', montant: 800, status: OrderStatus.inDelivery),
    Order(id: 'order-4', packageAmount: 30, storeUuid: 'store-4', deliveryDate: '2026-04-25', montant: 300, status: OrderStatus.delivered),
    Order(id: 'order-5', packageAmount: 15, storeUuid: 'store-1', deliveryDate: '2026-04-26', montant: 150, status: OrderStatus.pending),
    Order(id: 'order-6', packageAmount: 60, storeUuid: 'store-2', deliveryDate: '2026-04-26', montant: 600, status: OrderStatus.planned),
  ];

  final List<JourneyOrder> _journeyOrders = [
    JourneyOrder(journeyUuid: 'journey-1', orderId: 'order-1', deliveryOrder: 1, status: JourneyOrderStatus.loaded),
    JourneyOrder(journeyUuid: 'journey-1', orderId: 'order-2', deliveryOrder: 2, status: JourneyOrderStatus.planned),
    JourneyOrder(journeyUuid: 'journey-1', orderId: 'order-4', deliveryOrder: 3, status: JourneyOrderStatus.delivered),
    JourneyOrder(journeyUuid: 'journey-2', orderId: 'order-3', deliveryOrder: 1, status: JourneyOrderStatus.planned),
    JourneyOrder(journeyUuid: 'journey-2', orderId: 'order-6', deliveryOrder: 2, status: JourneyOrderStatus.planned),
    JourneyOrder(journeyUuid: 'journey-3', orderId: 'order-5', deliveryOrder: 1, status: JourneyOrderStatus.inDelivery),
  ];

  final _controller = StreamController<void>.broadcast();

  void _notify() => _controller.add(null);

  Journey? _journeyById(String journeyUuid) {
    final index = _journeys.indexWhere((j) => j.uuid == journeyUuid);
    return index == -1 ? null : _journeys[index];
  }

  Truck? _truckById(String truckId) {
    final index = _trucks.indexWhere((t) => t.id == truckId);
    return index == -1 ? null : _trucks[index];
  }

  List<JourneyOrder> _journeyOrdersFor(String journeyUuid) {
    final orders = _journeyOrders
        .where((jo) => jo.journeyUuid == journeyUuid)
        .toList()
      ..sort((a, b) => (a.deliveryOrder ?? 0).compareTo(b.deliveryOrder ?? 0));
    return List.unmodifiable(orders);
  }

  List<Order> _ordersForJourney(String journeyUuid) {
    final orderIds = _journeyOrdersFor(journeyUuid)
        .map((jo) => jo.orderId)
        .toSet();
    return List.unmodifiable(
      _orders.where((o) => orderIds.contains(o.id)).toList(),
    );
  }

  @override
  Stream<Journey?> watchJourney({required String journeyUuid}) async* {
    yield _journeyById(journeyUuid);
    yield* _controller.stream.map((_) => _journeyById(journeyUuid));
  }

  @override
  Stream<List<JourneyOrder>> watchJourneyOrders({required String journeyUuid}) async* {
    yield _journeyOrdersFor(journeyUuid);
    yield* _controller.stream.map((_) => _journeyOrdersFor(journeyUuid));
  }

  @override
  Stream<List<Order>> watchOrdersForJourney({required String journeyUuid}) async* {
    yield _ordersForJourney(journeyUuid);
    yield* _controller.stream.map((_) => _ordersForJourney(journeyUuid));
  }

  @override
  Stream<Truck?> watchTruck({required String truckId}) async* {
    yield _truckById(truckId);
    yield* _controller.stream.map((_) => _truckById(truckId));
  }

  @override
  Future<void> updateJourneyOrderStatus({
    required String journeyUuid,
    required String orderId,
    required String newStatus,
  }) async {
    final index = _journeyOrders.indexWhere(
      (jo) => jo.journeyUuid == journeyUuid && jo.orderId == orderId,
    );
    if (index == -1) return;

    final journeyOrderStatus = JourneyOrderStatus.fromString(newStatus);
    _journeyOrders[index] = _journeyOrders[index].copyWith(status: journeyOrderStatus);

    final orderIndex = _orders.indexWhere((o) => o.id == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex] = _orders[orderIndex].copyWith(
        status: _mapJourneyOrderStatusToOrderStatus(journeyOrderStatus),
      );
    }
    _notify();
  }

  @override
  Future<void> updateJourneyStatus({
    required String journeyUuid,
    required String newStatus,
  }) async {
    final index = _journeys.indexWhere((j) => j.uuid == journeyUuid);
    if (index == -1) return;
    _journeys[index] = _journeys[index].copyWith(status: JourneyStatus.fromString(newStatus));
    _notify();
  }

  OrderStatus _mapJourneyOrderStatusToOrderStatus(JourneyOrderStatus s) {
    switch (s) {
      case JourneyOrderStatus.planned:
        return OrderStatus.planned;
      case JourneyOrderStatus.loaded:
        return OrderStatus.planned;
      case JourneyOrderStatus.inDelivery:
        return OrderStatus.inDelivery;
      case JourneyOrderStatus.delivered:
        return OrderStatus.delivered;
    }
  }
}
