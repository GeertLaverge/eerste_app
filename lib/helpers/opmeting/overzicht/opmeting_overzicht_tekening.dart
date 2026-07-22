// THIMACO-CONTROLE: OVERZICHT-MAATVOERING-VRIJE-RUIMTE-20260722
// THIMACO-CONTROLE: DEURPANEEL-LOKAAL-KADER-ANKER-20260722
// THIMACO-CONTROLE: OVERZICHT-MAATVOERING-GELIJK-INZETHOR-20260720
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../deurpanelen/opmeting_deurpaneel_teken_helper.dart';
import '../raam/opmeting_raam_tekenvlak_painter.dart';
import 'opmeting_overzicht_model.dart';

class OpmetingOverzichtTekening extends CustomPainter {
  const OpmetingOverzichtTekening({
    required this.item,
    this.toonAchtergrondRaster = true,
    this.maatPijlGrootte = 7.0,
    this.maatLettergrootte = 11.5,
    this.maatLijndikte = 0.9,
  });

  final OpmetingOverzichtRaamItem item;
  final bool toonAchtergrondRaster;

  /// Vaste visuele maten, gelijk aan de maatvoering van de vaste inzethor.
  /// De omgekeerde canvasschaal wordt intern toegepast, waardoor deze waarden
  /// niet mee vergroten of verkleinen met het raam.
  final double maatPijlGrootte;
  final double maatLettergrootte;
  final double maatLijndikte;

  @override
  void paint(Canvas canvas, Size size) {
    final data = item.tekeningData;

    final bronTekeningGrootte = _bronTekeningGrootte(item);
    final virtueleGrootte = _virtueleTekeningGrootte(
      bronTekeningGrootte: bronTekeningGrootte,
      beschikbareGrootte: size,
    );
    final schaal = math.min(
      size.width / virtueleGrootte.width,
      size.height / virtueleGrootte.height,
    );
    final dx = (size.width - virtueleGrootte.width * schaal) / 2;
    final dy = (size.height - virtueleGrootte.height * schaal) / 2;
    final veiligeSchaal = schaal.isFinite && schaal > 0 ? schaal : 1.0;

    final basisPainter = OpmetingRaamTekenvlakPainter(
      breedteMm: item.raammaatBreedteMm,
      hoogteMm: item.raammaatHoogteMm,
      geselecteerdeLijn: null,
      previewPunt: null,
      tStijlen: data.tStijlen,
      tStijlenPerKader: data.tStijlenPerKader,
      vleugels: data.vleugels,
      vleugelsPerKader: data.vleugelsPerKader,
      vulvlakken: data.vulvlakken,
      vulvlakkenPerKader: data.vulvlakkenPerKader,
      vullingToewijzingen: data.vullingToewijzingen,
      vullingToewijzingenPerKader: data.vullingToewijzingenPerKader,
      geselecteerdeVulvlakIds: const <String>{},
      geselecteerdeVulvlakIdsPerKader: const <String, Set<String>>{},
      kleinhouten: data.kleinhouten,
      kleinhoutenPerKader: data.kleinhoutenPerKader,
      geselecteerdeKleinhoutVlakIds: const <String>{},
      geselecteerdeKleinhoutVlakIdsPerKader: const <String, Set<String>>{},
      technischeTekeningen: data.technischeTekeningen,
      technischeTekeningenPerKader: data.technischeTekeningenPerKader,
      technischeTekeningenPerKaderGroep: data.technischeTekeningenPerKaderGroep,
      technischeKaderGroepen: data.technischeKaderGroepen,
      geselecteerdeKaderIds: const <String>{},
      kaderSamenstelling: item.kaderSamenstelling,
      actiefKaderId: '__overzicht_geen_actief_kader__',
      schuifraamSamenstelling: data.schuifraamSamenstelling,
      toonAchtergrondRaster: toonAchtergrondRaster,
      vasteMaatvoering: true,
      maatvoeringSchaalCorrectie: 1.0 / veiligeSchaal,
      vasteMaatPijlGrootte: maatPijlGrootte,
      vasteMaatLettergrootte: maatLettergrootte,
      vasteMaatLijndikte: maatLijndikte,
    );

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(schaal);

    basisPainter.paint(canvas, bronTekeningGrootte);

    if (item.deurpaneelToewijzingen.isNotEmpty) {
      final deurpaneelPainter = OpmetingDeurpaneelTekenvlakPainter(
        breedteMm: item.raammaatBreedteMm,
        hoogteMm: item.raammaatHoogteMm,
        vleugels: data.vleugels,
        vleugelsPerKader: data.vleugelsPerKader,
        kaderSamenstelling: item.kaderSamenstelling,
        toewijzingen: item.deurpaneelToewijzingen,
      );

      deurpaneelPainter.paint(canvas, bronTekeningGrootte);
    }

    canvas.restore();
  }

  Size _bronTekeningGrootte(OpmetingOverzichtRaamItem item) {
    final data = item.tekeningData;

    if (data.heeftTekenvlakGrootte) {
      return Size(data.tekenvlakBreedtePx, data.tekenvlakHoogtePx);
    }

    final verhouding = item.raammaatHoogteMm <= 0
        ? 1.65
        : item.raammaatBreedteMm / item.raammaatHoogteMm;

    if (verhouding >= 2.0) {
      return const Size(1100, 560);
    }

    if (verhouding <= 0.8) {
      return const Size(720, 760);
    }

    return const Size(920, 620);
  }

  Size _virtueleTekeningGrootte({
    required Size bronTekeningGrootte,
    required Size beschikbareGrootte,
  }) {
    var resultaat = bronTekeningGrootte;

    // De marge hangt af van de uiteindelijke schaal. Een paar korte iteraties
    // volstaan om de omgekeerde schaalcorrectie stabiel mee te nemen.
    for (var index = 0; index < 4; index++) {
      final schaal = math.min(
        beschikbareGrootte.width / resultaat.width,
        beschikbareGrootte.height / resultaat.height,
      );
      final veiligeSchaal = schaal.isFinite && schaal > 0 ? schaal : 1.0;
      final marge = _maatvoeringsMarge(1.0 / veiligeSchaal);
      resultaat = Size(
        bronTekeningGrootte.width + marge.width,
        bronTekeningGrootte.height + marge.height,
      );
    }

    return resultaat;
  }

  Size _maatvoeringsMarge(double schaalCorrectie) {
    final veiligeCorrectie = schaalCorrectie.isFinite && schaalCorrectie > 0
        ? schaalCorrectie
        : 1.0;
    final letterFactor = (maatLettergrootte / 11.0).clamp(0.5, 8.0).toDouble();
    final vasteFactor = veiligeCorrectie * letterFactor;

    // De bron-tekenvlakken bevatten al de normale werkmarge. Alleen de extra
    // ruimte die nodig is voor vaste maattekst wordt toegevoegd.
    final gewensteRuimteRechts = 78.0 * vasteFactor;
    final gewensteRuimteOnder = 72.0 * vasteFactor;

    return Size(
      math.max(8.0, gewensteRuimteRechts - 70.0).toDouble(),
      math.max(8.0, gewensteRuimteOnder - 66.0).toDouble(),
    );
  }

  @override
  bool shouldRepaint(covariant OpmetingOverzichtTekening oldDelegate) {
    return !identical(item, oldDelegate.item) ||
        toonAchtergrondRaster != oldDelegate.toonAchtergrondRaster ||
        maatPijlGrootte != oldDelegate.maatPijlGrootte ||
        maatLettergrootte != oldDelegate.maatLettergrootte ||
        maatLijndikte != oldDelegate.maatLijndikte;
  }
}
