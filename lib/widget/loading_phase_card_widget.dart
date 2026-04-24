import 'package:flutter/material.dart';

import '../models/enums/journey_status.dart';

class LoadingPhaseCard extends StatelessWidget {
  final JourneyStatus journeyStatus;
  final bool isAdvancing;
  final VoidCallback? onPressed;

  const LoadingPhaseCard({
    super.key,
    required this.journeyStatus,
    required this.isAdvancing,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final bool isPlanned = journeyStatus == JourneyStatus.planned;
    final String title =
        isPlanned ? 'Prêt à charger ?' : 'Chargement en cours';
    final String subtitle = isPlanned
        ? 'Appuyez pour commencer le chargement du camion.'
        : 'Appuyez quand le camion est chargé pour démarrer les livraisons.';
    final String buttonLabel =
        isPlanned ? 'Charger le camion' : 'Camion chargé, démarrer !';
    final IconData buttonIcon =
        isPlanned ? Icons.download_rounded : Icons.local_shipping;
    final Color accentColor = isPlanned ? colors.tertiary : Colors.orange;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accentColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              isPlanned ? Icons.local_shipping_outlined : Icons.inventory,
              size: 48,
              color: accentColor,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: isAdvancing
                  ? Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: accentColor,
                        ),
                      ),
                    )
                  : FilledButton.icon(
                      onPressed: onPressed,
                      icon: Icon(buttonIcon),
                      label: Text(buttonLabel),
                      style: FilledButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
