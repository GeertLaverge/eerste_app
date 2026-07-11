import 'package:flutter/material.dart';

import '../kader_samenstelling/opmeting_kader_samenstelling_model.dart';
import 'opmeting_raam_keuzemenu_model.dart';
import 'opmeting_raam_kleinhout_model.dart';
import 'opmeting_raam_model.dart';
import 'opmeting_raam_tekenvlak_painter.dart';
import 'opmeting_raam_vulling_helper.dart';

class OpmetingRaamTekenvlakTekenlaag extends StatelessWidget {
  const OpmetingRaamTekenvlakTekenlaag({
    super.key,
    required this.breedteMm,
    required this.hoogteMm,
    required this.onTapDown,
    required this.geselecteerdeLijn,
    required this.previewPunt,
    required this.tStijlen,
    this.tStijlenPerKader = const <String, List<OpmetingRaamTStijl>>{},
    required this.vleugels,
    this.vleugelsPerKader = const <String, List<OpmetingRaamVleugel>>{},
    required this.vulvlakken,
    this.vulvlakkenPerKader = const <String, List<OpmetingRaamVulvlak>>{},
    required this.vullingToewijzingen,
    this.vullingToewijzingenPerKader =
        const <String, List<OpmetingRaamVullingToewijzing>>{},
    required this.geselecteerdeVulvlakIds,
    this.geselecteerdeVulvlakIdsPerKader = const <String, Set<String>>{},
    required this.kleinhouten,
    this.kleinhoutenPerKader = const <String, List<OpmetingRaamKleinhout>>{},
    required this.geselecteerdeKleinhoutVlakIds,
    this.geselecteerdeKleinhoutVlakIdsPerKader = const <String, Set<String>>{},
    required this.technischeTekeningen,
    this.technischeTekeningenPerKader =
        const <String, List<OpmetingRaamTechnischeTekeningInstelling>>{},
    this.technischeTekeningenPerKaderGroep =
        const <String, List<OpmetingRaamTechnischeTekeningInstelling>>{},
    this.technischeKaderGroepen = const <String, Set<String>>{},
    this.geselecteerdeKaderIds = const <String>{},
    this.kaderSamenstelling,
    this.actiefKaderId,
  });

  final int breedteMm;
  final int hoogteMm;

  final GestureTapDownCallback onTapDown;

  final OpmetingRaamLijn? geselecteerdeLijn;
  final Offset? previewPunt;

  final List<OpmetingRaamTStijl> tStijlen;
  final Map<String, List<OpmetingRaamTStijl>> tStijlenPerKader;

  final List<OpmetingRaamVleugel> vleugels;
  final Map<String, List<OpmetingRaamVleugel>> vleugelsPerKader;

  final List<OpmetingRaamVulvlak> vulvlakken;
  final Map<String, List<OpmetingRaamVulvlak>> vulvlakkenPerKader;

  final List<OpmetingRaamVullingToewijzing> vullingToewijzingen;
  final Map<String, List<OpmetingRaamVullingToewijzing>>
  vullingToewijzingenPerKader;

  final Set<String> geselecteerdeVulvlakIds;
  final Map<String, Set<String>> geselecteerdeVulvlakIdsPerKader;

  final List<OpmetingRaamKleinhout> kleinhouten;
  final Map<String, List<OpmetingRaamKleinhout>> kleinhoutenPerKader;

  final Set<String> geselecteerdeKleinhoutVlakIds;
  final Map<String, Set<String>> geselecteerdeKleinhoutVlakIdsPerKader;

  final List<OpmetingRaamTechnischeTekeningInstelling> technischeTekeningen;

  final Map<String, List<OpmetingRaamTechnischeTekeningInstelling>>
  technischeTekeningenPerKader;

  final Map<String, List<OpmetingRaamTechnischeTekeningInstelling>>
  technischeTekeningenPerKaderGroep;

  final Map<String, Set<String>> technischeKaderGroepen;

  final Set<String> geselecteerdeKaderIds;

  final OpmetingKaderSamenstelling? kaderSamenstelling;
  final String? actiefKaderId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: onTapDown,
      child: CustomPaint(
        painter: OpmetingRaamTekenvlakPainter(
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
          geselecteerdeLijn: geselecteerdeLijn,
          previewPunt: previewPunt,
          tStijlen: tStijlen,
          tStijlenPerKader: tStijlenPerKader,
          vleugels: vleugels,
          vleugelsPerKader: vleugelsPerKader,
          vulvlakken: vulvlakken,
          vulvlakkenPerKader: vulvlakkenPerKader,
          vullingToewijzingen: vullingToewijzingen,
          vullingToewijzingenPerKader: vullingToewijzingenPerKader,
          geselecteerdeVulvlakIds: geselecteerdeVulvlakIds,
          geselecteerdeVulvlakIdsPerKader: geselecteerdeVulvlakIdsPerKader,
          kleinhouten: kleinhouten,
          kleinhoutenPerKader: kleinhoutenPerKader,
          geselecteerdeKleinhoutVlakIds: geselecteerdeKleinhoutVlakIds,
          geselecteerdeKleinhoutVlakIdsPerKader:
              geselecteerdeKleinhoutVlakIdsPerKader,
          technischeTekeningen: technischeTekeningen,
          technischeTekeningenPerKader: technischeTekeningenPerKader,
          technischeTekeningenPerKaderGroep: technischeTekeningenPerKaderGroep,
          technischeKaderGroepen: technischeKaderGroepen,
          geselecteerdeKaderIds: geselecteerdeKaderIds,
          kaderSamenstelling: kaderSamenstelling,
          actiefKaderId: actiefKaderId,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
