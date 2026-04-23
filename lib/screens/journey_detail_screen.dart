import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/journey_detail_bloc/journey_detail_bloc.dart';
import '../models/enums/journey_order_status.dart';
import '../models/enums/journey_status.dart';
import '../models/enums/truck_type.dart';
import '../models/journey_order.dart';
import '../models/order.dart';
import '../models/truck.dart';

class JourneyDetailScreenArgs {
  final String journeyUuid;
  const JourneyDetailScreenArgs({required this.journeyUuid});
}

class JourneyDetailScreen extends StatelessWidget {
  static const routeName = '/journey-detail';
  final String journeyUuid;

  const JourneyDetailScreen({super.key, required this.journeyUuid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détail de tournée')),
      body: BlocBuilder<JourneyDetailBloc, JourneyDetailState>(
        builder: (context, state) {
          if (state.status == JourneyDetailStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == JourneyDetailStatus.error) {
            return const Center(child: Text('Erreur lors du chargement.'));
          }

          final journey = state.journey;
          if (journey == null) {
            return const Center(child: Text('Aucune tournée trouvée.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --- Header Journey ---
              _JourneyHeaderCard(
                uuid: journey.uuid,
                status: journey.status,
                driverEmail: journey.driverEmail,
                startTime: journey.startTime,
                endTime: journey.endTime,
              ),
              const SizedBox(height: 12),

              // --- Truck Card ---
              _TruckCard(truck: state.truck),
              const SizedBox(height: 20),

              // --- Commandes ---
              Row(
                children: [
                  const Icon(Icons.list_alt, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Commandes (${state.journeyOrders.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (state.journeyOrders.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Aucune commande associée',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  ),
                )
              else
                ...state.journeyOrders.map((jo) {
                  final order = state.orders
                      .cast<Order?>()
                      .firstWhere((o) => o?.id == jo.orderId, orElse: () => null);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _OrderCard(journeyOrder: jo, order: order),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

class _JourneyHeaderCard extends StatelessWidget {
  final String uuid;
  final JourneyStatus status;
  final String? driverEmail;
  final DateTime? startTime;
  final DateTime? endTime;

  const _JourneyHeaderCard({
    required this.uuid,
    required this.status,
    this.driverEmail,
    this.startTime,
    this.endTime,
  });

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
    final sc = _statusColor(status, colors);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // UUID + badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    uuid,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
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
                      Icon(_statusIcon(status), size: 16, color: sc),
                      const SizedBox(width: 4),
                      Text(
                        _statusLabel(status),
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

            // Infos
            Row(
              children: [
                Expanded(
                  child: _DetailRow(
                    icon: Icons.person_outline,
                    label: 'Livreur',
                    value: driverEmail ?? '-',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DetailRow(
                    icon: Icons.calendar_month,
                    label: 'Date',
                    value: _fmtDate(startTime),
                  ),
                ),
                Expanded(
                  child: _DetailRow(
                    icon: Icons.schedule,
                    label: 'Horaires',
                    value: '${_fmt(startTime)} → ${_fmt(endTime)}',
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

class _TruckCard extends StatelessWidget {
  final Truck? truck;
  const _TruckCard({this.truck});

  String _truckTypeLabel(TruckType t) {
    switch (t) {
      case TruckType.small:
        return 'Petit (4 palettes)';
      case TruckType.medium:
        return 'Moyen (10 palettes)';
      case TruckType.big:
        return 'Semi-remorque (40 palettes)';
    }
  }

  IconData _truckIcon(TruckType t) {
    switch (t) {
      case TruckType.small:
        return Icons.airport_shuttle;
      case TruckType.medium:
        return Icons.local_shipping;
      case TruckType.big:
        return Icons.fire_truck;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (truck == null) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(Icons.local_shipping_outlined, color: colors.outline),
              const SizedBox(width: 12),
              Text('Aucun camion assigné',
                  style: TextStyle(color: colors.outline)),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _truckIcon(truck!.type),
                color: colors.onPrimaryContainer,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    truck!.name ?? truck!.id,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _truckTypeLabel(truck!.type),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                truck!.id,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSecondaryContainer,
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
// Order Card (dans la liste des commandes)
// ─────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final JourneyOrder journeyOrder;
  final Order? order;
  const _OrderCard({required this.journeyOrder, this.order});

  Color _statusColor(JourneyOrderStatus s, ColorScheme c) {
    switch (s) {
      case JourneyOrderStatus.planned:
        return c.primary;
      case JourneyOrderStatus.loaded:
        return c.tertiary;
      case JourneyOrderStatus.inDelivery:
        return Colors.orange;
      case JourneyOrderStatus.delivered:
        return Colors.green;
    }
  }

  String _statusLabel(JourneyOrderStatus s) {
    switch (s) {
      case JourneyOrderStatus.planned:
        return 'Planifiée';
      case JourneyOrderStatus.loaded:
        return 'Chargée';
      case JourneyOrderStatus.inDelivery:
        return 'En livraison';
      case JourneyOrderStatus.delivered:
        return 'Livrée';
    }
  }

  IconData _statusIcon(JourneyOrderStatus s) {
    switch (s) {
      case JourneyOrderStatus.planned:
        return Icons.schedule;
      case JourneyOrderStatus.loaded:
        return Icons.inventory;
      case JourneyOrderStatus.inDelivery:
        return Icons.local_shipping;
      case JourneyOrderStatus.delivered:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final sc = _statusColor(journeyOrder.status, colors);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ligne du haut
            Row(
              children: [
                // Numéro d'ordre
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${journeyOrder.deliveryOrder ?? '-'}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order?.id ?? journeyOrder.orderId,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (order?.storeUuid != null)
                        Text(
                          order!.storeUuid!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                // Badge statut
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: sc.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(journeyOrder.status), size: 14, color: sc),
                      const SizedBox(width: 4),
                      Text(
                        _statusLabel(journeyOrder.status),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: sc,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (order != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // Détails commande
              Row(
                children: [
                  _MiniInfo(icon: Icons.inventory_2, label: '${order!.packageAmount ?? 0} colis'),
                  const SizedBox(width: 16),
                  _MiniInfo(icon: Icons.euro, label: '${order!.montant ?? 0} €'),
                  const SizedBox(width: 16),
                  if (order!.deliveryDate != null)
                    _MiniInfo(icon: Icons.calendar_month, label: order!.deliveryDate!),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: colors.onSurfaceVariant),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelSmall?.copyWith(color: colors.outline)),
            Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MiniInfo({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
      ],
    );
  }
}
