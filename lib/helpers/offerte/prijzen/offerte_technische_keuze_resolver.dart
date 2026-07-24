import '../../opmeting/raam/opmeting_raam_keuzemenu_model.dart';
import '../../opmeting/toebehoren/vaste_inzethor/opmeting_vaste_inzethor_model.dart';
import 'offerte_technische_keuze_ref.dart';

class OfferteTechnischeKeuzeResolver {
  const OfferteTechnischeKeuzeResolver._();

  /// Controleert of een technische keuze ergens in de selecties van het
  /// volledige artikel voorkomt. De koppeling gebeurt uitsluitend via de
  /// stabiele menu- en keuze-ID's.
  static bool isGeselecteerd({
    required OfferteTechnischeKeuzeRef keuze,
    required Map<String, Map<String, OpmetingRaamKeuzeSelectie>>
    keuzeSelectiesPerKader,
  }) {
    final menuId = keuze.menuId.trim();
    final keuzeId = keuze.keuzeId.trim();

    if (menuId.isEmpty || keuzeId.isEmpty) {
      return false;
    }

    for (final selecties in keuzeSelectiesPerKader.values) {
      final rechtstreekseSelectie = selecties[menuId];
      if (rechtstreekseSelectie != null &&
          rechtstreekseSelectie.optieId.trim() == keuzeId) {
        return true;
      }

      for (final selectie in selecties.values) {
        if (selectie.menuId.trim() == menuId &&
            selectie.optieId.trim() == keuzeId) {
          return true;
        }
      }
    }

    return false;
  }

  /// Maakt een compacte en stabiel gesorteerde lijst van de technische
  /// selecties. Deze lijst wordt gebruikt in de prijssignatuur om wijzigingen
  /// betrouwbaar te detecteren.
  static List<Map<String, String>> signatuurSelecties(
    Map<String, Map<String, OpmetingRaamKeuzeSelectie>> keuzeSelectiesPerKader,
  ) {
    final resultaat = <Map<String, String>>[];
    final werkvlakSleutels = keuzeSelectiesPerKader.keys.toList(growable: false)
      ..sort();

    for (final werkvlakSleutel in werkvlakSleutels) {
      final selecties = keuzeSelectiesPerKader[werkvlakSleutel];
      if (selecties == null) {
        continue;
      }

      final menuSleutels = selecties.keys.toList(growable: false)..sort();
      for (final menuSleutel in menuSleutels) {
        final selectie = selecties[menuSleutel];
        if (selectie == null) {
          continue;
        }

        resultaat.add(<String, String>{
          'werkvlak': werkvlakSleutel,
          'menuId': selectie.menuId.trim().isEmpty
              ? menuSleutel.trim()
              : selectie.menuId.trim(),
          'keuzeId': selectie.optieId.trim(),
        });
      }
    }

    return List<Map<String, String>>.unmodifiable(resultaat);
  }

  static bool pastBijVasteInzethor({
    required OfferteTechnischeKeuzeRef keuze,
    required OpmetingVasteInzethorModel model,
  }) {
    if (_normaliseer(keuze.formulierType) != 'vasteinzethor') {
      return false;
    }

    final menuId = keuze.menuId.trim();
    final keuzeId = keuze.keuzeId.trim();

    final resultaat = switch (menuId) {
      'soort' => _vergelijkSoort(keuzeId, model),
      'speling' => _vergelijkSpeling(keuzeId, model),
      'spelingKeuze' => _vergelijkSpelingKeuze(keuzeId, model),
      'flensDiepte' => _vergelijkFlensDiepte(keuzeId, model),
      'maatRandFlens' => _vergelijkMaatRandFlens(keuzeId, model),
      'profiel' => _vergelijkProfiel(keuzeId, model),
      'maatType' => _vergelijkMaatType(keuzeId, model),
      'traverseType' => _vergelijkTraverseType(keuzeId, model),
      'populaireKleur' => _vergelijkKleur(keuzeId, model),
      'gaas' => _vergelijkGaas(keuzeId, model),
      'kleurPees' => _vergelijkKleurPees(keuzeId, model),
      'borstels' => _vergelijkBorstels(keuzeId, model),
      'bevestiging' => _vergelijkBevestiging(keuzeId, model),
      'soortClipsen' => _vergelijkSoortClipsen(keuzeId, model),
      'soortBevestiging' => _vergelijkSoortBevestiging(keuzeId, model),
      _ => false,
    };

    if (resultaat) {
      return true;
    }

    return _normaliseer(keuze.keuzeTitelMomentopname) ==
        _normaliseer(_actueleWaardeVoorMenu(menuId, model));
  }

  static bool _vergelijkSoort(
    String keuzeId,
    OpmetingVasteInzethorModel model,
  ) {
    return switch (keuzeId) {
      'vliegenraamClassic' =>
        model.soort == OpmetingVasteInzethorModel.soortVliegenraamClassic,
      'vliegenraamDubbel' =>
        model.soort == OpmetingVasteInzethorModel.soortVliegenraamDubbel,
      'inzetvliegenraam' =>
        model.soort == OpmetingVasteInzethorModel.soortInzetvliegenraam,
      'vliegenraamRv' =>
        model.soort == OpmetingVasteInzethorModel.soortVliegenraamRv,
      _ => false,
    };
  }

  static bool _vergelijkSpeling(
    String keuzeId,
    OpmetingVasteInzethorModel model,
  ) {
    if (!model.isInzetvliegenraam) return false;
    return switch (keuzeId) {
      'vr033Inzet' =>
        model.speling == OpmetingVasteInzethorModel.spelingVr033Inzet,
      'vr033Ultra' =>
        model.speling == OpmetingVasteInzethorModel.spelingVr033Ultra,
      _ => false,
    };
  }

  static bool _vergelijkSpelingKeuze(
    String keuzeId,
    OpmetingVasteInzethorModel model,
  ) {
    if (!model.isInzetvliegenraam) return false;
    return switch (keuzeId) {
      'standaard' || 'standaardSpeling' => model.heeftStandaardSpeling,
      'geen' || 'geenSpeling' => model.heeftGeenSpeling,
      _ => false,
    };
  }

  static bool _vergelijkFlensDiepte(
    String keuzeId,
    OpmetingVasteInzethorModel model,
  ) {
    if (!model.isInzetvliegenraam || !model.isVr033Ultra) return false;
    return switch (keuzeId) {
      '20mm' => model.flensDiepte == OpmetingVasteInzethorModel.flensDiepte20,
      '30mm' => model.flensDiepte == OpmetingVasteInzethorModel.flensDiepte30,
      '40mm' => model.flensDiepte == OpmetingVasteInzethorModel.flensDiepte40,
      '50mm' => model.flensDiepte == OpmetingVasteInzethorModel.flensDiepte50,
      '60mm' => model.flensDiepte == OpmetingVasteInzethorModel.flensDiepte60,
      'opMaat' =>
        model.flensDiepte == OpmetingVasteInzethorModel.flensDiepteOpMaat,
      _ => false,
    };
  }

  static bool _vergelijkMaatRandFlens(
    String keuzeId,
    OpmetingVasteInzethorModel model,
  ) {
    if (!model.isInzetvliegenraam || !model.isVr033Ultra) return false;
    return switch (keuzeId) {
      '8mm' => model.maatRandFlens == OpmetingVasteInzethorModel.maatRandFlens8,
      '11mm' =>
        model.maatRandFlens == OpmetingVasteInzethorModel.maatRandFlens11,
      _ => false,
    };
  }

  static bool _vergelijkProfiel(
    String keuzeId,
    OpmetingVasteInzethorModel model,
  ) {
    if (model.isInzetvliegenraam) return false;
    return switch (keuzeId) {
      'vr050' => model.profiel == OpmetingVasteInzethorModel.profielVr050,
      'vr054' => model.profiel == OpmetingVasteInzethorModel.profielVr054,
      'vr060' => model.profiel == OpmetingVasteInzethorModel.profielVr060,
      'vr061' => model.profiel == OpmetingVasteInzethorModel.profielVr061,
      'vr080' => model.profiel == OpmetingVasteInzethorModel.profielVr080,
      'vr090' => model.profiel == OpmetingVasteInzethorModel.profielVr090,
      _ => false,
    };
  }

  static bool _vergelijkMaatType(
    String keuzeId,
    OpmetingVasteInzethorModel model,
  ) {
    return switch (keuzeId) {
      'binnenmaat' => model.isBinnenmaat,
      'buitenmaat' => !model.isBinnenmaat,
      _ => false,
    };
  }

  static bool _vergelijkTraverseType(
    String keuzeId,
    OpmetingVasteInzethorModel model,
  ) {
    return switch (keuzeId) {
      'standaard' =>
        model.traverseType == OpmetingVasteInzethorModel.traverseStandaard,
      'opMaat' =>
        model.traverseType == OpmetingVasteInzethorModel.traverseOpMaat,
      _ => false,
    };
  }

  static bool _vergelijkKleur(
    String keuzeId,
    OpmetingVasteInzethorModel model,
  ) {
    return switch (keuzeId) {
      'antraciet' =>
        model.populaireKleur == OpmetingVasteInzethorModel.kleurAntraciet,
      'bruin' => model.populaireKleur == OpmetingVasteInzethorModel.kleurBruin,
      'zwart' => model.populaireKleur == OpmetingVasteInzethorModel.kleurZwart,
      'wit' => model.populaireKleur == OpmetingVasteInzethorModel.kleurWit,
      'anodiseNatuur' =>
        model.populaireKleur == OpmetingVasteInzethorModel.kleurAnodiseNatuur,
      'poederlak' =>
        model.populaireKleur == OpmetingVasteInzethorModel.kleurPoederlak,
      'projectkleur' || 'ralKleurToebehoren' => model.isProjectkleur,
      _ => false,
    };
  }

  static bool _vergelijkGaas(String keuzeId, OpmetingVasteInzethorModel model) {
    return switch (keuzeId) {
      'standaard' => model.isGaasStandaard,
      'clearview' || 'standaardClearview' => model.isGaasClearview,

      // De historische algemene Petscreen-koppeling blijft alle
      // Petscreen-uitvoeringen herkennen. Nieuwe specifieke koppelingen
      // kunnen grijs en zwart afzonderlijk selecteren.
      'petscreen' => model.isGaasPetscreen,
      'petscreenGrijs' => model.isGaasPetscreenGrijs,
      'petscreenZwart' => model.isGaasPetscreenZwart,
      'inox' => model.isGaasInox,
      'geen' => !model.heeftGaas,
      _ => false,
    };
  }

  static bool _vergelijkKleurPees(
    String keuzeId,
    OpmetingVasteInzethorModel model,
  ) {
    return switch (keuzeId) {
      'zwart' => model.kleurPees == OpmetingVasteInzethorModel.peesZwart,
      'grijs' => model.kleurPees == OpmetingVasteInzethorModel.peesGrijs,
      _ => false,
    };
  }

  static bool _vergelijkBorstels(
    String keuzeId,
    OpmetingVasteInzethorModel model,
  ) {
    return switch (keuzeId) {
      'geen' => model.borstels == OpmetingVasteInzethorModel.borstelsGeen,
      'vp1200' => model.borstels == OpmetingVasteInzethorModel.borstelsVp1200,
      _ => false,
    };
  }

  static bool _vergelijkBevestiging(
    String keuzeId,
    OpmetingVasteInzethorModel model,
  ) {
    return switch (keuzeId) {
      'clipsenZakje' =>
        model.bevestiging == OpmetingVasteInzethorModel.bevestigingClipsenZakje,
      'clipsenGemonteerd' =>
        model.bevestiging ==
            OpmetingVasteInzethorModel.bevestigingClipsenGemonteerd,
      'geenClipsen' =>
        model.bevestiging == OpmetingVasteInzethorModel.bevestigingGeenClipsen,
      _ => false,
    };
  }

  static bool _vergelijkSoortClipsen(
    String keuzeId,
    OpmetingVasteInzethorModel model,
  ) {
    return switch (keuzeId) {
      'standaard' =>
        model.soortClipsen == OpmetingVasteInzethorModel.clipsenStandaard,
      'staallook' =>
        model.soortClipsen == OpmetingVasteInzethorModel.clipsenStaallook,
      'maritiem' || 'standaardMaritiem' =>
        model.soortClipsen ==
            OpmetingVasteInzethorModel.clipsenStandaardMaritiem,
      'staallookMaritiem' =>
        model.soortClipsen ==
            OpmetingVasteInzethorModel.clipsenStaallookMaritiem,
      _ => false,
    };
  }

  static bool _vergelijkSoortBevestiging(
    String keuzeId,
    OpmetingVasteInzethorModel model,
  ) {
    return _normaliseer(keuzeId) == _normaliseer(model.soortBevestiging);
  }

  static String _actueleWaardeVoorMenu(
    String menuId,
    OpmetingVasteInzethorModel model,
  ) {
    return switch (menuId) {
      'soort' => model.soort,
      'speling' => model.speling,
      'spelingKeuze' => model.spelingVoorOverzicht,
      'flensDiepte' => model.flensDiepte,
      'maatRandFlens' => model.maatRandFlens,
      'profiel' => model.profielVoorWeergave,
      'maatType' =>
        model.isBinnenmaat
            ? OpmetingVasteInzethorModel.maatTypeBinnen
            : OpmetingVasteInzethorModel.maatTypeBuiten,
      'traverseType' => model.traverseType,
      'populaireKleur' => model.populaireKleur,
      'gaas' => model.gaasVoorOverzicht,
      'kleurPees' => model.kleurPees,
      'borstels' => model.borstels,
      'bevestiging' => model.bevestiging,
      'soortClipsen' => model.soortClipsen,
      'soortBevestiging' => model.soortBevestigingVoorWeergave,
      _ => '',
    };
  }

  static String _normaliseer(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }
}
