import 'package:flutter/foundation.dart';

import 'opmeting_deurpaneel_dxf_model.dart';
import 'opmeting_deurpaneel_dxf_parser.dart';
import 'opmeting_deurpaneel_dxf_storage_helper.dart';
import 'opmeting_deurpaneel_dxf_test_bestanden.dart';

class OpmetingDeurpaneelDxfBibliotheek {
  OpmetingDeurpaneelDxfBibliotheek._();

  static final ValueNotifier<int> versie = ValueNotifier<int>(0);

  static final Map<String, String> _dxfTeksten = <String, String>{};
  static final Map<String, OpmetingDeurpaneelDxfTekening> _cache =
      <String, OpmetingDeurpaneelDxfTekening>{};

  static final Set<String> _automatischeTestSleutels = <String>{};

  static bool _geladen = false;
  static bool _ladenBezig = false;

  static int get aantalDxfs {
    return _dxfTeksten.length;
  }

  static bool get isGeladen {
    return _geladen;
  }

  static List<String> get bestandsnamen {
    final lijst = _dxfTeksten.keys.toList()..sort();

    return List<String>.unmodifiable(lijst);
  }

  static Future<void> laad({bool force = false}) async {
    if (!force && (_geladen || _ladenBezig)) {
      return;
    }

    _ladenBezig = true;

    try {
      final opgeslagen = await OpmetingDeurpaneelDxfStorageHelper.laadDxfs();

      _dxfTeksten.clear();
      _automatischeTestSleutels.clear();
      _dxfTeksten.addAll(opgeslagen ?? <String, String>{});

      /*
       * Tijdelijke test-DXF's worden als fallback geladen uit assets.
       * Belangrijk: lokaal ingeladen DXF's uit Instellingen krijgen voorrang.
       * Daardoor kan de leverancier later gewoon dezelfde bestandsnaam vervangen
       * zonder code aan te passen.
       */
      await _laadTestAssetsAlsFallback();

      _cache.clear();
      _geladen = true;
      versie.value++;
    } finally {
      _ladenBezig = false;
    }
  }

  static Future<void> _laadTestAssetsAlsFallback() async {
    final testDxfs = await OpmetingDeurpaneelDxfTestBestanden.laadAlle();

    for (final entry in testDxfs.entries) {
      if (_dxfTeksten.containsKey(entry.key)) {
        continue;
      }

      _dxfTeksten[entry.key] = entry.value;
      _automatischeTestSleutels.add(entry.key);
    }
  }

  static Future<void> bewaarDxf({
    required String bestandsnaam,
    required String inhoud,
  }) async {
    final sleutel = normaliseerBestandsnaam(bestandsnaam);
    final dxfInhoud = inhoud.trimRight();

    if (sleutel.isEmpty || dxfInhoud.trim().isEmpty) {
      return;
    }

    if (!_geladen && !_ladenBezig) {
      await laad();
    }

    _dxfTeksten[sleutel] = dxfInhoud;
    _automatischeTestSleutels.remove(sleutel);
    _cache.remove(sleutel);

    await OpmetingDeurpaneelDxfStorageHelper.bewaarDxfs(
      _alleenOpgeslagenDxfs(),
    );

    _geladen = true;
    versie.value++;
  }

  static Future<void> verwijderDxf(String bestandsnaam) async {
    final sleutel = normaliseerBestandsnaam(bestandsnaam);

    if (sleutel.isEmpty) {
      return;
    }

    if (!_geladen && !_ladenBezig) {
      await laad();
    }

    _dxfTeksten.remove(sleutel);
    _automatischeTestSleutels.remove(sleutel);
    _cache.remove(sleutel);

    await OpmetingDeurpaneelDxfStorageHelper.bewaarDxfs(
      _alleenOpgeslagenDxfs(),
    );

    _geladen = true;
    versie.value++;
  }

  static Future<void> laadTestBestanden() async {
    if (!_geladen && !_ladenBezig) {
      await laad();
    }

    final testDxfs = await OpmetingDeurpaneelDxfTestBestanden.laadAlle();

    for (final entry in testDxfs.entries) {
      _dxfTeksten[entry.key] = entry.value;
      _automatischeTestSleutels.remove(entry.key);
    }

    _cache.clear();

    await OpmetingDeurpaneelDxfStorageHelper.bewaarDxfs(
      _alleenOpgeslagenDxfs(),
    );

    _geladen = true;
    versie.value++;
  }

  static Future<void> wisAlleDxfs() async {
    _dxfTeksten.clear();
    _automatischeTestSleutels.clear();
    _cache.clear();

    await OpmetingDeurpaneelDxfStorageHelper.bewaarDxfs(<String, String>{});

    await _laadTestAssetsAlsFallback();

    _geladen = true;
    versie.value++;
  }

  static OpmetingDeurpaneelDxfTekening? tekeningVoorBestandsnaam(
    String bestandsnaam,
  ) {
    final sleutel = _bestaandeSleutelVoorBestandsnaam(bestandsnaam);

    if (sleutel == null || sleutel.isEmpty) {
      return null;
    }

    if (_cache.containsKey(sleutel)) {
      return _cache[sleutel];
    }

    final inhoud = _dxfTeksten[sleutel];

    if (inhoud == null || inhoud.trim().isEmpty) {
      return null;
    }

    final tekening = OpmetingDeurpaneelDxfParser.parse(
      inhoud,
      bestandsnaam: sleutel,
    );

    _cache[sleutel] = tekening;

    return tekening;
  }

  static bool heeftDxfVoorBestandsnaam(String bestandsnaam) {
    return _bestaandeSleutelVoorBestandsnaam(bestandsnaam) != null;
  }

  static String statusVoorBestandsnaam(String bestandsnaam) {
    final sleutel = _bestaandeSleutelVoorBestandsnaam(bestandsnaam);

    if (sleutel == null) {
      return 'DXF ontbreekt';
    }

    final tekening = tekeningVoorBestandsnaam(bestandsnaam);

    if (tekening == null || tekening.isLeeg) {
      return 'DXF leeg of niet leesbaar';
    }

    return 'DXF aanwezig';
  }

  static String normaliseerBestandsnaam(String bestandsnaam) {
    var resultaat = bestandsnaam.trim().replaceAll('\\', '/');

    if (resultaat.contains('/')) {
      resultaat = resultaat.split('/').last;
    }

    return resultaat.toLowerCase();
  }

  static String? _bestaandeSleutelVoorBestandsnaam(String bestandsnaam) {
    final sleutel = normaliseerBestandsnaam(bestandsnaam);

    if (sleutel.isEmpty) {
      return null;
    }

    if (_dxfTeksten.containsKey(sleutel)) {
      return sleutel;
    }

    final alias = OpmetingDeurpaneelDxfTestBestanden.aliasVoorBestandsnaam(
      sleutel,
    );

    if (alias != null && _dxfTeksten.containsKey(alias)) {
      return alias;
    }

    return null;
  }

  static Map<String, String> _alleenOpgeslagenDxfs() {
    final resultaat = <String, String>{};

    for (final entry in _dxfTeksten.entries) {
      if (_automatischeTestSleutels.contains(entry.key)) {
        continue;
      }

      resultaat[entry.key] = entry.value;
    }

    return resultaat;
  }
}
