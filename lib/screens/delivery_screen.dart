import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/journey_bloc/journey_bloc.dart';
import '../models/enums/journey_order_status.dart';
import '../models/enums/journey_status.dart';
import '../models/journey.dart';
import '../models/journey_order.dart';
import '../widget/on_error_widget.dart';
import '../widget/order_card_widget.dart';

class DeliveryScreen extends StatelessWidget {
  const DeliveryScreen({super.key});

  /// Trouve l'index de la prochaine commande non livrée.
  int? _findNextOrderIndex(List<JourneyOrder> orders) {
    for (int i = 0; i < orders.length; i++) {
      if (orders[i].status != JourneyOrderStatus.delivered) {
        return i;
      }
    }
    return null;
  }

  /// Body pour planned → loading.
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

  /// Body pour loading → in_delivery.
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

  /// Body pour valider une livraison et passer au suivant.
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
      appBar: AppBar(title: const Text('Livraisons')),
      body: BlocConsumer<JourneyBloc, JourneyState>(
        listenWhen: (prev, curr) {

          if (prev.advancing && !curr.advancing && curr.journey != null) {
            return curr.journey!.status == JourneyStatus.completed;
          }
          // 2. Ou via le polling, le statut passe à completed
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
            // Pas de commandes → retour au dashboard
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) Navigator.of(context).pop();
            });
            return const Center(child: CircularProgressIndicator());
          }

          final orders = journey.journeyOrders;
          final nextIndex = _findNextOrderIndex(orders);
          final isAdvancing = state.advancing;
          final journeyStatus = journey.status;

          // Phase chargement : planned ou loading
          final isLoadingPhase = journeyStatus == JourneyStatus.planned ||
              journeyStatus == JourneyStatus.loading;

          // Toutes livrées
          final allDelivered = nextIndex == null;

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Bouton de chargement ──
                  if (isLoadingPhase) ...[
                    _LoadingPhaseCard(
                      journeyStatus: journeyStatus,
                      isAdvancing: isAdvancing,
                      onPressed: isAdvancing
                          ? null
                          : () {
                              final body = journeyStatus == JourneyStatus.planned
                                  ? _loadingStartBody
                                  : _loadingEndBody(journey);
                              context
                                  .read<JourneyBloc>()
                                  .add(AdvanceNextStep(body: body));
                            },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Message de succès ──
                  if (journeyStatus == JourneyStatus.completed) ...[
                    _SuccessBanner(),
                    const SizedBox(height: 16),
                  ],

                  // ── Liste des commandes ──
                  ...List.generate(orders.length, (index) {
                    final jo = orders[index];
                    final isNext =
                        index == nextIndex && !isLoadingPhase;

                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: index < orders.length - 1 ? 8 : 0),
                      child: OrderCard(
                        journeyOrder: jo,
                        isNextDelivery: isNext,
                        isLoading: isNext && isAdvancing,
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

              // Overlay de chargement
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
              Navigator.of(context).pop(); // ferme le dialog
              Navigator.of(context).pop(); // retour au dashboard
            },
            child: const Text('Retour au tableau de bord'),
          ),
        ],
      ),
    );
  }
}

/// Carte pour la phase de chargement du camion.
class _LoadingPhaseCard extends StatelessWidget {
  final JourneyStatus journeyStatus;
  final bool isAdvancing;
  final VoidCallback? onPressed;

  const _LoadingPhaseCard({
    required this.journeyStatus,
    required this.isAdvancing,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final bool isPlanned = journeyStatus == JourneyStatus.planned;
    final String title =
        isPlanned ? 'Prêt à charger ?' : 'Chargement en cours';
    final String subtitle = isPlanned
        ? 'Appuyez pour commencer le chargement du camion.'
        : 'Appuyez quand le camion est chargé pour démarrer les livraisons.';
    final String buttonLabel =
        isPlanned ? 'Charger le camion' : 'Camion chargé, démarrer !';
    final IconData buttonIcon =
        isPlanned ? Icons.download_rounded : Icons.local_shipping;
    final Color accentColor = isPlanned ? colors.tertiary : Colors.orange;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accentColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              isPlanned ? Icons.local_shipping_outlined : Icons.inventory,
              size: 48,
              color: accentColor,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: isAdvancing
                  ? Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: accentColor,
                        ),
                      ),
                    )
                  : FilledButton.icon(
                      onPressed: onPressed,
                      icon: Icon(buttonIcon),
                      label: Text(buttonLabel),
                      style: FilledButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bannière de succès quand toutes les commandes sont livrées.
class _SuccessBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: Colors.green.withValues(alpha: 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.green, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.celebration, size: 48, color: Colors.green),
            const SizedBox(height: 12),
            Text(
              'Toutes les commandes sont livrées !',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Bravo, tournée complétée avec succès.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.green.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
