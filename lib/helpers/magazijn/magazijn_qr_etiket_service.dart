// THIMACO-CONTROLE: MAGAZIJN-QR-ETIKET-SERVICE-FASE-1-20260804

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'magazijn_model.dart';

class MagazijnQrEtiketService {
  const MagazijnQrEtiketService._();

  static Future<void> printEtiket({
    required MagazijnArtikel artikel,
    required String leverancierNaam,
    PdfPageFormat formaat = const PdfPageFormat(
      60 * PdfPageFormat.mm,
      40 * PdfPageFormat.mm,
      marginAll: 3 * PdfPageFormat.mm,
    ),
  }) async {
    final document = pw.Document();
    document.addPage(
      pw.Page(
        pageFormat: formaat,
        build: (_) => pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: <pw.Widget>[
            pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: artikel.qrWaarde,
              width: 30 * PdfPageFormat.mm,
              height: 30 * PdfPageFormat.mm,
            ),
            pw.SizedBox(width: 3 * PdfPageFormat.mm),
            pw.Expanded(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Text(
                    artikel.omschrijving,
                    maxLines: 3,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  if (artikel.effectiefBestelArtikelnummer.isNotEmpty)
                    pw.Text(
                      artikel.effectiefBestelArtikelnummer,
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  pw.Text(
                    leverancierNaam,
                    maxLines: 2,
                    style: const pw.TextStyle(fontSize: 7),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final bytes = await document.save();
    await Printing.layoutPdf(
      name: 'Magazijn_${artikel.omschrijving}.pdf',
      onLayout: (_) async => Uint8List.fromList(bytes),
    );
  }
}
