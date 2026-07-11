import 'dart:math' as math;

import 'package:flutter/material.dart';

class OpmetingRaamKaderHelper {
  const OpmetingRaamKaderHelper._();

  /// Werkelijke kaderbreedte in millimeter.
  static const double kaderOffsetMm = 70;

  /// Gewenste maximale schermmarge rondom het raam.
  static const double standaardTekenvlakMarge = 70;

  /// Minimale marge zolang het tekenvlak groot genoeg is.
  static const double minimaleTekenvlakMarge = 12;

  static Rect buitenKader({
    required Size size,
    required int breedteMm,
    required int hoogteMm,
  }) {
    if (!_isGeldigeGrootte(size) || breedteMm <= 0 || hoogteMm <= 0) {
      return Rect.zero;
    }

    final kortsteTekenvlakZijde = math.min(size.width, size.height);

    final marge = _berekenTekenvlakMarge(kortsteTekenvlakZijde);

    final maximaleBreedte = size.width - (marge * 2);

    final maximaleHoogte = size.height - (marge * 2);

    if (maximaleBreedte <= 0 || maximaleHoogte <= 0) {
      return Rect.zero;
    }

    /*
     * Er wordt bewust één schaalfactor gebruikt.
     *
     * Daardoor blijft de verhouding van het raam exact
     * behouden bij:
     *
     * - staand naar liggend;
     * - liggend naar staand;
     * - grotere of kleinere kaderafmetingen;
     * - een groter of kleiner tekenvlak.
     */
    final schaalX = maximaleBreedte / breedteMm;

    final schaalY = maximaleHoogte / hoogteMm;

    final schaal = math.min(schaalX, schaalY);

    if (!schaal.isFinite || schaal <= 0) {
      return Rect.zero;
    }

    final kaderBreedte = breedteMm * schaal;

    final kaderHoogte = hoogteMm * schaal;

    final links = (size.width - kaderBreedte) / 2;

    final boven = (size.height - kaderHoogte) / 2;

    return Rect.fromLTWH(links, boven, kaderBreedte, kaderHoogte);
  }

  static Rect binnenKader({
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
  }) {
    if (!_isGeldigVlak(buitenKader) || breedteMm <= 0 || hoogteMm <= 0) {
      return Rect.zero;
    }

    /*
     * BuitenKader gebruikt één uniforme schaalfactor.
     * We nemen hier opnieuw de kleinste schaal zodat de
     * kaderdikte horizontaal en verticaal identiek blijft.
     */
    final pixelsPerMmX = buitenKader.width / breedteMm;

    final pixelsPerMmY = buitenKader.height / hoogteMm;

    final pixelsPerMm = math.min(pixelsPerMmX, pixelsPerMmY);

    if (!pixelsPerMm.isFinite || pixelsPerMm <= 0) {
      return Rect.zero;
    }

    final gewensteOffset = pixelsPerMm * kaderOffsetMm;

    /*
     * De begrenzing voorkomt een omgekeerd binnenkader bij
     * uitzonderlijk kleine testafmetingen.
     */
    final maximaleOffsetX = math.max(0.0, (buitenKader.width / 2) - 0.5);

    final maximaleOffsetY = math.max(0.0, (buitenKader.height / 2) - 0.5);

    final offsetX = math.min(gewensteOffset, maximaleOffsetX);

    final offsetY = math.min(gewensteOffset, maximaleOffsetY);

    final binnenKader = Rect.fromLTRB(
      buitenKader.left + offsetX,
      buitenKader.top + offsetY,
      buitenKader.right - offsetX,
      buitenKader.bottom - offsetY,
    );

    if (!_isGeldigVlak(binnenKader)) {
      return Rect.zero;
    }

    return binnenKader;
  }

  static double _berekenTekenvlakMarge(double kortsteTekenvlakZijde) {
    if (!kortsteTekenvlakZijde.isFinite || kortsteTekenvlakZijde <= 0) {
      return 0;
    }

    /*
     * Op een normaal iPad-tekenvlak blijft de marge 70 px.
     * Op een smaller tekenvlak wordt ze automatisch kleiner,
     * zodat er altijd voldoende ruimte voor het raam overblijft.
     */
    final voorgesteldeMarge = kortsteTekenvlakZijde * 0.10;

    if (kortsteTekenvlakZijde < minimaleTekenvlakMarge * 2) {
      return 0;
    }

    return voorgesteldeMarge
        .clamp(minimaleTekenvlakMarge, standaardTekenvlakMarge)
        .toDouble();
  }

  static bool _isGeldigeGrootte(Size size) {
    return size.width.isFinite &&
        size.height.isFinite &&
        size.width > 0 &&
        size.height > 0;
  }

  static bool _isGeldigVlak(Rect vlak) {
    return vlak.left.isFinite &&
        vlak.top.isFinite &&
        vlak.right.isFinite &&
        vlak.bottom.isFinite &&
        vlak.width > 0 &&
        vlak.height > 0;
  }
}
