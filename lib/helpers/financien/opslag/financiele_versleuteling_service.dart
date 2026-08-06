// THIMACO-CONTROLE: FINANCIELE-KLUIS-AES256-GCM-20260806
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

class FinancieleVersleutelingService {
  FinancieleVersleutelingService();

  static const int schemaVersie = 1;
  static const int _argonMemory = 19 * 1024;
  static const int _argonIterations = 2;
  static const int _argonParallelism = 1;
  static const int _sleutelLengte = 32;

  final AesGcm _aesGcm = AesGcm.with256bits();
  final Random _random = Random.secure();

  Future<Map<String, dynamic>> versleutelJson({
    required Map<String, dynamic> inhoud,
    required Uint8List sleutel,
  }) async {
    _controleerSleutel(sleutel);

    final nonce = _aesGcm.newNonce();
    final clearBytes = utf8.encode(jsonEncode(inhoud));
    final secretBox = await _aesGcm.encrypt(
      clearBytes,
      secretKey: SecretKey(sleutel),
      nonce: nonce,
    );

    return <String, dynamic>{
      'schemaVersie': schemaVersie,
      'algoritme': 'AES-256-GCM',
      'nonce': base64UrlEncode(secretBox.nonce),
      'cipherText': base64UrlEncode(secretBox.cipherText),
      'mac': base64UrlEncode(secretBox.mac.bytes),
    };
  }

  Future<Map<String, dynamic>> ontsleutelJson({
    required Map<String, dynamic> envelop,
    required Uint8List sleutel,
  }) async {
    _controleerSleutel(sleutel);
    _controleerAesEnvelop(envelop);

    final secretBox = _leesSecretBox(envelop);
    final clearBytes = await _aesGcm.decrypt(
      secretBox,
      secretKey: SecretKey(sleutel),
    );
    final decoded = jsonDecode(utf8.decode(clearBytes));

    if (decoded is! Map) {
      throw const FinancieleKluisCryptoException(
        'De ontsleutelde kluisinhoud heeft een ongeldig formaat.',
      );
    }

    return Map<String, dynamic>.from(decoded);
  }

  Future<Map<String, dynamic>> verpakMasterKey({
    required Uint8List masterKey,
    required String herstelcode,
  }) async {
    _controleerSleutel(masterKey);

    final genormaliseerdeCode = normaliseerHerstelcode(herstelcode);
    if (!isGeldigeHerstelcode(genormaliseerdeCode)) {
      throw const FinancieleKluisCryptoException(
        'De herstelcode heeft geen geldig formaat.',
      );
    }

    final salt = _randomBytes(16);
    final afgeleideSleutel = await _leidHerstelsleutelAf(
      herstelcode: genormaliseerdeCode,
      salt: salt,
    );
    try {
      final nonce = _aesGcm.newNonce();
      final secretBox = await _aesGcm.encrypt(
        masterKey,
        secretKey: SecretKey(afgeleideSleutel),
        nonce: nonce,
      );

      return <String, dynamic>{
        'schemaVersie': schemaVersie,
        'kdf': <String, dynamic>{
          'algoritme': 'Argon2id',
          'memory': _argonMemory,
          'iterations': _argonIterations,
          'parallelism': _argonParallelism,
          'hashLength': _sleutelLengte,
          'salt': base64UrlEncode(salt),
        },
        'sleutelEnvelop': <String, dynamic>{
          'schemaVersie': schemaVersie,
          'algoritme': 'AES-256-GCM',
          'nonce': base64UrlEncode(secretBox.nonce),
          'cipherText': base64UrlEncode(secretBox.cipherText),
          'mac': base64UrlEncode(secretBox.mac.bytes),
        },
      };
    } finally {
      afgeleideSleutel.fillRange(0, afgeleideSleutel.length, 0);
    }
  }

  Future<Uint8List> ontpakMasterKey({
    required Map<String, dynamic> verpakking,
    required String herstelcode,
  }) async {
    final verpakkingVersie = _leesInt(
      verpakking['schemaVersie'],
      'schemaVersie',
    );
    if (verpakkingVersie != schemaVersie) {
      throw const FinancieleKluisCryptoException(
        'De sleutelverpakking gebruikt een niet-ondersteunde versie.',
      );
    }

    final kdf = _leesMap(verpakking['kdf'], 'kdf');
    final sleutelEnvelop = _leesMap(
      verpakking['sleutelEnvelop'],
      'sleutelEnvelop',
    );

    final memory = _leesInt(kdf['memory'], 'memory');
    final iterations = _leesInt(kdf['iterations'], 'iterations');
    final parallelism = _leesInt(kdf['parallelism'], 'parallelism');
    final hashLength = _leesInt(kdf['hashLength'], 'hashLength');
    final salt = _decodeBase64(kdf['salt'], 'salt');

    if (kdf['algoritme']?.toString() != 'Argon2id' ||
        memory != _argonMemory ||
        iterations != _argonIterations ||
        parallelism != _argonParallelism ||
        hashLength != _sleutelLengte ||
        salt.length != 16) {
      throw const FinancieleKluisCryptoException(
        'De sleutelafleiding in de noodback-up is ongeldig of wordt niet ondersteund.',
      );
    }

    _controleerAesEnvelop(sleutelEnvelop);

    final genormaliseerdeCode = normaliseerHerstelcode(herstelcode);
    if (!isGeldigeHerstelcode(genormaliseerdeCode)) {
      throw const FinancieleKluisCryptoException(
        'De herstelcode heeft geen geldig formaat.',
      );
    }

    final algoritme = Argon2id(
      memory: memory,
      iterations: iterations,
      parallelism: parallelism,
      hashLength: hashLength,
    );
    final afgeleideSecretKey = await algoritme.deriveKeyFromPassword(
      password: genormaliseerdeCode,
      nonce: salt,
    );
    final afgeleideSleutel = Uint8List.fromList(
      await afgeleideSecretKey.extractBytes(),
    );

    try {
      final secretBox = _leesSecretBox(sleutelEnvelop);
      final masterKey = await _aesGcm.decrypt(
        secretBox,
        secretKey: SecretKey(afgeleideSleutel),
      );
      final resultaat = Uint8List.fromList(masterKey);
      _controleerSleutel(resultaat);
      return resultaat;
    } finally {
      afgeleideSleutel.fillRange(0, afgeleideSleutel.length, 0);
    }
  }

  String maakHerstelcode() {
    const alfabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final groepen = <String>[];

    for (var groep = 0; groep < 12; groep++) {
      final buffer = StringBuffer();
      for (var teken = 0; teken < 4; teken++) {
        buffer.write(alfabet[_random.nextInt(alfabet.length)]);
      }
      groepen.add(buffer.toString());
    }

    return groepen.join('-');
  }

  Future<Map<String, dynamic>> maakHerstelcodeVerifier({
    required String herstelcode,
  }) async {
    final genormaliseerd = normaliseerHerstelcode(herstelcode);
    if (!isGeldigeHerstelcode(genormaliseerd)) {
      throw const FinancieleKluisCryptoException(
        'De herstelcode heeft geen geldig formaat.',
      );
    }

    final salt = _randomBytes(16);
    final sleutel = await _leidHerstelsleutelAf(
      herstelcode: genormaliseerd,
      salt: salt,
    );

    try {
      return <String, dynamic>{
        'algoritme': 'Argon2id',
        'memory': _argonMemory,
        'iterations': _argonIterations,
        'parallelism': _argonParallelism,
        'hashLength': _sleutelLengte,
        'salt': base64UrlEncode(salt),
        'hash': base64UrlEncode(sleutel),
      };
    } finally {
      sleutel.fillRange(0, sleutel.length, 0);
    }
  }

  Future<bool> verifieerHerstelcode({
    required String herstelcode,
    required Map<String, dynamic> verifier,
  }) async {
    final genormaliseerd = normaliseerHerstelcode(herstelcode);
    if (!isGeldigeHerstelcode(genormaliseerd)) {
      return false;
    }

    try {
      final memory = _leesInt(verifier['memory'], 'memory');
      final iterations = _leesInt(verifier['iterations'], 'iterations');
      final parallelism = _leesInt(verifier['parallelism'], 'parallelism');
      final hashLength = _leesInt(verifier['hashLength'], 'hashLength');
      final salt = _decodeBase64(verifier['salt'], 'salt');
      final verwacht = _decodeBase64(verifier['hash'], 'hash');

      if (verifier['algoritme']?.toString() != 'Argon2id' ||
          memory != _argonMemory ||
          iterations != _argonIterations ||
          parallelism != _argonParallelism ||
          hashLength != _sleutelLengte ||
          salt.length != 16 ||
          verwacht.length != _sleutelLengte) {
        return false;
      }

      final algoritme = Argon2id(
        memory: memory,
        iterations: iterations,
        parallelism: parallelism,
        hashLength: hashLength,
      );
      final afgeleid = await algoritme.deriveKeyFromPassword(
        password: genormaliseerd,
        nonce: salt,
      );
      final werkelijk = Uint8List.fromList(await afgeleid.extractBytes());

      try {
        if (werkelijk.length != verwacht.length) {
          return false;
        }

        var verschil = 0;
        for (var index = 0; index < verwacht.length; index++) {
          verschil |= werkelijk[index] ^ verwacht[index];
        }

        return verschil == 0;
      } finally {
        werkelijk.fillRange(0, werkelijk.length, 0);
      }
    } catch (_) {
      return false;
    }
  }

  static String normaliseerHerstelcode(String waarde) {
    final schoon = waarde.trim().toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '',
    );

    if (schoon.length != 48) {
      return schoon;
    }

    final groepen = <String>[];
    for (var index = 0; index < schoon.length; index += 4) {
      groepen.add(schoon.substring(index, index + 4));
    }

    return groepen.join('-');
  }

  static bool isGeldigeHerstelcode(String waarde) {
    return RegExp(
      r'^[A-HJ-NP-Z2-9]{4}(?:-[A-HJ-NP-Z2-9]{4}){11}$',
    ).hasMatch(normaliseerHerstelcode(waarde));
  }

  Future<Uint8List> _leidHerstelsleutelAf({
    required String herstelcode,
    required Uint8List salt,
  }) async {
    final algoritme = Argon2id(
      memory: _argonMemory,
      iterations: _argonIterations,
      parallelism: _argonParallelism,
      hashLength: _sleutelLengte,
    );
    final key = await algoritme.deriveKeyFromPassword(
      password: herstelcode,
      nonce: salt,
    );

    return Uint8List.fromList(await key.extractBytes());
  }

  void _controleerAesEnvelop(Map<String, dynamic> envelop) {
    final versie = _leesInt(envelop['schemaVersie'], 'schemaVersie');
    final algoritme = envelop['algoritme']?.toString();

    if (versie != schemaVersie || algoritme != 'AES-256-GCM') {
      throw const FinancieleKluisCryptoException(
        'De versleutelde gegevens gebruiken een niet-ondersteund formaat.',
      );
    }
  }

  SecretBox _leesSecretBox(Map<String, dynamic> envelop) {
    final nonce = _decodeBase64(envelop['nonce'], 'nonce');
    final cipherText = _decodeBase64(envelop['cipherText'], 'cipherText');
    final mac = _decodeBase64(envelop['mac'], 'mac');

    if (nonce.length != 12 || mac.length != 16 || cipherText.isEmpty) {
      throw const FinancieleKluisCryptoException(
        'De versleutelde gegevens zijn onvolledig of beschadigd.',
      );
    }

    return SecretBox(cipherText, nonce: nonce, mac: Mac(mac));
  }

  Map<String, dynamic> _leesMap(Object? waarde, String veld) {
    if (waarde is! Map) {
      throw FinancieleKluisCryptoException(
        'Het veld “$veld” ontbreekt in de noodback-up.',
      );
    }

    return Map<String, dynamic>.from(waarde);
  }

  int _leesInt(Object? waarde, String veld) {
    if (waarde is int) {
      return waarde;
    }

    final resultaat = int.tryParse(waarde?.toString() ?? '');
    if (resultaat == null) {
      throw FinancieleKluisCryptoException('Het veld “$veld” is ongeldig.');
    }

    return resultaat;
  }

  Uint8List _decodeBase64(Object? waarde, String veld) {
    final tekst = waarde?.toString().trim() ?? '';
    if (tekst.isEmpty) {
      throw FinancieleKluisCryptoException('Het veld “$veld” ontbreekt.');
    }

    try {
      return Uint8List.fromList(base64Url.decode(tekst));
    } catch (_) {
      throw FinancieleKluisCryptoException(
        'Het veld “$veld” bevat ongeldige gegevens.',
      );
    }
  }

  Uint8List _randomBytes(int lengte) {
    return Uint8List.fromList(
      List<int>.generate(lengte, (_) => _random.nextInt(256)),
    );
  }

  void _controleerSleutel(Uint8List sleutel) {
    if (sleutel.length != _sleutelLengte) {
      throw const FinancieleKluisCryptoException(
        'De financiële hoofdsleutel heeft een ongeldige lengte.',
      );
    }
  }
}

class FinancieleKluisCryptoException implements Exception {
  const FinancieleKluisCryptoException(this.bericht);

  final String bericht;

  @override
  String toString() => bericht;
}
