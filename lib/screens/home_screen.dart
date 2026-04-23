import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:livreur_infflux/blocs/journey_bloc/journey_bloc.dart';
import 'package:livreur_infflux/repository/journey_repository/data_sources/journey_api_data_source.dart';
import 'package:livreur_infflux/repository/journey_repository/journey_repository.dart';
import 'package:livreur_infflux/screens/dash_board_screen.dart';
import 'package:livreur_infflux/screens/delivery_screen.dart';
import 'package:livreur_infflux/services/auth_service.dart';

import '../models/enums/journey_status.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => JourneyBloc(
        repository: JourneyRepository(
          journeyDataSource: JourneyApiDataSource(),
        ),
      )..add(WatchMyJourney()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Livreur Infflux'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Se déconnecter',
              onPressed: () => AuthService().signOut(),
            ),
          ],
        ),
        body: const DashBoardScreen(),
        floatingActionButton: const _DeliveryFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

/// FAB flottant qui redirige vers DeliveryScreen.
/// Affiche un label contextuel selon le statut de la tournée.
class _DeliveryFab extends StatelessWidget {
  const _DeliveryFab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JourneyBloc, JourneyState>(
      builder: (context, state) {
        final journey = state.journey;
        if (journey == null) return const SizedBox.shrink();

        // Pas de FAB si la tournée est terminée
        if (journey.status == JourneyStatus.completed) {
          return const SizedBox.shrink();
        }

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
            label = '';
            icon = Icons.check;
            bgColor = Colors.green;
            fgColor = Colors.white;
        }

        return FloatingActionButton.extended(
          heroTag: 'delivery_fab',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<JourneyBloc>(),
                  child: const DeliveryScreen(),
                ),
              ),
            );
          },
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          icon: Icon(icon),
          label: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        );
      },
    );
  }
}
