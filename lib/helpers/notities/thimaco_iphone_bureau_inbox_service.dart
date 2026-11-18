// THIMACO-IPHONENOTITIES-V10: afzonderlijke, append-only OneDrive-inbox.
// Elke notitie wordt pas zichtbaar na upload van ALLE fotos.
// De bureaucomputers halen de berichten zelf op; de gedeelde notitie-sync
// verspreidt daarna de gewone NotitieModel-records naar de andere computer.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../sync/onedrive_auth_service.dart';
import 'notitie_model.dart';

class ThimacoIphoneBureauInboxService {
  static const _basis = 'https://graph.microsoft.com/v1.0/me/drive/special/approot';
  static const _map = 'thimaco_iphone_bureau_inbox_v1';
  static final _veiligBestand = RegExp(r'^[a-zA-Z0-9_.-]+$');
  static const _timeout = Duration(seconds: 35);
  final OneDriveAuthService _auth = OneDriveAuthService();

  Future<String> _token() async {
    final token = await _auth.tokenVoorGraph();
    if (token.trim().isEmpty || token.startsWith('FOUT')) {
      throw StateError('Microsoft is niet aangemeld. Gebruik eerst Aanmelden Microsoft.');
    }
    return token;
  }

  Map<String, String> _headers(String token, {String? contentType}) => {
    'Authorization': 'Bearer $token',
    if (contentType != null) 'Content-Type': contentType,
  };

  String _bestandPad(String naam) {
    if (!_veiligBestand.hasMatch(naam) || naam.contains('..')) {
      throw const FormatException('Ongeldige bestandsnaam in bureaunotitie.');
    }
    return '$_basis:/$_map/$naam:/content';
  }

  Future<void> _mapMaken(String token) async {
    final controle = await http.get(
      Uri.parse('$_basis:/$_map:'), headers: _headers(token),
    ).timeout(_timeout);
    if (controle.statusCode == 200) return;
    if (controle.statusCode != 404) {
      throw StateError('OneDrive-map controleren mislukt (${controle.statusCode}).');
    }
    final gemaakt = await http.post(
      Uri.parse('$_basis/children'),
      headers: _headers(token, contentType: 'application/json'),
      body: jsonEncode({
        'name': _map,
        'folder': <String, Object>{},
        '@microsoft.graph.conflictBehavior': 'fail',
      }),
    ).timeout(_timeout);
    // 409: de andere iPhone heeft de map intussen gemaakt.
    if (gemaakt.statusCode != 201 && gemaakt.statusCode != 200 &&
        gemaakt.statusCode != 409) {
      throw StateError('OneDrive-inbox aanmaken mislukt (${gemaakt.statusCode}).');
    }
  }

  Future<void> _plaatsBestand(
      String token, String naam, List<int> inhoud, String mime) async {
    final antwoord = await http.put(
      Uri.parse(_bestandPad(naam)),
      headers: _headers(token, contentType: mime),
      body: inhoud,
    ).timeout(_timeout);
    if (antwoord.statusCode != 200 && antwoord.statusCode != 201) {
      throw StateError('Bijlage of notitie uploaden mislukt (${antwoord.statusCode}).');
    }
  }

  // Explicit gebruikersactie: automatische synchronisatie toont nooit zelf
  // een Microsoft-aanmeldvenster.
  Future<void> aanmeldenMicrosoft() async {
    final resultaat = await _auth.loginInteractief();
    if (resultaat.trim().isEmpty || resultaat.startsWith('FOUT')) {
      throw StateError('Aanmelden Microsoft mislukt. Controleer de accounttoegang.');
    }
  }

  Future<void> publiceerNotitie(Map<String, dynamic> record) async {
    final id = (record['id'] ?? '').toString();
    if (!RegExp(r'^iphone-[0-9]+(?:-[a-zA-Z0-9]+)?$').hasMatch(id)) {
      throw const FormatException('Ongeldig ID van de iPhone-notitie.');
    }
    final klantnaam = (record['klantnaam'] ?? '').toString().trim();
    final inhoud = (record['notitie'] ?? '').toString().trim();
    if (klantnaam.isEmpty || inhoud.isEmpty) {
      throw const FormatException('Klantnaam en notitie zijn verplicht.');
    }
    final token = await _token();
    await _mapMaken(token);
    final fotos = (record['fotos'] is List)
        ? (record['fotos'] as List).whereType<String>().toList()
        : <String>[];
    final bestanden = <String>[];
    for (var i = 0; i < fotos.length; i++) {
      final lokaal = File(fotos[i]);
      if (!await lokaal.exists()) {
        throw StateError('Foto ${i + 1} ontbreekt op dit toestel. Verzending gestopt.');
      }
      final extensie = fotos[i].toLowerCase().endsWith('.png') ? 'png'
          : fotos[i].toLowerCase().endsWith('.heic') ? 'heic'
          : fotos[i].toLowerCase().endsWith('.webp') ? 'webp' : 'jpg';
      final naam = '${id}_foto_${i + 1}.$extensie';
      final mime = extensie == 'png' ? 'image/png'
          : extensie == 'heic' ? 'image/heic'
          : extensie == 'webp' ? 'image/webp' : 'image/jpeg';
      await _plaatsBestand(token, naam, await lokaal.readAsBytes(), mime);
      bestanden.add(naam);
    }
    // Pas na alle geslaagde foto-uploads het JSON-bericht plaatsen.
    final bericht = <String, dynamic>{
      'schema': 1,
      'id': id,
      'klantnaam': klantnaam,
      'notitie': inhoud,
      'aangemaaktOp': (record['aangemaaktOp'] ?? '').toString(),
      'fotos': bestanden,
      'bron': 'Thimaco iPhone',
    };
    final bestandsnaam = '$id.json';
    await _plaatsBestand(
      token, bestandsnaam, utf8.encode(jsonEncode(bericht)), 'application/json');
    // Controle: het bericht moet ook opnieuw leesbaar zijn.
    final bevestiging = await http.get(
      Uri.parse(_bestandPad(bestandsnaam)), headers: _headers(token),
    ).timeout(_timeout);
    if (bevestiging.statusCode != 200) {
      throw StateError('OneDrive heeft de ontvangst nog niet bevestigd.');
    }
    final gelezen = jsonDecode(utf8.decode(bevestiging.bodyBytes));
    if (gelezen is! Map || gelezen['id'] != id) {
      throw StateError('Ontvangstcontrole van de notitie mislukt.');
    }
  }

  Future<List<NotitieModel>> haalNieuweNotities(Set<String> bestaandeIds) async {
    final token = await _token();
    var url = '$_basis:/$_map:/children?\$top=200';
    final namen = <String>[];
    // Een 404 betekent dat nog geen iPhone een notitie heeft verstuurd.
    for (var pagina = 0; pagina < 10 && url.isNotEmpty; pagina++) {
      final antwoord = await http.get(Uri.parse(url), headers: _headers(token))
          .timeout(_timeout);
      if (antwoord.statusCode == 404) return <NotitieModel>[];
      if (antwoord.statusCode != 200) {
        throw StateError('OneDrive-inbox lezen mislukt (${antwoord.statusCode}).');
      }
      final data = jsonDecode(utf8.decode(antwoord.bodyBytes));
      if (data is! Map || data['value'] is! List) {
        throw const FormatException('Ongeldige OneDrive-inbox.');
      }
      for (final kind in (data['value'] as List)) {
        if (kind is! Map) continue;
        final naam = (kind['name'] ?? '').toString();
        if (RegExp(r'^iphone-[0-9]+(?:-[a-zA-Z0-9]+)?\.json$').hasMatch(naam)
            && !bestaandeIds.contains(naam.substring(0, naam.length - 5))) {
          namen.add(naam);
        }
      }
      final volgende = (data['@odata.nextLink'] ?? '').toString();
      if (volgende.isNotEmpty &&
          Uri.tryParse(volgende)?.host != 'graph.microsoft.com') {
        throw const FormatException('Ongeldige pagina in OneDrive-antwoord.');
      }
      url = volgende;
    }
    final nieuw = <NotitieModel>[];
    // Beperkte import per ronde: 60 records; de timer haalt de rest later op.
    for (final naam in namen.take(60)) {
      final antwoord = await http.get(
        Uri.parse(_bestandPad(naam)), headers: _headers(token),
      ).timeout(_timeout);
      if (antwoord.statusCode != 200) {
        throw StateError('Notitie $naam ophalen mislukt (${antwoord.statusCode}).');
      }
      final data = jsonDecode(utf8.decode(antwoord.bodyBytes));
      if (data is! Map) throw const FormatException('Ongeldig notitiebericht.');
      final id = (data['id'] ?? '').toString();
      if ('$id.json' != naam) throw const FormatException('Notitie-ID komt niet overeen.');
      final klant = (data['klantnaam'] ?? '').toString().trim();
      final tekst = (data['notitie'] ?? '').toString().trim();
      if (klant.isEmpty || tekst.isEmpty) {
        throw const FormatException('Onvolledige ontvangen notitie.');
      }
      final fotos = <String>[];
      if (data['fotos'] is List) {
        for (final bestand in (data['fotos'] as List).whereType<String>()) {
          if (_veiligBestand.hasMatch(bestand) && !bestand.contains('..') &&
              bestand.startsWith('${id}_foto_')) {
            fotos.add(bestand);
          }
        }
      }
      final aangemaakt = DateTime.tryParse((data['aangemaaktOp'] ?? '').toString())
          ?? DateTime.now();
      final datum = '${aangemaakt.year.toString().padLeft(4, '0')}-'
          '${aangemaakt.month.toString().padLeft(2, '0')}-'
          '${aangemaakt.day.toString().padLeft(2, '0')}';
      nieuw.add(NotitieModel(
        id: id,
        datumKey: datum,
        titel: klant,
        detail: tekst,
        iphoneFotoBestanden: fotos,
        aangemaaktOp: aangemaakt,
        gewijzigdOp: aangemaakt,
      ));
    }
    return nieuw;
  }

  Future<Uint8List> downloadFoto(String bestand) async {
    final token = await _token();
    final antwoord = await http.get(
      Uri.parse(_bestandPad(bestand)), headers: _headers(token),
    ).timeout(_timeout);
    if (antwoord.statusCode != 200) {
      throw StateError('Foto laden uit OneDrive mislukt (${antwoord.statusCode}).');
    }
    return antwoord.bodyBytes;
  }
}
