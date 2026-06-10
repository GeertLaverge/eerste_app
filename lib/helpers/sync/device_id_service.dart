import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdService {
  static const String _deviceIdKey = 'thimaco_device_id';

  static Future<String> deviceId() async {
    final prefs = await SharedPreferences.getInstance();

    final bestaand = prefs.getString(_deviceIdKey);

    if (bestaand != null && bestaand.trim().isNotEmpty) {
      return bestaand;
    }

    final nieuw = DateTime.now().microsecondsSinceEpoch.toString();

    await prefs.setString(
      _deviceIdKey,
      nieuw,
    );

    return nieuw;
  }
}
