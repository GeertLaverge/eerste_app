import 'opmeting_raam_keuzemenu_model.dart';

/// Eén concrete tekenopdracht die voortkomt uit een gekozen
/// optie in de rechterkolom.
///
/// Dit model bevat nog geen Flutter Canvas-code. Het beschrijft
/// alleen wat later getekend moet worden.
class OpmetingRaamTekenElement {
  const OpmetingRaamTekenElement({
    required this.menuId,
    required this.menuTitel,
    required this.optieId,
    required this.optieNaam,
    required this.uitvoerTekst,
    required this.tekenfunctie,
    required this.extraWaarden,
  });

  final String menuId;
  final String menuTitel;

  final String optieId;
  final String optieNaam;

  /// De tekst die later op de opmetingsfiche wordt weergegeven.
  final String uitvoerTekst;

  /// Bepaalt welke vaste tekenfunctie gebruikt moet worden.
  final OpmetingRaamTekenfunctie tekenfunctie;

  /// Ingevulde waarden zoals hoogte, breedte, positie enzovoort.
  final Map<String, dynamic> extraWaarden;

  String get id {
    return '${menuId}_$optieId';
  }

  /// Tekst die bij een tekening kan worden geplaatst.
  ///
  /// Wanneer geen aparte uitvoertekst werd ingegeven,
  /// gebruiken we de korte naam van de optie.
  String get label {
    final volledigeTekst = uitvoerTekst.trim();

    if (volledigeTekst.isNotEmpty) {
      return volledigeTekst;
    }

    return optieNaam.trim();
  }

  String tekstWaarde(String veldId, {String standaardWaarde = ''}) {
    final waarde = extraWaarden[veldId];

    if (waarde == null) {
      return standaardWaarde;
    }

    final tekst = waarde.toString().trim();

    if (tekst.isEmpty) {
      return standaardWaarde;
    }

    return tekst;
  }

  double? getalWaarde(String veldId) {
    final waarde = extraWaarden[veldId];

    if (waarde == null) {
      return null;
    }

    if (waarde is num) {
      return waarde.toDouble();
    }

    return double.tryParse(waarde.toString().trim().replaceAll(',', '.'));
  }

  int? geheelGetalWaarde(String veldId) {
    final waarde = extraWaarden[veldId];

    if (waarde == null) {
      return null;
    }

    if (waarde is int) {
      return waarde;
    }

    if (waarde is num) {
      return waarde.round();
    }

    final tekst = waarde.toString().trim();

    final rechtstreeks = int.tryParse(tekst);

    if (rechtstreeks != null) {
      return rechtstreeks;
    }

    final kommagetal = double.tryParse(tekst.replaceAll(',', '.'));

    return kommagetal?.round();
  }

  bool schakelaarWaarde(String veldId, {bool standaardWaarde = false}) {
    final waarde = extraWaarden[veldId];

    if (waarde == null) {
      return standaardWaarde;
    }

    if (waarde is bool) {
      return waarde;
    }

    if (waarde is num) {
      return waarde != 0;
    }

    final tekst = waarde.toString().trim().toLowerCase();

    if (tekst == 'true' ||
        tekst == 'ja' ||
        tekst == 'yes' ||
        tekst == '1' ||
        tekst == 'aan') {
      return true;
    }

    if (tekst == 'false' ||
        tekst == 'nee' ||
        tekst == 'no' ||
        tekst == '0' ||
        tekst == 'uit') {
      return false;
    }

    return standaardWaarde;
  }
}

class OpmetingRaamTekenfunctieHelper {
  const OpmetingRaamTekenfunctieHelper._();

  /// Zet de keuzes uit de rechterkolom om naar concrete
  /// tekenopdrachten.
  ///
  /// Niet getekend worden:
  /// - inactieve menu's;
  /// - inactieve opties;
  /// - de vaste keuze "Geen";
  /// - opties met tekenfunctie "Geen tekening";
  /// - verdwenen of ongeldige selecties.
  static List<OpmetingRaamTekenElement> bouwTekenElementen({
    required Iterable<OpmetingRaamKeuzeMenu> menus,
    required Map<String, OpmetingRaamKeuzeSelectie> selecties,
  }) {
    final gesorteerdeMenus = List<OpmetingRaamKeuzeMenu>.from(menus);

    gesorteerdeMenus.sort((eerste, tweede) {
      final volgordeVergelijking = eerste.volgorde.compareTo(tweede.volgorde);

      if (volgordeVergelijking != 0) {
        return volgordeVergelijking;
      }

      return eerste.titel.toLowerCase().compareTo(tweede.titel.toLowerCase());
    });

    final resultaat = <OpmetingRaamTekenElement>[];

    for (final menu in gesorteerdeMenus) {
      if (!menu.actief) {
        continue;
      }

      final selectie = selecties[menu.id];

      if (selectie == null) {
        continue;
      }

      final optie = _vindOptie(menu: menu, optieId: selectie.optieId);

      if (optie == null ||
          !optie.actief ||
          optie.isGeenKeuze ||
          optie.tekenfunctie == OpmetingRaamTekenfunctie.geen) {
        continue;
      }

      final effectieveExtraWaarden = _bouwEffectieveExtraWaarden(
        optie: optie,
        selectie: selectie,
      );

      resultaat.add(
        OpmetingRaamTekenElement(
          menuId: menu.id,
          menuTitel: menu.titel,
          optieId: optie.id,
          optieNaam: optie.naam,
          uitvoerTekst: optie.uitvoerTekst,
          tekenfunctie: optie.tekenfunctie,
          extraWaarden: Map<String, dynamic>.unmodifiable(
            effectieveExtraWaarden,
          ),
        ),
      );
    }

    return List<OpmetingRaamTekenElement>.unmodifiable(resultaat);
  }

  static OpmetingRaamKeuzeOptie? _vindOptie({
    required OpmetingRaamKeuzeMenu menu,
    required String optieId,
  }) {
    for (final optie in menu.opties) {
      if (optie.id == optieId) {
        return optie;
      }
    }

    return null;
  }

  /// Combineert de opgeslagen waarden van de concrete opmeting
  /// met de standaardwaarden uit de menuopbouw.
  ///
  /// Zo blijft een bestaande optie bruikbaar wanneer later een
  /// extra veld aan die optie wordt toegevoegd.
  static Map<String, dynamic> _bouwEffectieveExtraWaarden({
    required OpmetingRaamKeuzeOptie optie,
    required OpmetingRaamKeuzeSelectie selectie,
  }) {
    final resultaat = <String, dynamic>{};

    for (final veld in optie.extraVelden) {
      final opgeslagenWaarde = selectie.extraWaarden[veld.id];

      if (opgeslagenWaarde != null) {
        resultaat[veld.id] = opgeslagenWaarde;
        continue;
      }

      resultaat[veld.id] = _standaardWaardeVoorVeld(veld);
    }

    /// Waarden die nog opgeslagen zijn maar waarvan het veld
    /// later uit de menuopbouw werd verwijderd, bewaren we ook.
    ///
    /// Daardoor gaat bij oudere opmetingen geen informatie
    /// onmiddellijk verloren.
    for (final entry in selectie.extraWaarden.entries) {
      resultaat.putIfAbsent(entry.key, () => entry.value);
    }

    return resultaat;
  }

  static dynamic _standaardWaardeVoorVeld(OpmetingRaamExtraVeldDefinitie veld) {
    switch (veld.type) {
      case OpmetingRaamExtraVeldType.tekst:
        return veld.standaardWaarde;

      case OpmetingRaamExtraVeldType.getal:
        final tekst = veld.standaardWaarde.trim().replaceAll(',', '.');

        if (tekst.isEmpty) {
          return '';
        }

        return double.tryParse(tekst) ?? veld.standaardWaarde;

      case OpmetingRaamExtraVeldType.keuze:
        if (veld.keuzes.contains(veld.standaardWaarde)) {
          return veld.standaardWaarde;
        }

        if (veld.keuzes.isNotEmpty) {
          return veld.keuzes.first;
        }

        return '';

      case OpmetingRaamExtraVeldType.schakelaar:
        final tekst = veld.standaardWaarde.trim().toLowerCase();

        return tekst == 'true' ||
            tekst == 'ja' ||
            tekst == 'yes' ||
            tekst == '1' ||
            tekst == 'aan';
    }
  }

  static bool bevatTekenfunctie({
    required Iterable<OpmetingRaamTekenElement> elementen,
    required OpmetingRaamTekenfunctie tekenfunctie,
  }) {
    return elementen.any((element) => element.tekenfunctie == tekenfunctie);
  }

  static OpmetingRaamTekenElement? eersteElementVoorTekenfunctie({
    required Iterable<OpmetingRaamTekenElement> elementen,
    required OpmetingRaamTekenfunctie tekenfunctie,
  }) {
    for (final element in elementen) {
      if (element.tekenfunctie == tekenfunctie) {
        return element;
      }
    }

    return null;
  }
}
