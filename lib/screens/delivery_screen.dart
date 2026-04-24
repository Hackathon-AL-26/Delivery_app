import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/journey_bloc/journey_bloc.dart';
import '../models/enums/journey_order_status.dart';
import '../models/enums/journey_status.dart';
import '../models/journey.dart';
import '../models/journey_order.dart';
import '../repository/journey_repository/journey_repository.dart';
import '../widget/loading_phase_card_widget.dart';
import '../widget/on_error_widget.dart';
import '../widget/order_card_widget.dart';
import '../widget/success_banner_widget.dart';
import 'detail_delivery_order_screen.dart';
import 'journey_detail_screen.dart';

class DeliveryScreen extends StatelessWidget {
  const DeliveryScreen({super.key});

  int? _findNextOrderIndex(List<JourneyOrder> orders) {
    for (int i = 0; i < orders.length; i++) {
      if (orders[i].status != JourneyOrderStatus.delivered) {
        return i;
      }
    }
    return null;
  }

  Map<String, dynamic> get _loadingStartBody => {
        'advanced': true,
        'newJourneyStatus': 'loading',
        'completedStep': {
          'type': 'loading_start',
          'label': 'Début remplissage camion',
        },
        'nextStep': {
          'type': 'loading_end',
          'label': 'Fin remplissage camion',
        },
      };

  Map<String, dynamic> _loadingEndBody(Journey journey) {
    final nextOrder = _findNextOrder(journey);
    final nextLabel = nextOrder?.store?.name ?? 'Livraison';
    return {
      'advanced': true,
      'newJourneyStatus': 'in_delivery',
      'completedStep': {
        'type': 'loading_end',
        'label': 'Fin remplissage camion',
      },
      'nextStep': {
        'type': 'delivery',
        'label': nextLabel,
      },
    };
  }

  JourneyOrder? _findNextOrder(Journey journey) {
    for (final jo in journey.journeyOrders) {
      if (jo.status != JourneyOrderStatus.delivered) return jo;
    }
    return null;
  }

  Map<String, dynamic> _buildDeliveryStepBody(
    List<JourneyOrder> orders,
    int currentIndex,
  ) {
    final current = orders[currentIndex];
    final currentLabel = current.store?.name ?? 'Livraison';

    JourneyOrder? nextOrder;
    for (int i = currentIndex + 1; i < orders.length; i++) {
      if (orders[i].status != JourneyOrderStatus.delivered) {
        nextOrder = orders[i];
        break;
      }
    }

    if (nextOrder != null) {
      final nextLabel = nextOrder.store?.name ?? 'Livraison';
      return {
        'advanced': true,
        'newJourneyStatus': 'in_delivery',
        'completedStep': {'type': 'delivery', 'label': currentLabel},
        'nextStep': {'type': 'delivery', 'label': nextLabel},
      };
    } else {
      return {
        'advanced': true,
        'newJourneyStatus': 'completed',
        'completedStep': {'type': 'delivery', 'label': currentLabel},
        'nextStep': {'type': 'completed', 'label': 'Tournée terminée'},
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livraisons'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'Voir la tournée',
            onPressed: () {
              final bloc = context.read<JourneyBloc>();
              final repo = context.read<JourneyRepository>();
              final journey = bloc.state.journey;
              if (journey == null) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => JourneyDetailScreen(
                    journey: journey,
                    repository: repo,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<JourneyBloc, JourneyState>(
        listenWhen: (prev, curr) {
          if (prev.advancing && !curr.advancing && curr.journey != null) {
            return curr.journey!.status == JourneyStatus.completed;
          }
          if (prev.journey != null &&
              curr.journey != null &&
              prev.journey!.status != JourneyStatus.completed &&
              curr.journey!.status == JourneyStatus.completed) {
            return true;
          }
          return false;
        },
        listener: (context, state) {
          _showSuccessDialog(context);
        },
        builder: (context, state) {
          if (state.status == JourneyBlocStatus.loading ||
              state.status == JourneyBlocStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == JourneyBlocStatus.error) {
            return OnErrorWidget(
              text: state.errorMessage ?? 'Erreur lors du chargement.',
            );
          }

          final journey = state.journey;
          if (journey == null || journey.journeyOrders.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) Navigator.of(context).pop();
            });
            return const Center(child: CircularProgressIndicator());
          }

          final orders = journey.journeyOrders;
          final nextIndex = _findNextOrderIndex(orders);
          final isAdvancing = state.advancing;
          final journeyStatus = journey.status;

          final isLoadingPhase = journeyStatus == JourneyStatus.planned ||
              journeyStatus == JourneyStatus.loading;

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 32),
                children: [
                  // ── Carte de chargement ──
                  if (isLoadingPhase) ...[
                    LoadingPhaseCard(
                      journeyStatus: journeyStatus,
                      isAdvancing: isAdvancing,
                      onPressed: isAdvancing
                          ? null
                          : () {
                              final body =
                                  journeyStatus == JourneyStatus.planned
                                      ? _loadingStartBody
                                      : _loadingEndBody(journey);
                              context
                                  .read<JourneyBloc>()
                                  .add(AdvanceNextStep(body: body));
                              context.read<JourneyBloc>().add(UpdateTruckStatus(truckId: journey.truckId ?? "", status: "in_use"));
                            },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Bannière de succès ──
                  if (journeyStatus == JourneyStatus.completed) ...[
                    const SuccessBanner(),
                    const SizedBox(height: 16),
                  ],

                  // ── Liste des commandes ──
                  ...List.generate(orders.length, (index) {
                    final jo = orders[index];
                    final isNext = index == nextIndex && !isLoadingPhase;

                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: index < orders.length - 1 ? 8 : 0),
                      child: OrderCard(
                        journeyOrder: jo,
                        isNextDelivery: isNext,
                        isLoading: isNext && isAdvancing,
                        onTap: () {
                          final repo = context.read<JourneyRepository>();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DetailDeliveryOrderScreen(
                                journeyOrder: jo,
                                repository: repo,
                              ),
                            ),
                          );
                        },
                        onAdvanceStep: isNext && !isAdvancing
                            ? () {
                                context.read<JourneyBloc>().add(
                                      AdvanceNextStep(
                                        body: _buildDeliveryStepBody(
                                            orders, index),
                                      ),
                                    );
                              }
                            : null,
                      ),
                    );
                  }),
                ],
              ),

              if (isAdvancing)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.05),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.celebration, size: 48, color: Colors.green),
        title: const Text('Tournée terminée !'),
        content: const Text(
          'Toutes les commandes ont été livrées avec succès. Beau travail !',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Retour au tableau de bord'),
          ),
        ],
      ),
    );
  }
}
