import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/alumni_directory_screen.dart';
import '../screens/alumni_profile_screen.dart';
import '../screens/job_board_screen.dart';
import '../screens/job_details_screen.dart';
import '../screens/community_feed_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/student_profile_screen.dart';
import '../screens/alumni_dashboard_screen.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/main_shell_layout.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/conversations_screen.dart';
import '../screens/chat_screen.dart';

final routerProvider = Provider<GoRouter>(
  create: (context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final loggedIn = authProvider.currentUser != null;
        final goingToLogin = state.matchedLocation == '/login';
        final goingToRegister = state.matchedLocation == '/register';
        final goingToSplash = state.matchedLocation == '/splash';

        if (goingToSplash) return null;

        if (!loggedIn && !goingToLogin && !goingToRegister) {
          return '/login';
        }
        if (loggedIn && (goingToLogin || goingToRegister)) {
          return '/';
        }
        return null;
      },
      routes: [
        // Splash route
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // Auth routes
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),

        // Main Application shell (keeps bottom navigation visible)
        ShellRoute(
          builder: (context, state, child) {
            return MainShellLayout(child: child);
          },
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/directory',
              builder: (context, state) => const AlumniDirectoryScreen(),
            ),
            GoRoute(
              path: '/feed',
              builder: (context, state) => const CommunityFeedScreen(),
            ),
            GoRoute(
              path: '/jobs',
              builder: (context, state) => const JobBoardScreen(),
            ),
            GoRoute(
              path: '/dashboard',
              builder: (context, state) {
                // Dynamically route based on user role
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final role = auth.currentUser?.role ?? 'student';

                if (role == 'admin') {
                  return const AdminDashboardScreen();
                } else if (role == 'alumni') {
                  return const AlumniDashboardScreen();
                } else {
                  return const StudentProfileScreen();
                }
              },
            ),
          ],
        ),

        // Detail pages (no bottom navigation bar shown)
        GoRoute(
          path: '/alumni/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return AlumniProfileScreen(userId: id);
          },
        ),
        GoRoute(
          path: '/jobs/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return JobDetailsScreen(jobId: id);
          },
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/conversations',
          builder: (context, state) => const ConversationsScreen(),
        ),
        GoRoute(
          path: '/chat/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ChatScreen(otherUserId: id);
          },
        ),
      ],
    );
  },
);
