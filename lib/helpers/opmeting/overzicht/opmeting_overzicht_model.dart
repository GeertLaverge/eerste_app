import '../kader_samenstelling/opmeting_kader_samenstelling_model.dart';
import '../raam/opmeting_raam_kleinhout_model.dart';
import '../raam/opmeting_raam_keuzemenu_model.dart';
import '../raam/opmeting_raam_model.dart';
import '../raam/opmeting_raam_vulling_helper.dart';

class OpmetingOverzichtTechnischeRegel {
  const OpmetingOverzichtTechnischeRegel({
    required this.titel,
    required this.waarde,
  });

  final String titel;
  final String waarde;

  bool get isZichtbaar {
    return titel.trim().isNotEmpty && waarde.trim().isNotEmpty;
  }
}

class OpmetingOverzichtTechnischeContainer {
  const OpmetingOverzichtTechnischeContainer({
    required this.titel,
    required this.afmeting,
    this.regels = const <OpmetingOverzichtTechnischeRegel>[],
  });

  final String titel;
  final String afmeting;
  final List<OpmetingOverzichtTechnischeRegel> regels;

  List<OpmetingOverzichtTechnischeRegel> get zichtbareRegels {
    return regels.where((regel) => regel.isZichtbaar).toList();
  }

  bool get isZichtbaar {
    return titel.trim().isNotEmpty && afmeting.trim().isNotEmpty;
  }
}

class OpmetingOverzichtTekeningData {
  const OpmetingOverzichtTekeningData({
    this.tekenvlakBreedtePx = 0,
    this.tekenvlakHoogtePx = 0,
    this.tStijlen = const <OpmetingRaamTStijl>[],
    this.tStijlenPerKader = const <String, List<OpmetingRaamTStijl>>{},
    this.vleugels = const <OpmetingRaamVleugel>[],
    this.vleugelsPerKader = const <String, List<OpmetingRaamVleugel>>{},
    this.vulvlakken = const <OpmetingRaamVulvlak>[],
    this.vulvlakkenPerKader = const <String, List<OpmetingRaamVulvlak>>{},
    this.vullingToewijzingen = const <OpmetingRaamVullingToewijzing>[],
    this.vullingToewijzingenPerKader =
        const <String, List<OpmetingRaamVullingToewijzing>>{},
    this.kleinhouten = const <OpmetingRaamKleinhout>[],
    this.kleinhoutenPerKader = const <String, List<OpmetingRaamKleinhout>>{},
    this.technischeTekeningen =
        const <OpmetingRaamTechnischeTekeningInstelling>[],
    this.technischeTekeningenPerKader =
        const <String, List<OpmetingRaamTechnischeTekeningInstelling>>{},
    this.technischeTekeningenPerKaderGroep =
        const <String, List<OpmetingRaamTechnischeTekeningInstelling>>{},
    this.technischeKaderGroepen = const <String, Set<String>>{},
  });

  final double tekenvlakBreedtePx;
  final double tekenvlakHoogtePx;

  bool get heeftTekenvlakGrootte {
    return tekenvlakBreedtePx > 10 && tekenvlakHoogtePx > 10;
  }

  final List<OpmetingRaamTStijl> tStijlen;
  final Map<String, List<OpmetingRaamTStijl>> tStijlenPerKader;

  final List<OpmetingRaamVleugel> vleugels;
  final Map<String, List<OpmetingRaamVleugel>> vleugelsPerKader;

  final List<OpmetingRaamVulvlak> vulvlakken;
  final Map<String, List<OpmetingRaamVulvlak>> vulvlakkenPerKader;

  final List<OpmetingRaamVullingToewijzing> vullingToewijzingen;
  final Map<String, List<OpmetingRaamVullingToewijzing>>
  vullingToewijzingenPerKader;

  final List<OpmetingRaamKleinhout> kleinhouten;
  final Map<String, List<OpmetingRaamKleinhout>> kleinhoutenPerKader;

  final List<OpmetingRaamTechnischeTekeningInstelling> technischeTekeningen;
  final Map<String, List<OpmetingRaamTechnischeTekeningInstelling>>
  technischeTekeningenPerKader;
  final Map<String, List<OpmetingRaamTechnischeTekeningInstelling>>
  technischeTekeningenPerKaderGroep;
  final Map<String, Set<String>> technischeKaderGroepen;

  factory OpmetingOverzichtTekeningData.leeg() {
    return const OpmetingOverzichtTekeningData();
  }

  OpmetingOverzichtTekeningData copyWith({
    double? tekenvlakBreedtePx,
    double? tekenvlakHoogtePx,
    List<OpmetingRaamTStijl>? tStijlen,
    Map<String, List<OpmetingRaamTStijl>>? tStijlenPerKader,
    List<OpmetingRaamVleugel>? vleugels,
    Map<String, List<OpmetingRaamVleugel>>? vleugelsPerKader,
    List<OpmetingRaamVulvlak>? vulvlakken,
    Map<String, List<OpmetingRaamVulvlak>>? vulvlakkenPerKader,
    List<OpmetingRaamVullingToewijzing>? vullingToewijzingen,
    Map<String, List<OpmetingRaamVullingToewijzing>>?
    vullingToewijzingenPerKader,
    List<OpmetingRaamKleinhout>? kleinhouten,
    Map<String, List<OpmetingRaamKleinhout>>? kleinhoutenPerKader,
    List<OpmetingRaamTechnischeTekeningInstelling>? technischeTekeningen,
    Map<String, List<OpmetingRaamTechnischeTekeningInstelling>>?
    technischeTekeningenPerKader,
    Map<String, List<OpmetingRaamTechnischeTekeningInstelling>>?
    technischeTekeningenPerKaderGroep,
    Map<String, Set<String>>? technischeKaderGroepen,
  }) {
    return OpmetingOverzichtTekeningData(
      tekenvlakBreedtePx: tekenvlakBreedtePx ?? this.tekenvlakBreedtePx,
      tekenvlakHoogtePx: tekenvlakHoogtePx ?? this.tekenvlakHoogtePx,
      tStijlen: tStijlen ?? this.tStijlen,
      tStijlenPerKader: tStijlenPerKader ?? this.tStijlenPerKader,
      vleugels: vleugels ?? this.vleugels,
      vleugelsPerKader: vleugelsPerKader ?? this.vleugelsPerKader,
      vulvlakken: vulvlakken ?? this.vulvlakken,
      vulvlakkenPerKader: vulvlakkenPerKader ?? this.vulvlakkenPerKader,
      vullingToewijzingen: vullingToewijzingen ?? this.vullingToewijzingen,
      vullingToewijzingenPerKader:
          vullingToewijzingenPerKader ?? this.vullingToewijzingenPerKader,
      kleinhouten: kleinhouten ?? this.kleinhouten,
      kleinhoutenPerKader: kleinhoutenPerKader ?? this.kleinhoutenPerKader,
      technischeTekeningen: technischeTekeningen ?? this.technischeTekeningen,
      technischeTekeningenPerKader:
          technischeTekeningenPerKader ?? this.technischeTekeningenPerKader,
      technischeTekeningenPerKaderGroep:
          technischeTekeningenPerKaderGroep ??
          this.technischeTekeningenPerKaderGroep,
      technischeKaderGroepen:
          technischeKaderGroepen ?? this.technischeKaderGroepen,
    );
  }

  String get wijzigingsSignatuur {
    return <Object>[
      tekenvlakBreedtePx,
      tekenvlakHoogtePx,
      tStijlen,
      tStijlenPerKader,
      vleugels,
      vleugelsPerKader,
      vulvlakken,
      vulvlakkenPerKader,
      vullingToewijzingen,
      vullingToewijzingenPerKader,
      kleinhouten,
      kleinhoutenPerKader,
      technischeTekeningen,
      technischeTekeningenPerKader,
      technischeTekeningenPerKaderGroep,
      technischeKaderGroepen,
    ].join('|');
  }
}

class OpmetingOverzichtRaamItem {
  const OpmetingOverzichtRaamItem({
    required this.id,
    required this.titel,
    required this.klantNaam,
    required this.dagmaatBreedteMm,
    required this.dagmaatHoogteMm,
    required this.raammaatBreedteMm,
    required this.raammaatHoogteMm,
    required this.kaderSamenstelling,
    this.tekeningData = const OpmetingOverzichtTekeningData(),
    this.technischeRegels = const <OpmetingOverzichtTechnischeRegel>[],
    this.technischeContainers = const <OpmetingOverzichtTechnischeContainer>[],
    this.keuzeSelectiesPerKader =
        const <String, Map<String, OpmetingRaamKeuzeSelectie>>{},
    this.notities = '',
  });

  final String id;
  final String titel;
  final String klantNaam;

  final int dagmaatBreedteMm;
  final int dagmaatHoogteMm;
  final int raammaatBreedteMm;
  final int raammaatHoogteMm;

  final OpmetingKaderSamenstelling kaderSamenstelling;
  final OpmetingOverzichtTekeningData tekeningData;
  final List<OpmetingOverzichtTechnischeRegel> technischeRegels;
  final List<OpmetingOverzichtTechnischeContainer> technischeContainers;
  final Map<String, Map<String, OpmetingRaamKeuzeSelectie>>
  keuzeSelectiesPerKader;
  final String notities;

  List<OpmetingOverzichtTechnischeRegel> get zichtbareTechnischeRegels {
    return technischeRegels.where((regel) => regel.isZichtbaar).toList();
  }

  List<OpmetingOverzichtTechnischeContainer> get zichtbareTechnischeContainers {
    return technischeContainers
        .where((container) => container.isZichtbaar)
        .toList();
  }
}
