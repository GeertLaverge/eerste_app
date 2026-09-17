// THIMACO-CONTROLE: FINANCIELE-KLUIS-SESSIE-HERSTELPAKKET-V2-20260916
import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../opslag/financiele_noodbackup_service.dart';
import '../opslag/financiele_opslag_service.dart';
import '../opslag/financiele_reddingsscan_service.dart';
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
  final FinancieleReddingsscanService _reddingsscanService =
      FinancieleReddingsscanService();

  FinancieleKluisStatus _status = FinancieleKluisStatus.initialiseren;
  Uint8List? _masterKey;
  Map<String, dynamic>? _inhoud;
  String _foutBericht = '';
  Timer? _sessieTimer;
  bool _bewerkingBezig = false;
  bool _heeftLokaalHerstelpakket = false;

  FinancieleKluisStatus get status => _status;
  String get foutBericht => _foutBericht;
  bool get bewerkingBezig => _bewerkingBezig;
  bool get heeftLokaalHerstelpakket => _heeftLokaalHerstelpakket;
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
    _heeftLokaalHerstelpakket = false;

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
      _heeftLokaalHerstelpakket =
          await _opslagService.lokaalHerstelpakketBestaat();

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

      if (await _opslagService.bestaat()) {
        throw const FinancieleSessieException(
          'Er staat nog een oude lokale financiële kluis op deze iPad. Gebruik eerst “Nieuwe kluis starten” zodat die veilig wordt gearchiveerd.',
        );
      }

      final resultaat = await _toegangService.bereidActivatieVoor(
        activatieCode: activatieCode,
      );
      activatieResultaat = resultaat;

      final herstelcodeVerifier = await _versleutelingService
          .maakHerstelcodeVerifier(herstelcode: resultaat.herstelcode);
      final sleutelVerpakking = await _versleutelingService.verpakMasterKey(
        masterKey: resultaat.masterKey,
        herstelcode: resultaat.herstelcode,
      );

      try {
        await _opslagService.initialiseerLegeKluis(
          masterKey: resultaat.masterKey,
          herstelcodeVerifier: herstelcodeVerifier,
        );
        await _opslagService.schrijfLokaalHerstelpakket(
          sleutelVerpakking: sleutelVerpakking,
        );
        await _toegangService.bewaarRegistratie(resultaat.masterKey);
      } catch (_) {
        try {
          await _toegangService.wisRegistratie();
        } catch (_) {
          // Best effort: activatie is nog niet als geslaagd teruggegeven.
        }
        try {
          await _opslagService.wisFinancieleLokaleDataVoorNieuweStart();
        } catch (_) {
          // De oorspronkelijke activatiefout blijft leidend.
        }
        rethrow;
      }

      _heeftLokaalHerstelpakket = true;
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

  Future<void> herstelToegangMetPapierenCode({
    required String herstelcode,
  }) async {
    _startBewerking();
    Uint8List? tijdelijkeKey;
    FinancieleKeychainHerstelTransactie? keychainTransactie;
    var keychainGeactiveerd = false;

    try {
      if (_status != FinancieleKluisStatus.vergrendeld) {
        throw const FinancieleSessieException(
          'Herstel met de papieren code kan alleen bij een vergrendelde lokale kluis.',
        );
      }

      final verpakking = await _opslagService.leesLokaalHerstelpakket();
      final key = await _versleutelingService.ontpakMasterKey(
        verpakking: verpakking,
        herstelcode: herstelcode,
      );
      tijdelijkeKey = key;

      final inhoud = await _opslagService.laadOntsleuteld(key);
      final verifierRuw = inhoud['herstelcodeVerifier'];
      if (verifierRuw is! Map ||
          !await _versleutelingService.verifieerHerstelcode(
            herstelcode: herstelcode,
            verifier: Map<String, dynamic>.from(verifierRuw),
          )) {
        throw const FinancieleSessieException(
          'De papieren herstelcode hoort niet bij deze financiële kluis.',
        );
      }

      keychainTransactie = await _toegangService
          .bereidHersteldeRegistratieVoor(key);
      await _toegangService.voltooiHersteldeRegistratie(keychainTransactie);
      keychainGeactiveerd = true;

      _masterKey = Uint8List.fromList(key);
      _inhoud = inhoud;
      _heeftLokaalHerstelpakket = true;
      _zetStatus(FinancieleKluisStatus.ontgrendeld);
      registreerActiviteit();
    } catch (fout) {
      if (!keychainGeactiveerd && keychainTransactie != null) {
        try {
          await _toegangService.annuleerHersteldeRegistratie(
            keychainTransactie,
          );
        } catch (_) {
          // Een inactieve sleutel geeft geen toegang tot de kluis.
        }
      }
      _wisGeheugen();
      _zetFout(_berichtVan(fout), behoudVorigeStatus: true);
      rethrow;
    } finally {
      final sleutelOmTeWissen = tijdelijkeKey;
      if (sleutelOmTeWissen != null) {
        sleutelOmTeWissen.fillRange(0, sleutelOmTeWissen.length, 0);
      }
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

      final sleutelVerpakking = await _versleutelingService.verpakMasterKey(
        masterKey: key,
        herstelcode: herstelcode,
      );
      await _opslagService.schrijfLokaalHerstelpakket(
        sleutelVerpakking: sleutelVerpakking,
      );
      _heeftLokaalHerstelpakket = true;

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

  Future<ShareResult> exporteerRuweLokaleKluis({
    required Rect sharePositionOrigin,
  }) async {
    _startBewerking();

    try {
      final exports = await _opslagService.stelRuweKluisVeiligVoorExport();
      final bestanden = exports
          .map(
            (export) => XFile(
              export.veiligPad,
              mimeType: 'application/octet-stream',
            ),
          )
          .toList(growable: false);

      return await SharePlus.instance.share(
        ShareParams(
          title: 'Thimaco versleutelde lokale kluis veiligstellen',
          subject: 'Versleutelde lokale financiële kluis',
          text:
              'Bewaar deze bestanden buiten de Thimaco-app, bijvoorbeeld in OneDrive of iCloud Drive. '
              'De export kan naast de kluis ook het versleutelde lokale herstelpakket bevatten.',
          files: bestanden,
          sharePositionOrigin: sharePositionOrigin,
        ),
      );
    } catch (fout) {
      _zetFout(_berichtVan(fout), behoudVorigeStatus: true);
      rethrow;
    } finally {
      _stopBewerking();
    }
  }

  Future<FinancieleNieuweStartResultaat> maakKlaarVoorNieuweKluis() async {
    _startBewerking();

    try {
      if (_status != FinancieleKluisStatus.vergrendeld &&
          _status != FinancieleKluisStatus.herstelNodig) {
        throw const FinancieleSessieException(
          'Een nieuwe kluis kan alleen vanuit een vergrendelde of te herstellen eigenaarinstallatie worden gestart.',
        );
      }

      final archief = await _opslagService.archiveerVoorNieuweStart();

      // Pas nadat alle aanwezige financiële bestanden byte-voor-byte zijn
      // gecontroleerd, wordt de actieve lokale opslag vrijgemaakt.
      await _opslagService.wisFinancieleLokaleDataVoorNieuweStart();
      try {
        await _toegangService.resetRegistratieVoorNieuweStart();
      } catch (_) {
        // Wanneer de registratie niet kan worden vrijgemaakt, zetten we de
        // gearchiveerde lokale bestanden terug en starten we geen nieuwe kluis.
        await _opslagService.herstelActieveBestandenUitNieuweStartArchief(
          archief,
        );
        rethrow;
      }

      _sessieTimer?.cancel();
      _sessieTimer = null;
      _wisGeheugen();
      _heeftLokaalHerstelpakket = false;
      _zetStatus(FinancieleKluisStatus.nietGeactiveerd);

      return FinancieleNieuweStartResultaat(
        archiefMapPad: archief.mapPad,
        aantalBestanden: archief.bestanden.length,
      );
    } catch (fout) {
      _zetFout(_berichtVan(fout), behoudVorigeStatus: true);
      rethrow;
    } finally {
      _stopBewerking();
    }
  }

  Future<bool> herstelVanNoodbackup({required String herstelcode}) async {
    _startBewerking();
    FinancieleHerstelResultaat? herstelResultaat;

    try {
      _controleerHerstelToegestaan();

      final herstel = await _noodbackupService.kiesEnHerstel(
        herstelcode: herstelcode,
      );
      if (herstel == null) {
        return false;
      }
      herstelResultaat = herstel;

      await _pasHerstelToe(herstel, herstelcode: herstelcode);
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

  Future<bool> herstelVanVrijGekozenBestand({
    required String herstelcode,
  }) async {
    _startBewerking();
    FinancieleHerstelResultaat? herstelResultaat;

    try {
      _controleerHerstelToegestaan();

      final herstel = await _noodbackupService.kiesVrijBestandEnHerstel(
        herstelcode: herstelcode,
      );
      if (herstel == null) {
        return false;
      }
      herstelResultaat = herstel;

      await _pasHerstelToe(herstel, herstelcode: herstelcode);
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

  Future<FinancieleReddingsHerstelResultaat> herstelVanTijdelijkeNoodbackup({
    required String herstelcode,
  }) async {
    _startBewerking();
    FinancieleHerstelResultaat? herstelResultaat;

    try {
      _controleerHerstelToegestaan();

      final kandidaten = await _reddingsscanService.zoekEnStelVeilig();
      if (kandidaten.isEmpty) {
        throw const FinancieleReddingsscanException(
          'De reddingsscan vond geen tijdelijke Thimaco-noodback-up in de lokale appmappen van deze iPad.',
        );
      }

      FinancieleNoodbackupException? laatsteOntsleutelFout;

      for (final kandidaat in kandidaten) {
        try {
          final bytes = await _reddingsscanService.leesVeiligeKopie(kandidaat);
          final herstel = await _noodbackupService.herstelUitBytes(
            bytes: bytes,
            herstelcode: herstelcode,
          );
          herstelResultaat = herstel;

          await _pasHerstelToe(herstel, herstelcode: herstelcode);

          return FinancieleReddingsHerstelResultaat(
            gevondenAantal: kandidaten.length,
            veiligeBestandsnaam: kandidaat.veiligeBestandsnaam,
            gewijzigdOp: kandidaat.gewijzigdOp,
          );
        } on FinancieleNoodbackupException catch (fout) {
          laatsteOntsleutelFout = fout;
          herstelResultaat = null;
        }
      }

      final extra = laatsteOntsleutelFout == null
          ? ''
          : '\n\n${laatsteOntsleutelFout.bericht}';
      throw FinancieleReddingsscanException(
        'De reddingsscan heeft ${kandidaten.length} mogelijke noodback-up'
        '${kandidaten.length == 1 ? '' : 's'} gevonden en veiliggesteld, '
        'maar geen ervan kon met de papieren herstelcode worden geopend.'
        '$extra',
      );
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

  Future<void> _pasHerstelToe(
    FinancieleHerstelResultaat herstel, {
    required String herstelcode,
  }) async {
    FinancieleKeychainHerstelTransactie? keychainTransactie;
    var opslagVoorbereid = false;
    var pakketVoorbereid = false;
    var keychainGeactiveerd = false;

    try {
      keychainTransactie = await _toegangService.bereidHersteldeRegistratieVoor(
        herstel.masterKey,
      );

      await _opslagService.schrijfVersleuteldeEnvelop(
        herstel.kluisEnvelop,
        behoudVorigeVersie: true,
      );
      opslagVoorbereid = true;

      final sleutelVerpakking = await _versleutelingService.verpakMasterKey(
        masterKey: herstel.masterKey,
        herstelcode: herstelcode,
      );
      await _opslagService.schrijfLokaalHerstelpakket(
        sleutelVerpakking: sleutelVerpakking,
        behoudVorigeVersie: true,
      );
      pakketVoorbereid = true;

      await _toegangService.voltooiHersteldeRegistratie(keychainTransactie);
      keychainGeactiveerd = true;

      try {
        await _opslagService.voltooiHerstelSchrijfbeurt();
        await _opslagService.voltooiHerstelpakketSchrijfbeurt();
      } catch (_) {
        // De actieve kluis, sleutel en herstelverpakking zijn al consistent.
      }
    } catch (_) {
      if (!keychainGeactiveerd && pakketVoorbereid) {
        try {
          await _opslagService.annuleerHerstelpakketSchrijfbeurt();
        } catch (_) {
          // De externe noodback-up blijft beschikbaar.
        }
      }
      if (!keychainGeactiveerd && opslagVoorbereid) {
        try {
          await _opslagService.annuleerHerstelSchrijfbeurt();
        } catch (_) {
          // De .bak-versie blijft beschikbaar voor veilig herstel.
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

    _heeftLokaalHerstelpakket = true;
    _masterKey = Uint8List.fromList(herstel.masterKey);
    _inhoud = Map<String, dynamic>.from(herstel.inhoud);
    _zetStatus(FinancieleKluisStatus.ontgrendeld);
    registreerActiviteit();
  }

  void _controleerHerstelToegestaan() {
    if (_status != FinancieleKluisStatus.nietGeactiveerd &&
        _status != FinancieleKluisStatus.herstelNodig &&
        _status != FinancieleKluisStatus.vergrendeld) {
      throw const FinancieleSessieException(
        'Een herstelactie kan alleen op een lege, vergrendelde of beschadigde eigenaarinstallatie worden uitgevoerd.',
      );
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
    if (fout is FinancieleReddingsscanException) return fout.bericht;
    if (fout is FinancieleKluisCryptoException) return fout.bericht;
    if (fout is FinancieleSessieException) return fout.bericht;

    return 'De beveiligde financiële bewerking is niet gelukt.';
  }
}

class FinancieleReddingsHerstelResultaat {
  const FinancieleReddingsHerstelResultaat({
    required this.gevondenAantal,
    required this.veiligeBestandsnaam,
    required this.gewijzigdOp,
  });

  final int gevondenAantal;
  final String veiligeBestandsnaam;
  final DateTime gewijzigdOp;
}

class FinancieleNieuweStartResultaat {
  const FinancieleNieuweStartResultaat({
    required this.archiefMapPad,
    required this.aantalBestanden,
  });

  final String archiefMapPad;
  final int aantalBestanden;
}

class FinancieleSessieException implements Exception {
  const FinancieleSessieException(this.bericht);

  final String bericht;

  @override
  String toString() => bericht;
}
