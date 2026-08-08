// THIMACO-CONTROLE: BIBLIOTHEEK-FOLDER-AFDRUKKEN-MAIL-BLAUWE-AGENDA-20260808
// THIMACO-CONTROLE: BIBLIOTHEEK-FOLDER-OPMEETFICHE-KOPPELINGEN-20260802
// THIMACO-CONTROLE: BIBLIOTHEEK-FOLDER-GROENE-MENUS-20260802

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../helpers/app_storage.dart';
import '../helpers/bibliotheek/bibliotheek_model.dart';
import '../helpers/bibliotheek/bibliotheek_onedrive_service.dart';
import '../helpers/bibliotheek/bibliotheek_pdf_kiezer_dialog.dart';
import '../helpers/klanten/fiche/klantenfiche_model.dart';
import '../helpers/offerte/artikelen/offerte_artikel_register.dart';
import '../helpers/offerte/mail/offerte_mail_verzend_service.dart';
import '../helpers/opmeting/project/opmeting_project_titelhoofd_model.dart';
import 'klanten_fiche_pagina.dart';

const Color _bibliotheekGroen = Color(0xFF0B7A3B);
const Color _bibliotheekRand = Color(0xFFE5E7EB);

ThemeData _bouwBibliotheekGroenThema(BuildContext context) {
  final basis = Theme.of(context);
  final kleurenschema = basis.colorScheme.copyWith(
    primary: _bibliotheekGroen,
    secondary: _bibliotheekGroen,
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
  );

  return basis.copyWith(
    colorScheme: kleurenschema,
    primaryColor: _bibliotheekGroen,
    focusColor: _bibliotheekGroen.withValues(alpha: 0.12),
    hoverColor: _bibliotheekGroen.withValues(alpha: 0.07),
    splashColor: _bibliotheekGroen.withValues(alpha: 0.10),
    highlightColor: _bibliotheekGroen.withValues(alpha: 0.06),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: _bibliotheekGroen,
      selectionColor: Color(0x5534A764),
      selectionHandleColor: _bibliotheekGroen,
    ),
    inputDecorationTheme: InputDecorationTheme(
      floatingLabelStyle: const TextStyle(color: _bibliotheekGroen),
      prefixIconColor: _bibliotheekGroen,
      suffixIconColor: _bibliotheekGroen,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _bibliotheekGroen, width: 1.6),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _bibliotheekGroen),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _bibliotheekGroen,
        foregroundColor: Colors.white,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _bibliotheekGroen,
        side: const BorderSide(color: _bibliotheekGroen),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      iconColor: _bibliotheekGroen,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: _bibliotheekRand),
      ),
    ),
    chipTheme: basis.chipTheme.copyWith(
      selectedColor: const Color(0xFFE7F6EC),
      checkmarkColor: _bibliotheekGroen,
      deleteIconColor: _bibliotheekGroen,
      side: const BorderSide(color: Color(0xFFB9E0C7)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _bibliotheekGroen,
    ),
  );
}

class BibliotheekFolderPagina extends StatefulWidget {
  const BibliotheekFolderPagina({
    super.key,
    required this.folder,
    required this.leverancierNaam,
    required this.schapNaam,
  });

  final BibliotheekFolder folder;
  final String leverancierNaam;
  final String schapNaam;

  @override
  State<BibliotheekFolderPagina> createState() {
    return _BibliotheekFolderPaginaState();
  }
}

class _BibliotheekFolderPaginaState extends State<BibliotheekFolderPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  final BibliotheekOneDriveService _oneDriveService =
      BibliotheekOneDriveService();

  late BibliotheekFolder _folder;
  Future<Uint8List>? _pdfFuture;
  bool _sluitenBezig = false;
  bool _afdrukkenBezig = false;
  bool _mailenBezig = false;

  @override
  void initState() {
    super.initState();
    _folder = widget.folder;
    _herlaadPdf();
  }

  void _herlaadPdf() {
    _pdfFuture = _folder.heeftPdf
        ? _oneDriveService.downloadPdf(_folder.onedriveItemId)
        : null;
  }

  Future<void> _sluitMetResultaat() async {
    if (_sluitenBezig || !mounted) return;
    _sluitenBezig = true;
    Navigator.of(context).pop(_folder);
  }

  Future<void> _kiesPdf() async {
    final gekozen = await BibliotheekPdfKiezerDialog.toon(
      context: context,
      service: _oneDriveService,
    );

    if (!mounted || gekozen == null) return;

    setState(() {
      _folder = _folder.metNieuweWijzigingsDatum(
        onedriveItemId: gekozen.id,
        bestandsnaam: gekozen.naam,
        webUrl: gekozen.webUrl,
      );
      _herlaadPdf();
    });
  }

  Future<Uint8List?> _laadPdfVoorActie() async {
    if (!_folder.heeftPdf) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kies eerst een PDF voor deze fiche.'),
            backgroundColor: _groen,
          ),
        );
      }
      return null;
    }

    try {
      final future =
          _pdfFuture ?? _oneDriveService.downloadPdf(_folder.onedriveItemId);
      _pdfFuture = future;
      final bytes = await future;
      if (bytes.isEmpty) {
        throw StateError('De PDF is leeg.');
      }
      return bytes;
    } catch (fout) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('De PDF kon niet worden geladen: $fout'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
      return null;
    }
  }

  String get _pdfBestandsnaam {
    final bestaand = _folder.bestandsnaam.trim();
    if (bestaand.isNotEmpty) {
      return bestaand.toLowerCase().endsWith('.pdf')
          ? bestaand
          : '$bestaand.pdf';
    }

    final naam = _folder.naam.trim().isEmpty ? 'document' : _folder.naam.trim();
    return '$naam.pdf';
  }

  Future<void> _drukPdfAf() async {
    if (_afdrukkenBezig) return;

    setState(() => _afdrukkenBezig = true);
    try {
      final bytes = await _laadPdfVoorActie();
      if (bytes == null || !mounted) return;

      await Printing.layoutPdf(
        name: _pdfBestandsnaam,
        onLayout: (_) async => bytes,
      );
    } catch (fout) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Afdrukken kon niet worden gestart: $fout'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _afdrukkenBezig = false);
      }
    }
  }

  Future<void> _mailPdf() async {
    if (_mailenBezig) return;

    setState(() => _mailenBezig = true);
    try {
      final klanten = await AppStorage.laadAgendaKlantenVoorOpmeting();
      if (!mounted) return;

      final ontvanger = await showDialog<_BibliotheekMailOntvanger>(
        context: context,
        builder: (dialogContext) => Theme(
          data: _bouwBibliotheekGroenThema(dialogContext),
          child: _BibliotheekMailKlantKeuzeDialog(klanten: klanten),
        ),
      );

      if (!mounted || ontvanger == null) return;

      final email = ontvanger.email.trim();
      if (email.isEmpty) return;

      final bytes = await _laadPdfVoorActie();
      if (bytes == null || !mounted) return;

      final klantNaam = ontvanger.klantNaam.trim();
      final ficheNaam = _folder.naam.trim().isEmpty
          ? 'documentatie'
          : _folder.naam.trim();

      await OfferteMailVerzendService().verstuur(
        ontvanger: email,
        onderwerp: 'Thimaco · $ficheNaam',
        bericht: <String>[
          klantNaam.isEmpty ? 'Beste,' : 'Beste $klantNaam,',
          '',
          'In bijlage vindt u de gevraagde informatie over $ficheNaam.',
          '',
          'Met vriendelijke groeten',
          'Thimaco',
          'Ramen · deuren · zonwering',
        ].join('\n'),
        bijlagen: <OfferteMailBijlage>[
          OfferteMailBijlage(bestandsnaam: _pdfBestandsnaam, bytes: bytes),
        ],
      );
    } on OfferteMailGeannuleerdException catch (fout) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(fout.bericht), backgroundColor: _groen),
        );
      }
    } on OfferteMailVerzendException catch (fout) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(fout.bericht),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    } catch (fout) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('De e-mail kon niet worden geopend: $fout'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _mailenBezig = false);
      }
    }
  }

  Future<void> _wijzigFoldergegevens() async {
    final resultaat = await showDialog<_FolderTeksten>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Theme(
          data: _bouwBibliotheekGroenThema(dialogContext),
          child: _FolderTekstenDialog(
            beginNaam: _folder.naam,
            beginOmschrijving: _folder.omschrijving,
          ),
        );
      },
    );

    if (!mounted || resultaat == null) return;

    setState(() {
      _folder = _folder.metNieuweWijzigingsDatum(
        naam: resultaat.naam,
        omschrijving: resultaat.omschrijving,
      );
    });
  }

  Future<void> _koppelOpmeetfiches() async {
    final beginSelectie = _folder.formulierKoppelingen
        .map((koppeling) => _normaliseerFormulierType(koppeling.formulierType))
        .where((type) => type.isNotEmpty)
        .toSet();

    final gekozen = await showDialog<Set<String>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Theme(
          data: _bouwBibliotheekGroenThema(dialogContext),
          child: _OpmeetficheKiezerDialog(beginSelectie: beginSelectie),
        );
      },
    );

    if (!mounted || gekozen == null) return;

    final koppelingen = OfferteArtikelRegister.registraties
        .where(
          (registratie) => gekozen.contains(
            _normaliseerFormulierType(registratie.formulierType),
          ),
        )
        .map(
          (registratie) => BibliotheekFormulierKoppeling(
            formulierType: registratie.formulierType,
            formulierNaam: registratie.formulierNaam,
          ),
        )
        .toList(growable: false);

    setState(() {
      _folder = _folder.metNieuweWijzigingsDatum(
        formulierKoppelingen: koppelingen,
      );
    });
  }

  void _verwijderOpmeetfiche(BibliotheekFormulierKoppeling koppeling) {
    final sleutel = _normaliseerFormulierType(koppeling.formulierType);
    setState(() {
      _folder = _folder.metNieuweWijzigingsDatum(
        formulierKoppelingen: _folder.formulierKoppelingen
            .where(
              (item) =>
                  _normaliseerFormulierType(item.formulierType) != sleutel,
            )
            .toList(growable: false),
      );
    });
  }

  static String _normaliseerFormulierType(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  Future<void> _koppelKlantenfiche() async {
    final ruweFiches = await AppStorage.laadKlantenFiches();
    if (!mounted) return;

    final gekoppeldeIds = _folder.klanten.map((klant) => klant.id).toSet();
    final fiches =
        ruweFiches
            .where((fiche) {
              final id = fiche['id']?.toString().trim() ?? '';
              return id.isNotEmpty && !gekoppeldeIds.contains(id);
            })
            .toList(growable: false)
          ..sort((links, rechts) {
            final linksNaam = links['naam']?.toString().toLowerCase() ?? '';
            final rechtsNaam = rechts['naam']?.toString().toLowerCase() ?? '';
            return linksNaam.compareTo(rechtsNaam);
          });

    if (fiches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alle beschikbare klantenfiches zijn al gekoppeld.'),
          backgroundColor: _groen,
        ),
      );
      return;
    }

    final gekozen = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => Theme(
        data: _bouwBibliotheekGroenThema(dialogContext),
        child: _KlantenficheKiezerDialog(fiches: fiches),
      ),
    );

    if (!mounted || gekozen == null) return;

    final koppeling = BibliotheekKlantKoppeling(
      id: gekozen['id']?.toString().trim() ?? '',
      naam: gekozen['naam']?.toString().trim() ?? '',
      klantNr: gekozen['klantNr']?.toString().trim() ?? '',
    );

    if (koppeling.id.isEmpty) return;

    setState(() {
      _folder = _folder.metNieuweWijzigingsDatum(
        klanten: <BibliotheekKlantKoppeling>[..._folder.klanten, koppeling],
      );
    });
  }

  Future<void> _openKlantenfiche(BibliotheekKlantKoppeling koppeling) async {
    final fiches = await AppStorage.laadKlantenFiches();
    if (!mounted) return;

    Map<String, dynamic>? gevonden;
    for (final fiche in fiches) {
      if (fiche['id']?.toString().trim() == koppeling.id) {
        gevonden = fiche;
        break;
      }
    }

    final ficheJson = gevonden;
    if (ficheJson == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deze klantenfiche bestaat niet meer.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => KlantenFichePagina(
          bestaandeFiche: KlantenficheModel.fromJson(ficheJson),
        ),
      ),
    );
  }

  void _verwijderKlant(BibliotheekKlantKoppeling koppeling) {
    setState(() {
      _folder = _folder.metNieuweWijzigingsDatum(
        klanten: _folder.klanten
            .where((klant) => klant.id != koppeling.id)
            .toList(growable: false),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _bouwBibliotheekGroenThema(context),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) await _sluitMetResultaat();
        },
        child: Scaffold(
          backgroundColor: _achtergrond,
          appBar: AppBar(
            backgroundColor: _groen,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              tooltip: 'Terug',
              onPressed: _sluitMetResultaat,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            ),
            title: Text(
              _folder.naam,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            actions: <Widget>[
              IconButton(
                tooltip: 'Foldergegevens wijzigen',
                onPressed: _wijzigFoldergegevens,
                icon: const Icon(Icons.edit_outlined),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _groen,
                  ),
                  onPressed: _kiesPdf,
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                  label: Text(
                    _folder.heeftPdf ? 'PDF vervangen' : 'PDF kiezen',
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: <Widget>[
              _bouwFolderKop(),
              Expanded(child: _bouwPdfGedeelte()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bouwFolderKop() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              _InfoChip(
                icoon: Icons.business_outlined,
                tekst: widget.leverancierNaam,
              ),
              _InfoChip(
                icoon: Icons.view_stream_outlined,
                tekst: widget.schapNaam,
              ),
              if (_folder.bestandsnaam.trim().isNotEmpty)
                _InfoChip(
                  icoon: Icons.picture_as_pdf_outlined,
                  tekst: _folder.bestandsnaam,
                ),
            ],
          ),
          if (_folder.omschrijving.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              _folder.omschrijving,
              style: const TextStyle(color: _tekstGrijs, height: 1.35),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: _folder.heeftPdf && !_afdrukkenBezig
                    ? _drukPdfAf
                    : null,
                icon: _afdrukkenBezig
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.print_outlined, size: 18),
                label: const Text('Afdrukken'),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: _groen),
                onPressed: _folder.heeftPdf && !_mailenBezig ? _mailPdf : null,
                icon: _mailenBezig
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.mail_outline_rounded, size: 18),
                label: const Text('Mailen'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Gekoppelde opmeetfiches',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: _groen),
                onPressed: _koppelOpmeetfiches,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Opmeetfiche koppelen'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_folder.formulierKoppelingen.isEmpty)
            const Text(
              'Nog geen opmeetfiche gekoppeld. Deze folder wordt dan niet '
              'automatisch voorgesteld bij een offerte.',
              style: TextStyle(color: _tekstGrijs),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _folder.formulierKoppelingen
                  .map((koppeling) {
                    return InputChip(
                      avatar: const Icon(Icons.description_outlined, size: 18),
                      label: Text(koppeling.label),
                      onPressed: _koppelOpmeetfiches,
                      onDeleted: () => _verwijderOpmeetfiche(koppeling),
                      deleteIcon: const Icon(Icons.close_rounded, size: 18),
                      backgroundColor: const Color(0xFFE7F6EC),
                      side: const BorderSide(color: Color(0xFFB9E0C7)),
                    );
                  })
                  .toList(growable: false),
            ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: _rand),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Gekoppelde klantenfiches',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: _groen),
                onPressed: _koppelKlantenfiche,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Klantenfiche koppelen'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_folder.klanten.isEmpty)
            const Text(
              'Nog geen klantenfiche gekoppeld.',
              style: TextStyle(color: _tekstGrijs),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _folder.klanten
                  .map((koppeling) {
                    return InputChip(
                      avatar: const Icon(
                        Icons.person_outline_rounded,
                        size: 18,
                      ),
                      label: Text(koppeling.label),
                      onPressed: () => _openKlantenfiche(koppeling),
                      onDeleted: () => _verwijderKlant(koppeling),
                      deleteIcon: const Icon(Icons.close_rounded, size: 18),
                      backgroundColor: const Color(0xFFE7F6EC),
                      side: const BorderSide(color: Color(0xFFB9E0C7)),
                    );
                  })
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }

  Widget _bouwPdfGedeelte() {
    final pdfFuture = _pdfFuture;

    if (!_folder.heeftPdf || pdfFuture == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 540),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _rand),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.folder_open_outlined, size: 48, color: _groen),
                const SizedBox(height: 14),
                const Text(
                  'Deze folder heeft nog geen PDF',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Kies een leveranciersfolder uit OneDrive. Daarna wordt het document hier op volledig scherm getoond.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _tekstGrijs, height: 1.35),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: _groen),
                  onPressed: _kiesPdf,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('PDF uit OneDrive kiezen'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return FutureBuilder<Uint8List>(
      key: ValueKey<String>(_folder.onedriveItemId),
      future: pdfFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator(color: _groen));
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 42,
                    color: Color(0xFFDC2626),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    snapshot.error?.toString() ??
                        'De PDF kon niet worden geopend.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    children: <Widget>[
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _groen,
                          side: const BorderSide(color: _groen),
                        ),
                        onPressed: () {
                          setState(_herlaadPdf);
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Opnieuw proberen'),
                      ),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(backgroundColor: _groen),
                        onPressed: _kiesPdf,
                        icon: const Icon(Icons.swap_horiz_rounded),
                        label: const Text('Andere PDF kiezen'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        final bytes = snapshot.data!;

        return PdfPreview(
          key: ValueKey<String>('pdf-${_folder.onedriveItemId}'),
          build: (_) async => bytes,
          initialPageFormat: PdfPageFormat.a4,
          allowPrinting: false,
          allowSharing: false,
          canChangeOrientation: false,
          canChangePageFormat: false,
          canDebug: false,
          pdfFileName: _folder.bestandsnaam.trim().isEmpty
              ? '${_folder.naam}.pdf'
              : _folder.bestandsnaam,
          loadingWidget: const Center(
            child: CircularProgressIndicator(color: _groen),
          ),
          onError: (context, error) {
            return Center(child: Text(error.toString()));
          },
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icoon, required this.tekst});

  final IconData icoon;
  final String tekst;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icoon, size: 16, color: const Color(0xFF0B7A3B)),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Text(
              tekst,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _FolderTekstenDialog extends StatefulWidget {
  const _FolderTekstenDialog({
    required this.beginNaam,
    required this.beginOmschrijving,
  });

  final String beginNaam;
  final String beginOmschrijving;

  @override
  State<_FolderTekstenDialog> createState() {
    return _FolderTekstenDialogState();
  }
}

class _FolderTekstenDialogState extends State<_FolderTekstenDialog> {
  static const Color _groen = Color(0xFF0B7A3B);

  late final TextEditingController _naamController;
  late final TextEditingController _omschrijvingController;
  String _fout = '';

  @override
  void initState() {
    super.initState();
    _naamController = TextEditingController(text: widget.beginNaam);
    _omschrijvingController = TextEditingController(
      text: widget.beginOmschrijving,
    );
  }

  @override
  void dispose() {
    _naamController.dispose();
    _omschrijvingController.dispose();
    super.dispose();
  }

  void _bewaar() {
    final naam = _naamController.text.trim();
    if (naam.isEmpty) {
      setState(() => _fout = 'Geef een naam in.');
      return;
    }

    Navigator.of(context).pop(
      _FolderTeksten(
        naam: naam,
        omschrijving: _omschrijvingController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        'Folder wijzigen',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _naamController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Naam folder',
                errorText: _fout.isEmpty ? null : _fout,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_fout.isNotEmpty) setState(() => _fout = '');
              },
              onSubmitted: (_) => _bewaar(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _omschrijvingController,
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Omschrijving',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(foregroundColor: _groen),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuleren'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _groen),
          onPressed: _bewaar,
          child: const Text('Bewaren'),
        ),
      ],
    );
  }
}

class _OpmeetficheKiezerDialog extends StatefulWidget {
  const _OpmeetficheKiezerDialog({required this.beginSelectie});

  final Set<String> beginSelectie;

  @override
  State<_OpmeetficheKiezerDialog> createState() {
    return _OpmeetficheKiezerDialogState();
  }
}

class _OpmeetficheKiezerDialogState extends State<_OpmeetficheKiezerDialog> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  late final Set<String> _selectie;

  @override
  void initState() {
    super.initState();
    _selectie = Set<String>.from(widget.beginSelectie);
  }

  static String _normaliseer(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  @override
  Widget build(BuildContext context) {
    final registraties = OfferteArtikelRegister.registraties;

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 760),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 10, 12),
              child: Row(
                children: <Widget>[
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Opmeetfiches koppelen',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'U kunt één folder aan meerdere soorten opmeetfiches '
                          'koppelen.',
                          style: TextStyle(color: _tekstGrijs),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _rand),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(14),
                itemCount: registraties.length,
                separatorBuilder: (_, __) => const SizedBox(height: 7),
                itemBuilder: (context, index) {
                  final registratie = registraties[index];
                  final sleutel = _normaliseer(registratie.formulierType);
                  final geselecteerd = _selectie.contains(sleutel);

                  return CheckboxListTile(
                    value: geselecteerd,
                    activeColor: _groen,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 3,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    secondary: Icon(registratie.icoon, color: _groen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: geselecteerd ? const Color(0xFF7FC89A) : _rand,
                      ),
                    ),
                    tileColor: geselecteerd
                        ? const Color(0xFFE7F6EC)
                        : Colors.white,
                    title: Text(
                      registratie.formulierNaam,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(registratie.categorie.label),
                    onChanged: (waarde) {
                      setState(() {
                        if (waarde == true) {
                          _selectie.add(sleutel);
                        } else {
                          _selectie.remove(sleutel);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1, color: _rand),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '${_selectie.length} opmeetfiche(s) geselecteerd',
                      style: const TextStyle(
                        color: _tekstGrijs,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuleren'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: _groen),
                    onPressed: () => Navigator.pop(
                      context,
                      Set<String>.unmodifiable(_selectie),
                    ),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Koppelingen bewaren'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KlantenficheKiezerDialog extends StatefulWidget {
  const _KlantenficheKiezerDialog({required this.fiches});

  final List<Map<String, dynamic>> fiches;

  @override
  State<_KlantenficheKiezerDialog> createState() {
    return _KlantenficheKiezerDialogState();
  }
}

class _KlantenficheKiezerDialogState extends State<_KlantenficheKiezerDialog> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _rand = Color(0xFFE5E7EB);

  final TextEditingController _zoekController = TextEditingController();
  String _zoekterm = '';

  @override
  void dispose() {
    _zoekController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _zichtbareFiches {
    if (_zoekterm.isEmpty) return widget.fiches;

    return widget.fiches
        .where((fiche) {
          final naam = fiche['naam']?.toString().toLowerCase() ?? '';
          final nummer = fiche['klantNr']?.toString().toLowerCase() ?? '';
          final gemeente = fiche['gemeente']?.toString().toLowerCase() ?? '';
          return naam.contains(_zoekterm) ||
              nummer.contains(_zoekterm) ||
              gemeente.contains(_zoekterm);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final zichtbaar = _zichtbareFiches;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 680),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 10, 12),
              child: Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'Klantenfiche koppelen',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: TextField(
                controller: _zoekController,
                onChanged: (waarde) {
                  setState(() {
                    _zoekterm = waarde.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Zoek op naam, klantnummer of gemeente',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: _achtergrond,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _rand),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _rand),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _groen, width: 1.6),
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: _rand),
            Expanded(
              child: zichtbaar.isEmpty
                  ? const Center(child: Text('Geen klantenfiche gevonden.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(14),
                      itemCount: zichtbaar.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 7),
                      itemBuilder: (context, index) {
                        final fiche = zichtbaar[index];
                        final naam = fiche['naam']?.toString().trim() ?? '';
                        final nummer =
                            fiche['klantNr']?.toString().trim() ?? '';
                        final gemeente =
                            fiche['gemeente']?.toString().trim() ?? '';

                        return ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: _rand),
                          ),
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE7F6EC),
                            foregroundColor: _groen,
                            child: Icon(Icons.person_outline_rounded),
                          ),
                          title: Text(
                            naam.isEmpty ? 'Naamloos' : naam,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(
                            <String>[
                              nummer,
                              gemeente,
                            ].where((deel) => deel.isNotEmpty).join(' · '),
                          ),
                          trailing: const Icon(
                            Icons.add_circle_outline_rounded,
                            color: _groen,
                          ),
                          onTap: () => Navigator.of(context).pop(fiche),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BibliotheekMailKlantKeuzeDialog extends StatefulWidget {
  const _BibliotheekMailKlantKeuzeDialog({required this.klanten});

  final List<OpmetingAgendaKlantInfo> klanten;

  @override
  State<_BibliotheekMailKlantKeuzeDialog> createState() =>
      _BibliotheekMailKlantKeuzeDialogState();
}

class _BibliotheekMailKlantKeuzeDialogState
    extends State<_BibliotheekMailKlantKeuzeDialog> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _zoekController = TextEditingController();
  String _zoekterm = '';
  String _emailFout = '';

  @override
  void dispose() {
    _emailController.dispose();
    _zoekController.dispose();
    super.dispose();
  }

  List<OpmetingAgendaKlantInfo> get _zichtbareKlanten {
    final zoek = _zoekterm.trim().toLowerCase();
    if (zoek.isEmpty) return widget.klanten;

    return widget.klanten
        .where((klant) {
          final naam = klant.klantNaamMetAanspreking.toLowerCase();
          return naam.contains(zoek);
        })
        .toList(growable: false);
  }

  bool _geldigEmailadres(String email) {
    final waarde = email.trim();
    if (waarde.isEmpty || waarde.contains(' ')) return false;
    final at = waarde.indexOf('@');
    final punt = waarde.lastIndexOf('.');
    return at > 0 && punt > at + 1 && punt < waarde.length - 1;
  }

  void _gebruikHandmatigEmailadres() {
    final email = _emailController.text.trim();
    if (!_geldigEmailadres(email)) {
      setState(() {
        _emailFout = 'Geef een geldig e-mailadres in.';
      });
      return;
    }

    Navigator.of(
      context,
    ).pop(_BibliotheekMailOntvanger(email: email, klantNaam: ''));
  }

  @override
  Widget build(BuildContext context) {
    final klanten = _zichtbareKlanten;

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 660, maxHeight: 760),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 10, 10),
              child: Row(
                children: <Widget>[
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'E-mailadres kiezen',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Kies een klant uit de blauwe agenda of geef zelf een e-mailadres in.',
                          style: TextStyle(color: _tekstGrijs),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F6EC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFB9E0C7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Text(
                      'E-mailadres handmatig ingeven',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      onChanged: (_) {
                        if (_emailFout.isNotEmpty) {
                          setState(() => _emailFout = '');
                        }
                      },
                      onSubmitted: (_) => _gebruikHandmatigEmailadres(),
                      decoration: InputDecoration(
                        hintText: 'naam@voorbeeld.be',
                        prefixIcon: const Icon(Icons.email_outlined),
                        errorText: _emailFout.isEmpty ? null : _emailFout,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: _gebruikHandmatigEmailadres,
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Dit e-mailadres gebruiken'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: <Widget>[
                  Expanded(child: Divider(color: _rand)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'OF KIES EEN KLANT',
                      style: TextStyle(
                        color: _tekstGrijs,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: _rand)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              child: TextField(
                controller: _zoekController,
                onChanged: (waarde) {
                  setState(() => _zoekterm = waarde);
                },
                decoration: InputDecoration(
                  hintText: 'Zoek klant op naam',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _zoekterm.trim().isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Zoekopdracht wissen',
                          onPressed: () {
                            _zoekController.clear();
                            setState(() => _zoekterm = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  filled: true,
                  fillColor: _achtergrond,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _rand),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _rand),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _groen, width: 1.6),
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: _rand),
            Expanded(
              child: widget.klanten.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Geen klanten gevonden in de blauwe agenda. U kunt hierboven wel handmatig een e-mailadres ingeven.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _tekstGrijs),
                        ),
                      ),
                    )
                  : klanten.isEmpty
                  ? const Center(
                      child: Text(
                        'Geen klant gevonden.',
                        style: TextStyle(color: _tekstGrijs),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(14),
                      itemCount: klanten.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 7),
                      itemBuilder: (context, index) {
                        final klant = klanten[index];
                        final email = klant.email.trim();
                        final heeftEmail = email.isNotEmpty;
                        final extra = <String>[
                          if (klant.klantnummer.trim().isNotEmpty)
                            'Klant ${klant.klantnummer.trim()}',
                          if (klant.plaats.trim().isNotEmpty)
                            klant.plaats.trim(),
                        ].join(' · ');

                        return ListTile(
                          enabled: heeftEmail,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: heeftEmail
                                  ? _rand
                                  : const Color(0xFFFECACA),
                            ),
                          ),
                          tileColor: heeftEmail
                              ? Colors.white
                              : const Color(0xFFFFF7F7),
                          leading: CircleAvatar(
                            backgroundColor: heeftEmail
                                ? const Color(0xFFE7F6EC)
                                : const Color(0xFFFEE2E2),
                            foregroundColor: heeftEmail
                                ? _groen
                                : const Color(0xFFDC2626),
                            child: Icon(
                              heeftEmail
                                  ? Icons.mail_outline_rounded
                                  : Icons.error_outline_rounded,
                            ),
                          ),
                          title: Text(
                            klant.klantNaamMetAanspreking,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(height: 2),
                              Text(
                                heeftEmail
                                    ? email
                                    : 'Geen e-mailadres in de blauwe agenda',
                                style: TextStyle(
                                  color: heeftEmail
                                      ? _groen
                                      : const Color(0xFFDC2626),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (extra.isNotEmpty) ...<Widget>[
                                const SizedBox(height: 2),
                                Text(
                                  extra,
                                  style: const TextStyle(color: _tekstGrijs),
                                ),
                              ],
                            ],
                          ),
                          trailing: heeftEmail
                              ? const Icon(
                                  Icons.chevron_right_rounded,
                                  color: _groen,
                                )
                              : null,
                          onTap: heeftEmail
                              ? () => Navigator.of(context).pop(
                                  _BibliotheekMailOntvanger(
                                    email: email,
                                    klantNaam: klant.klantNaamMetAanspreking
                                        .trim(),
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BibliotheekMailOntvanger {
  const _BibliotheekMailOntvanger({
    required this.email,
    required this.klantNaam,
  });

  final String email;
  final String klantNaam;
}

class _FolderTeksten {
  const _FolderTeksten({required this.naam, required this.omschrijving});

  final String naam;
  final String omschrijving;
}
