// ignore_for_file: unused_import
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusion/Screens/community_screen.dart';
import 'package:fusion/Screens/home_screen.dart';
import 'package:fusion/Screens/login_screen.dart';
import 'package:fusion/Screens/nft_screen.dart';
import 'package:fusion/Screens/portfolio_screen.dart';
import 'package:fusion/Screens/signup_screen.dart';
import 'package:fusion/Screens/swap_screen.dart';
import 'package:fusion/Screens/token_profiles_screen.dart';
import 'package:fusion/firebase_options.dart';
import 'package:fusion/services/auth/auth_notifier.dart';
import 'package:fusion/shell_navigation.dart';
import 'package:fusion/theme.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.watch(authNotifierProvider);

    final router = GoRouter(
      initialLocation: '/home',
      refreshListenable: authNotifier,
      redirect: (BuildContext context, GoRouterState state) {
        final bool loggedIn = authNotifier.isLoggedIn;
        final String location = state.uri.toString(); // Current location

        final bool isPublicRoute =
            location == '/login' || location == '/signup';

        // Redirect logic:
        // If user is not logged in and trying to access a protected route
        if (!loggedIn && !isPublicRoute) {
          return '/login'; // Redirect to login
        }
        // If user is logged in and trying to access login/signup
        if (loggedIn && isPublicRoute) {
          return '/home'; // Redirect to home
        }
        // No redirection needed
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpScreen(),
        ),
        ShellRoute(
          navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'shell'),
          builder: (context, state, child) {
            return ShellNavigation(child: child);
          },
          routes: [
            GoRoute(
                path: '/home', builder: (context, state) => const HomeScreen()),
            GoRoute(
                path: '/exchange',
                builder: (context, state) => const SwapCalculatorScreen()),
            GoRoute(
                path: '/tokens',
                builder: (context, state) => const CryptoListingsScreen()),
            GoRoute(
                path: '/Portfolio',
                builder: (context, state) => const PortfolioPage()),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Page not found: ${state.error}')),
      ),
    );

    return MaterialApp.router(
      routerConfig: router,
      theme: darkNightTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
