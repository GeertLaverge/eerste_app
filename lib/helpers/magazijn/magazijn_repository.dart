// THIMACO-CONTROLE: MAGAZIJN-REPOSITORY-FASE-1-20260804

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../sync/onedrive_sync_service.dart';
import 'magazijn_model.dart';

class MagazijnRepository {
  const MagazijnRepository();

  static const String opslagKey = 'thimaco_magazijn_data';

  Future<MagazijnData> laad() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonTekst = prefs.getString(opslagKey);
    if (jsonTekst == null || jsonTekst.trim().isEmpty) {
      return const MagazijnData();
    }

    try {
      final json = jsonDecode(jsonTekst);
      if (json is! Map) return const MagazijnData();
      return MagazijnData.fromJson(Map<String, dynamic>.from(json));
    } catch (_) {
      return const MagazijnData();
    }
  }

  Future<void> bewaar(MagazijnData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(opslagKey, jsonEncode(data.toJson()));
    await OneDriveSyncService.registreerLokaleWijziging();
    OneDriveSyncService().uploadBackupOpAchtergrond();
  }

  Future<MagazijnData> wijzigVoorraad({
    required MagazijnData data,
    required String artikelId,
    required int verschil,
    String reden = '',
  }) async {
    final index = data.artikelen.indexWhere((item) => item.id == artikelId);
    if (index < 0 || verschil == 0) return data;

    final huidig = data.artikelen[index];
    final nieuweStock = (huidig.stock + verschil).clamp(0, 999999).toInt();
    final werkelijkVerschil = nieuweStock - huidig.stock;
    if (werkelijkVerschil == 0) return data;

    final artikelen = List<MagazijnArtikel>.from(data.artikelen);
    artikelen[index] = huidig.copyWith(stock: nieuweStock);

    final mutatie = MagazijnVoorraadMutatie(
      id: 'mut-${DateTime.now().microsecondsSinceEpoch}',
      artikelId: artikelId,
      tijdstip: DateTime.now(),
      verschil: werkelijkVerschil,
      stockVoor: huidig.stock,
      stockNa: nieuweStock,
      reden: reden,
    );

    final bijgewerkt = data.copyWith(
      artikelen: List<MagazijnArtikel>.unmodifiable(artikelen),
      mutaties: List<MagazijnVoorraadMutatie>.unmodifiable(
        <MagazijnVoorraadMutatie>[mutatie, ...data.mutaties].take(2000),
      ),
    );
    await bewaar(bijgewerkt);
    return bijgewerkt;
  }

  MagazijnArtikel? artikelVoorQr(MagazijnData data, String ruweWaarde) {
    final waarde = ruweWaarde.trim();
    final id = waarde.startsWith('THIMACO-MAGAZIJN:')
        ? waarde.substring('THIMACO-MAGAZIJN:'.length)
        : waarde;
    for (final artikel in data.artikelen) {
      if (artikel.id == id) return artikel;
    }
    return null;
  }
}
