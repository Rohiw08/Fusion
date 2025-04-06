import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
  runApp(
    // 1. Wrap with ProviderScope
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// Make MyApp a ConsumerWidget to access ref
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. Get the AuthNotifier for GoRouter's refreshListenable and redirect
    final authNotifier = ref.watch(authNotifierProvider);

    // 3. Configure GoRouter with redirect and refreshListenable
    final router = GoRouter(
      initialLocation: '/home', // Initial location attempt
      refreshListenable: authNotifier, // Listen to auth changes for redirection
      redirect: (BuildContext context, GoRouterState state) {
        final bool loggedIn = authNotifier.isLoggedIn;
        final String location = state.uri.toString(); // Current location

        // Define public routes
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
        // Add Login and Signup routes (outside the shell)
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpScreen(),
        ),
        // Main application shell
        ShellRoute(
          // Using a GlobalKey for the shell's navigator is good practice
          navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'shell'),
          builder: (context, state, child) {
            // ShellNavigation now wraps the child screen
            return ShellNavigation(child: child);
          },
          routes: [
            // Routes accessible within the shell (protected by redirect)
            GoRoute(
                path: '/home', builder: (context, state) => const HomeScreen()),
            GoRoute(
                path: '/exchange',
                builder: (context, state) => const SwapCalculatorScreen()),
            // GoRoute(
            //     path: '/nft',
            //     builder: (context, state) => const TokenProfilesScreen()),
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

    // 4. Use MaterialApp.router
    return MaterialApp.router(
      routerConfig: router, // Use the configured router
      theme: darkNightTheme, // Apply your theme
      debugShowCheckedModeBanner: false,
    );
  }
}
