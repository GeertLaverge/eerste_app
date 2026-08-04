// THIMACO-CONTROLE: VOLLEDIGE-OPGESLAGEN-MAILBERICHTEN-20260802

enum OfferteMailBerichtGebruik {
  offerte,
  bevestiging,
  bestelbon,
  beide;

  String get label {
    return switch (this) {
      OfferteMailBerichtGebruik.offerte => 'Offerte versturen',
      OfferteMailBerichtGebruik.bevestiging => 'Bevestiging na goedkeuring',
      OfferteMailBerichtGebruik.bestelbon => 'Bestelbon leverancier',
      OfferteMailBerichtGebruik.beide => 'Offerte en bevestiging',
    };
  }

  bool get beschikbaarVoorOfferte {
    return this == OfferteMailBerichtGebruik.offerte ||
        this == OfferteMailBerichtGebruik.beide;
  }

  bool get beschikbaarVoorBevestiging {
    return this == OfferteMailBerichtGebruik.bevestiging ||
        this == OfferteMailBerichtGebruik.beide;
  }

  bool get beschikbaarVoorBestelbon {
    return this == OfferteMailBerichtGebruik.bestelbon;
  }
}

class OfferteMailTekstBlok {
  const OfferteMailTekstBlok({
    required this.id,
    required this.naam,
    required this.onderwerp,
    required this.tekst,
    required this.gebruik,
    required this.actief,
    required this.gewijzigdOp,
  });

  final String id;
  final String naam;
  final String onderwerp;
  final String tekst;
  final OfferteMailBerichtGebruik gebruik;
  final bool actief;
  final String gewijzigdOp;

  OfferteMailTekstBlok copyWith({
    String? id,
    String? naam,
    String? onderwerp,
    String? tekst,
    OfferteMailBerichtGebruik? gebruik,
    bool? actief,
    String? gewijzigdOp,
  }) {
    return OfferteMailTekstBlok(
      id: id ?? this.id,
      naam: naam ?? this.naam,
      onderwerp: onderwerp ?? this.onderwerp,
      tekst: tekst ?? this.tekst,
      gebruik: gebruik ?? this.gebruik,
      actief: actief ?? this.actief,
      gewijzigdOp: gewijzigdOp ?? this.gewijzigdOp,
    );
  }

  OfferteMailTekstBlok metNieuweWijzigingsDatum({
    String? naam,
    String? onderwerp,
    String? tekst,
    OfferteMailBerichtGebruik? gebruik,
    bool? actief,
  }) {
    return copyWith(
      naam: naam,
      onderwerp: onderwerp,
      tekst: tekst,
      gebruik: gebruik,
      actief: actief,
      gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'naam': naam,
      'onderwerp': onderwerp,
      'tekst': tekst,
      'gebruik': gebruik.name,
      'actief': actief,
      'gewijzigdOp': gewijzigdOp,
    };
  }

  factory OfferteMailTekstBlok.fromJson(Map<String, dynamic> json) {
    final naam = json['naam']?.toString().trim() ?? '';
    final gebruikNaam = json['gebruik']?.toString().trim() ?? '';
    final gebruik = OfferteMailBerichtGebruik.values.firstWhere(
      (waarde) => waarde.name == gebruikNaam,
      orElse: () {
        final kleineNaam = naam.toLowerCase();
        if (kleineNaam.contains('goedkeuring') ||
            kleineNaam.contains('bevestiging')) {
          return OfferteMailBerichtGebruik.bevestiging;
        }
        return OfferteMailBerichtGebruik.offerte;
      },
    );

    final onderwerpUitJson = json['onderwerp']?.toString().trim() ?? '';
    final standaardOnderwerp = switch (gebruik) {
      OfferteMailBerichtGebruik.bevestiging =>
        'Bevestiging goedkeuring offerte Thimaco [offertenummer]',
      OfferteMailBerichtGebruik.bestelbon =>
        'Bestelbon Thimaco – [leverancier]',
      _ => 'Offerte Thimaco [offertenummer] – [klantnaam]',
    };

    return OfferteMailTekstBlok(
      id: json['id']?.toString() ?? '',
      naam: naam,
      onderwerp: onderwerpUitJson.isEmpty
          ? standaardOnderwerp
          : onderwerpUitJson,
      tekst: json['tekst']?.toString() ?? '',
      gebruik: gebruik,
      actief: json['actief'] != false,
      gewijzigdOp: json['gewijzigdOp']?.toString() ?? '',
    );
  }
}

class OfferteMailTekstenData {
  const OfferteMailTekstenData({required this.blokken});

  final List<OfferteMailTekstBlok> blokken;

  /// Wordt gebruikt wanneer nog niets werd opgeslagen. Zo zijn de drie
  /// meest gebruikte volledige berichten meteen beschikbaar.
  factory OfferteMailTekstenData.leeg() {
    return OfferteMailTekstenData.standaard();
  }

  factory OfferteMailTekstenData.standaard() {
    return const OfferteMailTekstenData(
      blokken: <OfferteMailTekstBlok>[
        OfferteMailTekstBlok(
          id: 'mailbericht_eerste_offerte',
          naam: 'Eerste offerte afleveren',
          onderwerp: 'Offerte Thimaco [offertenummer] – [klantnaam]',
          tekst: '''Beste [aanspreking],

In bijlage bezorgen wij u onze offerte met nummer [offertenummer] voor de besproken werken.

Het totaalbedrag van de offerte bedraagt [totaalbedrag] inclusief btw.

U kunt de offerte op een van de volgende manieren goedkeuren:

• ondertekenen tijdens onze afspraak op de iPad;
• de goedkeuringspagina afdrukken, ondertekenen en per e-mail terugbezorgen;
• deze e-mail beantwoorden met de onderstaande tekst:

“Ik, [klantnaam], keur offerte [offertenummer] van [offertedatum] voor een totaalbedrag van [totaalbedrag] inclusief btw goed.”

Hebt u nog vragen of wenst u bepaalde zaken te bespreken, dan mag u ons uiteraard steeds contacteren.

Met vriendelijke groeten

Geert
Thimaco
Ramen · Deuren · Zonwering
Kerkdreef 1
8791 Beveren-Leie
056 44 91 35
info@thimaco.be''',
          gebruik: OfferteMailBerichtGebruik.offerte,
          actief: true,
          gewijzigdOp: '',
        ),
        OfferteMailTekstBlok(
          id: 'mailbericht_gewijzigde_offerte',
          naam: 'Gewijzigde offerte afleveren',
          onderwerp: 'Gewijzigde offerte Thimaco [offertenummer] – [klantnaam]',
          tekst: '''Beste [aanspreking],

Zoals besproken hebben wij de offerte aangepast.

In bijlage bezorgen wij u de gewijzigde offerte met nummer [offertenummer]. Het aangepaste totaalbedrag bedraagt [totaalbedrag] inclusief btw.

Gelieve deze nieuwe versie te gebruiken ter vervanging van de vorige offerte.

Hebt u nog vragen of wenst u de wijzigingen samen te overlopen, dan mag u ons uiteraard steeds contacteren.

Met vriendelijke groeten

Geert
Thimaco
Ramen · Deuren · Zonwering
Kerkdreef 1
8791 Beveren-Leie
056 44 91 35
info@thimaco.be''',
          gebruik: OfferteMailBerichtGebruik.offerte,
          actief: true,
          gewijzigdOp: '',
        ),
        OfferteMailTekstBlok(
          id: 'mailbericht_bevestiging_goedkeuring',
          naam: 'Goedkeuring bevestigen',
          onderwerp: 'Bevestiging goedkeuring offerte Thimaco [offertenummer]',
          tekst: '''Beste [aanspreking],

Bedankt voor uw goedkeuring van offerte [offertenummer].

In bijlage vindt u een kopie van de door u ondertekende offerte voor een totaalbedrag van [totaalbedrag] inclusief btw.

Wij nemen contact met u op voor de verdere opvolging en planning van uw dossier.

Met vriendelijke groeten

Geert
Thimaco
Ramen · Deuren · Zonwering
Kerkdreef 1
8791 Beveren-Leie
056 44 91 35
info@thimaco.be''',
          gebruik: OfferteMailBerichtGebruik.bevestiging,
          actief: true,
          gewijzigdOp: '',
        ),
        OfferteMailTekstBlok(
          id: 'mailbericht_bestelbon_leverancier',
          naam: 'Bestelbon leverancier',
          onderwerp: 'Bestelbon Thimaco – [leverancier]',
          tekst: '''Geachte,

In bijlage bezorgen wij u onze bestelbon.

Gelieve de bestelling te controleren en de verwachte leverdatum te bevestigen.

Met vriendelijke groeten

Geert
Thimaco
Ramen · Deuren · Zonwering
Kerkdreef 1
8791 Beveren-Leie
056 44 91 35
info@thimaco.be''',
          gebruik: OfferteMailBerichtGebruik.bestelbon,
          actief: true,
          gewijzigdOp: '',
        ),
      ],
    );
  }

  OfferteMailTekstenData copyWith({List<OfferteMailTekstBlok>? blokken}) {
    return OfferteMailTekstenData(
      blokken: List<OfferteMailTekstBlok>.unmodifiable(blokken ?? this.blokken),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'versie': 2,
      'blokken': blokken.map((blok) => blok.toJson()).toList(growable: false),
    };
  }

  factory OfferteMailTekstenData.fromJson(Map<String, dynamic> json) {
    final ruweBlokken = json['blokken'];
    if (ruweBlokken is! List) return OfferteMailTekstenData.standaard();

    return OfferteMailTekstenData(
      blokken: ruweBlokken
          .whereType<Map>()
          .map(
            (item) =>
                OfferteMailTekstBlok.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((blok) {
            return blok.id.trim().isNotEmpty &&
                blok.naam.trim().isNotEmpty &&
                blok.tekst.trim().isNotEmpty;
          })
          .toList(growable: false),
    );
  }
}
