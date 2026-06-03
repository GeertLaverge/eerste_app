import 'package:flutter/material.dart';

import 'agenda_item.dart';
import 'agenda_tijd_picker.dart';

class AgendaKlantPlanningTijdHelper {
  static Future<AgendaItem?> kiesTijd({
    required BuildContext context,
    required AgendaItem item,
  }) async {
    final keuze = await showDialog<String>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Planning klant',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, 'ganseDag');
                    },
                    child: const Text('Ganse dag 07:00 - 15:30'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context, 'tijdKiezen');
                    },
                    child: const Text('Tijd kiezen'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (keuze == null) return null;

    if (keuze == 'ganseDag') {
      return item.copyWithTijd(
        startUur: 7,
        startMinuut: 0,
        eindUur: 15,
        eindMinuut: 30,
      );
    }

    final start = await AgendaTijdPicker.kiesTijd(
      context: context,
      titel: 'Starttijd',
      beginTijd: const TimeOfDay(hour: 7, minute: 0),
    );

    if (start == null) return null;

    final einde = await AgendaTijdPicker.kiesTijd(
      context: context,
      titel: 'Eindtijd',
      beginTijd: const TimeOfDay(hour: 15, minute: 30),
    );

    if (einde == null) return null;

    return item.copyWithTijd(
      startUur: start.hour,
      startMinuut: start.minute,
      eindUur: einde.hour,
      eindMinuut: einde.minute,
    );
  }
}
