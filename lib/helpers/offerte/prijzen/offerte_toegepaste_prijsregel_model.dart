import 'offerte_prijs_categorie.dart';
import 'offerte_prijs_eenheid.dart';
import 'offerte_prijs_uitschrijfmodus.dart';
import 'offerte_technische_keuze_ref.dart';

class OfferteToegepastePrijsregelModel {
  OfferteToegepastePrijsregelModel({
    required String bronPrijsregelId,
    required this.categorie,
    required String omschrijving,
    required double prijsExclBtw,
    required this.eenheid,
    required double hoeveelheid,
    required double totaalExclBtw,
    required this.uitschrijfmodus,
    this.technischeKeuze,
    int verdeeldOverAantalArtikelen = 0,
    double projectPrijsExclBtw = 0,
    double aankoopTotaalVoorVerdelingExclBtw = 0,
    double verdeelLimietBedragExclBtw = 0,
    String bronGewijzigdOp = '',
    String berekendOp = '',
  }) : bronPrijsregelId = bronPrijsregelId.trim(),
       omschrijving = omschrijving.trim(),
       prijsExclBtw = _normaliseerGetal(prijsExclBtw),
       hoeveelheid = _normaliseerGetal(hoeveelheid),
       totaalExclBtw = _normaliseerGetal(totaalExclBtw),
       verdeeldOverAantalArtikelen = verdeeldOverAantalArtikelen < 0
           ? 0
           : verdeeldOverAantalArtikelen,
       projectPrijsExclBtw = _normaliseerGetal(projectPrijsExclBtw),
       aankoopTotaalVoorVerdelingExclBtw = _normaliseerGetal(
         aankoopTotaalVoorVerdelingExclBtw,
       ),
       verdeelLimietBedragExclBtw = _normaliseerGetal(
         verdeelLimietBedragExclBtw,
       ),
       bronGewijzigdOp = bronGewijzigdOp.trim(),
       berekendOp = berekendOp.trim();

  final String bronPrijsregelId;
  final OffertePrijsCategorie categorie;
  final String omschrijving;
  final double prijsExclBtw;
  final OffertePrijsEenheid eenheid;
  final double hoeveelheid;
  final double totaalExclBtw;
  final OffertePrijsUitschrijfmodus uitschrijfmodus;
  final OfferteTechnischeKeuzeRef? technischeKeuze;
  final int verdeeldOverAantalArtikelen;
  final double projectPrijsExclBtw;
  final double aankoopTotaalVoorVerdelingExclBtw;
  final double verdeelLimietBedragExclBtw;
  final String bronGewijzigdOp;
  final String berekendOp;

  bool get isGeldig {
    return bronPrijsregelId.isNotEmpty && omschrijving.isNotEmpty;
  }

  bool get isVerdeeldeProjectkost {
    return categorie == OffertePrijsCategorie.alleArtikelen &&
        uitschrijfmodus.isVerdeeldeInterneKost;
  }

  bool get toonOpOverzicht {
    return true;
  }

  /// Geeft aan of de omschrijving op de klantofferte zichtbaar mag zijn.
  bool get toonOpOfferte {
    return uitschrijfmodus.toonOmschrijvingOpOfferte;
  }

  /// Geeft aan dat alleen de omschrijving mag worden getoond.
  /// Het bedrag wordt wel in het eindtotaal verwerkt.
  bool get toonOmschrijvingZonderPrijsOpOfferte {
    return isGeldig &&
        !isOptie &&
        uitschrijfmodus.toonOmschrijvingOpOfferte &&
        !uitschrijfmodus.toonPrijsOpOfferte;
  }

  bool get isOptie {
    return uitschrijfmodus.isOptie;
  }

  /// Zichtbaarheid op de offerte heeft geen invloed op de berekening.
  /// Alleen een expliciete optie wordt niet in het eindtotaal opgenomen.
  bool get teltMeeInOfferteTotaal {
    return uitschrijfmodus.teltMeeInEindtotaal;
  }

  /// Alleen regels waarbij zowel omschrijving als bedrag zichtbaar mogen
  /// zijn, worden als afzonderlijke prijsregel uitgeschreven.
  bool get toonAfzonderlijkePrijsOpOfferte {
    return isGeldig &&
        !isOptie &&
        uitschrijfmodus.toonOmschrijvingOpOfferte &&
        uitschrijfmodus.toonPrijsOpOfferte;
  }

  bool get toonAlsOptieOpOfferte {
    return isGeldig && uitschrijfmodus.isOptie;
  }

  OfferteToegepastePrijsregelModel copyWith({
    String? bronPrijsregelId,
    OffertePrijsCategorie? categorie,
    String? omschrijving,
    double? prijsExclBtw,
    OffertePrijsEenheid? eenheid,
    double? hoeveelheid,
    double? totaalExclBtw,
    OffertePrijsUitschrijfmodus? uitschrijfmodus,
    OfferteTechnischeKeuzeRef? technischeKeuze,
    bool technischeKeuzeWissen = false,
    int? verdeeldOverAantalArtikelen,
    double? projectPrijsExclBtw,
    double? aankoopTotaalVoorVerdelingExclBtw,
    double? verdeelLimietBedragExclBtw,
    String? bronGewijzigdOp,
    String? berekendOp,
  }) {
    return OfferteToegepastePrijsregelModel(
      bronPrijsregelId: bronPrijsregelId ?? this.bronPrijsregelId,
      categorie: categorie ?? this.categorie,
      omschrijving: omschrijving ?? this.omschrijving,
      prijsExclBtw: prijsExclBtw ?? this.prijsExclBtw,
      eenheid: eenheid ?? this.eenheid,
      hoeveelheid: hoeveelheid ?? this.hoeveelheid,
      totaalExclBtw: totaalExclBtw ?? this.totaalExclBtw,
      uitschrijfmodus: uitschrijfmodus ?? this.uitschrijfmodus,
      technischeKeuze: technischeKeuzeWissen
          ? null
          : technischeKeuze ?? this.technischeKeuze,
      verdeeldOverAantalArtikelen:
          verdeeldOverAantalArtikelen ?? this.verdeeldOverAantalArtikelen,
      projectPrijsExclBtw: projectPrijsExclBtw ?? this.projectPrijsExclBtw,
      aankoopTotaalVoorVerdelingExclBtw:
          aankoopTotaalVoorVerdelingExclBtw ??
          this.aankoopTotaalVoorVerdelingExclBtw,
      verdeelLimietBedragExclBtw:
          verdeelLimietBedragExclBtw ?? this.verdeelLimietBedragExclBtw,
      bronGewijzigdOp: bronGewijzigdOp ?? this.bronGewijzigdOp,
      berekendOp: berekendOp ?? this.berekendOp,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'bronPrijsregelId': bronPrijsregelId,
      'categorie': categorie.jsonWaarde,
      'omschrijving': omschrijving,
      'prijsExclBtw': prijsExclBtw,
      'eenheid': eenheid.jsonWaarde,
      'hoeveelheid': hoeveelheid,
      'totaalExclBtw': totaalExclBtw,
      'uitschrijfmodus': uitschrijfmodus.jsonWaarde,
      'technischeKeuze': technischeKeuze?.toJson(),
      'verdeeldOverAantalArtikelen': verdeeldOverAantalArtikelen,
      'projectPrijsExclBtw': projectPrijsExclBtw,
      'aankoopTotaalVoorVerdelingExclBtw': aankoopTotaalVoorVerdelingExclBtw,
      'verdeelLimietBedragExclBtw': verdeelLimietBedragExclBtw,
      'bronGewijzigdOp': bronGewijzigdOp,
      'berekendOp': berekendOp,
    };
  }

  factory OfferteToegepastePrijsregelModel.fromJson(Map<String, dynamic> json) {
    return OfferteToegepastePrijsregelModel(
      bronPrijsregelId: json['bronPrijsregelId']?.toString() ?? '',
      categorie: OffertePrijsCategorie.fromJson(json['categorie']),
      omschrijving: json['omschrijving']?.toString() ?? '',
      prijsExclBtw: _leesDouble(json['prijsExclBtw']),
      eenheid: OffertePrijsEenheid.fromJson(json['eenheid']),
      hoeveelheid: _leesDouble(json['hoeveelheid']),
      totaalExclBtw: _leesDouble(json['totaalExclBtw']),
      uitschrijfmodus: OffertePrijsUitschrijfmodus.fromJson(
        json['uitschrijfmodus'],
      ),
      technischeKeuze: OfferteTechnischeKeuzeRef.fromJsonWaarde(
        json['technischeKeuze'],
      ),
      verdeeldOverAantalArtikelen: _leesInt(
        json['verdeeldOverAantalArtikelen'],
      ),
      projectPrijsExclBtw: _leesDouble(json['projectPrijsExclBtw']),
      aankoopTotaalVoorVerdelingExclBtw: _leesDouble(
        json['aankoopTotaalVoorVerdelingExclBtw'],
      ),
      verdeelLimietBedragExclBtw: _leesDouble(
        json['verdeelLimietBedragExclBtw'],
      ),
      bronGewijzigdOp: json['bronGewijzigdOp']?.toString() ?? '',
      berekendOp: json['berekendOp']?.toString() ?? '',
    );
  }

  static double _normaliseerGetal(double waarde) {
    if (!waarde.isFinite || waarde < 0) {
      return 0;
    }

    return waarde;
  }

  static double _leesDouble(Object? waarde) {
    if (waarde is num) {
      return _normaliseerGetal(waarde.toDouble());
    }

    return _normaliseerGetal(
      double.tryParse(waarde?.toString().trim().replaceAll(',', '.') ?? '') ??
          0,
    );
  }

  static int _leesInt(Object? waarde) {
    if (waarde is int) {
      return waarde < 0 ? 0 : waarde;
    }

    if (waarde is num) {
      final getal = waarde.toInt();
      return getal < 0 ? 0 : getal;
    }

    final getal = int.tryParse(waarde?.toString().trim() ?? '') ?? 0;
    return getal < 0 ? 0 : getal;
  }
}
