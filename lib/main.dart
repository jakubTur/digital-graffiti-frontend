import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:frontend/features/friends/domain/repositories/relation_repository.dart';
import 'package:frontend/features/friends/presentation/friends_popup.dart';
import 'package:frontend/features/map/presentation/state/map_model.dart';
import 'package:frontend/features/map/presentation/map_screen.dart';
import 'package:frontend/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:frontend/features/notifications/data/services/push_notification_service.dart';
import 'package:frontend/features/profile/presentation/settings/change_email_form.dart';
import 'package:frontend/features/profile/presentation/settings/delete_account_form.dart';
import 'package:frontend/features/profile/presentation/settings/logout_form.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'features/auth/data/datasources/auth_storage.dart';
import 'features/auth/data/datasources/user_remote_ds.dart';
import 'features/auth/data/repositories/user_repository_impl.dart';
import 'features/auth/presentation/registration_successful.dart';
import 'features/auth/presentation/registration_ui.dart';
import 'features/posts/data/datasources/posts_remote_ds.dart';
import 'features/posts/domain/usecases/post_publisher.dart';
import 'features/posts/data/repositories/posts_repository_impl.dart';
import 'features/posts/domain/repositories/posts_repository.dart';
import 'features/posts/presentation/post_creation_flow.dart';
import 'features/profile/presentation/profile_popup.dart';
import 'features/profile/presentation/settings/change_password_form.dart';

void main() async {
  // App locked into vertical mode
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  const secureStorage = FlutterSecureStorage();
  final authStorage = AuthStorage(secureStorage);
  final api = ApiClient(
    tokenProvider: authStorage.readAccessToken,
    refreshTokenProvider: authStorage.readRefreshToken,
    updateTokens: authStorage.updateTokens,
  );
  final notificationsDataSource = NotificationsRemoteDataSource(api);
  final pushNotificationService = PushNotificationService(
    getAccessToken: authStorage.readAccessToken,
    registerDeviceToken: notificationsDataSource.registerDeviceToken,
  );
  try {
    await pushNotificationService.initialize();
  } catch (error, stackTrace) {
    debugPrint('Push notification service initialization error: $error');
    debugPrint('Stack trace: $stackTrace');
  }
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
      pushNotificationService: pushNotificationService,
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
    required this.pushNotificationService,
  });

  final UserRepository userRepository;
  final PostsRepository postsRepository;
  final RelationRepository relationRepository;
  final AuthStorage authStorage;
  final bool isLoggedIn;
  final PushNotificationService pushNotificationService;

  late final GoRouter router = GoRouter(
    initialLocation: isLoggedIn ? '/map' : '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => LoginUi(
          repo: userRepository,
          authStorage: authStorage,
          notificationService: pushNotificationService,
        ),
      ),
      ShellRoute(
        // gives access to MapModel to the child routes
        builder: (context, state, child) {
          return ChangeNotifierProvider(
            create: (_) => MapModel(
              postsRepository: postsRepository,
              authStorage: authStorage,
            ),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/map',
            builder: (context, state) => MapScreen(
              postsRepository: postsRepository,
              authStorage: authStorage,
              postCreationFlow: PostCreationFlow(
                PostPublisher(postsRepository, authStorage),
              ),
            ),
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
                  postsRepository: postsRepository,
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
        ],
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
