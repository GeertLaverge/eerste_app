// THIMACO-CONTROLE: NATIVE-IOS-MAILCOMPOSER-MET-BIJLAGEN-20260802
// THIMACO-CONTROLE: EEN-OPGESLAGEN-MAILBERICHT-PER-VERZENDING-20260802

import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../bibliotheek/bibliotheek_model.dart';
import '../../bibliotheek/bibliotheek_onedrive_service.dart';
import '../../bibliotheek/bibliotheek_repository.dart';
import '../offerte_goedkeuring_model.dart';
import '../offerte_mail_template_service.dart';
import '../offerte_pdf_model.dart';
import 'offerte_mail_tekst_model.dart';
import 'offerte_mail_teksten_repository.dart';
import 'offerte_mail_verzend_service.dart';

enum OfferteMailVerzendSoort { offerte, bevestiging }

class OfferteMailVerzendDialog extends StatefulWidget {
  const OfferteMailVerzendDialog({
    super.key,
    required this.data,
    required this.offerteBytes,
    required this.offerteBestandsnaam,
    required this.soort,
    this.goedkeuring,
  });

  final OfferteDocumentData data;
  final Uint8List offerteBytes;
  final String offerteBestandsnaam;
  final OfferteMailVerzendSoort soort;
  final OfferteGoedkeuring? goedkeuring;

  static Future<bool?> toon({
    required BuildContext context,
    required OfferteDocumentData data,
    required Uint8List offerteBytes,
    required String offerteBestandsnaam,
    required OfferteMailVerzendSoort soort,
    OfferteGoedkeuring? goedkeuring,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return OfferteMailVerzendDialog(
          data: data,
          offerteBytes: offerteBytes,
          offerteBestandsnaam: offerteBestandsnaam,
          soort: soort,
          goedkeuring: goedkeuring,
        );
      },
    );
  }

  @override
  State<OfferteMailVerzendDialog> createState() {
    return _OfferteMailVerzendDialogState();
  }
}

class _OfferteMailVerzendDialogState extends State<OfferteMailVerzendDialog> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  final BibliotheekOneDriveService _oneDriveService =
      BibliotheekOneDriveService();
  final OfferteMailVerzendService _verzendService = OfferteMailVerzendService();

  late final TextEditingController _ontvangerController;
  late final TextEditingController _onderwerpController;
  late final TextEditingController _berichtController;

  OfferteMailTekstenData _tekstenData = OfferteMailTekstenData.leeg();
  List<OfferteMailTekstBlok> _beschikbareBerichten =
      const <OfferteMailTekstBlok>[];
  List<_BeschikbareBibliotheekFolder> _folders =
      const <_BeschikbareBibliotheekFolder>[];
  final Set<String> _geselecteerdeFolderIds = <String>{};

  String? _geselecteerdBerichtId;
  bool _laden = true;
  bool _overzichtLadenMislukt = false;
  bool _sjabloonBewaren = false;
  bool _versturen = false;
  String _fout = '';
  String _status = '';
  double _voortgang = 0;

  @override
  void initState() {
    super.initState();
    _ontvangerController = TextEditingController(text: widget.data.klant.email);
    _onderwerpController = TextEditingController();
    _berichtController = TextEditingController();
    _laadOverzicht();
  }

  @override
  void dispose() {
    _ontvangerController.dispose();
    _onderwerpController.dispose();
    _berichtController.dispose();
    super.dispose();
  }

  ThemeData _groenThema(BuildContext context) {
    final basis = Theme.of(context);
    return basis.copyWith(
      colorScheme: basis.colorScheme.copyWith(
        primary: _groen,
        secondary: _groen,
        surface: Colors.white,
        onPrimary: Colors.white,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: _groen,
        selectionColor: Color(0x5534A764),
        selectionHandleColor: _groen,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        floatingLabelStyle: const TextStyle(color: _groen),
        prefixIconColor: _groen,
        suffixIconColor: _groen,
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
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: _groen),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _groen,
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _groen,
          side: const BorderSide(color: _groen),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          return states.contains(WidgetState.selected) ? _groen : Colors.white;
        }),
        checkColor: const WidgetStatePropertyAll<Color>(Colors.white),
        side: const BorderSide(color: _groen, width: 1.4),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: _groen),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        iconColor: _groen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: _rand),
        ),
      ),
    );
  }

  bool _isBeschikbaarVoorHuidigeVerzending(OfferteMailTekstBlok bericht) {
    return switch (widget.soort) {
      OfferteMailVerzendSoort.offerte => bericht.gebruik.beschikbaarVoorOfferte,
      OfferteMailVerzendSoort.bevestiging =>
        bericht.gebruik.beschikbaarVoorBevestiging,
    };
  }

  OfferteMailBerichtGebruik get _gebruikVoorHuidigeVerzending {
    return widget.soort == OfferteMailVerzendSoort.offerte
        ? OfferteMailBerichtGebruik.offerte
        : OfferteMailBerichtGebruik.bevestiging;
  }

  Future<void> _laadOverzicht() async {
    if (mounted) {
      setState(() {
        _laden = true;
        _overzichtLadenMislukt = false;
        _fout = '';
      });
    }

    try {
      final tekstenData = await OfferteMailTekstenRepository.laad();
      final bibliotheek = await BibliotheekRepository.laad();
      final beschikbareBerichten = tekstenData.blokken
          .where((bericht) {
            return bericht.actief &&
                bericht.tekst.trim().isNotEmpty &&
                _isBeschikbaarVoorHuidigeVerzending(bericht);
          })
          .toList(growable: false);
      final beschikbareFolders = _zoekGeldigeFolders(bibliotheek);

      _geselecteerdeFolderIds
        ..clear()
        ..addAll(beschikbareFolders.map((folder) => folder.folder.id));

      final geselecteerdId = beschikbareBerichten.isEmpty
          ? null
          : beschikbareBerichten.first.id;

      if (!mounted) return;
      setState(() {
        _tekstenData = tekstenData;
        _beschikbareBerichten = beschikbareBerichten;
        _folders = beschikbareFolders;
        _geselecteerdBerichtId = geselecteerdId;
        _laden = false;
      });

      if (geselecteerdId != null) {
        _laadBericht(geselecteerdId);
      }
    } catch (fout) {
      if (!mounted) return;
      setState(() {
        _laden = false;
        _overzichtLadenMislukt = true;
        _fout = 'Het verzendoverzicht kon niet worden opgebouwd.\n$fout';
      });
    }
  }

  List<_BeschikbareBibliotheekFolder> _zoekGeldigeFolders(
    BibliotheekData data,
  ) {
    final offerteFormulieren = <String>{};
    for (final positie in widget.data.offertePositiesVoorWeergave) {
      final sleutel = _normaliseerFormulierType(positie.formulierType);
      if (sleutel.isNotEmpty) offerteFormulieren.add(sleutel);
    }
    for (final positie in widget.data.offerteOptiePosities) {
      final sleutel = _normaliseerFormulierType(positie.formulierType);
      if (sleutel.isNotEmpty) offerteFormulieren.add(sleutel);
    }

    final resultaat = <_BeschikbareBibliotheekFolder>[];
    final toegevoegdeBestandIds = <String>{};

    for (final leverancier in data.leveranciers) {
      for (final schap in leverancier.schappen) {
        for (final folder in schap.folders) {
          if (!folder.heeftPdf || folder.id.trim().isEmpty) continue;

          final geldigeKoppelingen = folder.formulierKoppelingen
              .where((koppeling) {
                return offerteFormulieren.contains(
                  _normaliseerFormulierType(koppeling.formulierType),
                );
              })
              .toList(growable: false);

          final bestandSleutel = folder.onedriveItemId.trim().isEmpty
              ? folder.id.trim()
              : folder.onedriveItemId.trim();
          if (geldigeKoppelingen.isEmpty ||
              !toegevoegdeBestandIds.add(bestandSleutel)) {
            continue;
          }

          resultaat.add(
            _BeschikbareBibliotheekFolder(
              leverancierNaam: leverancier.naam,
              schapNaam: schap.naam,
              folder: folder,
              geldigeKoppelingen: geldigeKoppelingen,
            ),
          );
        }
      }
    }

    resultaat.sort((links, rechts) {
      final leverancierVergelijking = links.leverancierNaam
          .toLowerCase()
          .compareTo(rechts.leverancierNaam.toLowerCase());
      if (leverancierVergelijking != 0) return leverancierVergelijking;
      return links.folder.naam.toLowerCase().compareTo(
        rechts.folder.naam.toLowerCase(),
      );
    });
    return resultaat;
  }

  void _laadBericht(String berichtId) {
    OfferteMailTekstBlok? gekozen;
    for (final bericht in _beschikbareBerichten) {
      if (bericht.id == berichtId) {
        gekozen = bericht;
        break;
      }
    }
    if (gekozen == null) return;

    final ingevuld = OfferteMailTemplateService.vulIn(
      onderwerp: gekozen.onderwerp,
      bericht: gekozen.tekst,
      data: widget.data,
      goedkeuring: widget.goedkeuring,
    );
    _onderwerpController.text = ingevuld.onderwerp;
    _berichtController.text = ingevuld.bericht;
  }

  Future<void> _kiesBericht(String? berichtId) async {
    if (berichtId == null || berichtId == _geselecteerdBerichtId) return;
    setState(() => _geselecteerdBerichtId = berichtId);
    _laadBericht(berichtId);
  }

  OfferteMailTekstBlok? get _geselecteerdBericht {
    final id = _geselecteerdBerichtId;
    if (id == null) return null;
    for (final bericht in _tekstenData.blokken) {
      if (bericht.id == id) return bericht;
    }
    return null;
  }

  Future<void> _bewaarWijzigingen() async {
    final bestaand = _geselecteerdBericht;
    if (bestaand == null || _sjabloonBewaren) return;

    final onderwerp = _onderwerpController.text.trim();
    final tekst = _berichtController.text.trim();
    if (onderwerp.isEmpty || tekst.isEmpty) {
      _toonFout('Vul eerst een onderwerp en een volledig bericht in.');
      return;
    }

    setState(() => _sjabloonBewaren = true);
    try {
      final bijgewerkt = bestaand.metNieuweWijzigingsDatum(
        onderwerp: OfferteMailTemplateService.maakOnderwerpHerbruikbaar(
          onderwerp,
          widget.data,
          widget.goedkeuring,
        ),
        tekst: OfferteMailTemplateService.maakBerichtHerbruikbaar(
          tekst,
          widget.data,
          widget.goedkeuring,
        ),
      );
      final blokken = _tekstenData.blokken
          .map((item) {
            return item.id == bijgewerkt.id ? bijgewerkt : item;
          })
          .toList(growable: false);
      final nieuweData = _tekstenData.copyWith(blokken: blokken);
      await OfferteMailTekstenRepository.bewaar(nieuweData);
      if (!mounted) return;
      _werkLokaleBerichtenBij(nieuweData, geselecteerdId: bijgewerkt.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('“${bijgewerkt.naam}” is bijgewerkt.'),
          backgroundColor: _groen,
        ),
      );
    } catch (fout) {
      if (!mounted) return;
      _toonFout('Het bericht kon niet worden bewaard.\n$fout');
    } finally {
      if (mounted) setState(() => _sjabloonBewaren = false);
    }
  }

  Future<void> _bewaarAls() async {
    if (_sjabloonBewaren) return;
    final onderwerp = _onderwerpController.text.trim();
    final tekst = _berichtController.text.trim();
    if (onderwerp.isEmpty || tekst.isEmpty) {
      _toonFout('Vul eerst een onderwerp en een volledig bericht in.');
      return;
    }

    final naam = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Theme(
          data: _groenThema(dialogContext),
          child: const _OpslaanAlsDialog(),
        );
      },
    );
    if (!mounted || naam == null || naam.trim().isEmpty) return;

    setState(() => _sjabloonBewaren = true);
    try {
      final bestaand = _geselecteerdBericht;
      final nieuw = OfferteMailTekstBlok(
        id: 'mailbericht_${DateTime.now().microsecondsSinceEpoch}',
        naam: naam.trim(),
        onderwerp: OfferteMailTemplateService.maakOnderwerpHerbruikbaar(
          onderwerp,
          widget.data,
          widget.goedkeuring,
        ),
        tekst: OfferteMailTemplateService.maakBerichtHerbruikbaar(
          tekst,
          widget.data,
          widget.goedkeuring,
        ),
        gebruik: bestaand?.gebruik ?? _gebruikVoorHuidigeVerzending,
        actief: true,
        gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
      );
      final blokken = List<OfferteMailTekstBlok>.from(_tekstenData.blokken)
        ..add(nieuw);
      final nieuweData = _tekstenData.copyWith(blokken: blokken);
      await OfferteMailTekstenRepository.bewaar(nieuweData);
      if (!mounted) return;
      _werkLokaleBerichtenBij(nieuweData, geselecteerdId: nieuw.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('“${nieuw.naam}” is als nieuw bericht opgeslagen.'),
          backgroundColor: _groen,
        ),
      );
    } catch (fout) {
      if (!mounted) return;
      _toonFout('Opslaan als is niet gelukt.\n$fout');
    } finally {
      if (mounted) setState(() => _sjabloonBewaren = false);
    }
  }

  void _werkLokaleBerichtenBij(
    OfferteMailTekstenData data, {
    required String geselecteerdId,
  }) {
    final beschikbaar = data.blokken
        .where((bericht) {
          return bericht.actief &&
              bericht.tekst.trim().isNotEmpty &&
              _isBeschikbaarVoorHuidigeVerzending(bericht);
        })
        .toList(growable: false);
    setState(() {
      _tekstenData = data;
      _beschikbareBerichten = beschikbaar;
      _geselecteerdBerichtId = geselecteerdId;
    });
  }

  void _toonFout(String tekst) {
    if (!mounted) return;
    setState(() => _fout = tekst);
  }

  Future<void> _verstuurMail() async {
    if (_versturen) return;

    final ontvanger = _ontvangerController.text.trim();
    final onderwerp = _onderwerpController.text.trim();
    final bericht = _berichtController.text.trim();
    if (ontvanger.isEmpty || onderwerp.isEmpty || bericht.isEmpty) {
      _toonFout('Vul de ontvanger, het onderwerp en het bericht volledig in.');
      return;
    }

    setState(() {
      _versturen = true;
      _fout = '';
      _status = 'Documenten voorbereiden…';
      _voortgang = 0.02;
    });

    try {
      final bijlagen = <OfferteMailBijlage>[
        OfferteMailBijlage(
          bestandsnaam: _veiligePdfNaam(
            widget.offerteBestandsnaam,
            'Offerte.pdf',
          ),
          bytes: widget.offerteBytes,
        ),
      ];

      final geselecteerdeFolders = _folders
          .where((item) => _geselecteerdeFolderIds.contains(item.folder.id))
          .toList(growable: false);
      final gebruikteNamen = <String>{
        bijlagen.first.bestandsnaam.toLowerCase(),
      };

      for (var index = 0; index < geselecteerdeFolders.length; index++) {
        final item = geselecteerdeFolders[index];
        if (!mounted) return;
        setState(() {
          _status =
              'Folder ${index + 1} van ${geselecteerdeFolders.length} ophalen…';
          _voortgang =
              0.03 +
              (geselecteerdeFolders.isEmpty
                  ? 0
                  : (index / geselecteerdeFolders.length) * 0.17);
        });

        final bytes = await _oneDriveService.downloadPdf(
          item.folder.onedriveItemId,
        );
        var naam = _veiligePdfNaam(
          item.folder.bestandsnaam,
          '${item.folder.naam}.pdf',
        );
        naam = _maakUniekeBestandsnaam(naam, gebruikteNamen);
        gebruikteNamen.add(naam.toLowerCase());
        bijlagen.add(OfferteMailBijlage(bestandsnaam: naam, bytes: bytes));
      }

      await _verzendService.verstuur(
        ontvanger: ontvanger,
        onderwerp: onderwerp,
        bericht: bericht,
        bijlagen: bijlagen,
        onVoortgang: (status, voortgang) {
          if (!mounted) return;
          setState(() {
            _status = status;
            _voortgang = 0.20 + voortgang * 0.80;
          });
        },
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } on OfferteMailGeannuleerdException catch (fout) {
      if (!mounted) return;
      setState(() {
        _versturen = false;
        _status = '';
        _voortgang = 0;
        _fout = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(fout.bericht), backgroundColor: _groen),
      );
    } catch (fout) {
      if (!mounted) return;
      setState(() {
        _versturen = false;
        _status = '';
        _voortgang = 0;
        _fout = fout is OfferteMailVerzendException
            ? fout.bericht
            : 'Het iPad-mailvenster kon niet worden geopend.\n$fout';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scherm = MediaQuery.sizeOf(context);

    return Theme(
      data: _groenThema(context),
      child: Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        insetPadding: const EdgeInsets.all(18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: (scherm.width - 36).clamp(300.0, 980.0).toDouble(),
          height: (scherm.height - 36).clamp(420.0, 880.0).toDouble(),
          child: Column(
            children: <Widget>[
              _bouwKop(),
              const Divider(height: 1, color: _rand),
              Expanded(child: _bouwInhoud()),
              const Divider(height: 1, color: _rand),
              _bouwVoet(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bouwKop() {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _lichtGroen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.outgoing_mail, color: _groen),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              widget.soort == OfferteMailVerzendSoort.offerte
                  ? 'Offerte versturen'
                  : 'Bevestiging versturen',
              style: const TextStyle(
                color: _tekstDonker,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Sluiten',
            onPressed: _versturen ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: _tekstDonker),
          ),
        ],
      ),
    );
  }

  Widget _bouwInhoud() {
    if (_laden) {
      return const Center(child: CircularProgressIndicator(color: _groen));
    }

    if (_overzichtLadenMislukt) {
      return _bouwGroteFout();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _SectieKaart(
            titel: 'E-mailbericht',
            icoon: Icons.email_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextField(
                  controller: _ontvangerController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Aan',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                if (_beschikbareBerichten.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _lichtGroen,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: const Color(0xFFB9E0C7)),
                    ),
                    child: const Text(
                      'Er is geen actief opgeslagen bericht voor dit '
                      'verzendmoment. Vul hieronder een bericht in en gebruik '
                      '“Opslaan als” om het later opnieuw te gebruiken.',
                      style: TextStyle(
                        color: _tekstDonker,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    key: ValueKey<String?>(_geselecteerdBerichtId),
                    initialValue: _geselecteerdBerichtId,
                    dropdownColor: Colors.white,
                    decoration: const InputDecoration(
                      labelText: 'Opgeslagen bericht',
                      prefixIcon: Icon(Icons.text_snippet_outlined),
                    ),
                    items: _beschikbareBerichten
                        .map((bericht) {
                          return DropdownMenuItem<String>(
                            value: bericht.id,
                            child: Text(
                              bericht.naam,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        })
                        .toList(growable: false),
                    onChanged: _versturen ? null : _kiesBericht,
                  ),
                const SizedBox(height: 10),
                TextField(
                  controller: _onderwerpController,
                  decoration: const InputDecoration(
                    labelText: 'Onderwerp',
                    prefixIcon: Icon(Icons.subject_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _berichtController,
                  minLines: 12,
                  maxLines: 22,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Bericht',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: <Widget>[
                    OutlinedButton.icon(
                      onPressed:
                          _versturen ||
                              _sjabloonBewaren ||
                              _geselecteerdBericht == null
                          ? null
                          : _bewaarWijzigingen,
                      icon: _sjabloonBewaren
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined, size: 18),
                      label: const Text('Opslaan'),
                    ),
                    FilledButton.icon(
                      onPressed: _versturen || _sjabloonBewaren
                          ? null
                          : _bewaarAls,
                      icon: const Icon(Icons.save_as_outlined, size: 18),
                      label: const Text('Opslaan als'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectieKaart(
            titel: 'Documenten en folders',
            icoon: Icons.attach_file_rounded,
            child: _bouwDocumentKeuzes(),
          ),
          if (_fout.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE8E8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF3B7B7)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFB91C1C),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _fout,
                      style: const TextStyle(
                        color: Color(0xFFB91C1C),
                        fontWeight: FontWeight.w700,
                      ),
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

  Widget _bouwGroteFout() {
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
            Text(_fout, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _laadOverzicht,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Opnieuw proberen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bouwDocumentKeuzes() {
    return Column(
      children: <Widget>[
        CheckboxListTile(
          value: true,
          activeColor: _groen,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          secondary: const Icon(Icons.picture_as_pdf_outlined, color: _groen),
          title: const Text(
            'Offerte-PDF',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          subtitle: Text(widget.offerteBestandsnaam),
          onChanged: null,
        ),
        const Divider(height: 1, color: _rand),
        if (_folders.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 13),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Er zijn geen bibliotheekfolders gekoppeld aan de '
                'opmeetfiches in deze offerte.',
                style: TextStyle(color: _tekstGrijs),
              ),
            ),
          )
        else
          ..._folders.map((item) {
            final geselecteerd = _geselecteerdeFolderIds.contains(
              item.folder.id,
            );
            return CheckboxListTile(
              value: geselecteerd,
              activeColor: _groen,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              secondary: const Icon(Icons.menu_book_outlined, color: _groen),
              title: Text(
                item.folder.naam,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                '${item.leverancierNaam} · ${item.schapNaam}\n'
                '${item.geldigeKoppelingen.map((koppeling) => koppeling.label).join(' · ')}',
              ),
              isThreeLine: true,
              onChanged: _versturen
                  ? null
                  : (waarde) {
                      setState(() {
                        if (waarde == true) {
                          _geselecteerdeFolderIds.add(item.folder.id);
                        } else {
                          _geselecteerdeFolderIds.remove(item.folder.id);
                        }
                      });
                    },
            );
          }),
      ],
    );
  }

  Widget _bouwVoet() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 11, 16, 13),
      color: Colors.white,
      child: Column(
        children: <Widget>[
          if (_versturen) ...<Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    _status,
                    style: const TextStyle(
                      color: _tekstDonker,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${(_voortgang.clamp(0.0, 1.0) * 100).round()}%',
                  style: const TextStyle(
                    color: _groen,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            LinearProgressIndicator(
              value: _voortgang.clamp(0.0, 1.0).toDouble(),
              color: _groen,
              backgroundColor: _lichtGroen,
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${1 + _geselecteerdeFolderIds.length} document(en) geselecteerd',
                  style: const TextStyle(
                    color: _tekstGrijs,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: _versturen ? null : () => Navigator.pop(context),
                child: const Text('Annuleren'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _versturen ? null : _verstuurMail,
                icon: _versturen
                    ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                label: const Text(
                  'Openen in iPad Mail',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _normaliseerFormulierType(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  static String _veiligePdfNaam(String waarde, String fallback) {
    var naam = waarde.trim();
    if (naam.isEmpty) naam = fallback.trim();
    naam = naam.replaceAll(RegExp(r'[\\/:*?"<>|]+'), '_');
    if (!naam.toLowerCase().endsWith('.pdf')) naam = '$naam.pdf';
    return naam;
  }

  static String _maakUniekeBestandsnaam(
    String naam,
    Set<String> gebruikteNamen,
  ) {
    if (!gebruikteNamen.contains(naam.toLowerCase())) return naam;
    final basis = naam.toLowerCase().endsWith('.pdf')
        ? naam.substring(0, naam.length - 4)
        : naam;
    var teller = 2;
    var kandidaat = '$basis ($teller).pdf';
    while (gebruikteNamen.contains(kandidaat.toLowerCase())) {
      teller++;
      kandidaat = '$basis ($teller).pdf';
    }
    return kandidaat;
  }
}

class _OpslaanAlsDialog extends StatefulWidget {
  const _OpslaanAlsDialog();

  @override
  State<_OpslaanAlsDialog> createState() => _OpslaanAlsDialogState();
}

class _OpslaanAlsDialogState extends State<_OpslaanAlsDialog> {
  String _naam = '';
  String _fout = '';

  void _bewaar() {
    final naam = _naam.trim();
    if (naam.isEmpty) {
      setState(() => _fout = 'Geef een herkenbare naam in.');
      return;
    }
    Navigator.pop(context, naam);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text(
        'Bericht opslaan als',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              autofocus: true,
              initialValue: '',
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nieuwe naam',
                hintText: 'bv. Offerte na bespreking',
                prefixIcon: Icon(Icons.label_outline_rounded),
              ),
              onChanged: (waarde) => _naam = waarde,
              onFieldSubmitted: (_) => _bewaar(),
            ),
            if (_fout.isNotEmpty) ...<Widget>[
              const SizedBox(height: 9),
              Text(
                _fout,
                style: const TextStyle(
                  color: Color(0xFFB91C1C),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuleren'),
        ),
        FilledButton.icon(
          onPressed: _bewaar,
          icon: const Icon(Icons.save_as_outlined),
          label: const Text('Opslaan als'),
        ),
      ],
    );
  }
}

class _BeschikbareBibliotheekFolder {
  const _BeschikbareBibliotheekFolder({
    required this.leverancierNaam,
    required this.schapNaam,
    required this.folder,
    required this.geldigeKoppelingen,
  });

  final String leverancierNaam;
  final String schapNaam;
  final BibliotheekFolder folder;
  final List<BibliotheekFormulierKoppeling> geldigeKoppelingen;
}

class _SectieKaart extends StatelessWidget {
  const _SectieKaart({
    required this.titel,
    required this.icoon,
    required this.child,
  });

  final String titel;
  final IconData icoon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 9,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F6EC),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icoon, color: const Color(0xFF0B7A3B), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    titel,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
