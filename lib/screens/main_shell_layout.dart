import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/role_switcher_fab.dart';

class MainShellLayout extends StatefulWidget {
  final Widget child;

  const MainShellLayout({super.key, required this.child});

  @override
  State<MainShellLayout> createState() => _MainShellLayoutState();
}

class _MainShellLayoutState extends State<MainShellLayout> {
  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == '/') return 0;
    if (location == '/directory') return 1;
    if (location == '/feed') return 2;
    if (location == '/jobs') return 3;
    if (location == '/dashboard') return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/directory');
        break;
      case 2:
        context.go('/feed');
        break;
      case 3:
        context.go('/jobs');
        break;
      case 4:
        context.go('/dashboard');
        break;
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
    final unreadCount = notificationProvider.unreadCount;

    return Scaffold(
      body: widget.child,
      floatingActionButton: const RoleSwitcherFab(),
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
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined),
              activeIcon: Icon(Icons.people_alt),
              label: 'Alumni',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.dynamic_feed_outlined),
              activeIcon: Icon(Icons.dynamic_feed),
              label: 'Feed',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.work_outline),
              activeIcon: Icon(Icons.work),
              label: 'Jobs',
            ),
            BottomNavigationBarItem(
              icon: Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  String label = 'Profile';
                  IconData icon = Icons.person_outline;
                  IconData activeIcon = Icons.person;

                  if (auth.currentUser != null) {
                    if (auth.currentUser!.role == 'admin') {
                      icon = Icons.admin_panel_settings_outlined;
                      activeIcon = Icons.admin_panel_settings;
                    } else if (auth.currentUser!.role == 'alumni') {
                      icon = Icons.dashboard_customize_outlined;
                      activeIcon = Icons.dashboard_customize;
                    }
                  }
                  return Icon(selectedIndex == 4 ? activeIcon : icon);
                },
              ),
              label: 'Dashboard',
            ),
          ],
        ),
      ),
    );
  }
}
