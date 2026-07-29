// THIMACO-CONTROLE: PLOOIWERKEN-RECHTERKOLOM-OPHANGING-LEVERANCIER-20260728
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'opmeting_plooiwerken_instellingen_model.dart';
import 'opmeting_plooiwerken_model.dart';

class OpmetingPlooiwerkenRechterkolom extends StatefulWidget {
  const OpmetingPlooiwerkenRechterkolom({
    super.key,
    required this.model,
    required this.instellingen,
    required this.projectKleur,
    required this.onGewijzigd,
  });

  final OpmetingPlooiwerkenModel model;
  final OpmetingPlooiwerkenInstellingen instellingen;
  final String projectKleur;
  final ValueChanged<OpmetingPlooiwerkenModel> onGewijzigd;

  @override
  State<OpmetingPlooiwerkenRechterkolom> createState() {
    return _OpmetingPlooiwerkenRechterkolomState();
  }
}

class _OpmetingPlooiwerkenRechterkolomState
    extends State<OpmetingPlooiwerkenRechterkolom> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekst = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  late final TextEditingController _aantalController;
  late final TextEditingController _aantalPlooienController;
  late final TextEditingController _totaleLengteController;
  late final TextEditingController _rotatieController;
  late final List<TextEditingController> _lengteControllers;
  late final List<TextEditingController> _hoekControllers;

  @override
  void initState() {
    super.initState();
    _aantalController = TextEditingController();
    _aantalPlooienController = TextEditingController();
    _totaleLengteController = TextEditingController();
    _rotatieController = TextEditingController();
    _lengteControllers = List<TextEditingController>.generate(
      OpmetingPlooiwerkenModel.aantalPlooienMaximum + 1,
      (_) => TextEditingController(),
    );
    _hoekControllers = List<TextEditingController>.generate(
      OpmetingPlooiwerkenModel.aantalPlooienMaximum,
      (_) => TextEditingController(),
    );
    _synchroniseerControllers();
  }

  @override
  void didUpdateWidget(covariant OpmetingPlooiwerkenRechterkolom oldWidget) {
    super.didUpdateWidget(oldWidget);
    _synchroniseerControllers();
  }

  @override
  void dispose() {
    _aantalController.dispose();
    _aantalPlooienController.dispose();
    _totaleLengteController.dispose();
    _rotatieController.dispose();
    for (final controller in _lengteControllers) {
      controller.dispose();
    }
    for (final controller in _hoekControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _synchroniseerControllers() {
    _stelTekstIn(_aantalController, widget.model.aantal.toString());
    _stelTekstIn(
      _aantalPlooienController,
      widget.model.aantalPlooien.toString(),
    );
    _stelTekstIn(
      _totaleLengteController,
      widget.model.totaleLengteMm == 0
          ? ''
          : widget.model.totaleLengteMm.toString(),
    );
    _stelTekstIn(
      _rotatieController,
      widget.model.tekeningRotatieGraden.toString(),
    );

    final lengtes = widget.model.actieveLengtesMm;
    for (var index = 0; index < _lengteControllers.length; index++) {
      _stelTekstIn(
        _lengteControllers[index],
        index < lengtes.length && lengtes[index] != null
            ? lengtes[index].toString()
            : '',
      );
    }

    final hoeken = widget.model.actieveHoekenGraden;
    for (var index = 0; index < _hoekControllers.length; index++) {
      _stelTekstIn(
        _hoekControllers[index],
        index < hoeken.length && hoeken[index] != null
            ? hoeken[index].toString()
            : '',
      );
    }
  }

  void _stelTekstIn(TextEditingController controller, String tekst) {
    if (controller.text == tekst) return;
    controller.value = TextEditingValue(
      text: tekst,
      selection: TextSelection.collapsed(offset: tekst.length),
    );
  }

  void _wijzigAantal(String tekst) {
    final waarde = int.tryParse(tekst);
    if (waarde == null) return;

    widget.onGewijzigd(
      widget.model.copyWith(
        aantal: waarde
            .clamp(
              OpmetingPlooiwerkenModel.aantalMinimum,
              OpmetingPlooiwerkenModel.aantalMaximum,
            )
            .toInt(),
      ),
    );
  }

  void _wijzigAantalPlooien(String tekst) {
    if (!widget.model.isVrijeVorm) return;

    final waarde = int.tryParse(tekst);
    if (waarde == null) return;

    widget.onGewijzigd(widget.model.metAantalPlooien(waarde));
  }

  void _wijzigTotaleLengte(String tekst) {
    final waarde = tekst.trim().isEmpty ? 0 : int.tryParse(tekst);
    if (waarde == null) return;

    widget.onGewijzigd(
      widget.model.copyWith(
        totaleLengteMm: waarde
            .clamp(
              OpmetingPlooiwerkenModel.totaleLengteMinimumMm,
              OpmetingPlooiwerkenModel.totaleLengteMaximumMm,
            )
            .toInt(),
      ),
    );
  }

  void _wijzigLengte(int index, String tekst) {
    final waarde = tekst.trim().isEmpty ? null : int.tryParse(tekst);
    widget.onGewijzigd(widget.model.metLengteMm(index, waarde));
  }

  void _wijzigHoek(int index, String tekst) {
    final waarde = tekst.trim().isEmpty ? null : int.tryParse(tekst);
    widget.onGewijzigd(widget.model.metHoekGraden(index, waarde));
  }

  void _wijzigRotatie(String tekst) {
    final waarde = int.tryParse(tekst);
    if (waarde == null) return;

    widget.onGewijzigd(
      widget.model.copyWith(
        tekeningRotatieGraden: waarde
            .clamp(
              OpmetingPlooiwerkenModel.rotatieMinimumGraden,
              OpmetingPlooiwerkenModel.rotatieMaximumGraden,
            )
            .toInt(),
      ),
    );
  }

  List<String> _keuzesMetHuidigeWaarde(
    Iterable<String> basis,
    String huidigeWaarde,
  ) {
    final resultaat = <String>[];
    final gebruikt = <String>{};

    void voegToe(String waarde) {
      final tekst = waarde.trim();
      if (tekst.isEmpty) return;
      if (gebruikt.add(tekst.toLowerCase())) resultaat.add(tekst);
    }

    for (final keuze in basis) {
      voegToe(keuze);
    }
    voegToe(huidigeWaarde);

    return List<String>.unmodifiable(resultaat);
  }

  @override
  Widget build(BuildContext context) {
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            color: _lichtGroen,
            child: const Row(
              children: <Widget>[
                Icon(Icons.architecture_outlined, color: _groen, size: 19),
                SizedBox(width: 8),
                Text(
                  'Plooiwerken',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _SectieKaart(
                    titel: 'Algemeen',
                    children: <Widget>[
                      _CompactGetalRij(
                        titel: 'Aantal',
                        controller: _aantalController,
                        eenheid: 'st.',
                        onChanged: _wijzigAantal,
                      ),
                    ],
                  ),
                  _bouwKleursoort(),
                  _bouwKleur(),
                  _bouwDikte(),
                  _bouwVorm(),
                  _bouwPlooitekening(),
                  if (widget.model.toontZichtzijde) _bouwZichtzijde(),
                  _bouwSoortOphanging(),
                  _bouwPlaatsOphanging(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwKleursoort() {
    return _KeuzeSectie<OpmetingPlooiwerkenKleursoort>(
      titel: 'Kleursoort',
      waarde: widget.model.kleursoort,
      keuzes: OpmetingPlooiwerkenKleursoort.values,
      labelVoor: (waarde) => waarde.label,
      onChanged: (waarde) {
        final kleuren = widget.instellingen.kleuren;
        final folies = widget.instellingen.folies;
        widget.onGewijzigd(
          widget.model.copyWith(
            kleursoort: waarde,
            kleurWaarde:
                waarde == OpmetingPlooiwerkenKleursoort.kleur &&
                    widget.model.kleurWaarde.trim().isEmpty &&
                    kleuren.isNotEmpty
                ? kleuren.first
                : widget.model.kleurWaarde,
            folieWaarde:
                waarde == OpmetingPlooiwerkenKleursoort.folie &&
                    widget.model.folieWaarde.trim().isEmpty &&
                    folies.isNotEmpty
                ? folies.first
                : widget.model.folieWaarde,
            projectKleurWaarde:
                waarde == OpmetingPlooiwerkenKleursoort.projectKleur
                ? widget.projectKleur.trim()
                : widget.model.projectKleurWaarde,
          ),
        );
      },
    );
  }

  Widget _bouwKleur() {
    switch (widget.model.kleursoort) {
      case OpmetingPlooiwerkenKleursoort.brut:
        return const _WaardeSectie(titel: 'Kleur', waarde: 'Brut (BRUT)');
      case OpmetingPlooiwerkenKleursoort.kleur:
        final keuzes = _keuzesMetHuidigeWaarde(
          widget.instellingen.kleuren,
          widget.model.kleurWaarde,
        );
        if (keuzes.isEmpty) {
          return const _MeldingSectie(
            titel: 'Kleur',
            tekst:
                'Voeg eerst poederlakkleuren toe via Instellingen > Plooiwerken.',
          );
        }
        final waarde = keuzes.contains(widget.model.kleurWaarde)
            ? widget.model.kleurWaarde
            : keuzes.first;
        return _DropdownKeuzeSectie(
          titel: 'Kleur',
          waarde: waarde,
          keuzes: keuzes,
          hintTekst: 'Zoek of kies een poederlakkleur',
          onChanged: (keuze) {
            widget.onGewijzigd(widget.model.copyWith(kleurWaarde: keuze));
          },
        );
      case OpmetingPlooiwerkenKleursoort.folie:
        final keuzes = _keuzesMetHuidigeWaarde(
          widget.instellingen.folies,
          widget.model.folieWaarde,
        );
        if (keuzes.isEmpty) {
          return const _MeldingSectie(
            titel: 'Kleur',
            tekst:
                'Voeg eerst foliekleuren toe via Instellingen > Plooiwerken.',
          );
        }
        final waarde = keuzes.contains(widget.model.folieWaarde)
            ? widget.model.folieWaarde
            : keuzes.first;
        return _DropdownKeuzeSectie(
          titel: 'Kleur',
          waarde: waarde,
          keuzes: keuzes,
          hintTekst: 'Zoek of kies een Renolit-foliekleur',
          onChanged: (keuze) {
            widget.onGewijzigd(widget.model.copyWith(folieWaarde: keuze));
          },
        );
      case OpmetingPlooiwerkenKleursoort.anodise:
        return const _WaardeSectie(titel: 'Kleur', waarde: 'Anodisé natuur');
      case OpmetingPlooiwerkenKleursoort.projectKleur:
        final projectKleur = widget.projectKleur.trim().isNotEmpty
            ? widget.projectKleur.trim()
            : widget.model.projectKleurWaarde.trim();
        return _WaardeSectie(
          titel: 'Projectkleur uit hoofdpagina',
          waarde: projectKleur.isEmpty
              ? 'Nog geen projectkleur gekozen op de hoofdpagina'
              : projectKleur,
        );
    }
  }

  Widget _bouwDikte() {
    return _KeuzeSectie<OpmetingPlooiwerkenDikte>(
      titel: 'Dikte',
      waarde: widget.model.dikte,
      keuzes: OpmetingPlooiwerkenDikte.values,
      labelVoor: (waarde) => waarde.label,
      onChanged: (waarde) {
        widget.onGewijzigd(widget.model.copyWith(dikte: waarde));
      },
    );
  }

  Widget _bouwVorm() {
    return _KeuzeSectie<OpmetingPlooiwerkenVorm>(
      titel: 'Vorm',
      waarde: widget.model.vorm,
      keuzes: OpmetingPlooiwerkenVorm.values,
      labelVoor: (waarde) => waarde.label,
      onChanged: (waarde) {
        widget.onGewijzigd(widget.model.metVorm(waarde));
      },
    );
  }

  Widget _bouwPlooitekening() {
    return _SectieKaart(
      titel: 'Plooitekening',
      children: <Widget>[
        _CompactGetalRij(
          titel: 'Lengte',
          controller: _totaleLengteController,
          eenheid: 'mm · 0–4000',
          onChanged: _wijzigTotaleLengte,
        ),
        const SizedBox(height: 4),
        _CompactGetalRij(
          titel: 'Aantal plooien',
          controller: _aantalPlooienController,
          eenheid: widget.model.isVrijeVorm ? 'max. 7' : 'volgens vorm',
          enabled: widget.model.isVrijeVorm,
          onChanged: _wijzigAantalPlooien,
        ),
        const SizedBox(height: 6),
        for (var index = 0; index < widget.model.aantalZijden; index++)
          _bouwStap(index),
        const Divider(height: 12, color: _rand),
        _CompactGetalRij(
          titel: 'Tekening draaien',
          controller: _rotatieController,
          eenheid: '°',
          onChanged: _wijzigRotatie,
        ),
      ],
    );
  }

  Widget _bouwStap(int index) {
    final isLaatste = index == widget.model.aantalZijden - 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        children: <Widget>[
          _CompactGetalRij(
            titel: 'Lengte ${index + 1}',
            controller: _lengteControllers[index],
            eenheid: 'mm',
            onChanged: (tekst) => _wijzigLengte(index, tekst),
          ),
          if (!isLaatste) ...<Widget>[
            const SizedBox(height: 3),
            _CompactGetalRij(
              titel: 'Graden ${index + 1}',
              controller: _hoekControllers[index],
              eenheid: '°',
              onChanged: (tekst) => _wijzigHoek(index, tekst),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bouwZichtzijde() {
    return _KeuzeSectie<OpmetingPlooiwerkenLakzijde>(
      titel: 'Zichtzijde',
      waarde: widget.model.lakzijde,
      keuzes: OpmetingPlooiwerkenLakzijde.values,
      labelVoor: (waarde) => waarde.label,
      onChanged: (waarde) {
        widget.onGewijzigd(widget.model.copyWith(lakzijde: waarde));
      },
    );
  }

  Widget _bouwSoortOphanging() {
    final keuzes = _keuzesMetHuidigeWaarde(
      OpmetingPlooiwerkenModel.soortOphangingKeuzes,
      widget.model.soortOphanging,
    );
    final waarde = widget.model.soortOphanging.trim().isEmpty
        ? OpmetingPlooiwerkenModel.soortOphangingGaatjes
        : widget.model.soortOphanging;

    return _KeuzeSectie<String>(
      titel: 'Soort ophanging',
      waarde: waarde,
      keuzes: keuzes,
      labelVoor: (keuze) => keuze,
      onChanged: (keuze) {
        widget.onGewijzigd(widget.model.copyWith(soortOphanging: keuze));
      },
    );
  }

  Widget _bouwPlaatsOphanging() {
    final keuzes = widget.model.beschikbarePlaatsOphangingKeuzes;
    final waarde = keuzes.contains(widget.model.plaatsOphanging)
        ? widget.model.plaatsOphanging
        : keuzes.first;

    return _KeuzeSectie<String>(
      titel: 'Plaats ophanging',
      waarde: waarde,
      keuzes: keuzes,
      labelVoor: (keuze) => keuze,
      onChanged: (keuze) {
        widget.onGewijzigd(widget.model.copyWith(plaatsOphanging: keuze));
      },
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
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _OpmetingPlooiwerkenRechterkolomState._rand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            titel,
            style: const TextStyle(
              color: _OpmetingPlooiwerkenRechterkolomState._groen,
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

class _KeuzeSectie<T> extends StatelessWidget {
  const _KeuzeSectie({
    required this.titel,
    required this.waarde,
    required this.keuzes,
    required this.labelVoor,
    required this.onChanged,
  });

  final String titel;
  final T waarde;
  final List<T> keuzes;
  final String Function(T waarde) labelVoor;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<T>(
      groupValue: waarde,
      onChanged: (nieuw) {
        if (nieuw != null) onChanged(nieuw);
      },
      child: _SectieKaart(
        titel: titel,
        children: keuzes
            .map((keuze) {
              return RadioListTile<T>(
                value: keuze,
                activeColor: _OpmetingPlooiwerkenRechterkolomState._groen,
                dense: true,
                visualDensity: const VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
                contentPadding: EdgeInsets.zero,
                title: Text(
                  labelVoor(keuze),
                  style: const TextStyle(
                    color: _OpmetingPlooiwerkenRechterkolomState._tekst,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _DropdownKeuzeSectie extends StatelessWidget {
  const _DropdownKeuzeSectie({
    required this.titel,
    required this.waarde,
    required this.keuzes,
    required this.hintTekst,
    required this.onChanged,
  });

  final String titel;
  final String waarde;
  final List<String> keuzes;
  final String hintTekst;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final geldigeWaarde = keuzes.contains(waarde) ? waarde : null;
    final menuSignatuur = Object.hashAll(<Object?>[
      titel,
      geldigeWaarde,
      ...keuzes,
    ]);

    return _SectieKaart(
      titel: titel,
      children: <Widget>[
        LayoutBuilder(
          builder: (context, constraints) {
            return DropdownMenu<String>(
              key: ValueKey<int>(menuSignatuur),
              width: constraints.maxWidth,
              menuHeight: 320,
              initialSelection: geldigeWaarde,
              enableFilter: true,
              enableSearch: true,
              requestFocusOnTap: true,
              hintText: hintTekst,
              leadingIcon: const Icon(
                Icons.search_rounded,
                size: 18,
                color: _OpmetingPlooiwerkenRechterkolomState._tekstGrijs,
              ),
              trailingIcon: const Icon(Icons.arrow_drop_down_rounded),
              selectedTrailingIcon: const Icon(Icons.arrow_drop_up_rounded),
              textStyle: const TextStyle(
                color: _OpmetingPlooiwerkenRechterkolomState._tekst,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
              inputDecorationTheme: InputDecorationTheme(
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: _OpmetingPlooiwerkenRechterkolomState._rand,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: _OpmetingPlooiwerkenRechterkolomState._rand,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: _OpmetingPlooiwerkenRechterkolomState._groen,
                    width: 1.4,
                  ),
                ),
              ),
              menuStyle: MenuStyle(
                backgroundColor: const WidgetStatePropertyAll<Color>(
                  Colors.white,
                ),
                elevation: const WidgetStatePropertyAll<double>(8),
                shape: WidgetStatePropertyAll<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(
                      color: _OpmetingPlooiwerkenRechterkolomState._rand,
                    ),
                  ),
                ),
              ),
              dropdownMenuEntries: keuzes
                  .map((keuze) {
                    return DropdownMenuEntry<String>(
                      value: keuze,
                      label: keuze,
                      style: ButtonStyle(
                        textStyle: const WidgetStatePropertyAll<TextStyle>(
                          TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        foregroundColor: const WidgetStatePropertyAll<Color>(
                          _OpmetingPlooiwerkenRechterkolomState._tekst,
                        ),
                      ),
                    );
                  })
                  .toList(growable: false),
              onSelected: (nieuw) {
                if (nieuw == null || nieuw == waarde) return;
                onChanged(nieuw);
              },
            );
          },
        ),
      ],
    );
  }
}

class _CompactGetalRij extends StatelessWidget {
  const _CompactGetalRij({
    required this.titel,
    required this.controller,
    required this.onChanged,
    this.eenheid,
    this.enabled = true,
  });

  final String titel;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? eenheid;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 112,
          child: Text(
            titel,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: _OpmetingPlooiwerkenRechterkolomState._tekst,
            ),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: onChanged,
            style: const TextStyle(fontSize: 12),
            decoration: _veldDecoratie(suffixText: eenheid),
          ),
        ),
      ],
    );
  }
}

class _WaardeSectie extends StatelessWidget {
  const _WaardeSectie({required this.titel, required this.waarde});

  final String titel;
  final String waarde;

  @override
  Widget build(BuildContext context) {
    return _SectieKaart(
      titel: titel,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: _OpmetingPlooiwerkenRechterkolomState._lichtGroen,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: _OpmetingPlooiwerkenRechterkolomState._rand,
            ),
          ),
          child: Text(
            waarde,
            style: const TextStyle(
              color: _OpmetingPlooiwerkenRechterkolomState._tekst,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _MeldingSectie extends StatelessWidget {
  const _MeldingSectie({required this.titel, required this.tekst});

  final String titel;
  final String tekst;

  @override
  Widget build(BuildContext context) {
    return _SectieKaart(
      titel: titel,
      children: <Widget>[
        Text(
          tekst,
          style: const TextStyle(
            color: _OpmetingPlooiwerkenRechterkolomState._tekstGrijs,
            fontSize: 10.5,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

InputDecoration _veldDecoratie({String? suffixText}) {
  return InputDecoration(
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
    suffixText: suffixText,
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: Color(0xFF0B7A3B), width: 1.4),
    ),
  );
}
