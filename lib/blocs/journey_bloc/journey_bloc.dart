import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../models/journey.dart';
import '../../models/enums/truck_status.dart';
import '../../models/truck.dart';
import '../../repository/journey_repository/journey_repository.dart';

part 'journey_event.dart';

part 'journey_state.dart';

class JourneyBloc extends Bloc<JourneyEvent, JourneyState> {
  final JourneyRepository _repository;
  StreamSubscription<Journey?>? _subscription;

  JourneyBloc({required JourneyRepository repository})
    : _repository = repository,
      super(const JourneyState()) {
    on<WatchMyJourney>(_onWatch);
    on<_JourneyDataReceived>(_onDataReceived);
    on<_JourneyLoadFailed>(_onLoadFailed);
    on<JourneyStatusChanged>(_onJourneyStatusChanged);
    on<JourneyOrderStatusChanged>(_onOrderStatusChanged);
    on<AdvanceNextStep>(_onAdvanceNextStep);
    on<TruckMaintenanceRequested>(_onTruckMaintenance);
  }

  Future<void> _onWatch(
    WatchMyJourney event,
    Emitter<JourneyState> emit,
  ) async {
    emit(
      state.copyWith(
        status: JourneyBlocStatus.loading,
        clearErrorMessage: true,
      ),
    );
    await _subscription?.cancel();

    _subscription = _repository.watchMyJourney().listen(
      (journey) => add(_JourneyDataReceived(journey)),
      onError: (error, _) => add(_JourneyLoadFailed(error.toString())),
    );
  }

  Future<void> _onDataReceived(
    _JourneyDataReceived event,
    Emitter<JourneyState> emit,
  ) async {
    emit(
      state.copyWith(
        status: JourneyBlocStatus.loaded,
        journey: event.journey,
        clearJourney: event.journey == null,
        clearErrorMessage: true,
      ),
    );

    // Récupérer les infos du camion si on a un truckId
    final truckId = event.journey?.truckId;
    if (truckId != null && truckId.isNotEmpty) {
      try {
        final truck = await _repository.fetchTruck(truckId: truckId);
        emit(
          state.copyWith(
            truck: truck,
            truckInMaintenance: truck.status == TruckStatus.maintenance,
          ),
        );
      } catch (_) {
        // Silently ignore truck fetch errors
      }
    }
  }

  void _onLoadFailed(_JourneyLoadFailed event, Emitter<JourneyState> emit) {
    emit(
      state.copyWith(
        status: JourneyBlocStatus.error,
        errorMessage: event.message,
      ),
    );
  }

  Future<void> _onJourneyStatusChanged(
    JourneyStatusChanged event,
    Emitter<JourneyState> emit,
  ) async {
    try {
      await _repository.updateJourneyStatus(
        journeyUuid: event.journeyUuid,
        newStatus: event.newStatus,
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: JourneyBlocStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onOrderStatusChanged(
    JourneyOrderStatusChanged event,
    Emitter<JourneyState> emit,
  ) async {
    try {
      await _repository.updateJourneyOrderStatus(
        journeyUuid: event.journeyUuid,
        orderId: event.orderId,
        newStatus: event.newStatus,
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: JourneyBlocStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAdvanceNextStep(
    AdvanceNextStep event,
    Emitter<JourneyState> emit,
  ) async {
    emit(state.copyWith(advancing: true));
    try {
      await _repository.advanceNextStep(body: event.body);
      // Rafraîchir les données immédiatement après le succès
      final journey = await _repository.fetchMyJourney();
      emit(
        state.copyWith(
          advancing: false,
          journey: journey,
          clearJourney: journey == null,
          clearErrorMessage: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          advancing: false,
          status: JourneyBlocStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onTruckMaintenance(
    TruckMaintenanceRequested event,
    Emitter<JourneyState> emit,
  ) async {
    try {
      await _repository.updateTruckStatus(
        truckId: event.truckId,
        status: event.status,
      );
      if (event.status == 'maintenance') {
        emit(state.copyWith(truckInMaintenance: true));
      } else {
        emit(state.copyWith(truckInMaintenance: false));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: JourneyBlocStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
