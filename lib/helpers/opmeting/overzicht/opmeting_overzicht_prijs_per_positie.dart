// THIMACO-CONTROLE: ALGEMENE-OPMETING-ZONDER-PRIJS-PER-POSITIE-20260817
// THIMACO-CONTROLE: TECHNISCHE-KEUZE-NIET-DUBBEL-IN-PRIJSBEREKENING-20260816
// THIMACO-CONTROLE: PRIJS-VOOR-ALLE-POSITIES-GEEN-RUIMTE-PER-ARTIKEL-20260816
// THIMACO-CONTROLE: VERDEELDE-KOST-IN-PRIJSBEREKENING-ONDER-KORTING-20260816
// THIMACO-CONTROLE: PRIJS-VOOR-ALLE-POSITIES-MEETELLEN-IN-POSITIETOTAAL-20260815
// THIMACO-CONTROLE: PRIJS-VOOR-ALLE-POSITIES-FASE2-IN-PRIJSZONE-20260815
// THIMACO-CONTROLE: PRIJS-PER-POSITIE-IPAD-COMPACT-GROTER-LETTERTYPE-EN-INVOERLIMIETEN-20260815
// THIMACO-CONTROLE: PRIJS-PER-POSITIE-COMPACTE-IPAD-LANDSCHAP-REGEL-20260815
// THIMACO-CONTROLE: PRIJS-PER-POSITIE-UI-TOONT-EENHEIDSBEREKENING-MET-MATEN-20260815
// THIMACO-CONTROLE: PRIJS-PER-POSITIE-DROPDOWNS-ZELFDE-40PX-HOOGTE-20260814
// THIMACO-CONTROLE: PRIJS-PER-POSITIE-OMSCHRIJVING-STANDAARDHOOGTE-ALLE-VELDEN-40PX-MENU-LINKS-20260814
// THIMACO-CONTROLE: PRIJS-PER-POSITIE-APARTE-CONTAINERS-GELIJKE-VELDHOOGTE-NIEUWE-EENHEDEN-20260814
// THIMACO-CONTROLE: PRIJS-PER-POSITIE-VLOTTERE-INGAVE-ZONDER-TOEVOEGMENU-20260814
// THIMACO-CONTROLE: PRIJSARCHITECTUUR-STAP5D3B-STABILISATIE-HELPER-WARNING-20260814
// THIMACO-CONTROLE: PRIJSARCHITECTUUR-OPRUIMEN-STAP5D3B-PRIJS-PER-POSITIE-ZONDER-LEGACY-RESULTAAT-20260814
// THIMACO-CONTROLE: PRIJSARCHITECTUUR-OPRUIMEN-STAP5B2-ANALYZERFIX-PRIJS-PER-POSITIE-20260814
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
import '../../offerte/prijzen/offerte_prijs_verdeeld_over_service.dart';
import '../../offerte/prijzen/offerte_prijs_voor_alle_posities_regel_model.dart';
import '../../offerte/prijzen/offerte_prijs_voor_alle_posities_service.dart';
import '../../offerte/prijzen/offerte_berekening_resultaat.dart';
import 'opmeting_overzicht_artikel_layout_helper.dart';
import 'opmeting_overzicht_prijs_voor_alle_posities.dart';

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
    bool toonPrijsPerPositieRegelsBlok = true,
    List<OffertePrijsVoorAllePositiesRegelModel> prijsVoorAllePositiesRegels =
        const <OffertePrijsVoorAllePositiesRegelModel>[],
    String huidigePositieId = '',
    bool toonPrijsVoorAllePositiesEditor = true,
  }) {
    if (!berekenPrijzen) {
      return 0.0;
    }

    final aantalSamenvattingRegels = heeftAlgemenePrijsUitsplitsing
        ? 2
        : (toonPrijsPerStukVeld ? 0 : 1);

    final invoerHoogte =
        (toonPrijsPerStukVeld ? 52.0 : 0.0) +
        (toonWinstEnKorting ? 104.0 : 0.0);
    final prijsPerPositieHoogte = toonPrijsPerPositieRegelsBlok
        ? 54.0 + (prijsResultaat.prijsPerPositieRegels.length * 98.0)
        : 0.0;
    final positieId = huidigePositieId.trim();
    final aantalVerdeeldeRegels = positieId.isEmpty
        ? 0
        : prijsVoorAllePositiesRegels
              .where(
                (regel) =>
                    OffertePrijsVerdeeldOverService.isVerdeeldOverRegel(
                      regel,
                    ) &&
                    regel.isVanToepassingOp(positieId),
              )
              .length;
    final aantalGewoneAllePositiesRegels =
        !toonPrijsVoorAllePositiesEditor || positieId.isEmpty
        ? 0
        : prijsVoorAllePositiesRegels
              .where(
                (regel) =>
                    !OffertePrijsVerdeeldOverService.isVerdeeldOverRegel(
                      regel,
                    ) &&
                    regel.isVanToepassingOp(positieId),
              )
              .length;
    final prijsVoorAllePositiesHoogte =
        toonPrijsVoorAllePositiesEditor && positieId.isNotEmpty
        ? 54.0 + (aantalGewoneAllePositiesRegels * 148.0)
        : 0.0;

    return 104.0 +
        invoerHoogte +
        ((aantalSamenvattingRegels + aantalVerdeeldeRegels) * 34.0) +
        prijsPerPositieHoogte +
        prijsVoorAllePositiesHoogte;
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
    bool toonPrijsPerPositieRegelsBlok = true,
    List<OffertePrijsVoorAllePositiesRegelModel> prijsVoorAllePositiesRegels =
        const <OffertePrijsVoorAllePositiesRegelModel>[],
    String huidigePositieId = '',
    List<OpmetingOverzichtPrijsDoelPositie> prijsDoelPosities =
        const <OpmetingOverzichtPrijsDoelPositie>[],
    ValueChanged<List<OffertePrijsVoorAllePositiesRegelModel>>?
    onPrijsVoorAllePositiesRegelsGewijzigd,
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
        kortingToestaan: kortingToestaan,
        onPrijsGewijzigd: onPrijsGewijzigd,
        onWinstmargeGewijzigd: onWinstmargeGewijzigd,
        onKortingGewijzigd: onKortingGewijzigd,
        onPrijsPerPositieRegelsGewijzigd: onPrijsPerPositieRegelsGewijzigd,
        toonPrijsPerPositieRegelsBlok: toonPrijsPerPositieRegelsBlok,
        prijsVoorAllePositiesRegels: prijsVoorAllePositiesRegels,
        huidigePositieId: huidigePositieId,
        prijsDoelPosities: prijsDoelPosities,
        onPrijsVoorAllePositiesRegelsGewijzigd:
            onPrijsVoorAllePositiesRegelsGewijzigd,
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
    required this.kortingToestaan,
    required this.onPrijsGewijzigd,
    required this.onWinstmargeGewijzigd,
    required this.onKortingGewijzigd,
    required this.onPrijsPerPositieRegelsGewijzigd,
    required this.toonPrijsPerPositieRegelsBlok,
    required this.prijsVoorAllePositiesRegels,
    required this.huidigePositieId,
    required this.prijsDoelPosities,
    this.onPrijsVoorAllePositiesRegelsGewijzigd,
    this.basisOmschrijving,
    this.algemeneVerkoopPrijsTotaalExclBtw,
    this.algemeneAankoopPrijsTotaalExclBtw,
  });

  final OfferteBerekeningResultaat resultaat;
  final OfferteArtikelPrijsDataModel prijsData;
  final int aantal;
  final bool toonPrijsPerStukVeld;
  final bool toonWinstEnKorting;
  final bool kortingToestaan;
  final ValueChanged<double> onPrijsGewijzigd;
  final ValueChanged<double> onWinstmargeGewijzigd;
  final ValueChanged<double> onKortingGewijzigd;
  final ValueChanged<List<OffertePrijsPerPositieRegelModel>>
  onPrijsPerPositieRegelsGewijzigd;
  final bool toonPrijsPerPositieRegelsBlok;
  final List<OffertePrijsVoorAllePositiesRegelModel>
  prijsVoorAllePositiesRegels;
  final String huidigePositieId;
  final List<OpmetingOverzichtPrijsDoelPositie> prijsDoelPosities;
  final ValueChanged<List<OffertePrijsVoorAllePositiesRegelModel>>?
  onPrijsVoorAllePositiesRegelsGewijzigd;
  final String? basisOmschrijving;
  final double? algemeneVerkoopPrijsTotaalExclBtw;
  final double? algemeneAankoopPrijsTotaalExclBtw;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    final prijsVoorAllePositiesTotaal =
        OffertePrijsVoorAllePositiesService.totaalVoorPositie(
          positieId: huidigePositieId,
          breedteMm: resultaat.breedteMm,
          hoogteMm: resultaat.hoogteMm,
          regels: prijsVoorAllePositiesRegels,
        );
    final volledigPositieTotaal = _rondBedragAf(
      resultaat.totaalExclBtw + prijsVoorAllePositiesTotaal,
    );
    final positieId = huidigePositieId.trim();
    final verdeeldeRegels = positieId.isEmpty
        ? const <OffertePrijsVoorAllePositiesRegelModel>[]
        : prijsVoorAllePositiesRegels
              .where(
                (regel) =>
                    OffertePrijsVerdeeldOverService.isVerdeeldOverRegel(
                      regel,
                    ) &&
                    regel.isVanToepassingOp(positieId),
              )
              .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // 1. Algemene prijsberekening staat bewust in een eigen container.
        Container(
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
              if (verdeeldeRegels.isNotEmpty)
                ...verdeeldeRegels.map((regel) {
                  final omschrijving = regel.omschrijving.trim().isEmpty
                      ? 'Verdeelde kost'
                      : regel.omschrijving.trim();
                  final bedrag = regel.prijsregel.eindTotaalExclBtwVoorMaten(
                    breedteMm: resultaat.breedteMm,
                    hoogteMm: resultaat.hoogteMm,
                  );
                  return _PrijsSamenvattingRij(
                    omschrijving: omschrijving,
                    bedrag: bedrag,
                  );
                }),
            ],
          ),
        ),
        if (toonPrijsPerPositieRegelsBlok) ...<Widget>[
          const SizedBox(height: 10),

          // 2. Lokale prijs per positie heeft zijn eigen duidelijke container.
          _PrijsPerPositieRegelsBlok(
            resultaat: resultaat,
            regels: prijsData.prijsPerPositieRegels,
            onGewijzigd: onPrijsPerPositieRegelsGewijzigd,
          ),
        ],
        if (huidigePositieId.trim().isNotEmpty &&
            onPrijsVoorAllePositiesRegelsGewijzigd != null) ...<Widget>[
          const SizedBox(height: 8),
          OpmetingOverzichtPrijsVoorAllePositiesBlok(
            huidigePositieId: huidigePositieId,
            breedteMm: resultaat.breedteMm,
            hoogteMm: resultaat.hoogteMm,
            regels: prijsVoorAllePositiesRegels,
            doelPosities: prijsDoelPosities,
            onGewijzigd: onPrijsVoorAllePositiesRegelsGewijzigd!,
          ),
        ],
        const SizedBox(height: 8),

        // Het eindtotaal blijft los onder de prijsblokken en sluit rechts uit.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: _PrijsSamenvattingRij(
            omschrijving: 'Totaal positie excl. btw',
            bedrag: volledigPositieTotaal,
            vet: true,
          ),
        ),
      ],
    );
  }

  static double _rondBedragAf(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) {
      return 0.0;
    }
    return (waarde * 100.0).roundToDouble() / 100.0;
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

class _PrijsPerPositieRegelsBlok extends StatelessWidget {
  const _PrijsPerPositieRegelsBlok({
    required this.resultaat,
    required this.regels,
    required this.onGewijzigd,
  });

  final OfferteBerekeningResultaat resultaat;
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
    '1 x B',
    '1 x H',
    '2 x B',
    '2 x H',
    '2 x H en 1 x B',
    '1 x H en 2 x B',
    'rondom',
    'oppervlakte',
  ];

  String _nieuwRegelId() {
    return 'positie_${DateTime.now().microsecondsSinceEpoch}';
  }

  /// + Regel maakt onmiddellijk een lege invoerregel aan.
  /// Er is bewust geen tussenmenu meer.
  void _voegHandmatigeRegelToe() {
    final nieuweRegel = OffertePrijsPerPositieRegelModel(
      id: _nieuwRegelId(),
      omschrijving: '',
      type: OffertePrijsPerPositieType.verkoop,
      aantal: 0,
      eenheid: '',
      eenheidsPrijsExclBtw: 0,
      winstPercentage: 0,
      offerteWeergave: OffertePrijsPerPositieWeergave.uit,
    );

    onGewijzigd(<OffertePrijsPerPositieRegelModel>[...regels, nieuweRegel]);
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
              ? 'Prijsregel gekopieerd. Gebruik het plak-icoon naast + Regel op de doelpositie.'
              : '“$omschrijving” gekopieerd. Gebruik het plak-icoon naast + Regel op de doelpositie.',
        ),
      ),
    );
  }

  void _plakGekopieerdeRegelToe(BuildContext context) {
    final bron = _gekopieerdeRegel;
    if (bron == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text('Kopieer eerst een prijsregel.'),
        ),
      );
      return;
    }

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

  void _pasTemplateToeOpRegel(
    OffertePrijsPerPositieRegelModel regel,
    OffertePrijsPerArtikelTemplateModel template,
  ) {
    final uitTemplate = template.maakPositieRegel(nieuwId: regel.id);

    final bijgewerkt = uitTemplate.copyWith(
      // Heeft de gebruiker al een aantal ingevuld, dan blijft dat behouden.
      // Bij een nieuwe lege regel neemt het sjabloon de standaard 1 over.
      aantal: regel.aantal > 0 ? regel.aantal : uitTemplate.aantal,
      // Een reeds bewust gekozen eenheid blijft behouden; anders komt de
      // eenheid uit Instellingen mee.
      eenheid: regel.eenheid.trim().isNotEmpty
          ? regel.eenheid
          : uitTemplate.eenheid,
      // Een reeds ingegeven prijs en offerteweergave mogen niet verdwijnen
      // wanneer alleen een omschrijving/sjabloon wordt gekozen.
      eenheidsPrijsExclBtw: regel.eenheidsPrijsExclBtw,
      offerteWeergave: regel.offerteWeergave,
    );

    _vervangRegel(bijgewerkt);
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
                onPressed: _voegHandmatigeRegelToe,
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
              IconButton(
                onPressed: () => _plakGekopieerdeRegelToe(context),
                tooltip: 'Gekopieerde prijsregel plakken',
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.content_paste_rounded,
                  size: 17,
                  color: _groen,
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
                  resultaat: resultaat,
                  regel: regel,
                  eenheden: _eenheden,
                  onGewijzigd: _vervangRegel,
                  onTemplateGekozen: (template) {
                    _pasTemplateToeOpRegel(regel, template);
                  },
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
    required this.resultaat,
    required this.regel,
    required this.eenheden,
    required this.onGewijzigd,
    required this.onTemplateGekozen,
    required this.onKopieren,
    required this.onVerwijderen,
  });

  final OfferteBerekeningResultaat resultaat;
  final OffertePrijsPerPositieRegelModel regel;
  final List<String> eenheden;
  final ValueChanged<OffertePrijsPerPositieRegelModel> onGewijzigd;
  final ValueChanged<OffertePrijsPerArtikelTemplateModel> onTemplateGekozen;
  final VoidCallback onKopieren;
  final VoidCallback onVerwijderen;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _achtergrond = Color(0xFFF9FAFB);

  List<String> get _eenhedenVoorDropdown {
    final huidige = regel.eenheid.trim();
    if (huidige.isEmpty || eenheden.contains(huidige)) return eenheden;
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _PrijsPerArtikelOmschrijvingMenu(onGekozen: onTemplateGekozen),
              const SizedBox(width: 6),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: _PrijsRegelInvoerVeld(
                    sleutel: 'omschrijving_${regel.id}',
                    beginTekst: regel.omschrijving,
                    hintText: 'Omschrijving',
                    onBewaren: (waarde) {
                      onGewijzigd(regel.copyWith(omschrijving: waarde.trim()));
                    },
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 88,
                height: 40,
                child: DropdownButtonFormField<OffertePrijsPerPositieWeergave>(
                  key: ValueKey<String>(
                    'prijsWeergave_${regel.id}_${regel.offerteWeergave.name}',
                  ),
                  initialValue: regel.offerteWeergave,
                  isDense: false,
                  isExpanded: true,
                  decoration: _regelDropdownDecoratie(),
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
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  onPressed: onKopieren,
                  tooltip: 'Prijsregel kopiëren',
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.copy_rounded, size: 17, color: _groen),
                ),
              ),
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  onPressed: onVerwijderen,
                  tooltip: 'Prijsregel verwijderen',
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: Color(0xFFB91C1C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          LayoutBuilder(
            builder: (context, constraints) {
              const tussenruimte = 4.0;

              Widget cel({required Widget child, required int flex}) {
                return Expanded(
                  flex: flex,
                  child: SizedBox(height: 40, child: child),
                );
              }

              Widget ruimte() => const SizedBox(width: tussenruimte);

              final huidigeEenheid = regel.eenheid.trim();
              final basisTotaal = resultaat.prijsPerPositieBasisTotaalExclBtw(
                regel,
              );
              final winstBedrag = resultaat.prijsPerPositieWinstBedragExclBtw(
                regel,
              );
              final eindTotaal = resultaat.prijsPerPositieEindTotaalExclBtw(
                regel,
              );
              final totaalHeeftWaarde = basisTotaal > 0;
              final winstHeeftWaarde = winstBedrag > 0;
              final eindtotaalHeeftWaarde = eindTotaal > 0;

              // Compacte, responsieve breedtes voor iPad in liggende stand.
              // De regel gebruikt altijd exact de beschikbare breedte:
              // A/V 4 | aantal 6 | eenheid 12 | prijs 8 | totaal 8 |
              // % 4 | winst € 8 | eindtotaal 9.
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  cel(
                    flex: 4,
                    child:
                        _PrijsRegelCompactKeuzeMenu<OffertePrijsPerPositieType>(
                          waarde: regel.type,
                          waarden: OffertePrijsPerPositieType.values,
                          hintText: 'V',
                          tekstVoor: (waarde) => waarde.label,
                          tekstGrootte: 13,
                          tekstVet: true,
                          onGekozen: (waarde) {
                            if (waarde == regel.type) return;
                            onGewijzigd(regel.copyWith(type: waarde));
                          },
                        ),
                  ),
                  ruimte(),
                  cel(
                    flex: 6,
                    child: _PrijsRegelInvoerVeld(
                      sleutel: 'aantal_${regel.id}',
                      beginTekst: _getal(regel.aantal, decimalen: 4),
                      hintText: 'Aantal',
                      numeriek: true,
                      maxGeheleCijfers: 3,
                      maxDecimalen: 2,
                      onBewaren: (waarde) {
                        onGewijzigd(
                          regel.copyWith(aantal: _leesDouble(waarde)),
                        );
                      },
                    ),
                  ),
                  ruimte(),
                  cel(
                    flex: 12,
                    child: _PrijsRegelCompactKeuzeMenu<String>(
                      waarde: huidigeEenheid.isEmpty ? null : huidigeEenheid,
                      waarden: _eenhedenVoorDropdown,
                      hintText: 'Eenheid',
                      tekstVoor: (waarde) => waarde,
                      tekstGrootte: 11.5,
                      onGekozen: (waarde) {
                        if (waarde == regel.eenheid) return;
                        onGewijzigd(regel.copyWith(eenheid: waarde));
                      },
                    ),
                  ),
                  ruimte(),
                  cel(
                    flex: 8,
                    child: _PrijsRegelInvoerVeld(
                      sleutel: 'prijs_${regel.id}',
                      beginTekst: _getal(regel.eenheidsPrijsExclBtw),
                      hintText: 'Prijs',
                      numeriek: true,
                      maxGeheleCijfers: 4,
                      maxDecimalen: 2,
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
                  ruimte(),
                  cel(
                    flex: 8,
                    child: _PrijsRegelWaardeVak(
                      tekst: totaalHeeftWaarde
                          ? _bedrag(basisTotaal)
                          : 'Totaal',
                      hint: !totaalHeeftWaarde,
                    ),
                  ),
                  ruimte(),
                  cel(
                    flex: 4,
                    child: regel.isAankoop
                        ? _PrijsRegelInvoerVeld(
                            sleutel: 'winst_${regel.id}',
                            beginTekst: _getal(regel.winstPercentage),
                            hintText: '%',
                            numeriek: true,
                            maxGeheleCijfers: 2,
                            maxDecimalen: 2,
                            suffixText: '%',
                            onBewaren: (waarde) {
                              onGewijzigd(
                                regel.copyWith(
                                  winstPercentage: _leesDouble(waarde),
                                ),
                              );
                            },
                          )
                        : const _PrijsRegelWaardeVak(tekst: '%', hint: true),
                  ),
                  ruimte(),
                  cel(
                    flex: 8,
                    child: _PrijsRegelWaardeVak(
                      tekst: winstHeeftWaarde ? _bedrag(winstBedrag) : '€',
                      hint: !winstHeeftWaarde,
                    ),
                  ),
                  ruimte(),
                  cel(
                    flex: 9,
                    child: _PrijsRegelWaardeVak(
                      tekst: eindtotaalHeeftWaarde
                          ? _bedrag(eindTotaal)
                          : 'Eindtotaal',
                      vet: eindtotaalHeeftWaarde,
                      hint: !eindtotaalHeeftWaarde,
                      achtergrond: const Color(0xFFE7F6EC),
                      randKleur: const Color(0xFFCDE9D5),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PrijsRegelCompactKeuzeMenu<T> extends StatelessWidget {
  const _PrijsRegelCompactKeuzeMenu({
    required this.waarde,
    required this.waarden,
    required this.hintText,
    required this.tekstVoor,
    required this.onGekozen,
    this.tekstGrootte = 10,
    this.tekstVet = false,
  });

  final T? waarde;
  final List<T> waarden;
  final String hintText;
  final String Function(T waarde) tekstVoor;
  final ValueChanged<T> onGekozen;
  final double tekstGrootte;
  final bool tekstVet;

  @override
  Widget build(BuildContext context) {
    final huidigeTekst = waarde == null ? '' : tekstVoor(waarde as T).trim();

    return PopupMenuButton<T>(
      tooltip: hintText,
      position: PopupMenuPosition.under,
      padding: EdgeInsets.zero,
      onSelected: onGekozen,
      itemBuilder: (context) {
        return waarden
            .map(
              (item) => PopupMenuItem<T>(
                value: item,
                height: 36,
                child: Text(
                  tekstVoor(item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: item == waarde
                        ? FontWeight.w900
                        : FontWeight.w600,
                  ),
                ),
              ),
            )
            .toList(growable: false);
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.only(left: 5, right: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                huidigeTekst.isEmpty ? hintText : huidigeTekst,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: huidigeTekst.isEmpty
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF111827),
                  fontSize: tekstGrootte,
                  fontWeight: tekstVet ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_drop_down_rounded,
              size: 15,
              color: Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrijsRegelWaardeVak extends StatelessWidget {
  const _PrijsRegelWaardeVak({
    required this.tekst,
    this.vet = false,
    this.hint = false,
    this.achtergrond = Colors.white,
    this.randKleur = const Color(0xFFE5E7EB),
  });

  final String tekst;
  final bool vet;
  final bool hint;
  final Color achtergrond;
  final Color randKleur;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: achtergrond,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: randKleur),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Text(
          tekst,
          maxLines: 1,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: hint ? const Color(0xFF9CA3AF) : const Color(0xFF111827),
            fontSize: vet ? 13 : 12.5,
            fontWeight: hint
                ? FontWeight.w600
                : (vet ? FontWeight.w900 : FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _PrijsPerArtikelOmschrijvingMenu extends StatefulWidget {
  const _PrijsPerArtikelOmschrijvingMenu({required this.onGekozen});

  final ValueChanged<OffertePrijsPerArtikelTemplateModel> onGekozen;

  @override
  State<_PrijsPerArtikelOmschrijvingMenu> createState() =>
      _PrijsPerArtikelOmschrijvingMenuState();
}

class _PrijsPerArtikelOmschrijvingMenuState
    extends State<_PrijsPerArtikelOmschrijvingMenu> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  List<OffertePrijsPerArtikelTemplateModel> _templates =
      const <OffertePrijsPerArtikelTemplateModel>[];
  bool _laden = true;

  @override
  void initState() {
    super.initState();
    _laadTemplates();
  }

  Future<void> _laadTemplates() async {
    try {
      final templates = await AppStorage.laadOffertePrijsPerArtikelTemplates();
      if (!mounted) return;
      setState(() {
        _templates = templates;
        _laden = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _templates = const <OffertePrijsPerArtikelTemplateModel>[];
        _laden = false;
      });
    }
  }

  static String _percentage(double waarde) {
    var tekst = waarde.toStringAsFixed(2).replaceAll('.', ',');
    tekst = tekst.replaceFirst(RegExp(r'0+$'), '');
    return tekst.replaceFirst(RegExp(r',$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: PopupMenuButton<OffertePrijsPerArtikelTemplateModel>(
        tooltip: 'Omschrijving kiezen uit Instellingen',
        position: PopupMenuPosition.under,
        padding: EdgeInsets.zero,
        onOpened: _laadTemplates,
        onSelected: widget.onGekozen,
        icon: const Icon(
          Icons.arrow_drop_down_circle_outlined,
          size: 19,
          color: _groen,
        ),
        itemBuilder: (context) {
          if (_laden) {
            return const <PopupMenuEntry<OffertePrijsPerArtikelTemplateModel>>[
              PopupMenuItem<OffertePrijsPerArtikelTemplateModel>(
                enabled: false,
                child: Text('Prijsregels laden…'),
              ),
            ];
          }

          if (_templates.isEmpty) {
            return const <PopupMenuEntry<OffertePrijsPerArtikelTemplateModel>>[
              PopupMenuItem<OffertePrijsPerArtikelTemplateModel>(
                enabled: false,
                child: Text('Geen regels in Instellingen > Prijs per artikel'),
              ),
            ];
          }

          return _templates
              .map((template) {
                final winstTekst = template.isAankoop
                    ? ' · winst ${_percentage(template.veiligeStandaardWinstPercentage)} %'
                    : '';

                return PopupMenuItem<OffertePrijsPerArtikelTemplateModel>(
                  value: template,
                  child: SizedBox(
                    width: 360,
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7F6EC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            template.type.label,
                            style: const TextStyle(
                              color: _groen,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                template.omschrijving,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${template.eenheid}$winstTekst',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _tekstGrijs,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              })
              .toList(growable: false);
        },
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
    this.maxGeheleCijfers,
    this.maxDecimalen = 2,
    this.prefixText,
    this.suffixText,
  });

  final String sleutel;
  final String beginTekst;
  final String hintText;
  final ValueChanged<String> onBewaren;
  final bool numeriek;
  final int? maxGeheleCijfers;
  final int maxDecimalen;
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
    if (oldWidget.beginTekst == widget.beginTekst) {
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
      expands: true,
      maxLines: null,
      minLines: null,
      textAlignVertical: TextAlignVertical.center,
      keyboardType: widget.numeriek
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: widget.numeriek
          ? <TextInputFormatter>[
              TextInputFormatter.withFunction((oudeWaarde, nieuweWaarde) {
                final maxGeheleCijfers = widget.maxGeheleCijfers;
                final maxDecimalen = widget.maxDecimalen < 0
                    ? 0
                    : widget.maxDecimalen;

                final patroon = maxGeheleCijfers == null
                    ? RegExp(
                        r'^\d*([,.]\d{0,' + maxDecimalen.toString() + r'})?$',
                      )
                    : RegExp(
                        r'^\d{0,' +
                            maxGeheleCijfers.toString() +
                            r'}([,.]\d{0,' +
                            maxDecimalen.toString() +
                            r'})?$',
                      );

                return patroon.hasMatch(nieuweWaarde.text)
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
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
      ),
      onSubmitted: (_) => _bewaar(),
      onTapOutside: (_) {
        _focusNode.unfocus();
      },
    );
  }
}

InputDecoration _regelDropdownDecoratie() {
  return _regelDecoratie().copyWith(
    isDense: false,
    constraints: const BoxConstraints.tightFor(height: 40),
    contentPadding: const EdgeInsets.symmetric(horizontal: 9),
  );
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
    hintStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Color(0xFF9CA3AF),
    ),
    prefixStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Color(0xFF111827),
    ),
    suffixStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Color(0xFF111827),
    ),
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    constraints: const BoxConstraints.tightFor(height: 40),
    contentPadding: const EdgeInsets.symmetric(horizontal: 6),
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
  });

  final String omschrijving;
  final double bedrag;
  final bool vet;

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
