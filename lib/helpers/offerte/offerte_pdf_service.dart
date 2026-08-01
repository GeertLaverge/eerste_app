// THIMACO-CONTROLE: OFFERTE-GOEDKEURING-IPAD-PAPIER-20260801
// THIMACO-CONTROLE: UITVALSCHERM-PDF-KOPPELING-20260801
// THIMACO-CONTROLE: OPMETING-PDF-KLANTADRES-IN-KOP-20260731
// THIMACO-CONTROLE: GENEREREN-OPMETING-PDF-ZONDER-PRIJZEN-20260731
// THIMACO-CONTROLE: VOORZETROLLUIK-CENTRALE-OFFERTE-PDF-20260731
// THIMACO-CONTROLE: VELUX-CENTRALE-OFFERTE-PDF-20260729-2212
// THIMACO-CONTROLE: SEKTIONALE-POORTEN-PDF-SERVICE-20260729
// THIMACO-CONTROLE: PLOOIWERKEN-CENTRALE-OFFERTE-PDF-20260728
// THIMACO-CONTROLE: SCHUIFVLIEGENDEUR-CENTRALE-OFFERTE-PDF-20260728
// THIMACO-CONTROLE: VOORBLAD-ONDERBLOK-VAST-ONDERAAN-EN-ARTIKELSPATIE-20260726
// THIMACO-CONTROLE: VOORBLAD-WELKOM-TERUG-ONDERAAN-20260726
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../opmeting/overzicht/opmeting_artikel_type_omschrijving_helper.dart';
import '../opmeting/overzicht/opmeting_overzicht_model.dart';
import 'offerte_pdf_artikel_layout_helper.dart';
import 'offerte_goedkeuring_model.dart';
import 'offerte_pdf_inzethor_widget.dart';
import 'offerte_pdf_plooiwerken_widget.dart';
import 'offerte_pdf_voorzetscreen_widget.dart';
import 'offerte_pdf_voorzetrolluik_widget.dart';
import 'offerte_pdf_uitvalscherm_widget.dart';
import 'offerte_pdf_sektionale_poort_widget.dart';
import 'offerte_pdf_pvc_raam_widget.dart';
import 'offerte_pdf_schuifvliegendeur_widget.dart';
import 'offerte_pdf_velux_dakraam_widget.dart';
import 'offerte_pdf_vliegendeur_widget.dart';
import 'offerte_pdf_model.dart';

class OffertePdfService {
  const OffertePdfService._();

  static const String logoAsset = 'assets/offerte/thimaco_logo.png';
  static const String toonzaalAsset = 'assets/offerte/thimaco_toonzaal.jpg';

  static const PdfColor oranje = PdfColor.fromInt(0xFFF15A24);
  static const PdfColor tekstDonker = PdfColor.fromInt(0xFF22272D);
  static const PdfColor tekstGrijs = PdfColor.fromInt(0xFF616973);
  static const PdfColor rand = PdfColor.fromInt(0xFFE2E5E8);
  static const PdfColor lichtVlak = PdfColor.fromInt(0xFFF7F8F9);

  static const double _detailPaddingBoven = 27;
  static const double _detailPaddingOnder = 22;
  static const double _artikelKopHoogte = 32;
  static const double _ruimteTussenArtikels = 16;
  static const double _paginaVoetReserve = 36;
  static const double _basisEindBerekeningReserve = 0;
  static const double _opmetingPaddingBoven = 18;
  static const double _opmetingPaddingOnder = 18;
  static const double _opmetingKopHoogte = 72;
  static const double _opmetingKopTussenruimte = 10;

  static String maakOfferteNummer(DateTime datum) {
    String twee(int waarde) => waarde.toString().padLeft(2, '0');

    return 'OF-${datum.year}${twee(datum.month)}${twee(datum.day)}-'
        '${twee(datum.hour)}${twee(datum.minute)}';
  }

  static Future<Uint8List> bouwPdf(
    OfferteDocumentData data, {
    OfferteGoedkeuring? goedkeuring,
  }) async {
    final logoData = await rootBundle.load(logoAsset);
    final toonzaalData = await rootBundle.load(toonzaalAsset);

    final logo = pw.MemoryImage(
      logoData.buffer.asUint8List(
        logoData.offsetInBytes,
        logoData.lengthInBytes,
      ),
    );
    final toonzaal = pw.MemoryImage(
      toonzaalData.buffer.asUint8List(
        toonzaalData.offsetInBytes,
        toonzaalData.lengthInBytes,
      ),
    );

    final basisFont = await PdfGoogleFonts.notoSansRegular();
    final vetFont = await PdfGoogleFonts.notoSansBold();
    final pdfThema = pw.ThemeData.withFont(base: basisFont, bold: vetFont);

    final document = pw.Document(
      title: 'Offerte ${data.offerteNummer}',
      author: 'Thimaco',
      creator: 'Thimaco app',
      subject: 'Offerte ${data.klant.naam}',
    );

    final detailPaginas = _verdeelPositiesOverPaginas(data);
    final optiePaginas = _verdeelOptiesOverPaginas(data);
    final totaalPaginaAantal = 2 + detailPaginas.length + optiePaginas.length;

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        theme: pdfThema,
        build: (context) =>
            _bouwVoorblad(data: data, logo: logo, toonzaal: toonzaal),
      ),
    );

    var paginaNummer = 2;
    for (
      var detailIndex = 0;
      detailIndex < detailPaginas.length;
      detailIndex++
    ) {
      final pagina = detailPaginas[detailIndex];
      document.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          theme: pdfThema,
          build: (context) => _bouwDetailPagina(
            data: data,
            logo: logo,
            pagina: pagina,
            paginaNummer: paginaNummer,
            totaalPaginaAantal: totaalPaginaAantal,
            toonEindBerekening: detailIndex == detailPaginas.length - 1,
          ),
        ),
      );
      paginaNummer++;
    }

    // Alleen opties waarvoor expliciet `apartePagina` werd gekozen, komen
    // na de volledige hoofdofferte en vóór de afzonderlijke goedkeuringspagina. Opties met
    // `positieBehouden` staan al op hun oorspronkelijke plaats tussen de
    // gewone artikelen. Een artikelblok wordt nooit opgesplitst.
    for (final optiePagina in optiePaginas) {
      document.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          theme: pdfThema,
          build: (context) => _bouwOptiePagina(
            data: data,
            logo: logo,
            pagina: optiePagina,
            paginaNummer: paginaNummer,
            totaalPaginaAantal: totaalPaginaAantal,
          ),
        ),
      );
      paginaNummer++;
    }

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        theme: pdfThema,
        build: (context) => _bouwGoedkeuringsPagina(
          data: data,
          logo: logo,
          goedkeuring: goedkeuring,
          paginaNummer: paginaNummer,
          totaalPaginaAantal: totaalPaginaAantal,
        ),
      ),
    );

    return document.save();
  }

  static Future<Uint8List> bouwOpmetingPdf(OfferteDocumentData data) {
    return OffertePdfArtikelLayoutHelper.zonderPrijsblokken<Future<Uint8List>>(
      () async {
        final logoData = await rootBundle.load(logoAsset);
        final logo = pw.MemoryImage(
          logoData.buffer.asUint8List(
            logoData.offsetInBytes,
            logoData.lengthInBytes,
          ),
        );

        final basisFont = await PdfGoogleFonts.notoSansRegular();
        final vetFont = await PdfGoogleFonts.notoSansBold();
        final pdfThema = pw.ThemeData.withFont(base: basisFont, bold: vetFont);

        final document = pw.Document(
          title: 'Opmeting ${data.klant.naam}',
          author: 'Thimaco',
          creator: 'Thimaco app',
          subject: 'Opmeting ${data.klant.naam}',
        );

        final paginas = _verdeelOpmetingPositiesOverPaginas(data);
        final totaalPaginaAantal = paginas.length;

        for (var index = 0; index < paginas.length; index++) {
          final pagina = paginas[index];
          document.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4,
              margin: pw.EdgeInsets.zero,
              theme: pdfThema,
              build: (context) => _bouwOpmetingPagina(
                data: data,
                logo: logo,
                pagina: pagina,
                paginaNummer: index + 1,
                totaalPaginaAantal: totaalPaginaAantal,
                eerstePagina: index == 0,
              ),
            ),
          );
        }

        return document.save();
      },
    );
  }

  static pw.Widget _bouwVoorblad({
    required OfferteDocumentData data,
    required pw.ImageProvider logo,
    required pw.ImageProvider toonzaal,
  }) {
    return pw.Container(
      width: PdfPageFormat.a4.width,
      height: PdfPageFormat.a4.height,
      color: PdfColors.white,
      child: pw.Stack(
        fit: pw.StackFit.expand,
        children: <pw.Widget>[
          pw.Align(
            alignment: pw.Alignment.bottomCenter,
            child: pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 34),
              child: pw.SizedBox(
                width: PdfPageFormat.a4.width,
                height: 315,
                child: pw.Opacity(
                  opacity: 0.10,
                  child: pw.Image(toonzaal, fit: pw.BoxFit.cover),
                ),
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 42, bottom: 28),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: <pw.Widget>[
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 42),
                  child: pw.Text(
                    'OFFERTE',
                    style: pw.TextStyle(
                      color: tekstDonker,
                      fontSize: 34,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 0.55,
                    ),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Container(height: 1.3, color: oranje),
                pw.SizedBox(height: 22),
                pw.Expanded(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 42),
                    child: pw.Stack(
                      fit: pw.StackFit.expand,
                      children: <pw.Widget>[
                        pw.Align(
                          alignment: pw.Alignment.topCenter,
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: <pw.Widget>[
                              pw.Expanded(
                                flex: 10,
                                child: _bouwBedrijfsblok(logo),
                              ),
                              pw.SizedBox(width: 26),
                              pw.Expanded(
                                flex: 11,
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.stretch,
                                  children: <pw.Widget>[
                                    _bouwKlantblok(data),
                                    if (data
                                        .heeftProjectKleuren) ...<pw.Widget>[
                                      pw.SizedBox(height: 10),
                                      _bouwProjectKleurenBlok(data),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.Align(
                          alignment: pw.Alignment.bottomCenter,
                          child: pw.Column(
                            mainAxisSize: pw.MainAxisSize.min,
                            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                            children: <pw.Widget>[
                              _bouwWelkomBlok(),
                              pw.SizedBox(height: 18),
                              _bouwVoetregel(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _bouwBedrijfsblok(pw.ImageProvider logo) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Image(logo, width: 240, fit: pw.BoxFit.contain),
        pw.SizedBox(height: 18),
        _contactRegel('Kerkdreef 1, Beveren-Leie'),
        _contactRegel('056 44 91 35'),
        _contactRegel('info@thimaco.be'),
        _contactRegel('www.thimaco.be'),
      ],
    );
  }

  static pw.Widget _contactRegel(String tekst) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 13),
      child: pw.Row(
        children: <pw.Widget>[
          pw.SizedBox(
            width: 22,
            height: 22,
            child: pw.Center(
              child: pw.SvgImage(
                width: 9,
                height: 9,
                svg: '''
<svg xmlns="http://www.w3.org/2000/svg" width="9" height="9" viewBox="0 0 9 9">
  <rect x="1.5" y="1.5" width="6" height="6" fill="#F15A24" transform="rotate(45 4.5 4.5)"/>
</svg>
''',
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Text(
              tekst,
              style: const pw.TextStyle(color: tekstDonker, fontSize: 10.2),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _bouwKlantblok(OfferteDocumentData data) {
    final datum = _formatteerDatum(data.offerteDatum);
    final klantNaam = data.klant.naam.trim();

    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(18, 17, 18, 16),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: rand, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: <pw.Widget>[
          pw.Text(
            klantNaam,
            style: pw.TextStyle(
              color: tekstDonker,
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              lineSpacing: 1.5,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Align(
            alignment: pw.Alignment.centerLeft,
            child: pw.Container(width: 26, height: 1.1, color: oranje),
          ),
          pw.SizedBox(height: 13),
          if (data.klant.contactpersoon.trim().isNotEmpty)
            _klantRegel('Contactpersoon', data.klant.contactpersoon),
          _klantRegel('Adres', data.klant.adres),
          _klantRegel('Postcode en gemeente', data.klant.postcodeEnGemeente),
          _klantRegel('Telefoon', data.klant.telefoon),
          _klantRegel('E-mail', data.klant.email),
          _klantRegel('Projectadres', data.klant.projectAdres),
          pw.SizedBox(height: 4),
          pw.Container(height: 0.8, color: rand),
          pw.SizedBox(height: 10),
          _klantRegel('Offertedatum', datum),
          _klantRegel('Offertenummer', data.offerteNummer),
        ],
      ),
    );
  }

  static pw.Widget _bouwProjectKleurenBlok(OfferteDocumentData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(10, 8, 10, 7),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF9FAFB),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: rand, width: 0.7),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: <pw.Widget>[
          pw.Text(
            'Projectkleuren',
            style: pw.TextStyle(
              color: tekstDonker,
              fontSize: 8.8,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          _projectKleurRegel('Binnen', data.projectKleurBinnen),
          _projectKleurRegel('Buiten', data.projectKleurBuiten),
          _projectKleurRegel('RAL toebehoren', data.ralKleurToebehoren),
        ],
      ),
    );
  }

  static pw.Widget _projectKleurRegel(String label, String waarde) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.SizedBox(
            width: 72,
            child: pw.Text(
              label,
              style: const pw.TextStyle(color: tekstGrijs, fontSize: 7.8),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              waarde.trim().isEmpty ? '-' : waarde.trim(),
              style: const pw.TextStyle(color: tekstDonker, fontSize: 7.9),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _klantRegel(String titel, String waarde) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.SizedBox(
            width: 82,
            child: pw.Text(
              titel,
              style: const pw.TextStyle(color: tekstGrijs, fontSize: 8.7),
            ),
          ),
          pw.SizedBox(width: 6),
          pw.Expanded(
            child: pw.Text(
              waarde.trim().isEmpty ? '-' : waarde.trim(),
              style: const pw.TextStyle(color: tekstDonker, fontSize: 8.8),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _bouwWelkomBlok() {
    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(20, 18, 22, 18),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: rand, width: 0.8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Container(
            width: 54,
            height: 54,
            decoration: const pw.BoxDecoration(
              color: lichtVlak,
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(
              child: pw.Text(
                'T',
                style: pw.TextStyle(
                  color: oranje,
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 18),
          pw.Container(width: 1.2, height: 104, color: oranje),
          pw.SizedBox(width: 18),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Text(
                  'Welkom bij Thimaco',
                  style: pw.TextStyle(
                    color: tekstDonker,
                    fontSize: 13.2,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Container(width: 30, height: 1.4, color: oranje),
                pw.SizedBox(height: 9),
                pw.Text(
                  'Hartelijk dank voor uw interesse in Thimaco. '
                  'Met veel zorg en aandacht hebben wij deze offerte voor u '
                  'samengesteld, volledig afgestemd op uw project en wensen.',
                  style: const pw.TextStyle(
                    color: tekstDonker,
                    fontSize: 9,
                    lineSpacing: 2,
                  ),
                ),
                pw.SizedBox(height: 7),
                pw.Text(
                  'Wij staan voor hoogwaardige kwaliteit, persoonlijke service '
                  'en een verzorgde afwerking waar u jarenlang van geniet. '
                  'We ontvangen u graag in onze toonzaal, waar u onze producten '
                  'en afwerkingen van dichtbij kunt bekijken.',
                  style: const pw.TextStyle(
                    color: tekstDonker,
                    fontSize: 9,
                    lineSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _bouwOpmetingPagina({
    required OfferteDocumentData data,
    required pw.ImageProvider logo,
    required _OfferteDetailPagina pagina,
    required int paginaNummer,
    required int totaalPaginaAantal,
    required bool eerstePagina,
  }) {
    return pw.Container(
      width: PdfPageFormat.a4.width,
      height: PdfPageFormat.a4.height,
      color: PdfColors.white,
      padding: const pw.EdgeInsets.fromLTRB(
        34,
        _opmetingPaddingBoven,
        34,
        _opmetingPaddingOnder,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: <pw.Widget>[
          _bouwOpmetingKop(data: data, logo: logo, volledig: eerstePagina),
          pw.SizedBox(height: _opmetingKopTussenruimte),
          if (pagina.artikels.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                color: lichtVlak,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border(
                  left: pw.BorderSide(color: rand, width: 0.8),
                  top: pw.BorderSide(color: rand, width: 0.8),
                  right: pw.BorderSide(color: rand, width: 0.8),
                  bottom: pw.BorderSide(color: rand, width: 0.8),
                ),
              ),
              child: pw.Text(
                'Geen artikels beschikbaar voor deze opmeting.',
                style: const pw.TextStyle(color: tekstGrijs, fontSize: 9),
              ),
            )
          else
            for (
              var index = 0;
              index < pagina.artikels.length;
              index++
            ) ...<pw.Widget>[
              if (index > 0) pw.SizedBox(height: _ruimteTussenArtikels),
              _bouwArtikelBlok(
                data,
                pagina.artikels[index],
                toonPrijsOpties: false,
                toonOptieMelding: false,
              ),
            ],
          pw.Spacer(),
          _bouwPaginaVoet(
            logo: logo,
            paginaNummer: paginaNummer,
            totaalPaginaAantal: totaalPaginaAantal,
          ),
        ],
      ),
    );
  }

  static pw.Widget _bouwOpmetingKop({
    required OfferteDocumentData data,
    required pw.ImageProvider logo,
    required bool volledig,
  }) {
    final klantNaam = data.klant.naam.trim().isEmpty
        ? 'Klant niet ingevuld'
        : data.klant.naam.trim();
    final klantAdres = <String>[
      data.klant.adres.trim(),
      data.klant.postcodeEnGemeente.trim(),
    ].where((deel) => deel.isNotEmpty).join(', ');
    final kleurDelen = <String>[
      if (data.projectKleurBinnen.trim().isNotEmpty)
        'Binnen: ${data.projectKleurBinnen.trim()}',
      if (data.projectKleurBuiten.trim().isNotEmpty)
        'Buiten: ${data.projectKleurBuiten.trim()}',
      if (data.ralKleurToebehoren.trim().isNotEmpty)
        'Toebehoren: ${data.ralKleurToebehoren.trim()}',
    ];

    return pw.SizedBox(
      height: _opmetingKopHoogte,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: <pw.Widget>[
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: <pw.Widget>[
              pw.Image(logo, width: 92, height: 30, fit: pw.BoxFit.contain),
              pw.SizedBox(width: 14),
              pw.Container(width: 1.2, height: 28, color: oranje),
              pw.SizedBox(width: 14),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Text(
                      volledig ? 'OPMETING' : 'OPMETING · VERVOLG',
                      style: pw.TextStyle(
                        color: oranje,
                        fontSize: volledig ? 15 : 11.5,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      klantNaam,
                      maxLines: 1,
                      style: pw.TextStyle(
                        color: tekstDonker,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Text(
                _formatteerDatum(data.offerteDatum),
                style: const pw.TextStyle(color: tekstGrijs, fontSize: 8),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Container(height: 1, color: oranje),
          pw.SizedBox(height: 5),
          if (klantAdres.isNotEmpty)
            pw.Text(
              'Adres: $klantAdres',
              maxLines: 1,
              style: const pw.TextStyle(color: tekstDonker, fontSize: 8),
            ),
          if (volledig && kleurDelen.isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 3),
            pw.Text(
              kleurDelen.join('   ·   '),
              maxLines: 1,
              style: const pw.TextStyle(color: tekstGrijs, fontSize: 7.7),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _bouwDetailPagina({
    required OfferteDocumentData data,
    required pw.ImageProvider logo,
    required _OfferteDetailPagina pagina,
    required int paginaNummer,
    required int totaalPaginaAantal,
    required bool toonEindBerekening,
  }) {
    return pw.Container(
      width: PdfPageFormat.a4.width,
      height: PdfPageFormat.a4.height,
      color: PdfColors.white,
      padding: const pw.EdgeInsets.fromLTRB(
        34,
        _detailPaddingBoven,
        34,
        _detailPaddingOnder,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: <pw.Widget>[
          for (var index = 0; index < pagina.artikels.length; index++) ...[
            if (index > 0) pw.SizedBox(height: _ruimteTussenArtikels),
            _bouwArtikelBlok(data, pagina.artikels[index]),
          ],
          pw.Spacer(),
          if (toonEindBerekening) ...<pw.Widget>[
            if (data.heeftZichtbareProjectPrijsregels) ...<pw.Widget>[
              _bouwProjectPrijsregels(data),
              pw.SizedBox(height: 10),
            ],
            if (data.heeftLossePrijsOpties) ...<pw.Widget>[
              _bouwLossePrijsOpties(data),
              pw.SizedBox(height: 10),
            ],
            if (data.heeftZichtbareProjectPrijsregels ||
                data.heeftLossePrijsOpties)
              pw.SizedBox(height: 4),
          ],
          _bouwPaginaVoet(
            logo: logo,
            paginaNummer: paginaNummer,
            totaalPaginaAantal: totaalPaginaAantal,
          ),
        ],
      ),
    );
  }

  static pw.Widget _bouwOptiePagina({
    required OfferteDocumentData data,
    required pw.ImageProvider logo,
    required _OfferteDetailPagina pagina,
    required int paginaNummer,
    required int totaalPaginaAantal,
  }) {
    return pw.Container(
      width: PdfPageFormat.a4.width,
      height: PdfPageFormat.a4.height,
      color: PdfColors.white,
      padding: const pw.EdgeInsets.fromLTRB(
        34,
        _detailPaddingBoven,
        34,
        _detailPaddingOnder,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: <pw.Widget>[
          for (
            var index = 0;
            index < pagina.artikels.length;
            index++
          ) ...<pw.Widget>[
            if (index > 0) pw.SizedBox(height: _ruimteTussenArtikels),
            _bouwArtikelBlok(
              data,
              pagina.artikels[index],
              kortingToestaan: false,
            ),
          ],
          pw.Spacer(),
          _bouwPaginaVoet(
            logo: logo,
            paginaNummer: paginaNummer,
            totaalPaginaAantal: totaalPaginaAantal,
          ),
        ],
      ),
    );
  }

  static pw.Widget _bouwArtikelBlok(
    OfferteDocumentData data,
    _GenummerdeOffertePositie artikel, {
    bool? kortingToestaan,
    bool toonPrijsOpties = true,
    bool toonOptieMelding = true,
  }) {
    final isOptie = artikel.positie.isOfferteOptie;
    final kortingToestaanEffectief = kortingToestaan ?? !isOptie;
    final positieOpties = toonPrijsOpties
        ? data.positiePrijsOptiesVoor(artikel.positie)
        : const <OffertePrijsOptieRegel>[];
    final isVelux = artikel.positie.veluxDakraamData != null;
    final artikelType = isVelux
        ? OffertePdfVeluxDakraamWidget.titelVoorPositie(artikel.positie)
        : artikel.positie.formulierTypeLabel;
    final uitvoeringsRegels = isVelux
        ? const <String>[]
        : OpmetingArtikelTypeOmschrijvingHelper.omschrijvingRegelsVoor(
            artikel.positie,
          );
    final artikelKopHoogte = _artikelKopHoogteVoor(
      artikel.positie,
      toonOptieMelding: toonOptieMelding,
    );

    return pw.SizedBox(
      height: _berekenArtikelBlokHoogte(
        data,
        artikel.positie,
        kortingToestaan: kortingToestaanEffectief,
        toonPrijsOpties: toonPrijsOpties,
        toonOptieMelding: toonOptieMelding,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: <pw.Widget>[
          pw.SizedBox(
            height: artikelKopHoogte,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: <pw.Widget>[
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: <pw.Widget>[
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: artikel.kopLabel,
                            style: pw.TextStyle(
                              color: tekstDonker,
                              fontSize: 11.9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.TextSpan(
                            text: '  -  $artikelType',
                            style: pw.TextStyle(
                              color: oranje,
                              fontSize: 11.9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (uitvoeringsRegels.isNotEmpty) ...<pw.Widget>[
                      pw.SizedBox(width: 6),
                      pw.Expanded(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 1.5),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: <pw.Widget>[
                              for (final regel in uitvoeringsRegels)
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(
                                    bottom: 1.5,
                                  ),
                                  child: pw.Text(
                                    regel,
                                    style: pw.TextStyle(
                                      color: tekstGrijs,
                                      fontSize: 8.6,
                                      fontWeight: pw.FontWeight.normal,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (isOptie && toonOptieMelding) ...<pw.Widget>[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Optie — niet meegerekend in het eindtotaal',
                    style: pw.TextStyle(
                      color: tekstDonker,
                      fontSize: 7.8,
                      fontWeight: pw.FontWeight.normal,
                    ),
                  ),
                ],
                pw.SizedBox(height: 2),
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Container(width: 26, height: 1.1, color: oranje),
                ),
              ],
            ),
          ),
          if (artikel.positie.vasteInzethorData != null)
            OffertePdfInzethorWidget.bouwPositie(
              positie: artikel.positie,
              kortingToestaan: kortingToestaanEffectief,
              isOptie: isOptie,
              btwPercentage: data.btwPercentage,
              btwRegelLabel: data.btwRegelLabel,
            )
          else if (artikel.positie.vliegendeurData != null)
            OffertePdfVliegendeurWidget.bouwPositie(
              positie: artikel.positie,
              kortingToestaan: kortingToestaanEffectief,
              isOptie: isOptie,
              btwPercentage: data.btwPercentage,
              btwRegelLabel: data.btwRegelLabel,
            )
          else if (artikel.positie.schuifvliegendeurData != null)
            OffertePdfSchuifvliegendeurWidget.bouwPositie(
              positie: artikel.positie,
              kortingToestaan: kortingToestaanEffectief,
              isOptie: isOptie,
              btwPercentage: data.btwPercentage,
              btwRegelLabel: data.btwRegelLabel,
            )
          else if (artikel.positie.plooiwerkenData != null)
            OffertePdfPlooiwerkenWidget.bouwPositie(
              positie: artikel.positie,
              kortingToestaan: kortingToestaanEffectief,
              isOptie: isOptie,
              btwPercentage: data.btwPercentage,
              btwRegelLabel: data.btwRegelLabel,
            )
          else if (artikel.positie.voorzetscreenData != null)
            OffertePdfVoorzetscreenWidget.bouwPositie(
              positie: artikel.positie,
              kortingToestaan: kortingToestaanEffectief,
              isOptie: isOptie,
              btwPercentage: data.btwPercentage,
              btwRegelLabel: data.btwRegelLabel,
            )
          else if (artikel.positie.voorzetrolluikData != null)
            OffertePdfVoorzetrolluikWidget.bouwPositie(
              positie: artikel.positie,
              kortingToestaan: kortingToestaanEffectief,
              isOptie: isOptie,
              btwPercentage: data.btwPercentage,
              btwRegelLabel: data.btwRegelLabel,
            )
          else if (artikel.positie.uitvalschermData != null)
            OffertePdfUitvalschermWidget.bouwPositie(
              positie: artikel.positie,
              kortingToestaan: kortingToestaanEffectief,
              isOptie: isOptie,
              btwPercentage: data.btwPercentage,
              btwRegelLabel: data.btwRegelLabel,
            )
          else if (artikel.positie.sektionalePoortData != null)
            OffertePdfSektionalePoortWidget.bouwPositie(
              positie: artikel.positie,
              kortingToestaan: kortingToestaanEffectief,
              isOptie: isOptie,
              btwPercentage: data.btwPercentage,
              btwRegelLabel: data.btwRegelLabel,
            )
          else if (artikel.positie.veluxDakraamData != null)
            OffertePdfVeluxDakraamWidget.bouwPositie(
              positie: artikel.positie,
              kortingToestaan: kortingToestaanEffectief,
              isOptie: isOptie,
              btwPercentage: data.btwPercentage,
              btwRegelLabel: data.btwRegelLabel,
            )
          else
            OffertePdfPvcRaamWidget.bouwPositie(
              positie: artikel.positie,
              isOptie: isOptie,
              kortingToestaan: kortingToestaanEffectief,
              btwPercentage: data.btwPercentage,
              btwRegelLabel: data.btwRegelLabel,
              tekeningPng: data.pvcRaamTekeningVoor(artikel.positie),
            ),
          if (positieOpties.isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 8),
            _bouwPositiePrijsOpties(positieOpties),
          ],
        ],
      ),
    );
  }

  static pw.Widget _bouwPositiePrijsOpties(
    List<OffertePrijsOptieRegel> opties,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFFFFBF5),
        borderRadius: pw.BorderRadius.circular(7),
        border: pw.Border.all(color: rand, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: <pw.Widget>[
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(11, 7, 11, 6),
            child: pw.Text(
              'Opties bij deze positie — niet meegerekend in eindtotaal',
              style: pw.TextStyle(
                color: tekstDonker,
                fontSize: 8.5,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          for (var index = 0; index < opties.length; index++) ...<pw.Widget>[
            pw.Container(height: 0.5, color: rand),
            pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(11, 6, 11, 6),
              child: pw.Row(
                children: <pw.Widget>[
                  pw.Expanded(
                    child: pw.Text(
                      opties[index].omschrijving,
                      style: const pw.TextStyle(
                        color: tekstGrijs,
                        fontSize: 8.1,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  pw.Text(
                    _formatteerEuro(opties[index].bedragExclBtw),
                    style: pw.TextStyle(
                      color: tekstDonker,
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static List<_OfferteDetailPagina> _verdeelOpmetingPositiesOverPaginas(
    OfferteDocumentData data,
  ) {
    final beschikbareHoogte =
        PdfPageFormat.a4.height -
        _opmetingPaddingBoven -
        _opmetingPaddingOnder -
        _opmetingKopHoogte -
        _opmetingKopTussenruimte -
        _paginaVoetReserve;

    final zichtbarePosities = data.posities
        .where(data.isOndersteundeOffertePositie)
        .toList(growable: false);
    final artikels = <_GenummerdeOffertePositie>[
      for (var index = 0; index < zichtbarePosities.length; index++)
        _GenummerdeOffertePositie(
          positie: zichtbarePosities[index],
          kopLabel: 'Positie ${index + 1}',
        ),
    ];

    final paginas = _verdeelArtikelblokken(
      data: data,
      artikels: artikels,
      beschikbareHoogte: beschikbareHoogte,
      toonPrijsOpties: false,
      toonOptieMelding: false,
    );

    if (paginas.isEmpty) {
      paginas.add(
        _OfferteDetailPagina(artikels: const <_GenummerdeOffertePositie>[]),
      );
    }

    return paginas;
  }

  static List<_OfferteDetailPagina> _verdeelPositiesOverPaginas(
    OfferteDocumentData data,
  ) {
    final beschikbareHoogte =
        PdfPageFormat.a4.height -
        _detailPaddingBoven -
        _detailPaddingOnder -
        _paginaVoetReserve;
    final eindBerekeningReserve = _berekenEindBerekeningReserve(data);

    // Vliegendeur en Schuifvliegendeur worden ook vanuit hun onafhankelijke
    // selecties toegevoegd en daarna op ID ontdubbeld. Zo kan een toekomstige
    // prijsfilter deze toebehorenartikelen nooit uit de PDF halen.
    String positieSleutel(OpmetingOverzichtRaamItem positie) {
      final id = positie.id.trim();
      return id.isNotEmpty ? 'id:$id' : 'object:${identityHashCode(positie)}';
    }

    final toegestaneSleutels = <String>{
      ...data.offertePositiesVoorWeergave.map(positieSleutel),
      ...data.vliegendeurPositiesVoorWeergave.map(positieSleutel),
      ...data.schuifvliegendeurPositiesVoorWeergave.map(positieSleutel),
    };
    final zichtbarePosities = data.posities
        .where(
          (positie) => toegestaneSleutels.contains(positieSleutel(positie)),
        )
        .toList(growable: false);

    final artikels = zichtbarePosities
        .map(
          (positie) => _GenummerdeOffertePositie(
            positie: positie,
            kopLabel: positie.isOfferteOptieOpPositie
                ? 'Optie ${data.optieLetter(positie)}'
                : 'Artikel ${data.hoofdofferteArtikelNummer(positie)}',
          ),
        )
        .toList(growable: false);

    final paginas = _verdeelArtikelblokken(
      data: data,
      artikels: artikels,
      beschikbareHoogte: beschikbareHoogte,
    );

    if (paginas.isEmpty) {
      paginas.add(
        _OfferteDetailPagina(artikels: const <_GenummerdeOffertePositie>[]),
      );
    }

    final laatstePaginaHoogte = _berekenGebruikteArtikelHoogte(
      data,
      paginas.last.artikels,
    );
    if (laatstePaginaHoogte + eindBerekeningReserve > beschikbareHoogte) {
      paginas.add(
        _OfferteDetailPagina(artikels: const <_GenummerdeOffertePositie>[]),
      );
    }

    return paginas;
  }

  static List<_OfferteDetailPagina> _verdeelOptiesOverPaginas(
    OfferteDocumentData data,
  ) {
    final beschikbareHoogte =
        PdfPageFormat.a4.height -
        _detailPaddingBoven -
        _detailPaddingOnder -
        _paginaVoetReserve;

    final opties = data.offerteOptiePosities
        .where((positie) => positie.isOfferteOptieOpApartePagina)
        .map(
          (positie) => _GenummerdeOffertePositie(
            positie: positie,
            kopLabel: 'Optie ${data.optieLetter(positie)}',
          ),
        )
        .toList(growable: false);

    return _verdeelArtikelblokken(
      data: data,
      artikels: opties,
      beschikbareHoogte: beschikbareHoogte,
      kortingToestaan: false,
    );
  }

  static List<_OfferteDetailPagina> _verdeelArtikelblokken({
    required OfferteDocumentData data,
    required List<_GenummerdeOffertePositie> artikels,
    required double beschikbareHoogte,
    bool? kortingToestaan,
    bool toonPrijsOpties = true,
    bool toonOptieMelding = true,
  }) {
    final paginas = <_OfferteDetailPagina>[];
    var huidigeArtikels = <_GenummerdeOffertePositie>[];
    var gebruikteHoogte = 0.0;

    void bewaarHuidigePagina() {
      if (huidigeArtikels.isEmpty) return;
      paginas.add(_OfferteDetailPagina(artikels: huidigeArtikels));
      huidigeArtikels = <_GenummerdeOffertePositie>[];
      gebruikteHoogte = 0.0;
    }

    for (final artikel in artikels) {
      final artikelHoogte = _berekenArtikelBlokHoogte(
        data,
        artikel.positie,
        kortingToestaan: kortingToestaan,
        toonPrijsOpties: toonPrijsOpties,
        toonOptieMelding: toonOptieMelding,
      );
      final tussenruimte = huidigeArtikels.isEmpty
          ? 0.0
          : _ruimteTussenArtikels;

      if (huidigeArtikels.isNotEmpty &&
          gebruikteHoogte + tussenruimte + artikelHoogte > beschikbareHoogte) {
        bewaarHuidigePagina();
      }

      if (huidigeArtikels.isNotEmpty) {
        gebruikteHoogte += _ruimteTussenArtikels;
      }
      huidigeArtikels.add(artikel);
      gebruikteHoogte += artikelHoogte;
    }

    bewaarHuidigePagina();
    return paginas;
  }

  static double _berekenArtikelBlokHoogte(
    OfferteDocumentData data,
    OpmetingOverzichtRaamItem positie, {
    bool? kortingToestaan,
    bool toonPrijsOpties = true,
    bool toonOptieMelding = true,
  }) {
    final isOptie = positie.isOfferteOptie;
    final kortingToestaanEffectief = kortingToestaan ?? !isOptie;
    final positieOpties = toonPrijsOpties
        ? data.positiePrijsOptiesVoor(positie)
        : const <OffertePrijsOptieRegel>[];
    final optieRegelsHoogte = positieOpties.isEmpty
        ? 0.0
        : 32.0 + (positieOpties.length * 22.0) + 8.0;

    final double inhoudHoogte;
    if (positie.vasteInzethorData != null) {
      inhoudHoogte = OffertePdfInzethorWidget.berekenTotalePositieHoogte(
        positie,
        kortingToestaan: kortingToestaanEffectief,
        isOptie: isOptie,
      );
    } else if (positie.vliegendeurData != null) {
      inhoudHoogte = OffertePdfVliegendeurWidget.berekenTotalePositieHoogte(
        positie,
        kortingToestaan: kortingToestaanEffectief,
        isOptie: isOptie,
      );
    } else if (positie.schuifvliegendeurData != null) {
      inhoudHoogte =
          OffertePdfSchuifvliegendeurWidget.berekenTotalePositieHoogte(
            positie,
            kortingToestaan: kortingToestaanEffectief,
            isOptie: isOptie,
          );
    } else if (positie.plooiwerkenData != null) {
      inhoudHoogte = OffertePdfPlooiwerkenWidget.berekenTotalePositieHoogte(
        positie,
        kortingToestaan: kortingToestaanEffectief,
        isOptie: isOptie,
      );
    } else if (positie.voorzetscreenData != null) {
      inhoudHoogte = OffertePdfVoorzetscreenWidget.berekenTotalePositieHoogte(
        positie,
        kortingToestaan: kortingToestaanEffectief,
        isOptie: isOptie,
      );
    } else if (positie.voorzetrolluikData != null) {
      inhoudHoogte = OffertePdfVoorzetrolluikWidget.berekenTotalePositieHoogte(
        positie,
        kortingToestaan: kortingToestaanEffectief,
        isOptie: isOptie,
      );
    } else if (positie.uitvalschermData != null) {
      inhoudHoogte = OffertePdfUitvalschermWidget.berekenTotalePositieHoogte(
        positie,
        kortingToestaan: kortingToestaanEffectief,
        isOptie: isOptie,
      );
    } else if (positie.sektionalePoortData != null) {
      inhoudHoogte = OffertePdfSektionalePoortWidget.berekenTotalePositieHoogte(
        positie,
        kortingToestaan: kortingToestaanEffectief,
        isOptie: isOptie,
      );
    } else if (positie.veluxDakraamData != null) {
      inhoudHoogte = OffertePdfVeluxDakraamWidget.berekenTotalePositieHoogte(
        positie,
        kortingToestaan: kortingToestaanEffectief,
        isOptie: isOptie,
      );
    } else {
      inhoudHoogte = OffertePdfPvcRaamWidget.berekenTotalePositieHoogte(
        positie,
        kortingToestaan: kortingToestaanEffectief,
        isOptie: isOptie,
      );
    }

    return _artikelKopHoogteVoor(positie, toonOptieMelding: toonOptieMelding) +
        inhoudHoogte +
        optieRegelsHoogte;
  }

  static double _artikelKopHoogteVoor(
    OpmetingOverzichtRaamItem positie, {
    bool toonOptieMelding = true,
  }) {
    final uitvoeringsRegels = positie.veluxDakraamData != null
        ? const <String>[]
        : OpmetingArtikelTypeOmschrijvingHelper.omschrijvingRegelsVoor(positie);
    final extraRegels = uitvoeringsRegels.length > 1
        ? uitvoeringsRegels.length - 1
        : 0;
    final optieMeldingHoogte = toonOptieMelding && positie.isOfferteOptie
        ? 10.0
        : 0.0;

    return _artikelKopHoogte + optieMeldingHoogte + extraRegels * 9.5;
  }

  static double _berekenGebruikteArtikelHoogte(
    OfferteDocumentData data,
    List<_GenummerdeOffertePositie> artikels,
  ) {
    if (artikels.isEmpty) return 0;

    var hoogte = 0.0;
    for (var index = 0; index < artikels.length; index++) {
      if (index > 0) hoogte += _ruimteTussenArtikels;
      hoogte += _berekenArtikelBlokHoogte(data, artikels[index].positie);
    }
    return hoogte;
  }

  static double _berekenEindBerekeningReserve(OfferteDocumentData data) {
    final aantalProjectRegels =
        data.afzonderlijkeProjectPrijsregelsVoorOfferte.length +
        data.projectOmschrijvingZonderPrijsRegelsVoorOfferte.length +
        data.algemeneArtikelPrijsregelsInbegrepenInOfferte.length;
    final aantalProjectOpties = data.lossePrijsOpties.length;
    var reserve = _basisEindBerekeningReserve;
    if (aantalProjectRegels > 0) {
      reserve += 38.0 + (aantalProjectRegels * 25.0);
    }
    if (aantalProjectOpties > 0) {
      reserve += 38.0 + (aantalProjectOpties * 24.0);
    }
    return reserve;
  }

  static pw.Widget _bouwProjectPrijsregels(OfferteDocumentData data) {
    final projectRegels = [
      ...data.projectOmschrijvingZonderPrijsRegelsVoorOfferte,
      ...data.afzonderlijkeProjectPrijsregelsVoorOfferte,
    ];
    final algemeneRegels = data.algemeneArtikelPrijsregelsInbegrepenInOfferte;

    return pw.Container(
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF9FAFB),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: rand, width: 0.9),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: <pw.Widget>[
          pw.Container(
            padding: const pw.EdgeInsets.fromLTRB(12, 8, 12, 7),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFFFF7ED),
              borderRadius: pw.BorderRadius.circular(7),
            ),
            child: pw.Text(
              'Extra werk/materiaal inbegrepen in offerte',
              style: pw.TextStyle(
                color: tekstDonker,
                fontSize: 8.6,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          for (var index = 0; index < algemeneRegels.length; index++)
            _bouwSamengevoegdeAlgemenePrijsregel(
              algemeneRegels[index],
              toonScheiding: index > 0,
            ),
          for (
            var index = 0;
            index < projectRegels.length;
            index++
          ) ...<pw.Widget>[
            if (algemeneRegels.isNotEmpty || index > 0)
              pw.Container(height: 0.7, color: rand),
            pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(12, 7, 12, 7),
              child: pw.Row(
                children: <pw.Widget>[
                  pw.Expanded(
                    child: pw.Text(
                      projectRegels[index].omschrijving,
                      style: const pw.TextStyle(
                        color: tekstGrijs,
                        fontSize: 8.5,
                      ),
                    ),
                  ),
                  if (projectRegels[index].toonAfzonderlijkePrijsOpOfferte) ...[
                    pw.SizedBox(width: 18),
                    pw.Text(
                      _formatteerEuro(projectRegels[index].totaalExclBtw),
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        color: tekstDonker,
                        fontSize: 8.6,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _bouwSamengevoegdeAlgemenePrijsregel(
    OfferteSamengevoegdeArtikelPrijsregel regel, {
    required bool toonScheiding,
  }) {
    return pw.Column(
      children: <pw.Widget>[
        if (toonScheiding) pw.Container(height: 0.7, color: rand),
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(12, 7, 12, 7),
          child: pw.Row(
            children: <pw.Widget>[
              pw.Expanded(
                child: pw.Text(
                  regel.omschrijving,
                  style: const pw.TextStyle(color: tekstGrijs, fontSize: 8.5),
                ),
              ),
              if (regel.toonAfzonderlijkePrijs) ...<pw.Widget>[
                pw.SizedBox(width: 18),
                pw.Text(
                  _formatteerEuro(regel.totaalExclBtw),
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    color: tekstDonker,
                    fontSize: 8.6,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _bouwGoedkeuringsPagina({
    required OfferteDocumentData data,
    required pw.ImageProvider logo,
    required OfferteGoedkeuring? goedkeuring,
    required int paginaNummer,
    required int totaalPaginaAantal,
  }) {
    final isOndertekend = goedkeuring?.isOndertekend ?? false;
    final klantNaam = data.klant.naam.trim();
    final offerteNummer = data.offerteNummer.trim().isEmpty
        ? 'Zonder offertenummer'
        : data.offerteNummer.trim();

    return pw.Container(
      width: PdfPageFormat.a4.width,
      height: PdfPageFormat.a4.height,
      color: PdfColors.white,
      padding: const pw.EdgeInsets.fromLTRB(
        34,
        _detailPaddingBoven,
        34,
        _detailPaddingOnder,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: <pw.Widget>[
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: <pw.Widget>[
              pw.Image(logo, width: 76, height: 34, fit: pw.BoxFit.contain),
              pw.SizedBox(width: 14),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Text(
                      'Goedkeuring offerte',
                      style: pw.TextStyle(
                        color: tekstDonker,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      '$offerteNummer · ${_formatteerDatum(data.offerteDatum)}',
                      style: const pw.TextStyle(
                        color: tekstGrijs,
                        fontSize: 8.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOndertekend)
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: pw.BoxDecoration(
                    color: const PdfColor.fromInt(0xFFE7F6EC),
                    borderRadius: pw.BorderRadius.circular(20),
                    border: pw.Border.all(
                      color: const PdfColor.fromInt(0xFF0B7A3B),
                      width: 0.7,
                    ),
                  ),
                  child: pw.Text(
                    'ONDERTEKEND',
                    style: pw.TextStyle(
                      color: const PdfColor.fromInt(0xFF0B7A3B),
                      fontSize: 7.5,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          pw.SizedBox(height: 14),
          pw.Container(height: 1, color: oranje),
          pw.SizedBox(height: 16),
          _bouwEindBerekening(data),
          pw.SizedBox(height: 18),
          _bouwGoedkeuringsContainer(
            data: data,
            goedkeuring: goedkeuring,
            klantNaam: klantNaam,
            offerteNummer: offerteNummer,
          ),
          pw.Spacer(),
          pw.Text(
            'Afzonderlijk vermelde opties zijn niet in het bovenstaande '
            'totaal inbegrepen, tenzij dit uitdrukkelijk anders is vermeld.',
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(color: tekstGrijs, fontSize: 7.2),
          ),
          pw.SizedBox(height: 10),
          _bouwPaginaVoet(
            logo: logo,
            paginaNummer: paginaNummer,
            totaalPaginaAantal: totaalPaginaAantal,
          ),
        ],
      ),
    );
  }

  static pw.Widget _bouwGoedkeuringsContainer({
    required OfferteDocumentData data,
    required OfferteGoedkeuring? goedkeuring,
    required String klantNaam,
    required String offerteNummer,
  }) {
    final isOndertekend = goedkeuring?.isOndertekend ?? false;

    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF9FAFB),
        borderRadius: pw.BorderRadius.circular(9),
        border: pw.Border.all(color: rand, width: 0.9),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: <pw.Widget>[
          pw.Text(
            'Goedkeuring door de klant',
            style: pw.TextStyle(
              color: tekstDonker,
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 7),
          pw.Text(
            'Ondergetekende verklaart kennis te hebben genomen van deze '
            'offerte en de bijbehorende voorwaarden en keurt de beschreven '
            'werken en het vermelde totaalbedrag goed.',
            style: const pw.TextStyle(
              color: tekstGrijs,
              fontSize: 8.2,
              lineSpacing: 2,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Expanded(
                child: _goedkeuringsInfoRegel(
                  label: 'Offertenummer',
                  waarde: offerteNummer,
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: _goedkeuringsInfoRegel(
                  label: 'Datum offerte',
                  waarde: _formatteerDatum(data.offerteDatum),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          _goedkeuringsInfoRegel(
            label: 'Totaal inclusief btw',
            waarde: _formatteerEuro(data.totaalInclusiefBtw),
            benadrukt: true,
          ),
          pw.SizedBox(height: 16),
          if (isOndertekend) ...<pw.Widget>[
            pw.Row(
              children: <pw.Widget>[
                pw.Expanded(
                  child: _goedkeuringsInfoRegel(
                    label: 'Naam klant',
                    waarde: goedkeuring!.naam.trim(),
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: _goedkeuringsInfoRegel(
                    label: 'Ondertekend op',
                    waarde: _formatteerDatumTijd(goedkeuring!.getekendOp),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Container(
              height: 128,
              padding: const pw.EdgeInsets.fromLTRB(12, 8, 12, 8),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(7),
                border: pw.Border.all(color: rand, width: 0.8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Text(
                    'Handtekening klant',
                    style: const pw.TextStyle(color: tekstGrijs, fontSize: 7.5),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Expanded(
                    child: pw.Center(
                      child: pw.Image(
                        pw.MemoryImage(goedkeuring!.handtekeningPng),
                        fit: pw.BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...<pw.Widget>[
            pw.Row(
              children: <pw.Widget>[
                pw.Expanded(
                  child: _legeGoedkeuringsLijn(
                    label: 'Naam klant',
                    vooraf: klantNaam,
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: _legeGoedkeuringsLijn(label: 'Datum goedkeuring'),
                ),
              ],
            ),
            pw.SizedBox(height: 14),
            pw.Container(
              height: 128,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(7),
                border: pw.Border.all(color: rand, width: 0.8),
              ),
              child: pw.Align(
                alignment: pw.Alignment.topLeft,
                child: pw.Text(
                  'Handtekening klant',
                  style: const pw.TextStyle(color: tekstGrijs, fontSize: 7.5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _goedkeuringsInfoRegel({
    required String label,
    required String waarde,
    bool benadrukt = false,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(
          label,
          style: const pw.TextStyle(color: tekstGrijs, fontSize: 7.2),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          waarde.trim().isEmpty ? '—' : waarde.trim(),
          style: pw.TextStyle(
            color: benadrukt ? oranje : tekstDonker,
            fontSize: benadrukt ? 10 : 8.5,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static pw.Widget _legeGoedkeuringsLijn({
    required String label,
    String vooraf = '',
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(
          label,
          style: const pw.TextStyle(color: tekstGrijs, fontSize: 7.2),
        ),
        pw.SizedBox(height: 6),
        if (vooraf.trim().isNotEmpty)
          pw.Text(
            vooraf.trim(),
            style: const pw.TextStyle(color: tekstDonker, fontSize: 8.5),
          ),
        pw.SizedBox(height: vooraf.trim().isNotEmpty ? 5 : 15),
        pw.Container(height: 0.8, color: tekstGrijs),
      ],
    );
  }

  static pw.Widget _bouwEindBerekening(OfferteDocumentData data) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: rand, width: 0.9),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: <pw.Widget>[
          _eindBerekeningRegel(
            label: 'Totaalprijs excl. btw',
            bedrag: data.totaalVoorKortingExclBtw,
          ),
          if (data.kortingTotaalExclBtw > 0.0) ...<pw.Widget>[
            pw.Container(height: 0.7, color: rand),
            _eindBerekeningRegel(
              label: data.kortingOmschrijving,
              bedrag: data.kortingTotaalExclBtw,
              negatief: true,
            ),
            pw.Container(height: 0.7, color: rand),
            _eindBerekeningRegel(
              label: 'Totaalprijs excl. btw na korting',
              bedrag: data.totaalExclusiefBtw,
            ),
          ],
          pw.Container(height: 0.7, color: rand),
          _eindBerekeningRegel(
            label: data.btwRegelLabel,
            bedrag: data.btwBedrag,
          ),
          pw.Container(height: 0.7, color: rand),
          pw.Container(
            color: const PdfColor.fromInt(0xFFFFF7ED),
            child: _eindBerekeningRegel(
              label: 'Totaalbedrag inclusief btw',
              bedrag: data.totaalInclusiefBtw,
              benadrukt: true,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _bouwLossePrijsOpties(OfferteDocumentData data) {
    final opties = data.lossePrijsOpties;
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFFFF7ED),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: oranje, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: <pw.Widget>[
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(12, 8, 12, 7),
            child: pw.Text(
              'Opties voor alle artikelen — niet meegerekend in eindtotaal',
              style: pw.TextStyle(
                color: tekstDonker,
                fontSize: 8.6,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          for (var index = 0; index < opties.length; index++) ...<pw.Widget>[
            if (index > 0) pw.Container(height: 0.7, color: rand),
            pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(12, 7, 12, 7),
              child: pw.Row(
                children: <pw.Widget>[
                  pw.Expanded(
                    child: pw.Text(
                      opties[index].omschrijving,
                      style: const pw.TextStyle(
                        color: tekstGrijs,
                        fontSize: 8.5,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 18),
                  pw.Text(
                    _formatteerEuro(opties[index].bedragExclBtw),
                    style: pw.TextStyle(
                      color: oranje,
                      fontSize: 8.6,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _eindBerekeningRegel({
    required String label,
    required double bedrag,
    bool benadrukt = false,
    bool negatief = false,
  }) {
    return pw.Padding(
      padding: pw.EdgeInsets.fromLTRB(
        14,
        benadrukt ? 10 : 8,
        14,
        benadrukt ? 10 : 8,
      ),
      child: pw.Row(
        children: <pw.Widget>[
          pw.Expanded(
            child: pw.Text(
              label,
              style: pw.TextStyle(
                color: benadrukt ? tekstDonker : tekstGrijs,
                fontSize: benadrukt ? 9.5 : 8.5,
                fontWeight: benadrukt
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
              ),
            ),
          ),
          pw.SizedBox(width: 18),
          pw.Text(
            negatief ? '- ${_formatteerEuro(bedrag)}' : _formatteerEuro(bedrag),
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              color: benadrukt ? oranje : tekstDonker,
              fontSize: benadrukt ? 12.5 : 9.5,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatteerEuro(double waarde) {
    final veilig = waarde.isFinite ? waarde : 0.0;
    final delen = veilig.toStringAsFixed(2).split('.');
    final geheel = delen.first;
    final decimalen = delen.length > 1 ? delen[1] : '00';
    final negatief = geheel.startsWith('-');
    final cijfers = negatief ? geheel.substring(1) : geheel;
    final buffer = StringBuffer();

    for (var index = 0; index < cijfers.length; index++) {
      if (index > 0 && (cijfers.length - index) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(cijfers[index]);
    }

    return '€ ${negatief ? '-' : ''}${buffer.toString()},$decimalen';
  }

  static pw.Widget _bouwVoetregel() {
    return pw.Row(
      children: <pw.Widget>[
        pw.Expanded(child: pw.Container(height: 1, color: oranje)),
        pw.SizedBox(width: 14),
        pw.Container(
          width: 8,
          height: 8,
          decoration: const pw.BoxDecoration(
            color: oranje,
            shape: pw.BoxShape.circle,
          ),
        ),
        pw.SizedBox(width: 14),
        pw.Expanded(child: pw.Container(height: 1, color: oranje)),
      ],
    );
  }

  static pw.Widget _bouwPaginaVoet({
    required pw.ImageProvider logo,
    required int paginaNummer,
    required int totaalPaginaAantal,
  }) {
    return pw.Column(
      children: <pw.Widget>[
        pw.Row(
          children: <pw.Widget>[
            pw.Expanded(child: pw.Container(height: 0.9, color: oranje)),
            pw.SizedBox(width: 12),
            pw.Image(logo, width: 42, height: 18, fit: pw.BoxFit.contain),
            pw.SizedBox(width: 12),
            pw.Expanded(child: pw.Container(height: 0.9, color: oranje)),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          'Pagina $paginaNummer van $totaalPaginaAantal',
          style: const pw.TextStyle(color: tekstGrijs, fontSize: 8.3),
        ),
      ],
    );
  }

  static String _formatteerDatumTijd(DateTime datum) {
    String twee(int waarde) => waarde.toString().padLeft(2, '0');

    return '${twee(datum.day)}/${twee(datum.month)}/${datum.year} '
        'om ${twee(datum.hour)}:${twee(datum.minute)}';
  }

  static String _formatteerDatum(DateTime datum) {
    String twee(int waarde) => waarde.toString().padLeft(2, '0');

    return '${twee(datum.day)}/${twee(datum.month)}/${datum.year}';
  }
}

class _OfferteDetailPagina {
  _OfferteDetailPagina({required List<_GenummerdeOffertePositie> artikels})
    : artikels = List<_GenummerdeOffertePositie>.from(artikels);

  final List<_GenummerdeOffertePositie> artikels;
}

class _GenummerdeOffertePositie {
  const _GenummerdeOffertePositie({
    required this.positie,
    required this.kopLabel,
  });

  final OpmetingOverzichtRaamItem positie;
  final String kopLabel;
}
