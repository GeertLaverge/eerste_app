import 'package:flutter/material.dart';

import 'agenda_item.dart';
import 'agenda_dagtaak_popup.dart';
import 'agenda_verlof_popup.dart';
import 'agenda_toevoeg_popup.dart';

class AgendaItemOpenHelper {
  static const Color _thimacoGroen = Color(0xFF0B7A3B);

  static Future<Object?> open({
    required BuildContext context,
    required AgendaItem item,
    required List<AgendaItem> geplandeItems,
  }) async {
    if (item.isWebsiteShowroomAfspraak) {
      return showDialog<Object>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            icon: const Icon(
              Icons.home_outlined,
              color: _thimacoGroen,
            ),
            title: const Text(
              'Showroomadvies',
              style: TextStyle(
                color: _thimacoGroen,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.tijdTekst.isNotEmpty)
                    _InfoRegel(label: 'Uur', waarde: item.tijdTekst),
                  if (item.naamKlant.trim().isNotEmpty)
                    _InfoRegel(label: 'Klant', waarde: item.naamKlant.trim()),
                  if (item.gsm.trim().isNotEmpty)
                    _InfoRegel(label: 'Gsm', waarde: item.gsm.trim()),
                  if (item.email.trim().isNotEmpty)
                    _InfoRegel(label: 'E-mail', waarde: item.email.trim()),
                  if (item.gemeente.trim().isNotEmpty)
                    _InfoRegel(label: 'Gemeente', waarde: item.gemeente.trim()),
                  if (item.opmerkingen.trim().isNotEmpty)
                    _InfoRegel(
                      label: 'Opmerking',
                      waarde: item.opmerkingen.trim(),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    'Deze afspraak werd via de website geboekt. '
                    'De gegevens kunnen hier niet gewijzigd worden.',
                    style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                      color:
                          Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                onPressed: () async {
                  final bevestigd = await showDialog<bool>(
                    context: dialogContext,
                    builder: (bevestigContext) {
                      return AlertDialog(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        title: const Text('Afspraak verwijderen?'),
                        content: const Text(
                          'Deze showroomafspraak wordt verwijderd uit de '
                          'agenda. Het tijdstip komt opnieuw vrij op de '
                          'website.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(bevestigContext, false),
                            child: const Text('Annuleren'),
                          ),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () =>
                                Navigator.pop(bevestigContext, true),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Verwijderen'),
                          ),
                        ],
                      );
                    },
                  );

                  if (bevestigd == true && dialogContext.mounted) {
                    Navigator.pop(dialogContext, 'website_verwijderen');
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Verwijderen'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _thimacoGroen,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Sluiten'),
              ),
            ],
          );
        },
      );
    }

    return showDialog<Object>(
      context: context,
      builder: (context) {
        if (item.type == 'dagtaak') {
          return AgendaDagtaakPopup(bestaandItem: item);
        }

        if (item.type == 'verlof') {
          return AgendaVerlofPopup(bestaandItem: item);
        }

        return AgendaToevoegPopup(
          bestaandItem: item,
          geplandeItems: geplandeItems,
        );
      },
    );
  }
}

class _InfoRegel extends StatelessWidget {
  const _InfoRegel({required this.label, required this.waarde});

  final String label;
  final String waarde;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: Text(waarde)),
        ],
      ),
    );
  }
}
