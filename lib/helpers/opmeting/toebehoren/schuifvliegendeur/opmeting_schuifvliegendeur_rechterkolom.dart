// THIMACO-CONTROLE: SCHUIFVLIEGENDEUR-BASISVELDEN-ONDER-ELKAAR-20260728
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'opmeting_schuifvliegendeur_model.dart';
import 'opmeting_schuifvliegendeur_profiel_catalogus.dart';
import 'opmeting_schuifvliegendeur_profiel_painter.dart';

class OpmetingSchuifvliegendeurRechterkolom extends StatefulWidget {
  const OpmetingSchuifvliegendeurRechterkolom({
    super.key,
    required this.model,
    required this.onGewijzigd,
    this.projectRalKleur = '',
  });

  final OpmetingSchuifvliegendeurModel model;
  final ValueChanged<OpmetingSchuifvliegendeurModel> onGewijzigd;
  final String projectRalKleur;

  @override
  State<OpmetingSchuifvliegendeurRechterkolom> createState() {
    return _OpmetingSchuifvliegendeurRechterkolomState();
  }
}

class _OpmetingSchuifvliegendeurRechterkolomState
    extends State<OpmetingSchuifvliegendeurRechterkolom> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekst = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  late final TextEditingController _stukReferentieController;
  late final TextEditingController _aantalController;
  late final TextEditingController _breedteController;
  late final TextEditingController _hoogteController;
  late final TextEditingController _poederlakController;
  late final TextEditingController _railLengteController;
  late final TextEditingController _aantalTraversenController;
  late final List<TextEditingController> _traverseHoogteControllers;
  late final TextEditingController _dierenluikNotitiesController;
  late final TextEditingController _plaatHoogteController;

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
    _poederlakController = TextEditingController(text: model.poederlakKleur);
    _railLengteController = TextEditingController(
      text: model.railLengteMm.toString(),
    );
    _aantalTraversenController = TextEditingController(
      text: model.aantalTraversen.toString(),
    );
    _traverseHoogteControllers = List<TextEditingController>.generate(
      OpmetingSchuifvliegendeurModel.aantalTraversenMaximum,
      (index) {
        final waarde = index < model.traverseHoogtesMm.length
            ? model.traverseHoogtesMm[index]
            : 0;
        return TextEditingController(text: waarde > 0 ? '$waarde' : '');
      },
    );
    _dierenluikNotitiesController = TextEditingController(
      text: model.dierenluikNotities,
    );
    _plaatHoogteController = TextEditingController(
      text: model.plaatHoogteOpMaatMm.toString(),
    );
  }

  @override
  void didUpdateWidget(
    covariant OpmetingSchuifvliegendeurRechterkolom oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    final model = widget.model;
    _zetTekstIndienAnders(_stukReferentieController, model.stukReferentie);
    _zetTekstIndienAnders(_aantalController, '${model.aantal}');
    _zetTekstIndienAnders(_breedteController, '${model.breedteMm}');
    _zetTekstIndienAnders(_hoogteController, '${model.hoogteMm}');
    _zetTekstIndienAnders(_poederlakController, model.poederlakKleur);
    _zetTekstIndienAnders(_railLengteController, '${model.railLengteMm}');
    _zetTekstIndienAnders(
      _aantalTraversenController,
      '${model.aantalTraversen}',
    );
    for (var index = 0; index < _traverseHoogteControllers.length; index++) {
      final waarde = index < model.traverseHoogtesMm.length
          ? model.traverseHoogtesMm[index]
          : 0;
      _zetTekstIndienAnders(
        _traverseHoogteControllers[index],
        waarde > 0 ? '$waarde' : '',
      );
    }
    _zetTekstIndienAnders(
      _dierenluikNotitiesController,
      model.dierenluikNotities,
    );
    _zetTekstIndienAnders(
      _plaatHoogteController,
      '${model.plaatHoogteOpMaatMm}',
    );
  }

  void _zetTekstIndienAnders(TextEditingController controller, String waarde) {
    if (controller.text == waarde) return;
    controller.value = TextEditingValue(
      text: waarde,
      selection: TextSelection.collapsed(offset: waarde.length),
    );
  }

  @override
  void dispose() {
    _stukReferentieController.dispose();
    _aantalController.dispose();
    _breedteController.dispose();
    _hoogteController.dispose();
    _poederlakController.dispose();
    _railLengteController.dispose();
    _aantalTraversenController.dispose();
    for (final controller in _traverseHoogteControllers) {
      controller.dispose();
    }
    _dierenluikNotitiesController.dispose();
    _plaatHoogteController.dispose();
    super.dispose();
  }

  void _wijzig(OpmetingSchuifvliegendeurModel model) {
    widget.onGewijzigd(_normaliseerModel(model));
  }

  OpmetingSchuifvliegendeurModel _normaliseerModel(
    OpmetingSchuifvliegendeurModel model,
  ) {
    var resultaat = model;

    if (resultaat.gebruiktProjectKleur) {
      resultaat = resultaat.copyWith(
        ralKleurToebehorenWaarde: widget.projectRalKleur.trim(),
      );
    }

    if (resultaat.isElegancePlus) {
      resultaat = resultaat.copyWith(
        aantalTraversen: 0,
        traverseHoogtesMm: const <int>[],
        plaat: resultaat.isPlaatTotTussenstijl
            ? OpmetingSchuifvliegendeurModel.plaatGeen
            : resultaat.plaat,
      );
    } else if (resultaat.aantalTraversen <= 0) {
      resultaat = resultaat.copyWith(
        aantalTraversen: 1,
        traverseHoogtesMm: const <int>[955],
      );
    }

    return resultaat;
  }

  void _wijzigGetal({
    required String tekst,
    required int minimum,
    required int maximum,
    required ValueChanged<int> onGeldig,
  }) {
    final waarde = int.tryParse(tekst.trim());
    if (waarde == null || waarde < minimum || waarde > maximum) return;
    onGeldig(waarde);
  }

  void _wijzigAantalTraversen(String tekst) {
    _wijzigGetal(
      tekst: tekst,
      minimum: 1,
      maximum: OpmetingSchuifvliegendeurModel.aantalTraversenMaximum,
      onGeldig: (waarde) {
        final hoogtes = List<int>.from(widget.model.traverseHoogtesMm);
        while (hoogtes.length < waarde) {
          final index = hoogtes.length;
          final standaard = switch (index) {
            0 => 955,
            1 => 1400,
            _ => 1800,
          };
          hoogtes.add(
            standaard.clamp(100, widget.model.hoogteMm - 100).toInt(),
          );
        }
        _wijzig(
          widget.model.copyWith(
            aantalTraversen: waarde,
            traverseHoogtesMm: hoogtes.take(waarde).toList(growable: false),
          ),
        );
      },
    );
  }

  void _wijzigTraverseHoogte(int index, String tekst) {
    final minimum = switch (index) {
      0 => 100,
      1 => 500,
      _ => 1000,
    };
    final maximum = (widget.model.hoogteMm - 100).clamp(minimum, 1900).toInt();

    _wijzigGetal(
      tekst: tekst,
      minimum: minimum,
      maximum: maximum,
      onGeldig: (waarde) {
        final hoogtes = List<int>.from(widget.model.traverseHoogtesMm);
        while (hoogtes.length <= index) {
          hoogtes.add(waarde);
        }
        hoogtes[index] = waarde;
        _wijzig(widget.model.copyWith(traverseHoogtesMm: hoogtes));
      },
    );
  }

  String _projectkleurVoorWeergave() {
    final kleur = widget.projectRalKleur.trim();
    return kleur.isEmpty ? 'Kleur nog te bepalen' : kleur;
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
                Icon(Icons.door_sliding_outlined, size: 19, color: _groen),
                SizedBox(width: 8),
                Text(
                  'Schuifvliegendeur',
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
                      onChanged: (waarde) {
                        _wijzig(model.copyWith(stukReferentie: waarde));
                      },
                    ),
                    _CompactGetalVeld(
                      titel: 'Aantal (1 - 20)',
                      controller: _aantalController,
                      minimum: OpmetingSchuifvliegendeurModel.aantalMinimum,
                      maximum: OpmetingSchuifvliegendeurModel.aantalMaximum,
                      onChanged: (tekst) {
                        _wijzigGetal(
                          tekst: tekst,
                          minimum: OpmetingSchuifvliegendeurModel.aantalMinimum,
                          maximum: OpmetingSchuifvliegendeurModel.aantalMaximum,
                          onGeldig: (waarde) {
                            _wijzig(model.copyWith(aantal: waarde));
                          },
                        );
                      },
                    ),
                    _CompactGetalVeld(
                      titel: 'Breedte (300 - 5600)',
                      controller: _breedteController,
                      minimum: OpmetingSchuifvliegendeurModel.breedteMinimumMm,
                      maximum: OpmetingSchuifvliegendeurModel.breedteMaximumMm,
                      eenheid: 'mm',
                      onChanged: (tekst) {
                        _wijzigGetal(
                          tekst: tekst,
                          minimum:
                              OpmetingSchuifvliegendeurModel.breedteMinimumMm,
                          maximum:
                              OpmetingSchuifvliegendeurModel.breedteMaximumMm,
                          onGeldig: (waarde) {
                            _wijzig(model.copyWith(breedteMm: waarde));
                          },
                        );
                      },
                    ),
                    _CompactGetalVeld(
                      titel: 'Hoogte inclusief rails (1500 - 3100)',
                      controller: _hoogteController,
                      minimum: OpmetingSchuifvliegendeurModel.hoogteMinimumMm,
                      maximum: OpmetingSchuifvliegendeurModel.hoogteMaximumMm,
                      eenheid: 'mm',
                      onChanged: (tekst) {
                        _wijzigGetal(
                          tekst: tekst,
                          minimum:
                              OpmetingSchuifvliegendeurModel.hoogteMinimumMm,
                          maximum:
                              OpmetingSchuifvliegendeurModel.hoogteMaximumMm,
                          onGeldig: (waarde) {
                            _wijzig(model.copyWith(hoogteMm: waarde));
                          },
                        );
                      },
                    ),
                  ],
                ),
                _KeuzeSectie(
                  titel: 'Soort',
                  waarde: model.soort,
                  keuzes: OpmetingSchuifvliegendeurModel.soortKeuzes,
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(soort: waarde));
                  },
                ),
                _KeuzeSectie(
                  titel: 'Kleursoort',
                  waarde: model.kleursoort,
                  keuzes: OpmetingSchuifvliegendeurModel.kleursoortKeuzes,
                  onChanged: (waarde) {
                    _wijzig(
                      model.copyWith(
                        kleursoort: waarde,
                        ralKleurToebehorenWaarde:
                            waarde ==
                                OpmetingSchuifvliegendeurModel
                                    .kleursoortProjectKleur
                            ? widget.projectRalKleur.trim()
                            : model.ralKleurToebehorenWaarde,
                      ),
                    );
                  },
                ),
                if (model.gebruiktProjectKleur)
                  _InformatieKaart(
                    titel: 'Project kleur',
                    waarde: _projectkleurVoorWeergave(),
                  ),
                if (model.isPoederlak)
                  _SectieKaart(
                    titel: 'Poederlak',
                    children: <Widget>[
                      _CompactTekstVeld(
                        titel: 'Kleur of referentie',
                        controller: _poederlakController,
                        onChanged: (waarde) {
                          _wijzig(model.copyWith(poederlakKleur: waarde));
                        },
                      ),
                    ],
                  ),
                _KeuzeSectie(
                  titel: 'Uitvoering',
                  waarde: model.uitvoering,
                  keuzes: OpmetingSchuifvliegendeurModel.uitvoeringKeuzes,
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(uitvoering: waarde));
                  },
                ),
                if (model.heeftRails) ...<Widget>[
                  _ProfielKeuzeSectie(
                    titel: 'Onderrail',
                    waarde: model.onderrailCode,
                    profielen:
                        OpmetingSchuifvliegendeurProfielCatalogus.onderrails,
                    onChanged: (waarde) {
                      _wijzig(model.copyWith(onderrailCode: waarde));
                    },
                  ),
                  _ProfielKeuzeSectie(
                    titel: 'Bovenrail',
                    waarde: model.bovenrailCode,
                    profielen:
                        OpmetingSchuifvliegendeurProfielCatalogus.bovenrails,
                    onChanged: (waarde) {
                      _wijzig(model.copyWith(bovenrailCode: waarde));
                    },
                  ),
                  _SectieKaart(
                    titel: 'Rails',
                    children: <Widget>[
                      _CompactGetalVeld(
                        titel: 'Lengte rails (200 - 12000)',
                        controller: _railLengteController,
                        minimum:
                            OpmetingSchuifvliegendeurModel.railLengteMinimumMm,
                        maximum:
                            OpmetingSchuifvliegendeurModel.railLengteMaximumMm,
                        eenheid: 'mm',
                        onChanged: (tekst) {
                          _wijzigGetal(
                            tekst: tekst,
                            minimum: OpmetingSchuifvliegendeurModel
                                .railLengteMinimumMm,
                            maximum: OpmetingSchuifvliegendeurModel
                                .railLengteMaximumMm,
                            onGeldig: (waarde) {
                              _wijzig(model.copyWith(railLengteMm: waarde));
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
                if (!model.isElegancePlus) ...<Widget>[
                  _KeuzeSectie(
                    titel: 'Traversen',
                    waarde: model.traverseType,
                    keuzes: OpmetingSchuifvliegendeurModel.traverseKeuzes,
                    onChanged: (waarde) {
                      if (waarde ==
                          OpmetingSchuifvliegendeurModel.traverseStandaard) {
                        _wijzig(
                          model.copyWith(
                            traverseType: waarde,
                            aantalTraversen: 1,
                            traverseHoogtesMm: const <int>[955],
                          ),
                        );
                      } else {
                        _wijzig(model.copyWith(traverseType: waarde));
                      }
                    },
                  ),
                  _SectieKaart(
                    titel: 'Traversehoogtes',
                    children: <Widget>[
                      _CompactGetalVeld(
                        titel: 'Aantal traversen (1 - 3)',
                        controller: _aantalTraversenController,
                        minimum: 1,
                        maximum: OpmetingSchuifvliegendeurModel
                            .aantalTraversenMaximum,
                        enabled: model.isTraverseOpMaat,
                        onChanged: _wijzigAantalTraversen,
                      ),
                      for (
                        var index = 0;
                        index < model.aantalTraversen.clamp(1, 3);
                        index++
                      )
                        _CompactGetalVeld(
                          titel: 'Hoogte T${index + 1}',
                          controller: _traverseHoogteControllers[index],
                          minimum: switch (index) {
                            0 => 100,
                            1 => 500,
                            _ => 1000,
                          },
                          maximum: (model.hoogteMm - 100).clamp(switch (index) {
                            0 => 100,
                            1 => 500,
                            _ => 1000,
                          }, 1900).toInt(),
                          eenheid: 'mm',
                          enabled: model.isTraverseOpMaat,
                          onChanged: (tekst) {
                            _wijzigTraverseHoogte(index, tekst);
                          },
                        ),
                    ],
                  ),
                ],
                _KeuzeSectie(
                  titel: 'Kleur pees',
                  waarde: model.kleurPees,
                  keuzes: OpmetingSchuifvliegendeurModel.kleurPeesKeuzes,
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(kleurPees: waarde));
                  },
                ),
                if (model.isSmal)
                  _KeuzeSectie(
                    titel: 'Stootrubbers',
                    waarde: model.stootrubbers,
                    keuzes: OpmetingSchuifvliegendeurModel.stootrubbersKeuzes,
                    onChanged: (waarde) {
                      _wijzig(model.copyWith(stootrubbers: waarde));
                    },
                  ),
                _KeuzeSectie(
                  titel: 'Kleur PVC',
                  waarde: model.kleurPvc,
                  keuzes: OpmetingSchuifvliegendeurModel.kleurPvcKeuzes,
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(kleurPvc: waarde));
                  },
                ),
                _KeuzeSectie(
                  titel: 'Pomp',
                  waarde: model.pomp,
                  keuzes: OpmetingSchuifvliegendeurModel.pompKeuzes,
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(pomp: waarde));
                  },
                ),
                _KeuzeSectie(
                  titel: 'Eindstoppen',
                  waarde: model.eindstoppen,
                  keuzes: OpmetingSchuifvliegendeurModel.eindstoppenKeuzes,
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(eindstoppen: waarde));
                  },
                ),
                _KeuzeSectie(
                  titel: 'Dierenluik',
                  waarde: model.dierenluik,
                  keuzes: OpmetingSchuifvliegendeurModel.dierenluikKeuzes,
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(dierenluik: waarde));
                  },
                ),
                if (model.heeftDierenluik)
                  _SectieKaart(
                    titel: 'Notitie dierenluik',
                    children: <Widget>[
                      _CompactTekstVeld(
                        titel: 'Afmetingen of opmerkingen',
                        controller: _dierenluikNotitiesController,
                        maxRegels: 3,
                        onChanged: (waarde) {
                          _wijzig(model.copyWith(dierenluikNotities: waarde));
                        },
                      ),
                    ],
                  ),
                _KeuzeSectie(
                  titel: 'Plaat',
                  waarde: model.plaat,
                  keuzes: OpmetingSchuifvliegendeurModel.plaatKeuzes
                      .where(
                        (keuze) =>
                            !model.isElegancePlus ||
                            keuze !=
                                OpmetingSchuifvliegendeurModel
                                    .plaatTotTussenstijl,
                      )
                      .toList(growable: false),
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(plaat: waarde));
                  },
                ),
                if (model.isPlaatOpMaat)
                  _SectieKaart(
                    titel: 'Plaat op maat',
                    children: <Widget>[
                      _CompactGetalVeld(
                        titel: 'Hoogte (0 - 824)',
                        controller: _plaatHoogteController,
                        minimum:
                            OpmetingSchuifvliegendeurModel.plaatHoogteMinimumMm,
                        maximum:
                            OpmetingSchuifvliegendeurModel.plaatHoogteMaximumMm,
                        eenheid: 'mm',
                        onChanged: (tekst) {
                          _wijzigGetal(
                            tekst: tekst,
                            minimum: OpmetingSchuifvliegendeurModel
                                .plaatHoogteMinimumMm,
                            maximum: OpmetingSchuifvliegendeurModel
                                .plaatHoogteMaximumMm,
                            onGeldig: (waarde) {
                              _wijzig(
                                model.copyWith(plaatHoogteOpMaatMm: waarde),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                _KeuzeSectie(
                  titel: 'Gaas',
                  waarde: model.gaas,
                  keuzes: OpmetingSchuifvliegendeurModel.gaasKeuzes,
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(gaas: waarde));
                  },
                ),
                if (model.heeftTraversen)
                  _KeuzeSectie(
                    titel: 'Gaas onder T1',
                    waarde: model.gaasOnderT1,
                    keuzes: OpmetingSchuifvliegendeurModel.gaasKeuzes,
                    onChanged: (waarde) {
                      _wijzig(model.copyWith(gaasOnderT1: waarde));
                    },
                  ),
                _KeuzeSectie(
                  titel: 'Borstel links',
                  waarde: model.borstelLinks,
                  keuzes: OpmetingSchuifvliegendeurModel.borstelKeuzes,
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(borstelLinks: waarde));
                  },
                ),
                _KeuzeSectie(
                  titel: 'Borstel rechts',
                  waarde: model.borstelRechts,
                  keuzes: OpmetingSchuifvliegendeurModel.borstelKeuzes,
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(borstelRechts: waarde));
                  },
                ),
              ],
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
          color: _OpmetingSchuifvliegendeurRechterkolomState._rand,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            titel,
            style: const TextStyle(
              color: _OpmetingSchuifvliegendeurRechterkolomState._tekst,
              fontSize: 11.5,
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
  });

  final String titel;
  final String waarde;
  final List<String> keuzes;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SectieKaart(
      titel: titel,
      children: <Widget>[
        RadioGroup<String>(
          groupValue: waarde,
          onChanged: (nieuw) {
            if (nieuw != null) onChanged(nieuw);
          },
          child: Column(
            children: <Widget>[
              for (final keuze in keuzes)
                RadioListTile<String>(
                  value: keuze,
                  dense: true,
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                  contentPadding: EdgeInsets.zero,
                  activeColor:
                      _OpmetingSchuifvliegendeurRechterkolomState._groen,
                  title: Text(
                    keuze,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: _OpmetingSchuifvliegendeurRechterkolomState._tekst,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfielKeuzeSectie extends StatelessWidget {
  const _ProfielKeuzeSectie({
    required this.titel,
    required this.waarde,
    required this.profielen,
    required this.onChanged,
  });

  final String titel;
  final String waarde;
  final List<OpmetingSchuifvliegendeurProfiel> profielen;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SectieKaart(
      titel: titel,
      children: <Widget>[
        RadioGroup<String>(
          groupValue: waarde,
          onChanged: (nieuw) {
            if (nieuw != null) onChanged(nieuw);
          },
          child: Column(
            children: <Widget>[
              for (final profiel in profielen)
                InkWell(
                  borderRadius: BorderRadius.circular(9),
                  onTap: () => onChanged(profiel.code),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: <Widget>[
                        Radio<String>(
                          value: profiel.code,
                          activeColor:
                              _OpmetingSchuifvliegendeurRechterkolomState
                                  ._groen,
                          visualDensity: const VisualDensity(
                            horizontal: -4,
                            vertical: -4,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                profiel.code,
                                style: const TextStyle(
                                  color:
                                      _OpmetingSchuifvliegendeurRechterkolomState
                                          ._tekst,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (profiel.omschrijving.trim().isNotEmpty)
                                Text(
                                  profiel.omschrijving,
                                  style: const TextStyle(
                                    color:
                                        _OpmetingSchuifvliegendeurRechterkolomState
                                            ._tekstGrijs,
                                    fontSize: 9.5,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        OpmetingSchuifvliegendeurProfielSchetsWidget(
                          profiel: profiel,
                          geselecteerd: profiel.code == waarde,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InformatieKaart extends StatelessWidget {
  const _InformatieKaart({required this.titel, required this.waarde});

  final String titel;
  final String waarde;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            titel,
            style: const TextStyle(
              color: _OpmetingSchuifvliegendeurRechterkolomState._groen,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            waarde,
            style: const TextStyle(
              color: _OpmetingSchuifvliegendeurRechterkolomState._tekst,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactTekstVeld extends StatelessWidget {
  const _CompactTekstVeld({
    required this.titel,
    required this.controller,
    required this.onChanged,
    this.hulptekst,
    this.maxRegels = 1,
  });

  final String titel;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? hulptekst;
  final int maxRegels;

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
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: _OpmetingSchuifvliegendeurRechterkolomState._tekst,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            maxLines: maxRegels,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 12),
            decoration: _veldDecoratie(helperText: hulptekst),
          ),
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
    required this.maximum,
    required this.onChanged,
    this.eenheid,
    this.enabled = true,
  });

  final String titel;
  final TextEditingController controller;
  final int minimum;
  final int maximum;
  final ValueChanged<String> onChanged;
  final String? eenheid;
  final bool enabled;

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
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: _OpmetingSchuifvliegendeurRechterkolomState._tekst,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: onChanged,
            style: const TextStyle(fontSize: 12),
            decoration: _veldDecoratie(
              suffixText: eenheid,
              helperText: enabled ? 'Toegelaten: $minimum - $maximum' : null,
            ),
          ),
        ],
      ),
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
        color: _OpmetingSchuifvliegendeurRechterkolomState._rand,
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: _OpmetingSchuifvliegendeurRechterkolomState._groen,
        width: 1.4,
      ),
    ),
  );
}
