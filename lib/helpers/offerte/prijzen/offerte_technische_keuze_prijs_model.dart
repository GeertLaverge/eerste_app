// THIMACO-CONTROLE: CENTRALE-TECHNISCHE-KEUZEPRIJS-MODEL-20260815
import 'offerte_artikel_prijs_data_model.dart';
import 'offerte_technische_keuze_overeenkomst_helper.dart';
import 'offerte_technische_keuze_ref.dart';

/// Eén centrale prijsinstelling voor één technische keuze.
///
/// De sleutel is bewust fiche-onafhankelijk. Wanneer dezelfde keuze via
/// "Keuze opladen" in PVC raam, ALU raam, deur, ... voorkomt, wordt dezelfde
/// prijsinstelling gebruikt.
///
/// Dit is uitsluitend de centrale instelling. De uiteindelijke offerte bewaart
/// later een eigen momentopname zodat een prijswijziging in Instellingen een
/// bestaande offerte niet achteraf verandert.
class OfferteTechnischeKeuzePrijsModel {
  const OfferteTechnischeKeuzePrijsModel({
    required this.id,
    required this.technischeKeuze,
    this.type = OffertePrijsPerPositieType.verkoop,
    this.eenheid = 'st',
    this.prijsExclBtw = 0.0,
    double winstPercentage = 0.0,
    this.offerteWeergave = OffertePrijsPerPositieWeergave.uit,
    this.gewijzigdOp = '',
  }) : winstPercentage = type == OffertePrijsPerPositieType.verkoop
           ? 0.0
           : winstPercentage;

  final String id;
  final OfferteTechnischeKeuzeRef technischeKeuze;
  final OffertePrijsPerPositieType type;
  final String eenheid;
  final double prijsExclBtw;
  final double winstPercentage;
  final OffertePrijsPerPositieWeergave offerteWeergave;
  final String gewijzigdOp;

  bool get isAankoop => type.isAankoop;
  bool get isVerkoop => type.isVerkoop;

  double get veiligePrijsExclBtw {
    if (!prijsExclBtw.isFinite || prijsExclBtw < 0.0) {
      return 0.0;
    }
    return _rondBedragAf(prijsExclBtw);
  }

  double get veiligWinstPercentage {
    if (isVerkoop || !winstPercentage.isFinite || winstPercentage <= 0.0) {
      return 0.0;
    }
    return winstPercentage.clamp(0.0, 999.99).toDouble();
  }

  bool get heeftPrijs => veiligePrijsExclBtw > 0.0;

  String get omschrijving {
    final uitschrijftekst = technischeKeuze.hoeUitschrijven.trim();
    if (uitschrijftekst.isNotEmpty) {
      return uitschrijftekst;
    }
    return technischeKeuze.keuzeTitelMomentopname.trim();
  }

  double get verkoopPrijsPerEenheidExclBtw {
    if (!isAankoop) {
      return veiligePrijsExclBtw;
    }
    return _rondBedragAf(
      veiligePrijsExclBtw * (1.0 + (veiligWinstPercentage / 100.0)),
    );
  }

  bool get isGeldig {
    if (id.trim().isEmpty || technischeKeuze.isLeeg) {
      return false;
    }
    return technischeKeuze.keuzeId.trim().isNotEmpty;
  }

  OfferteTechnischeKeuzePrijsModel copyWith({
    String? id,
    OfferteTechnischeKeuzeRef? technischeKeuze,
    OffertePrijsPerPositieType? type,
    String? eenheid,
    double? prijsExclBtw,
    double? winstPercentage,
    OffertePrijsPerPositieWeergave? offerteWeergave,
    String? gewijzigdOp,
  }) {
    final nieuwType = type ?? this.type;
    return OfferteTechnischeKeuzePrijsModel(
      id: id ?? this.id,
      technischeKeuze: technischeKeuze ?? this.technischeKeuze,
      type: nieuwType,
      eenheid: eenheid ?? this.eenheid,
      prijsExclBtw: prijsExclBtw ?? this.prijsExclBtw,
      winstPercentage: nieuwType.isVerkoop
          ? 0.0
          : (winstPercentage ?? this.winstPercentage),
      offerteWeergave: offerteWeergave ?? this.offerteWeergave,
      gewijzigdOp: gewijzigdOp ?? this.gewijzigdOp,
    );
  }

  OfferteTechnischeKeuzePrijsModel metWijzigingsDatum() {
    return copyWith(gewijzigdOp: DateTime.now().toUtc().toIso8601String());
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'technischeKeuze': technischeKeuze.toJson(),
      'type': type.jsonWaarde,
      'eenheid': eenheid,
      'prijsExclBtw': veiligePrijsExclBtw,
      'winstPercentage': veiligWinstPercentage,
      'offerteWeergave': offerteWeergave.jsonWaarde,
      'gewijzigdOp': gewijzigdOp,
    };
  }

  factory OfferteTechnischeKeuzePrijsModel.fromJson(Map<String, dynamic> json) {
    final keuze =
        OfferteTechnischeKeuzeRef.fromJsonWaarde(json['technischeKeuze']) ??
        const OfferteTechnischeKeuzeRef();
    var id = json['id']?.toString().trim() ?? '';
    if (id.isEmpty && !keuze.isLeeg) {
      id =
          OfferteTechnischeKeuzeOvereenkomstHelper.exacteSleutelTussenArtikeltypesVan(
            keuze,
          );
    }

    return OfferteTechnischeKeuzePrijsModel(
      id: id,
      technischeKeuze: keuze,
      type: OffertePrijsPerPositieType.fromJson(json['type']),
      eenheid: json['eenheid']?.toString().trim() ?? 'st',
      prijsExclBtw: _leesDouble(json['prijsExclBtw']),
      winstPercentage: _leesDouble(json['winstPercentage']),
      offerteWeergave: OffertePrijsPerPositieWeergave.fromJson(
        json['offerteWeergave'],
      ),
      gewijzigdOp: json['gewijzigdOp']?.toString() ?? '',
    );
  }

  static double _leesDouble(Object? waarde) {
    if (waarde is num) {
      return waarde.toDouble();
    }
    return double.tryParse(
          waarde?.toString().trim().replaceAll(',', '.') ?? '',
        ) ??
        0.0;
  }

  static double _rondBedragAf(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) {
      return 0.0;
    }
    return (waarde * 100.0).roundToDouble() / 100.0;
  }
}
