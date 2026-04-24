part of 'journey_bloc.dart';

enum JourneyBlocStatus { initial, loading, loaded, error }

final class JourneyState {
  final JourneyBlocStatus status;
  final Journey? journey;
  final String? errorMessage;

  /// True pendant un appel POST /journeys/me/next-step.
  final bool advancing;

  /// True si le camion a été signalé en maintenance.
  final bool truckInMaintenance;

  /// Infos du camion récupérées via GET /trucks/{id}.
  final Truck? truck;

  const JourneyState({
    this.status = JourneyBlocStatus.initial,
    this.journey,
    this.errorMessage,
    this.advancing = false,
    this.truckInMaintenance = false,
    this.truck,
  });

  JourneyState copyWith({
    JourneyBlocStatus? status,
    Journey? journey,
    bool clearJourney = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? advancing,
    bool? truckInMaintenance,
    Truck? truck,
    bool clearTruck = false,
  }) {
    return JourneyState(
      status: status ?? this.status,
      journey: clearJourney ? null : (journey ?? this.journey),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      advancing: advancing ?? this.advancing,
      truckInMaintenance: truckInMaintenance ?? this.truckInMaintenance,
      truck: clearTruck ? null : (truck ?? this.truck),
    );
  }
}
