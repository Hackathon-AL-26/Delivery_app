import 'package:livreur_infflux/models/journey.dart';

import 'data_sources/journey_data_source.dart';

class JourneyRepository {
  final JourneyDataSource _dataSource;

  JourneyRepository({required JourneyDataSource journeyDataSource})
      : _dataSource = journeyDataSource;

  Stream<List<Journey>> watchJourney() {
    return _dataSource.watchJourney();
  }

  Stream<List<Journey>> watchDriverJourney(String driverId) {
    return _dataSource.watchDriverJourney(driverId: driverId);
  }

  Future<void> updateDeliveryStatus({
    required String deliveryUuid,
    required String newStatus,
  }) {
    return _dataSource.updateDeliveryStatus(
      deliveryUuid: deliveryUuid,
      newStatus: newStatus,
    );
  }
}
