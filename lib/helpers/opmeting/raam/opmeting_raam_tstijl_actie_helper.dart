import 'dart:ui';

import 'opmeting_raam_kader_helper.dart';
import 'opmeting_raam_model.dart';
import 'opmeting_raam_tekenvlak_acties.dart';
import 'opmeting_raam_tstijl_helper.dart';

class OpmetingRaamTStijlActieResultaat {
  const OpmetingRaamTStijlActieResultaat({
    required this.gewijzigd,
    required this.foutmelding,
    required this.tStijlen,
  });

  final bool gewijzigd;
  final String? foutmelding;
  final List<OpmetingRaamTStijl> tStijlen;
}

class OpmetingRaamTStijlActieHelper {
  const OpmetingRaamTStijlActieHelper._();

  static OpmetingRaamLijn? vindStartLijn({
    required Offset punt,
    required Size tekenvlakGrootte,
    required int breedteMm,
    required int hoogteMm,
    required List<OpmetingRaamTStijl> tStijlen,
    required List<OpmetingRaamVleugel> vleugels,
  }) {
    return OpmetingRaamTekenvlakActies.vindTStijlStartLijn(
      punt: punt,
      tekenvlakGrootte: tekenvlakGrootte,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      tStijlen: tStijlen,
      vleugels: vleugels,
    );
  }

  static Offset? bepaalPreviewPunt({
    required OpmetingRaamLijn? geselecteerdeLijn,
    required Size tekenvlakGrootte,
    required int breedteMm,
    required int hoogteMm,
    required String positieType,
    required String positieTekst,
  }) {
    return OpmetingRaamTekenvlakActies.bepaalTStijlPreviewPunt(
      geselecteerdeLijn: geselecteerdeLijn,
      tekenvlakGrootte: tekenvlakGrootte,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      positieType: positieType,
      positieTekst: positieTekst,
    );
  }

  static bool heeftVleugelsLangsBeideZijden({
    required OpmetingRaamLijn? geselecteerdeLijn,
    required Size tekenvlakGrootte,
    required int breedteMm,
    required int hoogteMm,
    required List<OpmetingRaamTStijl> tStijlen,
    required List<OpmetingRaamVleugel> vleugels,
  }) {
    final index = OpmetingRaamTekenvlakActies.indexVanGeselecteerdeTStijlLijn(
      geselecteerdeLijn,
    );

    if (index == null || index < 0 || index >= tStijlen.length) {
      return false;
    }

    final buitenKader = OpmetingRaamKaderHelper.buitenKader(
      size: tekenvlakGrootte,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    return OpmetingRaamTStijlHelper.heeftVleugelLangsBeideZijden(
      tStijlIndex: index,
      tStijlen: tStijlen,
      vleugels: vleugels,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );
  }

  static OpmetingRaamTStijlActieResultaat voegToe({
    required OpmetingRaamLijn? geselecteerdeLijn,
    required Size tekenvlakGrootte,
    required int breedteMm,
    required int hoogteMm,
    required String positieType,
    required String positieTekst,
    required List<OpmetingRaamTStijl> bestaandeTStijlen,
    required List<OpmetingRaamVleugel> bestaandeVleugels,
  }) {
    if (heeftVleugelsLangsBeideZijden(
      geselecteerdeLijn: geselecteerdeLijn,
      tekenvlakGrootte: tekenvlakGrootte,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      tStijlen: bestaandeTStijlen,
      vleugels: bestaandeVleugels,
    )) {
      return _ongewijzigd(bestaandeTStijlen: bestaandeTStijlen);
    }

    final nieuweTStijl = OpmetingRaamTekenvlakActies.maakTStijl(
      geselecteerdeLijn: geselecteerdeLijn,
      tekenvlakGrootte: tekenvlakGrootte,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      positieType: positieType,
      positieTekst: positieTekst,
      bestaandeTStijlen: bestaandeTStijlen,
      vleugels: bestaandeVleugels,
    );

    if (nieuweTStijl == null) {
      return _ongewijzigd(bestaandeTStijlen: bestaandeTStijlen);
    }

    return OpmetingRaamTStijlActieResultaat(
      gewijzigd: true,
      foutmelding: null,
      tStijlen: List<OpmetingRaamTStijl>.unmodifiable(<OpmetingRaamTStijl>[
        ...bestaandeTStijlen,
        nieuweTStijl,
      ]),
    );
  }

  static OpmetingRaamTStijlActieResultaat verwijder({
    required OpmetingRaamLijn? geselecteerdeLijn,
    required Size tekenvlakGrootte,
    required int breedteMm,
    required int hoogteMm,
    required List<OpmetingRaamTStijl> bestaandeTStijlen,
    required List<OpmetingRaamVleugel> bestaandeVleugels,
  }) {
    final index = OpmetingRaamTekenvlakActies.indexVanGeselecteerdeTStijlLijn(
      geselecteerdeLijn,
    );

    if (index == null || index < 0 || index >= bestaandeTStijlen.length) {
      return _ongewijzigd(bestaandeTStijlen: bestaandeTStijlen);
    }

    if (heeftVleugelsLangsBeideZijden(
      geselecteerdeLijn: geselecteerdeLijn,
      tekenvlakGrootte: tekenvlakGrootte,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      tStijlen: bestaandeTStijlen,
      vleugels: bestaandeVleugels,
    )) {
      return _ongewijzigd(bestaandeTStijlen: bestaandeTStijlen);
    }

    final magWissen = OpmetingRaamTekenvlakActies.magTStijlWissen(
      index: index,
      tekenvlakGrootte: tekenvlakGrootte,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      tStijlen: bestaandeTStijlen,
    );

    if (!magWissen) {
      return _ongewijzigd(
        foutmelding:
            'Deze T-stijl kan niet gewist worden omdat er een andere T-stijl op aansluit.',
        bestaandeTStijlen: bestaandeTStijlen,
      );
    }

    final nieuweTStijlen = OpmetingRaamTekenvlakActies.verwijderTStijl(
      index: index,
      tStijlen: bestaandeTStijlen,
    );

    return OpmetingRaamTStijlActieResultaat(
      gewijzigd: true,
      foutmelding: null,
      tStijlen: List<OpmetingRaamTStijl>.unmodifiable(nieuweTStijlen),
    );
  }

  static OpmetingRaamTStijlActieResultaat _ongewijzigd({
    String? foutmelding,
    required List<OpmetingRaamTStijl> bestaandeTStijlen,
  }) {
    return OpmetingRaamTStijlActieResultaat(
      gewijzigd: false,
      foutmelding: foutmelding,
      tStijlen: List<OpmetingRaamTStijl>.unmodifiable(bestaandeTStijlen),
    );
  }
}
