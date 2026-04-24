part of 'journey_bloc.dart';

sealed class JourneyEvent {}

final class WatchMyJourney extends JourneyEvent {}

final class JourneyStatusChanged extends JourneyEvent {
  final String journeyUuid;
  final String newStatus;
  JourneyStatusChanged({required this.journeyUuid, required this.newStatus});
}

final class JourneyOrderStatusChanged extends JourneyEvent {
  final String journeyUuid;
  final String orderId;
  final String newStatus;
  JourneyOrderStatusChanged({
    required this.journeyUuid,
    required this.orderId,
    required this.newStatus,
  });
}

final class ReportIssue extends JourneyEvent {
  final String journeyUuid;
  final String newStatus;
  ReportIssue({required this.journeyUuid, required this.newStatus});
}

final class AdvanceNextStep extends JourneyEvent {
  final Map<String, dynamic> body;
  AdvanceNextStep({required this.body});
}

final class TruckMaintenanceRequested extends JourneyEvent {
  final String truckId;
  final String status;
  TruckMaintenanceRequested({required this.truckId, required this.status});
}


final class _JourneyDataReceived extends JourneyEvent {
  final Journey? journey;
  _JourneyDataReceived(this.journey);
}

final class _JourneyLoadFailed extends JourneyEvent {
  final String message;
  _JourneyLoadFailed(this.message);
}
