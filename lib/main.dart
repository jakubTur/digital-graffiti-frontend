import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/features/auth/presentation/login_ui.dart';
import 'package:frontend/features/drawing/presentation/drawing_canvas.dart';
import 'package:frontend/features/map/presentation/map_screen.dart';
import 'package:go_router/go_router.dart';

void main() async {
  // App locked into vertical mode
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  GoRouter router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => LoginUi()),
      GoRoute(path: '/map', builder: (context, state) => MapScreen()),
      GoRoute(path: '/canvas', builder: (context, state) => DrawingCanvas()),
      GoRoute(path: '/map', builder: (context, state) => MapScreen()),
      // TODO: put other routes here!!!
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: router);
  }
}
