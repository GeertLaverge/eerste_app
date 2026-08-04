// THIMACO-CONTROLE: BUITENJALOEZIE-KASTKEUZE-ZOEK-UITSTEEK-FIX-20260804

import 'opmeting_buitenjaloezie_model.dart';

class OpmetingBuitenjaloezieKastResultaat {
  const OpmetingBuitenjaloezieKastResultaat({
    required this.kastHoogteMm,
    required this.maximaleDagmaatHoogteMm,
    required this.maximaleElementHoogteMm,
    required this.overschrijdtTabel,
    required this.combinatieGeldig,
    this.lamellenpakketUitsteekMm = 0,
  });

  final int kastHoogteMm;
  final int maximaleDagmaatHoogteMm;
  final int maximaleElementHoogteMm;
  final bool overschrijdtTabel;
  final bool combinatieGeldig;
  final int lamellenpakketUitsteekMm;

  int get grensWaardeMm => maximaleElementHoogteMm;
}

class OpmetingBuitenjaloezieKasthoogteHelper {
  const OpmetingBuitenjaloezieKasthoogteHelper._();

  static const List<int> moduloKastHoogtesMm = <int>[200, 240, 260, 280, 320];
  static const List<int> raffstoreKastHoogtesMm = <int>[165, 185];

  static OpmetingBuitenjaloezieKastResultaat bereken({
    required OpmetingBuitenjaloezieSysteem systeem,
    required OpmetingBuitenjaloezieLameltype lameltype,
    required int ingegevenHoogteMm,
    required bool hoogteInclusiefKast,
  }) {
    if (!systeem.isModulo) {
      final opties = berekenRaffstoreOpties(
        systeem: systeem,
        lameltype: lameltype,
        ingegevenHoogteMm: ingegevenHoogteMm,
        hoogteInclusiefKast: hoogteInclusiefKast,
      );
      for (final optie in opties) {
        if (optie.combinatieGeldig) {
          return optie;
        }
      }
      return opties.isNotEmpty
          ? opties.first
          : const OpmetingBuitenjaloezieKastResultaat(
              kastHoogteMm: 0,
              maximaleDagmaatHoogteMm: 0,
              maximaleElementHoogteMm: 0,
              overschrijdtTabel: true,
              combinatieGeldig: false,
            );
    }

    final basisSysteem = systeem.basisVariant;
    final rijen = _tabel[basisSysteem]?[lameltype];

    if (rijen == null || rijen.isEmpty) {
      return const OpmetingBuitenjaloezieKastResultaat(
        kastHoogteMm: 0,
        maximaleDagmaatHoogteMm: 0,
        maximaleElementHoogteMm: 0,
        overschrijdtTabel: true,
        combinatieGeldig: false,
      );
    }

    for (final rij in rijen) {
      final grens = hoogteInclusiefKast
          ? rij.maximaleElementHoogteMm
          : rij.maximaleDagmaatHoogteMm;

      if (ingegevenHoogteMm <= grens) {
        return OpmetingBuitenjaloezieKastResultaat(
          kastHoogteMm: rij.kastHoogteMm,
          maximaleDagmaatHoogteMm: rij.maximaleDagmaatHoogteMm,
          maximaleElementHoogteMm: rij.maximaleElementHoogteMm,
          overschrijdtTabel: false,
          combinatieGeldig: true,
        );
      }
    }

    final laatste = rijen.last;
    return OpmetingBuitenjaloezieKastResultaat(
      kastHoogteMm: laatste.kastHoogteMm,
      maximaleDagmaatHoogteMm: laatste.maximaleDagmaatHoogteMm,
      maximaleElementHoogteMm: laatste.maximaleElementHoogteMm,
      overschrijdtTabel: true,
      combinatieGeldig: true,
    );
  }

  static List<OpmetingBuitenjaloezieKastResultaat> berekenRaffstoreOpties({
    required OpmetingBuitenjaloezieSysteem systeem,
    required OpmetingBuitenjaloezieLameltype lameltype,
    required int ingegevenHoogteMm,
    required bool hoogteInclusiefKast,
  }) {
    if (lameltype != OpmetingBuitenjaloezieLameltype.dbl70 &&
        lameltype != OpmetingBuitenjaloezieLameltype.gl80) {
      return const <OpmetingBuitenjaloezieKastResultaat>[];
    }

    final tabel = systeem.metRolhor ? _raffstoreXpTabel : _raffstorePTabel;
    final grenzenPerUitsteek = tabel[lameltype];

    if (grenzenPerUitsteek == null || grenzenPerUitsteek.isEmpty) {
      return const <OpmetingBuitenjaloezieKastResultaat>[];
    }

    return raffstoreKastHoogtesMm
        .map(
          (kastHoogteMm) => _berekenRaffstoreOptieVoorKast(
            grenzenPerUitsteek: grenzenPerUitsteek,
            kastHoogteMm: kastHoogteMm,
            ingegevenHoogteMm: ingegevenHoogteMm,
            hoogteInclusiefKast: hoogteInclusiefKast,
          ),
        )
        .toList(growable: false);
  }

  static OpmetingBuitenjaloezieKastResultaat _berekenRaffstoreOptieVoorKast({
    required Map<int, _RaffstoreHoogtegrens> grenzenPerUitsteek,
    required int kastHoogteMm,
    required int ingegevenHoogteMm,
    required bool hoogteInclusiefKast,
  }) {
    final geldig = _zoekKleinsteUitsteek(
      grenzenPerUitsteek: grenzenPerUitsteek,
      kastHoogteMm: kastHoogteMm,
      ingegevenHoogteMm: ingegevenHoogteMm,
      hoogteInclusiefKast: hoogteInclusiefKast,
    );
    if (geldig != null) {
      return geldig;
    }

    final laatsteUitsteek =
        OpmetingBuitenjaloezieModel.toegestaneUitstekenMm.last;
    final laatsteGrens = grenzenPerUitsteek[laatsteUitsteek]!;
    final maximaleElementHoogteMm = kastHoogteMm == 165
        ? laatsteGrens.max165Mm
        : laatsteGrens.max185Mm;

    return OpmetingBuitenjaloezieKastResultaat(
      kastHoogteMm: kastHoogteMm,
      maximaleDagmaatHoogteMm: maximaleElementHoogteMm - kastHoogteMm,
      maximaleElementHoogteMm: maximaleElementHoogteMm,
      overschrijdtTabel: true,
      combinatieGeldig: false,
      lamellenpakketUitsteekMm: laatsteUitsteek,
    );
  }

  static OpmetingBuitenjaloezieKastResultaat? _zoekKleinsteUitsteek({
    required Map<int, _RaffstoreHoogtegrens> grenzenPerUitsteek,
    required int kastHoogteMm,
    required int ingegevenHoogteMm,
    required bool hoogteInclusiefKast,
  }) {
    final elementHoogteMm = hoogteInclusiefKast
        ? ingegevenHoogteMm
        : ingegevenHoogteMm + kastHoogteMm;

    for (final uitsteekMm
        in OpmetingBuitenjaloezieModel.toegestaneUitstekenMm) {
      final grens = grenzenPerUitsteek[uitsteekMm];
      if (grens == null) continue;

      final maximaleElementHoogteMm = kastHoogteMm == 165
          ? grens.max165Mm
          : grens.max185Mm;

      if (elementHoogteMm <= maximaleElementHoogteMm) {
        return OpmetingBuitenjaloezieKastResultaat(
          kastHoogteMm: kastHoogteMm,
          maximaleDagmaatHoogteMm: maximaleElementHoogteMm - kastHoogteMm,
          maximaleElementHoogteMm: maximaleElementHoogteMm,
          overschrijdtTabel: false,
          combinatieGeldig: true,
          lamellenpakketUitsteekMm: uitsteekMm,
        );
      }
    }

    return null;
  }

  static OpmetingBuitenjaloezieModel pasAutomatischToe(
    OpmetingBuitenjaloezieModel model,
  ) {
    if (model.systeem.isModulo) {
      final resultaat = bereken(
        systeem: model.systeem,
        lameltype: model.lameltype,
        ingegevenHoogteMm: model.hoogteMm,
        hoogteInclusiefKast: model.hoogteInclusiefKast,
      );

      if (!resultaat.combinatieGeldig) {
        return model;
      }

      return model.copyWith(
        kastHoogteMm: resultaat.kastHoogteMm,
        lamellenpakketUitsteekMm: resultaat.lamellenpakketUitsteekMm,
      );
    }

    final opties = berekenRaffstoreOpties(
      systeem: model.systeem,
      lameltype: model.lameltype,
      ingegevenHoogteMm: model.hoogteMm,
      hoogteInclusiefKast: model.hoogteInclusiefKast,
    );
    if (opties.isEmpty) {
      return model;
    }

    OpmetingBuitenjaloezieKastResultaat? gekozen;
    for (final optie in opties) {
      if (optie.kastHoogteMm == model.kastHoogteMm &&
          optie.lamellenpakketUitsteekMm == model.lamellenpakketUitsteekMm &&
          optie.combinatieGeldig) {
        gekozen = optie;
        break;
      }
    }

    gekozen ??= () {
      for (final optie in opties) {
        if (optie.combinatieGeldig) {
          return optie;
        }
      }
      return opties.first;
    }();

    final resultaat = gekozen!;
    return model.copyWith(
      kastHoogteMm: resultaat.kastHoogteMm,
      lamellenpakketUitsteekMm: resultaat.lamellenpakketUitsteekMm,
    );
  }

  static const Map<
    OpmetingBuitenjaloezieLameltype,
    Map<int, _RaffstoreHoogtegrens>
  >
  _raffstorePTabel =
      <OpmetingBuitenjaloezieLameltype, Map<int, _RaffstoreHoogtegrens>>{
        OpmetingBuitenjaloezieLameltype.dbl70: <int, _RaffstoreHoogtegrens>{
          0: _RaffstoreHoogtegrens(2630, 2980),
          15: _RaffstoreHoogtegrens(2890, 3300),
          30: _RaffstoreHoogtegrens(3220, 3560),
          45: _RaffstoreHoogtegrens(3540, 3890),
        },
        OpmetingBuitenjaloezieLameltype.gl80: <int, _RaffstoreHoogtegrens>{
          0: _RaffstoreHoogtegrens(2370, 2660),
          15: _RaffstoreHoogtegrens(2510, 2870),
          30: _RaffstoreHoogtegrens(2800, 3160),
          45: _RaffstoreHoogtegrens(3090, 3450),
        },
      };

  static const Map<
    OpmetingBuitenjaloezieLameltype,
    Map<int, _RaffstoreHoogtegrens>
  >
  _raffstoreXpTabel =
      <OpmetingBuitenjaloezieLameltype, Map<int, _RaffstoreHoogtegrens>>{
        OpmetingBuitenjaloezieLameltype.dbl70: <int, _RaffstoreHoogtegrens>{
          0: _RaffstoreHoogtegrens(2310, 2650),
          15: _RaffstoreHoogtegrens(2630, 2980),
          30: _RaffstoreHoogtegrens(2890, 3300),
          45: _RaffstoreHoogtegrens(3220, 3560),
        },
        OpmetingBuitenjaloezieLameltype.gl80: <int, _RaffstoreHoogtegrens>{
          0: _RaffstoreHoogtegrens(1650, 1940),
          15: _RaffstoreHoogtegrens(1870, 2230),
          30: _RaffstoreHoogtegrens(2080, 2440),
          45: _RaffstoreHoogtegrens(2370, 2730),
        },
      };

  static const Map<
    OpmetingBuitenjaloezieSysteem,
    Map<
      OpmetingBuitenjaloezieLameltype,
      List<_OpmetingBuitenjaloezieKastTabelRij>
    >
  >
  _tabel =
      <
        OpmetingBuitenjaloezieSysteem,
        Map<
          OpmetingBuitenjaloezieLameltype,
          List<_OpmetingBuitenjaloezieKastTabelRij>
        >
      >{
        OpmetingBuitenjaloezieSysteem.moduloXp:
            <
              OpmetingBuitenjaloezieLameltype,
              List<_OpmetingBuitenjaloezieKastTabelRij>
            >{
              OpmetingBuitenjaloezieLameltype.cdl70:
                  <_OpmetingBuitenjaloezieKastTabelRij>[
                    _OpmetingBuitenjaloezieKastTabelRij(200, 512, 712),
                    _OpmetingBuitenjaloezieKastTabelRij(240, 1227, 1467),
                    _OpmetingBuitenjaloezieKastTabelRij(260, 1584, 1844),
                    _OpmetingBuitenjaloezieKastTabelRij(280, 1942, 2222),
                    _OpmetingBuitenjaloezieKastTabelRij(320, 2657, 2977),
                  ],
              OpmetingBuitenjaloezieLameltype.zl81:
                  <_OpmetingBuitenjaloezieKastTabelRij>[
                    _OpmetingBuitenjaloezieKastTabelRij(200, 1029, 1229),
                    _OpmetingBuitenjaloezieKastTabelRij(240, 1948, 2188),
                    _OpmetingBuitenjaloezieKastTabelRij(260, 2408, 2668),
                    _OpmetingBuitenjaloezieKastTabelRij(280, 2868, 3148),
                    _OpmetingBuitenjaloezieKastTabelRij(320, 3787, 4107),
                  ],
              OpmetingBuitenjaloezieLameltype.dbl70:
                  <_OpmetingBuitenjaloezieKastTabelRij>[
                    _OpmetingBuitenjaloezieKastTabelRij(200, 918, 1118),
                    _OpmetingBuitenjaloezieKastTabelRij(240, 1712, 1952),
                    _OpmetingBuitenjaloezieKastTabelRij(260, 2108, 2368),
                    _OpmetingBuitenjaloezieKastTabelRij(280, 2505, 2785),
                    _OpmetingBuitenjaloezieKastTabelRij(320, 3298, 3618),
                  ],
              OpmetingBuitenjaloezieLameltype.gl80:
                  <_OpmetingBuitenjaloezieKastTabelRij>[
                    _OpmetingBuitenjaloezieKastTabelRij(200, 825, 1025),
                    _OpmetingBuitenjaloezieKastTabelRij(240, 1547, 1787),
                    _OpmetingBuitenjaloezieKastTabelRij(260, 1908, 2168),
                    _OpmetingBuitenjaloezieKastTabelRij(280, 2269, 2549),
                    _OpmetingBuitenjaloezieKastTabelRij(320, 2991, 3311),
                  ],
            },
        OpmetingBuitenjaloezieSysteem.moduloP:
            <
              OpmetingBuitenjaloezieLameltype,
              List<_OpmetingBuitenjaloezieKastTabelRij>
            >{
              OpmetingBuitenjaloezieLameltype.cdl70:
                  <_OpmetingBuitenjaloezieKastTabelRij>[
                    _OpmetingBuitenjaloezieKastTabelRij(200, 1267, 1467),
                    _OpmetingBuitenjaloezieKastTabelRij(240, 1982, 2222),
                    _OpmetingBuitenjaloezieKastTabelRij(260, 2339, 2599),
                    _OpmetingBuitenjaloezieKastTabelRij(280, 2697, 2977),
                    _OpmetingBuitenjaloezieKastTabelRij(320, 3411, 3731),
                  ],
              OpmetingBuitenjaloezieLameltype.zl81:
                  <_OpmetingBuitenjaloezieKastTabelRij>[
                    _OpmetingBuitenjaloezieKastTabelRij(200, 1988, 2188),
                    _OpmetingBuitenjaloezieKastTabelRij(240, 2908, 3148),
                    _OpmetingBuitenjaloezieKastTabelRij(260, 3367, 3627),
                    _OpmetingBuitenjaloezieKastTabelRij(280, 3827, 4107),
                    _OpmetingBuitenjaloezieKastTabelRij(320, 4180, 4500),
                  ],
              OpmetingBuitenjaloezieLameltype.dbl70:
                  <_OpmetingBuitenjaloezieKastTabelRij>[
                    _OpmetingBuitenjaloezieKastTabelRij(200, 1752, 1952),
                    _OpmetingBuitenjaloezieKastTabelRij(240, 2545, 2785),
                    _OpmetingBuitenjaloezieKastTabelRij(260, 2942, 3202),
                    _OpmetingBuitenjaloezieKastTabelRij(280, 3338, 3618),
                    _OpmetingBuitenjaloezieKastTabelRij(320, 4180, 4500),
                  ],
              OpmetingBuitenjaloezieLameltype.gl80:
                  <_OpmetingBuitenjaloezieKastTabelRij>[
                    _OpmetingBuitenjaloezieKastTabelRij(200, 1587, 1787),
                    _OpmetingBuitenjaloezieKastTabelRij(240, 2309, 2549),
                    _OpmetingBuitenjaloezieKastTabelRij(260, 2670, 2930),
                    _OpmetingBuitenjaloezieKastTabelRij(280, 3031, 3311),
                    _OpmetingBuitenjaloezieKastTabelRij(320, 3680, 4000),
                  ],
              OpmetingBuitenjaloezieLameltype.fl80:
                  <_OpmetingBuitenjaloezieKastTabelRij>[
                    _OpmetingBuitenjaloezieKastTabelRij(200, 3377, 3577),
                    _OpmetingBuitenjaloezieKastTabelRij(240, 4010, 4250),
                    _OpmetingBuitenjaloezieKastTabelRij(260, 3990, 4250),
                    _OpmetingBuitenjaloezieKastTabelRij(280, 3970, 4250),
                    _OpmetingBuitenjaloezieKastTabelRij(320, 3930, 4250),
                  ],
            },
      };
}

class _RaffstoreHoogtegrens {
  const _RaffstoreHoogtegrens(this.max165Mm, this.max185Mm);

  final int max165Mm;
  final int max185Mm;
}

class _OpmetingBuitenjaloezieKastTabelRij {
  const _OpmetingBuitenjaloezieKastTabelRij(
    this.kastHoogteMm,
    this.maximaleDagmaatHoogteMm,
    this.maximaleElementHoogteMm,
  );

  final int kastHoogteMm;
  final int maximaleDagmaatHoogteMm;
  final int maximaleElementHoogteMm;
}
