// THIMACO-CONTROLE: ALGEMENE-BIBLIOTHEEK-MODEL-20260802

class BibliotheekData {
  const BibliotheekData({required this.leveranciers});

  final List<BibliotheekLeverancier> leveranciers;

  factory BibliotheekData.leeg() {
    return const BibliotheekData(leveranciers: <BibliotheekLeverancier>[]);
  }

  BibliotheekData copyWith({List<BibliotheekLeverancier>? leveranciers}) {
    return BibliotheekData(
      leveranciers: List<BibliotheekLeverancier>.unmodifiable(
        leveranciers ?? this.leveranciers,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'versie': 3,
      'leveranciers': leveranciers
          .map((leverancier) => leverancier.toJson())
          .toList(growable: false),
    };
  }

  factory BibliotheekData.fromJson(Map<String, dynamic> json) {
    final ruweLeveranciers = json['leveranciers'];

    if (ruweLeveranciers is! List) {
      return BibliotheekData.leeg();
    }

    return BibliotheekData(
      leveranciers: ruweLeveranciers
          .whereType<Map>()
          .map(
            (item) => BibliotheekLeverancier.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where((leverancier) => leverancier.id.trim().isNotEmpty)
          .toList(growable: false),
    );
  }
}

class BibliotheekLeverancier {
  const BibliotheekLeverancier({
    required this.id,
    required this.naam,
    required this.schappen,
    this.kleurWaarde = 0xFF434A4E,
  });

  final String id;
  final String naam;
  final List<BibliotheekSchap> schappen;
  final int kleurWaarde;

  int get aantalFolders {
    return schappen.fold<int>(
      0,
      (totaal, schap) => totaal + schap.folders.length,
    );
  }

  BibliotheekLeverancier copyWith({
    String? id,
    String? naam,
    List<BibliotheekSchap>? schappen,
    int? kleurWaarde,
  }) {
    return BibliotheekLeverancier(
      id: id ?? this.id,
      naam: naam ?? this.naam,
      schappen: List<BibliotheekSchap>.unmodifiable(schappen ?? this.schappen),
      kleurWaarde: kleurWaarde ?? this.kleurWaarde,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'naam': naam,
      'kleurWaarde': kleurWaarde,
      'schappen': schappen
          .map((schap) => schap.toJson())
          .toList(growable: false),
    };
  }

  factory BibliotheekLeverancier.fromJson(Map<String, dynamic> json) {
    final ruweSchappen = json['schappen'];

    return BibliotheekLeverancier(
      id: json['id']?.toString() ?? '',
      naam: json['naam']?.toString() ?? '',
      kleurWaarde: json['kleurWaarde'] is num
          ? (json['kleurWaarde'] as num).toInt()
          : 0xFF434A4E,
      schappen: ruweSchappen is List
          ? ruweSchappen
                .whereType<Map>()
                .map(
                  (item) => BibliotheekSchap.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .where((schap) => schap.id.trim().isNotEmpty)
                .toList(growable: false)
          : const <BibliotheekSchap>[],
    );
  }
}

class BibliotheekSchap {
  const BibliotheekSchap({
    required this.id,
    required this.naam,
    required this.folders,
  });

  final String id;
  final String naam;
  final List<BibliotheekFolder> folders;

  BibliotheekSchap copyWith({
    String? id,
    String? naam,
    List<BibliotheekFolder>? folders,
  }) {
    return BibliotheekSchap(
      id: id ?? this.id,
      naam: naam ?? this.naam,
      folders: List<BibliotheekFolder>.unmodifiable(folders ?? this.folders),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'naam': naam,
      'folders': folders
          .map((folder) => folder.toJson())
          .toList(growable: false),
    };
  }

  factory BibliotheekSchap.fromJson(Map<String, dynamic> json) {
    final ruweFolders = json['folders'];

    return BibliotheekSchap(
      id: json['id']?.toString() ?? '',
      naam: json['naam']?.toString() ?? '',
      folders: ruweFolders is List
          ? ruweFolders
                .whereType<Map>()
                .map(
                  (item) => BibliotheekFolder.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .where((folder) => folder.id.trim().isNotEmpty)
                .toList(growable: false)
          : const <BibliotheekFolder>[],
    );
  }
}

class BibliotheekFolder {
  const BibliotheekFolder({
    required this.id,
    required this.naam,
    required this.omschrijving,
    required this.onedriveItemId,
    required this.bestandsnaam,
    required this.webUrl,
    required this.klanten,
    this.formulierKoppelingen = const <BibliotheekFormulierKoppeling>[],
    required this.gewijzigdOp,
  });

  final String id;
  final String naam;
  final String omschrijving;
  final String onedriveItemId;
  final String bestandsnaam;
  final String webUrl;
  final List<BibliotheekKlantKoppeling> klanten;
  final List<BibliotheekFormulierKoppeling> formulierKoppelingen;
  final String gewijzigdOp;

  bool get heeftPdf => onedriveItemId.trim().isNotEmpty;

  BibliotheekFolder copyWith({
    String? id,
    String? naam,
    String? omschrijving,
    String? onedriveItemId,
    String? bestandsnaam,
    String? webUrl,
    List<BibliotheekKlantKoppeling>? klanten,
    List<BibliotheekFormulierKoppeling>? formulierKoppelingen,
    String? gewijzigdOp,
  }) {
    return BibliotheekFolder(
      id: id ?? this.id,
      naam: naam ?? this.naam,
      omschrijving: omschrijving ?? this.omschrijving,
      onedriveItemId: onedriveItemId ?? this.onedriveItemId,
      bestandsnaam: bestandsnaam ?? this.bestandsnaam,
      webUrl: webUrl ?? this.webUrl,
      klanten: List<BibliotheekKlantKoppeling>.unmodifiable(
        klanten ?? this.klanten,
      ),
      formulierKoppelingen: List<BibliotheekFormulierKoppeling>.unmodifiable(
        formulierKoppelingen ?? this.formulierKoppelingen,
      ),
      gewijzigdOp: gewijzigdOp ?? this.gewijzigdOp,
    );
  }

  BibliotheekFolder metNieuweWijzigingsDatum({
    String? naam,
    String? omschrijving,
    String? onedriveItemId,
    String? bestandsnaam,
    String? webUrl,
    List<BibliotheekKlantKoppeling>? klanten,
    List<BibliotheekFormulierKoppeling>? formulierKoppelingen,
  }) {
    return copyWith(
      naam: naam,
      omschrijving: omschrijving,
      onedriveItemId: onedriveItemId,
      bestandsnaam: bestandsnaam,
      webUrl: webUrl,
      klanten: klanten,
      formulierKoppelingen: formulierKoppelingen,
      gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'naam': naam,
      'omschrijving': omschrijving,
      'onedriveItemId': onedriveItemId,
      'bestandsnaam': bestandsnaam,
      'webUrl': webUrl,
      'klanten': klanten.map((klant) => klant.toJson()).toList(growable: false),
      'formulierKoppelingen': formulierKoppelingen
          .map((koppeling) => koppeling.toJson())
          .toList(growable: false),
      'gewijzigdOp': gewijzigdOp,
    };
  }

  factory BibliotheekFolder.fromJson(Map<String, dynamic> json) {
    final ruweKlanten = json['klanten'];
    final ruweFormulierKoppelingen = json['formulierKoppelingen'];

    return BibliotheekFolder(
      id: json['id']?.toString() ?? '',
      naam: json['naam']?.toString() ?? '',
      omschrijving: json['omschrijving']?.toString() ?? '',
      onedriveItemId: json['onedriveItemId']?.toString() ?? '',
      bestandsnaam: json['bestandsnaam']?.toString() ?? '',
      webUrl: json['webUrl']?.toString() ?? '',
      klanten: ruweKlanten is List
          ? ruweKlanten
                .whereType<Map>()
                .map(
                  (item) => BibliotheekKlantKoppeling.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .where((klant) => klant.id.trim().isNotEmpty)
                .toList(growable: false)
          : const <BibliotheekKlantKoppeling>[],
      formulierKoppelingen: ruweFormulierKoppelingen is List
          ? ruweFormulierKoppelingen
                .whereType<Map>()
                .map(
                  (item) => BibliotheekFormulierKoppeling.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .where((koppeling) => koppeling.formulierType.trim().isNotEmpty)
                .toList(growable: false)
          : const <BibliotheekFormulierKoppeling>[],
      gewijzigdOp: json['gewijzigdOp']?.toString() ?? '',
    );
  }
}

class BibliotheekKlantKoppeling {
  const BibliotheekKlantKoppeling({
    required this.id,
    required this.naam,
    required this.klantNr,
  });

  final String id;
  final String naam;
  final String klantNr;

  String get label {
    final nummer = klantNr.trim();
    return nummer.isEmpty ? naam.trim() : '${naam.trim()} · $nummer';
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'naam': naam, 'klantNr': klantNr};
  }

  factory BibliotheekKlantKoppeling.fromJson(Map<String, dynamic> json) {
    return BibliotheekKlantKoppeling(
      id: json['id']?.toString() ?? '',
      naam: json['naam']?.toString() ?? '',
      klantNr: json['klantNr']?.toString() ?? '',
    );
  }
}

class BibliotheekFormulierKoppeling {
  const BibliotheekFormulierKoppeling({
    required this.formulierType,
    required this.formulierNaam,
  });

  final String formulierType;
  final String formulierNaam;

  String get label {
    final naam = formulierNaam.trim();
    return naam.isEmpty ? formulierType.trim() : naam;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'formulierType': formulierType,
      'formulierNaam': formulierNaam,
    };
  }

  factory BibliotheekFormulierKoppeling.fromJson(Map<String, dynamic> json) {
    return BibliotheekFormulierKoppeling(
      formulierType: json['formulierType']?.toString() ?? '',
      formulierNaam: json['formulierNaam']?.toString() ?? '',
    );
  }
}
