// THIMACO-CONTROLE: ALGEMENE-BIBLIOTHEEK-ONEDRIVE-SERVICE-20260802

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../sync/onedrive_auth_service.dart';

class BibliotheekOneDriveItem {
  const BibliotheekOneDriveItem({
    required this.id,
    required this.naam,
    required this.isMap,
    required this.webUrl,
    required this.grootte,
  });

  final String id;
  final String naam;
  final bool isMap;
  final String webUrl;
  final int grootte;

  bool get isPdf => !isMap && naam.trim().toLowerCase().endsWith('.pdf');
}

class BibliotheekOneDriveService {
  BibliotheekOneDriveService({OneDriveAuthService? authService})
    : _authService = authService ?? OneDriveAuthService();

  static const String _graphBasis = 'https://graph.microsoft.com/v1.0';

  final OneDriveAuthService _authService;
  String? _token;

  Future<List<BibliotheekOneDriveItem>> laadItems({String? mapId}) async {
    final eersteUrl = mapId == null
        ? Uri.parse(
            '$_graphBasis/me/drive/root/children?'
            r'$select=id,name,folder,file,size,webUrl&$top=200',
          )
        : Uri.parse(
            '$_graphBasis/me/drive/items/${Uri.encodeComponent(mapId)}/children?'
            r'$select=id,name,folder,file,size,webUrl&$top=200',
          );

    final resultaat = <BibliotheekOneDriveItem>[];
    Uri? volgendeUrl = eersteUrl;

    while (volgendeUrl != null) {
      final response = await _getMetHerlogin(volgendeUrl);

      if (response.statusCode != 200) {
        throw BibliotheekOneDriveException(
          _foutmelding(
            response,
            standaard: 'De OneDrive-map kon niet worden gelezen.',
          ),
        );
      }

      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        throw const BibliotheekOneDriveException(
          'OneDrive gaf een onverwacht antwoord terug.',
        );
      }

      final items = data['value'];
      if (items is List) {
        for (final ruwItem in items) {
          if (ruwItem is! Map) continue;

          final item = Map<String, dynamic>.from(ruwItem);
          final id = item['id']?.toString().trim() ?? '';
          final naam = item['name']?.toString().trim() ?? '';
          final isMap = item['folder'] != null;

          if (id.isEmpty || naam.isEmpty) continue;
          if (!isMap && !naam.toLowerCase().endsWith('.pdf')) continue;

          resultaat.add(
            BibliotheekOneDriveItem(
              id: id,
              naam: naam,
              isMap: isMap,
              webUrl: item['webUrl']?.toString().trim() ?? '',
              grootte: int.tryParse(item['size']?.toString() ?? '') ?? 0,
            ),
          );
        }
      }

      final volgendeLink = data['@odata.nextLink']?.toString().trim() ?? '';
      volgendeUrl = volgendeLink.isEmpty ? null : Uri.tryParse(volgendeLink);
    }

    resultaat.sort((links, rechts) {
      if (links.isMap != rechts.isMap) {
        return links.isMap ? -1 : 1;
      }
      return links.naam.toLowerCase().compareTo(rechts.naam.toLowerCase());
    });

    return resultaat;
  }

  Future<Uint8List> downloadPdf(String itemId) async {
    final schoonId = itemId.trim();
    if (schoonId.isEmpty) {
      throw const BibliotheekOneDriveException(
        'Deze folder heeft geen geldig OneDrive-bestand.',
      );
    }

    final url = Uri.parse(
      '$_graphBasis/me/drive/items/${Uri.encodeComponent(schoonId)}/content',
    );
    final response = await _getMetHerlogin(url);

    if (response.statusCode != 200) {
      throw BibliotheekOneDriveException(
        _foutmelding(
          response,
          standaard: 'De PDF kon niet uit OneDrive worden geopend.',
        ),
      );
    }

    if (response.bodyBytes.isEmpty) {
      throw const BibliotheekOneDriveException('De gekozen PDF is leeg.');
    }

    return response.bodyBytes;
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

  Future<String> _haalToken({bool forceerInteractief = false}) async {
    if (!forceerInteractief && _token != null && _token!.trim().isNotEmpty) {
      return _token!;
    }

    final token = forceerInteractief
        ? await _authService.loginInteractief()
        : await _authService.login();

    if (token.trim().isEmpty || token.startsWith('FOUT')) {
      throw BibliotheekOneDriveException(
        'Aanmelden bij OneDrive is niet gelukt.\n$token',
      );
    }

    _token = token;
    return token;
  }

  String _foutmelding(http.Response response, {required String standaard}) {
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

    if (detail.isEmpty) {
      return '$standaard (OneDrive-fout ${response.statusCode})';
    }

    return '$standaard\nOneDrive-fout ${response.statusCode}: $detail';
  }
}

class BibliotheekOneDriveException implements Exception {
  const BibliotheekOneDriveException(this.bericht);

  final String bericht;

  @override
  String toString() => bericht;
}
