// THIMACO-CONTROLE: MAGAZIJN-BESTELD-ONMIDDELLIJKE-UI-20261103
// THIMACO-CONTROLE: MAGAZIJN-CONTROLLER-FASE-1-20260804

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'magazijn_model.dart';
import 'magazijn_repository.dart';
import 'magazijn_plaatsers_event_service.dart';

class MagazijnController extends ChangeNotifier {
  MagazijnController({MagazijnRepository? repository})
    : _repository = repository ?? const MagazijnRepository();

  final MagazijnRepository _repository;

  MagazijnData _data = const MagazijnData();
  bool _laden = false;

  // Serializeer de opslag zodat een oudere bestelling niet later een
  // recentere toestand kan overschrijven.
  Future<void> _bestelBewaarKeten = Future<void>.value();

  MagazijnData get data => _data;
  bool get laden => _laden;

  Future<void> laad() async {
    _laden = true;
    notifyListeners();
    _data = await _repository.laad();
    try {
      const brug = MagazijnPlaatsersEventService();
      final verwerkt = await brug.verwerk(_data);
      if (!identical(verwerkt, _data)) {
        await _repository.bewaar(verwerkt);
        await brug.markeerVerwerkt(verwerkt);
        _data = verwerkt;
      }
    } catch (fout) {
      debugPrint('Magazijn plaatsers sync: $fout');
    }
    _laden = false;
    notifyListeners();
  }

  MagazijnArtikel? artikelVoorQr(String waarde) {
    return _repository.artikelVoorQr(_data, waarde);
  }

  Future<void> wijzigVoorraad({
    required String artikelId,
    required int verschil,
    String reden = '',
  }) async {
    _data = await _repository.wijzigVoorraad(
      data: _data,
      artikelId: artikelId,
      verschil: verschil,
      reden: reden,
    );
    notifyListeners();
  }

  Future<void> voegEenheidToe(String ruweEenheid) async {
    final eenheid = ruweEenheid.trim();
    if (eenheid.isEmpty) return;

    final bestaat = _data.eenheden.any(
      (item) => item.toLowerCase() == eenheid.toLowerCase(),
    );
    if (bestaat) return;

    final eenheden = <String>[..._data.eenheden, eenheid]
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    _data = _data.copyWith(eenheden: List<String>.unmodifiable(eenheden));
    await _repository.bewaar(_data);
    notifyListeners();
  }

  Future<void> bewaarLeverancier(MagazijnLeverancier leverancier) async {
    final lijst = List<MagazijnLeverancier>.from(_data.leveranciers);
    final index = lijst.indexWhere((item) => item.id == leverancier.id);
    if (index < 0) {
      lijst.add(leverancier);
    } else {
      lijst[index] = leverancier;
    }
    _data = _data.copyWith(
      leveranciers: List<MagazijnLeverancier>.unmodifiable(lijst),
    );
    await _repository.bewaar(_data);
    notifyListeners();
  }

  /// Verwijder een leverancier met al zijn artikelen, bestellingen en mutaties.
  /// Wacht eerst op oudere bestelsnapshots om terugschrijven te voorkomen.
  Future<void> verwijderLeverancier(String id) async {
    await _bestelBewaarKeten;
    final artikelIds = _data.artikelen
        .where((artikel) => artikel.leverancierId == id)
        .map((artikel) => artikel.id)
        .toSet();
    final bijgewerkt = _data.copyWith(
      leveranciers: _data.leveranciers
          .where((item) => item.id != id)
          .toList(growable: false),
      artikelen: _data.artikelen
          .where((artikel) => artikel.leverancierId != id)
          .toList(growable: false),
      bestellingen: _data.bestellingen
          .where((bestelling) => bestelling.leverancierId != id &&
              !artikelIds.contains(bestelling.artikelId))
          .toList(growable: false),
      mutaties: _data.mutaties
          .where((mutatie) => !artikelIds.contains(mutatie.artikelId))
          .toList(growable: false),
    );
    await _repository.bewaar(bijgewerkt);
    _data = bijgewerkt;
    notifyListeners();
  }

  Future<void> bewaarArtikel(MagazijnArtikel artikel) async {
    final lijst = List<MagazijnArtikel>.from(_data.artikelen);
    final index = lijst.indexWhere((item) => item.id == artikel.id);
    if (index < 0) {
      lijst.add(artikel);
    } else {
      lijst[index] = artikel;
    }
    _data = _data.copyWith(
      artikelen: List<MagazijnArtikel>.unmodifiable(lijst),
    );
    await _repository.bewaar(_data);
    notifyListeners();
  }

  Future<void> verplaatsArtikel({
    required String artikelId,
    required String naarLeverancierId,
  }) async {
    final index = _data.artikelen.indexWhere((item) => item.id == artikelId);
    if (index < 0) return;

    final artikelen = List<MagazijnArtikel>.from(_data.artikelen);
    artikelen[index] = artikelen[index].copyWith(
      leverancierId: naarLeverancierId,
    );

    _data = _data.copyWith(
      artikelen: List<MagazijnArtikel>.unmodifiable(artikelen),
    );
    await _repository.bewaar(_data);
    notifyListeners();
  }

  Future<void> kopieerArtikel({
    required String artikelId,
    required String naarLeverancierId,
  }) async {
    MagazijnArtikel? origineel;
    for (final item in _data.artikelen) {
      if (item.id == artikelId) {
        origineel = item;
        break;
      }
    }
    if (origineel == null) return;

    final kopie = origineel.copyWith(
      id: 'art-${DateTime.now().microsecondsSinceEpoch}',
      leverancierId: naarLeverancierId,
      omschrijving: '${origineel.omschrijving} - kopie',
    );

    _data = _data.copyWith(
      artikelen: List<MagazijnArtikel>.unmodifiable(<MagazijnArtikel>[
        ..._data.artikelen,
        kopie,
      ]),
    );
    await _repository.bewaar(_data);
    notifyListeners();
  }

  /// Verwijder een artikel inclusief alle bestellingen en voorraadmutaties.
  /// 'Te bestellen' verdwijnt automatisch uit het berekende besteladvies.
  Future<void> verwijderArtikel(String id) async {
    await _bestelBewaarKeten;
    final bijgewerkt = _data.copyWith(
      artikelen: _data.artikelen
          .where((artikel) => artikel.id != id)
          .toList(growable: false),
      bestellingen: _data.bestellingen
          .where((bestelling) => bestelling.artikelId != id)
          .toList(growable: false),
      mutaties: _data.mutaties
          .where((mutatie) => mutatie.artikelId != id)
          .toList(growable: false),
    );
    await _repository.bewaar(bijgewerkt);
    _data = bijgewerkt;
    notifyListeners();
  }

  /// Reeds besteld maar nog niet ontvangen. Dit is de bron voor bureau en later iPad.
  List<MagazijnBestelling> onderwegVoorLeverancier(String leverancierId) {
    return _data.bestellingen
        .where((b) => b.leverancierId == leverancierId && b.isOpen)
        .toList(growable: false);
  }

  int onderwegAantal(String artikelId) => _data.bestellingen
      .where((b) => b.artikelId == artikelId && b.isOpen)
      .fold<int>(0, (totaal, b) => totaal + b.onderweg);

  /// Maak één bestelling, zonder de stock te veranderen.
  Future<void> markeerBesteld({
    required MagazijnArtikel artikel,
    required int aantal,
  }) async {
    if (aantal <= 0 || onderwegAantal(artikel.id) > 0) return;
    final nu = DateTime.now();
    final bestelling = MagazijnBestelling(
      id: 'best-${nu.microsecondsSinceEpoch}',
      artikelId: artikel.id,
      leverancierId: artikel.leverancierId,
      aantal: aantal,
      besteldOp: nu,
    );
    _data = _data.copyWith(
      bestellingen: List<MagazijnBestelling>.unmodifiable(
        <MagazijnBestelling>[..._data.bestellingen, bestelling],
      ),
    );
    // Leg de snapshot vast VOOR de volgende gebruikeractie.
    final snapshot = _data;

    // De twee kolommen worden nu direct gemarkeerd om opnieuw te tekenen.
    notifyListeners();

    // Cruciaal: repository.bewaar() serialiseert JSON op de UI-isolate en
    // start OneDrive-werk. Zelfs wanneer het na notifyListeners() staat,
    // kan het de EERSTVOLGENDE frame blokkeren. Dus eerst laten tekenen.
    await SchedulerBinding.instance.endOfFrame;

    // Bij meerdere snelle vinkjes bewaren we snapshots in correcte volgorde.
    final vorige = _bestelBewaarKeten;
    final volgende = () async {
      try {
        await vorige;
      } catch (_) {
        // Een mislukte vorige opslag mag nieuwere wijzigingen niet blokkeren.
      }
      await _repository.bewaar(snapshot);
    }();
    _bestelBewaarKeten = volgende;
    await volgende;
  }

  /// Alleen gebruiken bij een geannuleerde bestelling, niet bij ontvangst.
  Future<void> annuleerBestelling(String bestellingId) async {
    final index = _data.bestellingen.indexWhere((b) => b.id == bestellingId);
    if (index < 0 || _data.bestellingen[index].ontvangenAantal > 0) return;
    _data = _data.copyWith(
      bestellingen: _data.bestellingen
          .where((b) => b.id != bestellingId)
          .toList(growable: false),
    );
    await _repository.bewaar(_data);
    notifyListeners();
  }

  /// Voor de toekomstige iPad-koppeling: één atomaire opslag van ontvangst,
  /// voorraadmutatie en openstaand bestelaantal.
  Future<void> registreerOntvangst({
    required String bestellingId,
    required int aantal,
  }) async {
    if (aantal <= 0) return;
    final index = _data.bestellingen.indexWhere((b) => b.id == bestellingId);
    if (index < 0) return;
    final bestelling = _data.bestellingen[index];
    if (!bestelling.isOpen) return;
    final artikelIndex = _data.artikelen.indexWhere((a) => a.id == bestelling.artikelId);
    if (artikelIndex < 0) return;
    final ontvangen = aantal.clamp(0, bestelling.onderweg).toInt();
    if (ontvangen == 0) return;
    final artikel = _data.artikelen[artikelIndex];
    final nieuweStock = (artikel.stock + ontvangen).clamp(0, 999999).toInt();
    final effectief = nieuweStock - artikel.stock;
    if (effectief == 0) return;
    final nu = DateTime.now();
    final bestellingen = List<MagazijnBestelling>.from(_data.bestellingen);
    final nieuwOntvangen = bestelling.ontvangenAantal + effectief;
    bestellingen[index] = bestelling.copyWith(
      ontvangenAantal: nieuwOntvangen,
      ontvangenOp: nieuwOntvangen >= bestelling.aantal ? nu : null,
    );
    final artikelen = List<MagazijnArtikel>.from(_data.artikelen);
    artikelen[artikelIndex] = artikel.copyWith(stock: nieuweStock);
    final mutatie = MagazijnVoorraadMutatie(
      id: 'mut-${nu.microsecondsSinceEpoch}',
      artikelId: artikel.id,
      tijdstip: nu,
      verschil: effectief,
      stockVoor: artikel.stock,
      stockNa: nieuweStock,
      reden: 'Levering bestelling ${bestelling.id}',
    );
    _data = _data.copyWith(
      bestellingen: List<MagazijnBestelling>.unmodifiable(bestellingen),
      artikelen: List<MagazijnArtikel>.unmodifiable(artikelen),
      mutaties: <MagazijnVoorraadMutatie>[mutatie, ..._data.mutaties].take(2000).toList(growable: false),
    );
    await _repository.bewaar(_data);
    notifyListeners();
  }

  List<MagazijnArtikel> bestelArtikelenVoorLeverancier(String leverancierId) {
    final vanLeverancier = _data.artikelen
        .where((item) => item.actief && item.leverancierId == leverancierId && onderwegAantal(item.id) == 0)
        .toList(growable: false);

    final heeftVerplicht = vanLeverancier.any(
      (artikel) => artikel.onderMinimum,
    );
    // Laat meebestelartikelen zichtbaar zolang een bestelling voor deze
    // leverancier onderweg is, ook wanneer het minimumartikel reeds besteld is.
    final heeftLopendeBestelling = _data.bestellingen.any(
      (b) => b.leverancierId == leverancierId && b.isOpen,
    );
    if (!heeftVerplicht && !heeftLopendeBestelling) {
      return const <MagazijnArtikel>[];
    }

    return vanLeverancier
        .where((artikel) => artikel.onderMinimum || artikel.onderMeebestelgrens)
        .toList(growable: false);
  }
}
