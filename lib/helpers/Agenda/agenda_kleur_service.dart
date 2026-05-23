import 'package:flutter/material.dart';

class AgendaKleurService {
  static Color kleur(String type) {
    switch (type) {
      case 'planning':
        return const Color(0xFF15803D); // groen

      case 'opvolging':
        return const Color(0xFFEAB308); // geel

      case 'nadienst':
        return Colors.purple;

      case 'afspraak':
        return Colors.blue;

      case 'dagtaak':
        return const Color(0xFFF06418); // oranje

      case 'verlof':
        return Colors.red;

      case 'kraan':
        return Colors.brown;

      default:
        return Colors.grey;
    }
  }

  static Color achtergrond(String type) {
    return kleur(type).withOpacity(0.14);
  }
}
