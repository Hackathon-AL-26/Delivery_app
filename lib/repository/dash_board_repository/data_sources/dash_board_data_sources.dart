import '../../../models/journey.dart';
import '../../../models/journey_order.dart';
import '../../../models/truck.dart';


abstract class DashBoardDataSource {
  Stream<List<Journey>> watchActiveJourney({required String driverId});

  Stream<List<JourneyOrder>> watchJourneyOrders({required String journeyUuid});

  Stream<List<Truck>> watchTrucks({required String driverId});

  Future<void> updateOrderStatus({
    required String journeyUuid,
    required String orderId,
    required String newStatus,
  });

  Future<void> updateJourneyStatus({
    required String journeyUuid,
    required String newStatus,
  });
}
