import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../sync/onedrive_sync_service.dart';
import 'opmeting_deurpaneel_model.dart';

class OpmetingDeurpaneelStorageHelper {
  const OpmetingDeurpaneelStorageHelper._();

  static const String opslagSleutel = 'thimaco_deurpanelen_bibliotheek';

  static const String gewijzigdOpSleutel =
      'thimaco_deurpanelen_bibliotheek_gewijzigd_op';

  static Future<void> _registreerWijzigingVoorSync() async {
    await OneDriveSyncService.registreerLokaleWijziging();
    OneDriveSyncService().uploadBackupOpAchtergrond();
  }

  static Future<List<OpmetingDeurpaneel>?> laadPanelen() async {
    final prefs = await SharedPreferences.getInstance();
    final tekst = prefs.getString(opslagSleutel);

    if (tekst == null || tekst.trim().isEmpty) {
      return null;
    }

    final decoded = jsonDecode(tekst);

    if (decoded is! List) {
      return null;
    }

    return decoded
        .whereType<Map>()
        .map((item) {
          return OpmetingDeurpaneel.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          );
        })
        .where((paneel) {
          return paneel.id.trim().isNotEmpty &&
              paneel.naam.trim().isNotEmpty &&
              paneel.tekeningBestandsnaam.trim().isNotEmpty;
        })
        .toList(growable: false);
  }

  static Future<void> bewaarPanelen(List<OpmetingDeurpaneel> panelen) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      panelen.map((paneel) => paneel.toJson()).toList(growable: false),
    );

    await prefs.setString(opslagSleutel, encoded);
    await prefs.setString(
      gewijzigdOpSleutel,
      DateTime.now().toUtc().toIso8601String(),
    );

    await _registreerWijzigingVoorSync();
  }

  static Future<void> bewaarPanelenVoorSync({
    required String? jsonTekst,
    required String? gewijzigdOp,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final tekst = jsonTekst?.trim() ?? '';

    if (tekst.isEmpty) {
      await prefs.remove(opslagSleutel);
    } else {
      await prefs.setString(opslagSleutel, tekst);
    }

    final datum = gewijzigdOp?.trim() ?? '';
    if (datum.isEmpty) {
      await prefs.remove(gewijzigdOpSleutel);
    } else {
      await prefs.setString(gewijzigdOpSleutel, datum);
    }
  }

  static Future<void> wisPanelen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(opslagSleutel, '[]');
    await prefs.setString(
      gewijzigdOpSleutel,
      DateTime.now().toUtc().toIso8601String(),
    );

    await _registreerWijzigingVoorSync();
  }
}
