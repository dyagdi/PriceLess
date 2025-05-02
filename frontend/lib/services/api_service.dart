import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/constants/constants_url.dart';

class ApiService {
  static const String baseUrl = 'https://priceless.onrender.com/api';
  static const String tokenKey = 'auth_token';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  static Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await removeToken();
      }
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  static Future<bool> deleteAccount() async {
    try {
      final token = await getToken();
      if (token == null) {
        print('No token found for account deletion');
        return false;
      }

      print('Attempting to delete account with token: $token');
      final response = await http.delete(
        Uri.parse('$baseUrl/delete-account/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      print('Delete account response status: ${response.statusCode}');
      print('Delete account response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Account deletion successful, removing token');
        await removeToken(); 
        return true;
      } else {
        print('Delete account failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deleting account: $e');
      print('Error type: ${e.runtimeType}');
      if (e is http.ClientException) {
        print('HTTP Client Exception: ${e.message}');
      }
      return false;
    }
  }

  static Future<void> changePassword(String newPassword) async {
    final token = await getToken();
    if (token == null) return;

    final response = await http.post(
      Uri.parse('${baseUrl}/users/change-password/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'new_password': newPassword}),
    );

    if (response.statusCode != 200) {
      print('Error changing password: ${response.body}');
    }
  }
} 