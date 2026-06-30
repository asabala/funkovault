import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/app_state.dart';
import 'services/hive_service.dart';
import 'theme/atlas_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await HiveService.openBox();

  final appState = AppState();

  await appState.loadData();

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const FunkoVaultApp(),
    ),
  );
}

class FunkoVaultApp extends StatelessWidget {
  const FunkoVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Funko Vault',
      debugShowCheckedModeBanner: false,
      theme: AtlasTheme.dark(),
      home: const HomeScreen(),
    );
  }
}