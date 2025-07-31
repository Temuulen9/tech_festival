import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecStorage {
  // Singleton instance
  static final SecStorage _instance = SecStorage._internal();

  // Private constructor for singleton
  SecStorage._internal();

  // Factory constructor returning the same instance
  factory SecStorage() {
    return _instance;
  }

  // FlutterSecureStorage instance
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Read method with error handling
  Future<String?> read({required String key}) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      return null;
    }
  }

  // Write method with error handling
  Future<bool> write({required String key, required String value}) async {
    try {
      await _storage.write(key: key, value: value);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete specific key method with error handling
  Future<bool> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete all keys method with error handling
  Future<bool> deleteAll() async {
    try {
      await _storage.deleteAll();
      return true;
    } catch (e) {
      return false;
    }
  }
}

// Centralized storage keys for easy management
class SecStorageKeys {
  static const accessToken = 'accessToken';
}
