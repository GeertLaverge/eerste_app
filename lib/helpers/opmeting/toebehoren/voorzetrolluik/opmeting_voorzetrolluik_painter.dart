// THIMACO-CONTROLE: VOORZETROLLUIK-PAINTER-WIT9016-NIEUWE-LAMELLEN-20260731-1105
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'opmeting_voorzetrolluik_model.dart';

class OpmetingVoorzetrolluikPainter extends CustomPainter {
  const OpmetingVoorzetrolluikPainter({required this.model});

  final OpmetingVoorzetrolluikModel model;

  static const Color _lijn = Color(0xFF374151);
  static const Color _maat = Color(0xFF475569);
  static const Color _profiel = Color(0xFFF8FAFC);
  static const Color _profielSchaduw = Color(0xFFE5E7EB);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 20 || size.height <= 20) return;

    final titelHoogte = size.height < 360 ? 20.0 : 28.0;
    final binnen = Rect.fromLTWH(
      44,
      titelHoogte + 18,
      math.max(40.0, size.width - 88),
      math.max(40.0, size.height - titelHoogte - 50),
    );

    final voorBreedte = binnen.width * 0.68;
    final tussenruimte = math.max(18.0, binnen.width * 0.045);
    final zijBreedte = math.max(
      70.0,
      binnen.width - voorBreedte - tussenruimte,
    );

    final voorZone = Rect.fromLTWH(
      binnen.left,
      binnen.top,
      voorBreedte,
      binnen.height,
    );
    final zijZone = Rect.fromLTWH(
      voorZone.right + tussenruimte,
      binnen.top,
      zijBreedte,
      binnen.height,
    );

    _tekenTekst(
      canvas,
      'Vooraanzicht',
      Offset(voorZone.center.dx, 12),
      fontSize: 11,
      vet: true,
    );
    _tekenTekst(
      canvas,
      'Zijaanzicht',
      Offset(zijZone.center.dx, 12),
      fontSize: 11,
      vet: true,
    );

    final buitenBreedteMm = model.buitenBreedteMm.toDouble();
    final buitenHoogteMm = model.buitenHoogteMm.toDouble();
    final schaal = math.min(
      (voorZone.width - 44) / buitenBreedteMm,
      (voorZone.height - 48) / buitenHoogteMm,
    );
    final breedte = buitenBreedteMm * schaal;
    final hoogte = buitenHoogteMm * schaal;
    final links = voorZone.center.dx - breedte / 2;
    final boven = voorZone.center.dy - hoogte / 2 - 2;
    final voorRect = Rect.fromLTWH(links, boven, breedte, hoogte);

    _tekenVooraanzicht(canvas, voorRect, schaal);
    _tekenZijaanzicht(canvas, zijZone, voorRect, schaal);
  }

  void _tekenVooraanzicht(Canvas canvas, Rect rect, double schaal) {
    final kastHoogte = math.max(14.0, model.kastmaat.millimeter * schaal);
    final geleiderBreedte = math.max(
      6.0,
      math.min(14.0, OpmetingVoorzetrolluikModel.geleiderBreedteMm * schaal),
    );
    final onderlatHoogte = math.max(6.0, math.min(13.0, 22 * schaal));
    final vrijeOnderruimte =
        OpmetingVoorzetrolluikModel.vrijeOnderruimteMm * schaal;

    final profielVulling = Paint()
      ..color = _profiel
      ..style = PaintingStyle.fill;
    final profielRand = Paint()
      ..color = _lijn
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final kastRect = Rect.fromLTWH(rect.left, rect.top, rect.width, kastHoogte);
    canvas.drawRect(kastRect, Paint()..color = _profielSchaduw);
    canvas.drawRect(kastRect, profielRand);

    final onderlatBoven = math.max(
      kastRect.bottom + 18,
      rect.bottom - vrijeOnderruimte - onderlatHoogte,
    );
    final lamellenRect = Rect.fromLTRB(
      rect.left + geleiderBreedte,
      kastRect.bottom,
      rect.right - geleiderBreedte,
      onderlatBoven,
    );

    canvas.drawRect(lamellenRect, Paint()..color = _lamelKleur());
    _tekenLamellen(canvas, lamellenRect, schaal);
    canvas.drawRect(lamellenRect, profielRand);

    final onderlat = Rect.fromLTRB(
      lamellenRect.left,
      lamellenRect.bottom,
      lamellenRect.right,
      lamellenRect.bottom + onderlatHoogte,
    );
    final linksGeleider = Rect.fromLTRB(
      rect.left,
      kastRect.bottom,
      rect.left + geleiderBreedte,
      rect.bottom,
    );
    final rechtsGeleider = Rect.fromLTRB(
      rect.right - geleiderBreedte,
      kastRect.bottom,
      rect.right,
      rect.bottom,
    );

    final openVlak = Rect.fromLTRB(
      linksGeleider.right,
      onderlat.bottom,
      rechtsGeleider.left,
      rect.bottom,
    );
    canvas.drawRect(openVlak, Paint()..color = Colors.white);

    canvas.drawRect(linksGeleider, profielVulling);
    canvas.drawRect(linksGeleider, profielRand);
    canvas.drawRect(rechtsGeleider, profielVulling);
    canvas.drawRect(rechtsGeleider, profielRand);
    canvas.drawRect(onderlat, profielVulling);
    canvas.drawRect(onderlat, profielRand);

    final breedteMaatLinks = model.breedteInclusiefGeleiders
        ? rect.left
        : linksGeleider.right;
    final breedteMaatRechts = model.breedteInclusiefGeleiders
        ? rect.right
        : rechtsGeleider.left;

    _tekenHorizontaleMaat(
      canvas,
      begin: Offset(breedteMaatLinks, rect.bottom + 21),
      eind: Offset(breedteMaatRechts, rect.bottom + 21),
      bronBegin: Offset(breedteMaatLinks, rect.bottom),
      bronEind: Offset(breedteMaatRechts, rect.bottom),
      tekst: '${model.breedteMm} mm',
    );

    final hoogteMaatBoven = model.hoogteInclusiefKast
        ? rect.top
        : kastRect.bottom;
    _tekenVerticaleMaat(
      canvas,
      begin: Offset(rect.left - 23, hoogteMaatBoven),
      eind: Offset(rect.left - 23, rect.bottom),
      bronBegin: Offset(rect.left, hoogteMaatBoven),
      bronEind: Offset(rect.left, rect.bottom),
      tekst: '${model.hoogteMm} mm',
    );
  }

  void _tekenLamellen(Canvas canvas, Rect rect, double schaal) {
    final lijnPaint = Paint()
      ..color = _lijn.withValues(alpha: 0.65)
      ..strokeWidth = 0.8;
    final stap = math.max(2.4, model.lamelHoogteMm * schaal);
    final aantalRijen = math.max(1, (rect.height / stap).floor());
    final aantalOpen = (aantalRijen * model.openLamellenPercentage / 100)
        .round();
    final eersteOpenRij = aantalRijen - aantalOpen;
    final spleetPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.72)
      ..style = PaintingStyle.fill;

    for (var index = 1; index < aantalRijen; index++) {
      final y = rect.top + (index * stap);
      if (y >= rect.bottom) break;
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), lijnPaint);

      if (index >= eersteOpenRij && model.openLamellenPercentage > 0) {
        final spleetHoogte = math.max(0.8, math.min(2.6, stap * 0.18));
        canvas.drawRect(
          Rect.fromLTWH(
            rect.left + 1,
            y - (spleetHoogte / 2),
            math.max(0, rect.width - 2),
            spleetHoogte,
          ),
          spleetPaint,
        );
      }
    }
  }

  void _tekenZijaanzicht(
    Canvas canvas,
    Rect zone,
    Rect voorRect,
    double schaal,
  ) {
    final kastGrootte = model.kastmaat.millimeter * schaal;
    final geleiderBreedte = math.max(2.0, math.min(12.0, 24 * schaal));
    final totaleBreedte = kastGrootte + geleiderBreedte;
    final links = zone.center.dx - totaleBreedte / 2;
    final boven = voorRect.top + 2;
    final kastRect = Rect.fromLTWH(links, boven, kastGrootte, kastGrootte);

    final rand = Paint()
      ..color = _lijn
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    final vulling = Paint()
      ..color = _profiel
      ..style = PaintingStyle.fill;

    final kastPad = _kastProfielPad(kastRect);
    canvas.drawPath(kastPad, vulling);
    canvas.drawPath(kastPad, rand);

    final geleiderRect = Rect.fromLTRB(
      kastRect.left,
      kastRect.bottom,
      kastRect.left + geleiderBreedte,
      voorRect.bottom,
    );
    canvas.drawRect(geleiderRect, Paint()..color = _profielSchaduw);
    canvas.drawRect(geleiderRect, rand);

    _tekenHorizontaleMaat(
      canvas,
      begin: Offset(kastRect.left, kastRect.top - 14),
      eind: Offset(kastRect.right, kastRect.top - 14),
      bronBegin: Offset(kastRect.left, kastRect.top),
      bronEind: Offset(kastRect.right, kastRect.top),
      tekst: '${model.kastmaat.millimeter} mm',
    );

    _tekenVerticaleMaat(
      canvas,
      begin: Offset(kastRect.right + 15, kastRect.top),
      eind: Offset(kastRect.right + 15, kastRect.bottom),
      bronBegin: Offset(kastRect.right, kastRect.top),
      bronEind: Offset(kastRect.right, kastRect.bottom),
      tekst: '${model.kastmaat.millimeter} mm',
    );

    _tekenTekst(
      canvas,
      model.kastvorm.label,
      Offset(zone.center.dx, voorRect.bottom + 12),
      fontSize: 11,
      vet: true,
    );
  }

  Path _kastProfielPad(Rect rect) {
    return switch (model.kastvorm) {
      OpmetingVoorzetrolluikKastvorm.schuin => () {
        final afschuining = rect.width * 0.23;
        return Path()
          ..moveTo(rect.left, rect.top)
          ..lineTo(rect.right, rect.top)
          ..lineTo(rect.right, rect.bottom - afschuining)
          ..lineTo(rect.right - afschuining, rect.bottom)
          ..lineTo(rect.left, rect.bottom)
          ..close();
      }(),
      OpmetingVoorzetrolluikKastvorm.rond =>
        Path()
          ..moveTo(rect.left, rect.top)
          ..lineTo(rect.right, rect.top)
          ..lineTo(rect.right, rect.center.dy)
          ..quadraticBezierTo(
            rect.right,
            rect.bottom,
            rect.center.dx,
            rect.bottom,
          )
          ..lineTo(rect.left, rect.bottom)
          ..close(),
    };
  }

  void _tekenHorizontaleMaat(
    Canvas canvas, {
    required Offset begin,
    required Offset eind,
    required Offset bronBegin,
    required Offset bronEind,
    required String tekst,
  }) {
    final paint = Paint()
      ..color = _maat
      ..strokeWidth = 0.9;
    canvas.drawLine(begin, eind, paint);
    canvas.drawLine(bronBegin, begin, paint);
    canvas.drawLine(bronEind, eind, paint);
    _tekenPijlpunt(canvas, begin, eind, paint);
    _tekenPijlpunt(canvas, eind, begin, paint);
    _tekenTekst(canvas, tekst, Offset((begin.dx + eind.dx) / 2, begin.dy));
  }

  void _tekenVerticaleMaat(
    Canvas canvas, {
    required Offset begin,
    required Offset eind,
    required Offset bronBegin,
    required Offset bronEind,
    required String tekst,
  }) {
    final paint = Paint()
      ..color = _maat
      ..strokeWidth = 0.9;
    canvas.drawLine(begin, eind, paint);
    canvas.drawLine(bronBegin, begin, paint);
    canvas.drawLine(bronEind, eind, paint);
    _tekenPijlpunt(canvas, begin, eind, paint);
    _tekenPijlpunt(canvas, eind, begin, paint);

    canvas.save();
    final midden = Offset(begin.dx, (begin.dy + eind.dy) / 2);
    canvas.translate(midden.dx, midden.dy);
    canvas.rotate(-math.pi / 2);
    _tekenTekst(canvas, tekst, Offset.zero);
    canvas.restore();
  }

  void _tekenPijlpunt(Canvas canvas, Offset punt, Offset naar, Paint paint) {
    final richting = naar - punt;
    final lengte = richting.distance;
    if (lengte <= 0.001) return;
    final eenheid = richting / lengte;
    final normaal = Offset(-eenheid.dy, eenheid.dx);
    const pijl = 5.0;
    canvas.drawLine(punt, punt + eenheid * pijl + normaal * 2.4, paint);
    canvas.drawLine(punt, punt + eenheid * pijl - normaal * 2.4, paint);
  }

  void _tekenTekst(
    Canvas canvas,
    String tekst,
    Offset midden, {
    double fontSize = 10,
    bool vet = false,
  }) {
    final span = TextSpan(
      text: tekst,
      style: TextStyle(
        color: _maat,
        fontSize: fontSize,
        fontWeight: vet ? FontWeight.w700 : FontWeight.w500,
      ),
    );
    final painter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    final achtergrond = Rect.fromCenter(
      center: midden,
      width: painter.width + 6,
      height: painter.height + 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(achtergrond, const Radius.circular(3)),
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );
    painter.paint(
      canvas,
      Offset(midden.dx - painter.width / 2, midden.dy - painter.height / 2),
    );
  }

  Color _lamelKleur() {
    final cijfers = model.lamelKleurCode.replaceAll(RegExp(r'[^0-9]'), '');
    if (cijfers.contains('9016')) return Colors.white;
    return _kleurUitHex(model.lamelKleurHex);
  }

  Color _kleurUitHex(String waarde) {
    final tekst = waarde.trim().replaceFirst('#', '');
    final getal = int.tryParse(tekst, radix: 16);
    return getal == null ? const Color(0xFFD1D5DB) : Color(0xFF000000 | getal);
  }

  @override
  bool shouldRepaint(covariant OpmetingVoorzetrolluikPainter oldDelegate) {
    return oldDelegate.model != model;
  }
}
