import 'package:flutter/material.dart';

import 'opmeting_raam_model.dart';
import 'opmeting_raam_opvulling_model.dart';
import 'opmeting_raam_tstijl_helper.dart';
import 'opmeting_raam_vlak_helper.dart';

class OpmetingRaamVulvlak {
  const OpmetingRaamVulvlak({
    required this.id,
    required this.werkvlakId,
    required this.vlak,
  });

  final String id;
  final String werkvlakId;
  final Rect vlak;

  bool bevatPunt(Offset punt) {
    return vlak.contains(punt);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'werkvlakId': werkvlakId,
      'vlak': _rectToJson(vlak),
    };
  }

  factory OpmetingRaamVulvlak.fromJson(Map<String, dynamic> json) {
    return OpmetingRaamVulvlak(
      id: json['id']?.toString() ?? '',
      werkvlakId: json['werkvlakId']?.toString() ?? 'kader',
      vlak: _rectFromJson(json['vlak']),
    );
  }
}

class OpmetingRaamVullingLegendaItem {
  const OpmetingRaamVullingLegendaItem({
    required this.nummer,
    required this.opvullingId,
    required this.naam,
    required this.kleurWaarde,
    required this.transparantie,
    required this.vlakIds,
  });

  final int nummer;
  final String opvullingId;
  final String naam;
  final int kleurWaarde;
  final double transparantie;
  final List<String> vlakIds;

  Color get kleur => Color(kleurWaarde);

  Color get weergaveKleur {
    return kleur.withOpacity(transparantie.clamp(0.05, 1.0).toDouble());
  }
}

class OpmetingRaamVullingHelper {
  const OpmetingRaamVullingHelper._();

  static const double _tolerantie = 3;

  static List<OpmetingRaamVulvlak> bepaalVulvlakken({
    required Rect binnenKader,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
    required List<OpmetingRaamTStijl> tStijlen,
    required List<OpmetingRaamVleugel> vleugels,
  }) {
    if (!_isGeldigVlak(binnenKader) ||
        !_isGeldigVlak(buitenKader) ||
        breedteMm <= 0 ||
        hoogteMm <= 0) {
      return <OpmetingRaamVulvlak>[];
    }

    final resultaat = <OpmetingRaamVulvlak>[];

    final kaderTStijlen = tStijlen
        .where((stijl) => stijl.werkvlakId == 'kader')
        .toList();

    final kaderVlakken = OpmetingRaamVlakHelper.bepaalVlakken(
      binnenKader: binnenKader,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      tStijlen: kaderTStijlen,
    );

    for (var index = 0; index < kaderVlakken.length; index++) {
      final kaderVlak = kaderVlakken[index];

      final heeftVleugel = vleugels.any(
        (vleugel) =>
            _vleugelHoortBijKaderVlak(vleugel: vleugel, kaderVlak: kaderVlak),
      );

      if (heeftVleugel) {
        continue;
      }

      resultaat.add(
        OpmetingRaamVulvlak(
          id: _maakVlakId(werkvlakId: 'kader', index: index),
          werkvlakId: 'kader',
          vlak: kaderVlak,
        ),
      );
    }

    for (final deurVleugel in vleugels.where(
      (vleugel) => vleugel.isDeurVleugel,
    )) {
      final deurVlak = _bepaalDeurVleugelBinnenVlak(
        vleugel: deurVleugel,
        buitenKader: buitenKader,
        breedteMm: breedteMm,
        hoogteMm: hoogteMm,
      );

      if (!_isGeldigVlak(deurVlak)) {
        continue;
      }

      final werkvlakId = _deurVleugelWerkvlakId(deurVleugel);

      resultaat.add(
        OpmetingRaamVulvlak(
          id: _maakVlakId(werkvlakId: werkvlakId, index: 0),
          werkvlakId: werkvlakId,
          vlak: deurVlak,
        ),
      );
    }

    final normaleVleugels = vleugels
        .where((vleugel) => !vleugel.isDeurVleugel)
        .toList();

    final vleugelWerkvlakken =
        OpmetingRaamTStijlHelper.bepaalVleugelWerkvlakken(
          vleugels: normaleVleugels,
          buitenKader: buitenKader,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
        );

    final gesorteerdeWerkvlakEntries = vleugelWerkvlakken.entries.toList()
      ..sort((eerste, tweede) {
        return eerste.key.compareTo(tweede.key);
      });

    for (final entry in gesorteerdeWerkvlakEntries) {
      final werkvlakId = entry.key;
      final werkvlak = entry.value;

      if (!_isGeldigVlak(werkvlak)) {
        continue;
      }

      final interneTStijlen = tStijlen
          .where((stijl) => stijl.werkvlakId == werkvlakId)
          .toList();

      final interneVlakken = OpmetingRaamVlakHelper.bepaalVlakken(
        binnenKader: werkvlak,
        buitenKader: buitenKader,
        breedteMm: breedteMm,
        hoogteMm: hoogteMm,
        tStijlen: interneTStijlen,
      );

      for (var index = 0; index < interneVlakken.length; index++) {
        resultaat.add(
          OpmetingRaamVulvlak(
            id: _maakVlakId(werkvlakId: werkvlakId, index: index),
            werkvlakId: werkvlakId,
            vlak: interneVlakken[index],
          ),
        );
      }
    }

    resultaat.sort(_vergelijkVulvlakken);

    return resultaat;
  }

  static OpmetingRaamVulvlak? vindVulvlak({
    required Offset punt,
    required List<OpmetingRaamVulvlak> vulvlakken,
  }) {
    OpmetingRaamVulvlak? gevondenVlak;

    for (final vulvlak in vulvlakken) {
      if (!vulvlak.bevatPunt(punt)) {
        continue;
      }

      if (gevondenVlak == null ||
          _oppervlakte(vulvlak.vlak) < _oppervlakte(gevondenVlak.vlak)) {
        gevondenVlak = vulvlak;
      }
    }

    return gevondenVlak;
  }

  static List<OpmetingRaamVullingToewijzing> pasOpvullingToe({
    required List<OpmetingRaamVullingToewijzing> bestaandeToewijzingen,
    required Iterable<OpmetingRaamVulvlak> geselecteerdeVlakken,
    required OpmetingRaamOpvullingModel opvulling,
  }) {
    final geselecteerdeLijst = geselecteerdeVlakken.toList();

    if (geselecteerdeLijst.isEmpty) {
      return List<OpmetingRaamVullingToewijzing>.from(bestaandeToewijzingen);
    }

    final geselecteerdeIds = geselecteerdeLijst.map((vlak) => vlak.id).toSet();

    final resultaat = bestaandeToewijzingen
        .where((toewijzing) => !geselecteerdeIds.contains(toewijzing.vlakId))
        .toList();

    for (final vulvlak in geselecteerdeLijst) {
      resultaat.add(
        OpmetingRaamVullingToewijzing(
          vlakId: vulvlak.id,
          werkvlakId: vulvlak.werkvlakId,
          opvullingId: opvulling.id,
          naam: opvulling.naam,
          kleurWaarde: opvulling.kleurWaarde,
          transparantie: opvulling.transparantie,
        ),
      );
    }

    return resultaat;
  }

  static List<OpmetingRaamVullingToewijzing> verwijderOpvullingUitVlakken({
    required List<OpmetingRaamVullingToewijzing> bestaandeToewijzingen,
    required Iterable<String> vlakIds,
  }) {
    final teVerwijderenIds = vlakIds.toSet();

    return bestaandeToewijzingen
        .where((toewijzing) => !teVerwijderenIds.contains(toewijzing.vlakId))
        .toList();
  }

  static List<OpmetingRaamVullingToewijzing>
  verwijderNietBestaandeToewijzingen({
    required List<OpmetingRaamVullingToewijzing> bestaandeToewijzingen,
    required List<OpmetingRaamVulvlak> huidigeVulvlakken,
  }) {
    final huidigeVlakIds = huidigeVulvlakken.map((vlak) => vlak.id).toSet();

    return bestaandeToewijzingen
        .where((toewijzing) => huidigeVlakIds.contains(toewijzing.vlakId))
        .toList();
  }

  static List<OpmetingRaamVullingToewijzing>
  herkoppelToewijzingenNaVlakWijziging({
    required List<OpmetingRaamVulvlak> oudeVulvlakken,
    required List<OpmetingRaamVulvlak> nieuweVulvlakken,
    required List<OpmetingRaamVullingToewijzing> bestaandeToewijzingen,
  }) {
    if (bestaandeToewijzingen.isEmpty || nieuweVulvlakken.isEmpty) {
      return <OpmetingRaamVullingToewijzing>[];
    }

    final oudVlakPerId = <String, OpmetingRaamVulvlak>{
      for (final vulvlak in oudeVulvlakken) vulvlak.id: vulvlak,
    };

    final nieuwVlakPerId = <String, OpmetingRaamVulvlak>{
      for (final vulvlak in nieuweVulvlakken) vulvlak.id: vulvlak,
    };

    final alleKandidaten = <_VulvlakKoppelingKandidaat>[];

    for (
      var toewijzingIndex = 0;
      toewijzingIndex < bestaandeToewijzingen.length;
      toewijzingIndex++
    ) {
      final toewijzing = bestaandeToewijzingen[toewijzingIndex];
      final oudVlak = oudVlakPerId[toewijzing.vlakId];

      if (oudVlak == null) {
        final gelijkIdVlak = nieuwVlakPerId[toewijzing.vlakId];

        if (gelijkIdVlak != null) {
          alleKandidaten.add(
            _VulvlakKoppelingKandidaat(
              toewijzingIndex: toewijzingIndex,
              nieuwVlak: gelijkIdVlak,
              score: 1000,
            ),
          );
        }

        continue;
      }

      var mogelijkeNieuweVlakken = nieuweVulvlakken
          .where((nieuwVlak) => nieuwVlak.werkvlakId == oudVlak.werkvlakId)
          .toList();

      if (mogelijkeNieuweVlakken.isEmpty) {
        mogelijkeNieuweVlakken = List<OpmetingRaamVulvlak>.from(
          nieuweVulvlakken,
        );
      }

      for (final nieuwVlak in mogelijkeNieuweVlakken) {
        alleKandidaten.add(
          _VulvlakKoppelingKandidaat(
            toewijzingIndex: toewijzingIndex,
            nieuwVlak: nieuwVlak,
            score: _berekenVlakKoppelScore(
              oudVlak: oudVlak,
              nieuwVlak: nieuwVlak,
            ),
          ),
        );
      }
    }

    alleKandidaten.sort((eerste, tweede) {
      final scoreVergelijking = tweede.score.compareTo(eerste.score);

      if (scoreVergelijking != 0) {
        return scoreVergelijking;
      }

      return eerste.nieuwVlak.id.compareTo(tweede.nieuwVlak.id);
    });

    final gekoppeldVlakPerToewijzingIndex = <int, OpmetingRaamVulvlak>{};

    final gebruikteNieuweVlakIds = <String>{};

    for (final kandidaat in alleKandidaten) {
      if (gekoppeldVlakPerToewijzingIndex.containsKey(
        kandidaat.toewijzingIndex,
      )) {
        continue;
      }

      if (gebruikteNieuweVlakIds.contains(kandidaat.nieuwVlak.id)) {
        continue;
      }

      gekoppeldVlakPerToewijzingIndex[kandidaat.toewijzingIndex] =
          kandidaat.nieuwVlak;

      gebruikteNieuweVlakIds.add(kandidaat.nieuwVlak.id);
    }

    final resultaat = <OpmetingRaamVullingToewijzing>[];

    for (
      var toewijzingIndex = 0;
      toewijzingIndex < bestaandeToewijzingen.length;
      toewijzingIndex++
    ) {
      final oudeToewijzing = bestaandeToewijzingen[toewijzingIndex];

      var nieuwVlak = gekoppeldVlakPerToewijzingIndex[toewijzingIndex];

      nieuwVlak ??= _vindBesteVrijeKandidaat(
        oudeToewijzing: oudeToewijzing,
        oudVlak: oudVlakPerId[oudeToewijzing.vlakId],
        nieuweVulvlakken: nieuweVulvlakken,
        gebruikteNieuweVlakIds: gebruikteNieuweVlakIds,
      );

      if (nieuwVlak == null) {
        continue;
      }

      gebruikteNieuweVlakIds.add(nieuwVlak.id);

      resultaat.add(
        OpmetingRaamVullingToewijzing(
          vlakId: nieuwVlak.id,
          werkvlakId: nieuwVlak.werkvlakId,
          opvullingId: oudeToewijzing.opvullingId,
          naam: oudeToewijzing.naam,
          kleurWaarde: oudeToewijzing.kleurWaarde,
          transparantie: oudeToewijzing.transparantie,
        ),
      );
    }

    resultaat.sort((eerste, tweede) {
      return eerste.vlakId.compareTo(tweede.vlakId);
    });

    return resultaat;
  }

  static OpmetingRaamVulvlak? _vindBesteVrijeKandidaat({
    required OpmetingRaamVullingToewijzing oudeToewijzing,
    required OpmetingRaamVulvlak? oudVlak,
    required List<OpmetingRaamVulvlak> nieuweVulvlakken,
    required Set<String> gebruikteNieuweVlakIds,
  }) {
    final vrijeVlakken = nieuweVulvlakken
        .where((vulvlak) => !gebruikteNieuweVlakIds.contains(vulvlak.id))
        .toList();

    if (vrijeVlakken.isEmpty) {
      return null;
    }

    final gelijkIdVlak = vrijeVlakken.where(
      (vulvlak) => vulvlak.id == oudeToewijzing.vlakId,
    );

    if (gelijkIdVlak.isNotEmpty) {
      return gelijkIdVlak.first;
    }

    var kandidaten = vrijeVlakken
        .where((vulvlak) => vulvlak.werkvlakId == oudeToewijzing.werkvlakId)
        .toList();

    if (kandidaten.isEmpty) {
      kandidaten = vrijeVlakken;
    }

    if (oudVlak == null) {
      kandidaten.sort((eerste, tweede) {
        return eerste.id.compareTo(tweede.id);
      });

      return kandidaten.first;
    }

    kandidaten.sort((eerste, tweede) {
      final eersteScore = _berekenVlakKoppelScore(
        oudVlak: oudVlak,
        nieuwVlak: eerste,
      );

      final tweedeScore = _berekenVlakKoppelScore(
        oudVlak: oudVlak,
        nieuwVlak: tweede,
      );

      return tweedeScore.compareTo(eersteScore);
    });

    return kandidaten.first;
  }

  static double _berekenVlakKoppelScore({
    required OpmetingRaamVulvlak oudVlak,
    required OpmetingRaamVulvlak nieuwVlak,
  }) {
    final oudeOppervlakte = _oppervlakte(oudVlak.vlak);
    final nieuweOppervlakte = _oppervlakte(nieuwVlak.vlak);

    if (oudeOppervlakte <= 0 || nieuweOppervlakte <= 0) {
      return double.negativeInfinity;
    }

    final overlap = _overlapOppervlakte(oudVlak.vlak, nieuwVlak.vlak);

    final dekkingOud = overlap / oudeOppervlakte;
    final dekkingNieuw = overlap / nieuweOppervlakte;

    final gezamenlijkeGrenzen = oudVlak.vlak.expandToInclude(nieuwVlak.vlak);

    final maximaleAfstand = gezamenlijkeGrenzen.size.longestSide > 0
        ? gezamenlijkeGrenzen.size.longestSide
        : 1.0;

    final middenAfstand =
        (oudVlak.vlak.center - nieuwVlak.vlak.center).distance;

    final middenScore =
        1 - (middenAfstand / maximaleAfstand).clamp(0.0, 1.0).toDouble();

    final breedteScore = _verhoudingsScore(
      oudVlak.vlak.width,
      nieuwVlak.vlak.width,
    );

    final hoogteScore = _verhoudingsScore(
      oudVlak.vlak.height,
      nieuwVlak.vlak.height,
    );

    final zelfdeIdBonus = oudVlak.id == nieuwVlak.id ? 0.14 : 0.0;

    final zelfdeWerkvlakBonus = oudVlak.werkvlakId == nieuwVlak.werkvlakId
        ? 0.10
        : 0.0;

    return dekkingOud * 0.36 +
        dekkingNieuw * 0.30 +
        middenScore * 0.16 +
        breedteScore * 0.09 +
        hoogteScore * 0.09 +
        zelfdeIdBonus +
        zelfdeWerkvlakBonus;
  }

  static double _verhoudingsScore(double eerste, double tweede) {
    if (eerste <= 0 || tweede <= 0) {
      return 0;
    }

    final kleinste = eerste < tweede ? eerste : tweede;
    final grootste = eerste > tweede ? eerste : tweede;

    return (kleinste / grootste).clamp(0.0, 1.0).toDouble();
  }

  static OpmetingRaamVullingToewijzing? vindToewijzingVoorVlak({
    required String vlakId,
    required List<OpmetingRaamVullingToewijzing> toewijzingen,
  }) {
    for (final toewijzing in toewijzingen) {
      if (toewijzing.vlakId == vlakId) {
        return toewijzing;
      }
    }

    return null;
  }

  static List<OpmetingRaamVullingLegendaItem> bepaalLegenda({
    required List<OpmetingRaamVulvlak> vulvlakken,
    required List<OpmetingRaamVullingToewijzing> toewijzingen,
  }) {
    final toewijzingPerVlakId = <String, OpmetingRaamVullingToewijzing>{
      for (final toewijzing in toewijzingen) toewijzing.vlakId: toewijzing,
    };

    final groepen = <String, List<OpmetingRaamVullingToewijzing>>{};

    for (final vulvlak in vulvlakken) {
      final toewijzing = toewijzingPerVlakId[vulvlak.id];

      if (toewijzing == null) {
        continue;
      }

      final groepId = _groepIdVoorToewijzing(toewijzing);

      groepen
          .putIfAbsent(groepId, () => <OpmetingRaamVullingToewijzing>[])
          .add(toewijzing);
    }

    final legenda = <OpmetingRaamVullingLegendaItem>[];
    var nummer = 1;

    for (final groep in groepen.entries) {
      if (groep.value.isEmpty) {
        continue;
      }

      final eerste = groep.value.first;

      legenda.add(
        OpmetingRaamVullingLegendaItem(
          nummer: nummer,
          opvullingId: eerste.opvullingId,
          naam: eerste.naam,
          kleurWaarde: eerste.kleurWaarde,
          transparantie: eerste.transparantie,
          vlakIds: groep.value.map((toewijzing) => toewijzing.vlakId).toList(),
        ),
      );

      nummer++;
    }

    return legenda;
  }

  static Map<String, int> bepaalNummerPerVlak({
    required List<OpmetingRaamVulvlak> vulvlakken,
    required List<OpmetingRaamVullingToewijzing> toewijzingen,
  }) {
    final legenda = bepaalLegenda(
      vulvlakken: vulvlakken,
      toewijzingen: toewijzingen,
    );

    final nummerPerVlak = <String, int>{};

    for (final item in legenda) {
      for (final vlakId in item.vlakIds) {
        nummerPerVlak[vlakId] = item.nummer;
      }
    }

    return nummerPerVlak;
  }

  static Rect _bepaalDeurVleugelBinnenVlak({
    required OpmetingRaamVleugel vleugel,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
  }) {
    if (breedteMm <= 0 || hoogteMm <= 0 || !_isGeldigVlak(vleugel.vlak)) {
      return Rect.zero;
    }

    final schaalX = buitenKader.width / breedteMm;
    final schaalY = buitenKader.height / hoogteMm;

    final profielBreedteX = (vleugel.deurVleugelBreedteMm * schaalX)
        .abs()
        .clamp(5.0, buitenKader.width / 3)
        .toDouble();

    final profielBreedteY = (vleugel.deurVleugelBreedteMm * schaalY)
        .abs()
        .clamp(5.0, buitenKader.height / 3)
        .toDouble();

    final onderAfstandPx = (vleugel.deurVleugelOnderAfstandMm * schaalY)
        .abs()
        .clamp(0.0, buitenKader.height / 4)
        .toDouble();

    final deurRect = Rect.fromLTRB(
      vleugel.vlak.left,
      vleugel.vlak.top,
      vleugel.vlak.right,
      buitenKader.bottom - onderAfstandPx,
    );

    final binnenVlak = Rect.fromLTRB(
      deurRect.left + profielBreedteX,
      deurRect.top + profielBreedteY,
      deurRect.right - profielBreedteX,
      deurRect.bottom - profielBreedteY,
    );

    if (!_isGeldigVlak(binnenVlak)) {
      return Rect.zero;
    }

    return binnenVlak;
  }

  static String _deurVleugelWerkvlakId(OpmetingRaamVleugel vleugel) {
    final id = vleugel.id.trim().isEmpty ? 'deurvleugel' : vleugel.id.trim();

    return 'deurvleugel_${id}_binnen';
  }

  static String _maakVlakId({required String werkvlakId, required int index}) {
    return '${werkvlakId}_vlak_$index';
  }

  static String _groepIdVoorToewijzing(
    OpmetingRaamVullingToewijzing toewijzing,
  ) {
    if (toewijzing.opvullingId.trim().isNotEmpty) {
      return toewijzing.opvullingId;
    }

    return '${toewijzing.naam.trim().toLowerCase()}_'
        '${toewijzing.kleurWaarde}_'
        '${toewijzing.transparantie.toStringAsFixed(2)}';
  }

  static bool _vleugelHoortBijKaderVlak({
    required OpmetingRaamVleugel vleugel,
    required Rect kaderVlak,
  }) {
    if (kaderVlak.inflate(_tolerantie).contains(vleugel.vlak.center)) {
      return true;
    }

    final overlap = _overlapOppervlakte(vleugel.vlak, kaderVlak);

    if (overlap <= 0) {
      return false;
    }

    final vleugelOppervlakte = _oppervlakte(vleugel.vlak);

    if (vleugelOppervlakte <= 0) {
      return false;
    }

    return overlap / vleugelOppervlakte >= 0.5;
  }

  static int _vergelijkVulvlakken(
    OpmetingRaamVulvlak eerste,
    OpmetingRaamVulvlak tweede,
  ) {
    final verschilBoven = eerste.vlak.top - tweede.vlak.top;

    if (verschilBoven.abs() > _tolerantie) {
      return verschilBoven < 0 ? -1 : 1;
    }

    final verschilLinks = eerste.vlak.left - tweede.vlak.left;

    if (verschilLinks.abs() > _tolerantie) {
      return verschilLinks < 0 ? -1 : 1;
    }

    final werkvlakVergelijking = eerste.werkvlakId.compareTo(tweede.werkvlakId);

    if (werkvlakVergelijking != 0) {
      return werkvlakVergelijking;
    }

    return eerste.id.compareTo(tweede.id);
  }

  static double _overlapOppervlakte(Rect eerste, Rect tweede) {
    final links = eerste.left > tweede.left ? eerste.left : tweede.left;

    final boven = eerste.top > tweede.top ? eerste.top : tweede.top;

    final rechts = eerste.right < tweede.right ? eerste.right : tweede.right;

    final onder = eerste.bottom < tweede.bottom ? eerste.bottom : tweede.bottom;

    if (rechts <= links || onder <= boven) {
      return 0;
    }

    return (rechts - links) * (onder - boven);
  }

  static double _oppervlakte(Rect vlak) {
    if (!_isGeldigVlak(vlak)) {
      return 0;
    }

    return vlak.width * vlak.height;
  }

  static bool _isGeldigVlak(Rect vlak) {
    return vlak.left.isFinite &&
        vlak.top.isFinite &&
        vlak.right.isFinite &&
        vlak.bottom.isFinite &&
        vlak.width > 0 &&
        vlak.height > 0;
  }
}

class _VulvlakKoppelingKandidaat {
  const _VulvlakKoppelingKandidaat({
    required this.toewijzingIndex,
    required this.nieuwVlak,
    required this.score,
  });

  final int toewijzingIndex;
  final OpmetingRaamVulvlak nieuwVlak;
  final double score;
}

Map<String, dynamic> _rectToJson(Rect rect) {
  return <String, dynamic>{
    'left': rect.left,
    'top': rect.top,
    'right': rect.right,
    'bottom': rect.bottom,
  };
}

Rect _rectFromJson(Object? waarde) {
  if (waarde is Map) {
    return Rect.fromLTRB(
      _leesDouble(waarde['left'], 0),
      _leesDouble(waarde['top'], 0),
      _leesDouble(waarde['right'], 0),
      _leesDouble(waarde['bottom'], 0),
    );
  }

  return Rect.zero;
}

double _leesDouble(Object? waarde, double standaardWaarde) {
  if (waarde is double) {
    return waarde;
  }

  if (waarde is num) {
    return waarde.toDouble();
  }

  return double.tryParse(
        waarde?.toString().trim().replaceAll(',', '.') ?? '',
      ) ??
      standaardWaarde;
}
