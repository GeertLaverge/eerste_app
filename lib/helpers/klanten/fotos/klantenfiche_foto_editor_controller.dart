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

  final List<Offset?> tekenPunten = [];

  void wisAlles() {
    tekenPunten.clear();
  }
}
