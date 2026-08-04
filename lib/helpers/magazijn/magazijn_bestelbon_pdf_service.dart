// THIMACO-CONTROLE: MAGAZIJN-BESTELBON-PDF-SERVICE-20260804

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'magazijn_model.dart';

class MagazijnBestelbonRegel {
  const MagazijnBestelbonRegel({required this.artikel, required this.aantal});

  final MagazijnArtikel artikel;
  final int aantal;
}

class MagazijnBestelbonPdfService {
  const MagazijnBestelbonPdfService._();

  static Future<Uint8List> maakPdf({
    required MagazijnLeverancier leverancier,
    required List<MagazijnBestelbonRegel> regels,
    String opmerking = '',
  }) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(34),
        build: (_) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: <pw.Widget>[
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.Text(
                          'THIMACO',
                          style: pw.TextStyle(
                            fontSize: 21,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text('Ramen · deuren · zonwering'),
                        pw.SizedBox(height: 6),
                        pw.Text('Kerkdreef 1'),
                        pw.Text('Beveren-Leie'),
                        pw.Text('056 44 91 35'),
                        pw.Text('info@thimaco.be'),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey400),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: <pw.Widget>[
                          pw.Text(
                            leverancier.naam,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          if (leverancier.contactpersoon.trim().isNotEmpty)
                            pw.Text(leverancier.contactpersoon.trim()),
                          if (leverancier.email.trim().isNotEmpty)
                            pw.Text(leverancier.email.trim()),
                          if (leverancier.telefoonVoorBestelbon.isNotEmpty)
                            pw.Text(leverancier.telefoonVoorBestelbon),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
              pw.Text(
                'BESTELBON',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Datum: ${_datum(DateTime.now())}',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey500),
                columnWidths: const <int, pw.TableColumnWidth>{
                  0: pw.FlexColumnWidth(4.2),
                  1: pw.FlexColumnWidth(2.2),
                  2: pw.FlexColumnWidth(1.6),
                },
                children: <pw.TableRow>[_kopRij(), ...regels.map(_artikelRij)],
              ),
              if (opmerking.trim().isNotEmpty) ...<pw.Widget>[
                pw.SizedBox(height: 18),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey500),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Text(
                        'Opmerking',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(opmerking.trim()),
                    ],
                  ),
                ),
              ],
              pw.Spacer(),
              pw.Text(
                'Gelieve deze bestelling te bevestigen.',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          );
        },
      ),
    );

    return document.save();
  }

  static Future<void> afdrukken({
    required MagazijnLeverancier leverancier,
    required List<MagazijnBestelbonRegel> regels,
    String opmerking = '',
  }) async {
    final bytes = await maakPdf(
      leverancier: leverancier,
      regels: regels,
      opmerking: opmerking,
    );
    await Printing.layoutPdf(
      name: bestandsNaam(leverancier),
      onLayout: (_) async => bytes,
    );
  }

  static Future<void> delen({
    required MagazijnLeverancier leverancier,
    required List<MagazijnBestelbonRegel> regels,
    String opmerking = '',
  }) async {
    final bytes = await maakPdf(
      leverancier: leverancier,
      regels: regels,
      opmerking: opmerking,
    );
    await Printing.sharePdf(bytes: bytes, filename: bestandsNaam(leverancier));
  }

  static pw.TableRow _kopRij() {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
      children: <pw.Widget>[
        _cel('Omschrijving', vet: true),
        _cel('Artikelnr.', vet: true),
        _cel('Aantal te bestellen', vet: true),
      ],
    );
  }

  static pw.TableRow _artikelRij(MagazijnBestelbonRegel regel) {
    return pw.TableRow(
      children: <pw.Widget>[
        _cel(regel.artikel.omschrijving),
        _cel(regel.artikel.effectiefBestelArtikelnummer),
        _cel(
          '${regel.aantal} ${regel.artikel.eenheidVoorAantal(regel.aantal)}',
        ),
      ],
    );
  }

  static pw.Widget _cel(String tekst, {bool vet = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(7),
      child: pw.Text(
        tekst,
        style: pw.TextStyle(
          fontSize: 9.5,
          fontWeight: vet ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static String _datum(DateTime datum) {
    return '${datum.day.toString().padLeft(2, '0')}/'
        '${datum.month.toString().padLeft(2, '0')}/'
        '${datum.year}';
  }

  static String bestandsNaam(MagazijnLeverancier leverancier) {
    final veilig = leverancier.naam
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    return 'Bestelbon_$veilig.pdf';
  }
}
