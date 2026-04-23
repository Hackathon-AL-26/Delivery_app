part of 'journey_bloc.dart';

sealed class JourneyEvent {}

final class JourneyWatchAllStarted extends JourneyEvent {}

final class JourneyWatchDriverStarted extends JourneyEvent {
  final String driverId;
  JourneyWatchDriverStarted({required this.driverId});
}

final class JourneyDeliveryStatusChanged extends JourneyEvent {
  final String deliveryUuid;
  final String newStatus;

  JourneyDeliveryStatusChanged({
    required this.deliveryUuid,
    required this.newStatus,
  });
}
