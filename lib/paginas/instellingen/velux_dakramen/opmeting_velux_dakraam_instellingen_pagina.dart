// THIMACO-CONTROLE: VELUX-DOWNLOADSIGNAAL-FASE15-20260805
// THIMACO-CONTROLE: VELUX-AFWERKINGSPRIJZEN-UIT-CATALOGUSINSTELLINGEN-20260730
// THIMACO-CONTROLE: INSTELLINGEN-VELUX-FASE-1-2-20260729-2030
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../helpers/app_storage.dart';
import '../../../helpers/opmeting/toebehoren/velux_dakramen/opmeting_velux_dakraam_instellingen_model.dart';
import '../../../helpers/sync/sync_navigatie_helper.dart';

class OpmetingVeluxDakraamInstellingenPagina extends StatefulWidget {
  const OpmetingVeluxDakraamInstellingenPagina({super.key});

  @override
  State<OpmetingVeluxDakraamInstellingenPagina> createState() {
    return _OpmetingVeluxDakraamInstellingenPaginaState();
  }
}

class _OpmetingVeluxDakraamInstellingenPaginaState
    extends State<OpmetingVeluxDakraamInstellingenPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekst = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  final TextEditingController _catalogusJaarController =
      TextEditingController();
  final TextEditingController _geldigVanafController = TextEditingController();
  final TextEditingController _kux110PrijsController = TextEditingController();
  final Map<String, TextEditingController> _prijsControllers =
      <String, TextEditingController>{};
  final Map<String, TextEditingController> _muggengaasPrijsControllers =
      <String, TextEditingController>{};

  OpmetingVeluxDakraamInstellingen? _instellingen;
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

    _catalogusJaarController.addListener(_verwerkControllerWijziging);
    _geldigVanafController.addListener(_verwerkControllerWijziging);
    _kux110PrijsController.addListener(_verwerkControllerWijziging);

    _laad();
  }

  @override
  void dispose() {
    SyncNavigatieHelper.downloadVersie.removeListener(
      _verwerkAchtergrondDownload,
    );

    _catalogusJaarController.removeListener(_verwerkControllerWijziging);
    _geldigVanafController.removeListener(_verwerkControllerWijziging);
    _kux110PrijsController.removeListener(_verwerkControllerWijziging);

    _catalogusJaarController.dispose();
    _geldigVanafController.dispose();
    _kux110PrijsController.dispose();
    for (final controller in _prijsControllers.values) {
      controller.removeListener(_verwerkControllerWijziging);
      controller.dispose();
    }
    for (final controller in _muggengaasPrijsControllers.values) {
      controller.removeListener(_verwerkControllerWijziging);
      controller.dispose();
    }
    super.dispose();
  }

  void _verwerkControllerWijziging() {
    if (_controllersWordenGeladen) {
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
          'Er zijn nieuwere Velux-instellingen ontvangen. '
          'Je niet-opgeslagen prijswijzigingen blijven behouden.',
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
        await AppStorage.laadOpmetingVeluxDakraamInstellingen();
    if (!mounted) return;

    _vulControllers(instellingen);
    setState(() {
      _instellingen = instellingen;
      _laden = false;
      _lokaleWijzigingen = false;
      _downloadHerladenUitgesteld = false;
    });
  }

  void _vulControllers(OpmetingVeluxDakraamInstellingen instellingen) {
    _controllersWordenGeladen = true;

    _catalogusJaarController.text = instellingen.catalogusJaar.toString();
    _geldigVanafController.text = instellingen.geldigVanaf;
    _kux110PrijsController.text = _formatPrijsVoorInvoer(
      instellingen.kux110PrijsExclBtw,
    );

    for (final prijs in instellingen.prijzen) {
      final controller = _prijsControllers.putIfAbsent(prijs.id, () {
        final nieuw = TextEditingController();
        nieuw.addListener(_verwerkControllerWijziging);
        return nieuw;
      });
      controller.text = _formatPrijsVoorInvoer(prijs.prijsExclBtw);
    }

    for (final prijs in instellingen.muggengaasPrijzen) {
      final controller = _muggengaasPrijsControllers.putIfAbsent(prijs.id, () {
        final nieuw = TextEditingController();
        nieuw.addListener(_verwerkControllerWijziging);
        return nieuw;
      });
      controller.text = _formatPrijsVoorInvoer(prijs.prijsExclBtw);
    }

    _controllersWordenGeladen = false;
  }

  String _formatPrijsVoorInvoer(double waarde) {
    if (waarde == waarde.roundToDouble()) {
      return waarde.toInt().toString();
    }
    return waarde.toStringAsFixed(2).replaceAll('.', ',');
  }

  double _parsePrijs(String tekst) {
    return double.tryParse(tekst.trim().replaceAll(',', '.')) ?? 0;
  }

  void _herstelStandaard() {
    final standaard = OpmetingVeluxDakraamInstellingen.standaard2026();
    _vulControllers(standaard);
    setState(() {
      _instellingen = standaard;
      _lokaleWijzigingen = true;
    });
  }

  Future<void> _bewaar() async {
    final huidig = _instellingen;
    if (_bewaren || huidig == null) return;

    setState(() => _bewaren = true);
    try {
      final bijgewerktePrijzen = huidig.prijzen
          .map((prijs) {
            final controller = _prijsControllers[prijs.id];
            if (controller == null) return prijs;
            return prijs.copyWith(prijsExclBtw: _parsePrijs(controller.text));
          })
          .toList(growable: false);

      final bijgewerkteMuggengaasPrijzen = huidig.muggengaasPrijzen
          .map((prijs) {
            final controller = _muggengaasPrijsControllers[prijs.id];
            if (controller == null) return prijs;
            return prijs.copyWith(prijsExclBtw: _parsePrijs(controller.text));
          })
          .toList(growable: false);

      final instellingen = huidig
          .copyWith(
            catalogusJaar:
                int.tryParse(_catalogusJaarController.text.trim()) ??
                huidig.catalogusJaar,
            geldigVanaf: _geldigVanafController.text.trim(),
            prijzen: bijgewerktePrijzen,
            muggengaasPrijzen: bijgewerkteMuggengaasPrijzen,
            kux110PrijsExclBtw: _parsePrijs(_kux110PrijsController.text),
          )
          .metWijzigingsDatum();

      await AppStorage.bewaarOpmetingVeluxDakraamInstellingen(instellingen);
      if (!mounted) return;

      setState(() {
        _instellingen = instellingen;
        _lokaleWijzigingen = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Instellingen Velux dakramen bewaard.')),
      );
    } finally {
      if (mounted) setState(() => _bewaren = false);
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
          'Instellingen Velux dakramen',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: <Widget>[
          TextButton.icon(
            onPressed: _laden || _bewaren ? null : _herstelStandaard,
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('Catalogus herstellen'),
          ),
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
                _bouwCatalogusInfo(),
                const SizedBox(height: 16),
                _bouwGgu0070Tabel(),
                const SizedBox(height: 16),
                _bouwGootstukkenTabel(),
                const SizedBox(height: 16),
                _bouwRolluikenTabel(),
                const SizedBox(height: 16),
                _bouwBuitenscreensTabel(),
                const SizedBox(height: 16),
                _bouwVerduisteringsgordijnTabel(),
                const SizedBox(height: 16),
                _bouwMuggengaasTabel(),
                const SizedBox(height: 16),
                _bouwAanvullendePrijzen(),
              ],
            ),
    );
  }

  Widget _bouwCatalogusInfo() {
    return _kaart(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Catalogusgegevens',
            style: TextStyle(
              color: _tekst,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Alle ingevoerde bedragen zijn de catalogusbedragen zonder btw. Het btw-tarief wordt later op het overzichtsblad toegepast.',
            style: TextStyle(color: _tekstGrijs, fontSize: 12.5, height: 1.4),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              SizedBox(
                width: 180,
                child: TextField(
                  controller: _catalogusJaarController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Catalogusjaar',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(
                width: 220,
                child: TextField(
                  controller: _geldigVanafController,
                  decoration: const InputDecoration(
                    labelText: 'Geldig vanaf',
                    hintText: 'bijv. 01/07/2026',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bouwGgu0070Tabel() {
    final prijzen = _instellingen!.prijzenVoorProduct(
      OpmetingVeluxDakraamInstellingen.ggu0070ProductCode,
    );

    return _tabelKaart(
      titel: 'Manueel dakvenster – opening bovenaan',
      subtitel:
          'Hout omhuld met wit afgelakt polyurethaan · standaard GGU 0070',
      bronTekst:
          'Bron: doorgegeven VELUX-catalogustabel, pagina 27. Alleen de bovenste catalogusbedragen zijn opgenomen.',
      tabel: _bouwPrijsTabel(
        prijzenPerRij: <String, List<OpmetingVeluxDakraamCatalogusPrijs>>{
          OpmetingVeluxDakraamInstellingen.ggu0070ProductCode: prijzen,
        },
      ),
    );
  }

  Widget _bouwGootstukkenTabel() {
    final instellingen = _instellingen!;
    final prijzenPerRij = <String, List<OpmetingVeluxDakraamCatalogusPrijs>>{
      for (final productCode
          in OpmetingVeluxDakraamInstellingen.gootstukProductVolgorde)
        productCode: instellingen.prijzenVoorProduct(productCode),
    };

    return _tabelKaart(
      titel: 'Kit gootstukken Pro+ inclusief installatieproducten BDX en BFX',
      subtitel: 'EDW, EDT, EDP en EDB 2000 · gootstukken voor pannen',
      bronTekst:
          'Bron: doorgegeven VELUX-catalogustabel, pagina 81. Alleen de bovenste catalogusbedragen zijn opgenomen.',
      tabel: _bouwPrijsTabel(prijzenPerRij: prijzenPerRij),
    );
  }

  Widget _bouwRolluikenTabel() {
    final instellingen = _instellingen!;
    return _tabelKaart(
      titel: 'VELUX rolluiken',
      subtitel: 'Op zonne-energie SSL en elektrisch SML',
      bronTekst:
          'Bron: doorgegeven VELUX-catalogustabel, pagina 133. Alleen de bovenste catalogusbedragen zijn opgenomen.',
      tabel: _bouwPrijsTabel(
        toonAfmetingen: false,
        prijzenPerRij: <String, List<OpmetingVeluxDakraamCatalogusPrijs>>{
          'Op zonne-energie · SSL': instellingen.prijzenVoorProduct('SSL'),
          'Elektrisch · SML': instellingen.prijzenVoorProduct('SML'),
        },
      ),
    );
  }

  Widget _bouwBuitenscreensTabel() {
    final instellingen = _instellingen!;
    return _tabelKaart(
      titel: 'VELUX buitenscreens',
      subtitel: 'Op zonne-energie MSL, elektrisch MML en manueel MHL',
      bronTekst:
          'Bron: doorgegeven VELUX-catalogustabel, pagina 134. Alleen de bovenste catalogusbedragen zijn opgenomen.',
      tabel: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _bouwPrijsTabel(
            toonAfmetingen: false,
            prijzenPerRij: <String, List<OpmetingVeluxDakraamCatalogusPrijs>>{
              'Op zonne-energie · MSL': instellingen.prijzenVoorProduct('MSL'),
              'Elektrisch · MML': instellingen.prijzenVoorProduct('MML'),
            },
          ),
          const SizedBox(height: 14),
          _bouwPrijsTabel(
            toonAfmetingen: false,
            prijzenPerRij: <String, List<OpmetingVeluxDakraamCatalogusPrijs>>{
              'Manueel · MHL': instellingen.prijzenVoorProduct('MHL'),
            },
          ),
        ],
      ),
    );
  }

  Widget _bouwVerduisteringsgordijnTabel() {
    final prijzen = _instellingen!.prijzenVoorProduct(
      OpmetingVeluxDakraamInstellingen.verduisteringsGordijnProductCode,
    );

    return _tabelKaart(
      titel: 'VELUX verduisteringsgordijn',
      subtitel:
          'Manueel DKL · kleuren 1085 Crème, 1100 Blauw, 0705 Grijs, 1025 Wit en 3009 Zwart',
      bronTekst:
          'Bron: doorgegeven VELUX-catalogustabel, pagina 138. De vijf doorgegeven kleurcodes gebruiken dezelfde catalogusprijzen.',
      tabel: _bouwPrijsTabel(
        toonAfmetingen: false,
        prijzenPerRij: <String, List<OpmetingVeluxDakraamCatalogusPrijs>>{
          'Manueel · DKL': prijzen,
        },
      ),
    );
  }

  Widget _bouwAanvullendePrijzen() {
    return _tabelKaart(
      titel: 'Aanvullende Velux-prijs',
      subtitel:
          'De stroomvoorziening KUX 110 wordt rechtstreeks in de Velux-catalogusberekening gebruikt.',
      bronTekst:
          'De prijzen voor MDF- en kunststofbinnenafwerking beheer je voortaan uniform via Instellingen → Offerteprijzen → Prijs volgens technische keuze → Velux dakramen.',
      tabel: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const <int, TableColumnWidth>{
          0: FixedColumnWidth(430),
          1: FixedColumnWidth(170),
        },
        border: TableBorder.all(color: _rand),
        children: <TableRow>[
          const TableRow(
            decoration: BoxDecoration(color: _lichtGroen),
            children: <Widget>[
              _VeluxInstellingenStatischeCel('Artikel', vet: true),
              _VeluxInstellingenStatischeCel('Prijs', vet: true),
            ],
          ),
          TableRow(
            children: <Widget>[
              _tabelCel(
                'Stroomvoorzieningseenheid KUX 110 · maximaal 5 Velux-producten',
                vet: true,
                uitlijning: Alignment.centerLeft,
              ),
              Padding(
                padding: const EdgeInsets.all(7),
                child: _bouwPrijsVeld(_kux110PrijsController),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bouwMuggengaasTabel() {
    return _tabelKaart(
      titel: 'VELUX muggengaas',
      subtitel:
          'Prijs wordt bepaald met maat A (breedte) en maat B (hoogte) van de afgewerkte raamopening',
      bronTekst:
          'Bron: doorgegeven VELUX-catalogustabel, pagina 155. Een leeg vak betekent dat die maatcombinatie niet beschikbaar is.',
      tabel: _bouwMuggengaasPrijsTabel(),
    );
  }

  Widget _bouwMuggengaasPrijsTabel() {
    final prijzen = _instellingen!.muggengaasPrijzen;
    const breedteBereiken = <({int min, int max})>[
      (min: 439, max: 530),
      (min: 531, max: 640),
      (min: 641, max: 760),
      (min: 761, max: 922),
      (min: 923, max: 1120),
      (min: 1121, max: 1320),
    ];
    const hoogteBereiken = <({int min, int max})>[
      (min: 0, max: 1600),
      (min: 1601, max: 2000),
      (min: 2001, max: 2400),
    ];

    OpmetingVeluxMuggengaasCatalogusPrijs? zoekPrijs({
      required int breedteMin,
      required int breedteMax,
      required int hoogteMin,
      required int hoogteMax,
    }) {
      for (final prijs in prijzen) {
        if (prijs.breedteMinMm == breedteMin &&
            prijs.breedteMaxMm == breedteMax &&
            prijs.hoogteMinMm == hoogteMin &&
            prijs.hoogteMaxMm == hoogteMax) {
          return prijs;
        }
      }
      return null;
    }

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: <int, TableColumnWidth>{
        0: const FixedColumnWidth(190),
        for (var index = 1; index <= breedteBereiken.length; index++)
          index: const FixedColumnWidth(175),
      },
      border: TableBorder.all(color: _rand),
      children: <TableRow>[
        TableRow(
          decoration: const BoxDecoration(color: _lichtGroen),
          children: <Widget>[
            _tabelCel(
              'B hoogte \\ A breedte',
              vet: true,
              uitlijning: Alignment.centerLeft,
            ),
            for (final bereik in breedteBereiken)
              _tabelCel('${bereik.min}–${bereik.max} mm', vet: true),
          ],
        ),
        for (final hoogte in hoogteBereiken)
          TableRow(
            children: <Widget>[
              _tabelCel(
                '${hoogte.min}–${hoogte.max} mm',
                vet: true,
                uitlijning: Alignment.centerLeft,
              ),
              for (final breedte in breedteBereiken)
                _bouwMuggengaasCel(
                  zoekPrijs(
                    breedteMin: breedte.min,
                    breedteMax: breedte.max,
                    hoogteMin: hoogte.min,
                    hoogteMax: hoogte.max,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _bouwMuggengaasCel(OpmetingVeluxMuggengaasCatalogusPrijs? prijs) {
    if (prijs == null) {
      return _tabelCel('—');
    }

    final controller = _muggengaasPrijsControllers[prijs.id]!;
    return Padding(
      padding: const EdgeInsets.all(7),
      child: Column(
        children: <Widget>[
          Text(
            prijs.productCode,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _tekst,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          _bouwPrijsVeld(controller),
        ],
      ),
    );
  }

  Widget _tabelKaart({
    required String titel,
    required String subtitel,
    required String bronTekst,
    required Widget tabel,
  }) {
    return _kaart(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            decoration: const BoxDecoration(
              color: _lichtGroen,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  titel,
                  style: const TextStyle(
                    color: _groen,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitel,
                  style: const TextStyle(
                    color: _tekstGrijs,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: tabel,
                ),
                const SizedBox(height: 10),
                Text(
                  bronTekst,
                  style: const TextStyle(
                    color: _tekstGrijs,
                    fontSize: 11.5,
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

  Widget _bouwPrijsTabel({
    required Map<String, List<OpmetingVeluxDakraamCatalogusPrijs>>
    prijzenPerRij,
    bool toonAfmetingen = true,
  }) {
    final eerstePrijzen = prijzenPerRij.values.first;

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: <int, TableColumnWidth>{
        0: const FixedColumnWidth(230),
        for (var index = 1; index <= eerstePrijzen.length; index++)
          index: const FixedColumnWidth(112),
      },
      border: TableBorder.all(color: _rand),
      children: <TableRow>[
        TableRow(
          decoration: const BoxDecoration(color: _lichtGroen),
          children: <Widget>[
            _tabelCel('Type', vet: true, uitlijning: Alignment.centerLeft),
            ...eerstePrijzen.map(
              (prijs) => _tabelCel(prijs.maatCode, vet: true),
            ),
          ],
        ),
        if (toonAfmetingen)
          TableRow(
            decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
            children: <Widget>[
              _tabelCel(
                'Afmetingen buitenframe (B × H) in cm',
                uitlijning: Alignment.centerLeft,
              ),
              ...eerstePrijzen.map((prijs) => _tabelCel(prijs.afmetingLabel)),
            ],
          ),
        for (final rij in prijzenPerRij.entries)
          TableRow(
            children: <Widget>[
              _tabelCel(rij.key, vet: true, uitlijning: Alignment.centerLeft),
              ...rij.value.map(_prijsCel),
            ],
          ),
      ],
    );
  }

  Widget _kaart({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(15),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rand),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _tabelCel(
    String tekst, {
    bool vet = false,
    Alignment uitlijning = Alignment.center,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      alignment: uitlijning,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      child: Text(
        tekst,
        textAlign: uitlijning == Alignment.centerLeft
            ? TextAlign.left
            : TextAlign.center,
        style: TextStyle(
          color: _tekst,
          fontSize: 12,
          height: 1.25,
          fontWeight: vet ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _prijsCel(OpmetingVeluxDakraamCatalogusPrijs prijs) {
    final controller = _prijsControllers[prijs.id]!;
    return Padding(
      padding: const EdgeInsets.all(7),
      child: _bouwPrijsVeld(controller),
    );
  }

  Widget _bouwPrijsVeld(TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
      ],
      textAlign: TextAlign.right,
      selectAllOnFocus: true,
      decoration: InputDecoration(
        prefixText: '€ ',
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFFCFCFD),
        contentPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 11),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _rand),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _groen, width: 1.5),
        ),
      ),
    );
  }
}

class _VeluxInstellingenStatischeCel extends StatelessWidget {
  const _VeluxInstellingenStatischeCel(this.tekst, {this.vet = false});

  final String tekst;
  final bool vet;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      child: Text(
        tekst,
        style: TextStyle(
          color: const Color(0xFF111827),
          fontSize: 12,
          fontWeight: vet ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
    );
  }
}
