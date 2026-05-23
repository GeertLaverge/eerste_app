import 'package:flutter/material.dart';

import '../../../modellen/klant.dart';
import '../../../services/home_service.dart';

class PlanningRij extends StatelessWidget {
  final DagPlanningItem item;
  final void Function(Klant klant) onTapKlant;

  const PlanningRij({
    super.key,
    required this.item,
    required this.onTapKlant,
  });

  static const Color donkerTekst = Color(0xFF111827);

  String tijdTekst(int uur, int minuut) {
    return '${uur.toString().padLeft(2, '0')}:${minuut.toString().padLeft(2, '0')}';
  }

  Color statusKleur(Klant klant) {
    if (klant.isProjectAfgewerkt) return Colors.grey;
    if (klant.isNadienst) return Colors.purple;
    if (klant.isOpTeVolgen) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final klant = item.klant;
    final kleur = statusKleur(klant);

    return InkWell(
      onTap: () => onTapKlant(klant),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 86,
              child: Text(
                '${tijdTekst(item.startUur, item.startMinuut)}\n'
                '${tijdTekst(item.eindUur, item.eindMinuut)}',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.15,
                  fontWeight: FontWeight.bold,
                  color: kleur,
                ),
              ),
            ),
            Expanded(
              child: Text(
                klant.klantnaam.isEmpty ? 'Klant zonder naam' : klant.klantnaam,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: donkerTekst,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
