import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../helpers/bibliotheek/bibliotheek_model.dart';
import '../helpers/klanten/fiche/klantenfiche_model.dart';
import '../helpers/klanten/fiche/klantenfiche_service.dart';
import '../helpers/sync/onedrive_auth_service.dart';

typedef LeveringRegel = ({
  String klantId,
  String versie,
  int index,
  String klant,
  String leverancier,
  String artikel,
});

Map<String, dynamic> _leesBibliotheek(Uint8List bytes) {
  final backup = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
  final waarde = backup['bibliotheek'];
  return waarde == null || waarde == ''
      ? <String, dynamic>{}
      : jsonDecode(waarde as String) as Map<String, dynamic>;
}

class ThimacoIphoneBureaugegevens {
  final _auth = OneDriveAuthService();
  static const _basis = 'https://graph.microsoft.com/v1.0/me/drive/special/approot';
  static const _klanten = 'thimaco_sync_klanten.json';
  static const _timeout = Duration(seconds: 60);

  Uri _bestand(String naam, {bool inhoud = true}) =>
      Uri.parse('$_basis:/$naam${inhoud ? ":/content" : ""}');

  Future<Map<String, String>> _headers({required bool aanmelden}) async {
    var token = await _auth.tokenSilent();
    if (aanmelden && (token.isEmpty || token.startsWith('FOUT'))) {
      token = await _auth.loginInteractief();
    }
    if (token.isEmpty || token.startsWith('FOUT')) {
      throw StateError('Meld je aan bij Microsoft via Vernieuwen.');
    }
    return {'Authorization': 'Bearer $token'};
  }

  Future<http.Response> _haal(Uri uri, Map<String, String> headers) async {
    final antwoord = await http.get(uri, headers: headers).timeout(_timeout);
    if (antwoord.statusCode != 200) {
      throw StateError('Bureaugegevens ophalen mislukt (${antwoord.statusCode}).');
    }
    return antwoord;
  }

  Future<BibliotheekData> laadBibliotheek({required bool aanmelden}) async {
    final antwoord = await _haal(
      _bestand('thimaco_backup.json'),
      await _headers(aanmelden: aanmelden),
    );
    return BibliotheekData.fromJson(await compute(_leesBibliotheek, antwoord.bodyBytes));
  }

  List<Map<String, dynamic>> _fiches(Map<String, dynamic> module) {
    if (module['module'] != 'klanten' || module['klantenFiches'] is! String) {
      throw const FormatException('Ongeldig klantenbestand van bureau.');
    }
    final fiches = jsonDecode(module['klantenFiches'] as String) as List;
    return fiches.cast<Map<String, dynamic>>();
  }

  bool _actief(Map<String, dynamic> fiche) =>
      (fiche['deletedAt'] ?? '').toString().trim().isEmpty &&
      (fiche['archiefDatum'] ?? '').toString().trim().isEmpty &&
      (fiche['klantStatus'] ?? '').toString().trim().toLowerCase() == 'actief';

  Future<List<LeveringRegel>> laadLeveringen({required bool aanmelden}) async {
    final antwoord = await _haal(_bestand(_klanten), await _headers(aanmelden: aanmelden));
    final module = jsonDecode(utf8.decode(antwoord.bodyBytes)) as Map<String, dynamic>;
    return [
      for (final fiche in _fiches(module).where(_actief))
        for (final (index, artikel) in (fiche['artikelen'] as List? ?? const []).indexed)
          if (artikel is Map && artikel['besteld'] == true && artikel['geleverd'] != true)
            (
              klantId: fiche['id'].toString(),
              versie: (fiche['updatedAt'] ?? '').toString(),
              index: index,
              klant: (fiche['naam'] ?? '').toString(),
              leverancier: (artikel['leverancier'] ?? '').toString(),
              artikel: (artikel['artikel'] ?? '').toString(),
            ),
    ];
  }

  Future<void> bevestigLeveringen(Set<LeveringRegel> regels) async {
    final headers = await _headers(aanmelden: false);
    final metadata = await _haal(_bestand(_klanten, inhoud: false), headers);
    final etag = (jsonDecode(metadata.body) as Map)['eTag'];
    if (etag is! String || etag.trim().isEmpty) {
      throw StateError('OneDrive gaf geen versie voor het klantenbestand.');
    }
    final antwoord = await _haal(_bestand(_klanten), headers);
    final module = jsonDecode(utf8.decode(antwoord.bodyBytes)) as Map<String, dynamic>;
    final fiches = _fiches(module);
    final perId = {for (final fiche in fiches) (fiche['id'] ?? '').toString(): fiche};
    final gewijzigd = <Map<String, dynamic>>{};
    for (final regel in regels) {
      final fiche = perId[regel.klantId];
      final artikelen = fiche?['artikelen'];
      if (fiche == null || !_actief(fiche) || artikelen is! List ||
          regel.index >= artikelen.length) {
        throw StateError('Een artikel is op bureau gewijzigd. Vernieuw de lijst.');
      }
      final artikel = artikelen[regel.index];
      if (artikel is! Map<String, dynamic> ||
          (artikel['leverancier'] ?? '').toString() != regel.leverancier ||
          (artikel['artikel'] ?? '').toString() != regel.artikel ||
          artikel['besteld'] != true) {
        throw StateError('Een artikel is op bureau gewijzigd. Vernieuw de lijst.');
      }
      if (artikel['geleverd'] == true) continue;
      if ((fiche['updatedAt'] ?? '').toString() != regel.versie) {
        throw StateError('Een klantenfiche is op bureau gewijzigd. Vernieuw de lijst.');
      }
      artikel['geleverd'] = true;
      gewijzigd.add(fiche);
    }
    if (gewijzigd.isEmpty) return;
    final nu = DateTime.now().toUtc().toIso8601String();
    for (final fiche in gewijzigd) {
      fiche['updatedAt'] = nu;
      fiche['bestelStatus'] = KlantenficheService.berekenBestelStatus(
        (fiche['artikelen'] as List)
            .cast<Map<String, dynamic>>()
            .map(KlantenficheArtikel.fromJson).toList(),
      );
    }
    module['moduleDatum'] = nu;
    module['klantenFiches'] = jsonEncode(fiches);
    final upload = await http.put(_bestand(_klanten), headers: {
      ...headers,
      'If-Match': etag,
      'Content-Type': 'application/json',
    }, body: utf8.encode(jsonEncode(module))).timeout(_timeout);
    if (upload.statusCode == 412) {
      throw StateError('Het klantenbestand is intussen gewijzigd. Vernieuw de lijst.');
    }
    if (upload.statusCode != 200 && upload.statusCode != 201) {
      throw StateError('Leveringen opslaan mislukt (${upload.statusCode}).');
    }
  }
}
