// THIMACO-CONTROLE: OPMETING-PDF-ONEDRIVE-MAPPEN-EN-BESTANDSNAAM-20260731
// THIMACO-CONTROLE: OPMETING-PDF-PREVIEW-ZONDER-PRIJZEN-20260731
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../opmeting/project/opmeting_project_titelhoofd_model.dart';
import '../sync/onedrive_klantdocument_service.dart';
import '../sync/onedrive_map_kiezer_dialog.dart';
import 'offerte_pdf_model.dart';
import 'offerte_pdf_service.dart';
import 'offerte_pvc_raam_tekening_service.dart';

class OpmetingPdfPreviewPagina extends StatefulWidget {
  const OpmetingPdfPreviewPagina({
    super.key,
    required this.titelhoofd,
    required this.posities,
  });

  final OpmetingProjectTitelhoofd titelhoofd;
  final List<OpmetingOverzichtRaamItem> posities;

  @override
  State<OpmetingPdfPreviewPagina> createState() {
    return _OpmetingPdfPreviewPaginaState();
  }
}

class _OpmetingPdfPreviewPaginaState extends State<OpmetingPdfPreviewPagina> {
  static const Color _groen = Color(0xFF0B7A3B);

  final OneDriveKlantdocumentService _oneDriveService =
      OneDriveKlantdocumentService();

  late Future<Uint8List> _pdfFuture;
  int _pdfVersie = 0;
  bool _opslaanNaarOneDriveBezig = false;

  @override
  void initState() {
    super.initState();
    _pdfFuture = _bouwPdf();
  }

  @override
  void didUpdateWidget(covariant OpmetingPdfPreviewPagina oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.titelhoofd != widget.titelhoofd ||
        oldWidget.posities != widget.posities) {
      _maakNieuwePdfFuture();
    }
  }

  @override
  void reassemble() {
    super.reassemble();

    if (!mounted) return;
    setState(_maakNieuwePdfFuture);
  }

  void _maakNieuwePdfFuture() {
    _pdfVersie++;
    _pdfFuture = _bouwPdf();
  }

  void _vernieuwPdf() {
    setState(_maakNieuwePdfFuture);
  }

  String _maakBestandsnaam() {
    final datumTekst = _datumVoorBestandsnaam(DateTime.now());
    final veiligeNaam = _veiligBestandsdeel(widget.titelhoofd.klantNaam);

    return veiligeNaam.isEmpty
        ? 'Thimaco_opmeting_$datumTekst.pdf'
        : 'Thimaco_opmeting_${datumTekst}_$veiligeNaam.pdf';
  }

  Future<void> _opslaanNaarOneDrive() async {
    if (_opslaanNaarOneDriveBezig) return;

    setState(() {
      _opslaanNaarOneDriveBezig = true;
    });

    try {
      final gekozenMap = await OneDriveMapKiezerDialog.toon(
        context: context,
        service: _oneDriveService,
        klantNaam: widget.titelhoofd.klantNaam,
        klantnummer: widget.titelhoofd.klantnummer,
        initieleBestandsnaam: _maakBestandsnaam(),
      );

      if (gekozenMap == null || !mounted) return;

      final pdfBytes = await _pdfFuture;
      final resultaat = await _oneDriveService.uploadPdf(
        map: gekozenMap,
        documentType: 'Opmeting',
        bestandsnaam: gekozenMap.bestandsnaam,
        bytes: pdfBytes,
      );

      if (!mounted) return;

      setState(() {
        _opslaanNaarOneDriveBezig = false;
      });
      Navigator.of(context).pop(resultaat);
    } on OneDriveKlantdocumentException catch (fout) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(fout.bericht),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } catch (fout) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opslaan naar OneDrive is niet gelukt.\n$fout'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted && _opslaanNaarOneDriveBezig) {
        setState(() {
          _opslaanNaarOneDriveBezig = false;
        });
      }
    }
  }

  Widget _bouwOneDriveActie(BuildContext context) {
    final toonTekst = MediaQuery.sizeOf(context).width >= 700;

    if (!toonTekst) {
      return IconButton(
        tooltip: 'Opslaan naar OneDrive klanten',
        onPressed: _opslaanNaarOneDriveBezig ? null : _opslaanNaarOneDrive,
        icon: _opslaanNaarOneDriveBezig
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.cloud_upload_outlined),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0x26FFFFFF),
          padding: const EdgeInsets.symmetric(horizontal: 13),
        ),
        onPressed: _opslaanNaarOneDriveBezig ? null : _opslaanNaarOneDrive,
        icon: _opslaanNaarOneDriveBezig
            ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.cloud_upload_outlined, size: 19),
        label: const Text(
          'Opslaan naar OneDrive klanten',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Future<Uint8List> _bouwPdf() async {
    final datum = DateTime.now();
    final titelhoofd = widget.titelhoofd;
    final posities = List<OpmetingOverzichtRaamItem>.unmodifiable(
      widget.posities,
    );
    final pvcRaamTekeningen =
        await OffertePvcRaamTekeningService.maakTekeningen(posities);

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
      pvcRaamTekeningen: pvcRaamTekeningen,
    );

    return OffertePdfService.bouwOpmetingPdf(data);
  }

  @override
  Widget build(BuildContext context) {
    final bestandsnaam = _maakBestandsnaam();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: _groen,
        foregroundColor: Colors.white,
        title: const Text(
          'Opmetingvoorbeeld',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: <Widget>[
          _bouwOneDriveActie(context),
          const SizedBox(width: 6),
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
            pdfFileName: bestandsnaam,
            build: (_) => _pdfFuture,
            loadingWidget: const Center(
              child: CircularProgressIndicator(color: _groen),
            ),
            onError: (context, fout) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'De opmeting kon niet worden opgebouwd.\n\n$fout',
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

  static String _veiligBestandsdeel(String waarde) {
    return waarde
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  static String _datumVoorBestandsnaam(DateTime datum) {
    String twee(int waarde) => waarde.toString().padLeft(2, '0');

    return '${datum.year}-${twee(datum.month)}-${twee(datum.day)}';
  }
}
