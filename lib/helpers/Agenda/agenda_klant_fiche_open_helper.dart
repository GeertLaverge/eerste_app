import 'package:flutter/material.dart';

import '../../paginas/klanten_fiche_pagina.dart';
import '../klanten/fiche/klantenfiche_repository.dart';
import 'agenda_item.dart';

class AgendaKlantFicheOpenHelper {
  static Future<bool> openAlsKlantPlanning({
    required BuildContext context,
    required AgendaItem item,
  }) async {
    if (item.type != 'planning' && item.type != 'opvolging') {
      return false;
    }

    if (item.naamKlant.trim().isEmpty) return false;

    final fiches = await KlantenficheRepository.laadKlantenFiches();

    final naam = item.naamKlant.trim().toLowerCase();

    for (final fiche in fiches) {
      if (fiche.naam.trim().toLowerCase() == naam) {
        if (!context.mounted) return true;

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => KlantenFichePagina(
              bestaandeFiche: fiche,
            ),
          ),
        );

        return true;
      }
    }

    return false;
  }
}
