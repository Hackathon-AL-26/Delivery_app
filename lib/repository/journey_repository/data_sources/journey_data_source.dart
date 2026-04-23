import '../../../models/journey.dart';

abstract class JourneyDataSource {
  /// Écoute la journey du driver connecté via /journeys/me.
  Stream<Journey?> watchMyJourney();

  /// Met à jour le statut de la journey.
  Future<void> updateJourneyStatus({
    required String journeyUuid,
    required String newStatus,
  });

  /// Met à jour le statut d'une journey_order.
  Future<void> updateJourneyOrderStatus({
    required String journeyUuid,
    required String orderId,
    required String newStatus,
  });
}
