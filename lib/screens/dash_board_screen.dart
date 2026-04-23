import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/journey_bloc/journey_bloc.dart';
import '../models/enums/journey_order_status.dart';
import '../models/enums/journey_status.dart';
import '../models/journey.dart';
import '../models/journey_order.dart';
import '../widget/journey_card_widget.dart';
import '../widget/on_error_widget.dart';
import '../widget/order_card_widget.dart';
import '../widget/report_alert_dialog.dart';
import '../widget/truck_banner_widget.dart';

class DashBoardScreen extends StatelessWidget {
  const DashBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JourneyBloc, JourneyState>(
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
        if (journey == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.celebration, size: 64, color: Colors.green),
                  const SizedBox(height: 16),
                  Text(
                    'Tournée du jour terminée !',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vous avez effectué toutes vos livraisons du jour. Beau travail !',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          // Padding en bas pour ne pas cacher du contenu sous le FAB
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour !',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Voici votre tournée du jour',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    reportAlertDialog(context);
                  },
                  icon: const Icon(Icons.warning_amber_rounded, size: 18),
                  label: const Text('Signaler'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.errorContainer,
                    foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Camion
            TruckBanner(truckId: journey.truckId),
            const SizedBox(height: 24),

            // Journey card
            Row(
              children: [
                Icon(Icons.route, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Ma tournée',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            JourneyCard(journey: journey),

            const SizedBox(height: 24),

            // Résumé commandes
            Row(
              children: [
                Icon(Icons.list_alt, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Commandes (${journey.journeyOrders.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _ordersSummary(journey),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),

            const SizedBox(height: 24),

            // Prochaine commande
            ..._buildNextOrder(context, journey),

            // Badge tournée terminée
            if (journey.status == JourneyStatus.completed) ...[
              const SizedBox(height: 24),
              Card(
                color: Colors.green.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Tournée terminée',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  List<Widget> _buildNextOrder(BuildContext context, Journey journey) {
    final nextOrder = _findNextOrder(journey);
    if (nextOrder == null) return [];

    return [
      Row(
        children: [
          Icon(Icons.next_plan, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            'Prochaine livraison',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      OrderCard(journeyOrder: nextOrder),
    ];
  }

  static JourneyOrder? _findNextOrder(Journey journey) {
    for (final jo in journey.journeyOrders) {
      if (jo.status != JourneyOrderStatus.delivered) {
        return jo;
      }
    }
    return null;
  }

  String _ordersSummary(Journey journey) {
    final total = journey.journeyOrders.length;
    final delivered = journey.journeyOrders
        .where((jo) => jo.status.value == 'delivered')
        .length;
    return '$delivered / $total livrées';
  }
}
