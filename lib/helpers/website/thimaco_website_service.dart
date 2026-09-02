import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../sync/onedrive_auth_service.dart';

class WebsiteShowroomBooking {
  const WebsiteShowroomBooking({
    required this.id,
    required this.reference,
    required this.datum,
    required this.startTijd,
    required this.eindTijd,
    required this.projecten,
    required this.klantNaam,
    required this.email,
    required this.gsm,
    required this.locatie,
    required this.notitie,
  });

  final String id;
  final String reference;
  final DateTime datum;
  final String startTijd;
  final String eindTijd;
  final List<String> projecten;
  final String klantNaam;
  final String email;
  final String gsm;
  final String locatie;
  final String notitie;

  factory WebsiteShowroomBooking.fromJson(Map<String, dynamic> json) {
    return WebsiteShowroomBooking(
      id: json['id']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      datum: DateTime.tryParse(json['booking_date']?.toString() ?? '') ??
          DateTime(2000),
      startTijd: _tijdZonderSeconden(json['start_time']?.toString() ?? ''),
      eindTijd: _tijdZonderSeconden(json['end_time']?.toString() ?? ''),
      projecten: (json['projects'] as List<dynamic>? ?? const <dynamic>[])
          .map((e) => e.toString())
          .toList(growable: false),
      klantNaam: json['customer_name']?.toString() ?? '',
      email: json['customer_email']?.toString() ?? '',
      gsm: json['customer_phone']?.toString() ?? '',
      locatie: json['customer_location']?.toString() ?? '',
      notitie: json['notes']?.toString() ?? '',
    );
  }
}

class WebsiteShowroomBlock {
  const WebsiteShowroomBlock({
    required this.id,
    required this.datum,
    required this.startMinuut,
    required this.eindMinuut,
    required this.reden,
    required this.notitie,
    required this.source,
    required this.agendaItemId,
  });

  final String id;
  final DateTime datum;
  final int startMinuut;
  final int eindMinuut;
  final String reden;
  final String notitie;
  final String source;
  final String agendaItemId;

  bool get isAgendaBlokkering => agendaItemId.trim().isNotEmpty;

  factory WebsiteShowroomBlock.fromJson(Map<String, dynamic> json) {
    return WebsiteShowroomBlock(
      id: json['id']?.toString() ?? '',
      datum: DateTime.tryParse(json['block_date']?.toString() ?? '') ??
          DateTime(2000),
      startMinuut: int.tryParse(json['start_minute']?.toString() ?? '') ?? 0,
      eindMinuut: int.tryParse(json['end_minute']?.toString() ?? '') ?? 0,
      reden: json['reason']?.toString() ?? '',
      notitie: json['note']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      agendaItemId: json['agenda_item_id']?.toString() ?? '',
    );
  }
}

class WebsiteBericht {
  const WebsiteBericht({
    required this.id,
    required this.type,
    required this.tekst,
    required this.vanaf,
    required this.tot,
    required this.actief,
  });

  final String id;
  final String type;
  final String tekst;
  final DateTime vanaf;
  final DateTime tot;
  final bool actief;

  factory WebsiteBericht.fromJson(Map<String, dynamic> json) {
    return WebsiteBericht(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Mededeling',
      tekst: json['message']?.toString() ?? '',
      vanaf: DateTime.tryParse(json['starts_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      tot: DateTime.tryParse(json['ends_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now().add(const Duration(days: 1)),
      actief: json['active'] == true,
    );
  }
}

class WebsiteShowroomData {
  const WebsiteShowroomData({
    required this.bookings,
    required this.blocks,
    required this.bericht,
  });

  final List<WebsiteShowroomBooking> bookings;
  final List<WebsiteShowroomBlock> blocks;
  final WebsiteBericht? bericht;
}

class ThimacoWebsiteService {
  ThimacoWebsiteService({OneDriveAuthService? authService})
      : _authService = authService ?? OneDriveAuthService();

  final OneDriveAuthService _authService;

  static const String _releaseBasisUrl = 'https://thimaco.be';

  static String get basisUrl {
    const viaDefine = String.fromEnvironment('THIMACO_WEBSITE_URL');
    if (viaDefine.trim().isNotEmpty) return viaDefine.trim();
    return kDebugMode ? 'http://localhost:3000' : _releaseBasisUrl;
  }

  Uri _beheerUri({Map<String, String>? query}) {
    return Uri.parse('$basisUrl/api/thimaco-app/website-beheer')
        .replace(queryParameters: query);
  }

  Future<WebsiteShowroomData> laadMaand(DateTime maand) async {
    final eerste = DateTime(maand.year, maand.month, 1);
    final laatste = DateTime(maand.year, maand.month + 1, 0);

    final response = await _request(
      method: 'GET',
      uri: _beheerUri(
        query: <String, String>{
          'from': _datumKey(eerste),
          'to': _datumKey(laatste),
        },
      ),
    );

    final data = _decodeMap(response);

    final bookings = (data['bookings'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map>()
        .map((json) => WebsiteShowroomBooking.fromJson(
              Map<String, dynamic>.from(json),
            ))
        .toList(growable: false);

    final blocks = (data['blocks'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map>()
        .map((json) => WebsiteShowroomBlock.fromJson(
              Map<String, dynamic>.from(json),
            ))
        .toList(growable: false);

    WebsiteBericht? bericht;
    if (data['announcement'] is Map) {
      bericht = WebsiteBericht.fromJson(
        Map<String, dynamic>.from(data['announcement'] as Map),
      );
    }

    return WebsiteShowroomData(
      bookings: bookings,
      blocks: blocks,
      bericht: bericht,
    );
  }

  Future<bool> bewaarAgendaBlokkering({
    required String agendaItemId,
    required DateTime datum,
    required int startMinuut,
    required int eindMinuut,
  }) async {
    final id = agendaItemId.trim();
    if (id.isEmpty) {
      throw const WebsiteServiceException(
        'Agenda-item-ID ontbreekt voor websiteblokkering.',
      );
    }

    final response = await _request(
      method: 'POST',
      uri: _beheerUri(),
      jsonBody: <String, dynamic>{
        'action': 'upsert_agenda_block',
        'agendaItemId': id,
        'blockDate': _datumKey(datum),
        'startMinute': startMinuut,
        'endMinute': eindMinuut,
      },
    );

    final data = _decodeMap(response);
    return data['coveredByBooking'] == true;
  }

  Future<void> verwijderAgendaBlokkering(String agendaItemId) async {
    final id = agendaItemId.trim();
    if (id.isEmpty) {
      return;
    }

    final response = await _request(
      method: 'POST',
      uri: _beheerUri(),
      jsonBody: <String, dynamic>{
        'action': 'delete_agenda_block',
        'agendaItemId': id,
      },
    );

    _decodeMap(response);
  }

  Future<void> voegBlokkeringToe({
    required DateTime datum,
    required int startMinuut,
    required int eindMinuut,
    required String reden,
    String notitie = '',
  }) async {
    final response = await _request(
      method: 'POST',
      uri: _beheerUri(),
      jsonBody: <String, dynamic>{
        'action': 'create_block',
        'blockDate': _datumKey(datum),
        'startMinute': startMinuut,
        'endMinute': eindMinuut,
        'reason': reden,
        'note': notitie.trim(),
      },
    );

    _decodeMap(response);
  }

  Future<void> verwijderBlokkering(String id) async {
    final response = await _request(
      method: 'POST',
      uri: _beheerUri(),
      jsonBody: <String, dynamic>{
        'action': 'delete_block',
        'id': id,
      },
    );

    _decodeMap(response);
  }

  Future<WebsiteBericht> bewaarWebsiteBericht({
    String id = '',
    required String type,
    required String tekst,
    required DateTime vanaf,
    required DateTime tot,
    required bool actief,
  }) async {
    final response = await _request(
      method: 'POST',
      uri: _beheerUri(),
      jsonBody: <String, dynamic>{
        'action': 'save_announcement',
        'id': id,
        'type': type,
        'message': tekst.trim(),
        'startsAt': vanaf.toUtc().toIso8601String(),
        'endsAt': tot.toUtc().toIso8601String(),
        'active': actief,
      },
    );

    final data = _decodeMap(response);
    final announcement = data['announcement'];

    if (announcement is! Map) {
      throw const WebsiteServiceException(
        'Het websitebericht werd opgeslagen, maar kon niet opnieuw geladen worden.',
      );
    }

    return WebsiteBericht.fromJson(
      Map<String, dynamic>.from(announcement),
    );
  }

  Future<http.Response> _request({
    required String method,
    required Uri uri,
    Map<String, dynamic>? jsonBody,
  }) async {
    var token = await _authService.tokenVoorGraph();

    if (_isTokenFout(token)) {
      throw const WebsiteServiceException(
        'Microsoft is niet aangemeld. Meld eerst opnieuw aan in de Thimaco-app.',
      );
    }

    var response = await _verstuur(
      method: method,
      uri: uri,
      token: token,
      jsonBody: jsonBody,
    );

    if (response.statusCode == 401) {
      token = await _authService.tokenVoorGraph(forceerVernieuwen: true);

      if (_isTokenFout(token)) {
        throw const WebsiteServiceException(
          'De Microsoft-sessie kon niet vernieuwd worden.',
        );
      }

      response = await _verstuur(
        method: method,
        uri: uri,
        token: token,
        jsonBody: jsonBody,
      );
    }

    return response;
  }

  Future<http.Response> _verstuur({
    required String method,
    required Uri uri,
    required String token,
    Map<String, dynamic>? jsonBody,
  }) {
    final headers = <String, String>{
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final body = jsonBody == null ? null : jsonEncode(jsonBody);

    switch (method) {
      case 'GET':
        return http.get(uri, headers: headers);
      case 'POST':
        return http.post(uri, headers: headers, body: body);
      default:
        throw WebsiteServiceException('Niet ondersteunde HTTP-methode: $method');
    }
  }

  Map<String, dynamic> _decodeMap(http.Response response) {
    Map<String, dynamic> data = <String, dynamic>{};

    if (response.body.trim().isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        data = Map<String, dynamic>.from(decoded);
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = data['error']?.toString().trim();
      throw WebsiteServiceException(
        message == null || message.isEmpty
            ? 'Websitebeheer gaf fout ${response.statusCode}.'
            : message,
      );
    }

    return data;
  }

  static String _datumKey(DateTime datum) {
    return '${datum.year.toString().padLeft(4, '0')}-'
        '${datum.month.toString().padLeft(2, '0')}-'
        '${datum.day.toString().padLeft(2, '0')}';
  }

  static bool _isTokenFout(String token) {
    final value = token.trim();
    return value.isEmpty || value.startsWith('FOUT');
  }
}

class WebsiteServiceException implements Exception {
  const WebsiteServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

String _tijdZonderSeconden(String value) {
  return value.length >= 5 ? value.substring(0, 5) : value;
}
