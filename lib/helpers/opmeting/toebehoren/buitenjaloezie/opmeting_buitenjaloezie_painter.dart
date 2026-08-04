// THIMACO-CONTROLE: BUITENJALOEZIE-MAATLIJNEN-A-B-D-VERFIJND-20260804
// THIMACO-CONTROLE: BUITENJALOEZIE-ZIJAANZICHT-RECHTS-VAN-VOORAANZICHT-20260803

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'opmeting_buitenjaloezie_model.dart';

class OpmetingBuitenjaloeziePainter extends CustomPainter {
  const OpmetingBuitenjaloeziePainter({required this.model});

  final OpmetingBuitenjaloezieModel model;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 1 || size.height <= 1) return;

    const margeLinks = 54.0;
    const margeRechts = 54.0;
    const margeBoven = 48.0;
    const margeOnder = 58.0;
    const tussenruimte = 34.0;

    final beschikbareBreedte = math.max(
      1.0,
      size.width - margeLinks - margeRechts,
    );
    final beschikbareHoogte = math.max(
      1.0,
      size.height - margeBoven - margeOnder,
    );

    final vooraanzichtBreedte = math.max(120.0, beschikbareBreedte * 0.68);
    final zijaanzichtBreedte = math.max(
      90.0,
      beschikbareBreedte - vooraanzichtBreedte - tussenruimte,
    );

    final frontRect = Rect.fromLTWH(
      margeLinks,
      margeBoven,
      vooraanzichtBreedte,
      beschikbareHoogte,
    );

    final sideRect = Rect.fromLTWH(
      frontRect.right + tussenruimte,
      margeBoven,
      zijaanzichtBreedte,
      beschikbareHoogte,
    );

    final totaalBreedteMm = math.max(1, model.totaleBreedteMm);
    final totaalHoogteMm = math.max(1, model.totaleHoogteMm);
    final frontSchaal = math.min(
      frontRect.width / totaalBreedteMm,
      frontRect.height / totaalHoogteMm,
    );

    _tekenVooraanzicht(canvas, frontRect, frontSchaal);
    _tekenZijaanzicht(canvas, sideRect, frontSchaal);

    if (!model.systeem.isModulo && model.lamellenpakketUitsteekMm > 0) {
      final frontBreedte = totaalBreedteMm * frontSchaal;
      final frontHoogte = totaalHoogteMm * frontSchaal;
      final frontLinks = frontRect.left + (frontRect.width - frontBreedte) / 2;
      final frontBoven = frontRect.top + (frontRect.height - frontHoogte) / 2;
      final kastHoogte = model.kastHoogteMm * frontSchaal;
      final geleiderBreedte = math.max(
        3.0,
        model.geleiderBreedteMm * frontSchaal,
      );
      final lamelLinks = frontLinks + geleiderBreedte;
      final frontRechts = frontLinks + frontBreedte - geleiderBreedte;
      final uitsteekY =
          frontBoven +
          kastHoogte +
          model.lamellenpakketUitsteekMm * frontSchaal;

      final sideBreedte = _zijaanzichtBreedteMm * frontSchaal;
      final sideLinks = sideRect.left + (sideRect.width - sideBreedte) / 2;
      final sideRechts = sideLinks + sideBreedte;

      _tekenUitsteekAslijnTussenAanzichten(
        canvas,
        frontLinks: lamelLinks,
        frontRechts: frontRechts,
        sideLinks: sideLinks,
        sideRechts: sideRechts,
        y: uitsteekY,
        tekst: '${model.lamellenpakketUitsteekMm} mm\nuitsteek',
      );
    }
  }

  void _tekenVooraanzicht(Canvas canvas, Rect zone, double schaal) {
    final totaalBreedteMm = math.max(1, model.totaleBreedteMm);
    final totaalHoogteMm = math.max(1, model.totaleHoogteMm);

    final breedte = totaalBreedteMm * schaal;
    final hoogte = totaalHoogteMm * schaal;
    final links = zone.left + (zone.width - breedte) / 2;
    final boven = zone.top + (zone.height - hoogte) / 2;

    final kastHoogte = model.kastHoogteMm * schaal;
    final geleiderBreedte = math.max(3.0, model.geleiderBreedteMm * schaal);
    final geleiderBoven = boven + kastHoogte;
    final geleiderHoogte = math.max(0.0, hoogte - kastHoogte);

    final kaderPaint = Paint()
      ..color = const Color(0xFF202428)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final kastPaint = Paint()
      ..color = const Color(0xFFF8FAFC)
      ..style = PaintingStyle.fill;

    final geleiderPaint = Paint()
      ..color = const Color(0xFFF3F4F6)
      ..style = PaintingStyle.fill;

    final lamelPaint = Paint()
      ..color = _kleurUitHex(model.lamelkleurHex)
      ..style = PaintingStyle.fill;

    final lamelRandPaint = Paint()
      ..color = const Color(0xFF23272B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    final kastRect = Rect.fromLTWH(links, boven, breedte, kastHoogte);
    canvas.drawRect(kastRect, kastPaint);
    canvas.drawRect(kastRect, kaderPaint);

    final linksGeleider = Rect.fromLTWH(
      links,
      geleiderBoven,
      geleiderBreedte,
      geleiderHoogte,
    );
    final rechtsGeleider = Rect.fromLTWH(
      links + breedte - geleiderBreedte,
      geleiderBoven,
      geleiderBreedte,
      geleiderHoogte,
    );

    canvas.drawRect(linksGeleider, geleiderPaint);
    canvas.drawRect(rechtsGeleider, geleiderPaint);
    canvas.drawRect(linksGeleider, kaderPaint);
    canvas.drawRect(rechtsGeleider, kaderPaint);

    final lamelLinks = links + geleiderBreedte;
    final lamelRechts = links + breedte - geleiderBreedte;
    final lamelBreedte = math.max(1.0, lamelRechts - lamelLinks);

    final lamelHoogte = math.max(
      1.2,
      OpmetingBuitenjaloezieModel.lamelTekeningHoogteMm * schaal,
    );
    final steek = math.max(
      2.0,
      OpmetingBuitenjaloezieModel.lamelSteekMm * schaal,
    );

    var y = geleiderBoven + math.max(3.0, steek * 0.15);
    final ondergrens = boven + hoogte - math.max(2.0, lamelHoogte);

    while (y <= ondergrens) {
      final rect = Rect.fromLTWH(lamelLinks, y, lamelBreedte, lamelHoogte);
      canvas.drawRect(rect, lamelPaint);
      canvas.drawRect(rect, lamelRandPaint);
      y += steek;
    }

    _tekenLadderkoorden(
      canvas,
      lamelLinks: lamelLinks,
      lamelRechts: lamelRechts,
      boven: geleiderBoven,
      onder: boven + hoogte,
    );

    _tekenMaatlijnHorizontaal(
      canvas,
      start: Offset(links, boven - 20),
      einde: Offset(links + breedte, boven - 20),
      tekst: '${model.totaleBreedteMm} mm',
    );

    _tekenMaatlijnVerticaal(
      canvas,
      start: Offset(links - 26, boven),
      einde: Offset(links - 26, boven + hoogte),
      tekst: '${model.totaleHoogteMm} mm',
    );

    _tekenMaatlijnVerticaal(
      canvas,
      start: Offset(links + breedte + 24, boven),
      einde: Offset(links + breedte + 24, boven + kastHoogte),
      tekst: '${model.kastHoogteMm} mm',
      rechts: true,
    );

    _tekenLabel(
      canvas,
      tekst: '${model.systeem.label} · ${model.lameltype.label}',
      positie: Offset(links + breedte / 2, boven + 2),
      gecentreerd: true,
      vet: true,
    );

    _tekenLabel(
      canvas,
      tekst: model.lamelkleurSamenvatting,
      positie: Offset(links + breedte / 2, boven + kastHoogte - 18),
      gecentreerd: true,
    );

    _tekenLabel(
      canvas,
      tekst: 'Vooraanzicht',
      positie: Offset(links + breedte / 2, zone.bottom + 10),
      gecentreerd: true,
      vet: true,
    );
  }

  void _tekenZijaanzicht(Canvas canvas, Rect zone, double schaal) {
    final totaalHoogteMm = math.max(1, model.totaleHoogteMm);
    final zijaanzichtBreedteMm = _zijaanzichtBreedteMm;

    final hoogte = totaalHoogteMm * schaal;
    final breedte = zijaanzichtBreedteMm * schaal;
    final links = zone.left + (zone.width - breedte) / 2;
    final boven = zone.top + (zone.height - hoogte) / 2;
    final onder = boven + hoogte;

    final kastHoogte = model.kastHoogteMm * schaal;
    final geleiderDiepte = _geleiderDiepteMm * schaal;

    final kaderPaint = Paint()
      ..color = const Color(0xFF202428)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final kastPaint = Paint()
      ..color = const Color(0xFFF8FAFC)
      ..style = PaintingStyle.fill;

    final geleiderPaint = Paint()
      ..color = const Color(0xFFF3F4F6)
      ..style = PaintingStyle.fill;

    if (model.systeem.isModulo) {
      final kastBreedte = _kastMaatBreedteMm * schaal;
      final geleiderHoogte = math.max(0.0, hoogte - kastHoogte);
      final achterX = links;
      final kastVoorX = links + kastBreedte;
      final kastOnderY = boven + kastHoogte;

      final kastRect = Rect.fromLTWH(achterX, boven, kastBreedte, kastHoogte);
      canvas.drawRect(kastRect, kastPaint);
      canvas.drawRect(kastRect, kaderPaint);

      final geleiderRect = Rect.fromLTWH(
        achterX,
        kastOnderY,
        geleiderDiepte,
        geleiderHoogte,
      );
      canvas.drawRect(geleiderRect, geleiderPaint);
      canvas.drawRect(geleiderRect, kaderPaint);

      final achterwandPaint = Paint()
        ..color = const Color(0xFF374151)
        ..strokeWidth = 1.2;
      canvas.drawLine(
        Offset(achterX, boven),
        Offset(achterX, onder),
        achterwandPaint,
      );

      if (model.klinkeruitvoering && geleiderRect.right < kastVoorX) {
        final klinkerRect = Rect.fromLTRB(
          geleiderRect.right,
          kastOnderY,
          kastVoorX,
          onder,
        );
        final klinkerPaint = Paint()
          ..color = const Color(0xFF6B7280)
          ..style = PaintingStyle.fill;
        canvas.drawRect(klinkerRect, klinkerPaint);
        canvas.drawRect(klinkerRect, kaderPaint);
      }

      _tekenMaatlijnHorizontaal(
        canvas,
        start: Offset(achterX, boven - 20),
        einde: Offset(kastVoorX, boven - 20),
        tekst: '$_kastMaatBreedteMm mm',
      );

      _tekenLabel(
        canvas,
        tekst: 'geleider ${model.geleiderOmschrijving}',
        positie: Offset(achterX + breedte / 2, onder + 10),
        gecentreerd: true,
      );
      return;
    }

    final vormData = _vormData;
    final kastBreedte = vormData.totaleBreedteMm * schaal;
    final topBreedte = vormData.topBreedteMm * schaal;
    final geleiderHoogte = math.max(0.0, hoogte - kastHoogte);
    final kastLinks = links;
    final kastRechts = kastLinks + kastBreedte;
    final kastOnderY = boven + kastHoogte;

    final kastPad = model.systeem.isRondo
        ? _bouwRondoPad(
            left: kastLinks,
            top: boven,
            right: kastRechts,
            bottom: kastOnderY,
            topBreedte: topBreedte,
          )
        : _bouwPentoPad(
            left: kastLinks,
            top: boven,
            right: kastRechts,
            bottom: kastOnderY,
            topBreedte: topBreedte,
          );

    canvas.save();
    canvas.translate(kastLinks + kastRechts, 0);
    canvas.scale(-1, 1);

    canvas.drawPath(kastPad, kastPaint);
    canvas.drawPath(kastPad, kaderPaint);

    final geleiderRect = Rect.fromLTWH(
      kastRechts - geleiderDiepte,
      kastOnderY,
      geleiderDiepte,
      geleiderHoogte,
    );
    canvas.drawRect(geleiderRect, geleiderPaint);
    canvas.drawRect(geleiderRect, kaderPaint);

    final achterwandPaint = Paint()
      ..color = const Color(0xFF374151)
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(kastRechts, boven),
      Offset(kastRechts, onder),
      achterwandPaint,
    );

    if (model.klinkeruitvoering) {
      final coverBreedte = model.systeem.isRondo
          ? math.max(geleiderDiepte, vormData.topBreedteMm * schaal)
          : kastBreedte;
      final coverRect = Rect.fromLTWH(
        kastRechts - coverBreedte,
        kastOnderY,
        coverBreedte,
        geleiderHoogte,
      );
      final klinkerPaint = Paint()
        ..color = const Color(0xFF6B7280)
        ..style = PaintingStyle.fill;
      canvas.drawRect(coverRect, klinkerPaint);
      canvas.drawRect(coverRect, kaderPaint);
    }

    canvas.restore();

    _tekenKastMaatHorizontaal(
      canvas,
      links: kastLinks,
      rechts: kastRechts,
      objectBoven: boven,
      maatY: boven - 24,
      tekst:
          '${vormData.horizontaleMaatLabel} ${vormData.horizontaleMaatMm} mm',
    );

    _tekenKastMaatVerticaal(
      canvas,
      boven: boven,
      onder: kastOnderY,
      objectRechts: kastRechts,
      maatX: kastRechts + 25,
      tekst: 'A ${vormData.aMaatMm} mm',
    );

    _tekenLabel(
      canvas,
      tekst: 'geleider ${model.geleiderOmschrijving}',
      positie: Offset(kastLinks + breedte / 2, onder + 10),
      gecentreerd: true,
    );
  }

  Path _bouwRondoPad({
    required double left,
    required double top,
    required double right,
    required double bottom,
    required double topBreedte,
  }) {
    final height = bottom - top;
    final topStartX = right - topBreedte;
    final arcRect = Rect.fromLTWH(left, top, height, height);
    return Path()
      ..moveTo(right, top)
      ..lineTo(topStartX, top)
      ..arcTo(arcRect, -math.pi / 2, -math.pi, false)
      ..lineTo(right, bottom)
      ..close();
  }

  Path _bouwPentoPad({
    required double left,
    required double top,
    required double right,
    required double bottom,
    required double topBreedte,
  }) {
    final height = bottom - top;
    final topStartX = right - topBreedte;
    final schuinX = left + topBreedte * 0.18;
    final schuinY = top + height * 0.70;
    final linkerOpstandY = top + height * 0.18;
    return Path()
      ..moveTo(right, top)
      ..lineTo(topStartX, top)
      ..lineTo(left, linkerOpstandY)
      ..lineTo(schuinX, schuinY)
      ..lineTo(schuinX, bottom)
      ..lineTo(right, bottom)
      ..close();
  }

  _ZijaanzichtVormData get _vormData {
    final nominaleKast = model.kastHoogteMm <= 165 ? 165 : 185;
    return switch (model.systeem) {
      OpmetingBuitenjaloezieSysteem.moduloP => const _ZijaanzichtVormData(
        totaleBreedteMm: 120,
        topBreedteMm: 120,
        aMaatMm: 120,
        horizontaleMaatLabel: '',
        horizontaleMaatMm: 120,
      ),
      OpmetingBuitenjaloezieSysteem.moduloXp => const _ZijaanzichtVormData(
        totaleBreedteMm: 140,
        topBreedteMm: 140,
        aMaatMm: 140,
        horizontaleMaatLabel: '',
        horizontaleMaatMm: 140,
      ),
      OpmetingBuitenjaloezieSysteem.rondoP =>
        nominaleKast == 165
            ? const _ZijaanzichtVormData(
                totaleBreedteMm: 178,
                topBreedteMm: 94,
                aMaatMm: 169,
                horizontaleMaatLabel: 'D',
                horizontaleMaatMm: 178,
              )
            : const _ZijaanzichtVormData(
                totaleBreedteMm: 194,
                topBreedteMm: 103,
                aMaatMm: 185,
                horizontaleMaatLabel: 'D',
                horizontaleMaatMm: 194,
              ),
      OpmetingBuitenjaloezieSysteem.rondoXp =>
        nominaleKast == 165
            ? const _ZijaanzichtVormData(
                totaleBreedteMm: 198,
                topBreedteMm: 114,
                aMaatMm: 169,
                horizontaleMaatLabel: 'D',
                horizontaleMaatMm: 198,
              )
            : const _ZijaanzichtVormData(
                totaleBreedteMm: 214,
                topBreedteMm: 122,
                aMaatMm: 185,
                horizontaleMaatLabel: 'D',
                horizontaleMaatMm: 214,
              ),
      OpmetingBuitenjaloezieSysteem.pentoP =>
        nominaleKast == 165
            ? const _ZijaanzichtVormData(
                totaleBreedteMm: 169,
                topBreedteMm: 169,
                aMaatMm: 169,
                horizontaleMaatLabel: 'B',
                horizontaleMaatMm: 169,
              )
            : const _ZijaanzichtVormData(
                totaleBreedteMm: 185,
                topBreedteMm: 185,
                aMaatMm: 185,
                horizontaleMaatLabel: 'B',
                horizontaleMaatMm: 185,
              ),
      OpmetingBuitenjaloezieSysteem.pentoXp =>
        nominaleKast == 165
            ? const _ZijaanzichtVormData(
                totaleBreedteMm: 189,
                topBreedteMm: 189,
                aMaatMm: 169,
                horizontaleMaatLabel: 'B',
                horizontaleMaatMm: 189,
              )
            : const _ZijaanzichtVormData(
                totaleBreedteMm: 205,
                topBreedteMm: 205,
                aMaatMm: 185,
                horizontaleMaatLabel: 'B',
                horizontaleMaatMm: 205,
              ),
    };
  }

  int get _kastMaatBreedteMm => _vormData.topBreedteMm;

  int get _zijaanzichtBreedteMm =>
      math.max(_vormData.totaleBreedteMm, _geleiderDiepteMm);

  int get _geleiderDiepteMm {
    final match = RegExp(
      r'(\d+)\s*[x×]\s*(\d+)',
    ).firstMatch(model.geleiderOmschrijving);
    if (match != null) {
      return int.tryParse(match.group(2) ?? '') ?? 69;
    }
    return 69;
  }

  void _tekenUitsteekAslijnTussenAanzichten(
    Canvas canvas, {
    required double frontLinks,
    required double frontRechts,
    required double sideLinks,
    required double sideRechts,
    required double y,
    required String tekst,
  }) {
    const blauw = Color(0xFF2563EB);
    final paint = Paint()
      ..color = blauw
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final tekstPainter = TextPainter(
      text: TextSpan(
        text: tekst,
        style: const TextStyle(
          color: blauw,
          fontSize: 10.0,
          fontWeight: FontWeight.w700,
          height: 1.15,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 2,
    )..layout(maxWidth: math.max(36.0, sideLinks - frontRechts - 12));

    final middenLinks = frontRechts + 6;
    final middenRechts = sideLinks - 6;
    final labelBreedte = math.min(
      tekstPainter.width,
      math.max(24.0, middenRechts - middenLinks),
    );
    final labelX =
        middenLinks + ((middenRechts - middenLinks) - labelBreedte) / 2;
    final labelY = y + 8;

    _tekenOnderbrokenLijn(
      canvas,
      paint: paint,
      startX: frontLinks,
      endX: frontRechts,
      y: y,
    );

    if (middenRechts > middenLinks) {
      _tekenOnderbrokenLijn(
        canvas,
        paint: paint,
        startX: middenLinks,
        endX: math.max(middenLinks, labelX - 6),
        y: y,
      );
      _tekenOnderbrokenLijn(
        canvas,
        paint: paint,
        startX: math.min(middenRechts, labelX + tekstPainter.width + 6),
        endX: middenRechts,
        y: y,
      );
    }

    _tekenOnderbrokenLijn(
      canvas,
      paint: paint,
      startX: sideLinks,
      endX: sideRechts,
      y: y,
    );

    tekstPainter.paint(canvas, Offset(labelX, labelY));
  }

  void _tekenOnderbrokenLijn(
    Canvas canvas, {
    required Paint paint,
    required double startX,
    required double endX,
    required double y,
  }) {
    if (endX <= startX) return;
    const streep = 6.0;
    const ruimte = 4.0;
    var x = startX;
    while (x < endX) {
      final einde = math.min(x + streep, endX);
      canvas.drawLine(Offset(x, y), Offset(einde, y), paint);
      x += streep + ruimte;
    }
  }

  void _tekenLadderkoorden(
    Canvas canvas, {
    required double lamelLinks,
    required double lamelRechts,
    required double boven,
    required double onder,
  }) {
    final kleur = model.ladderkoord == OpmetingBuitenjaloezieLadderkoord.zwart
        ? const Color(0xFF111827)
        : const Color(0xFF9CA3AF);

    final paint = Paint()
      ..color = kleur
      ..strokeWidth = 1.1;

    final breedte = lamelRechts - lamelLinks;
    for (final factor in <double>[0.24, 0.50, 0.76]) {
      final x = lamelLinks + breedte * factor;
      canvas.drawLine(Offset(x, boven), Offset(x, onder), paint);
    }
  }

  void _tekenKastMaatHorizontaal(
    Canvas canvas, {
    required double links,
    required double rechts,
    required double objectBoven,
    required double maatY,
    required String tekst,
  }) {
    final paint = Paint()
      ..color = const Color(0xFF4B5563)
      ..strokeWidth = 1;

    canvas.drawLine(Offset(links, maatY), Offset(rechts, maatY), paint);
    canvas.drawLine(
      Offset(links, objectBoven - 2),
      Offset(links, maatY - 3),
      paint,
    );
    canvas.drawLine(
      Offset(rechts, objectBoven - 2),
      Offset(rechts, maatY - 3),
      paint,
    );
    canvas.drawLine(Offset(links, maatY - 4), Offset(links, maatY + 4), paint);
    canvas.drawLine(
      Offset(rechts, maatY - 4),
      Offset(rechts, maatY + 4),
      paint,
    );

    _tekenLabel(
      canvas,
      tekst: tekst.trim(),
      positie: Offset((links + rechts) / 2, maatY - 17),
      gecentreerd: true,
      vet: true,
    );
  }

  void _tekenKastMaatVerticaal(
    Canvas canvas, {
    required double boven,
    required double onder,
    required double objectRechts,
    required double maatX,
    required String tekst,
  }) {
    final paint = Paint()
      ..color = const Color(0xFF4B5563)
      ..strokeWidth = 1;

    canvas.drawLine(Offset(maatX, boven), Offset(maatX, onder), paint);
    canvas.drawLine(
      Offset(objectRechts + 2, boven),
      Offset(maatX + 3, boven),
      paint,
    );
    canvas.drawLine(
      Offset(objectRechts + 2, onder),
      Offset(maatX + 3, onder),
      paint,
    );
    canvas.drawLine(Offset(maatX - 4, boven), Offset(maatX + 4, boven), paint);
    canvas.drawLine(Offset(maatX - 4, onder), Offset(maatX + 4, onder), paint);

    final tekstPainter = TextPainter(
      text: TextSpan(
        text: tekst,
        style: const TextStyle(
          color: Color(0xFF4B5563),
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(maatX + 12, (boven + onder) / 2);
    canvas.rotate(-math.pi / 2);
    tekstPainter.paint(
      canvas,
      Offset(-tekstPainter.width / 2, -tekstPainter.height / 2),
    );
    canvas.restore();
  }

  void _tekenMaatlijnHorizontaal(
    Canvas canvas, {
    required Offset start,
    required Offset einde,
    required String tekst,
  }) {
    final paint = Paint()
      ..color = const Color(0xFF4B5563)
      ..strokeWidth = 1;

    canvas.drawLine(start, einde, paint);
    canvas.drawLine(
      Offset(start.dx, start.dy - 5),
      Offset(start.dx, start.dy + 5),
      paint,
    );
    canvas.drawLine(
      Offset(einde.dx, einde.dy - 5),
      Offset(einde.dx, einde.dy + 5),
      paint,
    );

    _tekenLabel(
      canvas,
      tekst: tekst,
      positie: Offset((start.dx + einde.dx) / 2, start.dy - 17),
      gecentreerd: true,
    );
  }

  void _tekenMaatlijnVerticaal(
    Canvas canvas, {
    required Offset start,
    required Offset einde,
    required String tekst,
    bool rechts = false,
  }) {
    final paint = Paint()
      ..color = const Color(0xFF4B5563)
      ..strokeWidth = 1;

    canvas.drawLine(start, einde, paint);
    canvas.drawLine(
      Offset(start.dx - 5, start.dy),
      Offset(start.dx + 5, start.dy),
      paint,
    );
    canvas.drawLine(
      Offset(einde.dx - 5, einde.dy),
      Offset(einde.dx + 5, einde.dy),
      paint,
    );

    final tekstPainter = TextPainter(
      text: TextSpan(
        text: tekst,
        style: const TextStyle(
          color: Color(0xFF4B5563),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    final midden = Offset(
      start.dx + (rechts ? 15 : -15),
      (start.dy + einde.dy) / 2,
    );
    canvas.translate(midden.dx, midden.dy);
    canvas.rotate(-math.pi / 2);
    tekstPainter.paint(
      canvas,
      Offset(-tekstPainter.width / 2, -tekstPainter.height / 2),
    );
    canvas.restore();
  }

  void _tekenLabel(
    Canvas canvas, {
    required String tekst,
    required Offset positie,
    bool gecentreerd = false,
    bool vet = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: tekst,
        style: TextStyle(
          color: const Color(0xFF374151),
          fontSize: 10.5,
          fontWeight: vet ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: 220);

    painter.paint(
      canvas,
      Offset(
        gecentreerd ? positie.dx - painter.width / 2 : positie.dx,
        positie.dy,
      ),
    );
  }

  Color _kleurUitHex(String hex) {
    final schoon = hex.replaceAll('#', '').trim();
    final waarde = int.tryParse(schoon, radix: 16);
    if (waarde == null) return const Color(0xFFB7B7B7);
    return Color(0xFF000000 | waarde);
  }

  @override
  bool shouldRepaint(covariant OpmetingBuitenjaloeziePainter oldDelegate) {
    return oldDelegate.model != model;
  }
}

class _ZijaanzichtVormData {
  const _ZijaanzichtVormData({
    required this.totaleBreedteMm,
    required this.topBreedteMm,
    required this.aMaatMm,
    required this.horizontaleMaatLabel,
    required this.horizontaleMaatMm,
  });

  final int totaleBreedteMm;
  final int topBreedteMm;
  final int aMaatMm;
  final String horizontaleMaatLabel;
  final int horizontaleMaatMm;
}
