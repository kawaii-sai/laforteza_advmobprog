import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://dummyjson.com';

  static const String userKey = 'loggedInUser';
  static const String accessTokenKey = 'accessToken';
  static const String refreshTokenKey = 'refreshToken';

  // Login using DummyJSON authentication
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 60,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        userKey,
        jsonEncode(data),
      );

      if (data['accessToken'] != null) {
        await prefs.setString(
          accessTokenKey,
          data['accessToken'],
        );
      }

      if (data['refreshToken'] != null) {
        await prefs.setString(
          refreshTokenKey,
          data['refreshToken'],
        );
      }

      return data;
    }

    throw Exception(
      data['message'] ?? 'Login failed. Please check your credentials.',
    );
  }

  // Check whether a user is currently logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    final user = prefs.getString(userKey);
    final token = prefs.getString(accessTokenKey);

    return user != null && token != null;
  }

  // Get the saved user
  static Future<Map<String, dynamic>?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();

    final userData = prefs.getString(userKey);

    if (userData == null) {
      return null;
    }

    try {
      return jsonDecode(userData) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Get saved access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(accessTokenKey);
  }

  // Sign out and remove saved login data
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(userKey);
    await prefs.remove(accessTokenKey);
    await prefs.remove(refreshTokenKey);
  }
}