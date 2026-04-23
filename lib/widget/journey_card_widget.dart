import 'package:flutter/material.dart';

import '../models/enums/journey_status.dart';
import '../models/journey.dart';

class JourneyCard extends StatelessWidget {
  final Journey journey;
  final VoidCallback? onTap;

  const JourneyCard({super.key, required this.journey, this.onTap});

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
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
      ),
    );
  }
}
