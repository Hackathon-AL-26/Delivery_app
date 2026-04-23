part of 'journey_bloc.dart';

enum JourneyBlocStatus { initial, loading, loaded, error }

final class JourneyState {
  final JourneyBlocStatus status;
  final Journey? journey;
  final String? errorMessage;

  /// True pendant un appel POST /journeys/me/next-step.
  final bool advancing;

  const JourneyState({
    this.status = JourneyBlocStatus.initial,
    this.journey,
    this.errorMessage,
    this.advancing = false,
  });

  JourneyState copyWith({
    JourneyBlocStatus? status,
    Journey? journey,
    bool clearJourney = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? advancing,
  }) {
    return JourneyState(
      status: status ?? this.status,
      journey: clearJourney ? null : (journey ?? this.journey),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      advancing: advancing ?? this.advancing,
    );
  }
}
