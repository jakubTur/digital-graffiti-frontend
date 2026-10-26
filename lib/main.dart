import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/camera/camera.dart';
import 'package:frontend/features/auth/domain/repositories/user_repository.dart';
import 'package:frontend/features/auth/presentation/login_ui.dart';
import 'package:frontend/features/drawing/presentation/paint_screen.dart';
import 'package:frontend/features/map/presentation/map_screen.dart';
import 'package:go_router/go_router.dart';

import 'core/network/api_client.dart';
import 'features/auth/data/datasources/user_remote_ds.dart';
import 'features/auth/data/repositories/user_repository_impl.dart';
import 'features/auth/presentation/registration_successful.dart';
import 'features/auth/presentation/registration_ui.dart';

void main() async {
  // App locked into vertical mode
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final api = ApiClient();
  final repo = UserRepositoryImpl(UserRemoteDataSource(api));

  runApp(MyApp(userRepository: repo));
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.userRepository});

  final UserRepository userRepository;

  late final GoRouter router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => LoginUi()),
      GoRoute(path: '/map', builder: (context, state) => MapScreen()),
      GoRoute(
        path: '/canvas',
        builder: (context, state) {
          final imagePath = state.extra as String?;
          return PaintScreen(imagePath: imagePath);
        },
      ),
      GoRoute(
        path: '/camera',
        builder: (context, state) => const CameraScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegistrationUi(repo: userRepository),
      ),
      GoRoute(
        path: '/registration_successful',
        builder: (context, state) => const RegistrationSuccessful(),
      ),
      // TODO: put other routes here!!!
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: router);
  }
}
