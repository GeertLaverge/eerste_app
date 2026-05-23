import 'package:flutter/material.dart';

class AgendaFilterMenu extends StatelessWidget {
  final bool toonPlanning;
  final bool toonOpvolging;
  final bool toonNadienst;
  final bool toonAfspraak;
  final bool toonDagtaak;
  final bool toonVerlof;
  final bool toonKraan;

  final ValueChanged<bool> onPlanningChanged;
  final ValueChanged<bool> onOpvolgingChanged;
  final ValueChanged<bool> onNadienstChanged;
  final ValueChanged<bool> onAfspraakChanged;
  final ValueChanged<bool> onDagtaakChanged;
  final ValueChanged<bool> onVerlofChanged;
  final ValueChanged<bool> onKraanChanged;

  const AgendaFilterMenu({
    super.key,
    required this.toonPlanning,
    required this.toonOpvolging,
    required this.toonNadienst,
    required this.toonAfspraak,
    required this.toonDagtaak,
    required this.toonVerlof,
    required this.toonKraan,
    required this.onPlanningChanged,
    required this.onOpvolgingChanged,
    required this.onNadienstChanged,
    required this.onAfspraakChanged,
    required this.onDagtaakChanged,
    required this.onVerlofChanged,
    required this.onKraanChanged,
  });

  Widget filterRegel({
    required String tekst,
    required bool waarde,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          14,
        ),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: SwitchListTile(
        dense: true,
        contentPadding: const EdgeInsets.fromLTRB(
          14,
          2,
          8,
          2,
        ),
        activeColor: Colors.white,
        activeTrackColor: const Color(
          0xFF0B7A3B,
        ),
        inactiveTrackColor: Colors.grey.shade300,
        value: waarde,
        onChanged: onChanged,
        title: Text(
          tekst,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          4,
          4,
          4,
          8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            filterRegel(
              tekst: 'Planning',
              waarde: toonPlanning,
              onChanged: onPlanningChanged,
            ),
            filterRegel(
              tekst: 'Opvolging',
              waarde: toonOpvolging,
              onChanged: onOpvolgingChanged,
            ),
            filterRegel(
              tekst: 'Nadienst',
              waarde: toonNadienst,
              onChanged: onNadienstChanged,
            ),
            filterRegel(
              tekst: 'Afspraak',
              waarde: toonAfspraak,
              onChanged: onAfspraakChanged,
            ),
            filterRegel(
              tekst: 'Dagtaak',
              waarde: toonDagtaak,
              onChanged: onDagtaakChanged,
            ),
            filterRegel(
              tekst: 'Verlof',
              waarde: toonVerlof,
              onChanged: onVerlofChanged,
            ),
            filterRegel(
              tekst: 'Kraan',
              waarde: toonKraan,
              onChanged: onKraanChanged,
            ),
          ],
        ),
      ),
    );
  }
}
