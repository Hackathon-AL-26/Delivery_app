import 'package:flutter/material.dart';

import '../models/enums/truck_status.dart';
import '../models/enums/truck_type.dart';
import '../models/truck.dart';

class TruckBanner extends StatelessWidget {
  final Truck? truck;
  final String? truckId;

  const TruckBanner({super.key, this.truck, this.truckId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isMaintenance = truck?.status == TruckStatus.maintenance;
    final cardColor = isMaintenance ? colors.errorContainer : colors.primaryContainer;
    final onCardColor = isMaintenance ? colors.onErrorContainer : colors.onPrimaryContainer;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: onCardColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isMaintenance ? Icons.build : Icons.local_shipping,
                color: onCardColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    truck?.name ?? 'Votre camion',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: onCardColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _subtitle(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: onCardColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: onCardColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _statusLabel(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: onCardColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _subtitle() {
    if (truck == null) return truckId ?? 'Aucun camion assigné';
    final typeLabel = _truckTypeLabel(truck!.type);
    return '$typeLabel';
  }

  String _statusLabel() {
    if (truck == null) return truckId ?? '';
    switch (truck!.status) {
      case TruckStatus.free:
        return 'Disponible';
      case TruckStatus.inUse:
        return 'En service';
      case TruckStatus.maintenance:
        return 'Maintenance';
    }
  }

  String _truckTypeLabel(TruckType type) {
    switch (type) {
      case TruckType.small:
        return 'Petit';
      case TruckType.medium:
        return 'Moyen';
      case TruckType.big:
        return 'Grand';
    }
  }
}
