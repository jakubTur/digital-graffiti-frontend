import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/camera/camera.dart';
import 'package:frontend/features/auth/domain/repositories/user_repository.dart';
import 'package:frontend/features/auth/presentation/login_ui.dart';
import 'package:frontend/features/drawing/presentation/paint_screen.dart';
import 'package:frontend/features/map/presentation/map_screen.dart';
import 'package:frontend/features/profile/data/user_relation_status.dart';
import 'package:frontend/features/profile/presentation/account_settings.dart';
import 'package:frontend/features/profile/presentation/edit_profile_ui.dart';
import 'package:go_router/go_router.dart';

import 'core/storage/auth_storage.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'core/storage/auth_storage.dart';
import 'features/auth/data/datasources/user_remote_ds.dart';
import 'features/auth/data/repositories/user_repository_impl.dart';
import 'features/auth/presentation/registration_successful.dart';
import 'features/auth/presentation/registration_ui.dart';
import 'features/profile/presentation/profile_ui.dart';

void main() async {
  // App locked into vertical mode
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  const secureStorage = FlutterSecureStorage();
  final authStorage = AuthStorage(secureStorage);
  final api = ApiClient(
    tokenProvider: authStorage.readAccessToken,
    refreshTokenProvider: authStorage.readRefreshToken,
    updateTokens: authStorage.updateTokens,
  );
  final repo = UserRepositoryImpl(UserRemoteDataSource(api));

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(
    MyApp(
      userRepository: repo,
      authStorage: authStorage,
      isLoggedIn: isLoggedIn,
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({
    super.key,
    required this.userRepository,
    required this.authStorage,
    required this.isLoggedIn,
  });

  final UserRepository userRepository;
  final AuthStorage authStorage;
  final bool isLoggedIn;

  late final GoRouter router = GoRouter(
    initialLocation: isLoggedIn ? '/map' : '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            LoginUi(repo: userRepository, authStorage: authStorage),
      ),
      GoRoute(path: '/map', builder: (context, state) => const MapScreen()),
      GoRoute(
        path: '/post/draw',
        builder: (context, _) =>
            PaintScreen(onImageCreated: (image) => context.pop(image)),
      ),
      GoRoute(
        path: '/post/camera',
        builder: (context, _) => CameraScreen(
          onPhotoCaptured: (path) async {
            final image = await context.push<Uint8List>(
              '/post/photo-edit',
              extra: path,
            );
            if (context.mounted) context.pop(image);
          },
        ),
      ),
      GoRoute(
        path: '/post/photo-edit',
        builder: (context, state) => PaintScreen(
          imagePath: state.extra as String,
          onImageCreated: (image) => context.pop(image),
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) =>
            RegistrationUi(repo: userRepository, authStorage: authStorage),
      ),
      GoRoute(
        path: '/registration_successful',
        builder: (context, state) => const RegistrationSuccessful(),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          opaque: false, // makes the map visible behind the screen
          // screen transition animation
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: const ProfileUi(UserRelationStatus.SELF),
        ),
      ),
      GoRoute(
        path: '/account-settings',
        builder: (context, state) => const AccountSettings(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileUi(),
      ),

      // TODO: put other routes here!!!
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: router);
  }
}
