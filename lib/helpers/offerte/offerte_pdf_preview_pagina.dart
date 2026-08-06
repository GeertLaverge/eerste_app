// THIMACO-CONTROLE: OFFERTE-CONCEPTVERSIES-EN-WERKVERSIES-20260806
// THIMACO-CONTROLE: OFFERTE-ONDERTEKENDE-VERSIES-MENU-20260806
// THIMACO-CONTROLE: OFFERTE-MAIL-VERZENDOVERZICHT-EN-BIBLIOTHEEK-20260802
// THIMACO-CONTROLE: OFFERTE-GOEDKEURING-IPAD-PAPIER-MAIL-20260801
// THIMACO-CONTROLE: OFFERTE-PDF-ONEDRIVE-MAPPEN-EN-BESTANDSNAAM-20260731
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../opmeting/project/opmeting_project_titelhoofd_model.dart';
import '../sync/onedrive_klantdocument_service.dart';
import '../sync/onedrive_map_kiezer_dialog.dart';
import 'offerte_goedkeuring_model.dart';
import 'offerte_handtekening_dialog.dart';
import 'mail/offerte_mail_verzend_dialog.dart';
import 'offerte_pdf_model.dart';
import 'offerte_pdf_service.dart';
import 'offerte_pvc_raam_tekening_service.dart';
import 'prijzen/offerte_project_prijs_service.dart';
import 'versies/offerte_versie_model.dart';
import 'versies/offerte_versie_service.dart';

typedef OfferteVersieAlsWerkversieCallback =
    Future<bool> Function({
      required OpmetingProjectTitelhoofd versieTitelhoofd,
      required List<OpmetingOverzichtRaamItem> versiePosities,
      required String bronVersieId,
      required int bronVersieNummer,
    });

typedef OfferteVersieBewaardCallback =
    Future<void> Function({
      required String versieId,
      required int versieNummer,
    });

class OffertePdfPreviewResultaat {
  const OffertePdfPreviewResultaat({
    this.oneDriveResultaat,
    this.werkversieGeopend = false,
  });

  final OneDriveKlantdocumentResultaat? oneDriveResultaat;
  final bool werkversieGeopend;
}

class OffertePdfPreviewPagina extends StatefulWidget {
  const OffertePdfPreviewPagina({
    super.key,
    required this.titelhoofd,
    required this.posities,
    List<OpmetingOverzichtRaamItem>? werkPosities,
    this.initieleGoedkeuring,
    this.initieleOfferteDatum,
    this.alleenLezen = false,
    this.archiefVersieNummer,
    this.archiefVersieId = '',
    this.archiefIsConcept = false,
    this.archiefVersieNaam = '',
    this.startOndertekenen = false,
    this.onOpenVersieAlsWerkversie,
    this.onVersieBewaard,
  }) : werkPosities = werkPosities ?? posities;

  final OpmetingProjectTitelhoofd titelhoofd;
  final List<OpmetingOverzichtRaamItem> posities;
  final List<OpmetingOverzichtRaamItem> werkPosities;
  final OfferteGoedkeuring? initieleGoedkeuring;
  final DateTime? initieleOfferteDatum;
  final bool alleenLezen;
  final int? archiefVersieNummer;
  final String archiefVersieId;
  final bool archiefIsConcept;
  final String archiefVersieNaam;
  final bool startOndertekenen;
  final OfferteVersieAlsWerkversieCallback? onOpenVersieAlsWerkversie;
  final OfferteVersieBewaardCallback? onVersieBewaard;

  @override
  State<OffertePdfPreviewPagina> createState() {
    return _OffertePdfPreviewPaginaState();
  }
}

class _OffertePdfPreviewPaginaState extends State<OffertePdfPreviewPagina> {
  static const Color _oranje = Color(0xFFF15A24);
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);
  static const Color _rand = Color(0xFFE5E7EB);

  final OneDriveKlantdocumentService _oneDriveService =
      OneDriveKlantdocumentService();
  final OfferteVersieService _versieService = const OfferteVersieService();

  late Future<Uint8List> _pdfFuture;
  late DateTime _offerteDatum;
  late String _huidigeInhoudSignatuur;
  OfferteDocumentData? _laatsteDocumentData;
  OfferteGoedkeuring? _goedkeuring;
  List<OfferteVersieModel> _versies = const <OfferteVersieModel>[];
  int _pdfVersie = 0;
  bool _opslaanNaarOneDriveBezig = false;
  bool _ondertekenenBezig = false;
  bool _versieBewarenBezig = false;
  bool _versiesLaden = true;
  bool _conceptWeergave = false;
  bool _archiefConceptOndertekend = false;

  bool get _isArchief => widget.archiefVersieNummer != null;

  bool get _actiefArchiefIsConcept =>
      widget.archiefIsConcept && !_archiefConceptOndertekend;

  bool get _magOndertekenen => !widget.alleenLezen || _actiefArchiefIsConcept;

  bool get _isOndertekend => _goedkeuring?.isOndertekend ?? false;

  bool get _heeftOndertekendeVersies =>
      _versies.any((versie) => versie.isOndertekend);

  OfferteVersieModel? get _overeenkomendeOndertekendeVersie {
    return _versieService.vindOvereenkomendeVersie(
      versies: _versies,
      inhoudSignatuur: _huidigeInhoudSignatuur,
      status: OfferteVersieStatus.ondertekend,
    );
  }

  OfferteVersieModel? get _overeenkomendeConceptVersie {
    return _versieService.vindOvereenkomendeVersie(
      versies: _versies,
      inhoudSignatuur: _huidigeInhoudSignatuur,
      status: OfferteVersieStatus.concept,
    );
  }

  OfferteVersieModel? get _overeenkomendeVersie =>
      _overeenkomendeOndertekendeVersie ?? _overeenkomendeConceptVersie;

  OfferteVersieModel? get _bronVersie {
    final bronId = widget.titelhoofd.offerteBronVersieId.trim();
    if (bronId.isEmpty) return null;

    for (final versie in _versies) {
      if (versie.id == bronId) return versie;
    }
    return null;
  }

  bool get _isGewijzigdVanWerkBron {
    final bron = _bronVersie;
    return !_isArchief &&
        bron != null &&
        bron.inhoudSignatuur != _huidigeInhoudSignatuur;
  }

  bool get _isGewijzigdNaOndertekening {
    return !_isArchief &&
        _heeftOndertekendeVersies &&
        _overeenkomendeOndertekendeVersie == null;
  }

  @override
  void initState() {
    super.initState();
    _offerteDatum = widget.initieleOfferteDatum ?? DateTime.now();
    _goedkeuring = widget.initieleGoedkeuring;
    _huidigeInhoudSignatuur = _versieService.maakInhoudSignatuur(
      titelhoofd: widget.titelhoofd,
      posities: widget.posities,
    );
    _pdfFuture = _bouwPdf();
    _laadVersies();

    if (widget.startOndertekenen && _magOndertekenen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _laatOndertekenen();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant OffertePdfPreviewPagina oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.titelhoofd != widget.titelhoofd ||
        oldWidget.posities != widget.posities) {
      _conceptWeergave = false;
      _goedkeuring = widget.initieleGoedkeuring;
      _offerteDatum = widget.initieleOfferteDatum ?? DateTime.now();
      _huidigeInhoudSignatuur = _versieService.maakInhoudSignatuur(
        titelhoofd: widget.titelhoofd,
        posities: widget.posities,
      );
      _versiesLaden = true;
      _maakNieuwePdfFuture();
      _laadVersies();
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

  Future<void> _laadVersies() async {
    try {
      final versies = await _versieService.laadVoorProject(widget.titelhoofd);
      if (!mounted) return;

      final overeenkomst = _versieService.vindOvereenkomendeVersie(
        versies: versies,
        inhoudSignatuur: _huidigeInhoudSignatuur,
        status: OfferteVersieStatus.ondertekend,
      );

      setState(() {
        _versies = versies;
        _versiesLaden = false;

        if (!_isArchief && !_conceptWeergave) {
          _goedkeuring = overeenkomst?.goedkeuring;
          if (overeenkomst != null) {
            _offerteDatum = overeenkomst.offerteDatum;
          }
          _maakNieuwePdfFuture();
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _versiesLaden = false;
      });
    }
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

    String versieDeel = '';
    if (_isArchief) {
      final soort = _actiefArchiefIsConcept ? 'Concept' : 'Ondertekend';
      versieDeel = '_${soort}_v${widget.archiefVersieNummer}';
    } else if (_isOndertekend) {
      final nummer = _overeenkomendeOndertekendeVersie?.versieNummer;
      versieDeel = nummer == null ? '_Ondertekend' : '_Ondertekend_v$nummer';
    } else if (_overeenkomendeConceptVersie != null) {
      versieDeel = '_Concept_v${_overeenkomendeConceptVersie!.versieNummer}';
    }

    return veiligeNaam.isEmpty
        ? 'Thimaco_offerte_$nummerVoorBestandsnaam$versieDeel.pdf'
        : 'Thimaco_offerte_${nummerVoorBestandsnaam}_$veiligeNaam'
              '$versieDeel.pdf';
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
      Navigator.of(
        context,
      ).pop(OffertePdfPreviewResultaat(oneDriveResultaat: resultaat));
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
    if (_ondertekenenBezig || !_magOndertekenen) return;

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

      final bestaandeConceptId = _actiefArchiefIsConcept
          ? widget.archiefVersieId
          : _overeenkomendeConceptVersie?.id ?? '';
      final versie = await _versieService.bewaarOndertekendeVersie(
        titelhoofd: widget.titelhoofd,
        posities: widget.posities,
        werkPosities: widget.werkPosities,
        offerteDatum: _offerteDatum,
        totaalInclusiefBtw: data.totaalInclusiefBtw,
        goedkeuring: resultaat,
        bestaandeConceptVersieId: bestaandeConceptId,
      );

      if (!mounted) return;

      setState(() {
        _goedkeuring = resultaat;
        _conceptWeergave = false;
        _archiefConceptOndertekend =
            _archiefConceptOndertekend ||
            (_isArchief && widget.archiefIsConcept);
        _versies =
            <OfferteVersieModel>[
              versie,
              ..._versies.where((bestaand) => bestaand.id != versie.id),
            ]..sort((eerste, tweede) {
              return tweede.versieNummer.compareTo(eerste.versieNummer);
            });
        _maakNieuwePdfFuture();
      });

      if (!_isArchief && widget.onVersieBewaard != null) {
        try {
          await widget.onVersieBewaard!(
            versieId: versie.id,
            versieNummer: versie.versieNummer,
          );
        } catch (_) {
          // De versie zelf is al veilig opgeslagen. Een mislukte markering van
          // de werkbron mag de ondertekening niet terugdraaien.
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            bestaandeConceptId.trim().isNotEmpty
                ? 'Conceptversie ${versie.versieNummer} is ondertekend en '
                      'blijft als dezelfde historische versie bewaard.'
                : 'Ondertekende offerteversie ${versie.versieNummer} is '
                      'bewaard. Latere wijzigingen overschrijven deze versie '
                      'niet.',
          ),
          backgroundColor: _groen,
        ),
      );
    } catch (fout) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'De ondertekende offerte kon niet blijvend worden bewaard.\n$fout',
          ),
          backgroundColor: const Color(0xFFDC2626),
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
    if (_isArchief) {
      if (_magOndertekenen && !_isOndertekend) {
        await _laatOndertekenen();
      }
      return;
    }

    if (!_isOndertekend) {
      await _laatOndertekenen();
      return;
    }

    final keuze = await showModalBottomSheet<_OndertekeningKeuze>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final versieNummer = _overeenkomendeOndertekendeVersie?.versieNummer;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  versieNummer == null
                      ? 'Ondertekende offerte'
                      : 'Ondertekende offerte · Versie $versieNummer',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Ondertekend door ${_goedkeuring!.naam} op '
                  '${_formatteerDatumTijd(_goedkeuring!.getekendOp)}.',
                  style: const TextStyle(color: _tekstGrijs),
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: const Icon(Icons.draw_outlined, color: _groen),
                  title: const Text('Opnieuw laten ondertekenen'),
                  subtitle: const Text(
                    'Er wordt een nieuwe ondertekende versie toegevoegd.',
                  ),
                  onTap: () =>
                      Navigator.pop(context, _OndertekeningKeuze.opnieuw),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.description_outlined,
                    color: _oranje,
                  ),
                  title: const Text('Niet-ondertekend concept bekijken'),
                  subtitle: const Text(
                    'De bewaarde ondertekende versie blijft in Offerteversies.',
                  ),
                  onTap: () =>
                      Navigator.pop(context, _OndertekeningKeuze.concept),
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
    } else if (keuze == _OndertekeningKeuze.concept) {
      setState(() {
        _conceptWeergave = true;
        _goedkeuring = null;
        _maakNieuwePdfFuture();
      });
    }
  }

  Future<void> _toonVerzendOverzicht(OfferteMailVerzendSoort soort) async {
    final pdfBytes = await _pdfFuture;
    final data = _laatsteDocumentData;
    if (data == null || !mounted) return;

    if (soort == OfferteMailVerzendSoort.bevestiging && !_isOndertekend) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Laat de offerte eerst ondertekenen voordat u een '
            'bevestigingsmail verstuurt.',
          ),
          backgroundColor: _groen,
        ),
      );
      return;
    }

    final verstuurd = await OfferteMailVerzendDialog.toon(
      context: context,
      data: data,
      offerteBytes: pdfBytes,
      offerteBestandsnaam: _maakBestandsnaam(),
      soort: soort,
      goedkeuring: _goedkeuring,
    );

    if (!mounted || verstuurd != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('De e-mail is verstuurd.'),
        backgroundColor: _groen,
      ),
    );
  }

  Future<OfferteVersieModel?> _bewaarInGeschiedenis() async {
    if (_isArchief || _versieBewarenBezig) return null;

    final bestaand = _overeenkomendeVersie;
    if (bestaand != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            bestaand.isOndertekend
                ? 'Deze offerte staat al als ondertekende versie '
                      '${bestaand.versieNummer} in de geschiedenis.'
                : 'Deze offerte staat al als conceptversie '
                      '${bestaand.versieNummer} in de geschiedenis.',
          ),
          backgroundColor: _groen,
        ),
      );
      return bestaand;
    }

    await _pdfFuture;
    final data = _laatsteDocumentData;
    if (data == null || !mounted) return null;

    final hoogsteNummer = _versies.fold<int>(
      0,
      (hoogste, versie) =>
          versie.versieNummer > hoogste ? versie.versieNummer : hoogste,
    );
    final standaardNaam = widget.titelhoofd.offerteBronVersieNummer > 0
        ? 'Gewijzigd vanuit versie '
              '${widget.titelhoofd.offerteBronVersieNummer}'
        : 'Variant ${hoogsteNummer + 1}';
    final naamController = TextEditingController(text: standaardNaam);
    final omschrijvingController = TextEditingController();

    final invoer = await showDialog<_ConceptVersieInvoer>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: <Widget>[
              Icon(Icons.bookmark_add_outlined, color: _groen),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Offerte in geschiedenis plaatsen',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Alleen deze bewust gekozen versie wordt bewaard. '
                  'Een gewone PDF-vernieuwing of tussentijdse controle komt '
                  'niet automatisch in de geschiedenis.',
                  style: TextStyle(color: _tekstGrijs, height: 1.4),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: naamController,
                  autofocus: true,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    labelText: 'Naam van deze versie',
                    hintText: 'Bijvoorbeeld: Variant met schuifraam',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: omschrijvingController,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: 300,
                  decoration: const InputDecoration(
                    labelText: 'Interne omschrijving (optioneel)',
                    hintText: 'Wat onderscheidt deze variant?',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (widget.titelhoofd.offerteBronVersieNummer > 0)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: Text(
                      'Deze nieuwe versie krijgt automatisch de verwijzing '
                      '“gewijzigd vanuit versie '
                      '${widget.titelhoofd.offerteBronVersieNummer}”.',
                      style: const TextStyle(
                        color: _oranje,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuleren'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _groen),
              onPressed: () {
                final naam = naamController.text.trim();
                if (naam.isEmpty) return;
                Navigator.pop(
                  dialogContext,
                  _ConceptVersieInvoer(
                    naam: naam,
                    omschrijving: omschrijvingController.text.trim(),
                  ),
                );
              },
              icon: const Icon(Icons.history_rounded),
              label: const Text('In geschiedenis plaatsen'),
            ),
          ],
        );
      },
    );

    naamController.dispose();
    omschrijvingController.dispose();

    if (invoer == null || !mounted) return null;

    setState(() {
      _versieBewarenBezig = true;
    });

    try {
      final versie = await _versieService.bewaarConceptVersie(
        titelhoofd: widget.titelhoofd,
        posities: widget.posities,
        werkPosities: widget.werkPosities,
        offerteDatum: _offerteDatum,
        totaalInclusiefBtw: data.totaalInclusiefBtw,
        naam: invoer.naam,
        omschrijving: invoer.omschrijving,
      );

      if (!mounted) return versie;

      setState(() {
        _versies =
            <OfferteVersieModel>[
              versie,
              ..._versies.where((bestaand) => bestaand.id != versie.id),
            ]..sort((eerste, tweede) {
              return tweede.versieNummer.compareTo(eerste.versieNummer);
            });
      });

      if (widget.onVersieBewaard != null) {
        try {
          await widget.onVersieBewaard!(
            versieId: versie.id,
            versieNummer: versie.versieNummer,
          );
        } catch (_) {
          // De historische versie zelf is reeds veilig opgeslagen.
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Conceptversie ${versie.versieNummer} · '
              '${versie.weergaveNaam} is in de geschiedenis geplaatst.',
            ),
            backgroundColor: _groen,
          ),
        );
      }
      return versie;
    } catch (fout) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'De offerte kon niet in de geschiedenis worden geplaatst.\n'
              '$fout',
            ),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _versieBewarenBezig = false;
        });
      }
    }
  }

  Future<void> _openVersieAlsWerkversie(OfferteVersieModel versie) async {
    final callback = widget.onOpenVersieAlsWerkversie;
    if (_isArchief || callback == null) return;

    if (versie.inhoudSignatuur == _huidigeInhoudSignatuur) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Versie ${versie.versieNummer} komt al overeen met de huidige '
            'werkversie.',
          ),
          backgroundColor: _groen,
        ),
      );
      return;
    }

    final huidigeWerkversieNietBewaard = _overeenkomendeVersie == null;
    final keuze = await showDialog<_WerkversieKeuze>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Versie ${versie.versieNummer} als werkversie openen?',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'De historische versie blijft ongewijzigd. De inhoud ervan '
                  'wordt als nieuwe bewerkbare werkversie in het '
                  'overzichtsblad geplaatst.',
                  style: const TextStyle(color: _tekstGrijs, height: 1.4),
                ),
                if (huidigeWerkversieNietBewaard) ...<Widget>[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: const Text(
                      'De huidige werkversie staat nog niet in de '
                      'geschiedenis. Je kunt ze eerst bewaren om niets te '
                      'verliezen.',
                      style: TextStyle(
                        color: _oranje,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, _WerkversieKeuze.annuleren),
              child: const Text('Annuleren'),
            ),
            if (huidigeWerkversieNietBewaard)
              OutlinedButton(
                onPressed: () =>
                    Navigator.pop(dialogContext, _WerkversieKeuze.eerstBewaren),
                child: const Text('Huidige eerst bewaren'),
              ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _groen),
              onPressed: () =>
                  Navigator.pop(dialogContext, _WerkversieKeuze.openen),
              child: Text('Versie ${versie.versieNummer} openen'),
            ),
          ],
        );
      },
    );

    if (keuze == null || keuze == _WerkversieKeuze.annuleren || !mounted) {
      return;
    }

    if (keuze == _WerkversieKeuze.eerstBewaren) {
      final bewaard = await _bewaarInGeschiedenis();
      if (bewaard == null || !mounted) return;
    }

    final gelukt = await callback(
      versieTitelhoofd: _versieService.titelhoofdVan(versie),
      versiePosities: _versieService.werkPositiesVan(versie),
      bronVersieId: versie.id,
      bronVersieNummer: versie.versieNummer,
    );

    if (!mounted || !gelukt) return;

    Navigator.of(
      context,
    ).pop(const OffertePdfPreviewResultaat(werkversieGeopend: true));
  }

  Future<void> _verwijderConceptVersie(OfferteVersieModel versie) async {
    if (!versie.isConcept) return;
    if (versie.inhoudSignatuur == _huidigeInhoudSignatuur ||
        versie.id == widget.titelhoofd.offerteBronVersieId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'De huidige of gebruikte bronversie kan niet worden verwijderd.',
          ),
          backgroundColor: _groen,
        ),
      );
      return;
    }

    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Text(
            'Conceptversie verwijderen?',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'Versie ${versie.versieNummer} · ${versie.weergaveNaam} wordt '
            'uit de geschiedenis verwijderd. Ondertekende versies kunnen '
            'nooit via deze actie worden gewist.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuleren'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Concept verwijderen'),
            ),
          ],
        );
      },
    );

    if (bevestigen != true || !mounted) return;

    try {
      await _versieService.verwijderConceptVersie(versie);
      if (!mounted) return;

      setState(() {
        _versies = _versies
            .where((bestaand) => bestaand.id != versie.id)
            .toList(growable: false);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Conceptversie ${versie.versieNummer} is verwijderd.'),
          backgroundColor: _groen,
        ),
      );
    } catch (fout) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Conceptversie verwijderen is niet gelukt.\n$fout'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  Future<void> _openVersie(
    OfferteVersieModel versie, {
    bool startOndertekenen = false,
  }) async {
    try {
      final titelhoofd = _versieService.titelhoofdVan(versie);
      final posities = _versieService.positiesVan(versie);
      if (!mounted) return;

      final resultaat = await Navigator.of(context)
          .push<OffertePdfPreviewResultaat>(
            MaterialPageRoute<OffertePdfPreviewResultaat>(
              builder: (_) {
                return OffertePdfPreviewPagina(
                  titelhoofd: titelhoofd,
                  posities: posities,
                  werkPosities: _versieService.werkPositiesVan(versie),
                  initieleGoedkeuring: versie.isOndertekend
                      ? versie.goedkeuring
                      : null,
                  initieleOfferteDatum: versie.offerteDatum,
                  alleenLezen: true,
                  archiefVersieNummer: versie.versieNummer,
                  archiefVersieId: versie.id,
                  archiefIsConcept: versie.isConcept,
                  archiefVersieNaam: versie.weergaveNaam,
                  startOndertekenen: startOndertekenen && versie.isConcept,
                );
              },
            ),
          );

      await _laadVersies();
      if (!mounted || resultaat?.oneDriveResultaat == null) return;

      final oneDrive = resultaat!.oneDriveResultaat!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${oneDrive.documentType} opgeslagen in OneDrive: '
            '${oneDrive.volledigPad}',
          ),
          backgroundColor: _groen,
        ),
      );
    } catch (fout) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deze offerteversie kon niet worden geopend.\n$fout'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }

  Future<void> _vergelijkVersie(OfferteVersieModel versie) async {
    await _pdfFuture;
    final data = _laatsteDocumentData;
    if (data == null || !mounted) return;

    final vergelijking = _versieService.vergelijkMetHuidig(
      versie: versie,
      huidigTitelhoofd: widget.titelhoofd,
      huidigePosities: widget.posities,
      huidigTotaalInclusiefBtw: data.totaalInclusiefBtw,
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: Text(
            'Vergelijk met versie ${versie.versieNummer}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          content: SizedBox(
            width: 590,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 540),
              child: vergelijking.heeftWijzigingen
                  ? ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        if (vergelijking.totaalGewijzigd)
                          _bouwVergelijkTotaal(vergelijking),
                        if (vergelijking.toegevoegdePosities.isNotEmpty)
                          _bouwVergelijkSectie(
                            titel: 'Toegevoegd',
                            icoon: Icons.add_circle_outline,
                            regels: vergelijking.toegevoegdePosities,
                          ),
                        if (vergelijking.verwijderdePosities.isNotEmpty)
                          _bouwVergelijkSectie(
                            titel: 'Verwijderd',
                            icoon: Icons.remove_circle_outline,
                            regels: vergelijking.verwijderdePosities,
                          ),
                        if (vergelijking.gewijzigdePosities.isNotEmpty)
                          _bouwVergelijkSectie(
                            titel: 'Gewijzigde artikelen',
                            icoon: Icons.edit_outlined,
                            regels: vergelijking.gewijzigdePosities,
                          ),
                        if (vergelijking.projectWijzigingen.isNotEmpty)
                          _bouwVergelijkSectie(
                            titel: 'Gewijzigde projectgegevens',
                            icoon: Icons.assignment_outlined,
                            regels: vergelijking.projectWijzigingen,
                          ),
                      ],
                    )
                  : Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F6EC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFB9E1C6)),
                      ),
                      child: const Row(
                        children: <Widget>[
                          Icon(Icons.check_circle_outline, color: _groen),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Er zijn geen inhoudelijke verschillen met deze '
                              'historische versie.',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Sluiten'),
            ),
          ],
        );
      },
    );
  }

  Widget _bouwVergelijkTotaal(OfferteVergelijkingResultaat vergelijking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Totaal inclusief btw',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            '${_formatteerEuro(vergelijking.oudTotaalInclusiefBtw)} → '
            '${_formatteerEuro(vergelijking.nieuwTotaalInclusiefBtw)}',
            style: const TextStyle(
              color: _oranje,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwVergelijkSectie({
    required String titel,
    required IconData icoon,
    required List<String> regels,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _rand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icoon, color: _groen, size: 19),
              const SizedBox(width: 8),
              Text(titel, style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 8),
          for (final regel in regels)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text('• $regel'),
            ),
        ],
      ),
    );
  }

  Future<void> _toonVersiesMenu() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final scherm = MediaQuery.sizeOf(dialogContext);
        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 28,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: _rand),
          ),
          child: SizedBox(
            width: math.min(760.0, scherm.width - 40).toDouble(),
            height: math.min(650.0, scherm.height - 56).toDouble(),
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 15, 10, 15),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE7F6EC),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFCDEBD6)),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.history_rounded, color: _groen),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Offertegeschiedenis (${_versies.length})',
                          style: const TextStyle(
                            color: _groen,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Sluiten',
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: _bouwVersieStatusKaart(),
                ),
                Expanded(
                  child: _versiesLaden
                      ? const Center(
                          child: CircularProgressIndicator(color: _groen),
                        )
                      : _versies.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Er staan nog geen offerteversies in de '
                              'geschiedenis. Gebruik “In geschiedenis” om een '
                              'gekozen concept te bewaren. Ondertekende '
                              'offertes worden automatisch bewaard.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _tekstGrijs,
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                          itemCount: _versies.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, index) {
                            final versie = _versies[index];
                            final isHuidig = _isArchief
                                ? versie.versieNummer ==
                                      widget.archiefVersieNummer
                                : versie.inhoudSignatuur ==
                                      _huidigeInhoudSignatuur;
                            final isBronVoorLatereVersie = _versies.any(
                              (andere) => andere.bronVersieId == versie.id,
                            );
                            final statusKleur = versie.isOndertekend
                                ? _groen
                                : _oranje;
                            final statusAchtergrond = versie.isOndertekend
                                ? const Color(0xFFE7F6EC)
                                : const Color(0xFFFFF7ED);

                            return Container(
                              padding: const EdgeInsets.fromLTRB(13, 11, 7, 11),
                              decoration: BoxDecoration(
                                color: isHuidig
                                    ? const Color(0xFFF0FDF4)
                                    : const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isHuidig
                                      ? const Color(0xFF86D39D)
                                      : _rand,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: statusAchtergrond,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: statusKleur.withOpacity(0.28),
                                      ),
                                    ),
                                    child: Icon(
                                      versie.isOndertekend
                                          ? Icons.verified_outlined
                                          : Icons.description_outlined,
                                      color: statusKleur,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                'Versie ${versie.versieNummer} '
                                                '· ${versie.weergaveNaam}',
                                                style: const TextStyle(
                                                  color: _tekstDonker,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: statusAchtergrond,
                                                borderRadius:
                                                    BorderRadius.circular(99),
                                              ),
                                              child: Text(
                                                versie.isOndertekend
                                                    ? 'Ondertekend'
                                                    : 'Concept',
                                                style: TextStyle(
                                                  color: statusKleur,
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          versie.isOndertekend
                                              ? '${versie.goedkeuring.naam} · '
                                                    '${_formatteerDatumTijd(versie.goedkeuring.getekendOp)} '
                                                    '· ${_formatteerEuro(versie.totaalInclusiefBtw)}'
                                              : '${_formatteerDatumTijd(versie.opgeslagenOp)} '
                                                    '· ${_formatteerEuro(versie.totaalInclusiefBtw)}',
                                          style: const TextStyle(
                                            color: _tekstGrijs,
                                            fontSize: 12,
                                          ),
                                        ),
                                        if (versie.omschrijving
                                            .trim()
                                            .isNotEmpty) ...<Widget>[
                                          const SizedBox(height: 4),
                                          Text(
                                            versie.omschrijving.trim(),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: _tekstDonker,
                                              fontSize: 11.5,
                                            ),
                                          ),
                                        ],
                                        if (versie.bronVersieNummer > 0) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Gewijzigd vanuit versie '
                                            '${versie.bronVersieNummer}',
                                            style: const TextStyle(
                                              color: _oranje,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                        if (isHuidig) ...<Widget>[
                                          const SizedBox(height: 4),
                                          const Text(
                                            'Komt overeen met de geopende '
                                            'offerte',
                                            style: TextStyle(
                                              color: _groen,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<_VersieActie>(
                                    tooltip: 'Acties voor deze versie',
                                    color: Colors.white,
                                    onSelected: (actie) {
                                      Navigator.pop(dialogContext);
                                      switch (actie) {
                                        case _VersieActie.openen:
                                          _openVersie(versie);
                                          break;
                                        case _VersieActie.ondertekenen:
                                          _openVersie(
                                            versie,
                                            startOndertekenen: true,
                                          );
                                          break;
                                        case _VersieActie.vergelijken:
                                          _vergelijkVersie(versie);
                                          break;
                                        case _VersieActie.werkversie:
                                          _openVersieAlsWerkversie(versie);
                                          break;
                                        case _VersieActie.verwijderen:
                                          _verwijderConceptVersie(versie);
                                          break;
                                      }
                                    },
                                    itemBuilder: (_) =>
                                        <PopupMenuEntry<_VersieActie>>[
                                          const PopupMenuItem<_VersieActie>(
                                            value: _VersieActie.openen,
                                            child: ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              leading: Icon(
                                                Icons.picture_as_pdf_outlined,
                                                color: _groen,
                                              ),
                                              title: Text('PDF openen'),
                                            ),
                                          ),
                                          if (versie.isConcept)
                                            const PopupMenuItem<_VersieActie>(
                                              value: _VersieActie.ondertekenen,
                                              child: ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                leading: Icon(
                                                  Icons.draw_outlined,
                                                  color: _groen,
                                                ),
                                                title: Text(
                                                  'Openen en ondertekenen',
                                                ),
                                              ),
                                            ),
                                          if (!_isArchief && !isHuidig)
                                            const PopupMenuItem<_VersieActie>(
                                              value: _VersieActie.vergelijken,
                                              child: ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                leading: Icon(
                                                  Icons.compare_arrows_rounded,
                                                  color: _oranje,
                                                ),
                                                title: Text(
                                                  'Vergelijk met huidige',
                                                ),
                                              ),
                                            ),
                                          if (!_isArchief &&
                                              !isHuidig &&
                                              widget.onOpenVersieAlsWerkversie !=
                                                  null)
                                            const PopupMenuItem<_VersieActie>(
                                              value: _VersieActie.werkversie,
                                              child: ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                leading: Icon(
                                                  Icons.edit_note_rounded,
                                                  color: _groen,
                                                ),
                                                title: Text(
                                                  'Als basis openen om te '
                                                  'wijzigen',
                                                ),
                                              ),
                                            ),
                                          if (versie.isConcept &&
                                              !isHuidig &&
                                              !isBronVoorLatereVersie &&
                                              versie.id !=
                                                  widget
                                                      .titelhoofd
                                                      .offerteBronVersieId)
                                            const PopupMenuItem<_VersieActie>(
                                              value: _VersieActie.verwijderen,
                                              child: ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                leading: Icon(
                                                  Icons.delete_outline,
                                                  color: Color(0xFFDC2626),
                                                ),
                                                title: Text(
                                                  'Concept verwijderen',
                                                ),
                                              ),
                                            ),
                                        ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bouwVersieStatusKaart() {
    late final Color achtergrond;
    late final Color rand;
    late final Color kleur;
    late final IconData icoon;
    late final String titel;
    late final String uitleg;

    if (_isArchief) {
      final nummer = widget.archiefVersieNummer ?? 0;
      if (_actiefArchiefIsConcept) {
        achtergrond = const Color(0xFFFFF7ED);
        rand = const Color(0xFFFED7AA);
        kleur = _oranje;
        icoon = Icons.description_outlined;
        titel = 'Conceptversie $nummer · ${widget.archiefVersieNaam}';
        uitleg =
            'Dit is een vaste historische momentopname. Je kunt deze '
            'exacte versie laten ondertekenen; inhoudelijke wijzigingen maak '
            'je via “Als basis openen om te wijzigen”.';
      } else {
        achtergrond = const Color(0xFFE7F6EC);
        rand = const Color(0xFFB9E1C6);
        kleur = _groen;
        icoon = Icons.lock_outline_rounded;
        titel = 'Ondertekende versie $nummer';
        uitleg =
            'Deze versie is vastgelegd en alleen-lezen. Latere '
            'wijzigingen overschrijven haar nooit.';
      }
    } else if (_isGewijzigdVanWerkBron || _isGewijzigdNaOndertekening) {
      achtergrond = const Color(0xFFFFF7ED);
      rand = const Color(0xFFFED7AA);
      kleur = _oranje;
      icoon = Icons.edit_note_rounded;
      titel = widget.titelhoofd.offerteBronVersieNummer > 0
          ? 'Werkversie gewijzigd vanuit versie '
                '${widget.titelhoofd.offerteBronVersieNummer}'
          : 'Huidige offerte is gewijzigd';
      uitleg =
          'De eerdere versies blijven hieronder bewaard. Plaats deze '
          'variant bewust in de geschiedenis of laat ze opnieuw '
          'ondertekenen.';
    } else if (_isOndertekend) {
      achtergrond = const Color(0xFFE7F6EC);
      rand = const Color(0xFFB9E1C6);
      kleur = _groen;
      icoon = Icons.verified_rounded;
      titel = 'Huidige offerte is ondertekend';
      uitleg =
          'Deze inhoud komt overeen met ondertekende versie '
          '${_overeenkomendeOndertekendeVersie?.versieNummer ?? ''}.';
    } else if (_overeenkomendeConceptVersie != null) {
      achtergrond = const Color(0xFFFFF7ED);
      rand = const Color(0xFFFED7AA);
      kleur = _oranje;
      icoon = Icons.bookmark_added_outlined;
      titel =
          'Opgeslagen als conceptversie '
          '${_overeenkomendeConceptVersie!.versieNummer}';
      uitleg =
          'Deze werkversie staat bewust in de geschiedenis en kan later '
          'worden geopend, aangepast of ondertekend.';
    } else {
      achtergrond = const Color(0xFFF9FAFB);
      rand = _rand;
      kleur = _tekstGrijs;
      icoon = Icons.history_rounded;
      titel = 'Nog niet in de geschiedenis geplaatst';
      uitleg =
          'Tussentijds genereren blijft een controle. Alleen via '
          '“In geschiedenis” wordt deze versie als concept bewaard.';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: achtergrond,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rand),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icoon, color: kleur, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  titel,
                  style: TextStyle(color: kleur, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  uitleg,
                  style: const TextStyle(
                    color: _tekstGrijs,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwOndertekenActie(BuildContext context) {
    if (_isArchief && !_magOndertekenen) {
      return const SizedBox.shrink();
    }

    final toonTekst = MediaQuery.sizeOf(context).width >= 920;
    final icoon = _isOndertekend ? Icons.verified_rounded : Icons.draw_outlined;
    final label = _isArchief && _actiefArchiefIsConcept
        ? 'Deze versie ondertekenen'
        : _isOndertekend
        ? 'Ondertekend'
        : _heeftOndertekendeVersies
        ? 'Opnieuw ondertekenen'
        : 'Laten ondertekenen';
    final tooltip = _isOndertekend ? 'Ondertekende offerte beheren' : label;

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
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _bouwGeschiedenisBewaarActie(BuildContext context) {
    if (_isArchief) return const SizedBox.shrink();

    final toonTekst = MediaQuery.sizeOf(context).width >= 1120;
    final bestaand = _overeenkomendeVersie;
    final tooltip = bestaand == null
        ? 'Deze offerte bewust in de geschiedenis plaatsen'
        : 'Deze offerte staat al in de geschiedenis';

    if (!toonTekst) {
      return IconButton(
        tooltip: tooltip,
        onPressed: _versieBewarenBezig
            ? null
            : () {
                _bewaarInGeschiedenis();
              },
        icon: _versieBewarenBezig
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Icon(
                bestaand == null
                    ? Icons.bookmark_add_outlined
                    : Icons.bookmark_added_outlined,
              ),
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
        onPressed: _versieBewarenBezig
            ? null
            : () {
                _bewaarInGeschiedenis();
              },
        icon: _versieBewarenBezig
            ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                bestaand == null
                    ? Icons.bookmark_add_outlined
                    : Icons.bookmark_added_outlined,
                size: 19,
              ),
        label: Text(
          bestaand == null ? 'In geschiedenis' : 'Bewaard',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _bouwVersiesActie(BuildContext context) {
    final toonTekst = MediaQuery.sizeOf(context).width >= 1040;

    if (!toonTekst) {
      return IconButton(
        tooltip: 'Offertegeschiedenis (${_versies.length})',
        onPressed: _toonVersiesMenu,
        icon: _versiesLaden
            ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Badge(
                label: Text('${_versies.length}'),
                isLabelVisible: _versies.isNotEmpty,
                child: const Icon(Icons.history_rounded),
              ),
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
        onPressed: _toonVersiesMenu,
        icon: _versiesLaden
            ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.history_rounded, size: 19),
        label: Text(
          'Geschiedenis (${_versies.length})',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _bouwMailActie() {
    return PopupMenuButton<OfferteMailVerzendSoort>(
      tooltip: 'E-mail versturen',
      color: Colors.white,
      surfaceTintColor: Colors.white,
      icon: const Icon(Icons.email_outlined),
      onSelected: _toonVerzendOverzicht,
      itemBuilder: (context) => <PopupMenuEntry<OfferteMailVerzendSoort>>[
        const PopupMenuItem<OfferteMailVerzendSoort>(
          value: OfferteMailVerzendSoort.offerte,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.outgoing_mail, color: _groen),
            title: Text('Offerte versturen'),
            subtitle: Text('Overzicht van tekst en bijlagen'),
          ),
        ),
        PopupMenuItem<OfferteMailVerzendSoort>(
          value: OfferteMailVerzendSoort.bevestiging,
          enabled: _isOndertekend,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.mark_email_read_outlined,
              color: _isOndertekend ? _groen : const Color(0xFF9CA3AF),
            ),
            title: const Text('Bevestiging na ondertekening'),
            subtitle: Text(
              _isOndertekend
                  ? 'Ondertekende offerte en gekozen folders'
                  : 'Eerst laten ondertekenen',
            ),
          ),
        ),
      ],
    );
  }

  Widget _bouwOneDriveActie(BuildContext context) {
    final toonTekst = MediaQuery.sizeOf(context).width >= 1220;

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

  Widget? _bouwStatusBalk() {
    if (_isArchief) {
      final concept = _actiefArchiefIsConcept;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        color: concept ? const Color(0xFFFFF7ED) : const Color(0xFFE7F6EC),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              concept ? Icons.description_outlined : Icons.lock_outline_rounded,
              color: concept ? _oranje : _groen,
              size: 18,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                concept
                    ? 'Conceptversie ${widget.archiefVersieNummer ?? ''} · '
                          '${widget.archiefVersieNaam} · vaste historische '
                          'momentopname'
                    : 'Ondertekende versie '
                          '${widget.archiefVersieNummer ?? ''} · vastgelegd '
                          'en alleen-lezen',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: concept ? _oranje : _groen,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_isGewijzigdVanWerkBron || _isGewijzigdNaOndertekening) {
      final bronNummer = widget.titelhoofd.offerteBronVersieNummer;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        color: const Color(0xFFFFF7ED),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.edit_note_rounded, color: _oranje, size: 19),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                bronNummer > 0
                    ? 'Werkversie gewijzigd vanuit versie $bronNummer · '
                          'plaats deze variant in de geschiedenis of laat ze '
                          'ondertekenen.'
                    : 'Gewijzigd na ondertekening · opnieuw laten '
                          'ondertekenen. De eerdere versie blijft bewaard in '
                          'de geschiedenis.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _oranje,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final concept = _overeenkomendeConceptVersie;
    if (!_isOndertekend && concept != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        color: const Color(0xFFFFF7ED),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.bookmark_added_outlined, color: _oranje, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Opgeslagen als conceptversie ${concept.versieNummer} · '
                '${concept.weergaveNaam}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _oranje,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return null;
  }

  String _appBarTitel() {
    if (_isArchief) {
      final soort = _actiefArchiefIsConcept ? 'Concept' : 'Ondertekend';
      return '$soort · Versie ${widget.archiefVersieNummer ?? ''}';
    }
    if (_isOndertekend) return 'Offertevoorbeeld · Ondertekend';
    if (_isGewijzigdVanWerkBron || _isGewijzigdNaOndertekening) {
      return 'Offertevoorbeeld · Gewijzigd';
    }
    if (_overeenkomendeConceptVersie != null) {
      return 'Offertevoorbeeld · Concept bewaard';
    }
    return 'Offertevoorbeeld';
  }

  @override
  Widget build(BuildContext context) {
    final bestandsnaam = _maakBestandsnaam();
    final statusBalk = _bouwStatusBalk();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: _oranje,
        foregroundColor: Colors.white,
        title: Text(
          _appBarTitel(),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: <Widget>[
          _bouwGeschiedenisBewaarActie(context),
          _bouwVersiesActie(context),
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
      body: Column(
        children: <Widget>[
          if (statusBalk != null) statusBalk,
          Expanded(
            child: LayoutBuilder(
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
          ),
        ],
      ),
    );
  }

  static String _formatteerEuro(double waarde) {
    final veilig = waarde.isFinite ? waarde : 0.0;
    final negatief = veilig < 0;
    final delen = veilig.abs().toStringAsFixed(2).split('.');
    final geheel = delen.first;
    final decimalen = delen.length > 1 ? delen[1] : '00';
    final buffer = StringBuffer();

    for (var index = 0; index < geheel.length; index++) {
      if (index > 0 && (geheel.length - index) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(geheel[index]);
    }

    return '${negatief ? '- ' : ''}€ ${buffer.toString()},$decimalen';
  }

  static String _formatteerDatumTijd(DateTime datum) {
    String twee(int waarde) => waarde.toString().padLeft(2, '0');
    return '${twee(datum.day)}/${twee(datum.month)}/${datum.year} '
        '${twee(datum.hour)}:${twee(datum.minute)}';
  }
}

enum _OndertekeningKeuze { opnieuw, concept }

enum _VersieActie { openen, ondertekenen, vergelijken, werkversie, verwijderen }

enum _WerkversieKeuze { annuleren, eerstBewaren, openen }

class _ConceptVersieInvoer {
  const _ConceptVersieInvoer({required this.naam, required this.omschrijving});

  final String naam;
  final String omschrijving;
}
