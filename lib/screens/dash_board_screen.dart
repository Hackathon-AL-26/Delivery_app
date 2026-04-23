import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/journey_bloc/journey_bloc.dart';
import '../models/enums/journey_status.dart';
import '../models/journey.dart';
import '../widget/on_error_widget.dart';

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.event_available,
                    size: 48,
                    color: Theme.of(context).colorScheme.outline),
                const SizedBox(height: 12),
                Text(
                  'Aucune tournée assignée',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Greeting
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
            const SizedBox(height: 24),

            // Camion
            _TruckBanner(truckId: journey.truckId),
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
            _JourneyCard(journey: journey),

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
          ],
        );
      },
    );
  }

  String _ordersSummary(Journey journey) {
    final total = journey.journeyOrders.length;
    final delivered = journey.journeyOrders
        .where((jo) => jo.status.value == 'delivered')
        .length;
    return '$delivered / $total livrées';
  }
}

// ─────────────────────────────────────────────
// Bannière camion
// ─────────────────────────────────────────────
class _TruckBanner extends StatelessWidget {
  final String? truckId;
  const _TruckBanner({this.truckId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.local_shipping,
                color: colors.onPrimaryContainer,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Votre camion',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    truckId ?? 'Aucun camion assigné',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (truckId != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  truckId!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Journey Card
// ─────────────────────────────────────────────
class _JourneyCard extends StatelessWidget {
  final Journey journey;
  const _JourneyCard({required this.journey});

  Color _statusColor(JourneyStatus s, ColorScheme c) {
    switch (s) {
      case JourneyStatus.planned:
        return c.primary;
      case JourneyStatus.loading:
        return c.tertiary;
      case JourneyStatus.inDelivery:
        return Colors.orange;
      case JourneyStatus.completed:
        return Colors.green;
    }
  }

  String _statusLabel(JourneyStatus s) {
    switch (s) {
      case JourneyStatus.planned:
        return 'Planifiée';
      case JourneyStatus.loading:
        return 'Chargement';
      case JourneyStatus.inDelivery:
        return 'En livraison';
      case JourneyStatus.completed:
        return 'Terminée';
    }
  }

  IconData _statusIcon(JourneyStatus s) {
    switch (s) {
      case JourneyStatus.planned:
        return Icons.calendar_today;
      case JourneyStatus.loading:
        return Icons.download;
      case JourneyStatus.inDelivery:
        return Icons.local_shipping;
      case JourneyStatus.completed:
        return Icons.check_circle;
    }
  }

  String _fmt(DateTime? dt) {
    if (dt == null) return '--:--';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final sc = _statusColor(journey.status, colors);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tournée',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sc.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(journey.status), size: 16, color: sc),
                      const SizedBox(width: 4),
                      Text(
                        _statusLabel(journey.status),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: sc,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Date & horaires
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month, size: 16, color: colors.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date',
                              style: theme.textTheme.labelSmall?.copyWith(color: colors.outline)),
                          Text(_fmtDate(journey.startTime),
                              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: colors.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Horaires',
                              style: theme.textTheme.labelSmall?.copyWith(color: colors.outline)),
                          Text(
                            '${_fmt(journey.startTime)} → ${_fmt(journey.endTime)}',
                            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
