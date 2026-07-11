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

  /// Nieuwe opslagvorm met maximaal vier rechthoeken.
  final List<OpmetingRaamTechnischeTekeningInstelling> tekeningen;

  /// Tijdelijke ondersteuning voor bestaande code die nog
  /// één technische tekening doorgeeft.
  final OpmetingRaamTechnischeTekeningInstelling? _oudeTekening;

  /// Andere keuzes waarmee deze keuze niet gecombineerd
  /// mag worden.
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

  /// Compatibiliteit met bestaande code.
  OpmetingRaamTechnischeTekeningInstelling get tekening {
    final bestaandeTekeningen = alleTekeningen;

    if (bestaandeTekeningen.isNotEmpty) {
      return bestaandeTekeningen.first;
    }

    return OpmetingRaamTechnischeTekeningInstelling.standaard();
  }
}

class OpmetingRaamTechnischMenuResultaat {
  const OpmetingRaamTechnischMenuResultaat({
    required this.titel,
    required this.soorten,
    required this.actief,
  });

  final String titel;

  final List<OpmetingRaamTechnischeSoortResultaat> soorten;

  final bool actief;
}

Future<OpmetingRaamTechnischMenuResultaat?>
toonOpmetingRaamTechnischMenuDialoog({
  required BuildContext context,
  OpmetingRaamTechnischMenuResultaat? bestaandMenu,
  List<OpmetingRaamBeschikbareNietCombineerbareKeuze>
      beschikbareNietCombineerbareKeuzes =
      const <OpmetingRaamBeschikbareNietCombineerbareKeuze>[],
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
              fontWeight: FontWeight.w600,
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
  });

  final OpmetingRaamTechnischMenuResultaat? bestaandMenu;

  final List<OpmetingRaamBeschikbareNietCombineerbareKeuze>
  beschikbareNietCombineerbareKeuzes;

  @override
  State<OpmetingRaamTechnischMenuDialoog> createState() {
    return _OpmetingRaamTechnischMenuDialoogState();
  }
}

class _OpmetingRaamTechnischMenuDialoogState
    extends State<OpmetingRaamTechnischMenuDialoog> {
  static const Color groen = Color(0xFF0B7A3B);
  static const Color rand = Color(0xFFE5E7EB);
  static const Color achtergrond = Color(0xFFF9FAFB);

  late final TextEditingController _titelController;

  final List<_TechnischeSoortConcept> _soorten = <_TechnischeSoortConcept>[];

  bool _menuActief = true;
  String? _foutmelding;

  @override
  void initState() {
    super.initState();

    _titelController = TextEditingController(
      text: widget.bestaandMenu?.titel ?? '',
    );

    _menuActief = widget.bestaandMenu?.actief ?? true;

    final bestaandeSoorten = widget.bestaandMenu?.soorten;

    if (bestaandeSoorten != null && bestaandeSoorten.isNotEmpty) {
      for (final soort in bestaandeSoorten) {
        _soorten.add(_TechnischeSoortConcept.vanResultaat(soort));
      }
    } else {
      _soorten.add(_TechnischeSoortConcept.nieuw());
    }
  }

  @override
  void dispose() {
    _titelController.dispose();

    for (final soort in _soorten) {
      soort.dispose();
    }

    super.dispose();
  }

  void _voegSoortToe() {
    setState(() {
      _soorten.add(_TechnischeSoortConcept.nieuw());

      _foutmelding = null;
    });
  }

  void _verwijderSoort(int index) {
    if (index < 0 || index >= _soorten.length) {
      return;
    }

    setState(() {
      final verwijderd = _soorten.removeAt(index);

      verwijderd.dispose();
      _foutmelding = null;
    });
  }

  void _voegTekeningToe(_TechnischeSoortConcept soort) {
    if (soort.tekeningen.length >= 4) {
      setState(() {
        _foutmelding =
            'Per soort kunnen maximaal vier rechthoeken '
            'worden toegevoegd.';
      });

      return;
    }

    setState(() {
      soort.tekeningen.add(OpmetingRaamTechnischeTekeningConcept.nieuw());

      _foutmelding = null;
    });
  }

  void _verwijderTekening({
    required _TechnischeSoortConcept soort,
    required int index,
  }) {
    if (index < 0 || index >= soort.tekeningen.length) {
      return;
    }

    setState(() {
      final verwijderd = soort.tekeningen.removeAt(index);

      verwijderd.dispose();
      _foutmelding = null;
    });
  }

  void _bewaar() {
    final titel = _titelController.text.trim();

    if (titel.isEmpty) {
      _toonFout('Vul een titel in.');
      return;
    }

    if (_soorten.isEmpty) {
      _toonFout('Voeg minstens één soort of keuze toe.');
      return;
    }

    final gebruikteNamen = <String>{};

    final resultaten = <OpmetingRaamTechnischeSoortResultaat>[];

    for (var soortIndex = 0; soortIndex < _soorten.length; soortIndex++) {
      final soort = _soorten[soortIndex];

      final naam = soort.naamController.text.trim();

      if (naam.isEmpty) {
        _toonFout(
          'Vul een naam in bij soort '
          '${soortIndex + 1}.',
        );
        return;
      }

      if (naam.toLowerCase() == 'geen') {
        _toonFout(
          'De keuze “Geen” wordt automatisch '
          'toegevoegd.',
        );
        return;
      }

      final naamSleutel = naam.toLowerCase();

      if (!gebruikteNamen.add(naamSleutel)) {
        _toonFout(
          'De soort “$naam” werd meer dan '
          'één keer ingevoerd.',
        );
        return;
      }

      if (soort.tekeningen.length > 4) {
        _toonFout(
          'Bij “$naam” kunnen maximaal vier '
          'rechthoeken worden gebruikt.',
        );
        return;
      }

      for (
        var tekeningIndex = 0;
        tekeningIndex < soort.tekeningen.length;
        tekeningIndex++
      ) {
        final tekening = soort.tekeningen[tekeningIndex];

        final nummer = tekeningIndex + 1;

        if (tekening.breedteKeuze ==
                OpmetingRaamTechnischeMaatKeuze.vasteMaat &&
            tekening.breedteMm <= 0) {
          _toonFout(
            'Vul bij “$naam”, rechthoek $nummer, '
            'een geldige breedte in.',
          );
          return;
        }

        if (tekening.hoogteKeuze == OpmetingRaamTechnischeMaatKeuze.vasteMaat &&
            tekening.hoogteMm <= 0) {
          _toonFout(
            'Vul bij “$naam”, rechthoek $nummer, '
            'een geldige hoogte in.',
          );
          return;
        }

        if (tekening.maatPlaatsing ==
            OpmetingRaamTechnischeMaatPlaatsing.buitenDeRaammaat) {
          final afstandTekst = tekening.afstandController.text.trim();

          if (afstandTekst.isEmpty || int.tryParse(afstandTekst) == null) {
            _toonFout(
              'Vul bij “$naam”, rechthoek $nummer, '
              'een geldige afstand in. Negatieve '
              'waarden zijn toegestaan.',
            );
            return;
          }
        }

        if (tekening.inhoudType == OpmetingRaamTechnischeInhoudType.tekst &&
            tekening.tekstController.text.trim().isEmpty) {
          _toonFout(
            'Vul bij “$naam”, rechthoek $nummer, '
            'de tekst voor de rechthoek in.',
          );
          return;
        }
      }

      final geldigeNietCombineerbareKeuzes =
          <OpmetingRaamNietCombineerbareKeuze>[];

      final gebruikteKoppelingen = <String>{};

      for (final koppeling in soort.nietCombineerbaarMet) {
        if (!koppeling.isGeldig) {
          continue;
        }

        /*
         * Een keuze mag zichzelf niet als
         * niet-combineerbaar opslaan.
         */
        if (koppeling.optieId == soort.id) {
          continue;
        }

        if (!gebruikteKoppelingen.add(koppeling.sleutel)) {
          continue;
        }

        geldigeNietCombineerbareKeuzes.add(koppeling);
      }

      resultaten.add(
        OpmetingRaamTechnischeSoortResultaat(
          id: soort.id,
          naam: naam,
          tekeningen: soort.tekeningen
              .map((tekening) => tekening.naarInstelling())
              .take(4)
              .toList(),
          nietCombineerbaarMet:
              List<OpmetingRaamNietCombineerbareKeuze>.unmodifiable(
                geldigeNietCombineerbareKeuzes,
              ),
        ),
      );
    }

    Navigator.pop(
      context,
      OpmetingRaamTechnischMenuResultaat(
        titel: titel,
        soorten: resultaten,
        actief: _menuActief,
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
          maxWidth: 820,
          maxHeight: schermHoogte - 48,
        ),
        child: Column(
          children: [
            _bouwKop(),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _titelController,
                      autofocus: widget.bestaandMenu == null,
                      decoration: const InputDecoration(
                        labelText: 'Titel',
                        hintText: 'Bijvoorbeeld: Dorpel',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Technische keuze actief',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: const Text(
                        'Een inactieve technische keuze '
                        'wordt tijdens een normale opmeting '
                        'verborgen.',
                      ),
                      value: _menuActief,
                      onChanged: (waarde) {
                        setState(() {
                          _menuActief = waarde;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Soorten / keuzes',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _voegSoortToe,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Soort toevoegen'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...List<Widget>.generate(_soorten.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _bouwSoortKaart(
                          soort: _soorten[index],
                          index: index,
                        ),
                      );
                    }),
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

  Widget _bouwKop() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 10, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.bestaandMenu == null
                  ? 'Nieuwe technische keuze'
                  : 'Technische keuze aanpassen',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            tooltip: 'Sluiten',
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _bouwOnderbalk() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Annuleren'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: _bewaar,
            style: FilledButton.styleFrom(
              backgroundColor: groen,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Bewaren'),
          ),
        ],
      ),
    );
  }

  Widget _bouwSoortKaart({
    required _TechnischeSoortConcept soort,
    required int index,
  }) {
    final maximumBereikt = soort.tekeningen.length >= 4;

    /*
     * De eigen keuze wordt uit de beschikbare
     * uitsluitingen gefilterd.
     */
    final beschikbareNietCombineerbareKeuzes = widget
        .beschikbareNietCombineerbareKeuzes
        .where((keuze) => keuze.optieId != soort.id)
        .toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: achtergrond,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: soort.naamController,
                  decoration: InputDecoration(
                    labelText: 'Soort ${index + 1}',
                    hintText: 'Bijvoorbeeld: Blauwe hardsteen',
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Soort verwijderen',
                onPressed: () {
                  _verwijderSoort(index);
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 12),

          OpmetingRaamNietCombineerbaarKeuzemenu(
            beschikbareKeuzes: beschikbareNietCombineerbareKeuzes,
            geselecteerdeKeuzes: soort.nietCombineerbaarMet,
            onGewijzigd: (nieuweKeuzes) {
              setState(() {
                soort.nietCombineerbaarMet =
                    List<OpmetingRaamNietCombineerbareKeuze>.from(nieuweKeuzes);

                _foutmelding = null;
              });
            },
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Extra rechthoekige tekeningen',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${soort.tekeningen.length}/4',
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
                        _voegTekeningToe(soort);
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

          if (soort.tekeningen.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Geen extra rechthoekige tekening. '
                'Gebruik het plusteken om er één toe '
                'te voegen.',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
            )
          else ...[
            const SizedBox(height: 8),
            ...List<Widget>.generate(soort.tekeningen.length, (tekeningIndex) {
              final tekening = soort.tekeningen[tekeningIndex];

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
                    _verwijderTekening(soort: soort, index: tekeningIndex);
                  },
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _TechnischeSoortConcept {
  _TechnischeSoortConcept({
    required this.id,
    required this.naamController,
    required this.tekeningen,
    required this.nietCombineerbaarMet,
  });

  factory _TechnischeSoortConcept.nieuw() {
    return _TechnischeSoortConcept(
      id: 'soort_${DateTime.now().microsecondsSinceEpoch}',
      naamController: TextEditingController(),
      tekeningen: <OpmetingRaamTechnischeTekeningConcept>[],
      nietCombineerbaarMet: <OpmetingRaamNietCombineerbareKeuze>[],
    );
  }

  factory _TechnischeSoortConcept.vanResultaat(
    OpmetingRaamTechnischeSoortResultaat resultaat,
  ) {
    return _TechnischeSoortConcept(
      id: resultaat.id,
      naamController: TextEditingController(text: resultaat.naam),
      tekeningen: resultaat.alleTekeningen
          .take(4)
          .map(OpmetingRaamTechnischeTekeningConcept.vanInstelling)
          .toList(),
      nietCombineerbaarMet: List<OpmetingRaamNietCombineerbareKeuze>.from(
        resultaat.nietCombineerbaarMet,
      ),
    );
  }

  final String id;

  final TextEditingController naamController;

  final List<OpmetingRaamTechnischeTekeningConcept> tekeningen;

  List<OpmetingRaamNietCombineerbareKeuze> nietCombineerbaarMet;

  void dispose() {
    naamController.dispose();

    for (final tekening in tekeningen) {
      tekening.dispose();
    }
  }
}
