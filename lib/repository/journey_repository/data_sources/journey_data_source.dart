import '../../../models/journey.dart';
import '../../../models/store.dart';
import '../../../models/truck.dart';

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

  /// Met le camion en maintenance via PATCH /trucks/{id}/status.
  Future<void> updateTruckStatus({
    required String truckId,
    required String status,
  });

  /// Récupère les infos du camion via GET /trucks/{id}.
  Future<Truck> fetchTruck({required String truckId});

  /// Récupère les infos d'un magasin via GET /stores/{uuid}.
  Future<Store> fetchStore({required String storeUuid});
}
