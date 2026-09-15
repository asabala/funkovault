import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'atlas/boot/atlas_boot_screen.dart';
import 'config/atlas_config.dart';
import 'security/auth_provider.dart';
import 'services/app_state.dart';
import 'services/hive_service.dart';
import 'subscriptions/revenuecat_subscription_service.dart';
import 'theme/atlas_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await HiveService.openBox();

  await Supabase.initialize(
    url: AtlasConfig.supabaseUrl,
    publishableKey: AtlasConfig.supabasePublishableKey,
  );

  await Supabase.initialize(
    url: AtlasConfig.supabaseUrl,
    publishableKey: AtlasConfig.supabasePublishableKey,
  );

  final appState = AppState();

  await appState.loadData();

  await RevenueCatSubscriptionService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
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
      home: const AtlasBootScreen(),
    );
  }
}
