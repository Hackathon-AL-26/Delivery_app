import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../models/journey.dart';
import '../../models/journey_order.dart';
import '../../models/order.dart';
import '../../models/truck.dart';
import '../../repository/journey_detail_repository/journey_detail_repository.dart';

part 'journey_detail_event.dart';
part 'journey_detail_state.dart';

class JourneyDetailBloc extends Bloc<JourneyDetailEvent, JourneyDetailState> {
  final JourneyDetailRepository _repository;
  StreamSubscription<Journey?>? _journeySubscription;
  StreamSubscription<Truck?>? _truckSubscription;
  StreamSubscription<List<JourneyOrder>>? _journeyOrdersSubscription;
  StreamSubscription<List<Order>>? _ordersSubscription;

  JourneyDetailBloc({required JourneyDetailRepository repository})
      : _repository = repository,
        super(const JourneyDetailState()) {
    on<JourneyDetailStarted>(_onStarted);
    on<_JourneyChanged>(_onJourneyChanged);
    on<_TruckChanged>(_onTruckChanged);
    on<_JourneyOrdersChanged>(_onJourneyOrdersChanged);
    on<_OrdersChanged>(_onOrdersChanged);
    on<JourneyOrderStatusChanged>(_onJourneyOrderStatusChanged);
    on<JourneyStatusChanged>(_onJourneyStatusChanged);
  }

  Future<void> _onStarted(
    JourneyDetailStarted event,
    Emitter<JourneyDetailState> emit,
  ) async {
    emit(state.copyWith(
      status: JourneyDetailStatus.loading,
      journeyUuid: event.journeyUuid,
    ));

    await _journeySubscription?.cancel();
    await _truckSubscription?.cancel();
    await _journeyOrdersSubscription?.cancel();
    await _ordersSubscription?.cancel();

    _journeySubscription = _repository
        .watchJourney(journeyUuid: event.journeyUuid)
        .listen((journey) {
      add(_JourneyChanged(journey));

      // Quand la journey arrive, on s'abonne au truck si truckId est présent
      if (journey?.truckId != null) {
        _truckSubscription?.cancel();
        _truckSubscription = _repository
            .watchTruck(truckId: journey!.truckId!)
            .listen((truck) => add(_TruckChanged(truck)));
      }
    });

    _journeyOrdersSubscription = _repository
        .watchJourneyOrders(journeyUuid: event.journeyUuid)
        .listen((journeyOrders) => add(_JourneyOrdersChanged(journeyOrders)));

    _ordersSubscription = _repository
        .watchOrdersForJourney(journeyUuid: event.journeyUuid)
        .listen((orders) => add(_OrdersChanged(orders)));
  }

  void _onJourneyChanged(
    _JourneyChanged event,
    Emitter<JourneyDetailState> emit,
  ) {
    emit(state.copyWith(
      status: JourneyDetailStatus.loaded,
      journey: event.journey,
    ));
  }

  void _onTruckChanged(
    _TruckChanged event,
    Emitter<JourneyDetailState> emit,
  ) {
    emit(state.copyWith(
      status: JourneyDetailStatus.loaded,
      truck: event.truck,
    ));
  }

  void _onJourneyOrdersChanged(
    _JourneyOrdersChanged event,
    Emitter<JourneyDetailState> emit,
  ) {
    emit(state.copyWith(
      status: JourneyDetailStatus.loaded,
      journeyOrders: event.journeyOrders,
    ));
  }

  void _onOrdersChanged(
    _OrdersChanged event,
    Emitter<JourneyDetailState> emit,
  ) {
    emit(state.copyWith(
      status: JourneyDetailStatus.loaded,
      orders: event.orders,
    ));
  }

  Future<void> _onJourneyOrderStatusChanged(
    JourneyOrderStatusChanged event,
    Emitter<JourneyDetailState> emit,
  ) async {
    try {
      await _repository.updateJourneyOrderStatus(
        journeyUuid: event.journeyUuid,
        orderId: event.orderId,
        newStatus: event.newStatus,
      );
    } catch (_) {
      emit(state.copyWith(status: JourneyDetailStatus.error));
    }
  }

  Future<void> _onJourneyStatusChanged(
    JourneyStatusChanged event,
    Emitter<JourneyDetailState> emit,
  ) async {
    try {
      await _repository.updateJourneyStatus(
        journeyUuid: event.journeyUuid,
        newStatus: event.newStatus,
      );
    } catch (_) {
      emit(state.copyWith(status: JourneyDetailStatus.error));
    }
  }

  @override
  Future<void> close() async {
    await _journeySubscription?.cancel();
    await _truckSubscription?.cancel();
    await _journeyOrdersSubscription?.cancel();
    await _ordersSubscription?.cancel();
    return super.close();
  }
}
