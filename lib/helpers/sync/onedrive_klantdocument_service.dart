// THIMACO-CONTROLE: ONEDRIVE-KLANTDOCUMENTEN-STAP-2-20260731
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
  const OneDriveGekozenMap({required this.id, required this.pad});

  final String id;
  final String pad;
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

  final OneDriveAuthService _authService;
  String? _token;

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

  Future<OneDriveKlantdocumentResultaat> uploadPdf({
    required OneDriveGekozenMap map,
    required String documentType,
    required String bestandsnaam,
    required Uint8List bytes,
  }) async {
    final schoneBestandsnaam = bestandsnaam.trim();

    if (map.id.trim().isEmpty) {
      throw const OneDriveKlantdocumentException(
        'Er werd geen geldige OneDrive-map gekozen.',
      );
    }

    if (schoneBestandsnaam.isEmpty) {
      throw const OneDriveKlantdocumentException(
        'De PDF heeft geen geldige bestandsnaam.',
      );
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

    var token = forceerInteractief
        ? await _authService.loginInteractief()
        : await _authService.tokenSilent();

    if (!forceerInteractief && token.startsWith('FOUT')) {
      token = await _authService.loginInteractief();
    }

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
