import 'package:flutter/material.dart';

import 'opmeting_raam_keuzemenu_model.dart';

class OpmetingRaamBeschikbareNietCombineerbareKeuze {
  const OpmetingRaamBeschikbareNietCombineerbareKeuze({
    required this.menuId,
    required this.optieId,
    required this.menuTitel,
    required this.optieNaam,
  });

  final String menuId;
  final String optieId;

  final String menuTitel;
  final String optieNaam;

  String get sleutel {
    return '$menuId::$optieId';
  }

  String get label {
    return '$menuTitel → $optieNaam';
  }

  OpmetingRaamNietCombineerbareKeuze naarKoppeling() {
    return OpmetingRaamNietCombineerbareKeuze(menuId: menuId, optieId: optieId);
  }
}

class OpmetingRaamNietCombineerbaarKeuzemenu extends StatelessWidget {
  const OpmetingRaamNietCombineerbaarKeuzemenu({
    super.key,
    required this.beschikbareKeuzes,
    required this.geselecteerdeKeuzes,
    required this.onGewijzigd,
  });

  final List<OpmetingRaamBeschikbareNietCombineerbareKeuze> beschikbareKeuzes;

  final List<OpmetingRaamNietCombineerbareKeuze> geselecteerdeKeuzes;

  final ValueChanged<List<OpmetingRaamNietCombineerbareKeuze>> onGewijzigd;

  @override
  Widget build(BuildContext context) {
    final geselecteerdeSleutels = geselecteerdeKeuzes
        .map((koppeling) => koppeling.sleutel)
        .toSet();

    final nogBeschikbareKeuzes = beschikbareKeuzes
        .where((keuze) => !geselecteerdeSleutels.contains(keuze.sleutel))
        .toList();

    nogBeschikbareKeuzes.sort(
      (eerste, tweede) =>
          eerste.label.toLowerCase().compareTo(tweede.label.toLowerCase()),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Niet combineerbaar met',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          key: ValueKey(geselecteerdeSleutels.join('|')),
          initialValue: null,
          isExpanded: true,
          decoration: const InputDecoration(
            hintText: 'Kies een andere keuze',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: nogBeschikbareKeuzes
              .map(
                (keuze) => DropdownMenuItem<String>(
                  value: keuze.sleutel,
                  child: Text(keuze.label, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: nogBeschikbareKeuzes.isEmpty
              ? null
              : (sleutel) {
                  if (sleutel == null) {
                    return;
                  }

                  final keuze = _zoekBeschikbareKeuze(sleutel);

                  if (keuze == null) {
                    return;
                  }

                  final nieuweKeuzes = <OpmetingRaamNietCombineerbareKeuze>[
                    ...geselecteerdeKeuzes,
                    keuze.naarKoppeling(),
                  ];

                  onGewijzigd(
                    List<OpmetingRaamNietCombineerbareKeuze>.unmodifiable(
                      nieuweKeuzes,
                    ),
                  );
                },
        ),
        if (geselecteerdeKeuzes.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: geselecteerdeKeuzes.map((koppeling) {
              final beschikbareKeuze = _zoekBeschikbareKeuze(koppeling.sleutel);

              return InputChip(
                label: Text(
                  beschikbareKeuze?.label ?? 'Keuze niet meer beschikbaar',
                ),
                tooltip: 'Verwijder deze uitsluiting',
                onDeleted: () {
                  final nieuweKeuzes = geselecteerdeKeuzes
                      .where(
                        (huidigeKoppeling) =>
                            huidigeKoppeling.sleutel != koppeling.sleutel,
                      )
                      .toList();

                  onGewijzigd(
                    List<OpmetingRaamNietCombineerbareKeuze>.unmodifiable(
                      nieuweKeuzes,
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 5),
        const Text(
          'Wanneer beide keuzes geselecteerd zijn, wordt alleen '
          'een waarschuwing getoond. Er wordt niets automatisch '
          'gewijzigd of verwijderd.',
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 11.5),
        ),
      ],
    );
  }

  OpmetingRaamBeschikbareNietCombineerbareKeuze? _zoekBeschikbareKeuze(
    String sleutel,
  ) {
    for (final keuze in beschikbareKeuzes) {
      if (keuze.sleutel == sleutel) {
        return keuze;
      }
    }

    return null;
  }
}
