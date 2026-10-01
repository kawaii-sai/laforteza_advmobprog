import 'package:flutter/material.dart';

import '../services/user_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {
  final UserService _userService =
      UserService();

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(
      const Duration(seconds: 2),
    );

    final loggedIn =
        await _userService.isLoggedIn();

    if (!mounted) return;

    if (loggedIn) {
      Navigator.pushReplacementNamed(
        context,
        '/home',
      );
    } else {
      Navigator.pushReplacementNamed(
        context,
        '/signin',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/nu_icon.jpg',
              width: 130,
              height: 130,
            ),

            const SizedBox(
              height: 25,
            ),

            const Text(
              'E-Commerce App',
              style: TextStyle(
                fontSize: 26,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            const Text(
              'Welcome',
              style: TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}