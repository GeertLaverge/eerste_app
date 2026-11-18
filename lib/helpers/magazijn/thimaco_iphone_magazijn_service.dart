// THIMACO-iPHONE-MAGAZIJN-V11-20261117
// iPhone: optimistische Graph-mutatie op de centrale magazijnmodule.
// Windows-preview: bestaande MagazijnController/Repository, geen eigen formaat.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../sync/onedrive_auth_service.dart';
import 'magazijn_controller.dart';

class IphoneMagazijnArtikel {
  const IphoneMagazijnArtikel({
    required this.id,
    required this.naam,
    required this.stock,
    required this.eenheid,
  });
  final String id;
  final String naam;
  final int stock;
  final String eenheid;

  String get qrWaarde => 'THIMACO-MAGAZIJN:$id';
}

class IphoneMagazijnMutatieResultaat {
  const IphoneMagazijnMutatieResultaat(this.artikel, this.naarBureauAangeboden);
  final IphoneMagazijnArtikel artikel;
  final bool naarBureauAangeboden;
}

class ThimacoIphoneMagazijnService {
  static const _moduleUrl =
      'https://graph.microsoft.com/v1.0/me/drive/special/approot:/thimaco_sync_magazijn.json';
  static const _timeout = Duration(seconds: 30);
  static const _pendingKey = 'thimaco_iphone_magazijn_pending_mutatie_v11';
  final _auth = OneDriveAuthService();

  bool get isWindowsPreview => !kIsWeb && Platform.isWindows;

  int _leesInt(Object? waarde) {
    if (waarde is int) return waarde;
    if (waarde is num) return waarde.toInt();
    return int.tryParse(waarde?.toString() ?? '') ?? 0;
  }

  IphoneMagazijnArtikel _artikelUitJson(Map<String, dynamic> data) {
    return IphoneMagazijnArtikel(
      id: (data['id'] ?? '').toString(),
      naam: (data['omschrijving'] ?? '').toString(),
      stock: _leesInt(data['stock']),
      eenheid: (data['eenheid'] ?? 'stuk').toString(),
    );
  }

  String? artikelIdUitQr(String qr) {
    final tekst = qr.trim();
    if (tekst.startsWith('THIMACO-MAGAZIJN:')) {
      final id = tekst.substring('THIMACO-MAGAZIJN:'.length).trim();
      return id.isEmpty ? null : id;
    }
    // De bestaande repository accepteert ook een rechtstreeks artikel-ID.
    if (RegExp(r'^art-[a-zA-Z0-9_-]+$').hasMatch(tekst)) return tekst;
    return null;
  }

  Future<String> _token() async {
    final token = await _auth.tokenVoorGraph();
    if (token.trim().isEmpty || token.startsWith('FOUT')) {
      throw StateError('Meld je eerst op de iPhone aan bij Microsoft via Notities Bureau.');
    }
    return token;
  }

  Map<String, String> _authHeaders(String token) => {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

  Future<_MagazijnGraphDocument> _leesCloud(String token) async {
    final metadata = await http.get(
      Uri.parse('$_moduleUrl?%24select=eTag'),
      headers: _authHeaders(token),
    ).timeout(_timeout);
    if (metadata.statusCode == 404) {
      throw StateError('Het centrale magazijnbestand bestaat nog niet in OneDrive.');
    }
    if (metadata.statusCode != 200) {
      throw StateError('OneDrive-magazijn niet bereikbaar (${metadata.statusCode}).');
    }
    final info = jsonDecode(utf8.decode(metadata.bodyBytes));
    if (info is! Map || (info['eTag'] ?? '').toString().isEmpty) {
      throw StateError('OneDrive gaf geen geldige ETag.');
    }
    final etag = info['eTag'].toString();
    final response = await http.get(
      Uri.parse('$_moduleUrl:/content'),
      headers: _authHeaders(token),
    ).timeout(_timeout);
    if (response.statusCode != 200) {
      throw StateError('Magazijngegevens ophalen mislukt (${response.statusCode}).');
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map) throw const FormatException('Ongeldig magazijnbestand.');
    final module = Map<String, dynamic>.from(decoded);
    if (module['module'] != 'magazijn' || module['magazijnData'] is! String) {
      throw const FormatException('Onbekend formaat van het centrale magazijn.');
    }
    final ruweData = jsonDecode(module['magazijnData'] as String);
    if (ruweData is! Map) {
      throw const FormatException('Ongeldige artikelenlijst in het magazijn.');
    }
    final data = Map<String, dynamic>.from(ruweData);
    if (data['artikelen'] is! List || data['mutaties'] is! List) {
      throw const FormatException('Magazijnbestand mist artikelen of mutaties.');
    }
    return _MagazijnGraphDocument(etag, module, data);
  }

  List<IphoneMagazijnArtikel> _artikelenUitDocument(_MagazijnGraphDocument doc) {
    return (doc.data['artikelen'] as List)
        .whereType<Map>()
        .map((item) => _artikelUitJson(Map<String, dynamic>.from(item)))
        .where((item) => item.id.isNotEmpty)
        .toList(growable: false)
      ..sort((a, b) => a.naam.toLowerCase().compareTo(b.naam.toLowerCase()));
  }

  Future<List<IphoneMagazijnArtikel>> laadArtikelen() async {
    if (isWindowsPreview) {
      final controller = MagazijnController();
      try {
        await controller.laad();
        return controller.data.artikelen
            .where((a) => a.actief)
            .map((a) => IphoneMagazijnArtikel(
                  id: a.id,
                  naam: a.omschrijving,
                  stock: a.stock,
                  eenheid: a.eenheid,
                ))
            .toList(growable: false)
          ..sort((a, b) => a.naam.toLowerCase().compareTo(b.naam.toLowerCase()));
      } finally {
        controller.dispose();
      }
    }
    final token = await _token();
    return _artikelenUitDocument(await _leesCloud(token));
  }

  Future<IphoneMagazijnMutatieResultaat> bevestigMutatie({
    required String artikelId,
    required int verschil,
  }) async {
    if (verschil == 0) throw ArgumentError('Kies een waarde groter of kleiner dan nul.');

    if (isWindowsPreview) {
      // Zelfde repository als de grote Windows-app. Test uitsluitend op
      // de testlaptop met een onbelangrijk proefartikel.
      final controller = MagazijnController();
      try {
        await controller.laad();
        final bestaand = controller.data.artikelen.where((a) => a.id == artikelId);
        if (bestaand.isEmpty) throw StateError('Artikel bestaat niet meer.');
        final stock = bestaand.first.stock;
        if (stock + verschil < 0) {
          throw StateError('Er zijn maar $stock stuks op voorraad.');
        }
        await controller.wijzigVoorraad(
          artikelId: artikelId,
          verschil: verschil,
          reden: 'iPhone Magazijn (Windows-testpreview)',
        );
        await controller.laad();
        final nieuw = controller.data.artikelen.firstWhere((a) => a.id == artikelId);
        return IphoneMagazijnMutatieResultaat(
          IphoneMagazijnArtikel(id: nieuw.id, naam: nieuw.omschrijving,
              stock: nieuw.stock, eenheid: nieuw.eenheid),
          false, // Lokaal geregistreerd, OneDrive-upload niet bevestigd.
        );
      } finally {
        controller.dispose();
      }
    }

    final token = await _token();
    final prefs = await SharedPreferences.getInstance();
    final bestaandPending = prefs.getString(_pendingKey);
    late final String mutatieId;
    if (bestaandPending != null && bestaandPending.isNotEmpty) {
      final pending = jsonDecode(bestaandPending);
      if (pending is! Map || pending['artikelId'] != artikelId ||
          _leesInt(pending['verschil']) != verschil) {
        throw StateError('Er is nog een niet-bevestigde voorraadmutatie. '
            'Herhaal eerst dezelfde bevestiging, zodat de voorraad niet dubbel verandert.');
      }
      mutatieId = (pending['id'] ?? '').toString();
      if (mutatieId.isEmpty) throw StateError('Ongeldige openstaande voorraadmutatie.');
    } else {
      mutatieId = 'mut-iphone-${DateTime.now().toUtc().microsecondsSinceEpoch}-${Random.secure().nextInt(0x7fffffff)}';
      final veilig = await prefs.setString(_pendingKey, jsonEncode({
        'id': mutatieId, 'artikelId': artikelId, 'verschil': verschil,
      }));
      if (!veilig) throw StateError('Mutatie-ID kon niet veilig bewaard worden.');
    }

    // ETag-voorwaarden beschermen tegen overlappende iPhone-mutaties.
    // Bij een 412 wordt de nieuwste voorraad opnieuw gelezen en berekend.
    for (var poging = 0; poging < 4; poging++) {
      final document = await _leesCloud(token);
      final artikelen = (document.data['artikelen'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      final mutaties = (document.data['mutaties'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      final index = artikelen.indexWhere((item) => '${item['id']}' == artikelId);
      if (index < 0) {
        await prefs.remove(_pendingKey);
        throw StateError('Artikel bestaat niet meer in OneDrive.');
      }
      final huidig = artikelen[index];
      final oudeStock = _leesInt(huidig['stock']);
      // Bij onzekere netwerkuitkomst dezelfde mutatie NIET opnieuw toepassen.
      if (mutaties.any((item) => item['id'] == mutatieId)) {
        await prefs.remove(_pendingKey);
        return IphoneMagazijnMutatieResultaat(_artikelUitJson(huidig), true);
      }
      final nieuweStock = oudeStock + verschil;
      if (nieuweStock < 0 || nieuweStock > 999999) {
        await prefs.remove(_pendingKey);
        throw StateError('Onmogelijke voorraad. Huidig aantal: $oudeStock.');
      }
      huidig['stock'] = nieuweStock;
      mutaties.insert(0, {
        'id': mutatieId,
        'artikelId': artikelId,
        'tijdstip': DateTime.now().toUtc().toIso8601String(),
        'verschil': verschil,
        'stockVoor': oudeStock,
        'stockNa': nieuweStock,
        'reden': 'Thimaco iPhone',
      });
      document.data['artikelen'] = artikelen;
      document.data['mutaties'] = mutaties.take(2000).toList();
      document.module['magazijnData'] = jsonEncode(document.data);
      document.module['moduleDatum'] = DateTime.now().toUtc().toIso8601String();
      final antwoord = await http.put(
        Uri.parse('$_moduleUrl:/content'),
        headers: {
          ..._authHeaders(token),
          'Content-Type': 'application/json',
          'If-Match': document.etag,
        },
        body: utf8.encode(jsonEncode(document.module)),
      ).timeout(_timeout);
      if (antwoord.statusCode == 412 || antwoord.statusCode == 409) continue;
      if (antwoord.statusCode != 200 && antwoord.statusCode != 201) {
        throw StateError('Voorraadwijziging niet opgeslagen in OneDrive (${antwoord.statusCode}).');
      }
      // Pas als we onze mutatie in OneDrive teruglezen melden we succes.
      final bevestigd = await _leesCloud(token);
      final controleMutaties = bevestigd.data['mutaties'] as List;
      if (!controleMutaties.whereType<Map>().any((item) => item['id'] == mutatieId)) {
        throw StateError('OneDrive kon deze mutatie nog niet bevestigen. Vernieuw eerst de voorraad.');
      }
      final actueleArtikelen = _artikelenUitDocument(bevestigd);
      final nieuw = actueleArtikelen.firstWhere((a) => a.id == artikelId);
      await prefs.remove(_pendingKey);
      return IphoneMagazijnMutatieResultaat(nieuw, true);
    }
    throw StateError('Het magazijn werd gelijktijdig aangepast. Vernieuw en probeer opnieuw.');
  }
}

class _MagazijnGraphDocument {
  _MagazijnGraphDocument(this.etag, this.module, this.data);
  final String etag;
  final Map<String, dynamic> module;
  final Map<String, dynamic> data;
}
