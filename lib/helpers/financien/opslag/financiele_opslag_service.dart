// THIMACO-CONTROLE: FINANCIELE-KLUIS-LOKALE-OPSLAG-FASE2A-20260807
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import '../beveiliging/financiele_privacy_scherm_service.dart';
import 'financiele_versleuteling_service.dart';

class FinancieleOpslagService {
  FinancieleOpslagService({
    FinancieleVersleutelingService? versleutelingService,
  }) : _versleutelingService =
           versleutelingService ?? FinancieleVersleutelingService();

  static const String _bestandsnaam = 'thimaco_financiele_kluis_v1.dat';

  final FinancieleVersleutelingService _versleutelingService;

  Future<bool> bestaat() async {
    final bestand = await _bestand();
    final vorigeVersie = File('${bestand.path}.bak');
    final huidigBestaat = await bestand.exists();
    final vorigeVersieBestaat = await vorigeVersie.exists();
    return huidigBestaat || vorigeVersieBestaat;
  }

  Future<void> initialiseerLegeKluis({
    required Uint8List masterKey,
    required Map<String, dynamic> herstelcodeVerifier,
  }) async {
    final inhoud = <String, dynamic>{
      'schemaVersie': 1,
      'aangemaaktOp': DateTime.now().toUtc().toIso8601String(),
      'gewijzigdOp': DateTime.now().toUtc().toIso8601String(),
      'rekeningen': <dynamic>[],
      'teBetalenFacturen': <dynamic>[],
      'teOntvangenFacturen': <dynamic>[],
      'andereOntvangsten': <dynamic>[],
      'vasteKosten': <dynamic>[],
      'notities': <dynamic>[],
      'herstelcodeVerifier': herstelcodeVerifier,
    };

    await bewaarOntsleuteld(inhoud: inhoud, masterKey: masterKey);
  }

  Future<Map<String, dynamic>> laadOntsleuteld(Uint8List masterKey) async {
    final bestand = await _bestand();
    final vorigeVersie = File('${bestand.path}.bak');

    Object? huidigeFout;
    if (await bestand.exists()) {
      try {
        final envelop = await _leesEnvelopUitBestand(bestand);
        final inhoud = await _versleutelingService.ontsleutelJson(
          envelop: envelop,
          sleutel: masterKey,
        );

        // Een achtergebleven .bak betekent dat de app tijdens de laatste
        // hersteltransactie is onderbroken. Wanneer de actuele combinatie van
        // sleutel en bestand werkt, is de nieuwe toestand geldig.
        await _verwijderBestandZonderFout(vorigeVersie);
        return _normaliseerInhoud(inhoud);
      } catch (fout) {
        huidigeFout = fout;
      }
    }

    if (await vorigeVersie.exists()) {
      try {
        final oudeEnvelop = await _leesEnvelopUitBestand(vorigeVersie);
        final oudeInhoud = await _versleutelingService.ontsleutelJson(
          envelop: oudeEnvelop,
          sleutel: masterKey,
        );

        // De sleutel hoort nog bij de vorige versie. Herstel die versie
        // automatisch; zo blijft ook een stroomonderbreking tijdens herstel
        // veilig en consistent.
        await _verwijderBestandZonderFout(bestand);
        await vorigeVersie.rename(bestand.path);
        return _normaliseerInhoud(oudeInhoud);
      } catch (_) {
        // De algemene fout hieronder voorkomt dat cryptografische details
        // in de gebruikersinterface terechtkomen.
      }
    }

    if (huidigeFout is FinancieleKluisCryptoException) {
      throw const FinancieleOpslagException(
        'Het lokale kluisbestand hoort niet bij de beschikbare toestelgebonden sleutel.',
      );
    }

    throw const FinancieleOpslagException(
      'Het lokale kluisbestand is beschadigd of onleesbaar.',
    );
  }

  Future<void> bewaarOntsleuteld({
    required Map<String, dynamic> inhoud,
    required Uint8List masterKey,
  }) async {
    final bijgewerkt = _normaliseerInhoud(inhoud)
      ..['gewijzigdOp'] = DateTime.now().toUtc().toIso8601String();

    final envelop = await _versleutelingService.versleutelJson(
      inhoud: bijgewerkt,
      sleutel: masterKey,
    );

    await schrijfVersleuteldeEnvelop(envelop);
  }

  Future<Map<String, dynamic>> leesVersleuteldeEnvelop() async {
    final bestand = await _bestand();
    if (!await bestand.exists()) {
      throw const FinancieleOpslagException(
        'Op dit toestel werd geen financiële kluis gevonden.',
      );
    }

    return _leesEnvelopUitBestand(bestand);
  }

  Future<void> schrijfVersleuteldeEnvelop(
    Map<String, dynamic> envelop, {
    bool behoudVorigeVersie = false,
  }) async {
    final bestand = await _bestand();
    final tijdelijk = File('${bestand.path}.tmp');
    final vorigeVersie = File('${bestand.path}.bak');

    try {
      await _verwijderBestandZonderFout(tijdelijk);
      await _verwijderBestandZonderFout(vorigeVersie);

      await tijdelijk.writeAsString(jsonEncode(envelop), flush: true);

      if (await bestand.exists()) {
        await bestand.rename(vorigeVersie.path);
      }

      await tijdelijk.rename(bestand.path);

      if (!behoudVorigeVersie) {
        await _verwijderBestandZonderFout(vorigeVersie);
      }
    } catch (_) {
      await _verwijderBestandZonderFout(tijdelijk);

      if (!await bestand.exists() && await vorigeVersie.exists()) {
        try {
          await vorigeVersie.rename(bestand.path);
        } catch (_) {
          // De originele fout wordt hieronder als veilige opslagfout gemeld.
        }
      }

      throw const FinancieleOpslagException(
        'De financiële kluis kon niet veilig worden opgeslagen.',
      );
    }
  }

  Future<void> annuleerHerstelSchrijfbeurt() async {
    final bestand = await _bestand();
    final vorigeVersie = File('${bestand.path}.bak');

    if (!await vorigeVersie.exists()) {
      // Bij herstel op een nog niet geactiveerde iPad bestond geen vorige
      // kluis. Verwijder dan de nieuw voorbereide versie volledig.
      await _verwijderBestandZonderFout(bestand);
      return;
    }

    await _verwijderBestandZonderFout(bestand);
    try {
      await vorigeVersie.rename(bestand.path);
    } catch (_) {
      throw const FinancieleOpslagException(
        'De vorige lokale kluisversie kon na de mislukte herstelpoging niet worden teruggezet.',
      );
    }
  }

  Future<void> voltooiHerstelSchrijfbeurt() async {
    final bestand = await _bestand();
    await _verwijderBestandZonderFout(File('${bestand.path}.bak'));
  }

  Future<void> wisLokaalKluisbestand() async {
    final bestand = await _bestand();
    await _verwijderBestandZonderFout(File('${bestand.path}.tmp'));
    await _verwijderBestandZonderFout(File('${bestand.path}.bak'));
    await _verwijderBestandZonderFout(bestand);
  }

  Map<String, dynamic> _normaliseerInhoud(Map<String, dynamic> inhoud) {
    final resultaat = Map<String, dynamic>.from(inhoud);

    void zorgVoorLijst(String sleutel) {
      if (resultaat[sleutel] is! List) {
        resultaat[sleutel] = <dynamic>[];
      }
    }

    resultaat['schemaVersie'] ??= 1;
    resultaat['aangemaaktOp'] ??= DateTime.now().toUtc().toIso8601String();
    zorgVoorLijst('rekeningen');
    zorgVoorLijst('teBetalenFacturen');
    zorgVoorLijst('teOntvangenFacturen');
    zorgVoorLijst('andereOntvangsten');
    zorgVoorLijst('vasteKosten');
    zorgVoorLijst('notities');

    return resultaat;
  }

  Future<Map<String, dynamic>> _leesEnvelopUitBestand(File bestand) async {
    try {
      final tekst = await bestand.readAsString();
      final decoded = jsonDecode(tekst);
      if (decoded is! Map) {
        throw const FormatException('Geen JSON-object.');
      }

      return Map<String, dynamic>.from(decoded);
    } catch (_) {
      throw const FinancieleOpslagException(
        'Het lokale kluisbestand is beschadigd of onleesbaar.',
      );
    }
  }

  Future<void> _verwijderBestandZonderFout(File bestand) async {
    try {
      if (await bestand.exists()) {
        await bestand.delete();
      }
    } catch (_) {
      // Oude tijdelijke bestanden bevatten uitsluitend versleutelde data.
      // Een latere opslag- of laadbeurt probeert de opruiming opnieuw.
    }
  }

  Future<File> _bestand() async {
    final map = await getApplicationSupportDirectory();
    final financieleMap = Directory('${map.path}/financiele_kluis');

    if (!await financieleMap.exists()) {
      await financieleMap.create(recursive: true);
    }

    final uitgeslotenVanBackup =
        await FinancielePrivacySchermService.sluitPadUitVanIosBackup(
          financieleMap.path,
        );
    if (!uitgeslotenVanBackup) {
      throw const FinancieleOpslagException(
        'De financiële opslag kon niet van iCloud-reservekopieën worden uitgesloten.',
      );
    }

    return File('${financieleMap.path}/$_bestandsnaam');
  }
}

class FinancieleOpslagException implements Exception {
  const FinancieleOpslagException(this.bericht);

  final String bericht;

  @override
  String toString() => bericht;
}
