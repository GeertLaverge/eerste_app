// THIMACO-CONTROLE: HOME-MAIL-GRAPH-INBOX-20260915
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../sync/onedrive_auth_service.dart';

class HomeMailBericht {
  const HomeMailBericht({
    required this.id,
    required this.onderwerp,
    required this.afzenderNaam,
    required this.afzenderAdres,
    required this.ontvangenOp,
    required this.preview,
    required this.webLink,
  });

  final String id;
  final String onderwerp;
  final String afzenderNaam;
  final String afzenderAdres;
  final DateTime ontvangenOp;
  final String preview;
  final String webLink;
}

class HomeMailOverzicht {
  const HomeMailOverzicht({
    required this.ongelezenAantal,
    required this.berichten,
    this.foutmelding,
  });

  final int ongelezenAantal;
  final List<HomeMailBericht> berichten;
  final String? foutmelding;

  bool get heeftFout => foutmelding != null && foutmelding!.trim().isNotEmpty;
}

class HomeMailService {
  HomeMailService({OneDriveAuthService? authService})
      : _authService = authService ?? OneDriveAuthService();

  static const String _graphBasis = 'https://graph.microsoft.com/v1.0';
  static const Duration _cacheDuur = Duration(minutes: 1);

  static HomeMailOverzicht? _cache;
  static DateTime? _cacheOp;

  final OneDriveAuthService _authService;

  Future<HomeMailOverzicht> laadOngelezen({bool forceer = false}) async {
    final cache = _cache;
    final cacheOp = _cacheOp;

    if (!forceer &&
        cache != null &&
        cacheOp != null &&
        DateTime.now().difference(cacheOp) < _cacheDuur) {
      return cache;
    }

    final token = await _authService.tokenSilent();
    if (_isFout(token)) {
      return const HomeMailOverzicht(
        ongelezenAantal: 0,
        berichten: <HomeMailBericht>[],
        foutmelding: 'Microsoft-mail is niet aangemeld.',
      );
    }

    try {
      final resultaten = await Future.wait<http.Response>(<Future<http.Response>>[
        http
            .get(
              Uri.parse(
                '$_graphBasis/me/mailFolders/inbox'
                '?\$select=unreadItemCount',
              ),
              headers: <String, String>{
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 8)),
        http
            .get(
              Uri.parse(
                '$_graphBasis/me/mailFolders/inbox/messages'
                '?\$top=25'
                '&\$select=id,subject,receivedDateTime,from,isRead,'
                'bodyPreview,webLink'
                '&\$orderby=receivedDateTime%20desc',
              ),
              headers: <String, String>{
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 8)),
      ]);

      final mapResponse = resultaten[0];
      final berichtenResponse = resultaten[1];

      if (mapResponse.statusCode != 200 || berichtenResponse.statusCode != 200) {
        return HomeMailOverzicht(
          ongelezenAantal: 0,
          berichten: const <HomeMailBericht>[],
          foutmelding:
              'Mail kon niet geladen worden '
              '(${berichtenResponse.statusCode}).',
        );
      }

      final mapDecoded = jsonDecode(mapResponse.body);
      final berichtenDecoded = jsonDecode(berichtenResponse.body);

      final mapData = mapDecoded is Map
          ? Map<String, dynamic>.from(mapDecoded)
          : const <String, dynamic>{};

      final berichtenData = berichtenDecoded is Map
          ? Map<String, dynamic>.from(berichtenDecoded)
          : const <String, dynamic>{};

      final ongelezenAantal = _alsInt(mapData['unreadItemCount']);
      final value = berichtenData['value'];

      final berichten = <HomeMailBericht>[];

      if (value is List) {
        for (final item in value) {
          if (item is! Map) continue;
          final map = Map<String, dynamic>.from(item);

          if (map['isRead'] == true) continue;

          final ontvangenOp =
              DateTime.tryParse(map['receivedDateTime']?.toString() ?? '');
          if (ontvangenOp == null) continue;

          final from = map['from'];
          final fromMap =
              from is Map ? Map<String, dynamic>.from(from) : null;
          final emailAddress = fromMap?['emailAddress'];
          final emailMap = emailAddress is Map
              ? Map<String, dynamic>.from(emailAddress)
              : null;

          final onderwerp = map['subject']?.toString().trim() ?? '';
          final naam = emailMap?['name']?.toString().trim() ?? '';
          final adres = emailMap?['address']?.toString().trim() ?? '';

          berichten.add(
            HomeMailBericht(
              id: map['id']?.toString() ?? '',
              onderwerp: onderwerp.isEmpty ? '(zonder onderwerp)' : onderwerp,
              afzenderNaam: naam.isEmpty ? adres : naam,
              afzenderAdres: adres,
              ontvangenOp: ontvangenOp.toLocal(),
              preview: map['bodyPreview']?.toString().trim() ?? '',
              webLink: map['webLink']?.toString().trim() ?? '',
            ),
          );

          if (berichten.length >= 5) break;
        }
      }

      final overzicht = HomeMailOverzicht(
        ongelezenAantal: ongelezenAantal,
        berichten: List<HomeMailBericht>.unmodifiable(berichten),
      );

      _cache = overzicht;
      _cacheOp = DateTime.now();
      return overzicht;
    } catch (_) {
      return const HomeMailOverzicht(
        ongelezenAantal: 0,
        berichten: <HomeMailBericht>[],
        foutmelding: 'Mail kon tijdelijk niet geladen worden.',
      );
    }
  }

  Future<bool> openBericht(HomeMailBericht bericht) async {
    final link = bericht.webLink.trim();
    if (link.isEmpty) return openInbox();

    final uri = Uri.tryParse(link);
    if (uri == null) return false;

    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<bool> openInbox() {
    return launchUrl(
      Uri.parse('https://outlook.office.com/mail/inbox'),
      mode: LaunchMode.externalApplication,
    );
  }

  static bool _isFout(String waarde) {
    final tekst = waarde.trim().toUpperCase();
    return tekst.isEmpty || tekst.startsWith('FOUT');
  }

  static int _alsInt(dynamic waarde) {
    if (waarde is int) return waarde;
    if (waarde is num) return waarde.round();
    return int.tryParse(waarde?.toString() ?? '') ?? 0;
  }
}
