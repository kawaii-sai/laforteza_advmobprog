import 'package:flutter/material.dart';

import '../services/user_services.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() =>
      _SignupScreenState();
}

class _SignupScreenState
    extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController =
      TextEditingController();

  final _lastNameController =
      TextEditingController();

  final _ageController =
      TextEditingController();

  final _contactController =
      TextEditingController();

  final _usernameController =
      TextEditingController();

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  final _confirmPasswordController =
      TextEditingController();

  final UserService _userService =
      UserService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _contactController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _userService.createAccount(
        email: _emailController.text.trim(),
        password:
            _passwordController.text,
        username:
            _usernameController.text.trim(),
        firstName:
            _firstNameController.text.trim(),
        lastName:
            _lastNameController.text.trim(),
        age: int.parse(
          _ageController.text.trim(),
        ),
        contactNo:
            _contactController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Account created successfully.',
          ),
        ),
      );

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

  String? _validateRequired(
    String? value,
    String fieldName,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return '$fieldName is required.';
    }

    return null;
  }

  String? _validateAge(String? value) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Age is required.';
    }

    final age = int.tryParse(
      value.trim(),
    );

    if (age == null) {
      return 'Please enter a valid age.';
    }

    if (age < 1 || age > 120) {
      return 'Please enter a valid age.';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Email address is required.';
    }

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(
      value.trim(),
    )) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null ||
        value.isEmpty) {
      return 'Password is required.';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    return null;
  }

  String? _validateConfirmPassword(
    String? value,
  ) {
    if (value == null ||
        value.isEmpty) {
      return 'Please confirm your password.';
    }

    if (value !=
        _passwordController.text) {
      return 'Passwords do not match.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Account',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding:
                const EdgeInsets.all(20),
            children: [
              const Icon(
                Icons.person_add,
                size: 70,
              ),

              const SizedBox(
                height: 16,
              ),

              const Text(
                'Create your account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              const Text(
                'Enter your information below to register.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              TextFormField(
                controller:
                    _firstNameController,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText: 'First Name',
                  prefixIcon:
                      Icon(Icons.person),
                  border:
                      OutlineInputBorder(),
                ),
                validator: (value) =>
                    _validateRequired(
                  value,
                  'First name',
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              TextFormField(
                controller:
                    _lastNameController,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText: 'Last Name',
                  prefixIcon:
                      Icon(Icons.person),
                  border:
                      OutlineInputBorder(),
                ),
                validator: (value) =>
                    _validateRequired(
                  value,
                  'Last name',
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              TextFormField(
                controller:
                    _ageController,
                keyboardType:
                    TextInputType.number,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText: 'Age',
                  prefixIcon:
                      Icon(Icons.cake),
                  border:
                      OutlineInputBorder(),
                ),
                validator:
                    _validateAge,
              ),

              const SizedBox(
                height: 15,
              ),

              TextFormField(
                controller:
                    _contactController,
                keyboardType:
                    TextInputType.phone,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Contact Number',
                  prefixIcon:
                      Icon(Icons.phone),
                  border:
                      OutlineInputBorder(),
                ),
                validator: (value) =>
                    _validateRequired(
                  value,
                  'Contact number',
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              TextFormField(
                controller:
                    _usernameController,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText: 'Username',
                  prefixIcon:
                      Icon(Icons.account_circle),
                  border:
                      OutlineInputBorder(),
                ),
                validator: (value) =>
                    _validateRequired(
                  value,
                  'Username',
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              TextFormField(
                controller:
                    _emailController,
                keyboardType:
                    TextInputType.emailAddress,
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

              const SizedBox(
                height: 15,
              ),

              TextFormField(
                controller:
                    _passwordController,
                obscureText:
                    _obscurePassword,
                textInputAction:
                    TextInputAction.next,
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
                          ? Icons
                              .visibility
                          : Icons
                              .visibility_off,
                    ),
                  ),
                ),
                validator:
                    _validatePassword,
              ),

              const SizedBox(
                height: 15,
              ),

              TextFormField(
                controller:
                    _confirmPasswordController,
                obscureText:
                    _obscureConfirmPassword,
                textInputAction:
                    TextInputAction.done,
                decoration:
                    InputDecoration(
                  labelText:
                      'Confirm Password',
                  prefixIcon:
                      const Icon(Icons.lock),
                  border:
                      const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword =
                            !_obscureConfirmPassword;
                      });
                    },
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons
                              .visibility
                          : Icons
                              .visibility_off,
                    ),
                  ),
                ),
                validator:
                    _validateConfirmPassword,
              ),

              const SizedBox(
                height: 25,
              ),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _createAccount,
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
                          'Create Account',
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
                        Navigator.pop(
                          context,
                        );
                      },
                child: const Text(
                  'Already have an account? Sign In',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}