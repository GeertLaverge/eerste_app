import 'package:flutter/material.dart';

import '../raam/opmeting_raam_model.dart';
import 'opmeting_deurpaneel_model.dart';

class OpmetingDeurpaneelGeometrieHelper {
  const OpmetingDeurpaneelGeometrieHelper._();

  static OpmetingRaamVleugel? vindDeurVleugelVoorPunt({
    required Offset punt,
    required Iterable<OpmetingRaamVleugel> vleugels,
  }) {
    OpmetingRaamVleugel? kleinsteVleugel;
    double? kleinsteOppervlakte;

    for (final vleugel in vleugels) {
      if (!vleugel.isDeurVleugel) {
        continue;
      }

      if (!vleugel.vlak.contains(punt)) {
        continue;
      }

      final oppervlakte = vleugel.vlak.width.abs() * vleugel.vlak.height.abs();

      if (kleinsteVleugel == null ||
          kleinsteOppervlakte == null ||
          oppervlakte < kleinsteOppervlakte) {
        kleinsteVleugel = vleugel;
        kleinsteOppervlakte = oppervlakte;
      }
    }

    return kleinsteVleugel;
  }

  static Rect paneelVlakVoorVleugel({
    required OpmetingRaamVleugel vleugel,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
    required OpmetingDeurpaneelUitvoering uitvoering,
  }) {
    if (uitvoering == OpmetingDeurpaneelUitvoering.vleugelOverdekkend) {
      return deurBuitenVlakVoorVleugel(
        vleugel: vleugel,
        buitenKader: buitenKader,
        hoogteMm: hoogteMm,
      );
    }

    return deurBinnenVlakVoorVleugel(
      vleugel: vleugel,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );
  }

  static Rect deurBuitenVlakVoorVleugel({
    required OpmetingRaamVleugel vleugel,
    required Rect buitenKader,
    required int hoogteMm,
  }) {
    if (hoogteMm <= 0 || !_isGeldigVlak(vleugel.vlak)) {
      return Rect.zero;
    }

    final schaalY = buitenKader.height / hoogteMm;
    final onderAfstandPx = (vleugel.deurVleugelOnderAfstandMm * schaalY)
        .abs()
        .clamp(0.0, buitenKader.height / 4)
        .toDouble();

    final buitenVlak = Rect.fromLTRB(
      vleugel.vlak.left,
      vleugel.vlak.top,
      vleugel.vlak.right,
      buitenKader.bottom - onderAfstandPx,
    );

    return _isGeldigVlak(buitenVlak) ? buitenVlak : Rect.zero;
  }

  static Rect deurBinnenVlakVoorVleugel({
    required OpmetingRaamVleugel vleugel,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
  }) {
    if (breedteMm <= 0 || hoogteMm <= 0) {
      return Rect.zero;
    }

    final buitenVlak = deurBuitenVlakVoorVleugel(
      vleugel: vleugel,
      buitenKader: buitenKader,
      hoogteMm: hoogteMm,
    );

    if (!_isGeldigVlak(buitenVlak)) {
      return Rect.zero;
    }

    final schaalX = buitenKader.width / breedteMm;
    final schaalY = buitenKader.height / hoogteMm;

    final profielBreedteX = (vleugel.deurVleugelBreedteMm * schaalX)
        .abs()
        .clamp(5.0, buitenKader.width / 3)
        .toDouble();

    final profielBreedteY = (vleugel.deurVleugelBreedteMm * schaalY)
        .abs()
        .clamp(5.0, buitenKader.height / 3)
        .toDouble();

    final binnenVlak = Rect.fromLTRB(
      buitenVlak.left + profielBreedteX,
      buitenVlak.top + profielBreedteY,
      buitenVlak.right - profielBreedteX,
      buitenVlak.bottom - profielBreedteY,
    );

    return _isGeldigVlak(binnenVlak) ? binnenVlak : Rect.zero;
  }

  static Offset? cilinderPuntVoorVleugel({
    required OpmetingRaamVleugel vleugel,
    required Rect paneelVlak,
    required Rect buitenKader,
    required int hoogteMm,
  }) {
    if (!_isGeldigVlak(paneelVlak) || hoogteMm <= 0) {
      return null;
    }

    if (!vleugel.isActiefDeurdeelMetKruk) {
      return null;
    }

    final schaalY = buitenKader.height / hoogteMm;
    final krukHoogteVanafOnderPx = (1000 * schaalY).abs();
    final y = (paneelVlak.bottom - krukHoogteVanafOnderPx).clamp(
      paneelVlak.top + 20,
      paneelVlak.bottom - 20,
    );

    final margeX = (paneelVlak.width * 0.16).clamp(18.0, 42.0).toDouble();

    final x = vleugel.deurVleugelKrukZijde == OpmetingRaamKrukZijde.links
        ? paneelVlak.left + margeX
        : paneelVlak.right - margeX;

    return Offset(x, y.toDouble());
  }

  static bool isGeldigVlak(Rect vlak) {
    return _isGeldigVlak(vlak);
  }

  static bool _isGeldigVlak(Rect vlak) {
    return vlak.width.isFinite &&
        vlak.height.isFinite &&
        vlak.width > 4 &&
        vlak.height > 4;
  }
}
