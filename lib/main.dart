import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const FunkoVaultApp());
}

class FunkoVaultApp extends StatelessWidget {
  const FunkoVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Funko Vault',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}