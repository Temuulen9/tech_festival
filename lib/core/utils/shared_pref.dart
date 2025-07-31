import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static late SharedPreferences _instance;

  static Future<void> init() async {
    _instance = await SharedPreferences.getInstance();
  }

  static SharedPreferences get instance {
    return _instance;
  }

  /// User role
  static Future<void> setRoleCode({
    String? role,
  }) async {
    await SharedPref.instance.setString(
      SharedPrefKeys.role,
      role!,
    );
  }

  static String? getRoleCode({
    String? role,
  }) {
    final role = SharedPref.instance.getString(
      SharedPrefKeys.role,
    );
    return role;
  }
}

class SharedPrefKeys {
  static const role = 'role';
}
