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

class TekenVorm {
  Rect rect;
  List<Offset>? hoeken;

  Color kleur;
  FotoEditorTool type;

  bool geselecteerd;

  TekenVorm({
    required this.rect,
    this.hoeken,
    required this.kleur,
    required this.type,
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
  final List<TekenVorm> vormen = [];
  TekenLijn? huidigeLijn;
  TekenLijn? geselecteerdeLijn;

  TekenTekst? geselecteerdeTekst;

  TekenVorm? geselecteerdeVorm;

  int? geselecteerdHandleIndex;
  int? geselecteerdeVormHandleIndex;

  bool lijnWordtVerplaatst = false;

  bool tekstWordtVerplaatst = false;

  bool vormWordtVerplaatst = false;

  Offset? laatsteVerplaatsPositie;
  Offset? laatsteTekstVerplaatsPositie;

  Offset? rechteLijnStart;
  Offset? vormStart;

  Offset? laatsteVormVerplaatsPositie;

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
    for (final vorm in vormen) {
      vorm.geselecteerd = false;
    }

    geselecteerdeLijn = null;
    geselecteerdeTekst = null;
    geselecteerdeVorm = null;
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
    vormen.clear();
    geselecteerdeVorm = null;
    vormStart = null;

    huidigeLijn = null;
    geselecteerdeLijn = null;
    geselecteerdeTekst = null;
  }

  void voegVormToe({
    required Offset start,
    required Offset einde,
    required FotoEditorTool type,
  }) {
    deselecteerAlles();

    final rect = Rect.fromPoints(
      start,
      einde,
    );

    final vorm = TekenVorm(
      rect: rect,
      hoeken: type == FotoEditorTool.rechthoek
          ? [
              rect.topLeft,
              rect.topRight,
              rect.bottomRight,
              rect.bottomLeft,
            ]
          : null,
      kleur: actieveKleur,
      type: type,
      geselecteerd: true,
    );

    vormen.add(vorm);
    geselecteerdeVorm = vorm;
  }

  void selecteerVorm(
    TekenVorm vorm,
  ) {
    deselecteerAlles();

    vorm.geselecteerd = true;
    geselecteerdeVorm = vorm;
  }

  void selecteerVormOpPunt(
    Offset punt,
  ) {
    deselecteerAlles();

    for (final vorm in vormen.reversed) {
      final ruimereRect = vorm.rect.inflate(14);

      if (ruimereRect.contains(punt)) {
        selecteerVorm(vorm);
        return;
      }
    }
  }

  void verwijderGeselecteerdeVorm() {
    if (geselecteerdeVorm == null) return;

    vormen.remove(geselecteerdeVorm);
    geselecteerdeVorm = null;
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

  void startVormVerplaatsen(
    Offset positie,
  ) {
    vormWordtVerplaatst = true;
    laatsteVormVerplaatsPositie = positie;
  }

  void verplaatsGeselecteerdeVorm(
    Offset nieuwePositie,
  ) {
    if (!vormWordtVerplaatst) return;
    if (geselecteerdeVorm == null) return;
    if (laatsteVormVerplaatsPositie == null) return;

    final delta = nieuwePositie - laatsteVormVerplaatsPositie!;

    geselecteerdeVorm!.rect = geselecteerdeVorm!.rect.shift(delta);

    laatsteVormVerplaatsPositie = nieuwePositie;
  }

  void stopVormVerplaatsen() {
    vormWordtVerplaatst = false;
    laatsteVormVerplaatsPositie = null;
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

    const afstand = 40.0;

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

  bool selecteerVormHandleOpPunt(
    Offset punt,
  ) {
    if (geselecteerdeVorm == null) {
      return false;
    }

    const afstand = 40.0;

    final hoeken = [
      geselecteerdeVorm!.rect.topLeft,
      geselecteerdeVorm!.rect.topRight,
      geselecteerdeVorm!.rect.bottomRight,
      geselecteerdeVorm!.rect.bottomLeft,
    ];

    for (int i = 0; i < hoeken.length; i++) {
      if ((punt - hoeken[i]).distance < afstand) {
        geselecteerdeVormHandleIndex = i;
        return true;
      }
    }

    geselecteerdeVormHandleIndex = null;
    return false;
  }

  void verplaatsVormHandle(
    Offset nieuwePositie,
  ) {
    if (geselecteerdeVorm == null) return;
    if (geselecteerdeVormHandleIndex == null) return;
    if (geselecteerdeVorm!.type == FotoEditorTool.rechthoek &&
        geselecteerdeVorm!.hoeken != null) {
      geselecteerdeVorm!.hoeken![geselecteerdeVormHandleIndex!] = nieuwePositie;

      return;
    }

    final rect = geselecteerdeVorm!.rect;

    Offset topLeft = rect.topLeft;
    Offset topRight = rect.topRight;
    Offset bottomRight = rect.bottomRight;
    Offset bottomLeft = rect.bottomLeft;

    switch (geselecteerdeVormHandleIndex) {
      case 0:
        topLeft = nieuwePositie;
        break;
      case 1:
        topRight = nieuwePositie;
        break;
      case 2:
        bottomRight = nieuwePositie;
        break;
      case 3:
        bottomLeft = nieuwePositie;
        break;
    }

    Offset vasteHoek;

    switch (geselecteerdeVormHandleIndex) {
      case 0:
        vasteHoek = rect.bottomRight;
        break;
      case 1:
        vasteHoek = rect.bottomLeft;
        break;
      case 2:
        vasteHoek = rect.topLeft;
        break;
      case 3:
        vasteHoek = rect.topRight;
        break;
      default:
        return;
    }

    geselecteerdeVorm!.rect = Rect.fromPoints(
      vasteHoek,
      nieuwePositie,
    );
  }
}
