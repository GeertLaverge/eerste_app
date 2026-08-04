// THIMACO-CONTROLE: MAGAZIJN-CONTROLLER-FASE-1-20260804

import 'package:flutter/foundation.dart';

import 'magazijn_model.dart';
import 'magazijn_repository.dart';

class MagazijnController extends ChangeNotifier {
  MagazijnController({MagazijnRepository? repository})
    : _repository = repository ?? const MagazijnRepository();

  final MagazijnRepository _repository;

  MagazijnData _data = const MagazijnData();
  bool _laden = false;

  MagazijnData get data => _data;
  bool get laden => _laden;

  Future<void> laad() async {
    _laden = true;
    notifyListeners();
    _data = await _repository.laad();
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

  Future<void> verwijderLeverancier(String id) async {
    final heeftArtikelen = _data.artikelen.any(
      (artikel) => artikel.leverancierId == id,
    );
    if (heeftArtikelen) {
      throw StateError('Verwijder eerst de artikelen van deze leverancier.');
    }
    _data = _data.copyWith(
      leveranciers: _data.leveranciers
          .where((item) => item.id != id)
          .toList(growable: false),
    );
    await _repository.bewaar(_data);
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

  Future<void> verwijderArtikel(String id) async {
    _data = _data.copyWith(
      artikelen: _data.artikelen
          .where((item) => item.id != id)
          .toList(growable: false),
      mutaties: _data.mutaties
          .where((item) => item.artikelId != id)
          .toList(growable: false),
    );
    await _repository.bewaar(_data);
    notifyListeners();
  }

  List<MagazijnArtikel> bestelArtikelenVoorLeverancier(String leverancierId) {
    final vanLeverancier = _data.artikelen
        .where((item) => item.actief && item.leverancierId == leverancierId)
        .toList(growable: false);

    final heeftVerplicht = vanLeverancier.any(
      (artikel) => artikel.onderMinimum,
    );
    if (!heeftVerplicht) return const <MagazijnArtikel>[];

    return vanLeverancier
        .where((artikel) => artikel.onderMinimum || artikel.onderMeebestelgrens)
        .toList(growable: false);
  }
}
