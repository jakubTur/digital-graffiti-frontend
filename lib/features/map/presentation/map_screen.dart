import 'package:flutter/material.dart';
import 'package:frontend/features/map/data/map_model.dart';
import 'package:frontend/features/map/presentation/map_ui.dart';
import 'package:provider/provider.dart';

import 'display_map.dart';

/// Main screen of the app, containing the map and its model (aka state repository)
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Map',
      home: ChangeNotifierProvider(
        create: (context) => MapModel(), // Map-wide state
        child: Stack(children: [DisplayMap(), MapUi()]), // Map widget
      ),
    );
  }
}
