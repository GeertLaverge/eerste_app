import 'package:flutter/material.dart';

enum FotoEditorTool {
  tekenen,
  tekst,
  pijl,
  cirkel,
  rechthoek,
}

class KlantenficheFotoEditorController {
  FotoEditorTool actieveTool = FotoEditorTool.tekenen;

  Color actieveKleur = const Color(0xFF0B7A3B);

  final List<Offset?> tekenPunten = [];

  void kiesKleur(Color kleur) {
    actieveKleur = kleur;
  }

  void wisAlles() {
    tekenPunten.clear();
  }
}
