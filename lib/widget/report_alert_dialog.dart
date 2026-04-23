import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livreur_infflux/blocs/journey_bloc/journey_bloc.dart';


void reportAlertDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (_, setState) {
          return AlertDialog(
            title: Text('Signaler un probleme avec le camion'),
            content: SingleChildScrollView(
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Column(
                      children: [
                        Text(
                          'Etes vous sur de signaler le camion comme ayant un probleme ?',
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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
                onPressed: () {
                  Navigator.pop(dialogContext);

                },
                child: const Text('Signaler un probleme'),
              ),
            ],
          );
        },
      );
    },
  );
}
