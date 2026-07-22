import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/auth/data/auth_providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/pending_screen.dart';
import '../../features/auth/presentation/suspended_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/match/presentation/create_match_screen.dart';
import '../../features/match/presentation/match_detail_screen.dart';
import '../../features/admin/presentation/admin_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../models/enums.dart';

// ---------------------------------------------------------------------------
// Route path constants
// ---------------------------------------------------------------------------

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const pending = '/pending';
  static const suspended = '/suspended';
  static const dashboard = '/dashboard';
  static const forgotPassword = '/forgot-password';
  static const matchCreate = '/match/create';
  static const matchDetail = '/match/:matchId';
  static const admin = '/admin';
  static const adminUsers = '/admin/users';
  static const adminLocations = '/admin/locations';
  static const profile = '/profile';
}

// ---------------------------------------------------------------------------
// RouterNotifier — watches authStateProvider and triggers GoRouter refresh
// whenever the Firebase Auth state changes.
// ---------------------------------------------------------------------------

class RouterNotifier extends AsyncNotifier<void> implements Listenable {
  VoidCallback? _routerListener;

  @override
  Future<void> build() async {
    // Watch the auth state stream. Every time it emits a new value (sign-in,
    // sign-out), this notifier rebuilds and notifies GoRouter to re-evaluate
    // the redirect guard.
    ref.watch(authStateProvider);

    // Notify GoRouter after the build completes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _routerListener?.call();
    });
  }

  // ---- Listenable interface ------------------------------------------------

  @override
  void addListener(VoidCallback listener) {
    _routerListener = listener;
  }

  @override
  void removeListener(VoidCallback listener) {
    if (_routerListener == listener) {
      _routerListener = null;
    }
  }
}

final routerNotifierProvider =
    AsyncNotifierProvider<RouterNotifier, void>(RouterNotifier.new);

// ---------------------------------------------------------------------------
// GoRouter provider
// ---------------------------------------------------------------------------

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider.notifier);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: notifier,
    redirect: (BuildContext context, GoRouterState state) async {
      // Read the current auth state synchronously from the provider cache.
      final authState = ref.read(authStateProvider);
      final User? user = authState.valueOrNull;
      final location = state.matchedLocation;

      // -----------------------------------------------------------------------
      // 1. Not authenticated → redirect to /login
      //    Allow /login and /register without authentication.
      // -----------------------------------------------------------------------
      final isAuthRoute =
          location == AppRoutes.login || location == AppRoutes.register || location == AppRoutes.forgotPassword;

      if (user == null) {
        // Still loading auth state — don't redirect yet.
        if (authState.isLoading) return null;
        return isAuthRoute ? null : AppRoutes.login;
      }

      // -----------------------------------------------------------------------
      // 2. Authenticated — check user status from Firestore via
      //    userStatusProvider (reads users/{uid} document).
      //    This replaces the previous custom-claims status check so that
      //    status changes in Firestore are reflected immediately without
      //    waiting for a token refresh.
      // -----------------------------------------------------------------------
      UserStatus userStatus;
      try {
        userStatus = await ref.read(userStatusProvider(user.uid).future);
      } catch (_) {
        // If we can't read the status (e.g. no network and no cache), fall
        // back to allowing the current route to avoid a redirect loop.
        return null;
      }

      // If the user is on an auth route but already authenticated, redirect
      // them to the appropriate destination.
      if (isAuthRoute) {
        if (userStatus == UserStatus.pending) return AppRoutes.pending;
        if (userStatus == UserStatus.suspended) return AppRoutes.suspended;
        return AppRoutes.dashboard;
      }

      // -----------------------------------------------------------------------
      // 3. Status-based guards for authenticated users.
      // -----------------------------------------------------------------------
      if (userStatus == UserStatus.pending) {
        return location == AppRoutes.pending ? null : AppRoutes.pending;
      }

      if (userStatus == UserStatus.suspended) {
        return location == AppRoutes.suspended ? null : AppRoutes.suspended;
      }

      // -----------------------------------------------------------------------
      // 4. Admin guard — routes under /admin require role == 'admin'.
      //    The admin role is still checked via Firebase custom claims because
      //    it is a security-sensitive attribute managed server-side.
      // -----------------------------------------------------------------------
      final isAdminRoute = location.startsWith('/admin');
      if (isAdminRoute) {
        final idTokenResult = await user.getIdTokenResult();
        final role = (idTokenResult.claims ?? {})['role'] as String?;
        if (role != 'admin') return AppRoutes.dashboard;
      }

      // No redirect needed.
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.pending,
        name: 'pending',
        builder: (context, state) => const PendingScreen(),
      ),
      GoRoute(
        path: AppRoutes.suspended,
        name: 'suspended',
        builder: (context, state) => const SuspendedScreen(),
      ),

      // Player routes
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.matchCreate,
        name: 'match-create',
        builder: (context, state) => const CreateMatchScreen(),
      ),
      GoRoute(
        path: AppRoutes.matchDetail,
        name: 'match-detail',
        builder: (context, state) {
          final matchId = state.pathParameters['matchId']!;
          return MatchDetailScreen(matchId: matchId);
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Admin routes
      GoRoute(
        path: AppRoutes.admin,
        name: 'admin',
        builder: (context, state) => const AdminScreen(),
        routes: [
          GoRoute(
            path: 'users',
            name: 'admin-users',
            builder: (context, state) => const AdminScreen(),
          ),
          GoRoute(
            path: 'locations',
            name: 'admin-locations',
            builder: (context, state) => const AdminScreen(),
          ),
        ],
      ),
    ],
  );
});
