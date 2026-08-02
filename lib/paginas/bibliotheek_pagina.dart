// THIMACO-CONTROLE: BIBLIOTHEEK-VASTE-BOVENBALK-GROENE-MENUS-GELIJKE-BOEKHOOGTE-20260802

import 'package:flutter/material.dart';

import '../helpers/bibliotheek/bibliotheek_model.dart';
import '../helpers/bibliotheek/bibliotheek_repository.dart';
import 'bibliotheek_folder_pagina.dart';

class BibliotheekPagina extends StatefulWidget {
  const BibliotheekPagina({super.key});

  @override
  State<BibliotheekPagina> createState() => _BibliotheekPaginaState();
}

class _BibliotheekPaginaState extends State<BibliotheekPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  static const List<int> _leveranciersKleurWaarden = <int>[
    0xFF343A40,
    0xFF1F4E5F,
    0xFF315C46,
    0xFFF28A2E,
    0xFF8B3A3A,
    0xFF5A4A78,
    0xFF3F6B78,
    0xFF8A7356,
    0xFF68706D,
    0xFFB0A79C,
    0xFFD4C6B4,
    0xFF8795A1,
  ];

  final TextEditingController _zoekController = TextEditingController();

  BibliotheekData _data = BibliotheekData.leeg();
  String? _geselecteerdeLeverancierId;
  bool _laden = true;
  bool _bewarenBezig = false;
  String _fout = '';

  BibliotheekLeverancier? get _geselecteerdeLeverancier {
    final id = _geselecteerdeLeverancierId;
    if (id == null) return null;

    for (final leverancier in _data.leveranciers) {
      if (leverancier.id == id) return leverancier;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _laadBibliotheek();
  }

  @override
  void dispose() {
    _zoekController.dispose();
    super.dispose();
  }

  Future<void> _laadBibliotheek() async {
    setState(() {
      _laden = true;
      _fout = '';
    });

    try {
      final data = await BibliotheekRepository.laad();
      if (!mounted) return;

      setState(() {
        _data = data;
        _geselecteerdeLeverancierId = data.leveranciers.isEmpty
            ? null
            : data.leveranciers.first.id;
        _laden = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _laden = false;
        _fout = e.toString();
      });
    }
  }

  Future<void> _bewaarData(BibliotheekData nieuweData) async {
    setState(() {
      _data = nieuweData;
      _bewarenBezig = true;
    });

    try {
      await BibliotheekRepository.bewaar(nieuweData);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bibliotheek kon niet worden bewaard: $e'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _bewarenBezig = false);
      }
    }
  }

  String _nieuwId(String prefix) {
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}';
  }

  Future<_NaamEnOmschrijving?> _vraagNaam({
    required String titel,
    required String label,
    String beginNaam = '',
    String beginOmschrijving = '',
    bool toonOmschrijving = false,
    bool toonKleur = false,
    int beginKleurWaarde = 0xFF343A40,
  }) {
    return showDialog<_NaamEnOmschrijving>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Theme(
          data: _bouwGroenThema(dialogContext),
          child: _NaamEnOmschrijvingDialog(
            titel: titel,
            label: label,
            beginNaam: beginNaam,
            beginOmschrijving: beginOmschrijving,
            toonOmschrijving: toonOmschrijving,
            toonKleur: toonKleur,
            beginKleurWaarde: beginKleurWaarde,
          ),
        );
      },
    );
  }

  Future<bool> _bevestig({
    required String titel,
    required String tekst,
    String bevestigTekst = 'Verwijderen',
  }) async {
    final resultaat = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Theme(
          data: _bouwGroenThema(dialogContext),
          child: AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              titel,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            content: Text(tekst),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(foregroundColor: _groen),
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Annuleren'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                ),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(bevestigTekst),
              ),
            ],
          ),
        );
      },
    );

    return resultaat == true;
  }

  Future<void> _voegLeverancierToe() async {
    final invoer = await _vraagNaam(
      titel: 'Leverancier toevoegen',
      label: 'Naam leverancier',
      toonKleur: true,
      beginKleurWaarde:
          _leveranciersKleurWaarden[_data.leveranciers.length %
              _leveranciersKleurWaarden.length],
    );
    if (invoer == null) return;

    final leverancierId = _nieuwId('leverancier');
    final leverancier = BibliotheekLeverancier(
      id: leverancierId,
      naam: invoer.naam,
      kleurWaarde: invoer.kleurWaarde,
      schappen: <BibliotheekSchap>[
        BibliotheekSchap(
          id: _nieuwId('schap'),
          naam: 'Schap 1',
          folders: const <BibliotheekFolder>[],
        ),
      ],
    );

    _geselecteerdeLeverancierId = leverancierId;
    await _bewaarData(
      _data.copyWith(
        leveranciers: <BibliotheekLeverancier>[
          ..._data.leveranciers,
          leverancier,
        ],
      ),
    );
  }

  Future<void> _wijzigLeverancier(BibliotheekLeverancier leverancier) async {
    final invoer = await _vraagNaam(
      titel: 'Leverancier wijzigen',
      label: 'Naam leverancier',
      beginNaam: leverancier.naam,
      toonKleur: true,
      beginKleurWaarde: leverancier.kleurWaarde,
    );
    if (invoer == null) return;

    final leveranciers = _data.leveranciers
        .map((item) {
          return item.id == leverancier.id
              ? item.copyWith(
                  naam: invoer.naam,
                  kleurWaarde: invoer.kleurWaarde,
                )
              : item;
        })
        .toList(growable: false);

    await _bewaarData(_data.copyWith(leveranciers: leveranciers));
  }

  Future<void> _verwijderLeverancier(BibliotheekLeverancier leverancier) async {
    final akkoord = await _bevestig(
      titel: 'Leverancier verwijderen?',
      tekst: leverancier.aantalFolders == 0
          ? 'De leverancier “${leverancier.naam}” en alle schappen worden verwijderd.'
          : 'De leverancier “${leverancier.naam}” bevat ${leverancier.aantalFolders} folder(s). De leverancier, alle schappen en alle folders worden verwijderd.',
    );
    if (!akkoord) return;

    final leveranciers = _data.leveranciers
        .where((item) => item.id != leverancier.id)
        .toList(growable: false);

    _geselecteerdeLeverancierId = leveranciers.isEmpty
        ? null
        : leveranciers.first.id;
    await _bewaarData(_data.copyWith(leveranciers: leveranciers));
  }

  Future<void> _voegSchapToe() async {
    final leverancier = _geselecteerdeLeverancier;
    if (leverancier == null) return;

    final invoer = await _vraagNaam(
      titel: 'Schap toevoegen',
      label: 'Naam schap',
      beginNaam: 'Schap ${leverancier.schappen.length + 1}',
    );
    if (invoer == null) return;

    final nieuwSchap = BibliotheekSchap(
      id: _nieuwId('schap'),
      naam: invoer.naam,
      folders: const <BibliotheekFolder>[],
    );

    await _vervangLeverancier(
      leverancier.copyWith(
        schappen: <BibliotheekSchap>[...leverancier.schappen, nieuwSchap],
      ),
    );
  }

  Future<void> _wijzigSchap(
    BibliotheekLeverancier leverancier,
    BibliotheekSchap schap,
  ) async {
    final invoer = await _vraagNaam(
      titel: 'Schap wijzigen',
      label: 'Naam schap',
      beginNaam: schap.naam,
    );
    if (invoer == null) return;

    final schappen = leverancier.schappen
        .map((item) {
          return item.id == schap.id ? item.copyWith(naam: invoer.naam) : item;
        })
        .toList(growable: false);

    await _vervangLeverancier(leverancier.copyWith(schappen: schappen));
  }

  Future<void> _verwijderSchap(
    BibliotheekLeverancier leverancier,
    BibliotheekSchap schap,
  ) async {
    final akkoord = await _bevestig(
      titel: 'Schap verwijderen?',
      tekst: schap.folders.isEmpty
          ? 'Het schap “${schap.naam}” wordt verwijderd.'
          : 'Het schap “${schap.naam}” bevat ${schap.folders.length} folder(s). Het schap en deze folders worden verwijderd.',
    );
    if (!akkoord) return;

    final schappen = leverancier.schappen
        .where((item) => item.id != schap.id)
        .toList(growable: false);

    await _vervangLeverancier(leverancier.copyWith(schappen: schappen));
  }

  Future<void> _voegFolderToe(
    BibliotheekLeverancier leverancier,
    BibliotheekSchap schap,
  ) async {
    final invoer = await _vraagNaam(
      titel: 'Folder toevoegen',
      label: 'Naam folder',
      toonOmschrijving: true,
    );
    if (invoer == null) return;

    final folder = BibliotheekFolder(
      id: _nieuwId('folder'),
      naam: invoer.naam,
      omschrijving: invoer.omschrijving,
      onedriveItemId: '',
      bestandsnaam: '',
      webUrl: '',
      klanten: const <BibliotheekKlantKoppeling>[],
      gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
    );

    final nieuwSchap = schap.copyWith(
      folders: <BibliotheekFolder>[...schap.folders, folder],
    );
    await _vervangSchap(leverancier, nieuwSchap);
  }

  Future<void> _openFolder(
    BibliotheekLeverancier leverancier,
    BibliotheekSchap schap,
    BibliotheekFolder folder,
  ) async {
    final bijgewerkt = await Navigator.push<BibliotheekFolder>(
      context,
      MaterialPageRoute<BibliotheekFolder>(
        builder: (_) => BibliotheekFolderPagina(
          folder: folder,
          leverancierNaam: leverancier.naam,
          schapNaam: schap.naam,
        ),
      ),
    );

    if (!mounted || bijgewerkt == null) return;

    final nieuwSchap = schap.copyWith(
      folders: schap.folders
          .map((item) {
            return item.id == bijgewerkt.id ? bijgewerkt : item;
          })
          .toList(growable: false),
    );
    await _vervangSchap(leverancier, nieuwSchap);
  }

  Future<void> _verwijderFolder(
    BibliotheekLeverancier leverancier,
    BibliotheekSchap schap,
    BibliotheekFolder folder,
  ) async {
    final akkoord = await _bevestig(
      titel: 'Folder verwijderen?',
      tekst:
          'De folder “${folder.naam}” wordt van dit schap verwijderd. De PDF in OneDrive zelf wordt niet gewist.',
    );
    if (!akkoord) return;

    final nieuwSchap = schap.copyWith(
      folders: schap.folders
          .where((item) => item.id != folder.id)
          .toList(growable: false),
    );
    await _vervangSchap(leverancier, nieuwSchap);
  }

  Future<void> _vervangSchap(
    BibliotheekLeverancier leverancier,
    BibliotheekSchap nieuwSchap,
  ) async {
    final schappen = leverancier.schappen
        .map((schap) {
          return schap.id == nieuwSchap.id ? nieuwSchap : schap;
        })
        .toList(growable: false);
    await _vervangLeverancier(leverancier.copyWith(schappen: schappen));
  }

  Future<void> _vervangLeverancier(
    BibliotheekLeverancier nieuweLeverancier,
  ) async {
    final leveranciers = _data.leveranciers
        .map((leverancier) {
          return leverancier.id == nieuweLeverancier.id
              ? nieuweLeverancier
              : leverancier;
        })
        .toList(growable: false);
    await _bewaarData(_data.copyWith(leveranciers: leveranciers));
  }

  Future<void> _verplaatsFolder({
    required String bronSchapId,
    required String folderId,
    required String doelSchapId,
    required int doelIndex,
  }) async {
    final leverancier = _geselecteerdeLeverancier;
    if (leverancier == null || _zoekController.text.trim().isNotEmpty) return;

    BibliotheekFolder? folder;
    int bronIndex = -1;

    for (final schap in leverancier.schappen) {
      if (schap.id != bronSchapId) continue;
      bronIndex = schap.folders.indexWhere((item) => item.id == folderId);
      if (bronIndex >= 0) folder = schap.folders[bronIndex];
      break;
    }

    if (folder == null) return;

    final nieuweSchappen = leverancier.schappen
        .map((schap) {
          final folders = List<BibliotheekFolder>.from(schap.folders);

          if (schap.id == bronSchapId) {
            folders.removeWhere((item) => item.id == folderId);
          }

          if (schap.id == doelSchapId) {
            var invoegIndex = doelIndex;
            if (bronSchapId == doelSchapId && bronIndex < doelIndex) {
              invoegIndex--;
            }
            invoegIndex = invoegIndex.clamp(0, folders.length).toInt();
            folders.insert(invoegIndex, folder!);
          }

          return schap.copyWith(folders: folders);
        })
        .toList(growable: false);

    await _vervangLeverancier(leverancier.copyWith(schappen: nieuweSchappen));
  }

  @override
  Widget build(BuildContext context) {
    final leverancier = _geselecteerdeLeverancier;

    return Theme(
      data: _bouwGroenThema(context),
      child: Scaffold(
        backgroundColor: _achtergrond,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              _bouwBovenbalk(leverancier),
              Expanded(child: _bouwBody()),
            ],
          ),
        ),
      ),
    );
  }

  ThemeData _bouwGroenThema(BuildContext context) {
    final basis = Theme.of(context);
    final kleurenschema = basis.colorScheme.copyWith(
      primary: _groen,
      secondary: _groen,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    );

    return basis.copyWith(
      colorScheme: kleurenschema,
      primaryColor: _groen,
      focusColor: _groen.withValues(alpha: 0.12),
      hoverColor: _groen.withValues(alpha: 0.07),
      splashColor: _groen.withValues(alpha: 0.10),
      highlightColor: _groen.withValues(alpha: 0.06),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: _groen,
        selectionColor: Color(0x5534A764),
        selectionHandleColor: _groen,
      ),
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelStyle: const TextStyle(color: _groen),
        prefixIconColor: _groen,
        suffixIconColor: _groen,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
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
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        iconColor: _groen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: _rand),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: _groen),
    );
  }

  Widget _bouwBovenbalk(BibliotheekLeverancier? leverancier) {
    final titel = leverancier?.naam.trim() ?? '';

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: _groen,
          border: Border(bottom: BorderSide(color: Color(0xFF086A34))),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final heelSmal = constraints.maxWidth < 650;
            final middel = constraints.maxWidth < 920;
            final knopBreedte = heelSmal ? 42.0 : (middel ? 124.0 : 138.0);
            final actieBreedte =
                (knopBreedte * 2) + 8 + 16 + (_bewarenBezig ? 33 : 0);
            final titelBreedte = (constraints.maxWidth - (actieBreedte * 2))
                .clamp(80.0, constraints.maxWidth)
                .toDouble();

            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Center(
                  child: SizedBox(
                    width: titelBreedte,
                    child: Text(
                      titel.isEmpty ? 'Geen leverancier geselecteerd' : titel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: titel.isEmpty
                            ? Colors.white.withValues(alpha: 0.74)
                            : Colors.white,
                        fontSize: middel ? 15 : 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 4,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    tooltip: 'Home',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.home_rounded,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 7,
                  bottom: 7,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (_bewarenBezig) ...<Widget>[
                        const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      SizedBox(
                        width: knopBreedte,
                        height: 38,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _groen,
                            padding: EdgeInsets.symmetric(
                              horizontal: heelSmal ? 0 : 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          onPressed: _voegLeverancierToe,
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: heelSmal
                              ? const SizedBox.shrink()
                              : const Text(
                                  'Leverancier',
                                  style: TextStyle(fontWeight: FontWeight.w900),
                                ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: knopBreedte,
                        height: 38,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _groen,
                            disabledBackgroundColor: Colors.white.withValues(
                              alpha: 0.42,
                            ),
                            disabledForegroundColor: Colors.white.withValues(
                              alpha: 0.76,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: heelSmal ? 0 : 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          onPressed: leverancier == null ? null : _voegSchapToe,
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: heelSmal
                              ? const SizedBox.shrink()
                              : const Text(
                                  'Schap',
                                  style: TextStyle(fontWeight: FontWeight.w900),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _bouwBody() {
    if (_laden) {
      return const Center(child: CircularProgressIndicator(color: _groen));
    }

    if (_fout.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(height: 12),
              Text(_fout, textAlign: TextAlign.center),
              const SizedBox(height: 14),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: _groen),
                onPressed: _laadBibliotheek,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Opnieuw proberen'),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bredeKast = constraints.maxWidth >= 760;

        if (bredeKast) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(width: 292, child: _bouwLeveranciersBoekenkast()),
              Expanded(child: _bouwDocumentenBoekenkast()),
            ],
          );
        }

        return Column(
          children: <Widget>[
            SizedBox(height: 194, child: _bouwCompacteLeveranciersBoeken()),
            Expanded(child: _bouwDocumentenBoekenkast()),
          ],
        );
      },
    );
  }

  Widget _bouwLeveranciersBoekenkast() {
    final aantalPlanken = ((_data.leveranciers.length + 3) ~/ 4)
        .clamp(3, 100)
        .toInt();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0EFEB),
        border: Border(right: BorderSide(color: Color(0xFFD7D5CF))),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE8E6E1),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: const Color(0xFFD4D1CB)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.055),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            _bouwLedLijn(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
                itemCount: aantalPlanken,
                itemBuilder: (context, plankIndex) {
                  final begin = plankIndex * 4;
                  final einde = (begin + 4)
                      .clamp(0, _data.leveranciers.length)
                      .toInt();
                  final leveranciers = begin < _data.leveranciers.length
                      ? _data.leveranciers.sublist(begin, einde)
                      : const <BibliotheekLeverancier>[];

                  return _bouwLeveranciersPlank(
                    leveranciers: leveranciers,
                    beginIndex: begin,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bouwLeveranciersPlank({
    required List<BibliotheekLeverancier> leveranciers,
    required int beginIndex,
  }) {
    return SizedBox(
      height: 206,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  for (
                    var index = 0;
                    index < leveranciers.length;
                    index++
                  ) ...<Widget>[
                    _bouwLeveranciersBoek(
                      leveranciers[index],
                      beginIndex + index,
                    ),
                    if (index != leveranciers.length - 1)
                      const SizedBox(width: 7),
                  ],
                ],
              ),
            ),
          ),
          _bouwKastPlank(),
        ],
      ),
    );
  }

  Widget _bouwLedLijn() {
    return Container(
      height: 10,
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Colors.transparent,
            Colors.white.withValues(alpha: 0.95),
            Colors.transparent,
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.85),
            blurRadius: 14,
          ),
        ],
      ),
    );
  }

  Widget _bouwKastPlank() {
    return Container(
      height: 12,
      margin: const EdgeInsets.only(top: 6, bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD8D6D1),
        border: const Border(
          top: BorderSide(color: Color(0xFFF9F8F5), width: 2),
          bottom: BorderSide(color: Color(0xFFBDBAB4)),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }

  Widget _bouwLeveranciersBoek(BibliotheekLeverancier leverancier, int index) {
    final geselecteerd = leverancier.id == _geselecteerdeLeverancierId;
    final boekKleur = Color(leverancier.kleurWaarde);
    final tekstKleur = _contrasterendeTekst(boekKleur);
    final breedte = 52.0 + ((index % 3) * 4.0);
    const hoogte = 160.0;
    const boekRadius = BorderRadius.only(
      topLeft: Radius.circular(3),
      topRight: Radius.circular(4),
      bottomLeft: Radius.circular(2),
      bottomRight: Radius.circular(2),
    );

    return Material(
      color: boekKleur,
      elevation: geselecteerd ? 6 : 3,
      borderRadius: boekRadius,
      shadowColor: Colors.black.withValues(alpha: 0.34),
      child: InkWell(
        borderRadius: boekRadius,
        onTap: () {
          setState(() {
            _geselecteerdeLeverancierId = leverancier.id;
            _zoekController.clear();
          });
        },
        child: Container(
          width: breedte,
          height: hoogte,
          decoration: BoxDecoration(
            borderRadius: boekRadius,
            border: Border.all(
              color: geselecteerd
                  ? const Color(0xFFF28A2E)
                  : Colors.black.withValues(alpha: 0.17),
              width: geselecteerd ? 3 : 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.17),
                offset: const Offset(1, 0),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 28,
                child: PopupMenuButton<String>(
                  tooltip: 'Leverancier beheren',
                  padding: EdgeInsets.zero,
                  color: Colors.white,
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    size: 18,
                    color: tekstKleur.withValues(alpha: 0.86),
                  ),
                  onSelected: (actie) {
                    if (actie == 'wijzig') {
                      _wijzigLeverancier(leverancier);
                    } else if (actie == 'verwijder') {
                      _verwijderLeverancier(leverancier);
                    }
                  },
                  itemBuilder: (_) => const <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'wijzig',
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.palette_outlined, color: _groen),
                        title: Text(
                          'Naam en kleur wijzigen',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'verwijder',
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFDC2626),
                        ),
                        title: Text('Verwijderen'),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Center(
                      child: Text(
                        leverancier.naam.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: tekstKleur,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.55,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.08),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                child: Text(
                  '${leverancier.aantalFolders}',
                  style: TextStyle(
                    color: tekstKleur.withValues(alpha: 0.80),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bouwCompacteLeveranciersBoeken() {
    return Container(
      color: const Color(0xFFF0EFEB),
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: _data.leveranciers.isEmpty
                ? const SizedBox.shrink()
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _data.leveranciers.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 7),
                    itemBuilder: (context, index) {
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: _bouwLeveranciersBoek(
                          _data.leveranciers[index],
                          index,
                        ),
                      );
                    },
                  ),
          ),
          _bouwKastPlank(),
        ],
      ),
    );
  }

  Widget _bouwDocumentenBoekenkast() {
    final leverancier = _geselecteerdeLeverancier;

    return Container(
      color: const Color(0xFFF4F2EE),
      child: Column(
        children: <Widget>[
          _bouwKastWerkbalk(leverancier),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              decoration: BoxDecoration(
                color: const Color(0xFFEDEAE4),
                border: Border.all(color: const Color(0xFFD4D1CA)),
                borderRadius: BorderRadius.circular(5),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.055),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                children: <Widget>[
                  _bouwLedLijn(),
                  Expanded(
                    child: leverancier == null
                        ? _bouwLegeHoofdkast()
                        : leverancier.schappen.isEmpty
                        ? _bouwLegeKast(leverancier)
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
                            itemCount: leverancier.schappen.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return _bouwSchap(
                                leverancier,
                                leverancier.schappen[index],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwKastWerkbalk(BibliotheekLeverancier? leverancier) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: TextField(
        controller: _zoekController,
        enabled: leverancier != null,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: leverancier == null
              ? 'Voeg bovenaan een leverancier toe'
              : 'Zoek folder bij ${leverancier.naam}',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _zoekController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Zoekopdracht wissen',
                  onPressed: () {
                    _zoekController.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
          filled: true,
          fillColor: const Color(0xFFF8F7F4),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: _rand),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: _rand),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: _rand),
          ),
        ),
      ),
    );
  }

  Widget _bouwLegeKast(BibliotheekLeverancier leverancier) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _bouwLeegBasisSchap(
          tekst: index == 0
              ? 'Nog geen schappen. Gebruik + Schap bovenaan.'
              : null,
        );
      },
    );
  }

  Widget _bouwLegeHoofdkast() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _bouwLeegBasisSchap(
          tekst: index == 0 ? 'Voeg bovenaan een leverancier toe.' : null,
        );
      },
    );
  }

  Widget _bouwLeegBasisSchap({String? tekst}) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F2EC),
        border: Border.all(color: const Color(0xFFD7D3CB)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: tekst == null
                ? const SizedBox.shrink()
                : Center(
                    child: Text(
                      tekst,
                      style: const TextStyle(
                        color: _tekstGrijs,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          ),
          _bouwSchapPlank(),
        ],
      ),
    );
  }

  Widget _bouwSchap(
    BibliotheekLeverancier leverancier,
    BibliotheekSchap schap,
  ) {
    final zoekterm = _zoekController.text.trim().toLowerCase();
    final zoekenActief = zoekterm.isNotEmpty;
    final folders = zoekenActief
        ? schap.folders
              .where((folder) {
                return folder.naam.toLowerCase().contains(zoekterm) ||
                    folder.omschrijving.toLowerCase().contains(zoekterm) ||
                    folder.bestandsnaam.toLowerCase().contains(zoekterm);
              })
              .toList(growable: false)
        : schap.folders;

    return Container(
      height: 226,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F2EC),
        border: Border.all(color: const Color(0xFFD7D3CB)),
        borderRadius: BorderRadius.circular(4),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          _bouwSchapKop(leverancier, schap),
          Expanded(
            child: folders.isEmpty
                ? _bouwLeegSchap(leverancier, schap, zoekenActief)
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        if (!zoekenActief)
                          _bouwInvoegDoel(schapId: schap.id, index: 0),
                        for (
                          var index = 0;
                          index < folders.length;
                          index++
                        ) ...<Widget>[
                          _bouwFolderBoek(
                            leverancier: leverancier,
                            schap: schap,
                            folder: folders[index],
                            index: index,
                            slepenActief: !zoekenActief,
                          ),
                          if (!zoekenActief)
                            _bouwInvoegDoel(
                              schapId: schap.id,
                              index: index + 1,
                            ),
                        ],
                      ],
                    ),
                  ),
          ),
          _bouwSchapPlank(),
        ],
      ),
    );
  }

  Widget _bouwSchapKop(
    BibliotheekLeverancier leverancier,
    BibliotheekSchap schap,
  ) {
    return SizedBox(
      height: 43,
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 14),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFE3E0DA),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(3),
                bottomRight: Radius.circular(3),
              ),
              border: Border.all(color: const Color(0xFFC9C6C0)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              schap.naam.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF4B4C4C),
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '${schap.folders.length} folder(s)',
            style: const TextStyle(
              color: _tekstGrijs,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            tooltip: 'Folder toevoegen',
            onPressed: () => _voegFolderToe(leverancier, schap),
            icon: const Icon(
              Icons.library_add_outlined,
              size: 21,
              color: _groen,
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Schap beheren',
            onSelected: (actie) {
              if (actie == 'wijzig') {
                _wijzigSchap(leverancier, schap);
              } else if (actie == 'verwijder') {
                _verwijderSchap(leverancier, schap);
              }
            },
            itemBuilder: (_) => const <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'wijzig',
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.edit_outlined, color: _groen),
                  title: Text(
                    'Naam wijzigen',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: 'verwijder',
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFDC2626),
                  ),
                  title: Text('Verwijderen'),
                ),
              ),
            ],
          ),
          const SizedBox(width: 2),
        ],
      ),
    );
  }

  Widget _bouwSchapPlank() {
    return Container(
      height: 16,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFFF8F7F4),
            Color(0xFFD8D5CF),
            Color(0xFFC6C3BD),
          ],
        ),
        border: const Border(
          top: BorderSide(color: Colors.white, width: 2),
          bottom: BorderSide(color: Color(0xFFAAA7A2)),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
    );
  }

  Widget _bouwLeegSchap(
    BibliotheekLeverancier leverancier,
    BibliotheekSchap schap,
    bool zoekenActief,
  ) {
    if (zoekenActief) {
      return const Center(
        child: Text(
          'Geen overeenkomende folders op dit schap.',
          style: TextStyle(color: _tekstGrijs),
        ),
      );
    }

    return DragTarget<_FolderSleepData>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        _verplaatsFolder(
          bronSchapId: details.data.schapId,
          folderId: details.data.folderId,
          doelSchapId: schap.id,
          doelIndex: 0,
        );
      },
      builder: (context, kandidaten, _) {
        final actief = kandidaten.isNotEmpty;
        return Center(
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _voegFolderToe(leverancier, schap),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 280,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: actief
                    ? _lichtGroen
                    : Colors.white.withValues(alpha: 0.52),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: actief ? _groen : const Color(0xFFD4D1CA),
                  width: actief ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    actief
                        ? Icons.move_to_inbox_outlined
                        : Icons.library_add_outlined,
                    color: _groen,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    actief
                        ? 'Laat los om de folder hier te plaatsen'
                        : 'Folder op dit schap plaatsen',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _bouwFolderBoek({
    required BibliotheekLeverancier leverancier,
    required BibliotheekSchap schap,
    required BibliotheekFolder folder,
    required int index,
    required bool slepenActief,
  }) {
    final boek = _FolderBoek(
      folder: folder,
      kleur: _folderBoekKleur(folder, index),
      hoogte: 148,
      onOpen: () => _openFolder(leverancier, schap, folder),
      onVerwijder: () => _verwijderFolder(leverancier, schap, folder),
    );

    if (!slepenActief) return boek;

    return LongPressDraggable<_FolderSleepData>(
      data: _FolderSleepData(schapId: schap.id, folderId: folder.id),
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 136, child: boek),
      ),
      childWhenDragging: Opacity(opacity: 0.28, child: boek),
      child: boek,
    );
  }

  Widget _bouwInvoegDoel({required String schapId, required int index}) {
    return DragTarget<_FolderSleepData>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        _verplaatsFolder(
          bronSchapId: details.data.schapId,
          folderId: details.data.folderId,
          doelSchapId: schapId,
          doelIndex: index,
        );
      },
      builder: (context, kandidaten, _) {
        final actief = kandidaten.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: actief ? 36 : 12,
          height: 154,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: actief ? _lichtGroen : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: actief ? Border.all(color: _groen, width: 1.5) : null,
          ),
          child: actief
              ? const Icon(Icons.arrow_downward_rounded, color: _groen)
              : null,
        );
      },
    );
  }

  Color _folderBoekKleur(BibliotheekFolder folder, int index) {
    const kleuren = <Color>[
      Color(0xFF26384D),
      Color(0xFF34495E),
      Color(0xFF5A636B),
      Color(0xFFA7A39D),
      Color(0xFF777B7D),
      Color(0xFF3E454B),
      Color(0xFFBBB7B0),
      Color(0xFF6F7775),
    ];
    final basis = folder.id.hashCode.abs() + index;
    return kleuren[basis % kleuren.length];
  }

  Color _contrasterendeTekst(Color achtergrond) {
    return ThemeData.estimateBrightnessForColor(achtergrond) == Brightness.dark
        ? Colors.white
        : const Color(0xFF292D30);
  }
}

class _FolderBoek extends StatelessWidget {
  const _FolderBoek({
    required this.folder,
    required this.kleur,
    required this.hoogte,
    required this.onOpen,
    required this.onVerwijder,
  });

  final BibliotheekFolder folder;
  final Color kleur;
  final int hoogte;
  final VoidCallback onOpen;
  final VoidCallback onVerwijder;

  @override
  Widget build(BuildContext context) {
    final tekstKleur =
        ThemeData.estimateBrightnessForColor(kleur) == Brightness.dark
        ? Colors.white
        : const Color(0xFF2B2E30);

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Material(
        color: kleur,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.35),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(2),
          bottomRight: Radius.circular(2),
        ),
        child: InkWell(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(2),
            bottomRight: Radius.circular(2),
          ),
          onTap: onOpen,
          child: Container(
            width: 132,
            height: hoogte.toDouble(),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
                bottomLeft: Radius.circular(2),
                bottomRight: Radius.circular(2),
              ),
              border: Border.all(color: Colors.black.withValues(alpha: 0.14)),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 10,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.10),
                    border: Border(
                      right: BorderSide(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 3, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topRight,
                          child: PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            iconSize: 18,
                            tooltip: 'Folder beheren',
                            color: Colors.white,
                            icon: Icon(
                              Icons.more_vert_rounded,
                              color: tekstKleur.withValues(alpha: 0.82),
                            ),
                            onSelected: (actie) {
                              if (actie == 'open') {
                                onOpen();
                              } else if (actie == 'verwijder') {
                                onVerwijder();
                              }
                            },
                            itemBuilder: (_) => const <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'open',
                                child: ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    Icons.open_in_full_rounded,
                                    color: Color(0xFF0B7A3B),
                                  ),
                                  title: Text(
                                    'Openen',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'verwijder',
                                child: ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    Icons.delete_outline_rounded,
                                    color: Color(0xFFDC2626),
                                  ),
                                  title: Text('Verwijderen'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              folder.naam,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: tekstKleur,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                height: 1.18,
                              ),
                            ),
                          ),
                        ),
                        Icon(
                          folder.heeftPdf
                              ? Icons.picture_as_pdf_outlined
                              : Icons.menu_book_rounded,
                          size: 25,
                          color: tekstKleur.withValues(alpha: 0.90),
                        ),
                        if (folder.klanten.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 4),
                          Text(
                            '${folder.klanten.length} klant(en)',
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: tekstKleur.withValues(alpha: 0.72),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 4,
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.24),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FolderSleepData {
  const _FolderSleepData({required this.schapId, required this.folderId});

  final String schapId;
  final String folderId;
}

class _NaamEnOmschrijvingDialog extends StatefulWidget {
  const _NaamEnOmschrijvingDialog({
    required this.titel,
    required this.label,
    required this.beginNaam,
    required this.beginOmschrijving,
    required this.toonOmschrijving,
    required this.toonKleur,
    required this.beginKleurWaarde,
  });

  final String titel;
  final String label;
  final String beginNaam;
  final String beginOmschrijving;
  final bool toonOmschrijving;
  final bool toonKleur;
  final int beginKleurWaarde;

  @override
  State<_NaamEnOmschrijvingDialog> createState() {
    return _NaamEnOmschrijvingDialogState();
  }
}

class _NaamEnOmschrijvingDialogState extends State<_NaamEnOmschrijvingDialog> {
  static const Color _groen = Color(0xFF0B7A3B);

  late final TextEditingController _naamController;
  late final TextEditingController _omschrijvingController;
  String _fout = '';
  late int _kleurWaarde;

  @override
  void initState() {
    super.initState();
    _naamController = TextEditingController(text: widget.beginNaam);
    _omschrijvingController = TextEditingController(
      text: widget.beginOmschrijving,
    );
    _kleurWaarde = widget.beginKleurWaarde;
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
      _NaamEnOmschrijving(
        naam: naam,
        omschrijving: _omschrijvingController.text.trim(),
        kleurWaarde: _kleurWaarde,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        widget.titel,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _naamController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: widget.label,
                errorText: _fout.isEmpty ? null : _fout,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_fout.isNotEmpty) setState(() => _fout = '');
              },
              onSubmitted: (_) => _bewaar(),
            ),
            if (widget.toonKleur) ...<Widget>[
              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Kleur boekenrug',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 9),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: _BibliotheekPaginaState._leveranciersKleurWaarden
                    .map((waarde) {
                      final geselecteerd = waarde == _kleurWaarde;
                      final kleur = Color(waarde);
                      return InkWell(
                        borderRadius: BorderRadius.circular(5),
                        onTap: () => setState(() => _kleurWaarde = waarde),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: kleur,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: geselecteerd
                                  ? const Color(0xFFF28A2E)
                                  : const Color(0xFFD1D5DB),
                              width: geselecteerd ? 3 : 1,
                            ),
                            boxShadow: geselecteerd
                                ? <BoxShadow>[
                                    BoxShadow(
                                      color: const Color(
                                        0xFFF28A2E,
                                      ).withValues(alpha: 0.24),
                                      blurRadius: 7,
                                    ),
                                  ]
                                : null,
                          ),
                          child: geselecteerd
                              ? Icon(
                                  Icons.check_rounded,
                                  color:
                                      ThemeData.estimateBrightnessForColor(
                                            kleur,
                                          ) ==
                                          Brightness.dark
                                      ? Colors.white
                                      : const Color(0xFF20252A),
                                )
                              : null,
                        ),
                      );
                    })
                    .toList(growable: false),
              ),
            ],
            if (widget.toonOmschrijving) ...<Widget>[
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

class _NaamEnOmschrijving {
  const _NaamEnOmschrijving({
    required this.naam,
    required this.omschrijving,
    required this.kleurWaarde,
  });

  final String naam;
  final String omschrijving;
  final int kleurWaarde;
}
