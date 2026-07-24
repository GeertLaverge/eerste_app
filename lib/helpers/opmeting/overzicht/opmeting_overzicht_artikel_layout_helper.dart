// THIMACO-CONTROLE: ALGEMENE-OVERZICHT-ARTIKEL-LAYOUT-20260720
import 'package:flutter/material.dart';

import 'opmeting_overzicht_model.dart';

class OpmetingOverzichtTechnischeRegelPrijs {
  const OpmetingOverzichtTechnischeRegelPrijs({
    required this.regel,
    this.bedragExclBtw,
  });

  final OpmetingOverzichtTechnischeRegel regel;
  final double? bedragExclBtw;

  bool get heeftBedrag {
    final bedrag = bedragExclBtw;
    return bedrag != null && bedrag.isFinite && bedrag > 0.0;
  }
}

class OpmetingOverzichtArtikelLayoutHelper {
  const OpmetingOverzichtArtikelLayoutHelper._();

  static const Color groen = Color(0xFF0B7A3B);
  static const Color tekstDonker = Color(0xFF111827);
  static const Color tekstGrijs = Color(0xFF6B7280);
  static const Color rand = Color(0xFFE5E7EB);
  static const Color vlakAchtergrond = Color(0xFFFCFCFD);
  static const Color kopAchtergrond = Color(0xFFF8FAF9);
  static const Color technischAchtergrond = Color(0xFFFAFAFA);

  static const double tussenruimte = 14;
  static const int tekenvlakFlex = 45;
  static const int technischeKolomFlex = 55;
  static const double prijsZoneBreedte = 88;
  static const double minimumHoogte = 500;
  static const double maximumHoogte = 1450;

  // Eén technische regel krijgt overal exact dezelfde hoogte. De
  // niet-scrollbare artikelkaart kan daardoor haar hoogte betrouwbaar
  // berekenen, zonder schattingen die bij veel regels een RenderFlex-overflow
  // veroorzaken.
  static const double technischeRegelHoogte = 31;
  static const double technischeContainerRandReserve = 2;

  static List<OpmetingOverzichtTechnischeRegel> combineerTechnischeRegels(
    List<OpmetingOverzichtTechnischeRegel> technischeRegels,
  ) {
    final resultaat = <OpmetingOverzichtTechnischeRegel>[];
    final indexPerSleutel = <String, int>{};

    for (final regel in technischeRegels) {
      final netteRegel = OpmetingOverzichtTechnischeRegel(
        titel: _opEenRegel(regel.titel),
        waarde: _opEenRegel(regel.waarde),
      );
      final sleutel = _technischeRegelSleutel(netteRegel);

      if (sleutel.isEmpty) {
        continue;
      }

      final bestaandIndex = indexPerSleutel[sleutel];
      if (bestaandIndex == null) {
        indexPerSleutel[sleutel] = resultaat.length;
        resultaat.add(netteRegel);
        continue;
      }

      resultaat[bestaandIndex] = _voorkeursRegel(
        resultaat[bestaandIndex],
        netteRegel,
      );
    }

    return List<OpmetingOverzichtTechnischeRegel>.unmodifiable(resultaat);
  }

  static List<OpmetingOverzichtTechnischeRegelPrijs>
  combineerTechnischeRegelsMetPrijs(
    List<OpmetingOverzichtTechnischeRegelPrijs> technischeRegels,
  ) {
    final resultaat = <OpmetingOverzichtTechnischeRegelPrijs>[];
    final indexPerSleutel = <String, int>{};

    for (final weergave in technischeRegels) {
      final netteRegel = OpmetingOverzichtTechnischeRegel(
        titel: _opEenRegel(weergave.regel.titel),
        waarde: _opEenRegel(weergave.regel.waarde),
      );
      final sleutel = _technischeRegelSleutel(netteRegel);

      if (sleutel.isEmpty) {
        continue;
      }

      final bestaandIndex = indexPerSleutel[sleutel];
      if (bestaandIndex == null) {
        indexPerSleutel[sleutel] = resultaat.length;
        resultaat.add(
          OpmetingOverzichtTechnischeRegelPrijs(
            regel: netteRegel,
            bedragExclBtw: _bruikbaarBedrag(weergave.bedragExclBtw),
          ),
        );
        continue;
      }

      final bestaand = resultaat[bestaandIndex];
      final bestaandBedrag = _bruikbaarBedrag(bestaand.bedragExclBtw);
      final nieuwBedrag = _bruikbaarBedrag(weergave.bedragExclBtw);

      resultaat[bestaandIndex] = OpmetingOverzichtTechnischeRegelPrijs(
        regel: _voorkeursRegel(bestaand.regel, netteRegel),
        bedragExclBtw: bestaandBedrag == null && nieuwBedrag == null
            ? null
            : (bestaandBedrag ?? 0.0) + (nieuwBedrag ?? 0.0),
      );
    }

    return List<OpmetingOverzichtTechnischeRegelPrijs>.unmodifiable(resultaat);
  }

  static double berekenGemeenschappelijkeHoogte({
    required int aantalTechnischeRegels,
    bool toonPrijzen = false,
    double prijsVeldHoogte = 0,
    double prijsCorrectieVeldHoogte = 0,
    double prijsSamenvattingHoogte = 0,
  }) {
    final geschatteTechnischeHoogte = aantalTechnischeRegels <= 0
        ? 180.0
        : aantalTechnischeRegels * 30.0 + 18.0;

    final totaleHoogte =
        geschatteTechnischeHoogte +
        (toonPrijzen ? prijsVeldHoogte : 0) +
        (toonPrijzen ? prijsCorrectieVeldHoogte : 0) +
        (toonPrijzen ? prijsSamenvattingHoogte : 0);

    return totaleHoogte.clamp(minimumHoogte, maximumHoogte).toDouble();
  }

  static double berekenNietScrollbareTechnischeHoogte({
    required List<OpmetingOverzichtTechnischeRegel> technischeRegels,
    double minimaleHoogte = minimumHoogte,
  }) {
    final aantalRegels = combineerTechnischeRegels(technischeRegels).length;
    final benodigdeHoogte = aantalRegels <= 0
        ? minimaleHoogte
        : (aantalRegels * technischeRegelHoogte) +
              technischeContainerRandReserve;

    return benodigdeHoogte < minimaleHoogte ? minimaleHoogte : benodigdeHoogte;
  }

  static Widget bouwLayout({
    required double hoogte,
    required Widget tekenvlak,
    required Widget rechterkolom,
  }) {
    return SizedBox(
      height: hoogte,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(flex: tekenvlakFlex, child: tekenvlak),
          const SizedBox(width: tussenruimte),
          Expanded(flex: technischeKolomFlex, child: rechterkolom),
        ],
      ),
    );
  }

  static Widget bouwTekenvlak({
    required String maatTitel,
    required String maatWaarde,
    required Widget tekening,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: vlakAchtergrond,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rand),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: kopAchtergrond,
              border: Border(bottom: BorderSide(color: rand)),
            ),
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: '${maatTitel.trim()} ',
                    style: const TextStyle(
                      color: groen,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(
                    text: maatWaarde.trim(),
                    style: const TextStyle(
                      color: tekstDonker,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: tekening),
        ],
      ),
    );
  }

  static Widget bouwRechterkolom({
    required List<OpmetingOverzichtTechnischeRegel> technischeRegels,
    List<OpmetingOverzichtTechnischeRegelPrijs>? technischeRegelsMetPrijs,
    List<Widget> onderWidgets = const <Widget>[],
    String legeTekst = 'Geen technische kenmerken ingevuld.',
    bool scrollbaar = true,
    bool toonPrijsZone = true,
  }) {
    final regelWeergaven = combineerTechnischeRegelsMetPrijs(
      technischeRegelsMetPrijs ??
          technischeRegels
              .map(
                (regel) => OpmetingOverzichtTechnischeRegelPrijs(regel: regel),
              )
              .toList(growable: false),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: regelWeergaven.isEmpty
              ? bouwLegeTechnischeContainer(tekst: legeTekst)
              : bouwTechnischeRegelsMetPrijsContainer(
                  regelWeergaven,
                  scrollbaar: scrollbaar,
                  toonPrijsZone: toonPrijsZone,
                ),
        ),
        for (final widget in onderWidgets) ...<Widget>[
          const SizedBox(height: 9),
          widget,
        ],
      ],
    );
  }

  static Widget bouwLegeTechnischeContainer({
    String tekst = 'Geen technische kenmerken ingevuld.',
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: technischAchtergrond,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rand),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          tekst,
          style: const TextStyle(
            color: tekstGrijs,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static Widget bouwTechnischeRegelsContainer(
    List<OpmetingOverzichtTechnischeRegel> technischeRegels,
  ) {
    return bouwTechnischeRegelsMetPrijsContainer(
      combineerTechnischeRegels(technischeRegels)
          .map((regel) => OpmetingOverzichtTechnischeRegelPrijs(regel: regel))
          .toList(growable: false),
    );
  }

  static Widget bouwTechnischeRegelsMetPrijsContainer(
    List<OpmetingOverzichtTechnischeRegelPrijs> technischeRegels, {
    bool scrollbaar = true,
    bool toonPrijsZone = true,
  }) {
    final samengevoegdeRegels = combineerTechnischeRegelsMetPrijs(
      technischeRegels,
    );

    final inhoud = Column(
      children: List<Widget>.generate(samengevoegdeRegels.length, (index) {
        final weergave = samengevoegdeRegels[index];
        final regel = weergave.regel;

        return SizedBox(
          height: technischeRegelHoogte,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11),
            decoration: BoxDecoration(
              border: index == samengevoegdeRegels.length - 1
                  ? null
                  : const Border(bottom: BorderSide(color: rand, width: 0.8)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text.rich(
                        TextSpan(
                          children: <InlineSpan>[
                            TextSpan(
                              text: regel.titel,
                              style: const TextStyle(
                                color: tekstGrijs,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                height: 1.15,
                              ),
                            ),
                            if (regel.titel.isNotEmpty &&
                                regel.waarde.isNotEmpty)
                              const TextSpan(text: ': '),
                            if (regel.waarde.isNotEmpty)
                              TextSpan(
                                text: regel.waarde,
                                style: const TextStyle(
                                  color: tekstDonker,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                ),
                              ),
                          ],
                        ),
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ),
                  ),
                ),
                if (toonPrijsZone) ...<Widget>[
                  const SizedBox(width: 10),
                  SizedBox(
                    width: prijsZoneBreedte,
                    child: Text(
                      weergave.heeftBedrag
                          ? _formatteerBedrag(weergave.bedragExclBtw!)
                          : '',
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: tekstDonker,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );

    return Container(
      decoration: BoxDecoration(
        color: technischAchtergrond,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rand),
      ),
      clipBehavior: Clip.antiAlias,
      child: scrollbaar
          ? SingleChildScrollView(padding: EdgeInsets.zero, child: inhoud)
          : inhoud,
    );
  }

  static String _opEenRegel(String waarde) {
    return waarde.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String _formatteerBedrag(double bedrag) {
    return '€ ${bedrag.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  static String _technischeRegelSleutel(
    OpmetingOverzichtTechnischeRegel regel,
  ) {
    final titel = regel.titel.trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    final waarde = regel.waarde.trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    if (titel.isEmpty && waarde.isEmpty) {
      return '';
    }
    return '$titel|$waarde';
  }

  static OpmetingOverzichtTechnischeRegel _voorkeursRegel(
    OpmetingOverzichtTechnischeRegel eerste,
    OpmetingOverzichtTechnischeRegel tweede,
  ) {
    final eersteHeeftTitelEnWaarde =
        eerste.titel.trim().isNotEmpty && eerste.waarde.trim().isNotEmpty;
    final tweedeHeeftTitelEnWaarde =
        tweede.titel.trim().isNotEmpty && tweede.waarde.trim().isNotEmpty;

    if (!eersteHeeftTitelEnWaarde && tweedeHeeftTitelEnWaarde) {
      return tweede;
    }
    return eerste;
  }

  static double? _bruikbaarBedrag(double? bedrag) {
    if (bedrag == null || !bedrag.isFinite || bedrag <= 0.0) {
      return null;
    }
    return bedrag;
  }
}
