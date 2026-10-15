import 'package:flutter/material.dart';
import 'features/map/presentation/display_map.dart';

///TODO: split this megascript into smaller scripts when it grows out of scale

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Map',
      home: const TestMap(title: 'Flutter Map Test'),
    );
  }
}
