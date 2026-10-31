import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/calculator/calculator_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/dashboard/shell_scaffold.dart';
import '../features/help/help_screen.dart';
import '../features/offices/offices_screen.dart';
import '../features/onboarding/language_screen.dart';
import '../features/onboarding/location_screen.dart';
import '../features/profile/legal_screens.dart';
import '../features/profile/profile_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/webview/web_screen.dart';
import 'providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final s = ref.read(settingsProvider);
      final path = state.uri.path;
      const open = ['/splash', '/language', '/location'];
      if (open.contains(path)) return null;
      if (s.lang == null) return '/language?first=1';
      if (!s.hasLocation) return '/location?first=1';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(
          path: '/language',
          builder: (_, st) => LanguageScreen(first: st.uri.queryParameters['first'] == '1')),
      GoRoute(
          path: '/location',
          builder: (_, st) => LocationScreen(first: st.uri.queryParameters['first'] == '1')),
      GoRoute(path: '/web', builder: (_, st) => WebScreen(args: st.extra as WebArgs)),
      GoRoute(path: '/help', builder: (_, __) => const HelpScreen()),
      GoRoute(path: '/privacy', builder: (_, __) => const LegalScreen(kind: LegalKind.privacy)),
      GoRoute(path: '/terms', builder: (_, __) => const LegalScreen(kind: LegalKind.terms)),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => ShellScaffold(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, __) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/calculator', builder: (_, __) => const CalculatorScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/offices', builder: (_, __) => const OfficesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          ]),
        ],
      ),
    ],
  );
});
