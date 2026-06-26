import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';

class MainShellLayout extends StatefulWidget {
  final Widget child;

  const MainShellLayout({super.key, required this.child});

  @override
  State<MainShellLayout> createState() => _MainShellLayoutState();
}

class _MainShellLayoutState extends State<MainShellLayout> {
  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final role = auth.currentUser?.role ?? 'student';

    if (role == 'alumni') {
      if (location == '/') return 0;
      if (location == '/requests') return 1;
      if (location == '/post-job') return 2;
      if (location == '/conversations') return 3;
      if (location == '/profile') return 4;
    } else {
      if (location == '/') return 0;
      if (location == '/directory') return 1;
      if (location == '/jobs') return 2;
      if (location == '/conversations') return 3;
      if (location == '/profile') return 4;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final role = auth.currentUser?.role ?? 'student';

    if (role == 'alumni') {
      switch (index) {
        case 0:
          context.go('/');
          break;
        case 1:
          context.go('/requests');
          break;
        case 2:
          context.go('/post-job');
          break;
        case 3:
          context.go('/conversations');
          break;
        case 4:
          context.go('/profile');
          break;
      }
    } else {
      switch (index) {
        case 0:
          context.go('/');
          break;
        case 1:
          context.go('/directory');
          break;
        case 2:
          context.go('/jobs');
          break;
        case 3:
          context.go('/conversations');
          break;
        case 4:
          context.go('/profile');
          break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch notifications on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null) {
        Provider.of<NotificationProvider>(context, listen: false).fetchNotifications(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedIndex = _getSelectedIndex(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final role = user?.role ?? 'student';

    List<BottomNavigationBarItem> navItems = [];
    if (role == 'alumni') {
      navItems = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.group_outlined),
          activeIcon: Icon(Icons.group),
          label: 'Students',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          activeIcon: Icon(Icons.add_circle),
          label: 'Post Job',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          activeIcon: Icon(Icons.chat_bubble),
          label: 'Messages',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else {
      navItems = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.school_outlined),
          activeIcon: Icon(Icons.school),
          label: 'Alumni',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.work_outline),
          activeIcon: Icon(Icons.work),
          label: 'Jobs',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          activeIcon: Icon(Icons.chat_bubble),
          label: 'Messages',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) => _onItemTapped(index, context),
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.colorScheme.surface,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          items: navItems,
        ),
      ),
    );
  }
}
