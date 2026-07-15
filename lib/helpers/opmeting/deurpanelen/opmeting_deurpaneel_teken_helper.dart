import 'package:flutter/material.dart';

import '../kader_samenstelling/opmeting_kader_samenstelling_model.dart';
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
    this.vleugelsPerKader = const <String, List<OpmetingRaamVleugel>>{},
    this.kaderSamenstelling,
  });

  final int breedteMm;
  final int hoogteMm;
  final List<OpmetingRaamVleugel> vleugels;
  final Map<String, List<OpmetingRaamVleugel>> vleugelsPerKader;
  final OpmetingKaderSamenstelling? kaderSamenstelling;
  final List<OpmetingDeurpaneelToewijzing> toewijzingen;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _tekstDonker = Color(0xFF111827);

  @override
  void paint(Canvas canvas, Size size) {
    if (toewijzingen.isEmpty || breedteMm <= 0 || hoogteMm <= 0) {
      return;
    }

    final vleugelWeergaves = _bepaalDeurVleugelWeergaves(size);

    if (vleugelWeergaves.isEmpty) {
      return;
    }

    final vleugelPerId = <String, _DeurpaneelVleugelWeergave>{};

    for (final weergave in vleugelWeergaves) {
      if (!weergave.vleugel.isDeurVleugel) {
        continue;
      }

      vleugelPerId[weergave.vleugel.id] = weergave;
    }

    for (final toewijzing in toewijzingen) {
      final weergave = vleugelPerId[toewijzing.deurVleugelId];

      if (weergave == null) {
        continue;
      }

      final paneelVlak =
          OpmetingDeurpaneelGeometrieHelper.paneelVlakVoorVleugel(
            vleugel: weergave.vleugel,
            buitenKader: weergave.buitenKader,
            breedteMm: weergave.breedteMm,
            hoogteMm: weergave.hoogteMm,
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

      _tekenOpeningslijnenBovenPaneel(canvas: canvas, weergave: weergave);

      _tekenCilinderIndienNodig(
        canvas: canvas,
        weergave: weergave,
        paneelVlak: paneelVlak,
        toewijzing: toewijzing,
      );

      _tekenPaneelRand(
        canvas: canvas,
        paneelVlak: paneelVlak,
        toewijzing: toewijzing,
      );
    }
  }

  List<_DeurpaneelVleugelWeergave> _bepaalDeurVleugelWeergaves(Size size) {
    final samenstelling = kaderSamenstelling;

    if (samenstelling == null || samenstelling.kaders.length <= 1) {
      final buitenKader = OpmetingRaamKaderHelper.buitenKader(
        size: size,
        breedteMm: breedteMm,
        hoogteMm: hoogteMm,
      );

      return vleugels
          .where((vleugel) => vleugel.isDeurVleugel)
          .map(
            (vleugel) => _DeurpaneelVleugelWeergave(
              vleugel: vleugel,
              buitenKader: buitenKader,
              breedteMm: breedteMm,
              hoogteMm: hoogteMm,
            ),
          )
          .toList(growable: false);
    }

    if (samenstelling.kaders.isEmpty) {
      return const <_DeurpaneelVleugelWeergave>[];
    }

    final compositieBuitenKader = OpmetingRaamKaderHelper.buitenKader(
      size: size,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    final minLinks = samenstelling.kaders
        .map((kader) => kader.linksMm)
        .reduce((a, b) => a < b ? a : b);
    final minBoven = samenstelling.kaders
        .map((kader) => kader.bovenMm)
        .reduce((a, b) => a < b ? a : b);

    final resultaat = <_DeurpaneelVleugelWeergave>[];

    for (final kader in samenstelling.kaders) {
      final lokaleVleugels = vleugelsPerKader[kader.id];

      if (lokaleVleugels == null || lokaleVleugels.isEmpty) {
        continue;
      }

      final kaderBuitenKader = _buitenKaderVoorSamenstellingsKader(
        compositieBuitenKader: compositieBuitenKader,
        kader: kader,
        minLinksMm: minLinks,
        minBovenMm: minBoven,
      );

      if (!OpmetingDeurpaneelGeometrieHelper.isGeldigVlak(kaderBuitenKader)) {
        continue;
      }

      final lokaalBuitenKader = OpmetingRaamKaderHelper.buitenKader(
        size: size,
        breedteMm: kader.breedteMm,
        hoogteMm: kader.hoogteMm,
      );

      if (!OpmetingDeurpaneelGeometrieHelper.isGeldigVlak(lokaalBuitenKader)) {
        continue;
      }

      for (final lokaleVleugel in lokaleVleugels) {
        if (!lokaleVleugel.isDeurVleugel) {
          continue;
        }

        final geschaaldeVleugel = lokaleVleugel.copyWith(
          vlak: _schaalRectVanLokaalNaarKader(
            rect: lokaleVleugel.vlak,
            lokaalBuitenKader: lokaalBuitenKader,
            kaderBuitenKader: kaderBuitenKader,
          ),
        );

        resultaat.add(
          _DeurpaneelVleugelWeergave(
            vleugel: geschaaldeVleugel,
            buitenKader: kaderBuitenKader,
            breedteMm: kader.breedteMm,
            hoogteMm: kader.hoogteMm,
          ),
        );
      }
    }

    return List<_DeurpaneelVleugelWeergave>.unmodifiable(resultaat);
  }

  Rect _buitenKaderVoorSamenstellingsKader({
    required Rect compositieBuitenKader,
    required OpmetingKaderDeel kader,
    required int minLinksMm,
    required int minBovenMm,
  }) {
    if (breedteMm <= 0 || hoogteMm <= 0) {
      return Rect.zero;
    }

    final schaalX = compositieBuitenKader.width / breedteMm;
    final schaalY = compositieBuitenKader.height / hoogteMm;

    return Rect.fromLTRB(
      compositieBuitenKader.left + (kader.linksMm - minLinksMm) * schaalX,
      compositieBuitenKader.top + (kader.bovenMm - minBovenMm) * schaalY,
      compositieBuitenKader.left + (kader.rechtsMm - minLinksMm) * schaalX,
      compositieBuitenKader.top + (kader.onderMm - minBovenMm) * schaalY,
    );
  }

  Rect _schaalRectVanLokaalNaarKader({
    required Rect rect,
    required Rect lokaalBuitenKader,
    required Rect kaderBuitenKader,
  }) {
    if (lokaalBuitenKader.width == 0 || lokaalBuitenKader.height == 0) {
      return Rect.zero;
    }

    double schaalX(double x) {
      final fractie = (x - lokaalBuitenKader.left) / lokaalBuitenKader.width;
      return kaderBuitenKader.left + fractie * kaderBuitenKader.width;
    }

    double schaalY(double y) {
      final fractie = (y - lokaalBuitenKader.top) / lokaalBuitenKader.height;
      return kaderBuitenKader.top + fractie * kaderBuitenKader.height;
    }

    return Rect.fromLTRB(
      schaalX(rect.left),
      schaalY(rect.top),
      schaalX(rect.right),
      schaalY(rect.bottom),
    );
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
    required _DeurpaneelVleugelWeergave weergave,
  }) {
    final binnenVlak =
        OpmetingDeurpaneelGeometrieHelper.deurBinnenVlakVoorVleugel(
          vleugel: weergave.vleugel,
          buitenKader: weergave.buitenKader,
          breedteMm: weergave.breedteMm,
          hoogteMm: weergave.hoogteMm,
        );

    if (!OpmetingDeurpaneelGeometrieHelper.isGeldigVlak(binnenVlak)) {
      return;
    }

    final vleugel = weergave.vleugel;
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
    required _DeurpaneelVleugelWeergave weergave,
    required Rect paneelVlak,
    required OpmetingDeurpaneelToewijzing toewijzing,
  }) {
    if (toewijzing.cilinderZijde == OpmetingDeurpaneelCilinderZijde.geen) {
      return;
    }

    final cilinderPunt =
        OpmetingDeurpaneelGeometrieHelper.cilinderPuntVoorVleugel(
          vleugel: weergave.vleugel,
          paneelVlak: paneelVlak,
          buitenKader: weergave.buitenKader,
          hoogteMm: weergave.hoogteMm,
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
        oldDelegate.vleugelsPerKader != vleugelsPerKader ||
        oldDelegate.kaderSamenstelling != kaderSamenstelling ||
        oldDelegate.toewijzingen != toewijzingen;
  }
}

class _DeurpaneelVleugelWeergave {
  const _DeurpaneelVleugelWeergave({
    required this.vleugel,
    required this.buitenKader,
    required this.breedteMm,
    required this.hoogteMm,
  });

  final OpmetingRaamVleugel vleugel;
  final Rect buitenKader;
  final int breedteMm;
  final int hoogteMm;
}
