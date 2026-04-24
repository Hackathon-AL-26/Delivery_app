import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/journey_bloc/journey_bloc.dart';
import '../models/enums/journey_status.dart';
import '../models/journey.dart';
import '../repository/journey_repository/journey_repository.dart';
import '../screens/delivery_screen.dart';

class FixedDeliveryButton extends StatelessWidget {
  final Journey journey;
  final bool disabled;

  const FixedDeliveryButton({super.key,
    required this.journey,
    this.disabled = false,
  });



  @override
  Widget build(BuildContext context) {
    final String label;
    final IconData icon;
    final Color bgColor;
    final Color fgColor;

    switch (journey.status) {
      case JourneyStatus.planned:
        label = 'Commencer le chargement';
        icon = Icons.download;
        bgColor = Theme.of(context).colorScheme.tertiary;
        fgColor = Theme.of(context).colorScheme.onTertiary;
      case JourneyStatus.loading:
        label = 'Voir les commandes';
        icon = Icons.local_shipping;
        bgColor = Colors.orange;
        fgColor = Colors.white;
      case JourneyStatus.inDelivery:
        label = 'Continuer les livraisons';
        icon = Icons.delivery_dining;
        bgColor = Theme.of(context).colorScheme.primary;
        fgColor = Theme.of(context).colorScheme.onPrimary;
      case JourneyStatus.completed:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (disabled)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.build,
                      size: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Camion en maintenance',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: disabled
                    ? null
                    : () {
                  final bloc = context.read<JourneyBloc>();
                  final repo = context.read<JourneyRepository>();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RepositoryProvider.value(
                        value: repo,
                        child: BlocProvider.value(
                          value: bloc,
                          child: const DeliveryScreen(),
                        ),
                      ),
                    ),
                  );
                },
                icon: Icon(icon),
                label: Text(label),
                style: FilledButton.styleFrom(
                  backgroundColor: bgColor,
                  foregroundColor: fgColor,
                  disabledBackgroundColor: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.12),
                  disabledForegroundColor: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}