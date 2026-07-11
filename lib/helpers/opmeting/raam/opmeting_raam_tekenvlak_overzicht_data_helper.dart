import 'package:flutter/material.dart';

import '../overzicht/opmeting_overzicht_model.dart';
import 'opmeting_raam_kleinhout_model.dart';
import 'opmeting_raam_model.dart';
import 'opmeting_raam_opvulling_model.dart';
import 'opmeting_raam_vulling_helper.dart';
import 'opmeting_raam_technische_layout_helper.dart';
import 'opmeting_raam_keuzemenu_model.dart';

class OpmetingRaamTekenvlakOverzichtDataHelper {
  const OpmetingRaamTekenvlakOverzichtDataHelper._();

  static Map<String, List<T>> kopieLijstMap<T>(Map<String, List<T>> bron) {
    return bron.map((sleutel, lijst) {
      return MapEntry(sleutel, List<T>.from(lijst));
    });
  }

  static void laadBeginTekeningData({
    required OpmetingOverzichtTekeningData? data,
    required List<OpmetingRaamTStijl> tStijlen,
    required Map<String, List<OpmetingRaamTStijl>> tStijlenPerKader,
    required List<OpmetingRaamVleugel> vleugels,
    required Map<String, List<OpmetingRaamVleugel>> vleugelsPerKader,
    required List<OpmetingRaamVullingToewijzing> vullingToewijzingen,
    required Map<String, List<OpmetingRaamVullingToewijzing>>
    vullingToewijzingenPerKader,
    required List<OpmetingRaamKleinhout> kleinhouten,
    required Map<String, List<OpmetingRaamKleinhout>> kleinhoutenPerKader,
  }) {
    if (data == null) {
      return;
    }

    tStijlen
      ..clear()
      ..addAll(data.tStijlen);
    tStijlenPerKader
      ..clear()
      ..addAll(kopieLijstMap(data.tStijlenPerKader));

    vleugels
      ..clear()
      ..addAll(data.vleugels);
    vleugelsPerKader
      ..clear()
      ..addAll(kopieLijstMap(data.vleugelsPerKader));

    vullingToewijzingen
      ..clear()
      ..addAll(data.vullingToewijzingen);
    vullingToewijzingenPerKader
      ..clear()
      ..addAll(kopieLijstMap(data.vullingToewijzingenPerKader));

    kleinhouten
      ..clear()
      ..addAll(data.kleinhouten);
    kleinhoutenPerKader
      ..clear()
      ..addAll(kopieLijstMap(data.kleinhoutenPerKader));
  }

  static Map<String, List<T>> lijstMapVoorWeergave<T>({
    required bool heeftSamenstelling,
    required Map<String, List<T>> bewaardePerKader,
    String? actieveKaderId,
    List<T>? actieveLijst,
  }) {
    if (!heeftSamenstelling) {
      return <String, List<T>>{};
    }

    final resultaat = <String, List<T>>{};

    for (final entry in bewaardePerKader.entries) {
      resultaat[entry.key] = List<T>.unmodifiable(entry.value);
    }

    if (actieveKaderId != null && actieveLijst != null) {
      resultaat[actieveKaderId] = List<T>.unmodifiable(actieveLijst);
    }

    return Map<String, List<T>>.unmodifiable(resultaat);
  }

  static Map<String, Set<String>> setMapVoorWeergave({
    required bool heeftSamenstelling,
    required Map<String, Set<String>> bewaardePerKader,
  }) {
    if (!heeftSamenstelling) {
      return <String, Set<String>>{};
    }

    final resultaat = <String, Set<String>>{};

    for (final entry in bewaardePerKader.entries) {
      resultaat[entry.key] = Set<String>.unmodifiable(entry.value);
    }

    return Map<String, Set<String>>.unmodifiable(resultaat);
  }

  static OpmetingOverzichtTekeningData maakTekeningData({
    required Size tekenvlakGrootte,
    required List<OpmetingRaamTStijl> tStijlen,
    required Map<String, List<OpmetingRaamTStijl>> tStijlenPerKader,
    required List<OpmetingRaamVleugel> vleugels,
    required Map<String, List<OpmetingRaamVleugel>> vleugelsPerKader,
    required List<OpmetingRaamVulvlak> vulvlakken,
    required Map<String, List<OpmetingRaamVulvlak>> vulvlakkenPerKader,
    required List<OpmetingRaamVullingToewijzing> vullingToewijzingen,
    required Map<String, List<OpmetingRaamVullingToewijzing>>
    vullingToewijzingenPerKader,
    required List<OpmetingRaamKleinhout> kleinhouten,
    required Map<String, List<OpmetingRaamKleinhout>> kleinhoutenPerKader,
    required List<OpmetingRaamTechnischeTekeningInstelling>
    technischeTekeningen,
    required Map<String, List<OpmetingRaamTechnischeTekeningInstelling>>
    technischeTekeningenPerKader,
    required Map<String, List<OpmetingRaamTechnischeTekeningInstelling>>
    technischeTekeningenPerKaderGroep,
    required Map<String, Set<String>> technischeKaderGroepen,
  }) {
    return OpmetingOverzichtTekeningData(
      tekenvlakBreedtePx: tekenvlakGrootte.width,
      tekenvlakHoogtePx: tekenvlakGrootte.height,
      tStijlen: List<OpmetingRaamTStijl>.unmodifiable(tStijlen),
      tStijlenPerKader: Map<String, List<OpmetingRaamTStijl>>.unmodifiable(
        tStijlenPerKader,
      ),
      vleugels: List<OpmetingRaamVleugel>.unmodifiable(vleugels),
      vleugelsPerKader: Map<String, List<OpmetingRaamVleugel>>.unmodifiable(
        vleugelsPerKader,
      ),
      vulvlakken: List<OpmetingRaamVulvlak>.unmodifiable(vulvlakken),
      vulvlakkenPerKader: Map<String, List<OpmetingRaamVulvlak>>.unmodifiable(
        vulvlakkenPerKader,
      ),
      vullingToewijzingen: List<OpmetingRaamVullingToewijzing>.unmodifiable(
        vullingToewijzingen,
      ),
      vullingToewijzingenPerKader:
          Map<String, List<OpmetingRaamVullingToewijzing>>.unmodifiable(
            vullingToewijzingenPerKader,
          ),
      kleinhouten: List<OpmetingRaamKleinhout>.unmodifiable(kleinhouten),
      kleinhoutenPerKader:
          Map<String, List<OpmetingRaamKleinhout>>.unmodifiable(
            kleinhoutenPerKader,
          ),
      technischeTekeningen:
          List<OpmetingRaamTechnischeTekeningInstelling>.unmodifiable(
            technischeTekeningen,
          ),
      technischeTekeningenPerKader:
          Map<
            String,
            List<OpmetingRaamTechnischeTekeningInstelling>
          >.unmodifiable(technischeTekeningenPerKader),
      technischeTekeningenPerKaderGroep:
          Map<
            String,
            List<OpmetingRaamTechnischeTekeningInstelling>
          >.unmodifiable(technischeTekeningenPerKaderGroep),
      technischeKaderGroepen: Map<String, Set<String>>.unmodifiable(
        technischeKaderGroepen,
      ),
    );
  }
}
