import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/camera/camera.dart';
import 'package:frontend/core/widgets/success_screen.dart';
import 'package:frontend/features/auth/domain/repositories/user_repository.dart';
import 'package:frontend/features/auth/presentation/login_ui.dart';
import 'package:frontend/features/drawing/presentation/paint_screen.dart';
import 'package:frontend/features/friends/data/datasources/relations_remote_ds.dart';
import 'package:frontend/features/friends/data/repositories/relation_repository_impl.dart';
import 'package:frontend/features/friends/domain/repository/relation_repository.dart';
import 'package:frontend/features/friends/presentation/friends_popup.dart';
import 'package:frontend/features/map/presentation/map_screen.dart';
import 'package:frontend/features/profile/presentation/settings/change_email_form.dart';
import 'package:frontend/features/profile/presentation/settings/delete_account_form.dart';
import 'package:frontend/features/profile/presentation/settings/logout_form.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'core/storage/auth_storage.dart';
import 'features/auth/data/datasources/user_remote_ds.dart';
import 'features/auth/data/repositories/user_repository_impl.dart';
import 'features/auth/presentation/registration_successful.dart';
import 'features/auth/presentation/registration_ui.dart';
import 'features/posts/data/datasources/posts_remote_ds.dart';
import 'features/posts/data/post_publisher.dart';
import 'features/posts/data/repositories/posts_repository_impl.dart';
import 'features/posts/domain/repositories/posts_repository.dart';
import 'features/posts/presentation/post_creation_flow.dart';
import 'features/profile/presentation/profile_popup.dart';
import 'features/profile/presentation/settings/change_password_form.dart';

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
  final usersRepo = UserRepositoryImpl(UserRemoteDataSource(api));
  final postsRepo = PostsRepositoryImpl(PostsRemoteDataSource(api));
  final relationRepo = RelationRepositoryImpl(RelationsRemoteDataSource(api));

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(
    MyApp(
      userRepository: usersRepo,
      postsRepository: postsRepo,
      relationRepository: relationRepo,
      authStorage: authStorage,
      isLoggedIn: isLoggedIn,
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({
    super.key,
    required this.userRepository,
    required this.postsRepository,
    required this.relationRepository,
    required this.authStorage,
    required this.isLoggedIn,
  });

  final UserRepository userRepository;
  final PostsRepository postsRepository;
  final RelationRepository relationRepository;
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
      
      GoRoute(
        path: '/map',
        builder: (context, state) => MapScreen(
        postsRepository: postsRepository,
        authStorage: authStorage,
        relationRepository: relationRepository,
        postCreationFlow: PostCreationFlow(
        PostPublisher(postsRepository, authStorage),
        ),
      ),
    ),

      GoRoute(
        path: '/post/draw',
        builder: (context, state) => PaintScreen(
          backgroundLayers: state.extra as List<ImageProvider>? ?? const [],
          onImageCreated: (image) => context.pop(image),
        ),
      ),
      GoRoute(
        path: '/post/camera',
        builder: (context, _) =>
            CameraScreen(onPhotoCaptured: (path) async => context.pop(path)),
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
        name: '/profile',
        path: '/profile/:nickname',
        pageBuilder: (context, state) {
          final String? nickname = state.pathParameters['nickname'];
          final bool fromPostView =
              state.uri.queryParameters['fromPostView'] == 'true';
          return CustomTransitionPage(
            key: state.pageKey,
            opaque: false, // makes the map visible behind the screen
            // screen transition animation
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            child: ProfilePopup(
              relationRepository: relationRepository,
              userRepository: userRepository,
              authStorage: authStorage,
              nickname: nickname,
              showTopButtons: !fromPostView,
            ),
          );
        },
      ),
      GoRoute(
        path: '/friends',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            opaque: false, // makes the map visible behind the screen
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            child: FriendsPopup(
              relationRepository: relationRepository,
              userRepository: userRepository,
              authStorage: authStorage,
            ),
          );
        },
      ),
      GoRoute(
        path: '/logout',
        builder: (context, state) => LogoutForm(authStorage: authStorage),
      ),
      GoRoute(
        path: '/delete-account',
        builder: (context, state) =>
            DeleteAccountForm(authStorage, userRepository),
      ),
      GoRoute(
        path: '/change-email',
        builder: (context, state) =>
            ChangeEmailForm(authStorage, userRepository),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) =>
            ChangePasswordForm(authStorage, userRepository),
      ),
      GoRoute(
        path: '/email-changed',
        builder: (context, state) =>
            SuccessScreen('Your email was changed', 'Please login again'),
      ),
      GoRoute(
        path: '/password-changed',
        builder: (context, state) =>
            SuccessScreen('Your password was changed', 'Please login again'),
      ),
      // TODO: put other routes here!!!
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: router);
  }
}
