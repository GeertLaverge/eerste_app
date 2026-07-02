import 'package:flutter/material.dart';

import 'opmeting_raam_model.dart';

enum _VleugelSluiting { geen, knipslot, krukBoven, krukRechts, krukLinks }

class OpmetingRaamVleugelHelper {
  const OpmetingRaamVleugelHelper._();

  static const double vleugelProfielMm = 60;
  static const double makelaarBreedteMm = 50;

  static Rect maakVleugelVlak({
    required Rect vlak,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
  }) {
    // Het volledige geselecteerde vlak is de buitencontour
    // van de vleugel of vleugelcombinatie.
    return vlak;
  }

  static Rect maakGlasOpening({
    required Rect vleugel,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
  }) {
    if (breedteMm <= 0 || hoogteMm <= 0) {
      return vleugel;
    }

    final berekendeDikteX = (buitenKader.width / breedteMm) * vleugelProfielMm;

    final berekendeDikteY = (buitenKader.height / hoogteMm) * vleugelProfielMm;

    final maximaleDikteX = vleugel.width / 2;
    final maximaleDikteY = vleugel.height / 2;

    final profielDikteX = berekendeDikteX.clamp(0.0, maximaleDikteX).toDouble();

    final profielDikteY = berekendeDikteY.clamp(0.0, maximaleDikteY).toDouble();

    return Rect.fromLTRB(
      vleugel.left + profielDikteX,
      vleugel.top + profielDikteY,
      vleugel.right - profielDikteX,
      vleugel.bottom - profielDikteY,
    );
  }

  static void tekenVleugel({
    required Canvas canvas,
    required OpmetingRaamVleugel vleugel,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
  }) {
    switch (vleugel.type) {
      case OpmetingRaamVleugelType.geenVleugel:
        return;
      case OpmetingRaamVleugelType.enkelOpenRechts:
        _tekenEnkeleVleugel(
          canvas: canvas,
          vlak: vleugel.vlak,
          buitenKader: buitenKader,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
          draaiRechts: true,
          sluiting: _VleugelSluiting.krukRechts,
        );
        break;

      case OpmetingRaamVleugelType.enkelOpenLinks:
        _tekenEnkeleVleugel(
          canvas: canvas,
          vlak: vleugel.vlak,
          buitenKader: buitenKader,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
          draaiLinks: true,
          sluiting: _VleugelSluiting.krukLinks,
        );
        break;

      case OpmetingRaamVleugelType.draaiKipRechts:
        _tekenEnkeleVleugel(
          canvas: canvas,
          vlak: vleugel.vlak,
          buitenKader: buitenKader,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
          draaiRechts: true,
          kip: true,
          sluiting: _VleugelSluiting.krukRechts,
        );
        break;

      case OpmetingRaamVleugelType.draaiKipLinks:
        _tekenEnkeleVleugel(
          canvas: canvas,
          vlak: vleugel.vlak,
          buitenKader: buitenKader,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
          draaiLinks: true,
          kip: true,
          sluiting: _VleugelSluiting.krukLinks,
        );
        break;

      case OpmetingRaamVleugelType.kipraamMetKnipslot:
        _tekenEnkeleVleugel(
          canvas: canvas,
          vlak: vleugel.vlak,
          buitenKader: buitenKader,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
          kip: true,
          sluiting: _VleugelSluiting.knipslot,
        );
        break;

      case OpmetingRaamVleugelType.kipraamKrukBoven:
        _tekenEnkeleVleugel(
          canvas: canvas,
          vlak: vleugel.vlak,
          buitenKader: buitenKader,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
          kip: true,
          sluiting: _VleugelSluiting.krukBoven,
        );
        break;

      case OpmetingRaamVleugelType.kipraamKrukRechts:
        _tekenEnkeleVleugel(
          canvas: canvas,
          vlak: vleugel.vlak,
          buitenKader: buitenKader,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
          kip: true,
          sluiting: _VleugelSluiting.krukRechts,
        );
        break;

      case OpmetingRaamVleugelType.kipraamKrukLinks:
        _tekenEnkeleVleugel(
          canvas: canvas,
          vlak: vleugel.vlak,
          buitenKader: buitenKader,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
          kip: true,
          sluiting: _VleugelSluiting.krukLinks,
        );
        break;

      case OpmetingRaamVleugelType.dubbelOpenKrukRechts:
        _tekenDubbeleVleugel(
          canvas: canvas,
          vlak: vleugel.vlak,
          buitenKader: buitenKader,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
          krukRechts: true,
          actieveVleugelHeeftKip: false,
        );
        break;

      case OpmetingRaamVleugelType.dubbelOpenKrukLinks:
        _tekenDubbeleVleugel(
          canvas: canvas,
          vlak: vleugel.vlak,
          buitenKader: buitenKader,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
          krukRechts: false,
          actieveVleugelHeeftKip: false,
        );
        break;

      case OpmetingRaamVleugelType.dubbelDraaiKipKrukRechts:
        _tekenDubbeleVleugel(
          canvas: canvas,
          vlak: vleugel.vlak,
          buitenKader: buitenKader,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
          krukRechts: true,
          actieveVleugelHeeftKip: true,
        );
        break;

      case OpmetingRaamVleugelType.dubbelDraaiKipKrukLinks:
        _tekenDubbeleVleugel(
          canvas: canvas,
          vlak: vleugel.vlak,
          buitenKader: buitenKader,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
          krukRechts: false,
          actieveVleugelHeeftKip: true,
        );
        break;

      case OpmetingRaamVleugelType.vastDubbeleKader:
        _tekenEnkeleVleugel(
          canvas: canvas,
          vlak: vleugel.vlak,
          buitenKader: buitenKader,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
        );
        break;
    }
  }

  static void _tekenEnkeleVleugel({
    required Canvas canvas,
    required Rect vlak,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
    bool draaiLinks = false,
    bool draaiRechts = false,
    bool kip = false,
    _VleugelSluiting sluiting = _VleugelSluiting.geen,
  }) {
    final glasOpening = maakGlasOpening(
      vleugel: vlak,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    _tekenProfiel(canvas: canvas, buiten: vlak, binnen: glasOpening);

    final symboolVlak = _maakSymboolVlak(glasOpening);

    if (draaiLinks) {
      _tekenDraaiLinks(canvas, symboolVlak);
    }

    if (draaiRechts) {
      _tekenDraaiRechts(canvas, symboolVlak);
    }

    if (kip) {
      _tekenKip(canvas, symboolVlak);
    }

    _tekenSluiting(
      canvas: canvas,
      buiten: vlak,
      binnen: glasOpening,
      sluiting: sluiting,
    );
  }

  static void _tekenDubbeleVleugel({
    required Canvas canvas,
    required Rect vlak,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
    required bool krukRechts,
    required bool actieveVleugelHeeftKip,
  }) {
    final berekendeMakelaarBreedte =
        (buitenKader.width / breedteMm) * makelaarBreedteMm;

    final makelaarBreedte = berekendeMakelaarBreedte
        .clamp(0.0, vlak.width * 0.30)
        .toDouble();

    final halveMakelaar = makelaarBreedte / 2;
    final middenX = vlak.center.dx;

    final linkerVlak = Rect.fromLTRB(
      vlak.left,
      vlak.top,
      middenX - halveMakelaar,
      vlak.bottom,
    );

    final makelaarVlak = Rect.fromLTRB(
      middenX - halveMakelaar,
      vlak.top,
      middenX + halveMakelaar,
      vlak.bottom,
    );

    final rechterVlak = Rect.fromLTRB(
      middenX + halveMakelaar,
      vlak.top,
      vlak.right,
      vlak.bottom,
    );

    final linkerGlas = maakGlasOpening(
      vleugel: linkerVlak,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    final rechterGlas = maakGlasOpening(
      vleugel: rechterVlak,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    _tekenProfiel(canvas: canvas, buiten: linkerVlak, binnen: linkerGlas);

    _tekenProfiel(canvas: canvas, buiten: rechterVlak, binnen: rechterGlas);

    _tekenMakelaar(canvas: canvas, makelaar: makelaarVlak);

    // Scharnieren staan aan de buitenzijden.
    // De draairichtingen wijzen naar de makelaar.
    _tekenDraaiRechts(canvas, _maakSymboolVlak(linkerGlas));

    _tekenDraaiLinks(canvas, _maakSymboolVlak(rechterGlas));

    if (actieveVleugelHeeftKip) {
      if (krukRechts) {
        _tekenKip(canvas, _maakSymboolVlak(rechterGlas));
      } else {
        _tekenKip(canvas, _maakSymboolVlak(linkerGlas));
      }
    }

    if (krukRechts) {
      _tekenSluiting(
        canvas: canvas,
        buiten: rechterVlak,
        binnen: rechterGlas,
        sluiting: _VleugelSluiting.krukLinks,
      );
    } else {
      _tekenSluiting(
        canvas: canvas,
        buiten: linkerVlak,
        binnen: linkerGlas,
        sluiting: _VleugelSluiting.krukRechts,
      );
    }
  }

  static void _tekenProfiel({
    required Canvas canvas,
    required Rect buiten,
    required Rect binnen,
  }) {
    final profielVulling = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.fill;

    final profielLijn = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    final verstekLijn = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final profielPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(buiten)
      ..addRect(binnen);

    canvas.drawPath(profielPath, profielVulling);

    canvas.drawRect(buiten, profielLijn);

    canvas.drawRect(binnen, profielLijn);

    canvas.drawLine(buiten.topLeft, binnen.topLeft, verstekLijn);

    canvas.drawLine(buiten.topRight, binnen.topRight, verstekLijn);

    canvas.drawLine(buiten.bottomRight, binnen.bottomRight, verstekLijn);

    canvas.drawLine(buiten.bottomLeft, binnen.bottomLeft, verstekLijn);
  }

  static Rect _maakSymboolVlak(Rect glasOpening) {
    return glasOpening;
  }

  static Paint _symboolLijn() {
    return Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
  }

  static void _tekenDraaiRechts(Canvas canvas, Rect vlak) {
    final lijn = _symboolLijn();
    final puntRechts = Offset(vlak.right, vlak.center.dy);

    canvas.drawLine(vlak.topLeft, puntRechts, lijn);

    canvas.drawLine(vlak.bottomLeft, puntRechts, lijn);
  }

  static void _tekenDraaiLinks(Canvas canvas, Rect vlak) {
    final lijn = _symboolLijn();
    final puntLinks = Offset(vlak.left, vlak.center.dy);

    canvas.drawLine(vlak.topRight, puntLinks, lijn);

    canvas.drawLine(vlak.bottomRight, puntLinks, lijn);
  }

  static void _tekenKip(Canvas canvas, Rect vlak) {
    final lijn = _symboolLijn();
    final puntBoven = Offset(vlak.center.dx, vlak.top);

    canvas.drawLine(vlak.bottomLeft, puntBoven, lijn);

    canvas.drawLine(vlak.bottomRight, puntBoven, lijn);
  }

  static void _tekenMakelaar({required Canvas canvas, required Rect makelaar}) {
    final vulling = Paint()
      ..color = Colors.white.withOpacity(0.98)
      ..style = PaintingStyle.fill;

    final lijn = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    canvas.drawRect(makelaar, vulling);

    canvas.drawRect(makelaar, lijn);
  }

  static void _tekenSluiting({
    required Canvas canvas,
    required Rect buiten,
    required Rect binnen,
    required _VleugelSluiting sluiting,
  }) {
    if (sluiting == _VleugelSluiting.geen) {
      return;
    }

    final lijn = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    switch (sluiting) {
      case _VleugelSluiting.geen:
        return;

      case _VleugelSluiting.knipslot:
        final middenX = buiten.center.dx;
        final middenY = (buiten.top + binnen.top) / 2;

        final slot = Rect.fromCenter(
          center: Offset(middenX, middenY),
          width: 12,
          height: 6,
        );

        canvas.drawRRect(
          RRect.fromRectAndRadius(slot, const Radius.circular(2)),
          Paint()
            ..color = const Color(0xFF111827)
            ..style = PaintingStyle.fill,
        );
        break;

      case _VleugelSluiting.krukBoven:
        final punt = Offset(buiten.center.dx, (buiten.top + binnen.top) / 2);

        canvas.drawLine(
          Offset(punt.dx - 7, punt.dy),
          Offset(punt.dx + 7, punt.dy),
          lijn,
        );
        break;

      case _VleugelSluiting.krukRechts:
        final punt = Offset(
          (buiten.right + binnen.right) / 2,
          buiten.center.dy,
        );

        canvas.drawLine(
          Offset(punt.dx, punt.dy - 7),
          Offset(punt.dx, punt.dy + 7),
          lijn,
        );
        break;

      case _VleugelSluiting.krukLinks:
        final punt = Offset((buiten.left + binnen.left) / 2, buiten.center.dy);

        canvas.drawLine(
          Offset(punt.dx, punt.dy - 7),
          Offset(punt.dx, punt.dy + 7),
          lijn,
        );
        break;
    }
  }
}
