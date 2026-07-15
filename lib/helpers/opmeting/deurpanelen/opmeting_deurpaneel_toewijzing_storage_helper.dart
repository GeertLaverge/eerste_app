import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../sync/onedrive_sync_service.dart';
import 'opmeting_deurpaneel_toewijzing_model.dart';

class OpmetingDeurpaneelToewijzingStorageHelper {
  const OpmetingDeurpaneelToewijzingStorageHelper._();

  static const String _prefix = 'thimaco_deurpaneel_toewijzingen_';

  static String _sleutelVoorOpmetingId(String opmetingId) {
    return '$_prefix${opmetingId.trim()}';
  }

  static Future<void> _registreerWijzigingVoorSync() async {
    await OneDriveSyncService.registreerLokaleWijziging();
    OneDriveSyncService().uploadBackupOpAchtergrond();
  }

  static Future<List<OpmetingDeurpaneelToewijzing>> laadVoorOpmetingId({
    required String opmetingId,
  }) async {
    final id = opmetingId.trim();

    if (id.isEmpty) {
      return const <OpmetingDeurpaneelToewijzing>[];
    }

    final prefs = await SharedPreferences.getInstance();
    final tekst = prefs.getString(_sleutelVoorOpmetingId(id));

    if (tekst == null || tekst.trim().isEmpty) {
      return const <OpmetingDeurpaneelToewijzing>[];
    }

    try {
      final decoded = jsonDecode(tekst);

      if (decoded is! List) {
        return const <OpmetingDeurpaneelToewijzing>[];
      }

      return decoded
          .whereType<Map>()
          .map((item) {
            return OpmetingDeurpaneelToewijzing.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            );
          })
          .where((toewijzing) {
            return toewijzing.id.trim().isNotEmpty &&
                toewijzing.deurVleugelId.trim().isNotEmpty &&
                toewijzing.paneelId.trim().isNotEmpty &&
                toewijzing.paneelNaam.trim().isNotEmpty;
          })
          .toList(growable: false);
    } catch (_) {
      return const <OpmetingDeurpaneelToewijzing>[];
    }
  }

  static Future<void> bewaarVoorOpmetingId({
    required String opmetingId,
    required List<OpmetingDeurpaneelToewijzing> toewijzingen,
  }) async {
    final id = opmetingId.trim();

    if (id.isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final sleutel = _sleutelVoorOpmetingId(id);

    if (toewijzingen.isEmpty) {
      await prefs.remove(sleutel);
      await _registreerWijzigingVoorSync();
      return;
    }

    final encoded = jsonEncode(
      toewijzingen
          .map((toewijzing) => toewijzing.toJson())
          .toList(growable: false),
    );

    await prefs.setString(sleutel, encoded);
    await _registreerWijzigingVoorSync();
  }

  static Future<void> wisVoorOpmetingId({required String opmetingId}) async {
    final id = opmetingId.trim();

    if (id.isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sleutelVoorOpmetingId(id));
    await _registreerWijzigingVoorSync();
  }
}
