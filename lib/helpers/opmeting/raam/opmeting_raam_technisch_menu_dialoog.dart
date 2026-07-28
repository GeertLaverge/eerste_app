// THIMACO-CONTROLE: TECHNISCHE-STAMBOOM-VOLGORDE-BINNEN-ZELFDE-NIVEAU-20260728
// THIMACO-CONTROLE: TECHNISCHE-STAMBOOM-HERNOEMEN-KOPIEREN-VERPLAATSEN-20260728
// THIMACO-CONTROLE: STAMBOOM-WISSEN-INKLAPPEN-KEUZE-KOPIEREN-20260727
// THIMACO-CONTROLE: ALLE-TITELS-OP-EEN-BLAD-EN-STABIELE-INVOEGDIALOOG-20260727
// THIMACO-CONTROLE: RUSTIGE-STAMBOOM-EERST-STRUCTUUR-DAN-INVULLEN-20260727
// THIMACO-CONTROLE: COMPACTE-BOOM-KOPIEREN-VANUIT-BOOM-FASE-3-20260727
// THIMACO-CONTROLE: COMPACTE-BOOM-AANMAKEN-VANUIT-BOOM-FASE-2-20260727
// THIMACO-CONTROLE: COMPACTE-BOOM-KEUZE-APART-20260727
// THIMACO-CONTROLE: KEUZE-OPLADEN-BEHOUDT-STABIELE-IDS-20260727
// THIMACO-CONTROLE: TITEL-TECHNISCHE-KEUZE-BIBLIOTHEEK-20260722
// THIMACO-CONTROLE: HOE-UITSCHRIJVEN-KEUZE-OPLADEN-20260720
import 'package:flutter/material.dart';

import 'opmeting_raam_keuzemenu_model.dart';
import 'opmeting_raam_niet_combineerbaar_keuzemenu.dart';
import 'opmeting_raam_technische_tekening_editor.dart';

class OpmetingRaamTechnischeSoortResultaat {
  const OpmetingRaamTechnischeSoortResultaat({
    required this.id,
    required this.naam,
    this.hoeUitschrijven = '',
    this.tekeningen = const <OpmetingRaamTechnischeTekeningInstelling>[],
    OpmetingRaamTechnischeTekeningInstelling? tekening,
    this.nietCombineerbaarMet = const <OpmetingRaamNietCombineerbareKeuze>[],
  }) : _oudeTekening = tekening;

  final String id;
  final String naam;
  final String hoeUitschrijven;

  String get effectieveUitschrijftekst {
    final tekst = hoeUitschrijven.trim();
    return tekst.isNotEmpty ? tekst : naam.trim();
  }

  final List<OpmetingRaamTechnischeTekeningInstelling> tekeningen;
  final OpmetingRaamTechnischeTekeningInstelling? _oudeTekening;
  final List<OpmetingRaamNietCombineerbareKeuze> nietCombineerbaarMet;

  List<OpmetingRaamTechnischeTekeningInstelling> get alleTekeningen {
    if (tekeningen.isNotEmpty) {
      return List<OpmetingRaamTechnischeTekeningInstelling>.unmodifiable(
        tekeningen.take(4),
      );
    }

    if (_oudeTekening != null) {
      return List<OpmetingRaamTechnischeTekeningInstelling>.unmodifiable(
        <OpmetingRaamTechnischeTekeningInstelling>[_oudeTekening],
      );
    }

    return const <OpmetingRaamTechnischeTekeningInstelling>[];
  }

  OpmetingRaamTechnischeTekeningInstelling get tekening {
    final bestaandeTekeningen = alleTekeningen;

    if (bestaandeTekeningen.isNotEmpty) {
      return bestaandeTekeningen.first;
    }

    return OpmetingRaamTechnischeTekeningInstelling.standaard();
  }
}

class OpmetingRaamTechnischeOplaadbareKeuze {
  const OpmetingRaamTechnischeOplaadbareKeuze({
    required this.id,
    required this.formulierNaam,
    required this.titel,
    required this.items,
  });

  final String id;
  final String formulierNaam;
  final String titel;
  final List<OpmetingRaamKeuzeMenuItem> items;

  String get label {
    final netteTitel = titel.trim();
    final netteFormulierNaam = formulierNaam.trim();

    if (netteTitel.isEmpty) {
      return netteFormulierNaam.isEmpty
          ? 'Technische keuze'
          : netteFormulierNaam;
    }

    return netteFormulierNaam.isEmpty
        ? netteTitel
        : '$netteTitel · $netteFormulierNaam';
  }
}

class OpmetingRaamTechnischMenuResultaat {
  const OpmetingRaamTechnischMenuResultaat({
    required this.titel,
    required this.soorten,
    required this.actief,
    this.items = const <OpmetingRaamKeuzeMenuItem>[],
  });

  final String titel;
  final List<OpmetingRaamTechnischeSoortResultaat> soorten;
  final List<OpmetingRaamKeuzeMenuItem> items;
  final bool actief;
}

enum OpmetingRaamTechnischMenuBeginActie {
  nieuweKeuze,
  nieuwSubmenu,
  kopieerItem,
  bewerkKeuze,
}

class OpmetingRaamTechnischMenuBeginToevoeging {
  const OpmetingRaamTechnischMenuBeginToevoeging({
    required this.actie,
    this.ouderSubmenuId,
    this.bronItemId,
  });

  final OpmetingRaamTechnischMenuBeginActie actie;
  final String? ouderSubmenuId;
  final String? bronItemId;
}

Future<OpmetingRaamTechnischMenuResultaat?>
toonOpmetingRaamTechnischMenuDialoog({
  required BuildContext context,
  OpmetingRaamTechnischMenuResultaat? bestaandMenu,
  List<OpmetingRaamBeschikbareNietCombineerbareKeuze>
      beschikbareNietCombineerbareKeuzes =
      const <OpmetingRaamBeschikbareNietCombineerbareKeuze>[],
  List<OpmetingRaamTechnischeOplaadbareKeuze> oplaadbareKeuzes =
      const <OpmetingRaamTechnischeOplaadbareKeuze>[],
  OpmetingRaamTechnischMenuBeginToevoeging? beginToevoeging,
  bool kopieerAlsNieuw = false,
  bool alleenKeuzeInvullen = false,
}) {
  const groen = Color(0xFF0B7A3B);

  return showDialog<OpmetingRaamTechnischMenuResultaat>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final basisTheme = Theme.of(dialogContext);

      return Theme(
        data: basisTheme.copyWith(
          colorScheme: basisTheme.colorScheme.copyWith(
            primary: groen,
            secondary: groen,
          ),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: groen,
            selectionHandleColor: groen,
          ),
          inputDecorationTheme: basisTheme.inputDecorationTheme.copyWith(
            floatingLabelStyle: const TextStyle(
              color: groen,
              fontWeight: FontWeight.w700,
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: groen, width: 2),
            ),
          ),
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: groen,
          ),
        ),
        child: OpmetingRaamTechnischMenuDialoog(
          bestaandMenu: bestaandMenu,
          beschikbareNietCombineerbareKeuzes:
              beschikbareNietCombineerbareKeuzes,
          oplaadbareKeuzes: oplaadbareKeuzes,
          beginToevoeging: beginToevoeging,
          kopieerAlsNieuw: kopieerAlsNieuw,
          alleenKeuzeInvullen: alleenKeuzeInvullen,
        ),
      );
    },
  );
}

class OpmetingRaamTechnischMenuDialoog extends StatefulWidget {
  const OpmetingRaamTechnischMenuDialoog({
    super.key,
    this.bestaandMenu,
    this.beschikbareNietCombineerbareKeuzes =
        const <OpmetingRaamBeschikbareNietCombineerbareKeuze>[],
    this.oplaadbareKeuzes = const <OpmetingRaamTechnischeOplaadbareKeuze>[],
    this.beginToevoeging,
    this.kopieerAlsNieuw = false,
    this.alleenKeuzeInvullen = false,
  });

  final OpmetingRaamTechnischMenuResultaat? bestaandMenu;
  final List<OpmetingRaamBeschikbareNietCombineerbareKeuze>
  beschikbareNietCombineerbareKeuzes;
  final List<OpmetingRaamTechnischeOplaadbareKeuze> oplaadbareKeuzes;
  final OpmetingRaamTechnischMenuBeginToevoeging? beginToevoeging;
  final bool kopieerAlsNieuw;
  final bool alleenKeuzeInvullen;

  @override
  State<OpmetingRaamTechnischMenuDialoog> createState() {
    return _OpmetingRaamTechnischMenuDialoogState();
  }
}

class _OpmetingRaamTechnischMenuDialoogState
    extends State<OpmetingRaamTechnischMenuDialoog> {
  static const Color groen = Color(0xFF0B7A3B);
  static const Color lichtGroen = Color(0xFFE7F6EC);
  static const Color rand = Color(0xFFE5E7EB);

  late final TextEditingController _titelController;
  late final FocusNode _titelFocusNode;
  late final ScrollController _boomScrollController;
  String? _geselecteerdeTitelKeuzeSleutel;
  bool _titelBevestigd = false;

  final List<_TechnischMenuItemConcept> _items = <_TechnischMenuItemConcept>[];

  _TechnischMenuItemConcept? _geopendeKeuze;
  double _bewaardeBoomScrollOffset = 0;
  String? _foutmelding;

  @override
  void initState() {
    super.initState();

    _titelController = TextEditingController(
      text: widget.bestaandMenu?.titel ?? '',
    );
    _titelFocusNode = FocusNode();
    _boomScrollController = ScrollController();
    _titelBevestigd = widget.bestaandMenu != null;

    final bestaandeItems = widget.bestaandMenu?.items;

    if (bestaandeItems != null && bestaandeItems.isNotEmpty) {
      for (final item in bestaandeItems) {
        if (item.isKeuze && item.optie?.isGeenKeuze == true) {
          continue;
        }

        _items.add(_TechnischMenuItemConcept.vanMenuItem(item));
      }
    } else {
      final bestaandeSoorten = widget.bestaandMenu?.soorten;

      if (bestaandeSoorten != null && bestaandeSoorten.isNotEmpty) {
        for (final soort in bestaandeSoorten) {
          _items.add(_TechnischMenuItemConcept.vanResultaat(soort));
        }
      }
    }

    _zetAllesIngeklapt(_items);

    if (widget.kopieerAlsNieuw && widget.bestaandMenu != null) {
      _maakHuidigMenuKopie();
    }

    final beginToevoeging = widget.beginToevoeging;

    if (beginToevoeging != null) {
      _pasBeginToevoegingToe(beginToevoeging);
    }
  }

  @override
  void dispose() {
    _titelController.dispose();
    _titelFocusNode.dispose();
    _boomScrollController.dispose();

    for (final item in _items) {
      item.dispose();
    }

    super.dispose();
  }

  static int _idTeller = 0;

  String _nieuwId(String prefix) {
    _idTeller++;

    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}_$_idTeller';
  }

  List<_TechnischeKeuzeBronOptie> _maakTitelKeuzeOpties() {
    final keuzes =
        List<OpmetingRaamTechnischeOplaadbareKeuze>.from(
          widget.oplaadbareKeuzes,
        )..sort((eerste, tweede) {
          final titelVergelijking = eerste.titel.trim().toLowerCase().compareTo(
            tweede.titel.trim().toLowerCase(),
          );

          if (titelVergelijking != 0) {
            return titelVergelijking;
          }

          return eerste.formulierNaam.trim().toLowerCase().compareTo(
            tweede.formulierNaam.trim().toLowerCase(),
          );
        });

    final gebruikteSleutels = <String>{};
    final opties = <_TechnischeKeuzeBronOptie>[];

    for (var index = 0; index < keuzes.length; index++) {
      final keuze = keuzes[index];
      final id = keuze.id.trim();
      final basisSleutel = id.isNotEmpty
          ? 'bestaand:$id'
          : 'bestaand:${keuze.titel.trim().toLowerCase()}:'
                '${keuze.formulierNaam.trim().toLowerCase()}';
      var sleutel = basisSleutel;
      var volgnummer = 2;

      while (!gebruikteSleutels.add(sleutel)) {
        sleutel = '$basisSleutel:$volgnummer';
        volgnummer++;
      }

      opties.add(_TechnischeKeuzeBronOptie(sleutel: sleutel, keuze: keuze));
    }

    return List<_TechnischeKeuzeBronOptie>.unmodifiable(opties);
  }

  void _selecteerTitelKeuze(String? sleutel) {
    if (sleutel == null || sleutel.trim().isEmpty) {
      return;
    }

    for (final optie in _maakTitelKeuzeOpties()) {
      if (optie.sleutel == sleutel) {
        _laadTechnischeKeuze(optie.keuze, bronSleutel: optie.sleutel);
        return;
      }
    }

    _toonFout('De gekozen titel kon niet worden geladen.');
  }

  void _zetAllesIngeklapt(List<_TechnischMenuItemConcept> lijst) {
    for (final item in lijst) {
      item.ingeklapt = true;
      _zetAllesIngeklapt(item.kinderen);
    }
  }

  void _maakHuidigMenuKopie() {
    final kopieen = <_TechnischMenuItemConcept>[];

    for (final item in _items) {
      kopieen.add(
        _TechnischMenuItemConcept.kopieVan(
          item,
          nieuwId: _nieuwId,
          naamAlsKopie: false,
        ),
      );
      item.dispose();
    }

    _items
      ..clear()
      ..addAll(kopieen);

    final titel = _titelController.text.trim();
    _titelController.text = titel.isEmpty ? '' : '$titel kopie';
    _geselecteerdeTitelKeuzeSleutel = null;
    _titelBevestigd = true;
    _zetAllesIngeklapt(_items);
    _geopendeKeuze = null;
    _foutmelding = null;
  }

  void _pasBeginToevoegingToe(
    OpmetingRaamTechnischMenuBeginToevoeging toevoeging,
  ) {
    _titelBevestigd = true;

    if (toevoeging.actie == OpmetingRaamTechnischMenuBeginActie.bewerkKeuze) {
      final locatie = _vindItemLocatieEnOpenPad(toevoeging.bronItemId);

      if (locatie == null || !locatie.item.isKeuze) {
        _foutmelding =
            'De gekozen technische keuze kon niet meer worden gevonden. Open het overzicht opnieuw en probeer nogmaals.';
        return;
      }

      _geopendeKeuze = locatie.item;
      _foutmelding = null;
      return;
    }

    if (toevoeging.actie == OpmetingRaamTechnischMenuBeginActie.kopieerItem) {
      final locatie = _vindItemLocatieEnOpenPad(toevoeging.bronItemId);

      if (locatie == null) {
        _foutmelding =
            'De gekozen keuze of het submenu kon niet meer worden gevonden. Open de boom opnieuw en probeer nogmaals.';
        return;
      }

      final kopie = _TechnischMenuItemConcept.kopieVan(
        locatie.item,
        nieuwId: _nieuwId,
      );
      locatie.lijst.insert(locatie.index + 1, kopie);
      _foutmelding = null;
      return;
    }

    final doelLijst = _vindDoelLijstEnOpenPad(toevoeging.ouderSubmenuId);

    if (doelLijst == null) {
      _foutmelding =
          'Het gekozen submenu kon niet meer worden gevonden. Open de boom opnieuw en probeer nogmaals.';
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }

      switch (toevoeging.actie) {
        case OpmetingRaamTechnischMenuBeginActie.nieuweKeuze:
          await _voegKeuzeToe(doelLijst: doelLijst);
          break;

        case OpmetingRaamTechnischMenuBeginActie.nieuwSubmenu:
          await _voegSubmenuToe(doelLijst: doelLijst);
          break;

        case OpmetingRaamTechnischMenuBeginActie.kopieerItem:
        case OpmetingRaamTechnischMenuBeginActie.bewerkKeuze:
          break;
      }
    });
  }

  _TechnischMenuItemLocatie? _vindItemLocatieEnOpenPad(String? bronItemId) {
    final doelId = bronItemId?.trim() ?? '';

    if (doelId.isEmpty) {
      return null;
    }

    _TechnischMenuItemLocatie? zoek(List<_TechnischMenuItemConcept> lijst) {
      for (var index = 0; index < lijst.length; index++) {
        final item = lijst[index];

        if (item.id == doelId) {
          return _TechnischMenuItemLocatie(
            lijst: lijst,
            item: item,
            index: index,
          );
        }

        if (!item.isSubmenu) {
          continue;
        }

        final gevonden = zoek(item.kinderen);

        if (gevonden != null) {
          item.ingeklapt = false;
          return gevonden;
        }
      }

      return null;
    }

    return zoek(_items);
  }

  List<_TechnischMenuItemConcept>? _vindDoelLijstEnOpenPad(
    String? ouderSubmenuId,
  ) {
    final doelId = ouderSubmenuId?.trim() ?? '';

    if (doelId.isEmpty) {
      return _items;
    }

    List<_TechnischMenuItemConcept>? zoek(
      List<_TechnischMenuItemConcept> lijst,
    ) {
      for (final item in lijst) {
        if (!item.isSubmenu) {
          continue;
        }

        if (item.id == doelId) {
          item.ingeklapt = false;
          return item.kinderen;
        }

        final gevonden = zoek(item.kinderen);

        if (gevonden != null) {
          item.ingeklapt = false;
          return gevonden;
        }
      }

      return null;
    }

    return zoek(_items);
  }

  void _bewaarBoomScrollpositie() {
    if (_boomScrollController.hasClients) {
      _bewaardeBoomScrollOffset = _boomScrollController.offset;
    }
  }

  void _herstelBoomScrollpositie() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_boomScrollController.hasClients) {
        return;
      }

      final maximum = _boomScrollController.position.maxScrollExtent;
      final doel = _bewaardeBoomScrollOffset.clamp(0.0, maximum).toDouble();
      _boomScrollController.jumpTo(doel);
    });
  }

  void _openKeuze(_TechnischMenuItemConcept item) {
    if (!item.isKeuze) {
      return;
    }

    _bewaarBoomScrollpositie();

    setState(() {
      _geopendeKeuze = item;
      _foutmelding = null;
    });
  }

  void _sluitKeuzeInvulscherm() {
    setState(() {
      _geopendeKeuze = null;
      _foutmelding = null;
    });

    _herstelBoomScrollpositie();
  }

  Future<void> _voegKeuzeToe({
    List<_TechnischMenuItemConcept>? doelLijst,
    String? voorafIngevuldeNaam,
  }) async {
    final naam =
        voorafIngevuldeNaam ??
        await _vraagNaamVoorStructuurItem(isSubmenu: false);

    if (!mounted || naam == null) {
      return;
    }

    final nieuweKeuze = _TechnischMenuItemConcept.nieuweKeuze(
      id: _nieuwId('soort'),
      ingeklapt: true,
    );
    nieuweKeuze.naamController.text = naam.trim();

    setState(() {
      (doelLijst ?? _items).add(nieuweKeuze);
      _foutmelding = null;
    });
  }

  Future<void> _voegSubmenuToe({
    List<_TechnischMenuItemConcept>? doelLijst,
    String? voorafIngevuldeNaam,
  }) async {
    final naam =
        voorafIngevuldeNaam ??
        await _vraagNaamVoorStructuurItem(isSubmenu: true);

    if (!mounted || naam == null) {
      return;
    }

    final nieuwSubmenu = _TechnischMenuItemConcept.nieuwSubmenu(
      id: _nieuwId('submenu'),
      ingeklapt: false,
    );
    nieuwSubmenu.naamController.text = naam.trim();

    setState(() {
      (doelLijst ?? _items).add(nieuwSubmenu);
      _foutmelding = null;
    });
  }

  void _laadTechnischeKeuze(
    OpmetingRaamTechnischeOplaadbareKeuze geladenKeuze, {
    String? bronSleutel,
  }) {
    final nieuweItems = <_TechnischMenuItemConcept>[];

    for (final bronItem in geladenKeuze.items) {
      final tijdelijkConcept = _TechnischMenuItemConcept.vanMenuItem(bronItem);
      final kopie = _TechnischMenuItemConcept.kopieVan(
        tijdelijkConcept,
        nieuwId: _nieuwId,
        naamAlsKopie: false,
        behoudNietCombineerbaar: false,
        behoudIds: true,
      );
      tijdelijkConcept.dispose();
      nieuweItems.add(kopie);
    }

    if (nieuweItems.isEmpty) {
      _toonFout('De gekozen titel bevat geen bruikbare keuzes.');
      return;
    }

    setState(() {
      for (final item in _items) {
        item.dispose();
      }

      _items
        ..clear()
        ..addAll(nieuweItems);

      _titelController.text = geladenKeuze.titel.trim();
      _geselecteerdeTitelKeuzeSleutel = bronSleutel;
      _titelBevestigd = true;
      _zetAllesIngeklapt(_items);
      _geopendeKeuze = null;
      _bewaardeBoomScrollOffset = 0;
      _foutmelding = null;
    });
  }

  void _voegTekeningToe(_TechnischMenuItemConcept item) {
    if (item.tekeningen.length >= 4) {
      _toonFout(
        'Per keuze kunnen maximaal vier rechthoeken worden toegevoegd.',
      );
      return;
    }

    setState(() {
      item.tekeningen.add(OpmetingRaamTechnischeTekeningConcept.nieuw());
      item.ingeklapt = false;
      _foutmelding = null;
    });
  }

  void _verwijderTekening({
    required _TechnischMenuItemConcept item,
    required int index,
  }) {
    if (index < 0 || index >= item.tekeningen.length) {
      return;
    }

    setState(() {
      final verwijderd = item.tekeningen.removeAt(index);
      verwijderd.dispose();
      _foutmelding = null;
    });
  }

  int _aantalKeuzes(List<_TechnischMenuItemConcept> items) {
    var totaal = 0;

    for (final item in items) {
      if (item.isKeuze) {
        totaal++;
      }

      totaal += _aantalKeuzes(item.kinderen);
    }

    return totaal;
  }

  String? _controleerKeuzeInhoud({
    required _TechnischMenuItemConcept item,
    required String naam,
  }) {
    if (item.hoeUitschrijvenController.text.trim().isEmpty) {
      return 'Vul bij “$naam” in hoe deze keuze moet worden uitgeschreven.';
    }

    if (item.tekeningen.length > 4) {
      return 'Bij “$naam” kunnen maximaal vier rechthoeken worden gebruikt.';
    }

    for (
      var tekeningIndex = 0;
      tekeningIndex < item.tekeningen.length;
      tekeningIndex++
    ) {
      final tekening = item.tekeningen[tekeningIndex];
      final nummer = tekeningIndex + 1;

      if (tekening.breedteKeuze == OpmetingRaamTechnischeMaatKeuze.vasteMaat &&
          tekening.breedteMm <= 0) {
        return 'Vul bij “$naam”, rechthoek $nummer, een geldige breedte in.';
      }

      if (tekening.hoogteKeuze == OpmetingRaamTechnischeMaatKeuze.vasteMaat &&
          tekening.hoogteMm <= 0) {
        return 'Vul bij “$naam”, rechthoek $nummer, een geldige hoogte in.';
      }

      final afstandTekst = tekening.afstandController.text.trim();

      if (afstandTekst.isNotEmpty && int.tryParse(afstandTekst) == null) {
        return 'Vul bij “$naam”, rechthoek $nummer, een geldige afstand in. Negatieve waarden zijn toegestaan.';
      }

      if (tekening.inhoudType == OpmetingRaamTechnischeInhoudType.tekst &&
          tekening.tekstController.text.trim().isEmpty) {
        return 'Vul bij “$naam”, rechthoek $nummer, de tekst voor de rechthoek in.';
      }
    }

    return null;
  }

  bool _keuzeIsVolledig(_TechnischMenuItemConcept item) {
    if (!item.isKeuze) {
      return false;
    }

    final naam = item.naamController.text.trim();

    if (naam.isEmpty || naam.toLowerCase() == 'geen') {
      return false;
    }

    return _controleerKeuzeInhoud(item: item, naam: naam) == null;
  }

  String? _controleerItem({
    required _TechnischMenuItemConcept item,
    required List<String> pad,
    required Set<String> gebruiktePaden,
  }) {
    final naam = item.naamController.text.trim();

    if (naam.isEmpty) {
      return item.isSubmenu
          ? 'Vul een naam in bij een submenu.'
          : 'Vul een naam in bij een keuze.';
    }

    if (naam.toLowerCase() == 'geen') {
      return 'De keuze “Geen” wordt automatisch toegevoegd.';
    }

    final nieuwPad = <String>[...pad, naam];

    if (item.isKeuze) {
      final padSleutel = nieuwPad.join(' > ').toLowerCase();

      if (!gebruiktePaden.add(padSleutel)) {
        return 'De keuze “${nieuwPad.join(' > ')}” werd meer dan één keer ingevoerd.';
      }
    }

    for (final kind in item.kinderen) {
      final fout = _controleerItem(
        item: kind,
        pad: nieuwPad,
        gebruiktePaden: gebruiktePaden,
      );

      if (fout != null) {
        return fout;
      }
    }

    return null;
  }

  OpmetingRaamKeuzeMenuItem _maakMenuItem(_TechnischMenuItemConcept item) {
    final naam = item.naamController.text.trim();

    if (item.isSubmenu) {
      return OpmetingRaamKeuzeMenuItem.submenu(
        id: item.id,
        naam: naam,
        kinderen: item.kinderen.map(_maakMenuItem).toList(),
        actief: true,
      );
    }

    return OpmetingRaamKeuzeMenuItem.keuze(
      optie: _maakOptieVanItem(item),
      actief: true,
    );
  }

  OpmetingRaamKeuzeOptie _maakOptieVanItem(_TechnischMenuItemConcept item) {
    final geldigeNietCombineerbareKeuzes =
        <OpmetingRaamNietCombineerbareKeuze>[];
    final gebruikteKoppelingen = <String>{};

    for (final koppeling in item.nietCombineerbaarMet) {
      if (!koppeling.isGeldig) {
        continue;
      }

      if (koppeling.optieId == item.id) {
        continue;
      }

      if (!gebruikteKoppelingen.add(koppeling.sleutel)) {
        continue;
      }

      geldigeNietCombineerbareKeuzes.add(koppeling);
    }

    return OpmetingRaamKeuzeOptie(
      id: item.id,
      naam: item.naamController.text.trim(),
      uitvoerTekst: item.hoeUitschrijvenController.text.trim(),
      isGeenKeuze: false,
      tekenfunctie: OpmetingRaamTekenfunctie.geen,
      technischeTekeningen: item.tekeningen
          .map((tekening) => tekening.naarInstelling())
          .take(4)
          .toList(),
      nietCombineerbaarMet:
          List<OpmetingRaamNietCombineerbareKeuze>.unmodifiable(
            geldigeNietCombineerbareKeuzes,
          ),
      actief: true,
    );
  }

  List<OpmetingRaamTechnischeSoortResultaat> _maakSoortenResultaat() {
    final resultaten = <OpmetingRaamTechnischeSoortResultaat>[];

    void verzamel(_TechnischMenuItemConcept item) {
      if (item.isKeuze) {
        final optie = _maakOptieVanItem(item);

        resultaten.add(
          OpmetingRaamTechnischeSoortResultaat(
            id: optie.id,
            naam: optie.naam,
            hoeUitschrijven: optie.hoeUitschrijven,
            tekeningen: optie.alleTechnischeTekeningen,
            nietCombineerbaarMet: optie.nietCombineerbaarMet,
          ),
        );
      }

      for (final kind in item.kinderen) {
        verzamel(kind);
      }
    }

    for (final item in _items) {
      verzamel(item);
    }

    return List<OpmetingRaamTechnischeSoortResultaat>.unmodifiable(resultaten);
  }

  void _bewaar() {
    final titel = _titelController.text.trim();

    if (titel.isEmpty) {
      _toonFout('Vul een titel in.');
      return;
    }

    if (_items.isEmpty || _aantalKeuzes(_items) == 0) {
      _toonFout('Voeg minstens één keuze toe.');
      return;
    }

    final gebruiktePaden = <String>{};

    for (final item in _items) {
      final fout = _controleerItem(
        item: item,
        pad: const <String>[],
        gebruiktePaden: gebruiktePaden,
      );

      if (fout != null) {
        _toonFout(fout);
        return;
      }
    }

    final items = _items.map(_maakMenuItem).toList();

    Navigator.pop(
      context,
      OpmetingRaamTechnischMenuResultaat(
        titel: titel,
        soorten: _maakSoortenResultaat(),
        items: items,
        actief: true,
      ),
    );
  }

  void _toonFout(String melding) {
    setState(() {
      _foutmelding = melding;
    });
  }

  void _bevestigNieuweTitel() {
    final titel = _titelController.text.trim();

    if (titel.isEmpty) {
      _toonFout('Vul eerst een nieuwe titel in.');
      return;
    }

    setState(() {
      _titelController.text = titel;
      _titelBevestigd = true;
      _geselecteerdeTitelKeuzeSleutel = null;
      _foutmelding = null;
    });
  }

  Future<String?> _vraagNaamVoorStructuurItem({required bool isSubmenu}) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _NaamStructuurItemDialoog(isSubmenu: isSubmenu),
    );
  }

  Future<void> _toonStructuurActies({
    required String doelNaam,
    required List<_TechnischMenuItemConcept> doelLijst,
  }) async {
    final resultaat = await showDialog<_StructuurToevoegingResultaat>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _StructuurToevoegingDialoog(doelNaam: doelNaam),
    );

    if (!mounted || resultaat == null) {
      return;
    }

    if (resultaat.isSubmenu) {
      await _voegSubmenuToe(
        doelLijst: doelLijst,
        voorafIngevuldeNaam: resultaat.naam,
      );
      return;
    }

    await _voegKeuzeToe(
      doelLijst: doelLijst,
      voorafIngevuldeNaam: resultaat.naam,
    );
  }

  @override
  Widget build(BuildContext context) {
    final schermHoogte = MediaQuery.sizeOf(context).height;
    final geopendeKeuze = _geopendeKeuze;

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 680,
          maxHeight: schermHoogte - 48,
        ),
        child: Column(
          children: [
            _bouwKop(),
            const Divider(height: 1),
            Expanded(
              child: geopendeKeuze != null
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(14),
                      child: _bouwKeuzeInvulscherm(geopendeKeuze),
                    )
                  : !_titelBevestigd
                  ? _bouwTitelStartscherm()
                  : _bouwStamboomOverzicht(),
            ),
            const Divider(height: 1),
            _bouwOnderbalk(),
          ],
        ),
      ),
    );
  }

  Widget _bouwKeuzeInvulscherm(_TechnischMenuItemConcept item) {
    final naam = item.naamController.text.trim();
    final volledig = _keuzeIsVolledig(item);
    final beschikbareNietCombineerbareKeuzes = widget
        .beschikbareNietCombineerbareKeuzes
        .where((keuze) => keuze.optieId != item.id)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
          decoration: BoxDecoration(
            color: lichtGroen,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: groen),
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: widget.alleenKeuzeInvullen
                    ? 'Annuleren'
                    : 'Terug naar de boom',
                visualDensity: VisualDensity.compact,
                onPressed: widget.alleenKeuzeInvullen
                    ? () => Navigator.pop(context)
                    : _sluitKeuzeInvulscherm,
                icon: const Icon(Icons.arrow_back, color: groen, size: 20),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Keuze invullen',
                      style: TextStyle(
                        color: groen,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      naam.isEmpty ? 'Nieuwe keuze' : naam,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF374151),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Tooltip(
                message: volledig
                    ? 'Deze keuze is volledig ingevuld'
                    : 'Deze keuze is nog niet volledig ingevuld',
                child: Icon(
                  volledig ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: volledig ? groen : const Color(0xFFF59E0B),
                  size: 22,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _bouwKeuzeInhoud(
          item: item,
          beschikbareNietCombineerbareKeuzes:
              beschikbareNietCombineerbareKeuzes,
        ),
        if (_foutmelding != null) ...[
          const SizedBox(height: 8),
          _bouwFoutmelding(),
        ],
      ],
    );
  }

  Widget _bouwFoutmelding() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Text(
        _foutmelding ?? '',
        style: const TextStyle(
          color: Color(0xFFB91C1C),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _bouwTitelStartscherm() {
    final bronOpties = _maakTitelKeuzeOpties();
    final geldigeSleutels = bronOpties.map((optie) => optie.sleutel).toSet();
    final geselecteerdeSleutel =
        geldigeSleutels.contains(_geselecteerdeTitelKeuzeSleutel)
        ? _geselecteerdeTitelKeuzeSleutel
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey<String?>(
              'bestaande-titel-${geselecteerdeSleutel ?? 'geen'}',
            ),
            initialValue: geselecteerdeSleutel,
            isExpanded: true,
            menuMaxHeight: 420,
            decoration: const InputDecoration(
              labelText: 'Bestaande titel opladen',
              hintText: 'Kies een titel uit een ander artikel',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: bronOpties.map((optie) {
              return DropdownMenuItem<String>(
                value: optie.sleutel,
                child: Text(
                  optie.keuze.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: bronOpties.isEmpty ? null : _selecteerTitelKeuze,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titelController,
            focusNode: _titelFocusNode,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => _bevestigNieuweTitel(),
            onChanged: (_) {
              if (_foutmelding != null) {
                setState(() {
                  _foutmelding = null;
                });
              }
            },
            decoration: InputDecoration(
              labelText: 'Nieuwe titel',
              hintText: 'Bijvoorbeeld: Rolluiken',
              border: const OutlineInputBorder(),
              isDense: true,
              suffixIcon: IconButton(
                tooltip: 'Titel bevestigen',
                onPressed: _bevestigNieuweTitel,
                icon: const Icon(Icons.check_circle_outline, color: groen),
              ),
            ),
          ),
          if (_foutmelding != null) ...[
            const SizedBox(height: 12),
            _bouwFoutmelding(),
          ],
        ],
      ),
    );
  }

  Widget _bouwStamboomOverzicht() {
    final titel = _titelController.text.trim();
    final aantalKeuzes = _aantalKeuzes(_items);

    return Scrollbar(
      controller: _boomScrollController,
      thumbVisibility: true,
      child: ListView(
        controller: _boomScrollController,
        padding: const EdgeInsets.all(14),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: rand),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  color: lichtGroen,
                  child: InkWell(
                    onTap: () {
                      _toonStructuurActies(doelNaam: titel, doelLijst: _items);
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.account_tree_outlined,
                            color: groen,
                            size: 21,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  titel.isEmpty ? 'Technische titel' : titel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: groen,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  aantalKeuzes == 0
                                      ? 'Tik om een keuze of submenu toe te voegen'
                                      : '$aantalKeuzes ${aantalKeuzes == 1 ? 'keuze' : 'keuzes'} · tik om verder uit te bouwen',
                                  style: const TextStyle(
                                    color: Color(0xFF4B5563),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: groen,
                            size: 21,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'De stamboom is nog leeg. Tik hierboven op de titel om een keuze of submenu toe te voegen.',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12.2,
                        height: 1.4,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
                    child: Column(
                      children: _items.map((item) {
                        return _bouwItemKaart(item: item, diepte: 0);
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
          if (_foutmelding != null) ...[
            const SizedBox(height: 12),
            _bouwFoutmelding(),
          ],
        ],
      ),
    );
  }

  Widget _bouwKop() {
    final inKeuzeInvulscherm = _geopendeKeuze != null;
    final titel = inKeuzeInvulscherm
        ? 'Technische keuze invullen'
        : !_titelBevestigd
        ? 'Nieuwe technische keuze'
        : 'Stamboom technische keuzes';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      decoration: const BoxDecoration(
        color: lichtGroen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(
            inKeuzeInvulscherm
                ? Icons.edit_note_outlined
                : Icons.account_tree_outlined,
            color: groen,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              titel,
              style: const TextStyle(
                color: groen,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Sluiten',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: groen),
          ),
        ],
      ),
    );
  }

  Widget _bouwOnderbalk() {
    final inKeuzeInvulscherm = _geopendeKeuze != null;

    if (!_titelBevestigd && !inKeuzeInvulscherm) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuleren'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          TextButton(
            onPressed: inKeuzeInvulscherm
                ? widget.alleenKeuzeInvullen
                      ? () => Navigator.pop(context)
                      : _sluitKeuzeInvulscherm
                : () => Navigator.pop(context),
            child: Text(
              inKeuzeInvulscherm && !widget.alleenKeuzeInvullen
                  ? 'Terug naar boom'
                  : 'Annuleren',
            ),
          ),
          const Spacer(),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: groen,
              foregroundColor: Colors.white,
            ),
            onPressed: inKeuzeInvulscherm
                ? widget.alleenKeuzeInvullen
                      ? _bewaar
                      : _sluitKeuzeInvulscherm
                : _bewaar,
            icon: Icon(
              inKeuzeInvulscherm ? Icons.save_outlined : Icons.check,
              size: 18,
            ),
            label: Text(inKeuzeInvulscherm ? 'Keuze bewaren' : 'Bewaren'),
          ),
        ],
      ),
    );
  }

  Widget _bouwItemKaart({
    required _TechnischMenuItemConcept item,
    required int diepte,
  }) {
    final naam = item.naamController.text.trim();
    final volledig = item.isKeuze && _keuzeIsVolledig(item);
    final statusKleur = volledig ? groen : const Color(0xFFF59E0B);
    final statusIcoon = item.isSubmenu
        ? Icons.account_tree_outlined
        : volledig
        ? Icons.check_circle
        : Icons.warning_amber_rounded;
    final subtitel = item.isSubmenu
        ? '${item.kinderen.length} onderliggende ${item.kinderen.length == 1 ? 'tak' : 'takken'} · tik om verder uit te bouwen'
        : volledig
        ? 'Volledig ingevuld'
        : 'Nog niet ingevuld';

    return Padding(
      padding: EdgeInsets.only(left: diepte * 18.0, bottom: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: item.isSubmenu ? const Color(0xFFFAFAFA) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: item.isSubmenu
                  ? () {
                      _toonStructuurActies(
                        doelNaam: naam,
                        doelLijst: item.kinderen,
                      );
                    }
                  : () => _openKeuze(item),
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 8, 9, 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: rand),
                ),
                child: Row(
                  children: [
                    Icon(
                      statusIcoon,
                      color: item.isSubmenu ? groen : statusKleur,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            naam.isEmpty
                                ? item.isSubmenu
                                      ? 'Submenu'
                                      : 'Keuze'
                                : naam,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            subtitel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 10.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: item.isSubmenu ? groen : statusKleur,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (item.isSubmenu && item.kinderen.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Column(
                children: item.kinderen.map((kind) {
                  return _bouwItemKaart(item: kind, diepte: diepte + 1);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _bouwKeuzeInhoud({
    required _TechnischMenuItemConcept item,
    required List<OpmetingRaamBeschikbareNietCombineerbareKeuze>
    beschikbareNietCombineerbareKeuzes,
  }) {
    final maximumBereikt = item.tekeningen.length >= 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: item.hoeUitschrijvenController,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) {
            setState(() {
              _foutmelding = null;
            });
          },
          decoration: const InputDecoration(
            labelText: 'Hoe uitschrijven',
            hintText: 'Korte duidelijke tekst voor overzicht en offerte',
            helperText:
                'Deze tekst wordt ook automatisch gebruikt bij een gekoppelde prijsregel.',
            helperMaxLines: 2,
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: item.naamController,
          onChanged: (_) {
            setState(() {
              _foutmelding = null;
            });
          },
          decoration: const InputDecoration(
            labelText: 'Naam keuze',
            hintText: 'Bijvoorbeeld: Minirol',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 10),
        OpmetingRaamNietCombineerbaarKeuzemenu(
          beschikbareKeuzes: beschikbareNietCombineerbareKeuzes,
          geselecteerdeKeuzes: item.nietCombineerbaarMet,
          onGewijzigd: (nieuweKeuzes) {
            setState(() {
              item.nietCombineerbaarMet =
                  List<OpmetingRaamNietCombineerbareKeuze>.from(nieuweKeuzes);
              _foutmelding = null;
            });
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Extra rechthoekige tekening',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ),
            Text(
              '${item.tekeningen.length}/4',
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
            ),
            const SizedBox(width: 6),
            IconButton.filled(
              tooltip: maximumBereikt
                  ? 'Maximum van vier rechthoeken bereikt'
                  : 'Rechthoek toevoegen',
              visualDensity: VisualDensity.compact,
              onPressed: maximumBereikt
                  ? null
                  : () {
                      _voegTekeningToe(item);
                    },
              style: IconButton.styleFrom(
                backgroundColor: groen,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFD1D5DB),
              ),
              icon: const Icon(Icons.add, size: 19),
            ),
          ],
        ),
        if (item.tekeningen.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Geen extra rechthoekige tekening. Gebruik het plusteken om er één toe te voegen.',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
            ),
          )
        else ...[
          const SizedBox(height: 8),
          ...List<Widget>.generate(item.tekeningen.length, (tekeningIndex) {
            final tekening = item.tekeningen[tekeningIndex];

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OpmetingRaamTechnischeTekeningEditor(
                key: ValueKey(tekening.id),
                volgnummer: tekeningIndex + 1,
                concept: tekening,
                onGewijzigd: () {
                  setState(() {
                    _foutmelding = null;
                  });
                },
                onVerwijderen: () {
                  _verwijderTekening(item: item, index: tekeningIndex);
                },
              ),
            );
          }),
        ],
      ],
    );
  }
}

class _TechnischeKeuzeBronOptie {
  const _TechnischeKeuzeBronOptie({required this.sleutel, required this.keuze});

  final String sleutel;
  final OpmetingRaamTechnischeOplaadbareKeuze keuze;
}

class _TechnischMenuItemLocatie {
  const _TechnischMenuItemLocatie({
    required this.lijst,
    required this.item,
    required this.index,
  });

  final List<_TechnischMenuItemConcept> lijst;
  final _TechnischMenuItemConcept item;
  final int index;
}

class _TechnischMenuItemConcept {
  _TechnischMenuItemConcept({
    required this.id,
    required this.type,
    required this.naamController,
    required this.hoeUitschrijvenController,
    required this.tekeningen,
    required this.nietCombineerbaarMet,
    required this.kinderen,
    required this.ingeklapt,
  });

  factory _TechnischMenuItemConcept.nieuweKeuze({
    String? id,
    bool ingeklapt = true,
  }) {
    return _TechnischMenuItemConcept(
      id: id ?? 'soort_${DateTime.now().microsecondsSinceEpoch}',
      type: OpmetingRaamKeuzeMenuItemType.keuze,
      naamController: TextEditingController(),
      hoeUitschrijvenController: TextEditingController(),
      tekeningen: <OpmetingRaamTechnischeTekeningConcept>[],
      nietCombineerbaarMet: <OpmetingRaamNietCombineerbareKeuze>[],
      kinderen: <_TechnischMenuItemConcept>[],
      ingeklapt: ingeklapt,
    );
  }

  factory _TechnischMenuItemConcept.nieuwSubmenu({
    String? id,
    bool ingeklapt = true,
  }) {
    return _TechnischMenuItemConcept(
      id: id ?? 'submenu_${DateTime.now().microsecondsSinceEpoch}',
      type: OpmetingRaamKeuzeMenuItemType.submenu,
      naamController: TextEditingController(),
      hoeUitschrijvenController: TextEditingController(),
      tekeningen: <OpmetingRaamTechnischeTekeningConcept>[],
      nietCombineerbaarMet: <OpmetingRaamNietCombineerbareKeuze>[],
      kinderen: <_TechnischMenuItemConcept>[],
      ingeklapt: ingeklapt,
    );
  }

  factory _TechnischMenuItemConcept.vanResultaat(
    OpmetingRaamTechnischeSoortResultaat resultaat,
  ) {
    return _TechnischMenuItemConcept(
      id: resultaat.id,
      type: OpmetingRaamKeuzeMenuItemType.keuze,
      naamController: TextEditingController(text: resultaat.naam),
      hoeUitschrijvenController: TextEditingController(
        text: resultaat.effectieveUitschrijftekst,
      ),
      tekeningen: resultaat.alleTekeningen
          .take(4)
          .map(OpmetingRaamTechnischeTekeningConcept.vanInstelling)
          .toList(),
      nietCombineerbaarMet: List<OpmetingRaamNietCombineerbareKeuze>.from(
        resultaat.nietCombineerbaarMet,
      ),
      kinderen: <_TechnischMenuItemConcept>[],
      ingeklapt: true,
    );
  }

  factory _TechnischMenuItemConcept.vanMenuItem(
    OpmetingRaamKeuzeMenuItem item,
  ) {
    if (item.isSubmenu) {
      return _TechnischMenuItemConcept(
        id: item.id,
        type: OpmetingRaamKeuzeMenuItemType.submenu,
        naamController: TextEditingController(text: item.naam),
        hoeUitschrijvenController: TextEditingController(),
        tekeningen: <OpmetingRaamTechnischeTekeningConcept>[],
        nietCombineerbaarMet: <OpmetingRaamNietCombineerbareKeuze>[],
        kinderen: item.kinderen
            .map(_TechnischMenuItemConcept.vanMenuItem)
            .toList(),
        ingeklapt: true,
      );
    }

    final optie = item.optie;

    return _TechnischMenuItemConcept(
      id: optie?.id ?? item.id,
      type: OpmetingRaamKeuzeMenuItemType.keuze,
      naamController: TextEditingController(text: optie?.naam ?? item.naam),
      hoeUitschrijvenController: TextEditingController(
        text: optie?.hoeUitschrijven ?? item.naam,
      ),
      tekeningen:
          (optie?.alleTechnischeTekeningen ??
                  const <OpmetingRaamTechnischeTekeningInstelling>[])
              .take(4)
              .map(OpmetingRaamTechnischeTekeningConcept.vanInstelling)
              .toList(),
      nietCombineerbaarMet: List<OpmetingRaamNietCombineerbareKeuze>.from(
        optie?.nietCombineerbaarMet ??
            const <OpmetingRaamNietCombineerbareKeuze>[],
      ),
      kinderen: <_TechnischMenuItemConcept>[],
      ingeklapt: true,
    );
  }

  factory _TechnischMenuItemConcept.kopieVan(
    _TechnischMenuItemConcept bron, {
    required String Function(String prefix) nieuwId,
    bool naamAlsKopie = true,
    bool behoudNietCombineerbaar = true,
    bool behoudIds = false,
  }) {
    final naam = bron.naamController.text.trim();

    if (bron.isSubmenu) {
      return _TechnischMenuItemConcept(
        id: behoudIds && bron.id.trim().isNotEmpty
            ? bron.id.trim()
            : nieuwId('submenu'),
        type: OpmetingRaamKeuzeMenuItemType.submenu,
        naamController: TextEditingController(
          text: naam.isEmpty ? '' : (naamAlsKopie ? '$naam kopie' : naam),
        ),
        hoeUitschrijvenController: TextEditingController(),
        tekeningen: <OpmetingRaamTechnischeTekeningConcept>[],
        nietCombineerbaarMet: <OpmetingRaamNietCombineerbareKeuze>[],
        kinderen: bron.kinderen
            .map(
              (kind) => _TechnischMenuItemConcept.kopieVan(
                kind,
                nieuwId: nieuwId,
                naamAlsKopie: naamAlsKopie,
                behoudNietCombineerbaar: behoudNietCombineerbaar,
                behoudIds: behoudIds,
              ),
            )
            .toList(),
        ingeklapt: false,
      );
    }

    return _TechnischMenuItemConcept(
      id: behoudIds && bron.id.trim().isNotEmpty
          ? bron.id.trim()
          : nieuwId('soort'),
      type: OpmetingRaamKeuzeMenuItemType.keuze,
      naamController: TextEditingController(
        text: naam.isEmpty ? '' : (naamAlsKopie ? '$naam kopie' : naam),
      ),
      hoeUitschrijvenController: TextEditingController(
        text: bron.hoeUitschrijvenController.text.trim(),
      ),
      tekeningen: bron.tekeningen
          .map(OpmetingRaamTechnischeTekeningConcept.kopieVan)
          .toList(),
      nietCombineerbaarMet: behoudNietCombineerbaar
          ? List<OpmetingRaamNietCombineerbareKeuze>.from(
              bron.nietCombineerbaarMet,
            )
          : <OpmetingRaamNietCombineerbareKeuze>[],
      kinderen: <_TechnischMenuItemConcept>[],
      ingeklapt: false,
    );
  }

  final String id;
  final OpmetingRaamKeuzeMenuItemType type;
  final TextEditingController naamController;
  final TextEditingController hoeUitschrijvenController;
  final List<OpmetingRaamTechnischeTekeningConcept> tekeningen;

  List<OpmetingRaamNietCombineerbareKeuze> nietCombineerbaarMet;
  final List<_TechnischMenuItemConcept> kinderen;
  bool ingeklapt;

  bool get isSubmenu {
    return type == OpmetingRaamKeuzeMenuItemType.submenu;
  }

  bool get isKeuze {
    return type == OpmetingRaamKeuzeMenuItemType.keuze;
  }

  void dispose() {
    naamController.dispose();
    hoeUitschrijvenController.dispose();

    for (final tekening in tekeningen) {
      tekening.dispose();
    }

    for (final kind in kinderen) {
      kind.dispose();
    }
  }
}

class _StructuurToevoegingResultaat {
  const _StructuurToevoegingResultaat({
    required this.isSubmenu,
    required this.naam,
  });

  final bool isSubmenu;
  final String naam;
}

class _StructuurToevoegingDialoog extends StatefulWidget {
  const _StructuurToevoegingDialoog({required this.doelNaam});

  final String doelNaam;

  @override
  State<_StructuurToevoegingDialoog> createState() {
    return _StructuurToevoegingDialoogState();
  }
}

class _StructuurToevoegingDialoogState
    extends State<_StructuurToevoegingDialoog> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);

  final TextEditingController _naamController = TextEditingController();
  bool? _isSubmenu;
  String? _foutmelding;

  @override
  void dispose() {
    _naamController.dispose();
    super.dispose();
  }

  void _kiesType(bool isSubmenu) {
    setState(() {
      _isSubmenu = isSubmenu;
      _foutmelding = null;
      _naamController.clear();
    });
  }

  void _bevestig() {
    final naam = _naamController.text.trim();

    if (naam.isEmpty) {
      setState(() {
        _foutmelding = _isSubmenu == true
            ? 'Vul een naam voor het submenu in.'
            : 'Vul een naam voor de keuze in.';
      });
      return;
    }

    Navigator.pop(
      context,
      _StructuurToevoegingResultaat(isSubmenu: _isSubmenu == true, naam: naam),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSubmenu = _isSubmenu;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
        decoration: const BoxDecoration(
          color: _lichtGroen,
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        child: Row(
          children: [
            Icon(
              isSubmenu == null
                  ? Icons.account_tree_outlined
                  : isSubmenu
                  ? Icons.account_tree_outlined
                  : Icons.radio_button_checked,
              color: _groen,
              size: 21,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isSubmenu == null
                    ? 'Toevoegen'
                    : isSubmenu
                    ? 'Naam submenu'
                    : 'Naam keuze',
                style: const TextStyle(
                  color: _groen,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: 430,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: isSubmenu == null
              ? Column(
                  key: const ValueKey<String>('type-kiezen'),
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.doelNaam.trim().isNotEmpty) ...[
                      Text(
                        widget.doelNaam.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    _StructuurTypeTegel(
                      icoon: Icons.radio_button_checked,
                      titel: 'Nieuwe keuze',
                      uitleg: 'Voeg eerst alleen de naam van de keuze toe.',
                      onTap: () => _kiesType(false),
                    ),
                    const SizedBox(height: 8),
                    _StructuurTypeTegel(
                      icoon: Icons.account_tree_outlined,
                      titel: 'Nieuw submenu',
                      uitleg: 'Maak een nieuwe tak in de stamboom.',
                      onTap: () => _kiesType(true),
                    ),
                  ],
                )
              : Column(
                  key: ValueKey<String>(
                    isSubmenu ? 'naam-submenu' : 'naam-keuze',
                  ),
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _naamController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _bevestig(),
                      onChanged: (_) {
                        if (_foutmelding != null) {
                          setState(() {
                            _foutmelding = null;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: isSubmenu ? 'Naam submenu' : 'Naam keuze',
                        hintText: isSubmenu
                            ? 'Bijvoorbeeld: Aansluitingen'
                            : 'Bijvoorbeeld: Opspuiten buitenzijde',
                        errorText: _foutmelding,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
        ),
      ),
      actions: [
        if (isSubmenu != null)
          TextButton.icon(
            onPressed: () {
              setState(() {
                _isSubmenu = null;
                _foutmelding = null;
                _naamController.clear();
              });
            },
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Terug'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuleren'),
        ),
        if (isSubmenu != null)
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _groen,
              foregroundColor: Colors.white,
            ),
            onPressed: _bevestig,
            child: const Text('Bevestigen'),
          ),
      ],
    );
  }
}

class _StructuurTypeTegel extends StatelessWidget {
  const _StructuurTypeTegel({
    required this.icoon,
    required this.titel,
    required this.uitleg,
    required this.onTap,
  });

  final IconData icoon;
  final String titel;
  final String uitleg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFAFAFA),
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Icon(icoon, color: const Color(0xFF0B7A3B), size: 21),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titel,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      uitleg,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 11.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF0B7A3B)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NaamStructuurItemDialoog extends StatefulWidget {
  const _NaamStructuurItemDialoog({required this.isSubmenu});

  final bool isSubmenu;

  @override
  State<_NaamStructuurItemDialoog> createState() {
    return _NaamStructuurItemDialoogState();
  }
}

class _NaamStructuurItemDialoogState extends State<_NaamStructuurItemDialoog> {
  static const Color _groen = Color(0xFF0B7A3B);

  final TextEditingController _controller = TextEditingController();
  String? _foutmelding;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _bevestig() {
    final naam = _controller.text.trim();

    if (naam.isEmpty) {
      setState(() {
        _foutmelding = widget.isSubmenu
            ? 'Vul een naam voor het submenu in.'
            : 'Vul een naam voor de keuze in.';
      });
      return;
    }

    Navigator.pop(context, naam);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text(
        widget.isSubmenu ? 'Naam submenu' : 'Naam keuze',
        style: const TextStyle(color: _groen, fontWeight: FontWeight.w900),
      ),
      content: SizedBox(
        width: 420,
        child: TextField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => _bevestig(),
          onChanged: (_) {
            if (_foutmelding != null) {
              setState(() {
                _foutmelding = null;
              });
            }
          },
          decoration: InputDecoration(
            labelText: widget.isSubmenu ? 'Naam submenu' : 'Naam keuze',
            hintText: widget.isSubmenu
                ? 'Bijvoorbeeld: Aansluitingen'
                : 'Bijvoorbeeld: Opspuiten buitenzijde',
            errorText: _foutmelding,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuleren'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: _groen,
            foregroundColor: Colors.white,
          ),
          onPressed: _bevestig,
          child: const Text('Bevestigen'),
        ),
      ],
    );
  }
}

Future<List<OpmetingRaamKeuzeMenu>?>
toonOpmetingRaamTechnischeMenusBeheerDialoog({
  required BuildContext context,
  required List<OpmetingRaamKeuzeMenu> bestaandeMenus,
  List<OpmetingRaamBeschikbareNietCombineerbareKeuze>
      beschikbareNietCombineerbareKeuzes =
      const <OpmetingRaamBeschikbareNietCombineerbareKeuze>[],
  List<OpmetingRaamTechnischeOplaadbareKeuze> oplaadbareKeuzes =
      const <OpmetingRaamTechnischeOplaadbareKeuze>[],
}) {
  const groen = Color(0xFF0B7A3B);

  return showDialog<List<OpmetingRaamKeuzeMenu>>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final basisTheme = Theme.of(dialogContext);

      return Theme(
        data: basisTheme.copyWith(
          colorScheme: basisTheme.colorScheme.copyWith(
            primary: groen,
            secondary: groen,
          ),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: groen,
            selectionHandleColor: groen,
          ),
          inputDecorationTheme: basisTheme.inputDecorationTheme.copyWith(
            floatingLabelStyle: const TextStyle(
              color: groen,
              fontWeight: FontWeight.w700,
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: groen, width: 2),
            ),
          ),
        ),
        child: OpmetingRaamTechnischeMenusBeheerDialoog(
          bestaandeMenus: bestaandeMenus,
          beschikbareNietCombineerbareKeuzes:
              beschikbareNietCombineerbareKeuzes,
          oplaadbareKeuzes: oplaadbareKeuzes,
        ),
      );
    },
  );
}

enum _BeheerStructuurActie { nieuweKeuze, nieuwSubmenu, naamWijzigen, kopieren }

enum _VolgordeVerplaatsActie { omhoog, omlaag }

class _BoomBestemming {
  const _BoomBestemming({
    required this.menuId,
    required this.label,
    this.ouderSubmenuId,
  });

  final String menuId;
  final String? ouderSubmenuId;
  final String label;
}

class _BeheerStructuurActieDialoog extends StatelessWidget {
  const _BeheerStructuurActieDialoog({
    required this.doelNaam,
    required this.isTitel,
  });

  final String doelNaam;
  final bool isTitel;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);

  @override
  Widget build(BuildContext context) {
    final netteNaam = doelNaam.trim();

    Widget actieTegel({
      required IconData icoon,
      required String titel,
      required String uitleg,
      required _BeheerStructuurActie actie,
    }) {
      return ListTile(
        leading: Icon(icoon, color: _groen),
        title: Text(titel, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(uitleg),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: () => Navigator.pop(context, actie),
      );
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
        decoration: const BoxDecoration(
          color: _lichtGroen,
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        child: Row(
          children: [
            const Icon(Icons.account_tree_outlined, color: _groen),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                isTitel ? 'Titel beheren' : 'Submenu beheren',
                style: const TextStyle(
                  color: _groen,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: 470,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (netteNaam.isNotEmpty) ...[
                Text(
                  netteNaam,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              actieTegel(
                icoon: Icons.radio_button_checked,
                titel: 'Nieuwe keuze',
                uitleg: 'Voeg een nieuwe technische keuze op deze plaats toe.',
                actie: _BeheerStructuurActie.nieuweKeuze,
              ),
              actieTegel(
                icoon: Icons.account_tree_outlined,
                titel: 'Nieuw submenu',
                uitleg: 'Maak een nieuwe onderliggende tak in de stamboom.',
                actie: _BeheerStructuurActie.nieuwSubmenu,
              ),
              const Divider(height: 18),
              actieTegel(
                icoon: Icons.edit_outlined,
                titel: 'Naam wijzigen',
                uitleg: isTitel
                    ? 'Wijzig alleen de naam van deze titel; alle ID’s en inhoud blijven behouden.'
                    : 'Wijzig alleen de naam van dit submenu; alle onderliggende inhoud blijft behouden.',
                actie: _BeheerStructuurActie.naamWijzigen,
              ),
              actieTegel(
                icoon: Icons.content_copy_rounded,
                titel: 'Kopiëren',
                uitleg: isTitel
                    ? 'Kopieer de volledige titel met alle submenu’s en keuzes naar een gekozen positie.'
                    : 'Kopieer dit submenu met alle onderliggende submenu’s en keuzes naar een gekozen plaats.',
                actie: _BeheerStructuurActie.kopieren,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuleren'),
        ),
      ],
    );
  }
}

class _NaamWijzigenDialoog extends StatefulWidget {
  const _NaamWijzigenDialoog({
    required this.titel,
    required this.label,
    required this.beginWaarde,
  });

  final String titel;
  final String label;
  final String beginWaarde;

  @override
  State<_NaamWijzigenDialoog> createState() {
    return _NaamWijzigenDialoogState();
  }
}

class _NaamWijzigenDialoogState extends State<_NaamWijzigenDialoog> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);

  late final TextEditingController _controller;
  String? _foutmelding;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.beginWaarde);
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _bewaar() {
    final waarde = _controller.text.trim();

    if (waarde.isEmpty) {
      setState(() {
        _foutmelding = 'Vul een naam in.';
      });
      return;
    }

    Navigator.pop(context, waarde);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
        decoration: const BoxDecoration(
          color: _lichtGroen,
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        child: Row(
          children: [
            const Icon(Icons.edit_outlined, color: _groen),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                widget.titel,
                style: const TextStyle(
                  color: _groen,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: 430,
        child: TextField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => _bewaar(),
          onChanged: (_) {
            if (_foutmelding != null) {
              setState(() {
                _foutmelding = null;
              });
            }
          },
          decoration: InputDecoration(
            labelText: widget.label,
            errorText: _foutmelding,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuleren'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: _groen),
          onPressed: _bewaar,
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Bewaren'),
        ),
      ],
    );
  }
}

class OpmetingRaamTechnischeMenusBeheerDialoog extends StatefulWidget {
  const OpmetingRaamTechnischeMenusBeheerDialoog({
    super.key,
    required this.bestaandeMenus,
    this.beschikbareNietCombineerbareKeuzes =
        const <OpmetingRaamBeschikbareNietCombineerbareKeuze>[],
    this.oplaadbareKeuzes = const <OpmetingRaamTechnischeOplaadbareKeuze>[],
  });

  final List<OpmetingRaamKeuzeMenu> bestaandeMenus;
  final List<OpmetingRaamBeschikbareNietCombineerbareKeuze>
  beschikbareNietCombineerbareKeuzes;
  final List<OpmetingRaamTechnischeOplaadbareKeuze> oplaadbareKeuzes;

  @override
  State<OpmetingRaamTechnischeMenusBeheerDialoog> createState() {
    return _OpmetingRaamTechnischeMenusBeheerDialoogState();
  }
}

class _OpmetingRaamTechnischeMenusBeheerDialoogState
    extends State<OpmetingRaamTechnischeMenusBeheerDialoog> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstGrijs = Color(0xFF6B7280);
  static const Color _oranje = Color(0xFFF59E0B);

  static int _idTeller = 0;

  final TextEditingController _nieuweTitelController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late List<OpmetingRaamKeuzeMenu> _menus;
  final Set<String> _openMenuIds = <String>{};
  final Set<String> _openSubmenuSleutels = <String>{};
  String? _foutmelding;
  int _dropdownVersie = 0;

  @override
  void initState() {
    super.initState();
    _menus = List<OpmetingRaamKeuzeMenu>.from(widget.bestaandeMenus)
      ..sort((eerste, tweede) => eerste.volgorde.compareTo(tweede.volgorde));
    _menus = _normaliseerVolgorde(_menus);
  }

  @override
  void dispose() {
    _nieuweTitelController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _nieuwId(String prefix) {
    _idTeller++;
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}_$_idTeller';
  }

  String _titelSleutel(String titel) {
    return titel.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  List<OpmetingRaamTechnischeOplaadbareKeuze> _beschikbareTitels() {
    final bestaandeTitels = _menus.map((menu) {
      return _titelSleutel(menu.titel);
    }).toSet();
    final gebruikteBronnen = <String>{};
    final resultaat = <OpmetingRaamTechnischeOplaadbareKeuze>[];

    final bronnen =
        List<OpmetingRaamTechnischeOplaadbareKeuze>.from(
          widget.oplaadbareKeuzes,
        )..sort((eerste, tweede) {
          final titelVergelijking = eerste.titel.trim().toLowerCase().compareTo(
            tweede.titel.trim().toLowerCase(),
          );

          if (titelVergelijking != 0) {
            return titelVergelijking;
          }

          return eerste.formulierNaam.trim().toLowerCase().compareTo(
            tweede.formulierNaam.trim().toLowerCase(),
          );
        });

    for (final bron in bronnen) {
      final titel = bron.titel.trim();
      final titelSleutel = _titelSleutel(titel);

      if (titelSleutel.isEmpty || bestaandeTitels.contains(titelSleutel)) {
        continue;
      }

      final bronSleutel = <String>[
        titelSleutel,
        bron.formulierNaam.trim().toLowerCase(),
        bron.id.trim(),
      ].join('|');

      if (!gebruikteBronnen.add(bronSleutel)) {
        continue;
      }

      resultaat.add(bron);
    }

    return resultaat;
  }

  void _voegNieuweTitelToe() {
    final titel = _nieuweTitelController.text.trim();

    if (titel.isEmpty) {
      setState(() {
        _foutmelding = 'Vul eerst een nieuwe titel in.';
      });
      return;
    }

    final bestaatAl = _menus.any((menu) {
      return _titelSleutel(menu.titel) == _titelSleutel(titel);
    });

    if (bestaatAl) {
      setState(() {
        _foutmelding = 'Deze titel bestaat al bij dit artikel.';
      });
      return;
    }

    final menuId = _nieuwId('menu');
    final nieuwMenu = OpmetingRaamKeuzeMenu.nieuw(
      id: menuId,
      titel: titel,
      volgorde: _menus.length,
    );

    setState(() {
      _menus = <OpmetingRaamKeuzeMenu>[..._menus, nieuwMenu];
      _openMenuIds.add(menuId);
      _nieuweTitelController.clear();
      _foutmelding = null;
      _dropdownVersie++;
    });

    _scrollNaarOnder();
  }

  void _laadTitel(OpmetingRaamTechnischeOplaadbareKeuze? bron) {
    if (bron == null) {
      return;
    }

    final titel = bron.titel.trim();

    if (titel.isEmpty) {
      return;
    }

    final menuId = _nieuwId('menu');
    final basisMenu = OpmetingRaamKeuzeMenu.nieuw(
      id: menuId,
      titel: titel,
      volgorde: _menus.length,
    );
    final bronItems = bron.items.where((item) {
      return !(item.isKeuze && item.optie?.isGeenKeuze == true);
    }).toList();
    final opgeladenMenu = _menuMetItems(basisMenu, bronItems);

    setState(() {
      _menus = <OpmetingRaamKeuzeMenu>[..._menus, opgeladenMenu];
      _openMenuIds.add(menuId);
      _foutmelding = null;
      _dropdownVersie++;
    });

    _scrollNaarOnder();
  }

  void _scrollNaarOnder() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  List<OpmetingRaamKeuzeMenu> _normaliseerVolgorde(
    List<OpmetingRaamKeuzeMenu> menus,
  ) {
    return List<OpmetingRaamKeuzeMenu>.generate(
      menus.length,
      (index) => menus[index].copyWith(volgorde: index),
    );
  }

  List<OpmetingRaamKeuzeMenuItem> _bewerkbareItems(OpmetingRaamKeuzeMenu menu) {
    if (menu.items.isNotEmpty) {
      return List<OpmetingRaamKeuzeMenuItem>.from(menu.items);
    }

    return menu.boomItems.where((item) {
      return !(item.isKeuze && item.optie?.isGeenKeuze == true);
    }).toList();
  }

  OpmetingRaamKeuzeMenu _menuMetItems(
    OpmetingRaamKeuzeMenu menu,
    List<OpmetingRaamKeuzeMenuItem> items,
  ) {
    final opties = <OpmetingRaamKeuzeOptie>[menu.geenOptie];
    final gebruikteIds = <String>{menu.geenOptie.id};

    void verzamel(OpmetingRaamKeuzeMenuItem item) {
      if (item.isKeuze && item.optie != null) {
        final optie = item.optie!;

        if (!optie.isGeenKeuze && gebruikteIds.add(optie.id)) {
          opties.add(optie);
        }
      }

      for (final kind in item.kinderen) {
        verzamel(kind);
      }
    }

    for (final item in items) {
      verzamel(item);
    }

    return menu.copyWith(
      items: List<OpmetingRaamKeuzeMenuItem>.unmodifiable(items),
      opties: List<OpmetingRaamKeuzeOptie>.unmodifiable(opties),
    );
  }

  void _vervangMenu(OpmetingRaamKeuzeMenu bijgewerktMenu) {
    setState(() {
      _menus = _menus.map((menu) {
        return menu.id == bijgewerktMenu.id ? bijgewerktMenu : menu;
      }).toList();
      _foutmelding = null;
    });
  }

  OpmetingRaamKeuzeMenuItem? _zoekBoomItem({
    required List<OpmetingRaamKeuzeMenuItem> items,
    required String itemId,
  }) {
    for (final item in items) {
      if (item.id == itemId) {
        return item;
      }

      if (item.isSubmenu) {
        final gevonden = _zoekBoomItem(items: item.kinderen, itemId: itemId);

        if (gevonden != null) {
          return gevonden;
        }
      }
    }

    return null;
  }

  List<String>? _vindBoomItemPad({
    required List<OpmetingRaamKeuzeMenuItem> items,
    required String itemId,
  }) {
    for (final item in items) {
      if (item.id == itemId) {
        return <String>[item.id];
      }

      if (!item.isSubmenu) {
        continue;
      }

      final onderliggendPad = _vindBoomItemPad(
        items: item.kinderen,
        itemId: itemId,
      );

      if (onderliggendPad != null) {
        return <String>[item.id, ...onderliggendPad];
      }
    }

    return null;
  }

  List<OpmetingRaamKeuzeMenuItem> _kinderenVanOuder({
    required List<OpmetingRaamKeuzeMenuItem> items,
    String? ouderSubmenuId,
  }) {
    if (ouderSubmenuId == null || ouderSubmenuId.trim().isEmpty) {
      return items;
    }

    final ouder = _zoekBoomItem(items: items, itemId: ouderSubmenuId);

    if (ouder == null || !ouder.isSubmenu) {
      return const <OpmetingRaamKeuzeMenuItem>[];
    }

    return ouder.kinderen;
  }

  List<OpmetingRaamKeuzeMenuItem> _voegItemToeAanOuder({
    required List<OpmetingRaamKeuzeMenuItem> items,
    required OpmetingRaamKeuzeMenuItem nieuwItem,
    String? ouderSubmenuId,
    int? invoegIndex,
  }) {
    if (ouderSubmenuId == null || ouderSubmenuId.trim().isEmpty) {
      final resultaat = List<OpmetingRaamKeuzeMenuItem>.from(items);
      final doelIndex = (invoegIndex ?? resultaat.length)
          .clamp(0, resultaat.length)
          .toInt();
      resultaat.insert(doelIndex, nieuwItem);
      return resultaat;
    }

    var toegevoegd = false;

    List<OpmetingRaamKeuzeMenuItem> verwerk(
      List<OpmetingRaamKeuzeMenuItem> lijst,
    ) {
      return lijst.map((item) {
        if (item.isSubmenu && item.id == ouderSubmenuId) {
          final nieuweKinderen = List<OpmetingRaamKeuzeMenuItem>.from(
            item.kinderen,
          );
          final doelIndex = (invoegIndex ?? nieuweKinderen.length)
              .clamp(0, nieuweKinderen.length)
              .toInt();
          nieuweKinderen.insert(doelIndex, nieuwItem);
          toegevoegd = true;
          return item.copyWith(kinderen: nieuweKinderen);
        }

        if (!item.isSubmenu || item.kinderen.isEmpty) {
          return item;
        }

        return item.copyWith(kinderen: verwerk(item.kinderen));
      }).toList();
    }

    final resultaat = verwerk(items);
    return toegevoegd ? resultaat : items;
  }

  List<OpmetingRaamKeuzeMenuItem> _hernoemBoomItem({
    required List<OpmetingRaamKeuzeMenuItem> items,
    required String itemId,
    required String nieuweNaam,
  }) {
    return items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(naam: nieuweNaam);
      }

      if (!item.isSubmenu || item.kinderen.isEmpty) {
        return item;
      }

      return item.copyWith(
        kinderen: _hernoemBoomItem(
          items: item.kinderen,
          itemId: itemId,
          nieuweNaam: nieuweNaam,
        ),
      );
    }).toList();
  }

  Set<String> _verzamelSubmenuIds(OpmetingRaamKeuzeMenuItem item) {
    final resultaat = <String>{};

    void verzamel(OpmetingRaamKeuzeMenuItem huidig) {
      if (huidig.isSubmenu) {
        resultaat.add(huidig.id);
      }

      for (final kind in huidig.kinderen) {
        verzamel(kind);
      }
    }

    verzamel(item);
    return resultaat;
  }

  void _verzamelNieuweBoomIds({
    required OpmetingRaamKeuzeMenuItem item,
    required Map<String, String> idKoppeling,
  }) {
    final nieuwId = _nieuwId(item.isSubmenu ? 'submenu' : 'soort');
    idKoppeling[item.id] = nieuwId;

    final optieId = item.optie?.id.trim() ?? '';
    if (optieId.isNotEmpty) {
      idKoppeling[optieId] = nieuwId;
    }

    for (final kind in item.kinderen) {
      _verzamelNieuweBoomIds(item: kind, idKoppeling: idKoppeling);
    }
  }

  OpmetingRaamKeuzeMenuItem _kopieerBoomItemMetNieuweIds({
    required OpmetingRaamKeuzeMenuItem item,
    required Map<String, String> idKoppeling,
    required String doelMenuId,
    bool voegKopieToeAanNaam = false,
  }) {
    final nieuwId =
        idKoppeling[item.id] ?? _nieuwId(item.isSubmenu ? 'submenu' : 'soort');
    final basisNaam = item.weergaveNaam.trim();
    final nieuweNaam = voegKopieToeAanNaam && basisNaam.isNotEmpty
        ? '$basisNaam kopie'
        : basisNaam;

    if (item.isSubmenu) {
      return OpmetingRaamKeuzeMenuItem.submenu(
        id: nieuwId,
        naam: nieuweNaam,
        actief: item.actief,
        kinderen: item.kinderen.map((kind) {
          return _kopieerBoomItemMetNieuweIds(
            item: kind,
            idKoppeling: idKoppeling,
            doelMenuId: doelMenuId,
          );
        }).toList(),
      );
    }

    final optie = item.optie;

    if (optie == null) {
      return OpmetingRaamKeuzeMenuItem.keuze(
        optie: OpmetingRaamKeuzeOptie(
          id: nieuwId,
          naam: nieuweNaam,
          uitvoerTekst: '',
          isGeenKeuze: false,
          tekenfunctie: OpmetingRaamTekenfunctie.geen,
        ),
        actief: item.actief,
      );
    }

    final nieuweNietCombineerbaarMet = optie.nietCombineerbaarMet.map((ref) {
      final nieuwOptieId = idKoppeling[ref.optieId];

      if (nieuwOptieId == null) {
        return ref;
      }

      return OpmetingRaamNietCombineerbareKeuze(
        menuId: doelMenuId,
        optieId: nieuwOptieId,
      );
    }).toList();

    final nieuweOptie = optie.copyWith(
      id: nieuwId,
      naam: nieuweNaam,
      nietCombineerbaarMet: nieuweNietCombineerbaarMet,
    );

    return OpmetingRaamKeuzeMenuItem.keuze(
      optie: nieuweOptie,
      actief: item.actief,
    );
  }

  void _openPadNaarSubmenu({
    required OpmetingRaamKeuzeMenu menu,
    String? submenuId,
  }) {
    _openMenuIds.add(menu.id);

    if (submenuId == null || submenuId.trim().isEmpty) {
      return;
    }

    final pad = _vindBoomItemPad(
      items: _bewerkbareItems(menu),
      itemId: submenuId,
    );

    if (pad == null) {
      return;
    }

    for (final id in pad) {
      _openSubmenuSleutels.add(_submenuSleutel(menu.id, id));
    }
  }

  Future<String?> _vraagGewijzigdeNaam({
    required String titel,
    required String label,
    required String beginWaarde,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _NaamWijzigenDialoog(
        titel: titel,
        label: label,
        beginWaarde: beginWaarde,
      ),
    );
  }

  Future<void> _wijzigTitelNaam(OpmetingRaamKeuzeMenu menu) async {
    final nieuweNaam = await _vraagGewijzigdeNaam(
      titel: 'Naam titel wijzigen',
      label: 'Naam titel',
      beginWaarde: menu.titel,
    );

    if (!mounted || nieuweNaam == null) {
      return;
    }

    final bestaatAl = _menus.any((huidigMenu) {
      return huidigMenu.id != menu.id &&
          _titelSleutel(huidigMenu.titel) == _titelSleutel(nieuweNaam);
    });

    if (bestaatAl) {
      setState(() {
        _foutmelding = 'Er bestaat al een technische titel met deze naam.';
      });
      return;
    }

    setState(() {
      _menus = _menus.map((huidigMenu) {
        return huidigMenu.id == menu.id
            ? huidigMenu.copyWith(titel: nieuweNaam)
            : huidigMenu;
      }).toList();
      _dropdownVersie++;
      _foutmelding = null;
    });
  }

  Future<void> _wijzigSubmenuNaam({
    required OpmetingRaamKeuzeMenu menu,
    required OpmetingRaamKeuzeMenuItem submenu,
  }) async {
    final nieuweNaam = await _vraagGewijzigdeNaam(
      titel: 'Naam submenu wijzigen',
      label: 'Naam submenu',
      beginWaarde: submenu.weergaveNaam,
    );

    if (!mounted || nieuweNaam == null) {
      return;
    }

    final items = _bewerkbareItems(menu);
    final pad = _vindBoomItemPad(items: items, itemId: submenu.id);
    final ouderSubmenuId = pad != null && pad.length > 1
        ? pad[pad.length - 2]
        : null;
    final broersEnZussen = _kinderenVanOuder(
      items: items,
      ouderSubmenuId: ouderSubmenuId,
    );
    final bestaatAl = broersEnZussen.any((item) {
      return item.id != submenu.id &&
          item.weergaveNaam.trim().toLowerCase() ==
              nieuweNaam.trim().toLowerCase();
    });

    if (bestaatAl) {
      setState(() {
        _foutmelding = 'Op dit niveau bestaat al een item met deze naam.';
      });
      return;
    }

    final bijgewerktMenu = _menuMetItems(
      menu,
      _hernoemBoomItem(
        items: items,
        itemId: submenu.id,
        nieuweNaam: nieuweNaam,
      ),
    );

    setState(() {
      _menus = _menus.map((huidigMenu) {
        return huidigMenu.id == bijgewerktMenu.id ? bijgewerktMenu : huidigMenu;
      }).toList();
      _openPadNaarSubmenu(menu: bijgewerktMenu, submenuId: submenu.id);
      _foutmelding = null;
    });
  }

  Future<int?> _kiesTitelKopiePositie(OpmetingRaamKeuzeMenu bronMenu) {
    return showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Text('Plaats van gekopieerde titel'),
          content: SizedBox(
            width: 460,
            height: 360,
            child: ListView.builder(
              itemCount: _menus.length + 1,
              itemBuilder: (_, index) {
                final label = index == 0
                    ? 'Bovenaan'
                    : 'Na “${_menus[index - 1].titel}”';

                return ListTile(
                  leading: const Icon(
                    Icons.vertical_align_center_rounded,
                    color: _groen,
                  ),
                  title: Text(label),
                  selected: index == _menus.indexOf(bronMenu) + 1,
                  onTap: () => Navigator.pop(dialogContext, index),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuleren'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _kopieerVolledigeTitel(OpmetingRaamKeuzeMenu bronMenu) async {
    final invoegIndex = await _kiesTitelKopiePositie(bronMenu);

    if (!mounted || invoegIndex == null) {
      return;
    }

    final nieuwMenuId = _nieuwId('menu');
    final idKoppeling = <String, String>{};
    final bronItems = _bewerkbareItems(bronMenu);

    for (final item in bronItems) {
      _verzamelNieuweBoomIds(item: item, idKoppeling: idKoppeling);
    }

    final gekopieerdeItems = bronItems.map((item) {
      return _kopieerBoomItemMetNieuweIds(
        item: item,
        idKoppeling: idKoppeling,
        doelMenuId: nieuwMenuId,
      );
    }).toList();
    final basisMenu = OpmetingRaamKeuzeMenu.nieuw(
      id: nieuwMenuId,
      titel: '${bronMenu.titel.trim()} kopie',
      volgorde: invoegIndex,
    ).copyWith(actief: bronMenu.actief);
    final gekopieerdMenu = _menuMetItems(basisMenu, gekopieerdeItems);

    setState(() {
      final nieuweMenus = List<OpmetingRaamKeuzeMenu>.from(_menus);
      nieuweMenus.insert(
        invoegIndex.clamp(0, nieuweMenus.length).toInt(),
        gekopieerdMenu,
      );
      _menus = _normaliseerVolgorde(nieuweMenus);
      _openMenuIds.add(nieuwMenuId);
      _dropdownVersie++;
      _foutmelding = null;
    });
  }

  List<_BoomBestemming> _maakKopieBestemmingen({
    required OpmetingRaamKeuzeMenu bronMenu,
    required OpmetingRaamKeuzeMenuItem bronSubmenu,
  }) {
    final uitgeslotenSubmenuIds = _verzamelSubmenuIds(bronSubmenu);
    final resultaat = <_BoomBestemming>[];

    void verzamelSubmenus({
      required OpmetingRaamKeuzeMenu menu,
      required List<OpmetingRaamKeuzeMenuItem> items,
      required List<String> padNamen,
    }) {
      for (final item in items) {
        if (!item.isSubmenu) {
          continue;
        }

        final isUitgesloten =
            menu.id == bronMenu.id && uitgeslotenSubmenuIds.contains(item.id);
        final nieuwPad = <String>[...padNamen, item.weergaveNaam.trim()];

        if (!isUitgesloten) {
          resultaat.add(
            _BoomBestemming(
              menuId: menu.id,
              ouderSubmenuId: item.id,
              label: '${menu.titel} > ${nieuwPad.join(' > ')}',
            ),
          );
        }

        verzamelSubmenus(menu: menu, items: item.kinderen, padNamen: nieuwPad);
      }
    }

    for (final menu in _menus) {
      resultaat.add(
        _BoomBestemming(
          menuId: menu.id,
          label: '${menu.titel} · rechtstreeks onder titel',
        ),
      );
      verzamelSubmenus(
        menu: menu,
        items: _bewerkbareItems(menu),
        padNamen: const <String>[],
      );
    }

    return resultaat;
  }

  Future<_BoomBestemming?> _kiesBoomBestemming({
    required String titel,
    required List<_BoomBestemming> bestemmingen,
  }) {
    return showDialog<_BoomBestemming>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(titel),
          content: SizedBox(
            width: 520,
            height: 420,
            child: ListView.separated(
              itemCount: bestemmingen.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, index) {
                final bestemming = bestemmingen[index];
                return ListTile(
                  leading: Icon(
                    bestemming.ouderSubmenuId == null
                        ? Icons.account_tree_outlined
                        : Icons.subdirectory_arrow_right_rounded,
                    color: _groen,
                  ),
                  title: Text(bestemming.label),
                  onTap: () => Navigator.pop(dialogContext, bestemming),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuleren'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _kopieerVolledigSubmenu({
    required OpmetingRaamKeuzeMenu bronMenu,
    required OpmetingRaamKeuzeMenuItem bronSubmenu,
  }) async {
    final bestemmingen = _maakKopieBestemmingen(
      bronMenu: bronMenu,
      bronSubmenu: bronSubmenu,
    );
    final bestemming = await _kiesBoomBestemming(
      titel: 'Waar moet het submenu worden gekopieerd?',
      bestemmingen: bestemmingen,
    );

    if (!mounted || bestemming == null) {
      return;
    }

    final doelMenuIndex = _menus.indexWhere(
      (menu) => menu.id == bestemming.menuId,
    );

    if (doelMenuIndex < 0) {
      setState(() {
        _foutmelding = 'De gekozen bestemming bestaat niet meer.';
      });
      return;
    }

    final doelMenu = _menus[doelMenuIndex];
    final idKoppeling = <String, String>{};
    _verzamelNieuweBoomIds(item: bronSubmenu, idKoppeling: idKoppeling);
    final kopie = _kopieerBoomItemMetNieuweIds(
      item: bronSubmenu,
      idKoppeling: idKoppeling,
      doelMenuId: doelMenu.id,
      voegKopieToeAanNaam: true,
    );
    final nieuweItems = _voegItemToeAanOuder(
      items: _bewerkbareItems(doelMenu),
      ouderSubmenuId: bestemming.ouderSubmenuId,
      nieuwItem: kopie,
    );
    final bijgewerktMenu = _menuMetItems(doelMenu, nieuweItems);

    setState(() {
      _menus = _menus.map((menu) {
        return menu.id == bijgewerktMenu.id ? bijgewerktMenu : menu;
      }).toList();
      _openPadNaarSubmenu(
        menu: bijgewerktMenu,
        submenuId: bestemming.ouderSubmenuId,
      );
      _foutmelding = null;
    });
  }

  bool _kanBinnenZelfdeNiveauVerplaatsen({
    required OpmetingRaamKeuzeMenu menu,
    required OpmetingRaamKeuzeMenuItem item,
    required int richting,
  }) {
    final items = _bewerkbareItems(menu);
    final pad = _vindBoomItemPad(items: items, itemId: item.id);

    if (pad == null) {
      return false;
    }

    final ouderSubmenuId = pad.length > 1 ? pad[pad.length - 2] : null;
    final broersEnZussen = _kinderenVanOuder(
      items: items,
      ouderSubmenuId: ouderSubmenuId,
    );
    final huidigeIndex = broersEnZussen.indexWhere(
      (kandidaat) => kandidaat.id == item.id,
    );

    if (huidigeIndex < 0) {
      return false;
    }

    final nieuweIndex = huidigeIndex + richting;
    return nieuweIndex >= 0 && nieuweIndex < broersEnZussen.length;
  }

  void _verplaatsBinnenZelfdeNiveau({
    required OpmetingRaamKeuzeMenu menu,
    required OpmetingRaamKeuzeMenuItem item,
    required int richting,
  }) {
    final items = _bewerkbareItems(menu);
    final pad = _vindBoomItemPad(items: items, itemId: item.id);

    if (pad == null) {
      return;
    }

    final ouderSubmenuId = pad.length > 1 ? pad[pad.length - 2] : null;
    final broersEnZussen = _kinderenVanOuder(
      items: items,
      ouderSubmenuId: ouderSubmenuId,
    );
    final huidigeIndex = broersEnZussen.indexWhere(
      (kandidaat) => kandidaat.id == item.id,
    );
    final nieuweIndex = huidigeIndex + richting;

    if (huidigeIndex < 0 ||
        nieuweIndex < 0 ||
        nieuweIndex >= broersEnZussen.length) {
      return;
    }

    final zonderItem = _verwijderItemUitBoom(items: items, itemId: item.id);
    final nieuweItems = _voegItemToeAanOuder(
      items: zonderItem,
      ouderSubmenuId: ouderSubmenuId,
      nieuwItem: item,
      invoegIndex: nieuweIndex,
    );
    final bijgewerktMenu = _menuMetItems(menu, nieuweItems);

    setState(() {
      _menus = _menus.map((huidigMenu) {
        return huidigMenu.id == bijgewerktMenu.id ? bijgewerktMenu : huidigMenu;
      }).toList();
      _openPadNaarSubmenu(menu: bijgewerktMenu, submenuId: ouderSubmenuId);
      _foutmelding = null;
    });
  }

  String _submenuSleutel(String menuId, String submenuId) {
    return '$menuId/$submenuId';
  }

  void _wisselMenuOpen(String menuId) {
    setState(() {
      if (_openMenuIds.remove(menuId)) {
        _openSubmenuSleutels.removeWhere(
          (sleutel) => sleutel.startsWith('$menuId/'),
        );
      } else {
        _openMenuIds.add(menuId);
      }
    });
  }

  void _wisselSubmenuOpen(String sleutel) {
    setState(() {
      if (!_openSubmenuSleutels.remove(sleutel)) {
        _openSubmenuSleutels.add(sleutel);
      }
    });
  }

  Future<bool> _bevestigWissen({
    required String titel,
    required String melding,
  }) async {
    const rood = Color(0xFFDC2626);

    final bevestigen = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
            decoration: const BoxDecoration(
              color: _lichtGroen,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                const Icon(Icons.delete_outline_rounded, color: rood, size: 21),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    titel,
                    style: const TextStyle(
                      color: _groen,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: Text(melding),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuleren'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: rood,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('Verwijderen'),
            ),
          ],
        );
      },
    );

    return bevestigen == true;
  }

  Future<void> _verwijderTitel(OpmetingRaamKeuzeMenu menu) async {
    final bevestigen = await _bevestigWissen(
      titel: 'Titel verwijderen?',
      melding:
          'De titel “${menu.titel}” en alle onderliggende submenu’s en keuzes worden verwijderd. Weet je dit zeker?',
    );

    if (!mounted || !bevestigen) {
      return;
    }

    setState(() {
      _menus = _normaliseerVolgorde(
        _menus.where((huidigMenu) => huidigMenu.id != menu.id).toList(),
      );
      _openMenuIds.remove(menu.id);
      _openSubmenuSleutels.removeWhere(
        (sleutel) => sleutel.startsWith('${menu.id}/'),
      );
      _dropdownVersie++;
      _foutmelding = null;
    });
  }

  List<OpmetingRaamKeuzeMenuItem> _verwijderItemUitBoom({
    required List<OpmetingRaamKeuzeMenuItem> items,
    required String itemId,
  }) {
    final resultaat = <OpmetingRaamKeuzeMenuItem>[];

    for (final item in items) {
      if (item.id == itemId) {
        continue;
      }

      if (item.isSubmenu && item.kinderen.isNotEmpty) {
        resultaat.add(
          item.copyWith(
            kinderen: _verwijderItemUitBoom(
              items: item.kinderen,
              itemId: itemId,
            ),
          ),
        );
      } else {
        resultaat.add(item);
      }
    }

    return resultaat;
  }

  Future<void> _verwijderBoomItem({
    required OpmetingRaamKeuzeMenu menu,
    required OpmetingRaamKeuzeMenuItem item,
  }) async {
    final naam = item.weergaveNaam.trim().isEmpty
        ? item.isSubmenu
              ? 'Submenu'
              : 'Keuze'
        : item.weergaveNaam.trim();
    final isSubmenu = item.isSubmenu;
    final bevestigen = await _bevestigWissen(
      titel: isSubmenu ? 'Submenu verwijderen?' : 'Keuze verwijderen?',
      melding: isSubmenu
          ? 'Het submenu “$naam” en alles wat eronder staat wordt verwijderd. Weet je dit zeker?'
          : 'De keuze “$naam” wordt verwijderd. Weet je dit zeker?',
    );

    if (!mounted || !bevestigen) {
      return;
    }

    final nieuweItems = _verwijderItemUitBoom(
      items: _bewerkbareItems(menu),
      itemId: item.id,
    );
    final bijgewerktMenu = _menuMetItems(menu, nieuweItems);

    setState(() {
      _menus = _menus.map((huidigMenu) {
        return huidigMenu.id == bijgewerktMenu.id ? bijgewerktMenu : huidigMenu;
      }).toList();
      _openSubmenuSleutels.remove(_submenuSleutel(menu.id, item.id));
      _foutmelding = null;
    });
  }

  OpmetingRaamKeuzeMenuItem? _maakKeuzeKopie(OpmetingRaamKeuzeMenuItem bron) {
    final bronOptie = bron.optie;

    if (!bron.isKeuze || bronOptie == null || bronOptie.isGeenKeuze) {
      return null;
    }

    final nieuwId = _nieuwId('soort');
    final bronNaam = bronOptie.naam.trim();
    final nieuweNaam = bronNaam.isEmpty ? 'Keuze kopie' : '$bronNaam kopie';
    final nieuweOptie = bronOptie.copyWith(id: nieuwId, naam: nieuweNaam);

    return OpmetingRaamKeuzeMenuItem.keuze(
      optie: nieuweOptie,
      actief: bron.actief,
    );
  }

  List<OpmetingRaamKeuzeMenuItem> _voegKopieNaKeuzeToe({
    required List<OpmetingRaamKeuzeMenuItem> items,
    required String bronItemId,
    required OpmetingRaamKeuzeMenuItem kopie,
  }) {
    var toegevoegd = false;

    List<OpmetingRaamKeuzeMenuItem> verwerk(
      List<OpmetingRaamKeuzeMenuItem> lijst,
    ) {
      final resultaat = <OpmetingRaamKeuzeMenuItem>[];

      for (final item in lijst) {
        if (!toegevoegd && item.isSubmenu && item.kinderen.isNotEmpty) {
          final nieuweKinderen = verwerk(item.kinderen);
          resultaat.add(item.copyWith(kinderen: nieuweKinderen));
        } else {
          resultaat.add(item);
        }

        if (!toegevoegd && item.id == bronItemId) {
          resultaat.add(kopie);
          toegevoegd = true;
        }
      }

      return resultaat;
    }

    return verwerk(items);
  }

  void _kopieerKeuze({
    required OpmetingRaamKeuzeMenu menu,
    required OpmetingRaamKeuzeMenuItem keuze,
  }) {
    final kopie = _maakKeuzeKopie(keuze);

    if (kopie == null) {
      return;
    }

    final nieuweItems = _voegKopieNaKeuzeToe(
      items: _bewerkbareItems(menu),
      bronItemId: keuze.id,
      kopie: kopie,
    );
    final bijgewerktMenu = _menuMetItems(menu, nieuweItems);

    setState(() {
      _menus = _menus.map((huidigMenu) {
        return huidigMenu.id == bijgewerktMenu.id ? bijgewerktMenu : huidigMenu;
      }).toList();
      _openMenuIds.add(menu.id);
      _foutmelding = null;
    });
  }

  Future<void> _toonToevoegenAan({
    required OpmetingRaamKeuzeMenu menu,
    String? ouderSubmenuId,
    required String doelNaam,
  }) async {
    final isTitel = ouderSubmenuId == null;
    final actie = await showDialog<_BeheerStructuurActie>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          _BeheerStructuurActieDialoog(doelNaam: doelNaam, isTitel: isTitel),
    );

    if (!mounted || actie == null) {
      return;
    }

    if (actie == _BeheerStructuurActie.naamWijzigen) {
      if (isTitel) {
        await _wijzigTitelNaam(menu);
        return;
      }

      final submenu = _zoekBoomItem(
        items: _bewerkbareItems(menu),
        itemId: ouderSubmenuId,
      );

      if (submenu == null || !submenu.isSubmenu) {
        setState(() {
          _foutmelding = 'Het gekozen submenu bestaat niet meer.';
        });
        return;
      }

      await _wijzigSubmenuNaam(menu: menu, submenu: submenu);
      return;
    }

    if (actie == _BeheerStructuurActie.kopieren) {
      if (isTitel) {
        await _kopieerVolledigeTitel(menu);
        return;
      }

      final submenu = _zoekBoomItem(
        items: _bewerkbareItems(menu),
        itemId: ouderSubmenuId,
      );

      if (submenu == null || !submenu.isSubmenu) {
        setState(() {
          _foutmelding = 'Het gekozen submenu bestaat niet meer.';
        });
        return;
      }

      await _kopieerVolledigSubmenu(bronMenu: menu, bronSubmenu: submenu);
      return;
    }

    final isSubmenu = actie == _BeheerStructuurActie.nieuwSubmenu;
    final naam = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _NaamStructuurItemDialoog(isSubmenu: isSubmenu),
    );

    if (!mounted || naam == null) {
      return;
    }

    final nieuwItem = isSubmenu
        ? OpmetingRaamKeuzeMenuItem.submenu(id: _nieuwId('submenu'), naam: naam)
        : OpmetingRaamKeuzeMenuItem.keuze(
            optie: OpmetingRaamKeuzeOptie(
              id: _nieuwId('soort'),
              naam: naam,
              uitvoerTekst: '',
              isGeenKeuze: false,
              tekenfunctie: OpmetingRaamTekenfunctie.geen,
              technischeTekeningen:
                  const <OpmetingRaamTechnischeTekeningInstelling>[],
              nietCombineerbaarMet:
                  const <OpmetingRaamNietCombineerbareKeuze>[],
            ),
          );

    final huidigeItems = _bewerkbareItems(menu);
    final nieuweItems = ouderSubmenuId == null
        ? <OpmetingRaamKeuzeMenuItem>[...huidigeItems, nieuwItem]
        : _voegKindToe(
            items: huidigeItems,
            ouderSubmenuId: ouderSubmenuId,
            nieuwItem: nieuwItem,
          );

    final bijgewerktMenu = _menuMetItems(menu, nieuweItems);

    setState(() {
      _menus = _menus.map((huidigMenu) {
        return huidigMenu.id == bijgewerktMenu.id ? bijgewerktMenu : huidigMenu;
      }).toList();
      _openMenuIds.add(menu.id);

      if (ouderSubmenuId != null) {
        _openPadNaarSubmenu(menu: bijgewerktMenu, submenuId: ouderSubmenuId);
      }

      _foutmelding = null;
    });
  }

  List<OpmetingRaamKeuzeMenuItem> _voegKindToe({
    required List<OpmetingRaamKeuzeMenuItem> items,
    required String ouderSubmenuId,
    required OpmetingRaamKeuzeMenuItem nieuwItem,
  }) {
    var toegevoegd = false;

    List<OpmetingRaamKeuzeMenuItem> verwerk(
      List<OpmetingRaamKeuzeMenuItem> lijst,
    ) {
      return lijst.map((item) {
        if (item.isSubmenu && item.id == ouderSubmenuId) {
          toegevoegd = true;
          return item.copyWith(
            kinderen: <OpmetingRaamKeuzeMenuItem>[...item.kinderen, nieuwItem],
          );
        }

        if (!item.isSubmenu || item.kinderen.isEmpty) {
          return item;
        }

        final nieuweKinderen = verwerk(item.kinderen);

        if (identical(nieuweKinderen, item.kinderen)) {
          return item;
        }

        return item.copyWith(kinderen: nieuweKinderen);
      }).toList();
    }

    final resultaat = verwerk(items);

    if (!toegevoegd) {
      return <OpmetingRaamKeuzeMenuItem>[...items, nieuwItem];
    }

    return resultaat;
  }

  Future<void> _bewerkKeuze(
    OpmetingRaamKeuzeMenu menu,
    OpmetingRaamKeuzeMenuItem keuzeItem,
  ) async {
    final items = _bewerkbareItems(menu);
    final resultaat = await toonOpmetingRaamTechnischMenuDialoog(
      context: context,
      bestaandMenu: OpmetingRaamTechnischMenuResultaat(
        titel: menu.titel,
        soorten: _soortenVanItems(items),
        items: items,
        actief: menu.actief,
      ),
      beschikbareNietCombineerbareKeuzes:
          widget.beschikbareNietCombineerbareKeuzes,
      oplaadbareKeuzes: widget.oplaadbareKeuzes,
      beginToevoeging: OpmetingRaamTechnischMenuBeginToevoeging(
        actie: OpmetingRaamTechnischMenuBeginActie.bewerkKeuze,
        bronItemId: keuzeItem.id,
      ),
      alleenKeuzeInvullen: true,
    );

    if (!mounted || resultaat == null) {
      return;
    }

    _vervangMenu(
      _menuMetItems(
        menu.copyWith(titel: resultaat.titel, actief: resultaat.actief),
        resultaat.items,
      ),
    );
  }

  List<OpmetingRaamTechnischeSoortResultaat> _soortenVanItems(
    List<OpmetingRaamKeuzeMenuItem> items,
  ) {
    final resultaat = <OpmetingRaamTechnischeSoortResultaat>[];

    void verzamel(OpmetingRaamKeuzeMenuItem item) {
      final optie = item.optie;

      if (item.isKeuze && optie != null && !optie.isGeenKeuze) {
        resultaat.add(
          OpmetingRaamTechnischeSoortResultaat(
            id: optie.id,
            naam: optie.naam,
            hoeUitschrijven: optie.uitvoerTekst,
            tekeningen: optie.alleTechnischeTekeningen,
            nietCombineerbaarMet: optie.nietCombineerbaarMet,
          ),
        );
      }

      for (final kind in item.kinderen) {
        verzamel(kind);
      }
    }

    for (final item in items) {
      verzamel(item);
    }

    return resultaat;
  }

  bool _keuzeIsVolledig(OpmetingRaamKeuzeMenuItem item) {
    final optie = item.optie;

    if (!item.isKeuze || optie == null) {
      return false;
    }

    return optie.naam.trim().isNotEmpty &&
        optie.naam.trim().toLowerCase() != 'geen' &&
        optie.uitvoerTekst.trim().isNotEmpty;
  }

  int _aantalKeuzes(List<OpmetingRaamKeuzeMenuItem> items) {
    var totaal = 0;

    for (final item in items) {
      if (item.isKeuze && item.optie?.isGeenKeuze != true) {
        totaal++;
      }

      totaal += _aantalKeuzes(item.kinderen);
    }

    return totaal;
  }

  void _bewaar() {
    Navigator.pop(context, _normaliseerVolgorde(_menus));
  }

  @override
  Widget build(BuildContext context) {
    final schermHoogte = MediaQuery.sizeOf(context).height;
    final bronnen = _beschikbareTitels();

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 760,
          maxHeight: schermHoogte - 48,
        ),
        child: Column(
          children: [
            _bouwKop(),
            const Divider(height: 1),
            _bouwTitelInvoer(bronnen),
            const Divider(height: 1),
            Expanded(child: _bouwTitellijst()),
            const Divider(height: 1),
            _bouwOnderbalk(),
          ],
        ),
      ),
    );
  }

  Widget _bouwKop() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      decoration: const BoxDecoration(
        color: _lichtGroen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_tree_outlined, color: _groen, size: 21),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Technische titels en stambomen',
              style: TextStyle(
                color: _groen,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Sluiten',
            visualDensity: VisualDensity.compact,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: _groen),
          ),
        ],
      ),
    );
  }

  Widget _bouwTitelInvoer(List<OpmetingRaamTechnischeOplaadbareKeuze> bronnen) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<OpmetingRaamTechnischeOplaadbareKeuze>(
            key: ValueKey<int>(_dropdownVersie),
            initialValue: null,
            isExpanded: true,
            menuMaxHeight: 360,
            decoration: const InputDecoration(
              labelText: 'Bestaande titel opladen',
              hintText: 'Kies een titel uit een ander artikel',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: bronnen.map((bron) {
              return DropdownMenuItem<OpmetingRaamTechnischeOplaadbareKeuze>(
                value: bron,
                child: Text(
                  bron.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: bronnen.isEmpty ? null : _laadTitel,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nieuweTitelController,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => _voegNieuweTitelToe(),
            onChanged: (_) {
              if (_foutmelding != null) {
                setState(() {
                  _foutmelding = null;
                });
              }
            },
            decoration: InputDecoration(
              labelText: 'Nieuwe titel',
              hintText: 'Bijvoorbeeld: Rolluiken',
              border: const OutlineInputBorder(),
              isDense: true,
              suffixIcon: IconButton(
                tooltip: 'Titel toevoegen',
                onPressed: _voegNieuweTitelToe,
                icon: const Icon(Icons.check_circle_outline, color: _groen),
              ),
            ),
          ),
          if (_foutmelding != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Text(
                _foutmelding!,
                style: const TextStyle(
                  color: Color(0xFFB91C1C),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bouwTitellijst() {
    if (_menus.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Er zijn nog geen technische titels. Laad bovenaan een bestaande titel of maak een nieuwe titel.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _tekstGrijs, fontSize: 12.5, height: 1.45),
          ),
        ),
      );
    }

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
        itemCount: _menus.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          return _bouwMenuKaart(_menus[index]);
        },
      ),
    );
  }

  Widget _bouwMenuKaart(OpmetingRaamKeuzeMenu menu) {
    final items = _bewerkbareItems(menu);
    final aantalKeuzes = _aantalKeuzes(items);
    final open = _openMenuIds.contains(menu.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rand),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: _lichtGroen,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 5, 5, 5),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _wisselMenuOpen(menu.id),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(7, 7, 5, 7),
                        child: Row(
                          children: [
                            Icon(
                              open
                                  ? Icons.keyboard_arrow_down_rounded
                                  : Icons.keyboard_arrow_right_rounded,
                              color: _groen,
                              size: 23,
                            ),
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.account_tree_outlined,
                              color: _groen,
                              size: 21,
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    menu.titel.trim().isEmpty
                                        ? 'Technische titel'
                                        : menu.titel.trim(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: _groen,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    aantalKeuzes == 0
                                        ? 'Nog geen keuzes toegevoegd'
                                        : '$aantalKeuzes ${aantalKeuzes == 1 ? 'keuze' : 'keuzes'}',
                                    style: const TextStyle(
                                      color: Color(0xFF4B5563),
                                      fontSize: 11.3,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Toevoegen, naam wijzigen of kopiëren',
                    visualDensity: VisualDensity.compact,
                    onPressed: () =>
                        _toonToevoegenAan(menu: menu, doelNaam: menu.titel),
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: _groen,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Titel verwijderen',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _verwijderTitel(menu),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFDC2626),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (open && items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Deze stamboom is nog leeg. Gebruik de plusknop om een keuze of submenu toe te voegen.',
                style: TextStyle(color: _tekstGrijs, fontSize: 12),
              ),
            ),
          if (open && items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
              child: Column(
                children: items.map((item) {
                  return _bouwItem(menu: menu, item: item, diepte: 0);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _bouwItem({
    required OpmetingRaamKeuzeMenu menu,
    required OpmetingRaamKeuzeMenuItem item,
    required int diepte,
  }) {
    if (item.isKeuze && item.optie?.isGeenKeuze == true) {
      return const SizedBox.shrink();
    }

    final naam = item.weergaveNaam.trim();
    final volledig = _keuzeIsVolledig(item);
    final submenuSleutel = _submenuSleutel(menu.id, item.id);
    final open =
        item.isSubmenu && _openSubmenuSleutels.contains(submenuSleutel);
    final aantalOnderliggendeKeuzes = _aantalKeuzes(item.kinderen);

    return Padding(
      padding: EdgeInsets.only(left: diepte * 18.0, bottom: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: item.isSubmenu ? const Color(0xFFFAFAFA) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _rand),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: item.isSubmenu
                          ? () => _wisselSubmenuOpen(submenuSleutel)
                          : () => _bewerkKeuze(menu, item),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(9, 8, 5, 8),
                        child: Row(
                          children: [
                            if (item.isSubmenu)
                              Icon(
                                open
                                    ? Icons.keyboard_arrow_down_rounded
                                    : Icons.keyboard_arrow_right_rounded,
                                color: _groen,
                                size: 21,
                              ),
                            if (item.isSubmenu) const SizedBox(width: 2),
                            Icon(
                              item.isSubmenu
                                  ? Icons.account_tree_outlined
                                  : volledig
                                  ? Icons.check_circle
                                  : Icons.warning_amber_rounded,
                              color: item.isSubmenu
                                  ? _groen
                                  : volledig
                                  ? _groen
                                  : _oranje,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    naam.isEmpty
                                        ? item.isSubmenu
                                              ? 'Submenu'
                                              : 'Keuze'
                                        : naam,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF111827),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    item.isSubmenu
                                        ? aantalOnderliggendeKeuzes == 0
                                              ? 'Nog geen onderliggende keuzes'
                                              : '$aantalOnderliggendeKeuzes ${aantalOnderliggendeKeuzes == 1 ? 'keuze' : 'keuzes'} onder dit submenu'
                                        : volledig
                                        ? 'Volledig ingevuld'
                                        : 'Nog niet ingevuld · tik om in te vullen',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: _tekstGrijs,
                                      fontSize: 10.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (item.isSubmenu)
                    IconButton(
                      tooltip: 'Toevoegen, naam wijzigen of kopiëren',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _toonToevoegenAan(
                        menu: menu,
                        ouderSubmenuId: item.id,
                        doelNaam: naam,
                      ),
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: _groen,
                        size: 19,
                      ),
                    )
                  else
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: _groen,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 6,
                        ),
                        minimumSize: const Size(0, 32),
                      ),
                      onPressed: () => _kopieerKeuze(menu: menu, keuze: item),
                      icon: const Icon(Icons.content_copy_rounded, size: 15),
                      label: const Text(
                        'Kopiëren',
                        style: TextStyle(
                          fontSize: 10.8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  PopupMenuButton<_VolgordeVerplaatsActie>(
                    tooltip: 'Volgorde wijzigen binnen hetzelfde niveau',
                    enabled:
                        _kanBinnenZelfdeNiveauVerplaatsen(
                          menu: menu,
                          item: item,
                          richting: -1,
                        ) ||
                        _kanBinnenZelfdeNiveauVerplaatsen(
                          menu: menu,
                          item: item,
                          richting: 1,
                        ),
                    onSelected: (actie) {
                      switch (actie) {
                        case _VolgordeVerplaatsActie.omhoog:
                          _verplaatsBinnenZelfdeNiveau(
                            menu: menu,
                            item: item,
                            richting: -1,
                          );
                          break;
                        case _VolgordeVerplaatsActie.omlaag:
                          _verplaatsBinnenZelfdeNiveau(
                            menu: menu,
                            item: item,
                            richting: 1,
                          );
                          break;
                      }
                    },
                    itemBuilder: (_) =>
                        <PopupMenuEntry<_VolgordeVerplaatsActie>>[
                          PopupMenuItem<_VolgordeVerplaatsActie>(
                            value: _VolgordeVerplaatsActie.omhoog,
                            enabled: _kanBinnenZelfdeNiveauVerplaatsen(
                              menu: menu,
                              item: item,
                              richting: -1,
                            ),
                            child: const ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.arrow_upward_rounded),
                              title: Text('Eén plaats omhoog'),
                              subtitle: Text(
                                'Blijft onder dezelfde titel of submenu',
                              ),
                            ),
                          ),
                          PopupMenuItem<_VolgordeVerplaatsActie>(
                            value: _VolgordeVerplaatsActie.omlaag,
                            enabled: _kanBinnenZelfdeNiveauVerplaatsen(
                              menu: menu,
                              item: item,
                              richting: 1,
                            ),
                            child: const ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.arrow_downward_rounded),
                              title: Text('Eén plaats omlaag'),
                              subtitle: Text(
                                'Blijft onder dezelfde titel of submenu',
                              ),
                            ),
                          ),
                        ],
                    icon: const Icon(
                      Icons.swap_vert_rounded,
                      color: _groen,
                      size: 19,
                    ),
                  ),
                  IconButton(
                    tooltip: item.isSubmenu
                        ? 'Submenu verwijderen'
                        : 'Keuze verwijderen',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _verwijderBoomItem(menu: menu, item: item),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFDC2626),
                      size: 19,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (item.isSubmenu && open && item.kinderen.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Column(
                children: item.kinderen.map((kind) {
                  return _bouwItem(menu: menu, item: kind, diepte: diepte + 1);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _bouwOnderbalk() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuleren'),
          ),
          const Spacer(),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _groen,
              foregroundColor: Colors.white,
            ),
            onPressed: _bewaar,
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Bewaren'),
          ),
        ],
      ),
    );
  }
}
