
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/enums/truck_type.dart';
import '../models/truck.dart';

class TruckCard extends StatelessWidget {
  final Truck? truck;
  const TruckCard({this.truck});

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