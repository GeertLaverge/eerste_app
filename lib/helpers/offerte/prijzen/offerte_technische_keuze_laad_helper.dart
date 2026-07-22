// THIMACO-CONTROLE: PRIJSKEUZE-GEBRUIKT-EFFECTIEVE-UITSCHRIJFTEKST-20260720
import '../../app_storage.dart';
import '../../opmeting/raam/opmeting_raam_keuzemenu_model.dart';
import 'offerte_technische_keuze_ref.dart';

/// Laadt de zelf samengestelde technische keuzes uit de centrale opmetingsopslag
/// en zet ze om naar stabiele koppelingen voor offerteprijsregels.
class OfferteTechnischeKeuzeLaadHelper {
  const OfferteTechnischeKeuzeLaadHelper._();

  static Future<List<OfferteTechnischeKeuzeRef>> laadVoorFormulierType(
    String formulierType,
  ) async {
    final canoniekFormulierType = _canoniekFormulierType(formulierType);

    if (canoniekFormulierType.isEmpty ||
        canoniekFormulierType == 'vasteInzethor') {
      return const <OfferteTechnischeKeuzeRef>[];
    }

    final menus = await AppStorage.laadOpmetingRaamKeuzemenusVoorFormulier(
      canoniekFormulierType,
    );

    return bouwUitKeuzemenus(
      formulierType: canoniekFormulierType,
      menus: menus,
    );
  }

  static List<OfferteTechnischeKeuzeRef> bouwUitKeuzemenus({
    required String formulierType,
    required List<OpmetingRaamKeuzeMenu> menus,
  }) {
    final resultaatPerSleutel = <String, OfferteTechnischeKeuzeRef>{};
    final gesorteerdeMenus = List<OpmetingRaamKeuzeMenu>.from(menus)
      ..sort((eerste, tweede) {
        final volgorde = eerste.volgorde.compareTo(tweede.volgorde);
        if (volgorde != 0) return volgorde;
        return eerste.titel.toLowerCase().compareTo(tweede.titel.toLowerCase());
      });

    for (final menu in gesorteerdeMenus) {
      if (!menu.actief || menu.id.trim().isEmpty) {
        continue;
      }

      for (final item in menu.boomItems) {
        _verzamelKeuzes(
          formulierType: formulierType,
          menu: menu,
          item: item,
          submenuIds: const <String>[],
          submenuTitels: const <String>[],
          resultaatPerSleutel: resultaatPerSleutel,
        );
      }
    }

    final resultaat = resultaatPerSleutel.values.toList(growable: false)
      ..sort((eerste, tweede) {
        return _zichtbaarLabel(
          eerste,
        ).toLowerCase().compareTo(_zichtbaarLabel(tweede).toLowerCase());
      });

    return List<OfferteTechnischeKeuzeRef>.unmodifiable(resultaat);
  }

  static void _verzamelKeuzes({
    required String formulierType,
    required OpmetingRaamKeuzeMenu menu,
    required OpmetingRaamKeuzeMenuItem item,
    required List<String> submenuIds,
    required List<String> submenuTitels,
    required Map<String, OfferteTechnischeKeuzeRef> resultaatPerSleutel,
  }) {
    if (!item.actief) {
      return;
    }

    if (item.isSubmenu) {
      final nieuwSubmenuIds = <String>[
        ...submenuIds,
        if (item.id.trim().isNotEmpty) item.id.trim(),
      ];
      final nieuwSubmenuTitels = <String>[
        ...submenuTitels,
        if (item.weergaveNaam.trim().isNotEmpty) item.weergaveNaam.trim(),
      ];

      for (final kind in item.kinderen) {
        _verzamelKeuzes(
          formulierType: formulierType,
          menu: menu,
          item: kind,
          submenuIds: nieuwSubmenuIds,
          submenuTitels: nieuwSubmenuTitels,
          resultaatPerSleutel: resultaatPerSleutel,
        );
      }
      return;
    }

    final optie = item.optie;
    if (!item.isKeuze ||
        optie == null ||
        !optie.actief ||
        optie.isGeenKeuze ||
        optie.id.trim().isEmpty) {
      return;
    }

    final actueleOptie = _meestActueleOptieVoorId(menu: menu, itemOptie: optie);
    final keuzeTitel = actueleOptie.naam.trim().isNotEmpty
        ? actueleOptie.naam.trim()
        : item.weergaveNaam.trim();

    if (keuzeTitel.isEmpty) {
      return;
    }

    final hoeUitschrijven = _effectieveUitschrijftekst(
      menu: menu,
      optieId: actueleOptie.id,
      standaardKeuzeTitel: keuzeTitel,
    );

    final keuze = OfferteTechnischeKeuzeRef(
      formulierType: formulierType,
      menuId: menu.id.trim(),
      submenuId: submenuIds.join('/'),
      keuzeId: actueleOptie.id.trim(),
      menuTitelMomentopname: menu.titel.trim(),
      submenuTitelMomentopname: submenuTitels.join(' · '),
      keuzeTitelMomentopname: keuzeTitel,
      hoeUitschrijvenMomentopname: hoeUitschrijven,
    );

    resultaatPerSleutel[_sleutelVan(keuze)] = keuze;
  }

  static OpmetingRaamKeuzeOptie _meestActueleOptieVoorId({
    required OpmetingRaamKeuzeMenu menu,
    required OpmetingRaamKeuzeOptie itemOptie,
  }) {
    final kandidaten = <OpmetingRaamKeuzeOptie>[
      itemOptie,
      ...menu.opties.where((optie) => optie.id == itemOptie.id),
      ...menu.alleOptiesUitItems.where((optie) => optie.id == itemOptie.id),
    ];

    for (final kandidaat in kandidaten) {
      if (kandidaat.uitvoerTekst.trim().isNotEmpty) {
        return kandidaat;
      }
    }

    return itemOptie;
  }

  static String _effectieveUitschrijftekst({
    required OpmetingRaamKeuzeMenu menu,
    required String optieId,
    required String standaardKeuzeTitel,
  }) {
    final kandidaten = <OpmetingRaamKeuzeOptie>[
      ...menu.alleOptiesUitItems.where((optie) => optie.id == optieId),
      ...menu.opties.where((optie) => optie.id == optieId),
    ];

    for (final kandidaat in kandidaten) {
      final tekst = kandidaat.uitvoerTekst.trim();
      if (tekst.isNotEmpty) {
        return tekst;
      }
    }

    return standaardKeuzeTitel.trim();
  }

  static String _sleutelVan(OfferteTechnischeKeuzeRef keuze) {
    return <String>[
      keuze.formulierType.trim(),
      keuze.menuId.trim(),
      keuze.submenuId.trim(),
      keuze.keuzeId.trim(),
    ].join('|');
  }

  static String _zichtbaarLabel(OfferteTechnischeKeuzeRef keuze) {
    return <String>[
      keuze.menuTitelMomentopname.trim(),
      keuze.submenuTitelMomentopname.trim(),
      keuze.keuzeTitelMomentopname.trim(),
    ].where((deel) => deel.isNotEmpty).join(' · ');
  }

  static String _canoniekFormulierType(String waarde) {
    final genormaliseerd = waarde
        .trim()
        .toLowerCase()
        .replaceAll('_', '')
        .replaceAll(' ', '');

    return switch (genormaliseerd) {
      'vasteinzethor' => 'vasteInzethor',
      'pvcraam' => 'pvcRaam',
      'aluraam' => 'aluRaam',
      'pvcschuifraam' => 'pvcSchuifraam',
      'aluschuifraam' => 'aluSchuifraam',
      'pvcdeur' => 'pvcDeur',
      'aludeur' => 'aluDeur',
      _ => '',
    };
  }
}
