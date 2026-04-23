import '../../models/journey.dart';
import '../../models/journey_order.dart';
import '../../models/truck.dart';
import 'data_sources/dash_board_data_sources.dart';

class DashBoardRepository {
  final DashBoardDataSource _dataSource;

  DashBoardRepository({required DashBoardDataSource dataSource})
      : _dataSource = dataSource;

  Stream<List<Journey>> watchActiveJourney({required String driverId}) {
    return _dataSource.watchActiveJourney(driverId: driverId);
  }

  Stream<List<JourneyOrder>> watchJourneyOrders({
    required String journeyUuid,
  }) {
    return _dataSource.watchJourneyOrders(journeyUuid: journeyUuid);
  }

  Future<void> updateOrderStatus({
    required String journeyUuid,
    required String orderId,
    required String newStatus,
  }) {
    return _dataSource.updateOrderStatus(
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
