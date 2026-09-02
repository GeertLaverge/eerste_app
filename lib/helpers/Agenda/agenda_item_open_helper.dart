import 'package:flutter/material.dart';

import 'agenda_item.dart';
import 'agenda_dagtaak_popup.dart';
import 'agenda_verlof_popup.dart';
import 'agenda_toevoeg_popup.dart';

class AgendaItemOpenHelper {
  static Future<Object?> open({
    required BuildContext context,
    required AgendaItem item,
    required List<AgendaItem> geplandeItems,
  }) async {
    if (item.isWebsiteShowroomAfspraak) {
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: const Icon(Icons.home_outlined),
            title: const Text('Showroomadvies'),
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
                    'Deze afspraak werd via de website geboekt en is hier alleen-lezen.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Sluiten'),
              ),
            ],
          );
        },
      );

      return null;
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
