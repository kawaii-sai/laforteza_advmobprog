import 'package:flutter/material.dart';

import '../services/login_type.dart';
import '../services/user_services.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() =>
      _SignInScreenState();
}

class _SignInScreenState
    extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  final _usernameController =
      TextEditingController();

  final UserService _userService =
      UserService();

  LoginType _loginType =
      LoginType.firebase;

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();

    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_loginType == LoginType.firebase) {
        await _userService.signIn(
          email:
              _emailController.text.trim(),
          password:
              _passwordController.text,
        );
      } else {
        await _userService.loginUser(
          username:
              _usernameController.text.trim(),
          password:
              _passwordController.text,
        );
      }

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _forgotPassword() async {
    if (_loginType != LoginType.firebase) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset is available for Firebase accounts only.',
          ),
        ),
      );
      return;
    }

    final emailController =
        TextEditingController(
      text: _emailController.text.trim(),
    );

    final email =
        await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Reset Password',
          ),
          content: TextField(
            controller: emailController,
            keyboardType:
                TextInputType.emailAddress,
            decoration:
                const InputDecoration(
              labelText: 'Email Address',
              prefixIcon:
                  Icon(Icons.email),
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
                  emailController.text
                      .trim(),
                );
              },
              child:
                  const Text('Send'),
            ),
          ],
        );
      },
    );

    emailController.dispose();

    if (email == null ||
        email.isEmpty) {
      return;
    }

    try {
      await _userService
          .sendPasswordResetEmail(
        email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset email sent. Check your inbox.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
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

  String? _validatePassword(
    String? value,
  ) {
    if (value == null ||
        value.isEmpty) {
      return 'Password is required.';
    }

    return null;
  }

  String? _validateEmail(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Email is required.';
    }

    return null;
  }

  String? _validateUsername(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Username is required.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isFirebase =
        _loginType == LoginType.firebase;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign In',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding:
                const EdgeInsets.all(20),
            children: [
              const SizedBox(
                height: 20,
              ),

              const Icon(
                Icons.lock_person,
                size: 75,
              ),

              const SizedBox(
                height: 15,
              ),

              const Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              const Text(
                'Sign in to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              DropdownButtonFormField<LoginType>(
                value: _loginType,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Authentication Type',
                  border:
                      OutlineInputBorder(),
                  prefixIcon:
                      Icon(Icons.security),
                ),
                items: const [
                  DropdownMenuItem(
                    value:
                        LoginType.firebase,
                    child: Text(
                      'Firebase',
                    ),
                  ),
                  DropdownMenuItem(
                    value:
                        LoginType.dummyJson,
                    child: Text(
                      'DummyJSON',
                    ),
                  ),
                ],
                onChanged: _isLoading
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _loginType =
                              value;
                          _emailController
                              .clear();
                          _usernameController
                              .clear();
                          _passwordController
                              .clear();
                        });
                      },
              ),

              const SizedBox(
                height: 20,
              ),

              if (isFirebase)
                TextFormField(
                  controller:
                      _emailController,
                  keyboardType:
                      TextInputType
                          .emailAddress,
                  textInputAction:
                      TextInputAction.next,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Email Address',
                    prefixIcon:
                        Icon(Icons.email),
                    border:
                        OutlineInputBorder(),
                  ),
                  validator:
                      _validateEmail,
                ),

              if (!isFirebase)
                TextFormField(
                  controller:
                      _usernameController,
                  textInputAction:
                      TextInputAction.next,
                  decoration:
                      const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(
                      Icons.person,
                    ),
                    border:
                        OutlineInputBorder(),
                  ),
                  validator:
                      _validateUsername,
                ),

              const SizedBox(
                height: 15,
              ),

              TextFormField(
                controller:
                    _passwordController,
                obscureText:
                    _obscurePassword,
                textInputAction:
                    TextInputAction.done,
                decoration:
                    InputDecoration(
                  labelText: 'Password',
                  prefixIcon:
                      const Icon(Icons.lock),
                  border:
                      const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword =
                            !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons
                              .visibility_off,
                    ),
                  ),
                ),
                validator:
                    _validatePassword,
                onFieldSubmitted:
                    (_) => _signIn(),
              ),

              if (isFirebase)
                Align(
                  alignment:
                      Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : _forgotPassword,
                    child: const Text(
                      'Forgot Password?',
                    ),
                  ),
                ),

              const SizedBox(
                height: 10,
              ),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _signIn,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.pushNamed(
                          context,
                          '/signup',
                        );
                      },
                child: const Text(
                  'Create a new account',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}