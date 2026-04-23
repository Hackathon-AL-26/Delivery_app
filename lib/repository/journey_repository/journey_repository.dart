import '../../models/journey.dart';
import 'data_sources/journey_data_source.dart';

class JourneyRepository {
  final JourneyDataSource _dataSource;

  JourneyRepository({required JourneyDataSource journeyDataSource})
      : _dataSource = journeyDataSource;

  Stream<Journey?> watchMyJourney() {
    return _dataSource.watchMyJourney();
  }

  Future<Journey?> fetchMyJourney() {
    return _dataSource.fetchMyJourney();
  }

  Future<void> updateJourneyStatus({
    required String journeyUuid,
    required String newStatus,
  }) {
    return _dataSource.updateJourneyStatus(
      journeyUuid: journeyUuid,
      newStatus: newStatus,
    );
  }

  Future<void> updateJourneyOrderStatus({
    required String journeyUuid,
    required String orderId,
    required String newStatus,
  }) {
    return _dataSource.updateJourneyOrderStatus(
      journeyUuid: journeyUuid,
      orderId: orderId,
      newStatus: newStatus,
    );
  }

  Future<void> advanceNextStep({
    required Map<String, dynamic> body,
  }) {
    return _dataSource.advanceNextStep(body: body);
  }
}
