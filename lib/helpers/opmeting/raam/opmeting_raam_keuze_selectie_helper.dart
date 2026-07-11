import '../kader_samenstelling/opmeting_kader_samenstelling_model.dart';
import 'opmeting_raam_keuze_menu_helper.dart';
import 'opmeting_raam_keuzemenu_model.dart';

class OpmetingRaamKeuzeSelectieHelper {
  const OpmetingRaamKeuzeSelectieHelper._();

  static String actiefKaderIdVoorKeuzes({
    required OpmetingKaderSamenstelling kaderSamenstelling,
  }) {
    final actiefKader = kaderSamenstelling.actiefKader;

    if (actiefKader != null && actiefKader.id.trim().isNotEmpty) {
      return actiefKader.id;
    }

    if (kaderSamenstelling.kaders.isNotEmpty) {
      return kaderSamenstelling.kaders.first.id;
    }

    return 'basis';
  }

  static String actieveKeuzeSleutel({
    required OpmetingKaderSamenstelling kaderSamenstelling,
    required Set<String> geselecteerdeKaderIdsVoorKeuzes,
  }) {
    final geldigeKaderIds = kaderSamenstelling.kaders
        .map((kader) => kader.id)
        .where((id) => id.trim().isNotEmpty)
        .toSet();

    final geselecteerdeIds = geselecteerdeKaderIdsVoorKeuzes
        .where(geldigeKaderIds.contains)
        .toSet();

    if (geselecteerdeIds.length > 1) {
      return OpmetingRaamKeuzeMenuHelper.groepSleutelVoorKaderIds(
        geselecteerdeIds,
      );
    }

    if (geselecteerdeIds.length == 1) {
      return geselecteerdeIds.first;
    }

    return actiefKaderIdVoorKeuzes(kaderSamenstelling: kaderSamenstelling);
  }

  static Map<String, OpmetingRaamKeuzeSelectie> selectiesVoorSleutel({
    required Map<String, Map<String, OpmetingRaamKeuzeSelectie>>
    keuzeSelectiesPerKader,
    required String sleutel,
  }) {
    return keuzeSelectiesPerKader.putIfAbsent(
      sleutel,
      () => <String, OpmetingRaamKeuzeSelectie>{},
    );
  }

  static Set<String> verwijderKeuzeSelectiesVanNietBestaandeKaders({
    required OpmetingKaderSamenstelling kaderSamenstelling,
    required Map<String, Map<String, OpmetingRaamKeuzeSelectie>>
    keuzeSelectiesPerKader,
    required Set<String> geselecteerdeKaderIdsVoorKeuzes,
  }) {
    final geldigeKaderIds = kaderSamenstelling.kaders
        .map((kader) => kader.id)
        .where((id) => id.trim().isNotEmpty)
        .toSet();

    if (geldigeKaderIds.isEmpty) {
      return geselecteerdeKaderIdsVoorKeuzes;
    }

    final opgeschoondeGeselecteerdeIds = geselecteerdeKaderIdsVoorKeuzes
        .where(geldigeKaderIds.contains)
        .toSet();

    keuzeSelectiesPerKader.removeWhere((sleutel, _) {
      if (OpmetingRaamKeuzeMenuHelper.isGroepSleutel(sleutel)) {
        final ids = OpmetingRaamKeuzeMenuHelper.kaderIdsUitGroepSleutel(
          sleutel,
        );

        return ids.length <= 1 || !ids.every(geldigeKaderIds.contains);
      }

      return !geldigeKaderIds.contains(sleutel);
    });

    final actieveSleutel = actieveKeuzeSleutel(
      kaderSamenstelling: kaderSamenstelling,
      geselecteerdeKaderIdsVoorKeuzes: opgeschoondeGeselecteerdeIds,
    );

    selectiesVoorSleutel(
      keuzeSelectiesPerKader: keuzeSelectiesPerKader,
      sleutel: actieveSleutel,
    );

    return opgeschoondeGeselecteerdeIds;
  }

  static Set<String> normaliseerKeuzeSelecties({
    required OpmetingKaderSamenstelling kaderSamenstelling,
    required List<OpmetingRaamKeuzeMenu> keuzemenus,
    required Map<String, Map<String, OpmetingRaamKeuzeSelectie>>
    keuzeSelectiesPerKader,
    required Set<String> geselecteerdeKaderIdsVoorKeuzes,
  }) {
    final opgeschoondeGeselecteerdeIds =
        verwijderKeuzeSelectiesVanNietBestaandeKaders(
          kaderSamenstelling: kaderSamenstelling,
          keuzeSelectiesPerKader: keuzeSelectiesPerKader,
          geselecteerdeKaderIdsVoorKeuzes: geselecteerdeKaderIdsVoorKeuzes,
        );

    final geldigeMenuIds = keuzemenus.map((menu) => menu.id).toSet();

    void normaliseerMap(Map<String, OpmetingRaamKeuzeSelectie> selecties) {
      selecties.removeWhere((menuId, _) => !geldigeMenuIds.contains(menuId));

      for (final menu in keuzemenus) {
        final bestaandeSelectie = selecties[menu.id];
        final geldigeOptieIds = menu.actieveOpties
            .map((optie) => optie.id)
            .toSet();

        if (bestaandeSelectie != null &&
            geldigeOptieIds.contains(bestaandeSelectie.optieId)) {
          continue;
        }

        selecties[menu.id] = OpmetingRaamKeuzeSelectie(
          menuId: menu.id,
          optieId: menu.geenOptie.id,
        );
      }
    }

    for (final selecties in keuzeSelectiesPerKader.values) {
      normaliseerMap(selecties);
    }

    final actieveSleutel = actieveKeuzeSleutel(
      kaderSamenstelling: kaderSamenstelling,
      geselecteerdeKaderIdsVoorKeuzes: opgeschoondeGeselecteerdeIds,
    );

    normaliseerMap(
      selectiesVoorSleutel(
        keuzeSelectiesPerKader: keuzeSelectiesPerKader,
        sleutel: actieveSleutel,
      ),
    );

    return opgeschoondeGeselecteerdeIds;
  }

  static OpmetingRaamKeuzeSelectie selectieVoorMenu({
    required Map<String, OpmetingRaamKeuzeSelectie> selecties,
    required OpmetingRaamKeuzeMenu menu,
  }) {
    final bestaandeSelectie = selecties[menu.id];

    if (bestaandeSelectie != null) {
      return bestaandeSelectie;
    }

    return OpmetingRaamKeuzeSelectie(
      menuId: menu.id,
      optieId: menu.geenOptie.id,
    );
  }

  static OpmetingRaamKeuzeOptie optieVoorSelectie({
    required Map<String, OpmetingRaamKeuzeSelectie> selecties,
    required OpmetingRaamKeuzeMenu menu,
  }) {
    final selectie = selectieVoorMenu(selecties: selecties, menu: menu);

    for (final optie in menu.opties) {
      if (optie.id == selectie.optieId) {
        return optie;
      }
    }

    return menu.geenOptie;
  }

  static List<OpmetingRaamTechnischeTekeningInstelling>
  actieveTechnischeTekeningenVoorSleutel({
    required String sleutel,
    required Map<String, Map<String, OpmetingRaamKeuzeSelectie>>
    keuzeSelectiesPerKader,
    required List<OpmetingRaamKeuzeMenu> keuzemenus,
  }) {
    final resultaat = <OpmetingRaamTechnischeTekeningInstelling>[];
    final selecties = selectiesVoorSleutel(
      keuzeSelectiesPerKader: keuzeSelectiesPerKader,
      sleutel: sleutel,
    );

    for (final menu in keuzemenus) {
      if (!menu.actief) {
        continue;
      }

      final gekozenOptie = optieVoorSelectie(selecties: selecties, menu: menu);

      if (gekozenOptie.isGeenKeuze) {
        continue;
      }

      for (final technischeTekening in gekozenOptie.alleTechnischeTekeningen) {
        if (!technischeTekening.actief) {
          continue;
        }

        resultaat.add(technischeTekening);
      }
    }

    return List<OpmetingRaamTechnischeTekeningInstelling>.unmodifiable(
      resultaat,
    );
  }

  static Map<String, List<OpmetingRaamTechnischeTekeningInstelling>>
  technischeTekeningenPerKader({
    required OpmetingKaderSamenstelling kaderSamenstelling,
    required Map<String, Map<String, OpmetingRaamKeuzeSelectie>>
    keuzeSelectiesPerKader,
    required List<OpmetingRaamKeuzeMenu> keuzemenus,
  }) {
    final resultaat =
        <String, List<OpmetingRaamTechnischeTekeningInstelling>>{};

    for (final kader in kaderSamenstelling.kaders) {
      resultaat[kader.id] = actieveTechnischeTekeningenVoorSleutel(
        sleutel: kader.id,
        keuzeSelectiesPerKader: keuzeSelectiesPerKader,
        keuzemenus: keuzemenus,
      );
    }

    return Map<
      String,
      List<OpmetingRaamTechnischeTekeningInstelling>
    >.unmodifiable(resultaat);
  }

  static Map<String, List<OpmetingRaamTechnischeTekeningInstelling>>
  technischeTekeningenPerKaderGroep({
    required Map<String, Map<String, OpmetingRaamKeuzeSelectie>>
    keuzeSelectiesPerKader,
    required List<OpmetingRaamKeuzeMenu> keuzemenus,
  }) {
    final resultaat =
        <String, List<OpmetingRaamTechnischeTekeningInstelling>>{};

    for (final sleutel in keuzeSelectiesPerKader.keys) {
      if (!OpmetingRaamKeuzeMenuHelper.isGroepSleutel(sleutel)) {
        continue;
      }

      final tekeningen = actieveTechnischeTekeningenVoorSleutel(
        sleutel: sleutel,
        keuzeSelectiesPerKader: keuzeSelectiesPerKader,
        keuzemenus: keuzemenus,
      );

      if (tekeningen.isEmpty) {
        continue;
      }

      resultaat[sleutel] = tekeningen;
    }

    return Map<
      String,
      List<OpmetingRaamTechnischeTekeningInstelling>
    >.unmodifiable(resultaat);
  }

  static Map<String, Set<String>> technischeKaderGroepen({
    required Map<String, Map<String, OpmetingRaamKeuzeSelectie>>
    keuzeSelectiesPerKader,
  }) {
    final resultaat = <String, Set<String>>{};

    for (final sleutel in keuzeSelectiesPerKader.keys) {
      if (!OpmetingRaamKeuzeMenuHelper.isGroepSleutel(sleutel)) {
        continue;
      }

      final ids = OpmetingRaamKeuzeMenuHelper.kaderIdsUitGroepSleutel(sleutel);

      if (ids.length <= 1) {
        continue;
      }

      resultaat[sleutel] = Set<String>.unmodifiable(ids);
    }

    return Map<String, Set<String>>.unmodifiable(resultaat);
  }
}
