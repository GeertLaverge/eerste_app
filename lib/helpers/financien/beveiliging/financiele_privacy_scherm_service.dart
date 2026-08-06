// THIMACO-CONTROLE: FINANCIELE-KLUIS-IOS-PRIVACY-SCHILD-20260806
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FinancielePrivacySchermService {
  const FinancielePrivacySchermService._();

  static const MethodChannel _kanaal = MethodChannel(
    'be.thimaco.app/financiele_privacy',
  );

  static Future<void> zetFinancieelSchermActief(bool actief) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    try {
      await _kanaal.invokeMethod<void>('setSensitiveScreenActive', actief);
    } on MissingPluginException {
      // Een oudere app-build zonder native privacyschild blijft bruikbaar,
      // maar krijgt de native app-switcher-afdekking pas na een nieuwe build.
    } on PlatformException {
      // De Flutter-zijde vergrendelt de kluis sowieso onmiddellijk.
    }
  }

  static Future<void> verbergPrivacySchildNaVeiligeFrame() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    try {
      await _kanaal.invokeMethod<void>('hidePrivacyShield');
    } on MissingPluginException {
      // Zie toelichting hierboven.
    } on PlatformException {
      // Geen verdere actie nodig.
    }
  }

  static Future<bool> sluitPadUitVanIosBackup(String pad) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return true;
    }

    try {
      final resultaat = await _kanaal.invokeMethod<bool>(
        'excludeFromBackup',
        pad,
      );
      return resultaat == true;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
