import 'package:flutter/material.dart';
import '../agenda/agenda_route_helper.dart';

class HomeDashboard extends StatelessWidget {
  final List<dynamic> planningVandaag;
  final List<dynamic> dagTakenVandaag;

  const HomeDashboard({
    super.key,
    required this.planningVandaag,
    required this.dagTakenVandaag,
  });

  static const rand = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 700;

    if (planningVandaag.isEmpty && dagTakenVandaag.isEmpty) {
      return const _TaakSectie(
        titel: 'Vandaag',
        taken: [
          _LegeTaakRij(),
        ],
      );
    }

    return Column(
      children: [
        if (planningVandaag.isNotEmpty)
          _TaakSectie(
            titel: 'Planning vandaag',
            taken: planningVandaag.map((planning) {
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
        if (planningVandaag.isNotEmpty && dagTakenVandaag.isNotEmpty)
          const SizedBox(height: 6),
        if (dagTakenVandaag.isNotEmpty)
          _TaakSectie(
            titel: 'Dagtaak opvolging',
            taken: dagTakenVandaag.map((planning) {
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
    final tijdBreedte = compact ? 39.0 : 46.0;
    final streepBreedte = compact ? 8.0 : 18.0;
    final bolRuimte = compact ? 4.0 : 10.0;
    final naamRuimte = compact ? 4.0 : 10.0;

    return SizedBox(
      height: 34,
      child: Row(
        children: [
          SizedBox(
            width: tijdBreedte,
            child: Text(
              start,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(
            width: streepBreedte,
            child: const Center(
              child: Text(
                '-',
                style: TextStyle(color: Colors.black45),
              ),
            ),
          ),
          SizedBox(
            width: tijdBreedte,
            child: Text(
              eind,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(width: bolRuimte),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: kleur,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: naamRuimte),
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
