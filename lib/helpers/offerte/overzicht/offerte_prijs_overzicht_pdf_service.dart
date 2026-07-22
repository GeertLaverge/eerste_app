import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'offerte_prijs_overzicht_model.dart';

class OffertePrijsOverzichtPdfService {
  const OffertePrijsOverzichtPdfService._();

  static const PdfColor _groen = PdfColor.fromInt(0xFF0B7A3B);
  static const PdfColor _lichtGroen = PdfColor.fromInt(0xFFE7F6EC);
  static const PdfColor _oranje = PdfColor.fromInt(0xFFF15A24);
  static const PdfColor _oranjeLicht = PdfColor.fromInt(0xFFFFF7ED);
  static const PdfColor _rand = PdfColor.fromInt(0xFFE5E7EB);
  static const PdfColor _tekstDonker = PdfColor.fromInt(0xFF111827);
  static const PdfColor _tekstGrijs = PdfColor.fromInt(0xFF6B7280);
  static const PdfColor _achtergrond = PdfColor.fromInt(0xFFF8FAFC);
  static const PdfColor _wit = PdfColor.fromInt(0xFFFFFFFF);

  static const String _logoAsset = 'assets/offerte/thimaco_logo.png';

  static Future<Uint8List> bouwPdf(OffertePrijsOverzichtData data) async {
    pw.MemoryImage? logo;
    try {
      final logoData = await rootBundle.load(_logoAsset);
      logo = pw.MemoryImage(
        logoData.buffer.asUint8List(
          logoData.offsetInBytes,
          logoData.lengthInBytes,
        ),
      );
    } catch (_) {
      logo = null;
    }

    final normaal = await PdfGoogleFonts.notoSansRegular();
    final vet = await PdfGoogleFonts.notoSansBold();
    final thema = pw.ThemeData.withFont(base: normaal, bold: vet);
    final document = pw.Document(
      title: 'Intern prijs- en margeoverzicht',
      author: 'Thimaco',
      creator: 'Thimaco',
      subject: data.klantNaam,
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        theme: thema,
        margin: const pw.EdgeInsets.fromLTRB(22, 20, 22, 22),
        header: (context) =>
            _kop(data, logo: logo, compact: context.pageNumber > 1),
        footer: _voettekst,
        build: (context) => <pw.Widget>[
          _samenvatting(data),
          pw.SizedBox(height: 10),
          _sectieTitel(
            titel: 'Artikelen',
            subtitel:
                'Alle posities onder elkaar, gevolgd door één gezamenlijke totaalregel.',
          ),
          pw.SizedBox(height: 5),
          if (data.hoofdArtikelen.isEmpty)
            _legeMelding('Geen prijsdragende hoofdartikelen gevonden.')
          else
            _artikelenTabel(data.hoofdArtikelen),
          pw.SizedBox(height: 10),
          _prijsregelsOverzicht(data.hoofdPrijsregels),
          pw.SizedBox(height: 10),
          _financieleSamenvatting(data),
          if (data.optieArtikelen.isNotEmpty ||
              data.optiePrijsregels.isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 12),
            _sectieTitel(
              titel: 'Opties',
              subtitel:
                  'Optionele bedragen zijn informatief en tellen niet mee in het eindtotaal.',
              accent: _oranje,
              achtergrond: _oranjeLicht,
            ),
            pw.SizedBox(height: 5),
            if (data.optieArtikelen.isNotEmpty)
              _artikelenTabel(data.optieArtikelen, isOptie: true),
            if (data.optiePrijsregels.isNotEmpty) ...<pw.Widget>[
              pw.SizedBox(height: 8),
              _prijsregelsOverzicht(data.optiePrijsregels, isOptie: true),
            ],
          ],
        ],
      ),
    );

    return document.save();
  }

  static pw.Widget _kop(
    OffertePrijsOverzichtData data, {
    required pw.MemoryImage? logo,
    required bool compact,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 9),
      padding: pw.EdgeInsets.symmetric(
        horizontal: 11,
        vertical: compact ? 6 : 8,
      ),
      decoration: pw.BoxDecoration(
        color: _achtergrond,
        border: pw.Border.all(color: _rand, width: 0.7),
        borderRadius: pw.BorderRadius.circular(7),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: <pw.Widget>[
          if (logo != null)
            pw.SizedBox(
              width: 82,
              height: 30,
              child: pw.Image(logo, fit: pw.BoxFit.contain),
            )
          else
            pw.Container(
              width: 32,
              height: 32,
              alignment: pw.Alignment.center,
              decoration: pw.BoxDecoration(
                color: _groen,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text(
                'T',
                style: pw.TextStyle(
                  color: _wit,
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Text(
                  'Intern prijs- en margeoverzicht',
                  style: pw.TextStyle(
                    color: _tekstDonker,
                    fontSize: compact ? 11.5 : 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 1.5),
                pw.Text(
                  <String>[
                    if (data.klantNaam.isNotEmpty) data.klantNaam,
                    if (data.klantAdres.isNotEmpty) data.klantAdres,
                  ].join(' · '),
                  style: const pw.TextStyle(color: _tekstGrijs, fontSize: 7.2),
                ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: <pw.Widget>[
              if (data.offerteNummer.isNotEmpty)
                pw.Text(
                  'Offerte ${data.offerteNummer}',
                  style: pw.TextStyle(
                    color: _tekstDonker,
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              pw.Text(
                _datum(data.opgemaaktOp),
                style: const pw.TextStyle(color: _tekstGrijs, fontSize: 7.2),
              ),
              pw.Text(
                'INTERN DOCUMENT',
                style: pw.TextStyle(
                  color: _oranje,
                  fontSize: 6.5,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _samenvatting(OffertePrijsOverzichtData data) {
    final kaarten = <pw.Widget>[
      _samenvattingKaart(
        label: 'Artikelen',
        waarde: '${data.aantalArtikelen}',
        detail: '${data.aantalPosities} posities',
      ),
      _samenvattingKaart(
        label: 'Basisprijs',
        waarde: _euro(data.basisTotaalExclBtw),
        detail: 'hoofdartikelen',
      ),
      _samenvattingKaart(
        label: 'Prijsregels',
        waarde: _euro(data.prijsregelsTotaalExclBtw),
        detail: 'alle gekoppelde regels',
      ),
      _samenvattingKaart(
        label: 'Winstmarge',
        waarde: '+ ${_euro(data.totaleWinstmargeExclBtw)}',
        detail: 'op basisprijs',
        accent: _groen,
      ),
      _samenvattingKaart(
        label: 'Korting',
        waarde: '- ${_euro(data.totaleKortingExclBtw)}',
        detail: 'alleen basisprijs',
        accent: _oranje,
      ),
      _samenvattingKaart(
        label: 'Eindtotaal',
        waarde: _euro(data.eindtotaalExclBtw),
        detail: 'excl. btw',
        accent: _groen,
        opvallend: true,
      ),
    ];

    return pw.Row(
      children: kaarten
          .expand(
            (kaart) => <pw.Widget>[
              pw.Expanded(child: kaart),
              if (kaart != kaarten.last) pw.SizedBox(width: 5),
            ],
          )
          .toList(growable: false),
    );
  }

  static pw.Widget _samenvattingKaart({
    required String label,
    required String waarde,
    required String detail,
    PdfColor accent = _tekstDonker,
    bool opvallend = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: pw.BoxDecoration(
        color: opvallend ? _lichtGroen : _wit,
        border: pw.Border.all(color: opvallend ? _groen : _rand, width: 0.7),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            label,
            style: const pw.TextStyle(color: _tekstGrijs, fontSize: 6.8),
          ),
          pw.SizedBox(height: 1),
          pw.Text(
            waarde,
            style: pw.TextStyle(
              color: accent,
              fontSize: opvallend ? 10.5 : 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            detail,
            style: const pw.TextStyle(color: _tekstGrijs, fontSize: 6.2),
          ),
        ],
      ),
    );
  }

  static pw.Widget _sectieTitel({
    required String titel,
    required String subtitel,
    PdfColor accent = _groen,
    PdfColor achtergrond = _lichtGroen,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: pw.BoxDecoration(
        color: achtergrond,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Container(
            width: 4,
            height: 24,
            decoration: pw.BoxDecoration(
              color: accent,
              borderRadius: pw.BorderRadius.circular(2),
            ),
          ),
          pw.SizedBox(width: 7),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Text(
                  titel,
                  style: pw.TextStyle(
                    color: accent,
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 1),
                pw.Text(
                  subtitel,
                  style: const pw.TextStyle(color: _tekstGrijs, fontSize: 6.7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _artikelenTabel(
    List<OffertePrijsOverzichtArtikel> artikelen, {
    bool isOptie = false,
  }) {
    final totalen = _PdfArtikelTotalen.van(artikelen);
    final accent = isOptie ? _oranje : _groen;
    final totaalAchtergrond = isOptie ? _oranjeLicht : _lichtGroen;

    final rijen = <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: _achtergrond),
        children: <pw.Widget>[
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
        return pw.TableRow(
          decoration: pw.BoxDecoration(
            color: entry.key.isOdd ? _achtergrond : _wit,
          ),
          children: <pw.Widget>[
            _tabelCel(artikel.positieLabel, vet: true, kleur: accent),
            _tabelCel(artikel.artikelNaam, vet: true),
            _tabelCel(
              artikel.compacteOmschrijving.isEmpty
                  ? '—'
                  : artikel.compacteOmschrijving,
            ),
            _tabelCel('${artikel.aantal}', rechts: true),
            _tabelCel(_euro(artikel.basisPrijsPerStukExclBtw), rechts: true),
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
      pw.TableRow(
        decoration: pw.BoxDecoration(color: totaalAchtergrond),
        children: <pw.Widget>[
          _tabelCel(''),
          _tabelCel(
            isOptie ? 'Totaal opties' : 'Totaal artikelen',
            vet: true,
            kleur: accent,
          ),
          _tabelCel('${artikelen.length} posities', vet: true),
          _tabelCel('${totalen.aantal}', rechts: true, vet: true),
          _tabelCel(_euro(totalen.basisPerStuk), rechts: true, vet: true),
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
          _tabelCel(_euro(totalen.totaalPerStuk), rechts: true, vet: true),
          _tabelCel(
            _euro(totalen.positieTotaal),
            rechts: true,
            vet: true,
            kleur: accent,
          ),
        ],
      ),
    ];

    return pw.Table(
      columnWidths: const <int, pw.TableColumnWidth>{
        0: pw.FixedColumnWidth(45),
        1: pw.FixedColumnWidth(76),
        2: pw.FlexColumnWidth(1.8),
        3: pw.FixedColumnWidth(34),
        4: pw.FixedColumnWidth(62),
        5: pw.FixedColumnWidth(62),
        6: pw.FixedColumnWidth(62),
        7: pw.FixedColumnWidth(67),
        8: pw.FixedColumnWidth(72),
      },
      border: const pw.TableBorder(
        horizontalInside: pw.BorderSide(color: _rand, width: 0.45),
        top: pw.BorderSide(color: _rand, width: 0.55),
        bottom: pw.BorderSide(color: _rand, width: 0.55),
        left: pw.BorderSide(color: _rand, width: 0.55),
        right: pw.BorderSide(color: _rand, width: 0.55),
      ),
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: rijen,
    );
  }

  static pw.Widget _prijsregelsOverzicht(
    List<OffertePrijsOverzichtSamengevoegdeRegel> regels, {
    bool isOptie = false,
  }) {
    final accent = isOptie ? _oranje : _groen;
    final achtergrond = isOptie ? _oranjeLicht : _lichtGroen;
    final titel = isOptie
        ? 'Optionele prijsregels'
        : 'Prijsregels samengevoegd';
    final subtitel = isOptie
        ? 'Elke optionele omschrijving één keer, met het gezamenlijke totaal.'
        : 'Elke unieke omschrijving staat één keer. Terugkerende bedragen zijn opgeteld.';

    final onderdelen = <pw.Widget>[
      _sectieTitel(
        titel: titel,
        subtitel: subtitel,
        accent: accent,
        achtergrond: achtergrond,
      ),
      pw.SizedBox(height: 5),
    ];

    if (regels.isEmpty) {
      onderdelen.add(_legeMelding('Geen gekoppelde prijsregels gevonden.'));
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: onderdelen,
      );
    }

    for (final type in OffertePrijsOverzichtRegelType.values) {
      final typeRegels = regels
          .where((regel) => regel.type == type)
          .toList(growable: false);
      if (typeRegels.isEmpty) continue;

      final totaal = typeRegels.fold<double>(
        0.0,
        (som, regel) => som + regel.totaalExclBtw,
      );
      onderdelen
        ..add(
          pw.Row(
            children: <pw.Widget>[
              pw.Expanded(
                child: pw.Text(
                  type.label,
                  style: pw.TextStyle(
                    color: accent,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Text(
                _euro(totaal),
                style: pw.TextStyle(
                  color: accent,
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        )
        ..add(pw.SizedBox(height: 3))
        ..add(_prijsregelsTabel(typeRegels, accent))
        ..add(pw.SizedBox(height: 7));
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: onderdelen,
    );
  }

  static pw.Widget _prijsregelsTabel(
    List<OffertePrijsOverzichtSamengevoegdeRegel> regels,
    PdfColor accent,
  ) {
    return pw.Table(
      columnWidths: const <int, pw.TableColumnWidth>{
        0: pw.FlexColumnWidth(4),
        1: pw.FlexColumnWidth(5),
        2: pw.FixedColumnWidth(82),
      },
      border: const pw.TableBorder(
        horizontalInside: pw.BorderSide(color: _rand, width: 0.4),
        top: pw.BorderSide(color: _rand, width: 0.5),
        bottom: pw.BorderSide(color: _rand, width: 0.5),
        left: pw.BorderSide(color: _rand, width: 0.5),
        right: pw.BorderSide(color: _rand, width: 0.5),
      ),
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: <pw.TableRow>[
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _achtergrond),
          children: <pw.Widget>[
            _tabelCel('Omschrijving', kop: true),
            _tabelCel('Toegepast op', kop: true),
            _tabelCel('Totaal', kop: true, rechts: true),
          ],
        ),
        ...regels.asMap().entries.map((entry) {
          final regel = entry.value;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: entry.key.isOdd ? _achtergrond : _wit,
            ),
            children: <pw.Widget>[
              _tabelCel(regel.omschrijving, vet: true),
              _tabelCel(regel.toepassingTekst, kleur: _tekstGrijs),
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
    );
  }

  static pw.Widget _financieleSamenvatting(OffertePrijsOverzichtData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: _lichtGroen,
        border: pw.Border.all(color: _groen, width: 0.8),
        borderRadius: pw.BorderRadius.circular(7),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Text(
                  'Financiële samenvatting',
                  style: pw.TextStyle(
                    color: _groen,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'De korting wordt alleen op de basisprijs na winstmarge berekend. Technische, vrije en projectbrede prijsregels blijven buiten de korting.',
                  style: const pw.TextStyle(
                    color: _tekstGrijs,
                    fontSize: 7,
                    lineSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 28),
          pw.SizedBox(
            width: 300,
            child: pw.Column(
              children: <pw.Widget>[
                _totaalRij('Basisprijs', data.basisTotaalExclBtw),
                _totaalRij(
                  'Technische prijsregels',
                  data.technischePrijsregelsTotaalExclBtw,
                ),
                _totaalRij(
                  'Vrije prijsregels',
                  data.vrijePrijsregelsTotaalExclBtw,
                ),
                _totaalRij(
                  'Prijsregels voor alle artikelen',
                  data.alleArtikelenPrijsregelsTotaalExclBtw,
                ),
                _totaalRij(
                  'Winstmarge',
                  data.totaleWinstmargeExclBtw,
                  prefix: '+ ',
                  kleur: _groen,
                ),
                _totaalRij(
                  'Korting (alleen op basisprijs)',
                  data.totaleKortingExclBtw,
                  prefix: '- ',
                  kleur: _oranje,
                ),
                pw.Divider(height: 8, color: _groen),
                _totaalRij(
                  'Eindtotaal excl. btw',
                  data.eindtotaalExclBtw,
                  kleur: _groen,
                  vet: true,
                  groot: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _totaalRij(
    String label,
    double bedrag, {
    String prefix = '',
    PdfColor kleur = _tekstDonker,
    bool vet = false,
    bool groot = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: <pw.Widget>[
          pw.Expanded(
            child: pw.Text(
              label,
              style: pw.TextStyle(
                color: _tekstDonker,
                fontSize: groot ? 9 : 7.2,
                fontWeight: vet ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
          pw.Text(
            '$prefix${_euro(bedrag)}',
            style: pw.TextStyle(
              color: kleur,
              fontSize: groot ? 11 : 7.5,
              fontWeight: vet ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _tabelCel(
    String tekst, {
    bool kop = false,
    bool rechts = false,
    bool vet = false,
    PdfColor kleur = _tekstDonker,
  }) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(horizontal: 4, vertical: kop ? 4 : 4.5),
      child: pw.Text(
        tekst,
        textAlign: rechts ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(
          color: kop ? _tekstGrijs : kleur,
          fontSize: kop ? 6.2 : 6.5,
          lineSpacing: 1.2,
          fontWeight: kop || vet ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _legeMelding(String tekst) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(9),
      decoration: pw.BoxDecoration(
        color: _achtergrond,
        border: pw.Border.all(color: _rand, width: 0.6),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Text(
        tekst,
        style: const pw.TextStyle(color: _tekstGrijs, fontSize: 7.2),
      ),
    );
  }

  static pw.Widget _voettekst(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      padding: const pw.EdgeInsets.only(top: 5),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _rand, width: 0.5)),
      ),
      child: pw.Row(
        children: <pw.Widget>[
          pw.Expanded(
            child: pw.Text(
              'Thimaco · intern prijs- en margeoverzicht',
              style: const pw.TextStyle(color: _tekstGrijs, fontSize: 6.5),
            ),
          ),
          pw.Text(
            'Pagina ${context.pageNumber} van ${context.pagesCount}',
            style: const pw.TextStyle(color: _tekstGrijs, fontSize: 6.5),
          ),
        ],
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

class _PdfArtikelTotalen {
  const _PdfArtikelTotalen({
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

  factory _PdfArtikelTotalen.van(
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

    return _PdfArtikelTotalen(
      aantal: aantal,
      basisPerStuk: rond(basisPerStuk),
      winstPerStuk: rond(winstPerStuk),
      kortingPerStuk: rond(kortingPerStuk),
      totaalPerStuk: rond(totaalPerStuk),
      positieTotaal: rond(positieTotaal),
    );
  }
}
