// THIMACO-CONTROLE: FINANCIELE-KLUIS-SESSIE-FASE2A-20260807
import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../opslag/financiele_noodbackup_service.dart';
import '../opslag/financiele_opslag_service.dart';
import '../opslag/financiele_versleuteling_service.dart';
import 'financiele_kluis_configuratie.dart';
import 'financiele_toegang_service.dart';

enum FinancieleKluisStatus {
  nietBeschikbaar,
  configuratieOntbreekt,
  initialiseren,
  nietGeactiveerd,
  vergrendeld,
  ontgrendeld,
  herstelNodig,
  fout,
}

class FinancieleKluisSessieController extends ChangeNotifier {
  FinancieleKluisSessieController._();

  static final FinancieleKluisSessieController instance =
      FinancieleKluisSessieController._();

  final FinancieleToegangService _toegangService = FinancieleToegangService();
  final FinancieleOpslagService _opslagService = FinancieleOpslagService();
  final FinancieleNoodbackupService _noodbackupService =
      FinancieleNoodbackupService();
  final FinancieleVersleutelingService _versleutelingService =
      FinancieleVersleutelingService();

  FinancieleKluisStatus _status = FinancieleKluisStatus.initialiseren;
  Uint8List? _masterKey;
  Map<String, dynamic>? _inhoud;
  String _foutBericht = '';
  Timer? _sessieTimer;
  bool _bewerkingBezig = false;

  FinancieleKluisStatus get status => _status;
  String get foutBericht => _foutBericht;
  bool get bewerkingBezig => _bewerkingBezig;
  bool get magMenuTonen => FinancieleKluisConfiguratie.magModuleTonen;
  bool get isOntgrendeld =>
      _status == FinancieleKluisStatus.ontgrendeld &&
      _masterKey != null &&
      _inhoud != null;

  Map<String, dynamic>? get inhoud {
    final huidige = _inhoud;
    return huidige == null ? null : Map<String, dynamic>.unmodifiable(huidige);
  }

  Future<void> initialiseer() async {
    _sessieTimer?.cancel();
    _wisGeheugen();

    if (!FinancieleKluisConfiguratie.magModuleTonen) {
      _zetStatus(FinancieleKluisStatus.nietBeschikbaar);
      return;
    }

    if (!FinancieleKluisConfiguratie.heeftGeldigeActivatieHash) {
      _zetStatus(FinancieleKluisStatus.configuratieOntbreekt);
      return;
    }

    _zetStatus(FinancieleKluisStatus.initialiseren);

    try {
      final geactiveerd = await _toegangService.isGeactiveerd();
      if (!geactiveerd) {
        _zetStatus(FinancieleKluisStatus.nietGeactiveerd);
        return;
      }

      final kluisBestaat = await _opslagService.bestaat();
      _zetStatus(
        kluisBestaat
            ? FinancieleKluisStatus.vergrendeld
            : FinancieleKluisStatus.herstelNodig,
      );
    } catch (fout) {
      _zetFout(_berichtVan(fout));
    }
  }

  Future<String> activeer({required String activatieCode}) async {
    _startBewerking();
    FinancieleActivatieResultaat? activatieResultaat;

    try {
      if (_status != FinancieleKluisStatus.nietGeactiveerd) {
        throw const FinancieleSessieException(
          'Deze financiële kluis kan in de huidige toestand niet worden geactiveerd.',
        );
      }

      final resultaat = await _toegangService.bereidActivatieVoor(
        activatieCode: activatieCode,
      );
      activatieResultaat = resultaat;

      final herstelcodeVerifier = await _versleutelingService
          .maakHerstelcodeVerifier(herstelcode: resultaat.herstelcode);

      try {
        await _opslagService.initialiseerLegeKluis(
          masterKey: resultaat.masterKey,
          herstelcodeVerifier: herstelcodeVerifier,
        );
        await _toegangService.bewaarRegistratie(resultaat.masterKey);
      } catch (_) {
        await _toegangService.wisRegistratie();
        await _opslagService.wisLokaalKluisbestand();
        rethrow;
      }

      _masterKey = Uint8List.fromList(resultaat.masterKey);
      _inhoud = await _opslagService.laadOntsleuteld(_masterKey!);
      _zetStatus(FinancieleKluisStatus.ontgrendeld);
      registreerActiviteit();

      return resultaat.herstelcode;
    } catch (fout) {
      _zetFout(_berichtVan(fout), behoudVorigeStatus: true);
      rethrow;
    } finally {
      final tijdelijkeKey = activatieResultaat?.masterKey;
      if (tijdelijkeKey != null) {
        tijdelijkeKey.fillRange(0, tijdelijkeKey.length, 0);
      }
      _stopBewerking();
    }
  }

  Future<void> ontgrendel() async {
    _startBewerking();

    try {
      if (_status != FinancieleKluisStatus.vergrendeld) {
        throw const FinancieleSessieException(
          'De financiële kluis kan nu niet worden ontgrendeld.',
        );
      }

      final key = await _toegangService.leesMasterKeyMetBiometrie();
      try {
        final inhoud = await _opslagService.laadOntsleuteld(key);

        _masterKey = Uint8List.fromList(key);
        _inhoud = inhoud;
        _zetStatus(FinancieleKluisStatus.ontgrendeld);
        registreerActiviteit();
      } finally {
        key.fillRange(0, key.length, 0);
      }
    } catch (fout) {
      _wisGeheugen();
      _zetFout(_berichtVan(fout), behoudVorigeStatus: true);
      rethrow;
    } finally {
      _stopBewerking();
    }
  }

  Future<void> bewaarInhoud(Map<String, dynamic> nieuweInhoud) async {
    registreerActiviteit();

    final actieveKey = _masterKey;
    if (!isOntgrendeld || actieveKey == null || _inhoud == null) {
      throw const FinancieleSessieException(
        'Ontgrendel de financiële kluis voordat je gegevens opslaat.',
      );
    }

    final key = Uint8List.fromList(actieveKey);
    _startBewerking();

    try {
      final bijgewerkt = Map<String, dynamic>.from(nieuweInhoud)
        ..['gewijzigdOp'] = DateTime.now().toUtc().toIso8601String();

      await _opslagService.bewaarOntsleuteld(
        inhoud: bijgewerkt,
        masterKey: key,
      );

      if (_status == FinancieleKluisStatus.ontgrendeld && _masterKey != null) {
        _inhoud = bijgewerkt;
        _foutBericht = '';
        notifyListeners();
      }
    } catch (fout) {
      _zetFout(_berichtVan(fout), behoudVorigeStatus: true);
      rethrow;
    } finally {
      key.fillRange(0, key.length, 0);
      _stopBewerking();
      registreerActiviteit();
    }
  }

  Future<ShareResult> maakNoodbackup({
    required String herstelcode,
    required Rect sharePositionOrigin,
  }) async {
    registreerActiviteit();

    final actieveKey = _masterKey;
    if (!isOntgrendeld || actieveKey == null) {
      throw const FinancieleSessieException(
        'Ontgrendel de financiële kluis voordat je een noodback-up maakt.',
      );
    }

    // Gebruik een eigen werkkopie. Zodra iOS de deelpagina opent, kan de app
    // inactief worden en wordt de sleutel in de sessie onmiddellijk gewist.
    final key = Uint8List.fromList(actieveKey);
    _startBewerking();

    try {
      final verifierRuw = _inhoud?['herstelcodeVerifier'];
      if (verifierRuw is! Map) {
        throw const FinancieleSessieException(
          'De herstelcodecontrole ontbreekt in deze kluis.',
        );
      }

      final codeGeldig = await _versleutelingService.verifieerHerstelcode(
        herstelcode: herstelcode,
        verifier: Map<String, dynamic>.from(verifierRuw),
      );
      if (!codeGeldig) {
        throw const FinancieleSessieException(
          'De ingevoerde herstelcode komt niet overeen met de papieren code van deze kluis.',
        );
      }

      final envelop = await _opslagService.leesVersleuteldeEnvelop();
      return await _noodbackupService.deelNoodbackup(
        masterKey: key,
        herstelcode: herstelcode,
        kluisEnvelop: envelop,
        sharePositionOrigin: sharePositionOrigin,
      );
    } finally {
      key.fillRange(0, key.length, 0);
      _stopBewerking();
      registreerActiviteit();
    }
  }

  Future<bool> herstelVanNoodbackup({required String herstelcode}) async {
    _startBewerking();
    FinancieleHerstelResultaat? herstelResultaat;

    try {
      if (_status != FinancieleKluisStatus.nietGeactiveerd &&
          _status != FinancieleKluisStatus.herstelNodig &&
          _status != FinancieleKluisStatus.vergrendeld) {
        throw const FinancieleSessieException(
          'Een noodback-up kan alleen op een lege, vergrendelde of beschadigde eigenaarinstallatie worden hersteld.',
        );
      }

      final herstel = await _noodbackupService.kiesEnHerstel(
        herstelcode: herstelcode,
      );
      if (herstel == null) {
        return false;
      }
      herstelResultaat = herstel;

      FinancieleKeychainHerstelTransactie? keychainTransactie;
      var opslagVoorbereid = false;
      var keychainGeactiveerd = false;

      try {
        keychainTransactie = await _toegangService
            .bereidHersteldeRegistratieVoor(herstel.masterKey);

        await _opslagService.schrijfVersleuteldeEnvelop(
          herstel.kluisEnvelop,
          behoudVorigeVersie: true,
        );
        opslagVoorbereid = true;

        await _toegangService.voltooiHersteldeRegistratie(keychainTransactie);
        keychainGeactiveerd = true;

        // Opruimen is best effort. Bij een onderbreking herstelt de opslag bij
        // de eerstvolgende ontgrendeling automatisch de passende bestandversie.
        try {
          await _opslagService.voltooiHerstelSchrijfbeurt();
        } catch (_) {
          // Geen blokkering: sleutel en actuele kluis zijn al consistent.
        }
      } catch (_) {
        if (!keychainGeactiveerd && opslagVoorbereid) {
          try {
            await _opslagService.annuleerHerstelSchrijfbeurt();
          } catch (_) {
            // De .bak-versie blijft beschikbaar en wordt bij een volgende
            // ontgrendeling automatisch opnieuw beoordeeld.
          }
        }
        if (!keychainGeactiveerd && keychainTransactie != null) {
          try {
            await _toegangService.annuleerHersteldeRegistratie(
              keychainTransactie,
            );
          } catch (_) {
            // Een inactieve, niet-gemarkeerde sleutel geeft geen toegang.
          }
        }
        rethrow;
      }

      _masterKey = Uint8List.fromList(herstel.masterKey);
      _inhoud = Map<String, dynamic>.from(herstel.inhoud);
      _zetStatus(FinancieleKluisStatus.ontgrendeld);
      registreerActiviteit();
      return true;
    } catch (fout) {
      _wisGeheugen();
      _zetFout(_berichtVan(fout), behoudVorigeStatus: true);
      rethrow;
    } finally {
      final tijdelijkeHerstelKey = herstelResultaat?.masterKey;
      if (tijdelijkeHerstelKey != null) {
        tijdelijkeHerstelKey.fillRange(0, tijdelijkeHerstelKey.length, 0);
      }
      _stopBewerking();
    }
  }

  void registreerActiviteit() {
    if (!isOntgrendeld) {
      return;
    }

    _sessieTimer?.cancel();
    _sessieTimer = Timer(FinancieleKluisConfiguratie.sessieTimeout, vergrendel);
  }

  void vergrendel() {
    _sessieTimer?.cancel();
    _sessieTimer = null;

    if (_status == FinancieleKluisStatus.ontgrendeld) {
      _wisGeheugen();
      _zetStatus(FinancieleKluisStatus.vergrendeld);
    } else {
      _wisGeheugen();
    }
  }

  void wisFoutmelding() {
    if (_foutBericht.isEmpty) {
      return;
    }

    _foutBericht = '';
    notifyListeners();
  }

  void _startBewerking() {
    if (_bewerkingBezig) {
      throw const FinancieleSessieException(
        'Er is al een beveiligde bewerking bezig.',
      );
    }

    _bewerkingBezig = true;
    _foutBericht = '';
    notifyListeners();
  }

  void _stopBewerking() {
    if (!_bewerkingBezig) {
      return;
    }

    _bewerkingBezig = false;
    notifyListeners();
  }

  void _zetStatus(FinancieleKluisStatus nieuweStatus) {
    _status = nieuweStatus;
    if (nieuweStatus != FinancieleKluisStatus.fout) {
      _foutBericht = '';
    }
    notifyListeners();
  }

  void _zetFout(String bericht, {bool behoudVorigeStatus = false}) {
    _foutBericht = bericht;
    if (!behoudVorigeStatus) {
      _status = FinancieleKluisStatus.fout;
    }
    notifyListeners();
  }

  void _wisGeheugen() {
    final key = _masterKey;
    if (key != null) {
      key.fillRange(0, key.length, 0);
    }

    _masterKey = null;
    _inhoud = null;
  }

  String _berichtVan(Object fout) {
    if (fout is FinancieleToegangException) return fout.bericht;
    if (fout is FinancieleOpslagException) return fout.bericht;
    if (fout is FinancieleNoodbackupException) return fout.bericht;
    if (fout is FinancieleSessieException) return fout.bericht;

    return 'De beveiligde financiële bewerking is niet gelukt.';
  }
}

class FinancieleSessieException implements Exception {
  const FinancieleSessieException(this.bericht);

  final String bericht;

  @override
  String toString() => bericht;
}
