// THIMACO-CONTROLE: OVERZICHT-ARTIKEL-PRIJS-LAYOUT-20260721
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../offerte/prijzen/offerte_artikel_korting_kaart.dart';
import '../../offerte/prijzen/offerte_berekening_resultaat.dart';
import 'opmeting_overzicht_artikel_layout_helper.dart';
import 'opmeting_overzicht_model.dart';
import 'opmeting_overzicht_technische_prijs_koppel_helper.dart';

class OpmetingOverzichtArtikelPrijsLayout extends StatelessWidget {
  const OpmetingOverzichtArtikelPrijsLayout({
    required this.tekenvlak,
    required this.technischeRegels,
    required this.berekenPrijzen,
    required this.prijsResultaat,
    required this.aantal,
    required this.beginPrijsPerStukExclBtw,
    required this.beginWinstmargePercentage,
    required this.beginKortingPercentage,
    required this.kortingToestaan,
    required this.winstmargeVoorAlleArtikelen,
    required this.kortingVoorAlleArtikelen,
    required this.onPrijsGewijzigd,
    required this.onWinstmargeGewijzigd,
    required this.onKortingGewijzigd,
    super.key,
  });

  final Widget tekenvlak;
  final List<OpmetingOverzichtTechnischeRegel> technischeRegels;
  final bool berekenPrijzen;
  final OfferteBerekeningResultaat prijsResultaat;
  final int aantal;
  final double beginPrijsPerStukExclBtw;
  final double beginWinstmargePercentage;
  final double beginKortingPercentage;
  final bool kortingToestaan;
  final bool winstmargeVoorAlleArtikelen;
  final bool kortingVoorAlleArtikelen;
  final ValueChanged<double> onPrijsGewijzigd;
  final OfferteArtikelPercentageGewijzigd onWinstmargeGewijzigd;
  final OfferteArtikelPercentageGewijzigd onKortingGewijzigd;

  @override
  Widget build(BuildContext context) {
    final prijsSamenvattingHoogte = berekenPrijzen
        ? 92.0 +
              ((prijsResultaat.vrijeArtikelPrijsregels.length +
                      prijsResultaat.verdeeldePrijsregels.length +
                      (prijsResultaat.heeftArtikelWinstmarge ? 1 : 0) +
                      (prijsResultaat.heeftArtikelKorting ? 1 : 0)) *
                  34.0)
        : 0.0;

    final gemeenschappelijkeHoogte =
        OpmetingOverzichtArtikelLayoutHelper.berekenGemeenschappelijkeHoogte(
          aantalTechnischeRegels: technischeRegels.length,
          toonPrijzen: berekenPrijzen,
          prijsVeldHoogte: 58,
          prijsCorrectieVeldHoogte: 202,
          prijsSamenvattingHoogte: prijsSamenvattingHoogte,
        );

    final technischeRegelsMetPrijs = berekenPrijzen
        ? OpmetingOverzichtTechnischePrijsKoppelHelper.koppelTechnischePrijzenAanRegels(
            technischeRegels: technischeRegels,
            technischePrijsregels: prijsResultaat.technischePrijsregels,
          )
        : null;

    final prijsWidgets = berekenPrijzen
        ? <Widget>[
            _PrijsSamenvattingKaart(resultaat: prijsResultaat, aantal: aantal),
            _PrijsPerStukVeld(
              beginPrijs: beginPrijsPerStukExclBtw,
              onGewijzigd: onPrijsGewijzigd,
            ),
            OfferteArtikelKortingKaart(
              beginWinstmargePercentage: beginWinstmargePercentage,
              beginKortingPercentage: beginKortingPercentage,
              winstmargeBasisExclBtw: prijsResultaat.winstmargeBasisExclBtw,
              winstmargeBedragExclBtw: prijsResultaat.winstmargeBedragExclBtw,
              kortingBasisExclBtw: prijsResultaat.kortingBasisExclBtw,
              kortingBedragExclBtw: prijsResultaat.kortingBedragExclBtw,
              onWinstmargeGewijzigd: onWinstmargeGewijzigd,
              onKortingGewijzigd: onKortingGewijzigd,
              winstmargeVoorAlleArtikelen: winstmargeVoorAlleArtikelen,
              kortingVoorAlleArtikelen: kortingVoorAlleArtikelen,
              kortingToestaan: kortingToestaan,
            ),
          ]
        : const <Widget>[];

    return OpmetingOverzichtArtikelLayoutHelper.bouwLayout(
      hoogte: gemeenschappelijkeHoogte,
      tekenvlak: tekenvlak,
      rechterkolom: OpmetingOverzichtArtikelLayoutHelper.bouwRechterkolom(
        technischeRegels: technischeRegels,
        technischeRegelsMetPrijs: technischeRegelsMetPrijs,
        onderWidgets: prijsWidgets,
      ),
    );
  }
}

class _PrijsSamenvattingKaart extends StatelessWidget {
  const _PrijsSamenvattingKaart({
    required this.resultaat,
    required this.aantal,
  });

  final OfferteBerekeningResultaat resultaat;
  final int aantal;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

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
        children: [
          const Text(
            'Prijsberekening',
            style: TextStyle(
              color: _groen,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          _PrijsSamenvattingRij(
            omschrijving: aantal > 1
                ? 'Prijs per stuk · $aantal stuks'
                : 'Prijs per stuk',
            bedrag: resultaat.basisTotaalExclBtw,
          ),
          if (resultaat.heeftArtikelWinstmarge)
            _PrijsSamenvattingRij(
              omschrijving: resultaat.winstmargeOmschrijving,
              bedrag: resultaat.winstmargeBedragExclBtw,
            ),
          if (resultaat.heeftArtikelKorting)
            _PrijsSamenvattingRij(
              omschrijving: resultaat.kortingOmschrijving,
              bedrag: -resultaat.kortingBedragExclBtw,
              korting: true,
            ),
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
          const Divider(height: 18, color: _rand),
          _PrijsSamenvattingRij(
            omschrijving: 'Totaal positie excl. btw',
            bedrag: resultaat.totaalExclBtw,
            vet: true,
          ),
          if (!resultaat.heeftTechnischePrijsregels &&
              !resultaat.heeftVrijeArtikelPrijsregels &&
              !resultaat.heeftVerdeeldePrijsregels &&
              !resultaat.heeftArtikelWinstmarge &&
              !resultaat.heeftArtikelKorting) ...[
            const SizedBox(height: 5),
            const Text(
              'Geen bijkomende prijsregels van toepassing.',
              style: TextStyle(
                color: _tekstGrijs,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PrijsSamenvattingRij extends StatelessWidget {
  const _PrijsSamenvattingRij({
    required this.omschrijving,
    required this.bedrag,
    this.vet = false,
    this.intern = false,
    this.optie = false,
    this.korting = false,
  });

  final String omschrijving;
  final double bedrag;
  final bool vet;
  final bool intern;
  final bool optie;
  final bool korting;

  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);
  static const Color _groen = Color(0xFF0B7A3B);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Text(
            '${_formatteerBedrag(bedrag, korting: korting)} excl. btw',
            style: TextStyle(
              color: korting ? _groen : _tekstDonker,
              fontSize: vet ? 13 : 11.5,
              fontWeight: vet ? FontWeight.w900 : FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatteerBedrag(double bedrag, {bool korting = false}) {
    final absoluut = bedrag.abs().toStringAsFixed(2).replaceAll('.', ',');
    return korting || bedrag < 0 ? '- € $absoluut' : '€ $absoluut';
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
    if (prijs <= 0) {
      return '';
    }

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
    if (!_focusNode.hasFocus) {
      _formatteerHuidigeInvoer();
    }
  }

  void _formatteerHuidigeInvoer() {
    final huidigeTekst = _controller.text.trim();
    if (huidigeTekst.isEmpty) {
      return;
    }

    final prijs = _leesPrijs(huidigeTekst);
    final netteTekst = _prijsTekst(prijs);
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
      decoration: InputDecoration(
        labelText: 'Prijs per stuk — excl. btw',
        hintText: '0,00',
        prefixText: '€ ',
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFFFFBF5),
        contentPadding: const EdgeInsets.fromLTRB(12, 13, 12, 13),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0xFFFED7AA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0xFF0B7A3B), width: 1.5),
        ),
      ),
      onChanged: (tekst) {
        widget.onGewijzigd(_leesPrijs(tekst));
      },
      onSubmitted: (_) {
        _formatteerHuidigeInvoer();
      },
    );
  }
}
