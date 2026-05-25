import 'package:flutter/material.dart';

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
                start: planning.volledigeDag || planning.startUur == null
                    ? ''
                    : '${planning.startUur.toString().padLeft(2, '0')}:${planning.startMinuut.toString().padLeft(2, '0')}',
                eind: planning.volledigeDag || planning.eindUur == null
                    ? ''
                    : '${planning.eindUur.toString().padLeft(2, '0')}:${planning.eindMinuut.toString().padLeft(2, '0')}',
                kleur: planning.type == 'verlof' ? Colors.red : Colors.blue,
                titel: planning.titel,
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
                start: planning.volledigeDag || planning.startUur == null
                    ? ''
                    : '${planning.startUur.toString().padLeft(2, '0')}:${planning.startMinuut.toString().padLeft(2, '0')}',
                eind: planning.volledigeDag || planning.eindUur == null
                    ? ''
                    : '${planning.eindUur.toString().padLeft(2, '0')}:${planning.eindMinuut.toString().padLeft(2, '0')}',
                kleur: Colors.orange,
                titel: planning.titel,
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
  final String start;
  final String eind;
  final Color kleur;
  final String titel;

  const _TaakRij({
    required this.start,
    required this.eind,
    required this.kleur,
    required this.titel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Row(
        children: [
          SizedBox(
            width: 46,
            child: Text(
              start,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(
            width: 18,
            child: Center(
              child: Text(
                '-',
                style: TextStyle(color: Colors.black45),
              ),
            ),
          ),
          SizedBox(
            width: 46,
            child: Text(
              eind,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: kleur,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
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
        ],
      ),
    );
  }
}
