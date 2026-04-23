
import 'package:flutter/material.dart';

import '../models/enums/journey_status.dart';

class JourneyHeaderCard extends StatelessWidget {
  final String uuid;
  final JourneyStatus status;
  final String? driverEmail;
  final DateTime? startTime;
  final DateTime? endTime;

  const JourneyHeaderCard({
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