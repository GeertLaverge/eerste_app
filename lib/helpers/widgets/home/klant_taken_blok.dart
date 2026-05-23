import 'package:flutter/material.dart';

import '../../../modellen/klant.dart';
import 'klant_taak_rij.dart';

class KlantTakenBlok extends StatelessWidget {
  final List<Klant> taken;
  final void Function(Klant klant) onTapKlant;
  final Color Function(Klant klant) achtergrondKleur;
  final Color Function(Klant klant) randKleur;

  const KlantTakenBlok({
    super.key,
    required this.taken,
    required this.onTapKlant,
    required this.achtergrondKleur,
    required this.randKleur,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.assignment_outlined, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Taken gepland aan klant',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (taken.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Geen klanttaken vandaag'),
            )
          else
            ...taken.map(
              (klant) => KlantTaakRij(
                klant: klant,
                onTap: () => onTapKlant(klant),
                achtergrondKleur: achtergrondKleur(klant),
                randKleur: randKleur(klant),
              ),
            ),
        ],
      ),
    );
  }
}
