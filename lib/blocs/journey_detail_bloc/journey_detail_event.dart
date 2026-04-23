part of 'journey_detail_bloc.dart';

sealed class JourneyDetailEvent {}

final class JourneyDetailStarted extends JourneyDetailEvent {
  final String journeyUuid;
  JourneyDetailStarted({required this.journeyUuid});
}

final class _JourneyChanged extends JourneyDetailEvent {
  final Journey? journey;
  _JourneyChanged(this.journey);
}

final class _TruckChanged extends JourneyDetailEvent {
  final Truck? truck;
  _TruckChanged(this.truck);
}

final class _JourneyOrdersChanged extends JourneyDetailEvent {
  final List<JourneyOrder> journeyOrders;
  _JourneyOrdersChanged(this.journeyOrders);
}

final class _OrdersChanged extends JourneyDetailEvent {
  final List<Order> orders;
  _OrdersChanged(this.orders);
}

final class JourneyOrderStatusChanged extends JourneyDetailEvent {
  final String journeyUuid;
  final String orderId;
  final String newStatus;

  JourneyOrderStatusChanged({
    required this.journeyUuid,
    required this.orderId,
    required this.newStatus,
  });
}

final class JourneyStatusChanged extends JourneyDetailEvent {
  final String journeyUuid;
  final String newStatus;

  JourneyStatusChanged({
    required this.journeyUuid,
    required this.newStatus,
  });
}
