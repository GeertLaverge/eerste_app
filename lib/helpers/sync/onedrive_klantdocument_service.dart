// THIMACO-CONTROLE: ONEDRIVE-KLANTDOCUMENTEN-MAPPEN-EN-BESTANDSNAAM-20260731
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'onedrive_auth_service.dart';

class OneDriveMapItem {
  const OneDriveMapItem({required this.id, required this.naam});

  final String id;
  final String naam;
}

class OneDriveGekozenMap {
  const OneDriveGekozenMap({
    required this.id,
    required this.pad,
    required this.bestandsnaam,
  });

  final String id;
  final String pad;
  final String bestandsnaam;
}

class OneDriveKlantdocumentResultaat {
  const OneDriveKlantdocumentResultaat({
    required this.documentType,
    required this.mapPad,
    required this.bestandsnaam,
    this.webUrl = '',
  });

  final String documentType;
  final String mapPad;
  final String bestandsnaam;
  final String webUrl;

  String get volledigPad => '$mapPad/$bestandsnaam';
}

class OneDriveKlantdocumentException implements Exception {
  const OneDriveKlantdocumentException(this.bericht);

  final String bericht;

  @override
  String toString() => bericht;
}

class OneDriveKlantdocumentService {
  OneDriveKlantdocumentService({OneDriveAuthService? authService})
    : _authService = authService ?? OneDriveAuthService();

  static const String _graphBasis = 'https://graph.microsoft.com/v1.0';
  static final RegExp _ongeldigeOneDriveTekens = RegExp(r'["*:<>?/\\|]');

  final OneDriveAuthService _authService;
  String? _token;

  static String normaliseerPdfBestandsnaam(String waarde) {
    final naam = waarde.trim();
    if (naam.isEmpty) return '';

    return naam.toLowerCase().endsWith('.pdf') ? naam : '$naam.pdf';
  }

  static String? valideerMapNaam(String waarde) {
    final naam = waarde.trim();

    if (naam.isEmpty) {
      return 'Geef een naam in voor de nieuwe map.';
    }
    if (naam == '.' || naam == '..') {
      return 'Deze mapnaam is niet toegestaan.';
    }
    if (_ongeldigeOneDriveTekens.hasMatch(naam)) {
      return 'De mapnaam bevat een teken dat OneDrive niet toestaat.';
    }
    if (naam.endsWith('.') || naam.endsWith(' ')) {
      return 'Een mapnaam mag niet eindigen met een punt of spatie.';
    }

    return null;
  }

  static String? valideerPdfBestandsnaam(String waarde) {
    final naam = normaliseerPdfBestandsnaam(waarde);

    if (naam.isEmpty) {
      return 'Geef een bestandsnaam in voor de PDF.';
    }
    if (_ongeldigeOneDriveTekens.hasMatch(naam)) {
      return 'De bestandsnaam bevat een teken dat OneDrive niet toestaat.';
    }
    if (naam.endsWith('.') || naam.endsWith(' ')) {
      return 'Een bestandsnaam mag niet eindigen met een punt of spatie.';
    }

    return null;
  }

  Future<List<OneDriveMapItem>> laadMappen({String? bovenliggendeMapId}) async {
    final eersteUrl = bovenliggendeMapId == null
        ? Uri.parse(
            '$_graphBasis/me/drive/root/children?'
            r'$select=id,name,folder&$top=200',
          )
        : Uri.parse(
            '$_graphBasis/me/drive/items/'
            '${Uri.encodeComponent(bovenliggendeMapId)}/children?'
            r'$select=id,name,folder&$top=200',
          );

    final mappen = <OneDriveMapItem>[];
    Uri? volgendeUrl = eersteUrl;

    while (volgendeUrl != null) {
      final response = await _getMetHerlogin(volgendeUrl);

      if (response.statusCode != 200) {
        throw OneDriveKlantdocumentException(
          _maakGraphFoutmelding(
            response,
            standaard: 'De OneDrive-map kon niet worden gelezen.',
          ),
        );
      }

      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        throw const OneDriveKlantdocumentException(
          'OneDrive gaf een onverwacht antwoord bij het openen van de map.',
        );
      }

      final items = data['value'];
      if (items is List) {
        for (final item in items) {
          if (item is! Map) continue;
          if (item['folder'] == null) continue;

          final id = item['id']?.toString().trim() ?? '';
          final naam = item['name']?.toString().trim() ?? '';

          if (id.isEmpty || naam.isEmpty) continue;
          mappen.add(OneDriveMapItem(id: id, naam: naam));
        }
      }

      final volgendeLink = data['@odata.nextLink']?.toString().trim() ?? '';
      volgendeUrl = volgendeLink.isEmpty ? null : Uri.tryParse(volgendeLink);
    }

    mappen.sort(
      (links, rechts) =>
          links.naam.toLowerCase().compareTo(rechts.naam.toLowerCase()),
    );

    return mappen;
  }

  Future<OneDriveMapItem> maakMap({
    String? bovenliggendeMapId,
    required String naam,
  }) async {
    final schoneNaam = naam.trim();
    final validatieFout = valideerMapNaam(schoneNaam);
    if (validatieFout != null) {
      throw OneDriveKlantdocumentException(validatieFout);
    }

    final url = bovenliggendeMapId == null
        ? Uri.parse('$_graphBasis/me/drive/root/children')
        : Uri.parse(
            '$_graphBasis/me/drive/items/'
            '${Uri.encodeComponent(bovenliggendeMapId)}/children',
          );

    final response = await _postJsonMetHerlogin(url, <String, dynamic>{
      'name': schoneNaam,
      'folder': <String, dynamic>{},
      '@microsoft.graph.conflictBehavior': 'fail',
    });

    if (response.statusCode == 409) {
      throw OneDriveKlantdocumentException(
        'Er bestaat al een map met de naam “$schoneNaam” in deze map.',
      );
    }

    if (response.statusCode != 201) {
      throw OneDriveKlantdocumentException(
        _maakGraphFoutmelding(
          response,
          standaard: 'De nieuwe OneDrive-map kon niet worden aangemaakt.',
        ),
      );
    }

    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic>) {
      throw const OneDriveKlantdocumentException(
        'OneDrive gaf geen geldige nieuwe map terug.',
      );
    }

    final id = data['id']?.toString().trim() ?? '';
    final teruggegevenNaam = data['name']?.toString().trim() ?? schoneNaam;

    if (id.isEmpty) {
      throw const OneDriveKlantdocumentException(
        'De nieuwe OneDrive-map heeft geen geldig mapnummer gekregen.',
      );
    }

    return OneDriveMapItem(id: id, naam: teruggegevenNaam);
  }

  Future<OneDriveKlantdocumentResultaat> uploadPdf({
    required OneDriveGekozenMap map,
    required String documentType,
    required String bestandsnaam,
    required Uint8List bytes,
  }) async {
    final schoneBestandsnaam = normaliseerPdfBestandsnaam(bestandsnaam);
    final validatieFout = valideerPdfBestandsnaam(schoneBestandsnaam);

    if (map.id.trim().isEmpty) {
      throw const OneDriveKlantdocumentException(
        'Er werd geen geldige OneDrive-map gekozen.',
      );
    }

    if (validatieFout != null) {
      throw OneDriveKlantdocumentException(validatieFout);
    }

    if (bytes.isEmpty) {
      throw const OneDriveKlantdocumentException(
        'De PDF is leeg en kan niet naar OneDrive worden verstuurd.',
      );
    }

    final mapId = Uri.encodeComponent(map.id);
    final bestand = Uri.encodeComponent(schoneBestandsnaam);
    final url = Uri.parse(
      '$_graphBasis/me/drive/items/$mapId:/$bestand:/content',
    );

    final response = await _putMetHerlogin(url, bytes);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw OneDriveKlantdocumentException(
        _maakGraphFoutmelding(
          response,
          standaard:
              'De PDF kon niet in de gekozen OneDrive-map worden opgeslagen.',
        ),
      );
    }

    String webUrl = '';
    try {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        webUrl = data['webUrl']?.toString().trim() ?? '';
      }
    } catch (_) {
      // De upload is al geslaagd. Een ontbrekende webUrl is niet fataal.
    }

    return OneDriveKlantdocumentResultaat(
      documentType: documentType,
      mapPad: map.pad,
      bestandsnaam: schoneBestandsnaam,
      webUrl: webUrl,
    );
  }

  Future<http.Response> _getMetHerlogin(Uri url) async {
    var token = await _haalToken();
    var response = await http.get(
      url,
      headers: <String, String>{'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      token = await _haalToken(forceerInteractief: true);
      response = await http.get(
        url,
        headers: <String, String>{'Authorization': 'Bearer $token'},
      );
    }

    return response;
  }

  Future<http.Response> _postJsonMetHerlogin(
    Uri url,
    Map<String, dynamic> inhoud,
  ) async {
    var token = await _haalToken();
    var response = await http.post(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(inhoud),
    );

    if (response.statusCode == 401) {
      token = await _haalToken(forceerInteractief: true);
      response = await http.post(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(inhoud),
      );
    }

    return response;
  }

  Future<http.Response> _putMetHerlogin(Uri url, Uint8List bytes) async {
    var token = await _haalToken();
    var response = await http.put(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/pdf',
      },
      body: bytes,
    );

    if (response.statusCode == 401) {
      token = await _haalToken(forceerInteractief: true);
      response = await http.put(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/pdf',
        },
        body: bytes,
      );
    }

    return response;
  }

  Future<String> _haalToken({bool forceerInteractief = false}) async {
    if (!forceerInteractief && _token != null && _token!.isNotEmpty) {
      return _token!;
    }

    final token = forceerInteractief
        ? await _authService.loginInteractief()
        : await _authService.login();

    if (token.startsWith('FOUT') || token.trim().isEmpty) {
      throw OneDriveKlantdocumentException(
        'Aanmelden bij OneDrive is niet gelukt.\n$token',
      );
    }

    _token = token;
    return token;
  }

  String _maakGraphFoutmelding(
    http.Response response, {
    required String standaard,
  }) {
    String detail = '';

    try {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        final error = data['error'];
        if (error is Map) {
          detail = error['message']?.toString().trim() ?? '';
        }
      }
    } catch (_) {
      detail = response.body.trim();
    }

    final code = response.statusCode;
    if (detail.isEmpty) {
      return '$standaard (OneDrive-fout $code)';
    }

    return '$standaard\nOneDrive-fout $code: $detail';
  }
}
