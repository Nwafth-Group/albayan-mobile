// ============================================
// FILE: lib/utils/shared_pref_helper.dart
// ============================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../fatures/auth/data/models/user_model.dart';

class SharedPrefHelper {
  static const String _tokenKey    = 'auth_token';
  static const String _lngKey      = 'lng';
  static const String _userKey     = 'user_data';
  static const String _isLoggedIn  = 'is_logged_in';

  static late SharedPreferences _prefs;

  static void init(SharedPreferences prefs) {
    _prefs = prefs;
  }

  // ── Token ─────────────────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  // ── Language ──────────────────────────────────────────────────
  static Future<void> saveLng(String val) async {
    await _prefs.setString(_lngKey, val);
  }

  static Future<String?> getLng() async {
    return _prefs.getString(_lngKey);
  }

  // ── User ──────────────────────────────────────────────────────
  static Future<void> saveUser(UserModel user) async {
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
    await _prefs.setBool(_isLoggedIn, true);
  }

  static UserModel? getUser() {
    final data = _prefs.getString(_userKey);
    if (data == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ── Auth state ────────────────────────────────────────────────
  static bool isLoggedIn() {
    return _prefs.getBool(_isLoggedIn) ?? false;
  }

  // ── Clear ─────────────────────────────────────────────────────
  static Future<void> clearAll() async {
    await _prefs.clear();
  }

  static Future<void> logout() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
    await _prefs.setBool(_isLoggedIn, false);
  }
}