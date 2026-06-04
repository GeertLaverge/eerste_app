import 'package:flutter/material.dart';

enum FotoEditorTool {
  tekenen,
  rechteLijn,
  tekst,
  pijl,
  cirkel,
  rechthoek,
}

class TekenLijn {
  final List<Offset> punten;
  final Color kleur;

  bool geselecteerd;

  TekenLijn({
    required this.punten,
    required this.kleur,
    this.geselecteerd = false,
  });
}

class KlantenficheFotoEditorController {
  FotoEditorTool actieveTool = FotoEditorTool.tekenen;

  Color actieveKleur = const Color(0xFF0B7A3B);

  void kiesKleur(Color kleur) {
    actieveKleur = kleur;
  }

  final List<TekenLijn> lijnen = [];

  TekenLijn? huidigeLijn;
  TekenLijn? geselecteerdeLijn;
  Offset? rechteLijnStart;

  void startNieuweLijn(
    Offset startPunt,
  ) {
    huidigeLijn = TekenLijn(
      punten: [startPunt],
      kleur: actieveKleur,
    );

    lijnen.add(huidigeLijn!);
  }

  void voegPuntToe(
    Offset punt,
  ) {
    huidigeLijn?.punten.add(punt);
  }

  void eindigLijn() {
    huidigeLijn = null;
  }

  void deselecteerAlles() {
    for (final lijn in lijnen) {
      lijn.geselecteerd = false;
    }

    geselecteerdeLijn = null;
  }

  void selecteerLijn(
    TekenLijn lijn,
  ) {
    deselecteerAlles();

    lijn.geselecteerd = true;

    geselecteerdeLijn = lijn;
  }

  void verwijderGeselecteerdeLijn() {
    if (geselecteerdeLijn == null) return;

    lijnen.remove(geselecteerdeLijn);

    geselecteerdeLijn = null;
  }

  void wisAlles() {
    lijnen.clear();
    huidigeLijn = null;
    geselecteerdeLijn = null;
  }

  double afstandTotLijnSegment(
    Offset punt,
    Offset lijnStart,
    Offset lijnEind,
  ) {
    final dx = lijnEind.dx - lijnStart.dx;
    final dy = lijnEind.dy - lijnStart.dy;

    if (dx == 0 && dy == 0) {
      return (punt - lijnStart).distance;
    }

    final t = ((punt.dx - lijnStart.dx) * dx + (punt.dy - lijnStart.dy) * dy) /
        (dx * dx + dy * dy);

    final begrensd = t.clamp(0.0, 1.0);

    final projectie = Offset(
      lijnStart.dx + begrensd * dx,
      lijnStart.dy + begrensd * dy,
    );

    return (punt - projectie).distance;
  }

  void selecteerLijnOpPunt(Offset punt) {
    deselecteerAlles();

    for (final lijn in lijnen.reversed) {
      for (int i = 0; i < lijn.punten.length - 1; i++) {
        final afstand = afstandTotLijnSegment(
          punt,
          lijn.punten[i],
          lijn.punten[i + 1],
        );

        if (afstand < 18) {
          selecteerLijn(lijn);
          return;
        }
      }
    }
  }
}
