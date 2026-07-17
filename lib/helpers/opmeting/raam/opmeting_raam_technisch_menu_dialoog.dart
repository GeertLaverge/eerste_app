import 'package:flutter/material.dart';

import 'opmeting_raam_keuzemenu_model.dart';
import 'opmeting_raam_niet_combineerbaar_keuzemenu.dart';
import 'opmeting_raam_technische_tekening_editor.dart';

class OpmetingRaamTechnischeSoortResultaat {
  const OpmetingRaamTechnischeSoortResultaat({
    required this.id,
    required this.naam,
    this.tekeningen = const <OpmetingRaamTechnischeTekeningInstelling>[],
    OpmetingRaamTechnischeTekeningInstelling? tekening,
    this.nietCombineerbaarMet = const <OpmetingRaamNietCombineerbareKeuze>[],
  }) : _oudeTekening = tekening;

  final String id;
  final String naam;

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
        <OpmetingRaamTechnischeTekeningInstelling>[_oudeTekening!],
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

  int get aantalKeuzes {
    var totaal = 0;

    void telItem(OpmetingRaamKeuzeMenuItem item) {
      if (item.isKeuze && item.optie?.isGeenKeuze != true) {
        totaal++;
      }

      for (final kind in item.kinderen) {
        telItem(kind);
      }
    }

    for (final item in items) {
      telItem(item);
    }

    return totaal;
  }

  String get bronTekst {
    final aantal = aantalKeuzes;
    final keuzeTekst = aantal == 1 ? '1 keuze' : '$aantal keuzes';

    if (formulierNaam.trim().isEmpty) {
      return keuzeTekst;
    }

    return '${formulierNaam.trim()} · $keuzeTekst';
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

Future<OpmetingRaamTechnischMenuResultaat?>
toonOpmetingRaamTechnischMenuDialoog({
  required BuildContext context,
  OpmetingRaamTechnischMenuResultaat? bestaandMenu,
  List<OpmetingRaamBeschikbareNietCombineerbareKeuze>
      beschikbareNietCombineerbareKeuzes =
      const <OpmetingRaamBeschikbareNietCombineerbareKeuze>[],
  List<OpmetingRaamTechnischeOplaadbareKeuze> oplaadbareKeuzes =
      const <OpmetingRaamTechnischeOplaadbareKeuze>[],
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
  });

  final OpmetingRaamTechnischMenuResultaat? bestaandMenu;
  final List<OpmetingRaamBeschikbareNietCombineerbareKeuze>
  beschikbareNietCombineerbareKeuzes;
  final List<OpmetingRaamTechnischeOplaadbareKeuze> oplaadbareKeuzes;

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
  static const Color achtergrond = Color(0xFFF9FAFB);

  late final TextEditingController _titelController;

  final List<_TechnischMenuItemConcept> _items = <_TechnischMenuItemConcept>[];

  String? _foutmelding;

  @override
  void initState() {
    super.initState();

    _titelController = TextEditingController(
      text: widget.bestaandMenu?.titel ?? '',
    );

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
  }

  @override
  void dispose() {
    _titelController.dispose();

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

  void _zetAllesIngeklapt(List<_TechnischMenuItemConcept> lijst) {
    for (final item in lijst) {
      item.ingeklapt = true;
      _zetAllesIngeklapt(item.kinderen);
    }
  }

  void _voegKeuzeToe({List<_TechnischMenuItemConcept>? doelLijst}) {
    setState(() {
      final lijst = doelLijst ?? _items;

      _zetAllesIngeklapt(_items);

      lijst.add(
        _TechnischMenuItemConcept.nieuweKeuze(
          id: _nieuwId('soort'),
          ingeklapt: false,
        ),
      );

      _foutmelding = null;
    });
  }

  void _voegSubmenuToe({List<_TechnischMenuItemConcept>? doelLijst}) {
    setState(() {
      final lijst = doelLijst ?? _items;

      _zetAllesIngeklapt(_items);

      lijst.add(
        _TechnischMenuItemConcept.nieuwSubmenu(
          id: _nieuwId('submenu'),
          ingeklapt: false,
        ),
      );

      _foutmelding = null;
    });
  }

  Future<void> _openKeuzeOpladen({
    List<_TechnischMenuItemConcept>? doelLijst,
  }) async {
    if (widget.oplaadbareKeuzes.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            title: const Text('Keuze opladen'),
            content: const Text(
              'Er zijn nog geen keuzes gevonden in de andere opmeetfiches.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Sluiten'),
              ),
            ],
          );
        },
      );
      return;
    }

    final gekozen = await showDialog<OpmetingRaamTechnischeOplaadbareKeuze>(
      context: context,
      builder: (dialogContext) {
        final basisTheme = Theme.of(dialogContext);

        return Theme(
          data: basisTheme.copyWith(
            colorScheme: basisTheme.colorScheme.copyWith(
              primary: groen,
              secondary: groen,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: groen),
            ),
          ),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            titlePadding: EdgeInsets.zero,
            title: Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
              decoration: const BoxDecoration(
                color: lichtGroen,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.download_outlined, color: groen, size: 21),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Keuze opladen',
                      style: TextStyle(
                        color: groen,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            content: SizedBox(
              width: 540,
              height: 420,
              child: ListView.separated(
                itemCount: widget.oplaadbareKeuzes.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final keuze = widget.oplaadbareKeuzes[index];

                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.check_box_outline_blank,
                      color: groen,
                      size: 20,
                    ),
                    title: Text(
                      keuze.titel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      keuze.bronTekst,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.pop(dialogContext, keuze);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Annuleren'),
              ),
            ],
          ),
        );
      },
    );

    if (gekozen == null) {
      return;
    }

    setState(() {
      final nieuweItems = gekozen.items
          .map(
            (item) => _TechnischMenuItemConcept.kopieVanMenuItem(
              item,
              nieuwId: _nieuwId,
            ),
          )
          .toList();

      _zetAllesIngeklapt(_items);

      if (doelLijst == null) {
        for (final item in _items) {
          item.dispose();
        }

        _items
          ..clear()
          ..addAll(nieuweItems);

        if (_titelController.text.trim().isEmpty) {
          _titelController.text = gekozen.titel;
        }
      } else {
        doelLijst.addAll(nieuweItems);
      }

      if (nieuweItems.isNotEmpty) {
        nieuweItems.first.ingeklapt = false;
      }

      _foutmelding = null;
    });
  }

  void _kopieerItem({
    required List<_TechnischMenuItemConcept> lijst,
    required _TechnischMenuItemConcept item,
  }) {
    setState(() {
      _zetAllesIngeklapt(_items);

      final index = lijst.indexOf(item);
      final kopie = _TechnischMenuItemConcept.kopieVan(item, nieuwId: _nieuwId);

      kopie.ingeklapt = false;

      if (index < 0 || index >= lijst.length - 1) {
        lijst.add(kopie);
      } else {
        lijst.insert(index + 1, kopie);
      }

      _foutmelding = null;
    });
  }

  void _verwijderItem({
    required List<_TechnischMenuItemConcept> lijst,
    required int index,
  }) {
    if (index < 0 || index >= lijst.length) {
      return;
    }

    setState(() {
      final verwijderd = lijst.removeAt(index);
      verwijderd.dispose();
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

        if (tekening.breedteKeuze ==
                OpmetingRaamTechnischeMaatKeuze.vasteMaat &&
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
      uitvoerTekst: '',
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

  @override
  Widget build(BuildContext context) {
    final schermHoogte = MediaQuery.sizeOf(context).height;

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _titelController,
                      autofocus: widget.bestaandMenu == null,
                      decoration: const InputDecoration(
                        labelText: 'Titel technische keuze',
                        hintText: 'Bijvoorbeeld: Rolluiken',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _bouwStructuurKop(),
                    const SizedBox(height: 10),
                    ...List<Widget>.generate(_items.length, (index) {
                      return _bouwItemKaart(
                        lijst: _items,
                        item: _items[index],
                        index: index,
                        diepte: 0,
                      );
                    }),
                    if (_items.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: achtergrond,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: rand),
                        ),
                        child: const Text(
                          'Nog geen keuzes toegevoegd. Gebruik Submenu, + keuze of Keuze opladen.',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (_foutmelding != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Text(
                          _foutmelding!,
                          style: const TextStyle(
                            color: Color(0xFFB91C1C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            _bouwOnderbalk(),
          ],
        ),
      ),
    );
  }

  Widget _bouwStructuurKop() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: lichtGroen,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: groen),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Soorten / keuzes',
              style: TextStyle(
                color: groen,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  _openKeuzeOpladen();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: groen,
                  side: const BorderSide(color: groen),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.download_outlined, size: 17),
                label: const Text('Keuze opladen'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  _voegSubmenuToe();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: groen,
                  side: const BorderSide(color: groen),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.account_tree_outlined, size: 17),
                label: const Text('Submenu'),
              ),
              FilledButton.icon(
                onPressed: () {
                  _voegKeuzeToe();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: groen,
                  foregroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.add, size: 17),
                label: const Text('+ keuze'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bouwKop() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      decoration: const BoxDecoration(
        color: lichtGroen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune, color: groen, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.bestaandMenu == null
                  ? 'Nieuwe technische keuze'
                  : 'Technische keuze aanpassen',
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
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close, color: groen),
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
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Annuleren'),
          ),
          const Spacer(),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: groen,
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

  Widget _bouwItemKaart({
    required List<_TechnischMenuItemConcept> lijst,
    required _TechnischMenuItemConcept item,
    required int index,
    required int diepte,
  }) {
    final naam = item.naamController.text.trim();
    final titel = naam.isEmpty
        ? item.isSubmenu
              ? 'Submenu'
              : 'Keuze ${index + 1}'
        : naam;

    final beschikbareNietCombineerbareKeuzes = widget
        .beschikbareNietCombineerbareKeuzes
        .where((keuze) => keuze.optieId != item.id)
        .toList();

    return Padding(
      padding: EdgeInsets.only(left: diepte * 14.0, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: item.isSubmenu ? Colors.white : achtergrond,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: rand),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  item.ingeklapt = !item.ingeklapt;
                });
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 9, 8, 9),
                child: Row(
                  children: [
                    Icon(
                      item.ingeklapt
                          ? Icons.keyboard_arrow_right
                          : Icons.keyboard_arrow_down,
                      color: groen,
                      size: 21,
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      item.isSubmenu
                          ? Icons.account_tree_outlined
                          : Icons.check_box_outline_blank,
                      color: item.isSubmenu ? groen : const Color(0xFF6B7280),
                      size: 18,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            item.isSubmenu
                                ? 'Submenu · ${item.kinderen.length} onderliggend'
                                : '${item.tekeningen.length} rechthoek${item.tekeningen.length == 1 ? '' : 'en'}',
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: item.isSubmenu
                          ? 'Submenu kopiëren'
                          : 'Keuze kopiëren',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 30,
                        minHeight: 30,
                      ),
                      onPressed: () {
                        _kopieerItem(lijst: lijst, item: item);
                      },
                      icon: const Icon(Icons.copy, color: groen, size: 17),
                    ),
                    IconButton(
                      tooltip: item.isSubmenu
                          ? 'Submenu verwijderen'
                          : 'Keuze verwijderen',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 30,
                        minHeight: 30,
                      ),
                      onPressed: () {
                        _verwijderItem(lijst: lijst, index: index);
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFDC2626),
                        size: 19,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!item.ingeklapt) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: item.isSubmenu
                    ? _bouwSubmenuInhoud(item: item, diepte: diepte)
                    : _bouwKeuzeInhoud(
                        item: item,
                        index: index,
                        beschikbareNietCombineerbareKeuzes:
                            beschikbareNietCombineerbareKeuzes,
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _bouwSubmenuInhoud({
    required _TechnischMenuItemConcept item,
    required int diepte,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: item.naamController,
          onChanged: (_) {
            setState(() {});
          },
          decoration: const InputDecoration(
            labelText: 'Naam submenu',
            hintText: 'Bijvoorbeeld: Traditionele rolluiken',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _openKeuzeOpladen(doelLijst: item.kinderen);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: groen,
                  side: const BorderSide(color: groen),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.download_outlined, size: 17),
                label: const Text('Keuze opladen'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _voegSubmenuToe(doelLijst: item.kinderen);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: groen,
                  side: const BorderSide(color: groen),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.account_tree_outlined, size: 17),
                label: const Text('Submenu'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  _voegKeuzeToe(doelLijst: item.kinderen);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: groen,
                  foregroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.add, size: 17),
                label: const Text('+ keuze'),
              ),
            ),
          ],
        ),
        if (item.kinderen.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              'Geen onderliggende keuzes. Voeg hier keuzes of extra submenu’s toe.',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
            ),
          )
        else ...[
          const SizedBox(height: 10),
          ...List<Widget>.generate(item.kinderen.length, (kindIndex) {
            return _bouwItemKaart(
              lijst: item.kinderen,
              item: item.kinderen[kindIndex],
              index: kindIndex,
              diepte: diepte + 1,
            );
          }),
        ],
      ],
    );
  }

  Widget _bouwKeuzeInhoud({
    required _TechnischMenuItemConcept item,
    required int index,
    required List<OpmetingRaamBeschikbareNietCombineerbareKeuze>
    beschikbareNietCombineerbareKeuzes,
  }) {
    final maximumBereikt = item.tekeningen.length >= 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: item.naamController,
          onChanged: (_) {
            setState(() {});
          },
          decoration: InputDecoration(
            labelText: 'Keuze ${index + 1}',
            hintText: 'Bijvoorbeeld: Minirol',
            border: const OutlineInputBorder(),
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

class _TechnischMenuItemConcept {
  _TechnischMenuItemConcept({
    required this.id,
    required this.type,
    required this.naamController,
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

  factory _TechnischMenuItemConcept.kopieVanMenuItem(
    OpmetingRaamKeuzeMenuItem item, {
    required String Function(String prefix) nieuwId,
  }) {
    if (item.isSubmenu) {
      return _TechnischMenuItemConcept(
        id: nieuwId('submenu'),
        type: OpmetingRaamKeuzeMenuItemType.submenu,
        naamController: TextEditingController(text: item.naam.trim()),
        tekeningen: <OpmetingRaamTechnischeTekeningConcept>[],
        nietCombineerbaarMet: <OpmetingRaamNietCombineerbareKeuze>[],
        kinderen: item.kinderen
            .map(
              (kind) => _TechnischMenuItemConcept.kopieVanMenuItem(
                kind,
                nieuwId: nieuwId,
              ),
            )
            .toList(),
        ingeklapt: true,
      );
    }

    final optie = item.optie;

    return _TechnischMenuItemConcept(
      id: nieuwId('soort'),
      type: OpmetingRaamKeuzeMenuItemType.keuze,
      naamController: TextEditingController(
        text: (optie?.naam ?? item.naam).trim(),
      ),
      tekeningen:
          (optie?.alleTechnischeTekeningen ??
                  const <OpmetingRaamTechnischeTekeningInstelling>[])
              .take(4)
              .map(OpmetingRaamTechnischeTekeningConcept.vanInstelling)
              .toList(),
      nietCombineerbaarMet: <OpmetingRaamNietCombineerbareKeuze>[],
      kinderen: <_TechnischMenuItemConcept>[],
      ingeklapt: true,
    );
  }

  factory _TechnischMenuItemConcept.kopieVan(
    _TechnischMenuItemConcept bron, {
    required String Function(String prefix) nieuwId,
  }) {
    final naam = bron.naamController.text.trim();

    if (bron.isSubmenu) {
      return _TechnischMenuItemConcept(
        id: nieuwId('submenu'),
        type: OpmetingRaamKeuzeMenuItemType.submenu,
        naamController: TextEditingController(
          text: naam.isEmpty ? '' : '$naam kopie',
        ),
        tekeningen: <OpmetingRaamTechnischeTekeningConcept>[],
        nietCombineerbaarMet: <OpmetingRaamNietCombineerbareKeuze>[],
        kinderen: bron.kinderen
            .map(
              (kind) =>
                  _TechnischMenuItemConcept.kopieVan(kind, nieuwId: nieuwId),
            )
            .toList(),
        ingeklapt: false,
      );
    }

    return _TechnischMenuItemConcept(
      id: nieuwId('soort'),
      type: OpmetingRaamKeuzeMenuItemType.keuze,
      naamController: TextEditingController(
        text: naam.isEmpty ? '' : '$naam kopie',
      ),
      tekeningen: bron.tekeningen
          .map(OpmetingRaamTechnischeTekeningConcept.kopieVan)
          .toList(),
      nietCombineerbaarMet: List<OpmetingRaamNietCombineerbareKeuze>.from(
        bron.nietCombineerbaarMet,
      ),
      kinderen: <_TechnischMenuItemConcept>[],
      ingeklapt: false,
    );
  }

  final String id;
  final OpmetingRaamKeuzeMenuItemType type;
  final TextEditingController naamController;
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

    for (final tekening in tekeningen) {
      tekening.dispose();
    }

    for (final kind in kinderen) {
      kind.dispose();
    }
  }
}
