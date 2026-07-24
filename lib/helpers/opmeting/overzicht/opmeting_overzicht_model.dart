// THIMACO-CONTROLE: OVERZICHT-MODEL-PRIJSdata-BEHOUDEN-TECHNISCHE-REGEL-ZICHTBAAR-20260720
import '../../offerte/prijzen/offerte_artikel_prijs_data_model.dart';
import '../deurpanelen/opmeting_deurpaneel_toewijzing_model.dart';
import '../fotos/opmeting_foto_model.dart';
import '../kader_samenstelling/opmeting_kader_samenstelling_model.dart';
import '../raam/opmeting_raam_kleinhout_model.dart';
import '../raam/opmeting_raam_keuzemenu_model.dart';
import '../raam/opmeting_raam_model.dart';
import '../raam/opmeting_raam_vulling_helper.dart';
import '../schuifraam/opmeting_schuifraam_model.dart';
import '../toebehoren/vaste_inzethor/opmeting_vaste_inzethor_model.dart';
import '../toebehoren/vliegendeur/opmeting_vliegendeur_model.dart';

class OpmetingOverzichtTechnischeRegel {
  const OpmetingOverzichtTechnischeRegel({
    required this.titel,
    required this.waarde,
  });

  final String titel;
  final String waarde;

  bool get isZichtbaar {
    return titel.trim().isNotEmpty || waarde.trim().isNotEmpty;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'titel': titel, 'waarde': waarde};
  }

  factory OpmetingOverzichtTechnischeRegel.fromJson(Map<String, dynamic> json) {
    return OpmetingOverzichtTechnischeRegel(
      titel: json['titel']?.toString() ?? '',
      waarde: json['waarde']?.toString() ?? '',
    );
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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'titel': titel,
      'afmeting': afmeting,
      'regels': regels.map((regel) => regel.toJson()).toList(),
    };
  }

  factory OpmetingOverzichtTechnischeContainer.fromJson(
    Map<String, dynamic> json,
  ) {
    return OpmetingOverzichtTechnischeContainer(
      titel: json['titel']?.toString() ?? '',
      afmeting: json['afmeting']?.toString() ?? '',
      regels: _leesLijst(
        json['regels'],
        OpmetingOverzichtTechnischeRegel.fromJson,
      ),
    );
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
    this.schuifraamSamenstelling,
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
  final OpmetingSchuifraamSamenstelling? schuifraamSamenstelling;

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
    OpmetingSchuifraamSamenstelling? schuifraamSamenstelling,
    bool wisSchuifraamSamenstelling = false,
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
      schuifraamSamenstelling: wisSchuifraamSamenstelling
          ? null
          : schuifraamSamenstelling ?? this.schuifraamSamenstelling,
    );
  }

  String get wijzigingsSignatuur {
    return <Object?>[
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
      schuifraamSamenstelling?.toJson(),
    ].join('|');
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'tekenvlakBreedtePx': tekenvlakBreedtePx,
      'tekenvlakHoogtePx': tekenvlakHoogtePx,
      'tStijlen': tStijlen.map((item) => item.toJson()).toList(),
      'tStijlenPerKader': _schrijfMapLijst(
        tStijlenPerKader,
        (item) => item.toJson(),
      ),
      'vleugels': vleugels.map((item) => item.toJson()).toList(),
      'vleugelsPerKader': _schrijfMapLijst(
        vleugelsPerKader,
        (item) => item.toJson(),
      ),
      'vulvlakken': vulvlakken.map((item) => item.toJson()).toList(),
      'vulvlakkenPerKader': _schrijfMapLijst(
        vulvlakkenPerKader,
        (item) => item.toJson(),
      ),
      'vullingToewijzingen': vullingToewijzingen
          .map((item) => item.toJson())
          .toList(),
      'vullingToewijzingenPerKader': _schrijfMapLijst(
        vullingToewijzingenPerKader,
        (item) => item.toJson(),
      ),
      'kleinhouten': kleinhouten.map((item) => item.toJson()).toList(),
      'kleinhoutenPerKader': _schrijfMapLijst(
        kleinhoutenPerKader,
        (item) => item.toJson(),
      ),
      'technischeTekeningen': technischeTekeningen
          .map((item) => item.toJson())
          .toList(),
      'technischeTekeningenPerKader': _schrijfMapLijst(
        technischeTekeningenPerKader,
        (item) => item.toJson(),
      ),
      'technischeTekeningenPerKaderGroep': _schrijfMapLijst(
        technischeTekeningenPerKaderGroep,
        (item) => item.toJson(),
      ),
      'technischeKaderGroepen': technischeKaderGroepen.map((sleutel, ids) {
        return MapEntry(sleutel, ids.toList());
      }),
      if (schuifraamSamenstelling != null)
        'schuifraamSamenstelling': schuifraamSamenstelling!.toJson(),
    };
  }

  factory OpmetingOverzichtTekeningData.fromJson(Map<String, dynamic> json) {
    return OpmetingOverzichtTekeningData(
      tekenvlakBreedtePx: _leesDouble(json['tekenvlakBreedtePx']),
      tekenvlakHoogtePx: _leesDouble(json['tekenvlakHoogtePx']),
      tStijlen: _leesLijst(json['tStijlen'], OpmetingRaamTStijl.fromJson),
      tStijlenPerKader: _leesMapLijst(
        json['tStijlenPerKader'],
        OpmetingRaamTStijl.fromJson,
      ),
      vleugels: _leesLijst(json['vleugels'], OpmetingRaamVleugel.fromJson),
      vleugelsPerKader: _leesMapLijst(
        json['vleugelsPerKader'],
        OpmetingRaamVleugel.fromJson,
      ),
      vulvlakken: _leesLijst(json['vulvlakken'], OpmetingRaamVulvlak.fromJson),
      vulvlakkenPerKader: _leesMapLijst(
        json['vulvlakkenPerKader'],
        OpmetingRaamVulvlak.fromJson,
      ),
      vullingToewijzingen: _leesLijst(
        json['vullingToewijzingen'],
        OpmetingRaamVullingToewijzing.fromJson,
      ),
      vullingToewijzingenPerKader: _leesMapLijst(
        json['vullingToewijzingenPerKader'],
        OpmetingRaamVullingToewijzing.fromJson,
      ),
      kleinhouten: _leesLijst(
        json['kleinhouten'],
        OpmetingRaamKleinhout.fromJson,
      ),
      kleinhoutenPerKader: _leesMapLijst(
        json['kleinhoutenPerKader'],
        OpmetingRaamKleinhout.fromJson,
      ),
      technischeTekeningen: _leesLijst(
        json['technischeTekeningen'],
        OpmetingRaamTechnischeTekeningInstelling.fromJson,
      ),
      technischeTekeningenPerKader: _leesMapLijst(
        json['technischeTekeningenPerKader'],
        OpmetingRaamTechnischeTekeningInstelling.fromJson,
      ),
      technischeTekeningenPerKaderGroep: _leesMapLijst(
        json['technischeTekeningenPerKaderGroep'],
        OpmetingRaamTechnischeTekeningInstelling.fromJson,
      ),
      technischeKaderGroepen: _leesMapSet(json['technischeKaderGroepen']),
      schuifraamSamenstelling: _leesSchuifraamSamenstelling(
        json['schuifraamSamenstelling'],
      ),
    );
  }
}

enum OfferteOptiePlaatsing {
  positieBehouden('positieBehouden'),
  apartePagina('apartePagina');

  const OfferteOptiePlaatsing(this.jsonWaarde);

  final String jsonWaarde;

  static OfferteOptiePlaatsing fromJson(Object? waarde) {
    final tekst = waarde?.toString().trim();

    for (final plaatsing in OfferteOptiePlaatsing.values) {
      if (plaatsing.jsonWaarde == tekst || plaatsing.name == tekst) {
        return plaatsing;
      }
    }

    return OfferteOptiePlaatsing.apartePagina;
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
    this.formulierType = 'pvcRaam',
    this.gewijzigdOp = '',
    this.isVerwijderd = false,
    this.isOfferteOptie = false,
    this.offerteOptiePlaatsing = OfferteOptiePlaatsing.apartePagina,
    this.offerteOptieHoofdpositieId = '',
    this.gekopieerdVanPositieId = '',
    this.tekeningData = const OpmetingOverzichtTekeningData(),
    this.technischeRegels = const <OpmetingOverzichtTechnischeRegel>[],
    this.technischeContainers = const <OpmetingOverzichtTechnischeContainer>[],
    this.keuzeSelectiesPerKader =
        const <String, Map<String, OpmetingRaamKeuzeSelectie>>{},
    this.deurpaneelToewijzingen = const <OpmetingDeurpaneelToewijzing>[],
    this.fotos = const <OpmetingFoto>[],
    this.notities = '',
    this.offertePrijsData = const OfferteArtikelPrijsDataModel(),
    this.vasteInzethorData,
    this.vliegendeurData,
  });

  final String id;
  final String titel;
  final String klantNaam;
  final String formulierType;
  final String gewijzigdOp;
  final bool isVerwijderd;
  final bool isOfferteOptie;
  final OfferteOptiePlaatsing offerteOptiePlaatsing;
  final String offerteOptieHoofdpositieId;
  final String gekopieerdVanPositieId;

  bool get teltMeeInHoofdofferte => !isVerwijderd && !isOfferteOptie;
  bool get heeftOptieHoofdpositie =>
      offerteOptieHoofdpositieId.trim().isNotEmpty;
  bool get isZichtbareOfferteOptie => !isVerwijderd && isOfferteOptie;
  bool get isOfferteOptieOpPositie {
    return isZichtbareOfferteOptie &&
        offerteOptiePlaatsing == OfferteOptiePlaatsing.positieBehouden;
  }

  bool get isOfferteOptieOpApartePagina {
    return isZichtbareOfferteOptie &&
        offerteOptiePlaatsing == OfferteOptiePlaatsing.apartePagina;
  }

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
  final List<OpmetingDeurpaneelToewijzing> deurpaneelToewijzingen;
  final List<OpmetingFoto> fotos;
  final String notities;
  final OfferteArtikelPrijsDataModel offertePrijsData;
  final OpmetingVasteInzethorModel? vasteInzethorData;
  final OpmetingVliegendeurModel? vliegendeurData;

  List<OpmetingOverzichtTechnischeRegel> get zichtbareTechnischeRegels {
    return technischeRegels.where((regel) => regel.isZichtbaar).toList();
  }

  List<OpmetingOverzichtTechnischeContainer> get zichtbareTechnischeContainers {
    return technischeContainers
        .where((container) => container.isZichtbaar)
        .toList();
  }

  String get formulierTypeGenormaliseerd {
    switch (formulierType.trim()) {
      case 'aluRaam':
      case 'alu_raam':
      case 'ALU Raam':
        return 'aluRaam';

      case 'pvcSchuifraam':
      case 'pvc_schuifraam':
      case 'PVC Schuifraam':
      case 'schuifraam':
        return 'pvcSchuifraam';

      case 'aluSchuifraam':
      case 'alu_schuifraam':
      case 'ALU Schuifraam':
        return 'aluSchuifraam';

      case 'pvcDeur':
      case 'pvc_deur':
      case 'PVC Deur':
        return 'pvcDeur';

      case 'aluDeur':
      case 'alu_deur':
      case 'ALU Deur':
        return 'aluDeur';

      case 'vasteInzethor':
      case 'vaste_inzethor':
      case 'Vaste inzethor':
      case 'Vaste Inzethor':
        return 'vasteInzethor';

      case 'vliegendeur':
      case 'vliegen_deur':
      case 'Vliegendeur':
      case 'Vliegen deur':
        return 'vliegendeur';

      case 'pvcRaam':
      case 'pvc_raam':
      case 'PVC Raam':
      case 'raam':
      case '':
        return 'pvcRaam';

      default:
        return formulierType.trim().isEmpty ? 'pvcRaam' : formulierType.trim();
    }
  }

  String get formulierTypeLabel {
    switch (formulierTypeGenormaliseerd) {
      case 'aluRaam':
        return 'ALU Raam';

      case 'pvcSchuifraam':
        return 'PVC Schuifraam';

      case 'aluSchuifraam':
        return 'ALU Schuifraam';

      case 'pvcDeur':
        return 'PVC Deur';

      case 'aluDeur':
        return 'ALU Deur';

      case 'vasteInzethor':
        return 'Vaste inzethor';

      case 'vliegendeur':
        return 'Vliegendeur';

      case 'pvcRaam':
        return 'PVC Raam';

      default:
        return titel.trim().isEmpty ? formulierTypeGenormaliseerd : titel;
    }
  }

  OpmetingOverzichtRaamItem copyWith({
    String? id,
    String? titel,
    String? klantNaam,
    String? formulierType,
    String? gewijzigdOp,
    bool? isVerwijderd,
    bool? isOfferteOptie,
    OfferteOptiePlaatsing? offerteOptiePlaatsing,
    String? offerteOptieHoofdpositieId,
    String? gekopieerdVanPositieId,
    int? dagmaatBreedteMm,
    int? dagmaatHoogteMm,
    int? raammaatBreedteMm,
    int? raammaatHoogteMm,
    OpmetingKaderSamenstelling? kaderSamenstelling,
    OpmetingOverzichtTekeningData? tekeningData,
    List<OpmetingOverzichtTechnischeRegel>? technischeRegels,
    List<OpmetingOverzichtTechnischeContainer>? technischeContainers,
    Map<String, Map<String, OpmetingRaamKeuzeSelectie>>? keuzeSelectiesPerKader,
    List<OpmetingDeurpaneelToewijzing>? deurpaneelToewijzingen,
    List<OpmetingFoto>? fotos,
    String? notities,
    OfferteArtikelPrijsDataModel? offertePrijsData,
    OpmetingVasteInzethorModel? vasteInzethorData,
    OpmetingVliegendeurModel? vliegendeurData,
  }) {
    return OpmetingOverzichtRaamItem(
      id: id ?? this.id,
      titel: titel ?? this.titel,
      klantNaam: klantNaam ?? this.klantNaam,
      formulierType: formulierType ?? this.formulierType,
      gewijzigdOp: gewijzigdOp ?? this.gewijzigdOp,
      isVerwijderd: isVerwijderd ?? this.isVerwijderd,
      isOfferteOptie: isOfferteOptie ?? this.isOfferteOptie,
      offerteOptiePlaatsing:
          offerteOptiePlaatsing ?? this.offerteOptiePlaatsing,
      offerteOptieHoofdpositieId:
          offerteOptieHoofdpositieId ?? this.offerteOptieHoofdpositieId,
      gekopieerdVanPositieId:
          gekopieerdVanPositieId ?? this.gekopieerdVanPositieId,
      dagmaatBreedteMm: dagmaatBreedteMm ?? this.dagmaatBreedteMm,
      dagmaatHoogteMm: dagmaatHoogteMm ?? this.dagmaatHoogteMm,
      raammaatBreedteMm: raammaatBreedteMm ?? this.raammaatBreedteMm,
      raammaatHoogteMm: raammaatHoogteMm ?? this.raammaatHoogteMm,
      kaderSamenstelling: kaderSamenstelling ?? this.kaderSamenstelling,
      tekeningData: tekeningData ?? this.tekeningData,
      technischeRegels: technischeRegels ?? this.technischeRegels,
      technischeContainers: technischeContainers ?? this.technischeContainers,
      keuzeSelectiesPerKader:
          keuzeSelectiesPerKader ?? this.keuzeSelectiesPerKader,
      deurpaneelToewijzingen:
          deurpaneelToewijzingen ?? this.deurpaneelToewijzingen,
      fotos: fotos ?? this.fotos,
      notities: notities ?? this.notities,
      offertePrijsData: offertePrijsData ?? this.offertePrijsData,
      vasteInzethorData: vasteInzethorData ?? this.vasteInzethorData,
      vliegendeurData: vliegendeurData ?? this.vliegendeurData,
    );
  }

  OpmetingOverzichtRaamItem metNieuweWijzigingsDatum({bool? isVerwijderd}) {
    return copyWith(
      gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
      isVerwijderd: isVerwijderd,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'titel': titel,
      'klantNaam': klantNaam,
      'formulierType': formulierType,
      'gewijzigdOp': gewijzigdOp,
      'isVerwijderd': isVerwijderd,
      'isOfferteOptie': isOfferteOptie,
      'offerteOptiePlaatsing': offerteOptiePlaatsing.jsonWaarde,
      'offerteOptieHoofdpositieId': offerteOptieHoofdpositieId,
      'gekopieerdVanPositieId': gekopieerdVanPositieId,
      'dagmaatBreedteMm': dagmaatBreedteMm,
      'dagmaatHoogteMm': dagmaatHoogteMm,
      'raammaatBreedteMm': raammaatBreedteMm,
      'raammaatHoogteMm': raammaatHoogteMm,
      'kaderSamenstelling': kaderSamenstelling.toJson(),
      'tekeningData': tekeningData.toJson(),
      'technischeRegels': technischeRegels
          .map((regel) => regel.toJson())
          .toList(),
      'technischeContainers': technischeContainers
          .map((container) => container.toJson())
          .toList(),
      'keuzeSelectiesPerKader': keuzeSelectiesPerKader.map((kaderId, map) {
        return MapEntry(
          kaderId,
          map.map((menuId, selectie) {
            return MapEntry(menuId, selectie.toJson());
          }),
        );
      }),
      'deurpaneelToewijzingen': deurpaneelToewijzingen
          .map((toewijzing) => toewijzing.toJson())
          .toList(),
      'fotos': fotos.map((foto) => foto.toJson()).toList(),
      'notities': notities,
      'offertePrijsData': offertePrijsData.toJson(),
      if (vasteInzethorData != null)
        'vasteInzethorData': vasteInzethorData!.toJson(),
      if (vliegendeurData != null) 'vliegendeurData': vliegendeurData!.toJson(),
    };
  }

  factory OpmetingOverzichtRaamItem.fromJson(Map<String, dynamic> json) {
    final raammaatBreedteMm = _leesInt(json['raammaatBreedteMm']);
    final raammaatHoogteMm = _leesInt(json['raammaatHoogteMm']);
    final dagmaatBreedteMm = _leesInt(json['dagmaatBreedteMm']);
    final dagmaatHoogteMm = _leesInt(json['dagmaatHoogteMm']);

    final ruweKaderSamenstelling = json['kaderSamenstelling'];

    final kaderSamenstelling = ruweKaderSamenstelling is Map
        ? OpmetingKaderSamenstelling.fromJson(
            Map<String, dynamic>.from(ruweKaderSamenstelling),
          )
        : OpmetingKaderSamenstelling.basis(
            breedteMm: raammaatBreedteMm > 0 ? raammaatBreedteMm : 1000,
            hoogteMm: raammaatHoogteMm > 0 ? raammaatHoogteMm : 2000,
          );

    final ruweTekeningData = json['tekeningData'];

    return OpmetingOverzichtRaamItem(
      id: json['id']?.toString() ?? '',
      titel: json['titel']?.toString() ?? 'Raam',
      klantNaam: json['klantNaam']?.toString() ?? '',
      formulierType: json['formulierType']?.toString() ?? 'pvcRaam',
      gewijzigdOp: json['gewijzigdOp']?.toString() ?? '',
      isVerwijderd: json['isVerwijderd'] == true,
      isOfferteOptie: json['isOfferteOptie'] == true || json['isOptie'] == true,
      offerteOptiePlaatsing: OfferteOptiePlaatsing.fromJson(
        json['offerteOptiePlaatsing'] ?? json['optiePlaatsing'],
      ),
      offerteOptieHoofdpositieId:
          json['offerteOptieHoofdpositieId']?.toString() ??
          json['optieHoofdpositieId']?.toString() ??
          '',
      gekopieerdVanPositieId:
          json['gekopieerdVanPositieId']?.toString() ??
          json['kopieBronPositieId']?.toString() ??
          '',
      dagmaatBreedteMm: dagmaatBreedteMm,
      dagmaatHoogteMm: dagmaatHoogteMm,
      raammaatBreedteMm: raammaatBreedteMm,
      raammaatHoogteMm: raammaatHoogteMm,
      kaderSamenstelling: kaderSamenstelling,
      tekeningData: ruweTekeningData is Map
          ? OpmetingOverzichtTekeningData.fromJson(
              Map<String, dynamic>.from(ruweTekeningData),
            )
          : OpmetingOverzichtTekeningData.leeg(),
      technischeRegels: _leesLijst(
        json['technischeRegels'],
        OpmetingOverzichtTechnischeRegel.fromJson,
      ),
      technischeContainers: _leesLijst(
        json['technischeContainers'],
        OpmetingOverzichtTechnischeContainer.fromJson,
      ),
      keuzeSelectiesPerKader: _leesKeuzeSelectiesPerKader(
        json['keuzeSelectiesPerKader'],
      ),
      deurpaneelToewijzingen: _leesLijst(
        json['deurpaneelToewijzingen'],
        OpmetingDeurpaneelToewijzing.fromJson,
      ),
      fotos: _leesLijst(json['fotos'], OpmetingFoto.fromJson),
      notities: json['notities']?.toString() ?? '',
      offertePrijsData: json['offertePrijsData'] is Map
          ? OfferteArtikelPrijsDataModel.fromJson(
              Map<String, dynamic>.from(json['offertePrijsData'] as Map),
            )
          : const OfferteArtikelPrijsDataModel(),
      vasteInzethorData: json['vasteInzethorData'] is Map
          ? OpmetingVasteInzethorModel.fromJson(
              Map<String, dynamic>.from(json['vasteInzethorData'] as Map),
            )
          : null,
      vliegendeurData: json['vliegendeurData'] is Map
          ? OpmetingVliegendeurModel.fromJson(
              Map<String, dynamic>.from(json['vliegendeurData'] as Map),
            )
          : null,
    );
  }
}

List<T> _leesLijst<T>(
  Object? waarde,
  T Function(Map<String, dynamic> json) maker,
) {
  if (waarde is! List) {
    return <T>[];
  }

  return waarde.whereType<Map>().map((item) {
    return maker(Map<String, dynamic>.from(item));
  }).toList();
}

Map<String, List<T>> _leesMapLijst<T>(
  Object? waarde,
  T Function(Map<String, dynamic> json) maker,
) {
  if (waarde is! Map) {
    return <String, List<T>>{};
  }

  final resultaat = <String, List<T>>{};

  waarde.forEach((key, lijst) {
    resultaat[key.toString()] = _leesLijst(lijst, maker);
  });

  return resultaat;
}

OpmetingSchuifraamSamenstelling? _leesSchuifraamSamenstelling(Object? waarde) {
  if (waarde is! Map) {
    return null;
  }

  return OpmetingSchuifraamSamenstelling.fromJson(
    Map<String, dynamic>.from(waarde),
  );
}

Map<String, dynamic> _schrijfMapLijst<T>(
  Map<String, List<T>> bron,
  Map<String, dynamic> Function(T item) maker,
) {
  return bron.map((key, lijst) {
    return MapEntry(key, lijst.map(maker).toList());
  });
}

Map<String, Set<String>> _leesMapSet(Object? waarde) {
  if (waarde is! Map) {
    return <String, Set<String>>{};
  }

  final resultaat = <String, Set<String>>{};

  waarde.forEach((key, lijst) {
    if (lijst is List) {
      resultaat[key.toString()] = lijst
          .map((id) => id.toString())
          .where((id) => id.trim().isNotEmpty)
          .toSet();
    }
  });

  return resultaat;
}

Map<String, Map<String, OpmetingRaamKeuzeSelectie>> _leesKeuzeSelectiesPerKader(
  Object? waarde,
) {
  if (waarde is! Map) {
    return <String, Map<String, OpmetingRaamKeuzeSelectie>>{};
  }

  final resultaat = <String, Map<String, OpmetingRaamKeuzeSelectie>>{};

  waarde.forEach((kaderId, ruweSelecties) {
    if (ruweSelecties is! Map) {
      return;
    }

    final selecties = <String, OpmetingRaamKeuzeSelectie>{};

    ruweSelecties.forEach((menuId, ruweSelectie) {
      if (ruweSelectie is! Map) {
        return;
      }

      selecties[menuId.toString()] = OpmetingRaamKeuzeSelectie.fromJson(
        Map<String, dynamic>.from(ruweSelectie),
      );
    });

    resultaat[kaderId.toString()] = selecties;
  });

  return resultaat;
}

int _leesInt(Object? waarde, {int standaardWaarde = 0}) {
  if (waarde is int) {
    return waarde;
  }

  if (waarde is num) {
    return waarde.toInt();
  }

  return int.tryParse(waarde?.toString().trim() ?? '') ?? standaardWaarde;
}

double _leesDouble(Object? waarde, {double standaardWaarde = 0}) {
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
