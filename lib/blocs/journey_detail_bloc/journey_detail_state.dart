part of 'journey_detail_bloc.dart';

enum JourneyDetailStatus { initial, loading, loaded, error }

final class JourneyDetailState {
  final JourneyDetailStatus status;
  final String? journeyUuid;
  final Journey? journey;
  final Truck? truck;
  final List<JourneyOrder> journeyOrders;
  final List<Order> orders;

  const JourneyDetailState({
    this.status = JourneyDetailStatus.initial,
    this.journeyUuid,
    this.journey,
    this.truck,
    this.journeyOrders = const [],
    this.orders = const [],
  });

  JourneyDetailState copyWith({
    JourneyDetailStatus? status,
    String? journeyUuid,
    Journey? journey,
    Truck? truck,
    List<JourneyOrder>? journeyOrders,
    List<Order>? orders,
  }) {
    return JourneyDetailState(
      status: status ?? this.status,
      journeyUuid: journeyUuid ?? this.journeyUuid,
      journey: journey ?? this.journey,
      truck: truck ?? this.truck,
      journeyOrders: journeyOrders ?? this.journeyOrders,
      orders: orders ?? this.orders,
    );
  }
}
