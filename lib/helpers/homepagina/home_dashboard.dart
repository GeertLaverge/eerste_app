import 'package:flutter/material.dart';

import '../agenda/agenda_route_helper.dart';
import '../klanten/fiche/klantenfiche_repository.dart';

class HomeDashboard extends StatefulWidget {
  final List<dynamic> planningVandaag;
  final List<dynamic> dagTakenVandaag;
  final List<dynamic> klantTakenVandaag;

  const HomeDashboard({
    super.key,
    required this.planningVandaag,
    required this.dagTakenVandaag,
    required this.klantTakenVandaag,
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
    debugPrint('VOOR: ${taak.tekst} = ${taak.isAfgewerkt}');

    setState(() {
      taak.isAfgewerkt = !taak.isAfgewerkt;
    });

    debugPrint('NA: ${taak.tekst} = ${taak.isAfgewerkt}');

    await KlantenficheRepository.bewaarKlantenFiche(
      klant,
    );
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 700;

    final planningPlaatsers = widget.planningVandaag.where((item) {
      return item.type == 'planning';
    }).toList();

    final planningBureau = widget.planningVandaag.where((item) {
      return item.type != 'planning';
    }).toList();

    if (widget.planningVandaag.isEmpty &&
        widget.dagTakenVandaag.isEmpty &&
        widget.klantTakenVandaag.isEmpty) {
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
            taken: planningPlaatsers.map((planning) {
              return _TaakRij(
                compact: compact,
                start: planning.volledigeDag || planning.startUur == null
                    ? ''
                    : '${planning.startUur.toString().padLeft(2, '0')}:${planning.startMinuut.toString().padLeft(2, '0')}',
                eind: planning.volledigeDag || planning.eindUur == null
                    ? ''
                    : '${planning.eindUur.toString().padLeft(2, '0')}:${planning.eindMinuut.toString().padLeft(2, '0')}',
                kleur: const Color(0xFF0B7A3B),
                titel: planning.titel,
                straat: planning.straatnaam,
                huisNr: planning.huisNr,
                postcode: planning.postcode,
                gemeente: planning.gemeente,
                meldingVoorafMinuten: 0,
              );
            }).toList(),
          ),
        if (planningPlaatsers.isNotEmpty && planningBureau.isNotEmpty)
          const SizedBox(height: 6),
        if (widget.klantTakenVandaag.isNotEmpty) const SizedBox(height: 6),
        ...widget.klantTakenVandaag.map((klant) {
          final taken = List.from(klant.klantTaken);

          taken.sort((a, b) {
            if (a.isAfgewerkt == b.isAfgewerkt) return 0;
            return a.isAfgewerkt ? 1 : -1;
          });

          return _TaakSectie(
            titel: 'Taak voor ${klant.naam}',
            taken: taken.map<Widget>((taak) {
              return _KlantTaakRij(
                tekst: taak.tekst,
                isAfgewerkt: taak.isAfgewerkt,
                onTap: () {
                  print('CHECKBOX GEKLIKT: ${taak.tekst}');
                  taakAanpassen(klant, taak);
                },
              );
            }).toList(),
          );
        }),
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
                debugPrint('CHECKBOX GEKLIKT');
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
  });

  bool get heeftAdres {
    return straat.trim().isNotEmpty ||
        postcode.trim().isNotEmpty ||
        gemeente.trim().isNotEmpty;
  }

  bool get heeftMelding {
    return meldingVoorafMinuten > 0;
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
          if (heeftMelding)
            const Padding(
              padding: EdgeInsets.only(right: 6),
              child: Icon(
                Icons.notifications_none,
                size: 15,
                color: Color(0xFF0B7A3B),
              ),
            ),
          InkWell(
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
            child: Padding(
              padding: EdgeInsets.only(left: compact ? 4 : 10),
              child: Icon(
                Icons.navigation_outlined,
                size: 18,
                color:
                    heeftAdres ? const Color(0xFF0B7A3B) : Colors.grey.shade300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
