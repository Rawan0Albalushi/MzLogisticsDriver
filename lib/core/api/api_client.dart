import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/token_storage.dart';
import '../config/app_config.dart';
import 'api_envelope.dart';
import 'api_exception.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      sendTimeout: AppConfig.connectTimeout,
      headers: const {
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await ref.read(tokenStorageProvider).read();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<ApiEnvelope<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(dynamic raw) parse,
  }) {
    return _send(
      () => _dio.get<Map<String, dynamic>>(path, queryParameters: query),
      parse,
    );
  }

  Future<ApiEnvelope<T>> post<T>(
    String path, {
    Object? data,
    required T Function(dynamic raw) parse,
  }) {
    return _send(
      () => _dio.post<Map<String, dynamic>>(path, data: data),
      parse,
    );
  }

  Future<ApiEnvelope<T>> patch<T>(
    String path, {
    Object? data,
    required T Function(dynamic raw) parse,
  }) {
    return _send(
      () => _dio.patch<Map<String, dynamic>>(path, data: data),
      parse,
    );
  }

  Future<Uint8List> getBytes(String path) async {
    try {
      final response = await _dio.get<List<int>>(
        path,
        options: Options(
          responseType: ResponseType.bytes,
          headers: const {'Accept': '*/*'},
        ),
      );
      final data = response.data;
      if (data == null || data.isEmpty) {
        throw const ApiException(message: 'request_failed');
      }
      return Uint8List.fromList(data);
    } on DioException catch (error) {
      throw _mapDio(error);
    }
  }

  Future<ApiEnvelope<T>> _send<T>(
    Future<Response<Map<String, dynamic>>> Function() request,
    T Function(dynamic raw) parse,
  ) async {
    try {
      final response = await request();
      final body = response.data;
      if (body == null) {
        throw const ApiException(message: 'Empty response.');
      }
      return ApiEnvelope.fromJson(body, parse);
    } on DioException catch (error) {
      throw _mapDio(error);
    }
  }

  ApiException _mapDio(DioException error) {
    final type = error.type;
    final offline = type == DioExceptionType.connectionError ||
        type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.sendTimeout ||
        type == DioExceptionType.receiveTimeout ||
        error.error?.toString().contains('SocketException') == true;

    if (offline) {
      return const ApiException(
        message: 'offline',
        isOffline: true,
      );
    }

    final data = error.response?.data;
    var message = 'request_failed';
    var fieldErrors = <String, List<String>>{};

    if (data is Map<String, dynamic>) {
      message = (data['message'] ?? message).toString();
      final errors = data['errors'];
      if (errors is Map) {
        fieldErrors = errors.map((key, value) {
          if (value is List) {
            return MapEntry(
              key.toString(),
              value.map((item) => item.toString()).toList(),
            );
          }
          return MapEntry(key.toString(), [value.toString()]);
        });
      }
    }

    return ApiException(
      message: message,
      statusCode: error.response?.statusCode,
      fieldErrors: fieldErrors,
    );
  }
}
