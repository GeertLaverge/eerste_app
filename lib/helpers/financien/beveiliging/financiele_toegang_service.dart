// THIMACO-CONTROLE: FINANCIELE-KLUIS-KEYCHAIN-BIOMETRIE-20260806
import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../opslag/financiele_versleuteling_service.dart';
import 'financiele_kluis_configuratie.dart';

class FinancieleToegangService {
  FinancieleToegangService({LocalAuthentication? localAuthentication})
    : _localAuthentication = localAuthentication ?? LocalAuthentication();

  static const String _markerKey = 'thimaco_finance_device_marker_v1';
  static const String _legacyMasterKey = 'thimaco_finance_master_key_v1';
  static const String _masterKeyA = 'thimaco_finance_master_key_v2_a';
  static const String _masterKeyB = 'thimaco_finance_master_key_v2_b';
  static const String _markerWaarde = 'THIMACO_OWNER_DEVICE_V1';
  static const int _markerVersie = 2;

  static const IOSOptions _markerOpties = IOSOptions(
    accountName: 'be.thimaco.app.financiele.marker',
    accessibility: KeychainAccessibility.unlocked_this_device,
    synchronizable: false,
  );

  static const IOSOptions _masterKeyOpties = IOSOptions(
    accountName: 'be.thimaco.app.financiele.masterkey',
    accessibility: KeychainAccessibility.passcode,
    synchronizable: false,
    accessControlFlags: <AccessControlFlag>[
      AccessControlFlag.biometryCurrentSet,
    ],
    useSecureEnclave: true,
  );

  final LocalAuthentication _localAuthentication;
  final FlutterSecureStorage _markerStorage = const FlutterSecureStorage(
    iOptions: _markerOpties,
  );
  final FlutterSecureStorage _masterKeyStorage = const FlutterSecureStorage(
    iOptions: _masterKeyOpties,
  );
  final FinancieleVersleutelingService _versleutelingService =
      FinancieleVersleutelingService();

  Future<bool> isGeactiveerd() async {
    if (!FinancieleKluisConfiguratie.magModuleTonen) {
      return false;
    }

    try {
      return await _leesMarker() != null;
    } catch (_) {
      return false;
    }
  }

  Future<FinancieleActivatieResultaat> bereidActivatieVoor({
    required String activatieCode,
  }) async {
    if (!FinancieleKluisConfiguratie.magModuleTonen) {
      throw const FinancieleToegangException(
        'Deze app-build is geen financiële eigenaarbuild.',
      );
    }

    if (!FinancieleKluisConfiguratie.heeftGeldigeActivatieHash) {
      throw const FinancieleToegangException(
        'De eigenaarbuild bevat geen geldige activatiecontrole.',
      );
    }

    final codeGeldig = await FinancieleKluisConfiguratie.verifieerActivatieCode(
      activatieCode,
    );
    if (!codeGeldig) {
      throw const FinancieleToegangException(
        'De eigenaar-activatiecode is niet correct.',
      );
    }

    await _vereisBiometrischeAuthenticatie(
      reden: 'Bevestig dat jij deze iPad als financiële eigenaar activeert.',
    );

    final algoritme = AesGcm.with256bits();
    final masterKey = Uint8List.fromList(
      await (await algoritme.newSecretKey()).extractBytes(),
    );
    final herstelcode = _versleutelingService.maakHerstelcode();

    return FinancieleActivatieResultaat(
      masterKey: masterKey,
      herstelcode: herstelcode,
    );
  }

  Future<void> bewaarRegistratie(Uint8List masterKey) async {
    const actieveSleutel = 'a';
    final keyNaam = _keyNaamVoorSlot(actieveSleutel);

    try {
      await _verwijderKeyZonderFout(keyNaam);
      await _masterKeyStorage.write(
        key: keyNaam,
        value: base64UrlEncode(masterKey),
      );
      await _schrijfMarker(actieveSleutel);

      // Ruim mogelijke resten van een oudere of afgebroken installatie op.
      await _verwijderKeyZonderFout(_masterKeyB);
      await _verwijderKeyZonderFout(_legacyMasterKey);
    } catch (_) {
      await _verwijderKeyZonderFout(keyNaam);
      throw const FinancieleToegangException(
        'De toestelgebonden financiële sleutel kon niet in de iOS Keychain worden opgeslagen.',
      );
    }
  }

  Future<FinancieleKeychainHerstelTransactie> bereidHersteldeRegistratieVoor(
    Uint8List masterKey,
  ) async {
    await _vereisBiometrischeAuthenticatie(
      reden: 'Bevestig dat jij de financiële kluis op deze iPad herstelt.',
    );

    final oudeMarker = await _leesMarker();
    final nieuweSlot = oudeMarker?.actieveSlot == 'a' ? 'b' : 'a';
    final nieuweKeyNaam = _keyNaamVoorSlot(nieuweSlot);

    try {
      await _verwijderKeyZonderFout(nieuweKeyNaam);
      await _masterKeyStorage.write(
        key: nieuweKeyNaam,
        value: base64UrlEncode(masterKey),
      );
    } catch (_) {
      await _verwijderKeyZonderFout(nieuweKeyNaam);
      throw const FinancieleToegangException(
        'De herstelde financiële sleutel kon niet veilig worden voorbereid.',
      );
    }

    return FinancieleKeychainHerstelTransactie._(
      oudeKeyNaam: oudeMarker?.keyNaam,
      nieuweSlot: nieuweSlot,
      nieuweKeyNaam: nieuweKeyNaam,
    );
  }

  Future<void> voltooiHersteldeRegistratie(
    FinancieleKeychainHerstelTransactie transactie,
  ) async {
    try {
      // De marker is het enige actieve verwijspunt. Een afzonderlijke sleutel-
      // slotwisseling voorkomt dat een mislukte herstelpoging de bestaande
      // Keychain-sleutel overschrijft.
      await _schrijfMarker(transactie.nieuweSlot);
    } catch (_) {
      throw const FinancieleToegangException(
        'De herstelde financiële sleutel kon niet worden geactiveerd.',
      );
    }

    final oudeKeyNaam = transactie.oudeKeyNaam;
    if (oudeKeyNaam != null && oudeKeyNaam != transactie.nieuweKeyNaam) {
      await _verwijderKeyZonderFout(oudeKeyNaam);
    }
  }

  Future<void> annuleerHersteldeRegistratie(
    FinancieleKeychainHerstelTransactie transactie,
  ) async {
    await _verwijderKeyZonderFout(transactie.nieuweKeyNaam);
  }

  Future<Uint8List> leesMasterKeyMetBiometrie() async {
    final marker = await _leesMarker();
    if (marker == null) {
      throw const FinancieleToegangException(
        'Deze iPad is niet als financieel eigenaarstoestel geregistreerd.',
      );
    }

    try {
      final waarde = await _masterKeyStorage.read(key: marker.keyNaam);
      if (waarde == null || waarde.trim().isEmpty) {
        throw const FinancieleToegangException(
          'De financiële sleutel ontbreekt. Gebruik de noodback-up om de kluis te herstellen.',
        );
      }

      final bytes = Uint8List.fromList(base64Url.decode(waarde));
      if (bytes.length != 32) {
        throw const FinancieleToegangException(
          'De financiële sleutel in de Keychain is ongeldig.',
        );
      }

      return bytes;
    } on FinancieleToegangException {
      rethrow;
    } catch (_) {
      throw const FinancieleToegangException(
        'Face ID kon de financiële sleutel niet vrijgeven. Controleer of jouw biometrie nog dezelfde is als bij de activatie.',
      );
    }
  }

  Future<void> wisRegistratie() async {
    await _verwijderKeyZonderFout(_masterKeyA);
    await _verwijderKeyZonderFout(_masterKeyB);
    await _verwijderKeyZonderFout(_legacyMasterKey);

    try {
      await _markerStorage.delete(key: _markerKey);
    } catch (_) {
      // Geen verdere actie nodig.
    }
  }

  Future<_FinancieleRegistratieMarker?> _leesMarker() async {
    final ruweMarker = await _markerStorage.read(key: _markerKey);
    if (ruweMarker == null || ruweMarker.trim().isEmpty) {
      return null;
    }

    // Ondersteun een eventuele eerste testinstallatie van fase 1.
    if (ruweMarker == _markerWaarde) {
      return const _FinancieleRegistratieMarker.legacy();
    }

    try {
      final decoded = jsonDecode(ruweMarker);
      if (decoded is! Map) {
        return null;
      }

      final marker = Map<String, dynamic>.from(decoded);
      final versie = marker['versie'];
      final waarde = marker['waarde']?.toString();
      final actieveSlot = marker['actieveSleutel']?.toString();

      if (versie != _markerVersie ||
          waarde != _markerWaarde ||
          (actieveSlot != 'a' && actieveSlot != 'b')) {
        return null;
      }

      return _FinancieleRegistratieMarker(actieveSlot: actieveSlot!);
    } catch (_) {
      return null;
    }
  }

  Future<void> _schrijfMarker(String actieveSlot) async {
    final marker = <String, dynamic>{
      'versie': _markerVersie,
      'waarde': _markerWaarde,
      'actieveSleutel': actieveSlot,
    };

    await _markerStorage.write(key: _markerKey, value: jsonEncode(marker));
  }

  static String _keyNaamVoorSlot(String slot) {
    return slot == 'b' ? _masterKeyB : _masterKeyA;
  }

  Future<void> _verwijderKeyZonderFout(String keyNaam) async {
    try {
      await _masterKeyStorage.delete(key: keyNaam);
    } catch (_) {
      // Een niet-bestaande of ontoegankelijke oude sleutel mag geen nieuwe,
      // correct geactiveerde registratie blokkeren.
    }
  }

  Future<void> _vereisBiometrischeAuthenticatie({required String reden}) async {
    try {
      final kanBiometrie = await _localAuthentication.canCheckBiometrics;
      final beschikbareBiometrie = await _localAuthentication
          .getAvailableBiometrics();

      if (!kanBiometrie || beschikbareBiometrie.isEmpty) {
        throw const FinancieleToegangException(
          'Op deze iPad is geen Face ID of Touch ID ingesteld.',
        );
      }

      final bevestigd = await _localAuthentication.authenticate(
        localizedReason: reden,
        biometricOnly: true,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: false,
      );

      if (!bevestigd) {
        throw const FinancieleToegangException(
          'De biometrische controle werd geannuleerd.',
        );
      }
    } on FinancieleToegangException {
      rethrow;
    } on LocalAuthException catch (fout) {
      throw FinancieleToegangException(
        fout.description?.trim().isNotEmpty == true
            ? fout.description!.trim()
            : 'De biometrische controle is niet gelukt.',
      );
    } catch (_) {
      throw const FinancieleToegangException(
        'De biometrische controle is niet gelukt.',
      );
    }
  }
}

class FinancieleActivatieResultaat {
  const FinancieleActivatieResultaat({
    required this.masterKey,
    required this.herstelcode,
  });

  final Uint8List masterKey;
  final String herstelcode;
}

class FinancieleKeychainHerstelTransactie {
  const FinancieleKeychainHerstelTransactie._({
    required this.oudeKeyNaam,
    required this.nieuweSlot,
    required this.nieuweKeyNaam,
  });

  final String? oudeKeyNaam;
  final String nieuweSlot;
  final String nieuweKeyNaam;
}

class _FinancieleRegistratieMarker {
  const _FinancieleRegistratieMarker({required this.actieveSlot})
    : legacy = false;

  const _FinancieleRegistratieMarker.legacy()
    : actieveSlot = 'legacy',
      legacy = true;

  final String actieveSlot;
  final bool legacy;

  String get keyNaam {
    if (legacy) {
      return FinancieleToegangService._legacyMasterKey;
    }

    return FinancieleToegangService._keyNaamVoorSlot(actieveSlot);
  }
}

class FinancieleToegangException implements Exception {
  const FinancieleToegangException(this.bericht);

  final String bericht;

  @override
  String toString() => bericht;
}
