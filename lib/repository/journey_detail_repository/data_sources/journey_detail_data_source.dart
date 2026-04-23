import '../../../models/journey.dart';
import '../../../models/journey_order.dart';
import '../../../models/order.dart';
import '../../../models/truck.dart';

abstract class JourneyDetailDataSource {
  /// Écoute une journey spécifique par son UUID.
  Stream<Journey?> watchJourney({required String journeyUuid});

  /// Écoute les journey_orders liées à une journey.
  Stream<List<JourneyOrder>> watchJourneyOrders({required String journeyUuid});

  /// Écoute les orders complètes liées à une journey (via journey_order).
  Stream<List<Order>> watchOrdersForJourney({required String journeyUuid});

  /// Écoute le camion assigné à la journey.
  Stream<Truck?> watchTruck({required String truckId});

  /// Met à jour le statut d'une journey_order.
  Future<void> updateJourneyOrderStatus({
    required String journeyUuid,
    required String orderId,
    required String newStatus,
  });

  /// Met à jour le statut de la journey elle-même.
  Future<void> updateJourneyStatus({
    required String journeyUuid,
    required String newStatus,
  });
}
