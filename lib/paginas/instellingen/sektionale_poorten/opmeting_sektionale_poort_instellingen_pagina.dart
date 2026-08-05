// THIMACO-CONTROLE: SEKTIONALE-POORT-DOWNLOADSIGNAAL-FASE14-20260805
// THIMACO-CONTROLE: INSTELLINGEN-SEKTIONALE-POORTEN-KLEURENLIJST-20260729
import 'package:flutter/material.dart';

import '../../../helpers/app_storage.dart';
import '../../../helpers/opmeting/toebehoren/sektionale_poort/opmeting_sektionale_poort_instellingen_model.dart';
import '../../../helpers/sync/sync_navigatie_helper.dart';

class OpmetingSektionalePoortInstellingenPagina extends StatefulWidget {
  const OpmetingSektionalePoortInstellingenPagina({super.key});

  @override
  State<OpmetingSektionalePoortInstellingenPagina> createState() {
    return _OpmetingSektionalePoortInstellingenPaginaState();
  }
}

class _OpmetingSektionalePoortInstellingenPaginaState
    extends State<OpmetingSektionalePoortInstellingenPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekst = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  final TextEditingController _kleurenController = TextEditingController();

  bool _laden = true;
  bool _bewaren = false;
  bool _controllerWordtGeladen = false;
  bool _lokaleWijzigingen = false;
  bool _downloadHerladenUitgesteld = false;
  bool _herladenNaSync = false;
  bool _nogmaalsHerladenNaSync = false;

  int _laatsteVerwerkteDownloadVersie = 0;

  @override
  void initState() {
    super.initState();

    _laatsteVerwerkteDownloadVersie = SyncNavigatieHelper.downloadVersie.value;
    SyncNavigatieHelper.downloadVersie.addListener(_verwerkAchtergrondDownload);

    _kleurenController.addListener(_verwerkKleurenWijziging);

    _laad();
  }

  @override
  void dispose() {
    SyncNavigatieHelper.downloadVersie.removeListener(
      _verwerkAchtergrondDownload,
    );

    _kleurenController.removeListener(_verwerkKleurenWijziging);
    _kleurenController.dispose();

    super.dispose();
  }

  void _verwerkKleurenWijziging() {
    if (_controllerWordtGeladen) {
      return;
    }

    _lokaleWijzigingen = true;
  }

  void _verwerkAchtergrondDownload() {
    final nieuweVersie = SyncNavigatieHelper.downloadVersie.value;

    if (nieuweVersie <= _laatsteVerwerkteDownloadVersie) {
      return;
    }

    _laatsteVerwerkteDownloadVersie = nieuweVersie;

    if (_lokaleWijzigingen || _bewaren) {
      _downloadHerladenUitgesteld = true;
      _toonNieuweCloudversieMelding();
      return;
    }

    _herlaadNaSync();
  }

  void _toonNieuweCloudversieMelding() {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Er zijn nieuwere instellingen voor Sektionale poorten ontvangen. '
          'Je niet-opgeslagen wijzigingen blijven behouden.',
        ),
      ),
    );
  }

  Future<void> _herlaadNaSync() async {
    if (_herladenNaSync) {
      _nogmaalsHerladenNaSync = true;
      return;
    }

    _herladenNaSync = true;

    try {
      do {
        _nogmaalsHerladenNaSync = false;
        await _laad(toonLaden: false);
      } while (_nogmaalsHerladenNaSync && mounted);
    } finally {
      _herladenNaSync = false;
    }
  }

  Future<void> _laad({bool toonLaden = true}) async {
    if (toonLaden && mounted) {
      setState(() => _laden = true);
    }

    final instellingen =
        await AppStorage.laadOpmetingSektionalePoortInstellingen();

    if (!mounted) {
      return;
    }

    _controllerWordtGeladen = true;
    _kleurenController.text = instellingen.kleuren.join('\n');
    _controllerWordtGeladen = false;

    setState(() {
      _laden = false;
      _lokaleWijzigingen = false;
      _downloadHerladenUitgesteld = false;
    });
  }

  List<String> _parseLijst(String tekst) {
    final delen = tekst
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split(RegExp(r'[\n;\t]+'));

    final resultaat = <String>[];
    final gebruikt = <String>{};

    for (final deel in delen) {
      final waarde = deel.trim();

      if (waarde.isEmpty || !gebruikt.add(waarde.toLowerCase())) {
        continue;
      }

      resultaat.add(waarde);
    }

    return List<String>.unmodifiable(resultaat);
  }

  Future<void> _bewaar() async {
    if (_bewaren) {
      return;
    }

    setState(() => _bewaren = true);

    try {
      final instellingen = OpmetingSektionalePoortInstellingen(
        kleuren: _parseLijst(_kleurenController.text),
      ).metWijzigingsDatum();

      await AppStorage.bewaarOpmetingSektionalePoortInstellingen(instellingen);

      if (!mounted) {
        return;
      }

      setState(() => _lokaleWijzigingen = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Instellingen Sektionale poorten bewaard.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _bewaren = false);
      }
    }

    if (_downloadHerladenUitgesteld && mounted && !_lokaleWijzigingen) {
      _downloadHerladenUitgesteld = false;
      await _herlaadNaSync();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _achtergrond,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _tekst,
        elevation: 0,
        title: const Text(
          'Instellingen Sektionale poorten',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _groen),
              onPressed: _laden || _bewaren ? null : _bewaar,
              icon: _bewaren
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: const Text('Bewaren'),
            ),
          ),
        ],
      ),
      body: _laden
          ? const Center(child: CircularProgressIndicator(color: _groen))
          : ListView(
              padding: const EdgeInsets.all(18),
              children: <Widget>[
                const Text(
                  'Plak één kleur per regel. Lijsten uit Excel met tabs of '
                  'puntkomma’s worden eveneens verwerkt. Lege regels en '
                  'dubbele waarden worden verwijderd. Project kleur blijft '
                  'altijd als vaste keuze beschikbaar.',
                  style: TextStyle(
                    color: _tekstGrijs,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _rand),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text(
                        'Poortkleuren',
                        style: TextStyle(
                          color: _tekst,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Deze waarden verschijnen in het kleurkeuzemenu '
                        'van de fiche.',
                        style: TextStyle(
                          color: _tekstGrijs,
                          fontSize: 11.5,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _kleurenController,
                        minLines: 10,
                        maxLines: 20,
                        decoration: InputDecoration(
                          hintText: 'Eén kleur per regel',
                          filled: true,
                          fillColor: const Color(0xFFFCFCFD),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: _rand),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: _groen,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
