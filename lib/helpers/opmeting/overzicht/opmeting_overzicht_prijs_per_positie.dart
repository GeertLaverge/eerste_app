// THIMACO-CONTROLE: PRIJS-PER-POSITIE-KOPIEREN-PLAKKEN-20260813
// THIMACO-CONTROLE: PRIJS-PER-POSITIE-BIBLIOTHEEKKEUZE-20260813
// THIMACO-CONTROLE: PRIJS-PER-POSITIE-TABEL-UI-20260813
// THIMACO-CONTROLE: PRIJS-PER-POSITIE-COMPACTE-PRIJSBEREKENING-20260813
// THIMACO-CONTROLE: GROEPSGEWIJZE-WINST-KORTING-UI-VERWIJDERD-20260813
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_storage.dart';
import '../../offerte/prijzen/offerte_artikel_prijs_data_model.dart';
import '../../offerte/prijzen/offerte_prijs_per_artikel_template_model.dart';
import '../../offerte/prijzen/offerte_berekening_resultaat.dart';
import 'opmeting_overzicht_artikel_layout_helper.dart';

/// Centrale prijszone van één positie in het opmetingsoverzicht.
///
/// In deze fase blijft de bestaande opslag en berekening behouden. Alleen de
/// bediening is compacter gemaakt: prijs per stuk, winstmarge en korting staan
/// rechtstreeks in dezelfde prijsberekeningskaart. De oude knoppen/checkboxen
/// om winst of korting op meerdere artikelen toe te passen zijn hier bewust
/// niet meer aanwezig.
class OpmetingOverzichtPrijsPerPositie {
  const OpmetingOverzichtPrijsPerPositie._();

  static double berekenSamenvattingHoogte({
    required bool berekenPrijzen,
    required OfferteBerekeningResultaat prijsResultaat,
    required bool toonPrijsPerStukVeld,
    required bool toonWinstEnKorting,
    required bool toonTechnischePrijsregels,
    required bool heeftAlgemenePrijsUitsplitsing,
  }) {
    if (!berekenPrijzen) {
      return 0.0;
    }

    final aantalSamenvattingRegels =
        (heeftAlgemenePrijsUitsplitsing ? 2 : (toonPrijsPerStukVeld ? 0 : 1)) +
        (toonTechnischePrijsregels
            ? prijsResultaat.technischePrijsregels.length
            : 0) +
        prijsResultaat.vrijeArtikelPrijsregels.length +
        prijsResultaat.verdeeldePrijsregels.length;

    final invoerHoogte =
        (toonPrijsPerStukVeld ? 52.0 : 0.0) +
        (toonWinstEnKorting ? 104.0 : 0.0);
    final prijsPerPositieHoogte =
        54.0 + (prijsResultaat.prijsPerPositieRegels.length * 112.0);

    return 84.0 +
        invoerHoogte +
        (aantalSamenvattingRegels * 34.0) +
        prijsPerPositieHoogte;
  }

  static List<Widget> bouwWidgets({
    required bool berekenPrijzen,
    required OfferteArtikelPrijsDataModel prijsData,
    required OfferteBerekeningResultaat prijsResultaat,
    required int aantal,
    required bool toonPrijsPerStukVeld,
    required bool toonWinstEnKorting,
    required bool toonTechnischePrijsregelsInSamenvatting,
    required bool kortingToestaan,
    required ValueChanged<double> onPrijsGewijzigd,
    required ValueChanged<double> onWinstmargeGewijzigd,
    required ValueChanged<double> onKortingGewijzigd,
    required ValueChanged<List<OffertePrijsPerPositieRegelModel>>
    onPrijsPerPositieRegelsGewijzigd,
    String? basisOmschrijving,
    double? algemeneVerkoopPrijsTotaalExclBtw,
    double? algemeneAankoopPrijsTotaalExclBtw,
  }) {
    if (!berekenPrijzen) {
      return const <Widget>[];
    }

    return <Widget>[
      _PrijsBerekeningKaart(
        resultaat: prijsResultaat,
        prijsData: prijsData,
        aantal: aantal,
        toonPrijsPerStukVeld: toonPrijsPerStukVeld,
        toonWinstEnKorting: toonWinstEnKorting,
        toonTechnischePrijsregels: toonTechnischePrijsregelsInSamenvatting,
        kortingToestaan: kortingToestaan,
        onPrijsGewijzigd: onPrijsGewijzigd,
        onWinstmargeGewijzigd: onWinstmargeGewijzigd,
        onKortingGewijzigd: onKortingGewijzigd,
        onPrijsPerPositieRegelsGewijzigd: onPrijsPerPositieRegelsGewijzigd,
        basisOmschrijving: basisOmschrijving,
        algemeneVerkoopPrijsTotaalExclBtw: algemeneVerkoopPrijsTotaalExclBtw,
        algemeneAankoopPrijsTotaalExclBtw: algemeneAankoopPrijsTotaalExclBtw,
      ),
    ];
  }
}

class _PrijsBerekeningKaart extends StatelessWidget {
  const _PrijsBerekeningKaart({
    required this.resultaat,
    required this.prijsData,
    required this.aantal,
    required this.toonPrijsPerStukVeld,
    required this.toonWinstEnKorting,
    required this.toonTechnischePrijsregels,
    required this.kortingToestaan,
    required this.onPrijsGewijzigd,
    required this.onWinstmargeGewijzigd,
    required this.onKortingGewijzigd,
    required this.onPrijsPerPositieRegelsGewijzigd,
    this.basisOmschrijving,
    this.algemeneVerkoopPrijsTotaalExclBtw,
    this.algemeneAankoopPrijsTotaalExclBtw,
  });

  final OfferteBerekeningResultaat resultaat;
  final OfferteArtikelPrijsDataModel prijsData;
  final int aantal;
  final bool toonPrijsPerStukVeld;
  final bool toonWinstEnKorting;
  final bool toonTechnischePrijsregels;
  final bool kortingToestaan;
  final ValueChanged<double> onPrijsGewijzigd;
  final ValueChanged<double> onWinstmargeGewijzigd;
  final ValueChanged<double> onKortingGewijzigd;
  final ValueChanged<List<OffertePrijsPerPositieRegelModel>>
  onPrijsPerPositieRegelsGewijzigd;
  final String? basisOmschrijving;
  final double? algemeneVerkoopPrijsTotaalExclBtw;
  final double? algemeneAankoopPrijsTotaalExclBtw;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _rand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'Prijsberekening',
            style: TextStyle(
              color: _groen,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          if (toonPrijsPerStukVeld) ...<Widget>[
            _CompactPrijsRij(
              label: 'Prijs per stuk',
              veld: _PrijsPerStukVeld(
                beginPrijs: prijsData.prijsPerStukExclBtw,
                onGewijzigd: onPrijsGewijzigd,
              ),
              rechterTekst: aantal > 1
                  ? '$aantal stuks · € ${_bedrag(resultaat.basisTotaalExclBtw)}'
                  : '€ ${_bedrag(resultaat.basisTotaalExclBtw)}',
            ),
            const SizedBox(height: 7),
          ] else if (algemeneVerkoopPrijsTotaalExclBtw != null &&
              algemeneAankoopPrijsTotaalExclBtw != null) ...<Widget>[
            _PrijsSamenvattingRij(
              omschrijving: 'Totaal verkoopprijzen',
              bedrag: algemeneVerkoopPrijsTotaalExclBtw!,
            ),
            _PrijsSamenvattingRij(
              omschrijving: 'Totaal aankoopprijzen',
              bedrag: algemeneAankoopPrijsTotaalExclBtw!,
            ),
            const SizedBox(height: 4),
          ] else ...<Widget>[
            _PrijsSamenvattingRij(
              omschrijving: basisOmschrijving?.trim().isNotEmpty == true
                  ? basisOmschrijving!.trim()
                  : 'Basisprijs',
              bedrag: resultaat.basisTotaalExclBtw,
            ),
            const SizedBox(height: 4),
          ],
          if (toonWinstEnKorting) ...<Widget>[
            _CompactPrijsRij(
              label: 'Winstmarge',
              veld: _PercentageVeld(
                beginPercentage: prijsData.artikelWinstmargePercentage,
                maximum: 500,
                onGewijzigd: onWinstmargeGewijzigd,
              ),
              rechterTekst: resultaat.winstmargeBedragExclBtw > 0
                  ? '+ € ${_bedrag(resultaat.winstmargeBedragExclBtw)}'
                  : '€ 0,00',
            ),
            if (kortingToestaan) ...<Widget>[
              const SizedBox(height: 7),
              _CompactPrijsRij(
                label: 'Korting',
                veld: _PercentageVeld(
                  beginPercentage: prijsData.artikelKortingPercentage,
                  maximum: 100,
                  onGewijzigd: onKortingGewijzigd,
                ),
                rechterTekst: resultaat.kortingBedragExclBtw > 0
                    ? '- € ${_bedrag(resultaat.kortingBedragExclBtw)}'
                    : '€ 0,00',
                accentRechts: resultaat.kortingBedragExclBtw > 0,
              ),
            ],
            const SizedBox(height: 7),
          ],
          if (toonTechnischePrijsregels)
            ...resultaat.technischePrijsregels.map((prijsregel) {
              final omschrijving = prijsregel.isOptie
                  ? '${prijsregel.omschrijving} · technische keuze · optie'
                  : '${prijsregel.omschrijving} · technische keuze';
              return _PrijsSamenvattingRij(
                omschrijving: omschrijving,
                bedrag: prijsregel.totaalExclBtw,
                optie: prijsregel.isOptie,
              );
            }),
          ...resultaat.vrijeArtikelPrijsregels.map((prijsregel) {
            final omschrijving = prijsregel.isOptie
                ? '${prijsregel.omschrijving} · optie op offerte'
                : prijsregel.toonAfzonderlijkePrijsOpOfferte
                ? '${prijsregel.omschrijving} · apart op offerte'
                : '${prijsregel.omschrijving} · verwerkt in artikelprijs';
            return _PrijsSamenvattingRij(
              omschrijving: omschrijving,
              bedrag: prijsregel.totaalExclBtw,
              optie: prijsregel.isOptie,
            );
          }),
          ...resultaat.verdeeldePrijsregels.map((prijsregel) {
            final aantalArtikelen = prijsregel.verdeeldOverAantalArtikelen;
            final verdelingTekst = aantalArtikelen > 0
                ? ' · verdeeld over $aantalArtikelen artikelen'
                : ' · verdeelde projectkost';

            return _PrijsSamenvattingRij(
              omschrijving: '${prijsregel.omschrijving}$verdelingTekst',
              bedrag: prijsregel.totaalExclBtw,
              intern: true,
            );
          }),
          const SizedBox(height: 8),
          _PrijsPerPositieRegelsBlok(
            regels: prijsData.prijsPerPositieRegels,
            onGewijzigd: onPrijsPerPositieRegelsGewijzigd,
          ),
          const Divider(height: 16, color: _rand),
          _PrijsSamenvattingRij(
            omschrijving: 'Totaal positie excl. btw',
            bedrag: resultaat.totaalExclBtw,
            vet: true,
          ),
        ],
      ),
    );
  }

  static String _bedrag(double waarde) {
    return waarde.toStringAsFixed(2).replaceAll('.', ',');
  }
}

class _CompactPrijsRij extends StatelessWidget {
  const _CompactPrijsRij({
    required this.label,
    required this.veld,
    required this.rechterTekst,
    this.accentRechts = false,
  });

  final String label;
  final Widget veld;
  final String rechterTekst;
  final bool accentRechts;

  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);
  static const Color _groen = Color(0xFF0B7A3B);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 86,
          child: Text(
            label,
            style: const TextStyle(
              color: _tekstGrijs,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(width: 116, child: veld),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            rechterTekst,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: accentRechts ? _groen : _tekstDonker,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

enum _PrijsPerPositieToevoegActie { handmatig, uitBibliotheek, plakken }

class _PrijsPerPositieRegelsBlok extends StatelessWidget {
  const _PrijsPerPositieRegelsBlok({
    required this.regels,
    required this.onGewijzigd,
  });

  final List<OffertePrijsPerPositieRegelModel> regels;
  final ValueChanged<List<OffertePrijsPerPositieRegelModel>> onGewijzigd;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  // Sessiegeheugen: een gekopieerde regel is alleen een momentopname.
  // Bij plakken krijgt de regel altijd een nieuw lokaal ID en is hij daarna
  // volledig onafhankelijk van de bronpositie.
  static OffertePrijsPerPositieRegelModel? _gekopieerdeRegel;

  static const List<String> _eenheden = <String>[
    'st',
    'uur',
    'L/M',
    'KM',
    'm²',
    'L',
    'L en R',
    'L en B',
    'B en R',
    'rondom oppervlakte',
  ];

  String _nieuwRegelId() {
    return 'positie_${DateTime.now().microsecondsSinceEpoch}';
  }

  void _voegHandmatigeRegelToe() {
    final nieuweRegel = OffertePrijsPerPositieRegelModel(
      id: _nieuwRegelId(),
      omschrijving: '',
      type: OffertePrijsPerPositieType.verkoop,
      aantal: 1,
      eenheid: 'st',
      eenheidsPrijsExclBtw: 0,
      winstPercentage: 0,
      offerteWeergave: OffertePrijsPerPositieWeergave.uit,
    );

    onGewijzigd(<OffertePrijsPerPositieRegelModel>[...regels, nieuweRegel]);
  }

  Future<void> _openRegelToevoegen(BuildContext context) async {
    final actie = await showDialog<_PrijsPerPositieToevoegActie>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Prijsregel toevoegen',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE7F6EC),
                    foregroundColor: _groen,
                    child: Icon(Icons.edit_outlined),
                  ),
                  title: const Text(
                    'Handmatig',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text(
                    'Start met een lege prijsregel en vul alles op deze positie in.',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(
                    dialogContext,
                  ).pop(_PrijsPerPositieToevoegActie.handmatig),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE7F6EC),
                    foregroundColor: _groen,
                    child: Icon(Icons.library_books_outlined),
                  ),
                  title: const Text(
                    'Uit Prijs per artikel',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text(
                    'Neem omschrijving, A/V, eenheid en standaard winst over uit Instellingen.',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(
                    dialogContext,
                  ).pop(_PrijsPerPositieToevoegActie.uitBibliotheek),
                ),
                if (_gekopieerdeRegel != null) ...<Widget>[
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE7F6EC),
                      foregroundColor: _groen,
                      child: Icon(Icons.content_paste_rounded),
                    ),
                    title: const Text(
                      'Gekopieerde regel plakken',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      _gekopieerdeRegel!.omschrijving.trim().isEmpty
                          ? 'Plak de eerder gekopieerde prijsregel als nieuwe onafhankelijke regel.'
                          : 'Plak “${_gekopieerdeRegel!.omschrijving.trim()}” als nieuwe onafhankelijke regel.',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(
                      dialogContext,
                    ).pop(_PrijsPerPositieToevoegActie.plakken),
                  ),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuleren'),
            ),
          ],
        );
      },
    );

    if (actie == null || !context.mounted) return;

    if (actie == _PrijsPerPositieToevoegActie.handmatig) {
      _voegHandmatigeRegelToe();
      return;
    }

    if (actie == _PrijsPerPositieToevoegActie.plakken) {
      _plakGekopieerdeRegelToe(context);
      return;
    }

    await _voegRegelUitBibliotheekToe(context);
  }

  void _kopieerRegel(
    BuildContext context,
    OffertePrijsPerPositieRegelModel regel,
  ) {
    _gekopieerdeRegel = regel;

    final omschrijving = regel.omschrijving.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          omschrijving.isEmpty
              ? 'Prijsregel gekopieerd. Open + Regel op de doelpositie om te plakken.'
              : '“$omschrijving” gekopieerd. Open + Regel op de doelpositie om te plakken.',
        ),
      ),
    );
  }

  void _plakGekopieerdeRegelToe(BuildContext context) {
    final bron = _gekopieerdeRegel;
    if (bron == null) return;

    final nieuweRegel = bron.kopieMetNieuwId(_nieuwRegelId());
    onGewijzigd(<OffertePrijsPerPositieRegelModel>[...regels, nieuweRegel]);

    final omschrijving = bron.omschrijving.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          omschrijving.isEmpty
              ? 'Gekopieerde prijsregel als nieuwe onafhankelijke regel geplakt.'
              : '“$omschrijving” als nieuwe onafhankelijke regel geplakt.',
        ),
      ),
    );
  }

  Future<void> _voegRegelUitBibliotheekToe(BuildContext context) async {
    List<OffertePrijsPerArtikelTemplateModel> templates;

    try {
      templates = await AppStorage.laadOffertePrijsPerArtikelTemplates();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text('Prijs per artikel kon niet worden geladen: $e'),
        ),
      );
      return;
    }

    if (!context.mounted) return;

    if (templates.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text(
              'Nog geen prijsregels',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            content: const Text(
              'Er staan nog geen regels in Instellingen > Offerteprijzen > Prijs per artikel.',
            ),
            actions: <Widget>[
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Sluiten'),
              ),
            ],
          );
        },
      );
      return;
    }

    final gekozen = await showDialog<OffertePrijsPerArtikelTemplateModel>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Kies uit Prijs per artikel',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: SizedBox(
            width: 520,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 440),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: templates.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final template = templates[index];
                  final winstTekst = template.isAankoop
                      ? ' · winst ${_percentage(template.veiligeStandaardWinstPercentage)} %'
                      : ' · geen winst';

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 2),
                    leading: Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F6EC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        template.type.label,
                        style: const TextStyle(
                          color: _groen,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    title: Text(
                      template.omschrijving,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text('${template.eenheid}$winstTekst'),
                    trailing: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: _groen,
                    ),
                    onTap: () => Navigator.of(dialogContext).pop(template),
                  );
                },
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuleren'),
            ),
          ],
        );
      },
    );

    if (gekozen == null || !context.mounted) return;

    final nieuweRegel = gekozen.maakPositieRegel(nieuwId: _nieuwRegelId());
    onGewijzigd(<OffertePrijsPerPositieRegelModel>[...regels, nieuweRegel]);
  }

  static String _percentage(double waarde) {
    var tekst = waarde.toStringAsFixed(2).replaceAll('.', ',');
    tekst = tekst.replaceFirst(RegExp(r'0+$'), '');
    return tekst.replaceFirst(RegExp(r',$'), '');
  }

  void _vervangRegel(OffertePrijsPerPositieRegelModel gewijzigdeRegel) {
    final nieuweRegels = regels
        .map(
          (regel) => regel.id == gewijzigdeRegel.id ? gewijzigdeRegel : regel,
        )
        .toList(growable: false);
    onGewijzigd(nieuweRegels);
  }

  Future<void> _verwijderRegel(
    BuildContext context,
    OffertePrijsPerPositieRegelModel regel,
  ) async {
    final bevestigd = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Prijsregel verwijderen?'),
          content: Text(
            regel.omschrijving.trim().isEmpty
                ? 'Deze prijsregel wordt uit deze positie verwijderd.'
                : '“${regel.omschrijving.trim()}” wordt uit deze positie verwijderd.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuleren'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Verwijderen'),
            ),
          ],
        );
      },
    );

    if (bevestigd != true) return;
    onGewijzigd(
      regels.where((item) => item.id != regel.id).toList(growable: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _rand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Prijs per positie',
                  style: TextStyle(
                    color: _groen,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _openRegelToevoegen(context),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Regel'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ),
            ],
          ),
          if (regels.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(2, 2, 2, 5),
              child: Text(
                'Nog geen lokale prijsregels voor deze positie.',
                style: TextStyle(
                  color: _tekstGrijs,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ...regels.map((regel) {
              return Padding(
                key: ValueKey<String>(regel.id),
                padding: const EdgeInsets.only(top: 7),
                child: _PrijsPerPositieRegelKaart(
                  regel: regel,
                  eenheden: _eenheden,
                  onGewijzigd: _vervangRegel,
                  onKopieren: () => _kopieerRegel(context, regel),
                  onVerwijderen: () => _verwijderRegel(context, regel),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _PrijsPerPositieRegelKaart extends StatelessWidget {
  const _PrijsPerPositieRegelKaart({
    required this.regel,
    required this.eenheden,
    required this.onGewijzigd,
    required this.onKopieren,
    required this.onVerwijderen,
  });

  final OffertePrijsPerPositieRegelModel regel;
  final List<String> eenheden;
  final ValueChanged<OffertePrijsPerPositieRegelModel> onGewijzigd;
  final VoidCallback onKopieren;
  final VoidCallback onVerwijderen;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _achtergrond = Color(0xFFF9FAFB);

  List<String> get _eenhedenVoorDropdown {
    final huidige = regel.eenheid.trim().isEmpty ? 'st' : regel.eenheid.trim();
    if (eenheden.contains(huidige)) return eenheden;
    return <String>[huidige, ...eenheden];
  }

  double _leesDouble(String tekst) {
    return double.tryParse(tekst.trim().replaceAll(',', '.')) ?? 0.0;
  }

  String _getal(double waarde, {int decimalen = 2}) {
    if (!waarde.isFinite || waarde <= 0) return '';
    var tekst = waarde.toStringAsFixed(decimalen).replaceAll('.', ',');
    tekst = tekst.replaceFirst(RegExp(r'0+$'), '');
    return tekst.replaceFirst(RegExp(r',$'), '');
  }

  String _bedrag(double waarde) {
    return '€ ${waarde.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _achtergrond,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _rand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _PrijsRegelInvoerVeld(
                  sleutel: 'omschrijving_${regel.id}',
                  beginTekst: regel.omschrijving,
                  hintText: 'Omschrijving',
                  onBewaren: (waarde) {
                    onGewijzigd(regel.copyWith(omschrijving: waarde.trim()));
                  },
                ),
              ),
              const SizedBox(width: 7),
              SizedBox(
                width: 88,
                child: DropdownButtonFormField<OffertePrijsPerPositieWeergave>(
                  key: ValueKey<String>(
                    'prijsWeergave_${regel.id}_${regel.offerteWeergave.name}',
                  ),
                  initialValue: regel.offerteWeergave,
                  isDense: true,
                  decoration: _regelDecoratie(),
                  items: OffertePrijsPerPositieWeergave.values
                      .map(
                        (waarde) =>
                            DropdownMenuItem<OffertePrijsPerPositieWeergave>(
                              value: waarde,
                              child: Text(
                                waarde.label,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                      )
                      .toList(growable: false),
                  onChanged: (waarde) {
                    if (waarde == null || waarde == regel.offerteWeergave) {
                      return;
                    }
                    onGewijzigd(regel.copyWith(offerteWeergave: waarde));
                  },
                ),
              ),
              const SizedBox(width: 3),
              IconButton(
                onPressed: onKopieren,
                tooltip: 'Prijsregel kopiëren',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.copy_rounded, size: 17, color: _groen),
              ),
              IconButton(
                onPressed: onVerwijderen,
                tooltip: 'Prijsregel verwijderen',
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: Color(0xFFB91C1C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                _PrijsRegelKolom(
                  label: 'A/V',
                  breedte: 58,
                  child: DropdownButtonFormField<OffertePrijsPerPositieType>(
                    key: ValueKey<String>(
                      'prijsType_${regel.id}_${regel.type.name}',
                    ),
                    initialValue: regel.type,
                    isDense: true,
                    decoration: _regelDecoratie(),
                    items: OffertePrijsPerPositieType.values
                        .map(
                          (waarde) =>
                              DropdownMenuItem<OffertePrijsPerPositieType>(
                                value: waarde,
                                child: Text(
                                  waarde.label,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                        )
                        .toList(growable: false),
                    onChanged: (waarde) {
                      if (waarde == null || waarde == regel.type) return;
                      onGewijzigd(regel.copyWith(type: waarde));
                    },
                  ),
                ),
                _PrijsRegelKolom(
                  label: 'Aantal',
                  breedte: 68,
                  child: _PrijsRegelInvoerVeld(
                    sleutel: 'aantal_${regel.id}',
                    beginTekst: _getal(regel.aantal, decimalen: 4),
                    hintText: '1',
                    numeriek: true,
                    onBewaren: (waarde) {
                      onGewijzigd(regel.copyWith(aantal: _leesDouble(waarde)));
                    },
                  ),
                ),
                _PrijsRegelKolom(
                  label: 'Eenheid',
                  breedte: 92,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey<String>(
                      'prijsEenheid_${regel.id}_${regel.eenheid.trim()}',
                    ),
                    initialValue: regel.eenheid.trim().isEmpty
                        ? 'st'
                        : regel.eenheid.trim(),
                    isExpanded: true,
                    isDense: true,
                    decoration: _regelDecoratie(),
                    items: _eenhedenVoorDropdown
                        .map(
                          (waarde) => DropdownMenuItem<String>(
                            value: waarde,
                            child: Text(
                              waarde,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (waarde) {
                      if (waarde == null || waarde == regel.eenheid) return;
                      onGewijzigd(regel.copyWith(eenheid: waarde));
                    },
                  ),
                ),
                _PrijsRegelKolom(
                  label: 'Prijs',
                  breedte: 82,
                  child: _PrijsRegelInvoerVeld(
                    sleutel: 'prijs_${regel.id}',
                    beginTekst: _getal(regel.eenheidsPrijsExclBtw),
                    hintText: '0,00',
                    numeriek: true,
                    prefixText: '€ ',
                    onBewaren: (waarde) {
                      onGewijzigd(
                        regel.copyWith(
                          eenheidsPrijsExclBtw: _leesDouble(waarde),
                        ),
                      );
                    },
                  ),
                ),
                _PrijsRegelKolom(
                  label: 'Totaal',
                  breedte: 86,
                  child: _PrijsRegelWaardeVak(
                    tekst: _bedrag(regel.basisTotaalExclBtw),
                  ),
                ),
                _PrijsRegelKolom(
                  label: 'Winst %',
                  breedte: 72,
                  child: regel.isAankoop
                      ? _PrijsRegelInvoerVeld(
                          sleutel: 'winst_${regel.id}',
                          beginTekst: _getal(regel.winstPercentage),
                          hintText: '0',
                          numeriek: true,
                          suffixText: '%',
                          onBewaren: (waarde) {
                            onGewijzigd(
                              regel.copyWith(
                                winstPercentage: _leesDouble(waarde),
                              ),
                            );
                          },
                        )
                      : const _PrijsRegelWaardeVak(tekst: '—'),
                ),
                _PrijsRegelKolom(
                  label: 'Winst €',
                  breedte: 82,
                  child: _PrijsRegelWaardeVak(
                    tekst: _bedrag(regel.winstBedragExclBtw),
                  ),
                ),
                _PrijsRegelKolom(
                  label: 'Eindtotaal',
                  breedte: 92,
                  margeRechts: 0,
                  child: _PrijsRegelWaardeVak(
                    tekst: _bedrag(regel.eindTotaalExclBtw),
                    vet: true,
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

class _PrijsRegelKolom extends StatelessWidget {
  const _PrijsRegelKolom({
    required this.label,
    required this.breedte,
    required this.child,
    this.margeRechts = 6,
  });

  final String label;
  final double breedte;
  final Widget child;
  final double margeRechts;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: breedte,
      margin: EdgeInsets.only(right: margeRechts),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            label,
            maxLines: 1,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          child,
        ],
      ),
    );
  }
}

class _PrijsRegelWaardeVak extends StatelessWidget {
  const _PrijsRegelWaardeVak({required this.tekst, this.vet = false});

  final String tekst;
  final bool vet;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        tekst,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: const Color(0xFF111827),
          fontSize: 10,
          fontWeight: vet ? FontWeight.w900 : FontWeight.w700,
        ),
      ),
    );
  }
}

class _PrijsRegelInvoerVeld extends StatefulWidget {
  const _PrijsRegelInvoerVeld({
    required this.sleutel,
    required this.beginTekst,
    required this.hintText,
    required this.onBewaren,
    this.numeriek = false,
    this.prefixText,
    this.suffixText,
  });

  final String sleutel;
  final String beginTekst;
  final String hintText;
  final ValueChanged<String> onBewaren;
  final bool numeriek;
  final String? prefixText;
  final String? suffixText;

  @override
  State<_PrijsRegelInvoerVeld> createState() => _PrijsRegelInvoerVeldState();
}

class _PrijsRegelInvoerVeldState extends State<_PrijsRegelInvoerVeld> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late String _laatstBewaard;

  @override
  void initState() {
    super.initState();
    _laatstBewaard = widget.beginTekst;
    _controller = TextEditingController(text: widget.beginTekst);
    _focusNode = FocusNode()..addListener(_focusGewijzigd);
  }

  @override
  void didUpdateWidget(covariant _PrijsRegelInvoerVeld oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_focusNode.hasFocus || oldWidget.beginTekst == widget.beginTekst) {
      return;
    }
    _laatstBewaard = widget.beginTekst;
    if (_controller.text != widget.beginTekst) {
      _controller.value = TextEditingValue(
        text: widget.beginTekst,
        selection: TextSelection.collapsed(offset: widget.beginTekst.length),
      );
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_focusGewijzigd)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _focusGewijzigd() {
    if (!_focusNode.hasFocus) {
      _bewaar();
    }
  }

  void _bewaar() {
    final waarde = _controller.text.trim();
    if (waarde == _laatstBewaard.trim()) return;
    _laatstBewaard = waarde;
    widget.onBewaren(waarde);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: ValueKey<String>(widget.sleutel),
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: widget.numeriek
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: widget.numeriek
          ? <TextInputFormatter>[
              TextInputFormatter.withFunction((oudeWaarde, nieuweWaarde) {
                final geldig = RegExp(r'^\d*([,.]\d{0,4})?$');
                return geldig.hasMatch(nieuweWaarde.text)
                    ? nieuweWaarde
                    : oudeWaarde;
              }),
            ]
          : null,
      decoration: _regelDecoratie(
        hintText: widget.hintText,
        prefixText: widget.prefixText,
        suffixText: widget.suffixText,
      ),
      style: const TextStyle(
        color: Color(0xFF111827),
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
      ),
      onSubmitted: (_) => _bewaar(),
      onTapOutside: (_) {
        _focusNode.unfocus();
      },
    );
  }
}

InputDecoration _regelDecoratie({
  String? hintText,
  String? prefixText,
  String? suffixText,
}) {
  return InputDecoration(
    hintText: hintText,
    prefixText: prefixText,
    suffixText: suffixText,
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.fromLTRB(7, 9, 7, 9),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: Color(0xFF0B7A3B), width: 1.3),
    ),
  );
}

class _PrijsSamenvattingRij extends StatelessWidget {
  const _PrijsSamenvattingRij({
    required this.omschrijving,
    required this.bedrag,
    this.vet = false,
    this.intern = false,
    this.optie = false,
  });

  final String omschrijving;
  final double bedrag;
  final bool vet;
  final bool intern;
  final bool optie;

  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    omschrijving,
                    style: TextStyle(
                      color: vet ? _tekstDonker : _tekstGrijs,
                      fontSize: vet ? 12.5 : 11.5,
                      fontWeight: vet ? FontWeight.w900 : FontWeight.w700,
                    ),
                  ),
                ),
                if (intern || optie) ...<Widget>[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: Text(
                      optie ? 'optie' : 'intern',
                      style: const TextStyle(
                        color: Color(0xFF9A3412),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: OpmetingOverzichtArtikelLayoutHelper.prijsZoneBreedte,
            child: Text(
              '€ ${bedrag.toStringAsFixed(2).replaceAll('.', ',')} excl. btw',
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: _tekstDonker,
                fontSize: vet ? 13 : 11.5,
                fontWeight: vet ? FontWeight.w900 : FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrijsPerStukVeld extends StatefulWidget {
  const _PrijsPerStukVeld({
    required this.beginPrijs,
    required this.onGewijzigd,
  });

  final double beginPrijs;
  final ValueChanged<double> onGewijzigd;

  @override
  State<_PrijsPerStukVeld> createState() => _PrijsPerStukVeldState();
}

class _PrijsPerStukVeldState extends State<_PrijsPerStukVeld> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _prijsTekst(widget.beginPrijs));
    _focusNode = FocusNode()..addListener(_verwerkFocusWijziging);
  }

  @override
  void didUpdateWidget(covariant _PrijsPerStukVeld oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_focusNode.hasFocus || oldWidget.beginPrijs == widget.beginPrijs) {
      return;
    }

    final nieuweTekst = _prijsTekst(widget.beginPrijs);
    if (_controller.text != nieuweTekst) {
      _zetControllerTekst(nieuweTekst);
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_verwerkFocusWijziging)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  String _prijsTekst(double prijs) {
    if (prijs <= 0) return '';
    return prijs.toStringAsFixed(2).replaceAll('.', ',');
  }

  double _leesPrijs(String tekst) {
    return double.tryParse(tekst.trim().replaceAll(',', '.')) ?? 0;
  }

  void _zetControllerTekst(String tekst) {
    _controller.value = TextEditingValue(
      text: tekst,
      selection: TextSelection.collapsed(offset: tekst.length),
    );
  }

  void _verwerkFocusWijziging() {
    if (_focusNode.hasFocus) return;
    final huidigeTekst = _controller.text.trim();
    if (huidigeTekst.isEmpty) return;
    final netteTekst = _prijsTekst(_leesPrijs(huidigeTekst));
    if (_controller.text != netteTekst) {
      _zetControllerTekst(netteTekst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        TextInputFormatter.withFunction((oudeWaarde, nieuweWaarde) {
          final geldig = RegExp(r'^\d*([,.]\d{0,2})?$');
          return geldig.hasMatch(nieuweWaarde.text) ? nieuweWaarde : oudeWaarde;
        }),
      ],
      decoration: _veldDecoratie(prefixText: '€ ', hintText: '0,00'),
      onChanged: (tekst) => widget.onGewijzigd(_leesPrijs(tekst)),
      onSubmitted: (_) => _verwerkFocusWijziging(),
    );
  }
}

class _PercentageVeld extends StatefulWidget {
  const _PercentageVeld({
    required this.beginPercentage,
    required this.maximum,
    required this.onGewijzigd,
  });

  final double beginPercentage;
  final double maximum;
  final ValueChanged<double> onGewijzigd;

  @override
  State<_PercentageVeld> createState() => _PercentageVeldState();
}

class _PercentageVeldState extends State<_PercentageVeld> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _percentageTekst(widget.beginPercentage),
    );
    _focusNode = FocusNode()..addListener(_verwerkFocusWijziging);
  }

  @override
  void didUpdateWidget(covariant _PercentageVeld oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_focusNode.hasFocus ||
        oldWidget.beginPercentage == widget.beginPercentage) {
      return;
    }

    final nieuweTekst = _percentageTekst(widget.beginPercentage);
    if (_controller.text != nieuweTekst) {
      _zetControllerTekst(nieuweTekst);
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_verwerkFocusWijziging)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  String _percentageTekst(double waarde) {
    if (!waarde.isFinite || waarde <= 0) return '';
    var tekst = waarde.toStringAsFixed(2).replaceAll('.', ',');
    tekst = tekst.replaceFirst(RegExp(r'0+$'), '');
    return tekst.replaceFirst(RegExp(r',$'), '');
  }

  double _leesPercentage(String tekst) {
    final gelezen = double.tryParse(tekst.trim().replaceAll(',', '.')) ?? 0.0;
    if (!gelezen.isFinite || gelezen <= 0) return 0.0;
    return gelezen.clamp(0.0, widget.maximum).toDouble();
  }

  void _zetControllerTekst(String tekst) {
    _controller.value = TextEditingValue(
      text: tekst,
      selection: TextSelection.collapsed(offset: tekst.length),
    );
  }

  void _verwerkFocusWijziging() {
    if (_focusNode.hasFocus) return;
    final percentage = _leesPercentage(_controller.text);
    _zetControllerTekst(_percentageTekst(percentage));
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        TextInputFormatter.withFunction((oudeWaarde, nieuweWaarde) {
          final geldig = RegExp(r'^\d{0,3}([,.]\d{0,2})?$');
          if (!geldig.hasMatch(nieuweWaarde.text)) return oudeWaarde;

          final rauw = double.tryParse(
            nieuweWaarde.text.trim().replaceAll(',', '.'),
          );
          if (rauw != null && rauw > widget.maximum) return oudeWaarde;
          return nieuweWaarde;
        }),
      ],
      decoration: _veldDecoratie(suffixText: '%', hintText: '0'),
      onChanged: (tekst) => widget.onGewijzigd(_leesPercentage(tekst)),
      onSubmitted: (_) => _verwerkFocusWijziging(),
    );
  }
}

InputDecoration _veldDecoratie({
  String? prefixText,
  String? suffixText,
  required String hintText,
}) {
  return InputDecoration(
    hintText: hintText,
    prefixText: prefixText,
    suffixText: suffixText,
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.fromLTRB(9, 10, 9, 10),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF0B7A3B), width: 1.4),
    ),
  );
}
