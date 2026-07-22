import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../helpers/offerte/overzicht/offerte_prijs_overzicht_model.dart';
import '../helpers/offerte/overzicht/offerte_prijs_overzicht_pdf_service.dart'
    as prijs_pdf;
import '../helpers/offerte/overzicht/offerte_prijs_overzicht_service.dart'
    as prijs_overzicht;
import '../helpers/opmeting/overzicht/opmeting_overzicht_model.dart';
import '../helpers/opmeting/project/opmeting_project_titelhoofd_model.dart';

class OffertePrijsOverzichtPagina extends StatefulWidget {
  const OffertePrijsOverzichtPagina({
    super.key,
    required this.titelhoofd,
    required this.posities,
  });

  final OpmetingProjectTitelhoofd titelhoofd;
  final List<OpmetingOverzichtRaamItem> posities;

  @override
  State<OffertePrijsOverzichtPagina> createState() {
    return _OffertePrijsOverzichtPaginaState();
  }
}

class _OffertePrijsOverzichtPaginaState
    extends State<OffertePrijsOverzichtPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _oranje = Color(0xFFF15A24);
  static const Color _oranjeLicht = Color(0xFFFFF7ED);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  late OffertePrijsOverzichtData _data;

  @override
  void initState() {
    super.initState();
    _bouwData();
  }

  @override
  void didUpdateWidget(covariant OffertePrijsOverzichtPagina oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.titelhoofd != widget.titelhoofd ||
        oldWidget.posities != widget.posities) {
      _bouwData();
    }
  }

  void _bouwData() {
    _data = prijs_overzicht.OffertePrijsOverzichtService.bouw(
      titelhoofd: widget.titelhoofd,
      posities: widget.posities,
    );
  }

  void _openPdf() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _OffertePrijsOverzichtPdfPreviewPagina(data: _data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _achtergrond,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _tekstDonker,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Prijs- en margeoverzicht',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            Text(
              'Intern commercieel overzicht',
              style: TextStyle(
                color: _tekstGrijs,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _groen,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _openPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
            label: const Text(
              'PDF',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1380),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 34),
            children: <Widget>[
              _bouwProjectKop(),
              const SizedBox(height: 12),
              _bouwSamenvatting(),
              const SizedBox(height: 16),
              _bouwSectieKop(
                titel: 'Artikelen',
                uitleg:
                    'Alle posities staan eerst compact onder elkaar. De gezamenlijke bedragen worden in de laatste tabelrij opgeteld.',
                icoon: Icons.view_list_outlined,
              ),
              const SizedBox(height: 8),
              if (_data.hoofdArtikelen.isEmpty)
                _bouwLegeKaart('Geen prijsdragende hoofdartikelen gevonden.')
              else
                _bouwArtikelenKaart(_data.hoofdArtikelen),
              const SizedBox(height: 14),
              _bouwPrijsregelsKaart(_data.hoofdPrijsregels),
              const SizedBox(height: 14),
              _bouwFinancieleSamenvatting(),
              if (_data.optieArtikelen.isNotEmpty ||
                  _data.optiePrijsregels.isNotEmpty) ...<Widget>[
                const SizedBox(height: 18),
                _bouwSectieKop(
                  titel: 'Opties',
                  uitleg:
                      'Optionele artikelen en prijsregels worden apart getoond en tellen niet mee in het eindtotaal.',
                  icoon: Icons.bookmark_outline_rounded,
                  accent: _oranje,
                  achtergrond: _oranjeLicht,
                ),
                const SizedBox(height: 8),
                if (_data.optieArtikelen.isNotEmpty)
                  _bouwArtikelenKaart(_data.optieArtikelen, isOptie: true),
                if (_data.optiePrijsregels.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 10),
                  _bouwPrijsregelsKaart(_data.optiePrijsregels, isOptie: true),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _bouwProjectKop() {
    return _basisKaart(
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _groen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'T',
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _data.klantNaam.isEmpty
                      ? 'Prijs- en margeoverzicht'
                      : _data.klantNaam,
                  style: const TextStyle(
                    color: _tekstDonker,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (_data.klantAdres.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    _data.klantAdres,
                    style: const TextStyle(
                      color: _tekstGrijs,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _rand),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                if (_data.offerteNummer.isNotEmpty)
                  Text(
                    'Offerte ${_data.offerteNummer}',
                    style: const TextStyle(
                      color: _tekstDonker,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                Text(
                  _datum(_data.opgemaaktOp),
                  style: const TextStyle(
                    color: _tekstGrijs,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'INTERN DOCUMENT',
                  style: TextStyle(
                    color: _oranje,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwSamenvatting() {
    final prijsregels = _data.prijsregelsTotaalExclBtw;
    final kaarten = <Widget>[
      _bouwSamenvattingKaart(
        label: 'Artikelen',
        waarde: '${_data.aantalArtikelen}',
        detail: '${_data.aantalPosities} posities',
        icoon: Icons.inventory_2_outlined,
      ),
      _bouwSamenvattingKaart(
        label: 'Basisprijs',
        waarde: _euro(_data.basisTotaalExclBtw),
        detail: 'alle hoofdartikelen',
        icoon: Icons.euro_outlined,
      ),
      _bouwSamenvattingKaart(
        label: 'Prijsregels',
        waarde: _euro(prijsregels),
        detail: 'technisch, vrij en project',
        icoon: Icons.rule_folder_outlined,
      ),
      _bouwSamenvattingKaart(
        label: 'Winstmarge',
        waarde: '+ ${_euro(_data.totaleWinstmargeExclBtw)}',
        detail: 'op de basisprijs',
        icoon: Icons.trending_up_rounded,
        accent: _groen,
      ),
      _bouwSamenvattingKaart(
        label: 'Korting',
        waarde: '- ${_euro(_data.totaleKortingExclBtw)}',
        detail: 'alleen op de basisprijs',
        icoon: Icons.percent_rounded,
        accent: _oranje,
      ),
      _bouwSamenvattingKaart(
        label: 'Eindtotaal',
        waarde: _euro(_data.eindtotaalExclBtw),
        detail: 'excl. btw',
        icoon: Icons.summarize_outlined,
        accent: _groen,
        opvallend: true,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final aantalKolommen = constraints.maxWidth >= 1180
            ? 6
            : constraints.maxWidth >= 760
            ? 3
            : constraints.maxWidth >= 480
            ? 2
            : 1;
        final tussenruimte = 8.0 * (aantalKolommen - 1);
        final kaartBreedte =
            (constraints.maxWidth - tussenruimte) / aantalKolommen;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kaarten
              .map((kaart) => SizedBox(width: kaartBreedte, child: kaart))
              .toList(growable: false),
        );
      },
    );
  }

  Widget _bouwSamenvattingKaart({
    required String label,
    required String waarde,
    required String detail,
    required IconData icoon,
    Color accent = _tekstDonker,
    bool opvallend = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: opvallend ? _lichtGroen : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: opvallend ? _groen : _rand),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withAlpha(26),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icoon, color: accent, size: 18),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    color: _tekstGrijs,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  waarde,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accent,
                    fontSize: opvallend ? 15 : 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _tekstGrijs,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwSectieKop({
    required String titel,
    required String uitleg,
    required IconData icoon,
    Color accent = _groen,
    Color achtergrond = _lichtGroen,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: achtergrond,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icoon, color: accent, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                titel,
                style: TextStyle(
                  color: accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                uitleg,
                style: const TextStyle(
                  color: _tekstGrijs,
                  fontSize: 11,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bouwArtikelenKaart(
    List<OffertePrijsOverzichtArtikel> artikelen, {
    bool isOptie = false,
  }) {
    final totalen = _ArtikelTabelTotalen.van(artikelen);
    final accent = isOptie ? _oranje : _groen;
    final lichteAchtergrond = isOptie ? _oranjeLicht : _lichtGroen;

    return _basisKaart(
      randKleur: isOptie ? _oranje : _rand,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabelBreedte = math
              .max(1110.0, constraints.maxWidth)
              .toDouble();
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tabelBreedte,
              child: Table(
                columnWidths: const <int, TableColumnWidth>{
                  0: FixedColumnWidth(76),
                  1: FixedColumnWidth(145),
                  2: FlexColumnWidth(1),
                  3: FixedColumnWidth(58),
                  4: FixedColumnWidth(105),
                  5: FixedColumnWidth(105),
                  6: FixedColumnWidth(105),
                  7: FixedColumnWidth(112),
                  8: FixedColumnWidth(124),
                },
                border: const TableBorder(
                  horizontalInside: BorderSide(color: _rand),
                ),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: <TableRow>[
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFFF3F4F6)),
                    children: <Widget>[
                      _tabelCel('Positie', kop: true),
                      _tabelCel('Artikel', kop: true),
                      _tabelCel('Omschrijving / maat', kop: true),
                      _tabelCel('Aantal', kop: true, rechts: true),
                      _tabelCel('Basis/stuk', kop: true, rechts: true),
                      _tabelCel('Winst/stuk', kop: true, rechts: true),
                      _tabelCel('Korting/stuk', kop: true, rechts: true),
                      _tabelCel('Totaal/stuk', kop: true, rechts: true),
                      _tabelCel('Positietotaal', kop: true, rechts: true),
                    ],
                  ),
                  ...artikelen.asMap().entries.map((entry) {
                    final artikel = entry.value;
                    final achtergrond = entry.key.isOdd
                        ? const Color(0xFFFAFAFA)
                        : Colors.white;
                    return TableRow(
                      decoration: BoxDecoration(color: achtergrond),
                      children: <Widget>[
                        _tabelCel(
                          artikel.positieLabel,
                          vet: true,
                          kleur: accent,
                        ),
                        _tabelCel(artikel.artikelNaam, vet: true),
                        _tabelCel(
                          artikel.compacteOmschrijving.isEmpty
                              ? '—'
                              : artikel.compacteOmschrijving,
                          maxRegels: 3,
                        ),
                        _tabelCel('${artikel.aantal}', rechts: true),
                        _tabelCel(
                          _euro(artikel.basisPrijsPerStukExclBtw),
                          rechts: true,
                        ),
                        _tabelCel(
                          _bedragMetPercentage(
                            artikel.winstmargePerStukExclBtw,
                            artikel.winstmargePercentage,
                          ),
                          rechts: true,
                          kleur: _groen,
                        ),
                        _tabelCel(
                          _bedragMetPercentage(
                            artikel.kortingPerStukExclBtw,
                            artikel.kortingPercentage,
                            negatief: true,
                          ),
                          rechts: true,
                          kleur: _oranje,
                        ),
                        _tabelCel(
                          _euro(artikel.totaalPerStukExclBtw),
                          rechts: true,
                          vet: true,
                        ),
                        _tabelCel(
                          _euro(artikel.totaalExclBtw),
                          rechts: true,
                          vet: true,
                          kleur: accent,
                        ),
                      ],
                    );
                  }),
                  TableRow(
                    decoration: BoxDecoration(color: lichteAchtergrond),
                    children: <Widget>[
                      _tabelCel('', vet: true),
                      _tabelCel(
                        isOptie ? 'Totaal opties' : 'Totaal artikelen',
                        vet: true,
                        kleur: accent,
                      ),
                      _tabelCel(
                        '${artikelen.length} posities',
                        vet: true,
                        kleur: _tekstGrijs,
                      ),
                      _tabelCel('${totalen.aantal}', rechts: true, vet: true),
                      _tabelCel(
                        _euro(totalen.basisPerStuk),
                        rechts: true,
                        vet: true,
                      ),
                      _tabelCel(
                        '+ ${_euro(totalen.winstPerStuk)}',
                        rechts: true,
                        vet: true,
                        kleur: _groen,
                      ),
                      _tabelCel(
                        '- ${_euro(totalen.kortingPerStuk)}',
                        rechts: true,
                        vet: true,
                        kleur: _oranje,
                      ),
                      _tabelCel(
                        _euro(totalen.totaalPerStuk),
                        rechts: true,
                        vet: true,
                      ),
                      _tabelCel(
                        _euro(totalen.positieTotaal),
                        rechts: true,
                        vet: true,
                        kleur: accent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _bouwPrijsregelsKaart(
    List<OffertePrijsOverzichtSamengevoegdeRegel> regels, {
    bool isOptie = false,
  }) {
    final accent = isOptie ? _oranje : _groen;
    final achtergrond = isOptie ? _oranjeLicht : _lichtGroen;
    final titel = isOptie
        ? 'Optionele prijsregels'
        : 'Prijsregels samengevoegd';
    final uitleg = isOptie
        ? 'Elke optionele omschrijving staat één keer in de lijst met het gezamenlijke totaalbedrag.'
        : 'Technische, vrije en projectbrede prijsregels worden per unieke omschrijving samengevoegd. Terugkerende bedragen zijn opgeteld.';

    return _basisKaart(
      randKleur: isOptie ? _oranje : _rand,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _bouwSectieKop(
            titel: titel,
            uitleg: uitleg,
            icoon: Icons.rule_folder_outlined,
            accent: accent,
            achtergrond: achtergrond,
          ),
          const SizedBox(height: 12),
          if (regels.isEmpty)
            const Text(
              'Geen gekoppelde prijsregels gevonden.',
              style: TextStyle(
                color: _tekstGrijs,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            ...OffertePrijsOverzichtRegelType.values.expand((type) {
              final typeRegels = regels
                  .where((regel) => regel.type == type)
                  .toList(growable: false);
              if (typeRegels.isEmpty) return const <Widget>[];
              return <Widget>[
                _bouwPrijsregelTypeKop(type, typeRegels, accent),
                const SizedBox(height: 5),
                _bouwPrijsregelTabel(typeRegels, accent),
                if (type != OffertePrijsOverzichtRegelType.values.last)
                  const SizedBox(height: 12),
              ];
            }),
        ],
      ),
    );
  }

  Widget _bouwPrijsregelTypeKop(
    OffertePrijsOverzichtRegelType type,
    List<OffertePrijsOverzichtSamengevoegdeRegel> regels,
    Color accent,
  ) {
    final totaal = regels.fold<double>(
      0.0,
      (som, regel) => som + regel.totaalExclBtw,
    );
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            type.label,
            style: TextStyle(
              color: accent,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          _euro(totaal),
          style: TextStyle(
            color: accent,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _bouwPrijsregelTabel(
    List<OffertePrijsOverzichtSamengevoegdeRegel> regels,
    Color accent,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tabelBreedte = math.max(760.0, constraints.maxWidth).toDouble();
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tabelBreedte,
            child: Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(4),
                1: FlexColumnWidth(5),
                2: FixedColumnWidth(135),
              },
              border: const TableBorder(
                horizontalInside: BorderSide(color: _rand),
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: <TableRow>[
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFF3F4F6)),
                  children: <Widget>[
                    _tabelCel('Omschrijving', kop: true),
                    _tabelCel('Toegepast op', kop: true),
                    _tabelCel('Totaal', kop: true, rechts: true),
                  ],
                ),
                ...regels.asMap().entries.map((entry) {
                  final regel = entry.value;
                  return TableRow(
                    decoration: BoxDecoration(
                      color: entry.key.isOdd
                          ? const Color(0xFFFAFAFA)
                          : Colors.white,
                    ),
                    children: <Widget>[
                      _tabelCel(regel.omschrijving, vet: true),
                      _tabelCel(
                        regel.toepassingTekst,
                        kleur: _tekstGrijs,
                        maxRegels: 3,
                      ),
                      _tabelCel(
                        _euro(regel.totaalExclBtw),
                        rechts: true,
                        vet: true,
                        kleur: accent,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bouwFinancieleSamenvatting() {
    return _basisKaart(
      achtergrond: _lichtGroen,
      randKleur: _groen,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final kop = _bouwSectieKop(
            titel: 'Financiële samenvatting',
            uitleg:
                'De korting wordt alleen op de basisprijs na winstmarge berekend. Technische, vrije en projectbrede prijsregels blijven buiten de korting.',
            icoon: Icons.summarize_outlined,
          );
          final totalen = Column(
            children: <Widget>[
              _bouwTotaalRij('Basisprijs', _data.basisTotaalExclBtw),
              _bouwTotaalRij(
                'Technische prijsregels',
                _data.technischePrijsregelsTotaalExclBtw,
              ),
              _bouwTotaalRij(
                'Vrije prijsregels',
                _data.vrijePrijsregelsTotaalExclBtw,
              ),
              _bouwTotaalRij(
                'Prijsregels voor alle artikelen',
                _data.alleArtikelenPrijsregelsTotaalExclBtw,
              ),
              _bouwTotaalRij(
                'Winstmarge',
                _data.totaleWinstmargeExclBtw,
                prefix: '+ ',
                kleur: _groen,
              ),
              _bouwTotaalRij(
                'Korting (alleen op basisprijs)',
                _data.totaleKortingExclBtw,
                prefix: '- ',
                kleur: _oranje,
              ),
              const Divider(height: 16, color: _groen),
              _bouwTotaalRij(
                'Eindtotaal excl. btw',
                _data.eindtotaalExclBtw,
                kleur: _groen,
                vet: true,
                groot: true,
              ),
            ],
          );

          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[kop, const SizedBox(height: 12), totalen],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: kop),
              const SizedBox(width: 26),
              SizedBox(width: 460, child: totalen),
            ],
          );
        },
      ),
    );
  }

  Widget _bouwTotaalRij(
    String label,
    double bedrag, {
    String prefix = '',
    Color kleur = _tekstDonker,
    bool vet = false,
    bool groot = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: _tekstDonker,
                fontSize: groot ? 14 : 11.5,
                fontWeight: vet ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
          Text(
            '$prefix${_euro(bedrag)}',
            style: TextStyle(
              color: kleur,
              fontSize: groot ? 18 : 12,
              fontWeight: vet ? FontWeight.w900 : FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabelCel(
    String tekst, {
    bool kop = false,
    bool rechts = false,
    bool vet = false,
    Color kleur = _tekstDonker,
    int maxRegels = 2,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: kop ? 7 : 8),
      child: Text(
        tekst,
        textAlign: rechts ? TextAlign.right : TextAlign.left,
        maxLines: maxRegels,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: kop ? _tekstGrijs : kleur,
          fontSize: kop ? 9.5 : 10.5,
          height: 1.25,
          fontWeight: kop || vet ? FontWeight.w900 : FontWeight.w600,
        ),
      ),
    );
  }

  Widget _basisKaart({
    required Widget child,
    Color achtergrond = Colors.white,
    Color randKleur = _rand,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: achtergrond,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: randKleur),
      ),
      child: child,
    );
  }

  Widget _bouwLegeKaart(String tekst) {
    return _basisKaart(
      child: Text(
        tekst,
        style: const TextStyle(
          color: _tekstGrijs,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static String _bedragMetPercentage(
    double bedrag,
    double percentage, {
    bool negatief = false,
  }) {
    if (bedrag <= 0.0 && percentage <= 0.0) return _euro(0.0);
    final prefix = negatief ? '- ' : '+ ';
    return '$prefix${_euro(bedrag)}\n${_percentage(percentage)}%';
  }

  static String _euro(double waarde) {
    final veilig = waarde.isFinite ? waarde : 0.0;
    return '€ ${veilig.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  static String _percentage(double waarde) {
    final veilig = waarde.isFinite ? waarde : 0.0;
    return veilig
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '')
        .replaceAll('.', ',');
  }

  static String _datum(DateTime waarde) {
    return '${waarde.day.toString().padLeft(2, '0')}/'
        '${waarde.month.toString().padLeft(2, '0')}/${waarde.year}';
  }
}

class _ArtikelTabelTotalen {
  const _ArtikelTabelTotalen({
    required this.aantal,
    required this.basisPerStuk,
    required this.winstPerStuk,
    required this.kortingPerStuk,
    required this.totaalPerStuk,
    required this.positieTotaal,
  });

  final int aantal;
  final double basisPerStuk;
  final double winstPerStuk;
  final double kortingPerStuk;
  final double totaalPerStuk;
  final double positieTotaal;

  factory _ArtikelTabelTotalen.van(
    Iterable<OffertePrijsOverzichtArtikel> artikelen,
  ) {
    var aantal = 0;
    var basisPerStuk = 0.0;
    var winstPerStuk = 0.0;
    var kortingPerStuk = 0.0;
    var totaalPerStuk = 0.0;
    var positieTotaal = 0.0;

    for (final artikel in artikelen) {
      aantal += artikel.aantal;
      basisPerStuk += artikel.basisPrijsPerStukExclBtw;
      winstPerStuk += artikel.winstmargePerStukExclBtw;
      kortingPerStuk += artikel.kortingPerStukExclBtw;
      totaalPerStuk += artikel.totaalPerStukExclBtw;
      positieTotaal += artikel.totaalExclBtw;
    }

    double rond(double waarde) {
      if (!waarde.isFinite) return 0.0;
      return (waarde * 100.0).roundToDouble() / 100.0;
    }

    return _ArtikelTabelTotalen(
      aantal: aantal,
      basisPerStuk: rond(basisPerStuk),
      winstPerStuk: rond(winstPerStuk),
      kortingPerStuk: rond(kortingPerStuk),
      totaalPerStuk: rond(totaalPerStuk),
      positieTotaal: rond(positieTotaal),
    );
  }
}

class _OffertePrijsOverzichtPdfPreviewPagina extends StatefulWidget {
  const _OffertePrijsOverzichtPdfPreviewPagina({required this.data});

  final OffertePrijsOverzichtData data;

  @override
  State<_OffertePrijsOverzichtPdfPreviewPagina> createState() {
    return _OffertePrijsOverzichtPdfPreviewPaginaState();
  }
}

class _OffertePrijsOverzichtPdfPreviewPaginaState
    extends State<_OffertePrijsOverzichtPdfPreviewPagina> {
  static const Color _groen = Color(0xFF0B7A3B);

  late Future<Uint8List> _pdfFuture;
  int _versie = 0;

  @override
  void initState() {
    super.initState();
    _pdfFuture = prijs_pdf.OffertePrijsOverzichtPdfService.bouwPdf(widget.data);
  }

  void _vernieuw() {
    setState(() {
      _versie++;
      _pdfFuture = prijs_pdf.OffertePrijsOverzichtPdfService.bouwPdf(
        widget.data,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final veiligeNaam = widget.data.klantNaam.trim().replaceAll(
      RegExp(r'[^a-zA-Z0-9_-]+'),
      '_',
    );
    final nummer = widget.data.offerteNummer.trim().isEmpty
        ? 'zonder_nummer'
        : widget.data.offerteNummer.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: _groen,
        foregroundColor: Colors.white,
        title: const Text(
          'PDF · prijs- en margeoverzicht',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'PDF vernieuwen',
            onPressed: _vernieuw,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final beschikbareBreedte = math
              .max(320.0, constraints.maxWidth - 24)
              .toDouble();
          final beschikbareHoogte = math
              .max(360.0, constraints.maxHeight - 88)
              .toDouble();
          final verhouding =
              PdfPageFormat.a4.landscape.width /
              PdfPageFormat.a4.landscape.height;
          final breedteOpBasisVanHoogte = beschikbareHoogte * verhouding;
          final passendeBreedte = math
              .min(beschikbareBreedte, breedteOpBasisVanHoogte)
              .toDouble();

          return PdfPreview(
            key: ValueKey<int>(_versie),
            initialPageFormat: PdfPageFormat.a4.landscape,
            maxPageWidth: passendeBreedte,
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            allowPrinting: true,
            allowSharing: true,
            pdfFileName: veiligeNaam.isEmpty
                ? 'Thimaco_prijsoverzicht_$nummer.pdf'
                : 'Thimaco_prijsoverzicht_${nummer}_$veiligeNaam.pdf',
            build: (_) => _pdfFuture,
            loadingWidget: const Center(
              child: CircularProgressIndicator(color: _groen),
            ),
            onError: (context, fout) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Het prijs- en margeoverzicht kon niet worden opgebouwd.\n\n$fout',
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
}
