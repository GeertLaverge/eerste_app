import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'opmeting_raam_model.dart';
import 'opmeting_raam_tstijl_helper.dart';

class OpmetingRaamVlakHelper {
  const OpmetingRaamVlakHelper._();

  /// Tolerantie in werkelijke millimeters.
  ///
  /// Deze wordt per tekenvlak omgerekend naar pixels zodat
  /// dezelfde raamtekening bij iedere schermgrootte op
  /// dezelfde manier wordt verdeeld.
  static const double _tolerantieMm = 2;

  /// Een vlak moet minstens deze werkelijke maat hebben.
  ///
  /// Dit was vroeger 20 schermpixels. Daardoor kon een vlak
  /// bij het draaien van de iPad plots verdwijnen.
  static const double _minimaleVlakmaatMm = 20;

  static const double _sorteerEpsilon = 0.0000001;

  static List<Rect> bepaalVlakken({
    required Rect binnenKader,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
    required List<OpmetingRaamTStijl> tStijlen,
  }) {
    if (!_isGeldigVlak(binnenKader) ||
        !_isGeldigVlak(buitenKader) ||
        breedteMm <= 0 ||
        hoogteMm <= 0) {
      return <Rect>[];
    }

    if (tStijlen.isEmpty) {
      return <Rect>[binnenKader];
    }

    final pixelsPerMmX = buitenKader.width / breedteMm;

    final pixelsPerMmY = buitenKader.height / hoogteMm;

    if (!pixelsPerMmX.isFinite ||
        !pixelsPerMmY.isFinite ||
        pixelsPerMmX <= 0 ||
        pixelsPerMmY <= 0) {
      return <Rect>[];
    }

    final tolerantieX = math.max(0.1, pixelsPerMmX * _tolerantieMm);

    final tolerantieY = math.max(0.1, pixelsPerMmY * _tolerantieMm);

    final minimaleBreedtePx = math.max(0.1, pixelsPerMmX * _minimaleVlakmaatMm);

    final minimaleHoogtePx = math.max(0.1, pixelsPerMmY * _minimaleVlakmaatMm);

    var vlakken = <Rect>[binnenKader];

    final nietVerwerkteStijlen = <int>{
      for (var index = 0; index < tStijlen.length; index++) index,
    };

    var vooruitgangGemaakt = true;

    while (vooruitgangGemaakt && nietVerwerkteStijlen.isNotEmpty) {
      vooruitgangGemaakt = false;

      final huidigeIndexen = nietVerwerkteStijlen.toList();

      for (final index in huidigeIndexen) {
        final stijl = tStijlen[index];

        final profiel = OpmetingRaamTStijlHelper.profielRect(
          stijl: stijl,
          buitenKader: buitenKader,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
        );

        if (!_isGeldigVlak(profiel)) {
          continue;
        }

        final resultaat = _verdeelVlakkenMetStijl(
          vlakken: vlakken,
          profiel: profiel,
          richting: stijl.richting,
          tolerantieX: tolerantieX,
          tolerantieY: tolerantieY,
          minimaleBreedtePx: minimaleBreedtePx,
          minimaleHoogtePx: minimaleHoogtePx,
        );

        if (!resultaat.isGesplitst) {
          continue;
        }

        vlakken = resultaat.vlakken;
        nietVerwerkteStijlen.remove(index);
        vooruitgangGemaakt = true;
      }
    }

    final resultaat = vlakken
        .where(
          (vlak) => _isBruikbaarVlak(
            vlak,
            minimaleBreedtePx: minimaleBreedtePx,
            minimaleHoogtePx: minimaleHoogtePx,
          ),
        )
        .toList();

    /*
     * Sorteren gebeurt relatief binnen het binnenkader.
     *
     * Daardoor blijft de volgorde dezelfde wanneer het
     * raamblok groter, kleiner, liggend of staand wordt.
     * Dit houdt ook de vlak-ID's stabiel:
     *
     * kader_vlak_0
     * kader_vlak_1
     * vleugel_x_vlak_0
     */
    resultaat.sort((eerste, tweede) {
      return _vergelijkVlakkenStabiel(
        eerste: eerste,
        tweede: tweede,
        referentie: binnenKader,
      );
    });

    return resultaat;
  }

  static _VlakVerdelingResultaat _verdeelVlakkenMetStijl({
    required List<Rect> vlakken,
    required Rect profiel,
    required String richting,
    required double tolerantieX,
    required double tolerantieY,
    required double minimaleBreedtePx,
    required double minimaleHoogtePx,
  }) {
    final nieuweVlakken = <Rect>[];
    var isGesplitst = false;

    for (final vlak in vlakken) {
      if (richting == 'verticaal' &&
          _profielVerdeeltVlakVerticaal(
            profiel: profiel,
            vlak: vlak,
            tolerantieX: tolerantieX,
            tolerantieY: tolerantieY,
            minimaleBreedtePx: minimaleBreedtePx,
          )) {
        final linkerVlak = Rect.fromLTRB(
          vlak.left,
          vlak.top,
          profiel.left.clamp(vlak.left, vlak.right).toDouble(),
          vlak.bottom,
        );

        final rechterVlak = Rect.fromLTRB(
          profiel.right.clamp(vlak.left, vlak.right).toDouble(),
          vlak.top,
          vlak.right,
          vlak.bottom,
        );

        if (_isBruikbaarVlak(
              linkerVlak,
              minimaleBreedtePx: minimaleBreedtePx,
              minimaleHoogtePx: minimaleHoogtePx,
            ) &&
            _isBruikbaarVlak(
              rechterVlak,
              minimaleBreedtePx: minimaleBreedtePx,
              minimaleHoogtePx: minimaleHoogtePx,
            )) {
          nieuweVlakken.add(linkerVlak);
          nieuweVlakken.add(rechterVlak);

          isGesplitst = true;
          continue;
        }
      }

      if (richting == 'horizontaal' &&
          _profielVerdeeltVlakHorizontaal(
            profiel: profiel,
            vlak: vlak,
            tolerantieX: tolerantieX,
            tolerantieY: tolerantieY,
            minimaleHoogtePx: minimaleHoogtePx,
          )) {
        final bovensteVlak = Rect.fromLTRB(
          vlak.left,
          vlak.top,
          vlak.right,
          profiel.top.clamp(vlak.top, vlak.bottom).toDouble(),
        );

        final ondersteVlak = Rect.fromLTRB(
          vlak.left,
          profiel.bottom.clamp(vlak.top, vlak.bottom).toDouble(),
          vlak.right,
          vlak.bottom,
        );

        if (_isBruikbaarVlak(
              bovensteVlak,
              minimaleBreedtePx: minimaleBreedtePx,
              minimaleHoogtePx: minimaleHoogtePx,
            ) &&
            _isBruikbaarVlak(
              ondersteVlak,
              minimaleBreedtePx: minimaleBreedtePx,
              minimaleHoogtePx: minimaleHoogtePx,
            )) {
          nieuweVlakken.add(bovensteVlak);
          nieuweVlakken.add(ondersteVlak);

          isGesplitst = true;
          continue;
        }
      }

      nieuweVlakken.add(vlak);
    }

    return _VlakVerdelingResultaat(
      vlakken: nieuweVlakken,
      isGesplitst: isGesplitst,
    );
  }

  static bool _profielVerdeeltVlakVerticaal({
    required Rect profiel,
    required Rect vlak,
    required double tolerantieX,
    required double tolerantieY,
    required double minimaleBreedtePx,
  }) {
    final raaktBovenzijde = profiel.top <= vlak.top + tolerantieY;

    final raaktOnderzijde = profiel.bottom >= vlak.bottom - tolerantieY;

    if (!raaktBovenzijde || !raaktOnderzijde) {
      return false;
    }

    final breedteLinks = profiel.left - vlak.left;

    final breedteRechts = vlak.right - profiel.right;

    if (breedteLinks < minimaleBreedtePx || breedteRechts < minimaleBreedtePx) {
      return false;
    }

    return profiel.right > vlak.left + tolerantieX &&
        profiel.left < vlak.right - tolerantieX;
  }

  static bool _profielVerdeeltVlakHorizontaal({
    required Rect profiel,
    required Rect vlak,
    required double tolerantieX,
    required double tolerantieY,
    required double minimaleHoogtePx,
  }) {
    final raaktLinkerzijde = profiel.left <= vlak.left + tolerantieX;

    final raaktRechterzijde = profiel.right >= vlak.right - tolerantieX;

    if (!raaktLinkerzijde || !raaktRechterzijde) {
      return false;
    }

    final hoogteBoven = profiel.top - vlak.top;

    final hoogteOnder = vlak.bottom - profiel.bottom;

    if (hoogteBoven < minimaleHoogtePx || hoogteOnder < minimaleHoogtePx) {
      return false;
    }

    return profiel.bottom > vlak.top + tolerantieY &&
        profiel.top < vlak.bottom - tolerantieY;
  }

  static int _vergelijkVlakkenStabiel({
    required Rect eerste,
    required Rect tweede,
    required Rect referentie,
  }) {
    final eersteBoven = _normaliseerY(eerste.top, referentie);

    final tweedeBoven = _normaliseerY(tweede.top, referentie);

    final bovenVergelijking = _vergelijkGetal(eersteBoven, tweedeBoven);

    if (bovenVergelijking != 0) {
      return bovenVergelijking;
    }

    final eersteLinks = _normaliseerX(eerste.left, referentie);

    final tweedeLinks = _normaliseerX(tweede.left, referentie);

    final linksVergelijking = _vergelijkGetal(eersteLinks, tweedeLinks);

    if (linksVergelijking != 0) {
      return linksVergelijking;
    }

    final eersteOnder = _normaliseerY(eerste.bottom, referentie);

    final tweedeOnder = _normaliseerY(tweede.bottom, referentie);

    final onderVergelijking = _vergelijkGetal(eersteOnder, tweedeOnder);

    if (onderVergelijking != 0) {
      return onderVergelijking;
    }

    final eersteRechts = _normaliseerX(eerste.right, referentie);

    final tweedeRechts = _normaliseerX(tweede.right, referentie);

    return _vergelijkGetal(eersteRechts, tweedeRechts);
  }

  static int _vergelijkGetal(double eerste, double tweede) {
    final verschil = eerste - tweede;

    if (verschil.abs() <= _sorteerEpsilon) {
      return 0;
    }

    return verschil < 0 ? -1 : 1;
  }

  static double _normaliseerX(double waarde, Rect referentie) {
    if (referentie.width <= 0) {
      return 0;
    }

    return (waarde - referentie.left) / referentie.width;
  }

  static double _normaliseerY(double waarde, Rect referentie) {
    if (referentie.height <= 0) {
      return 0;
    }

    return (waarde - referentie.top) / referentie.height;
  }

  static Rect? vindVlak({required Offset punt, required List<Rect> vlakken}) {
    Rect? gevondenVlak;

    for (final vlak in vlakken) {
      if (!vlak.contains(punt)) {
        continue;
      }

      if (gevondenVlak == null ||
          vlak.width * vlak.height < gevondenVlak.width * gevondenVlak.height) {
        gevondenVlak = vlak;
      }
    }

    return gevondenVlak;
  }

  static bool _isBruikbaarVlak(
    Rect vlak, {
    required double minimaleBreedtePx,
    required double minimaleHoogtePx,
  }) {
    return _isGeldigVlak(vlak) &&
        vlak.width >= minimaleBreedtePx &&
        vlak.height >= minimaleHoogtePx;
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

class _VlakVerdelingResultaat {
  const _VlakVerdelingResultaat({
    required this.vlakken,
    required this.isGesplitst,
  });

  final List<Rect> vlakken;
  final bool isGesplitst;
}
