import '../../../models/journey.dart';

abstract class JourneyDataSource {
  /// Écoute la journey du driver connecté via /journeys/me.
  Stream<Journey?> watchMyJourney();

  /// Récupère la journey en one-shot (pour refresh après action).
  Future<Journey?> fetchMyJourney();

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

  /// Avance la tournée d'un step via POST /journeys/me/next-step.
  Future<void> advanceNextStep({
    required Map<String, dynamic> body,
  });
}
