import 'package:flutter/material.dart';

import '../raam/opmeting_raam_model.dart';
import '../raam/opmeting_raam_tstijl_helper.dart';
import '../raam/opmeting_raam_vlak_helper.dart';
import '../raam/opmeting_raam_vulling_helper.dart';
import 'opmeting_schuifraam_model.dart';
import 'opmeting_schuifraam_teken_helper.dart' as schuifraam_teken;

class OpmetingSchuifraamVulvlakHelper {
  const OpmetingSchuifraamVulvlakHelper._();

  static const double _tolerantie = 3;

  static List<OpmetingRaamVulvlak> bepaal({
    required Size tekenvlakGrootte,
    required int breedteMm,
    required int hoogteMm,
    required OpmetingSchuifraamSamenstelling samenstelling,
    required List<OpmetingRaamTStijl> tStijlen,
    required List<OpmetingRaamVleugel> vleugels,
  }) {
    if (!samenstelling.isGeldig || breedteMm <= 0 || hoogteMm <= 0) {
      return const <OpmetingRaamVulvlak>[];
    }

    final geometrie =
        schuifraam_teken.OpmetingSchuifraamTekenHelper.berekenGeometrie(
          tekenvlakGrootte: tekenvlakGrootte,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
          samenstelling: samenstelling,
        );

    if (!_isGeldigVlak(geometrie.buitenKader) ||
        !_isGeldigVlak(geometrie.binnenKader)) {
      return const <OpmetingRaamVulvlak>[];
    }

    final resultaat = <OpmetingRaamVulvlak>[];

    final kaderTStijlen = tStijlen
        .where((stijl) => stijl.werkvlakId == 'kader')
        .toList(growable: false);

    final kaderVlakken = OpmetingRaamVlakHelper.bepaalVlakken(
      binnenKader: geometrie.binnenKader,
      buitenKader: geometrie.buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      tStijlen: kaderTStijlen,
    );

    final logischeVleugels = vleugels
        .where(schuifraam_teken.OpmetingSchuifraamTekenHelper.isLogischeVleugel)
        .toList(growable: false);

    for (var index = 0; index < kaderVlakken.length; index++) {
      final kaderVlak = kaderVlakken[index];

      final hoortBijVleugelVak = geometrie.vakken.any((vak) {
        if (vak.vleugelVlak == null) {
          return false;
        }

        return vak.segmentVlak.inflate(_tolerantie).contains(kaderVlak.center);
      });

      final heeftVleugel =
          hoortBijVleugelVak ||
          logischeVleugels.any(
            (vleugel) => _vleugelHoortBijKaderVlak(
              vleugel: vleugel,
              kaderVlak: kaderVlak,
            ),
          );

      if (heeftVleugel || !_isGeldigVlak(kaderVlak)) {
        continue;
      }

      resultaat.add(
        OpmetingRaamVulvlak(
          id: _maakVlakId(werkvlakId: 'kader', index: index),
          werkvlakId: 'kader',
          vlak: kaderVlak,
        ),
      );
    }

    final vleugelWerkvlakken =
        OpmetingRaamTStijlHelper.bepaalVleugelWerkvlakken(
          vleugels: logischeVleugels,
          buitenKader: geometrie.buitenKader,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
        );

    final gesorteerdeWerkvlakken = vleugelWerkvlakken.entries.toList()
      ..sort((eerste, tweede) => eerste.key.compareTo(tweede.key));

    for (final entry in gesorteerdeWerkvlakken) {
      final werkvlakId = entry.key;
      final werkvlak = entry.value;

      if (!_isGeldigVlak(werkvlak)) {
        continue;
      }

      final interneTStijlen = tStijlen
          .where((stijl) => stijl.werkvlakId == werkvlakId)
          .toList(growable: false);

      final interneVlakken = OpmetingRaamVlakHelper.bepaalVlakken(
        binnenKader: werkvlak,
        buitenKader: geometrie.buitenKader,
        breedteMm: breedteMm,
        hoogteMm: hoogteMm,
        tStijlen: interneTStijlen,
      );

      for (var index = 0; index < interneVlakken.length; index++) {
        final internVlak = interneVlakken[index];

        if (!_isGeldigVlak(internVlak)) {
          continue;
        }

        resultaat.add(
          OpmetingRaamVulvlak(
            id: _maakVlakId(werkvlakId: werkvlakId, index: index),
            werkvlakId: werkvlakId,
            vlak: internVlak,
          ),
        );
      }
    }

    resultaat.sort(_vergelijkVulvlakken);
    return resultaat;
  }

  static String _maakVlakId({required String werkvlakId, required int index}) {
    return '${werkvlakId}_vlak_$index';
  }

  static bool _vleugelHoortBijKaderVlak({
    required OpmetingRaamVleugel vleugel,
    required Rect kaderVlak,
  }) {
    if (kaderVlak.inflate(_tolerantie).contains(vleugel.vlak.center)) {
      return true;
    }

    final overlap = _overlapOppervlakte(vleugel.vlak, kaderVlak);

    if (overlap <= 0) {
      return false;
    }

    final vleugelOppervlakte = _oppervlakte(vleugel.vlak);

    if (vleugelOppervlakte <= 0) {
      return false;
    }

    return overlap / vleugelOppervlakte >= 0.5;
  }

  static int _vergelijkVulvlakken(
    OpmetingRaamVulvlak eerste,
    OpmetingRaamVulvlak tweede,
  ) {
    final verschilBoven = eerste.vlak.top - tweede.vlak.top;

    if (verschilBoven.abs() > _tolerantie) {
      return verschilBoven < 0 ? -1 : 1;
    }

    final verschilLinks = eerste.vlak.left - tweede.vlak.left;

    if (verschilLinks.abs() > _tolerantie) {
      return verschilLinks < 0 ? -1 : 1;
    }

    final werkvlakVergelijking = eerste.werkvlakId.compareTo(tweede.werkvlakId);

    if (werkvlakVergelijking != 0) {
      return werkvlakVergelijking;
    }

    return eerste.id.compareTo(tweede.id);
  }

  static double _overlapOppervlakte(Rect eerste, Rect tweede) {
    final links = eerste.left > tweede.left ? eerste.left : tweede.left;
    final boven = eerste.top > tweede.top ? eerste.top : tweede.top;
    final rechts = eerste.right < tweede.right ? eerste.right : tweede.right;
    final onder = eerste.bottom < tweede.bottom ? eerste.bottom : tweede.bottom;

    if (rechts <= links || onder <= boven) {
      return 0;
    }

    return (rechts - links) * (onder - boven);
  }

  static double _oppervlakte(Rect vlak) {
    if (!_isGeldigVlak(vlak)) {
      return 0;
    }

    return vlak.width * vlak.height;
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
