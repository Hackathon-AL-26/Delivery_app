import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:livreur_infflux/blocs/journey_bloc/journey_bloc.dart';
import 'package:livreur_infflux/repository/journey_repository/data_sources/journey_api_data_source.dart';
import 'package:livreur_infflux/repository/journey_repository/journey_repository.dart';
import 'package:livreur_infflux/screens/dash_board_screen.dart';
import 'package:livreur_infflux/services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = JourneyRepository(
      journeyDataSource: JourneyApiDataSource(),
    );

    return RepositoryProvider.value(
      value: repository,
      child: BlocProvider(
        create: (_) => JourneyBloc(repository: repository)
          ..add(WatchMyJourney()),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('FluxTMS'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Se déconnecter',
                onPressed: () => AuthService().signOut(),
              ),
            ],
          ),
          body: const DashBoardScreen(),
        ),
      ),
    );
  }
}
