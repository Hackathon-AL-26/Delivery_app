import 'package:flutter/material.dart';

import '../models/enums/journey_order_status.dart';
import '../models/journey_order.dart';

class OrderCard extends StatelessWidget {
  final JourneyOrder journeyOrder;
  final VoidCallback? onTap;

  /// Si true, la carte est mise en évidence (prochaine livraison).
  final bool isNextDelivery;

  /// Callback pour le bouton "Passer au prochain step" (POST /journeys/me/next-step).
  final VoidCallback? onAdvanceStep;

  /// Affiche un spinner dans le bouton pendant l'appel API.
  final bool isLoading;

  const OrderCard({
    super.key,
    required this.journeyOrder,
    this.onTap,
    this.isNextDelivery = false,
    this.onAdvanceStep,
    this.isLoading = false,
  });

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
    final order = journeyOrder.order;
    final store = journeyOrder.store;
    final isDelivered = journeyOrder.status == JourneyOrderStatus.delivered;

    return Card(
      elevation: isNextDelivery ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isNextDelivery
            ? BorderSide(color: sc, width: 2)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bandeau de statut plein pour la prochaine livraison
            if (isNextDelivery)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: sc,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_statusIcon(journeyOrder.status),
                        size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      _statusLabel(journeyOrder.status).toUpperCase(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: ordre + store name + badge
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isNextDelivery
                              ? sc.withValues(alpha: 0.2)
                              : colors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${journeyOrder.deliveryOrder ?? '-'}',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: isNextDelivery
                                  ? sc
                                  : colors.onPrimaryContainer,
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
                              store?.name ?? 'Commande',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: isNextDelivery ? 16 : null,
                              ),
                            ),
                            if (store?.email != null)
                              Text(
                                store!.email!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Badge de statut (seulement si pas isNextDelivery, car on a le bandeau)
                      if (!isNextDelivery)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: sc.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_statusIcon(journeyOrder.status),
                                  size: 14, color: sc),
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

                  if (order != null || store != null) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        if (order?.packageAmount != null)
                          _MiniInfo(
                              icon: Icons.inventory_2,
                              label: '${order!.packageAmount} colis'),
                        if (order?.price != null)
                          _MiniInfo(
                              icon: Icons.euro,
                              label:
                                  '${order!.price!.toStringAsFixed(0)} €'),
                        if (order?.deliveryDate != null)
                          _MiniInfo(
                              icon: Icons.calendar_month,
                              label: order!.deliveryDate!),
                        if (store?.deliveryHours != null)
                          _MiniInfo(
                              icon: Icons.schedule,
                              label: store!.deliveryHours!),
                      ],
                    ),
                  ],

                  // Bouton next-step uniquement pour la prochaine livraison
                  if (isNextDelivery && !isDelivered) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: isLoading
                          ? Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: sc,
                                ),
                              ),
                            )
                          : FilledButton.icon(
                              onPressed: onAdvanceStep,
                              icon: const Icon(Icons.navigate_next, size: 20),
                              label: const Text('Valider et passer au suivant'),
                              style: FilledButton.styleFrom(
                                backgroundColor: sc,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                textStyle: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ),
                  ],

                  // Badge Livrée
                  if (isDelivered) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Livrée',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
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
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: colors.onSurfaceVariant)),
      ],
    );
  }
}
