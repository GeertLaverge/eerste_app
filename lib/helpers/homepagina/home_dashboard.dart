import 'package:flutter/material.dart';

import '../agenda/agenda_route_helper.dart';
import '../klanten/fiche/klantenfiche_repository.dart';

class HomeDashboard extends StatefulWidget {
  final List<dynamic> planningVandaag;
  final List<dynamic> dagTakenVandaag;
  final List<dynamic> klantTakenVandaag;
  final List<dynamic> kraanReservatiesVandaag;

  const HomeDashboard({
    super.key,
    required this.planningVandaag,
    required this.dagTakenVandaag,
    required this.klantTakenVandaag,
    required this.kraanReservatiesVandaag,
  });

  static const rand = Color(0xFFE5E7EB);

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  Future<void> taakAanpassen(
    dynamic klant,
    dynamic taak,
  ) async {
    setState(() {
      taak.isAfgewerkt = !taak.isAfgewerkt;
    });

    await KlantenficheRepository.bewaarKlantenFiche(
      klant,
    );
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 700;

    final planningPlaatsers = widget.planningVandaag.where((item) {
      return item.type == 'planning' ||
          item.type == 'opvolging' ||
          item.type == 'nadienst';
    }).toList();

    final planningBureau = widget.planningVandaag.where((item) {
      return item.type != 'planning' &&
          item.type != 'opvolging' &&
          item.type != 'nadienst' &&
          item.type != 'kraan';
    }).toList();

    if (widget.planningVandaag.isEmpty &&
        widget.dagTakenVandaag.isEmpty &&
        widget.klantTakenVandaag.isEmpty &&
        widget.kraanReservatiesVandaag.isEmpty) {
      return const _TaakSectie(
        titel: 'Vandaag',
        taken: [
          _LegeTaakRij(),
        ],
      );
    }

    return Column(
      children: [
        if (planningPlaatsers.isNotEmpty)
          _TaakSectie(
            titel: 'Planning plaatsers',
            taken: planningPlaatsers.expand<Widget>((planning) {
              final klant = widget.klantTakenVandaag.where((k) {
                return k.naam.toString().trim().toLowerCase() ==
                    planning.naamKlant.toString().trim().toLowerCase();
              }).toList();

              final klantenFiche = klant.isNotEmpty ? klant.first : null;

              final takenWidgets = <Widget>[
                _TaakRij(
                  compact: compact,
                  start: planning.volledigeDag || planning.startUur == null
                      ? ''
                      : '${planning.startUur.toString().padLeft(2, '0')}:${planning.startMinuut.toString().padLeft(2, '0')}',
                  eind: planning.volledigeDag || planning.eindUur == null
                      ? ''
                      : '${planning.eindUur.toString().padLeft(2, '0')}:${planning.eindMinuut.toString().padLeft(2, '0')}',
                  kleur: planning.type == 'nadienst'
                      ? Colors.purple
                      : planning.type == 'opvolging'
                          ? Colors.amber
                          : const Color(0xFF0B7A3B),
                  titel: planning.titel,
                  straat: planning.straatnaam,
                  huisNr: planning.huisNr,
                  postcode: planning.postcode,
                  gemeente: planning.gemeente,
                  meldingVoorafMinuten: 0,
                  opmerkingen: planning.opmerkingen,
                  toonKlantNotities: klantenFiche != null,
                  klantNotities: klantenFiche?.notities ?? '',
                ),
              ];

              if (klant.isNotEmpty) {
                final klantenFiche = klant.first;
                final taken = List.from(klantenFiche.klantTaken);

                taken.sort((a, b) {
                  if (a.isAfgewerkt == b.isAfgewerkt) return 0;
                  return a.isAfgewerkt ? 1 : -1;
                });

                takenWidgets.add(
                  Container(
                    margin: const EdgeInsets.only(
                      left: 22,
                      top: 4,
                      bottom: 8,
                    ),
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: HomeDashboard.rand,
                      ),
                    ),
                    child: Column(
                      children: taken.map<Widget>((taak) {
                        return _KlantTaakRij(
                          tekst: taak.tekst,
                          isAfgewerkt: taak.isAfgewerkt,
                          onTap: () {
                            taakAanpassen(klantenFiche, taak);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                );
              }

              return takenWidgets;
            }).toList(),
          ),
        if (widget.kraanReservatiesVandaag.isNotEmpty)
          _TaakSectie(
            titel: 'Kraanreservaties',
            taken: widget.kraanReservatiesVandaag.map((planning) {
              return _TaakRij(
                compact: compact,
                start: planning.volledigeDag || planning.startUur == null
                    ? ''
                    : '${planning.startUur.toString().padLeft(2, '0')}:${planning.startMinuut.toString().padLeft(2, '0')}',
                eind: planning.volledigeDag || planning.eindUur == null
                    ? ''
                    : '${planning.eindUur.toString().padLeft(2, '0')}:${planning.eindMinuut.toString().padLeft(2, '0')}',
                kleur: Colors.brown,
                titel: '🏗️ ${planning.titel}',
                straat: planning.straatnaam,
                huisNr: planning.huisNr,
                postcode: planning.postcode,
                gemeente: planning.gemeente,
                meldingVoorafMinuten: 0,
                opmerkingen: planning.opmerkingen,
              );
            }).toList(),
          ),
        if (planningPlaatsers.isNotEmpty && planningBureau.isNotEmpty)
          const SizedBox(height: 6),
        if (planningBureau.isNotEmpty)
          _TaakSectie(
            titel: 'Planning bureau',
            taken: planningBureau.map((planning) {
              return _TaakRij(
                compact: compact,
                start: planning.volledigeDag || planning.startUur == null
                    ? ''
                    : '${planning.startUur.toString().padLeft(2, '0')}:${planning.startMinuut.toString().padLeft(2, '0')}',
                eind: planning.volledigeDag || planning.eindUur == null
                    ? ''
                    : '${planning.eindUur.toString().padLeft(2, '0')}:${planning.eindMinuut.toString().padLeft(2, '0')}',
                kleur: planning.type == 'verlof' ? Colors.red : Colors.blue,
                titel: planning.titel,
                straat: planning.straatnaam,
                huisNr: planning.huisNr,
                postcode: planning.postcode,
                gemeente: planning.gemeente,
                meldingVoorafMinuten: planning.meldingVoorafMinuten,
                opmerkingen: planning.opmerkingen,
              );
            }).toList(),
          ),
        if ((planningPlaatsers.isNotEmpty || planningBureau.isNotEmpty) &&
            widget.dagTakenVandaag.isNotEmpty)
          const SizedBox(height: 6),
        if (widget.dagTakenVandaag.isNotEmpty)
          _TaakSectie(
            titel: 'Dagtaak opvolging',
            taken: widget.dagTakenVandaag.map((planning) {
              return _TaakRij(
                compact: compact,
                start: planning.volledigeDag || planning.startUur == null
                    ? ''
                    : '${planning.startUur.toString().padLeft(2, '0')}:${planning.startMinuut.toString().padLeft(2, '0')}',
                eind: planning.volledigeDag || planning.eindUur == null
                    ? ''
                    : '${planning.eindUur.toString().padLeft(2, '0')}:${planning.eindMinuut.toString().padLeft(2, '0')}',
                kleur: Colors.orange,
                titel: planning.titel,
                straat: planning.straatnaam,
                huisNr: planning.huisNr,
                postcode: planning.postcode,
                gemeente: planning.gemeente,
                meldingVoorafMinuten: planning.meldingVoorafMinuten,
                opmerkingen: planning.opmerkingen,
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _KlantTaakRij extends StatelessWidget {
  final String tekst;
  final bool isAfgewerkt;
  final VoidCallback onTap;

  const _KlantTaakRij({
    required this.tekst,
    required this.isAfgewerkt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Row(
        children: [
          SizedBox(
            width: 34,
            height: 34,
            child: Checkbox(
              value: isAfgewerkt,
              activeColor: const Color(0xFF0B7A3B),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              onChanged: (_) {
                onTap();
              },
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                tekst,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize: 13.2,
                  fontWeight: FontWeight.w600,
                  color: isAfgewerkt ? Colors.grey : Colors.black87,
                  decoration: isAfgewerkt
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaakSectie extends StatelessWidget {
  final String titel;
  final List<Widget> taken;

  const _TaakSectie({
    required this.titel,
    required this.taken,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 2,
        vertical: 2,
      ),
      padding: const EdgeInsets.fromLTRB(
        10,
        8,
        10,
        8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HomeDashboard.rand),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              titel,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...taken,
        ],
      ),
    );
  }
}

class _LegeTaakRij extends StatelessWidget {
  const _LegeTaakRij();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 34,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Geen taken vandaag',
          style: TextStyle(
            fontSize: 13.2,
            color: Colors.black54,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _TaakRij extends StatelessWidget {
  final bool compact;
  final String start;
  final String eind;
  final Color kleur;
  final String titel;
  final String straat;
  final String huisNr;
  final String postcode;
  final String gemeente;
  final int meldingVoorafMinuten;
  final String opmerkingen;
  final String klantNotities;
  final bool toonKlantNotities;

  const _TaakRij({
    required this.compact,
    required this.start,
    required this.eind,
    required this.kleur,
    required this.titel,
    required this.straat,
    required this.huisNr,
    required this.postcode,
    required this.gemeente,
    required this.meldingVoorafMinuten,
    required this.opmerkingen,
    this.klantNotities = '',
    this.toonKlantNotities = false,
  });

  bool get heeftAdres {
    return straat.trim().isNotEmpty ||
        postcode.trim().isNotEmpty ||
        gemeente.trim().isNotEmpty;
  }

  bool get heeftAfspraakNotitie {
    return opmerkingen.trim().isNotEmpty;
  }

  bool get heeftKlantNotitie {
    return toonKlantNotities && klantNotities.trim().isNotEmpty;
  }

  void toonPopup({
    required BuildContext context,
    required String titel,
    required String tekst,
  }) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(titel),
          content: Text(tekst),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Sluiten'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tijdTekst = start.isEmpty || eind.isEmpty ? '' : '$start - $eind';

    return SizedBox(
      height: 34,
      child: Row(
        children: [
          SizedBox(
            width: compact ? 88 : 112,
            child: Text(
              tijdTekst,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: kleur,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    titel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (heeftAfspraakNotitie)
                  InkWell(
                    onTap: () {
                      toonPopup(
                        context: context,
                        titel: 'Notitie afspraak',
                        tekst: opmerkingen,
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.sticky_note_2_outlined,
                        size: 16,
                        color: Color(0xFF0B7A3B),
                      ),
                    ),
                  ),
                if (heeftKlantNotitie)
                  InkWell(
                    onTap: () {
                      toonPopup(
                        context: context,
                        titel: 'Notities klant',
                        tekst: klantNotities,
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.sticky_note_2_outlined,
                        size: 16,
                        color: Color(0xFF0B7A3B),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 36,
            height: 36,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: heeftAdres
                  ? () async {
                      await AgendaRouteHelper.openRoute(
                        straat: straat,
                        huisNr: huisNr,
                        postcode: postcode,
                        gemeente: gemeente,
                      );
                    }
                  : null,
              child: Center(
                child: Icon(
                  Icons.navigation_outlined,
                  size: 18,
                  color: heeftAdres
                      ? const Color(0xFF0B7A3B)
                      : Colors.grey.shade300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
