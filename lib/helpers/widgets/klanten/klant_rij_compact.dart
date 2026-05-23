import 'package:flutter/material.dart';

import '../../../helpers/status_helper.dart';
import '../../../modellen/klant.dart';

class KlantRijCompact extends StatelessWidget {
  final Klant klant;
  final VoidCallback onTap;
  final VoidCallback onOpenAgenda;
  final VoidCallback onDelete;

  const KlantRijCompact({
    super.key,
    required this.klant,
    required this.onTap,
    required this.onOpenAgenda,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final artikelStatus = StatusHelper.bepaalStatus(klant);
    final artikelKleur = StatusHelper.bepaalStatusKleur(artikelStatus);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: artikelKleur.withValues(alpha: 0.12),
                child: Icon(
                  Icons.business,
                  color: artikelKleur,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        klant.klantnaam.isEmpty
                            ? 'Klant zonder naam'
                            : klant.klantnaam,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _artikelStatusChip(
                      artikelStatus,
                      artikelKleur,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Naar planning',
                onPressed: onOpenAgenda,
                icon: const Icon(Icons.calendar_month_outlined),
                color: Colors.green,
              ),
              if (klant.isProjectAfgewerkt)
                IconButton(
                  tooltip: 'Klant verwijderen',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _artikelStatusChip(String status, Color kleur) {
    final tekst = _korteStatusTekst(status);

    return Container(
      constraints: const BoxConstraints(maxWidth: 112),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: kleur.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        tekst,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: kleur,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _korteStatusTekst(String status) {
    switch (status) {
      case 'Nog niet alles besteld':
        return 'Niet compleet';
      case 'Alles besteld':
        return 'Besteld';
      case 'Alles geleverd':
        return 'Geleverd';
      case 'geen artikels nodig':
        return 'Geen nodig';
      default:
        return status;
    }
  }
}
