// THIMACO-CONTROLE: BUITENJALOEZIE-DOWNLOADSIGNAAL-FASE11-20260805
// THIMACO-CONTROLE: BUITENJALOEZIE-INSTELLINGEN-KASTTABEL-165-185-20260803

import 'package:flutter/material.dart';

import '../../../helpers/app_storage.dart';
import '../../../helpers/opmeting/toebehoren/buitenjaloezie/opmeting_buitenjaloezie_instellingen_model.dart';
import '../../../helpers/opmeting/toebehoren/buitenjaloezie/opmeting_buitenjaloezie_model.dart';
import '../../../helpers/sync/sync_navigatie_helper.dart';

class OpmetingBuitenjaloezieInstellingenPagina extends StatefulWidget {
  const OpmetingBuitenjaloezieInstellingenPagina({super.key});

  @override
  State<OpmetingBuitenjaloezieInstellingenPagina> createState() {
    return _OpmetingBuitenjaloezieInstellingenPaginaState();
  }
}

class _OpmetingBuitenjaloezieInstellingenPaginaState
    extends State<OpmetingBuitenjaloezieInstellingenPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekst = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  final TextEditingController _kleurenController = TextEditingController();
  final TextEditingController _geleidersController = TextEditingController();
  final TextEditingController _bedieningenController = TextEditingController();
  final TextEditingController _kabelsController = TextEditingController();
  final TextEditingController _afschuiningController = TextEditingController();

  bool _laden = true;
  bool _bewaren = false;
  bool _controllersWordenGeladen = false;
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

    for (final controller in _controllers) {
      controller.addListener(_ververs);
    }

    _laad();
  }

  List<TextEditingController> get _controllers => <TextEditingController>[
    _kleurenController,
    _geleidersController,
    _bedieningenController,
    _kabelsController,
    _afschuiningController,
  ];

  @override
  void dispose() {
    SyncNavigatieHelper.downloadVersie.removeListener(
      _verwerkAchtergrondDownload,
    );

    for (final controller in _controllers) {
      controller.removeListener(_ververs);
      controller.dispose();
    }

    super.dispose();
  }

  void _ververs() {
    if (_controllersWordenGeladen) {
      return;
    }

    _lokaleWijzigingen = true;

    if (mounted) {
      setState(() {});
    }
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
          'Er zijn nieuwere Buitenjaloezie-instellingen ontvangen. '
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
        await AppStorage.laadOpmetingBuitenjaloezieInstellingen();
    if (!mounted) return;

    _controllersWordenGeladen = true;

    _kleurenController.text = instellingen.lamelkleuren
        .map((kleur) {
          final types = kleur.toegestaanVoor
              .map((type) => type.label)
              .join(',');
          return <String>[
            kleur.code,
            kleur.naam,
            kleur.hexKleur,
            types,
            kleur.optioneel ? 'ja' : 'neen',
          ].join('\t');
        })
        .join('\n');

    _geleidersController.text = instellingen.geleiders
        .map((geleider) {
          final types = geleider.toegestaanVoor
              .map((type) => type.label)
              .join(',');
          return <String>[
            geleider.code,
            geleider.breedteMm.toString(),
            geleider.diepteMm.toString(),
            types,
          ].join('\t');
        })
        .join('\n');

    _bedieningenController.text = instellingen.bedieningen.join('\n');
    _kabelsController.text = instellingen.motorkabelLengtes.join(', ');
    _afschuiningController.text = instellingen.afschuiningGraden.join(', ');

    _controllersWordenGeladen = false;

    setState(() {
      _laden = false;
      _lokaleWijzigingen = false;
      _downloadHerladenUitgesteld = false;
    });
  }

  Future<void> _bewaar() async {
    if (_bewaren) return;

    final kleuren = _parseKleuren();
    final geleiders = _parseGeleiders();
    final bedieningen = _parseNietLegeRegels(_bedieningenController.text);
    final kabels = _parseIntLijst(_kabelsController.text);
    final afschuining = _parseIntLijst(_afschuiningController.text);

    if (kleuren.isEmpty) {
      _toonFout('Voeg minstens één geldige lamelkleur toe.');
      return;
    }
    if (geleiders.isEmpty) {
      _toonFout('Voeg minstens één geldige geleider toe.');
      return;
    }
    if (bedieningen.isEmpty) {
      _toonFout('Voeg minstens één bediening toe.');
      return;
    }
    if (kabels.isEmpty) {
      _toonFout('Voeg minstens één motorkabellengte toe.');
      return;
    }
    if (afschuining.isEmpty) {
      _toonFout('Voeg minstens één afschuiningsgraad toe.');
      return;
    }

    setState(() => _bewaren = true);
    try {
      final instellingen = OpmetingBuitenjaloezieInstellingen(
        lamelkleuren: kleuren,
        geleiders: geleiders,
        bedieningen: bedieningen,
        motorkabelLengtes: kabels,
        afschuiningGraden: afschuining,
      ).metWijzigingsDatum();

      await AppStorage.bewaarOpmetingBuitenjaloezieInstellingen(instellingen);

      if (!mounted) return;
      setState(() => _lokaleWijzigingen = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _groen,
          content: Text(
            'Buitenjaloezieën bewaard: '
            '${kleuren.length} kleuren en ${geleiders.length} geleiders.',
          ),
        ),
      );
    } catch (fout) {
      _toonFout('Bewaren is niet gelukt: $fout');
    } finally {
      if (mounted) setState(() => _bewaren = false);
    }

    if (_downloadHerladenUitgesteld && mounted && !_lokaleWijzigingen) {
      _downloadHerladenUitgesteld = false;
      await _herlaadNaSync();
    }
  }

  Future<void> _herstelStandaard() async {
    final bevestigd = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Standaardtabellen herstellen?'),
          content: const Text(
            'Alle aangepaste kleuren, geleiders en keuzelijsten worden '
            'vervangen door de standaardwaarden.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuleren'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(backgroundColor: _groen),
              child: const Text('Herstellen'),
            ),
          ],
        );
      },
    );

    if (bevestigd != true || !mounted) return;

    const standaard = OpmetingBuitenjaloezieInstellingen();
    _kleurenController.text = standaard.lamelkleuren
        .map((kleur) {
          return <String>[
            kleur.code,
            kleur.naam,
            kleur.hexKleur,
            kleur.toegestaanVoor.map((type) => type.label).join(','),
            kleur.optioneel ? 'ja' : 'neen',
          ].join('\t');
        })
        .join('\n');
    _geleidersController.text = standaard.geleiders
        .map((geleider) {
          return <String>[
            geleider.code,
            geleider.breedteMm.toString(),
            geleider.diepteMm.toString(),
            geleider.toegestaanVoor.map((type) => type.label).join(','),
          ].join('\t');
        })
        .join('\n');
    _bedieningenController.text = standaard.bedieningen.join('\n');
    _kabelsController.text = standaard.motorkabelLengtes.join(', ');
    _afschuiningController.text = standaard.afschuiningGraden.join(', ');
  }

  List<OpmetingBuitenjaloezieLamelkleur> _parseKleuren() {
    final resultaat = <OpmetingBuitenjaloezieLamelkleur>[];
    final gebruikt = <String>{};

    for (final regel in _parseNietLegeRegels(_kleurenController.text)) {
      final delen = regel.split(RegExp(r'[\t;]+'));
      if (delen.length < 4) continue;

      final code = delen[0].trim();
      final naam = delen[1].trim();
      final hex = _normaliseerHex(delen[2]);
      final types = _parseTypes(delen[3]);
      final optioneel = delen.length >= 5 && _isJa(delen[4]);

      if (code.isEmpty || naam.isEmpty || hex == null || types.isEmpty) {
        continue;
      }

      final kleur = OpmetingBuitenjaloezieLamelkleur(
        code: code,
        naam: naam,
        hexKleur: hex,
        toegestaanVoor: types,
        optioneel: optioneel,
      );

      if (gebruikt.add(kleur.id)) resultaat.add(kleur);
    }

    return List<OpmetingBuitenjaloezieLamelkleur>.unmodifiable(resultaat);
  }

  List<OpmetingBuitenjaloezieGeleider> _parseGeleiders() {
    final resultaat = <OpmetingBuitenjaloezieGeleider>[];
    final gebruikt = <String>{};

    for (final regel in _parseNietLegeRegels(_geleidersController.text)) {
      final delen = regel.split(RegExp(r'[\t;]+'));
      if (delen.length < 4) continue;

      final code = delen[0].trim();
      final breedte = int.tryParse(delen[1].trim());
      final diepte = int.tryParse(delen[2].trim());
      final types = _parseTypes(delen[3]);

      if (code.isEmpty ||
          breedte == null ||
          breedte <= 0 ||
          diepte == null ||
          diepte <= 0 ||
          types.isEmpty) {
        continue;
      }

      final geleider = OpmetingBuitenjaloezieGeleider(
        code: code,
        breedteMm: breedte,
        diepteMm: diepte,
        toegestaanVoor: types,
      );

      if (gebruikt.add(geleider.id)) resultaat.add(geleider);
    }

    return List<OpmetingBuitenjaloezieGeleider>.unmodifiable(resultaat);
  }

  Set<OpmetingBuitenjaloezieLameltype> _parseTypes(String tekst) {
    final resultaat = <OpmetingBuitenjaloezieLameltype>{};
    final delen = tekst.split(RegExp(r'[,|/]+'));

    for (final deel in delen) {
      final genormaliseerd = deel.trim().toLowerCase().replaceAll(
        RegExp(r'[^a-z0-9]'),
        '',
      );

      switch (genormaliseerd) {
        case 'cdl70':
          resultaat.add(OpmetingBuitenjaloezieLameltype.cdl70);
        case 'zl81':
          resultaat.add(OpmetingBuitenjaloezieLameltype.zl81);
        case 'dbl70':
          resultaat.add(OpmetingBuitenjaloezieLameltype.dbl70);
        case 'gl80':
          resultaat.add(OpmetingBuitenjaloezieLameltype.gl80);
        case 'fl80':
          resultaat.add(OpmetingBuitenjaloezieLameltype.fl80);
        case 'alle':
          resultaat.addAll(OpmetingBuitenjaloezieLameltype.values);
      }
    }

    return resultaat;
  }

  List<int> _parseIntLijst(String tekst) {
    final resultaat =
        tekst
            .split(RegExp(r'[,;\s]+'))
            .map((deel) => int.tryParse(deel.trim()))
            .whereType<int>()
            .where((waarde) => waarde >= 0)
            .toSet()
            .toList()
          ..sort();
    return List<int>.unmodifiable(resultaat);
  }

  List<String> _parseNietLegeRegels(String tekst) {
    return tekst
        .split(RegExp(r'\r?\n'))
        .map((regel) => regel.trim())
        .where((regel) => regel.isNotEmpty)
        .toList(growable: false);
  }

  String? _normaliseerHex(String tekst) {
    final schoon = tekst.trim().replaceAll('#', '').toUpperCase();
    if (!RegExp(r'^[0-9A-F]{6}$').hasMatch(schoon)) return null;
    return '#$schoon';
  }

  bool _isJa(String tekst) {
    final waarde = tekst.trim().toLowerCase();
    return waarde == 'ja' ||
        waarde == 'j' ||
        waarde == 'yes' ||
        waarde == 'true' ||
        waarde == '1' ||
        waarde == 'x';
  }

  void _toonFout(String tekst) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: const Color(0xFFDC2626), content: Text(tekst)),
    );
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
          'Instellingen Buitenjaloezieën',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: <Widget>[
          TextButton.icon(
            onPressed: _laden || _bewaren ? null : _herstelStandaard,
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('Standaard herstellen'),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _laden || _bewaren ? null : _bewaar,
              style: FilledButton.styleFrom(backgroundColor: _groen),
              icon: _bewaren
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text('Bewaren'),
            ),
          ),
        ],
      ),
      body: _laden
          ? const Center(child: CircularProgressIndicator(color: _groen))
          : LayoutBuilder(
              builder: (context, constraints) {
                final breed = constraints.maxWidth >= 1050;
                final eersteKolom = <Widget>[
                  _bewerkKaart(
                    titel: 'Lamelkleuren',
                    uitleg:
                        'Eén regel per kleur: code; naam; HEX; lameltypes; '
                        'optioneel. Gebruik CDL 70, ZL 81, DBL 70, GL 80 '
                        'en/of FL 80.',
                    controller: _kleurenController,
                    minimumRegels: 15,
                    voorbeeld:
                        '301; Lichtgrau; #D9D9D7; CDL 70,ZL 81,DBL 70,GL 80; neen',
                    teller: '${_parseKleuren().length} geldige kleuren',
                  ),
                  const SizedBox(height: 14),
                  _bewerkKaart(
                    titel: 'Geleiders',
                    uitleg:
                        'Eén regel per geleider: code; breedte; diepte; '
                        'toegestane lameltypes.',
                    controller: _geleidersController,
                    minimumRegels: 12,
                    voorbeeld: '1; 27; 69; ZL 81,DBL 70,GL 80',
                    teller: '${_parseGeleiders().length} geldige geleiders',
                  ),
                ];

                final tweedeKolom = <Widget>[
                  _bewerkKaart(
                    titel: 'Bedieningen',
                    uitleg: 'Eén bediening per regel.',
                    controller: _bedieningenController,
                    minimumRegels: 6,
                    voorbeeld: 'Inbouwschakelaar',
                    teller:
                        '${_parseNietLegeRegels(_bedieningenController.text).length} bedieningen',
                  ),
                  const SizedBox(height: 14),
                  _bewerkKaart(
                    titel: 'Motorkabellengtes',
                    uitleg:
                        'Lengtes in meter, gescheiden door komma’s. '
                        'Bijvoorbeeld 5, 10.',
                    controller: _kabelsController,
                    minimumRegels: 2,
                    voorbeeld: '5, 10',
                    teller:
                        '${_parseIntLijst(_kabelsController.text).length} lengtes',
                  ),
                  const SizedBox(height: 14),
                  _bewerkKaart(
                    titel: 'Afschuining geleiders',
                    uitleg:
                        'Gradenwaarden gescheiden door komma’s. '
                        '0° blijft de aanbevolen standaardkeuze.',
                    controller: _afschuiningController,
                    minimumRegels: 3,
                    voorbeeld: '0, 1, 2, 3, 4, 5',
                    teller:
                        '${_parseIntLijst(_afschuiningController.text).length} waarden',
                  ),
                  const SizedBox(height: 14),
                  _raffstoreKasttabelKaart(),
                  const SizedBox(height: 14),
                  _informatieKaart(),
                ];

                if (!breed) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: <Widget>[
                      ...eersteKolom,
                      const SizedBox(height: 14),
                      ...tweedeKolom,
                      const SizedBox(height: 24),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 6,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 8, 24),
                        children: eersteKolom,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(8, 16, 16, 24),
                        children: tweedeKolom,
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _bewerkKaart({
    required String titel,
    required String uitleg,
    required TextEditingController controller,
    required int minimumRegels,
    required String voorbeeld,
    required String teller,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rand),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  titel,
                  style: const TextStyle(
                    color: _tekst,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: _lichtGroen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  teller,
                  style: const TextStyle(
                    color: _groen,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            uitleg,
            style: const TextStyle(
              color: _tekstGrijs,
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            minLines: minimumRegels,
            maxLines: null,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              height: 1.35,
            ),
            decoration: InputDecoration(
              hintText: voorbeeld,
              alignLabelWithHint: true,
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _rand),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _rand),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _groen, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _raffstoreKasttabelKaart() {
    const rijen = <_KasttabelRij>[
      _KasttabelRij('P', 'DBL 70', 0, 2630, 2980),
      _KasttabelRij('P', 'DBL 70', 15, 2890, 3300),
      _KasttabelRij('P', 'DBL 70', 30, 3220, 3560),
      _KasttabelRij('P', 'DBL 70', 45, 3540, 3890),
      _KasttabelRij('P', 'GL 80', 0, 2370, 2660),
      _KasttabelRij('P', 'GL 80', 15, 2510, 2870),
      _KasttabelRij('P', 'GL 80', 30, 2800, 3160),
      _KasttabelRij('P', 'GL 80', 45, 3090, 3450),
      _KasttabelRij('XP', 'DBL 70', 0, 2310, 2650),
      _KasttabelRij('XP', 'DBL 70', 15, 2630, 2980),
      _KasttabelRij('XP', 'DBL 70', 30, 2890, 3300),
      _KasttabelRij('XP', 'DBL 70', 45, 3220, 3560),
      _KasttabelRij('XP', 'GL 80', 0, 1650, 1940),
      _KasttabelRij('XP', 'GL 80', 15, 1870, 2230),
      _KasttabelRij('XP', 'GL 80', 30, 2080, 2440),
      _KasttabelRij('XP', 'GL 80', 45, 2370, 2730),
    ];

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rand),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'Raffstore-kasttabel 165 / 185 mm',
            style: TextStyle(
              color: _tekst,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Maximale totale elementhoogte in mm. XP is de uitvoering met '
            'geïntegreerde rolhor. De uitsteek is het lamellenpakket met '
            'onderlijst onder de kast.',
            style: TextStyle(color: _tekstGrijs, fontSize: 11.5, height: 1.35),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: const WidgetStatePropertyAll(_lichtGroen),
              dataRowMinHeight: 34,
              dataRowMaxHeight: 38,
              columnSpacing: 22,
              columns: const <DataColumn>[
                DataColumn(label: Text('Systeem')),
                DataColumn(label: Text('Lamel')),
                DataColumn(label: Text('Uitsteek')),
                DataColumn(label: Text('Kast 165')),
                DataColumn(label: Text('Kast 185')),
              ],
              rows: rijen
                  .map((rij) {
                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(rij.systeem)),
                        DataCell(Text(rij.lameltype)),
                        DataCell(Text('${rij.uitsteekMm} mm')),
                        DataCell(Text('${rij.max165Mm} mm')),
                        DataCell(Text('${rij.max185Mm} mm')),
                      ],
                    );
                  })
                  .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _informatieKaart() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _lichtGroen,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCDEBD6)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Vaste systeemregels',
            style: TextStyle(
              color: _groen,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 7),
          Text(
            '• MODULO, RONDO en PENTO zijn beschikbaar als P en XP.\n'
            '• RONDO en PENTO gebruiken uitsluitend kast 165 of 185 mm.\n'
            '• De Raffstore-tabel hieronder is een vaste referentietabel.\n'
            '• Lamelhoogte 20 mm en vrije ruimte 30 mm blijven vaste tekenregels.',
            style: TextStyle(
              color: _tekst,
              fontSize: 11.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _KasttabelRij {
  const _KasttabelRij(
    this.systeem,
    this.lameltype,
    this.uitsteekMm,
    this.max165Mm,
    this.max185Mm,
  );

  final String systeem;
  final String lameltype;
  final int uitsteekMm;
  final int max165Mm;
  final int max185Mm;
}
