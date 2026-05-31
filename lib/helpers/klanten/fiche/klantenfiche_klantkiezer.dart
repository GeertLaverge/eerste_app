import 'package:flutter/material.dart';

import '../klanten_agenda_service.dart';
import '../../Agenda/agenda_item.dart';

class KlantenficheKlantkiezer {
  static Future<AgendaItem?> toon(
    BuildContext context,
  ) async {
    final klanten = await KlantenAgendaService.laadAfspraakKlantenUitAgenda();

    if (!context.mounted) return null;

    return showDialog<AgendaItem>(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            width: 420,
            height: 500,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  child: const Row(
                    children: [
                      Text(
                        'Kies klant',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: klanten.length,
                    itemBuilder: (context, index) {
                      final klant = klanten[index];

                      return ListTile(
                        title: Text(
                          klant.naamKlant,
                        ),
                        subtitle: Text(
                          '${klant.gemeente} (${klant.postcode})',
                        ),
                        onTap: () {
                          Navigator.pop(
                            context,
                            klant,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
