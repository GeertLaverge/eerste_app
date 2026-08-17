// THIMACO-CONTROLE: OFFERTE-IPAD-NATIVE-PRINT-A4-20260817
// THIMACO-CONTROLE: OFFERTE-IPAD-PRINT-A4-FORCE-CUSTOM-PAPER-20260817
// THIMACO-CONTROLE: OFFERTE-PDF-KLEURAFWIJKING-VOORBLAD-20260816
// THIMACO-CONTROLE: PRIJS-VOOR-ALLE-POSITIES-FASE3-OP-ACTUELE-PDF-PREVIEW-20260815
// THIMACO-CONTROLE: PRIJSARCHITECTUUR-OPRUIMEN-STAP5D2-PDF-ZONDER-PROJECTPRIJS-20260814
// THIMACO-CONTROLE: OFFERTEVARIANTEN-BEWERKEN-OPSLAAN-ALS-NIEUW-20260811
// THIMACO-CONTROLE: OFFERTE-IPAD-PRINT-A4-VAST-20260811
// THIMACO-CONTROLE: OFFERTE-GESCHIEDENIS-CONCEPTEN-WISSEN-ONDERTEKEND-BESCHERMD-20260809_2057
// THIMACO-CONTROLE: OFFERTE-OMSCHRIJVING-DOORGEVEN-AAN-PDF-20260809-2030
// THIMACO-CONTROLE: OFFERTE-MAIL-MEERDERE-GESCHIEDENISVERSIES-20260809
// THIMACO-CONTROLE: OFFERTE-CONCEPTVERSIES-EN-WERKVERSIES-20260806
// THIMACO-CONTROLE: OFFERTE-ONDERTEKENDE-VERSIES-MENU-20260806
// THIMACO-CONTROLE: OFFERTE-MAIL-VERZENDOVERZICHT-EN-BIBLIOTHEEK-20260802
// THIMACO-CONTROLE: OFFERTE-GOEDKEURING-IPAD-PAPIER-MAIL-20260801
// THIMACO-CONTROLE: OFFERTE-PDF-ONEDRIVE-MAPPEN-EN-BESTANDSNAAM-20260731
import 'dart:math' as math;

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
import 'mail/offerte_mail_verzend_dialog.dart';
import 'offerte_pdf_model.dart';
import 'offerte_pdf_service.dart';
import 'offerte_pvc_raam_tekening_service.dart';
import 'prijzen/offerte_prijs_voor_alle_posities_service.dart';
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
  static const MethodChannel _nativePrintKanaal = MethodChannel(
    'be.thimaco.app/native_print',
  );

  final OneDriveKlantdocumentService _oneDriveService =
      OneDriveKlantdocumentService();
  final OfferteVersieService _versieService = const OfferteVersieService();

  late Future<Uint8List> _pdfFuture;
  late DateTime _offerteDatum;
  late OpmetingProjectTitelhoofd _actiefTitelhoofd;
  late String _huidigeInhoudSignatuur;
  OfferteDocumentData? _laatsteDocumentData;
  OfferteGoedkeuring? _goedkeuring;
  List<OfferteVersieModel> _versies = const <OfferteVersieModel>[];
  int _pdfVersie = 0;
  bool _opslaanNaarOneDriveBezig = false;
  bool _afdrukkenBezig = false;
  bool _ondertekenenBezig = false;
  bool _versieBewarenBezig = false;
  bool _versiesLaden = true;
  bool _conceptWeergave = false;

  bool get _isArchief => widget.archiefVersieNummer != null;

  bool get _actiefArchiefIsConcept => widget.archiefIsConcept;

  bool get _magOndertekenen => !widget.alleenLezen || _actiefArchiefIsConcept;

  bool get _isOndertekend => _goedkeuring?.isOndertekend ?? false;

  List<OfferteVersieModel> get _varianten =>
      _versieService.variantenUit(_versies);

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

  OfferteVersieModel? get _actieveVariant {
    if (_isArchief && widget.archiefIsConcept) {
      return _versieService.variantVoorId(
        versies: _versies,
        variantId: widget.archiefVersieId,
      );
    }
    return _versieService.variantVoorId(
      versies: _versies,
      variantId: _actiefTitelhoofd.offerteBronVersieId,
    );
  }

  List<OfferteVersieModel> get _ondertekendeVanActieveVariant {
    final variant = _actieveVariant;
    if (variant == null) return const <OfferteVersieModel>[];
    return _versieService.ondertekendeMomentopnamesVoorVariant(
      versies: _versies,
      variantId: variant.id,
    );
  }

  bool get _actieveVariantHeeftActueleOndertekening {
    final variant = _actieveVariant;
    if (variant == null) return false;
    return _ondertekendeVanActieveVariant.any(
      (snapshot) => snapshot.inhoudSignatuur == variant.inhoudSignatuur,
    );
  }

  bool get _heeftOnopgeslagenWijzigingen {
    if (_isArchief) return false;
    final variant = _actieveVariant;
    if (variant != null) {
      return variant.inhoudSignatuur != _huidigeInhoudSignatuur;
    }
    return _overeenkomendeConceptVersie == null;
  }

  @override
  void initState() {
    super.initState();
    _offerteDatum = widget.initieleOfferteDatum ?? DateTime.now();
    _actiefTitelhoofd = widget.titelhoofd;
    _goedkeuring = widget.initieleGoedkeuring;
    _huidigeInhoudSignatuur = _versieService.maakInhoudSignatuur(
      titelhoofd: _actiefTitelhoofd,
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
      _actiefTitelhoofd = widget.titelhoofd;
      _goedkeuring = widget.initieleGoedkeuring;
      _offerteDatum = widget.initieleOfferteDatum ?? DateTime.now();
      _huidigeInhoudSignatuur = _versieService.maakInhoudSignatuur(
        titelhoofd: _actiefTitelhoofd,
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
      final versies = await _versieService.laadVoorProject(_actiefTitelhoofd);
      if (!mounted) return;

      setState(() {
        _versies = versies;
        _versiesLaden = false;

        // Een ondertekende momentopname staat voortaan naast de bewerkbare
        // variant. Bij normaal openen tonen we dus nooit automatisch de
        // handtekening van een vroegere momentopname over de werkvariant heen.
        if (!_isArchief && !_conceptWeergave) {
          _goedkeuring = widget.initieleGoedkeuring;
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

  String _maakBestandsnaam() {
    final offerteNummer = _actiefTitelhoofd.samengesteldOffertenummer;
    final veiligeNaam = _actiefTitelhoofd.klantNaam.trim().replaceAll(
      RegExp(r'[^a-zA-Z0-9_-]+'),
      '_',
    );
    final nummerVoorBestandsnaam = offerteNummer.trim().isEmpty
        ? 'zonder_nummer'
        : offerteNummer.trim();

    String versieDeel = '';
    if (_isArchief) {
      final soort = _actiefArchiefIsConcept ? 'Offerte' : 'Ondertekend';
      versieDeel = '_${soort}_${widget.archiefVersieNummer}';
    } else if (_isOndertekend) {
      final nummer =
          _actieveVariant?.versieNummer ??
          _overeenkomendeOndertekendeVersie?.versieNummer;
      versieDeel = nummer == null
          ? '_Ondertekend'
          : '_Ondertekend_Offerte_$nummer';
    } else if (_actieveVariant != null) {
      versieDeel = '_Offerte_${_actieveVariant!.versieNummer}';
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
        klantNaam: _actiefTitelhoofd.klantNaam,
        klantnummer: _actiefTitelhoofd.klantnummer,
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

  Future<OfferteVersieModel?> _zorgVariantBewaardVoorOndertekening() async {
    if (_isArchief) return _actieveVariant;

    final actief = _actieveVariant;
    if (actief == null) {
      final keuze = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Text(
            'Eerst als offerte opslaan',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'Een ondertekende offerte moet altijd gekoppeld zijn aan een '
            'bewerkbare offertevariant. Sla deze offerte daarom eerst als '
            'nieuwe offerte op.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuleren'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _groen),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Opslaan als nieuwe offerte'),
            ),
          ],
        ),
      );
      if (keuze != true || !mounted) return null;
      return _bewaarAlsNieuweVariant();
    }

    if (!_heeftOnopgeslagenWijzigingen) return actief;

    final keuze = await showDialog<_OndertekenBewaarKeuze>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          'Offerte ${actief.versieNummer} eerst opslaan?',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text(
          'Offerte ${actief.versieNummer} bevat nog niet-opgeslagen '
          'wijzigingen. Om exact deze inhoud te laten ondertekenen, moet ze '
          'eerst worden opgeslagen.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _OndertekenBewaarKeuze.annuleren),
            child: const Text('Annuleren'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              _OndertekenBewaarKeuze.nieuweVariant,
            ),
            child: const Text('Opslaan als nieuwe offerte'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _groen),
            onPressed: () => Navigator.pop(
              dialogContext,
              _OndertekenBewaarKeuze.huidigeVariant,
            ),
            child: Text('Opslaan in Offerte ${actief.versieNummer}'),
          ),
        ],
      ),
    );

    if (keuze == null || keuze == _OndertekenBewaarKeuze.annuleren) {
      return null;
    }
    if (keuze == _OndertekenBewaarKeuze.nieuweVariant) {
      return _bewaarAlsNieuweVariant();
    }
    return _bewaarHuidigeVariant();
  }

  Future<void> _laatOndertekenen() async {
    if (_ondertekenenBezig || !_magOndertekenen) return;

    if (!_isArchief && _versiesLaden) {
      await _laadVersies();
      if (!mounted) return;
    }

    OfferteVersieModel? variant;
    String variantId;
    int variantNummer;
    String variantNaam;

    if (_isArchief && widget.archiefIsConcept) {
      variantId = widget.archiefVersieId.trim();
      variantNummer = widget.archiefVersieNummer ?? 0;
      variantNaam = widget.archiefVersieNaam;
      if (variantId.isEmpty || variantNummer <= 0) return;
    } else {
      variant = await _zorgVariantBewaardVoorOndertekening();
      if (variant == null || !mounted) return;
      variantId = variant.id;
      variantNummer = variant.versieNummer;
      variantNaam = variant.naam;
    }

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
            : _actiefTitelhoofd.klantNaam.trim(),
        offerteNummer: data.offerteNummer,
        totaalTekst: _formatteerEuro(data.totaalInclusiefBtw),
      );

      if (resultaat == null || !mounted) return;

      final snapshot = await _versieService.bewaarOndertekendeVersie(
        titelhoofd: _actiefTitelhoofd,
        posities: widget.posities,
        werkPosities: widget.werkPosities,
        offerteDatum: _offerteDatum,
        totaalInclusiefBtw: data.totaalInclusiefBtw,
        goedkeuring: resultaat,
        variantId: variantId,
        variantNummer: variantNummer,
        variantNaam: variantNaam,
      );

      if (!mounted) return;

      setState(() {
        _goedkeuring = resultaat;
        _conceptWeergave = false;
        _versies =
            <OfferteVersieModel>[
              snapshot,
              ..._versies.where((bestaand) => bestaand.id != snapshot.id),
            ]..sort((eerste, tweede) {
              final nummer = tweede.versieNummer.compareTo(eerste.versieNummer);
              if (nummer != 0) return nummer;
              if (eerste.isVariant != tweede.isVariant) {
                return eerste.isVariant ? -1 : 1;
              }
              return tweede.opgeslagenOp.compareTo(eerste.opgeslagenOp);
            });
        _maakNieuwePdfFuture();
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ondertekende momentopname van Offerte $variantNummer is '
            'bewaard. De bewerkbare Offerte $variantNummer blijft bestaan.',
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
                      : 'Ondertekende Offerte $versieNummer',
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
                    'Er wordt een nieuwe onveranderbare momentopname toegevoegd.',
                  ),
                  onTap: () =>
                      Navigator.pop(context, _OndertekeningKeuze.opnieuw),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.description_outlined,
                    color: _oranje,
                  ),
                  title: const Text('Bewerkbare offerte bekijken'),
                  subtitle: const Text(
                    'De ondertekende momentopname blijft definitief bewaard.',
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

    final mailVersies = soort == OfferteMailVerzendSoort.offerte
        ? await _versieService.laadVoorProject(_actiefTitelhoofd)
        : const <OfferteVersieModel>[];
    if (!mounted) return;

    final verstuurd = await OfferteMailVerzendDialog.toon(
      context: context,
      data: data,
      offerteBytes: pdfBytes,
      offerteBestandsnaam: _maakBestandsnaam(),
      soort: soort,
      goedkeuring: _goedkeuring,
      historischeOffertes: _bouwHistorischeMailOffertes(mailVersies),
    );

    if (!mounted || verstuurd != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('De e-mail is verstuurd.'),
        backgroundColor: _groen,
      ),
    );
  }

  List<OfferteMailHistorischeOfferte> _bouwHistorischeMailOffertes(
    Iterable<OfferteVersieModel> versies,
  ) {
    final resultaat = versies
        .map((versie) {
          final naam = versie.weergaveNaam.trim().isEmpty
              ? 'Offerte ${versie.versieNummer}'
              : versie.weergaveNaam.trim();
          final nummer = versie.offerteNummer.trim().isEmpty
              ? _actiefTitelhoofd.samengesteldOffertenummer.trim()
              : versie.offerteNummer.trim();
          final bestandsnaam = _maakHistorischeOfferteBestandsnaam(
            offerteNummer: nummer,
            versieNummer: versie.versieNummer,
            naam: naam,
          );

          return OfferteMailHistorischeOfferte(
            id: versie.id,
            versieNummer: versie.versieNummer,
            naam: naam,
            statusLabel: versie.isOndertekend
                ? 'Ondertekend'
                : 'Bewerkbare offerte',
            opgeslagenOp: versie.opgeslagenOp,
            omschrijving: versie.omschrijving,
            bestandsnaam: bestandsnaam,
            pdfLader: () => _bouwPdfVoorHistorischeVersie(versie),
          );
        })
        .toList(growable: false);

    return List<OfferteMailHistorischeOfferte>.unmodifiable(resultaat);
  }

  String _maakHistorischeOfferteBestandsnaam({
    required String offerteNummer,
    required int versieNummer,
    required String naam,
  }) {
    var basis = <String>[
      'Offerte',
      if (offerteNummer.trim().isNotEmpty) offerteNummer.trim(),
      'V$versieNummer',
      naam.trim(),
    ].where((deel) => deel.trim().isNotEmpty).join(' - ');

    basis = basis.replaceAll(RegExp(r'[\\/:*?"<>|]+'), '_');
    basis = basis.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (basis.isEmpty) basis = 'Offerte $versieNummer';
    return '$basis.pdf';
  }

  Future<Uint8List> _bouwPdfVoorHistorischeVersie(
    OfferteVersieModel versie,
  ) async {
    var titelhoofd = _versieService.titelhoofdVan(versie);
    if (versie.isVariant) {
      titelhoofd = titelhoofd.metActieveOfferteVariant(
        versieId: versie.id,
        versieNummer: versie.versieNummer,
      );
    } else if (versie.versieNummer > 0) {
      titelhoofd = titelhoofd.copyWith(
        offerteVersie: OpmetingProjectTitelhoofd.offerteVersieVoorVariantNummer(
          versie.versieNummer,
        ),
      );
    }
    final posities = List<OpmetingOverzichtRaamItem>.unmodifiable(
      _versieService.positiesVan(versie),
    );
    final prijsPosities =
        OffertePrijsVoorAllePositiesService.projecteerOpPosities(
          posities: posities,
          regels: titelhoofd.prijsVoorAllePositiesRegels,
        );

    final pvcRaamTekeningen =
        await OffertePvcRaamTekeningService.maakTekeningen(posities);
    final data = OfferteDocumentData(
      klant: OfferteKlantgegevens.vanTitelhoofd(titelhoofd),
      offerteNummer: titelhoofd.samengesteldOffertenummer,
      offerteOmschrijving: titelhoofd.offerteOmschrijving,
      offerteDatum: versie.offerteDatum,
      btwTarief: titelhoofd.btwTarief,
      kortingOmschrijving: titelhoofd.kortingOmschrijving,
      projectKleurBinnen: titelhoofd.projectKleurBinnen,
      projectKleurBuiten: titelhoofd.projectKleurBuiten,
      ralKleurToebehoren: titelhoofd.ralKleurToebehoren,
      kleurAfwijking: titelhoofd.kleurAfwijking,
      posities: prijsPosities,
      pvcRaamTekeningen: pvcRaamTekeningen,
    );

    return OffertePdfService.bouwPdf(
      data,
      goedkeuring: versie.isOndertekend ? versie.goedkeuring : null,
    );
  }

  int get _volgendeVariantNummer {
    return _versies.fold<int>(
          0,
          (hoogste, versie) =>
              versie.versieNummer > hoogste ? versie.versieNummer : hoogste,
        ) +
        1;
  }

  Future<void> _registreerVariantAlsActief(OfferteVersieModel variant) async {
    final nieuwTitelhoofd = _versieService
        .titelhoofdVan(variant)
        .metActieveOfferteVariant(
          versieId: variant.id,
          versieNummer: variant.versieNummer,
        );

    if (mounted) {
      setState(() {
        _actiefTitelhoofd = nieuwTitelhoofd;
        _huidigeInhoudSignatuur = _versieService.maakInhoudSignatuur(
          titelhoofd: _actiefTitelhoofd,
          posities: widget.posities,
        );
        _goedkeuring = null;
        _conceptWeergave = false;
        _versies =
            <OfferteVersieModel>[
              variant,
              ..._versies.where((bestaand) => bestaand.id != variant.id),
            ]..sort((eerste, tweede) {
              final nummer = tweede.versieNummer.compareTo(eerste.versieNummer);
              if (nummer != 0) return nummer;
              if (eerste.isVariant != tweede.isVariant) {
                return eerste.isVariant ? -1 : 1;
              }
              return tweede.opgeslagenOp.compareTo(eerste.opgeslagenOp);
            });
        _maakNieuwePdfFuture();
      });
    }

    if (widget.onVersieBewaard != null) {
      try {
        await widget.onVersieBewaard!(
          versieId: variant.id,
          versieNummer: variant.versieNummer,
        );
      } catch (_) {
        // De variant zelf staat al veilig in de atomaire variantopslag.
      }
    }
  }

  Future<OfferteVersieModel?> _bewaarHuidigeVariant({
    bool toonMelding = true,
  }) async {
    if (_isArchief || _versieBewarenBezig) return null;

    final actief = _actieveVariant;
    if (actief == null) {
      if (toonMelding && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Er is nog geen actieve offertevariant. Gebruik '
              '“Opslaan als nieuwe offerte”.',
            ),
            backgroundColor: _oranje,
          ),
        );
      }
      return null;
    }

    if (actief.inhoudSignatuur == _huidigeInhoudSignatuur) {
      if (toonMelding && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Offerte ${actief.versieNummer} is al opgeslagen.'),
            backgroundColor: _groen,
          ),
        );
      }
      return actief;
    }

    await _pdfFuture;
    final data = _laatsteDocumentData;
    if (data == null || !mounted) return null;

    setState(() => _versieBewarenBezig = true);
    try {
      final variant = await _versieService.werkVariantBij(
        variantId: actief.id,
        titelhoofd: _actiefTitelhoofd,
        posities: widget.posities,
        werkPosities: widget.werkPosities,
        offerteDatum: _offerteDatum,
        totaalInclusiefBtw: data.totaalInclusiefBtw,
      );

      if (!mounted) return variant;
      await _registreerVariantAlsActief(variant);

      if (toonMelding && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Offerte ${variant.versieNummer} is bijgewerkt. '
              'Eerdere ondertekende momentopnames blijven ongewijzigd.',
            ),
            backgroundColor: _groen,
          ),
        );
      }
      return variant;
    } catch (fout) {
      if (toonMelding && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Offerte opslaan is niet gelukt.\n$fout'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
      return null;
    } finally {
      if (mounted) setState(() => _versieBewarenBezig = false);
    }
  }

  Future<OfferteVersieModel?> _bewaarAlsNieuweVariant({
    bool toonMelding = true,
  }) async {
    if (_isArchief || _versieBewarenBezig) return null;

    await _pdfFuture;
    final data = _laatsteDocumentData;
    if (data == null || !mounted) return null;

    final nummer = _volgendeVariantNummer;
    final naamController = TextEditingController();
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
          title: Row(
            children: <Widget>[
              const Icon(Icons.add_circle_outline, color: _groen),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Opslaan als nieuwe offerte · Offerte $nummer',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Er wordt een nieuwe bewerkbare offertevariant gemaakt. '
                  'Het offertenummer krijgt automatisch '
                  'V${OpmetingProjectTitelhoofd.offerteVersieVoorVariantNummer(nummer)}.',
                  style: const TextStyle(color: _tekstGrijs, height: 1.4),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: naamController,
                  autofocus: true,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    labelText: 'Korte naam (optioneel)',
                    hintText: 'Bijvoorbeeld: Rolluiken of Screens',
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
                    hintText: 'Wat onderscheidt deze offerte?',
                    border: OutlineInputBorder(),
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
              onPressed: () => Navigator.pop(
                dialogContext,
                _ConceptVersieInvoer(
                  naam: naamController.text.trim(),
                  omschrijving: omschrijvingController.text.trim(),
                ),
              ),
              icon: const Icon(Icons.bookmark_add_outlined),
              label: Text('Offerte $nummer opslaan'),
            ),
          ],
        );
      },
    );

    naamController.dispose();
    omschrijvingController.dispose();
    if (invoer == null || !mounted) return null;

    setState(() => _versieBewarenBezig = true);
    try {
      final variant = await _versieService.bewaarNieuweVariant(
        titelhoofd: _actiefTitelhoofd,
        posities: widget.posities,
        werkPosities: widget.werkPosities,
        offerteDatum: _offerteDatum,
        totaalInclusiefBtw: data.totaalInclusiefBtw,
        naam: invoer.naam,
        omschrijving: invoer.omschrijving,
      );

      if (!mounted) return variant;
      await _registreerVariantAlsActief(variant);

      if (toonMelding && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${variant.offerteVariantLabel} is opgeslagen en is nu de '
              'actieve bewerkbare offerte.',
            ),
            backgroundColor: _groen,
          ),
        );
      }
      return variant;
    } catch (fout) {
      if (toonMelding && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nieuwe offerte opslaan is niet gelukt.\n$fout'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
      return null;
    } finally {
      if (mounted) setState(() => _versieBewarenBezig = false);
    }
  }

  Future<void> _openVersieAlsWerkversie(OfferteVersieModel versie) async {
    final callback = widget.onOpenVersieAlsWerkversie;
    if (_isArchief || callback == null || !versie.isVariant) return;

    final actief = _actieveVariant;
    if (actief?.id == versie.id && !_heeftOnopgeslagenWijzigingen) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Offerte ${versie.versieNummer} is al de actieve offertevariant.',
          ),
          backgroundColor: _groen,
        ),
      );
      return;
    }

    final heeftOnopgeslagen = _heeftOnopgeslagenWijzigingen;
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
            '${versie.offerteVariantLabel} openen om te bewerken?',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          content: SizedBox(
            width: 540,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'De gekozen offertevariant wordt volledig terug als '
                  'werkbestand geopend. Andere opgeslagen offertevarianten '
                  'blijven ongewijzigd.',
                  style: TextStyle(color: _tekstGrijs, height: 1.4),
                ),
                if (heeftOnopgeslagen) ...<Widget>[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: Text(
                      actief == null
                          ? 'De huidige offerte is nog niet als variant '
                                'opgeslagen. Sla ze eerst als nieuwe offerte '
                                'op of kies bewust om de wijzigingen te negeren.'
                          : 'Offerte ${actief.versieNummer} bevat nog '
                                'niet-opgeslagen wijzigingen. Bewaar deze in '
                                'Offerte ${actief.versieNummer}, maak er een '
                                'nieuwe offerte van, of negeer ze bewust.',
                      style: const TextStyle(
                        color: _oranje,
                        fontWeight: FontWeight.w800,
                        height: 1.35,
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
            if (heeftOnopgeslagen && actief != null)
              OutlinedButton(
                onPressed: () =>
                    Navigator.pop(dialogContext, _WerkversieKeuze.opslaan),
                child: Text('Opslaan in Offerte ${actief.versieNummer}'),
              ),
            if (heeftOnopgeslagen)
              OutlinedButton(
                onPressed: () => Navigator.pop(
                  dialogContext,
                  _WerkversieKeuze.opslaanAlsNieuw,
                ),
                child: const Text('Opslaan als nieuwe offerte'),
              ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _groen),
              onPressed: () =>
                  Navigator.pop(dialogContext, _WerkversieKeuze.openen),
              child: Text(
                heeftOnopgeslagen
                    ? 'Wijzigingen negeren en openen'
                    : 'Offerte ${versie.versieNummer} openen',
              ),
            ),
          ],
        );
      },
    );

    if (keuze == null || keuze == _WerkversieKeuze.annuleren || !mounted) {
      return;
    }

    if (keuze == _WerkversieKeuze.opslaan) {
      final bewaard = await _bewaarHuidigeVariant();
      if (bewaard == null || !mounted) return;
    } else if (keuze == _WerkversieKeuze.opslaanAlsNieuw) {
      final bewaard = await _bewaarAlsNieuweVariant();
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
    if (!versie.isVariant || versie.isOndertekend) return;

    if (!_isArchief && _actieveVariant?.id == versie.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Offerte ${versie.versieNummer} is momenteel geopend. Open eerst '
            'een andere offertevariant voordat u deze verwijdert.',
          ),
          backgroundColor: _oranje,
        ),
      );
      return;
    }

    final ondertekende = _versieService.ondertekendeMomentopnamesVoorVariant(
      versies: _versies,
      variantId: versie.id,
    );
    if (ondertekende.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${versie.offerteVariantLabel} heeft een ondertekende '
            'momentopname en kan niet worden verwijderd.',
          ),
          backgroundColor: _oranje,
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
            'Offerte verwijderen?',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            '${versie.offerteVariantLabel} wordt definitief verwijderd.\n\n'
            'Deze actie kan niet ongedaan worden gemaakt. Een offertevariant '
            'met een ondertekende momentopname kan nooit worden gewist.',
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
              child: const Text('Offerte verwijderen'),
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
          content: Text('${versie.offerteVariantLabel} is verwijderd.'),
          backgroundColor: _groen,
        ),
      );
    } catch (fout) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Offerte verwijderen is niet gelukt.\n$fout'),
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
      var titelhoofd = _versieService.titelhoofdVan(versie);
      if (versie.isVariant) {
        titelhoofd = titelhoofd.metActieveOfferteVariant(
          versieId: versie.id,
          versieNummer: versie.versieNummer,
        );
      } else if (versie.isOndertekend && versie.versieNummer > 0) {
        titelhoofd = titelhoofd.copyWith(
          offerteVersie:
              OpmetingProjectTitelhoofd.offerteVersieVoorVariantNummer(
                versie.versieNummer,
              ),
        );
      }
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
          content: Text('Deze offerte kon niet worden geopend.\n$fout'),
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
      huidigTitelhoofd: _actiefTitelhoofd,
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
            'Vergelijk met Offerte ${versie.versieNummer}',
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
                              'opgeslagen offerte.',
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

  List<OfferteVersieModel> get _losseOndertekendeMomentopnames {
    final varianten = _varianten;
    final resultaat =
        _versies.where((versie) {
          if (!versie.isOndertekend) return false;
          return !varianten.any(
            (variant) => versie.hoortBijVariant(
              variant.id,
              variantNummer: variant.versieNummer,
            ),
          );
        }).toList()..sort((eerste, tweede) {
          final nummer = tweede.versieNummer.compareTo(eerste.versieNummer);
          if (nummer != 0) return nummer;
          return tweede.opgeslagenOp.compareTo(eerste.opgeslagenOp);
        });
    return resultaat;
  }

  Widget _bouwVariantKaart(
    BuildContext dialogContext,
    OfferteVersieModel variant,
  ) {
    final ondertekende = _versieService.ondertekendeMomentopnamesVoorVariant(
      versies: _versies,
      variantId: variant.id,
    );
    final isActief = !_isArchief && _actieveVariant?.id == variant.id;
    final komtOvereen = variant.inhoudSignatuur == _huidigeInhoudSignatuur;
    final heeftHandtekening = ondertekende.isNotEmpty;
    final heeftActueleHandtekening = ondertekende.any(
      (snapshot) => snapshot.inhoudSignatuur == variant.inhoudSignatuur,
    );
    final statusKleur = heeftActueleHandtekening ? _groen : _oranje;
    final statusAchtergrond = heeftActueleHandtekening
        ? const Color(0xFFE7F6EC)
        : const Color(0xFFFFF7ED);
    final statusTekst = heeftActueleHandtekening
        ? 'Ondertekend'
        : heeftHandtekening
        ? 'Gewijzigd na ondertekening'
        : 'Bewerkbaar';
    final kanVerwijderen = variant.isVariant && !heeftHandtekening && !isActief;

    return Container(
      padding: const EdgeInsets.fromLTRB(13, 11, 7, 11),
      decoration: BoxDecoration(
        color: isActief ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActief ? const Color(0xFF86D39D) : _rand),
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
              border: Border.all(color: statusKleur.withValues(alpha: 0.28)),
            ),
            child: Icon(
              heeftActueleHandtekening
                  ? Icons.verified_outlined
                  : heeftHandtekening
                  ? Icons.edit_note_rounded
                  : Icons.description_outlined,
              color: statusKleur,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        variant.offerteVariantLabel,
                        style: const TextStyle(
                          color: _tekstDonker,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusAchtergrond,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        statusTekst,
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
                  'Laatst opgeslagen ${_formatteerDatumTijd(variant.opgeslagenOp)} '
                  '· ${_formatteerEuro(variant.totaalInclusiefBtw)}',
                  style: const TextStyle(color: _tekstGrijs, fontSize: 12),
                ),
                if (variant.omschrijving.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    variant.omschrijving.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _tekstDonker, fontSize: 11.5),
                  ),
                ],
                if (variant.bronVersieNummer > 0 &&
                    variant.bronVersieId.trim() != variant.id) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    'Gemaakt vanuit Offerte ${variant.bronVersieNummer}',
                    style: const TextStyle(
                      color: _oranje,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                if (isActief) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    _heeftOnopgeslagenWijzigingen
                        ? 'Actieve offerte · niet-opgeslagen wijzigingen'
                        : 'Actieve offerte · volledig opgeslagen',
                    style: TextStyle(
                      color: _heeftOnopgeslagenWijzigingen ? _oranje : _groen,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ] else if (komtOvereen) ...<Widget>[
                  const SizedBox(height: 4),
                  const Text(
                    'Inhoud komt overeen met de geopende offerte',
                    style: TextStyle(
                      color: _groen,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                if (ondertekende.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  ...ondertekende.map((snapshot) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        Navigator.pop(dialogContext);
                        _openVersie(snapshot);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: <Widget>[
                            const Icon(
                              Icons.lock_outline_rounded,
                              color: _groen,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Ondertekend door ${snapshot.goedkeuring.naam} '
                                '· ${_formatteerDatumTijd(snapshot.goedkeuring.getekendOp)}',
                                style: const TextStyle(
                                  color: _groen,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.open_in_new_rounded,
                              size: 15,
                              color: _tekstGrijs,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
          PopupMenuButton<_VersieActie>(
            tooltip: 'Acties voor deze offerte',
            color: Colors.white,
            onSelected: (actie) {
              Navigator.pop(dialogContext);
              switch (actie) {
                case _VersieActie.openen:
                  _openVersie(variant);
                  break;
                case _VersieActie.ondertekenen:
                  _openVersie(variant, startOndertekenen: true);
                  break;
                case _VersieActie.vergelijken:
                  _vergelijkVersie(variant);
                  break;
                case _VersieActie.werkversie:
                  _openVersieAlsWerkversie(variant);
                  break;
                case _VersieActie.verwijderen:
                  _verwijderConceptVersie(variant);
                  break;
              }
            },
            itemBuilder: (_) => <PopupMenuEntry<_VersieActie>>[
              const PopupMenuItem<_VersieActie>(
                value: _VersieActie.openen,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.picture_as_pdf_outlined, color: _groen),
                  title: Text('PDF bekijken'),
                ),
              ),
              if (!_isArchief && widget.onOpenVersieAlsWerkversie != null)
                const PopupMenuItem<_VersieActie>(
                  value: _VersieActie.werkversie,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.edit_note_rounded, color: _groen),
                    title: Text('Openen en bewerken'),
                  ),
                ),
              const PopupMenuItem<_VersieActie>(
                value: _VersieActie.ondertekenen,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.draw_outlined, color: _groen),
                  title: Text('Openen en ondertekenen'),
                ),
              ),
              if (!_isArchief && !komtOvereen)
                const PopupMenuItem<_VersieActie>(
                  value: _VersieActie.vergelijken,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.compare_arrows_rounded, color: _oranje),
                    title: Text('Vergelijk met huidige'),
                  ),
                ),
              if (kanVerwijderen)
                const PopupMenuItem<_VersieActie>(
                  value: _VersieActie.verwijderen,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.delete_outline,
                      color: Color(0xFFDC2626),
                    ),
                    title: Text('Offerte verwijderen'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bouwLosseOndertekendeKaart(
    BuildContext dialogContext,
    OfferteVersieModel versie,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 11, 7, 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rand),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.lock_outline_rounded, color: _groen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Ondertekende Offerte ${versie.versieNummer} · oud archief',
                  style: const TextStyle(
                    color: _tekstDonker,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${versie.goedkeuring.naam} · '
                  '${_formatteerDatumTijd(versie.goedkeuring.getekendOp)} · '
                  '${_formatteerEuro(versie.totaalInclusiefBtw)}',
                  style: const TextStyle(color: _tekstGrijs, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Ondertekende PDF openen',
            onPressed: () {
              Navigator.pop(dialogContext);
              _openVersie(versie);
            },
            icon: const Icon(Icons.picture_as_pdf_outlined, color: _groen),
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
        final varianten = _varianten;
        final losseOndertekende = _losseOndertekendeMomentopnames;
        final totaalItems = varianten.length + losseOndertekende.length;

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
            width: math.min(780.0, scherm.width - 40).toDouble(),
            height: math.min(680.0, scherm.height - 56).toDouble(),
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
                      const Icon(Icons.folder_outlined, color: _groen),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Offertes (${varianten.length})',
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
                      : totaalItems == 0
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Er zijn nog geen offertevarianten opgeslagen. '
                              'Gebruik “Opslaan als nieuwe offerte” om de '
                              'eerste offerte te bewaren.',
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
                          itemCount: totaalItems,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, index) {
                            if (index < varianten.length) {
                              return _bouwVariantKaart(
                                dialogContext,
                                varianten[index],
                              );
                            }
                            return _bouwLosseOndertekendeKaart(
                              dialogContext,
                              losseOndertekende[index - varianten.length],
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
      if (_actiefArchiefIsConcept && !_isOndertekend) {
        achtergrond = const Color(0xFFFFF7ED);
        rand = const Color(0xFFFED7AA);
        kleur = _oranje;
        icoon = Icons.description_outlined;
        titel = widget.archiefVersieNaam.trim().isEmpty
            ? 'Offerte $nummer'
            : 'Offerte $nummer · ${widget.archiefVersieNaam}';
        uitleg =
            'Dit is de opgeslagen bewerkbare offertevariant. Bekijk hier de '
            'PDF of laat exact deze variant ondertekenen.';
      } else {
        achtergrond = const Color(0xFFE7F6EC);
        rand = const Color(0xFFB9E1C6);
        kleur = _groen;
        icoon = Icons.lock_outline_rounded;
        titel = 'Ondertekende Offerte $nummer';
        uitleg =
            'Dit is een onveranderbare ondertekende momentopname. Latere '
            'wijzigingen aan de bewerkbare offerte overschrijven ze nooit.';
      }
    } else if (_isOndertekend) {
      final nummer =
          _actieveVariant?.versieNummer ??
          _overeenkomendeOndertekendeVersie?.versieNummer ??
          _actiefTitelhoofd.offerteBronVersieNummer;
      achtergrond = const Color(0xFFE7F6EC);
      rand = const Color(0xFFB9E1C6);
      kleur = _groen;
      icoon = Icons.verified_rounded;
      titel = nummer > 0
          ? 'Ondertekende momentopname van Offerte $nummer'
          : 'Ondertekende offerte';
      uitleg =
          'De bewerkbare offertevariant blijft daarnaast afzonderlijk '
          'beschikbaar en kan later opnieuw worden geopend.';
    } else if (_heeftOnopgeslagenWijzigingen) {
      final actief = _actieveVariant;
      achtergrond = const Color(0xFFFFF7ED);
      rand = const Color(0xFFFED7AA);
      kleur = _oranje;
      icoon = Icons.edit_note_rounded;
      titel = actief == null
          ? 'Nog niet als offertevariant opgeslagen'
          : 'Offerte ${actief.versieNummer} bevat wijzigingen';
      uitleg = actief == null
          ? 'Gebruik “Opslaan als nieuwe offerte” om deze inhoud als eerste '
                'bewerkbare offertevariant te bewaren.'
          : 'Gebruik “Opslaan” om Offerte ${actief.versieNummer} bij te werken '
                'of “Opslaan als nieuwe” om een aparte variant te maken.';
    } else if (_actieveVariant != null) {
      final actief = _actieveVariant!;
      final ondertekendAantal = _ondertekendeVanActieveVariant.length;
      final actueleOndertekening = _actieveVariantHeeftActueleOndertekening;
      achtergrond = actueleOndertekening || ondertekendAantal == 0
          ? const Color(0xFFF0FDF4)
          : const Color(0xFFFFF7ED);
      rand = actueleOndertekening || ondertekendAantal == 0
          ? const Color(0xFFB9E1C6)
          : const Color(0xFFFED7AA);
      kleur = actueleOndertekening || ondertekendAantal == 0 ? _groen : _oranje;
      icoon = actueleOndertekening
          ? Icons.verified_outlined
          : ondertekendAantal > 0
          ? Icons.edit_note_rounded
          : Icons.check_circle_outline;
      titel = actueleOndertekening
          ? '${actief.offerteVariantLabel} is opgeslagen en ondertekend'
          : ondertekendAantal > 0
          ? '${actief.offerteVariantLabel} is gewijzigd na ondertekening'
          : '${actief.offerteVariantLabel} is opgeslagen';
      uitleg = ondertekendAantal == 0
          ? 'Deze offertevariant kan opnieuw worden geopend, aangepast of '
                'als basis voor een nieuwe offerte worden gebruikt.'
          : actueleOndertekening
          ? '$ondertekendAantal ondertekende momentopname${ondertekendAantal == 1 ? '' : 's'} '
                'blij${ondertekendAantal == 1 ? 'ft' : 'ven'} definitief bewaard.'
          : 'Er ${ondertekendAantal == 1 ? 'bestaat' : 'bestaan'} '
                '$ondertekendAantal eerdere ondertekende momentopname${ondertekendAantal == 1 ? '' : 's'}, '
                'maar de huidige opgeslagen inhoud is daarna gewijzigd.';
    } else if (_overeenkomendeConceptVersie != null) {
      final variant = _overeenkomendeConceptVersie!;
      achtergrond = const Color(0xFFF0FDF4);
      rand = const Color(0xFFB9E1C6);
      kleur = _groen;
      icoon = Icons.check_circle_outline;
      titel = 'Inhoud komt overeen met ${variant.offerteVariantLabel}';
      uitleg =
          'Open deze offertevariant via “Offertes” als u ze opnieuw actief '
          'wilt bewerken.';
    } else {
      achtergrond = const Color(0xFFF9FAFB);
      rand = _rand;
      kleur = _tekstGrijs;
      icoon = Icons.bookmark_add_outlined;
      titel = 'Nog geen offertevariant opgeslagen';
      uitleg =
          'Gebruik “Opslaan als nieuwe offerte” om deze offerte blijvend '
          'bewaarbaar en later opnieuw bewerkbaar te maken.';
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
    if (_isArchief && (_isOndertekend || !_magOndertekenen)) {
      return const SizedBox.shrink();
    }

    final toonTekst = MediaQuery.sizeOf(context).width >= 920;
    final icoon = _isOndertekend ? Icons.verified_rounded : Icons.draw_outlined;
    final label = _isArchief && _actiefArchiefIsConcept && !_isOndertekend
        ? 'Deze offerte ondertekenen'
        : _isOndertekend
        ? 'Ondertekend'
        : _ondertekendeVanActieveVariant.isNotEmpty
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

  Widget _bouwOpslaanActie(BuildContext context) {
    if (_isArchief) return const SizedBox.shrink();

    final actief = _actieveVariant;
    final toonTekst = MediaQuery.sizeOf(context).width >= 1180;
    final kanOpslaan = actief != null && !_versieBewarenBezig;
    final tooltip = actief == null
        ? 'Gebruik eerst Opslaan als nieuwe offerte'
        : _heeftOnopgeslagenWijzigingen
        ? 'Wijzigingen opslaan in Offerte ${actief.versieNummer}'
        : 'Offerte ${actief.versieNummer} is opgeslagen';

    if (!toonTekst) {
      return IconButton(
        tooltip: tooltip,
        onPressed: kanOpslaan ? () => _bewaarHuidigeVariant() : null,
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
                _heeftOnopgeslagenWijzigingen
                    ? Icons.save_outlined
                    : Icons.check_circle_outline,
              ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          disabledForegroundColor: const Color(0x99FFFFFF),
          backgroundColor: const Color(0x26FFFFFF),
          padding: const EdgeInsets.symmetric(horizontal: 13),
        ),
        onPressed: kanOpslaan ? () => _bewaarHuidigeVariant() : null,
        icon: _versieBewarenBezig
            ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save_outlined, size: 19),
        label: Text(
          actief == null ? 'Opslaan' : 'Opslaan · ${actief.versieNummer}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _bouwOpslaanAlsNieuweActie(BuildContext context) {
    if (_isArchief) return const SizedBox.shrink();

    final toonTekst = MediaQuery.sizeOf(context).width >= 1250;
    if (!toonTekst) {
      return IconButton(
        tooltip: 'Opslaan als nieuwe offerte',
        onPressed: _versieBewarenBezig ? null : () => _bewaarAlsNieuweVariant(),
        icon: const Icon(Icons.bookmark_add_outlined),
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
        onPressed: _versieBewarenBezig ? null : () => _bewaarAlsNieuweVariant(),
        icon: const Icon(Icons.bookmark_add_outlined, size: 19),
        label: const Text(
          'Opslaan als nieuwe',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _bouwVersiesActie(BuildContext context) {
    final toonTekst = MediaQuery.sizeOf(context).width >= 1080;

    if (!toonTekst) {
      return IconButton(
        tooltip: 'Offertes (${_varianten.length})',
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
                label: Text('${_varianten.length}'),
                isLabelVisible: _varianten.isNotEmpty,
                child: const Icon(Icons.folder_outlined),
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
            : const Icon(Icons.folder_outlined, size: 19),
        label: Text(
          'Offertes (${_varianten.length})',
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
    final titelhoofd = _actiefTitelhoofd;
    final posities = List<OpmetingOverzichtRaamItem>.unmodifiable(
      widget.posities,
    );
    final prijsPosities =
        OffertePrijsVoorAllePositiesService.projecteerOpPosities(
          posities: posities,
          regels: titelhoofd.prijsVoorAllePositiesRegels,
        );

    final pvcRaamTekeningen =
        await OffertePvcRaamTekeningService.maakTekeningen(posities);

    final data = OfferteDocumentData(
      klant: OfferteKlantgegevens.vanTitelhoofd(titelhoofd),
      offerteNummer: titelhoofd.samengesteldOffertenummer,
      offerteOmschrijving: titelhoofd.offerteOmschrijving,
      offerteDatum: datum,
      btwTarief: titelhoofd.btwTarief,
      kortingOmschrijving: titelhoofd.kortingOmschrijving,
      projectKleurBinnen: titelhoofd.projectKleurBinnen,
      projectKleurBuiten: titelhoofd.projectKleurBuiten,
      ralKleurToebehoren: titelhoofd.ralKleurToebehoren,
      kleurAfwijking: titelhoofd.kleurAfwijking,
      posities: prijsPosities,
      pvcRaamTekeningen: pvcRaamTekeningen,
    );

    _laatsteDocumentData = data;
    return OffertePdfService.bouwPdf(data, goedkeuring: _goedkeuring);
  }

  Widget? _bouwStatusBalk() {
    if (_isArchief) {
      final variant = _actiefArchiefIsConcept && !_isOndertekend;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        color: variant ? const Color(0xFFFFF7ED) : const Color(0xFFE7F6EC),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              variant ? Icons.description_outlined : Icons.lock_outline_rounded,
              color: variant ? _oranje : _groen,
              size: 18,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                variant
                    ? 'Offerte ${widget.archiefVersieNummer ?? ''} · '
                          '${widget.archiefVersieNaam} · opgeslagen '
                          'bewerkbare variant'
                    : 'Ondertekende Offerte '
                          '${widget.archiefVersieNummer ?? ''} · '
                          'onveranderbare momentopname',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: variant ? _oranje : _groen,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_isOndertekend) {
      final nummer =
          _actieveVariant?.versieNummer ??
          _actiefTitelhoofd.offerteBronVersieNummer;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        color: const Color(0xFFE7F6EC),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.verified_rounded, color: _groen, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                nummer > 0
                    ? 'Ondertekende momentopname van Offerte $nummer · '
                          'de bewerkbare variant blijft behouden.'
                    : 'Ondertekende offerte · onveranderbare momentopname.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _groen,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final actief = _actieveVariant;
    if (_heeftOnopgeslagenWijzigingen) {
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
                actief == null
                    ? 'Deze offerte is nog niet als variant opgeslagen · '
                          'gebruik Opslaan als nieuwe.'
                    : 'Offerte ${actief.versieNummer} bevat niet-opgeslagen '
                          'wijzigingen · gebruik Opslaan of Opslaan als nieuwe.',
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

    if (actief != null) {
      final heeftOndertekend = _ondertekendeVanActieveVariant.isNotEmpty;
      final actueleOndertekening = _actieveVariantHeeftActueleOndertekening;
      final waarschuwNaOndertekening =
          heeftOndertekend && !actueleOndertekening;
      final statusKleur = waarschuwNaOndertekening ? _oranje : _groen;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        color: waarschuwNaOndertekening
            ? const Color(0xFFFFF7ED)
            : const Color(0xFFF0FDF4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              actueleOndertekening
                  ? Icons.verified_outlined
                  : waarschuwNaOndertekening
                  ? Icons.edit_note_rounded
                  : Icons.check_circle_outline,
              color: statusKleur,
              size: 18,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                actueleOndertekening
                    ? '${actief.offerteVariantLabel} · opgeslagen · '
                          'huidige inhoud is ondertekend'
                    : waarschuwNaOndertekening
                    ? '${actief.offerteVariantLabel} · opgeslagen · '
                          'gewijzigd na eerdere ondertekening'
                    : '${actief.offerteVariantLabel} · opgeslagen',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: statusKleur,
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
      return _actiefArchiefIsConcept && !_isOndertekend
          ? 'Offerte ${widget.archiefVersieNummer ?? ''}'
          : 'Ondertekende Offerte ${widget.archiefVersieNummer ?? ''}';
    }
    if (_isOndertekend) {
      final nummer =
          _actieveVariant?.versieNummer ??
          _actiefTitelhoofd.offerteBronVersieNummer;
      return nummer > 0
          ? 'Offertevoorbeeld · Ondertekende Offerte $nummer'
          : 'Offertevoorbeeld · Ondertekend';
    }
    final actief = _actieveVariant;
    if (actief != null) {
      return _heeftOnopgeslagenWijzigingen
          ? 'Offertevoorbeeld · Offerte ${actief.versieNummer} gewijzigd'
          : 'Offertevoorbeeld · Offerte ${actief.versieNummer}';
    }
    return 'Offertevoorbeeld · Nieuwe offerte';
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
          _bouwOpslaanActie(context),
          _bouwOpslaanAlsNieuweActie(context),
          _bouwVersiesActie(context),
          _bouwOndertekenActie(context),
          _bouwMailActie(),
          IconButton(
            tooltip: 'Afdrukken op A4',
            onPressed: _afdrukkenBezig ? null : _drukA4Af,
            icon: _afdrukkenBezig
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.print_outlined),
          ),
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
                  pageFormats: const <String, PdfPageFormat>{
                    'A4': PdfPageFormat.a4,
                  },
                  dynamicLayout: false,
                  maxPageWidth: passendePaginaBreedte,
                  canChangePageFormat: false,
                  canChangeOrientation: false,
                  canDebug: false,
                  allowPrinting: false,
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

enum _OndertekenBewaarKeuze { annuleren, huidigeVariant, nieuweVariant }

enum _VersieActie { openen, ondertekenen, vergelijken, werkversie, verwijderen }

enum _WerkversieKeuze { annuleren, opslaan, opslaanAlsNieuw, openen }

class _ConceptVersieInvoer {
  const _ConceptVersieInvoer({required this.naam, required this.omschrijving});

  final String naam;
  final String omschrijving;
}
