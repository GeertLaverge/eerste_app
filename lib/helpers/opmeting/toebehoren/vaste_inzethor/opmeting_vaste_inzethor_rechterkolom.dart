import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'opmeting_vaste_inzethor_model.dart';

class OpmetingVasteInzethorRechterkolom extends StatefulWidget {
  const OpmetingVasteInzethorRechterkolom({
    super.key,
    required this.model,
    this.ralKleurToebehoren = '',
    required this.onGewijzigd,
  });

  final OpmetingVasteInzethorModel model;
  final String ralKleurToebehoren;
  final ValueChanged<OpmetingVasteInzethorModel> onGewijzigd;

  @override
  State<OpmetingVasteInzethorRechterkolom> createState() =>
      _OpmetingVasteInzethorRechterkolomState();
}

class _OpmetingVasteInzethorRechterkolomState
    extends State<OpmetingVasteInzethorRechterkolom> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekst = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  late final TextEditingController _stukReferentieController;
  late final TextEditingController _aantalController;
  late final TextEditingController _breedteController;
  late final TextEditingController _hoogteController;
  late final TextEditingController _hoogteOndersteKaderController;
  late final TextEditingController _poederlakController;
  late final TextEditingController _flensOpMaatController;
  late final TextEditingController _aantalTraversenController;
  late final List<TextEditingController> _traverseControllers;

  @override
  void initState() {
    super.initState();
    final model = widget.model;
    _stukReferentieController = TextEditingController(
      text: model.stukReferentie,
    );
    _aantalController = TextEditingController(text: model.aantal.toString());
    _breedteController = TextEditingController(
      text: model.breedteMm.toString(),
    );
    _hoogteController = TextEditingController(text: model.hoogteMm.toString());
    _hoogteOndersteKaderController = TextEditingController(
      text: model.hoogteOndersteKaderMm.toString(),
    );
    _poederlakController = TextEditingController(text: model.poederlakKleur);
    _flensOpMaatController = TextEditingController(
      text: model.flensDiepteOpMaatMm.toString(),
    );
    _aantalTraversenController = TextEditingController(
      text: model.aantalTraversenOpMaatGeldig.toString(),
    );
    final posities = model.gesynchroniseerdeTraversePositiesOpMaatMm;
    _traverseControllers = List<TextEditingController>.generate(3, (index) {
      final waarde = index < posities.length ? posities[index] : 0;
      return TextEditingController(text: waarde <= 0 ? '' : '$waarde');
    });
  }

  @override
  void didUpdateWidget(covariant OpmetingVasteInzethorRechterkolom oldWidget) {
    super.didUpdateWidget(oldWidget);
    final model = widget.model;
    _synchroniseerController(_stukReferentieController, model.stukReferentie);
    _synchroniseerController(_aantalController, '${model.aantal}');
    _synchroniseerController(_breedteController, '${model.breedteMm}');
    _synchroniseerController(_hoogteController, '${model.hoogteMm}');
    _synchroniseerController(
      _hoogteOndersteKaderController,
      '${model.hoogteOndersteKaderMm}',
    );
    _synchroniseerController(_poederlakController, model.poederlakKleur);
    _synchroniseerController(
      _flensOpMaatController,
      '${model.flensDiepteOpMaatMm}',
    );
    _synchroniseerController(
      _aantalTraversenController,
      '${model.aantalTraversenOpMaatGeldig}',
    );
    _synchroniseerTraverseControllers(model);
  }

  @override
  void dispose() {
    _stukReferentieController.dispose();
    _aantalController.dispose();
    _breedteController.dispose();
    _hoogteController.dispose();
    _hoogteOndersteKaderController.dispose();
    _poederlakController.dispose();
    _flensOpMaatController.dispose();
    _aantalTraversenController.dispose();
    for (final controller in _traverseControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _synchroniseerController(
    TextEditingController controller,
    String waarde,
  ) {
    if (controller.text == waarde) return;
    controller.value = TextEditingValue(
      text: waarde,
      selection: TextSelection.collapsed(offset: waarde.length),
    );
  }

  void _synchroniseerTraverseControllers(OpmetingVasteInzethorModel model) {
    final posities = model.gesynchroniseerdeTraversePositiesOpMaatMm;
    for (var index = 0; index < _traverseControllers.length; index++) {
      final waarde = index < posities.length ? posities[index] : 0;
      _synchroniseerController(
        _traverseControllers[index],
        waarde <= 0 ? '' : '$waarde',
      );
    }
  }

  void _wijzig(OpmetingVasteInzethorModel model) {
    widget.onGewijzigd(
      model.activeerTechnischeUitbreiding().genormaliseerdVoorProduct(),
    );
  }

  void _wijzigMetGesynchroniseerdeTraversen(OpmetingVasteInzethorModel model) {
    final genormaliseerd = model
        .activeerTechnischeUitbreiding()
        .genormaliseerdVoorProduct();
    _synchroniseerTraverseControllers(genormaliseerd);
    widget.onGewijzigd(genormaliseerd);
  }

  void _wijzigGetal({
    required String tekst,
    required int minimum,
    int? maximum,
    required ValueChanged<int> onGeldig,
  }) {
    final waarde = int.tryParse(tekst.trim());
    if (waarde == null || waarde < minimum) return;
    if (maximum != null && waarde > maximum) return;
    onGeldig(waarde);
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rand),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0F111827),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: _lichtGroen,
              borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
              border: Border(bottom: BorderSide(color: Color(0xFFCDEBD6))),
            ),
            child: const Row(
              children: <Widget>[
                Icon(Icons.grid_view_rounded, size: 19, color: _groen),
                SizedBox(width: 8),
                Text(
                  'Vaste inzethor',
                  style: TextStyle(
                    color: _groen,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              children: <Widget>[
                _SectieKaart(
                  titel: 'Basisgegevens',
                  children: <Widget>[
                    _CompactTekstVeld(
                      titel: 'Stuk referentie',
                      controller: _stukReferentieController,
                      hulptekst:
                          'Optioneel, geef een unieke referentie voor dit artikel mee.',
                      onChanged: (waarde) =>
                          _wijzig(model.copyWith(stukReferentie: waarde)),
                    ),
                    _CompactGetalVeld(
                      titel: 'Aantal',
                      controller: _aantalController,
                      minimum: 1,
                      onChanged: (tekst) => _wijzigGetal(
                        tekst: tekst,
                        minimum: 1,
                        onGeldig: (waarde) =>
                            _wijzig(model.copyWith(aantal: waarde)),
                      ),
                    ),
                  ],
                ),
                _KeuzeSectie(
                  titel: 'Soort',
                  waarde: model.soort,
                  keuzes: OpmetingVasteInzethorModel.soortOpties,
                  labelVoorWaarde: OpmetingVasteInzethorModel.soortLabel,
                  onChanged: (waarde) {
                    var gewijzigd = model.copyWith(soort: waarde);
                    if (waarde ==
                        OpmetingVasteInzethorModel.soortVliegenraamDubbel) {
                      gewijzigd = gewijzigd.copyWith(
                        profiel: OpmetingVasteInzethorModel.profielVr050,
                        maatType: OpmetingVasteInzethorModel.maatTypeBinnen,
                      );
                    } else if (waarde ==
                        OpmetingVasteInzethorModel.soortInzetvliegenraam) {
                      gewijzigd = gewijzigd.copyWith(
                        speling: OpmetingVasteInzethorModel.profielVr033Inzet,
                        spelingKeuze:
                            OpmetingVasteInzethorModel.spelingStandaard,
                        maatType: OpmetingVasteInzethorModel.maatTypeBinnen,
                      );
                    } else if (waarde ==
                        OpmetingVasteInzethorModel.soortVliegenraamRv) {
                      gewijzigd = gewijzigd.copyWith(
                        maatType: OpmetingVasteInzethorModel.maatTypeBinnen,
                        profiel: OpmetingVasteInzethorModel.profielVr061,
                        bevestiging:
                            OpmetingVasteInzethorModel.bevestigingClipsenZakje,
                        soortClipsen:
                            OpmetingVasteInzethorModel.clipsenStandaard,
                      );
                    }
                    _wijzigMetGesynchroniseerdeTraversen(gewijzigd);
                  },
                ),
                ..._bouwProductSpecifiekeSecties(model),
                _bouwTraverseKeuze(model),
                if (model.isTraverseOpMaat) _bouwTraversenOpMaat(model),
                if (!model.isTraverseOpMaat)
                  _SectieKaart(
                    titel: 'Traversen',
                    children: <Widget>[
                      _StandaardTraverseSamenvatting(model: model),
                    ],
                  ),
                _KeuzeSectie(
                  titel: 'Populaire kleuren',
                  waarde: model.populaireKleur,
                  keuzes: OpmetingVasteInzethorModel.kleurOpties,
                  labelVoorWaarde: OpmetingVasteInzethorModel.kleurLabel,
                  onChanged: (waarde) {
                    _wijzig(
                      model.copyWith(
                        populaireKleur: waarde,
                        ralKleurToebehorenWaarde:
                            waarde ==
                                OpmetingVasteInzethorModel.kleurRalToebehoren
                            ? widget.ralKleurToebehoren.trim()
                            : model.ralKleurToebehorenWaarde,
                      ),
                    );
                  },
                ),
                if (model.isProjectkleur)
                  _ProjectkleurSamenvatting(
                    projectkleur: model.ralKleurToebehorenWaarde,
                  ),
                if (model.isPoederlak)
                  _SectieKaart(
                    titel: 'Kleurcode',
                    children: <Widget>[
                      _CompactTekstVeld(
                        titel: 'Kleur poederlak',
                        controller: _poederlakController,
                        onChanged: (waarde) =>
                            _wijzig(model.copyWith(poederlakKleur: waarde)),
                      ),
                    ],
                  ),
                _KeuzeSectie(
                  titel: 'Gaas',
                  waarde: model.gaasVoorOverzicht,
                  keuzes: OpmetingVasteInzethorModel.gaasOpties,
                  labelVoorWaarde: OpmetingVasteInzethorModel.gaasLabel,
                  onChanged: (waarde) => _wijzig(model.copyWith(gaas: waarde)),
                ),
                _KeuzeSectie(
                  titel: 'Kleur pees',
                  waarde: model.kleurPees,
                  keuzes: OpmetingVasteInzethorModel.kleurPeesOpties,
                  onChanged: (waarde) =>
                      _wijzig(model.copyWith(kleurPees: waarde)),
                ),
                _KeuzeSectie(
                  titel: 'Borstels',
                  waarde: model.borstels,
                  keuzes: OpmetingVasteInzethorModel.borstelOpties,
                  onChanged: (waarde) =>
                      _wijzig(model.copyWith(borstels: waarde)),
                ),
                _KeuzeSectie(
                  titel: 'Bevestiging',
                  waarde: model.bevestiging,
                  keuzes: model.bevestigingOptiesVoorProduct,
                  onChanged: (waarde) =>
                      _wijzig(model.copyWith(bevestiging: waarde)),
                ),
                if (model.heeftClipsen)
                  _KeuzeSectie(
                    titel: 'Soort clipsen',
                    waarde: model.soortClipsen,
                    keuzes: model.soortClipsenOptiesVoorProduct,
                    onChanged: (waarde) =>
                        _wijzig(model.copyWith(soortClipsen: waarde)),
                  ),
                if (model.heeftClipsen)
                  _KeuzeSectie(
                    titel: 'Soort bevestiging',
                    waarde: model.soortBevestiging,
                    keuzes: model.soortBevestigingOptiesVoorProduct,
                    labelVoorWaarde:
                        OpmetingVasteInzethorModel.soortBevestigingLabel,
                    onChanged: (waarde) =>
                        _wijzig(model.copyWith(soortBevestiging: waarde)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _bouwProductSpecifiekeSecties(OpmetingVasteInzethorModel model) {
    final secties = <Widget>[];

    if (model.isInzetvliegenraam) {
      secties.add(
        _KeuzeSectie(
          titel: 'Profiel',
          waarde: model.speling,
          keuzes: OpmetingVasteInzethorModel.inzetProfielOpties,
          labelVoorWaarde: (waarde) =>
              waarde == OpmetingVasteInzethorModel.profielVr033Ultra
              ? 'VR033 Ultra'
              : 'VR033 (inzet)',
          onChanged: (waarde) {
            _wijzig(
              model.copyWith(
                speling: waarde,
                spelingKeuze:
                    waarde == OpmetingVasteInzethorModel.profielVr033Ultra
                    ? OpmetingVasteInzethorModel.spelingGeen
                    : model.spelingKeuze,
              ),
            );
          },
        ),
      );
    } else {
      secties.add(
        _KeuzeSectie(
          titel: 'Profiel',
          waarde: model.profiel,
          keuzes: model.profielOptiesVoorSoort,
          labelVoorWaarde: OpmetingVasteInzethorModel.profielLabel,
          onChanged: (waarde) {
            _wijzig(
              model.copyWith(
                profiel: waarde,
                maatType: waarde == OpmetingVasteInzethorModel.profielVr054
                    ? OpmetingVasteInzethorModel.maatTypeBinnen
                    : model.maatType,
              ),
            );
          },
        ),
      );
    }

    if (model.magBuitenmaatKiezen) {
      secties.add(
        _KeuzeSectie(
          titel: 'Binnenmaten / buitenmaten',
          waarde: model.maatType,
          keuzes: model.maatTypeOptiesVoorProduct,
          onChanged: (waarde) => _wijzig(model.copyWith(maatType: waarde)),
        ),
      );
    } else {
      secties.add(const _AlleenBinnenmaatSamenvatting());
    }

    secties.add(_bouwAfmetingen(model));

    // In Feneko volgen de profielafhankelijke inzetkeuzes pas na de maten.
    // Daardoor gaat "Geen speling" rechtstreeks door naar het traversenmenu.
    if (model.isInzetvliegenraam) {
      if (model.isVr033Ultra) {
        secties.add(
          _KeuzeSectie(
            titel: 'Flensdiepte',
            waarde: model.flensDiepte,
            keuzes: OpmetingVasteInzethorModel.flensDiepteOpties,
            onChanged: (waarde) => _wijzig(model.copyWith(flensDiepte: waarde)),
          ),
        );
        if (model.isFlensOpMaat) {
          secties.add(
            _SectieKaart(
              titel: 'Flens op maat',
              children: <Widget>[
                _CompactGetalVeld(
                  titel: 'Flensdiepte op maat',
                  controller: _flensOpMaatController,
                  minimum: 12,
                  maximum: 80,
                  eenheid: 'mm',
                  onChanged: (tekst) => _wijzigGetal(
                    tekst: tekst,
                    minimum: 12,
                    maximum: 80,
                    onGeldig: (waarde) =>
                        _wijzig(model.copyWith(flensDiepteOpMaatMm: waarde)),
                  ),
                ),
              ],
            ),
          );
        }
      } else {
        secties.add(
          _KeuzeSectie(
            titel: 'Speling',
            waarde: model.spelingKeuze,
            keuzes: OpmetingVasteInzethorModel.spelingKeuzeOpties,
            onChanged: (waarde) =>
                _wijzig(model.copyWith(spelingKeuze: waarde)),
          ),
        );
        if (model.heeftStandaardSpeling) {
          secties.add(const _VasteSpelingSamenvatting());
        }
      }
    }

    return secties;
  }

  Widget _bouwAfmetingen(OpmetingVasteInzethorModel model) {
    return _SectieKaart(
      titel: 'Afmetingen',
      children: <Widget>[
        _CompactGetalVeld(
          titel: model.breedteTitel,
          controller: _breedteController,
          minimum: model.breedteMinimumMm,
          maximum: model.breedteMaximumMm,
          eenheid: 'mm',
          onChanged: (tekst) => _wijzigGetal(
            tekst: tekst,
            minimum: model.breedteMinimumMm,
            maximum: model.breedteMaximumMm,
            onGeldig: (waarde) => _wijzig(model.copyWith(breedteMm: waarde)),
          ),
        ),
        _CompactGetalVeld(
          titel: model.hoogteTitel,
          controller: _hoogteController,
          minimum: model.hoogteMinimumMm,
          maximum: model.hoogteMaximumMm,
          eenheid: 'mm',
          onChanged: (tekst) => _wijzigGetal(
            tekst: tekst,
            minimum: model.hoogteMinimumMm,
            maximum: model.hoogteMaximumMm,
            onGeldig: (waarde) => _wijzigMetGesynchroniseerdeTraversen(
              model.copyWithGesynchroniseerdeTraversen(hoogteMm: waarde),
            ),
          ),
        ),
        if (model.isVliegenraamDubbel)
          _CompactGetalVeld(
            titel: model.hoogteOndersteKaderTitel,
            controller: _hoogteOndersteKaderController,
            minimum: model.hoogteOndersteKaderMinimumMm,
            maximum: model.hoogteOndersteKaderMaximumMm,
            eenheid: 'mm',
            onChanged: (tekst) => _wijzigGetal(
              tekst: tekst,
              minimum: model.hoogteOndersteKaderMinimumMm,
              maximum: model.hoogteOndersteKaderMaximumMm,
              onGeldig: (waarde) =>
                  _wijzig(model.copyWith(hoogteOndersteKaderMm: waarde)),
            ),
          ),
        _MaatSamenvatting(model: model),
      ],
    );
  }

  Widget _bouwTraverseKeuze(OpmetingVasteInzethorModel model) {
    return _KeuzeSectie(
      titel: 'Standaard traversen',
      waarde: model.traverseType,
      keuzes: OpmetingVasteInzethorModel.traverseTypeOpties,
      onChanged: (waarde) {
        final gewijzigd = model
            .copyWith(traverseType: waarde)
            .copyWithGesynchroniseerdeTraversen();
        _wijzigMetGesynchroniseerdeTraversen(gewijzigd);
      },
    );
  }

  Widget _bouwTraversenOpMaat(OpmetingVasteInzethorModel model) {
    return _SectieKaart(
      titel: 'Traversen op maat',
      children: <Widget>[
        _CompactGetalVeld(
          titel: 'Aantal traversen',
          controller: _aantalTraversenController,
          minimum: 1,
          maximum: model.maximumAantalTraversenOpMaat,
          onChanged: (tekst) => _wijzigGetal(
            tekst: tekst,
            minimum: 1,
            maximum: model.maximumAantalTraversenOpMaat,
            onGeldig: (waarde) => _wijzigMetGesynchroniseerdeTraversen(
              model.copyWithGesynchroniseerdeTraversen(
                aantalTraversenOpMaat: waarde,
              ),
            ),
          ),
        ),
        ...List<Widget>.generate(model.aantalTraversenOpMaatGeldig, (index) {
          final minimum = model.traverseMinimumVoorIndex(index);
          final maximum = model.traverseMaximumVoorIndex(index);
          return _CompactGetalVeld(
            titel: 'Hoogte traverse ${index + 1}',
            controller: _traverseControllers[index],
            minimum: minimum,
            maximum: maximum,
            eenheid: 'mm',
            onChanged: (tekst) => _wijzigGetal(
              tekst: tekst,
              minimum: minimum,
              maximum: maximum,
              onGeldig: (waarde) {
                final posities = List<int>.from(
                  model.gesynchroniseerdeTraversePositiesOpMaatMm,
                );
                while (posities.length <= index) {
                  posities.add(waarde);
                }
                posities[index] = waarde;
                _wijzigMetGesynchroniseerdeTraversen(
                  model.copyWithGesynchroniseerdeTraversen(
                    traversePositiesOpMaatMm: posities,
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}

class _AlleenBinnenmaatSamenvatting extends StatelessWidget {
  const _AlleenBinnenmaatSamenvatting();

  @override
  Widget build(BuildContext context) {
    return const _SectieKaart(
      titel: 'Maatsoort',
      children: <Widget>[
        _CompactInfoRegel(
          icoon: Icons.straighten_rounded,
          tekst: 'Alleen binnenmaat / doorkijkmaat',
        ),
      ],
    );
  }
}

class _VasteSpelingSamenvatting extends StatelessWidget {
  const _VasteSpelingSamenvatting();

  @override
  Widget build(BuildContext context) {
    return const _SectieKaart(
      titel: 'Vaste standaardspeling',
      children: <Widget>[
        _CompactInfoRegel(
          icoon: Icons.compress_rounded,
          tekst: 'Breedte 4 mm · hoogte 5 mm',
        ),
      ],
    );
  }
}

class _CompactInfoRegel extends StatelessWidget {
  const _CompactInfoRegel({required this.icoon, required this.tekst});

  final IconData icoon;
  final String tekst;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          Icon(
            icoon,
            size: 17,
            color: _OpmetingVasteInzethorRechterkolomState._groen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tekst,
              style: const TextStyle(
                color: _OpmetingVasteInzethorRechterkolomState._tekst,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectieKaart extends StatelessWidget {
  const _SectieKaart({required this.titel, required this.children});

  final String titel;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: _OpmetingVasteInzethorRechterkolomState._rand,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            titel,
            style: const TextStyle(
              color: _OpmetingVasteInzethorRechterkolomState._groen,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          ...children,
        ],
      ),
    );
  }
}

class _KeuzeSectie extends StatelessWidget {
  const _KeuzeSectie({
    required this.titel,
    required this.waarde,
    required this.keuzes,
    required this.onChanged,
    this.labelVoorWaarde,
  });

  final String titel;
  final String waarde;
  final List<String> keuzes;
  final ValueChanged<String> onChanged;
  final String Function(String waarde)? labelVoorWaarde;

  @override
  Widget build(BuildContext context) {
    final labelBouwer = labelVoorWaarde ?? (waarde) => waarde;
    final zichtbareKeuzes = <String>[
      if (waarde.trim().isNotEmpty && !keuzes.contains(waarde)) waarde,
      ...keuzes,
    ];

    return _SectieKaart(
      titel: titel,
      children: zichtbareKeuzes
          .map((keuze) {
            return RadioListTile<String>(
              value: keuze,
              groupValue: waarde,
              onChanged: (nieuw) {
                if (nieuw != null) {
                  onChanged(nieuw);
                }
              },
              activeColor: _OpmetingVasteInzethorRechterkolomState._groen,
              dense: true,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              contentPadding: EdgeInsets.zero,
              title: Text(
                labelBouwer(keuze),
                style: const TextStyle(
                  color: _OpmetingVasteInzethorRechterkolomState._tekst,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class _CompactTekstVeld extends StatelessWidget {
  const _CompactTekstVeld({
    required this.titel,
    required this.controller,
    required this.onChanged,
    this.hulptekst,
  });

  final String titel;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? hulptekst;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            titel,
            style: const TextStyle(
              color: _OpmetingVasteInzethorRechterkolomState._tekst,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            decoration: _veldDecoratie(),
          ),
          if (hulptekst != null) ...<Widget>[
            const SizedBox(height: 3),
            Text(
              hulptekst!,
              style: const TextStyle(
                color: _OpmetingVasteInzethorRechterkolomState._tekstGrijs,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CompactGetalVeld extends StatelessWidget {
  const _CompactGetalVeld({
    required this.titel,
    required this.controller,
    required this.minimum,
    required this.onChanged,
    this.maximum,
    this.eenheid,
  });

  final String titel;
  final TextEditingController controller;
  final int minimum;
  final int? maximum;
  final ValueChanged<String> onChanged;
  final String? eenheid;

  String get hulptekst {
    if (maximum != null) {
      return 'Toegelaten: $minimum - $maximum';
    }
    return 'Minimum: $minimum';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            titel,
            style: const TextStyle(
              color: _OpmetingVasteInzethorRechterkolomState._tekst,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: onChanged,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            decoration: _veldDecoratie(
              suffixText: eenheid,
              helperText: hulptekst,
            ),
          ),
        ],
      ),
    );
  }
}

class _MaatSamenvatting extends StatelessWidget {
  const _MaatSamenvatting({required this.model});

  final OpmetingVasteInzethorModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F6EC),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFCDEBD6)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.straighten_rounded,
            color: Color(0xFF0B7A3B),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  model.maatSamenvattingTitel,
                  style: const TextStyle(
                    color: Color(0xFF0B7A3B),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  model.maatSamenvatting,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectkleurSamenvatting extends StatelessWidget {
  const _ProjectkleurSamenvatting({required this.projectkleur});

  final String projectkleur;

  @override
  Widget build(BuildContext context) {
    final waarde = projectkleur.trim();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF8),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFCDEBD6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'Projectkleur',
            style: TextStyle(
              color: Color(0xFF0B7A3B),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            waarde.isEmpty
                ? 'Nog geen projectkleur ingevuld in het project.'
                : waarde,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StandaardTraverseSamenvatting extends StatelessWidget {
  const _StandaardTraverseSamenvatting({required this.model});

  final OpmetingVasteInzethorModel model;

  @override
  Widget build(BuildContext context) {
    final posities = model.standaardTraversePositiesMm;

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            const Expanded(
              child: Text(
                'Aantal traversen',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${model.standaardAantalTraversen}',
              style: const TextStyle(
                color: Color(0xFF0B7A3B),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...List<Widget>.generate(posities.length, (index) {
          final waarde = posities[index];
          final tekst = waarde == waarde.roundToDouble()
              ? '${waarde.round()} mm'
              : '${waarde.toStringAsFixed(1)} mm';

          return Padding(
            padding: EdgeInsets.only(
              top: index == 0 ? 0 : 4,
              bottom: index == posities.length - 1 ? 8 : 0,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Traverse ${index + 1}',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  tekst,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

InputDecoration _veldDecoratie({String? suffixText, String? helperText}) {
  return InputDecoration(
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
    suffixText: suffixText,
    helperText: helperText,
    helperStyle: const TextStyle(fontSize: 9, height: 1),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: _OpmetingVasteInzethorRechterkolomState._rand,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: _OpmetingVasteInzethorRechterkolomState._groen,
        width: 1.4,
      ),
    ),
  );
}
