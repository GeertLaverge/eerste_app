import 'package:flutter/material.dart';

class AgendaTijdHelper {
  static String tijdTekst({
    required int uur,
    required int minuut,
  }) {
    return '${uur.toString().padLeft(2, '0')}:'
        '${minuut.toString().padLeft(2, '0')}';
  }

  static String timeOfDayTekst(TimeOfDay tijd) {
    return tijdTekst(
      uur: tijd.hour,
      minuut: tijd.minute,
    );
  }
}
