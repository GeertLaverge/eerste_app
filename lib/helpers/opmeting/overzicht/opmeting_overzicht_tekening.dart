import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../deurpanelen/opmeting_deurpaneel_teken_helper.dart';
import '../raam/opmeting_raam_model.dart';
import '../raam/opmeting_raam_tekenvlak_painter.dart';
import 'opmeting_overzicht_model.dart';

class OpmetingOverzichtTekening extends CustomPainter {
  const OpmetingOverzichtTekening({required this.item});

  final OpmetingOverzichtRaamItem item;

  @override
  void paint(Canvas canvas, Size size) {
    final data = item.tekeningData;

    final virtueleGrootte = _virtueleTekeningGrootte(item);
    final schaal = math.min(
      size.width / virtueleGrootte.width,
      size.height / virtueleGrootte.height,
    );
    final dx = (size.width - virtueleGrootte.width * schaal) / 2;
    final dy = (size.height - virtueleGrootte.height * schaal) / 2;

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
    );

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(schaal);

    basisPainter.paint(canvas, virtueleGrootte);

    if (item.deurpaneelToewijzingen.isNotEmpty) {
      final deurpaneelPainter = OpmetingDeurpaneelTekenvlakPainter(
        breedteMm: item.raammaatBreedteMm,
        hoogteMm: item.raammaatHoogteMm,
        vleugels: _alleVleugelsVoorOverzicht(data),
        toewijzingen: item.deurpaneelToewijzingen,
      );

      deurpaneelPainter.paint(canvas, virtueleGrootte);
    }

    canvas.restore();
  }

  List<OpmetingRaamVleugel> _alleVleugelsVoorOverzicht(
    OpmetingOverzichtTekeningData data,
  ) {
    final resultaat = <OpmetingRaamVleugel>[];
    final ids = <String>{};

    void voegToe(Iterable<OpmetingRaamVleugel> vleugels) {
      for (final vleugel in vleugels) {
        if (ids.contains(vleugel.id)) {
          continue;
        }

        ids.add(vleugel.id);
        resultaat.add(vleugel);
      }
    }

    voegToe(data.vleugels);

    for (final lijst in data.vleugelsPerKader.values) {
      voegToe(lijst);
    }

    return List<OpmetingRaamVleugel>.unmodifiable(resultaat);
  }

  Size _virtueleTekeningGrootte(OpmetingOverzichtRaamItem item) {
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

  @override
  bool shouldRepaint(covariant OpmetingOverzichtTekening oldDelegate) {
    return !identical(item, oldDelegate.item);
  }
}
