// THIMACO-CONTROLE: OFFERTE-GOEDKEURING-IPAD-PAPIER-MAIL-20260801
// THIMACO-CONTROLE: OFFERTE-PDF-ONEDRIVE-MAPPEN-EN-BESTANDSNAAM-20260731
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../opmeting/project/opmeting_project_titelhoofd_model.dart';
import '../sync/onedrive_klantdocument_service.dart';
import '../sync/onedrive_map_kiezer_dialog.dart';
import 'offerte_goedkeuring_model.dart';
import 'offerte_handtekening_dialog.dart';
import 'offerte_mail_template_service.dart';
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
  static const Color _oranje = Color(0xFFF15A24);
  static const Color _groen = Color(0xFF0B7A3B);

  final OneDriveKlantdocumentService _oneDriveService =
      OneDriveKlantdocumentService();

  late Future<Uint8List> _pdfFuture;
  DateTime _offerteDatum = DateTime.now();
  OfferteDocumentData? _laatsteDocumentData;
  OfferteGoedkeuring? _goedkeuring;
  int _pdfVersie = 0;
  bool _opslaanNaarOneDriveBezig = false;
  bool _ondertekenenBezig = false;

  bool get _isOndertekend => _goedkeuring?.isOndertekend ?? false;

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
      _goedkeuring = null;
      _offerteDatum = DateTime.now();
      _maakNieuwePdfFuture();
    }
  }

  /// Tijdens hot reload blijft de State van deze pagina bestaan.
  /// Zonder deze heropbouw blijft PdfPreview de eerder gemaakte PDF tonen.
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
    final offerteNummer = widget.titelhoofd.samengesteldOffertenummer;
    final veiligeNaam = widget.titelhoofd.klantNaam.trim().replaceAll(
      RegExp(r'[^a-zA-Z0-9_-]+'),
      '_',
    );
    final nummerVoorBestandsnaam = offerteNummer.trim().isEmpty
        ? 'zonder_nummer'
        : offerteNummer.trim();
    final goedgekeurdDeel = _isOndertekend ? '_Goedgekeurd' : '';

    return veiligeNaam.isEmpty
        ? 'Thimaco_offerte_${nummerVoorBestandsnaam}$goedgekeurdDeel.pdf'
        : 'Thimaco_offerte_${nummerVoorBestandsnaam}_${veiligeNaam}'
              '$goedgekeurdDeel.pdf';
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
        documentType: _isOndertekend ? 'Goedgekeurde offerte' : 'Offerte',
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

  Future<void> _laatOndertekenen() async {
    if (_ondertekenenBezig) return;

    setState(() {
      _ondertekenenBezig = true;
    });

    try {
      await _pdfFuture;
      final data = _laatsteDocumentData;
      if (data == null || !mounted) return;

      final resultaat = await OfferteHandtekeningDialog.toon(
        context: context,
        klantNaam: _goedkeuring?.naam.trim().isNotEmpty == true
            ? _goedkeuring!.naam.trim()
            : widget.titelhoofd.klantNaam.trim(),
        offerteNummer: data.offerteNummer,
        totaalTekst: _formatteerEuro(data.totaalInclusiefBtw),
      );

      if (resultaat == null || !mounted) return;

      setState(() {
        _goedkeuring = resultaat;
        _maakNieuwePdfFuture();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'De ondertekende offerte is aangemaakt. '
            'Sla ze afzonderlijk op als Goedgekeurd.',
          ),
          backgroundColor: _groen,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _ondertekenenBezig = false;
        });
      }
    }
  }

  Future<void> _toonOndertekeningOpties() async {
    if (!_isOndertekend) {
      await _laatOndertekenen();
      return;
    }

    final keuze = await showModalBottomSheet<_OndertekeningKeuze>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Ondertekende offerte',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  'Ondertekend door ${_goedkeuring!.naam} op '
                  '${_formatteerDatumTijd(_goedkeuring!.getekendOp)}.',
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: const Icon(Icons.draw_outlined, color: _groen),
                  title: const Text('Opnieuw laten ondertekenen'),
                  onTap: () =>
                      Navigator.pop(context, _OndertekeningKeuze.opnieuw),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.restore_page_outlined,
                    color: Color(0xFFB91C1C),
                  ),
                  title: const Text('Terug naar originele offerte'),
                  subtitle: const Text(
                    'De handtekening verdwijnt uit de preview.',
                  ),
                  onTap: () =>
                      Navigator.pop(context, _OndertekeningKeuze.verwijderen),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    if (keuze == _OndertekeningKeuze.opnieuw) {
      await _laatOndertekenen();
    } else if (keuze == _OndertekeningKeuze.verwijderen) {
      setState(() {
        _goedkeuring = null;
        _maakNieuwePdfFuture();
      });
    }
  }

  Future<void> _toonMailtekst(_MailKeuze keuze) async {
    await _pdfFuture;
    final data = _laatsteDocumentData;
    if (data == null || !mounted) return;

    final mail = switch (keuze) {
      _MailKeuze.versturen => OfferteMailTemplateService.voorVersturen(data),
      _MailKeuze.bevestiging => OfferteMailTemplateService.naGoedkeuring(
        data,
        _goedkeuring,
      ),
    };

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            keuze == _MailKeuze.versturen
                ? 'Mail bij versturen offerte'
                : 'Bevestigingsmail na goedkeuring',
          ),
          content: SizedBox(
            width: 620,
            child: SingleChildScrollView(child: SelectableText(mail.volledig)),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Sluiten'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _groen,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: mail.volledig));
                if (!mounted) return;
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Onderwerp en mailtekst zijn gekopieerd.'),
                    backgroundColor: _groen,
                  ),
                );
              },
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Kopiëren'),
            ),
          ],
        );
      },
    );
  }

  Widget _bouwOndertekenActie(BuildContext context) {
    final toonTekst = MediaQuery.sizeOf(context).width >= 920;
    final icoon = _isOndertekend ? Icons.verified_rounded : Icons.draw_outlined;
    final tooltip = _isOndertekend
        ? 'Ondertekende offerte beheren'
        : 'Offerte laten ondertekenen';

    if (!toonTekst) {
      return IconButton(
        tooltip: tooltip,
        onPressed: _ondertekenenBezig ? null : _toonOndertekeningOpties,
        icon: _ondertekenenBezig
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Icon(icoon),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: _isOndertekend
              ? const Color(0x550B7A3B)
              : const Color(0x26FFFFFF),
          padding: const EdgeInsets.symmetric(horizontal: 13),
        ),
        onPressed: _ondertekenenBezig ? null : _toonOndertekeningOpties,
        icon: _ondertekenenBezig
            ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icoon, size: 19),
        label: Text(
          _isOndertekend ? 'Ondertekend' : 'Laten ondertekenen',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _bouwMailActie() {
    return PopupMenuButton<_MailKeuze>(
      tooltip: 'Mailtekst',
      icon: const Icon(Icons.email_outlined),
      onSelected: _toonMailtekst,
      itemBuilder: (context) => const <PopupMenuEntry<_MailKeuze>>[
        PopupMenuItem<_MailKeuze>(
          value: _MailKeuze.versturen,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.outgoing_mail),
            title: Text('Mail bij versturen'),
          ),
        ),
        PopupMenuItem<_MailKeuze>(
          value: _MailKeuze.bevestiging,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.mark_email_read_outlined),
            title: Text('Bevestiging na ondertekening'),
          ),
        ),
      ],
    );
  }

  Widget _bouwOneDriveActie(BuildContext context) {
    final toonTekst = MediaQuery.sizeOf(context).width >= 1120;

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
    final datum = _offerteDatum;
    final titelhoofd = widget.titelhoofd;
    final posities = List<OpmetingOverzichtRaamItem>.unmodifiable(
      widget.posities,
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

    _laatsteDocumentData = data;
    return OffertePdfService.bouwPdf(data, goedkeuring: _goedkeuring);
  }

  @override
  Widget build(BuildContext context) {
    final bestandsnaam = _maakBestandsnaam();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: _oranje,
        foregroundColor: Colors.white,
        title: Text(
          _isOndertekend
              ? 'Offertevoorbeeld · Ondertekend'
              : 'Offertevoorbeeld',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: <Widget>[
          _bouwOndertekenActie(context),
          _bouwMailActie(),
          _bouwOneDriveActie(context),
          const SizedBox(width: 4),
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

  static String _formatteerEuro(double waarde) {
    final veilig = waarde.isFinite ? waarde : 0.0;
    final delen = veilig.toStringAsFixed(2).split('.');
    final geheel = delen.first;
    final decimalen = delen.length > 1 ? delen[1] : '00';
    final buffer = StringBuffer();

    for (var index = 0; index < geheel.length; index++) {
      if (index > 0 && (geheel.length - index) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(geheel[index]);
    }

    return '€ ${buffer.toString()},$decimalen';
  }

  static String _formatteerDatumTijd(DateTime datum) {
    String twee(int waarde) => waarde.toString().padLeft(2, '0');
    return '${twee(datum.day)}/${twee(datum.month)}/${datum.year} '
        '${twee(datum.hour)}:${twee(datum.minute)}';
  }
}

enum _MailKeuze { versturen, bevestiging }

enum _OndertekeningKeuze { opnieuw, verwijderen }
