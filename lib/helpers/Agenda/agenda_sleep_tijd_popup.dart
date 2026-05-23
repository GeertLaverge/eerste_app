import 'package:flutter/material.dart';

import 'agenda_tijd_picker.dart';

class AgendaSleepTijdResultaat {
  final bool tijdenBehouden;

  final TimeOfDay? startTijd;
  final TimeOfDay? eindTijd;

  const AgendaSleepTijdResultaat({
    required this.tijdenBehouden,
    this.startTijd,
    this.eindTijd,
  });
}

class AgendaSleepTijdPopup {
  static Future<AgendaSleepTijdResultaat?> toon(
    BuildContext context, {
    required TimeOfDay huidigeStart,
    required TimeOfDay huidigeEind,
  }) async {
    final keuze = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              22,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(
              18,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Color(
                        0xFF0B7A3B,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Expanded(
                      child: Text(
                        'Tijden',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                        );
                      },
                      icon: const Icon(
                        Icons.close,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 18,
                ),
                const SizedBox(
                  height: 6,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        true,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF0B7A3B,
                      ),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Tijden behouden',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(
                        0xFF0B7A3B,
                      ),
                      side: const BorderSide(
                        color: Color(
                          0xFF0B7A3B,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Tijden aanpassen',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (keuze == null) {
      return null;
    }

    if (keuze) {
      return const AgendaSleepTijdResultaat(
        tijdenBehouden: true,
      );
    }

    final nieuweStart = await AgendaTijdPicker.kiesTijd(
      context: context,
      titel: 'Nieuwe starttijd',
      beginTijd: huidigeStart,
    );

    if (nieuweStart == null) {
      return null;
    }

    final nieuweEind = await AgendaTijdPicker.kiesTijd(
      context: context,
      titel: 'Nieuwe eindtijd',
      beginTijd: huidigeEind,
    );

    if (nieuweEind == null) {
      return null;
    }

    return AgendaSleepTijdResultaat(
      tijdenBehouden: false,
      startTijd: nieuweStart,
      eindTijd: nieuweEind,
    );
  }
}
