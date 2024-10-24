import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/providers/app_state.dart';
import 'package:tax_code_flutter_wear_os/widgets/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await Firebase.initializeApp();
  }

  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => AppState())],
    child: const TaxCodeApp(),
  ));
}

class TaxCodeApp extends StatelessWidget {
  const TaxCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          onSurface: Colors.white,
        ),
        visualDensity: VisualDensity.compact,
        useMaterial3: true,
      ),
      home: AuthGate(),
    );
  }
}
