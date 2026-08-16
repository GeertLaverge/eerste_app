// THIMACO-CONTROLE: PRIJS-VERDEELD-OVER-VOLLEDIG-IN-INSTELLINGEN-20260815
// THIMACO-CONTROLE: PRIJS-VERDEELD-OVER-BIBLIOTHEEK-MODEL-20260815
import 'offerte_artikel_prijs_data_model.dart';

/// Volledige automatische instelling voor "Prijzen verdeeld over…".
///
/// Alles wat nodig is om een verdeelkost toe te passen staat in dit centrale
/// sjabloon: bedrag, fichetypes, maximum offertebedrag, A/V, winstmarge en
/// zichtbaarheid. Concrete offertes hoeven daardoor geen handmatige
/// verdeelkeuze meer te tonen.
class OffertePrijsVerdeeldOverTemplateModel {
  const OffertePrijsVerdeeldOverTemplateModel({
    required this.id,
    required this.omschrijving,
    this.type = OffertePrijsPerPositieType.aankoop,
    this.teVerdelenBedragExclBtw = 0,
    this.maximaalTotaalExclBtw = 0,
    this.formulierTypes = const <String>{},
    double standaardWinstPercentage = 0,
    this.offerteWeergave = OffertePrijsPerPositieWeergave.uit,
    this.volgorde = 0,
    this.gewijzigdOp = '',
  }) : standaardWinstPercentage = type == OffertePrijsPerPositieType.verkoop
           ? 0
           : standaardWinstPercentage;

  final String id;
  final String omschrijving;
  final OffertePrijsPerPositieType type;

  /// Het totale bedrag dat over de passende posities verdeeld wordt.
  final double teVerdelenBedragExclBtw;

  /// Maximum van het gezamenlijke positietotaal excl. btw waarvoor deze regel
  /// geldt. 0 betekent bewust: geen maximum.
  final double maximaalTotaalExclBtw;

  /// Genormaliseerde formulierTypes waarop deze regel betrekking heeft.
  final Set<String> formulierTypes;

  final double standaardWinstPercentage;
  final OffertePrijsPerPositieWeergave offerteWeergave;
  final int volgorde;
  final String gewijzigdOp;

  bool get isAankoop => type.isAankoop;
  bool get isVerkoop => type.isVerkoop;

  double get veiligTeVerdelenBedragExclBtw {
    return _normaliseerBedrag(teVerdelenBedragExclBtw);
  }

  double get veiligMaximaalTotaalExclBtw {
    return _normaliseerBedrag(maximaalTotaalExclBtw);
  }

  bool get heeftMaximumTotaal => veiligMaximaalTotaalExclBtw > 0.0;

  double get veiligeStandaardWinstPercentage {
    if (isVerkoop) {
      return 0.0;
    }
    return _normaliseerPercentage(standaardWinstPercentage);
  }

  /// Oude bibliotheekrecords zonder de nieuwe automatische velden blijven
  /// zichtbaar in Instellingen zodat ze daar aangevuld kunnen worden.
  bool get isGeldig {
    return id.trim().isNotEmpty && omschrijving.trim().isNotEmpty;
  }

  bool get isAutomatischGeldig {
    return isGeldig &&
        veiligTeVerdelenBedragExclBtw > 0.0 &&
        formulierTypes.isNotEmpty;
  }

  bool pastBijFormulierType(String formulierType) {
    final sleutel = formulierType.trim();
    return sleutel.isNotEmpty && formulierTypes.contains(sleutel);
  }

  OffertePrijsVerdeeldOverTemplateModel copyWith({
    String? id,
    String? omschrijving,
    OffertePrijsPerPositieType? type,
    double? teVerdelenBedragExclBtw,
    double? maximaalTotaalExclBtw,
    Set<String>? formulierTypes,
    double? standaardWinstPercentage,
    OffertePrijsPerPositieWeergave? offerteWeergave,
    int? volgorde,
    String? gewijzigdOp,
  }) {
    final nieuwType = type ?? this.type;
    final nieuweWinst = nieuwType.isVerkoop
        ? 0.0
        : (standaardWinstPercentage ?? this.standaardWinstPercentage);

    return OffertePrijsVerdeeldOverTemplateModel(
      id: id ?? this.id,
      omschrijving: omschrijving ?? this.omschrijving,
      type: nieuwType,
      teVerdelenBedragExclBtw:
          teVerdelenBedragExclBtw ?? this.teVerdelenBedragExclBtw,
      maximaalTotaalExclBtw:
          maximaalTotaalExclBtw ?? this.maximaalTotaalExclBtw,
      formulierTypes: Set<String>.unmodifiable(
        formulierTypes ?? this.formulierTypes,
      ),
      standaardWinstPercentage: nieuweWinst,
      offerteWeergave: offerteWeergave ?? this.offerteWeergave,
      volgorde: volgorde ?? this.volgorde,
      gewijzigdOp: gewijzigdOp ?? this.gewijzigdOp,
    );
  }

  OffertePrijsVerdeeldOverTemplateModel metWijzigingsDatum() {
    return copyWith(gewijzigdOp: DateTime.now().toUtc().toIso8601String());
  }

  Map<String, dynamic> toJson() {
    final types =
        formulierTypes
            .map((waarde) => waarde.trim())
            .where((waarde) => waarde.isNotEmpty)
            .toSet()
            .toList(growable: false)
          ..sort();

    return <String, dynamic>{
      'id': id.trim(),
      'omschrijving': omschrijving.trim(),
      'type': type.jsonWaarde,
      'teVerdelenBedragExclBtw': veiligTeVerdelenBedragExclBtw,
      'maximaalTotaalExclBtw': veiligMaximaalTotaalExclBtw,
      'formulierTypes': types,
      'standaardWinstPercentage': veiligeStandaardWinstPercentage,
      'offerteWeergave': offerteWeergave.jsonWaarde,
      'volgorde': volgorde,
      'gewijzigdOp': gewijzigdOp,
    };
  }

  factory OffertePrijsVerdeeldOverTemplateModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = OffertePrijsPerPositieType.fromJson(json['type']);

    return OffertePrijsVerdeeldOverTemplateModel(
      id: json['id']?.toString().trim() ?? '',
      omschrijving: json['omschrijving']?.toString().trim() ?? '',
      type: type,
      teVerdelenBedragExclBtw: _leesDouble(
        json['teVerdelenBedragExclBtw'] ?? json['bedragExclBtw'],
      ),
      maximaalTotaalExclBtw: _leesDouble(
        json['maximaalTotaalExclBtw'] ?? json['toepassenTotExclBtw'],
      ),
      formulierTypes: _leesStringSet(
        json['formulierTypes'] ?? json['ficheTypes'],
      ),
      standaardWinstPercentage: type.isVerkoop
          ? 0.0
          : _leesDouble(json['standaardWinstPercentage']),
      offerteWeergave: OffertePrijsPerPositieWeergave.fromJson(
        json['offerteWeergave'],
      ),
      volgorde: _leesInt(json['volgorde']),
      gewijzigdOp: json['gewijzigdOp']?.toString().trim() ?? '',
    );
  }

  static Set<String> _leesStringSet(Object? waarde) {
    if (waarde is! List) {
      return const <String>{};
    }
    return Set<String>.unmodifiable(
      waarde
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toSet(),
    );
  }

  static int _leesInt(Object? waarde) {
    if (waarde is int) {
      return waarde;
    }
    if (waarde is num) {
      return waarde.toInt();
    }
    return int.tryParse(waarde?.toString().trim() ?? '') ?? 0;
  }

  static double _leesDouble(Object? waarde) {
    if (waarde is double) {
      return waarde.isFinite ? waarde : 0.0;
    }
    if (waarde is num) {
      final getal = waarde.toDouble();
      return getal.isFinite ? getal : 0.0;
    }

    final gelezen = double.tryParse(
      waarde?.toString().trim().replaceAll(',', '.') ?? '',
    );
    return gelezen != null && gelezen.isFinite ? gelezen : 0.0;
  }

  static double _normaliseerBedrag(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) {
      return 0.0;
    }
    return (waarde * 100.0).roundToDouble() / 100.0;
  }

  static double _normaliseerPercentage(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) {
      return 0.0;
    }
    if (waarde >= 500.0) {
      return 500.0;
    }
    return (waarde * 100.0).roundToDouble() / 100.0;
  }
}

/// Centrale lijst van alle opmeetfichetypes die in de huidige app voorkomen.
/// De IDs zijn dezelfde genormaliseerde formulierType-waarden als in het opmetingsoverzicht.
class OffertePrijsVerdeeldOverFicheType {
  const OffertePrijsVerdeeldOverFicheType(this.id, this.label);

  final String id;
  final String label;

  static const List<OffertePrijsVerdeeldOverFicheType>
  alle = <OffertePrijsVerdeeldOverFicheType>[
    OffertePrijsVerdeeldOverFicheType('pvcRaam', 'PVC Raam'),
    OffertePrijsVerdeeldOverFicheType('aluRaam', 'ALU Raam'),
    OffertePrijsVerdeeldOverFicheType('pvcSchuifraam', 'PVC Schuifraam'),
    OffertePrijsVerdeeldOverFicheType('aluSchuifraam', 'ALU Schuifraam'),
    OffertePrijsVerdeeldOverFicheType('pvcDeur', 'PVC Deur'),
    OffertePrijsVerdeeldOverFicheType('aluDeur', 'ALU Deur'),
    OffertePrijsVerdeeldOverFicheType('vasteInzethor', 'Vaste inzethor'),
    OffertePrijsVerdeeldOverFicheType('vliegendeur', 'Vliegendeur'),
    OffertePrijsVerdeeldOverFicheType('schuifvliegendeur', 'Schuifvliegendeur'),
    OffertePrijsVerdeeldOverFicheType('plooiwerken', 'Plooiwerken'),
    OffertePrijsVerdeeldOverFicheType('voorzetscreen', 'Voorzetscreen'),
    OffertePrijsVerdeeldOverFicheType('buitenjaloezie', 'Buitenjaloezie'),
    OffertePrijsVerdeeldOverFicheType('voorzetrolluik', 'Voorzetrolluik'),
    OffertePrijsVerdeeldOverFicheType('uitvalscherm', 'Uitvalscherm'),
    OffertePrijsVerdeeldOverFicheType('algemeneOpmeting', 'Algemene opmeting'),
    OffertePrijsVerdeeldOverFicheType('sektionalePoort', 'Sektionale poorten'),
    OffertePrijsVerdeeldOverFicheType('veluxDakraam', 'Velux dakramen'),
  ];

  static String labelVoor(String id) {
    final sleutel = id.trim();
    for (final type in alle) {
      if (type.id == sleutel) {
        return type.label;
      }
    }
    return sleutel;
  }
}
