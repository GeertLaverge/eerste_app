// THIMACO-CONTROLE: BIBLIOTHEEK-DOWNLOADSIGNAAL-FASE8-20260805
// THIMACO-CONTROLE: ALGEMENE-BIBLIOTHEEK-PAGINA-20260802

import 'package:flutter/material.dart';

import '../helpers/bibliotheek/bibliotheek_model.dart';
import '../helpers/bibliotheek/bibliotheek_repository.dart';
import '../helpers/sync/sync_navigatie_helper.dart';
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

  final TextEditingController _zoekController = TextEditingController();

  BibliotheekData _data = BibliotheekData.leeg();
  String? _geselecteerdeLeverancierId;
  bool _laden = true;
  bool _bewarenBezig = false;
  bool _herladenNaSync = false;
  bool _nogmaalsHerladenNaSync = false;
  int _laatsteVerwerkteDownloadVersie = 0;
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

    _laatsteVerwerkteDownloadVersie = SyncNavigatieHelper.downloadVersie.value;
    SyncNavigatieHelper.downloadVersie.addListener(_verwerkAchtergrondDownload);

    _laadBibliotheek();
  }

  @override
  void dispose() {
    SyncNavigatieHelper.downloadVersie.removeListener(
      _verwerkAchtergrondDownload,
    );
    _zoekController.dispose();
    super.dispose();
  }

  void _verwerkAchtergrondDownload() {
    final nieuweVersie = SyncNavigatieHelper.downloadVersie.value;

    if (nieuweVersie <= _laatsteVerwerkteDownloadVersie) {
      return;
    }

    _laatsteVerwerkteDownloadVersie = nieuweVersie;

    if (_herladenNaSync) {
      _nogmaalsHerladenNaSync = true;
      return;
    }

    _herlaadBibliotheekNaSync();
  }

  Future<void> _herlaadBibliotheekNaSync() async {
    if (_herladenNaSync) {
      _nogmaalsHerladenNaSync = true;
      return;
    }

    _herladenNaSync = true;

    try {
      do {
        _nogmaalsHerladenNaSync = false;
        await _laadBibliotheek(toonLaden: false);
      } while (_nogmaalsHerladenNaSync && mounted);
    } finally {
      _herladenNaSync = false;
    }
  }

  Future<void> _laadBibliotheek({bool toonLaden = true}) async {
    final vorigeSelectie = _geselecteerdeLeverancierId;

    if (toonLaden && mounted) {
      setState(() {
        _laden = true;
        _fout = '';
      });
    }

    try {
      final data = await BibliotheekRepository.laad();
      if (!mounted) return;

      setState(() {
        _data = data;
        final vorigeBestaatNog = data.leveranciers.any(
          (leverancier) => leverancier.id == vorigeSelectie,
        );
        _geselecteerdeLeverancierId = vorigeBestaatNog
            ? vorigeSelectie
            : data.leveranciers.isEmpty
            ? null
            : data.leveranciers.first.id;
        _laden = false;
        _fout = '';
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
  }) {
    return showDialog<_NaamEnOmschrijving>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _NaamEnOmschrijvingDialog(
          titel: titel,
          label: label,
          beginNaam: beginNaam,
          beginOmschrijving: beginOmschrijving,
          toonOmschrijving: toonOmschrijving,
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
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            titel,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(tekst),
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
              child: Text(bevestigTekst),
            ),
          ],
        );
      },
    );

    return resultaat == true;
  }

  Future<void> _voegLeverancierToe() async {
    final invoer = await _vraagNaam(
      titel: 'Leverancier toevoegen',
      label: 'Naam leverancier',
    );
    if (invoer == null) return;

    final leverancierId = _nieuwId('leverancier');
    final leverancier = BibliotheekLeverancier(
      id: leverancierId,
      naam: invoer.naam,
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
    );
    if (invoer == null) return;

    final leveranciers = _data.leveranciers
        .map((item) {
          return item.id == leverancier.id
              ? item.copyWith(naam: invoer.naam)
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
    return Scaffold(
      backgroundColor: _achtergrond,
      appBar: AppBar(
        backgroundColor: _groen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Bibliotheek',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: <Widget>[
          if (_bewarenBezig)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _groen,
              ),
              onPressed: _voegLeverancierToe,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Leverancier'),
            ),
          ),
        ],
      ),
      body: _bouwBody(),
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

    if (_data.leveranciers.isEmpty) {
      return _bouwLegeBibliotheek();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final breed = constraints.maxWidth >= 900;

        if (breed) {
          return Row(
            children: <Widget>[
              SizedBox(width: 260, child: _bouwLeveranciersPaneel()),
              const VerticalDivider(width: 1, color: _rand),
              Expanded(child: _bouwKast()),
            ],
          );
        }

        return Column(
          children: <Widget>[
            SizedBox(
              height: 112,
              child: _bouwLeveranciersPaneel(compact: true),
            ),
            const Divider(height: 1, color: _rand),
            Expanded(child: _bouwKast()),
          ],
        );
      },
    );
  }

  Widget _bouwLegeBibliotheek() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _rand),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.local_library_outlined, size: 54, color: _groen),
            const SizedBox(height: 16),
            const Text(
              'Maak uw eerste leverancierskast',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Voeg een leverancier toe. Daarna kunt u schappen en folders aanmaken, PDF’s uit OneDrive koppelen en klantenfiches aan folders verbinden.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _tekstGrijs, height: 1.4),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _groen),
              onPressed: _voegLeverancierToe,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Leverancier toevoegen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bouwLeveranciersPaneel({bool compact = false}) {
    final inhoud = ListView.separated(
      scrollDirection: compact ? Axis.horizontal : Axis.vertical,
      padding: const EdgeInsets.all(12),
      itemCount: _data.leveranciers.length,
      separatorBuilder: (_, __) =>
          SizedBox(width: compact ? 8 : 0, height: compact ? 0 : 8),
      itemBuilder: (context, index) {
        final leverancier = _data.leveranciers[index];
        final geselecteerd = leverancier.id == _geselecteerdeLeverancierId;

        return SizedBox(
          width: compact ? 210 : null,
          child: Material(
            color: geselecteerd ? _lichtGroen : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: geselecteerd ? _groen : _rand,
                width: geselecteerd ? 1.4 : 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                setState(() {
                  _geselecteerdeLeverancierId = leverancier.id;
                  _zoekController.clear();
                });
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: geselecteerd ? Colors.white : _achtergrond,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: _rand),
                      ),
                      child: const Icon(Icons.business_outlined, color: _groen),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            leverancier.naam,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${leverancier.schappen.length} schap(pen) · ${leverancier.aantalFolders} folder(s)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _tekstGrijs,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Leverancier beheren',
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
                            leading: Icon(Icons.edit_outlined),
                            title: Text('Naam wijzigen'),
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (compact) return inhoud;

    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Leveranciers',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          Expanded(child: inhoud),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _voegLeverancierToe,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Leverancier toevoegen'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwKast() {
    final leverancier = _geselecteerdeLeverancier;
    if (leverancier == null) return const SizedBox.shrink();

    return Column(
      children: <Widget>[
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _zoekController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Zoek folder bij ${leverancier.naam}',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _zoekController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _zoekController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                    filled: true,
                    fillColor: _achtergrond,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _rand),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _rand),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: _groen),
                onPressed: _voegSchapToe,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Schap'),
              ),
            ],
          ),
        ),
        Expanded(
          child: leverancier.schappen.isEmpty
              ? _bouwLegeKast(leverancier)
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: leverancier.schappen.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    return _bouwSchap(leverancier, leverancier.schappen[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _bouwLegeKast(BibliotheekLeverancier leverancier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.view_stream_outlined, size: 44, color: _groen),
            const SizedBox(height: 12),
            Text(
              '${leverancier.naam} heeft nog geen schappen.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _groen),
              onPressed: _voegSchapToe,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Schap toevoegen'),
            ),
          ],
        ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _rand),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 6, 8),
            child: Row(
              children: <Widget>[
                const Icon(Icons.view_stream_outlined, color: _groen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    schap.naam,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '${schap.folders.length} folder(s)',
                  style: const TextStyle(color: _tekstGrijs, fontSize: 12),
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Folder toevoegen',
                  onPressed: () => _voegFolderToe(leverancier, schap),
                  icon: const Icon(Icons.create_new_folder_outlined),
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
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Naam wijzigen'),
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
              ],
            ),
          ),
          Container(height: 10, color: const Color(0xFFD7C3A2)),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: folders.isEmpty
                ? _bouwLeegSchap(leverancier, schap, zoekenActief)
                : Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 8,
                    runSpacing: 10,
                    children: <Widget>[
                      if (!zoekenActief)
                        _bouwInvoegDoel(
                          schapId: schap.id,
                          index: 0,
                          compact: true,
                        ),
                      for (
                        var index = 0;
                        index < folders.length;
                        index++
                      ) ...<Widget>[
                        _bouwFolderKaart(
                          leverancier: leverancier,
                          schap: schap,
                          folder: folders[index],
                          slepenActief: !zoekenActief,
                        ),
                        if (!zoekenActief)
                          _bouwInvoegDoel(
                            schapId: schap.id,
                            index: index + 1,
                            compact: true,
                          ),
                      ],
                    ],
                  ),
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
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: Text(
            'Geen overeenkomende folders op dit schap.',
            style: TextStyle(color: _tekstGrijs),
          ),
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
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _voegFolderToe(leverancier, schap),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22),
            decoration: BoxDecoration(
              color: actief ? _lichtGroen : _achtergrond,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: actief ? _groen : _rand,
                width: actief ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: <Widget>[
                Icon(
                  actief
                      ? Icons.move_to_inbox_outlined
                      : Icons.create_new_folder_outlined,
                  color: _groen,
                ),
                const SizedBox(height: 6),
                Text(
                  actief
                      ? 'Laat los om de folder hier te plaatsen'
                      : 'Folder toevoegen',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bouwFolderKaart({
    required BibliotheekLeverancier leverancier,
    required BibliotheekSchap schap,
    required BibliotheekFolder folder,
    required bool slepenActief,
  }) {
    final kaart = _FolderKaart(
      folder: folder,
      onOpen: () => _openFolder(leverancier, schap, folder),
      onVerwijder: () => _verwijderFolder(leverancier, schap, folder),
    );

    if (!slepenActief) return kaart;

    return LongPressDraggable<_FolderSleepData>(
      data: _FolderSleepData(schapId: schap.id, folderId: folder.id),
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 170, child: kaart),
      ),
      childWhenDragging: Opacity(opacity: 0.28, child: kaart),
      child: kaart,
    );
  }

  Widget _bouwInvoegDoel({
    required String schapId,
    required int index,
    required bool compact,
  }) {
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
          width: actief ? 38 : (compact ? 8 : 14),
          height: 112,
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
}

class _FolderKaart extends StatelessWidget {
  const _FolderKaart({
    required this.folder,
    required this.onOpen,
    required this.onVerwijder,
  });

  final BibliotheekFolder folder;
  final VoidCallback onOpen;
  final VoidCallback onVerwijder;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF2A65A),
      elevation: 1,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(9),
        topRight: Radius.circular(9),
        bottomRight: Radius.circular(3),
        bottomLeft: Radius.circular(3),
      ),
      child: InkWell(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(9),
          topRight: Radius.circular(9),
          bottomRight: Radius.circular(3),
          bottomLeft: Radius.circular(3),
        ),
        onTap: onOpen,
        child: Container(
          width: 164,
          height: 112,
          padding: const EdgeInsets.fromLTRB(12, 10, 5, 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD3833A)),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(9),
              topRight: Radius.circular(9),
              bottomRight: Radius.circular(3),
              bottomLeft: Radius.circular(3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      folder.heeftPdf
                          ? Icons.folder_special_outlined
                          : Icons.folder_outlined,
                      size: 23,
                      color: const Color(0xFF5D3315),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      folder.naam,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF3E2412),
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      folder.klanten.isEmpty
                          ? (folder.heeftPdf ? 'PDF gekoppeld' : 'Nog geen PDF')
                          : '${folder.klanten.length} klant(en)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF6B3C1A),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                iconSize: 19,
                tooltip: 'Folder beheren',
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
                      leading: Icon(Icons.open_in_full_rounded),
                      title: Text('Openen'),
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
            ],
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
  });

  final String titel;
  final String label;
  final String beginNaam;
  final String beginOmschrijving;
  final bool toonOmschrijving;

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
      _NaamEnOmschrijving(
        naam: naam,
        omschrijving: _omschrijvingController.text.trim(),
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
  const _NaamEnOmschrijving({required this.naam, required this.omschrijving});

  final String naam;
  final String omschrijving;
}
