// THIMACO-CONTROLE: PRIJSARCHITECTUUR-STAP5D4B4A-DIALOOG-ZONDER-LEGACY-CATEGORIEEN-20260814
// THIMACO-CONTROLE: PRIJSARCHITECTUUR-STAP5D4A-ANALYZERFIX-PRIJS-PER-POSITIE-SWITCH-20260814
// THIMACO-CONTROLE: PRIJSARCHITECTUUR-OPRUIMEN-STAP5D2-EXHAUSTIEVE-DIALOG-SWITCH-20260814
// THIMACO-CONTROLE: PRIJSARCHITECTUUR-OPRUIMEN-STAP5C-DIALOG-ZONDER-VERDEELKOST-20260814
// THIMACO-CONTROLE: CENTRALE-TECHNISCHE-KEUZESLEUTELS-FASE-7-COMPILEFIX-20260727
// THIMACO-CONTROLE: TECHNISCHE-KEUZE-VOORAF-GESELECTEERD-20260726
// THIMACO-CONTROLE: GEDEELDE-VERDEELKOST-KEUZEMENU-20260723
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../helpers/offerte/prijzen/offerte_prijs_categorie.dart';
import '../../../helpers/offerte/prijzen/offerte_prijs_eenheid.dart';
import '../../../helpers/offerte/prijzen/offerte_prijs_uitschrijfmodus.dart';
import '../../../helpers/offerte/prijzen/offerte_prijsregel_model.dart';
import '../../../helpers/offerte/prijzen/offerte_prijsregel_weergave_service.dart';
import '../../../helpers/offerte/prijzen/offerte_technische_keuze_overeenkomst_helper.dart';
import '../../../helpers/offerte/prijzen/offerte_technische_keuze_ref.dart';
import 'offerte_technische_keuze_dropdown.dart';

class OffertePrijsregelFormulierOptie {
  const OffertePrijsregelFormulierOptie({
    required this.formulierType,
    required this.label,
  });

  final String formulierType;
  final String label;
}

Future<OffertePrijsregelModel?> toonOffertePrijsregelDialog({
  required BuildContext context,
  required OffertePrijsCategorie categorie,
  required String formulierType,
  required int volgendeVolgorde,
  List<OfferteTechnischeKeuzeRef> technischeKeuzes =
      const <OfferteTechnischeKeuzeRef>[],
  OfferteTechnischeKeuzeRef? beginTechnischeKeuze,
  bool technischeKeuzeVergrendeld = false,
  List<OffertePrijsregelFormulierOptie> formulierTypeOpties =
      const <OffertePrijsregelFormulierOptie>[],
  OffertePrijsregelModel? bestaandePrijsregel,
  String bevestigKnopTekst = 'Bewaren',
  IconData bevestigKnopIcoon = Icons.save_outlined,
}) {
  return showDialog<OffertePrijsregelModel>(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return _OffertePrijsregelDialog(
        categorie: categorie,
        formulierType: formulierType,
        volgendeVolgorde: volgendeVolgorde,
        technischeKeuzes: technischeKeuzes,
        beginTechnischeKeuze: beginTechnischeKeuze,
        technischeKeuzeVergrendeld: technischeKeuzeVergrendeld,
        formulierTypeOpties: formulierTypeOpties,
        bestaandePrijsregel: bestaandePrijsregel,
        bevestigKnopTekst: bevestigKnopTekst,
        bevestigKnopIcoon: bevestigKnopIcoon,
      );
    },
  );
}

class _OffertePrijsregelDialog extends StatefulWidget {
  const _OffertePrijsregelDialog({
    required this.categorie,
    required this.formulierType,
    required this.volgendeVolgorde,
    required this.technischeKeuzes,
    required this.formulierTypeOpties,
    required this.bevestigKnopTekst,
    required this.bevestigKnopIcoon,
    required this.technischeKeuzeVergrendeld,
    this.beginTechnischeKeuze,
    this.bestaandePrijsregel,
  });

  final OffertePrijsCategorie categorie;
  final String formulierType;
  final int volgendeVolgorde;
  final List<OfferteTechnischeKeuzeRef> technischeKeuzes;
  final OfferteTechnischeKeuzeRef? beginTechnischeKeuze;
  final bool technischeKeuzeVergrendeld;
  final List<OffertePrijsregelFormulierOptie> formulierTypeOpties;
  final OffertePrijsregelModel? bestaandePrijsregel;
  final String bevestigKnopTekst;
  final IconData bevestigKnopIcoon;

  @override
  State<_OffertePrijsregelDialog> createState() {
    return _OffertePrijsregelDialogState();
  }
}

class _OffertePrijsregelDialogState extends State<_OffertePrijsregelDialog> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstGrijs = Color(0xFF6B7280);
  static const Color _rood = Color(0xFFDC2626);
  static const Color _oranje = Color(0xFFF15A24);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _omschrijvingController;
  late final TextEditingController _prijsController;

  late final FocusNode _prijsFocusNode;

  late String _formulierType;
  late OffertePrijsEenheid _eenheid;
  late OffertePrijsUitschrijfmodus _uitschrijfmodus;
  late bool _actief;

  OfferteTechnischeKeuzeRef? _technischeKeuze;
  bool _technischeKeuzeFout = false;

  bool get _toonFormulierTypeKeuze {
    return widget.formulierTypeOpties.length > 1;
  }

  List<OffertePrijsregelFormulierOptie> get _formulierTypeOpties {
    return widget.formulierTypeOpties;
  }

  bool get _isTechnischePrijs {
    return widget.categorie == OffertePrijsCategorie.technischeKeuzePerArtikel;
  }

  List<OffertePrijsUitschrijfmodus> get _beschikbareUitschrijfmodi {
    if (_isTechnischePrijs) {
      return const <OffertePrijsUitschrijfmodus>[
        OffertePrijsUitschrijfmodus.overzichtEnOfferteMetPrijs,
        OffertePrijsUitschrijfmodus.invullenEnOfferteZonderPrijs,
        OffertePrijsUitschrijfmodus.alleenOverzicht,
        OffertePrijsUitschrijfmodus.optie,
      ];
    }

    return const <OffertePrijsUitschrijfmodus>[
      OffertePrijsUitschrijfmodus.overzichtEnOfferteMetPrijs,
      OffertePrijsUitschrijfmodus.invullenEnOfferteZonderPrijs,
      OffertePrijsUitschrijfmodus.alleenOverzicht,
      OffertePrijsUitschrijfmodus.optie,
    ];
  }

  @override
  void initState() {
    super.initState();

    final bestaand = widget.bestaandePrijsregel;

    _formulierType = _bepaalBeginFormulierType(
      bestaand?.formulierType ?? widget.formulierType,
    );

    _omschrijvingController = TextEditingController(
      text: bestaand?.omschrijving ?? '',
    );

    _prijsController = TextEditingController(
      text: bestaand == null ? '' : _bedragTekst(bestaand.prijsExclBtw),
    );

    _prijsFocusNode = FocusNode()..addListener(_verwerkPrijsFocus);

    _eenheid = bestaand?.eenheid ?? OffertePrijsEenheid.vast;

    _uitschrijfmodus =
        bestaand?.uitschrijfmodus ??
        _standaardUitschrijfmodus(widget.categorie);

    if (!_beschikbareUitschrijfmodi.contains(_uitschrijfmodus)) {
      _uitschrijfmodus = _standaardUitschrijfmodus(widget.categorie);
    }

    _actief = bestaand?.actief ?? true;

    _technischeKeuze = _vindActueleTechnischeKeuze(
      bestaand?.technischeKeuze ?? widget.beginTechnischeKeuze,
    );

    if (_isTechnischePrijs && _technischeKeuze != null) {
      final tekst = _technischeKeuze!.hoeUitschrijven.trim();

      if (tekst.isNotEmpty) {
        _omschrijvingController.text = tekst;
      }
    }
  }

  String _bepaalBeginFormulierType(String voorkeur) {
    final genormaliseerdeVoorkeur = _normaliseerFormulierType(voorkeur);

    for (final optie in _formulierTypeOpties) {
      if (_normaliseerFormulierType(optie.formulierType) ==
          genormaliseerdeVoorkeur) {
        return optie.formulierType;
      }
    }

    if (_formulierTypeOpties.isNotEmpty) {
      return _formulierTypeOpties.first.formulierType;
    }

    return voorkeur.trim();
  }

  OfferteTechnischeKeuzeRef? _vindActueleTechnischeKeuze(
    OfferteTechnischeKeuzeRef? bestaandeKeuze,
  ) {
    if (bestaandeKeuze == null) {
      return null;
    }

    for (final keuze in widget.technischeKeuzes) {
      if (OfferteTechnischeKeuzeOvereenkomstHelper.zijnLokaalExact(
        bestaandeKeuze,
        keuze,
      )) {
        return keuze;
      }
    }

    return bestaandeKeuze;
  }

  @override
  void dispose() {
    _prijsFocusNode
      ..removeListener(_verwerkPrijsFocus)
      ..dispose();

    _omschrijvingController.dispose();
    _prijsController.dispose();

    super.dispose();
  }

  void _verwerkPrijsFocus() {
    _formatteerBedragController(_prijsController, _prijsFocusNode);
  }

  void _formatteerBedragController(
    TextEditingController controller,
    FocusNode focusNode,
  ) {
    if (focusNode.hasFocus) {
      return;
    }

    final bedrag = _leesBedrag(controller.text);
    if (bedrag == null) {
      return;
    }

    controller.text = _bedragTekst(bedrag);
  }

  @override
  Widget build(BuildContext context) {
    final titel = widget.bestaandePrijsregel == null
        ? 'Prijsregel toevoegen'
        : 'Prijsregel wijzigen';

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
              color: const Color(0xFFE7F6EC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.euro_rounded, color: _groen, size: 21),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  titel,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.categorie.benaming,
                  style: const TextStyle(
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
        width: 560,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _bouwUitleg(),
                const SizedBox(height: 14),
                if (_toonFormulierTypeKeuze) ...<Widget>[
                  _bouwFormulierTypeKeuze(),
                  const SizedBox(height: 12),
                ],
                _bouwOmschrijvingVeld(),
                if (_isTechnischePrijs) ...<Widget>[
                  const SizedBox(height: 12),
                  _bouwTechnischeKeuze(),
                ],
                const SizedBox(height: 12),
                _bouwPrijsEnEenheid(),
                const SizedBox(height: 12),
                _bouwUitschrijfmodus(),
                const SizedBox(height: 8),
                _bouwUitschrijfUitleg(),
                const SizedBox(height: 10),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _actief,
                  activeThumbColor: _groen,
                  title: const Text(
                    'Prijsregel actief',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text(
                    'Een inactieve regel blijft bewaard, maar wordt niet berekend.',
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
          icon: Icon(widget.bevestigKnopIcoon, size: 18),
          label: Text(widget.bevestigKnopTekst),
        ),
      ],
    );
  }

  Widget _bouwFormulierTypeKeuze() {
    return DropdownButtonFormField<String>(
      key: ValueKey<String>(_formulierType),
      initialValue: _formulierType,
      isExpanded: true,
      decoration: _invoerDecoratie(label: 'Artikelgroep'),
      items: _formulierTypeOpties
          .map((optie) {
            return DropdownMenuItem<String>(
              value: optie.formulierType,
              child: Text(
                optie.label,
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
          _formulierType = waarde;
        });
      },
    );
  }

  Widget _bouwOmschrijvingVeld() {
    return TextFormField(
      controller: _omschrijvingController,
      autofocus: !_isTechnischePrijs,
      readOnly: _isTechnischePrijs,
      textCapitalization: TextCapitalization.sentences,
      decoration: _invoerDecoratie(
        label: _isTechnischePrijs
            ? 'Hoe uitschrijven — uit technische keuze'
            : 'Naam prijsregel',
        hint: _isTechnischePrijs
            ? 'Wordt automatisch overgenomen van de technische keuze'
            : 'Bijvoorbeeld: Petscreen toeslag',
      ),
      validator: _valideerOmschrijving,
    );
  }

  Widget _bouwTechnischeKeuze() {
    final technischeKeuze = _technischeKeuze;

    if (widget.technischeKeuzeVergrendeld && technischeKeuze != null) {
      final pad = <String>[
        technischeKeuze.menuTitelMomentopname.trim(),
        technischeKeuze.submenuTitelMomentopname.trim(),
        technischeKeuze.keuzeTitelMomentopname.trim(),
      ].where((deel) => deel.isNotEmpty).join(' · ');

      return Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(Icons.link_rounded, color: _groen, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Gekoppelde technische keuze',
                    style: TextStyle(
                      color: _groen,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    pad.isEmpty ? technischeKeuze.hoeUitschrijven : pad,
                    style: const TextStyle(
                      color: Color(0xFF166534),
                      fontSize: 11.5,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return OfferteTechnischeKeuzeDropdown(
      keuzes: widget.technischeKeuzes,
      waarde: _technischeKeuze,
      toonFout: _technischeKeuzeFout,
      onChanged: (keuze) {
        setState(() {
          _technischeKeuze = keuze;
          _technischeKeuzeFout = false;

          final tekst = keuze?.hoeUitschrijven.trim() ?? '';
          if (tekst.isNotEmpty) {
            _omschrijvingController.value = TextEditingValue(
              text: tekst,
              selection: TextSelection.collapsed(offset: tekst.length),
            );
          }
        });
      },
    );
  }

  Widget _bouwPrijsEnEenheid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final breed = constraints.maxWidth >= 470;

        final prijsVeld = TextFormField(
          controller: _prijsController,
          focusNode: _prijsFocusNode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: const <TextInputFormatter>[_BedragInputFormatter()],
          decoration: _invoerDecoratie(
            label: 'Prijs excl. btw',
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

        final eenheidVeld = DropdownButtonFormField<OffertePrijsEenheid>(
          key: ValueKey<OffertePrijsEenheid>(_eenheid),
          initialValue: _eenheid,
          isExpanded: true,
          decoration: _invoerDecoratie(label: 'Berekeningswijze'),
          items: OffertePrijsEenheid.values
              .map((eenheid) {
                return DropdownMenuItem<OffertePrijsEenheid>(
                  value: eenheid,
                  child: Text(
                    eenheid.benaming,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

        if (breed) {
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

  Widget _bouwUitschrijfmodus() {
    return DropdownButtonFormField<OffertePrijsUitschrijfmodus>(
      key: ValueKey<OffertePrijsUitschrijfmodus>(_uitschrijfmodus),
      initialValue: _uitschrijfmodus,
      isExpanded: true,
      decoration: _invoerDecoratie(label: 'Hoe uitschrijven'),
      items: _beschikbareUitschrijfmodi
          .map((modus) {
            return DropdownMenuItem<OffertePrijsUitschrijfmodus>(
              value: modus,
              child: Row(
                children: <Widget>[
                  Icon(
                    _icoonVoorUitschrijfmodus(modus),
                    size: 19,
                    color: _kleurVoorUitschrijfmodus(modus),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      OffertePrijsregelWeergaveService.benamingVoorUitschrijfmodus(
                        modus,
                      ),
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
        });
      },
    );
  }

  IconData _icoonVoorUitschrijfmodus(OffertePrijsUitschrijfmodus modus) {
    return switch (modus) {
      OffertePrijsUitschrijfmodus.overzichtEnOfferteMetPrijs =>
        Icons.visibility_outlined,
      OffertePrijsUitschrijfmodus.invullenEnOfferteMetPrijs =>
        Icons.visibility_outlined,
      OffertePrijsUitschrijfmodus.invullenEnOfferteZonderPrijs =>
        Icons.edit_note_rounded,
      OffertePrijsUitschrijfmodus.alleenOverzicht =>
        Icons.visibility_off_outlined,
      OffertePrijsUitschrijfmodus.optie => Icons.do_not_disturb_alt_outlined,
    };
  }

  Color _kleurVoorUitschrijfmodus(OffertePrijsUitschrijfmodus modus) {
    if (modus.isOptie) {
      return _oranje;
    }

    return _groen;
  }

  Widget _bouwUitschrijfUitleg() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rand),
      ),
      child: Column(
        children: <Widget>[
          _bouwUitschrijfInfoRegel(
            icoon: Icons.dashboard_outlined,
            label: 'Overzicht',
            waarde: _uitschrijfmodus.overzichtUitleg,
            kleur: _groen,
          ),
          const SizedBox(height: 7),
          _bouwUitschrijfInfoRegel(
            icoon: _uitschrijfmodus.toonOmschrijvingOpOfferte
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            label: 'Offerte',
            waarde: _uitschrijfmodus.offerteUitleg,
            kleur: _uitschrijfmodus.toonOmschrijvingOpOfferte
                ? _groen
                : _tekstGrijs,
          ),
          const SizedBox(height: 7),
          _bouwUitschrijfInfoRegel(
            icoon: _uitschrijfmodus.teltMeeInEindtotaal
                ? Icons.check_circle_outline
                : Icons.do_not_disturb_alt_outlined,
            label: 'Eindtotaal',
            waarde: _uitschrijfmodus.totaalUitleg,
            kleur: _uitschrijfmodus.teltMeeInEindtotaal ? _groen : _rood,
            benadrukt: true,
          ),
        ],
      ),
    );
  }

  Widget _bouwUitschrijfInfoRegel({
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
              color: benadrukt ? kleur : const Color(0xFF111827),
              fontSize: 11.2,
              height: 1.25,
              fontWeight: benadrukt ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _bouwUitleg() {
    final tekst = switch (widget.categorie) {
      OffertePrijsCategorie.technischeKeuzePerArtikel =>
        'Deze prijsregel wordt automatisch toegepast wanneer '
            'de gekoppelde technische keuze in het artikel voorkomt.',
      OffertePrijsCategorie.prijsPerPositie =>
        'Prijs per positie wordt rechtstreeks op de gekozen positie beheerd.',
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rand),
      ),
      child: Text(
        tekst,
        style: const TextStyle(
          color: _tekstGrijs,
          fontSize: 12,
          height: 1.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
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

  String? _valideerOmschrijving(String? waarde) {
    if (waarde == null || waarde.trim().isEmpty) {
      return _isTechnischePrijs
          ? 'Vul in hoe deze prijsregel moet worden uitgeschreven.'
          : 'Vul een naam voor de prijsregel in.';
    }

    return null;
  }

  void _bewaar() {
    final formulierGeldig = _formKey.currentState?.validate() ?? false;

    final technischeKeuzeGeldig =
        !_isTechnischePrijs ||
        (_technischeKeuze != null && !_technischeKeuze!.isLeeg);

    if (!technischeKeuzeGeldig) {
      setState(() {
        _technischeKeuzeFout = true;
      });
    }

    if (!formulierGeldig || !technischeKeuzeGeldig) {
      return;
    }

    final bestaand = widget.bestaandePrijsregel;
    final nu = DateTime.now().toUtc().toIso8601String();

    final id = _bepaalPrijsregelId(bestaand: bestaand);

    final prijsregel = OffertePrijsregelModel(
      id: id,
      categorie: widget.categorie,
      formulierType: _formulierType,
      omschrijving: _isTechnischePrijs
          ? _technischeKeuze!.hoeUitschrijven
          : _omschrijvingController.text,
      prijsExclBtw: _leesBedrag(_prijsController.text) ?? 0,
      eenheid: _eenheid,
      uitschrijfmodus: _uitschrijfmodus,
      technischeKeuze: _isTechnischePrijs ? _technischeKeuze : null,
      actief: _actief,
      volgorde: bestaand?.volgorde ?? widget.volgendeVolgorde,
      gewijzigdOp: nu,
    );

    Navigator.pop(context, prijsregel);
  }

  String _bepaalPrijsregelId({required OffertePrijsregelModel? bestaand}) {
    return bestaand?.id ?? 'prijs_${DateTime.now().microsecondsSinceEpoch}';
  }

  static OffertePrijsUitschrijfmodus _standaardUitschrijfmodus(
    OffertePrijsCategorie categorie,
  ) {
    if (categorie == OffertePrijsCategorie.prijsPerPositie) {
      return OffertePrijsUitschrijfmodus.invullenEnOfferteMetPrijs;
    }

    return OffertePrijsUitschrijfmodus.overzichtEnOfferteMetPrijs;
  }

  static String _normaliseerFormulierType(String waarde) {
    return waarde.trim().toLowerCase().replaceAll('_', '').replaceAll(' ', '');
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
