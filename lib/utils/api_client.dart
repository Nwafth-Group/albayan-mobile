// ============================================
// FILE: lib/utils/api_client.dart
// ============================================

import 'package:dio/dio.dart';
import 'dart:developer' as developer;

import '../utils/constants.dart';
import '../utils/shared_pref_helper.dart';
import 'helpers.dart';

class ApiService {
  late final Dio _dio;
  Dio get dio => _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Language': lng,
      },
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // ── Inject token from SharedPrefs (async, safe) ──────
          final token = await SharedPrefHelper.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          developer.log('📤 REQUEST', name: 'API');
          developer.log('URL: ${options.baseUrl}${options.path}', name: 'API');
          developer.log('Method: ${options.method}', name: 'API');
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
            developer.log('🚪 401 Unauthorized', name: 'API');
            // TODO: AppNavigator.pushAndRemoveUntil(const LoginScreen());
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

      return data is Map
          ? (data['message'] ?? error.message ?? 'An error occurred').toString()
          : (error.message ?? 'An error occurred');
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.receiveTimeout:
        return 'Server took too long to respond.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      default:
        return error.message ?? 'An unexpected error occurred.';
    }
  }
}