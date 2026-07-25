import 'package:flutter/material.dart';

import 'offerte_algemene_prijsregel_model.dart';

class OfferteAlgemenePrijsregelToepassenPositie {
  const OfferteAlgemenePrijsregelToepassenPositie({
    required this.artikelId,
    required this.positieLabel,
    required this.artikelLabel,
    this.bedragenPerPrijsregelId = const <String, double>{},
    this.toegepastePrijsregelIds = const <String>{},
  });

  final String artikelId;
  final String positieLabel;
  final String artikelLabel;
  final Map<String, double> bedragenPerPrijsregelId;
  final Set<String> toegepastePrijsregelIds;

  double bedragVoorPrijsregel(String prijsregelId) {
    return bedragenPerPrijsregelId[prijsregelId] ?? 0.0;
  }

  bool isToegepastVoorPrijsregel(String prijsregelId) {
    return toegepastePrijsregelIds.contains(prijsregelId);
  }
}

class OfferteAlgemenePrijsregelToepassenGroep {
  const OfferteAlgemenePrijsregelToepassenGroep({
    required this.formulierType,
    required this.label,
    this.posities = const <OfferteAlgemenePrijsregelToepassenPositie>[],
  });

  final String formulierType;
  final String label;
  final List<OfferteAlgemenePrijsregelToepassenPositie> posities;

  bool get isAanwezigInOfferte => posities.isNotEmpty;
}

enum OfferteAlgemenePrijsregelToepassenActie {
  toepassenOpOfferte,
  toepassenEnNogEenPrijsregelKiezen,
  nieuwePrijsregelToevoegen,
}

class OfferteAlgemenePrijsregelToepassenResultaat {
  const OfferteAlgemenePrijsregelToepassenResultaat({
    required this.prijsregel,
    required this.artikelIds,
    required this.volledigeGroepFormulierTypes,
    required this.actie,
  });

  final OfferteAlgemenePrijsregelModel? prijsregel;
  final Set<String> artikelIds;
  final Set<String> volledigeGroepFormulierTypes;
  final OfferteAlgemenePrijsregelToepassenActie actie;
}

Future<OfferteAlgemenePrijsregelToepassenResultaat?>
toonOfferteAlgemenePrijsregelToepassenDialog({
  required BuildContext context,
  required List<OfferteAlgemenePrijsregelModel> prijsregels,
  required List<OfferteAlgemenePrijsregelToepassenGroep> groepen,
  String? initielePrijsregelId,
}) {
  return showDialog<OfferteAlgemenePrijsregelToepassenResultaat>(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return _OfferteAlgemenePrijsregelToepassenDialog(
        prijsregels: prijsregels,
        groepen: groepen,
        initielePrijsregelId: initielePrijsregelId,
      );
    },
  );
}

class _OfferteAlgemenePrijsregelToepassenDialog extends StatefulWidget {
  const _OfferteAlgemenePrijsregelToepassenDialog({
    required this.prijsregels,
    required this.groepen,
    this.initielePrijsregelId,
  });

  final List<OfferteAlgemenePrijsregelModel> prijsregels;
  final List<OfferteAlgemenePrijsregelToepassenGroep> groepen;
  final String? initielePrijsregelId;

  @override
  State<_OfferteAlgemenePrijsregelToepassenDialog> createState() {
    return _OfferteAlgemenePrijsregelToepassenDialogState();
  }
}

class _OfferteAlgemenePrijsregelToepassenDialogState
    extends State<_OfferteAlgemenePrijsregelToepassenDialog> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);
  static const Color _rood = Color(0xFFDC2626);
  static const Color _groeneRand = Color(0xFF86C99F);

  late String _geselecteerdePrijsregelId;

  final Set<String> _geselecteerdeArtikelIds = <String>{};
  final Set<String> _explicietVolledigeGroepTypes = <String>{};

  OfferteAlgemenePrijsregelModel get _geselecteerdePrijsregel {
    for (final prijsregel in widget.prijsregels) {
      if (prijsregel.id == _geselecteerdePrijsregelId) {
        return prijsregel;
      }
    }

    return widget.prijsregels.first;
  }

  List<OfferteAlgemenePrijsregelToepassenGroep> get _groepenInOfferte {
    return widget.groepen
        .where((groep) => groep.isAanwezigInOfferte)
        .toList(growable: false);
  }

  List<OfferteAlgemenePrijsregelToepassenGroep> get _overigeGroepen {
    return widget.groepen
        .where((groep) => !groep.isAanwezigInOfferte)
        .toList(growable: false);
  }

  Set<String> get _toegelatenFormulierTypeSleutels {
    return _geselecteerdePrijsregel.toepasselijkeFormulierTypes
        .map(_normaliseerFormulierType)
        .where((sleutel) => sleutel.isNotEmpty)
        .toSet();
  }

  List<OfferteAlgemenePrijsregelToepassenPositie> get _beschikbarePosities {
    final resultaat = <OfferteAlgemenePrijsregelToepassenPositie>[];

    for (final groep in _groepenInOfferte) {
      if (!_groepIsToegelaten(groep)) {
        continue;
      }

      resultaat.addAll(groep.posities);
    }

    return resultaat;
  }

  bool get _allesGeselecteerd {
    final beschikbareIds = _beschikbarePosities
        .map((positie) => positie.artikelId)
        .toSet();

    return beschikbareIds.isNotEmpty &&
        _geselecteerdeArtikelIds.length == beschikbareIds.length &&
        _geselecteerdeArtikelIds.containsAll(beschikbareIds);
  }

  double get _selectieTotaalExclBtw {
    var totaal = 0.0;

    for (final positie in _beschikbarePosities) {
      if (_geselecteerdeArtikelIds.contains(positie.artikelId)) {
        totaal += positie.bedragVoorPrijsregel(_geselecteerdePrijsregelId);
      }
    }

    return (totaal * 100.0).roundToDouble() / 100.0;
  }

  bool get _heeftBestaandeToepassing {
    return _beschikbarePosities.any(
      (positie) =>
          positie.isToegepastVoorPrijsregel(_geselecteerdePrijsregelId),
    );
  }

  bool get _kanToepassen {
    return _geselecteerdeArtikelIds.isNotEmpty || _heeftBestaandeToepassing;
  }

  @override
  void initState() {
    super.initState();

    final voorgesteldId = widget.initielePrijsregelId?.trim() ?? '';

    _geselecteerdePrijsregelId =
        widget.prijsregels.any((prijsregel) => prijsregel.id == voorgesteldId)
        ? voorgesteldId
        : widget.prijsregels.first.id;

    _laadBestaandeSelectieVoorPrijsregel();
  }

  @override
  Widget build(BuildContext context) {
    final scherm = MediaQuery.sizeOf(context);

    final breedte = (scherm.width - 28).clamp(320.0, 900.0).toDouble();

    final hoogte = (scherm.height - 48).clamp(430.0, 800.0).toDouble();

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.all(14),
      contentPadding: EdgeInsets.zero,
      actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      titlePadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: _bouwTitel(),
      content: SizedBox(
        width: breedte,
        height: hoogte,
        child: Column(
          children: <Widget>[
            _bouwPrijsregelKeuze(),
            const Divider(height: 1, color: _rand),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                children: <Widget>[
                  _bouwSelectieUitleg(),
                  const SizedBox(height: 12),
                  _bouwAllesSelecteren(),
                  const SizedBox(height: 12),
                  const _SectieTitel(
                    titel: 'Artikelen in deze offerte',
                    subtitel:
                        'Deze artikelgroepen staan bovenaan. Selecteer een '
                        'volledige groep of afzonderlijke posities.',
                  ),
                  const SizedBox(height: 9),
                  if (_groepenInOfferte.isEmpty)
                    _bouwLegeOfferteMelding()
                  else
                    ..._groepenInOfferte.map(_bouwAanwezigeGroep),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: _rand),
                  const SizedBox(height: 14),
                  const _SectieTitel(
                    titel: 'Overige artikelen',
                    subtitel:
                        'Deze artikeltypes bestaan in het programma, maar '
                        'komen niet voor in de huidige offerte.',
                  ),
                  const SizedBox(height: 9),
                  if (_overigeGroepen.isEmpty)
                    const Text(
                      'Alle beschikbare artikeltypes komen in deze offerte voor.',
                      style: TextStyle(
                        color: _tekstGrijs,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    ..._overigeGroepen.map(_bouwOverigeGroep),
                ],
              ),
            ),
            _bouwSelectieSamenvatting(),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(foregroundColor: _tekstGrijs),
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Sluiten',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: _groen,
            side: const BorderSide(color: _groeneRand, width: 1.2),
            backgroundColor: Colors.white,
          ),
          onPressed: !_kanToepassen
              ? null
              : () => _sluitMetResultaat(
                  OfferteAlgemenePrijsregelToepassenActie
                      .toepassenEnNogEenPrijsregelKiezen,
                ),
          icon: const Icon(Icons.add_task_outlined, size: 18),
          label: const Text(
            'Toepassen en nog een prijsregel kiezen',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: _groen,
            foregroundColor: Colors.white,
          ),
          onPressed: !_kanToepassen
              ? null
              : () => _sluitMetResultaat(
                  OfferteAlgemenePrijsregelToepassenActie.toepassenOpOfferte,
                ),
          icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
          label: const Text(
            'Toepassen op offerte',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  Widget _bouwTitel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 12, 14),
      decoration: const BoxDecoration(
        color: _lichtGroen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        border: Border(bottom: BorderSide(color: _rand)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: _rand),
            ),
            child: const Icon(
              Icons.rule_folder_outlined,
              color: _groen,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Prijsregel toepassen op…',
                  style: TextStyle(
                    color: _tekstDonker,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Nieuwe onafhankelijke algemene prijsregels',
                  style: TextStyle(
                    color: _tekstGrijs,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Sluiten',
            color: _tekstGrijs,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _bouwPrijsregelKeuze() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 650;

          final keuzelijst = DropdownButtonFormField<String>(
            key: ValueKey<String>(_geselecteerdePrijsregelId),
            initialValue: _geselecteerdePrijsregelId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Algemene prijsregel',
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: _rand),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: _rand),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: _groen, width: 1.5),
              ),
            ),
            items: widget.prijsregels
                .map((prijsregel) {
                  return DropdownMenuItem<String>(
                    value: prijsregel.id,
                    child: Text(
                      prijsregel.omschrijving,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  );
                })
                .toList(growable: false),
            onChanged: (waarde) {
              if (waarde == null) {
                return;
              }

              setState(() {
                _geselecteerdePrijsregelId = waarde;
                _laadBestaandeSelectieVoorPrijsregel();
              });
            },
          );

          final toevoegenKnop = OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: _groen,
              backgroundColor: _lichtGroen,
              side: const BorderSide(color: _groeneRand, width: 1.2),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            onPressed: _sluitVoorNieuwePrijsregel,
            icon: const Icon(Icons.add_rounded, size: 19),
            label: const Text(
              'Prijsregel voor alle artikelen toevoegen',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                keuzelijst,
                const SizedBox(height: 10),
                toevoegenKnop,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(child: keuzelijst),
              const SizedBox(width: 10),
              toevoegenKnop,
            ],
          );
        },
      ),
    );
  }

  Widget _bouwSelectieUitleg() {
    final prijsregel = _geselecteerdePrijsregel;

    final aantalToegelaten = prijsregel.toepasselijkeFormulierTypes.length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _rand),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.info_outline_rounded, color: _groen, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'De bedragen worden per positie berekend volgens de gekozen '
              'eenheid. De gekozen prijsregel is in Instellingen toegelaten '
              'voor $aantalToegelaten artikeltype'
              '${aantalToegelaten == 1 ? '' : 's'}. '
              'Niet-toegelaten groepen blijven zichtbaar, maar zijn niet '
              'selecteerbaar. Alle bedragen zijn excl. btw.',
              style: const TextStyle(
                color: _tekstGrijs,
                fontSize: 11.5,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwAllesSelecteren() {
    final beschikbaarAantal = _beschikbarePosities.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: _lichtGroen,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFBBE4C9)),
      ),
      child: CheckboxListTile(
        value: _allesGeselecteerd
            ? true
            : _geselecteerdeArtikelIds.isNotEmpty
            ? null
            : false,
        tristate: true,
        activeColor: _groen,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        title: const Text(
          'Alle beschikbare offerteposities',
          style: TextStyle(
            color: _tekstDonker,
            fontSize: 12.8,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          '$beschikbaarAantal selecteerbare '
          'positie${beschikbaarAantal == 1 ? '' : 's'}',
          style: const TextStyle(
            color: _tekstGrijs,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        onChanged: beschikbaarAantal == 0 ? null : _wisselAlles,
      ),
    );
  }

  Widget _bouwAanwezigeGroep(OfferteAlgemenePrijsregelToepassenGroep groep) {
    final toegelaten = _groepIsToegelaten(groep);

    final heleGroep = toegelaten && _heleGroepGeselecteerd(groep);

    final gedeeltelijk = toegelaten && _deelVanGroepGeselecteerd(groep);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: toegelaten ? _rand : const Color(0xFFF1F2F4)),
      ),
      child: Column(
        children: <Widget>[
          CheckboxListTile(
            value: heleGroep
                ? true
                : gedeeltelijk
                ? null
                : false,
            tristate: true,
            activeColor: _groen,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              groep.label,
              style: TextStyle(
                color: toegelaten ? _tekstDonker : _tekstGrijs,
                fontSize: 12.8,
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: Text(
              toegelaten
                  ? '${groep.posities.length} positie'
                        '${groep.posities.length == 1 ? '' : 's'} in offerte'
                  : 'Niet toegestaan voor deze prijsregel',
              style: TextStyle(
                color: toegelaten ? _tekstGrijs : _rood,
                fontSize: 10.8,
                fontWeight: FontWeight.w600,
              ),
            ),
            onChanged: toegelaten
                ? (waarde) => _wisselGroep(groep, waarde)
                : null,
          ),
          if (toegelaten) ...<Widget>[
            const Divider(height: 1, color: _rand),
            ...groep.posities.map((positie) {
              final geselecteerd = _geselecteerdeArtikelIds.contains(
                positie.artikelId,
              );

              return CheckboxListTile(
                dense: true,
                visualDensity: const VisualDensity(vertical: -2),
                value: geselecteerd,
                activeColor: _groen,
                contentPadding: const EdgeInsets.fromLTRB(26, 0, 8, 0),
                controlAffinity: ListTileControlAffinity.leading,
                title: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        positie.positieLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _bedragTekst(
                        positie.bedragVoorPrijsregel(
                          _geselecteerdePrijsregelId,
                        ),
                      ),
                      style: const TextStyle(
                        color: _groen,
                        fontSize: 11.8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  positie.artikelLabel,
                  style: const TextStyle(
                    color: _tekstGrijs,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onChanged: (waarde) {
                  _wisselPositie(groep, positie, waarde);
                },
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _bouwOverigeGroep(OfferteAlgemenePrijsregelToepassenGroep groep) {
    final toegelaten = _groepIsToegelaten(groep);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _rand),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            toegelaten ? Icons.inventory_2_outlined : Icons.block_outlined,
            color: _tekstGrijs,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              groep.label,
              style: const TextStyle(
                color: _tekstGrijs,
                fontSize: 12.2,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            toegelaten ? 'Niet in offerte' : 'Niet toegelaten',
            style: const TextStyle(
              color: _tekstGrijs,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwLegeOfferteMelding() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _rand),
      ),
      child: const Text(
        'Er zijn geen ondersteunde, actieve offerteposities om te selecteren.',
        style: TextStyle(
          color: _tekstGrijs,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _bouwSelectieSamenvatting() {
    final aantal = _geselecteerdeArtikelIds.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        border: Border(top: BorderSide(color: _rand)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.checklist_rounded, color: _groen, size: 19),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$aantal positie${aantal == 1 ? '' : 's'} geselecteerd',
              style: const TextStyle(
                color: _tekstDonker,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const Text(
                'Selectietotaal excl. btw',
                style: TextStyle(
                  color: _tekstGrijs,
                  fontSize: 10.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                _bedragTekst(_selectieTotaalExclBtw),
                style: const TextStyle(
                  color: _groen,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _wisselAlles(bool? geselecteerd) {
    setState(() {
      _geselecteerdeArtikelIds.clear();
      _explicietVolledigeGroepTypes.clear();

      if (geselecteerd == true) {
        _geselecteerdeArtikelIds.addAll(
          _beschikbarePosities.map((positie) => positie.artikelId),
        );

        for (final groep in _groepenInOfferte) {
          if (_groepIsToegelaten(groep) && groep.posities.isNotEmpty) {
            _explicietVolledigeGroepTypes.add(groep.formulierType);
          }
        }
      }
    });
  }

  void _wisselGroep(
    OfferteAlgemenePrijsregelToepassenGroep groep,
    bool? geselecteerd,
  ) {
    if (!_groepIsToegelaten(groep)) {
      return;
    }

    final ids = groep.posities.map((positie) => positie.artikelId).toSet();

    setState(() {
      if (geselecteerd == true) {
        _geselecteerdeArtikelIds.addAll(ids);

        _explicietVolledigeGroepTypes.add(groep.formulierType);
      } else {
        _geselecteerdeArtikelIds.removeAll(ids);

        _explicietVolledigeGroepTypes.remove(groep.formulierType);
      }
    });
  }

  void _wisselPositie(
    OfferteAlgemenePrijsregelToepassenGroep groep,
    OfferteAlgemenePrijsregelToepassenPositie positie,
    bool? geselecteerd,
  ) {
    setState(() {
      _explicietVolledigeGroepTypes.remove(groep.formulierType);

      if (geselecteerd == true) {
        _geselecteerdeArtikelIds.add(positie.artikelId);
      } else {
        _geselecteerdeArtikelIds.remove(positie.artikelId);
      }
    });
  }

  bool _groepIsToegelaten(OfferteAlgemenePrijsregelToepassenGroep groep) {
    return _toegelatenFormulierTypeSleutels.contains(
      _normaliseerFormulierType(groep.formulierType),
    );
  }

  bool _heleGroepGeselecteerd(OfferteAlgemenePrijsregelToepassenGroep groep) {
    final ids = groep.posities.map((positie) => positie.artikelId).toSet();

    return ids.isNotEmpty && _geselecteerdeArtikelIds.containsAll(ids);
  }

  bool _deelVanGroepGeselecteerd(
    OfferteAlgemenePrijsregelToepassenGroep groep,
  ) {
    final ids = groep.posities.map((positie) => positie.artikelId).toSet();

    final geselecteerdAantal = ids
        .where(_geselecteerdeArtikelIds.contains)
        .length;

    return geselecteerdAantal > 0 && geselecteerdAantal < ids.length;
  }

  void _laadBestaandeSelectieVoorPrijsregel() {
    _geselecteerdeArtikelIds.clear();
    _explicietVolledigeGroepTypes.clear();

    for (final groep in _groepenInOfferte) {
      if (!_groepIsToegelaten(groep)) {
        continue;
      }

      for (final positie in groep.posities) {
        if (positie.isToegepastVoorPrijsregel(_geselecteerdePrijsregelId)) {
          _geselecteerdeArtikelIds.add(positie.artikelId);
        }
      }

      if (_heleGroepGeselecteerd(groep)) {
        _explicietVolledigeGroepTypes.add(groep.formulierType);
      }
    }
  }

  void _sluitVoorNieuwePrijsregel() {
    Navigator.pop(
      context,
      const OfferteAlgemenePrijsregelToepassenResultaat(
        prijsregel: null,
        artikelIds: <String>{},
        volledigeGroepFormulierTypes: <String>{},
        actie:
            OfferteAlgemenePrijsregelToepassenActie.nieuwePrijsregelToevoegen,
      ),
    );
  }

  void _sluitMetResultaat(OfferteAlgemenePrijsregelToepassenActie actie) {
    final volledigeGroepen = <String>{};

    for (final groep in _groepenInOfferte) {
      if (_explicietVolledigeGroepTypes.contains(groep.formulierType) &&
          _heleGroepGeselecteerd(groep)) {
        volledigeGroepen.add(groep.formulierType);
      }
    }

    Navigator.pop(
      context,
      OfferteAlgemenePrijsregelToepassenResultaat(
        prijsregel: _geselecteerdePrijsregel,
        artikelIds: Set<String>.unmodifiable(_geselecteerdeArtikelIds),
        volledigeGroepFormulierTypes: Set<String>.unmodifiable(
          volledigeGroepen,
        ),
        actie: actie,
      ),
    );
  }

  static String _bedragTekst(double bedrag) {
    final geldigBedrag = bedrag.isFinite && bedrag > 0.0 ? bedrag : 0.0;

    return '€ ${geldigBedrag.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  static String _normaliseerFormulierType(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }
}

class _SectieTitel extends StatelessWidget {
  const _SectieTitel({required this.titel, required this.subtitel});

  final String titel;
  final String subtitel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          titel,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitel,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 11,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
