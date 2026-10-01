import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../providers/cart_provider.dart';
import 'users_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text(
            'Are you sure you want to sign out?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                context
                    .read<CartProvider>()
                    .clearCart();

                await FirebaseAuth.instance.signOut();

                if (!context.mounted) return;

                Navigator.pop(dialogContext);

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/signin',
                  (route) => false,
                );
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider =
        context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Appearance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Card(
            child: SwitchListTile(
              secondary: Icon(
                themeProvider.isDark
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              title: const Text(
                'Dark Mode',
              ),
              subtitle: Text(
                themeProvider.isDark
                    ? 'Dark theme is enabled'
                    : 'Light theme is enabled',
              ),
              value: themeProvider.isDark,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.person_outline,
                  ),
                  title: const Text(
                    'Profile',
                  ),
                  subtitle: const Text(
                    'View your account information',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/profile',
                    );
                  },
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(
                    Icons.shopping_cart_outlined,
                  ),
                  title: const Text(
                    'My Cart',
                  ),
                  subtitle: const Text(
                    'View your current cart',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/cart',
                    );
                  },
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(
                    Icons.message_outlined,
                  ),
                  title: const Text(
                    'Messages',
                  ),
                  subtitle: const Text(
                    'Message other users',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const UsersScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Account Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.logout,
              ),
              title: const Text(
                'Sign Out',
              ),
              subtitle: const Text(
                'Sign out of your account',
              ),
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}