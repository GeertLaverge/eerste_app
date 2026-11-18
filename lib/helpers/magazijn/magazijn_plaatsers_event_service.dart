// THIMACO-CONTROLE: MAGAZIJN-PLAATSERS-EVENT-IMPORT-20261103
// Bureau verwerkt unieke iPad-registraties binnen de bestaande magazijnopslag.
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../sync/onedrive_auth_service.dart';
import 'magazijn_model.dart';

class MagazijnPlaatsersEventService {
  const MagazijnPlaatsersEventService();

  static const _url = 'https://graph.microsoft.com/v1.0/me/drive/special/approot:/thimaco_magazijn_plaatsers_events.json:/content';

  Future<MagazijnData> verwerk(MagazijnData data) async {
    final token = await OneDriveAuthService().tokenSilent();
    if (token.trim().isEmpty || token.startsWith('FOUT')) return data;
    final response = await http.get(Uri.parse(_url),
        headers: <String, String>{'Authorization': 'Bearer $token'});
    if (response.statusCode == 404) return data;
    if (response.statusCode != 200) {
      debugPrint('Magazijn iPad events HTTP ${response.statusCode}');
      return data;
    }
    final inhoud = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    final events = (inhoud['events'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e)).toList();
    if (events.isEmpty) return data;
    final prefs = await SharedPreferences.getInstance();
    // Ook na inkorten van historiek blijven oude gebeurtenis-IDs verwerkt.
    final processed = (prefs.getStringList('thimaco_magazijn_plaatsers_verwerkt_v1') ?? <String>[]).toSet();
    final artikelen = List<MagazijnArtikel>.from(data.artikelen);
    final bestellingen = List<MagazijnBestelling>.from(data.bestellingen);
    final mutaties = List<MagazijnVoorraadMutatie>.from(data.mutaties);
    final ids = mutaties.map((m) => m.id).toSet()..addAll(processed);
    var changed = false;
    for (final event in events) {
      final id = event['id']?.toString() ?? '';
      if (id.isEmpty || ids.contains(id)) continue;
      final artikelId = event['artikelId']?.toString() ?? '';
      final index = artikelen.indexWhere((a) => a.id == artikelId);
      final aantal = (event['aantal'] is num)
          ? (event['aantal'] as num).toInt()
          : int.tryParse(event['aantal']?.toString() ?? '') ?? 0;
      if (index < 0 || aantal <= 0) continue;
      final soort = event['soort']?.toString() ?? '';
      final huidig = artikelen[index];
      var verschil = 0;
      if (soort == 'meenemen') {
        verschil = -aantal.clamp(0, huidig.stock).toInt();
      } else if (soort == 'terugleggen') {
        verschil = aantal.clamp(0, 999999 - huidig.stock).toInt();
      } else if (soort == 'ontvangen') {
        final bestellingId = event['bestellingId']?.toString() ?? '';
        final bestelIndex = bestellingen.indexWhere(
          (b) => b.id == bestellingId && b.artikelId == artikelId && b.isOpen,
        );
        if (bestelIndex < 0) continue;
        final bestelling = bestellingen[bestelIndex];
        verschil = aantal.clamp(0, bestelling.onderweg).toInt();
        verschil = verschil.clamp(0, 999999 - huidig.stock).toInt();
        if (verschil > 0) {
          final ontvangen = bestelling.ontvangenAantal + verschil;
          bestellingen[bestelIndex] = bestelling.copyWith(
            ontvangenAantal: ontvangen,
            ontvangenOp: ontvangen >= bestelling.aantal ? DateTime.now() : null,
          );
        }
      } else {
        continue;
      }
      final nieuweStock = huidig.stock + verschil;
      artikelen[index] = huidig.copyWith(stock: nieuweStock);
      final tijdstip = DateTime.tryParse(event['tijdstip']?.toString() ?? '') ?? DateTime.now();
      mutaties.insert(0, MagazijnVoorraadMutatie(
        id: id, artikelId: artikelId, tijdstip: tijdstip,
        verschil: verschil, stockVoor: huidig.stock, stockNa: nieuweStock,
        reden: 'iPad plaatsers: $soort',
      ));
      ids.add(id);
      processed.add(id);
      changed = true;
    }
    if (!changed) return data;
    final bijgewerkt = data.copyWith(
      artikelen: List<MagazijnArtikel>.unmodifiable(artikelen),
      bestellingen: List<MagazijnBestelling>.unmodifiable(bestellingen),
      mutaties: mutaties.take(2000).toList(growable: false),
    );
    // Markeer IDs pas verwerkt nadat de gewijzigde gegevens bewaard zijn.
    // Deze helper geeft daarom resultaat plus in-data mutatie IDs terug.
    // De controller schrijft deze toestand daarna naar dezelfde repository.
    return bijgewerkt;
  }

  Future<void> markeerVerwerkt(MagazijnData data) async {
    final prefs = await SharedPreferences.getInstance();
    final bestaand = (prefs.getStringList('thimaco_magazijn_plaatsers_verwerkt_v1') ?? <String>[]).toSet();
    for (final mutatie in data.mutaties) {
      if (mutatie.id.startsWith('ipad-')) bestaand.add(mutatie.id);
    }
    await prefs.setStringList('thimaco_magazijn_plaatsers_verwerkt_v1',
        bestaand.toList(growable: false));
  }
}
