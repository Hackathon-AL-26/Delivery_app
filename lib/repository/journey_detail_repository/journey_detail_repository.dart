import '../../models/journey.dart';
import '../../models/journey_order.dart';
import '../../models/order.dart';
import '../../models/truck.dart';
import 'data_sources/journey_detail_data_source.dart';

class JourneyDetailRepository {
  final JourneyDetailDataSource _dataSource;

  JourneyDetailRepository({required JourneyDetailDataSource dataSource})
      : _dataSource = dataSource;

  Stream<Journey?> watchJourney({required String journeyUuid}) {
    return _dataSource.watchJourney(journeyUuid: journeyUuid);
  }

  Stream<List<JourneyOrder>> watchJourneyOrders({required String journeyUuid}) {
    return _dataSource.watchJourneyOrders(journeyUuid: journeyUuid);
  }

  Stream<List<Order>> watchOrdersForJourney({required String journeyUuid}) {
    return _dataSource.watchOrdersForJourney(journeyUuid: journeyUuid);
  }

  Stream<Truck?> watchTruck({required String truckId}) {
    return _dataSource.watchTruck(truckId: truckId);
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

  Future<void> updateJourneyStatus({
    required String journeyUuid,
    required String newStatus,
  }) {
    return _dataSource.updateJourneyStatus(
      journeyUuid: journeyUuid,
      newStatus: newStatus,
    );
  }
}
