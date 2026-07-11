import 'opmeting_raam_keuzemenu_model.dart';
import 'opmeting_raam_niet_combineerbaar_keuzemenu.dart';

class OpmetingRaamKeuzeMenuHelper {
  const OpmetingRaamKeuzeMenuHelper._();

  static const String groepSleutelPrefix = 'groep::';

  static Map<String, Map<String, OpmetingRaamKeuzeSelectie>>
  kopieKeuzeSelecties(
    Map<String, Map<String, OpmetingRaamKeuzeSelectie>> bron,
  ) {
    return bron.map((sleutel, selecties) {
      return MapEntry(
        sleutel,
        Map<String, OpmetingRaamKeuzeSelectie>.from(selecties),
      );
    });
  }

  static String groepSleutelVoorKaderIds(Iterable<String> kaderIds) {
    final ids = kaderIds.where((id) => id.trim().isNotEmpty).toSet().toList()
      ..sort();

    if (ids.length <= 1) {
      return ids.isEmpty ? 'basis' : ids.first;
    }

    return '$groepSleutelPrefix${ids.join('|')}';
  }

  static bool isGroepSleutel(String sleutel) {
    return sleutel.startsWith(groepSleutelPrefix);
  }

  static Set<String> kaderIdsUitGroepSleutel(String sleutel) {
    if (!isGroepSleutel(sleutel)) {
      return sleutel.trim().isEmpty ? <String>{} : <String>{sleutel};
    }

    final idsTekst = sleutel.substring(groepSleutelPrefix.length);

    return idsTekst
        .split('|')
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  static List<OpmetingRaamKeuzeMenu>
  verwijderOngeldigeNietCombineerbareKoppelingen(
    List<OpmetingRaamKeuzeMenu> menus,
  ) {
    final bestaandeKeuzes = <String>{};

    for (final menu in menus) {
      for (final optie in menu.opties) {
        if (optie.isGeenKeuze) {
          continue;
        }

        if (menu.id.trim().isEmpty || optie.id.trim().isEmpty) {
          continue;
        }

        bestaandeKeuzes.add('${menu.id}::${optie.id}');
      }
    }

    return menus.map((menu) {
      final aangepasteOpties = menu.opties.map((optie) {
        if (optie.isGeenKeuze) {
          return optie.copyWith(
            nietCombineerbaarMet: const <OpmetingRaamNietCombineerbareKeuze>[],
          );
        }

        final geldigeKoppelingen = <OpmetingRaamNietCombineerbareKeuze>[];
        final gebruikteSleutels = <String>{};

        for (final koppeling in optie.nietCombineerbaarMet) {
          if (!koppeling.isGeldig) {
            continue;
          }

          if (koppeling.menuId == menu.id && koppeling.optieId == optie.id) {
            continue;
          }

          if (!bestaandeKeuzes.contains(koppeling.sleutel)) {
            continue;
          }

          if (!gebruikteSleutels.add(koppeling.sleutel)) {
            continue;
          }

          geldigeKoppelingen.add(koppeling);
        }

        return optie.copyWith(
          nietCombineerbaarMet:
              List<OpmetingRaamNietCombineerbareKeuze>.unmodifiable(
                geldigeKoppelingen,
              ),
        );
      }).toList();

      return menu.copyWith(opties: aangepasteOpties);
    }).toList();
  }

  static List<OpmetingRaamKeuzeMenu> sorteerMenus(
    List<OpmetingRaamKeuzeMenu> menus,
  ) {
    final gesorteerdeMenus = List<OpmetingRaamKeuzeMenu>.from(menus);

    gesorteerdeMenus.sort((eerste, tweede) {
      final volgordeVergelijking = eerste.volgorde.compareTo(tweede.volgorde);

      if (volgordeVergelijking != 0) {
        return volgordeVergelijking;
      }

      return eerste.titel.toLowerCase().compareTo(tweede.titel.toLowerCase());
    });

    return List<OpmetingRaamKeuzeMenu>.unmodifiable(gesorteerdeMenus);
  }

  static Map<String, dynamic> standaardExtraWaarden(
    OpmetingRaamKeuzeOptie optie,
  ) {
    final resultaat = <String, dynamic>{};

    for (final veld in optie.extraVelden) {
      switch (veld.type) {
        case OpmetingRaamExtraVeldType.schakelaar:
          final tekst = veld.standaardWaarde.trim().toLowerCase();
          resultaat[veld.id] = tekst == 'true' || tekst == 'ja' || tekst == '1';
          break;

        case OpmetingRaamExtraVeldType.keuze:
          if (veld.standaardWaarde.trim().isNotEmpty &&
              veld.keuzes.contains(veld.standaardWaarde)) {
            resultaat[veld.id] = veld.standaardWaarde;
          } else if (veld.keuzes.isNotEmpty) {
            resultaat[veld.id] = veld.keuzes.first;
          } else {
            resultaat[veld.id] = '';
          }
          break;

        case OpmetingRaamExtraVeldType.tekst:
        case OpmetingRaamExtraVeldType.getal:
          resultaat[veld.id] = veld.standaardWaarde;
          break;
      }
    }

    return resultaat;
  }

  static List<OpmetingRaamBeschikbareNietCombineerbareKeuze>
  beschikbareNietCombineerbareKeuzes({
    required List<OpmetingRaamKeuzeMenu> keuzemenus,
    String? uitTeSluitenMenuId,
  }) {
    final resultaat = <OpmetingRaamBeschikbareNietCombineerbareKeuze>[];
    final gebruikteSleutels = <String>{};

    final gesorteerdeMenus = List<OpmetingRaamKeuzeMenu>.from(keuzemenus)
      ..sort((eerste, tweede) => eerste.volgorde.compareTo(tweede.volgorde));

    for (final menu in gesorteerdeMenus) {
      if (menu.id == uitTeSluitenMenuId) {
        continue;
      }

      if (!menu.actief) {
        continue;
      }

      for (final optie in menu.actieveOpties) {
        if (!optie.actief || optie.isGeenKeuze) {
          continue;
        }

        final keuze = OpmetingRaamBeschikbareNietCombineerbareKeuze(
          menuId: menu.id,
          optieId: optie.id,
          menuTitel: menu.titel,
          optieNaam: optie.naam,
        );

        if (!gebruikteSleutels.add(keuze.sleutel)) {
          continue;
        }

        resultaat.add(keuze);
      }
    }

    resultaat.sort(
      (eerste, tweede) =>
          eerste.label.toLowerCase().compareTo(tweede.label.toLowerCase()),
    );

    return List<OpmetingRaamBeschikbareNietCombineerbareKeuze>.unmodifiable(
      resultaat,
    );
  }
}
