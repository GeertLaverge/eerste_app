enum OpmetingKaderZijde { links, rechts, boven, onder }

extension OpmetingKaderZijdeExtension on OpmetingKaderZijde {
  String get opslagWaarde {
    return name;
  }

  String get label {
    switch (this) {
      case OpmetingKaderZijde.links:
        return 'Links';

      case OpmetingKaderZijde.rechts:
        return 'Rechts';

      case OpmetingKaderZijde.boven:
        return 'Boven';

      case OpmetingKaderZijde.onder:
        return 'Onder';
    }
  }

  static OpmetingKaderZijde? vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';

    for (final zijde in OpmetingKaderZijde.values) {
      if (zijde.name == tekst) {
        return zijde;
      }
    }

    return null;
  }
}

enum OpmetingKaderUitlijning { begin, midden, einde, vrij }

extension OpmetingKaderUitlijningExtension on OpmetingKaderUitlijning {
  String get opslagWaarde {
    return name;
  }

  String labelVoorZijde(OpmetingKaderZijde zijde) {
    final verticaalUitlijnen =
        zijde == OpmetingKaderZijde.links || zijde == OpmetingKaderZijde.rechts;

    switch (this) {
      case OpmetingKaderUitlijning.begin:
        return verticaalUitlijnen ? 'Boven' : 'Links';

      case OpmetingKaderUitlijning.midden:
        return 'Midden';

      case OpmetingKaderUitlijning.einde:
        return verticaalUitlijnen ? 'Onder' : 'Rechts';

      case OpmetingKaderUitlijning.vrij:
        return verticaalUitlijnen ? 'Vrij vanaf boven' : 'Vrij vanaf links';
    }
  }

  static OpmetingKaderUitlijning vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';

    for (final uitlijning in OpmetingKaderUitlijning.values) {
      if (uitlijning.name == tekst) {
        return uitlijning;
      }
    }

    return OpmetingKaderUitlijning.begin;
  }
}

class OpmetingKaderDeel {
  const OpmetingKaderDeel({
    required this.id,
    required this.naam,
    required this.breedteMm,
    required this.hoogteMm,
    this.xMm = 0,
    this.yMm = 0,
    this.actief = true,
    this.gekoppeldAanKaderId,
    this.gekoppeldeZijde,
    this.uitlijning = OpmetingKaderUitlijning.begin,
    this.vrijeOffsetMm = 0,
  });

  static const Object _ongewijzigd = Object();

  final String id;
  final String naam;

  final int breedteMm;
  final int hoogteMm;

  /// Positie binnen de volledige samenstelling, in mm.
  final int xMm;
  final int yMm;

  final bool actief;

  /// Kader waaraan dit kader gekoppeld werd.
  final String? gekoppeldAanKaderId;

  /// Zijde van het gekoppelde kader.
  final OpmetingKaderZijde? gekoppeldeZijde;

  /// Uitlijning langs de raakzijde.
  final OpmetingKaderUitlijning uitlijning;

  /// Alleen gebruikt bij uitlijning "vrij".
  ///
  /// Bij links/rechts = afstand vanaf boven.
  /// Bij boven/onder = afstand vanaf links.
  final int vrijeOffsetMm;

  int get linksMm {
    return xMm;
  }

  int get rechtsMm {
    return xMm + breedteMm;
  }

  int get bovenMm {
    return yMm;
  }

  int get onderMm {
    return yMm + hoogteMm;
  }

  bool get isBasisKader {
    return gekoppeldAanKaderId == null ||
        gekoppeldAanKaderId!.trim().isEmpty ||
        gekoppeldeZijde == null;
  }

  OpmetingKaderDeel copyWith({
    String? id,
    String? naam,
    int? breedteMm,
    int? hoogteMm,
    int? xMm,
    int? yMm,
    bool? actief,
    Object? gekoppeldAanKaderId = _ongewijzigd,
    Object? gekoppeldeZijde = _ongewijzigd,
    OpmetingKaderUitlijning? uitlijning,
    int? vrijeOffsetMm,
  }) {
    return OpmetingKaderDeel(
      id: id ?? this.id,
      naam: naam ?? this.naam,
      breedteMm: breedteMm ?? this.breedteMm,
      hoogteMm: hoogteMm ?? this.hoogteMm,
      xMm: xMm ?? this.xMm,
      yMm: yMm ?? this.yMm,
      actief: actief ?? this.actief,
      gekoppeldAanKaderId: identical(gekoppeldAanKaderId, _ongewijzigd)
          ? this.gekoppeldAanKaderId
          : gekoppeldAanKaderId as String?,
      gekoppeldeZijde: identical(gekoppeldeZijde, _ongewijzigd)
          ? this.gekoppeldeZijde
          : gekoppeldeZijde as OpmetingKaderZijde?,
      uitlijning: uitlijning ?? this.uitlijning,
      vrijeOffsetMm: vrijeOffsetMm ?? this.vrijeOffsetMm,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'naam': naam,
      'breedteMm': breedteMm,
      'hoogteMm': hoogteMm,
      'xMm': xMm,
      'yMm': yMm,
      'actief': actief,
      'gekoppeldAanKaderId': gekoppeldAanKaderId,
      'gekoppeldeZijde': gekoppeldeZijde?.opslagWaarde,
      'uitlijning': uitlijning.opslagWaarde,
      'vrijeOffsetMm': vrijeOffsetMm,
    };
  }

  factory OpmetingKaderDeel.fromJson(Map<String, dynamic> json) {
    return OpmetingKaderDeel(
      id: json['id']?.toString() ?? '',
      naam: json['naam']?.toString() ?? '',
      breedteMm: _leesInt(json['breedteMm'], standaardWaarde: 1000),
      hoogteMm: _leesInt(json['hoogteMm'], standaardWaarde: 2000),
      xMm: _leesInt(json['xMm']),
      yMm: _leesInt(json['yMm']),
      actief: json['actief'] != false,
      gekoppeldAanKaderId: json['gekoppeldAanKaderId']?.toString(),
      gekoppeldeZijde: OpmetingKaderZijdeExtension.vanOpslagWaarde(
        json['gekoppeldeZijde'],
      ),
      uitlijning: OpmetingKaderUitlijningExtension.vanOpslagWaarde(
        json['uitlijning'],
      ),
      vrijeOffsetMm: _leesInt(json['vrijeOffsetMm']),
    );
  }
}

class OpmetingKaderSamenstelling {
  const OpmetingKaderSamenstelling({
    required this.kaders,
    required this.actiefKaderId,
    this.slagLinksMm = 0,
    this.slagRechtsMm = 0,
    this.slagBovenMm = 0,
    this.slagOnderMm = 0,
  });

  final List<OpmetingKaderDeel> kaders;
  final String actiefKaderId;

  /// Slag hoort bij de volledige samenstelling,
  /// niet bij de interne aansluiting tussen twee kaders.
  final int slagLinksMm;
  final int slagRechtsMm;
  final int slagBovenMm;
  final int slagOnderMm;

  factory OpmetingKaderSamenstelling.basis({
    required int breedteMm,
    required int hoogteMm,
    int slagLinksMm = 0,
    int slagRechtsMm = 0,
    int slagBovenMm = 0,
    int slagOnderMm = 0,
  }) {
    const kaderId = 'kader_basis';

    return OpmetingKaderSamenstelling(
      actiefKaderId: kaderId,
      slagLinksMm: slagLinksMm,
      slagRechtsMm: slagRechtsMm,
      slagBovenMm: slagBovenMm,
      slagOnderMm: slagOnderMm,
      kaders: <OpmetingKaderDeel>[
        OpmetingKaderDeel(
          id: kaderId,
          naam: 'Kader 1',
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
        ),
      ],
    );
  }

  OpmetingKaderDeel? get actiefKader {
    for (final kader in kaders) {
      if (kader.id == actiefKaderId) {
        return kader;
      }
    }

    if (kaders.isNotEmpty) {
      return kaders.first;
    }

    return null;
  }

  OpmetingKaderSamenstelling copyWith({
    List<OpmetingKaderDeel>? kaders,
    String? actiefKaderId,
    int? slagLinksMm,
    int? slagRechtsMm,
    int? slagBovenMm,
    int? slagOnderMm,
  }) {
    final nieuweKaders = kaders ?? this.kaders;

    var nieuwActiefKaderId = actiefKaderId ?? this.actiefKaderId;

    final bestaatActiefKader = nieuweKaders.any(
      (kader) => kader.id == nieuwActiefKaderId,
    );

    if (!bestaatActiefKader && nieuweKaders.isNotEmpty) {
      nieuwActiefKaderId = nieuweKaders.first.id;
    }

    return OpmetingKaderSamenstelling(
      kaders: List<OpmetingKaderDeel>.unmodifiable(nieuweKaders),
      actiefKaderId: nieuwActiefKaderId,
      slagLinksMm: slagLinksMm ?? this.slagLinksMm,
      slagRechtsMm: slagRechtsMm ?? this.slagRechtsMm,
      slagBovenMm: slagBovenMm ?? this.slagBovenMm,
      slagOnderMm: slagOnderMm ?? this.slagOnderMm,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'kaders': kaders.map((kader) => kader.toJson()).toList(),
      'actiefKaderId': actiefKaderId,
      'slagLinksMm': slagLinksMm,
      'slagRechtsMm': slagRechtsMm,
      'slagBovenMm': slagBovenMm,
      'slagOnderMm': slagOnderMm,
    };
  }

  factory OpmetingKaderSamenstelling.fromJson(Map<String, dynamic> json) {
    final ruweKaders = json['kaders'];

    final kaders = ruweKaders is List
        ? ruweKaders
              .whereType<Map>()
              .map(
                (kader) => OpmetingKaderDeel.fromJson(
                  Map<String, dynamic>.from(kader),
                ),
              )
              .where(
                (kader) =>
                    kader.id.trim().isNotEmpty &&
                    kader.breedteMm > 0 &&
                    kader.hoogteMm > 0,
              )
              .toList()
        : <OpmetingKaderDeel>[];

    final samenstelling = OpmetingKaderSamenstelling(
      kaders: List<OpmetingKaderDeel>.unmodifiable(kaders),
      actiefKaderId: json['actiefKaderId']?.toString() ?? '',
      slagLinksMm: _leesInt(json['slagLinksMm']),
      slagRechtsMm: _leesInt(json['slagRechtsMm']),
      slagBovenMm: _leesInt(json['slagBovenMm']),
      slagOnderMm: _leesInt(json['slagOnderMm']),
    );

    return samenstelling.copyWith();
  }
}

int _leesInt(Object? waarde, {int standaardWaarde = 0}) {
  if (waarde is int) {
    return waarde;
  }

  if (waarde is num) {
    return waarde.toInt();
  }

  return int.tryParse(waarde?.toString().trim() ?? '') ?? standaardWaarde;
}
