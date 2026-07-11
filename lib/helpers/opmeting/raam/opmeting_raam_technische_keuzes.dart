import 'package:flutter/material.dart';

import 'opmeting_raam_technische_keuze_rij.dart';
import 'opmeting_raam_kleinhout_helper.dart';
import 'opmeting_raam_kleinhout_model.dart';
import 'opmeting_raam_vulling_helper.dart';
import 'opmeting_raam_extra_item_menu.dart';
import 'opmeting_raam_technisch_item_model.dart';

class OpmetingRaamTechnischeKeuzes extends StatefulWidget {
  const OpmetingRaamTechnischeKeuzes({
    super.key,
    required this.vleugelprofiel,
    required this.dorpel,
    required this.binnenkastprofiel,
    required this.rolluik,
    required this.vliegenraam,
    required this.verbredingsprofielen,
    required this.koppelprofielen,
    required this.ventilatierooster,
    required this.hoekprofielen,
    required this.binnenafwerking,
    required this.rolluikkast,
    required this.vensterbanken,
    required this.afwerkingslatten,
    required this.onChanged,
    this.opvullingen = const <OpmetingRaamVullingLegendaItem>[],
    this.kleinhouten = const <OpmetingRaamKleinhoutLegendaItem>[],
  });

  final String vleugelprofiel;
  final String dorpel;
  final String binnenkastprofiel;
  final String rolluik;
  final String vliegenraam;
  final String verbredingsprofielen;
  final String koppelprofielen;
  final String ventilatierooster;
  final String hoekprofielen;
  final String binnenafwerking;
  final String rolluikkast;
  final String vensterbanken;
  final String afwerkingslatten;

  final List<OpmetingRaamVullingLegendaItem> opvullingen;

  final List<OpmetingRaamKleinhoutLegendaItem> kleinhouten;

  final void Function(String veld, String waarde) onChanged;

  @override
  State<OpmetingRaamTechnischeKeuzes> createState() {
    return _OpmetingRaamTechnischeKeuzesState();
  }
}

class _OpmetingRaamTechnischeKeuzesState
    extends State<OpmetingRaamTechnischeKeuzes> {
  static const Color groen = Color(0xFF0B7A3B);
  static const Color lichtGroen = Color(0xFFE7F6EC);
  static const Color rand = Color(0xFFE5E7EB);
  static const Color tekstGrijs = Color(0xFF6B7280);

  bool _opvullingenOpen = false;
  bool _kleinhoutenOpen = false;

  final List<OpmetingRaamTechnischItemModel> _extraItems =
      <OpmetingRaamTechnischItemModel>[];

  Future<void> _openExtraItemMenu() async {
    final nieuwItem = await OpmetingRaamExtraItemMenu.toon(context);

    if (!mounted || nieuwItem == null) {
      return;
    }

    setState(() {
      _extraItems.add(nieuwItem);
    });
  }

  void _wijzigExtraItemKeuze(int index, String nieuweKeuze) {
    if (index < 0 || index >= _extraItems.length) {
      return;
    }

    setState(() {
      _extraItems[index] = _extraItems[index].copyWith(
        gekozenSoort: nieuweKeuze,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
      decoration: _kaartDecoratie(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'TECHNISCHE KEUZES',
                  style: TextStyle(
                    color: groen,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(
                width: 30,
                height: 30,
                child: IconButton(
                  tooltip: 'Extra technisch item toevoegen',
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  onPressed: _openExtraItemMenu,
                  icon: const Icon(
                    Icons.add_circle_outline,
                    size: 21,
                    color: groen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _keuze(
            'vleugelprofiel',
            'Vleugelprofiel',
            widget.vleugelprofiel,
            const ['Classic', 'Softline', 'Steel look', 'Renovatie'],
          ),
          _keuze('dorpel', 'Dorpel', widget.dorpel, const [
            'Geen',
            'Standaard',
            'Blauwe steen',
            'Aluminium dorpel',
          ]),
          _opvullingenMenu(),
          _kleinhoutenMenu(),
          _keuze(
            'binnenkastprofiel',
            'Binnenkastprofiel',
            widget.binnenkastprofiel,
            const ['Geen', '4047', '4048', '4050'],
          ),
          _keuze('rolluik', 'Rolluik', widget.rolluik, const [
            'Geen',
            'Lintbediend',
            'Elektrisch',
            'Elektrisch IO',
            'Solar IO',
          ]),
          _keuze('vliegenraam', 'Vliegenraam', widget.vliegenraam, const [
            'Geen',
            'Vast',
            'Schuif',
            'Hordeur',
            'Plissé',
          ]),
          _keuze(
            'verbredingsprofielen',
            'Verbredingsprofielen',
            widget.verbredingsprofielen,
            const [
              'Niet gebruikt',
              'Links',
              'Rechts',
              'Boven',
              'Onder',
              'Rondom',
            ],
          ),
          _keuze(
            'koppelprofielen',
            'Koppelprofielen',
            widget.koppelprofielen,
            const ['Niet gebruikt', 'Links', 'Rechts', 'Boven', 'Onder'],
          ),
          _keuze(
            'ventilatierooster',
            'Ventilatierooster',
            widget.ventilatierooster,
            const ['Geen', 'Invisivent', 'Glasrooster', 'Duco'],
          ),
          _keuze('hoekprofielen', 'Hoekprofielen', widget.hoekprofielen, const [
            'Geen',
            'Standaard',
            'Breed',
            'Speciaal',
          ]),
          _keuze(
            'binnenafwerking',
            'Binnenafwerking',
            widget.binnenafwerking,
            const [
              'Geen',
              'Chambrangs',
              'Binnenkast',
              'Chambrangs en binnenkasten',
            ],
          ),
          _keuze('rolluikkast', 'Rolluikkast', widget.rolluikkast, const [
            'Geen',
            'Kast 155',
            'Kast 180',
            'Kast 205',
          ]),
          _keuze('vensterbanken', 'Vensterbanken', widget.vensterbanken, const [
            'Geen',
            'Binnen PVC',
            'Binnen aluminium',
            'Buiten aluminium',
          ]),
          _keuze(
            'afwerkingslatten',
            'Afwerkingslatten buitenzijde',
            widget.afwerkingslatten,
            const ['Geen', 'Links', 'Rechts', 'Boven', 'Onder', 'Rondom'],
          ),
          ..._extraItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return OpmetingRaamTechnischeKeuzeRij(
              titel: item.titel,
              soorten: item.soorten,
              gekozenSoort: item.gekozenSoort,
              onGewijzigd: (nieuweKeuze) {
                _wijzigExtraItemKeuze(index, nieuweKeuze);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _opvullingenMenu() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: _uitklapMenu(
        titel: 'Opvulling',
        samenvatting: _opvullingSamenvatting(),
        isOpen: _opvullingenOpen,
        heeftInhoud: widget.opvullingen.isNotEmpty,
        onTap: () {
          setState(() {
            _opvullingenOpen = !_opvullingenOpen;
          });
        },
        inhoud: _opvullingenLijst(),
      ),
    );
  }

  Widget _kleinhoutenMenu() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: _uitklapMenu(
        titel: 'Kleinhouten',
        samenvatting: _kleinhoutSamenvatting(),
        isOpen: _kleinhoutenOpen,
        heeftInhoud: widget.kleinhouten.isNotEmpty,
        onTap: () {
          setState(() {
            _kleinhoutenOpen = !_kleinhoutenOpen;
          });
        },
        inhoud: _kleinhoutenLijst(),
      ),
    );
  }

  String _opvullingSamenvatting() {
    if (widget.opvullingen.isEmpty) {
      return 'Geen opvulling voorzien';
    }

    if (widget.opvullingen.length == 1) {
      return widget.opvullingen.first.naam;
    }

    return '${widget.opvullingen.length} opvullingen';
  }

  String _kleinhoutSamenvatting() {
    if (widget.kleinhouten.isEmpty) {
      return 'Geen kleinhouten voorzien';
    }

    if (widget.kleinhouten.length == 1) {
      final item = widget.kleinhouten.first;

      return '${item.type.korteNaam} · '
          'hor ${item.aantalHorizontaal} · '
          'vert ${item.aantalVerticaal}';
    }

    return '${widget.kleinhouten.length} uitvoeringen';
  }

  Widget _uitklapMenu({
    required String titel,
    required String samenvatting,
    required bool isOpen,
    required bool heeftInhoud,
    required VoidCallback onTap,
    required Widget inhoud,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: isOpen ? groen : rand,
          width: isOpen ? 1.4 : 1,
        ),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        titel,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        samenvatting,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: heeftInhoud ? groen : tekstGrijs,
                          fontSize: 10.5,
                          fontWeight: heeftInhoud
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      isOpen
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 19,
                      color: groen,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isOpen) ...[const Divider(height: 1, color: rand), inhoud],
        ],
      ),
    );
  }

  Widget _opvullingenLijst() {
    if (widget.opvullingen.isEmpty) {
      return _legeMelding(
        'Er zijn nog geen opvullingen aan de glasvlakken toegewezen.',
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: widget.opvullingen.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: rand),
              ),
              child: Row(
                children: [
                  _nummerCirkel(item.nummer),
                  const SizedBox(width: 8),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: item.weergaveKleur,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: item.kleur.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.naam,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _kleinhoutenLijst() {
    if (widget.kleinhouten.isEmpty) {
      return _legeMelding(
        'Er zijn nog geen kleinhouten aan de gevulde glasvlakken toegevoegd.',
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: widget.kleinhouten.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: rand),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _nummerCirkel(item.nummer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.type.korteNaam,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Horizontaal: '
                          '${item.aantalHorizontaal} · '
                          'Verticaal: '
                          '${item.aantalVerticaal}',
                          style: const TextStyle(
                            color: tekstGrijs,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (item.patroon ==
                                OpmetingRaamKleinhoutPatroon.bovenverdeling &&
                            item.horizontaleHoogteMm != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Hoogte horizontaal: '
                            '${_formatteerMaat(item.horizontaleHoogteMm!)} mm',
                            style: const TextStyle(
                              color: tekstGrijs,
                              fontSize: 10,
                            ),
                          ),
                        ],
                        const SizedBox(height: 2),
                        Text(
                          item.vlakIds.length == 1
                              ? 'Toegepast op 1 glasvlak'
                              : 'Toegepast op '
                                    '${item.vlakIds.length} glasvlakken',
                          style: const TextStyle(
                            color: tekstGrijs,
                            fontSize: 9.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _nummerCirkel(int nummer) {
    return Container(
      width: 25,
      height: 25,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: lichtGroen,
        shape: BoxShape.circle,
        border: Border.all(color: groen),
      ),
      child: Text(
        '$nummer',
        style: const TextStyle(
          color: groen,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _legeMelding(String tekst) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      color: const Color(0xFFF9FAFB),
      child: Text(
        tekst,
        style: const TextStyle(color: tekstGrijs, fontSize: 10, height: 1.3),
      ),
    );
  }

  String _formatteerMaat(double waarde) {
    if (waarde == waarde.roundToDouble()) {
      return waarde.round().toString();
    }

    return waarde.toStringAsFixed(1);
  }

  Widget _keuze(String veld, String titel, String waarde, List<String> keuzes) {
    return OpmetingRaamTechnischeKeuzeRij(
      titel: titel,
      soorten: keuzes,
      gekozenSoort: waarde,
      onGewijzigd: (String nieuweWaarde) {
        widget.onChanged(veld, nieuweWaarde);
      },
    );
  }

  BoxDecoration _kaartDecoratie() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: rand),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.035),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
