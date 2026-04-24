import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/journey_bloc/journey_bloc.dart';

void resetStatusAlertDialog(BuildContext context) {
  final journey = context.read<JourneyBloc>().state.journey;
  final truckId = journey?.truckId;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (_, setState) {
          return AlertDialog(
            title: const Text('Remettre le camion en service'),
            content: SingleChildScrollView(
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Êtes-vous sûr de vouloir remettre ce camion en service ?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => {Navigator.pop(dialogContext)},
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: truckId != null
                    ? () {
                        context.read<JourneyBloc>().add(
                          UpdateTruckStatus(
                              truckId: truckId,
                              status: 'in_use',
                          ),
                        );
                        Navigator.pop(dialogContext);
                      }
                    : null,
                child: const Text('Remettre en service'),
              ),
            ],
          );
        },
      );
    },
  );
}
