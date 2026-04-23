import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:livreur_infflux/models/journey.dart';

import '../../repository/journey_repository/journey_repository.dart';

part 'journey_event.dart';
part 'journey_state.dart';

class JourneyBloc extends Bloc<JourneyEvent, JourneyState> {
  final JourneyRepository _repository;

  JourneyBloc({required JourneyRepository repository})
      : _repository = repository,
        super(JourneyState()) {
    on<JourneyWatchAllStarted>(_onWatchJourneys);
    on<JourneyWatchDriverStarted>(_onWatchDriverJourneys);
    on<JourneyDeliveryStatusChanged>(_onDeliveryStatusChanged);
  }

  Future<void> _onWatchJourneys(
    JourneyWatchAllStarted event,
    Emitter<JourneyState> emit,
  ) async {
    emit(state.copyWith(status: JourneyBlocStatus.loading));
    try {
      await emit.forEach<List<Journey>>(
        _repository.watchJourney(),
        onData: (journeys) {
          return state.copyWith(
            status: JourneyBlocStatus.loaded,
            journeys: journeys,
          );
        },
      );
    } catch (error) {
      emit(state.copyWith(status: JourneyBlocStatus.error));
    }
  }

  Future<void> _onWatchDriverJourneys(
    JourneyWatchDriverStarted event,
    Emitter<JourneyState> emit,
  ) async {
    emit(state.copyWith(status: JourneyBlocStatus.loading));
    try {
      await emit.forEach<List<Journey>>(
        _repository.watchDriverJourney(event.driverId),
        onData: (journeys) {
          return state.copyWith(
            status: JourneyBlocStatus.loaded,
            journeys: journeys,
          );
        },
      );
    } catch (error) {
      emit(state.copyWith(status: JourneyBlocStatus.error));
    }
  }

  Future<void> _onDeliveryStatusChanged(
    JourneyDeliveryStatusChanged event,
    Emitter<JourneyState> emit,
  ) async {
    try {
      await _repository.updateDeliveryStatus(
        deliveryUuid: event.deliveryUuid,
        newStatus: event.newStatus,
      );
    } catch (e) {
      emit(state.copyWith(status: JourneyBlocStatus.error));
    }
  }
}
