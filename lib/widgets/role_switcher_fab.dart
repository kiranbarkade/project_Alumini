import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RoleSwitcherFab extends StatelessWidget {
  const RoleSwitcherFab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) return const SizedBox.shrink();

    return FloatingActionButton.small(
      heroTag: 'role_switcher_hero',
      backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
      onPressed: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.supervised_user_circle, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Developer Testing Tool',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'CareerBridge has no auth enabled per instructions. Switch users below to test different dashboards and permission views.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const Divider(height: 24),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: auth.availableUsers.length,
                        itemBuilder: (context, idx) {
                          final user = auth.availableUsers[idx];
                          final isSelected = user.id == auth.currentUser?.id;

                          IconData roleIcon;
                          Color roleColor;
                          switch (user.role) {
                            case 'admin':
                              roleIcon = Icons.admin_panel_settings;
                              roleColor = Colors.red;
                              break;
                            case 'alumni':
                              roleIcon = Icons.school;
                              roleColor = Colors.green;
                              break;
                            default:
                              roleIcon = Icons.person;
                              roleColor = Colors.blue;
                          }

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user.profileImage.isNotEmpty
                                  ? NetworkImage(user.profileImage)
                                  : null,
                              backgroundColor: roleColor.withOpacity(0.1),
                              child: user.profileImage.isEmpty
                                  ? Icon(roleIcon, color: roleColor)
                                  : null,
                            ),
                            title: Text(
                              user.name,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              '${user.role.toUpperCase()} • ${user.designation.isNotEmpty ? user.designation : user.branch}',
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, color: Colors.blue)
                                : null,
                            onTap: () {
                              auth.switchUser(user.id);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Switched session to ${user.name} (${user.role})'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
      child: const Icon(Icons.swap_horiz),
    );
  }
}
