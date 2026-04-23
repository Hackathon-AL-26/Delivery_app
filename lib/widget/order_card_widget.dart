import 'package:flutter/material.dart';

import '../models/enums/journey_order_status.dart';
import '../models/journey_order.dart';
import '../models/order.dart';



class OrderCard extends StatelessWidget {
  final JourneyOrder journeyOrder;
  final Order? order;
  const OrderCard({
    super.key,
    required this.journeyOrder,
    this.order,
  });

  Order? get _resolvedOrder => order ?? journeyOrder.order;

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
    final resolvedOrder = _resolvedOrder;
    final storeName = journeyOrder.store?.name ?? resolvedOrder?.storeUuid;

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
                        resolvedOrder?.id ?? journeyOrder.orderId,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (storeName != null)
                        Text(
                          storeName,
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

            if (resolvedOrder != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // Détails commande
              Row(
                children: [
                  _MiniInfo(icon: Icons.inventory_2, label: '${resolvedOrder.packageAmount ?? 0} colis'),
                  const SizedBox(width: 16),
                  _MiniInfo(icon: Icons.euro, label: '${resolvedOrder.price ?? 0} €'),
                  const SizedBox(width: 16),
                  if (resolvedOrder.deliveryDate != null)
                    _MiniInfo(icon: Icons.calendar_month, label: resolvedOrder.deliveryDate!),
                ],
              ),
            ],
          ],
        ),
      ),
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
