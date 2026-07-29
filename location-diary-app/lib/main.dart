import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/root_shell.dart';

void main() {
  runApp(const ProviderScope(child: LocationDiaryApp()));
}

class LocationDiaryApp extends StatelessWidget {
  const LocationDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '位置情報日記',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const RootShell(),
    );
  }
}
