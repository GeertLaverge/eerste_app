import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'opmeting_vliegendeur_model.dart';

class OpmetingVliegendeurRechterkolom extends StatefulWidget {
  const OpmetingVliegendeurRechterkolom({
    super.key,
    required this.model,
    required this.onGewijzigd,
    this.projectRalKleur = '',
  });

  final OpmetingVliegendeurModel model;
  final ValueChanged<OpmetingVliegendeurModel> onGewijzigd;
  final String projectRalKleur;

  @override
  State<OpmetingVliegendeurRechterkolom> createState() {
    return _OpmetingVliegendeurRechterkolomState();
  }
}

class _OpmetingVliegendeurRechterkolomState
    extends State<OpmetingVliegendeurRechterkolom> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekst = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  late final TextEditingController _stukReferentieController;
  late final TextEditingController _aantalController;
  late final TextEditingController _breedteController;
  late final TextEditingController _hoogteController;
  late final TextEditingController _aantalTraversenController;
  late final List<TextEditingController> _doorgangHoogteControllers;
  late final TextEditingController _poederlakController;
  late final TextEditingController _schopplaatHoogteController;

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
    _aantalTraversenController = TextEditingController(
      text: model.aantalTraversen.toString(),
    );
    _doorgangHoogteControllers = List<TextEditingController>.generate(
      OpmetingVliegendeurModel.aantalTraversenMaximum,
      (index) {
        final waarde = index < model.actieveDoorgangHoogtesMm.length
            ? model.actieveDoorgangHoogtesMm[index]
            : 0;
        return TextEditingController(
          text: waarde <= 0 ? '' : waarde.toString(),
        );
      },
    );
    _poederlakController = TextEditingController(text: model.poederlakKleur);
    _schopplaatHoogteController = TextEditingController(
      text: model.schopplaatHoogteOpMaatMm.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant OpmetingVliegendeurRechterkolom oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model.aantalTraversen != widget.model.aantalTraversen) {
      _aantalTraversenController.text = widget.model.aantalTraversen.toString();
      final hoogtes = widget.model.actieveDoorgangHoogtesMm;
      for (var index = 0; index < _doorgangHoogteControllers.length; index++) {
        final tekst = index < hoogtes.length ? hoogtes[index].toString() : '';
        if (_doorgangHoogteControllers[index].text != tekst) {
          _doorgangHoogteControllers[index].text = tekst;
        }
      }
    }
  }

  @override
  void dispose() {
    _stukReferentieController.dispose();
    _aantalController.dispose();
    _breedteController.dispose();
    _hoogteController.dispose();
    _aantalTraversenController.dispose();
    for (final controller in _doorgangHoogteControllers) {
      controller.dispose();
    }
    _poederlakController.dispose();
    _schopplaatHoogteController.dispose();
    super.dispose();
  }

  void _wijzig(OpmetingVliegendeurModel model) {
    widget.onGewijzigd(model);
  }

  void _wijzigGetal({
    required String tekst,
    required int minimum,
    required int maximum,
    required ValueChanged<int> onGeldig,
  }) {
    final waarde = int.tryParse(tekst.trim());
    if (waarde == null || waarde < minimum || waarde > maximum) {
      return;
    }
    onGeldig(waarde);
  }

  void _wijzigAantalTraversen(String tekst) {
    final model = widget.model;
    _wijzigGetal(
      tekst: tekst,
      minimum: 1,
      maximum: OpmetingVliegendeurModel.aantalTraversenMaximum,
      onGeldig: (waarde) {
        final hoogtes = List<int>.from(model.actieveDoorgangHoogtesMm);
        while (hoogtes.length < waarde) {
          final index = hoogtes.length;
          final standaard =
              ((model.hoogteMm -
                          (OpmetingVliegendeurModel.deurProfielAanzichtMm *
                              2)) *
                      ((index + 1) / (waarde + 1)))
                  .round();
          hoogtes.add(standaard);
        }
        _wijzig(
          model.copyWith(
            aantalTraversen: waarde,
            doorgangHoogtesMm: hoogtes.take(waarde).toList(growable: false),
          ),
        );
      },
    );
  }

  void _wijzigDoorgangHoogte(int index, String tekst) {
    final model = widget.model;
    _wijzigGetal(
      tekst: tekst,
      minimum: 100,
      maximum: model.hoogteMm - 150,
      onGeldig: (waarde) {
        final hoogtes = List<int>.from(model.actieveDoorgangHoogtesMm);
        while (hoogtes.length <= index) {
          hoogtes.add(waarde);
        }
        hoogtes[index] = waarde;
        _wijzig(model.copyWith(doorgangHoogtesMm: hoogtes));
      },
    );
  }

  String _kleurVoorWeergave(OpmetingVliegendeurModel model) {
    if (!model.isProjectKleur) {
      return model.kleurVoorOverzicht;
    }

    final projectkleur = widget.projectRalKleur.trim();
    return projectkleur.isEmpty
        ? OpmetingVliegendeurModel.kleurNogTeBepalen
        : projectkleur;
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
                Icon(Icons.door_front_door_outlined, size: 19, color: _groen),
                SizedBox(width: 8),
                Text(
                  'Vliegendeur',
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
                      minimum: OpmetingVliegendeurModel.aantalMinimum,
                      maximum: OpmetingVliegendeurModel.aantalMaximum,
                      onChanged: (tekst) {
                        _wijzigGetal(
                          tekst: tekst,
                          minimum: OpmetingVliegendeurModel.aantalMinimum,
                          maximum: OpmetingVliegendeurModel.aantalMaximum,
                          onGeldig: (waarde) {
                            _wijzig(model.copyWith(aantal: waarde));
                          },
                        );
                      },
                    ),
                    _CompactGetalVeld(
                      titel: 'Breedte (buitenmaat) (600 - 2000)',
                      controller: _breedteController,
                      minimum: OpmetingVliegendeurModel.breedteMinimumMm,
                      maximum: OpmetingVliegendeurModel.breedteMaximumMm,
                      eenheid: 'mm',
                      onChanged: (tekst) {
                        _wijzigGetal(
                          tekst: tekst,
                          minimum: OpmetingVliegendeurModel.breedteMinimumMm,
                          maximum: OpmetingVliegendeurModel.breedteMaximumMm,
                          onGeldig: (waarde) {
                            _wijzig(model.copyWith(breedteMm: waarde));
                          },
                        );
                      },
                    ),
                    _CompactGetalVeld(
                      titel: 'Hoogte (buitenmaat) (1600 - 2800)',
                      controller: _hoogteController,
                      minimum: OpmetingVliegendeurModel.hoogteMinimumMm,
                      maximum: OpmetingVliegendeurModel.hoogteMaximumMm,
                      eenheid: 'mm',
                      onChanged: (tekst) {
                        _wijzigGetal(
                          tekst: tekst,
                          minimum: OpmetingVliegendeurModel.hoogteMinimumMm,
                          maximum: OpmetingVliegendeurModel.hoogteMaximumMm,
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
                  keuzes: OpmetingVliegendeurModel.soortKeuzes,
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(soort: waarde));
                  },
                ),
                _KeuzeSectie(
                  titel: 'Standaard Traverse',
                  waarde: model.traverseType,
                  keuzes: OpmetingVliegendeurModel.traverseKeuzes,
                  onChanged: (waarde) {
                    if (waarde == OpmetingVliegendeurModel.traverseStandaard) {
                      _aantalTraversenController.text = '1';
                      _doorgangHoogteControllers[0].text = '877';
                      for (
                        var index = 1;
                        index < _doorgangHoogteControllers.length;
                        index++
                      ) {
                        _doorgangHoogteControllers[index].clear();
                      }
                      _wijzig(
                        model.copyWith(
                          traverseType: waarde,
                          aantalTraversen: 1,
                          doorgangHoogtesMm: const <int>[877],
                        ),
                      );
                    } else {
                      _wijzig(model.copyWith(traverseType: waarde));
                    }
                  },
                ),
                _SectieKaart(
                  titel: 'Traversen',
                  children: <Widget>[
                    _CompactGetalVeld(
                      titel: 'Aantal Traversen',
                      controller: _aantalTraversenController,
                      minimum: 1,
                      maximum: OpmetingVliegendeurModel.aantalTraversenMaximum,
                      enabled: model.isTraverseOpMaat,
                      onChanged: _wijzigAantalTraversen,
                    ),
                    ...List<Widget>.generate(
                      model.aantalTraversen
                          .clamp(
                            1,
                            OpmetingVliegendeurModel.aantalTraversenMaximum,
                          )
                          .toInt(),
                      (index) {
                        return _CompactGetalVeld(
                          titel: 'Doorganghoogte ${index + 1}',
                          controller: _doorgangHoogteControllers[index],
                          minimum: 100,
                          maximum: model.hoogteMm - 150,
                          eenheid: 'mm',
                          enabled: model.isTraverseOpMaat,
                          onChanged: (tekst) {
                            _wijzigDoorgangHoogte(index, tekst);
                          },
                        );
                      },
                    ),
                  ],
                ),
                _KeuzeSectie(
                  titel: 'Kleursoort',
                  waarde: model.kleursoort,
                  keuzes: OpmetingVliegendeurModel.kleursoortKeuzes,
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(kleursoort: waarde));
                  },
                ),
                if (model.isPoederlak)
                  _SectieKaart(
                    titel: 'Poederlak',
                    children: <Widget>[
                      _CompactTekstVeld(
                        titel: 'Kleur poederlak',
                        controller: _poederlakController,
                        onChanged: (waarde) {
                          _wijzig(model.copyWith(poederlakKleur: waarde));
                        },
                      ),
                    ],
                  ),
                _InformatieKaart(
                  titel: 'Kleur',
                  waarde: _kleurVoorWeergave(model),
                ),
                _KeuzeSectie(
                  titel: 'Kleur PVC',
                  waarde: model.kleurPvc,
                  keuzes: OpmetingVliegendeurModel.kleurPvcKeuzes,
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(kleurPvc: waarde));
                  },
                ),
                _KeuzeSectie(
                  titel: 'Kaderuitvoering',
                  waarde: model.kaderuitvoering,
                  keuzes: OpmetingVliegendeurModel.kaderuitvoeringKeuzes,
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(kaderuitvoering: waarde));
                  },
                ),
                _KeuzeSectie(
                  titel: 'Scharnierkant (van buiten gekeken)',
                  waarde: model.scharnierkant,
                  keuzes: OpmetingVliegendeurModel.scharnierkantKeuzes,
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(scharnierkant: waarde));
                  },
                ),
                _KeuzeSectie(
                  titel: 'Dierenluik',
                  waarde: model.dierenluik,
                  keuzes: OpmetingVliegendeurModel.dierenluikKeuzes,
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(dierenluik: waarde));
                  },
                ),
                _KeuzeSectie(
                  titel: 'Schopplaat',
                  waarde: model.schopplaat,
                  keuzes: OpmetingVliegendeurModel.schopplaatKeuzes,
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(schopplaat: waarde));
                  },
                ),
                if (model.isSchopplaatOpMaat)
                  _SectieKaart(
                    titel: 'Schopplaat op maat',
                    children: <Widget>[
                      _CompactGetalVeld(
                        titel: 'Hoogte op maat',
                        controller: _schopplaatHoogteController,
                        minimum: 100,
                        maximum: model.actieveDoorgangHoogtesMm.first,
                        eenheid: 'mm',
                        onChanged: (tekst) {
                          _wijzigGetal(
                            tekst: tekst,
                            minimum: 100,
                            maximum: model.actieveDoorgangHoogtesMm.first,
                            onGeldig: (waarde) {
                              _wijzig(
                                model.copyWith(
                                  schopplaatHoogteOpMaatMm: waarde,
                                ),
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
                  keuzes: OpmetingVliegendeurModel.gaasKeuzes,
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(gaas: waarde));
                  },
                ),
                _KeuzeSectie(
                  titel: 'Gaas onder T1',
                  waarde: model.gaasOnderT1,
                  keuzes: OpmetingVliegendeurModel.gaasKeuzes,
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(gaasOnderT1: waarde));
                  },
                ),
                _KeuzeSectie(
                  titel: 'Sluiting',
                  waarde: model.sluiting,
                  keuzes: OpmetingVliegendeurModel.sluitingKeuzes,
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(sluiting: waarde));
                  },
                ),
                _KeuzeSectie(
                  titel: 'Pomp',
                  waarde: model.pomp,
                  keuzes: OpmetingVliegendeurModel.pompKeuzes,
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(pomp: waarde));
                  },
                ),
                _KeuzeSectie(
                  titel: 'Afdekkappen',
                  waarde: model.afdekkappen,
                  keuzes: OpmetingVliegendeurModel.afdekkappenKeuzes,
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(afdekkappen: waarde));
                  },
                ),
                _KeuzeSectie(
                  titel: 'Kleur Pees',
                  waarde: model.kleurPees,
                  keuzes: OpmetingVliegendeurModel.kleurPeesKeuzes,
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(kleurPees: waarde));
                  },
                ),
                _KeuzeSectie(
                  titel: 'Kleur borstel',
                  waarde: model.kleurBorstel,
                  keuzes: OpmetingVliegendeurModel.kleurBorstelKeuzes,
                  onChanged: (waarde) {
                    _wijzig(model.copyWith(kleurBorstel: waarde));
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
        border: Border.all(color: _OpmetingVliegendeurRechterkolomState._rand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            titel,
            style: const TextStyle(
              color: _OpmetingVliegendeurRechterkolomState._groen,
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
  });

  final String titel;
  final String waarde;
  final List<String> keuzes;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SectieKaart(
      titel: titel,
      children: keuzes
          .map((keuze) {
            return RadioListTile<String>(
              value: keuze,
              groupValue: waarde,
              onChanged: (nieuw) {
                if (nieuw != null) onChanged(nieuw);
              },
              activeColor: _OpmetingVliegendeurRechterkolomState._groen,
              dense: true,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              contentPadding: EdgeInsets.zero,
              title: Text(
                keuze,
                style: const TextStyle(
                  color: _OpmetingVliegendeurRechterkolomState._tekst,
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
              color: _OpmetingVliegendeurRechterkolomState._tekst,
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
                color: _OpmetingVliegendeurRechterkolomState._tekstGrijs,
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
              color: _OpmetingVliegendeurRechterkolomState._tekst,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
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
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
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
              color: _OpmetingVliegendeurRechterkolomState._groen,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            waarde,
            style: const TextStyle(
              color: _OpmetingVliegendeurRechterkolomState._tekst,
              fontSize: 12,
              fontWeight: FontWeight.w800,
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
        color: _OpmetingVliegendeurRechterkolomState._rand,
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: _OpmetingVliegendeurRechterkolomState._groen,
        width: 1.4,
      ),
    ),
  );
}
