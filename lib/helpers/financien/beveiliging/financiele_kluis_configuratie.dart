// THIMACO-CONTROLE: FINANCIELE-KLUIS-EIGENAARBUILD-20260806
import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

class FinancieleKluisConfiguratie {
  const FinancieleKluisConfiguratie._();

  static const bool eigenaarBuild = bool.fromEnvironment(
    'THIMACO_FINANCE_OWNER_BUILD',
    defaultValue: false,
  );

  static const String _activatieHash = String.fromEnvironment(
    'THIMACO_FINANCE_ACTIVATION_SHA256',
    defaultValue: '',
  );

  static const Duration sessieTimeout = Duration(minutes: 2);

  static bool get platformOndersteund {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  }

  static bool get magModuleTonen {
    return eigenaarBuild && platformOndersteund;
  }

  static bool get heeftGeldigeActivatieHash {
    return RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(_activatieHash.trim());
  }

  static Future<bool> verifieerActivatieCode(String activatieCode) async {
    if (!heeftGeldigeActivatieHash) {
      return false;
    }

    final genormaliseerd = activatieCode.trim();
    if (genormaliseerd.length < 20) {
      return false;
    }

    final hash = await Sha256().hash(utf8.encode(genormaliseerd));
    final berekend = hash.bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();

    return _constantTimeEquals(
      berekend.toLowerCase(),
      _activatieHash.trim().toLowerCase(),
    );
  }

  static bool _constantTimeEquals(String eerste, String tweede) {
    if (eerste.length != tweede.length) {
      return false;
    }

    var verschil = 0;
    for (var index = 0; index < eerste.length; index++) {
      verschil |= eerste.codeUnitAt(index) ^ tweede.codeUnitAt(index);
    }

    return verschil == 0;
  }
}
