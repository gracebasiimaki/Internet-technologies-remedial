import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static String get _baseUrl {
    if (kIsWeb) return ApiConfig.webBaseUrl;
    return ApiConfig.baseUrl;
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // Auth
  static Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/register'),
      headers: await _headers(auth: false),
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Registration failed: ${response.body}');
  }

  static Future<Map<String, dynamic>> login(String emailOrUsername, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: await _headers(auth: false),
      body: jsonEncode({
        'emailOrUsername': emailOrUsername,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Login failed: ${response.body}');
  }

  // Profile
  static Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/users/me'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load profile');
  }

  // Mood
  static Future<Map<String, dynamic>> createMoodEntry(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/mood'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to create mood entry');
  }

  static Future<List<dynamic>> getMoodEntries() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/mood'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load mood entries');
  }

  // Chat
  static Future<Map<String, dynamic>> sendMessage(String message, String? sessionId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/chat'),
      headers: await _headers(),
      body: jsonEncode({
        'message': message,
        'sessionId': sessionId,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to send message');
  }

  // Quotes
  static Future<Map<String, dynamic>?> getDailyQuote() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/quotes/daily'),
      headers: await _headers(auth: false),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    if (response.statusCode == 204) return null;
    throw Exception('Failed to load quote');
  }

  // Journal
  static Future<Map<String, dynamic>> createJournalEntry(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/journal'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to create journal entry');
  }

  static Future<List<dynamic>> getJournalEntries() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/journal'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load journal entries');
  }

  // Gems
  static Future<Map<String, dynamic>?> getGemBalance() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/gems/balance'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    if (response.statusCode == 204) return null;
    throw Exception('Failed to load gem balance');
  }

  // Breathing
  static Future<void> logBreathingSession(Map<String, dynamic> data) async {
    await http.post(
      Uri.parse('$_baseUrl/api/breathing'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
  }
}
