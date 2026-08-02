// THIMACO-CONTROLE: ONEDRIVE-AFBEELDINGEN-KIEZER-20260801
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'onedrive_auth_service.dart';

class OneDriveAfbeeldingItem {
  const OneDriveAfbeeldingItem({
    required this.id,
    required this.naam,
    required this.isMap,
    this.mimeType = '',
    this.grootte = 0,
  });

  final String id;
  final String naam;
  final bool isMap;
  final String mimeType;
  final int grootte;
}

class OneDriveAfbeeldingDownload {
  const OneDriveAfbeeldingDownload({
    required this.bytes,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String mimeType;
}

class OneDriveAfbeeldingException implements Exception {
  const OneDriveAfbeeldingException(this.bericht);

  final String bericht;

  @override
  String toString() => bericht;
}

class OneDriveAfbeeldingService {
  OneDriveAfbeeldingService({OneDriveAuthService? authService})
    : _authService = authService ?? OneDriveAuthService();

  static const String _graphBasis = 'https://graph.microsoft.com/v1.0';
  static const int maximumBestandsgrootte = 15 * 1024 * 1024;

  final OneDriveAuthService _authService;
  String? _token;

  Future<List<OneDriveAfbeeldingItem>> laadItems({String? mapId}) async {
    final token = await _geldigToken();
    final url = mapId == null || mapId.trim().isEmpty
        ? '$_graphBasis/me/drive/root/children'
        : '$_graphBasis/me/drive/items/${Uri.encodeComponent(mapId)}/children';
    final uri = Uri.parse(url).replace(
      queryParameters: const <String, String>{
        r'$select': 'id,name,size,file,folder',
        r'$top': '999',
      },
    );
    final response = await http.get(
      uri,
      headers: <String, String>{'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw OneDriveAfbeeldingException(
        'De OneDrive-map kon niet worden gelezen '
        '(${response.statusCode}).',
      );
    }

    final data = jsonDecode(response.body);
    if (data is! Map || data['value'] is! List) {
      return const <OneDriveAfbeeldingItem>[];
    }

    final items = <OneDriveAfbeeldingItem>[];
    for (final raw in (data['value'] as List).whereType<Map>()) {
      final item = Map<String, dynamic>.from(raw);
      final id = item['id']?.toString().trim() ?? '';
      final naam = item['name']?.toString().trim() ?? '';
      if (id.isEmpty || naam.isEmpty) continue;

      final isMap = item['folder'] is Map;
      final mimeType = item['file'] is Map
          ? (Map<String, dynamic>.from(
                  item['file'] as Map,
                )['mimeType']?.toString() ??
                '')
          : '';
      if (!isMap && !_isOndersteundeAfbeelding(naam, mimeType)) continue;

      items.add(
        OneDriveAfbeeldingItem(
          id: id,
          naam: naam,
          isMap: isMap,
          mimeType: mimeType,
          grootte: _leesInt(item['size']),
        ),
      );
    }

    items.sort((eerste, tweede) {
      if (eerste.isMap != tweede.isMap) return eerste.isMap ? -1 : 1;
      return eerste.naam.toLowerCase().compareTo(tweede.naam.toLowerCase());
    });
    return List<OneDriveAfbeeldingItem>.unmodifiable(items);
  }

  Future<OneDriveAfbeeldingDownload> downloadAfbeelding(
    OneDriveAfbeeldingItem item,
  ) async {
    if (item.isMap) {
      throw const OneDriveAfbeeldingException('Een map is geen afbeelding.');
    }
    if (item.grootte > maximumBestandsgrootte) {
      throw const OneDriveAfbeeldingException(
        'De afbeelding is groter dan 15 MB.',
      );
    }

    final token = await _geldigToken();
    final response = await http.get(
      Uri.parse(
        '$_graphBasis/me/drive/items/${Uri.encodeComponent(item.id)}/content',
      ),
      headers: <String, String>{'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw OneDriveAfbeeldingException(
        'De afbeelding kon niet worden gedownload '
        '(${response.statusCode}).',
      );
    }
    if (response.bodyBytes.isEmpty) {
      throw const OneDriveAfbeeldingException('De afbeelding is leeg.');
    }
    if (response.bodyBytes.length > maximumBestandsgrootte) {
      throw const OneDriveAfbeeldingException(
        'De afbeelding is groter dan 15 MB.',
      );
    }

    final ontvangenType = response.headers['content-type']?.split(';').first;
    final mimeType = _mimeTypeVoor(
      item.naam,
      ontvangenType?.trim().isNotEmpty == true
          ? ontvangenType!.trim()
          : item.mimeType,
    );
    return OneDriveAfbeeldingDownload(
      bytes: response.bodyBytes,
      mimeType: mimeType,
    );
  }

  Future<String> _geldigToken() async {
    final bestaand = _token?.trim() ?? '';
    if (bestaand.isNotEmpty) return bestaand;

    final token = await _authService.login();
    if (token.trim().isEmpty || token.startsWith('FOUT')) {
      throw OneDriveAfbeeldingException(
        'Aanmelden bij OneDrive is niet gelukt.\n$token',
      );
    }
    _token = token.trim();
    return _token!;
  }

  static bool _isOndersteundeAfbeelding(String naam, String mimeType) {
    final type = mimeType.trim().toLowerCase();
    if (type == 'image/jpeg' || type == 'image/png') {
      return true;
    }
    final lager = naam.trim().toLowerCase();
    return lager.endsWith('.jpg') ||
        lager.endsWith('.jpeg') ||
        lager.endsWith('.png');
  }

  static String _mimeTypeVoor(String naam, String bestaand) {
    final type = bestaand.trim().toLowerCase();
    if (type == 'image/png' || type == 'image/jpeg') {
      return type;
    }
    final lager = naam.toLowerCase();
    if (lager.endsWith('.png')) return 'image/png';
    return 'image/jpeg';
  }

  static int _leesInt(Object? waarde) {
    if (waarde is int) return waarde;
    if (waarde is num) return waarde.toInt();
    return int.tryParse(waarde?.toString() ?? '') ?? 0;
  }
}
