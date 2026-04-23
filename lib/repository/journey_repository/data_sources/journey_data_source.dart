import 'package:livreur_infflux/models/journey.dart';


abstract class JourneyDataSource {
  Stream<List<Journey>> watchJourney();

  Stream<List<Journey>> watchDriverJourney({required String driverId});

  Future<void> updateDeliveryStatus({
    required String deliveryUuid,
    required String newStatus,
  });
}
