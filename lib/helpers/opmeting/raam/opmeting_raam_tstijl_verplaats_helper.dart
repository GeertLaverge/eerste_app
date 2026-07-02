import 'package:flutter/material.dart';

import 'opmeting_raam_kader_helper.dart';
import 'opmeting_raam_model.dart';
import 'opmeting_raam_tstijl_helper.dart';
import 'opmeting_raam_vlak_helper.dart';
import 'opmeting_raam_vleugel_helper.dart';
import 'opmeting_raam_vulling_helper.dart';
import 'opmeting_raam_opvulling_model.dart';

class OpmetingRaamTStijlVerplaatsResultaat {
  const OpmetingRaamTStijlVerplaatsResultaat({
    required this.tStijlen,
    required this.vleugels,
    required this.vullingToewijzingen,
    required this.gewijzigd,
    this.foutmelding,
  });

  final List<OpmetingRaamTStijl> tStijlen;
  final List<OpmetingRaamVleugel> vleugels;
  final List<OpmetingRaamVullingToewijzing> vullingToewijzingen;
  final bool gewijzigd;
  final String? foutmelding;
}

class OpmetingRaamTStijlVerplaatsHelper {
  const OpmetingRaamTStijlVerplaatsHelper._();

  static const double _aansluitTolerantie = 5;
  static const double _positieTolerantie = 0.5;

  static OpmetingRaamTStijlVerplaatsResultaat verplaatsTStijl({
    required Size tekenvlakGrootte,
    required int breedteMm,
    required int hoogteMm,
    required int tStijlIndex,
    required String positieType,
    required String positieTekst,
    required List<OpmetingRaamTStijl> bestaandeTStijlen,
    required List<OpmetingRaamVleugel> bestaandeVleugels,
    required List<OpmetingRaamVullingToewijzing> bestaandeVullingToewijzingen,
  }) {
    final ongewijzigd = _ongewijzigd(
      tStijlen: bestaandeTStijlen,
      vleugels: bestaandeVleugels,
      vullingToewijzingen: bestaandeVullingToewijzingen,
    );

    if (!_isGeldigeTekenvlakGrootte(tekenvlakGrootte) ||
        breedteMm <= 0 ||
        hoogteMm <= 0) {
      return _ongewijzigd(
        tStijlen: bestaandeTStijlen,
        vleugels: bestaandeVleugels,
        vullingToewijzingen: bestaandeVullingToewijzingen,
        foutmelding: 'De afmetingen van het tekenvlak zijn ongeldig.',
      );
    }

    if (tStijlIndex < 0 || tStijlIndex >= bestaandeTStijlen.length) {
      return _ongewijzigd(
        tStijlen: bestaandeTStijlen,
        vleugels: bestaandeVleugels,
        vullingToewijzingen: bestaandeVullingToewijzingen,
        foutmelding: 'Er is geen geldige T-stijl geselecteerd.',
      );
    }

    final geselecteerdeTStijl = bestaandeTStijlen[tStijlIndex];

    final buitenKader = OpmetingRaamKaderHelper.buitenKader(
      size: tekenvlakGrootte,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    final binnenKader = OpmetingRaamKaderHelper.binnenKader(
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    if (!_isGeldigVlak(buitenKader) || !_isGeldigVlak(binnenKader)) {
      return _ongewijzigd(
        tStijlen: bestaandeTStijlen,
        vleugels: bestaandeVleugels,
        vullingToewijzingen: bestaandeVullingToewijzingen,
        foutmelding: 'Het raamkader kon niet worden berekend.',
      );
    }

    final oudeVleugelWerkvlakken =
        OpmetingRaamTStijlHelper.bepaalVleugelWerkvlakken(
          vleugels: bestaandeVleugels,
          buitenKader: buitenKader,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
        );

    final werkvlak = geselecteerdeTStijl.werkvlakId == 'kader'
        ? binnenKader
        : oudeVleugelWerkvlakken[geselecteerdeTStijl.werkvlakId];

    if (werkvlak == null || !_isGeldigVlak(werkvlak)) {
      return _ongewijzigd(
        tStijlen: bestaandeTStijlen,
        vleugels: bestaandeVleugels,
        vullingToewijzingen: bestaandeVullingToewijzingen,
        foutmelding:
            'Het werkvlak van de geselecteerde T-stijl werd niet gevonden.',
      );
    }

    final nieuweCoordinaat = _berekenNieuweCoordinaat(
      stijl: geselecteerdeTStijl,
      werkvlak: werkvlak,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      positieType: positieType,
      positieTekst: positieTekst,
    );

    if (nieuweCoordinaat == null || !nieuweCoordinaat.isFinite) {
      return _ongewijzigd(
        tStijlen: bestaandeTStijlen,
        vleugels: bestaandeVleugels,
        vullingToewijzingen: bestaandeVullingToewijzingen,
        foutmelding: 'Vul een geldige maat in of kies een geldige breuk.',
      );
    }

    final oudeCoordinaat = geselecteerdeTStijl.richting == 'verticaal'
        ? geselecteerdeTStijl.start.dx
        : geselecteerdeTStijl.start.dy;

    if ((oudeCoordinaat - nieuweCoordinaat).abs() <= _positieTolerantie) {
      return _ongewijzigd(
        tStijlen: bestaandeTStijlen,
        vleugels: bestaandeVleugels,
        vullingToewijzingen: bestaandeVullingToewijzingen,
        foutmelding: 'De T-stijl staat al op de gekozen positie.',
      );
    }

    final oudeVulvlakken = OpmetingRaamVullingHelper.bepaalVulvlakken(
      binnenKader: binnenKader,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      tStijlen: bestaandeTStijlen,
      vleugels: bestaandeVleugels,
    );

    final verplaatsteWerkvlakTStijlen = _verplaatsTStijlEnAansluitingen(
      geselecteerdeIndex: tStijlIndex,
      nieuweCoordinaat: nieuweCoordinaat,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      bestaandeTStijlen: bestaandeTStijlen,
    );

    if (verplaatsteWerkvlakTStijlen == null) {
      return ongewijzigd;
    }

    var nieuweTStijlen = verplaatsteWerkvlakTStijlen;
    var nieuweVleugels = List<OpmetingRaamVleugel>.from(bestaandeVleugels);

    if (geselecteerdeTStijl.werkvlakId == 'kader') {
      final vleugelResultaat = _pasVleugelsAanNieuweKaderVlakkenAan(
        buitenKader: buitenKader,
        binnenKader: binnenKader,
        breedteMm: breedteMm,
        hoogteMm: hoogteMm,
        oudeTStijlen: bestaandeTStijlen,
        nieuweTStijlen: nieuweTStijlen,
        oudeVleugels: bestaandeVleugels,
      );

      nieuweTStijlen = vleugelResultaat.tStijlen;
      nieuweVleugels = vleugelResultaat.vleugels;
    }

    final nieuweVulvlakken = OpmetingRaamVullingHelper.bepaalVulvlakken(
      binnenKader: binnenKader,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      tStijlen: nieuweTStijlen,
      vleugels: nieuweVleugels,
    );

    final nieuweVullingToewijzingen =
        OpmetingRaamVullingHelper.herkoppelToewijzingenNaVlakWijziging(
          oudeVulvlakken: oudeVulvlakken,
          nieuweVulvlakken: nieuweVulvlakken,
          bestaandeToewijzingen: bestaandeVullingToewijzingen,
        );

    return OpmetingRaamTStijlVerplaatsResultaat(
      tStijlen: nieuweTStijlen,
      vleugels: nieuweVleugels,
      vullingToewijzingen: nieuweVullingToewijzingen,
      gewijzigd: true,
    );
  }

  static double? _berekenNieuweCoordinaat({
    required OpmetingRaamTStijl stijl,
    required Rect werkvlak,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
    required String positieType,
    required String positieTekst,
  }) {
    final fractie = _leesFractie(positieType);

    double doelCoordinaat;

    if (fractie != null) {
      if (stijl.richting == 'verticaal') {
        doelCoordinaat = werkvlak.left + werkvlak.width * fractie;
      } else {
        doelCoordinaat = werkvlak.top + werkvlak.height * fractie;
      }
    } else {
      final maatMm = double.tryParse(positieTekst.trim().replaceAll(',', '.'));

      if (maatMm == null || maatMm < 0) {
        return null;
      }

      if (stijl.richting == 'verticaal') {
        final pixelsPerMm = buitenKader.width / breedteMm;

        final startCoordinaat = stijl.werkvlakId == 'kader'
            ? buitenKader.left
            : werkvlak.left;

        doelCoordinaat = startCoordinaat + maatMm * pixelsPerMm;
      } else {
        final pixelsPerMm = buitenKader.height / hoogteMm;

        final startCoordinaat = stijl.werkvlakId == 'kader'
            ? buitenKader.top
            : werkvlak.top;

        doelCoordinaat = startCoordinaat + maatMm * pixelsPerMm;
      }
    }

    final profielDikte = stijl.richting == 'verticaal'
        ? (buitenKader.width / breedteMm) * stijl.breedteMm
        : (buitenKader.height / hoogteMm) * stijl.breedteMm;

    final halveProfielDikte = profielDikte / 2;

    if (stijl.richting == 'verticaal') {
      final minimum = werkvlak.left + halveProfielDikte;
      final maximum = werkvlak.right - halveProfielDikte;

      if (maximum <= minimum) {
        return null;
      }

      return doelCoordinaat.clamp(minimum, maximum).toDouble();
    }

    final minimum = werkvlak.top + halveProfielDikte;
    final maximum = werkvlak.bottom - halveProfielDikte;

    if (maximum <= minimum) {
      return null;
    }

    return doelCoordinaat.clamp(minimum, maximum).toDouble();
  }

  static double? _leesFractie(String positieType) {
    final waarde = positieType.trim();

    if (waarde == 'mm') {
      return null;
    }

    final delen = waarde.split('/');

    if (delen.length != 2) {
      return null;
    }

    final teller = double.tryParse(delen[0]);
    final noemer = double.tryParse(delen[1]);

    if (teller == null ||
        noemer == null ||
        noemer <= 0 ||
        teller < 0 ||
        teller > noemer) {
      return null;
    }

    return teller / noemer;
  }

  static List<OpmetingRaamTStijl>? _verplaatsTStijlEnAansluitingen({
    required int geselecteerdeIndex,
    required double nieuweCoordinaat,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
    required List<OpmetingRaamTStijl> bestaandeTStijlen,
  }) {
    if (geselecteerdeIndex < 0 ||
        geselecteerdeIndex >= bestaandeTStijlen.length) {
      return null;
    }

    final geselecteerdeStijl = bestaandeTStijlen[geselecteerdeIndex];

    final oudeProfielRect = OpmetingRaamTStijlHelper.profielRect(
      stijl: geselecteerdeStijl,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    final verplaatsteStijl = geselecteerdeStijl.richting == 'verticaal'
        ? OpmetingRaamTStijl(
            id: geselecteerdeStijl.id,
            richting: geselecteerdeStijl.richting,
            start: Offset(nieuweCoordinaat, geselecteerdeStijl.start.dy),
            einde: Offset(nieuweCoordinaat, geselecteerdeStijl.einde.dy),
            breedteMm: geselecteerdeStijl.breedteMm,
            werkvlakId: geselecteerdeStijl.werkvlakId,
          )
        : OpmetingRaamTStijl(
            id: geselecteerdeStijl.id,
            richting: geselecteerdeStijl.richting,
            start: Offset(geselecteerdeStijl.start.dx, nieuweCoordinaat),
            einde: Offset(geselecteerdeStijl.einde.dx, nieuweCoordinaat),
            breedteMm: geselecteerdeStijl.breedteMm,
            werkvlakId: geselecteerdeStijl.werkvlakId,
          );

    final nieuweProfielRect = OpmetingRaamTStijlHelper.profielRect(
      stijl: verplaatsteStijl,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    final resultaat = <OpmetingRaamTStijl>[];

    for (var index = 0; index < bestaandeTStijlen.length; index++) {
      final stijl = bestaandeTStijlen[index];

      if (index == geselecteerdeIndex) {
        resultaat.add(verplaatsteStijl);
        continue;
      }

      if (stijl.werkvlakId != geselecteerdeStijl.werkvlakId ||
          stijl.richting == geselecteerdeStijl.richting) {
        resultaat.add(stijl);
        continue;
      }

      resultaat.add(
        _pasAansluitingenAanVerplaatsteTStijlAan(
          stijl: stijl,
          verplaatsteStijl: geselecteerdeStijl,
          oudeProfielRect: oudeProfielRect,
          nieuweProfielRect: nieuweProfielRect,
        ),
      );
    }

    return resultaat;
  }

  static OpmetingRaamTStijl _pasAansluitingenAanVerplaatsteTStijlAan({
    required OpmetingRaamTStijl stijl,
    required OpmetingRaamTStijl verplaatsteStijl,
    required Rect oudeProfielRect,
    required Rect nieuweProfielRect,
  }) {
    final nieuwStart = _verplaatsAangeslotenPunt(
      punt: stijl.start,
      stijlRichting: stijl.richting,
      verplaatsteRichting: verplaatsteStijl.richting,
      verplaatsteStart: verplaatsteStijl.start,
      verplaatsteEinde: verplaatsteStijl.einde,
      oudeProfielRect: oudeProfielRect,
      nieuweProfielRect: nieuweProfielRect,
    );

    final nieuwEinde = _verplaatsAangeslotenPunt(
      punt: stijl.einde,
      stijlRichting: stijl.richting,
      verplaatsteRichting: verplaatsteStijl.richting,
      verplaatsteStart: verplaatsteStijl.start,
      verplaatsteEinde: verplaatsteStijl.einde,
      oudeProfielRect: oudeProfielRect,
      nieuweProfielRect: nieuweProfielRect,
    );

    return OpmetingRaamTStijl(
      id: stijl.id,
      richting: stijl.richting,
      start: nieuwStart,
      einde: nieuwEinde,
      breedteMm: stijl.breedteMm,
      werkvlakId: stijl.werkvlakId,
    );
  }

  static Offset _verplaatsAangeslotenPunt({
    required Offset punt,
    required String stijlRichting,
    required String verplaatsteRichting,
    required Offset verplaatsteStart,
    required Offset verplaatsteEinde,
    required Rect oudeProfielRect,
    required Rect nieuweProfielRect,
  }) {
    if (verplaatsteRichting == 'verticaal' && stijlRichting == 'horizontaal') {
      final minimumY = verplaatsteStart.dy < verplaatsteEinde.dy
          ? verplaatsteStart.dy
          : verplaatsteEinde.dy;

      final maximumY = verplaatsteStart.dy > verplaatsteEinde.dy
          ? verplaatsteStart.dy
          : verplaatsteEinde.dy;

      if (punt.dy < minimumY - _aansluitTolerantie ||
          punt.dy > maximumY + _aansluitTolerantie) {
        return punt;
      }

      final nieuweX = _vervangCoordinaatBijProfiel(
        coordinaat: punt.dx,
        oudeMinimum: oudeProfielRect.left,
        oudeMidden: oudeProfielRect.center.dx,
        oudeMaximum: oudeProfielRect.right,
        nieuweMinimum: nieuweProfielRect.left,
        nieuweMidden: nieuweProfielRect.center.dx,
        nieuweMaximum: nieuweProfielRect.right,
      );

      if (nieuweX == null) {
        return punt;
      }

      return Offset(nieuweX, punt.dy);
    }

    if (verplaatsteRichting == 'horizontaal' && stijlRichting == 'verticaal') {
      final minimumX = verplaatsteStart.dx < verplaatsteEinde.dx
          ? verplaatsteStart.dx
          : verplaatsteEinde.dx;

      final maximumX = verplaatsteStart.dx > verplaatsteEinde.dx
          ? verplaatsteStart.dx
          : verplaatsteEinde.dx;

      if (punt.dx < minimumX - _aansluitTolerantie ||
          punt.dx > maximumX + _aansluitTolerantie) {
        return punt;
      }

      final nieuweY = _vervangCoordinaatBijProfiel(
        coordinaat: punt.dy,
        oudeMinimum: oudeProfielRect.top,
        oudeMidden: oudeProfielRect.center.dy,
        oudeMaximum: oudeProfielRect.bottom,
        nieuweMinimum: nieuweProfielRect.top,
        nieuweMidden: nieuweProfielRect.center.dy,
        nieuweMaximum: nieuweProfielRect.bottom,
      );

      if (nieuweY == null) {
        return punt;
      }

      return Offset(punt.dx, nieuweY);
    }

    return punt;
  }

  static double? _vervangCoordinaatBijProfiel({
    required double coordinaat,
    required double oudeMinimum,
    required double oudeMidden,
    required double oudeMaximum,
    required double nieuweMinimum,
    required double nieuweMidden,
    required double nieuweMaximum,
  }) {
    final afstandMinimum = (coordinaat - oudeMinimum).abs();

    final afstandMidden = (coordinaat - oudeMidden).abs();

    final afstandMaximum = (coordinaat - oudeMaximum).abs();

    final kleinsteAfstand = [
      afstandMinimum,
      afstandMidden,
      afstandMaximum,
    ].reduce((eerste, tweede) => eerste < tweede ? eerste : tweede);

    if (kleinsteAfstand > _aansluitTolerantie) {
      return null;
    }

    if (kleinsteAfstand == afstandMinimum) {
      return nieuweMinimum;
    }

    if (kleinsteAfstand == afstandMaximum) {
      return nieuweMaximum;
    }

    return nieuweMidden;
  }

  static _VleugelAanpassingResultaat _pasVleugelsAanNieuweKaderVlakkenAan({
    required Rect buitenKader,
    required Rect binnenKader,
    required int breedteMm,
    required int hoogteMm,
    required List<OpmetingRaamTStijl> oudeTStijlen,
    required List<OpmetingRaamTStijl> nieuweTStijlen,
    required List<OpmetingRaamVleugel> oudeVleugels,
  }) {
    final oudeKaderTStijlen = oudeTStijlen
        .where((stijl) => stijl.werkvlakId == 'kader')
        .toList();

    final nieuweKaderTStijlen = nieuweTStijlen
        .where((stijl) => stijl.werkvlakId == 'kader')
        .toList();

    final oudeKaderVlakken = OpmetingRaamVlakHelper.bepaalVlakken(
      binnenKader: binnenKader,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      tStijlen: oudeKaderTStijlen,
    );

    final nieuweKaderVlakken = OpmetingRaamVlakHelper.bepaalVlakken(
      binnenKader: binnenKader,
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      tStijlen: nieuweKaderTStijlen,
    );

    if (oudeKaderVlakken.isEmpty || nieuweKaderVlakken.isEmpty) {
      return _VleugelAanpassingResultaat(
        tStijlen: nieuweTStijlen,
        vleugels: oudeVleugels,
      );
    }

    final oudeVleugelWerkvlakken =
        OpmetingRaamTStijlHelper.bepaalVleugelWerkvlakken(
          vleugels: oudeVleugels,
          buitenKader: buitenKader,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
        );

    final nieuweVleugels = <OpmetingRaamVleugel>[];

    for (final oudeVleugel in oudeVleugels) {
      final oudVlakIndex = _vindBestPassendVlakIndex(
        doelVlak: oudeVleugel.vlak,
        kandidaatVlakken: oudeKaderVlakken,
      );

      if (oudVlakIndex == null) {
        nieuweVleugels.add(oudeVleugel);
        continue;
      }

      final nieuwVlak = oudVlakIndex < nieuweKaderVlakken.length
          ? nieuweKaderVlakken[oudVlakIndex]
          : _vindBestPassendVlak(
              doelVlak: oudeKaderVlakken[oudVlakIndex],
              kandidaatVlakken: nieuweKaderVlakken,
            );

      if (nieuwVlak == null) {
        nieuweVleugels.add(oudeVleugel);
        continue;
      }

      final nieuwVleugelVlak = OpmetingRaamVleugelHelper.maakVleugelVlak(
        vlak: nieuwVlak,
        buitenKader: buitenKader,
        breedteMm: breedteMm,
        hoogteMm: hoogteMm,
      );

      nieuweVleugels.add(
        OpmetingRaamVleugel(
          id: oudeVleugel.id,
          vlak: nieuwVleugelVlak,
          type: oudeVleugel.type,
        ),
      );
    }

    final nieuweVleugelWerkvlakken =
        OpmetingRaamTStijlHelper.bepaalVleugelWerkvlakken(
          vleugels: nieuweVleugels,
          buitenKader: buitenKader,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
        );

    final aangepasteTStijlen = nieuweTStijlen.map((stijl) {
      if (stijl.werkvlakId == 'kader') {
        return stijl;
      }

      final oudWerkvlak = oudeVleugelWerkvlakken[stijl.werkvlakId];

      final nieuwWerkvlak = nieuweVleugelWerkvlakken[stijl.werkvlakId];

      if (oudWerkvlak == null ||
          nieuwWerkvlak == null ||
          !_isGeldigVlak(oudWerkvlak) ||
          !_isGeldigVlak(nieuwWerkvlak)) {
        return stijl;
      }

      return OpmetingRaamTStijl(
        id: stijl.id,
        richting: stijl.richting,
        start: _schaalPuntTussenVlakken(
          punt: stijl.start,
          oudVlak: oudWerkvlak,
          nieuwVlak: nieuwWerkvlak,
        ),
        einde: _schaalPuntTussenVlakken(
          punt: stijl.einde,
          oudVlak: oudWerkvlak,
          nieuwVlak: nieuwWerkvlak,
        ),
        breedteMm: stijl.breedteMm,
        werkvlakId: stijl.werkvlakId,
      );
    }).toList();

    return _VleugelAanpassingResultaat(
      tStijlen: aangepasteTStijlen,
      vleugels: nieuweVleugels,
    );
  }

  static int? _vindBestPassendVlakIndex({
    required Rect doelVlak,
    required List<Rect> kandidaatVlakken,
  }) {
    if (kandidaatVlakken.isEmpty) {
      return null;
    }

    var besteIndex = 0;
    var besteScore = double.negativeInfinity;

    for (var index = 0; index < kandidaatVlakken.length; index++) {
      final kandidaat = kandidaatVlakken[index];

      final score = _berekenVlakScore(
        doelVlak: doelVlak,
        kandidaatVlak: kandidaat,
      );

      if (score > besteScore) {
        besteScore = score;
        besteIndex = index;
      }
    }

    return besteIndex;
  }

  static Rect? _vindBestPassendVlak({
    required Rect doelVlak,
    required List<Rect> kandidaatVlakken,
  }) {
    final index = _vindBestPassendVlakIndex(
      doelVlak: doelVlak,
      kandidaatVlakken: kandidaatVlakken,
    );

    if (index == null) {
      return null;
    }

    return kandidaatVlakken[index];
  }

  static double _berekenVlakScore({
    required Rect doelVlak,
    required Rect kandidaatVlak,
  }) {
    final overlap = _overlapOppervlakte(doelVlak, kandidaatVlak);

    final doelOppervlakte = _oppervlakte(doelVlak);
    final kandidaatOppervlakte = _oppervlakte(kandidaatVlak);

    final overlapScore = doelOppervlakte > 0 && kandidaatOppervlakte > 0
        ? (overlap / doelOppervlakte) + (overlap / kandidaatOppervlakte)
        : 0.0;

    final gezamenlijkeGrenzen = doelVlak.expandToInclude(kandidaatVlak);

    final maximaleAfstand = gezamenlijkeGrenzen.size.longestSide > 0
        ? gezamenlijkeGrenzen.size.longestSide
        : 1.0;

    final middenAfstand = (doelVlak.center - kandidaatVlak.center).distance;

    final middenScore =
        1 - (middenAfstand / maximaleAfstand).clamp(0.0, 1.0).toDouble();

    return overlapScore * 10 + middenScore;
  }

  static Offset _schaalPuntTussenVlakken({
    required Offset punt,
    required Rect oudVlak,
    required Rect nieuwVlak,
  }) {
    if (!_isGeldigVlak(oudVlak) || !_isGeldigVlak(nieuwVlak)) {
      return punt;
    }

    final fractieX = ((punt.dx - oudVlak.left) / oudVlak.width)
        .clamp(0.0, 1.0)
        .toDouble();

    final fractieY = ((punt.dy - oudVlak.top) / oudVlak.height)
        .clamp(0.0, 1.0)
        .toDouble();

    return Offset(
      nieuwVlak.left + nieuwVlak.width * fractieX,
      nieuwVlak.top + nieuwVlak.height * fractieY,
    );
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

  static bool _isGeldigeTekenvlakGrootte(Size size) {
    return size.width > 0 &&
        size.height > 0 &&
        size.width.isFinite &&
        size.height.isFinite;
  }

  static bool _isGeldigVlak(Rect vlak) {
    return vlak.left.isFinite &&
        vlak.top.isFinite &&
        vlak.right.isFinite &&
        vlak.bottom.isFinite &&
        vlak.width > 0 &&
        vlak.height > 0;
  }

  static OpmetingRaamTStijlVerplaatsResultaat _ongewijzigd({
    required List<OpmetingRaamTStijl> tStijlen,
    required List<OpmetingRaamVleugel> vleugels,
    required List<OpmetingRaamVullingToewijzing> vullingToewijzingen,
    String? foutmelding,
  }) {
    return OpmetingRaamTStijlVerplaatsResultaat(
      tStijlen: List<OpmetingRaamTStijl>.from(tStijlen),
      vleugels: List<OpmetingRaamVleugel>.from(vleugels),
      vullingToewijzingen: List<OpmetingRaamVullingToewijzing>.from(
        vullingToewijzingen,
      ),
      gewijzigd: false,
      foutmelding: foutmelding,
    );
  }
}

class _VleugelAanpassingResultaat {
  const _VleugelAanpassingResultaat({
    required this.tStijlen,
    required this.vleugels,
  });

  final List<OpmetingRaamTStijl> tStijlen;
  final List<OpmetingRaamVleugel> vleugels;
}
