import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'opmeting_raam_keuzemenu_model.dart';

class OpmetingRaamTechnischVlak {
  const OpmetingRaamTechnischVlak({
    required this.rechthoek,
    required this.instelling,
  });

  final Rect rechthoek;
  final OpmetingRaamTechnischeTekeningInstelling instelling;
}

class OpmetingRaamTechnischeLayout {
  const OpmetingRaamTechnischeLayout({
    required this.totaleMaatRect,
    required this.raamKaderRect,
    required this.raamBreedteMm,
    required this.raamHoogteMm,
    required this.technischeVlakken,
  });

  /// De volledige opgegeven raammaat.
  final Rect totaleMaatRect;

  /// Het eigenlijke raamkader nadat de technische vlakken
  /// in de raammaat ervan zijn afgetrokken.
  final Rect raamKaderRect;

  final int raamBreedteMm;
  final int raamHoogteMm;

  final List<OpmetingRaamTechnischVlak> technischeVlakken;

  bool bevatRaamPunt(Offset punt) {
    return raamKaderRect.contains(punt);
  }

  /// Zet een zichtbaar punt in het verkleinde raamkader
  /// terug om naar het bestaande interne coördinatenstelsel.
  Offset naarBasisPunt(Offset zichtbaarPunt) {
    if (raamKaderRect.width <= 0 ||
        raamKaderRect.height <= 0 ||
        totaleMaatRect.width <= 0 ||
        totaleMaatRect.height <= 0) {
      return zichtbaarPunt;
    }

    final horizontaleFractie =
        (zichtbaarPunt.dx - raamKaderRect.left) / raamKaderRect.width;

    final verticaleFractie =
        (zichtbaarPunt.dy - raamKaderRect.top) / raamKaderRect.height;

    return Offset(
      totaleMaatRect.left + horizontaleFractie * totaleMaatRect.width,
      totaleMaatRect.top + verticaleFractie * totaleMaatRect.height,
    );
  }

  /// Zet een bestaand intern punt om naar de zichtbare plaats
  /// in het verkleinde raamkader.
  Offset naarRaamPunt(Offset basisPunt) {
    if (totaleMaatRect.width <= 0 || totaleMaatRect.height <= 0) {
      return basisPunt;
    }

    final horizontaleFractie =
        (basisPunt.dx - totaleMaatRect.left) / totaleMaatRect.width;

    final verticaleFractie =
        (basisPunt.dy - totaleMaatRect.top) / totaleMaatRect.height;

    return Offset(
      raamKaderRect.left + horizontaleFractie * raamKaderRect.width,
      raamKaderRect.top + verticaleFractie * raamKaderRect.height,
    );
  }

  /// Past alleen de bestaande raamtekening aan.
  /// Technische vlakken worden buiten deze transformatie getekend.
  void pasRaamTransformatieToe(Canvas canvas) {
    if (totaleMaatRect.width <= 0 || totaleMaatRect.height <= 0) {
      return;
    }

    final schaalX = raamKaderRect.width / totaleMaatRect.width;

    final schaalY = raamKaderRect.height / totaleMaatRect.height;

    canvas.translate(raamKaderRect.left, raamKaderRect.top);

    canvas.scale(schaalX, schaalY);

    canvas.translate(-totaleMaatRect.left, -totaleMaatRect.top);
  }
}

class OpmetingRaamTechnischeLayoutHelper {
  const OpmetingRaamTechnischeLayoutHelper._();

  static OpmetingRaamTechnischeLayout bereken({
    required Rect totaleMaatRect,
    required int breedteMm,
    required int hoogteMm,
    required List<OpmetingRaamTechnischeTekeningInstelling>
    technischeTekeningen,
  }) {
    if (breedteMm <= 0 ||
        hoogteMm <= 0 ||
        totaleMaatRect.width <= 0 ||
        totaleMaatRect.height <= 0) {
      return OpmetingRaamTechnischeLayout(
        totaleMaatRect: totaleMaatRect,
        raamKaderRect: totaleMaatRect,
        raamBreedteMm: breedteMm,
        raamHoogteMm: hoogteMm,
        technischeVlakken: const <OpmetingRaamTechnischVlak>[],
      );
    }

    final actieveTekeningen = technischeTekeningen
        .where((instelling) => instelling.actief)
        .toList();

    var bovenMm = 0;
    var onderMm = 0;
    var linksMm = 0;
    var rechtsMm = 0;

    /*
     * Alleen technische vlakken "in de raammaat"
     * verminderen het eigenlijke raamkader.
     */
    for (final instelling in actieveTekeningen) {
      if (instelling.maatPlaatsing !=
          OpmetingRaamTechnischeMaatPlaatsing.inDeRaammaat) {
        continue;
      }

      switch (instelling.positie) {
        case OpmetingRaamTechnischePositie.boven:
          bovenMm += _hoogteInMm(instelling, hoogteMm);
          break;

        case OpmetingRaamTechnischePositie.onder:
          onderMm += _hoogteInMm(instelling, hoogteMm);
          break;

        case OpmetingRaamTechnischePositie.links:
          linksMm += _breedteInMm(instelling, breedteMm);
          break;

        case OpmetingRaamTechnischePositie.rechts:
          rechtsMm += _breedteInMm(instelling, breedteMm);
          break;
      }
    }

    /*
     * Er blijft altijd minstens 1 mm raamkader over.
     */
    linksMm = linksMm.clamp(0, math.max(0, breedteMm - 1)).toInt();

    rechtsMm = rechtsMm.clamp(0, math.max(0, breedteMm - linksMm - 1)).toInt();

    bovenMm = bovenMm.clamp(0, math.max(0, hoogteMm - 1)).toInt();

    onderMm = onderMm.clamp(0, math.max(0, hoogteMm - bovenMm - 1)).toInt();

    final pixelsPerMmX = totaleMaatRect.width / breedteMm;

    final pixelsPerMmY = totaleMaatRect.height / hoogteMm;

    final raamKaderRect = Rect.fromLTRB(
      totaleMaatRect.left + linksMm * pixelsPerMmX,
      totaleMaatRect.top + bovenMm * pixelsPerMmY,
      totaleMaatRect.right - rechtsMm * pixelsPerMmX,
      totaleMaatRect.bottom - onderMm * pixelsPerMmY,
    );

    final technischeVlakken = <OpmetingRaamTechnischVlak>[];

    /*
     * Cursors voor meerdere rechthoeken binnen dezelfde
     * opgegeven raammaat.
     *
     * Twee vlakken boven worden bijvoorbeeld onder elkaar
     * geplaatst in de ruimte die van het raamkader is afgetrokken.
     */
    var binnenBovenCursor = totaleMaatRect.top;
    var binnenOnderCursor = totaleMaatRect.bottom;
    var binnenLinksCursor = totaleMaatRect.left;
    var binnenRechtsCursor = totaleMaatRect.right;

    for (final instelling in actieveTekeningen) {
      final inDeRaammaat =
          instelling.maatPlaatsing ==
          OpmetingRaamTechnischeMaatPlaatsing.inDeRaammaat;

      final rechthoek = inDeRaammaat
          ? _berekenBinnenVlak(
              instelling: instelling,
              totaleMaatRect: totaleMaatRect,
              raamKaderRect: raamKaderRect,
              breedteMm: breedteMm,
              hoogteMm: hoogteMm,
              pixelsPerMmX: pixelsPerMmX,
              pixelsPerMmY: pixelsPerMmY,
              bovenCursor: binnenBovenCursor,
              onderCursor: binnenOnderCursor,
              linksCursor: binnenLinksCursor,
              rechtsCursor: binnenRechtsCursor,
            )
          : _berekenBuitenVlak(
              instelling: instelling,
              totaleMaatRect: totaleMaatRect,
              breedteMm: breedteMm,
              hoogteMm: hoogteMm,
              pixelsPerMmX: pixelsPerMmX,
              pixelsPerMmY: pixelsPerMmY,
            );

      if (rechthoek == null || rechthoek.width <= 0 || rechthoek.height <= 0) {
        continue;
      }

      technischeVlakken.add(
        OpmetingRaamTechnischVlak(rechthoek: rechthoek, instelling: instelling),
      );

      /*
       * Alleen de cursors van vlakken in de raammaat
       * worden doorgeschoven.
       *
       * Vlakken buiten de raammaat worden geplaatst volgens
       * hun eigen afstand tot het oorspronkelijke raamkader.
       */
      if (inDeRaammaat) {
        switch (instelling.positie) {
          case OpmetingRaamTechnischePositie.boven:
            binnenBovenCursor = rechthoek.bottom;
            break;

          case OpmetingRaamTechnischePositie.onder:
            binnenOnderCursor = rechthoek.top;
            break;

          case OpmetingRaamTechnischePositie.links:
            binnenLinksCursor = rechthoek.right;
            break;

          case OpmetingRaamTechnischePositie.rechts:
            binnenRechtsCursor = rechthoek.left;
            break;
        }
      }
    }

    return OpmetingRaamTechnischeLayout(
      totaleMaatRect: totaleMaatRect,
      raamKaderRect: raamKaderRect,
      raamBreedteMm: math.max(1, breedteMm - linksMm - rechtsMm),
      raamHoogteMm: math.max(1, hoogteMm - bovenMm - onderMm),
      technischeVlakken: List<OpmetingRaamTechnischVlak>.unmodifiable(
        technischeVlakken,
      ),
    );
  }

  static Rect? _berekenBinnenVlak({
    required OpmetingRaamTechnischeTekeningInstelling instelling,
    required Rect totaleMaatRect,
    required Rect raamKaderRect,
    required int breedteMm,
    required int hoogteMm,
    required double pixelsPerMmX,
    required double pixelsPerMmY,
    required double bovenCursor,
    required double onderCursor,
    required double linksCursor,
    required double rechtsCursor,
  }) {
    final gewensteBreedte = _breedteInPixels(
      instelling: instelling,
      volledigeBreedte: raamKaderRect.width,
      pixelsPerMmX: pixelsPerMmX,
    );

    final gewensteHoogte = _hoogteInPixels(
      instelling: instelling,
      volledigeHoogte: raamKaderRect.height,
      pixelsPerMmY: pixelsPerMmY,
    );

    switch (instelling.positie) {
      case OpmetingRaamTechnischePositie.boven:
        final beschikbareHoogte = raamKaderRect.top - bovenCursor;

        final vlakHoogte = math.min(gewensteHoogte, beschikbareHoogte);

        final vlakBreedte = math.min(gewensteBreedte, totaleMaatRect.width);

        return Rect.fromLTWH(
          raamKaderRect.center.dx - vlakBreedte / 2,
          bovenCursor,
          vlakBreedte,
          vlakHoogte,
        );

      case OpmetingRaamTechnischePositie.onder:
        final beschikbareHoogte = onderCursor - raamKaderRect.bottom;

        final vlakHoogte = math.min(gewensteHoogte, beschikbareHoogte);

        final vlakBreedte = math.min(gewensteBreedte, totaleMaatRect.width);

        return Rect.fromLTWH(
          raamKaderRect.center.dx - vlakBreedte / 2,
          onderCursor - vlakHoogte,
          vlakBreedte,
          vlakHoogte,
        );

      case OpmetingRaamTechnischePositie.links:
        final beschikbareBreedte = raamKaderRect.left - linksCursor;

        final vlakBreedte = math.min(gewensteBreedte, beschikbareBreedte);

        final vlakHoogte = math.min(gewensteHoogte, raamKaderRect.height);

        return Rect.fromLTWH(
          linksCursor,
          raamKaderRect.center.dy - vlakHoogte / 2,
          vlakBreedte,
          vlakHoogte,
        );

      case OpmetingRaamTechnischePositie.rechts:
        final beschikbareBreedte = rechtsCursor - raamKaderRect.right;

        final vlakBreedte = math.min(gewensteBreedte, beschikbareBreedte);

        final vlakHoogte = math.min(gewensteHoogte, raamKaderRect.height);

        return Rect.fromLTWH(
          rechtsCursor - vlakBreedte,
          raamKaderRect.center.dy - vlakHoogte / 2,
          vlakBreedte,
          vlakHoogte,
        );
    }
  }

  static Rect _berekenBuitenVlak({
    required OpmetingRaamTechnischeTekeningInstelling instelling,
    required Rect totaleMaatRect,
    required int breedteMm,
    required int hoogteMm,
    required double pixelsPerMmX,
    required double pixelsPerMmY,
  }) {
    final vlakBreedte = _breedteInPixels(
      instelling: instelling,
      volledigeBreedte: totaleMaatRect.width,
      pixelsPerMmX: pixelsPerMmX,
    );

    final vlakHoogte = _hoogteInPixels(
      instelling: instelling,
      volledigeHoogte: totaleMaatRect.height,
      pixelsPerMmY: pixelsPerMmY,
    );

    /*
     * Positieve afstand:
     * er ontstaat ruimte tussen raamkader en rechthoek.
     *
     * Afstand nul:
     * rechthoek sluit aan tegen het raamkader.
     *
     * Negatieve afstand:
     * rechthoek schuift over het raamkader.
     */
    final afstandXPixels = instelling.afstandMm * pixelsPerMmX;

    final afstandYPixels = instelling.afstandMm * pixelsPerMmY;

    switch (instelling.positie) {
      case OpmetingRaamTechnischePositie.boven:
        return Rect.fromLTWH(
          totaleMaatRect.center.dx - vlakBreedte / 2,
          totaleMaatRect.top - vlakHoogte - afstandYPixels,
          vlakBreedte,
          vlakHoogte,
        );

      case OpmetingRaamTechnischePositie.onder:
        return Rect.fromLTWH(
          totaleMaatRect.center.dx - vlakBreedte / 2,
          totaleMaatRect.bottom + afstandYPixels,
          vlakBreedte,
          vlakHoogte,
        );

      case OpmetingRaamTechnischePositie.links:
        return Rect.fromLTWH(
          totaleMaatRect.left - vlakBreedte - afstandXPixels,
          totaleMaatRect.center.dy - vlakHoogte / 2,
          vlakBreedte,
          vlakHoogte,
        );

      case OpmetingRaamTechnischePositie.rechts:
        return Rect.fromLTWH(
          totaleMaatRect.right + afstandXPixels,
          totaleMaatRect.center.dy - vlakHoogte / 2,
          vlakBreedte,
          vlakHoogte,
        );
    }
  }

  static int _breedteInMm(
    OpmetingRaamTechnischeTekeningInstelling instelling,
    int raamBreedteMm,
  ) {
    if (instelling.breedteKeuze ==
        OpmetingRaamTechnischeMaatKeuze.volledigeRaammaat) {
      return raamBreedteMm;
    }

    return math.max(0, instelling.breedteMm);
  }

  static int _hoogteInMm(
    OpmetingRaamTechnischeTekeningInstelling instelling,
    int raamHoogteMm,
  ) {
    if (instelling.hoogteKeuze ==
        OpmetingRaamTechnischeMaatKeuze.volledigeRaammaat) {
      return raamHoogteMm;
    }

    return math.max(0, instelling.hoogteMm);
  }

  static double _breedteInPixels({
    required OpmetingRaamTechnischeTekeningInstelling instelling,
    required double volledigeBreedte,
    required double pixelsPerMmX,
  }) {
    if (instelling.breedteKeuze ==
        OpmetingRaamTechnischeMaatKeuze.volledigeRaammaat) {
      return volledigeBreedte;
    }

    return math.max(1, instelling.breedteMm * pixelsPerMmX);
  }

  static double _hoogteInPixels({
    required OpmetingRaamTechnischeTekeningInstelling instelling,
    required double volledigeHoogte,
    required double pixelsPerMmY,
  }) {
    if (instelling.hoogteKeuze ==
        OpmetingRaamTechnischeMaatKeuze.volledigeRaammaat) {
      return volledigeHoogte;
    }

    return math.max(1, instelling.hoogteMm * pixelsPerMmY);
  }
}
