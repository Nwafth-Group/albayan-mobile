// ============================================
// FILE: lib/utils/api_client.dart
// ============================================

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:developer' as developer;

import '../fatures/auth/screens/login_screen.dart';
import '../utils/constants.dart';
import '../utils/shared_pref_helper.dart';
import 'app_navigator.dart';
import 'google_auth_helper.dart';
import 'helpers.dart';

class ApiService {
  late final Dio _dio;
  Dio get dio => _dio;

  /// Guards against every in-flight request's 401 triggering its own
  /// logout — several can fail at once, but only the first should act.
  static bool _loggingOut = false;

  /// The token is stale/invalid: clear the session fully (local storage +
  /// Google sign-in) and send the user back to the login screen, the same
  /// way a manual "Logout" from Settings does.
  static Future<void> _forceLogout() async {
    if (_loggingOut || !SharedPrefHelper.isLoggedIn()) return;
    _loggingOut = true;
    developer.log('🚪 session expired — logging out', name: 'API');
    try {
      await SharedPrefHelper.logout();
      await GoogleAuthHelper.signOut();
      Helpers.showError(AppStrings.sessionExpired.tr());
      AppNavigator.pushAndRemoveUntil(const LoginScreen());
    } finally {
      _loggingOut = false;
    }
  }

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Read per request (not baked into BaseOptions) so a language
          // change applies to services that already exist.
          options.headers['Accept-Language'] = lang;


          // ── Inject token from SharedPrefs (async, safe) ──────
          final token = await SharedPrefHelper.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          developer.log('📤 REQUEST', name: 'API');
          developer.log('URL: ${options.baseUrl}${options.path}', name: 'API');
          developer.log('Method: ${options.method}', name: 'API');
          developer.log('Accept-Language: $lang', name: 'API');
          if (options.queryParameters.isNotEmpty) {
            developer.log('Params: ${options.queryParameters}', name: 'API');
          }
          if (options.data != null) {
            developer.log('Body: ${options.data}', name: 'API');
          }
          developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

          return handler.next(options);
        },
        onResponse: (response, handler) {
          developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          developer.log('📥 RESPONSE', name: 'API');
          developer.log(
              'URL: ${response.requestOptions.baseUrl}${response.requestOptions.path}',
              name: 'API');
          developer.log('Status: ${response.statusCode}', name: 'API');
          developer.log('Data: ${response.data}', name: 'API');
          developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          return handler.next(response);
        },
        onError: (error, handler) {
          developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          developer.log('❌ ERROR', name: 'API');
          developer.log(
              'URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}',
              name: 'API');
          developer.log('Status: ${error.response?.statusCode}', name: 'API');
          developer.log('Message: ${error.message}', name: 'API');
          if (error.response?.data != null) {
            developer.log('Response: ${error.response?.data}', name: 'API');
          }
          developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

          if (error.response?.statusCode == 401) {
            developer.log('🚪 401 Unauthorized — forcing logout', name: 'API');
            _forceLogout();
          }
          return handler.next(error);
        },
      ),
    );
  }

  // ── GET ───────────────────────────────────────────────────────
  Future<Map<String, dynamic>> get(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? data,
      }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── POST ──────────────────────────────────────────────────────
  Future<Map<String, dynamic>> post(
      String endpoint, {
        dynamic data,
      }) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final message = _handleError(e);
      Helpers.showError(message);
      throw message;
    }
  }

  // ── PUT ───────────────────────────────────────────────────────
  Future<Map<String, dynamic>> put(
      String endpoint, {
        dynamic data,
      }) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final message = _handleError(e);
      Helpers.showError(message);
      throw message;
    }
  }

  // ── PATCH ─────────────────────────────────────────────────────
  Future<Map<String, dynamic>> patch(
      String endpoint, {
        dynamic data,
      }) async {
    try {
      final response = await _dio.patch(endpoint, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── DELETE ────────────────────────────────────────────────────
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── MULTIPART POST ────────────────────────────────────────────
  Future<Response> postMultipart(
      String endpoint, {
        required FormData data,
        ProgressCallback? onSendProgress,
      }) async {
    try {
      return await _dio.post(
        endpoint,
        data: data,
        onSendProgress: onSendProgress,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Error handler ─────────────────────────────────────────────
  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;

      // Show field-level validation errors from `params`
      if (data is Map && data['params'] != null) {
        (data['params'] as Map<String, dynamic>).forEach((_, val) {
          Helpers.showError(val.toString());
        });
      }

      // The backend's `message` is already localized (Accept-Language).
      // Dio's own `error.message` is a technical English paragraph, so it's
      // never shown — a translated generic message is used instead.
      final message = data is Map ? data['message']?.toString() : null;
      return (message != null && message.trim().isNotEmpty)
          ? message
          : AppStrings.somethingWentWrong.tr();
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return AppStrings.errorConnectionTimeout.tr();
      case DioExceptionType.receiveTimeout:
        return AppStrings.errorServerTimeout.tr();
      case DioExceptionType.connectionError:
        return AppStrings.errorNoInternet.tr();
      default:
        return AppStrings.errorUnexpected.tr();
    }
  }
}