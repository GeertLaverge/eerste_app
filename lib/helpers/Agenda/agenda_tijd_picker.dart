import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AgendaTijdPicker {
  static Future<TimeOfDay?> kiesTijd({
    required BuildContext context,
    required String titel,
    required TimeOfDay beginTijd,
  }) async {
    int afgerondeMinuut = (beginTijd.minute / 5).round() * 5;

    if (afgerondeMinuut >= 60) {
      afgerondeMinuut = 55;
    }

    int gekozenUur = beginTijd.hour;
    int gekozenMinuut = afgerondeMinuut;

    final minuten = List.generate(
      12,
      (index) => index * 5,
    );

    final uurController = FixedExtentScrollController(
      initialItem: gekozenUur,
    );

    final minuutController = FixedExtentScrollController(
      initialItem: minuten.indexOf(
        gekozenMinuut,
      ),
    );

    return showDialog<TimeOfDay>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: SizedBox(
            width: 340,
            height: 350,
            child: Column(
              children: [
                const SizedBox(height: 14),
                Text(
                  titel,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          'uur',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'min',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 48,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 22,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7F6EC),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: const Color(0xFF0B7A3B),
                            width: 1.2,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: uurController,
                              itemExtent: 48,
                              magnification: 1.14,
                              squeeze: 0.95,
                              useMagnifier: true,
                              selectionOverlay: const SizedBox.shrink(),
                              onSelectedItemChanged: (waarde) {
                                gekozenUur = waarde;
                              },
                              children: List.generate(24, (index) {
                                return Center(
                                  child: Text(
                                    index.toString().padLeft(2, '0'),
                                    style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0B7A3B),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 165,
                            color: Colors.grey.shade200,
                          ),
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: minuutController,
                              itemExtent: 48,
                              magnification: 1.14,
                              squeeze: 0.95,
                              useMagnifier: true,
                              selectionOverlay: const SizedBox.shrink(),
                              onSelectedItemChanged: (index) {
                                gekozenMinuut = minuten[index];
                              },
                              children: minuten.map((minuut) {
                                return Center(
                                  child: Text(
                                    minuut.toString().padLeft(2, '0'),
                                    style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0B7A3B),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    14,
                    0,
                    14,
                    14,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Annuleren'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                              TimeOfDay(
                                hour: gekozenUur,
                                minute: gekozenMinuut,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B7A3B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 13,
                            ),
                          ),
                          child: const Text('Kiezen'),
                        ),
                      ),
                    ],
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
