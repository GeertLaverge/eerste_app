// THIMACO-CONTROLE: FRAGER-DXF-CONTROLE-DIRECT-ASSET-20260816
import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'opmeting_deurpaneel_dxf_model.dart';
import 'opmeting_deurpaneel_dxf_parser.dart';
import 'opmeting_deurpaneel_dxf_storage_helper.dart';
import 'opmeting_deurpaneel_dxf_test_bestanden.dart';

class OpmetingDeurpaneelDxfBibliotheek {
  OpmetingDeurpaneelDxfBibliotheek._();

  static const String _fragerBundelAsset =
      'assets/deurpanelen/dxf/frager_actueel_dxf.zip';

  static const int _maxAantalGecachteTekeningen = 4;

  static final ValueNotifier<int> versie = ValueNotifier<int>(0);

  /// Handmatig ingeladen DXF's en tijdelijke testfallbacks.
  ///
  /// De grote Frager-bundel wordt bewust NIET in SharedPreferences gezet.
  static final Map<String, String> _dxfTeksten = <String, String>{};

  /// Geparseerde tekeningen worden beperkt gecachet zodat een project met veel
  /// verschillende deurpanelen niet honderden zware DXF's in RAM houdt.
  static final Map<String, OpmetingDeurpaneelDxfTekening> _cache =
      <String, OpmetingDeurpaneelDxfTekening>{};

  static final Set<String> _automatischeTestSleutels = <String>{};

  /// Index van de 566 actuele Frager-DXF's in de gecomprimeerde assetbundel.
  /// De inhoud van een DXF wordt pas gedecomprimeerd wanneer die tekening
  /// werkelijk nodig is.
  static final Map<String, ArchiveFile> _fragerBestanden =
      <String, ArchiveFile>{};

  /// Houdt het Archive-object levend; ArchiveFile kan zijn gecomprimeerde
  /// inhoud vanuit deze bundel on demand lezen.
  static Archive? _fragerArchief;

  static bool _geladen = false;
  static bool _ladenBezig = false;

  static int get aantalDxfs {
    final sleutels = <String>{..._fragerBestanden.keys, ..._dxfTeksten.keys};
    return sleutels.length;
  }

  static int get aantalFragerDxfs => _fragerBestanden.length;

  static bool get isGeladen => _geladen;

  static List<String> get bestandsnamen {
    final lijst = <String>{
      ..._fragerBestanden.keys,
      ..._dxfTeksten.keys,
    }.toList()..sort();

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

      await _laadFragerBundel();

      /*
       * De drie tijdelijke test-DXF's blijven uitsluitend als noodfallback
       * bestaan voor een ontwikkelbuild waarin de Frager-bundel ontbreekt.
       * Zodra dezelfde echte DXF in de Frager-bundel zit, krijgt die altijd
       * voorrang op de oude testtekening.
       */
      await _laadTestAssetsAlsFallback();

      _cache.clear();
      _geladen = true;
      versie.value++;
    } finally {
      _ladenBezig = false;
    }
  }

  static Future<void> _laadFragerBundel() async {
    _fragerBestanden.clear();
    _fragerArchief = null;

    try {
      final data = await rootBundle.load(_fragerBundelAsset);
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      final archief = ZipDecoder().decodeBytes(bytes, verify: false);
      _fragerArchief = archief;

      for (final bestand in archief) {
        if (!bestand.isFile) {
          continue;
        }

        final sleutel = normaliseerBestandsnaam(bestand.name);
        if (sleutel.isEmpty || !sleutel.endsWith('.dxf')) {
          continue;
        }

        _fragerBestanden[sleutel] = bestand;
      }
    } catch (_) {
      // De app blijft bruikbaar wanneer de asset tijdens ontwikkeling nog niet
      // geplaatst is. In dat geval blijven handmatige/test-DXF's beschikbaar.
      _fragerBestanden.clear();
      _fragerArchief = null;
    }
  }

  static Future<void> _laadTestAssetsAlsFallback() async {
    final controleDxfs = await OpmetingDeurpaneelDxfTestBestanden.laadAlle();

    /*
     * JEF, HERMITAGE en VEDUO gebruiken tijdelijk bewust hun afzonderlijke
     * assetbestand als controlepad. Deze drie bestanden zijn nu de echte
     * leverancier-DXF's, niet de oude vereenvoudigde testtekeningen.
     *
     * Dit controlepad krijgt voor deze drie namen voorrang op dezelfde entry
     * uit de grote ZIP-bundel. Zo testen we de reeds bewezen rootBundle-route
     * zonder de schilder- of deurpaneellogica te wijzigen.
     *
     * Ze worden als automatische sleutels gemarkeerd en dus nooit naar
     * SharedPreferences/OneDrive weggeschreven.
     */
    for (final entry in controleDxfs.entries) {
      final sleutel = normaliseerBestandsnaam(entry.key);
      final inhoud = entry.value.trimRight();

      if (sleutel.isEmpty || inhoud.trim().isEmpty) {
        continue;
      }

      _dxfTeksten[sleutel] = inhoud;
      _automatischeTestSleutels.add(sleutel);
      _cache.remove(sleutel);
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

    // Een handmatig ingeladen DXF is bewust een override op dezelfde DXF uit
    // de leveranciersbundel.
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

    // Alleen een handmatige override wordt verwijderd. Wanneer dezelfde DXF
    // in de Frager-bundel zit, wordt die daarna automatisch opnieuw gebruikt.
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
      final sleutel = normaliseerBestandsnaam(entry.key);
      _dxfTeksten[sleutel] = entry.value;
      _automatischeTestSleutels.remove(sleutel);
    }

    _cache.clear();

    await OpmetingDeurpaneelDxfStorageHelper.bewaarDxfs(
      _alleenOpgeslagenDxfs(),
    );

    _geladen = true;
    versie.value++;
  }

  /// Wist alleen lokaal/handmatig opgeslagen DXF-overrides.
  /// De ingebouwde Frager-bundel blijft altijd beschikbaar.
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

    final gecachet = _cache[sleutel];
    if (gecachet != null) {
      return gecachet;
    }

    final inhoud = _inhoudVoorSleutel(sleutel);

    if (inhoud == null || inhoud.trim().isEmpty) {
      return null;
    }

    final tekening = OpmetingDeurpaneelDxfParser.parse(
      inhoud,
      bestandsnaam: sleutel,
    );

    _zetInCache(sleutel, tekening);
    return tekening;
  }

  static bool heeftDxfVoorBestandsnaam(String bestandsnaam) {
    return _bestaandeSleutelVoorBestandsnaam(bestandsnaam) != null;
  }

  static String statusVoorBestandsnaam(String bestandsnaam) {
    // Niet alle 566 DXF's hier parsen: deze functie wordt in de beheerpagina
    // voor iedere zichtbare rij aangeroepen. De bundel is vooraf gecontroleerd
    // en een geldige sleutel is daarom voldoende voor de status.
    return heeftDxfVoorBestandsnaam(bestandsnaam)
        ? 'DXF aanwezig'
        : 'DXF ontbreekt';
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

    if (_dxfTeksten.containsKey(sleutel) ||
        _fragerBestanden.containsKey(sleutel)) {
      return sleutel;
    }

    final alias = OpmetingDeurpaneelDxfTestBestanden.aliasVoorBestandsnaam(
      sleutel,
    );

    if (alias != null) {
      final aliasSleutel = normaliseerBestandsnaam(alias);
      if (_dxfTeksten.containsKey(aliasSleutel) ||
          _fragerBestanden.containsKey(aliasSleutel)) {
        return aliasSleutel;
      }
    }

    return null;
  }

  static String? _inhoudVoorSleutel(String sleutel) {
    final opgeslagen = _dxfTeksten[sleutel];
    if (opgeslagen != null && opgeslagen.trim().isNotEmpty) {
      return opgeslagen;
    }

    final bestand = _fragerBestanden[sleutel];
    if (bestand == null) {
      return null;
    }

    final bytes = bestand.readBytes();
    if (bytes == null || bytes.isEmpty) {
      return null;
    }

    return latin1.decode(bytes, allowInvalid: true).trimRight();
  }

  static void _zetInCache(
    String sleutel,
    OpmetingDeurpaneelDxfTekening tekening,
  ) {
    _cache.remove(sleutel);

    while (_cache.length >= _maxAantalGecachteTekeningen && _cache.isNotEmpty) {
      _cache.remove(_cache.keys.first);
    }

    _cache[sleutel] = tekening;
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
