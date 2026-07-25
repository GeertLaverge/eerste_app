import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../helpers/offerte/prijzen/offerte_algemene_prijsregel_model.dart';
import '../../../helpers/offerte/prijzen/offerte_artikel_prijs_koppeling_service.dart';
import '../../../helpers/offerte/prijzen/offerte_prijs_eenheid.dart';
import '../../../helpers/offerte/prijzen/offerte_prijs_uitschrijfmodus.dart';

Future<OfferteAlgemenePrijsregelModel?> toonOfferteAlgemenePrijsregelDialog({
  required BuildContext context,
  required int volgendeVolgorde,
  OfferteAlgemenePrijsregelModel? bestaandePrijsregel,
}) {
  return showDialog<OfferteAlgemenePrijsregelModel>(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return _OfferteAlgemenePrijsregelDialog(
        volgendeVolgorde: volgendeVolgorde,
        bestaandePrijsregel: bestaandePrijsregel,
      );
    },
  );
}

enum _AlgemenePrijssoort { vast, berekend }

class _ArtikelTypeOptie {
  const _ArtikelTypeOptie({required this.formulierType, required this.label});

  final String formulierType;
  final String label;
}

class _OfferteAlgemenePrijsregelDialog extends StatefulWidget {
  const _OfferteAlgemenePrijsregelDialog({
    required this.volgendeVolgorde,
    this.bestaandePrijsregel,
  });

  final int volgendeVolgorde;
  final OfferteAlgemenePrijsregelModel? bestaandePrijsregel;

  @override
  State<_OfferteAlgemenePrijsregelDialog> createState() {
    return _OfferteAlgemenePrijsregelDialogState();
  }
}

class _OfferteAlgemenePrijsregelDialogState
    extends State<_OfferteAlgemenePrijsregelDialog> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);
  static const Color _rood = Color(0xFFDC2626);
  static const Color _blauw = Color(0xFF2563EB);

  static const List<OffertePrijsUitschrijfmodus> _uitschrijfmodi =
      <OffertePrijsUitschrijfmodus>[
        OffertePrijsUitschrijfmodus.overzichtEnOfferteMetPrijs,
        OffertePrijsUitschrijfmodus.invullenEnOfferteZonderPrijs,
        OffertePrijsUitschrijfmodus.alleenOverzicht,
        OffertePrijsUitschrijfmodus.verdelenOverArtikelenAlleenOverzicht,
      ];

  static const List<OffertePrijsEenheid> _berekendeEenheden =
      <OffertePrijsEenheid>[
        OffertePrijsEenheid.eenBreedte,
        OffertePrijsEenheid.tweeBreedtes,
        OffertePrijsEenheid.eenHoogte,
        OffertePrijsEenheid.tweeHoogtes,
        OffertePrijsEenheid.eenBreedteTweeHoogtes,
        OffertePrijsEenheid.omtrek,
        OffertePrijsEenheid.oppervlakte,
      ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _omschrijvingController;
  late final TextEditingController _prijsController;
  late final TextEditingController _maximaleTotaleStukprijsController;

  late final FocusNode _prijsFocusNode;
  late final FocusNode _maximaleTotaleStukprijsFocusNode;

  late final List<_ArtikelTypeOptie> _artikelTypeOpties;
  late Set<String> _geselecteerdeFormulierTypes;

  late _AlgemenePrijssoort _prijssoort;
  late OffertePrijsEenheid _eenheid;
  late OffertePrijsUitschrijfmodus _uitschrijfmodus;

  late bool _altijdToepassenAlsArtikelInGebruik;
  late bool _actief;

  bool _toonArtikelSelectieFout = false;

  bool get _isVerdeeldePrijs {
    return _uitschrijfmodus.isVerdeeldeInterneKost;
  }

  @override
  void initState() {
    super.initState();

    final bestaand = widget.bestaandePrijsregel;

    _omschrijvingController = TextEditingController(
      text: bestaand?.omschrijving ?? '',
    );

    _prijsController = TextEditingController(
      text: bestaand == null ? '' : _bedragTekst(bestaand.prijsExclBtw),
    );

    _maximaleTotaleStukprijsController = TextEditingController(
      text: bestaand == null || bestaand.maximaleTotaleStukprijs <= 0
          ? ''
          : _bedragTekst(bestaand.maximaleTotaleStukprijs),
    );

    _prijsFocusNode = FocusNode()..addListener(_verwerkPrijsFocus);

    _maximaleTotaleStukprijsFocusNode = FocusNode()
      ..addListener(_verwerkMaximaleTotaleStukprijsFocus);

    _eenheid = bestaand?.eenheid ?? OffertePrijsEenheid.vast;

    _prijssoort = _eenheid == OffertePrijsEenheid.vast
        ? _AlgemenePrijssoort.vast
        : _AlgemenePrijssoort.berekend;

    _uitschrijfmodus =
        bestaand?.uitschrijfmodus ??
        OffertePrijsUitschrijfmodus.overzichtEnOfferteMetPrijs;

    if (!_uitschrijfmodi.contains(_uitschrijfmodus)) {
      _uitschrijfmodus = OffertePrijsUitschrijfmodus.overzichtEnOfferteMetPrijs;
    }

    if (_isVerdeeldePrijs) {
      _prijssoort = _AlgemenePrijssoort.vast;
      _eenheid = OffertePrijsEenheid.vast;
    } else if (_prijssoort == _AlgemenePrijssoort.berekend &&
        !_berekendeEenheden.contains(_eenheid)) {
      _eenheid = OffertePrijsEenheid.eenHoogte;
    }

    _altijdToepassenAlsArtikelInGebruik =
        bestaand?.altijdToepassenAlsArtikelInGebruik ?? false;

    _actief = bestaand?.actief ?? true;

    _artikelTypeOpties = _bouwArtikelTypeOpties(
      bestaandeFormulierTypes:
          bestaand?.toepasselijkeFormulierTypes ?? const <String>[],
    );

    final bestaandeSelectie =
        bestaand?.toepasselijkeFormulierTypes ?? const <String>[];

    _geselecteerdeFormulierTypes = bestaandeSelectie.isEmpty
        ? _artikelTypeOpties.map((optie) => optie.formulierType).toSet()
        : bestaandeSelectie
              .map((waarde) => waarde.trim())
              .where((waarde) => waarde.isNotEmpty)
              .toSet();
  }

  @override
  void dispose() {
    _prijsFocusNode
      ..removeListener(_verwerkPrijsFocus)
      ..dispose();

    _maximaleTotaleStukprijsFocusNode
      ..removeListener(_verwerkMaximaleTotaleStukprijsFocus)
      ..dispose();

    _omschrijvingController.dispose();
    _prijsController.dispose();
    _maximaleTotaleStukprijsController.dispose();

    super.dispose();
  }

  void _verwerkPrijsFocus() {
    if (_prijsFocusNode.hasFocus) {
      return;
    }

    final bedrag = _leesBedrag(_prijsController.text);

    if (bedrag == null) {
      return;
    }

    _prijsController.text = _bedragTekst(bedrag);
  }

  void _verwerkMaximaleTotaleStukprijsFocus() {
    if (_maximaleTotaleStukprijsFocusNode.hasFocus) {
      return;
    }

    final tekst = _maximaleTotaleStukprijsController.text.trim();

    if (tekst.isEmpty) {
      return;
    }

    final bedrag = _leesBedrag(tekst);

    if (bedrag == null) {
      return;
    }

    _maximaleTotaleStukprijsController.text = _bedragTekst(bedrag);
  }

  @override
  Widget build(BuildContext context) {
    final isWijzigen = widget.bestaandePrijsregel != null;

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(22, 20, 18, 0),
      contentPadding: const EdgeInsets.fromLTRB(22, 16, 22, 4),
      actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _lichtGroen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: _groen,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  isWijzigen
                      ? 'Algemene prijsregel wijzigen'
                      : 'Algemene prijsregel toevoegen',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Onafhankelijk van één artikelprijsprofiel',
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
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      content: SizedBox(
        width: 610,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _bouwUitleg(),
                const SizedBox(height: 14),
                _bouwOmschrijvingVeld(),
                const SizedBox(height: 12),
                _bouwPrijssoort(),
                const SizedBox(height: 12),
                _bouwPrijsEnBerekening(),
                if (_isVerdeeldePrijs) ...<Widget>[
                  const SizedBox(height: 12),
                  _bouwMaximaleTotaleStukprijs(),
                ],
                const SizedBox(height: 12),
                _bouwUitschrijfmodus(),
                const SizedBox(height: 8),
                _bouwUitschrijfUitleg(),
                const SizedBox(height: 14),
                _bouwArtikelTypeSelectie(),
                const SizedBox(height: 10),
                _bouwAutomatischToepassen(),
                const SizedBox(height: 2),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _actief,
                  activeThumbColor: _groen,
                  title: const Text(
                    'Prijsregel actief',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text(
                    'Een inactieve regel blijft bewaard, maar kan niet op '
                    'een offerte worden toegepast.',
                    style: TextStyle(fontSize: 11.5),
                  ),
                  onChanged: (waarde) {
                    setState(() {
                      _actief = waarde;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuleren'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: _groen),
          onPressed: _bewaar,
          icon: const Icon(Icons.save_outlined, size: 18),
          label: const Text('Bewaren'),
        ),
      ],
    );
  }

  Widget _bouwUitleg() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rand),
      ),
      child: const Text(
        'Deze regel wordt centraal beheerd. U kiest hier de berekening, '
        'de weergave op de offerte en de artikeltypes waarop de regel mag '
        'worden toegepast.',
        style: TextStyle(
          color: _tekstGrijs,
          fontSize: 12,
          height: 1.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _bouwOmschrijvingVeld() {
    return TextFormField(
      controller: _omschrijvingController,
      autofocus: widget.bestaandePrijsregel == null,
      textCapitalization: TextCapitalization.sentences,
      decoration: _invoerDecoratie(
        label: 'Omschrijving',
        hint: 'Bijvoorbeeld: Transportkost',
      ),
      validator: (waarde) {
        if (waarde == null || waarde.trim().isEmpty) {
          return 'Vul een omschrijving in.';
        }

        return null;
      },
    );
  }

  Widget _bouwPrijssoort() {
    final verdeeldePrijs = _isVerdeeldePrijs;

    return DropdownButtonFormField<_AlgemenePrijssoort>(
      key: ValueKey<String>('prijssoort_${_prijssoort.name}_$verdeeldePrijs'),
      initialValue: verdeeldePrijs ? _AlgemenePrijssoort.vast : _prijssoort,
      isExpanded: true,
      decoration: _invoerDecoratie(label: 'Soort prijs'),
      items: const <DropdownMenuItem<_AlgemenePrijssoort>>[
        DropdownMenuItem<_AlgemenePrijssoort>(
          value: _AlgemenePrijssoort.vast,
          child: Text(
            'Vaste prijs',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        DropdownMenuItem<_AlgemenePrijssoort>(
          value: _AlgemenePrijssoort.berekend,
          child: Text(
            'Berekenen volgens artikelmaten',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
      onChanged: verdeeldePrijs
          ? null
          : (waarde) {
              if (waarde == null) {
                return;
              }

              setState(() {
                _prijssoort = waarde;

                _eenheid = waarde == _AlgemenePrijssoort.vast
                    ? OffertePrijsEenheid.vast
                    : OffertePrijsEenheid.eenHoogte;
              });
            },
    );
  }

  Widget _bouwPrijsEnBerekening() {
    final prijsVeld = TextFormField(
      controller: _prijsController,
      focusNode: _prijsFocusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: const <TextInputFormatter>[_BedragInputFormatter()],
      decoration: _invoerDecoratie(
        label: _isVerdeeldePrijs
            ? 'Totaalbedrag te verdelen — excl. btw'
            : _prijssoort == _AlgemenePrijssoort.vast
            ? 'Vaste prijs excl. btw'
            : 'Prijs per berekende eenheid excl. btw',
        hint: '0,00',
        prefixText: '€ ',
      ),
      validator: (waarde) {
        if (_leesBedrag(waarde ?? '') == null) {
          return 'Vul een geldig bedrag in.';
        }

        return null;
      },
    );

    if (_isVerdeeldePrijs || _prijssoort == _AlgemenePrijssoort.vast) {
      return _bouwPrijsVeldMetUitleg(
        prijsVeld,
        _isVerdeeldePrijs
            ? 'Dit vaste totaalbedrag wordt over de geselecteerde '
                  'offerteposities verdeeld.'
            : 'De vaste prijs wordt volgens de gekozen posities toegepast.',
      );
    }

    final eenheidVeld = DropdownButtonFormField<OffertePrijsEenheid>(
      key: ValueKey<OffertePrijsEenheid>(_eenheid),
      initialValue: _eenheid,
      isExpanded: true,
      decoration: _invoerDecoratie(label: 'Berekeningswijze'),
      items: _berekendeEenheden
          .map((eenheid) {
            return DropdownMenuItem<OffertePrijsEenheid>(
              value: eenheid,
              child: Text(
                '${eenheid.benaming} · '
                '${eenheid.formuleBenaming}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            );
          })
          .toList(growable: false),
      onChanged: (waarde) {
        if (waarde == null) {
          return;
        }

        setState(() {
          _eenheid = waarde;
        });
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 500) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: prijsVeld),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: eenheidVeld),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            prijsVeld,
            const SizedBox(height: 12),
            eenheidVeld,
          ],
        );
      },
    );
  }

  Widget _bouwMaximaleTotaleStukprijs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextFormField(
          controller: _maximaleTotaleStukprijsController,
          focusNode: _maximaleTotaleStukprijsFocusNode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: const <TextInputFormatter>[_BedragInputFormatter()],
          decoration: _invoerDecoratie(
            label: 'Maximum totale artikelwaarde',
            hint: '0,00',
            prefixText: '€ ',
          ),
          validator: (waarde) {
            if (!_isVerdeeldePrijs) {
              return null;
            }

            final tekst = waarde?.trim() ?? '';

            if (tekst.isEmpty) {
              return null;
            }

            if (_leesBedrag(tekst) == null) {
              return 'Vul een geldig maximumbedrag in.';
            }

            return null;
          },
        ),
        const SizedBox(height: 6),
        const Text(
          'De grens wordt uitsluitend berekend op basis van de ingevulde '
          'stukprijs × het aantal van de geselecteerde artikelen. '
          'Technische prijsregels, vrije prijsregels, andere algemene regels, '
          'verdeelde kosten, winst en korting tellen niet mee. '
          'Bij € 0,00 geldt geen bovengrens.',
          style: TextStyle(
            color: _tekstGrijs,
            fontSize: 10.8,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _bouwPrijsVeldMetUitleg(Widget prijsVeld, String uitleg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        prijsVeld,
        const SizedBox(height: 6),
        Text(
          uitleg,
          style: const TextStyle(
            color: _tekstGrijs,
            fontSize: 10.8,
            height: 1.3,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _bouwUitschrijfmodus() {
    return DropdownButtonFormField<OffertePrijsUitschrijfmodus>(
      key: ValueKey<OffertePrijsUitschrijfmodus>(_uitschrijfmodus),
      initialValue: _uitschrijfmodus,
      isExpanded: true,
      decoration: _invoerDecoratie(label: 'Hoe uitschrijven'),
      items: _uitschrijfmodi
          .map((modus) {
            return DropdownMenuItem<OffertePrijsUitschrijfmodus>(
              value: modus,
              child: Row(
                children: <Widget>[
                  Icon(
                    _icoonVoorUitschrijfmodus(modus),
                    color: _kleurVoorUitschrijfmodus(modus),
                    size: 19,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _benamingVoorUitschrijfmodus(modus),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            );
          })
          .toList(growable: false),
      onChanged: (waarde) {
        if (waarde == null) {
          return;
        }

        setState(() {
          _uitschrijfmodus = waarde;

          if (_isVerdeeldePrijs) {
            _prijssoort = _AlgemenePrijssoort.vast;
            _eenheid = OffertePrijsEenheid.vast;
          } else {
            _maximaleTotaleStukprijsController.clear();
          }
        });
      },
    );
  }

  Widget _bouwUitschrijfUitleg() {
    final toontOmschrijving = _uitschrijfmodus.toonOmschrijvingOpOfferte;

    final toontPrijs = _uitschrijfmodus.toonPrijsOpOfferte;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rand),
      ),
      child: Column(
        children: <Widget>[
          _bouwInfoRegel(
            icoon: Icons.dashboard_outlined,
            label: 'Overzicht',
            waarde: _isVerdeeldePrijs
                ? 'Berekend, uitgeschreven en per positie verdeeld'
                : 'Berekend en uitgeschreven',
            kleur: _groen,
          ),
          const SizedBox(height: 7),
          _bouwInfoRegel(
            icoon: toontOmschrijving
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            label: 'Offerte',
            waarde: toontOmschrijving
                ? toontPrijs
                      ? 'Omschrijving en prijs zichtbaar'
                      : 'Alleen omschrijving zichtbaar'
                : 'Niet zichtbaar',
            kleur: toontOmschrijving ? _groen : _tekstGrijs,
          ),
          const SizedBox(height: 7),
          _bouwInfoRegel(
            icoon: Icons.check_circle_outline,
            label: 'Eindtotaal',
            waarde: 'Wel meegerekend',
            kleur: _groen,
            benadrukt: true,
          ),
        ],
      ),
    );
  }

  Widget _bouwArtikelTypeSelectie() {
    final allesGeselecteerd =
        _geselecteerdeFormulierTypes.length == _artikelTypeOpties.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _toonArtikelSelectieFout ? _rood : _rand,
          width: _toonArtikelSelectieFout ? 1.3 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Toepassen op artikeltypes',
                  style: TextStyle(
                    color: _tekstDonker,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _geselecteerdeFormulierTypes = allesGeselecteerd
                        ? <String>{}
                        : _artikelTypeOpties
                              .map((optie) => optie.formulierType)
                              .toSet();

                    _toonArtikelSelectieFout = false;
                  });
                },
                child: Text(
                  allesGeselecteerd ? 'Alles wissen' : 'Alles selecteren',
                ),
              ),
            ],
          ),
          const Text(
            'Hier kiest u welke soorten artikelen deze prijsregel mogen '
            'gebruiken.',
            style: TextStyle(
              color: _tekstGrijs,
              fontSize: 10.8,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          ..._artikelTypeOpties.map((optie) {
            final geselecteerd = _isFormulierTypeGeselecteerd(
              optie.formulierType,
            );

            return CheckboxListTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: -3),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: geselecteerd,
              activeColor: _groen,
              title: Text(
                optie.label,
                style: const TextStyle(
                  fontSize: 12.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onChanged: (waarde) {
                setState(() {
                  _zetFormulierTypeGeselecteerd(
                    optie.formulierType,
                    waarde == true,
                  );

                  _toonArtikelSelectieFout = false;
                });
              },
            );
          }),
          if (_toonArtikelSelectieFout)
            const Padding(
              padding: EdgeInsets.only(top: 4, left: 2),
              child: Text(
                'Selecteer minstens één artikeltype.',
                style: TextStyle(
                  color: _rood,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _bouwAutomatischToepassen() {
    return Container(
      decoration: BoxDecoration(
        color: _altijdToepassenAlsArtikelInGebruik ? _lichtGroen : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _altijdToepassenAlsArtikelInGebruik ? _groen : _rand,
        ),
      ),
      child: CheckboxListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        controlAffinity: ListTileControlAffinity.leading,
        value: _altijdToepassenAlsArtikelInGebruik,
        activeColor: _groen,
        title: const Text(
          'Deze prijsregel altijd toepassen als het artikel in gebruik is',
          style: TextStyle(
            color: _tekstDonker,
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: const Text(
          'De prijsregel wordt automatisch toegepast op alle actieve '
          'artikelen van de gekozen artikeltypes.',
          style: TextStyle(
            color: _tekstGrijs,
            fontSize: 10.8,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
        onChanged: (waarde) {
          setState(() {
            _altijdToepassenAlsArtikelInGebruik = waarde == true;
          });
        },
      ),
    );
  }

  Widget _bouwInfoRegel({
    required IconData icoon,
    required String label,
    required String waarde,
    required Color kleur,
    bool benadrukt = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icoon, size: 17, color: kleur),
        const SizedBox(width: 9),
        SizedBox(
          width: 76,
          child: Text(
            label,
            style: const TextStyle(
              color: _tekstGrijs,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            waarde,
            style: TextStyle(
              color: benadrukt ? kleur : _tekstDonker,
              fontSize: 11.2,
              height: 1.25,
              fontWeight: benadrukt ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  void _bewaar() {
    final formulierGeldig = _formKey.currentState?.validate() ?? false;

    final artikelSelectieGeldig = _geselecteerdeFormulierTypes.isNotEmpty;

    if (!artikelSelectieGeldig) {
      setState(() {
        _toonArtikelSelectieFout = true;
      });
    }

    if (!formulierGeldig || !artikelSelectieGeldig) {
      return;
    }

    final bestaand = widget.bestaandePrijsregel;
    final nu = DateTime.now().toUtc().toIso8601String();

    final prijsregel = OfferteAlgemenePrijsregelModel(
      id:
          bestaand?.id ??
          'algemene_prijs_'
              '${DateTime.now().microsecondsSinceEpoch}',
      omschrijving: _omschrijvingController.text,
      prijsExclBtw: _leesBedrag(_prijsController.text) ?? 0,
      eenheid: _isVerdeeldePrijs
          ? OffertePrijsEenheid.vast
          : _prijssoort == _AlgemenePrijssoort.vast
          ? OffertePrijsEenheid.vast
          : _eenheid,
      uitschrijfmodus: _uitschrijfmodus,
      toepasselijkeFormulierTypes: _artikelTypeOpties
          .where((optie) => _isFormulierTypeGeselecteerd(optie.formulierType))
          .map((optie) => optie.formulierType)
          .toList(growable: false),
      altijdToepassenAlsArtikelInGebruik: _altijdToepassenAlsArtikelInGebruik,
      maximaleTotaleStukprijs: _isVerdeeldePrijs
          ? _leesBedrag(_maximaleTotaleStukprijsController.text) ?? 0
          : 0,
      actief: _actief,
      volgorde: bestaand?.volgorde ?? widget.volgendeVolgorde,
      gewijzigdOp: nu,
    );

    Navigator.pop(context, prijsregel);
  }

  List<_ArtikelTypeOptie> _bouwArtikelTypeOpties({
    required Iterable<String> bestaandeFormulierTypes,
  }) {
    final perSleutel = <String, _ArtikelTypeOptie>{};

    for (final koppeling
        in OfferteArtikelPrijsKoppelingService.alleKoppelingen) {
      final sleutel = _normaliseerFormulierType(koppeling.formulierType);

      perSleutel[sleutel] = _ArtikelTypeOptie(
        formulierType: koppeling.formulierType,
        label: koppeling.formulierNaam,
      );
    }

    for (final formulierType in bestaandeFormulierTypes) {
      final schoon = formulierType.trim();
      final sleutel = _normaliseerFormulierType(schoon);

      if (sleutel.isEmpty || perSleutel.containsKey(sleutel)) {
        continue;
      }

      perSleutel[sleutel] = _ArtikelTypeOptie(
        formulierType: schoon,
        label: OfferteArtikelPrijsKoppelingService.formulierNaamVoor(schoon),
      );
    }

    return perSleutel.values.toList(growable: false);
  }

  bool _isFormulierTypeGeselecteerd(String formulierType) {
    final sleutel = _normaliseerFormulierType(formulierType);

    return _geselecteerdeFormulierTypes.any(
      (geselecteerd) => _normaliseerFormulierType(geselecteerd) == sleutel,
    );
  }

  void _zetFormulierTypeGeselecteerd(String formulierType, bool geselecteerd) {
    final sleutel = _normaliseerFormulierType(formulierType);

    _geselecteerdeFormulierTypes.removeWhere(
      (waarde) => _normaliseerFormulierType(waarde) == sleutel,
    );

    if (geselecteerd) {
      _geselecteerdeFormulierTypes.add(formulierType);
    }
  }

  InputDecoration _invoerDecoratie({
    required String label,
    String? hint,
    String? prefixText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefixText,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _rand),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _rand),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _groen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _rood),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _rood, width: 1.5),
      ),
    );
  }

  static String _benamingVoorUitschrijfmodus(
    OffertePrijsUitschrijfmodus modus,
  ) {
    return switch (modus) {
      OffertePrijsUitschrijfmodus.overzichtEnOfferteMetPrijs =>
        '1. Uitschrijven en prijs zichtbaar op offerte',
      OffertePrijsUitschrijfmodus.invullenEnOfferteZonderPrijs =>
        '2. Uitschrijven op offerte, prijs niet zichtbaar',
      OffertePrijsUitschrijfmodus.alleenOverzicht =>
        '3. Niet uitschrijven en niet zichtbaar',
      OffertePrijsUitschrijfmodus.verdelenOverArtikelenAlleenOverzicht =>
        '4. Prijs verdelen over geselecteerde artikelen',
      _ => modus.benaming,
    };
  }

  static IconData _icoonVoorUitschrijfmodus(OffertePrijsUitschrijfmodus modus) {
    return switch (modus) {
      OffertePrijsUitschrijfmodus.overzichtEnOfferteMetPrijs =>
        Icons.visibility_outlined,
      OffertePrijsUitschrijfmodus.invullenEnOfferteZonderPrijs =>
        Icons.edit_note_rounded,
      OffertePrijsUitschrijfmodus.alleenOverzicht =>
        Icons.visibility_off_outlined,
      OffertePrijsUitschrijfmodus.verdelenOverArtikelenAlleenOverzicht =>
        Icons.account_tree_outlined,
      _ => Icons.rule_outlined,
    };
  }

  static Color _kleurVoorUitschrijfmodus(OffertePrijsUitschrijfmodus modus) {
    return modus.isVerdeeldeInterneKost ? _blauw : _groen;
  }

  static String _normaliseerFormulierType(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  static String _bedragTekst(double bedrag) {
    return bedrag.toStringAsFixed(2).replaceAll('.', ',');
  }

  static double? _leesBedrag(String tekst) {
    final schoon = tekst.trim().replaceAll(' ', '').replaceAll(',', '.');

    if (schoon.isEmpty) {
      return null;
    }

    final bedrag = double.tryParse(schoon);

    if (bedrag == null || !bedrag.isFinite || bedrag < 0) {
      return null;
    }

    return bedrag;
  }
}

class _BedragInputFormatter extends TextInputFormatter {
  const _BedragInputFormatter();

  static final RegExp _geldigPatroon = RegExp(r'^\d{0,9}([,.]\d{0,2})?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty || _geldigPatroon.hasMatch(newValue.text)) {
      return newValue;
    }

    return oldValue;
  }
}
