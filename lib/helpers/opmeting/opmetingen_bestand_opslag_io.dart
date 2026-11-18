import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Windows-only bestandsopslag voor de grote opmeetlijst.
/// De OneDrive JSON-indeling en de in-memory modellen blijven ongewijzigd.
class OpmetingenBestandOpslag {
  static bool get actief => Platform.isWindows;

  static Future<File> _bestand() async {
    final basis = await getApplicationSupportDirectory();
    final map = Directory('${basis.path}${Platform.pathSeparator}thimaco_lokale_opmetingen');
    if (!await map.exists()) await map.create(recursive: true);
    return File('${map.path}${Platform.pathSeparator}opmetingen_v2.json');
  }

  static File _herstelMarker() {
    final lokaal = Platform.environment['LOCALAPPDATA'];
    if (lokaal == null || lokaal.isEmpty) {
      throw StateError('LOCALAPPDATA niet beschikbaar');
    }
    return File('$lokaal${Platform.pathSeparator}Thimaco_herstel_opmetingen_v2.flag');
  }

  static Future<void> migreer(SharedPreferences prefs, String key) async {
    if (!actief) return;

    // Herstelmodus voor gecontroleerd terugzetten naar een oudere appversie.
    final marker = _herstelMarker();
    if (await marker.exists()) {
      final inhoud = await lees();
      if (inhoud == null || inhoud.isEmpty) {
        throw StateError('Herstel geweigerd: geen opmeetbestand gevonden');
      }
      final gelukt = await prefs.setString(key, inhoud);
      if (!gelukt || prefs.getString(key) != inhoud) {
        throw StateError('Herstel van oude opslag mislukt');
      }
      await marker.delete();
      debugPrint('[THIMACO-OPSLAG] HERSTEL_VOLTOOID: oude opslag hersteld');
      return;
    }

    final legacy = prefs.getString(key);
    if (legacy == null) return;
    if (legacy.isEmpty) return; // leeg niet migreren, oude data behouden

    final bestand = await _bestand();
    if (!await bestand.exists()) {
      await _schrijfAtomair(bestand, legacy);
    }
    final controle = await bestand.readAsString();
    if (controle != legacy) {
      throw StateError('Opmeetbestand wijkt af van SharedPreferences; geen gegevens verwijderd');
    }

    // Bewaar een onafhankelijke herstelkopie voor een latere rollback.
    final migratieBackup = File('${bestand.path}.voor_migratie');
    if (!await migratieBackup.exists()) {
      await _schrijfAtomair(migratieBackup, legacy);
    }
    if (await migratieBackup.readAsString() != legacy) {
      throw StateError('Controle migratieback-up mislukt; geen gegevens verwijderd');
    }

    final verwijderd = await prefs.remove(key);
    if (!verwijderd) {
      throw StateError('Verwijderen van oude SharedPreferences-sleutel mislukt');
    }
    debugPrint('[THIMACO-OPSLAG] MIGRATIE_GESLAAGD: opmetingen buiten SharedPreferences');
    debugPrint('[THIMACO-OPSLAG] Opmeetbestand: ${bestand.path}');
  }

  static Future<File?> _actiefBestand() async {
    final bestand = await _bestand();
    if (await bestand.exists()) return bestand;
    // Crash tussen twee atomische hernoemingen: herstel de vorige versie.
    final vorig = File('${bestand.path}.vorige');
    if (await vorig.exists()) {
      await vorig.rename(bestand.path);
      debugPrint('[THIMACO-OPSLAG] Vorig opmeetbestand hersteld');
      return bestand;
    }
    // Een ooit gemigreerde installatie mag bij een ontbrekend bestand NOOIT
    // stilzwijgend een lege opmeetlijst gaan uploaden naar OneDrive.
    if (await File('${bestand.path}.voor_migratie').exists()) {
      throw StateError('Opmeetbestand ontbreekt; herstelkopie aanwezig. Geen lege gegevens laden.');
    }
    return null;
  }

  static Future<String?> lees() async {
    if (!actief) return null;
    final bestand = await _actiefBestand();
    if (bestand == null) return null;
    return bestand.readAsString();
  }

  static Future<String?> versie() async {
    if (!actief) return null;
    final bestand = await _actiefBestand();
    if (bestand == null) return null;
    final info = await bestand.stat();
    return '${info.modified.microsecondsSinceEpoch}:${info.size}';
  }

  static Future<void> schrijf(String jsonTekst) async {
    if (!actief) throw UnsupportedError('Bestandsopslag alleen voor Windows');
    final bestand = await _bestand();
    await _schrijfAtomair(bestand, jsonTekst);
  }

  static Future<void> _schrijfAtomair(File doel, String inhoud) async {
    final tijdelijk = File('${doel.path}.nieuw');
    final vorig = File('${doel.path}.vorige');
    // Verwijder een oude tijdelijke kopie van een eerdere onderbroken save.
    if (await tijdelijk.exists()) await tijdelijk.delete();
    await tijdelijk.writeAsString(inhoud, flush: true);
    if (await tijdelijk.length() == 0 && inhoud.isNotEmpty) {
      throw StateError('Opmeetbestand is leeg na schrijven');
    }

    if (await doel.exists()) {
      if (await vorig.exists()) await vorig.delete();
      await doel.rename(vorig.path);
    }
    try {
      await tijdelijk.rename(doel.path);
    } catch (_) {
      if (!await doel.exists() && await vorig.exists()) {
        await vorig.rename(doel.path);
      }
      rethrow;
    }
  }
}
