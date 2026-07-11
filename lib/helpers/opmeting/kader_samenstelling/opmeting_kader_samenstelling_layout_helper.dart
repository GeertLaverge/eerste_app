import 'dart:math' as math;

import 'opmeting_kader_samenstelling_model.dart';

class OpmetingKaderSamenstellingLayoutResultaat {
  const OpmetingKaderSamenstellingLayoutResultaat({
    required this.kaders,
    required this.minXMm,
    required this.minYMm,
    required this.maxXMm,
    required this.maxYMm,
  });

  final List<OpmetingKaderDeel> kaders;

  final int minXMm;
  final int minYMm;
  final int maxXMm;
  final int maxYMm;

  int get breedteMm {
    return math.max(0, maxXMm - minXMm);
  }

  int get hoogteMm {
    return math.max(0, maxYMm - minYMm);
  }

  bool get isLeeg {
    return kaders.isEmpty;
  }
}

class OpmetingKaderSamenstellingLayoutHelper {
  const OpmetingKaderSamenstellingLayoutHelper._();

  static OpmetingKaderSamenstellingLayoutResultaat bereken({
    required List<OpmetingKaderDeel> kaders,
  }) {
    if (kaders.isEmpty) {
      return const OpmetingKaderSamenstellingLayoutResultaat(
        kaders: <OpmetingKaderDeel>[],
        minXMm: 0,
        minYMm: 0,
        maxXMm: 0,
        maxYMm: 0,
      );
    }

    var minX = kaders.first.linksMm;
    var minY = kaders.first.bovenMm;
    var maxX = kaders.first.rechtsMm;
    var maxY = kaders.first.onderMm;

    for (final kader in kaders) {
      minX = math.min(minX, kader.linksMm);
      minY = math.min(minY, kader.bovenMm);
      maxX = math.max(maxX, kader.rechtsMm);
      maxY = math.max(maxY, kader.onderMm);
    }

    return OpmetingKaderSamenstellingLayoutResultaat(
      kaders: List<OpmetingKaderDeel>.unmodifiable(kaders),
      minXMm: minX,
      minYMm: minY,
      maxXMm: maxX,
      maxYMm: maxY,
    );
  }

  static List<OpmetingKaderDeel> normaliseerKaders({
    required List<OpmetingKaderDeel> kaders,
  }) {
    if (kaders.isEmpty) {
      return const <OpmetingKaderDeel>[];
    }

    final layout = bereken(kaders: kaders);

    final verschuivingX = -layout.minXMm;
    final verschuivingY = -layout.minYMm;

    if (verschuivingX == 0 && verschuivingY == 0) {
      return List<OpmetingKaderDeel>.unmodifiable(kaders);
    }

    return List<OpmetingKaderDeel>.unmodifiable(
      kaders.map((kader) {
        return kader.copyWith(
          xMm: kader.xMm + verschuivingX,
          yMm: kader.yMm + verschuivingY,
        );
      }),
    );
  }

  static List<OpmetingKaderDeel> voegKaderToe({
    required List<OpmetingKaderDeel> bestaandeKaders,
    required OpmetingKaderDeel nieuwKader,
    required String gekoppeldAanKaderId,
    required OpmetingKaderZijde zijde,
    required OpmetingKaderUitlijning uitlijning,
    int vrijeOffsetMm = 0,
  }) {
    final ankerKader = _zoekKader(
      kaders: bestaandeKaders,
      kaderId: gekoppeldAanKaderId,
    );

    if (ankerKader == null) {
      return List<OpmetingKaderDeel>.unmodifiable(<OpmetingKaderDeel>[
        ...bestaandeKaders,
        nieuwKader,
      ]);
    }

    final geplaatstKader = berekenGeplaatstKader(
      ankerKader: ankerKader,
      nieuwKader: nieuwKader,
      zijde: zijde,
      uitlijning: uitlijning,
      vrijeOffsetMm: vrijeOffsetMm,
    );

    return normaliseerKaders(
      kaders: <OpmetingKaderDeel>[...bestaandeKaders, geplaatstKader],
    );
  }

  static List<OpmetingKaderDeel> wijzigKaderAfmetingen({
    required List<OpmetingKaderDeel> kaders,
    required String kaderId,
    int? breedteMm,
    int? hoogteMm,
  }) {
    if (kaders.isEmpty || kaderId.trim().isEmpty) {
      return List<OpmetingKaderDeel>.unmodifiable(kaders);
    }

    final aangepasteKaders = kaders.map((kader) {
      if (kader.id != kaderId) {
        return kader;
      }

      return kader.copyWith(
        breedteMm: breedteMm == null ? kader.breedteMm : math.max(1, breedteMm),
        hoogteMm: hoogteMm == null ? kader.hoogteMm : math.max(1, hoogteMm),
      );
    }).toList();

    return herberekenGekoppeldeKaders(kaders: aangepasteKaders);
  }

  static List<OpmetingKaderDeel> herberekenGekoppeldeKaders({
    required List<OpmetingKaderDeel> kaders,
  }) {
    if (kaders.isEmpty) {
      return const <OpmetingKaderDeel>[];
    }

    final bronPerId = <String, OpmetingKaderDeel>{};

    for (final kader in kaders) {
      if (kader.id.trim().isEmpty) {
        continue;
      }

      bronPerId[kader.id] = kader;
    }

    final resultaatPerId = <String, OpmetingKaderDeel>{};
    final bezig = <String>{};

    OpmetingKaderDeel plaatsKader(OpmetingKaderDeel kader) {
      final bestaand = resultaatPerId[kader.id];

      if (bestaand != null) {
        return bestaand;
      }

      if (kader.isBasisKader || bezig.contains(kader.id)) {
        resultaatPerId[kader.id] = kader;
        return kader;
      }

      bezig.add(kader.id);

      final ankerKader = bronPerId[kader.gekoppeldAanKaderId ?? ''];

      if (ankerKader == null || kader.gekoppeldeZijde == null) {
        resultaatPerId[kader.id] = kader;
        bezig.remove(kader.id);
        return kader;
      }

      final geplaatstAnkerKader = plaatsKader(ankerKader);

      final geplaatstKader = berekenGeplaatstKader(
        ankerKader: geplaatstAnkerKader,
        nieuwKader: kader,
        zijde: kader.gekoppeldeZijde!,
        uitlijning: kader.uitlijning,
        vrijeOffsetMm: kader.vrijeOffsetMm,
      );

      resultaatPerId[kader.id] = geplaatstKader;
      bezig.remove(kader.id);

      return geplaatstKader;
    }

    for (final kader in kaders) {
      plaatsKader(kader);
    }

    final herberekendeKaders = kaders.map((kader) {
      return resultaatPerId[kader.id] ?? kader;
    }).toList();

    return normaliseerKaders(kaders: herberekendeKaders);
  }

  static OpmetingKaderDeel berekenGeplaatstKader({
    required OpmetingKaderDeel ankerKader,
    required OpmetingKaderDeel nieuwKader,
    required OpmetingKaderZijde zijde,
    required OpmetingKaderUitlijning uitlijning,
    int vrijeOffsetMm = 0,
  }) {
    late final int xMm;
    late final int yMm;

    switch (zijde) {
      case OpmetingKaderZijde.links:
        xMm = ankerKader.xMm - nieuwKader.breedteMm;
        yMm = _positieLangsRaakzijde(
          ankerStartMm: ankerKader.yMm,
          ankerLengteMm: ankerKader.hoogteMm,
          nieuwLengteMm: nieuwKader.hoogteMm,
          uitlijning: uitlijning,
          vrijeOffsetMm: vrijeOffsetMm,
        );
        break;

      case OpmetingKaderZijde.rechts:
        xMm = ankerKader.xMm + ankerKader.breedteMm;
        yMm = _positieLangsRaakzijde(
          ankerStartMm: ankerKader.yMm,
          ankerLengteMm: ankerKader.hoogteMm,
          nieuwLengteMm: nieuwKader.hoogteMm,
          uitlijning: uitlijning,
          vrijeOffsetMm: vrijeOffsetMm,
        );
        break;

      case OpmetingKaderZijde.boven:
        xMm = _positieLangsRaakzijde(
          ankerStartMm: ankerKader.xMm,
          ankerLengteMm: ankerKader.breedteMm,
          nieuwLengteMm: nieuwKader.breedteMm,
          uitlijning: uitlijning,
          vrijeOffsetMm: vrijeOffsetMm,
        );
        yMm = ankerKader.yMm - nieuwKader.hoogteMm;
        break;

      case OpmetingKaderZijde.onder:
        xMm = _positieLangsRaakzijde(
          ankerStartMm: ankerKader.xMm,
          ankerLengteMm: ankerKader.breedteMm,
          nieuwLengteMm: nieuwKader.breedteMm,
          uitlijning: uitlijning,
          vrijeOffsetMm: vrijeOffsetMm,
        );
        yMm = ankerKader.yMm + ankerKader.hoogteMm;
        break;
    }

    return nieuwKader.copyWith(
      xMm: xMm,
      yMm: yMm,
      gekoppeldAanKaderId: ankerKader.id,
      gekoppeldeZijde: zijde,
      uitlijning: uitlijning,
      vrijeOffsetMm: vrijeOffsetMm,
    );
  }

  static int totaleBreedteMetSlag({
    required int samenstellingBreedteMm,
    required int slagLinksMm,
    required int slagRechtsMm,
  }) {
    return math.max(0, samenstellingBreedteMm + slagLinksMm + slagRechtsMm);
  }

  static int totaleHoogteMetSlag({
    required int samenstellingHoogteMm,
    required int slagBovenMm,
    required int slagOnderMm,
  }) {
    return math.max(0, samenstellingHoogteMm + slagBovenMm + slagOnderMm);
  }

  static OpmetingKaderDeel? _zoekKader({
    required List<OpmetingKaderDeel> kaders,
    required String kaderId,
  }) {
    for (final kader in kaders) {
      if (kader.id == kaderId) {
        return kader;
      }
    }

    return null;
  }

  static int _positieLangsRaakzijde({
    required int ankerStartMm,
    required int ankerLengteMm,
    required int nieuwLengteMm,
    required OpmetingKaderUitlijning uitlijning,
    required int vrijeOffsetMm,
  }) {
    switch (uitlijning) {
      case OpmetingKaderUitlijning.begin:
        return ankerStartMm;

      case OpmetingKaderUitlijning.midden:
        return ankerStartMm + ((ankerLengteMm - nieuwLengteMm) / 2).round();

      case OpmetingKaderUitlijning.einde:
        return ankerStartMm + ankerLengteMm - nieuwLengteMm;

      case OpmetingKaderUitlijning.vrij:
        return ankerStartMm + vrijeOffsetMm;
    }
  }
}
