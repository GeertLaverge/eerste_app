// THIMACO-CONTROLE: DUBBELE-OPTIE-MELDING-CENTRAAL-VERWIJDERD-20260726
// THIMACO-CONTROLE: CENTRALE-OFFERTE-PDF-ARTIKELWIDGET-FASE1-20260726
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'offerte_pdf_artikel_layout_helper.dart';

typedef OffertePdfTekeningBouwer = pw.Widget Function(double kolomHoogte);

class OffertePdfArtikelPrijsRegel {
  const OffertePdfArtikelPrijsRegel({
    required this.omschrijving,
    this.prijsTekst = '',
  });

  final String omschrijving;
  final String prijsTekst;
}

class OffertePdfArtikelPrijsData {
  const OffertePdfArtikelPrijsData({
    required this.isOptie,
    required this.heeftPrijsInvoer,
    required this.totaalVoorKorting,
    required this.optieTotaalExclBtw,
    required this.optieBtw,
    required this.optieTotaalInclBtw,
    required this.btwRegelLabel,
    this.aanvullendeRegels = const <OffertePdfArtikelPrijsRegel>[],
  });

  final bool isOptie;
  final bool heeftPrijsInvoer;

  final double totaalVoorKorting;
  final double optieTotaalExclBtw;
  final double optieBtw;
  final double optieTotaalInclBtw;

  final String btwRegelLabel;

  final List<OffertePdfArtikelPrijsRegel> aanvullendeRegels;
}

class OffertePdfArtikelWidget {
  const OffertePdfArtikelWidget._();

  static const double gewonePrijsSectieHoogte = 28;
  static const double optiePrijsSectieHoogte = 72;
  static const double aanvullendePrijsregelHoogte = 18;

  static const double prijsTekstGrootte = 8;

  static const String _standaardOptieBovenMelding =
      'Niet meegerekend in het eindtotaal';

  static const PdfColor _tekstDonker =
      OffertePdfArtikelLayoutHelper.tekstDonker;

  static const PdfColor _tekstGrijs = OffertePdfArtikelLayoutHelper.tekstGrijs;

  static const PdfColor _rand = OffertePdfArtikelLayoutHelper.rand;

  static const PdfColor _oranje = OffertePdfArtikelLayoutHelper.oranje;

  static double berekenKolomHoogte({
    required List<OffertePdfTechnischeRegel> technischeRegels,
    String notities = '',
    String bovenMelding = '',
  }) {
    return OffertePdfArtikelLayoutHelper.berekenTechnischeKolomHoogte(
      regels: technischeRegels,
      notities: notities,
      bovenMelding: bovenMelding,
    );
  }

  static double berekenPrijsSectieHoogte({
    required bool isOptie,
    int aantalAanvullendePrijsregels = 0,
  }) {
    final veiligeAantalRegels = aantalAanvullendePrijsregels < 0
        ? 0
        : aantalAanvullendePrijsregels;

    final basisHoogte = isOptie
        ? optiePrijsSectieHoogte
        : gewonePrijsSectieHoogte;

    return basisHoogte + (veiligeAantalRegels * aanvullendePrijsregelHoogte);
  }

  static double berekenTotalePositieHoogte({
    required List<OffertePdfTechnischeRegel> technischeRegels,
    required bool isOptie,
    int aantalAanvullendePrijsregels = 0,
    String notities = '',
    String bovenMelding = '',
  }) {
    final effectieveBovenMelding = _effectieveBovenMelding(
      isOptie: isOptie,
      bovenMelding: bovenMelding,
    );

    final kolomHoogte = berekenKolomHoogte(
      technischeRegels: technischeRegels,
      notities: notities,
      bovenMelding: effectieveBovenMelding,
    );

    final prijsHoogte = berekenPrijsSectieHoogte(
      isOptie: isOptie,
      aantalAanvullendePrijsregels: aantalAanvullendePrijsregels,
    );

    return OffertePdfArtikelLayoutHelper.berekenTotalePositieHoogte(
      kolomHoogte: kolomHoogte,
      prijsHoogte: prijsHoogte,
    );
  }

  static pw.Widget bouw({
    required String maatTitel,
    required String maatWaarde,
    required List<OffertePdfTechnischeRegel> technischeRegels,
    required OffertePdfTekeningBouwer tekeningBouwer,
    required OffertePdfArtikelPrijsData prijsData,
    String notities = '',
    String bovenMelding = '',
    String legeTechnischeTekst = 'Geen bijkomende technische gegevens.',
    bool toonTechnischePrijsZone = true,
  }) {
    final effectieveBovenMelding = _effectieveBovenMelding(
      isOptie: prijsData.isOptie,
      bovenMelding: bovenMelding,
    );

    final kolomHoogte = berekenKolomHoogte(
      technischeRegels: technischeRegels,
      notities: notities,
      bovenMelding: effectieveBovenMelding,
    );

    return OffertePdfArtikelLayoutHelper.bouwArtikelLayout(
      kolomHoogte: kolomHoogte,
      tekenvlak: OffertePdfArtikelLayoutHelper.bouwTekenvlak(
        hoogte: kolomHoogte,
        maatTitel: maatTitel,
        maatWaarde: maatWaarde,
        tekening: tekeningBouwer(kolomHoogte),
      ),
      technischeKolom: OffertePdfArtikelLayoutHelper.bouwTechnischeKolom(
        hoogte: kolomHoogte,
        regels: technischeRegels,
        notities: notities,
        bovenMelding: effectieveBovenMelding,
        legeTekst: legeTechnischeTekst,
        toonPrijsZone: toonTechnischePrijsZone,
      ),
      prijsBlok: _bouwPrijsBlok(prijsData),
    );
  }

  static String _effectieveBovenMelding({
    required bool isOptie,
    required String bovenMelding,
  }) {
    final netteMelding = bovenMelding.trim();

    if (isOptie && netteMelding == _standaardOptieBovenMelding) {
      return '';
    }

    return netteMelding;
  }

  static pw.Widget _bouwPrijsBlok(OffertePdfArtikelPrijsData prijsData) {
    final prijsSectieHoogte = berekenPrijsSectieHoogte(
      isOptie: prijsData.isOptie,
      aantalAanvullendePrijsregels: prijsData.aanvullendeRegels.length,
    );

    return pw.Container(
      height: prijsSectieHoogte,
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(7),
        border: pw.Border.all(color: _rand, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: <pw.Widget>[
          for (final regel in prijsData.aanvullendeRegels)
            _bouwAanvullendePrijsregel(regel),
          if (prijsData.aanvullendeRegels.isNotEmpty) ...<pw.Widget>[
            pw.Container(height: 0.5, color: _rand),
            pw.SizedBox(height: 4),
          ],
          if (prijsData.isOptie)
            ..._bouwOptiePrijsregels(prijsData)
          else
            _bouwGewoonPositieTotaal(prijsData),
        ],
      ),
    );
  }

  static pw.Widget _bouwAanvullendePrijsregel(
    OffertePdfArtikelPrijsRegel regel,
  ) {
    final omschrijving = regel.omschrijving.trim();

    final prijsTekst = regel.prijsTekst.trim();

    return pw.SizedBox(
      height: aanvullendePrijsregelHoogte,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: <pw.Widget>[
          pw.Expanded(
            child: pw.Text(
              omschrijving,
              maxLines: 1,
              style: const pw.TextStyle(
                color: _tekstDonker,
                fontSize: prijsTekstGrootte,
              ),
            ),
          ),
          if (prijsTekst.isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(width: 8),
            pw.Text(
              prijsTekst,
              maxLines: 1,
              textAlign: pw.TextAlign.right,
              style: const pw.TextStyle(
                color: _tekstDonker,
                fontSize: prijsTekstGrootte,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _bouwGewoonPositieTotaal(
    OffertePdfArtikelPrijsData prijsData,
  ) {
    final toonNogInTeVullen =
        prijsData.totaalVoorKorting <= 0 && !prijsData.heeftPrijsInvoer;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: <pw.Widget>[
        pw.Expanded(
          child: pw.Text(
            'Totaal positie',
            style: const pw.TextStyle(
              color: _tekstDonker,
              fontSize: prijsTekstGrootte,
            ),
          ),
        ),
        pw.SizedBox(width: 8),
        if (toonNogInTeVullen)
          pw.Text(
            'Prijs nog in te vullen',
            maxLines: 1,
            textAlign: pw.TextAlign.right,
            style: const pw.TextStyle(
              color: _tekstGrijs,
              fontSize: prijsTekstGrootte,
            ),
          )
        else
          pw.Text(
            '€ ${_bedragMetPunt(prijsData.totaalVoorKorting)} excl. btw',
            maxLines: 1,
            textAlign: pw.TextAlign.right,
            style: const pw.TextStyle(
              color: _tekstDonker,
              fontSize: prijsTekstGrootte,
            ),
          ),
      ],
    );
  }

  static List<pw.Widget> _bouwOptiePrijsregels(
    OffertePdfArtikelPrijsData prijsData,
  ) {
    return <pw.Widget>[
      _bouwOptiePrijsregel(
        omschrijving: 'Totaal optie excl. btw',
        bedrag: prijsData.optieTotaalExclBtw,
      ),
      _bouwOptiePrijsregel(
        omschrijving: prijsData.btwRegelLabel,
        bedrag: prijsData.optieBtw,
      ),
      _bouwOptiePrijsregel(
        omschrijving: 'Totaal optie incl. btw',
        bedrag: prijsData.optieTotaalInclBtw,
        benadrukt: true,
        laatste: true,
      ),
    ];
  }

  static pw.Widget _bouwOptiePrijsregel({
    required String omschrijving,
    required double bedrag,
    bool benadrukt = false,
    bool laatste = false,
  }) {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(vertical: benadrukt ? 5 : 4),
      decoration: pw.BoxDecoration(
        color: benadrukt ? const PdfColor.fromInt(0xFFFFF7ED) : PdfColors.white,
        border: laatste
            ? null
            : const pw.Border(bottom: pw.BorderSide(color: _rand, width: 0.5)),
      ),
      child: pw.Row(
        children: <pw.Widget>[
          pw.Expanded(
            child: pw.Text(
              omschrijving,
              maxLines: 2,
              style: pw.TextStyle(
                color: benadrukt ? _tekstDonker : _tekstGrijs,
                fontSize: benadrukt ? 8.4 : 7.2,
                fontWeight: benadrukt ? pw.FontWeight.bold : null,
              ),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Text(
            '€ ${_bedragMetPunt(bedrag)}',
            maxLines: 1,
            style: pw.TextStyle(
              color: benadrukt ? _oranje : _tekstDonker,
              fontSize: benadrukt ? 10.8 : 7.6,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static String _bedragMetPunt(double waarde) {
    if (!waarde.isFinite) {
      return '0.00';
    }

    return waarde.toStringAsFixed(2);
  }
}
