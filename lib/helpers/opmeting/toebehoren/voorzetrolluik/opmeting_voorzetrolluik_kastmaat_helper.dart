// THIMACO-CONTROLE: VOORZETROLLUIK-KASTMAAT-HOOGTE-LAMEL-AS-BEDIENING-20260731-1105
import 'opmeting_voorzetrolluik_model.dart';

class OpmetingVoorzetrolluikKasttabelKolom {
  const OpmetingVoorzetrolluikKasttabelKolom({
    required this.lamelType,
    required this.asDiameterMm,
    required this.bronIndex,
  });

  final String lamelType;
  final int asDiameterMm;

  /// Kolom uit de oorspronkelijke Wilms-tabel waarop deze zichtbare
  /// lamel/as-combinatie is gebaseerd.
  final int bronIndex;

  String get sleutel => '$lamelType|$asDiameterMm';
  String get label => '$lamelType · as $asDiameterMm';
}

class OpmetingVoorzetrolluikKasttabelRij {
  const OpmetingVoorzetrolluikKasttabelRij({
    required this.hoogteMm,
    required this.kastmatenMm,
  });

  final int hoogteMm;
  final List<int> kastmatenMm;
}

class OpmetingVoorzetrolluikKastmaatHelper {
  const OpmetingVoorzetrolluikKastmaatHelper._();

  static const int minimumTabelHoogteMm = 500;
  static const int maximumTabelHoogteMm = 3000;

  static const List<String> lamelTypes = <String>[
    'WA39',
    'WA39H',
    'WA55',
    'WA55H',
    'WP37',
  ];

  /// Lint gebruikt altijd as 40 mm. Elektrisch gebruikt as 60 mm, behalve
  /// de H-lamellen: daarvoor wordt de beschikbare as 70 mm gebruikt.
  static int asDiameterVoor({
    required String lamelType,
    required OpmetingVoorzetrolluikBediening bediening,
  }) {
    if (bediening == OpmetingVoorzetrolluikBediening.lint) return 40;

    final lamel = normaliseerLamelType(lamelType);
    return lamel.endsWith('H') ? 70 : 60;
  }

  /// De zichtbare tabel gebruikt de actuele lamelbenamingen. WA39H gebruikt
  /// dezelfde kastwaarden als WA39. WA55 en WA55H gebruiken de bijbehorende
  /// grotere-lamellenkolommen uit de aangeleverde Wilms-tabel.
  static const List<OpmetingVoorzetrolluikKasttabelKolom> kolommen =
      <OpmetingVoorzetrolluikKasttabelKolom>[
        OpmetingVoorzetrolluikKasttabelKolom(
          lamelType: 'WA39',
          asDiameterMm: 40,
          bronIndex: 2,
        ),
        OpmetingVoorzetrolluikKasttabelKolom(
          lamelType: 'WA39',
          asDiameterMm: 60,
          bronIndex: 3,
        ),
        OpmetingVoorzetrolluikKasttabelKolom(
          lamelType: 'WA39',
          asDiameterMm: 70,
          bronIndex: 4,
        ),
        OpmetingVoorzetrolluikKasttabelKolom(
          lamelType: 'WA39H',
          asDiameterMm: 40,
          bronIndex: 2,
        ),
        OpmetingVoorzetrolluikKasttabelKolom(
          lamelType: 'WA39H',
          asDiameterMm: 60,
          bronIndex: 3,
        ),
        OpmetingVoorzetrolluikKasttabelKolom(
          lamelType: 'WA39H',
          asDiameterMm: 70,
          bronIndex: 4,
        ),
        OpmetingVoorzetrolluikKasttabelKolom(
          lamelType: 'WA55',
          asDiameterMm: 40,
          bronIndex: 5,
        ),
        OpmetingVoorzetrolluikKasttabelKolom(
          lamelType: 'WA55',
          asDiameterMm: 60,
          bronIndex: 6,
        ),
        OpmetingVoorzetrolluikKasttabelKolom(
          lamelType: 'WA55H',
          asDiameterMm: 40,
          bronIndex: 5,
        ),
        OpmetingVoorzetrolluikKasttabelKolom(
          lamelType: 'WA55H',
          asDiameterMm: 70,
          bronIndex: 7,
        ),
        OpmetingVoorzetrolluikKasttabelKolom(
          lamelType: 'WP37',
          asDiameterMm: 40,
          bronIndex: 0,
        ),
        OpmetingVoorzetrolluikKasttabelKolom(
          lamelType: 'WP37',
          asDiameterMm: 60,
          bronIndex: 1,
        ),
      ];

  static final List<OpmetingVoorzetrolluikKasttabelRij> rijen =
      List<OpmetingVoorzetrolluikKasttabelRij>.unmodifiable(
        _bronRijen.map((bronRij) {
          return OpmetingVoorzetrolluikKasttabelRij(
            hoogteMm: bronRij.hoogteMm,
            kastmatenMm: List<int>.unmodifiable(
              kolommen.map((kolom) => bronRij.kastmatenMm[kolom.bronIndex]),
            ),
          );
        }),
      );

  static const List<OpmetingVoorzetrolluikKasttabelRij> _bronRijen =
      <OpmetingVoorzetrolluikKasttabelRij>[
        OpmetingVoorzetrolluikKasttabelRij(
          hoogteMm: 500,
          kastmatenMm: <int>[150, 150, 150, 150, 150, 150, 150, 150],
        ),
        OpmetingVoorzetrolluikKasttabelRij(
          hoogteMm: 600,
          kastmatenMm: <int>[150, 150, 150, 150, 150, 150, 150, 150],
        ),
        OpmetingVoorzetrolluikKasttabelRij(
          hoogteMm: 700,
          kastmatenMm: <int>[150, 150, 150, 150, 150, 150, 150, 150],
        ),
        OpmetingVoorzetrolluikKasttabelRij(
          hoogteMm: 800,
          kastmatenMm: <int>[150, 150, 150, 150, 150, 150, 150, 150],
        ),
        OpmetingVoorzetrolluikKasttabelRij(
          hoogteMm: 900,
          kastmatenMm: <int>[150, 150, 150, 150, 150, 150, 150, 150],
        ),
        OpmetingVoorzetrolluikKasttabelRij(
          hoogteMm: 1000,
          kastmatenMm: <int>[150, 150, 150, 150, 150, 150, 150, 150],
        ),
        OpmetingVoorzetrolluikKasttabelRij(
          hoogteMm: 1100,
          kastmatenMm: <int>[150, 150, 150, 150, 150, 165, 165, 165],
        ),
        OpmetingVoorzetrolluikKasttabelRij(
          hoogteMm: 1200,
          kastmatenMm: <int>[150, 150, 150, 150, 165, 165, 165, 165],
        ),
        OpmetingVoorzetrolluikKasttabelRij(
          hoogteMm: 1300,
          kastmatenMm: <int>[150, 150, 150, 150, 165, 165, 165, 180],
        ),
        OpmetingVoorzetrolluikKasttabelRij(
          hoogteMm: 1400,
          kastmatenMm: <int>[150, 150, 150, 150, 165, 165, 165, 180],
        ),
        OpmetingVoorzetrolluikKasttabelRij(
          hoogteMm: 1500,
          kastmatenMm: <int>[150, 150, 150, 150, 165, 180, 180, 180],
        ),
        OpmetingVoorzetrolluikKasttabelRij(
          hoogteMm: 1600,
          kastmatenMm: <int>[150, 150, 150, 165, 180, 180, 180, 180],
        ),
        OpmetingVoorzetrolluikKasttabelRij(
          hoogteMm: 1700,
          kastmatenMm: <int>[150, 165, 165, 165, 180, 180, 180, 180],
        ),
        OpmetingVoorzetrolluikKasttabelRij(
          hoogteMm: 1800,
          kastmatenMm: <int>[150, 165, 165, 165, 180, 180, 180, 180],
        ),
        OpmetingVoorzetrolluikKasttabelRij(
          hoogteMm: 1900,
          kastmatenMm: <int>[150, 165, 165, 165, 180, 205, 205, 205],
        ),
        OpmetingVoorzetrolluikKasttabelRij(
          hoogteMm: 2000,
          kastmatenMm: <int>[165, 165, 165, 165, 180, 205, 205, 205],
        ),
        OpmetingVoorzetrolluikKasttabelRij(
          hoogteMm: 2100,
          kastmatenMm: <int>[165, 180, 180, 165, 180, 205, 205, 205],
        ),
        OpmetingVoorzetrolluikKasttabelRij(
          hoogteMm: 2200,
          kastmatenMm: <int>[165, 180, 180, 180, 180, 205, 205, 205],
        ),
        OpmetingVoorzetrolluikKasttabelRij(
          hoogteMm: 2300,
          kastmatenMm: <int>[165, 180, 180, 180, 180, 205, 205, 205],
        ),
        OpmetingVoorzetrolluikKasttabelRij(
          hoogteMm: 2400,
          kastmatenMm: <int>[180, 180, 180, 180, 205, 205, 205, 205],
        ),
        OpmetingVoorzetrolluikKasttabelRij(
          hoogteMm: 2500,
          kastmatenMm: <int>[180, 180, 180, 180, 205, 205, 205, 230],
        ),
        OpmetingVoorzetrolluikKasttabelRij(
          hoogteMm: 2600,
          kastmatenMm: <int>[180, 180, 180, 180, 205, 205, 205, 230],
        ),
        OpmetingVoorzetrolluikKasttabelRij(
          hoogteMm: 2700,
          kastmatenMm: <int>[180, 180, 180, 180, 205, 205, 230, 230],
        ),
        OpmetingVoorzetrolluikKasttabelRij(
          hoogteMm: 2800,
          kastmatenMm: <int>[180, 205, 180, 205, 205, 230, 230, 230],
        ),
        OpmetingVoorzetrolluikKasttabelRij(
          hoogteMm: 2900,
          kastmatenMm: <int>[180, 205, 205, 205, 205, 230, 230, 230],
        ),
        OpmetingVoorzetrolluikKasttabelRij(
          hoogteMm: 3000,
          kastmatenMm: <int>[180, 205, 205, 205, 205, 230, 230, 230],
        ),
      ];

  static int vereisteKastmaatMm({
    required String lamelType,
    required OpmetingVoorzetrolluikBediening bediening,
    required int hoogteMm,
  }) {
    final lamel = normaliseerLamelType(lamelType);
    final asDiameter = asDiameterVoor(lamelType: lamel, bediening: bediening);
    final kolomIndex = kolommen.indexWhere(
      (kolom) => kolom.lamelType == lamel && kolom.asDiameterMm == asDiameter,
    );
    if (kolomIndex < 0) return 150;

    final tabelHoogte = _rondHoogteNaarBovenAf(hoogteMm);
    final rij = rijen.firstWhere(
      (item) => item.hoogteMm == tabelHoogte,
      orElse: () => rijen.last,
    );
    return rij.kastmatenMm[kolomIndex];
  }

  static OpmetingVoorzetrolluikKastmaat vereisteKastmaat({
    required String lamelType,
    required OpmetingVoorzetrolluikBediening bediening,
    required int hoogteMm,
  }) {
    return OpmetingVoorzetrolluikKastmaatExtension.vanMillimeter(
      vereisteKastmaatMm(
        lamelType: lamelType,
        bediening: bediening,
        hoogteMm: hoogteMm,
      ),
    );
  }

  static bool isTeKlein({
    required OpmetingVoorzetrolluikKastmaat gekozen,
    required String lamelType,
    required OpmetingVoorzetrolluikBediening bediening,
    required int hoogteMm,
  }) {
    return gekozen.millimeter <
        vereisteKastmaatMm(
          lamelType: lamelType,
          bediening: bediening,
          hoogteMm: hoogteMm,
        );
  }

  static String normaliseerLamelType(String waarde) {
    final schoon = waarde.trim().toUpperCase();
    if (lamelTypes.contains(schoon)) return schoon;

    // Veilige migratie van de voorlopige benamingen uit fase 1.
    return switch (schoon) {
      'WA40' => 'WA55',
      'WA40H' => 'WA55H',
      _ => 'WA39',
    };
  }

  static int _rondHoogteNaarBovenAf(int hoogteMm) {
    final begrensd = hoogteMm.clamp(minimumTabelHoogteMm, maximumTabelHoogteMm);
    final honderdtal = ((begrensd + 99) ~/ 100) * 100;
    return honderdtal.clamp(minimumTabelHoogteMm, maximumTabelHoogteMm);
  }
}
