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
  State<OpmetingVasteInzethorRechterkolom> createState() {
    return _OpmetingVasteInzethorRechterkolomState();
  }
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
    _poederlakController = TextEditingController(text: model.poederlakKleur);
    _flensOpMaatController = TextEditingController(
      text: model.flensDiepteOpMaatMm.toString(),
    );
    _aantalTraversenController = TextEditingController(
      text: model.aantalTraversenOpMaat.toString(),
    );
    _traverseControllers = List<TextEditingController>.generate(3, (index) {
      final waarde = index < model.traversePositiesOpMaatMm.length
          ? model.traversePositiesOpMaatMm[index]
          : 0;
      return TextEditingController(text: waarde == 0 ? '' : waarde.toString());
    });
  }

  @override
  void dispose() {
    _stukReferentieController.dispose();
    _aantalController.dispose();
    _breedteController.dispose();
    _hoogteController.dispose();
    _poederlakController.dispose();
    _flensOpMaatController.dispose();
    _aantalTraversenController.dispose();
    for (final controller in _traverseControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _wijzig(OpmetingVasteInzethorModel model) {
    widget.onGewijzigd(model);
  }

  void _wijzigGetal(String tekst, void Function(int waarde) onGeldig) {
    final waarde = int.tryParse(tekst.trim());
    if (waarde != null) {
      onGeldig(waarde);
    }
  }

  List<String> get _soortBevestigingKeuzes {
    return <String>[
      '4',
      '5',
      '5 extra',
      '6',
      '7',
      '7 extra',
      ...List<String>.generate(13, (index) => '${index + 8}'),
    ];
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
                Icon(Icons.tune_rounded, size: 19, color: _groen),
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
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
              children: <Widget>[
                _CompactTekstVeld(
                  titel: 'Stuk referentie',
                  controller: _stukReferentieController,
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(stukReferentie: waarde));
                  },
                ),
                _CompactGetalVeld(
                  titel: 'Aantal',
                  controller: _aantalController,
                  minimum: 1,
                  onChanged: (tekst) {
                    _wijzigGetal(tekst, (waarde) {
                      if (waarde >= 1) {
                        _wijzig(model.copyWith(aantal: waarde));
                      }
                    });
                  },
                ),
                _CompactDropdown(
                  titel: 'Soort',
                  waarde: model.soort,
                  keuzes: const <String>[
                    OpmetingVasteInzethorModel.soortVliegenraamClassic,
                    OpmetingVasteInzethorModel.soortInzetvliegenraam,
                  ],
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(soort: waarde));
                  },
                ),
                if (model.isInzetvliegenraam) ...<Widget>[
                  _CompactDropdown(
                    titel: 'Speling',
                    waarde: model.speling,
                    keuzes: const <String>[
                      OpmetingVasteInzethorModel.spelingVr033Inzet,
                      OpmetingVasteInzethorModel.spelingVr033Ultra,
                    ],
                    onChanged: (waarde) {
                      _wijzig(model.copyWith(speling: waarde));
                    },
                  ),
                  if (model.isVr033Ultra) ...<Widget>[
                    _CompactDropdown(
                      titel: 'Flens diepte',
                      waarde: model.flensDiepte,
                      keuzes: const <String>[
                        OpmetingVasteInzethorModel.flensDiepte20,
                        OpmetingVasteInzethorModel.flensDiepte30,
                        OpmetingVasteInzethorModel.flensDiepte40,
                        OpmetingVasteInzethorModel.flensDiepte50,
                        OpmetingVasteInzethorModel.flensDiepte60,
                        OpmetingVasteInzethorModel.flensDiepteOpMaat,
                      ],
                      onChanged: (waarde) {
                        _wijzig(model.copyWith(flensDiepte: waarde));
                      },
                    ),
                    if (model.isFlensOpMaat) ...<Widget>[
                      _CompactGetalVeld(
                        titel: 'Flens diepte op maat (12 - 80)',
                        controller: _flensOpMaatController,
                        minimum: 12,
                        maximum: 80,
                        onChanged: (tekst) {
                          _wijzigGetal(tekst, (waarde) {
                            if (waarde >= 12 && waarde <= 80) {
                              _wijzig(
                                model.copyWith(flensDiepteOpMaatMm: waarde),
                              );
                            }
                          });
                        },
                      ),
                      _CompactDropdown(
                        titel: 'Maat rand flens',
                        waarde: model.maatRandFlens,
                        keuzes: const <String>[
                          OpmetingVasteInzethorModel.maatRandFlens8,
                          OpmetingVasteInzethorModel.maatRandFlens11,
                        ],
                        onChanged: (waarde) {
                          _wijzig(model.copyWith(maatRandFlens: waarde));
                        },
                      ),
                    ],
                  ],
                ],
                _CompactDropdown(
                  titel: 'Profiel',
                  waarde: model.profiel,
                  keuzes: const <String>[
                    OpmetingVasteInzethorModel.profielVr050,
                    OpmetingVasteInzethorModel.profielVr060,
                  ],
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(profiel: waarde));
                  },
                ),
                _CompactDropdown(
                  titel: 'Binnenmaten - Buitenmaten',
                  waarde: model.maatType,
                  keuzes: const <String>[
                    OpmetingVasteInzethorModel.maatTypeBinnen,
                    OpmetingVasteInzethorModel.maatTypeBuiten,
                  ],
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(maatType: waarde));
                  },
                ),
                _CompactGetalVeld(
                  titel: model.breedteTitel,
                  controller: _breedteController,
                  minimum: model.breedteMinimumMm,
                  maximum: model.breedteMaximumMm,
                  onChanged: (tekst) {
                    _wijzigGetal(tekst, (waarde) {
                      if (waarde >= model.breedteMinimumMm &&
                          waarde <= model.breedteMaximumMm) {
                        _wijzig(model.copyWith(breedteMm: waarde));
                      }
                    });
                  },
                ),
                _CompactGetalVeld(
                  titel: model.hoogteTitel,
                  controller: _hoogteController,
                  minimum: model.hoogteMinimumMm,
                  maximum: model.hoogteMaximumMm,
                  onChanged: (tekst) {
                    _wijzigGetal(tekst, (waarde) {
                      if (waarde >= model.hoogteMinimumMm &&
                          waarde <= model.hoogteMaximumMm) {
                        _wijzig(model.copyWith(hoogteMm: waarde));
                      }
                    });
                  },
                ),
                _MaatSamenvatting(model: model),
                _CompactDropdown(
                  titel: 'Aantal traversen',
                  waarde: model.traverseType,
                  keuzes: const <String>[
                    OpmetingVasteInzethorModel.traverseStandaard,
                    OpmetingVasteInzethorModel.traverseOpMaat,
                  ],
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(traverseType: waarde));
                  },
                ),
                if (!model.isTraverseOpMaat)
                  _StandaardTraverseSamenvatting(model: model)
                else ...<Widget>[
                  _CompactGetalVeld(
                    titel: 'Aantal traversen (1 - 3)',
                    controller: _aantalTraversenController,
                    minimum: 1,
                    maximum: 3,
                    onChanged: (tekst) {
                      _wijzigGetal(tekst, (waarde) {
                        if (waarde >= 1 && waarde <= 3) {
                          _wijzig(
                            model.copyWith(aantalTraversenOpMaat: waarde),
                          );
                        }
                      });
                    },
                  ),
                  ...List<Widget>.generate(
                    model.aantalTraversenOpMaat.clamp(1, 3),
                    (index) {
                      return _CompactGetalVeld(
                        titel: 'Hoogte traverse ${index + 1} (mm)',
                        controller: _traverseControllers[index],
                        minimum: 1,
                        maximum: model.hoogteMm - 1,
                        onChanged: (tekst) {
                          _wijzigGetal(tekst, (waarde) {
                            final posities = List<int>.from(
                              model.traversePositiesOpMaatMm,
                            );
                            while (posities.length < 3) {
                              posities.add(0);
                            }
                            posities[index] = waarde;
                            _wijzig(
                              model.copyWith(
                                traversePositiesOpMaatMm: posities,
                              ),
                            );
                          });
                        },
                      );
                    },
                  ),
                ],
                _CompactDropdown(
                  titel: 'Kleuren',
                  waarde: model.populaireKleur,
                  keuzes: const <String>[
                    OpmetingVasteInzethorModel.kleurAntraciet,
                    OpmetingVasteInzethorModel.kleurBruin,
                    OpmetingVasteInzethorModel.kleurZwart,
                    OpmetingVasteInzethorModel.kleurWit,
                    OpmetingVasteInzethorModel.kleurAnodiseNatuur,
                    OpmetingVasteInzethorModel.kleurPoederlak,
                    OpmetingVasteInzethorModel.kleurRalToebehoren,
                  ],
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
                if (model.isRalKleurToebehoren)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _lichtGroen,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: _rand),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.palette_outlined,
                          size: 16,
                          color: _groen,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            model.ralKleurToebehorenWaarde.trim().isEmpty
                                ? 'Nog geen RAL-kleur toebehoren ingevuld in het project.'
                                : model.ralKleurToebehorenWaarde.trim(),
                            style: const TextStyle(
                              color: _tekst,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (model.isPoederlak)
                  _CompactTekstVeld(
                    titel: 'Kleur poederlak',
                    controller: _poederlakController,
                    onChanged: (waarde) {
                      _wijzig(model.copyWith(poederlakKleur: waarde));
                    },
                  ),
                _CompactDropdown(
                  titel: 'Gaas',
                  waarde: model.gaasVoorOverzicht,
                  keuzes: const <String>[
                    OpmetingVasteInzethorModel.gaasStandaard,
                    OpmetingVasteInzethorModel.gaasPetscreen,
                    OpmetingVasteInzethorModel.gaasInox,
                    OpmetingVasteInzethorModel.gaasGeen,
                  ],
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(gaas: waarde));
                  },
                ),
                _CompactDropdown(
                  titel: 'Kleur pees',
                  waarde: model.kleurPees,
                  keuzes: const <String>[
                    OpmetingVasteInzethorModel.peesZwart,
                    OpmetingVasteInzethorModel.peesGrijs,
                  ],
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(kleurPees: waarde));
                  },
                ),
                _CompactDropdown(
                  titel: 'Borstels',
                  waarde: model.borstels,
                  keuzes: const <String>[
                    OpmetingVasteInzethorModel.borstelsGeen,
                    OpmetingVasteInzethorModel.borstelsVp1200,
                  ],
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(borstels: waarde));
                  },
                ),
                _CompactDropdown(
                  titel: 'Bevestiging',
                  waarde: model.bevestiging,
                  keuzes: const <String>[
                    OpmetingVasteInzethorModel.bevestigingClipsenZakje,
                    OpmetingVasteInzethorModel.bevestigingClipsenGemonteerd,
                    OpmetingVasteInzethorModel.bevestigingGeenClipsen,
                  ],
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(bevestiging: waarde));
                  },
                ),
                if (model.heeftClipsen) ...<Widget>[
                  _CompactDropdown(
                    titel: 'Soort clipsen',
                    waarde: model.soortClipsen,
                    keuzes: const <String>[
                      OpmetingVasteInzethorModel.clipsenStandaard,
                      OpmetingVasteInzethorModel.clipsenMaritiem,
                    ],
                    onChanged: (waarde) {
                      _wijzig(model.copyWith(soortClipsen: waarde));
                    },
                  ),
                  _CompactDropdown(
                    titel: 'Soort bevestiging',
                    waarde: model.soortBevestiging,
                    keuzes: _soortBevestigingKeuzes,
                    onChanged: (waarde) {
                      _wijzig(model.copyWith(soortBevestiging: waarde));
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactDropdown extends StatelessWidget {
  const _CompactDropdown({
    required this.titel,
    required this.waarde,
    required this.keuzes,
    required this.onChanged,
  });

  final String titel;
  final String waarde;
  final List<String> keuzes;
  final ValueChanged<String> onChanged;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekst = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DropdownButtonFormField<String>(
        value: keuzes.contains(waarde) ? waarde : keuzes.first,
        isExpanded: true,
        menuMaxHeight: 360,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _groen),
        style: const TextStyle(
          color: _tekst,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          labelText: titel,
          labelStyle: const TextStyle(
            color: _groen,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
          floatingLabelStyle: const TextStyle(
            color: _groen,
            fontWeight: FontWeight.w900,
          ),
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: _rand),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: _groen, width: 1.5),
          ),
        ),
        items: keuzes
            .map((keuze) {
              return DropdownMenuItem<String>(
                value: keuze,
                child: Text(
                  keuze,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            })
            .toList(growable: false),
        onChanged: (waarde) {
          if (waarde != null) {
            onChanged(waarde);
          }
        },
      ),
    );
  }
}

class _CompactTekstVeld extends StatelessWidget {
  const _CompactTekstVeld({
    required this.titel,
    required this.controller,
    required this.onChanged,
  });

  final String titel;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _CompactVeldBasis(
      titel: titel,
      controller: controller,
      onChanged: onChanged,
    );
  }
}

class _CompactGetalVeld extends StatelessWidget {
  const _CompactGetalVeld({
    required this.titel,
    required this.controller,
    required this.onChanged,
    this.minimum,
    this.maximum,
  });

  final String titel;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int? minimum;
  final int? maximum;

  @override
  Widget build(BuildContext context) {
    return _CompactVeldBasis(
      titel: titel,
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (tekst) {
        final waarde = int.tryParse((tekst ?? '').trim());
        if (waarde == null) {
          return 'Geef een geldig getal in';
        }
        if (minimum != null && waarde < minimum!) {
          return 'Minimum $minimum';
        }
        if (maximum != null && waarde > maximum!) {
          return 'Maximum $maximum';
        }
        return null;
      },
      onChanged: onChanged,
    );
  }
}

class _CompactVeldBasis extends StatelessWidget {
  const _CompactVeldBasis({
    required this.titel,
    required this.controller,
    required this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  final String titel;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: validator,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          labelText: titel,
          labelStyle: const TextStyle(
            color: _groen,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
          floatingLabelStyle: const TextStyle(
            color: _groen,
            fontWeight: FontWeight.w900,
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: _rand),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: _groen, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: Color(0xFFDC2626)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _MaatSamenvatting extends StatelessWidget {
  const _MaatSamenvatting({required this.model});

  final OpmetingVasteInzethorModel model;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: _lichtGroen,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFCDEBD6)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.straighten_rounded, color: _groen, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  model.maatSamenvattingTitel,
                  style: const TextStyle(
                    color: _groen,
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

class _StandaardTraverseSamenvatting extends StatelessWidget {
  const _StandaardTraverseSamenvatting({required this.model});

  final OpmetingVasteInzethorModel model;

  @override
  Widget build(BuildContext context) {
    final posities = model.standaardTraversePositiesMm;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              padding: EdgeInsets.only(top: index == 0 ? 0 : 4),
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
      ),
    );
  }
}
