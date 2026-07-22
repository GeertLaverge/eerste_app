import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../opmeting/overzicht/opmeting_artikel_type_omschrijving_helper.dart';
import '../opmeting/overzicht/opmeting_overzicht_model.dart';
import 'offerte_pdf_inzethor_widget.dart';
import 'offerte_pdf_pvc_raam_widget.dart';
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
  static const double _artikelKopHoogte = 64;
  static const double _ruimteTussenArtikels = 14;
  static const double _paginaVoetReserve = 36;
  static const double _basisEindBerekeningReserve = 106;

  static String maakOfferteNummer(DateTime datum) {
    String twee(int waarde) => waarde.toString().padLeft(2, '0');

    return 'OF-${datum.year}${twee(datum.month)}${twee(datum.day)}-'
        '${twee(datum.hour)}${twee(datum.minute)}';
  }

  static Future<Uint8List> bouwPdf(OfferteDocumentData data) async {
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
    final totaalPaginaAantal = 1 + detailPaginas.length + optiePaginas.length;

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
    // na de volledige hoofdofferte en haar eindberekening. Opties met
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

    return document.save();
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
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: <pw.Widget>[
                        pw.Row(
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
                                  if (data.heeftProjectKleuren) ...<pw.Widget>[
                                    pw.SizedBox(height: 10),
                                    _bouwProjectKleurenBlok(data),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        pw.Spacer(),
                        _bouwWelkomBlok(),
                        pw.SizedBox(height: 24),
                        _bouwVoetregel(),
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
    final aanspreking = klantNaam.isEmpty
        ? 'Dhr. & Mevr.'
        : 'Dhr. & Mevr. $klantNaam';

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
            aanspreking,
            style: pw.TextStyle(
              color: tekstDonker,
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              lineSpacing: 1.5,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Align(
            alignment: pw.Alignment.centerLeft,
            child: pw.Container(width: 32, height: 1.4, color: oranje),
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
            _bouwEindBerekening(data),
            if (data.heeftLossePrijsOpties) ...<pw.Widget>[
              pw.SizedBox(height: 10),
              _bouwLossePrijsOpties(data),
            ],
            pw.SizedBox(height: 14),
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
  }) {
    final isOptie = artikel.positie.isOfferteOptie;
    final kortingToestaanEffectief = kortingToestaan ?? !isOptie;
    final positieOpties = data.positiePrijsOptiesVoor(artikel.positie);
    final artikelType = artikel.positie.formulierTypeLabel;
    final uitvoeringsRegels =
        OpmetingArtikelTypeOmschrijvingHelper.omschrijvingRegelsVoor(
          artikel.positie,
        );
    final artikelKopHoogte = _artikelKopHoogteVoor(artikel.positie);

    return pw.SizedBox(
      height: _berekenArtikelBlokHoogte(
        data,
        artikel.positie,
        kortingToestaan: kortingToestaanEffectief,
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
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: artikel.kopLabel,
                            style: pw.TextStyle(
                              color: tekstDonker,
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.TextSpan(
                            text: '  -  $artikelType',
                            style: pw.TextStyle(
                              color: oranje,
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (uitvoeringsRegels.isNotEmpty) ...<pw.Widget>[
                      pw.SizedBox(width: 8),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: <pw.Widget>[
                            for (final regel in uitvoeringsRegels)
                              pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 1.5),
                                child: pw.Text(
                                  regel,
                                  style: pw.TextStyle(
                                    color: tekstGrijs,
                                    fontSize: 9.5,
                                    fontWeight: pw.FontWeight.normal,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                if (isOptie) ...<pw.Widget>[
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'Optie — niet meegerekend in het eindtotaal',
                    style: pw.TextStyle(
                      color: tekstDonker,
                      fontSize: 8.5,
                      fontWeight: pw.FontWeight.normal,
                    ),
                  ),
                ],
                pw.SizedBox(height: 6),
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Container(width: 32, height: 1.4, color: oranje),
                ),
                pw.Spacer(),
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

  static List<_OfferteDetailPagina> _verdeelPositiesOverPaginas(
    OfferteDocumentData data,
  ) {
    final beschikbareHoogte =
        PdfPageFormat.a4.height -
        _detailPaddingBoven -
        _detailPaddingOnder -
        _paginaVoetReserve;
    final eindBerekeningReserve = _berekenEindBerekeningReserve(data);

    final artikels = data.offertePositiesVoorWeergave
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
  }) {
    final isOptie = positie.isOfferteOptie;
    final kortingToestaanEffectief = kortingToestaan ?? !isOptie;
    final positieOpties = data.positiePrijsOptiesVoor(positie);
    final optieRegelsHoogte = positieOpties.isEmpty
        ? 0.0
        : 32.0 + (positieOpties.length * 22.0) + 8.0;

    final inhoudHoogte = positie.vasteInzethorData != null
        ? OffertePdfInzethorWidget.berekenTotalePositieHoogte(
            positie,
            kortingToestaan: kortingToestaanEffectief,
            isOptie: isOptie,
          )
        : OffertePdfPvcRaamWidget.berekenTotalePositieHoogte(
            positie,
            kortingToestaan: kortingToestaanEffectief,
            isOptie: isOptie,
          );

    return _artikelKopHoogteVoor(positie) + inhoudHoogte + optieRegelsHoogte;
  }

  static double _artikelKopHoogteVoor(OpmetingOverzichtRaamItem positie) {
    final uitvoeringsRegels =
        OpmetingArtikelTypeOmschrijvingHelper.omschrijvingRegelsVoor(positie);
    final extraRegels = uitvoeringsRegels.length > 1
        ? uitvoeringsRegels.length - 1
        : 0;

    return _artikelKopHoogte + extraRegels * 11.5;
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
        data.projectOmschrijvingZonderPrijsRegelsVoorOfferte.length;
    final aantalProjectOpties = data.lossePrijsOpties.length;
    var reserve = _basisEindBerekeningReserve;
    if (data.kortingTotaalExclBtw > 0.0) reserve += 48.0;
    if (aantalProjectRegels > 0) {
      reserve += 38.0 + (aantalProjectRegels * 25.0);
    }
    if (aantalProjectOpties > 0) {
      reserve += 38.0 + (aantalProjectOpties * 24.0);
    }
    return reserve;
  }

  static pw.Widget _bouwProjectPrijsregels(OfferteDocumentData data) {
    final regels = [
      ...data.projectOmschrijvingZonderPrijsRegelsVoorOfferte,
      ...data.afzonderlijkeProjectPrijsregelsVoorOfferte,
    ];

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
              'Bijkomende werken/materiaal',
              style: pw.TextStyle(
                color: tekstDonker,
                fontSize: 9.5,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          for (var index = 0; index < regels.length; index++) ...<pw.Widget>[
            if (index > 0) pw.Container(height: 0.7, color: rand),
            pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(12, 7, 12, 7),
              child: pw.Row(
                children: <pw.Widget>[
                  pw.Expanded(
                    child: pw.Text(
                      regels[index].omschrijving,
                      style: const pw.TextStyle(
                        color: tekstGrijs,
                        fontSize: 8.5,
                      ),
                    ),
                  ),
                  if (regels[index].toonAfzonderlijkePrijsOpOfferte) ...[
                    pw.SizedBox(width: 18),
                    pw.Text(
                      _formatteerEuro(regels[index].totaalExclBtw),
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        color: tekstDonker,
                        fontSize: 9.5,
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
                fontSize: 9.5,
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
                      fontSize: 9.5,
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
