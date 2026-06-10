import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../sync/device_id_service.dart';
import '../../sync/onedrive_sync_service.dart';

class KlantenficheLockService {
  static const String _lockKey = 'klantenfiche_locks';

  static const int _lockGeldigMinuten = 1;

  static Future<Map<String, dynamic>> _laadLocks() async {
    final prefs = await SharedPreferences.getInstance();

    final tekst = prefs.getString(_lockKey);

    if (tekst == null || tekst.isEmpty) {
      return {};
    }

    return Map<String, dynamic>.from(
      jsonDecode(tekst),
    );
  }

  static Future<void> _bewaarLocks(
    Map<String, dynamic> locks,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _lockKey,
      jsonEncode(locks),
    );

    await OneDriveSyncService.registreerLokaleWijziging();
    await OneDriveSyncService().uploadBackup();
  }

  static bool _isLockNogGeldig(
    String lockedAt,
  ) {
    final datum = DateTime.tryParse(lockedAt);

    if (datum == null) return false;

    final verschil = DateTime.now().difference(datum).inMinutes;

    return verschil < _lockGeldigMinuten;
  }

  static Future<bool> kanFicheOpenenEnLocken(
    String ficheId,
  ) async {
    await OneDriveSyncService().slimmeSync();

    final deviceId = await DeviceIdService.deviceId();

    final locks = await _laadLocks();

    final bestaandeLock = locks[ficheId];

    if (bestaandeLock is Map) {
      final lock = Map<String, dynamic>.from(bestaandeLock);

      final lockDeviceId = lock['deviceId'] ?? '';
      final lockedAt = lock['lockedAt'] ?? '';

      if (lockDeviceId != deviceId && _isLockNogGeldig(lockedAt)) {
        return false;
      }
    }

    locks[ficheId] = {
      'deviceId': deviceId,
      'lockedAt': DateTime.now().toIso8601String(),
    };

    await _bewaarLocks(locks);

    return true;
  }

  static Future<void> verwijderLock(
    String ficheId,
  ) async {
    final deviceId = await DeviceIdService.deviceId();

    final locks = await _laadLocks();

    final bestaandeLock = locks[ficheId];

    if (bestaandeLock is Map) {
      final lock = Map<String, dynamic>.from(bestaandeLock);

      final lockDeviceId = lock['deviceId'] ?? '';

      if (lockDeviceId == deviceId) {
        locks.remove(ficheId);
        await _bewaarLocks(locks);
      }
    }
  }

  static Future<void> vernieuwLock(
    String ficheId,
  ) async {
    final deviceId = await DeviceIdService.deviceId();

    final locks = await _laadLocks();

    locks[ficheId] = {
      'deviceId': deviceId,
      'lockedAt': DateTime.now().toIso8601String(),
    };

    await _bewaarLocks(locks);
  }
}
