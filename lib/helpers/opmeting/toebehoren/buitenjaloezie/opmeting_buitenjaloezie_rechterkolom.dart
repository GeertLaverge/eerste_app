// THIMACO-CONTROLE: BUITENJALOEZIE-KASTKEUZE-COMPACT-165-185-20260804
// THIMACO-CONTROLE: BUITENJALOEZIE-DEFINITIEVE-RECHTERKOLOM-20260803
// THIMACO-CONTROLE: BUITENJALOEZIE-INVOER-EN-KEUZEMENUS-CORRECTIE-20260803
// THIMACO-CONTROLE: BUITENJALOEZIE-RECHTERKOLOM-RADIOKNOPPEN-20260803

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'opmeting_buitenjaloezie_instellingen_model.dart';
import 'opmeting_buitenjaloezie_kasthoogte_helper.dart';
import 'opmeting_buitenjaloezie_model.dart';

class OpmetingBuitenjaloezieRechterkolom extends StatefulWidget {
  const OpmetingBuitenjaloezieRechterkolom({
    super.key,
    required this.model,
    required this.instellingen,
    required this.onChanged,
  });

  final OpmetingBuitenjaloezieModel model;
  final OpmetingBuitenjaloezieInstellingen instellingen;
  final ValueChanged<OpmetingBuitenjaloezieModel> onChanged;

  @override
  State<OpmetingBuitenjaloezieRechterkolom> createState() =>
      _OpmetingBuitenjaloezieRechterkolomState();
}

class _OpmetingBuitenjaloezieRechterkolomState
    extends State<OpmetingBuitenjaloezieRechterkolom> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekst = Color(0xFF1F2937);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  late final TextEditingController _referentieController;
  late final TextEditingController _aantalController;
  late final TextEditingController _breedteController;
  late final TextEditingController _hoogteController;
  final TextEditingController _kleurZoekController = TextEditingController();
  late final TextEditingController _afschuiningController;

  @override
  void initState() {
    super.initState();
    _referentieController = TextEditingController(
      text: widget.model.referentie,
    );
    _aantalController = TextEditingController(
      text: widget.model.aantal.toString(),
    );
    _breedteController = TextEditingController(
      text: widget.model.breedteMm.toString(),
    );
    _hoogteController = TextEditingController(
      text: widget.model.hoogteMm.toString(),
    );
    _afschuiningController = TextEditingController(
      text: widget.model.afschuiningGeleidersGraden.toString(),
    );

    _kleurZoekController.addListener(_ververs);
  }

  @override
  void didUpdateWidget(covariant OpmetingBuitenjaloezieRechterkolom oldWidget) {
    super.didUpdateWidget(oldWidget);
    _synchroniseerController(_referentieController, widget.model.referentie);
    _synchroniseerController(_aantalController, widget.model.aantal.toString());
    _synchroniseerController(
      _breedteController,
      widget.model.breedteMm.toString(),
    );
    _synchroniseerController(
      _hoogteController,
      widget.model.hoogteMm.toString(),
    );
    _synchroniseerController(
      _afschuiningController,
      widget.model.afschuiningGeleidersGraden.toString(),
    );
  }

  @override
  void dispose() {
    _kleurZoekController.removeListener(_ververs);
    _referentieController.dispose();
    _aantalController.dispose();
    _breedteController.dispose();
    _hoogteController.dispose();
    _kleurZoekController.dispose();
    _afschuiningController.dispose();
    super.dispose();
  }

  void _ververs() {
    if (mounted) setState(() {});
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

  void _wijzig(OpmetingBuitenjaloezieModel nieuwModel) {
    final gesynchroniseerd = _synchroniseerAfhankelijkeKeuzes(nieuwModel);
    final berekend = OpmetingBuitenjaloezieKasthoogteHelper.pasAutomatischToe(
      gesynchroniseerd,
    );
    widget.onChanged(_synchroniseerAfhankelijkeKeuzes(berekend));
  }

  OpmetingBuitenjaloezieModel _synchroniseerAfhankelijkeKeuzes(
    OpmetingBuitenjaloezieModel model,
  ) {
    var resultaat = model;

    final kleuren = widget.instellingen.kleurenVoor(resultaat.lameltype);
    final huidigeKleurGeldig = kleuren.any(
      (kleur) => kleur.code == resultaat.lamelkleurCode,
    );

    if (!huidigeKleurGeldig && kleuren.isNotEmpty) {
      final kleur = kleuren.first;
      resultaat = resultaat.copyWith(
        lamelkleurCode: kleur.code,
        lamelkleurNaam: kleur.naam,
        lamelkleurHex: kleur.hexKleur,
      );
    }

    final geleiders = widget.instellingen.geleidersVoor(resultaat.lameltype);
    final huidigeGeleiderGeldig = geleiders.any(
      (geleider) => geleider.code == resultaat.geleiderCode,
    );

    if (!huidigeGeleiderGeldig && geleiders.isNotEmpty) {
      final standaardCode =
          resultaat.lameltype == OpmetingBuitenjaloezieLameltype.cdl70
          ? '12'
          : geleiders.first.code;
      final geleider = geleiders.firstWhere(
        (item) => item.code == standaardCode,
        orElse: () => geleiders.first,
      );
      resultaat = resultaat.copyWith(
        geleiderCode: geleider.code,
        geleiderOmschrijving: geleider.omschrijving,
        geleiderBreedteMm: geleider.breedteMm,
      );
    }

    if (resultaat.lameltype == OpmetingBuitenjaloezieLameltype.fl80 &&
        resultaat.systeem.metRolhor) {
      resultaat = resultaat.copyWith(
        lameltype: OpmetingBuitenjaloezieLameltype.cdl70,
      );
    }

    if (!resultaat.systeem.isModulo &&
        resultaat.lameltype != OpmetingBuitenjaloezieLameltype.dbl70 &&
        resultaat.lameltype != OpmetingBuitenjaloezieLameltype.gl80) {
      resultaat = resultaat.copyWith(
        lameltype: OpmetingBuitenjaloezieLameltype.dbl70,
      );
    }

    if (!resultaat.systeem.isModulo && resultaat.klinkeruitvoering) {
      resultaat = resultaat.copyWith(klinkeruitvoering: false);
    }

    return resultaat;
  }

  @override
  Widget build(BuildContext context) {
    final kastResultaat = OpmetingBuitenjaloezieKasthoogteHelper.bereken(
      systeem: widget.model.systeem,
      lameltype: widget.model.lameltype,
      ingegevenHoogteMm: widget.model.hoogteMm,
      hoogteInclusiefKast: widget.model.hoogteInclusiefKast,
    );
    final raffstoreOpties = widget.model.systeem.isModulo
        ? const <OpmetingBuitenjaloezieKastResultaat>[]
        : OpmetingBuitenjaloezieKasthoogteHelper.berekenRaffstoreOpties(
            systeem: widget.model.systeem,
            lameltype: widget.model.lameltype,
            ingegevenHoogteMm: widget.model.hoogteMm,
            hoogteInclusiefKast: widget.model.hoogteInclusiefKast,
          );

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
      children: <Widget>[
        _sectie(
          titel: 'Referentie en maten',
          kinderen: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: _invoerVeld(
                    label: 'Referentie',
                    controller: _referentieController,
                    onChanged: (waarde) {
                      _wijzig(widget.model.copyWith(referentie: waarde));
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _invoerVeld(
                    label: 'Aantal',
                    controller: _aantalController,
                    numeriek: true,
                    onChanged: (waarde) {
                      final aantal = int.tryParse(waarde);
                      if (aantal == null) return;
                      _wijzig(widget.model.copyWith(aantal: aantal));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _keuzeTitel('Breedtemaat'),
            _radio<bool>(
              waarde: true,
              groepWaarde: widget.model.breedteTussenGeleiders,
              titel: 'Tussen de geleiders',
              subtitel: 'De ingegeven maat is de vrije breedte.',
              onChanged: (waarde) {
                _wijzig(widget.model.copyWith(breedteTussenGeleiders: waarde));
              },
            ),
            _radio<bool>(
              waarde: false,
              groepWaarde: widget.model.breedteTussenGeleiders,
              titel: 'Inclusief geleiders',
              subtitel: 'De ingegeven maat is de totale buitenbreedte.',
              onChanged: (waarde) {
                _wijzig(widget.model.copyWith(breedteTussenGeleiders: waarde));
              },
            ),
            const SizedBox(height: 10),
            _keuzeTitel('Hoogtemaat'),
            _radio<bool>(
              waarde: true,
              groepWaarde: widget.model.hoogteInclusiefKast,
              titel: 'Inclusief kast',
              subtitel: 'De kast zit al in de ingegeven totale hoogte.',
              onChanged: (waarde) {
                _wijzig(widget.model.copyWith(hoogteInclusiefKast: waarde));
              },
            ),
            _radio<bool>(
              waarde: false,
              groepWaarde: widget.model.hoogteInclusiefKast,
              titel: 'Exclusief kast',
              subtitel: 'De berekende kasthoogte wordt bijgeteld.',
              onChanged: (waarde) {
                _wijzig(widget.model.copyWith(hoogteInclusiefKast: waarde));
              },
            ),
            const SizedBox(height: 10),
            _invoerVeld(
              label: 'Breedte',
              suffix: 'mm',
              controller: _breedteController,
              numeriek: true,
              onChanged: (waarde) {
                final breedte = int.tryParse(waarde);
                if (breedte == null ||
                    breedte < OpmetingBuitenjaloezieModel.breedteMinimumMm ||
                    breedte > OpmetingBuitenjaloezieModel.breedteMaximumMm) {
                  return;
                }
                _wijzig(widget.model.copyWith(breedteMm: breedte));
              },
            ),
            const SizedBox(height: 8),
            _invoerVeld(
              label: 'Hoogte',
              suffix: 'mm',
              controller: _hoogteController,
              numeriek: true,
              onChanged: (waarde) {
                final hoogte = int.tryParse(waarde);
                if (hoogte == null ||
                    hoogte < OpmetingBuitenjaloezieModel.hoogteMinimumMm ||
                    hoogte > OpmetingBuitenjaloezieModel.hoogteMaximumMm) {
                  return;
                }
                _wijzig(widget.model.copyWith(hoogteMm: hoogte));
              },
            ),
            const SizedBox(height: 12),
            _berekendeMaatKaart(kastResultaat, raffstoreOpties),
          ],
        ),
        const SizedBox(height: 14),
        _sectie(
          titel: 'Systeem',
          kinderen: OpmetingBuitenjaloezieSysteem.values
              .map((systeem) {
                return _radio<OpmetingBuitenjaloezieSysteem>(
                  waarde: systeem,
                  groepWaarde: widget.model.systeem,
                  titel: systeem.label,
                  subtitel: systeem.omschrijving,
                  onChanged: (waarde) {
                    _wijzig(widget.model.copyWith(systeem: waarde));
                  },
                );
              })
              .toList(growable: false),
        ),
        const SizedBox(height: 14),
        _sectie(
          titel: 'Lameltype',
          kinderen: OpmetingBuitenjaloezieLameltype.values
              .map((lameltype) {
                final isRaffstore = !widget.model.systeem.isModulo;
                final nietBeschikbaar =
                    (widget.model.systeem.metRolhor &&
                        lameltype == OpmetingBuitenjaloezieLameltype.fl80) ||
                    (isRaffstore &&
                        lameltype != OpmetingBuitenjaloezieLameltype.dbl70 &&
                        lameltype != OpmetingBuitenjaloezieLameltype.gl80);

                return _radio<OpmetingBuitenjaloezieLameltype>(
                  waarde: lameltype,
                  groepWaarde: widget.model.lameltype,
                  titel: lameltype.label,
                  subtitel: nietBeschikbaar
                      ? isRaffstore
                            ? 'Volgens de beschikbare Raffstore-tabel enkel DBL 70 '
                                  'en GL 80.'
                            : 'Niet beschikbaar bij een XP-uitvoering'
                      : lameltype.alleenStaaldraad
                      ? 'Enkel bij staaldraad'
                      : 'Gekraalde uitvoering',
                  ingeschakeld: !nietBeschikbaar,
                  onChanged: (waarde) {
                    _wijzig(widget.model.copyWith(lameltype: waarde));
                  },
                );
              })
              .toList(growable: false),
        ),
        const SizedBox(height: 14),
        _kleurSectie(),
        const SizedBox(height: 14),
        _sectie(
          titel: 'Ladderkoord',
          kinderen: OpmetingBuitenjaloezieLadderkoord.values
              .map((keuze) {
                return _radio<OpmetingBuitenjaloezieLadderkoord>(
                  waarde: keuze,
                  groepWaarde: widget.model.ladderkoord,
                  titel: keuze.label,
                  onChanged: (waarde) {
                    _wijzig(widget.model.copyWith(ladderkoord: waarde));
                  },
                );
              })
              .toList(growable: false),
        ),
        const SizedBox(height: 14),
        _sectie(
          titel: 'Motor en bediening',
          kinderen: <Widget>[
            _keuzeTitel('Type motor'),
            ...OpmetingBuitenjaloezieMotorType.values.map((keuze) {
              return _radio<OpmetingBuitenjaloezieMotorType>(
                waarde: keuze,
                groepWaarde: widget.model.motorType,
                titel: keuze.label,
                onChanged: (waarde) {
                  _wijzig(widget.model.copyWith(motorType: waarde));
                },
              );
            }),
            const SizedBox(height: 10),
            _keuzeTitel('Bediening'),
            ...widget.instellingen.bedieningen.map((bediening) {
              return _radio<String>(
                waarde: bediening,
                groepWaarde: widget.model.bediening,
                titel: bediening,
                onChanged: (waarde) {
                  _wijzig(widget.model.copyWith(bediening: waarde));
                },
              );
            }),
            const SizedBox(height: 10),
            _keuzeTitel('Motorkabel'),
            ...widget.instellingen.motorkabelLengtes.map((lengte) {
              return _radio<int>(
                waarde: lengte,
                groepWaarde: widget.model.motorkabelMeter,
                titel: '$lengte m',
                onChanged: (waarde) {
                  _wijzig(widget.model.copyWith(motorkabelMeter: waarde));
                },
              );
            }),
            const SizedBox(height: 10),
            _keuzeTitel('Bedieningszijde · van binnen gezien'),
            ...OpmetingBuitenjaloezieBedieningszijde.values.map((zijde) {
              return _radio<OpmetingBuitenjaloezieBedieningszijde>(
                waarde: zijde,
                groepWaarde: widget.model.bedieningszijde,
                titel: zijde.label,
                onChanged: (waarde) {
                  _wijzig(widget.model.copyWith(bedieningszijde: waarde));
                },
              );
            }),
            const SizedBox(height: 10),
            _keuzeTitel('Kabeluitgang'),
            ...<int>[1, 2, 3, 4].map((uitgang) {
              return _radio<int>(
                waarde: uitgang,
                groepWaarde: widget.model.kabeluitgang,
                titel: 'Uitgang $uitgang',
                onChanged: (waarde) {
                  _wijzig(widget.model.copyWith(kabeluitgang: waarde));
                },
              );
            }),
          ],
        ),
        const SizedBox(height: 14),
        _geleiderSectie(),
        const SizedBox(height: 14),
        _sectie(
          titel: 'Montage',
          kinderen: <Widget>[
            _keuzeTitel('Boring'),
            ...OpmetingBuitenjaloezieBoring.values.map((boring) {
              return _radio<OpmetingBuitenjaloezieBoring>(
                waarde: boring,
                groepWaarde: widget.model.boring,
                titel: boring.label,
                onChanged: (waarde) {
                  _wijzig(widget.model.copyWith(boring: waarde));
                },
              );
            }),
            const SizedBox(height: 10),
            _keuzeTitel('Afschuining geleiders'),
            SizedBox(
              width: 140,
              child: _invoerVeld(
                label: 'Afschuining',
                suffix: '°',
                controller: _afschuiningController,
                numeriek: true,
                onChanged: (waarde) {
                  final graden = int.tryParse(waarde);
                  if (graden == null || graden < 0 || graden > 45) return;
                  _wijzig(
                    widget.model.copyWith(afschuiningGeleidersGraden: graden),
                  );
                },
              ),
            ),
            if (widget.model.systeem.isModulo) ...<Widget>[
              const SizedBox(height: 10),
              _keuzeTitel('Klinkeruitvoering'),
              _jaNeen(
                waarde: widget.model.klinkeruitvoering,
                onChanged: (waarde) {
                  _wijzig(widget.model.copyWith(klinkeruitvoering: waarde));
                },
              ),
            ],
            const SizedBox(height: 10),
            _keuzeTitel('Onder gesloten'),
            _jaNeen(
              waarde: widget.model.onderGesloten,
              onChanged: (waarde) {
                _wijzig(widget.model.copyWith(onderGesloten: waarde));
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _kleurSectie() {
    final zoekterm = _kleurZoekController.text.trim().toLowerCase();
    final kleuren = widget.instellingen
        .kleurenVoor(widget.model.lameltype)
        .where((kleur) {
          if (zoekterm.isEmpty) return true;
          return kleur.label.toLowerCase().contains(zoekterm);
        })
        .toList(growable: false);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rand),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        iconColor: _groen,
        collapsedIconColor: _tekstGrijs,
        title: const Text(
          'Kleur lamellen',
          style: TextStyle(
            color: _tekst,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Row(
          children: <Widget>[
            _kleurBol(widget.model.lamelkleurHex),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.model.lamelkleurSamenvatting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _tekstGrijs,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        children: <Widget>[
          _zoekVeld(
            controller: _kleurZoekController,
            hint: 'Zoeken op kleur of code',
          ),
          const SizedBox(height: 8),
          if (kleuren.isEmpty)
            const _LegeZoekmelding(tekst: 'Geen passende kleuren gevonden.')
          else
            ...kleuren.map((kleur) {
              final geselecteerd = kleur.code == widget.model.lamelkleurCode;
              return ListTile(
                onTap: () {
                  _wijzig(
                    widget.model.copyWith(
                      lamelkleurCode: kleur.code,
                      lamelkleurNaam: kleur.naam,
                      lamelkleurHex: kleur.hexKleur,
                    ),
                  );
                },
                leading: Icon(
                  geselecteerd
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: geselecteerd ? _groen : _tekstGrijs,
                ),
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Row(
                  children: <Widget>[
                    _kleurBol(kleur.hexKleur),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        kleur.label,
                        style: const TextStyle(
                          color: _tekst,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (kleur.optioneel)
                      const Text(
                        'Optioneel',
                        style: TextStyle(
                          color: Color(0xFFB45309),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
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

  Widget _geleiderSectie() {
    final geleiders = widget.instellingen.geleidersVoor(widget.model.lameltype);

    return _sectie(
      titel: 'Type geleiders',
      kinderen: <Widget>[
        if (geleiders.isEmpty)
          const _LegeZoekmelding(
            tekst: 'Geen geleiders beschikbaar voor dit lameltype.',
          )
        else
          ...geleiders.map((geleider) {
            return _radio<String>(
              waarde: geleider.code,
              groepWaarde: widget.model.geleiderCode,
              titel: geleider.label,
              subtitel: 'Breedte in tekening: ${geleider.breedteMm} mm',
              onChanged: (_) {
                _wijzig(
                  widget.model.copyWith(
                    geleiderCode: geleider.code,
                    geleiderOmschrijving: geleider.omschrijving,
                    geleiderBreedteMm: geleider.breedteMm,
                  ),
                );
              },
            );
          }),
      ],
    );
  }

  Widget _jaNeen({
    required bool waarde,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      children: <Widget>[
        _radio<bool>(
          waarde: true,
          groepWaarde: waarde,
          titel: 'Ja',
          onChanged: onChanged,
        ),
        _radio<bool>(
          waarde: false,
          groepWaarde: waarde,
          titel: 'Neen',
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _compacteKastOptie(OpmetingBuitenjaloezieKastResultaat optie) {
    final geselecteerd =
        widget.model.kastHoogteMm == optie.kastHoogteMm &&
        widget.model.lamellenpakketUitsteekMm == optie.lamellenpakketUitsteekMm;
    final uitsteekTekst = optie.lamellenpakketUitsteekMm == 0
        ? 'Geen uitsteek'
        : '${optie.lamellenpakketUitsteekMm} mm uitsteek';

    return InkWell(
      onTap: optie.combinatieGeldig
          ? () {
              _wijzig(
                widget.model.copyWith(
                  kastHoogteMm: optie.kastHoogteMm,
                  lamellenpakketUitsteekMm: optie.lamellenpakketUitsteekMm,
                ),
              );
            }
          : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: geselecteerd
              ? const Color(0xFFEFF6FF)
              : optie.combinatieGeldig
              ? const Color(0xFFF9FAFB)
              : const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: geselecteerd
                ? const Color(0xFF60A5FA)
                : optie.combinatieGeldig
                ? _rand
                : const Color(0xFFFDA4AF),
            width: geselecteerd ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  geselecteerd
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: geselecteerd
                      ? const Color(0xFF2563EB)
                      : optie.combinatieGeldig
                      ? _tekstGrijs
                      : const Color(0xFFBE123C),
                  size: 17,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${optie.kastHoogteMm} mm',
                    style: TextStyle(
                      color: optie.combinatieGeldig
                          ? _tekst
                          : const Color(0xFFBE123C),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              optie.combinatieGeldig ? uitsteekTekst : 'Niet mogelijk',
              style: TextStyle(
                color: optie.combinatieGeldig
                    ? const Color(0xFF1D4ED8)
                    : const Color(0xFFBE123C),
                fontSize: 10.8,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              widget.model.hoogteInclusiefKast
                  ? 'max. ${optie.maximaleElementHoogteMm} mm'
                  : 'max. LH ${optie.maximaleDagmaatHoogteMm} mm',
              style: const TextStyle(
                color: _tekstGrijs,
                fontSize: 9.8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _berekendeMaatKaart(
    OpmetingBuitenjaloezieKastResultaat resultaat,
    List<OpmetingBuitenjaloezieKastResultaat> raffstoreOpties,
  ) {
    final fout = resultaat.overschrijdtTabel || !resultaat.combinatieGeldig;

    if (!widget.model.systeem.isModulo && raffstoreOpties.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: const Color(0xFFCDEBD6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Kies kastmaat',
              style: TextStyle(
                color: _groen,
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              'De uitsteek wordt voor beide kastmaten automatisch berekend.',
              style: TextStyle(
                color: _tekstGrijs,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 9),
            LayoutBuilder(
              builder: (context, beperkingen) {
                final naastElkaar = beperkingen.maxWidth >= 270;
                final kaarten = raffstoreOpties
                    .map((optie) => _compacteKastOptie(optie))
                    .toList(growable: false);
                if (!naastElkaar) {
                  return Column(
                    children: <Widget>[
                      for (
                        var index = 0;
                        index < kaarten.length;
                        index++
                      ) ...<Widget>[
                        kaarten[index],
                        if (index < kaarten.length - 1)
                          const SizedBox(height: 8),
                      ],
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (
                      var index = 0;
                      index < kaarten.length;
                      index++
                    ) ...<Widget>[
                      Expanded(child: kaarten[index]),
                      if (index < kaarten.length - 1) const SizedBox(width: 8),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Text(
                "Gekozen: ${widget.model.kastHoogteMm} mm kast · ${widget.model.lamellenpakketUitsteekMm == 0 ? 'geen uitsteek' : '${widget.model.lamellenpakketUitsteekMm} mm uitsteek'}",
                style: const TextStyle(
                  color: Color(0xFF1D4ED8),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fout ? const Color(0xFFFFF1F2) : _lichtGroen,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: fout ? const Color(0xFFFDA4AF) : const Color(0xFFCDEBD6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Automatisch berekende kast',
            style: TextStyle(
              color: fout ? const Color(0xFFBE123C) : _groen,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${widget.model.kastHoogteMm} mm kast · '
            '${widget.model.totaleHoogteMm} mm totale hoogte',
            style: const TextStyle(
              color: _tekst,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.model.hoogteInclusiefKast
                ? 'EH-grens: ${resultaat.maximaleElementHoogteMm} mm'
                : 'LH-grens: ${resultaat.maximaleDagmaatHoogteMm} mm',
            style: const TextStyle(
              color: _tekstGrijs,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (fout) ...<Widget>[
            const SizedBox(height: 6),
            const Text(
              'De ingegeven hoogte valt buiten de officiële tabel '
              'voor deze combinatie.',
              style: TextStyle(
                color: Color(0xFFBE123C),
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectie({required String titel, required List<Widget> kinderen}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rand),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            titel,
            style: const TextStyle(
              color: _tekst,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ...kinderen,
        ],
      ),
    );
  }

  Widget _keuzeTitel(String tekst) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        tekst,
        style: const TextStyle(
          color: _tekstGrijs,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _radio<T>({
    required T waarde,
    required T groepWaarde,
    required String titel,
    String? subtitel,
    required ValueChanged<T> onChanged,
    bool ingeschakeld = true,
  }) {
    final geselecteerd = waarde == groepWaarde;
    return ListTile(
      onTap: ingeschakeld ? () => onChanged(waarde) : null,
      leading: Icon(
        geselecteerd ? Icons.radio_button_checked : Icons.radio_button_off,
        color: ingeschakeld
            ? (geselecteerd ? _groen : _tekstGrijs)
            : const Color(0xFF9CA3AF),
      ),
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        titel,
        style: TextStyle(
          color: ingeschakeld ? _tekst : const Color(0xFF9CA3AF),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: subtitel == null
          ? null
          : Text(
              subtitel,
              style: TextStyle(
                color: ingeschakeld ? _tekstGrijs : const Color(0xFF9CA3AF),
                fontSize: 10.5,
              ),
            ),
    );
  }

  Widget _invoerVeld({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    bool numeriek = false,
    String? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: numeriek ? TextInputType.number : TextInputType.text,
      inputFormatters: numeriek
          ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
          : null,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        isDense: true,
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
      ),
    );
  }

  Widget _zoekVeld({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: controller.clear,
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _rand),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _rand),
        ),
      ),
    );
  }

  Widget _kleurBol(String hex) {
    final kleur = _kleurUitHex(hex);
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: kleur,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFB8BEC7)),
      ),
    );
  }

  Color _kleurUitHex(String hex) {
    final schoon = hex.replaceAll('#', '').trim();
    final waarde = int.tryParse(schoon, radix: 16);
    if (waarde == null) return const Color(0xFFB7B7B7);
    return Color(0xFF000000 | waarde);
  }
}

class _LegeZoekmelding extends StatelessWidget {
  const _LegeZoekmelding({required this.tekst});

  final String tekst;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        tekst,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
