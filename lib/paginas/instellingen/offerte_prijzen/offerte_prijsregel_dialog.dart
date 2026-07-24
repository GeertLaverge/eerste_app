// THIMACO-CONTROLE: GEDEELDE-VERDEELKOST-KEUZEMENU-20260723
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../helpers/offerte/prijzen/offerte_prijs_categorie.dart';
import '../../../helpers/offerte/prijzen/offerte_prijs_eenheid.dart';
import '../../../helpers/offerte/prijzen/offerte_prijs_uitschrijfmodus.dart';
import '../../../helpers/offerte/prijzen/offerte_prijs_verdeel_limietmodus.dart';
import '../../../helpers/offerte/prijzen/offerte_prijsregel_model.dart';
import '../../../helpers/offerte/prijzen/offerte_prijsregel_weergave_service.dart';
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
  List<OffertePrijsregelFormulierOptie> formulierTypeOpties =
      const <OffertePrijsregelFormulierOptie>[],
  List<OffertePrijsregelModel> verdeelgroepOpties =
      const <OffertePrijsregelModel>[],
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
        formulierTypeOpties: formulierTypeOpties,
        verdeelgroepOpties: verdeelgroepOpties,
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
    required this.verdeelgroepOpties,
    required this.bevestigKnopTekst,
    required this.bevestigKnopIcoon,
    this.bestaandePrijsregel,
  });

  final OffertePrijsCategorie categorie;
  final String formulierType;
  final int volgendeVolgorde;
  final List<OfferteTechnischeKeuzeRef> technischeKeuzes;
  final List<OffertePrijsregelFormulierOptie> formulierTypeOpties;
  final List<OffertePrijsregelModel> verdeelgroepOpties;
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

  static const String _nieuweVerdeelgroepId =
      '__nieuwe_gedeelde_verdeelgroep__';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _omschrijvingController;
  late final TextEditingController _prijsController;
  late final TextEditingController _limietController;

  late final FocusNode _prijsFocusNode;
  late final FocusNode _limietFocusNode;

  late String _formulierType;
  late String _geselecteerdeVerdeelgroepId;
  late OffertePrijsEenheid _eenheid;
  late OffertePrijsUitschrijfmodus _uitschrijfmodus;
  late OffertePrijsVerdeelLimietmodus _verdeelLimietmodus;
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

  bool get _isVrijeArtikelPrijs {
    return widget.categorie == OffertePrijsCategorie.vrijPerArtikel;
  }

  bool get _isAlleArtikelenPrijs {
    return widget.categorie == OffertePrijsCategorie.alleArtikelen;
  }

  bool get _isVerdeelKost {
    return _isAlleArtikelenPrijs && _uitschrijfmodus.isVerdeeldeInterneKost;
  }

  bool get _isNieuweVerdeelgroep {
    return _geselecteerdeVerdeelgroepId == _nieuweVerdeelgroepId;
  }

  bool get _heeftVerdeelLimiet {
    return _isVerdeelKost &&
        _verdeelLimietmodus == OffertePrijsVerdeelLimietmodus.metAankooplimiet;
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

    if (_isVrijeArtikelPrijs) {
      return const <OffertePrijsUitschrijfmodus>[
        OffertePrijsUitschrijfmodus.invullenEnOfferteMetPrijs,
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
      OffertePrijsUitschrijfmodus.verdelenOverArtikelenAlleenOverzicht,
    ];
  }

  List<OffertePrijsregelModel> get _verdeelgroepen {
    final perId = <String, OffertePrijsregelModel>{};

    void voegToe(OffertePrijsregelModel regel) {
      if (!regel.isVerdeeldeProjectkost || regel.id.trim().isEmpty) {
        return;
      }

      final bestaand = perId[regel.id];
      if (bestaand == null ||
          _isNieuwer(regel.gewijzigdOp, bestaand.gewijzigdOp)) {
        perId[regel.id] = regel;
      }
    }

    for (final regel in widget.verdeelgroepOpties) {
      voegToe(regel);
    }

    final bestaandePrijsregel = widget.bestaandePrijsregel;
    if (bestaandePrijsregel != null) {
      voegToe(bestaandePrijsregel);
    }

    final resultaat = perId.values.toList(growable: false)
      ..sort((eerste, tweede) {
        return eerste.omschrijving.toLowerCase().compareTo(
          tweede.omschrijving.toLowerCase(),
        );
      });

    return resultaat;
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

    _limietController = TextEditingController(
      text: bestaand == null || bestaand.verdeelLimietBedragExclBtw <= 0
          ? ''
          : _bedragTekst(bestaand.verdeelLimietBedragExclBtw),
    );

    _prijsFocusNode = FocusNode()..addListener(_verwerkPrijsFocus);

    _limietFocusNode = FocusNode()..addListener(_verwerkLimietFocus);

    _eenheid = bestaand?.eenheid ?? OffertePrijsEenheid.vast;

    _uitschrijfmodus =
        bestaand?.uitschrijfmodus ??
        _standaardUitschrijfmodus(widget.categorie);

    if (!_beschikbareUitschrijfmodi.contains(_uitschrijfmodus)) {
      _uitschrijfmodus = _standaardUitschrijfmodus(widget.categorie);
    }

    _verdeelLimietmodus =
        bestaand?.verdeelLimietmodus ??
        OffertePrijsVerdeelLimietmodus.zonderLimiet;

    if (_uitschrijfmodus.isVerdeeldeInterneKost) {
      _eenheid = OffertePrijsEenheid.vast;
    }

    _actief = bestaand?.actief ?? true;

    _geselecteerdeVerdeelgroepId = bestaand?.isVerdeeldeProjectkost == true
        ? bestaand!.id
        : _nieuweVerdeelgroepId;

    _technischeKeuze = _vindActueleTechnischeKeuze(bestaand?.technischeKeuze);

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

    final bestaandeSleutel = <String>[
      bestaandeKeuze.formulierType.trim(),
      bestaandeKeuze.menuId.trim(),
      bestaandeKeuze.submenuId.trim(),
      bestaandeKeuze.keuzeId.trim(),
    ].join('|');

    for (final keuze in widget.technischeKeuzes) {
      final sleutel = <String>[
        keuze.formulierType.trim(),
        keuze.menuId.trim(),
        keuze.submenuId.trim(),
        keuze.keuzeId.trim(),
      ].join('|');

      if (sleutel == bestaandeSleutel) {
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

    _limietFocusNode
      ..removeListener(_verwerkLimietFocus)
      ..dispose();

    _omschrijvingController.dispose();
    _prijsController.dispose();
    _limietController.dispose();

    super.dispose();
  }

  void _verwerkPrijsFocus() {
    _formatteerBedragController(_prijsController, _prijsFocusNode);
  }

  void _verwerkLimietFocus() {
    _formatteerBedragController(_limietController, _limietFocusNode);
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
                if (_isVerdeelKost) ...<Widget>[
                  const SizedBox(height: 12),
                  _bouwVerdeelInstellingen(),
                ],
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
    if (_isVerdeelKost) {
      return _bouwVerdeelgroepOmschrijving();
    }

    return TextFormField(
      controller: _omschrijvingController,
      autofocus: !_isTechnischePrijs,
      readOnly: _isTechnischePrijs,
      textCapitalization: TextCapitalization.sentences,
      decoration: _invoerDecoratie(
        label: _isTechnischePrijs
            ? 'Hoe uitschrijven — uit technische keuze'
            : 'Omschrijving',
        hint: _isTechnischePrijs
            ? 'Wordt automatisch overgenomen van de technische keuze'
            : 'Bijvoorbeeld: Petscreen toeslag',
      ),
      validator: _valideerOmschrijving,
    );
  }

  Widget _bouwVerdeelgroepOmschrijving() {
    final opties = _verdeelgroepen;
    final geldigeIds = opties.map((regel) => regel.id).toSet();

    final actueleWaarde = geldigeIds.contains(_geselecteerdeVerdeelgroepId)
        ? _geselecteerdeVerdeelgroepId
        : _nieuweVerdeelgroepId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DropdownButtonFormField<String>(
          key: ValueKey<String>('verdeelgroep_$actueleWaarde'),
          initialValue: actueleWaarde,
          isExpanded: true,
          decoration: _invoerDecoratie(label: 'Omschrijving'),
          items: <DropdownMenuItem<String>>[
            const DropdownMenuItem<String>(
              value: _nieuweVerdeelgroepId,
              child: Text(
                'Nieuwe omschrijving toevoegen…',
                style: TextStyle(color: _groen, fontWeight: FontWeight.w900),
              ),
            ),
            ...opties.map((regel) {
              return DropdownMenuItem<String>(
                value: regel.id,
                child: Text(
                  regel.omschrijving,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              );
            }),
          ],
          onChanged: (waarde) {
            if (waarde == null) {
              return;
            }

            if (waarde == _nieuweVerdeelgroepId) {
              setState(() {
                _geselecteerdeVerdeelgroepId = _nieuweVerdeelgroepId;
                _omschrijvingController.clear();

                final bestaand = widget.bestaandePrijsregel;
                if (bestaand?.isVerdeeldeProjectkost != true) {
                  _prijsController.clear();
                  _limietController.clear();
                  _verdeelLimietmodus =
                      OffertePrijsVerdeelLimietmodus.zonderLimiet;
                  _actief = true;
                }
              });
              return;
            }

            OffertePrijsregelModel? gekozen;

            for (final regel in opties) {
              if (regel.id == waarde) {
                gekozen = regel;
                break;
              }
            }

            if (gekozen == null) {
              return;
            }

            _neemVerdeelgroepOver(gekozen);
          },
        ),
        const SizedBox(height: 10),
        if (actueleWaarde == _nieuweVerdeelgroepId)
          TextFormField(
            controller: _omschrijvingController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: _invoerDecoratie(
              label: 'Nieuwe omschrijving',
              hint: 'Bijvoorbeeld: Transportkost Feneko',
            ),
            validator: _valideerOmschrijving,
          )
        else
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.link_rounded, color: _groen, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Deze omschrijving is een gedeelde verdeelkost. '
                    'Wijzigingen aan bedrag, aankooplimiet of actiefstatus '
                    'worden toegepast op alle gekoppelde artikelgroepen.',
                    style: TextStyle(
                      color: Color(0xFF166534),
                      fontSize: 11.2,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _bouwTechnischeKeuze() {
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
            label: _isVerdeelKost
                ? 'Totaalbedrag te verdelen — excl. btw'
                : _isAlleArtikelenPrijs
                ? 'Projectprijs / eenheidsprijs excl. btw'
                : 'Prijs excl. btw',
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

        if (_isVerdeelKost) {
          return prijsVeld;
        }

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
            if (_isVrijeArtikelPrijs) ...<Widget>[
              const SizedBox(height: 7),
              const Text(
                'Deze actieve regel wordt automatisch toegepast. '
                'De gekozen berekeningswijze gebruikt rechtstreeks '
                'de maten en het aantal van het artikel.',
                style: TextStyle(
                  color: _tekstGrijs,
                  fontSize: 10.8,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
          final wasVerdeelkost = _isVerdeelKost;
          _uitschrijfmodus = waarde;

          if (_isVerdeelKost) {
            _eenheid = OffertePrijsEenheid.vast;

            if (!wasVerdeelkost) {
              final bestaand = widget.bestaandePrijsregel;
              _geselecteerdeVerdeelgroepId =
                  bestaand?.isVerdeeldeProjectkost == true
                  ? bestaand!.id
                  : _nieuweVerdeelgroepId;
            }
          }
        });
      },
    );
  }

  void _neemVerdeelgroepOver(OffertePrijsregelModel verdeelgroep) {
    setState(() {
      _geselecteerdeVerdeelgroepId = verdeelgroep.id;
      _omschrijvingController.text = verdeelgroep.omschrijving;
      _prijsController.text = _bedragTekst(verdeelgroep.prijsExclBtw);
      _verdeelLimietmodus = verdeelgroep.verdeelLimietmodus;
      _limietController.text = verdeelgroep.verdeelLimietBedragExclBtw <= 0
          ? ''
          : _bedragTekst(verdeelgroep.verdeelLimietBedragExclBtw);
      _actief = verdeelgroep.actief;
      _eenheid = OffertePrijsEenheid.vast;
    });
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
      OffertePrijsUitschrijfmodus.verdelenOverArtikelenAlleenOverzicht =>
        Icons.account_tree_outlined,
      OffertePrijsUitschrijfmodus.optie => Icons.do_not_disturb_alt_outlined,
    };
  }

  Color _kleurVoorUitschrijfmodus(OffertePrijsUitschrijfmodus modus) {
    if (modus.isOptie) {
      return _oranje;
    }

    if (modus.isVerdeeldeInterneKost) {
      return const Color(0xFF2563EB);
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

  Widget _bouwVerdeelInstellingen() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.account_tree_outlined, color: _groen, size: 18),
              SizedBox(width: 7),
              Text(
                'Verdelen over artikelen',
                style: TextStyle(
                  color: _groen,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'Het totaalbedrag wordt gelijk verdeeld over alle '
            'artikelgroepen die dezelfde omschrijving hebben gekozen. '
            'De kost wordt meegerekend, maar niet afzonderlijk op de '
            'klantofferte getoond.',
            style: TextStyle(
              color: _tekstGrijs,
              fontSize: 11.5,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<OffertePrijsVerdeelLimietmodus>(
            key: ValueKey<OffertePrijsVerdeelLimietmodus>(_verdeelLimietmodus),
            initialValue: _verdeelLimietmodus,
            isExpanded: true,
            decoration: _invoerDecoratie(label: 'Aankooplimiet'),
            items: OffertePrijsVerdeelLimietmodus.values
                .map((modus) {
                  return DropdownMenuItem<OffertePrijsVerdeelLimietmodus>(
                    value: modus,
                    child: Text(
                      modus.benaming,
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
                _verdeelLimietmodus = waarde;
              });
            },
          ),
          if (_heeftVerdeelLimiet) ...<Widget>[
            const SizedBox(height: 12),
            TextFormField(
              controller: _limietController,
              focusNode: _limietFocusNode,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: const <TextInputFormatter>[
                _BedragInputFormatter(),
              ],
              decoration: _invoerDecoratie(
                label: 'Niet toepassen vanaf aankoopbedrag',
                hint: '0,00',
                prefixText: '€ ',
              ),
              validator: (waarde) {
                if (!_heeftVerdeelLimiet) {
                  return null;
                }

                final bedrag = _leesBedrag(waarde ?? '');
                if (bedrag == null || bedrag <= 0) {
                  return 'Vul een aankooplimiet groter dan € 0,00 in.';
                }

                return null;
              },
            ),
            const SizedBox(height: 6),
            const Text(
              'De kost wordt toegepast zolang het gezamenlijke '
              'aankoopbedrag van alle gekoppelde artikelgroepen '
              'lager is dan deze limiet.',
              style: TextStyle(
                color: _tekstGrijs,
                fontSize: 10.8,
                height: 1.3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bouwUitleg() {
    final tekst = switch (widget.categorie) {
      OffertePrijsCategorie.technischeKeuzePerArtikel =>
        'Deze prijsregel wordt automatisch toegepast wanneer '
            'de gekoppelde technische keuze in het artikel voorkomt.',
      OffertePrijsCategorie.vrijPerArtikel =>
        'Iedere actieve regel wordt automatisch per artikel toegepast. '
            'De berekening gebruikt de artikelmaten en het aantal.',
      OffertePrijsCategorie.alleArtikelen =>
        'Een gewone regel wordt één keer over de artikelen van deze '
            'artikelgroep berekend. Een gedeelde verdeelkost kan over '
            'meerdere gekoppelde artikelgroepen worden verdeeld.',
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
          : 'Vul een omschrijving in.';
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

    final id = _bepaalPrijsregelId(bestaand: bestaand, nu: nu);

    final prijsregel = OffertePrijsregelModel(
      id: id,
      categorie: widget.categorie,
      formulierType: _formulierType,
      omschrijving: _isTechnischePrijs
          ? _technischeKeuze!.hoeUitschrijven
          : _omschrijvingController.text,
      prijsExclBtw: _leesBedrag(_prijsController.text) ?? 0,
      eenheid: _isVerdeelKost ? OffertePrijsEenheid.vast : _eenheid,
      uitschrijfmodus: _uitschrijfmodus,
      technischeKeuze: _isTechnischePrijs ? _technischeKeuze : null,
      verdeelLimietmodus: _isVerdeelKost
          ? _verdeelLimietmodus
          : OffertePrijsVerdeelLimietmodus.zonderLimiet,
      verdeelLimietBedragExclBtw: _heeftVerdeelLimiet
          ? _leesBedrag(_limietController.text) ?? 0
          : 0,
      actief: _actief,
      volgorde: bestaand?.volgorde ?? widget.volgendeVolgorde,
      gewijzigdOp: nu,
    );

    Navigator.pop(context, prijsregel);
  }

  String _bepaalPrijsregelId({
    required OffertePrijsregelModel? bestaand,
    required String nu,
  }) {
    if (_isVerdeelKost && !_isNieuweVerdeelgroep) {
      return _geselecteerdeVerdeelgroepId;
    }

    if (_isVerdeelKost &&
        _isNieuweVerdeelgroep &&
        bestaand?.isVerdeeldeProjectkost == true) {
      return 'prijs_${DateTime.now().microsecondsSinceEpoch}';
    }

    return bestaand?.id ?? 'prijs_${DateTime.now().microsecondsSinceEpoch}';
  }

  static OffertePrijsUitschrijfmodus _standaardUitschrijfmodus(
    OffertePrijsCategorie categorie,
  ) {
    if (categorie == OffertePrijsCategorie.vrijPerArtikel) {
      return OffertePrijsUitschrijfmodus.invullenEnOfferteMetPrijs;
    }

    return OffertePrijsUitschrijfmodus.overzichtEnOfferteMetPrijs;
  }

  static String _normaliseerFormulierType(String waarde) {
    return waarde.trim().toLowerCase().replaceAll('_', '').replaceAll(' ', '');
  }

  static bool _isNieuwer(String eerste, String tweede) {
    final eersteDatum = DateTime.tryParse(eerste);
    final tweedeDatum = DateTime.tryParse(tweede);

    if (eersteDatum == null) {
      return false;
    }

    if (tweedeDatum == null) {
      return true;
    }

    return eersteDatum.isAfter(tweedeDatum);
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
