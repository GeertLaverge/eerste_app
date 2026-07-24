import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../opmeting/project/opmeting_project_titelhoofd_model.dart';
import 'offerte_pdf_model.dart';
import 'offerte_pdf_service.dart';
import 'offerte_pvc_raam_tekening_service.dart';
import 'prijzen/offerte_project_prijs_service.dart';

class OffertePdfPreviewPagina extends StatefulWidget {
  const OffertePdfPreviewPagina({
    super.key,
    required this.titelhoofd,
    required this.posities,
  });

  final OpmetingProjectTitelhoofd titelhoofd;
  final List<OpmetingOverzichtRaamItem> posities;

  @override
  State<OffertePdfPreviewPagina> createState() {
    return _OffertePdfPreviewPaginaState();
  }
}

class _OffertePdfPreviewPaginaState extends State<OffertePdfPreviewPagina> {
  late Future<Uint8List> _pdfFuture;
  int _pdfVersie = 0;

  @override
  void initState() {
    super.initState();
    _pdfFuture = _bouwPdf();
  }

  @override
  void didUpdateWidget(covariant OffertePdfPreviewPagina oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.titelhoofd != widget.titelhoofd ||
        oldWidget.posities != widget.posities) {
      _maakNieuwePdfFuture();
    }
  }

  /// Tijdens hot reload blijft de State van deze pagina bestaan.
  /// Zonder deze heropbouw blijft PdfPreview de eerder gemaakte PDF tonen.
  @override
  void reassemble() {
    super.reassemble();

    if (!mounted) {
      return;
    }

    setState(_maakNieuwePdfFuture);
  }

  void _maakNieuwePdfFuture() {
    _pdfVersie++;
    _pdfFuture = _bouwPdf();
  }

  void _vernieuwPdf() {
    setState(_maakNieuwePdfFuture);
  }

  Future<Uint8List> _bouwPdf() async {
    final datum = DateTime.now();
    final titelhoofd = widget.titelhoofd;
    // De PDF-selectie mag niet samenvallen met de prijsselectie. Een
    // Vliegendeur heeft bewust geen prijsprofiel, maar moet wel als artikel
    // worden doorgegeven aan het afzonderlijke PDF-widget.
    final posities = List<OpmetingOverzichtRaamItem>.unmodifiable(
      widget.posities.where((positie) => !positie.isVerwijderd),
    );

    final pvcRaamTekeningen =
        await OffertePvcRaamTekeningService.maakTekeningen(posities);

    final projectPrijsResultaat =
        OfferteProjectPrijsService.berekenAlleOndersteundeUitTitelhoofd(
          titelhoofd: titelhoofd,
          alleOpmetingen: posities,
        );

    final data = OfferteDocumentData(
      klant: OfferteKlantgegevens.vanTitelhoofd(titelhoofd),
      offerteNummer: titelhoofd.samengesteldOffertenummer,
      offerteDatum: datum,
      btwTarief: titelhoofd.btwTarief,
      kortingOmschrijving: titelhoofd.kortingOmschrijving,
      projectKleurBinnen: titelhoofd.projectKleurBinnen,
      projectKleurBuiten: titelhoofd.projectKleurBuiten,
      ralKleurToebehoren: titelhoofd.ralKleurToebehoren,
      posities: posities,
      projectPrijsregels: projectPrijsResultaat.prijsregels,
      pvcRaamTekeningen: pvcRaamTekeningen,
    );

    return OffertePdfService.bouwPdf(data);
  }

  @override
  Widget build(BuildContext context) {
    final offerteNummer = widget.titelhoofd.samengesteldOffertenummer;
    final veiligeNaam = widget.titelhoofd.klantNaam.trim().replaceAll(
      RegExp(r'[^a-zA-Z0-9_-]+'),
      '_',
    );
    final nummerVoorBestandsnaam = offerteNummer.trim().isEmpty
        ? 'zonder_nummer'
        : offerteNummer.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF15A24),
        foregroundColor: Colors.white,
        title: const Text(
          'Offertevoorbeeld',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'PDF vernieuwen',
            onPressed: _vernieuwPdf,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final beschikbareBreedte = math
              .max(280.0, constraints.maxWidth - 24)
              .toDouble();
          final beschikbareHoogte = math
              .max(360.0, constraints.maxHeight - 88)
              .toDouble();
          final breedteOpBasisVanHoogte =
              beschikbareHoogte *
              PdfPageFormat.a4.width /
              PdfPageFormat.a4.height;
          final passendePaginaBreedte = math
              .min(beschikbareBreedte, breedteOpBasisVanHoogte)
              .toDouble();

          return PdfPreview(
            key: ValueKey<int>(_pdfVersie),
            initialPageFormat: PdfPageFormat.a4,
            maxPageWidth: passendePaginaBreedte,
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            allowPrinting: true,
            allowSharing: true,
            pdfFileName: veiligeNaam.isEmpty
                ? 'Thimaco_offerte_$nummerVoorBestandsnaam.pdf'
                : 'Thimaco_offerte_${nummerVoorBestandsnaam}_$veiligeNaam.pdf',
            build: (_) => _pdfFuture,
            loadingWidget: const Center(
              child: CircularProgressIndicator(color: Color(0xFFF15A24)),
            ),
            onError: (context, fout) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'De offerte kon niet worden opgebouwd.\n\n$fout',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFB91C1C),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
