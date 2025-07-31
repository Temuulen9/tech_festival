import 'package:dio/dio.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:tech_festival/core/utils/secure_storage.dart';
import 'package:tech_festival/main.dart';
import 'package:tech_festival/screens/auth/login_page.dart';

const bool isTest = true;

class Api {
  /// Singleton instance
  static final Api _singleton = Api._internal();

  /// Factory constructor to return the singleton instance
  factory Api() => _singleton;

  /// Private named constructor
  Api._internal();

  /// Dio Client instance (statically accessible)
  static late Dio _client;

  /// Getter to access the Dio client instance
  static Dio get client {
    if (!_isInitialized) {
      throw Exception('Api client is not initialized. Call Api.init() first.');
    }
    return _client;
  }

  /// Internal flag to track if Dio is initialized
  static bool _isInitialized = false;

  /// Initialize Dio instance
  Future<void> init() async {
    if (!_isInitialized) {
      try {
        _client = Dio(_getBaseOptions());
        _addInterceptors();

        _isInitialized = true;
      } catch (e) {
        rethrow;
      }
    }
  }

  /// Base options for Dio (can be expanded later if needed)
  BaseOptions _getBaseOptions() {
    return BaseOptions(
      baseUrl: 'http://192.168.0.136:8080/mcs-festival/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    );
  }

  /// Add interceptors to Dio instance
  void _addInterceptors() {
    if (isTest) {
      _client.interceptors
          .add(LogInterceptor(requestBody: true, responseBody: true));
    }
    _client.interceptors.add(AuthInterceptor());
  }
}

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Token

    final accessToken =
        await SecStorage().read(key: SecStorageKeys.accessToken);

    if (accessToken?.isNotEmpty == true && accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      SecStorage().delete(key: SecStorageKeys.accessToken);
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }

    super.onError(err, handler);
  }
}
