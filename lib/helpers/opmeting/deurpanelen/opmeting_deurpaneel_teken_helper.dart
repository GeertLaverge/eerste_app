// THIMACO-CONTROLE: DEURPANEEL-BLIJFT-BINNEN-VLEUGELKADER-20260722
import 'package:flutter/material.dart';

import '../kader_samenstelling/opmeting_kader_samenstelling_model.dart';
import '../kader_samenstelling/opmeting_kader_samenstelling_teken_helper.dart';
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

      // Een deurpaneel hoort uitsluitend bij het kader waarin zijn
      // deurvleugel staat. Deze clip is een laatste veiligheidsgrens voor
      // oudere fiches en voorkomt dat een paneel ooit over een bovenlicht,
      // zijlicht of ander gekoppeld kader kan tekenen.
      canvas.save();
      canvas.clipRect(weergave.buitenKader);

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

      canvas.restore();
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

    // Belangrijk bij meerdere kaders en schermrotatie:
    // Gebruik exact dezelfde kaderweergave als de hoofdtekening.
    // Een eigen mm->pixel berekening lijkt eerst juist, maar verschilt bij
    // liggend/staand, extra kaders en technische layout. Daardoor kwamen het
    // deurpaneel en de openingslijnen los van de deurvleugel te staan.
    final maatLayout = OpmetingKaderSamenstellingTekenHelper.berekenWeergave(
      tekenGebied: Rect.zero,
      samenstelling: samenstelling,
    ).layout;

    final compositieBuitenKader = OpmetingRaamKaderHelper.buitenKader(
      size: size,
      breedteMm: maatLayout.breedteMm,
      hoogteMm: maatLayout.hoogteMm,
    );

    if (!OpmetingDeurpaneelGeometrieHelper.isGeldigVlak(
      compositieBuitenKader,
    )) {
      return const <_DeurpaneelVleugelWeergave>[];
    }

    final weergave = OpmetingKaderSamenstellingTekenHelper.berekenWeergave(
      tekenGebied: compositieBuitenKader,
      samenstelling: samenstelling,
    );

    final resultaat = <_DeurpaneelVleugelWeergave>[];
    final heeftDeurVleugelsPerKader = vleugelsPerKader.values.any(
      (lijst) => lijst.any((vleugel) => vleugel.isDeurVleugel),
    );
    final fallbackKaderId = heeftDeurVleugelsPerKader
        ? null
        : _fallbackKaderIdVoorLosseVleugels(
            size: size,
            samenstelling: samenstelling,
          );

    for (final kader in weergave.layout.kaders) {
      final lokaleVleugels =
          vleugelsPerKader[kader.id] ??
          (fallbackKaderId == kader.id ? vleugels : null);

      if (lokaleVleugels == null || lokaleVleugels.isEmpty) {
        continue;
      }

      final kaderBuitenKader = weergave.rectVoorKaderId(kader.id);

      if (kaderBuitenKader == null ||
          !OpmetingDeurpaneelGeometrieHelper.isGeldigVlak(kaderBuitenKader)) {
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

        final geschaaldVlak = _schaalRectVanLokaalNaarKader(
          rect: lokaleVleugel.vlak,
          lokaalBuitenKader: lokaalBuitenKader,
          kaderBuitenKader: kaderBuitenKader,
        );
        final begrensdVlak = _begrensRectBinnenKader(
          rect: geschaaldVlak,
          kader: kaderBuitenKader,
        );

        if (!OpmetingDeurpaneelGeometrieHelper.isGeldigVlak(begrensdVlak)) {
          continue;
        }

        final geschaaldeVleugel = lokaleVleugel.copyWith(vlak: begrensdVlak);

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

  String? _fallbackKaderIdVoorLosseVleugels({
    required Size size,
    required OpmetingKaderSamenstelling samenstelling,
  }) {
    if (samenstelling.kaders.isEmpty) {
      return null;
    }

    final deurVleugels = vleugels
        .where((vleugel) => vleugel.isDeurVleugel)
        .toList(growable: false);

    if (deurVleugels.isEmpty) {
      final actiefKaderId = samenstelling.actiefKaderId.trim();
      final actiefBestaat = samenstelling.kaders.any(
        (kader) => kader.id == actiefKaderId,
      );
      return actiefBestaat ? actiefKaderId : samenstelling.kaders.first.id;
    }

    var gecombineerdVlak = deurVleugels.first.vlak;
    for (final vleugel in deurVleugels.skip(1)) {
      gecombineerdVlak = gecombineerdVlak.expandToInclude(vleugel.vlak);
    }

    final vleugelOppervlakte = _oppervlakte(gecombineerdVlak);
    String? besteKaderId;
    var besteScore = -1.0;
    var besteKaderOppervlakteMm = -1;

    for (final kader in samenstelling.kaders) {
      final lokaalBuitenKader = OpmetingRaamKaderHelper.buitenKader(
        size: size,
        breedteMm: kader.breedteMm,
        hoogteMm: kader.hoogteMm,
      );
      final overlap = _overlapOppervlakte(gecombineerdVlak, lokaalBuitenKader);
      final dekking = vleugelOppervlakte <= 0
          ? 0.0
          : overlap / vleugelOppervlakte;
      final middenBonus =
          lokaalBuitenKader.inflate(2).contains(gecombineerdVlak.center)
          ? 1.0
          : 0.0;
      final score = dekking + middenBonus;
      final kaderOppervlakteMm = kader.breedteMm * kader.hoogteMm;

      if (score > besteScore ||
          (score == besteScore &&
              kaderOppervlakteMm > besteKaderOppervlakteMm)) {
        besteScore = score;
        besteKaderOppervlakteMm = kaderOppervlakteMm;
        besteKaderId = kader.id;
      }
    }

    return besteKaderId ?? samenstelling.kaders.first.id;
  }

  double _oppervlakte(Rect rect) {
    if (rect.width <= 0 || rect.height <= 0) {
      return 0;
    }
    return rect.width * rect.height;
  }

  double _overlapOppervlakte(Rect eerste, Rect tweede) {
    final links = eerste.left > tweede.left ? eerste.left : tweede.left;
    final boven = eerste.top > tweede.top ? eerste.top : tweede.top;
    final rechts = eerste.right < tweede.right ? eerste.right : tweede.right;
    final onder = eerste.bottom < tweede.bottom ? eerste.bottom : tweede.bottom;

    if (rechts <= links || onder <= boven) {
      return 0;
    }

    return (rechts - links) * (onder - boven);
  }

  Rect _begrensRectBinnenKader({required Rect rect, required Rect kader}) {
    final links = rect.left.clamp(kader.left, kader.right).toDouble();
    final boven = rect.top.clamp(kader.top, kader.bottom).toDouble();
    final rechts = rect.right.clamp(kader.left, kader.right).toDouble();
    final onder = rect.bottom.clamp(kader.top, kader.bottom).toDouble();

    if (rechts <= links || onder <= boven) {
      return Rect.zero;
    }

    return Rect.fromLTRB(links, boven, rechts, onder);
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
