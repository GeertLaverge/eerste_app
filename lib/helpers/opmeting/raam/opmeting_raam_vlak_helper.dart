import 'package:flutter/material.dart';

import 'opmeting_raam_model.dart';
import 'opmeting_raam_tstijl_helper.dart';

class OpmetingRaamVlakHelper {
  const OpmetingRaamVlakHelper._();

  static const double _tolerantie = 2;
  static const double _minimaleVlakmaat = 20;

  static List<Rect> bepaalVlakken({
    required Rect binnenKader,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
    required List<OpmetingRaamTStijl> tStijlen,
  }) {
    if (!_isGeldigVlak(binnenKader)) {
      return <Rect>[];
    }

    if (tStijlen.isEmpty) {
      return <Rect>[binnenKader];
    }

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

        final resultaat = _verdeelVlakkenMetStijl(
          vlakken: vlakken,
          profiel: profiel,
          richting: stijl.richting,
        );

        if (!resultaat.isGesplitst) {
          continue;
        }

        vlakken = resultaat.vlakken;
        nietVerwerkteStijlen.remove(index);
        vooruitgangGemaakt = true;
      }
    }

    final resultaat = vlakken.where(_isBruikbaarVlak).toList();

    resultaat.sort((a, b) {
      final verschilBoven = a.top - b.top;

      if (verschilBoven.abs() > _tolerantie) {
        return verschilBoven < 0 ? -1 : 1;
      }

      final verschilLinks = a.left - b.left;

      if (verschilLinks.abs() > _tolerantie) {
        return verschilLinks < 0 ? -1 : 1;
      }

      return 0;
    });

    return resultaat;
  }

  static _VlakVerdelingResultaat _verdeelVlakkenMetStijl({
    required List<Rect> vlakken,
    required Rect profiel,
    required String richting,
  }) {
    final nieuweVlakken = <Rect>[];
    var isGesplitst = false;

    for (final vlak in vlakken) {
      if (richting == 'verticaal' &&
          _profielVerdeeltVlakVerticaal(profiel: profiel, vlak: vlak)) {
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

        if (_isBruikbaarVlak(linkerVlak) && _isBruikbaarVlak(rechterVlak)) {
          nieuweVlakken.add(linkerVlak);
          nieuweVlakken.add(rechterVlak);
          isGesplitst = true;
          continue;
        }
      }

      if (richting == 'horizontaal' &&
          _profielVerdeeltVlakHorizontaal(profiel: profiel, vlak: vlak)) {
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

        if (_isBruikbaarVlak(bovensteVlak) && _isBruikbaarVlak(ondersteVlak)) {
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
  }) {
    final raaktBovenzijde = profiel.top <= vlak.top + _tolerantie;
    final raaktOnderzijde = profiel.bottom >= vlak.bottom - _tolerantie;

    if (!raaktBovenzijde || !raaktOnderzijde) {
      return false;
    }

    final breedteLinks = profiel.left - vlak.left;
    final breedteRechts = vlak.right - profiel.right;

    if (breedteLinks < _minimaleVlakmaat || breedteRechts < _minimaleVlakmaat) {
      return false;
    }

    return profiel.right > vlak.left + _tolerantie &&
        profiel.left < vlak.right - _tolerantie;
  }

  static bool _profielVerdeeltVlakHorizontaal({
    required Rect profiel,
    required Rect vlak,
  }) {
    final raaktLinkerzijde = profiel.left <= vlak.left + _tolerantie;
    final raaktRechterzijde = profiel.right >= vlak.right - _tolerantie;

    if (!raaktLinkerzijde || !raaktRechterzijde) {
      return false;
    }

    final hoogteBoven = profiel.top - vlak.top;
    final hoogteOnder = vlak.bottom - profiel.bottom;

    if (hoogteBoven < _minimaleVlakmaat || hoogteOnder < _minimaleVlakmaat) {
      return false;
    }

    return profiel.bottom > vlak.top + _tolerantie &&
        profiel.top < vlak.bottom - _tolerantie;
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

  static bool _isBruikbaarVlak(Rect vlak) {
    return _isGeldigVlak(vlak) &&
        vlak.width >= _minimaleVlakmaat &&
        vlak.height >= _minimaleVlakmaat;
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
