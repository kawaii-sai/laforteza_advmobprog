import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/login_type.dart';
import '../services/user_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  final UserService _userService =
      UserService();

  User? _user;
  LoginType _loginType =
      LoginType.firebase;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final loginType =
          await _userService.getLoginType();

      final user =
          await _userService.getUserData();

      if (!mounted) return;

      setState(() {
        _loginType = loginType;
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _updateUsername() async {
    if (_loginType != LoginType.firebase) {
      _showMessage(
        'Username updates are currently available for Firebase accounts only.',
      );
      return;
    }

    final controller =
        TextEditingController(
      text: _user?.username ?? '',
    );

    final newUsername =
        await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Update Username',
          ),
          content: TextField(
            controller: controller,
            decoration:
                const InputDecoration(
              labelText: 'Username',
              border:
                  OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child:
                  const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  controller.text,
                );
              },
              child:
                  const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (newUsername == null ||
        newUsername.trim().isEmpty) {
      return;
    }

    try {
      await _userService
          .updateUsername(
        newUsername,
      );

      await _loadProfile();

      if (!mounted) return;

      _showMessage(
        'Username updated successfully.',
      );
    } catch (e) {
      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  Future<void> _changePassword() async {
    if (_loginType != LoginType.firebase) {
      _showMessage(
        'Password changes are currently available for Firebase accounts only.',
      );
      return;
    }

    final currentPasswordController =
        TextEditingController();

    final newPasswordController =
        TextEditingController();

    final confirmPasswordController =
        TextEditingController();

    final result =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Change Password',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                TextField(
                  controller:
                      currentPasswordController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Current Password',
                    border:
                        OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                TextField(
                  controller:
                      newPasswordController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'New Password',
                    border:
                        OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                TextField(
                  controller:
                      confirmPasswordController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Confirm New Password',
                    border:
                        OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                false,
              ),
              child:
                  const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newPasswordController
                        .text !=
                    confirmPasswordController
                        .text) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'New passwords do not match.',
                      ),
                    ),
                  );
                  return;
                }

                try {
                  await _userService
                      .resetPasswordFromCurrentPassword(
                    currentPassword:
                        currentPasswordController
                            .text,
                    newPassword:
                        newPasswordController
                            .text,
                  );

                  if (!context.mounted) {
                    return;
                  }

                  Navigator.pop(
                    context,
                    true,
                  );
                } catch (e) {
                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString()
                            .replaceFirst(
                          'Exception: ',
                          '',
                        ),
                      ),
                    ),
                  );
                }
              },
              child:
                  const Text('Update'),
            ),
          ],
        );
      },
    );

    currentPasswordController
        .dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    if (result == true && mounted) {
      _showMessage(
        'Password updated successfully.',
      );
    }
  }

  Future<void> _deleteAccount() async {
    if (_loginType != LoginType.firebase) {
      _showMessage(
        'Account deletion is currently available for Firebase accounts only.',
      );
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Account',
          ),
          content: const Text(
            'Are you sure you want to delete your Firebase account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                false,
              ),
              child:
                  const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                true,
              ),
              child:
                  const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _userService.deleteAccount();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/signin',
        (route) => false,
      );
    } catch (e) {
      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  Future<void> _logout() async {
    await _userService.signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/signin',
      (route) => false,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  String _getLoginTypeName() {
    switch (_loginType) {
      case LoginType.firebase:
        return 'Firebase Authentication';

      case LoginType.dummyJson:
        return 'DummyJSON Authentication';

      case LoginType.guest:
        return 'Guest';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Profile',
        ),
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : _user == null
              ? const Center(
                  child: Text(
                    'No user information found.',
                  ),
                )
              : RefreshIndicator(
                  onRefresh:
                      _loadProfile,
                  child: ListView(
                    padding:
                        const EdgeInsets.all(
                      16,
                    ),
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 45,
                          backgroundImage:
                              _user!.image
                                      .isNotEmpty
                                  ? NetworkImage(
                                      _user!.image,
                                    )
                                  : null,
                          child: _user!.image
                                  .isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 45,
                                )
                              : null,
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      Center(
                        child: Text(
                          '${_user!.firstName} ${_user!.lastName}'
                              .trim()
                              .isEmpty
                              ? _user!.username
                              : '${_user!.firstName} ${_user!.lastName}',
                          style:
                              const TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Center(
                        child: Text(
                          _user!.email,
                          style:
                              const TextStyle(
                            color:
                                Colors.grey,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons
                                .verified_user,
                          ),
                          title: const Text(
                            'Login Type',
                          ),
                          subtitle: Text(
                            _getLoginTypeName(),
                          ),
                        ),
                      ),

                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.person,
                          ),
                          title: const Text(
                            'Username',
                          ),
                          subtitle: Text(
                            _user!.username
                                    .isEmpty
                                ? 'Not provided'
                                : _user!.username,
                          ),
                          trailing:
                              _loginType ==
                                      LoginType
                                          .firebase
                                  ? const Icon(
                                      Icons
                                          .edit,
                                    )
                                  : null,
                          onTap:
                              _loginType ==
                                      LoginType
                                          .firebase
                                  ? _updateUsername
                                  : null,
                        ),
                      ),

                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.badge,
                          ),
                          title: const Text(
                            'Full Name',
                          ),
                          subtitle: Text(
                            '${_user!.firstName} ${_user!.lastName}'
                                .trim()
                                .isEmpty
                                ? 'Not provided'
                                : '${_user!.firstName} ${_user!.lastName}',
                          ),
                        ),
                      ),

                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.cake,
                          ),
                          title: const Text(
                            'Age',
                          ),
                          subtitle: Text(
                            _user!.age > 0
                                ? '${_user!.age}'
                                : 'Not provided',
                          ),
                        ),
                      ),

                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.phone,
                          ),
                          title: const Text(
                            'Contact Number',
                          ),
                          subtitle: Text(
                            _user!.contactNo
                                    .isEmpty
                                ? 'Not provided'
                                : _user!.contactNo,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      if (_loginType ==
                          LoginType.firebase)
                        Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons
                                  .lock_reset,
                            ),
                            title: const Text(
                              'Change Password',
                            ),
                            subtitle:
                                const Text(
                              'Update your Firebase password',
                            ),
                            onTap:
                                _changePassword,
                          ),
                        ),

                      if (_loginType ==
                          LoginType.firebase)
                        Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.delete_forever,
                            ),
                            title: const Text(
                              'Delete Account',
                            ),
                            subtitle:
                                const Text(
                              'Permanently delete your account',
                            ),
                            onTap:
                                _deleteAccount,
                          ),
                        ),

                      const SizedBox(
                        height: 20,
                      ),

                      SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(
                            Icons.logout,
                          ),
                          label: const Text(
                            'Logout',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}