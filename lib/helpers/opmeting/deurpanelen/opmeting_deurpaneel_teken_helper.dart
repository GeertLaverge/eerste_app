import 'package:flutter/material.dart';

import '../raam/opmeting_raam_kader_helper.dart';
import '../raam/opmeting_raam_model.dart';
import 'opmeting_deurpaneel_dxf_bibliotheek.dart';
import 'opmeting_deurpaneel_dxf_painter.dart';
import 'opmeting_deurpaneel_geometrie_helper.dart';
import 'opmeting_deurpaneel_model.dart';
import 'opmeting_deurpaneel_toewijzing_model.dart';

class OpmetingDeurpaneelTekenvlakPainter extends CustomPainter {
  const OpmetingDeurpaneelTekenvlakPainter({
    required this.breedteMm,
    required this.hoogteMm,
    required this.vleugels,
    required this.toewijzingen,
  });

  final int breedteMm;
  final int hoogteMm;
  final List<OpmetingRaamVleugel> vleugels;
  final List<OpmetingDeurpaneelToewijzing> toewijzingen;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _tekstDonker = Color(0xFF111827);

  @override
  void paint(Canvas canvas, Size size) {
    if (toewijzingen.isEmpty || breedteMm <= 0 || hoogteMm <= 0) {
      return;
    }

    final buitenKader = OpmetingRaamKaderHelper.buitenKader(
      size: size,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    final vleugelPerId = <String, OpmetingRaamVleugel>{};

    for (final vleugel in vleugels) {
      if (!vleugel.isDeurVleugel) {
        continue;
      }

      vleugelPerId[vleugel.id] = vleugel;
    }

    for (final toewijzing in toewijzingen) {
      final vleugel = vleugelPerId[toewijzing.deurVleugelId];

      if (vleugel == null) {
        continue;
      }

      final paneelVlak =
          OpmetingDeurpaneelGeometrieHelper.paneelVlakVoorVleugel(
            vleugel: vleugel,
            buitenKader: buitenKader,
            breedteMm: breedteMm,
            hoogteMm: hoogteMm,
            uitvoering: toewijzing.uitvoering,
          );

      if (!OpmetingDeurpaneelGeometrieHelper.isGeldigVlak(paneelVlak)) {
        continue;
      }

      _tekenPaneelAchtergrond(
        canvas: canvas,
        paneelVlak: paneelVlak,
        toewijzing: toewijzing,
      );

      _tekenPaneelDxfIndienBeschikbaar(
        canvas: canvas,
        paneelVlak: paneelVlak,
        toewijzing: toewijzing,
      );

      _tekenOpeningslijnenBovenPaneel(
        canvas: canvas,
        vleugel: vleugel,
        buitenKader: buitenKader,
      );

      _tekenCilinderIndienNodig(
        canvas: canvas,
        vleugel: vleugel,
        paneelVlak: paneelVlak,
        buitenKader: buitenKader,
        toewijzing: toewijzing,
      );

      _tekenPaneelRand(
        canvas: canvas,
        paneelVlak: paneelVlak,
        toewijzing: toewijzing,
      );
    }
  }

  void _tekenPaneelAchtergrond({
    required Canvas canvas,
    required Rect paneelVlak,
    required OpmetingDeurpaneelToewijzing toewijzing,
  }) {
    final isVleugelOverdekkend =
        toewijzing.uitvoering ==
        OpmetingDeurpaneelUitvoering.vleugelOverdekkend;

    final vulPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isVleugelOverdekkend
          ? Colors.white.withOpacity(0.96)
          : const Color(0xFFE7F6EC).withOpacity(0.28);

    canvas.drawRect(paneelVlak, vulPaint);
  }

  void _tekenPaneelRand({
    required Canvas canvas,
    required Rect paneelVlak,
    required OpmetingDeurpaneelToewijzing toewijzing,
  }) {
    final isVleugelOverdekkend =
        toewijzing.uitvoering ==
        OpmetingDeurpaneelUitvoering.vleugelOverdekkend;

    final randPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = isVleugelOverdekkend ? 2.2 : 1.6
      ..color = _groen;

    canvas.drawRect(paneelVlak, randPaint);
  }

  void _tekenPaneelDxfIndienBeschikbaar({
    required Canvas canvas,
    required Rect paneelVlak,
    required OpmetingDeurpaneelToewijzing toewijzing,
  }) {
    final dxfTekening =
        OpmetingDeurpaneelDxfBibliotheek.tekeningVoorBestandsnaam(
          toewijzing.tekeningBestandsnaam,
        );

    if (dxfTekening == null || dxfTekening.isLeeg) {
      return;
    }

    OpmetingDeurpaneelDxfPainterHelper.tekenDxf(
      canvas: canvas,
      paneelVlak: paneelVlak,
      tekening: dxfTekening,
      kleur: _tekstDonker.withOpacity(0.88),
      margePx: 0,
      strokeWidth: 1.18,
      behoudVerhouding: false,
    );
  }

  void _tekenOpeningslijnenBovenPaneel({
    required Canvas canvas,
    required OpmetingRaamVleugel vleugel,
    required Rect buitenKader,
  }) {
    final binnenVlak =
        OpmetingDeurpaneelGeometrieHelper.deurBinnenVlakVoorVleugel(
          vleugel: vleugel,
          buitenKader: buitenKader,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
        );

    if (!OpmetingDeurpaneelGeometrieHelper.isGeldigVlak(binnenVlak)) {
      return;
    }

    final isDubbeleDeur = vleugel.isDubbeleDeurVleugel;
    final krukLinks = isDubbeleDeur
        ? vleugel.deurVleugelDeel == OpmetingRaamDeurVleugelDeel.rechts
        : vleugel.deurVleugelKrukZijde == OpmetingRaamKrukZijde.links;

    final scharnierX = krukLinks ? binnenVlak.right : binnenVlak.left;
    final puntX = krukLinks ? binnenVlak.left : binnenVlak.right;
    final draaipunt = Offset(puntX, binnenVlak.center.dy);

    final bovenStart = Offset(scharnierX, binnenVlak.top);
    final onderStart = Offset(scharnierX, binnenVlak.bottom);

    final haloPaint = Paint()
      ..color = Colors.white.withOpacity(0.88)
      ..strokeWidth = 4.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final lijnPaint = Paint()
      ..color = _tekstDonker
      ..strokeWidth = 1.45
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(bovenStart, draaipunt, haloPaint);
    canvas.drawLine(onderStart, draaipunt, haloPaint);
    canvas.drawLine(bovenStart, draaipunt, lijnPaint);
    canvas.drawLine(onderStart, draaipunt, lijnPaint);
  }

  void _tekenCilinderIndienNodig({
    required Canvas canvas,
    required OpmetingRaamVleugel vleugel,
    required Rect paneelVlak,
    required Rect buitenKader,
    required OpmetingDeurpaneelToewijzing toewijzing,
  }) {
    if (toewijzing.cilinderZijde == OpmetingDeurpaneelCilinderZijde.geen) {
      return;
    }

    final cilinderPunt =
        OpmetingDeurpaneelGeometrieHelper.cilinderPuntVoorVleugel(
          vleugel: vleugel,
          paneelVlak: paneelVlak,
          buitenKader: buitenKader,
          hoogteMm: hoogteMm,
        );

    if (cilinderPunt == null) {
      return;
    }

    final randPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..color = _tekstDonker;

    final vulPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    canvas.drawCircle(cilinderPunt, 6, vulPaint);
    canvas.drawCircle(cilinderPunt, 6, randPaint);
    canvas.drawLine(
      Offset(cilinderPunt.dx - 4, cilinderPunt.dy),
      Offset(cilinderPunt.dx + 4, cilinderPunt.dy),
      randPaint,
    );
  }

  @override
  bool shouldRepaint(covariant OpmetingDeurpaneelTekenvlakPainter oldDelegate) {
    return oldDelegate.breedteMm != breedteMm ||
        oldDelegate.hoogteMm != hoogteMm ||
        oldDelegate.vleugels != vleugels ||
        oldDelegate.toewijzingen != toewijzingen;
  }
}
