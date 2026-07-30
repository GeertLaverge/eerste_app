// THIMACO-CONTROLE: NUMMERINVOER-LEEGMAAKBAAR-IPAD-20260729-1455
// THIMACO-CONTROLE: SEKTIONALE-POORTEN-R-PROFIELEN-MEERVOUDIG-20260729-1415
// THIMACO-CONTROLE: SEKTIONALE-POORTEN-R-PROFIELEN-INVOER-20260729-1313
// THIMACO-CONTROLE: SEKTIONALE-POORTEN-COMPACT-MENU-P-R-STOPCONTACT-20260729
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'opmeting_sektionale_poort_instellingen_model.dart';
import 'opmeting_sektionale_poort_model.dart';

class OpmetingSektionalePoortRechterkolom extends StatefulWidget {
  const OpmetingSektionalePoortRechterkolom({
    super.key,
    required this.model,
    required this.instellingen,
    required this.projectKleur,
    required this.onGewijzigd,
  });

  final OpmetingSektionalePoortModel model;
  final OpmetingSektionalePoortInstellingen instellingen;
  final String projectKleur;
  final ValueChanged<OpmetingSektionalePoortModel> onGewijzigd;

  @override
  State<OpmetingSektionalePoortRechterkolom> createState() {
    return _OpmetingSektionalePoortRechterkolomState();
  }
}

class _OpmetingSektionalePoortRechterkolomState
    extends State<OpmetingSektionalePoortRechterkolom> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);

  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = <String, TextEditingController>{};
    _synchroniseerControllers(widget.model, forceer: true);
  }

  @override
  void didUpdateWidget(
    covariant OpmetingSektionalePoortRechterkolom oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    _synchroniseerControllers(widget.model);
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controller(String sleutel, int waarde) {
    return _controllers.putIfAbsent(
      sleutel,
      () => TextEditingController(text: waarde == 0 ? '' : '$waarde'),
    );
  }

  void _zetController(String sleutel, int waarde, {bool forceer = false}) {
    final controller = _controller(sleutel, waarde);
    final tekst = waarde == 0 ? '' : '$waarde';
    if (controller.text == tekst) return;
    if (!forceer && int.tryParse(controller.text) == waarde) return;
    controller.value = TextEditingValue(
      text: tekst,
      selection: TextSelection.collapsed(offset: tekst.length),
    );
  }

  void _synchroniseerControllers(
    OpmetingSektionalePoortModel model, {
    bool forceer = false,
  }) {
    _zetController('aantal', model.aantal, forceer: forceer);
    _zetController('breedte', model.breedteMm, forceer: forceer);
    _zetController('hoogte', model.hoogteMm, forceer: forceer);
    _zetController('slagL', model.slagLMm, forceer: forceer);
    _zetController('slagR', model.slagRMm, forceer: forceer);
    _zetController('slagB', model.slagBMm, forceer: forceer);
    _zetController(
      'extraHandzenders',
      model.aantalExtraHandzenders,
      forceer: forceer,
    );
    _zetController('aantalPanelen', model.aantalPanelen, forceer: forceer);
    _zetController('rRaam1Afstand', model.rRaam1AfstandMm, forceer: forceer);
    _zetController('rRaam2Afstand', model.rRaam2AfstandMm, forceer: forceer);
    _synchroniseerProfielControllers(
      'afwerk',
      model.afwerkprofielMaten,
      forceer: forceer,
    );
    _synchroniseerProfielControllers(
      'dc1',
      model.montageDc1Maten,
      forceer: forceer,
    );
    _synchroniseerProfielControllers(
      'dc2',
      model.montageDc2Maten,
      forceer: forceer,
    );
    for (final koker in model.kokerMaten) {
      _zetController('koker-${koker.profiel}-l', koker.lMm, forceer: forceer);
      _zetController('koker-${koker.profiel}-r', koker.rMm, forceer: forceer);
      _zetController('koker-${koker.profiel}-b', koker.bMm, forceer: forceer);
    }
  }

  void _synchroniseerProfielControllers(
    String voorvoegsel,
    OpmetingSektionalePoortProfielMaten maten, {
    required bool forceer,
  }) {
    _zetController('$voorvoegsel-x', maten.xMm, forceer: forceer);
    _zetController('$voorvoegsel-l', maten.lMm, forceer: forceer);
    _zetController('$voorvoegsel-r', maten.rMm, forceer: forceer);
    _zetController('$voorvoegsel-b', maten.bMm, forceer: forceer);
  }

  int _leesInt(String tekst, {int standaard = 0}) {
    return int.tryParse(tekst.trim()) ?? standaard;
  }

  void _wijzig(OpmetingSektionalePoortModel model) {
    widget.onGewijzigd(model);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rand),
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: const BoxDecoration(
              color: Color(0xFFE7F6EC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: const Row(
              children: <Widget>[
                Icon(Icons.garage_outlined, color: _groen, size: 19),
                SizedBox(width: 8),
                Text(
                  'Sektionale poorten',
                  style: TextStyle(
                    color: _groen,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: <Widget>[
                _SectieKaart(
                  titel: 'Algemeen',
                  child: _NummerRij(
                    label: 'Aantal',
                    controller: _controller('aantal', widget.model.aantal),
                    achtervoegsel: 'st.',
                    onChanged: (tekst) {
                      final waarde = int.tryParse(tekst.trim());
                      if (waarde == null) return;
                      _wijzig(widget.model.copyWith(aantal: waarde));
                    },
                  ),
                ),
                _SectieKaart(
                  titel: 'Bestelmaten',
                  child: Column(
                    children: <Widget>[
                      _NummerRij(
                        label: 'Breedte',
                        controller: _controller(
                          'breedte',
                          widget.model.breedteMm,
                        ),
                        achtervoegsel: 'mm',
                        onChanged: (tekst) => _wijzig(
                          widget.model.copyWith(breedteMm: _leesInt(tekst)),
                        ),
                      ),
                      _NummerRij(
                        label: 'Hoogte',
                        controller: _controller(
                          'hoogte',
                          widget.model.hoogteMm,
                        ),
                        achtervoegsel: 'mm',
                        onChanged: (tekst) => _wijzig(
                          widget.model.copyWith(hoogteMm: _leesInt(tekst)),
                        ),
                      ),
                      _NummerRij(
                        label: 'Slag L',
                        controller: _controller('slagL', widget.model.slagLMm),
                        achtervoegsel: 'mm',
                        onChanged: (tekst) => _wijzig(
                          widget.model.copyWith(slagLMm: _leesInt(tekst)),
                        ),
                      ),
                      _NummerRij(
                        label: 'Slag R',
                        controller: _controller('slagR', widget.model.slagRMm),
                        achtervoegsel: 'mm',
                        onChanged: (tekst) => _wijzig(
                          widget.model.copyWith(slagRMm: _leesInt(tekst)),
                        ),
                      ),
                      _NummerRij(
                        label: 'Slag B',
                        controller: _controller('slagB', widget.model.slagBMm),
                        achtervoegsel: 'mm',
                        onChanged: (tekst) => _wijzig(
                          widget.model.copyWith(slagBMm: _leesInt(tekst)),
                        ),
                      ),
                    ],
                  ),
                ),
                _RondeSelectieSectie<OpmetingSektionalePoortSerie>(
                  titel: 'Type',
                  waarde: widget.model.serie,
                  keuzes: OpmetingSektionalePoortSerie.values,
                  labelVoor: (waarde) => waarde.label,
                  onChanged: (waarde) =>
                      _wijzig(widget.model.copyWith(serie: waarde)),
                ),
                _RondeSelectieSectie<OpmetingSektionalePoortStructuur>(
                  titel: 'Struktuur',
                  waarde: widget.model.structuur,
                  keuzes: OpmetingSektionalePoortStructuur.values,
                  labelVoor: (waarde) => waarde.label,
                  onChanged: (waarde) =>
                      _wijzig(widget.model.copyWith(structuur: waarde)),
                ),
                _bouwModelSectie(),
                _bouwKleurSectie(),
                _RondeSelectieSectie<OpmetingSektionalePoortKorrelgrootte>(
                  titel: 'Korrelgrootte',
                  waarde: widget.model.korrelgrootte,
                  keuzes: OpmetingSektionalePoortKorrelgrootte.values,
                  labelVoor: (waarde) => waarde.label,
                  kolommen: 2,
                  onChanged: (waarde) =>
                      _wijzig(widget.model.copyWith(korrelgrootte: waarde)),
                ),
                _RondeSelectieSectie<OpmetingSektionalePoortMotor>(
                  titel: 'Type Motor',
                  waarde: widget.model.motor,
                  keuzes: OpmetingSektionalePoortMotor.values,
                  labelVoor: (waarde) => waarde.label,
                  onChanged: (waarde) =>
                      _wijzig(widget.model.copyWith(motor: waarde)),
                ),
                _bouwBedieningSectie(),
                _JaNeeSectie(
                  titel: 'Bovenlatei + rubber',
                  waarde: widget.model.bovenlatei,
                  onChanged: (waarde) =>
                      _wijzig(widget.model.copyWith(bovenlatei: waarde)),
                ),
                _JaNeeSectie(
                  titel: 'PVC anti-roestvoetje Premium Pro',
                  waarde: widget.model.pvcAntiRoestvoetjePremiumPro,
                  onChanged: (waarde) => _wijzig(
                    widget.model.copyWith(pvcAntiRoestvoetjePremiumPro: waarde),
                  ),
                ),
                _JaNeeSectie(
                  titel: 'Plaatsen en aansluiten stopcontact',
                  waarde: widget.model.plaatsenEnAansluitenStopcontact,
                  onderschrift:
                      'Bij Ja kan onder Instellingen → Offerteprijzen een technische keuzeprijs worden ingesteld.',
                  onChanged: (waarde) => _wijzig(
                    widget.model.copyWith(
                      plaatsenEnAansluitenStopcontact: waarde,
                    ),
                  ),
                ),
                _bouwMontageProfielen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwModelSectie() {
    return _SectieKaart(
      titel: 'Model',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _RondeSelectieRaster<OpmetingSektionalePoortModelType>(
            waarde: widget.model.modelType,
            keuzes: OpmetingSektionalePoortModelType.values,
            labelVoor: (waarde) => waarde.label,
            kolommen: 2,
            beschikbaarVoor: widget.model.isModelBeschikbaar,
            onderschriftVoor: widget.model.redenNietBeschikbaar,
            onChanged: (waarde) =>
                _wijzig(widget.model.copyWith(modelType: waarde)),
          ),
          if (widget.model.modelType ==
              OpmetingSektionalePoortModelType.p) ...<Widget>[
            const SizedBox(height: 9),
            const Divider(height: 1),
            const SizedBox(height: 9),
            _NummerRij(
              label: 'Aantal panelen',
              controller: _controller(
                'aantalPanelen',
                widget.model.aantalPanelen,
              ),
              achtervoegsel: 'max. 6',
              onChanged: (tekst) {
                final waarde = int.tryParse(tekst.trim());
                if (waarde == null) return;
                _wijzig(widget.model.copyWith(aantalPanelen: waarde));
              },
            ),
            const SizedBox(height: 2),
            const Text(
              'Glaspanelen',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            _RondeToggleRaster<int>(
              keuzes: <int>[
                for (
                  var nummer = 1;
                  nummer <= widget.model.aantalPanelen;
                  nummer++
                )
                  nummer,
              ],
              geselecteerd: widget.model.geldigeGlasPaneelNummers.toSet(),
              labelVoor: widget.model.paneelLabel,
              kolommen: 2,
              onGewijzigd: (nummer, actief) {
                final gekozen = widget.model.geldigeGlasPaneelNummers.toSet();
                actief ? gekozen.add(nummer) : gekozen.remove(nummer);
                _wijzig(
                  widget.model.copyWith(
                    glasPaneelNummers: gekozen.toList(growable: false),
                  ),
                );
              },
            ),
          ],
          if (widget.model.modelType ==
              OpmetingSektionalePoortModelType.r) ...<Widget>[
            const SizedBox(height: 9),
            const Divider(height: 1),
            const SizedBox(height: 9),
            const Text(
              'Extra profielen',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            const Text(
              'Meerdere keuzes kunnen tegelijk worden aangeduid.',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            _RondeSelectieTegel(
              label: 'Vierkant raam met kleinhouten',
              geselecteerd: widget.model.rVierkantRaamMetKleinhouten,
              onTap: () => _wijzig(
                widget.model.copyWith(
                  rVierkantRaamMetKleinhouten:
                      !widget.model.rVierkantRaamMetKleinhouten,
                ),
              ),
            ),
            if (widget.model.rVierkantRaamMetKleinhouten)
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 4, 0, 7),
                child: _bouwVierkanteRamenInvoer(),
              ),
            _RondeSelectieTegel(
              label: 'Plint onderaan',
              geselecteerd: widget.model.rPlintOnderaan,
              onTap: () => _wijzig(
                widget.model.copyWith(
                  rPlintOnderaan: !widget.model.rPlintOnderaan,
                ),
              ),
            ),
            _RondeSelectieTegel(
              label: 'Voetje met makelaar',
              geselecteerd: widget.model.rVoetjeMetMakelaar,
              onTap: () => _wijzig(
                widget.model.copyWith(
                  rVoetjeMetMakelaar: !widget.model.rVoetjeMetMakelaar,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bouwVierkanteRamenInvoer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Text(
          'Aantal kaders',
          style: TextStyle(fontSize: 10.8, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Row(
          children: <Widget>[
            Expanded(
              child: _RondeSelectieTegel(
                label: '1 kader',
                geselecteerd: widget.model.rAantalVierkanteRamen == 1,
                onTap: () =>
                    _wijzig(widget.model.copyWith(rAantalVierkanteRamen: 1)),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _RondeSelectieTegel(
                label: '2 kaders',
                geselecteerd: widget.model.rAantalVierkanteRamen == 2,
                onTap: () =>
                    _wijzig(widget.model.copyWith(rAantalVierkanteRamen: 2)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        _bouwRaamPositieRij(
          nummer: 1,
          zijde: widget.model.rRaam1Zijde,
          afstandMm: widget.model.rRaam1AfstandMm,
          controllerSleutel: 'rRaam1Afstand',
          onZijdeGewijzigd: (zijde) =>
              _wijzig(widget.model.copyWith(rRaam1Zijde: zijde)),
          onAfstandGewijzigd: (waarde) =>
              _wijzig(widget.model.copyWith(rRaam1AfstandMm: waarde)),
        ),
        if (widget.model.rAantalVierkanteRamen == 2) ...<Widget>[
          const SizedBox(height: 5),
          _bouwRaamPositieRij(
            nummer: 2,
            zijde: widget.model.rRaam2Zijde,
            afstandMm: widget.model.rRaam2AfstandMm,
            controllerSleutel: 'rRaam2Afstand',
            onZijdeGewijzigd: (zijde) =>
                _wijzig(widget.model.copyWith(rRaam2Zijde: zijde)),
            onAfstandGewijzigd: (waarde) =>
                _wijzig(widget.model.copyWith(rRaam2AfstandMm: waarde)),
          ),
        ],
        const SizedBox(height: 3),
        const Text(
          '0 mm = buitenzijde kader tegen de gekozen zijkant van de poort.',
          style: TextStyle(
            fontSize: 8.8,
            color: Color(0xFF6B7280),
            height: 1.25,
          ),
        ),
      ],
    );
  }

  Widget _bouwRaamPositieRij({
    required int nummer,
    required OpmetingSektionalePoortRaamZijde zijde,
    required int afstandMm,
    required String controllerSleutel,
    required ValueChanged<OpmetingSektionalePoortRaamZijde> onZijdeGewijzigd,
    required ValueChanged<int> onAfstandGewijzigd,
  }) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 48,
          child: Text(
            'Raam $nummer',
            style: const TextStyle(fontSize: 10.8, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 4),
        _KleineRondeKeuze(
          label: 'Links',
          geselecteerd: zijde == OpmetingSektionalePoortRaamZijde.links,
          onTap: () => onZijdeGewijzigd(OpmetingSektionalePoortRaamZijde.links),
        ),
        const SizedBox(width: 5),
        _KleineRondeKeuze(
          label: 'Rechts',
          geselecteerd: zijde == OpmetingSektionalePoortRaamZijde.rechts,
          onTap: () =>
              onZijdeGewijzigd(OpmetingSektionalePoortRaamZijde.rechts),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: TextField(
            controller: _controller(controllerSleutel, afstandMm),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 11.3, fontWeight: FontWeight.w700),
            decoration: _invoerDecoratie(achtervoegsel: 'mm', compact: true),
            onChanged: (tekst) => onAfstandGewijzigd(_leesInt(tekst)),
          ),
        ),
      ],
    );
  }

  Widget _bouwKleurSectie() {
    final projectKleur = widget.projectKleur.trim();
    final opties = <String>[
      OpmetingSektionalePoortModel.projectKleurKeuze,
      ...widget.instellingen.kleuren,
    ];
    final uniekeOpties = <String>[];
    final gebruikt = <String>{};
    for (final optie in opties) {
      final nette = optie.trim();
      if (nette.isEmpty || !gebruikt.add(nette.toLowerCase())) continue;
      uniekeOpties.add(nette);
    }
    if (!uniekeOpties.contains(widget.model.kleur)) {
      uniekeOpties.add(widget.model.kleur);
    }

    return _SectieKaart(
      titel: 'Kleur',
      child: DropdownButtonFormField<String>(
        initialValue: widget.model.kleur,
        isExpanded: true,
        decoration: _invoerDecoratie(
          hint: 'Kies een kleur',
          helper: projectKleur.isEmpty
              ? 'Project kleur is nog niet ingevuld op de hoofdpagina.'
              : null,
        ),
        items: uniekeOpties
            .map((optie) {
              final label =
                  optie == OpmetingSektionalePoortModel.projectKleurKeuze &&
                      projectKleur.isNotEmpty
                  ? '$optie · $projectKleur'
                  : optie;
              return DropdownMenuItem<String>(value: optie, child: Text(label));
            })
            .toList(growable: false),
        onChanged: (waarde) {
          if (waarde == null) return;
          _wijzig(
            widget.model.copyWith(
              kleur: waarde,
              projectKleurWaarde: projectKleur,
            ),
          );
        },
      ),
    );
  }

  Widget _bouwBedieningSectie() {
    return _SectieKaart(
      titel: 'Bediening',
      child: Column(
        children: <Widget>[
          _RondeToggleTegel(
            label: 'Extra handzenders',
            waarde: widget.model.extraHandzenders,
            onChanged: (waarde) =>
                _wijzig(widget.model.copyWith(extraHandzenders: waarde)),
          ),
          if (widget.model.extraHandzenders)
            Padding(
              padding: const EdgeInsets.only(left: 26, bottom: 5),
              child: _NummerRij(
                label: 'Aantal',
                controller: _controller(
                  'extraHandzenders',
                  widget.model.aantalExtraHandzenders,
                ),
                achtervoegsel: 'st.',
                onChanged: (tekst) {
                  final waarde = int.tryParse(tekst.trim());
                  if (waarde == null) return;
                  _wijzig(
                    widget.model.copyWith(aantalExtraHandzenders: waarde),
                  );
                },
              ),
            ),
          _RondeToggleTegel(
            label: 'Muurzender draadloos IO',
            waarde: widget.model.muurzenderDraadloosIo,
            onChanged: (waarde) =>
                _wijzig(widget.model.copyWith(muurzenderDraadloosIo: waarde)),
          ),
          _RondeToggleTegel(
            label: 'Draadloos codeklavier',
            waarde: widget.model.draadloosCodeklavier,
            onChanged: (waarde) =>
                _wijzig(widget.model.copyWith(draadloosCodeklavier: waarde)),
          ),
        ],
      ),
    );
  }

  Widget _bouwMontageProfielen() {
    return _SectieKaart(
      titel: 'Montage profielen',
      child: Column(
        children: <Widget>[
          for (final keuze
              in OpmetingSektionalePoortMontageProfiel.values) ...<Widget>[
            _RondeSelectieTegel(
              label: keuze.label,
              geselecteerd: widget.model.montageProfiel == keuze,
              onTap: () =>
                  _wijzig(widget.model.copyWith(montageProfiel: keuze)),
            ),
            if (widget.model.montageProfiel == keuze)
              Padding(
                padding: const EdgeInsets.only(left: 26, bottom: 8),
                child: _bouwMontageInvoer(keuze),
              ),
          ],
        ],
      ),
    );
  }

  Widget _bouwMontageInvoer(OpmetingSektionalePoortMontageProfiel keuze) {
    switch (keuze) {
      case OpmetingSektionalePoortMontageProfiel.geenKaderwerk:
        return const SizedBox.shrink();
      case OpmetingSektionalePoortMontageProfiel.afwerkprofielenOverRail:
        return _bouwProfielMatenMetTekening(
          diagramType: _ProfielDiagramType.afwerkprofiel,
          sleutel: 'afwerk',
          maten: widget.model.afwerkprofielMaten,
          toonX: false,
          onChanged: (maten) =>
              _wijzig(widget.model.copyWith(afwerkprofielMaten: maten)),
        );
      case OpmetingSektionalePoortMontageProfiel.montageProfielDc1:
        return _bouwProfielMatenMetTekening(
          diagramType: _ProfielDiagramType.dc1,
          sleutel: 'dc1',
          maten: widget.model.montageDc1Maten,
          toonX: true,
          onChanged: (maten) =>
              _wijzig(widget.model.copyWith(montageDc1Maten: maten)),
        );
      case OpmetingSektionalePoortMontageProfiel.montageProfielDc2:
        return _bouwProfielMatenMetTekening(
          diagramType: _ProfielDiagramType.dc2,
          sleutel: 'dc2',
          maten: widget.model.montageDc2Maten,
          toonX: true,
          onChanged: (maten) =>
              _wijzig(widget.model.copyWith(montageDc2Maten: maten)),
        );
      case OpmetingSektionalePoortMontageProfiel.kokerprofielen:
        return _bouwKokerTabel();
    }
  }

  Widget _bouwProfielMatenMetTekening({
    required _ProfielDiagramType diagramType,
    required String sleutel,
    required OpmetingSektionalePoortProfielMaten maten,
    required bool toonX,
    required ValueChanged<OpmetingSektionalePoortProfielMaten> onChanged,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 250;
        final invoer = _bouwProfielMaten(
          sleutel: sleutel,
          maten: maten,
          toonX: toonX,
          onChanged: onChanged,
        );
        final diagram = _ProfielDiagram(type: diagramType);
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(alignment: Alignment.centerLeft, child: diagram),
              const SizedBox(height: 5),
              invoer,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 106, child: diagram),
            const SizedBox(width: 8),
            Expanded(child: invoer),
          ],
        );
      },
    );
  }

  Widget _bouwProfielMaten({
    required String sleutel,
    required OpmetingSektionalePoortProfielMaten maten,
    required bool toonX,
    required ValueChanged<OpmetingSektionalePoortProfielMaten> onChanged,
  }) {
    return Column(
      children: <Widget>[
        if (toonX)
          _NummerRij(
            label: 'X',
            labelBreedte: 28,
            controller: _controller('$sleutel-x', maten.xMm),
            achtervoegsel: 'mm',
            onChanged: (tekst) =>
                onChanged(maten.copyWith(xMm: _leesInt(tekst))),
          ),
        _NummerRij(
          label: 'L',
          labelBreedte: 28,
          controller: _controller('$sleutel-l', maten.lMm),
          achtervoegsel: 'mm',
          onChanged: (tekst) => onChanged(maten.copyWith(lMm: _leesInt(tekst))),
        ),
        _NummerRij(
          label: 'R',
          labelBreedte: 28,
          controller: _controller('$sleutel-r', maten.rMm),
          achtervoegsel: 'mm',
          onChanged: (tekst) => onChanged(maten.copyWith(rMm: _leesInt(tekst))),
        ),
        _NummerRij(
          label: 'B',
          labelBreedte: 28,
          controller: _controller('$sleutel-b', maten.bMm),
          achtervoegsel: 'mm',
          onChanged: (tekst) => onChanged(maten.copyWith(bMm: _leesInt(tekst))),
        ),
      ],
    );
  }

  Widget _bouwKokerTabel() {
    return Column(
      children: <Widget>[
        const Row(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Text(
                'Profiel',
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
              ),
            ),
            SizedBox(width: 5),
            Expanded(
              flex: 2,
              child: Text(
                'L',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
              ),
            ),
            SizedBox(width: 5),
            Expanded(
              flex: 2,
              child: Text(
                'R',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
              ),
            ),
            SizedBox(width: 5),
            Expanded(
              flex: 2,
              child: Text(
                'B',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        for (final profiel in OpmetingSektionalePoortModel.kokerProfielen)
          _bouwKokerRij(profiel),
      ],
    );
  }

  Widget _bouwKokerRij(String profiel) {
    final maten = widget.model.kokerVoor(profiel);

    Widget invoer(String zijde, int waarde, ValueChanged<int> onChanged) {
      return Expanded(
        flex: 2,
        child: TextField(
          controller: _controller('koker-$profiel-$zijde', waarde),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
          decoration: _invoerDecoratie(compact: true),
          onChanged: (tekst) => onChanged(_leesInt(tekst)),
        ),
      );
    }

    void wijzigKoker(OpmetingSektionalePoortKokerMaten nieuweMaten) {
      final lijst = widget.model.kokerMaten
          .map((item) {
            return item.profiel == profiel ? nieuweMaten : item;
          })
          .toList(growable: false);
      _wijzig(widget.model.copyWith(kokerMaten: lijst));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Text(
              profiel,
              style: const TextStyle(
                fontSize: 10.8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 5),
          invoer(
            'l',
            maten.lMm,
            (waarde) => wijzigKoker(maten.copyWith(lMm: waarde)),
          ),
          const SizedBox(width: 5),
          invoer(
            'r',
            maten.rMm,
            (waarde) => wijzigKoker(maten.copyWith(rMm: waarde)),
          ),
          const SizedBox(width: 5),
          invoer(
            'b',
            maten.bMm,
            (waarde) => wijzigKoker(maten.copyWith(bMm: waarde)),
          ),
        ],
      ),
    );
  }
}

class _SectieKaart extends StatelessWidget {
  const _SectieKaart({required this.titel, required this.child});

  final String titel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _OpmetingSektionalePoortRechterkolomState._rand,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            titel,
            style: const TextStyle(
              color: _OpmetingSektionalePoortRechterkolomState._groen,
              fontSize: 12.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          child,
        ],
      ),
    );
  }
}

class _RondeSelectieSectie<T> extends StatelessWidget {
  const _RondeSelectieSectie({
    required this.titel,
    required this.waarde,
    required this.keuzes,
    required this.labelVoor,
    required this.onChanged,
    this.kolommen = 1,
  });

  final String titel;
  final T waarde;
  final List<T> keuzes;
  final String Function(T waarde) labelVoor;
  final ValueChanged<T> onChanged;
  final int kolommen;

  @override
  Widget build(BuildContext context) {
    return _SectieKaart(
      titel: titel,
      child: _RondeSelectieRaster<T>(
        waarde: waarde,
        keuzes: keuzes,
        labelVoor: labelVoor,
        onChanged: onChanged,
        kolommen: kolommen,
      ),
    );
  }
}

class _RondeSelectieRaster<T> extends StatelessWidget {
  const _RondeSelectieRaster({
    required this.waarde,
    required this.keuzes,
    required this.labelVoor,
    required this.onChanged,
    this.kolommen = 1,
    this.beschikbaarVoor,
    this.onderschriftVoor,
  });

  final T waarde;
  final List<T> keuzes;
  final String Function(T waarde) labelVoor;
  final ValueChanged<T> onChanged;
  final int kolommen;
  final bool Function(T waarde)? beschikbaarVoor;
  final String Function(T waarde)? onderschriftVoor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const ruimte = 6.0;
        final effectiefKolommen = kolommen < 1 ? 1 : kolommen;
        final breedte =
            (constraints.maxWidth - ruimte * (effectiefKolommen - 1)) /
            effectiefKolommen;
        return Wrap(
          spacing: ruimte,
          runSpacing: 5,
          children: keuzes
              .map((keuze) {
                final beschikbaar = beschikbaarVoor?.call(keuze) ?? true;
                final onderschrift = onderschriftVoor?.call(keuze) ?? '';
                return SizedBox(
                  width: breedte,
                  child: _RondeSelectieTegel(
                    label: labelVoor(keuze),
                    onderschrift: beschikbaar ? '' : onderschrift,
                    geselecteerd: waarde == keuze,
                    beschikbaar: beschikbaar,
                    onTap: beschikbaar ? () => onChanged(keuze) : null,
                  ),
                );
              })
              .toList(growable: false),
        );
      },
    );
  }
}

class _RondeToggleRaster<T> extends StatelessWidget {
  const _RondeToggleRaster({
    required this.keuzes,
    required this.geselecteerd,
    required this.labelVoor,
    required this.onGewijzigd,
    this.kolommen = 1,
  });

  final List<T> keuzes;
  final Set<T> geselecteerd;
  final String Function(T waarde) labelVoor;
  final void Function(T waarde, bool actief) onGewijzigd;
  final int kolommen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const ruimte = 6.0;
        final breedte =
            (constraints.maxWidth - ruimte * (kolommen - 1)) / kolommen;
        return Wrap(
          spacing: ruimte,
          runSpacing: 5,
          children: keuzes
              .map((keuze) {
                final actief = geselecteerd.contains(keuze);
                return SizedBox(
                  width: breedte,
                  child: _RondeToggleTegel(
                    label: labelVoor(keuze),
                    waarde: actief,
                    onChanged: (nieuw) => onGewijzigd(keuze, nieuw),
                  ),
                );
              })
              .toList(growable: false),
        );
      },
    );
  }
}

class _RondeSelectieTegel extends StatelessWidget {
  const _RondeSelectieTegel({
    required this.label,
    required this.geselecteerd,
    this.onTap,
    this.beschikbaar = true,
    this.onderschrift = '',
  });

  final String label;
  final bool geselecteerd;
  final VoidCallback? onTap;
  final bool beschikbaar;
  final String onderschrift;

  @override
  Widget build(BuildContext context) {
    final kleur = beschikbaar
        ? _OpmetingSektionalePoortRechterkolomState._groen
        : const Color(0xFF9CA3AF);
    return Material(
      color: beschikbaar ? Colors.white : const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _RondeIndicator(
                geselecteerd: geselecteerd,
                beschikbaar: beschikbaar,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11.7,
                        fontWeight: FontWeight.w700,
                        color: beschikbaar
                            ? const Color(0xFF1F2937)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                    if (onderschrift.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          onderschrift,
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                            color: kleur,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!beschikbaar)
                const Padding(
                  padding: EdgeInsets.only(left: 3),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RondeToggleTegel extends StatelessWidget {
  const _RondeToggleTegel({
    required this.label,
    required this.waarde,
    required this.onChanged,
  });

  final String label;
  final bool waarde;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => onChanged(!waarde),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
          child: Row(
            children: <Widget>[
              _RondeIndicator(geselecteerd: waarde),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KleineRondeKeuze extends StatelessWidget {
  const _KleineRondeKeuze({
    required this.label,
    required this.geselecteerd,
    required this.onTap,
  });

  final String label;
  final bool geselecteerd;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _RondeIndicator(geselecteerd: geselecteerd),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RondeIndicator extends StatelessWidget {
  const _RondeIndicator({required this.geselecteerd, this.beschikbaar = true});

  final bool geselecteerd;
  final bool beschikbaar;

  @override
  Widget build(BuildContext context) {
    final kleur = beschikbaar
        ? _OpmetingSektionalePoortRechterkolomState._groen
        : const Color(0xFF9CA3AF);
    return Container(
      width: 17,
      height: 17,
      margin: const EdgeInsets.only(top: 0.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: kleur, width: 1.7),
      ),
      alignment: Alignment.center,
      child: geselecteerd
          ? Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: kleur),
            )
          : null,
    );
  }
}

class _JaNeeSectie extends StatelessWidget {
  const _JaNeeSectie({
    required this.titel,
    required this.waarde,
    required this.onChanged,
    this.onderschrift = '',
  });

  final String titel;
  final bool waarde;
  final ValueChanged<bool> onChanged;
  final String onderschrift;

  @override
  Widget build(BuildContext context) {
    return _SectieKaart(
      titel: titel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _RondeSelectieTegel(
                  label: 'Ja',
                  geselecteerd: waarde,
                  onTap: () => onChanged(true),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _RondeSelectieTegel(
                  label: 'Nee',
                  geselecteerd: !waarde,
                  onTap: () => onChanged(false),
                ),
              ),
            ],
          ),
          if (onderschrift.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                onderschrift,
                style: const TextStyle(
                  fontSize: 9,
                  color: Color(0xFF6B7280),
                  height: 1.3,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NummerRij extends StatelessWidget {
  const _NummerRij({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.achtervoegsel = '',
    this.labelBreedte = 90,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String achtervoegsel;
  final double labelBreedte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: labelBreedte,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
                signed: false,
              ),
              autocorrect: false,
              enableSuggestions: false,
              selectAllOnFocus: true,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              decoration: _invoerDecoratie(achtervoegsel: achtervoegsel),
              onTap: () {
                controller.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: controller.text.length,
                );
              },
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

enum _ProfielDiagramType { afwerkprofiel, dc1, dc2 }

class _ProfielDiagram extends StatelessWidget {
  const _ProfielDiagram({required this.type});

  final _ProfielDiagramType type;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104,
      height: 86,
      child: CustomPaint(painter: _ProfielDiagramPainter(type)),
    );
  }
}

class _ProfielDiagramPainter extends CustomPainter {
  const _ProfielDiagramPainter(this.type);

  final _ProfielDiagramType type;

  @override
  void paint(Canvas canvas, Size size) {
    final rood = Paint()
      ..color = const Color(0xFFE11D48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;
    final tekst = const TextStyle(
      color: Color(0xFF111827),
      fontSize: 9,
      fontWeight: FontWeight.w700,
    );

    if (type == _ProfielDiagramType.afwerkprofiel) {
      final pad = Path()
        ..moveTo(16, 65)
        ..lineTo(16, 24)
        ..lineTo(82, 24)
        ..lineTo(82, 65);
      canvas.drawPath(pad, rood);
      _schrijf(canvas, 'L', const Offset(7, 43), tekst);
      _schrijf(canvas, 'B', const Offset(47, 12), tekst);
      _schrijf(canvas, 'R', const Offset(88, 43), tekst);
      return;
    }

    final bovenMaat = type == _ProfielDiagramType.dc1 ? '40' : '50';
    final links = type == _ProfielDiagramType.dc1 ? 28.0 : 24.0;
    final rechts = type == _ProfielDiagramType.dc1 ? 72.0 : 76.0;
    final pad = Path()
      ..moveTo(9, 71)
      ..lineTo(rechts, 71)
      ..lineTo(rechts, 27)
      ..lineTo(links, 27)
      ..lineTo(links, 44);
    canvas.drawPath(pad, rood);
    _schrijf(canvas, bovenMaat, Offset((links + rechts) / 2 - 6, 12), tekst);
    _schrijf(canvas, '15', Offset(links - 22, 31), tekst);
    _schrijf(canvas, '40', Offset(rechts + 4, 43), tekst);
    _schrijf(canvas, 'X', const Offset(45, 73), tekst);
  }

  void _schrijf(Canvas canvas, String waarde, Offset positie, TextStyle stijl) {
    final painter = TextPainter(
      text: TextSpan(text: waarde, style: stijl),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, positie);
  }

  @override
  bool shouldRepaint(covariant _ProfielDiagramPainter oldDelegate) {
    return oldDelegate.type != type;
  }
}

InputDecoration _invoerDecoratie({
  String hint = '',
  String achtervoegsel = '',
  String? helper,
  bool compact = false,
}) {
  return InputDecoration(
    hintText: hint.isEmpty ? null : hint,
    suffixText: achtervoegsel.isEmpty ? null : achtervoegsel,
    helperText: helper,
    isDense: true,
    contentPadding: EdgeInsets.symmetric(
      horizontal: compact ? 6 : 9,
      vertical: compact ? 7 : 9,
    ),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF0B7A3B), width: 1.4),
    ),
  );
}
