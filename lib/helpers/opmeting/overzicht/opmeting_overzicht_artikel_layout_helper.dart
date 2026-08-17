// THIMACO-CONTROLE: TECHNISCHE-KEUZE-DYNAMISCHE-REGELHOOGTE-20260817
// THIMACO-CONTROLE: TECHNISCHE-CONTAINER-EXACT-PER-REGEL-20260815
// THIMACO-CONTROLE: TECHNISCHE-LEEGTE-1-REGEL-20260814
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

  // Een technische keuze start op één regel van 31 px. Lange tekst wordt
  // nooit kleiner gemaakt: de rij groeit per extra tekstregel automatisch mee.
  static const double technischeRegelHoogte = 31;
  static const double technischeRegelVerticalePadding = 7;
  static const double technischeTekstGrootte = 12;
  static const double technischeTekstRegelhoogte = 1.25;
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

  /// Berekent de echte breedte van de technische kolom binnen [bouwLayout].
  /// Omdat dit op de actuele layoutbreedte gebeurt, wordt de teksthoogte
  /// automatisch opnieuw bepaald wanneer het scherm staand/liggend draait.
  static double berekenTechnischeKolomBreedte(double totaleBreedte) {
    if (!totaleBreedte.isFinite || totaleBreedte <= 0) {
      return 320;
    }

    final bruikbareBreedte = totaleBreedte - tussenruimte;
    if (bruikbareBreedte <= 0) {
      return totaleBreedte;
    }

    return bruikbareBreedte *
        technischeKolomFlex /
        (tekenvlakFlex + technischeKolomFlex);
  }

  /// Hoogte van alle technische keuzes bij de werkelijk beschikbare breedte.
  /// Elke keuze krijgt minimaal één leesbare regel; langere tekst krijgt
  /// automatisch twee, drie, ... regels.
  static double berekenTechnischeRegelsHoogte({
    required List<OpmetingOverzichtTechnischeRegelPrijs> technischeRegels,
    required double beschikbareBreedte,
    bool toonPrijsZone = true,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    final samengevoegdeRegels = combineerTechnischeRegelsMetPrijs(
      technischeRegels,
    );

    if (samengevoegdeRegels.isEmpty) {
      return technischeRegelHoogte;
    }

    final tekstBreedte = _technischeTekstBreedte(
      beschikbareBreedte: beschikbareBreedte,
      toonPrijsZone: toonPrijsZone,
    );

    var totaleHoogte = technischeContainerRandReserve;

    for (final weergave in samengevoegdeRegels) {
      final painter = TextPainter(
        text: _technischeTekstSpan(weergave.regel),
        textDirection: textDirection,
      )..layout(maxWidth: tekstBreedte);

      final gemetenHoogte =
          painter.height + (technischeRegelVerticalePadding * 2);
      totaleHoogte += gemetenHoogte < technischeRegelHoogte
          ? technischeRegelHoogte
          : gemetenHoogte;
    }

    return totaleHoogte;
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final technischeHoogte = regelWeergaven.isEmpty
            ? technischeRegelHoogte
            : berekenTechnischeRegelsHoogte(
                technischeRegels: regelWeergaven,
                beschikbareBreedte: constraints.maxWidth,
                toonPrijsZone: toonPrijsZone,
                textDirection: Directionality.of(context),
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (regelWeergaven.isEmpty)
              bouwLegeTechnischeContainer(tekst: legeTekst)
            else
              SizedBox(
                height: technischeHoogte,
                child: bouwTechnischeRegelsMetPrijsContainer(
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
      },
    );
  }

  static Widget bouwLegeTechnischeContainer({
    String tekst = 'Geen technische kenmerken ingevuld.',
  }) {
    return SizedBox(
      height: technischeRegelHoogte,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          color: technischAchtergrond,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: rand),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            tekst,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: tekstGrijs,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
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
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(samengevoegdeRegels.length, (index) {
        final weergave = samengevoegdeRegels[index];
        final regel = weergave.regel;

        return Container(
          constraints: const BoxConstraints(minHeight: technischeRegelHoogte),
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: technischeRegelVerticalePadding,
          ),
          decoration: BoxDecoration(
            border: index == samengevoegdeRegels.length - 1
                ? null
                : const Border(bottom: BorderSide(color: rand, width: 0.8)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Text.rich(
                  _technischeTekstSpan(regel),
                  softWrap: true,
                  overflow: TextOverflow.visible,
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
                      height: technischeTekstRegelhoogte,
                    ),
                  ),
                ),
              ],
            ],
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

  static TextSpan _technischeTekstSpan(OpmetingOverzichtTechnischeRegel regel) {
    return TextSpan(
      style: const TextStyle(
        fontSize: technischeTekstGrootte,
        height: technischeTekstRegelhoogte,
      ),
      children: <InlineSpan>[
        TextSpan(
          text: regel.titel,
          style: const TextStyle(
            color: tekstGrijs,
            fontSize: technischeTekstGrootte,
            fontWeight: FontWeight.w700,
            height: technischeTekstRegelhoogte,
          ),
        ),
        if (regel.titel.isNotEmpty && regel.waarde.isNotEmpty)
          const TextSpan(
            text: ': ',
            style: TextStyle(
              color: tekstGrijs,
              fontSize: technischeTekstGrootte,
              fontWeight: FontWeight.w700,
              height: technischeTekstRegelhoogte,
            ),
          ),
        if (regel.waarde.isNotEmpty)
          TextSpan(
            text: regel.waarde,
            style: const TextStyle(
              color: tekstDonker,
              fontSize: technischeTekstGrootte,
              fontWeight: FontWeight.w800,
              height: technischeTekstRegelhoogte,
            ),
          ),
      ],
    );
  }

  static double _technischeTekstBreedte({
    required double beschikbareBreedte,
    required bool toonPrijsZone,
  }) {
    final veiligeBreedte = beschikbareBreedte.isFinite && beschikbareBreedte > 0
        ? beschikbareBreedte
        : 320.0;
    final prijsReserve = toonPrijsZone ? 10 + prijsZoneBreedte : 0.0;
    final tekstBreedte = veiligeBreedte - 22 - 2 - prijsReserve;

    return tekstBreedte < 40 ? 40 : tekstBreedte;
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
