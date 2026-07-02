import 'package:flutter/material.dart';

import 'opmeting_raam_kader_helper.dart';
import 'opmeting_raam_model.dart';
import 'opmeting_raam_opvulling_model.dart';
import 'opmeting_raam_tstijl_helper.dart';
import 'opmeting_raam_vlak_helper.dart';
import 'opmeting_raam_vleugel_helper.dart';
import 'opmeting_raam_vulling_helper.dart';

class OpmetingRaamVulvlakSelectieResultaat {
  const OpmetingRaamVulvlakSelectieResultaat({
    required this.geselecteerdeVulvlakIds,
    required this.geselecteerdeOpvullingId,
    required this.vlakGevonden,
  });

  final Set<String> geselecteerdeVulvlakIds;
  final String? geselecteerdeOpvullingId;
  final bool vlakGevonden;
}

class OpmetingRaamVullingOpschoningResultaat {
  const OpmetingRaamVullingOpschoningResultaat({
    required this.toewijzingen,
    required this.geselecteerdeVulvlakIds,
  });

  final List<OpmetingRaamVullingToewijzing> toewijzingen;
  final Set<String> geselecteerdeVulvlakIds;
}

class OpmetingRaamVleugelActieResultaat {
  const OpmetingRaamVleugelActieResultaat({
    required this.tStijlen,
    required this.vleugels,
    required this.gewijzigd,
  });

  final List<OpmetingRaamTStijl> tStijlen;
  final List<OpmetingRaamVleugel> vleugels;
  final bool gewijzigd;
}

class OpmetingRaamTekenvlakActies {
  const OpmetingRaamTekenvlakActies._();

  static List<OpmetingRaamVulvlak> bepaalVulvlakken({
    required Size tekenvlakGrootte,
    required int breedteMm,
    required int hoogteMm,
    required List<OpmetingRaamTStijl> tStijlen,
    required List<OpmetingRaamVleugel> vleugels,
  }) {
    if (!_isGeldigeTekenvlakGrootte(tekenvlakGrootte) ||
        breedteMm <= 0 ||
        hoogteMm <= 0) {
      return <OpmetingRaamVulvlak>[];
    }

    final buitenKader = OpmetingRaamKaderHelper.buitenKader(
      size: tekenvlakGrootte,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    final binnenKader = OpmetingRaamKaderHelper.binnenKader(
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    return OpmetingRaamVullingHelper.bepaalVulvlakken(
      binnenKader: binnenKader,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      tStijlen: tStijlen,
      vleugels: vleugels,
    );
  }

  static OpmetingRaamVulvlakSelectieResultaat wisselVulvlakSelectie({
    required Offset punt,
    required List<OpmetingRaamVulvlak> vulvlakken,
    required Set<String> huidigeGeselecteerdeVulvlakIds,
    required List<OpmetingRaamVullingToewijzing> toewijzingen,
    required List<OpmetingRaamOpvullingModel> opvullingen,
    required String? huidigeGeselecteerdeOpvullingId,
  }) {
    final vulvlak = OpmetingRaamVullingHelper.vindVulvlak(
      punt: punt,
      vulvlakken: vulvlakken,
    );

    final nieuweSelectie = <String>{...huidigeGeselecteerdeVulvlakIds};

    if (vulvlak == null) {
      return OpmetingRaamVulvlakSelectieResultaat(
        geselecteerdeVulvlakIds: nieuweSelectie,
        geselecteerdeOpvullingId: huidigeGeselecteerdeOpvullingId,
        vlakGevonden: false,
      );
    }

    if (nieuweSelectie.contains(vulvlak.id)) {
      nieuweSelectie.remove(vulvlak.id);

      return OpmetingRaamVulvlakSelectieResultaat(
        geselecteerdeVulvlakIds: nieuweSelectie,
        geselecteerdeOpvullingId: huidigeGeselecteerdeOpvullingId,
        vlakGevonden: true,
      );
    }

    nieuweSelectie.add(vulvlak.id);

    final bestaandeToewijzing =
        OpmetingRaamVullingHelper.vindToewijzingVoorVlak(
          vlakId: vulvlak.id,
          toewijzingen: toewijzingen,
        );

    var nieuweOpvullingId = huidigeGeselecteerdeOpvullingId;

    if (bestaandeToewijzing != null &&
        opvullingen.any(
          (opvulling) => opvulling.id == bestaandeToewijzing.opvullingId,
        )) {
      nieuweOpvullingId = bestaandeToewijzing.opvullingId;
    }

    return OpmetingRaamVulvlakSelectieResultaat(
      geselecteerdeVulvlakIds: nieuweSelectie,
      geselecteerdeOpvullingId: nieuweOpvullingId,
      vlakGevonden: true,
    );
  }

  static OpmetingRaamOpvullingModel? vindGeselecteerdeOpvulling({
    required List<OpmetingRaamOpvullingModel> opvullingen,
    required String? geselecteerdeOpvullingId,
  }) {
    if (geselecteerdeOpvullingId == null) {
      return null;
    }

    for (final opvulling in opvullingen) {
      if (opvulling.id == geselecteerdeOpvullingId) {
        return opvulling;
      }
    }

    return null;
  }

  static List<OpmetingRaamVullingToewijzing> pasOpvullingToe({
    required List<OpmetingRaamVulvlak> vulvlakken,
    required Set<String> geselecteerdeVulvlakIds,
    required List<OpmetingRaamVullingToewijzing> bestaandeToewijzingen,
    required OpmetingRaamOpvullingModel opvulling,
  }) {
    if (geselecteerdeVulvlakIds.isEmpty) {
      return <OpmetingRaamVullingToewijzing>[...bestaandeToewijzingen];
    }

    final geselecteerdeVlakken = vulvlakken.where(
      (vulvlak) => geselecteerdeVulvlakIds.contains(vulvlak.id),
    );

    return OpmetingRaamVullingHelper.pasOpvullingToe(
      bestaandeToewijzingen: bestaandeToewijzingen,
      geselecteerdeVlakken: geselecteerdeVlakken,
      opvulling: opvulling,
    );
  }

  static List<OpmetingRaamVullingToewijzing> verwijderOpvullingUitSelectie({
    required List<OpmetingRaamVullingToewijzing> bestaandeToewijzingen,
    required Set<String> geselecteerdeVulvlakIds,
  }) {
    if (geselecteerdeVulvlakIds.isEmpty) {
      return <OpmetingRaamVullingToewijzing>[...bestaandeToewijzingen];
    }

    return OpmetingRaamVullingHelper.verwijderOpvullingUitVlakken(
      bestaandeToewijzingen: bestaandeToewijzingen,
      vlakIds: geselecteerdeVulvlakIds,
    );
  }

  static Set<String> selecteerAlleVulvlakken(
    List<OpmetingRaamVulvlak> vulvlakken,
  ) {
    return vulvlakken.map((vulvlak) => vulvlak.id).toSet();
  }

  static OpmetingRaamVullingOpschoningResultaat schoonVullingToewijzingenOp({
    required List<OpmetingRaamVulvlak> huidigeVulvlakken,
    required List<OpmetingRaamVullingToewijzing> bestaandeToewijzingen,
    required Set<String> geselecteerdeVulvlakIds,
  }) {
    final geldigeToewijzingen =
        OpmetingRaamVullingHelper.verwijderNietBestaandeToewijzingen(
          bestaandeToewijzingen: bestaandeToewijzingen,
          huidigeVulvlakken: huidigeVulvlakken,
        );

    final geldigeVlakIds = huidigeVulvlakken
        .map((vulvlak) => vulvlak.id)
        .toSet();

    final geldigeSelectie = <String>{...geselecteerdeVulvlakIds}
      ..retainAll(geldigeVlakIds);

    return OpmetingRaamVullingOpschoningResultaat(
      toewijzingen: geldigeToewijzingen,
      geselecteerdeVulvlakIds: geldigeSelectie,
    );
  }

  static OpmetingRaamLijn? vindTStijlStartLijn({
    required Offset punt,
    required Size tekenvlakGrootte,
    required int breedteMm,
    required int hoogteMm,
    required List<OpmetingRaamTStijl> tStijlen,
    required List<OpmetingRaamVleugel> vleugels,
    double maxAfstand = 28,
  }) {
    if (!_isGeldigeTekenvlakGrootte(tekenvlakGrootte) ||
        breedteMm <= 0 ||
        hoogteMm <= 0) {
      return null;
    }

    final buitenKader = OpmetingRaamKaderHelper.buitenKader(
      size: tekenvlakGrootte,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    final binnenKader = OpmetingRaamKaderHelper.binnenKader(
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    final lijnen = OpmetingRaamTStijlHelper.selecteerbareStartLijnen(
      binnenKader: binnenKader,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      tStijlen: tStijlen,
      vleugels: vleugels,
    );

    return OpmetingRaamTStijlHelper.vindLijn(
      punt: punt,
      lijnen: lijnen,
      maxAfstand: maxAfstand,
    );
  }

  static Offset? bepaalTStijlPreviewPunt({
    required OpmetingRaamLijn? geselecteerdeLijn,
    required Size tekenvlakGrootte,
    required int breedteMm,
    required int hoogteMm,
    required String positieType,
    required String positieTekst,
  }) {
    if (geselecteerdeLijn == null ||
        !_isGeldigeTekenvlakGrootte(tekenvlakGrootte) ||
        breedteMm <= 0 ||
        hoogteMm <= 0) {
      return null;
    }

    final buitenKader = OpmetingRaamKaderHelper.buitenKader(
      size: tekenvlakGrootte,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    final positieMm = _leesMaatWaarde(positieTekst);

    return OpmetingRaamTStijlHelper.positieOpLijn(
      lijn: geselecteerdeLijn,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      positieType: positieType,
      positieMm: positieMm,
    );
  }

  static OpmetingRaamTStijl? maakTStijl({
    required OpmetingRaamLijn? geselecteerdeLijn,
    required Size tekenvlakGrootte,
    required int breedteMm,
    required int hoogteMm,
    required String positieType,
    required String positieTekst,
    required List<OpmetingRaamTStijl> bestaandeTStijlen,
    required List<OpmetingRaamVleugel> vleugels,
  }) {
    if (geselecteerdeLijn == null ||
        !_isGeldigeTekenvlakGrootte(tekenvlakGrootte) ||
        breedteMm <= 0 ||
        hoogteMm <= 0) {
      return null;
    }

    final buitenKader = OpmetingRaamKaderHelper.buitenKader(
      size: tekenvlakGrootte,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    final binnenKader = OpmetingRaamKaderHelper.binnenKader(
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    final positieMm = _leesMaatWaarde(positieTekst);

    final startPunt = OpmetingRaamTStijlHelper.positieOpLijn(
      lijn: geselecteerdeLijn,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      positieType: positieType,
      positieMm: positieMm,
    );

    return OpmetingRaamTStijlHelper.maakHaakseTStijl(
      startLijn: geselecteerdeLijn,
      startPunt: startPunt,
      binnenKader: binnenKader,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      bestaandeTStijlen: bestaandeTStijlen,
      vleugels: vleugels,
    );
  }

  static int? indexVanGeselecteerdeTStijlLijn(
    OpmetingRaamLijn? geselecteerdeLijn,
  ) {
    final id = geselecteerdeLijn?.id ?? '';

    if (!id.startsWith('tstijl_')) {
      return null;
    }

    final delen = id.split('_');

    if (delen.length < 3) {
      return null;
    }

    return int.tryParse(delen[1]);
  }

  static bool magTStijlWissen({
    required int index,
    required Size tekenvlakGrootte,
    required int breedteMm,
    required int hoogteMm,
    required List<OpmetingRaamTStijl> tStijlen,
  }) {
    if (!_isGeldigeTekenvlakGrootte(tekenvlakGrootte) ||
        breedteMm <= 0 ||
        hoogteMm <= 0 ||
        index < 0 ||
        index >= tStijlen.length) {
      return false;
    }

    final buitenKader = OpmetingRaamKaderHelper.buitenKader(
      size: tekenvlakGrootte,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    return OpmetingRaamTStijlHelper.magTStijlWissen(
      index: index,
      tStijlen: tStijlen,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );
  }

  static List<OpmetingRaamTStijl> verwijderTStijl({
    required int index,
    required List<OpmetingRaamTStijl> tStijlen,
  }) {
    if (index < 0 || index >= tStijlen.length) {
      return <OpmetingRaamTStijl>[...tStijlen];
    }

    final nieuweTStijlen = <OpmetingRaamTStijl>[...tStijlen];

    nieuweTStijlen.removeAt(index);

    return nieuweTStijlen;
  }

  static List<OpmetingRaamTStijl> verwijderTStijlenVanVleugel({
    required String vleugelId,
    required List<OpmetingRaamTStijl> tStijlen,
  }) {
    final prefix = 'vleugel_${vleugelId}_';

    return tStijlen
        .where((stijl) => !stijl.werkvlakId.startsWith(prefix))
        .toList();
  }

  static OpmetingRaamVleugelActieResultaat pasVleugelToe({
    required Offset punt,
    required Size tekenvlakGrootte,
    required int breedteMm,
    required int hoogteMm,
    required OpmetingRaamVleugelType geselecteerdVleugelType,
    required List<OpmetingRaamTStijl> bestaandeTStijlen,
    required List<OpmetingRaamVleugel> bestaandeVleugels,
  }) {
    final ongewijzigdResultaat = OpmetingRaamVleugelActieResultaat(
      tStijlen: <OpmetingRaamTStijl>[...bestaandeTStijlen],
      vleugels: <OpmetingRaamVleugel>[...bestaandeVleugels],
      gewijzigd: false,
    );

    if (!_isGeldigeTekenvlakGrootte(tekenvlakGrootte) ||
        breedteMm <= 0 ||
        hoogteMm <= 0) {
      return ongewijzigdResultaat;
    }

    final buitenKader = OpmetingRaamKaderHelper.buitenKader(
      size: tekenvlakGrootte,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    final binnenKader = OpmetingRaamKaderHelper.binnenKader(
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    final kaderTStijlen = bestaandeTStijlen
        .where((stijl) => stijl.werkvlakId == 'kader')
        .toList();

    final hoofdVlakken = OpmetingRaamVlakHelper.bepaalVlakken(
      binnenKader: binnenKader,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      tStijlen: kaderTStijlen,
    );

    final gekozenVlak = OpmetingRaamVlakHelper.vindVlak(
      punt: punt,
      vlakken: hoofdVlakken,
    );

    if (gekozenVlak == null) {
      return ongewijzigdResultaat;
    }

    final nieuweTStijlen = <OpmetingRaamTStijl>[...bestaandeTStijlen];

    final nieuweVleugels = <OpmetingRaamVleugel>[...bestaandeVleugels];

    final bestaandeIndex = nieuweVleugels.indexWhere(
      (vleugel) => vleugel.vlak.contains(punt),
    );

    if (geselecteerdVleugelType == OpmetingRaamVleugelType.geenVleugel) {
      if (bestaandeIndex < 0) {
        return ongewijzigdResultaat;
      }

      final bestaandeVleugel = nieuweVleugels[bestaandeIndex];
      final prefix = 'vleugel_${bestaandeVleugel.id}_';

      nieuweTStijlen.removeWhere(
        (stijl) => stijl.werkvlakId.startsWith(prefix),
      );

      nieuweVleugels.removeAt(bestaandeIndex);

      return OpmetingRaamVleugelActieResultaat(
        tStijlen: nieuweTStijlen,
        vleugels: nieuweVleugels,
        gewijzigd: true,
      );
    }

    final vleugelVlak = OpmetingRaamVleugelHelper.maakVleugelVlak(
      vlak: gekozenVlak,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    final vleugelId = bestaandeIndex >= 0
        ? nieuweVleugels[bestaandeIndex].id
        : DateTime.now().microsecondsSinceEpoch.toString();

    final nieuweVleugel = OpmetingRaamVleugel(
      id: vleugelId,
      vlak: vleugelVlak,
      type: geselecteerdVleugelType,
    );

    if (bestaandeIndex >= 0) {
      final bestaandeVleugel = nieuweVleugels[bestaandeIndex];

      if (bestaandeVleugel.type != geselecteerdVleugelType) {
        final prefix = 'vleugel_${bestaandeVleugel.id}_';

        nieuweTStijlen.removeWhere(
          (stijl) => stijl.werkvlakId.startsWith(prefix),
        );
      }

      nieuweVleugels[bestaandeIndex] = nieuweVleugel;
    } else {
      nieuweVleugels.add(nieuweVleugel);
    }

    return OpmetingRaamVleugelActieResultaat(
      tStijlen: nieuweTStijlen,
      vleugels: nieuweVleugels,
      gewijzigd: true,
    );
  }

  static Size berekenVleugelMenuGrootte(Size tekenvlakGrootte) {
    final beschikbareBreedte = tekenvlakGrootte.width - 24;
    final beschikbareHoogte = tekenvlakGrootte.height - 24;

    double menuBreedte;

    if (beschikbareBreedte <= 0) {
      menuBreedte = tekenvlakGrootte.width;
    } else if (beschikbareBreedte < 260) {
      menuBreedte = beschikbareBreedte;
    } else if (beschikbareBreedte > 360) {
      menuBreedte = 360;
    } else {
      menuBreedte = beschikbareBreedte;
    }

    double menuHoogte;

    if (beschikbareHoogte <= 0) {
      menuHoogte = tekenvlakGrootte.height;
    } else if (beschikbareHoogte < 280) {
      menuHoogte = beschikbareHoogte;
    } else if (beschikbareHoogte > 500) {
      menuHoogte = 500;
    } else {
      menuHoogte = beschikbareHoogte;
    }

    return Size(menuBreedte, menuHoogte);
  }

  static Offset begrensVleugelMenuPositie({
    required Offset positie,
    required Size tekenvlakGrootte,
    required Size menuGrootte,
  }) {
    final maximaleX = tekenvlakGrootte.width > menuGrootte.width
        ? tekenvlakGrootte.width - menuGrootte.width
        : 0.0;

    final maximaleY = tekenvlakGrootte.height > menuGrootte.height
        ? tekenvlakGrootte.height - menuGrootte.height
        : 0.0;

    return Offset(
      positie.dx.clamp(0.0, maximaleX).toDouble(),
      positie.dy.clamp(0.0, maximaleY).toDouble(),
    );
  }

  static Offset verplaatsVleugelMenu({
    required Offset huidigePositie,
    required Offset verplaatsing,
    required Size tekenvlakGrootte,
    required Size menuGrootte,
  }) {
    final nieuwePositie = Offset(
      huidigePositie.dx + verplaatsing.dx,
      huidigePositie.dy + verplaatsing.dy,
    );

    return begrensVleugelMenuPositie(
      positie: nieuwePositie,
      tekenvlakGrootte: tekenvlakGrootte,
      menuGrootte: menuGrootte,
    );
  }

  static double _leesMaatWaarde(String tekst) {
    return double.tryParse(tekst.trim().replaceAll(',', '.')) ?? 0;
  }

  static bool _isGeldigeTekenvlakGrootte(Size size) {
    return size.width > 0 &&
        size.height > 0 &&
        size.width.isFinite &&
        size.height.isFinite;
  }
}
