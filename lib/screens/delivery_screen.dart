import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:livreur_infflux/blocs/journey_bloc/journey_bloc.dart';
import 'package:livreur_infflux/models/journey.dart';
import 'package:livreur_infflux/models/enums/journey_status.dart';

enum _FilterMode { driverJourneys, notCompleted }

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  _FilterMode _filter = _FilterMode.driverJourneys;

  List<Journey> _applyFilter(List<Journey> journeys) {
    switch (_filter) {
      case _FilterMode.driverJourneys:
        return journeys;
      case _FilterMode.notCompleted:
        return journeys
            .where((j) => j.status != JourneyStatus.completed)
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SegmentedButton<_FilterMode>(
            segments: const [
              ButtonSegment(
                value: _FilterMode.driverJourneys,
                label: Text('Mes tournées'),
                icon: Icon(Icons.person),
              ),
              ButtonSegment(
                value: _FilterMode.notCompleted,
                label: Text('En cours'),
                icon: Icon(Icons.pending_actions),
              ),
            ],
            selected: {_filter},
            onSelectionChanged: (selection) {
              final nextFilter = selection.first;
              final driverId = FirebaseAuth.instance.currentUser?.email ?? '';

              setState(() => _filter = nextFilter);

              switch (nextFilter) {
                case _FilterMode.driverJourneys:
                  context.read<JourneyBloc>().add(
                    JourneyWatchDriverStarted(driverId: driverId),
                  );
                case _FilterMode.notCompleted:
                  context.read<JourneyBloc>().add(JourneyWatchAllStarted());
              }
            },
          ),
        ),

        Expanded(
          child: BlocBuilder<JourneyBloc, JourneyState>(
            builder: (context, state) {
              if (state.status == JourneyBlocStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == JourneyBlocStatus.error) {
                return const Center(
                  child: Text('Erreur lors du chargement des tournées.'),
                );
              }

              final journeys = _applyFilter(state.journeys);

              if (journeys.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 64, color: theme.colorScheme.outline),
                      const SizedBox(height: 12),
                      Text(
                        'Aucune tournée',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: journeys.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final journey = journeys[index];
                  return _JourneyCard(journey: journey);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _JourneyCard extends StatelessWidget {
  final Journey journey;
  const _JourneyCard({required this.journey});

  Color _statusColor(JourneyStatus status, ColorScheme colors) {
    switch (status) {
      case JourneyStatus.planned:
        return colors.primary;
      case JourneyStatus.loading:
        return colors.tertiary;
      case JourneyStatus.inDelivery:
        return Colors.orange;
      case JourneyStatus.completed:
        return Colors.green;
    }
  }

  String _statusLabel(JourneyStatus status) {
    switch (status) {
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

  IconData _statusIcon(JourneyStatus status) {
    switch (status) {
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

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final statusColor = _statusColor(journey.status, colors);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ligne du haut : UUID + badge statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  journey.uuid,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(journey.status),
                          size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        _statusLabel(journey.status),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                if (journey.truckId != null)
                  _InfoChip(
                    icon: Icons.local_shipping,
                    label: journey.truckId!,
                  ),
                if (journey.truckId != null) const SizedBox(width: 12),
                _InfoChip(
                  icon: Icons.schedule,
                  label:
                      '${_formatTime(journey.startTime)} → ${_formatTime(journey.endTime)}',
                ),
              ],
            ),

            if (journey.startTime != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_month,
                      size: 14, color: colors.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(journey.startTime),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
