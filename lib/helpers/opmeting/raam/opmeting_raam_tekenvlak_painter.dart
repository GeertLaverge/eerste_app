import 'package:flutter/material.dart';

import '../kader_samenstelling/opmeting_kader_samenstelling_model.dart';
import '../kader_samenstelling/opmeting_kader_samenstelling_teken_helper.dart';
import 'opmeting_raam_kader_helper.dart';
import 'opmeting_raam_keuzemenu_model.dart';
import 'opmeting_raam_kleinhout_helper.dart';
import 'opmeting_raam_kleinhout_model.dart';
import 'opmeting_raam_model.dart';
import 'opmeting_raam_opvulling_model.dart';
import 'opmeting_raam_technische_layout_helper.dart';
import 'opmeting_raam_technische_tekening_painter_helper.dart';
import 'opmeting_raam_tstijl_helper.dart';
import 'opmeting_raam_vleugel_helper.dart';
import 'opmeting_raam_vulling_helper.dart';
import 'opmeting_raam_vulling_teken_helper.dart';

class _OpmetingRaamTechnischeKaderGroepWeergave {
  const _OpmetingRaamTechnischeKaderGroepWeergave({
    required this.groepSleutel,
    required this.kaderIds,
    required this.groepRect,
    required this.layout,
  });

  final String groepSleutel;
  final Set<String> kaderIds;
  final Rect groepRect;
  final OpmetingRaamTechnischeLayout layout;
}

class OpmetingRaamTekenvlakPainter extends CustomPainter {
  const OpmetingRaamTekenvlakPainter({
    required this.breedteMm,
    required this.hoogteMm,
    required this.geselecteerdeLijn,
    required this.previewPunt,
    required this.tStijlen,
    this.tStijlenPerKader = const <String, List<OpmetingRaamTStijl>>{},
    required this.vleugels,
    this.vleugelsPerKader = const <String, List<OpmetingRaamVleugel>>{},
    required this.vulvlakken,
    this.vulvlakkenPerKader = const <String, List<OpmetingRaamVulvlak>>{},
    required this.vullingToewijzingen,
    this.vullingToewijzingenPerKader =
        const <String, List<OpmetingRaamVullingToewijzing>>{},
    required this.geselecteerdeVulvlakIds,
    this.geselecteerdeVulvlakIdsPerKader = const <String, Set<String>>{},
    this.kleinhouten = const <OpmetingRaamKleinhout>[],
    this.kleinhoutenPerKader = const <String, List<OpmetingRaamKleinhout>>{},
    this.geselecteerdeKleinhoutVlakIds = const <String>{},
    this.geselecteerdeKleinhoutVlakIdsPerKader = const <String, Set<String>>{},
    this.technischeTekeningen =
        const <OpmetingRaamTechnischeTekeningInstelling>[],
    this.technischeTekeningenPerKader =
        const <String, List<OpmetingRaamTechnischeTekeningInstelling>>{},
    this.technischeTekeningenPerKaderGroep =
        const <String, List<OpmetingRaamTechnischeTekeningInstelling>>{},
    this.technischeKaderGroepen = const <String, Set<String>>{},
    this.geselecteerdeKaderIds = const <String>{},
    this.kaderSamenstelling,
    this.actiefKaderId,
  });

  final int breedteMm;
  final int hoogteMm;

  final OpmetingRaamLijn? geselecteerdeLijn;
  final Offset? previewPunt;

  final List<OpmetingRaamTStijl> tStijlen;
  final Map<String, List<OpmetingRaamTStijl>> tStijlenPerKader;

  final List<OpmetingRaamVleugel> vleugels;
  final Map<String, List<OpmetingRaamVleugel>> vleugelsPerKader;

  final List<OpmetingRaamVulvlak> vulvlakken;
  final Map<String, List<OpmetingRaamVulvlak>> vulvlakkenPerKader;

  final List<OpmetingRaamVullingToewijzing> vullingToewijzingen;
  final Map<String, List<OpmetingRaamVullingToewijzing>>
  vullingToewijzingenPerKader;

  final Set<String> geselecteerdeVulvlakIds;
  final Map<String, Set<String>> geselecteerdeVulvlakIdsPerKader;

  final List<OpmetingRaamKleinhout> kleinhouten;
  final Map<String, List<OpmetingRaamKleinhout>> kleinhoutenPerKader;

  final Set<String> geselecteerdeKleinhoutVlakIds;
  final Map<String, Set<String>> geselecteerdeKleinhoutVlakIdsPerKader;

  final List<OpmetingRaamTechnischeTekeningInstelling> technischeTekeningen;

  final Map<String, List<OpmetingRaamTechnischeTekeningInstelling>>
  technischeTekeningenPerKader;

  final Map<String, List<OpmetingRaamTechnischeTekeningInstelling>>
  technischeTekeningenPerKaderGroep;

  final Map<String, Set<String>> technischeKaderGroepen;

  final Set<String> geselecteerdeKaderIds;

  final OpmetingKaderSamenstelling? kaderSamenstelling;
  final String? actiefKaderId;

  static const Color _maatKleur = Color(0xFF111827);
  static const double _kwartDraai = 1.5707963267948966;

  @override
  void paint(Canvas canvas, Size size) {
    _tekenRaster(canvas, size);

    final effectieveSamenstelling = _effectieveSamenstelling();

    final heeftMeerdereKaders = effectieveSamenstelling != null;

    final samenstellingLayout = heeftMeerdereKaders
        ? OpmetingKaderSamenstellingTekenHelper.berekenWeergave(
            tekenGebied: Rect.zero,
            samenstelling: effectieveSamenstelling,
          ).layout
        : null;

    final maatBreedteMm = samenstellingLayout?.breedteMm ?? breedteMm;
    final maatHoogteMm = samenstellingLayout?.hoogteMm ?? hoogteMm;

    final basisBuiten = OpmetingRaamKaderHelper.buitenKader(
      size: size,
      breedteMm: maatBreedteMm,
      hoogteMm: maatHoogteMm,
    );

    final basisBinnen = OpmetingRaamKaderHelper.binnenKader(
      buitenKader: basisBuiten,
      breedteMm: maatBreedteMm,
      hoogteMm: maatHoogteMm,
    );

    final onderdelenBuiten = heeftMeerdereKaders
        ? OpmetingRaamKaderHelper.buitenKader(
            size: size,
            breedteMm: breedteMm,
            hoogteMm: hoogteMm,
          )
        : basisBuiten;

    final onderdelenBinnen = heeftMeerdereKaders
        ? OpmetingRaamKaderHelper.binnenKader(
            buitenKader: onderdelenBuiten,
            breedteMm: breedteMm,
            hoogteMm: hoogteMm,
          )
        : basisBinnen;

    if (heeftMeerdereKaders) {
      _tekenKaderSamenstellingMetActiefRaam(
        canvas: canvas,
        size: size,
        tekenGebied: basisBuiten,
        samenstelling: effectieveSamenstelling!,
      );
    } else {
      final technischeLayout = OpmetingRaamTechnischeLayoutHelper.bereken(
        totaleMaatRect: basisBuiten,
        breedteMm: maatBreedteMm,
        hoogteMm: maatHoogteMm,
        technischeTekeningen: technischeTekeningen,
      );

      canvas.save();

      technischeLayout.pasRaamTransformatieToe(canvas);

      _tekenRaamInhoud(
        canvas: canvas,
        buiten: onderdelenBuiten,
        binnen: onderdelenBinnen,
      );

      canvas.restore();

      OpmetingRaamTechnischeTekeningPainterHelper.teken(
        canvas: canvas,
        layout: technischeLayout,
      );
    }

    if (heeftMeerdereKaders && effectieveSamenstelling != null) {
      _tekenMaatvoeringPerKader(
        canvas: canvas,
        size: size,
        tekenGebied: basisBuiten,
        samenstelling: effectieveSamenstelling,
      );
    } else {
      _tekenMaatvoering(
        canvas: canvas,
        buiten: basisBuiten,
        maatBreedteMm: maatBreedteMm,
        maatHoogteMm: maatHoogteMm,
        toonTStijlKetting: true,
      );
    }
  }

  OpmetingKaderSamenstelling? _effectieveSamenstelling() {
    final samenstelling = kaderSamenstelling;

    if (samenstelling == null) {
      return null;
    }

    if (samenstelling.kaders.length <= 1) {
      return null;
    }

    return samenstelling;
  }

  void _tekenKaderSamenstellingMetActiefRaam({
    required Canvas canvas,
    required Size size,
    required Rect tekenGebied,
    required OpmetingKaderSamenstelling samenstelling,
  }) {
    final weergave = OpmetingKaderSamenstellingTekenHelper.berekenWeergave(
      tekenGebied: tekenGebied,
      samenstelling: samenstelling,
    );

    final actieveId = actiefKaderId ?? samenstelling.actiefKaderId;

    final technischeGroepen = _berekenTechnischeGroepWeergaves(
      weergave: weergave,
    );

    final technischeGroepPerKaderId =
        <String, _OpmetingRaamTechnischeKaderGroepWeergave>{};

    for (final groep in technischeGroepen) {
      for (final kaderId in groep.kaderIds) {
        technischeGroepPerKaderId[kaderId] = groep;
      }
    }

    OpmetingKaderDeel? actiefKader;
    Rect? actiefRect;

    for (final kader in weergave.layout.kaders) {
      final origineleRect = weergave.rectVoorKaderId(kader.id);

      if (origineleRect == null) {
        continue;
      }

      final groepWeergave = technischeGroepPerKaderId[kader.id];

      final rect = groepWeergave == null
          ? origineleRect
          : _pasKaderRectAanVolgensGroepLayout(
              kaderRect: origineleRect,
              groepWeergave: groepWeergave,
            );

      if (kader.id == actieveId) {
        actiefKader = kader;
        actiefRect = rect;
        continue;
      }

      final kaderTStijlen =
          tStijlenPerKader[kader.id] ?? const <OpmetingRaamTStijl>[];

      final kaderVleugels =
          vleugelsPerKader[kader.id] ?? const <OpmetingRaamVleugel>[];

      final kaderVulvlakken =
          vulvlakkenPerKader[kader.id] ?? const <OpmetingRaamVulvlak>[];

      final kaderToewijzingen =
          vullingToewijzingenPerKader[kader.id] ??
          const <OpmetingRaamVullingToewijzing>[];

      final kaderGeselecteerdeVulvlakken =
          geselecteerdeVulvlakIdsPerKader[kader.id] ?? const <String>{};

      final kaderKleinhouten =
          kleinhoutenPerKader[kader.id] ?? const <OpmetingRaamKleinhout>[];

      final kaderGeselecteerdeKleinhoutVlakken =
          geselecteerdeKleinhoutVlakIdsPerKader[kader.id] ?? const <String>{};

      final kaderTechnischeTekeningen = groepWeergave == null
          ? technischeTekeningenPerKader[kader.id] ??
                const <OpmetingRaamTechnischeTekeningInstelling>[]
          : const <OpmetingRaamTechnischeTekeningInstelling>[];

      _tekenRaamInhoudInKader(
        canvas: canvas,
        size: size,
        doelRect: rect,
        kader: kader,
        tStijlenInKader: kaderTStijlen,
        vleugelsInKader: kaderVleugels,
        vulvlakkenInKader: kaderVulvlakken,
        vullingToewijzingenInKader: kaderToewijzingen,
        geselecteerdeVulvlakIdsInKader: kaderGeselecteerdeVulvlakken,
        kleinhoutenInKader: kaderKleinhouten,
        geselecteerdeKleinhoutVlakIdsInKader:
            kaderGeselecteerdeKleinhoutVlakken,
        technischeTekeningenInKader: kaderTechnischeTekeningen,
      );
    }

    if (actiefKader != null &&
        actiefRect != null &&
        actiefRect.width > 0 &&
        actiefRect.height > 0) {
      final actiefGroepWeergave = technischeGroepPerKaderId[actieveId];

      final actiefBuiten = OpmetingRaamKaderHelper.buitenKader(
        size: size,
        breedteMm: actiefKader.breedteMm,
        hoogteMm: actiefKader.hoogteMm,
      );

      final actieveTechnischeTekeningen = actiefGroepWeergave == null
          ? technischeTekeningenPerKader[actieveId] ?? technischeTekeningen
          : const <OpmetingRaamTechnischeTekeningInstelling>[];

      final actieveTechnischeLayout =
          OpmetingRaamTechnischeLayoutHelper.bereken(
            totaleMaatRect: actiefBuiten,
            breedteMm: actiefKader.breedteMm,
            hoogteMm: actiefKader.hoogteMm,
            technischeTekeningen: actieveTechnischeTekeningen,
          );

      canvas.save();

      _pasRectTransformatieToe(
        canvas: canvas,
        bron: actiefBuiten,
        doel: actiefRect,
      );

      canvas.save();

      actieveTechnischeLayout.pasRaamTransformatieToe(canvas);

      _tekenRaamInhoud(
        canvas: canvas,
        buiten: actiefBuiten,
        binnen: OpmetingRaamKaderHelper.binnenKader(
          buitenKader: actiefBuiten,
          breedteMm: actiefKader.breedteMm,
          hoogteMm: actiefKader.hoogteMm,
        ),
        tekenKader: true,
        werkBreedteMm: actiefKader.breedteMm,
        werkHoogteMm: actiefKader.hoogteMm,
        tStijlenOverride: tStijlen,
        vleugelsOverride: vleugels,
        vulvlakkenOverride: vulvlakkenPerKader[actieveId] ?? vulvlakken,
        vullingToewijzingenOverride:
            vullingToewijzingenPerKader[actieveId] ?? vullingToewijzingen,
        geselecteerdeVulvlakIdsOverride:
            geselecteerdeVulvlakIdsPerKader[actieveId] ??
            geselecteerdeVulvlakIds,
        kleinhoutenOverride: kleinhoutenPerKader[actieveId] ?? kleinhouten,
        geselecteerdeKleinhoutVlakIdsOverride:
            geselecteerdeKleinhoutVlakIdsPerKader[actieveId] ??
            geselecteerdeKleinhoutVlakIds,
        toonSelectie: true,
      );

      canvas.restore();

      OpmetingRaamTechnischeTekeningPainterHelper.teken(
        canvas: canvas,
        layout: actieveTechnischeLayout,
      );

      canvas.restore();
    }

    for (final groep in technischeGroepen) {
      OpmetingRaamTechnischeTekeningPainterHelper.teken(
        canvas: canvas,
        layout: groep.layout,
      );
    }

    if (geselecteerdeKaderIds.isNotEmpty) {
      for (final kaderId in geselecteerdeKaderIds) {
        final rect = weergave.rectVoorKaderId(kaderId);

        if (rect != null) {
          _tekenActiefKaderSelectie(canvas: canvas, rect: rect);
        }
      }
    } else if (actiefRect != null) {
      _tekenActiefKaderSelectie(canvas: canvas, rect: actiefRect);
    }
  }

  List<_OpmetingRaamTechnischeKaderGroepWeergave>
  _berekenTechnischeGroepWeergaves({
    required OpmetingKaderSamenstellingWeergave weergave,
  }) {
    final resultaat = <_OpmetingRaamTechnischeKaderGroepWeergave>[];

    for (final entry in technischeKaderGroepen.entries) {
      final groepSleutel = entry.key;
      final kaderIds = entry.value.where((id) => id.trim().isNotEmpty).toSet();

      if (kaderIds.length <= 1) {
        continue;
      }

      final tekeningen =
          technischeTekeningenPerKaderGroep[groepSleutel] ??
          const <OpmetingRaamTechnischeTekeningInstelling>[];

      if (tekeningen.isEmpty) {
        continue;
      }

      Rect? groepRect;
      int? minX;
      int? minY;
      int? maxX;
      int? maxY;

      for (final kader in weergave.layout.kaders) {
        if (!kaderIds.contains(kader.id)) {
          continue;
        }

        final rect = weergave.rectVoorKaderId(kader.id);

        if (rect == null || rect.width <= 0 || rect.height <= 0) {
          continue;
        }

        groepRect = groepRect == null ? rect : groepRect.expandToInclude(rect);

        minX = minX == null
            ? kader.linksMm
            : (kader.linksMm < minX ? kader.linksMm : minX);
        minY = minY == null
            ? kader.bovenMm
            : (kader.bovenMm < minY ? kader.bovenMm : minY);
        maxX = maxX == null
            ? kader.rechtsMm
            : (kader.rechtsMm > maxX ? kader.rechtsMm : maxX);
        maxY = maxY == null
            ? kader.onderMm
            : (kader.onderMm > maxY ? kader.onderMm : maxY);
      }

      if (groepRect == null ||
          minX == null ||
          minY == null ||
          maxX == null ||
          maxY == null) {
        continue;
      }

      final groepBreedteMm = maxX - minX;
      final groepHoogteMm = maxY - minY;

      if (groepBreedteMm <= 0 || groepHoogteMm <= 0) {
        continue;
      }

      final layout = OpmetingRaamTechnischeLayoutHelper.bereken(
        totaleMaatRect: groepRect,
        breedteMm: groepBreedteMm,
        hoogteMm: groepHoogteMm,
        technischeTekeningen: tekeningen,
      );

      resultaat.add(
        _OpmetingRaamTechnischeKaderGroepWeergave(
          groepSleutel: groepSleutel,
          kaderIds: Set<String>.unmodifiable(kaderIds),
          groepRect: groepRect,
          layout: layout,
        ),
      );
    }

    return resultaat;
  }

  Rect _pasKaderRectAanVolgensGroepLayout({
    required Rect kaderRect,
    required _OpmetingRaamTechnischeKaderGroepWeergave groepWeergave,
  }) {
    final groepRect = groepWeergave.groepRect;
    final raamRect = groepWeergave.layout.raamKaderRect;

    if (groepRect.width <= 0 ||
        groepRect.height <= 0 ||
        raamRect.width <= 0 ||
        raamRect.height <= 0) {
      return kaderRect;
    }

    double pasX(double x) {
      final fractie = ((x - groepRect.left) / groepRect.width)
          .clamp(0.0, 1.0)
          .toDouble();

      return raamRect.left + fractie * raamRect.width;
    }

    double pasY(double y) {
      final fractie = ((y - groepRect.top) / groepRect.height)
          .clamp(0.0, 1.0)
          .toDouble();

      return raamRect.top + fractie * raamRect.height;
    }

    return Rect.fromLTRB(
      pasX(kaderRect.left),
      pasY(kaderRect.top),
      pasX(kaderRect.right),
      pasY(kaderRect.bottom),
    );
  }

  void _tekenActiefKaderSelectie({required Canvas canvas, required Rect rect}) {
    if (rect.width <= 0 || rect.height <= 0) {
      return;
    }

    final selectiePaint = Paint()
      ..color = const Color(0xFF0B7A3B)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final bolPaint = Paint()
      ..color = const Color(0xFF0B7A3B)
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, selectiePaint);

    canvas.drawCircle(rect.topLeft, 5, bolPaint);
    canvas.drawCircle(rect.topRight, 5, bolPaint);
    canvas.drawCircle(rect.bottomLeft, 5, bolPaint);
    canvas.drawCircle(rect.bottomRight, 5, bolPaint);
  }

  void _tekenRaamInhoudInKader({
    required Canvas canvas,
    required Size size,
    required Rect doelRect,
    required OpmetingKaderDeel kader,
    required List<OpmetingRaamTStijl> tStijlenInKader,
    required List<OpmetingRaamVleugel> vleugelsInKader,
    required List<OpmetingRaamVulvlak> vulvlakkenInKader,
    required List<OpmetingRaamVullingToewijzing> vullingToewijzingenInKader,
    required Set<String> geselecteerdeVulvlakIdsInKader,
    required List<OpmetingRaamKleinhout> kleinhoutenInKader,
    required Set<String> geselecteerdeKleinhoutVlakIdsInKader,
    required List<OpmetingRaamTechnischeTekeningInstelling>
    technischeTekeningenInKader,
  }) {
    final bronBuiten = OpmetingRaamKaderHelper.buitenKader(
      size: size,
      breedteMm: kader.breedteMm,
      hoogteMm: kader.hoogteMm,
    );

    final bronBinnen = OpmetingRaamKaderHelper.binnenKader(
      buitenKader: bronBuiten,
      breedteMm: kader.breedteMm,
      hoogteMm: kader.hoogteMm,
    );

    final technischeLayout = OpmetingRaamTechnischeLayoutHelper.bereken(
      totaleMaatRect: bronBuiten,
      breedteMm: kader.breedteMm,
      hoogteMm: kader.hoogteMm,
      technischeTekeningen: technischeTekeningenInKader,
    );

    canvas.save();

    _pasRectTransformatieToe(canvas: canvas, bron: bronBuiten, doel: doelRect);

    canvas.save();

    technischeLayout.pasRaamTransformatieToe(canvas);

    _tekenRaamInhoud(
      canvas: canvas,
      buiten: bronBuiten,
      binnen: bronBinnen,
      tekenKader: true,
      werkBreedteMm: kader.breedteMm,
      werkHoogteMm: kader.hoogteMm,
      tStijlenOverride: tStijlenInKader,
      vleugelsOverride: vleugelsInKader,
      vulvlakkenOverride: vulvlakkenInKader,
      vullingToewijzingenOverride: vullingToewijzingenInKader,
      geselecteerdeVulvlakIdsOverride: geselecteerdeVulvlakIdsInKader,
      kleinhoutenOverride: kleinhoutenInKader,
      geselecteerdeKleinhoutVlakIdsOverride:
          geselecteerdeKleinhoutVlakIdsInKader,
      toonSelectie: false,
    );

    canvas.restore();

    OpmetingRaamTechnischeTekeningPainterHelper.teken(
      canvas: canvas,
      layout: technischeLayout,
    );

    canvas.restore();
  }

  void _pasRectTransformatieToe({
    required Canvas canvas,
    required Rect bron,
    required Rect doel,
  }) {
    if (bron.width <= 0 ||
        bron.height <= 0 ||
        doel.width <= 0 ||
        doel.height <= 0) {
      return;
    }

    canvas.translate(doel.left, doel.top);
    canvas.scale(doel.width / bron.width, doel.height / bron.height);
    canvas.translate(-bron.left, -bron.top);
  }

  void _tekenRaamInhoud({
    required Canvas canvas,
    required Rect buiten,
    required Rect binnen,
    bool tekenKader = true,
    int? werkBreedteMm,
    int? werkHoogteMm,
    List<OpmetingRaamTStijl>? tStijlenOverride,
    List<OpmetingRaamVleugel>? vleugelsOverride,
    List<OpmetingRaamVulvlak>? vulvlakkenOverride,
    List<OpmetingRaamVullingToewijzing>? vullingToewijzingenOverride,
    Set<String>? geselecteerdeVulvlakIdsOverride,
    List<OpmetingRaamKleinhout>? kleinhoutenOverride,
    Set<String>? geselecteerdeKleinhoutVlakIdsOverride,
    bool toonSelectie = true,
  }) {
    final effectieveBreedteMm = werkBreedteMm ?? breedteMm;
    final effectieveHoogteMm = werkHoogteMm ?? hoogteMm;

    final teTekenenTStijlen = tStijlenOverride ?? tStijlen;
    final teTekenenVleugels = vleugelsOverride ?? vleugels;
    final teTekenenVulvlakken = vulvlakkenOverride ?? vulvlakken;
    final teTekenenVullingToewijzingen =
        vullingToewijzingenOverride ?? vullingToewijzingen;
    final teTekenenGeselecteerdeVulvlakIds =
        geselecteerdeVulvlakIdsOverride ?? geselecteerdeVulvlakIds;
    final teTekenenKleinhouten = kleinhoutenOverride ?? kleinhouten;
    final teTekenenGeselecteerdeKleinhoutVlakIds =
        geselecteerdeKleinhoutVlakIdsOverride ?? geselecteerdeKleinhoutVlakIds;

    final teTekenenGeselecteerdeVoorgrondVlakIds = <String>{
      ...teTekenenGeselecteerdeVulvlakIds,
      ...teTekenenGeselecteerdeKleinhoutVlakIds,
    };

    OpmetingRaamVullingTekenHelper.tekenAchtergrond(
      canvas: canvas,
      vulvlakken: teTekenenVulvlakken,
      toewijzingen: teTekenenVullingToewijzingen,
    );

    if (tekenKader) {
      _tekenKader(canvas, buiten, binnen);
    }

    for (final vleugel in teTekenenVleugels) {
      OpmetingRaamVleugelHelper.tekenVleugel(
        canvas: canvas,
        vleugel: vleugel,
        buitenKader: buiten,
        breedteMm: effectieveBreedteMm,
        hoogteMm: effectieveHoogteMm,
      );
    }

    for (final stijl in teTekenenTStijlen) {
      OpmetingRaamTStijlHelper.tekenTStijl(
        canvas: canvas,
        stijl: stijl,
        buitenKader: buiten,
        breedteMm: effectieveBreedteMm,
        hoogteMm: effectieveHoogteMm,
      );
    }

    OpmetingRaamKleinhoutHelper.tekenKleinhouten(
      canvas: canvas,
      buitenKader: buiten,
      breedteMm: effectieveBreedteMm,
      hoogteMm: effectieveHoogteMm,
      vulvlakken: teTekenenVulvlakken,
      kleinhouten: teTekenenKleinhouten,
      geselecteerdeVlakIds: teTekenenGeselecteerdeKleinhoutVlakIds,
    );

    OpmetingRaamVullingTekenHelper.tekenVoorgrond(
      canvas: canvas,
      vulvlakken: teTekenenVulvlakken,
      toewijzingen: teTekenenVullingToewijzingen,
      geselecteerdeVulvlakIds: teTekenenGeselecteerdeVoorgrondVlakIds,
    );

    if (toonSelectie) {
      _tekenGeselecteerdeLijn(canvas);
      _tekenPreviewPunt(canvas);
    }
  }

  void _tekenGeselecteerdeLijn(Canvas canvas) {
    if (geselecteerdeLijn == null) {
      return;
    }

    final paint = Paint()
      ..color = const Color(0xFFF97316)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(geselecteerdeLijn!.start, geselecteerdeLijn!.einde, paint);
  }

  void _tekenPreviewPunt(Canvas canvas) {
    if (previewPunt == null) {
      return;
    }

    final paint = Paint()
      ..color = const Color(0xFFDC2626)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(previewPunt!, 6, paint);
  }

  void _tekenRaster(Canvas canvas, Size size) {
    final rasterKlein = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 0.4;

    final rasterGroot = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 0.8;

    for (double x = 0; x <= size.width; x += 10) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), rasterKlein);
    }

    for (double y = 0; y <= size.height; y += 10) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rasterKlein);
    }

    for (double x = 0; x <= size.width; x += 100) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), rasterGroot);
    }

    for (double y = 0; y <= size.height; y += 100) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rasterGroot);
    }
  }

  void _tekenKader(Canvas canvas, Rect buiten, Rect binnen) {
    final kaderVulling = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    final kaderLijn = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final verstekLijn = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 1;

    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(buiten)
      ..addRect(binnen);

    canvas.drawPath(path, kaderVulling);

    canvas.drawRect(buiten, kaderLijn);
    canvas.drawRect(binnen, kaderLijn);

    canvas.drawLine(buiten.topLeft, binnen.topLeft, verstekLijn);
    canvas.drawLine(buiten.topRight, binnen.topRight, verstekLijn);
    canvas.drawLine(buiten.bottomLeft, binnen.bottomLeft, verstekLijn);
    canvas.drawLine(buiten.bottomRight, binnen.bottomRight, verstekLijn);
  }

  void _tekenMaatvoeringPerKader({
    required Canvas canvas,
    required Size size,
    required Rect tekenGebied,
    required OpmetingKaderSamenstelling samenstelling,
  }) {
    final weergave = OpmetingKaderSamenstellingTekenHelper.berekenWeergave(
      tekenGebied: tekenGebied,
      samenstelling: samenstelling,
    );

    if (weergave.layout.isLeeg) {
      return;
    }

    final gebruikteBreedteSleutels = <String>{};
    final gebruikteHoogteSleutels = <String>{};

    final kadersMetVerticaleTStijlen = <String>[];
    final kadersMetHorizontaleTStijlen = <String>[];

    for (final kader in weergave.layout.kaders) {
      if (_tStijlBreedtePositiesMmVoorKader(
        size: size,
        kader: kader,
      ).isNotEmpty) {
        kadersMetVerticaleTStijlen.add(kader.id);
      }

      if (_tStijlHoogtePositiesMmVoorKader(
        size: size,
        kader: kader,
      ).isNotEmpty) {
        kadersMetHorizontaleTStijlen.add(kader.id);
      }
    }

    final tStijlBreedteY = tekenGebied.bottom + 14;
    final kaderBreedteY =
        tekenGebied.bottom + (kadersMetVerticaleTStijlen.isNotEmpty ? 38 : 18);
    final totaleBreedteY = kaderBreedteY + 28;

    final tStijlHoogteXPerKader = <String, double>{};
    var huidigeTStijlHoogteX = tekenGebied.right + 14;

    for (final kaderId in kadersMetHorizontaleTStijlen) {
      tStijlHoogteXPerKader[kaderId] = huidigeTStijlHoogteX;
      huidigeTStijlHoogteX += 24;
    }

    final kaderHoogteX =
        tekenGebied.right +
        (kadersMetHorizontaleTStijlen.isNotEmpty
            ? 14 + (kadersMetHorizontaleTStijlen.length * 24) + 18
            : 18);
    final totaleHoogteX = kaderHoogteX + 30;

    for (final kader in weergave.layout.kaders) {
      final rect = weergave.rectVoorKaderId(kader.id);

      if (rect == null || rect.width <= 0 || rect.height <= 0) {
        continue;
      }

      _tekenTStijlBreedtematenVoorKaderBuiten(
        canvas: canvas,
        size: size,
        rect: rect,
        buitenSamenstelling: tekenGebied,
        kader: kader,
        maatLijnY: tStijlBreedteY,
      );

      final breedteSleutel =
          '${rect.left.round()}_${rect.right.round()}_${kader.breedteMm}';

      if (gebruikteBreedteSleutels.add(breedteSleutel)) {
        _tekenKaderBreedtemaatBuiten(
          canvas: canvas,
          rect: rect,
          buitenSamenstelling: tekenGebied,
          maatLijnY: kaderBreedteY,
          breedteMm: kader.breedteMm,
        );
      }

      final tStijlHoogteX = tStijlHoogteXPerKader[kader.id];

      if (tStijlHoogteX != null) {
        _tekenTStijlHoogtematenVoorKaderBuiten(
          canvas: canvas,
          size: size,
          rect: rect,
          buitenSamenstelling: tekenGebied,
          kader: kader,
          maatLijnX: tStijlHoogteX,
        );
      }

      final hoogteIsGelijkAanTotaleHoogte =
          (kader.bovenMm - weergave.layout.minYMm).abs() <= 1 &&
          (kader.onderMm - weergave.layout.maxYMm).abs() <= 1 &&
          kader.hoogteMm == weergave.layout.hoogteMm;

      final hoogteSleutel =
          '${rect.top.round()}_${rect.bottom.round()}_${kader.hoogteMm}';

      if (!hoogteIsGelijkAanTotaleHoogte &&
          gebruikteHoogteSleutels.add(hoogteSleutel)) {
        _tekenKaderHoogtemaatBuiten(
          canvas: canvas,
          rect: rect,
          buitenSamenstelling: tekenGebied,
          maatLijnX: kaderHoogteX,
          hoogteMm: kader.hoogteMm,
        );
      }
    }

    _tekenTotaleBreedtemaat(
      canvas: canvas,
      buiten: tekenGebied,
      maatLijnY: totaleBreedteY,
      maatBreedteMm: weergave.layout.breedteMm,
    );

    _tekenTotaleHoogtemaat(
      canvas: canvas,
      buiten: tekenGebied,
      maatLijnX: totaleHoogteX,
      maatHoogteMm: weergave.layout.hoogteMm,
    );
  }

  void _tekenKaderBreedtemaatBuiten({
    required Canvas canvas,
    required Rect rect,
    required Rect buitenSamenstelling,
    required double maatLijnY,
    required int breedteMm,
  }) {
    final hulplijnPaint = Paint()
      ..color = _maatKleur
      ..strokeWidth = 0.65
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(rect.left, buitenSamenstelling.bottom + 2),
      Offset(rect.left, maatLijnY + 5),
      hulplijnPaint,
    );

    canvas.drawLine(
      Offset(rect.right, buitenSamenstelling.bottom + 2),
      Offset(rect.right, maatLijnY + 5),
      hulplijnPaint,
    );

    _tekenHorizontaleMaat(
      canvas: canvas,
      startX: rect.left,
      eindeX: rect.right,
      y: maatLijnY,
      tekst: '$breedteMm',
      buitenmaat: false,
    );
  }

  void _tekenKaderHoogtemaatBuiten({
    required Canvas canvas,
    required Rect rect,
    required Rect buitenSamenstelling,
    required double maatLijnX,
    required int hoogteMm,
  }) {
    final hulplijnPaint = Paint()
      ..color = _maatKleur
      ..strokeWidth = 0.65
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(buitenSamenstelling.right + 2, rect.top),
      Offset(maatLijnX + 5, rect.top),
      hulplijnPaint,
    );

    canvas.drawLine(
      Offset(buitenSamenstelling.right + 2, rect.bottom),
      Offset(maatLijnX + 5, rect.bottom),
      hulplijnPaint,
    );

    _tekenVerticaleMaat(
      canvas: canvas,
      startY: rect.top,
      eindeY: rect.bottom,
      x: maatLijnX,
      tekst: '$hoogteMm',
      buitenmaat: false,
    );
  }

  void _tekenTStijlBreedtematenVoorKaderBuiten({
    required Canvas canvas,
    required Size size,
    required Rect rect,
    required Rect buitenSamenstelling,
    required OpmetingKaderDeel kader,
    required double maatLijnY,
  }) {
    final positiesMm = _tStijlBreedtePositiesMmVoorKader(
      size: size,
      kader: kader,
    );

    if (positiesMm.isEmpty) {
      return;
    }

    _tekenHorizontaleMaatkettingMm(
      canvas: canvas,
      rect: rect,
      buitenSamenstelling: buitenSamenstelling,
      positiesMm: positiesMm,
      maatLijnY: maatLijnY,
      totaleMaatMm: kader.breedteMm,
    );
  }

  void _tekenTStijlHoogtematenVoorKaderBuiten({
    required Canvas canvas,
    required Size size,
    required Rect rect,
    required Rect buitenSamenstelling,
    required OpmetingKaderDeel kader,
    required double maatLijnX,
  }) {
    final positiesMm = _tStijlHoogtePositiesMmVoorKader(
      size: size,
      kader: kader,
    );

    if (positiesMm.isEmpty) {
      return;
    }

    _tekenVerticaleMaatkettingMm(
      canvas: canvas,
      rect: rect,
      buitenSamenstelling: buitenSamenstelling,
      positiesMm: positiesMm,
      maatLijnX: maatLijnX,
      totaleMaatMm: kader.hoogteMm,
    );
  }

  List<int> _tStijlBreedtePositiesMmVoorKader({
    required Size size,
    required OpmetingKaderDeel kader,
  }) {
    final stijlen = _tStijlenVoorMaatvoeringKader(kader.id);
    final bron = _kaderBronBuitenVoorMaatvoering(size: size, kader: kader);

    final posities = <int>[];

    for (final stijl in stijlen) {
      if (stijl.werkvlakId != 'kader' || stijl.richting != 'verticaal') {
        continue;
      }

      if (bron.width <= 0 || kader.breedteMm <= 0) {
        continue;
      }

      final positieMm =
          ((stijl.start.dx - bron.left) / bron.width * kader.breedteMm).round();

      if (positieMm <= 1 || positieMm >= kader.breedteMm - 1) {
        continue;
      }

      posities.add(positieMm);
    }

    return _uniekeGesorteerdeMmWaarden(posities);
  }

  List<int> _tStijlHoogtePositiesMmVoorKader({
    required Size size,
    required OpmetingKaderDeel kader,
  }) {
    final stijlen = _tStijlenVoorMaatvoeringKader(kader.id);
    final bron = _kaderBronBuitenVoorMaatvoering(size: size, kader: kader);

    final posities = <int>[];

    for (final stijl in stijlen) {
      if (stijl.werkvlakId != 'kader' || stijl.richting != 'horizontaal') {
        continue;
      }

      if (bron.height <= 0 || kader.hoogteMm <= 0) {
        continue;
      }

      final positieMm =
          ((stijl.start.dy - bron.top) / bron.height * kader.hoogteMm).round();

      if (positieMm <= 1 || positieMm >= kader.hoogteMm - 1) {
        continue;
      }

      posities.add(positieMm);
    }

    return _uniekeGesorteerdeMmWaarden(posities);
  }

  List<int> _uniekeGesorteerdeMmWaarden(List<int> waarden) {
    final gesorteerd = <int>[...waarden]..sort();
    final uniek = <int>[];

    for (final waarde in gesorteerd) {
      if (uniek.isEmpty || (waarde - uniek.last).abs() > 2) {
        uniek.add(waarde);
      }
    }

    return uniek;
  }

  void _tekenHorizontaleMaatkettingMm({
    required Canvas canvas,
    required Rect rect,
    required Rect buitenSamenstelling,
    required List<int> positiesMm,
    required double maatLijnY,
    required int totaleMaatMm,
  }) {
    if (totaleMaatMm <= 0 || rect.width <= 0) {
      return;
    }

    final puntenMm = <int>{0, ...positiesMm, totaleMaatMm}.toList()..sort();

    if (puntenMm.length < 2) {
      return;
    }

    final hulplijnPaint = Paint()
      ..color = _maatKleur
      ..strokeWidth = 0.75
      ..style = PaintingStyle.stroke;

    double xVoorMm(int mm) {
      return rect.left + (rect.width * (mm / totaleMaatMm));
    }

    for (final mm in puntenMm) {
      final x = xVoorMm(mm);

      canvas.drawLine(
        Offset(x, buitenSamenstelling.bottom + 2),
        Offset(x, maatLijnY + 5),
        hulplijnPaint,
      );
    }

    for (var index = 0; index < puntenMm.length - 1; index++) {
      final startMm = puntenMm[index];
      final eindeMm = puntenMm[index + 1];
      final maatMm = eindeMm - startMm;

      if (maatMm <= 0) {
        continue;
      }

      _tekenHorizontaleMaat(
        canvas: canvas,
        startX: xVoorMm(startMm),
        eindeX: xVoorMm(eindeMm),
        y: maatLijnY,
        tekst: '$maatMm',
        buitenmaat: false,
      );
    }
  }

  void _tekenVerticaleMaatkettingMm({
    required Canvas canvas,
    required Rect rect,
    required Rect buitenSamenstelling,
    required List<int> positiesMm,
    required double maatLijnX,
    required int totaleMaatMm,
  }) {
    if (totaleMaatMm <= 0 || rect.height <= 0) {
      return;
    }

    final puntenMm = <int>{0, ...positiesMm, totaleMaatMm}.toList()..sort();

    if (puntenMm.length < 2) {
      return;
    }

    final hulplijnPaint = Paint()
      ..color = _maatKleur
      ..strokeWidth = 0.75
      ..style = PaintingStyle.stroke;

    double yVoorMm(int mm) {
      return rect.top + (rect.height * (mm / totaleMaatMm));
    }

    for (final mm in puntenMm) {
      final y = yVoorMm(mm);

      canvas.drawLine(
        Offset(buitenSamenstelling.right + 2, y),
        Offset(maatLijnX + 5, y),
        hulplijnPaint,
      );
    }

    for (var index = 0; index < puntenMm.length - 1; index++) {
      final startMm = puntenMm[index];
      final eindeMm = puntenMm[index + 1];
      final maatMm = eindeMm - startMm;

      if (maatMm <= 0) {
        continue;
      }

      _tekenVerticaleMaat(
        canvas: canvas,
        startY: yVoorMm(startMm),
        eindeY: yVoorMm(eindeMm),
        x: maatLijnX,
        tekst: '$maatMm',
        buitenmaat: false,
      );
    }
  }

  List<OpmetingRaamTStijl> _tStijlenVoorMaatvoeringKader(String kaderId) {
    if (kaderId == (actiefKaderId ?? kaderSamenstelling?.actiefKaderId)) {
      return tStijlen;
    }

    return tStijlenPerKader[kaderId] ?? const <OpmetingRaamTStijl>[];
  }

  Rect _kaderBronBuitenVoorMaatvoering({
    required Size size,
    required OpmetingKaderDeel kader,
  }) {
    return OpmetingRaamKaderHelper.buitenKader(
      size: size,
      breedteMm: kader.breedteMm,
      hoogteMm: kader.hoogteMm,
    );
  }

  void _tekenMaatvoering({
    required Canvas canvas,
    required Rect buiten,
    required int maatBreedteMm,
    required int maatHoogteMm,
    required bool toonTStijlKetting,
  }) {
    final verticaleTStijlPosities = <double>[];
    final horizontaleTStijlPosities = <double>[];

    if (toonTStijlKetting) {
      for (final stijl in tStijlen) {
        if (stijl.werkvlakId != 'kader') {
          continue;
        }

        if (stijl.richting == 'verticaal') {
          final x = stijl.start.dx;

          if (x > buiten.left + 1 && x < buiten.right - 1) {
            verticaleTStijlPosities.add(x);
          }
        } else if (stijl.richting == 'horizontaal') {
          final y = stijl.start.dy;

          if (y > buiten.top + 1 && y < buiten.bottom - 1) {
            horizontaleTStijlPosities.add(y);
          }
        }
      }
    }

    final uniekeVerticalePosities = _uniekeGesorteerdeWaarden(
      verticaleTStijlPosities,
    );

    final uniekeHorizontalePosities = _uniekeGesorteerdeWaarden(
      horizontaleTStijlPosities,
    );

    final heeftBreedteKetting = uniekeVerticalePosities.isNotEmpty;
    final heeftHoogteKetting = uniekeHorizontalePosities.isNotEmpty;

    if (heeftBreedteKetting) {
      _tekenHorizontaleMaatketting(
        canvas: canvas,
        buiten: buiten,
        tStijlPosities: uniekeVerticalePosities,
        maatLijnY: buiten.bottom + 14,
        maatBreedteMm: maatBreedteMm,
      );
    }

    if (heeftHoogteKetting) {
      _tekenVerticaleMaatketting(
        canvas: canvas,
        buiten: buiten,
        tStijlPosities: uniekeHorizontalePosities,
        maatLijnX: buiten.right + 14,
        maatHoogteMm: maatHoogteMm,
      );
    }

    _tekenTotaleBreedtemaat(
      canvas: canvas,
      buiten: buiten,
      maatLijnY: buiten.bottom + (heeftBreedteKetting ? 42 : 28),
      maatBreedteMm: maatBreedteMm,
    );

    _tekenTotaleHoogtemaat(
      canvas: canvas,
      buiten: buiten,
      maatLijnX: buiten.right + (heeftHoogteKetting ? 44 : 28),
      maatHoogteMm: maatHoogteMm,
    );
  }

  List<double> _uniekeGesorteerdeWaarden(List<double> waarden) {
    final gesorteerd = <double>[...waarden]..sort();

    final uniek = <double>[];

    for (final waarde in gesorteerd) {
      if (uniek.isEmpty || (waarde - uniek.last).abs() > 2) {
        uniek.add(waarde);
      }
    }

    return uniek;
  }

  void _tekenHorizontaleMaatketting({
    required Canvas canvas,
    required Rect buiten,
    required List<double> tStijlPosities,
    required double maatLijnY,
    required int maatBreedteMm,
  }) {
    final punten = <double>[buiten.left, ...tStijlPosities, buiten.right]
      ..sort();

    final hulplijnPaint = Paint()
      ..color = _maatKleur
      ..strokeWidth = 0.75
      ..style = PaintingStyle.stroke;

    for (final x in punten) {
      canvas.drawLine(
        Offset(x, buiten.bottom + 2),
        Offset(x, maatLijnY + 5),
        hulplijnPaint,
      );
    }

    for (var index = 0; index < punten.length - 1; index++) {
      final startX = punten[index];
      final eindeX = punten[index + 1];

      if (eindeX - startX < 1) {
        continue;
      }

      final maatMm = ((eindeX - startX) / buiten.width * maatBreedteMm).round();

      _tekenHorizontaleMaat(
        canvas: canvas,
        startX: startX,
        eindeX: eindeX,
        y: maatLijnY,
        tekst: '$maatMm',
        buitenmaat: false,
      );
    }
  }

  void _tekenVerticaleMaatketting({
    required Canvas canvas,
    required Rect buiten,
    required List<double> tStijlPosities,
    required double maatLijnX,
    required int maatHoogteMm,
  }) {
    final punten = <double>[buiten.top, ...tStijlPosities, buiten.bottom]
      ..sort();

    final hulplijnPaint = Paint()
      ..color = _maatKleur
      ..strokeWidth = 0.75
      ..style = PaintingStyle.stroke;

    for (final y in punten) {
      canvas.drawLine(
        Offset(buiten.right + 2, y),
        Offset(maatLijnX + 5, y),
        hulplijnPaint,
      );
    }

    for (var index = 0; index < punten.length - 1; index++) {
      final startY = punten[index];
      final eindeY = punten[index + 1];

      if (eindeY - startY < 1) {
        continue;
      }

      final maatMm = ((eindeY - startY) / buiten.height * maatHoogteMm).round();

      _tekenVerticaleMaat(
        canvas: canvas,
        startY: startY,
        eindeY: eindeY,
        x: maatLijnX,
        tekst: '$maatMm',
        buitenmaat: false,
      );
    }
  }

  void _tekenTotaleBreedtemaat({
    required Canvas canvas,
    required Rect buiten,
    required double maatLijnY,
    required int maatBreedteMm,
  }) {
    final hulplijnPaint = Paint()
      ..color = _maatKleur
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(buiten.left, buiten.bottom + 2),
      Offset(buiten.left, maatLijnY + 6),
      hulplijnPaint,
    );

    canvas.drawLine(
      Offset(buiten.right, buiten.bottom + 2),
      Offset(buiten.right, maatLijnY + 6),
      hulplijnPaint,
    );

    _tekenHorizontaleMaat(
      canvas: canvas,
      startX: buiten.left,
      eindeX: buiten.right,
      y: maatLijnY,
      tekst: '$maatBreedteMm mm',
      buitenmaat: true,
    );
  }

  void _tekenTotaleHoogtemaat({
    required Canvas canvas,
    required Rect buiten,
    required double maatLijnX,
    required int maatHoogteMm,
  }) {
    final hulplijnPaint = Paint()
      ..color = _maatKleur
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(buiten.right + 2, buiten.top),
      Offset(maatLijnX + 6, buiten.top),
      hulplijnPaint,
    );

    canvas.drawLine(
      Offset(buiten.right + 2, buiten.bottom),
      Offset(maatLijnX + 6, buiten.bottom),
      hulplijnPaint,
    );

    _tekenVerticaleMaat(
      canvas: canvas,
      startY: buiten.top,
      eindeY: buiten.bottom,
      x: maatLijnX,
      tekst: '$maatHoogteMm mm',
      buitenmaat: true,
    );
  }

  void _tekenHorizontaleMaat({
    required Canvas canvas,
    required double startX,
    required double eindeX,
    required double y,
    required String tekst,
    required bool buitenmaat,
  }) {
    final lijnPaint = Paint()
      ..color = _maatKleur
      ..strokeWidth = buitenmaat ? 1 : 0.8
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(startX, y), Offset(eindeX, y), lijnPaint);

    final lengte = (eindeX - startX).abs();
    final pijlBinnen = lengte >= 16;
    final pijlGrootte = buitenmaat ? 5.5 : 4.5;

    _tekenHorizontalePijlpunt(
      canvas: canvas,
      punt: Offset(startX, y),
      isLinkerPunt: true,
      pijlBinnen: pijlBinnen,
      grootte: pijlGrootte,
    );

    _tekenHorizontalePijlpunt(
      canvas: canvas,
      punt: Offset(eindeX, y),
      isLinkerPunt: false,
      pijlBinnen: pijlBinnen,
      grootte: pijlGrootte,
    );

    final style = TextStyle(
      color: _maatKleur,
      fontSize: buitenmaat ? 11 : 9,
      fontWeight: buitenmaat ? FontWeight.w800 : FontWeight.w600,
    );

    final painter = _maakTekstPainter(tekst: tekst, style: style);

    final middenX = (startX + eindeX) / 2;
    final beschikbareBreedte = lengte - 12;

    if (painter.width <= beschikbareBreedte || buitenmaat) {
      _tekenTekstMetAchtergrond(
        canvas: canvas,
        painter: painter,
        midden: Offset(middenX, y),
      );
    } else {
      _tekenGedraaideTekstMetAchtergrond(
        canvas: canvas,
        painter: painter,
        midden: Offset(middenX, y),
        hoek: -_kwartDraai,
      );
    }
  }

  void _tekenVerticaleMaat({
    required Canvas canvas,
    required double startY,
    required double eindeY,
    required double x,
    required String tekst,
    required bool buitenmaat,
  }) {
    final lijnPaint = Paint()
      ..color = _maatKleur
      ..strokeWidth = buitenmaat ? 1 : 0.8
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(x, startY), Offset(x, eindeY), lijnPaint);

    final lengte = (eindeY - startY).abs();
    final pijlBinnen = lengte >= 16;
    final pijlGrootte = buitenmaat ? 5.5 : 4.5;

    _tekenVerticalePijlpunt(
      canvas: canvas,
      punt: Offset(x, startY),
      isBovenstePunt: true,
      pijlBinnen: pijlBinnen,
      grootte: pijlGrootte,
    );

    _tekenVerticalePijlpunt(
      canvas: canvas,
      punt: Offset(x, eindeY),
      isBovenstePunt: false,
      pijlBinnen: pijlBinnen,
      grootte: pijlGrootte,
    );

    final style = TextStyle(
      color: _maatKleur,
      fontSize: buitenmaat ? 11 : 9,
      fontWeight: buitenmaat ? FontWeight.w800 : FontWeight.w600,
    );

    final painter = _maakTekstPainter(tekst: tekst, style: style);

    final middenY = (startY + eindeY) / 2;
    final beschikbareHoogte = lengte - 12;

    if (painter.width <= beschikbareHoogte || buitenmaat) {
      _tekenGedraaideTekstMetAchtergrond(
        canvas: canvas,
        painter: painter,
        midden: Offset(x, middenY),
        hoek: -_kwartDraai,
      );
    } else {
      _tekenTekstMetAchtergrond(
        canvas: canvas,
        painter: painter,
        midden: Offset(x, middenY),
      );
    }
  }

  void _tekenHorizontalePijlpunt({
    required Canvas canvas,
    required Offset punt,
    required bool isLinkerPunt,
    required bool pijlBinnen,
    required double grootte,
  }) {
    final richting = isLinkerPunt
        ? (pijlBinnen ? 1.0 : -1.0)
        : (pijlBinnen ? -1.0 : 1.0);

    final path = Path()
      ..moveTo(punt.dx, punt.dy)
      ..lineTo(punt.dx + richting * grootte, punt.dy - grootte * 0.45)
      ..lineTo(punt.dx + richting * grootte, punt.dy + grootte * 0.45)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = _maatKleur
        ..style = PaintingStyle.fill,
    );
  }

  void _tekenVerticalePijlpunt({
    required Canvas canvas,
    required Offset punt,
    required bool isBovenstePunt,
    required bool pijlBinnen,
    required double grootte,
  }) {
    final richting = isBovenstePunt
        ? (pijlBinnen ? 1.0 : -1.0)
        : (pijlBinnen ? -1.0 : 1.0);

    final path = Path()
      ..moveTo(punt.dx, punt.dy)
      ..lineTo(punt.dx - grootte * 0.45, punt.dy + richting * grootte)
      ..lineTo(punt.dx + grootte * 0.45, punt.dy + richting * grootte)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = _maatKleur
        ..style = PaintingStyle.fill,
    );
  }

  TextPainter _maakTekstPainter({
    required String tekst,
    required TextStyle style,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: tekst, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    painter.layout();

    return painter;
  }

  void _tekenTekstMetAchtergrond({
    required Canvas canvas,
    required TextPainter painter,
    required Offset midden,
  }) {
    final tekstRect = Rect.fromCenter(
      center: midden,
      width: painter.width + 6,
      height: painter.height + 2,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(tekstRect, const Radius.circular(2)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.96)
        ..style = PaintingStyle.fill,
    );

    painter.paint(
      canvas,
      Offset(midden.dx - painter.width / 2, midden.dy - painter.height / 2),
    );
  }

  void _tekenGedraaideTekstMetAchtergrond({
    required Canvas canvas,
    required TextPainter painter,
    required Offset midden,
    required double hoek,
  }) {
    canvas.save();

    canvas.translate(midden.dx, midden.dy);
    canvas.rotate(hoek);

    final tekstRect = Rect.fromCenter(
      center: Offset.zero,
      width: painter.width + 6,
      height: painter.height + 2,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(tekstRect, const Radius.circular(2)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.96)
        ..style = PaintingStyle.fill,
    );

    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant OpmetingRaamTekenvlakPainter oldDelegate) {
    return breedteMm != oldDelegate.breedteMm ||
        hoogteMm != oldDelegate.hoogteMm ||
        geselecteerdeLijn != oldDelegate.geselecteerdeLijn ||
        previewPunt != oldDelegate.previewPunt ||
        !identical(tStijlen, oldDelegate.tStijlen) ||
        !identical(tStijlenPerKader, oldDelegate.tStijlenPerKader) ||
        !identical(vleugels, oldDelegate.vleugels) ||
        !identical(vleugelsPerKader, oldDelegate.vleugelsPerKader) ||
        !identical(vulvlakken, oldDelegate.vulvlakken) ||
        !identical(vulvlakkenPerKader, oldDelegate.vulvlakkenPerKader) ||
        !identical(vullingToewijzingen, oldDelegate.vullingToewijzingen) ||
        !identical(
          vullingToewijzingenPerKader,
          oldDelegate.vullingToewijzingenPerKader,
        ) ||
        !identical(
          geselecteerdeVulvlakIds,
          oldDelegate.geselecteerdeVulvlakIds,
        ) ||
        !identical(
          geselecteerdeVulvlakIdsPerKader,
          oldDelegate.geselecteerdeVulvlakIdsPerKader,
        ) ||
        !identical(kleinhouten, oldDelegate.kleinhouten) ||
        !identical(kleinhoutenPerKader, oldDelegate.kleinhoutenPerKader) ||
        !identical(
          geselecteerdeKleinhoutVlakIds,
          oldDelegate.geselecteerdeKleinhoutVlakIds,
        ) ||
        !identical(
          geselecteerdeKleinhoutVlakIdsPerKader,
          oldDelegate.geselecteerdeKleinhoutVlakIdsPerKader,
        ) ||
        !identical(technischeTekeningen, oldDelegate.technischeTekeningen) ||
        !identical(
          technischeTekeningenPerKader,
          oldDelegate.technischeTekeningenPerKader,
        ) ||
        !identical(
          technischeTekeningenPerKaderGroep,
          oldDelegate.technischeTekeningenPerKaderGroep,
        ) ||
        !identical(
          technischeKaderGroepen,
          oldDelegate.technischeKaderGroepen,
        ) ||
        !identical(geselecteerdeKaderIds, oldDelegate.geselecteerdeKaderIds) ||
        !identical(kaderSamenstelling, oldDelegate.kaderSamenstelling) ||
        actiefKaderId != oldDelegate.actiefKaderId;
  }
}
