// THIMACO-CONTROLE: PDF-PREVIEW-RUSTIGE-PROGRAMMASTIJL-FASE19-20260913
// THIMACO-CONTROLE: OFFERTE-PDF-ALLEEN-AFDRUKKEN-EN-ONEDRIVE-20260912
// THIMACO-CONTROLE: OFFERTE-PDF-ZONDER-OUDE-OFFERTEVARIANTEN-20260912
// THIMACO-CONTROLE: ONEDRIVE-BESTANDSNAAM-PROJECTNAAM-VERSIE-20260912
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../ui/thimaco_huisstijl.dart';

import '../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../opmeting/project/opmeting_project_titelhoofd_model.dart';
import '../sync/onedrive_klantdocument_service.dart';
import '../sync/onedrive_map_kiezer_dialog.dart';
import 'offerte_pdf_model.dart';
import 'offerte_pdf_service.dart';
import 'offerte_pvc_raam_tekening_service.dart';

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
  static const Color _oranje = ThimacoKleuren.oranje;
  static const Color _tekstDonker = ThimacoKleuren.antraciet;
  static const Color _rand = ThimacoKleuren.rand;
  static const MethodChannel _nativePrintKanaal = MethodChannel(
    'be.thimaco.app/native_print',
  );

  final OneDriveKlantdocumentService _oneDriveService =
      OneDriveKlantdocumentService();

  late Future<Uint8List> _pdfFuture;
  late final DateTime _offerteDatum;
  int _pdfVersie = 0;
  bool _opslaanNaarOneDriveBezig = false;
  bool _afdrukkenBezig = false;

  @override
  void initState() {
    super.initState();
    _offerteDatum = DateTime.now();
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

  String _maakBestandsnaam() {
    final titel = widget.titelhoofd;
    final projectNaam = titel.bestandsNaam.trim().isNotEmpty
        ? titel.bestandsNaam.trim()
        : titel.klantNaam.trim().isNotEmpty
        ? titel.klantNaam.trim()
        : 'Thimaco_offerte';
    final veiligeProjectNaam = _veiligBestandsdeel(projectNaam);
    final versie = titel.veiligeBestandVersieNummer;

    return '${veiligeProjectNaam.isEmpty ? 'Thimaco_offerte' : veiligeProjectNaam}'
        '_V$versie.pdf';
  }

  Future<void> _drukA4Af() async {
    if (_afdrukkenBezig) return;

    setState(() {
      _afdrukkenBezig = true;
    });

    try {
      final pdfBytes = await _pdfFuture;
      if (!mounted) return;

      if (Theme.of(context).platform == TargetPlatform.iOS) {
        await _nativePrintKanaal.invokeMethod<String>(
          'printPdfA4',
          <String, Object>{
            'bytes': pdfBytes,
            'bestandsnaam': _maakBestandsnaam(),
          },
        );
      } else {
        await Printing.layoutPdf(
          name: _maakBestandsnaam(),
          format: PdfPageFormat.a4,
          dynamicLayout: false,
          onLayout: (_) async => pdfBytes,
        );
      }
    } on PlatformException catch (fout) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            fout.message?.trim().isNotEmpty == true
                ? 'Afdrukken kon niet worden gestart.\n${fout.message}'
                : 'Afdrukken kon niet worden gestart.\n${fout.code}',
          ),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } catch (fout) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Afdrukken kon niet worden gestart.\n$fout'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _afdrukkenBezig = false;
        });
      }
    }
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
        documentType: 'Offerte',
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

  Widget _bouwAfdrukActie(BuildContext context) {
    final toonTekst = MediaQuery.sizeOf(context).width >= 900;

    if (_afdrukkenBezig) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 9),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: _oranje,
          ),
        ),
      );
    }

    if (!toonTekst) {
      return ThimacoIcoonActie(
        icoon: Icons.print_outlined,
        tooltip: 'Afdrukken op A4',
        grootte: 19,
        onPressed: _drukA4Af,
      );
    }

    return ThimacoTekstActie(
      tekst: 'Afdrukken',
      compact: false,
      onPressed: _drukA4Af,
    );
  }

  Widget _bouwOneDriveActie(BuildContext context) {
    final toonTekst = MediaQuery.sizeOf(context).width >= 900;

    if (_opslaanNaarOneDriveBezig) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 9),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: _oranje,
          ),
        ),
      );
    }

    if (!toonTekst) {
      return ThimacoIcoonActie(
        icoon: Icons.cloud_upload_outlined,
        tooltip: 'Opslaan naar OneDrive klanten',
        grootte: 19,
        onPressed: _opslaanNaarOneDrive,
      );
    }

    return ThimacoTekstActie(
      tekst: 'Opslaan naar OneDrive',
      compact: false,
      onPressed: _opslaanNaarOneDrive,
    );
  }

  Future<Uint8List> _bouwPdf() async {
    final titelhoofd = widget.titelhoofd;
    final posities = List<OpmetingOverzichtRaamItem>.unmodifiable(
      widget.posities,
    );
    final pvcRaamTekeningen =
        await OffertePvcRaamTekeningService.maakTekeningen(posities);

    final data = OfferteDocumentData(
      klant: OfferteKlantgegevens.vanTitelhoofd(titelhoofd),
      offerteNummer: titelhoofd.samengesteldOffertenummer,
      offerteOmschrijving: titelhoofd.offerteOmschrijving,
      offerteDatum: _offerteDatum,
      btwTarief: titelhoofd.btwTarief,
      kortingOmschrijving: titelhoofd.kortingOmschrijving,
      projectKleurBinnen: titelhoofd.projectKleurBinnen,
      projectKleurBuiten: titelhoofd.projectKleurBuiten,
      ralKleurToebehoren: titelhoofd.ralKleurToebehoren,
      kleurAfwijking: titelhoofd.kleurAfwijking,
      posities: posities,
      prijsVoorAllePositiesRegels: titelhoofd.prijsVoorAllePositiesRegels,
      pvcRaamTekeningen: pvcRaamTekeningen,
    );

    return OffertePdfService.bouwPdf(data);
  }

  String _appBarTitel() {
    final project = widget.titelhoofd.bestandsNaam.trim();
    if (project.isEmpty) return 'Offertevoorbeeld';

    return 'Offertevoorbeeld · '
        '${widget.titelhoofd.bestandsNaamMetVersie}';
  }

  @override
  Widget build(BuildContext context) {
    final bestandsnaam = _maakBestandsnaam();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _tekstDonker,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _appBarTitel(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _tekstDonker,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              width: 36,
              height: 1.5,
              decoration: BoxDecoration(
                color: _oranje.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          _bouwAfdrukActie(context),
          const SizedBox(width: 4),
          _bouwOneDriveActie(context),
          const SizedBox(width: 10),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: _rand),
        ),
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
            pageFormats: const <String, PdfPageFormat>{
              'A4': PdfPageFormat.a4,
            },
            dynamicLayout: false,
            maxPageWidth: passendePaginaBreedte,
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            allowPrinting: false,
            allowSharing: false,
            pdfFileName: bestandsnaam,
            build: (_) => _pdfFuture,
            loadingWidget: const Center(
              child: CircularProgressIndicator(color: _oranje),
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

  static String _veiligBestandsdeel(String waarde) {
    return waarde
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}
