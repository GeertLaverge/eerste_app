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
  final FotoEditorTool type;

  bool geselecteerd;

  TekenLijn({
    required this.punten,
    required this.kleur,
    required this.type,
    this.geselecteerd = false,
  });
}

class TekenTekst {
  Offset positie;
  String tekst;
  Color kleur;

  bool geselecteerd;

  TekenTekst({
    required this.positie,
    required this.tekst,
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
  final List<TekenTekst> teksten = [];

  TekenLijn? huidigeLijn;
  TekenLijn? geselecteerdeLijn;

  TekenTekst? geselecteerdeTekst;

  int? geselecteerdHandleIndex;

  bool lijnWordtVerplaatst = false;

  bool tekstWordtVerplaatst = false;

  Offset? laatsteVerplaatsPositie;
  Offset? laatsteTekstVerplaatsPositie;

  Offset? rechteLijnStart;

  void startNieuweLijn(
    Offset startPunt,
  ) {
    huidigeLijn = TekenLijn(
      punten: [startPunt],
      kleur: actieveKleur,
      type: actieveTool,
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

    for (final tekst in teksten) {
      tekst.geselecteerd = false;
    }

    geselecteerdeLijn = null;
    geselecteerdeTekst = null;
  }

  void selecteerLijn(
    TekenLijn lijn,
  ) {
    deselecteerAlles();

    lijn.geselecteerd = true;

    geselecteerdeLijn = lijn;
  }

  void selecteerTekst(
    TekenTekst tekst,
  ) {
    deselecteerAlles();

    tekst.geselecteerd = true;

    geselecteerdeTekst = tekst;
  }

  void voegTekstToe({
    required Offset positie,
    required String tekst,
  }) {
    deselecteerAlles();

    final nieuweTekst = TekenTekst(
      positie: positie,
      tekst: tekst,
      kleur: actieveKleur,
      geselecteerd: true,
    );

    teksten.add(nieuweTekst);

    geselecteerdeTekst = nieuweTekst;
  }

  void verwijderGeselecteerdeTekst() {
    if (geselecteerdeTekst == null) return;

    teksten.remove(geselecteerdeTekst);

    geselecteerdeTekst = null;
  }

  void verwijderGeselecteerdeLijn() {
    if (geselecteerdeLijn == null) return;

    lijnen.remove(geselecteerdeLijn);

    geselecteerdeLijn = null;
  }

  void wisAlles() {
    lijnen.clear();
    teksten.clear();

    huidigeLijn = null;
    geselecteerdeLijn = null;
    geselecteerdeTekst = null;
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

  void selecteerTekstOpPunt(
    Offset punt,
  ) {
    deselecteerAlles();

    for (final tekst in teksten.reversed) {
      final rect = Rect.fromLTWH(
        tekst.positie.dx - 6,
        tekst.positie.dy - 6,
        tekst.tekst.length * 14.0 + 12,
        34,
      );

      if (rect.contains(punt)) {
        selecteerTekst(tekst);
        return;
      }
    }
  }

  void selecteerLijnOpPunt(
    Offset punt,
  ) {
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

  void startVerplaatsen(
    Offset positie,
  ) {
    lijnWordtVerplaatst = true;
    laatsteVerplaatsPositie = positie;
  }

  void verplaatsGeselecteerdeLijn(
    Offset nieuwePositie,
  ) {
    if (!lijnWordtVerplaatst) return;
    if (geselecteerdeLijn == null) return;
    if (laatsteVerplaatsPositie == null) return;

    final delta = nieuwePositie - laatsteVerplaatsPositie!;

    for (int i = 0; i < geselecteerdeLijn!.punten.length; i++) {
      geselecteerdeLijn!.punten[i] = geselecteerdeLijn!.punten[i] + delta;
    }

    laatsteVerplaatsPositie = nieuwePositie;
  }

  void stopVerplaatsen() {
    lijnWordtVerplaatst = false;
    laatsteVerplaatsPositie = null;
  }

  void startTekstVerplaatsen(
    Offset positie,
  ) {
    tekstWordtVerplaatst = true;

    laatsteTekstVerplaatsPositie = positie;
  }

  void verplaatsGeselecteerdeTekst(
    Offset nieuwePositie,
  ) {
    if (!tekstWordtVerplaatst) return;

    if (geselecteerdeTekst == null) return;

    if (laatsteTekstVerplaatsPositie == null) return;

    final delta = nieuwePositie - laatsteTekstVerplaatsPositie!;

    geselecteerdeTekst!.positie = geselecteerdeTekst!.positie + delta;

    laatsteTekstVerplaatsPositie = nieuwePositie;
  }

  void stopTekstVerplaatsen() {
    tekstWordtVerplaatst = false;

    laatsteTekstVerplaatsPositie = null;
  }

  bool selecteerHandleOpPunt(
    Offset punt,
  ) {
    if (geselecteerdeLijn == null) {
      return false;
    }

    if (geselecteerdeLijn!.punten.length != 2) {
      return false;
    }

    const afstand = 18.0;

    final start = geselecteerdeLijn!.punten.first;

    final einde = geselecteerdeLijn!.punten.last;

    if ((punt - start).distance < afstand) {
      geselecteerdHandleIndex = 0;
      return true;
    }

    if ((punt - einde).distance < afstand) {
      geselecteerdHandleIndex = 1;
      return true;
    }

    geselecteerdHandleIndex = null;
    return false;
  }

  void verplaatsHandle(
    Offset nieuwePositie,
  ) {
    if (geselecteerdeLijn == null) return;
    if (geselecteerdHandleIndex == null) return;

    geselecteerdeLijn!.punten[geselecteerdHandleIndex!] = nieuwePositie;
  }
}
