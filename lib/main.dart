import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'package:livreur_infflux/blocs/journey_detail_bloc/journey_detail_bloc.dart';
import 'package:livreur_infflux/repository/journey_detail_repository/data_sources/journey_detail_local_data_source.dart';
import 'package:livreur_infflux/repository/journey_detail_repository/journey_detail_repository.dart';
import 'package:livreur_infflux/screens/auth/auth_gate.dart';
import 'package:livreur_infflux/screens/journey_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Livreur Infflux',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
      onGenerateRoute: (settings) {
        if (settings.name == JourneyDetailScreen.routeName) {
          final args = settings.arguments as JourneyDetailScreenArgs;
          return MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => JourneyDetailBloc(
                repository: JourneyDetailRepository(
                  dataSource: JourneyDetailLocalDataSource(),
                ),
              )..add(JourneyDetailStarted(journeyUuid: args.journeyUuid)),
              child: JourneyDetailScreen(journeyUuid: args.journeyUuid),
            ),
          );
        }

        return null;
      },
      home: const AuthGate(),
    );
  }
}
