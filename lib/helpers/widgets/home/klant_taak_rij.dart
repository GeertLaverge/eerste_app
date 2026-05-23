import 'package:flutter/material.dart';

import '../../../modellen/klant.dart';

class KlantTaakRij extends StatelessWidget {
  final Klant klant;
  final VoidCallback onTap;
  final Color achtergrondKleur;
  final Color randKleur;

  const KlantTaakRij({
    super.key,
    required this.klant,
    required this.onTap,
    required this.achtergrondKleur,
    required this.randKleur,
  });

  static const Color donkerTekst = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: achtergrondKleur,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: randKleur),
        ),
        child: Row(
          children: [
            const Icon(Icons.task_alt),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                klant.klantTaakTekst,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: donkerTekst,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
