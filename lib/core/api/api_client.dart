import 'package:dio/dio.dart';

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
}
