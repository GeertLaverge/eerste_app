// THIMACO-CONTROLE: PRIJSARCHITECTUUR-STAP5D3C-UITVALSCHERM-ZONDER-VRIJE-PRIJSROUTE-20260814
// THIMACO-CONTROLE: UITVALSCHERM-PDF-WIDGET-20260801
import 'dart:math' as math;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../opmeting/toebehoren/uitvalscherm/opmeting_uitvalscherm_model.dart';
import '../opmeting/toebehoren/uitvalscherm/opmeting_uitvalscherm_technische_regels_helper.dart';
import '../opmeting/toebehoren/uitvalscherm/opmeting_uitvalscherm_svg_helper.dart';
import 'offerte_pdf_artikel_layout_helper.dart';
import 'prijzen/offerte_artikel_prijs_koppeling_service.dart';
import 'prijzen/offerte_prijsregel_weergave_service.dart';

class OffertePdfUitvalschermWidget {
  const OffertePdfUitvalschermWidget._();

  static const double _basisPrijsRegelHoogte = 34;
  static const double _basisOptiePrijsRegelHoogte = 78;

  static String _notitiesVoorPdf(
    OpmetingOverzichtRaamItem positie,
    OpmetingUitvalschermModel model,
  ) {
    final overzichtNotities = positie.notities.trim();
    if (overzichtNotities.isNotEmpty) {
      return overzichtNotities;
    }
    return model.notities.trim();
  }

  static double berekenKolomHoogte(OpmetingOverzichtRaamItem positie) {
    final model = positie.uitvalschermData;
    if (model == null) {
      return OffertePdfArtikelLayoutHelper.minimumKolomHoogte;
    }

    final notities = _notitiesVoorPdf(positie, model);

    final basisHoogte =
        OffertePdfArtikelLayoutHelper.berekenTechnischeKolomHoogte(
          regels: _technischeRegelsVoorOfferte(positie, model),
          notities: notities,
        );

    // Het opmerkingenblok bevat naast de tekst ook een scheidingslijn, titel en
    // tussenruimtes. Reserveer extra hoogte zodat opmerkingen bij een volle
    // technische kolom niet buiten de zichtbare PDF-zone vallen.
    final extraNotitieHoogte = notities.isEmpty ? 0.0 : 20.0;

    return (basisHoogte + extraNotitieHoogte)
        .clamp(
          OffertePdfArtikelLayoutHelper.minimumKolomHoogte,
          OffertePdfArtikelLayoutHelper.maximumKolomHoogte,
        )
        .toDouble();
  }

  static double berekenTotalePositieHoogte(
    OpmetingOverzichtRaamItem positie, {
    bool kortingToestaan = true,
    bool isOptie = false,
  }) {
    return OffertePdfArtikelLayoutHelper.berekenTotalePositieHoogte(
      kolomHoogte: berekenKolomHoogte(positie),
      prijsHoogte: isOptie
          ? _basisOptiePrijsRegelHoogte
          : _basisPrijsRegelHoogte,
    );
  }

  static pw.Widget bouwPositie({
    required OpmetingOverzichtRaamItem positie,
    bool kortingToestaan = true,
    bool isOptie = false,
    double btwPercentage = 0.0,
    String btwRegelLabel = 'BTW',
  }) {
    final model = positie.uitvalschermData;
    if (model == null) {
      return pw.SizedBox();
    }

    final hoogte = berekenKolomHoogte(positie);
    final regels = _technischeRegelsVoorOfferte(positie, model);

    return OffertePdfArtikelLayoutHelper.bouwArtikelLayout(
      kolomHoogte: hoogte,
      tekenvlak: OffertePdfArtikelLayoutHelper.bouwTekenvlak(
        hoogte: hoogte,
        maatTitel: 'Afmetingen',
        maatWaarde: model.maatSamenvatting,
        tekening: _bouwTekening(
          model,
          breedte: OffertePdfArtikelLayoutHelper.tekenInhoudBreedte,
          hoogte: math
              .max(120.0, hoogte - OffertePdfArtikelLayoutHelper.kopHoogte - 10)
              .toDouble(),
        ),
      ),
      technischeKolom: OffertePdfArtikelLayoutHelper.bouwTechnischeKolom(
        hoogte: hoogte,
        regels: regels,
        notities: _notitiesVoorPdf(positie, model),
        legeTekst: 'Geen gegevens ingevuld.',
      ),
      prijsBlok: _bouwPrijsBlok(
        positie,
        kortingToestaan: kortingToestaan && !isOptie,
        isOptie: isOptie,
        btwPercentage: btwPercentage,
        btwRegelLabel: btwRegelLabel,
      ),
    );
  }

  static List<OffertePdfTechnischeRegel> _technischeRegelsVoorOfferte(
    OpmetingOverzichtRaamItem positie,
    OpmetingUitvalschermModel model,
  ) {
    final resultaat = OpmetingUitvalschermTechnischeRegelsHelper.bouw(model)
        .map(
          (regel) => OffertePdfTechnischeRegel(
            titel: regel.titel,
            waarde: regel.waarde,
          ),
        )
        .toList(growable: true);

    final prijsResultaat =
        OfferteArtikelPrijsKoppelingService.resultaatVoorArtikel(
          positie,
          kortingToestaan: false,
        );
    if (prijsResultaat != null) {
      final zichtbareLokalePrijsregels =
          [
            ...prijsResultaat.omschrijvingZonderPrijsRegelsVoorOfferte,
            ...prijsResultaat.afzonderlijkePrijsregelsVoorOfferte,
          ].where(
            (prijsregel) =>
                !OffertePrijsregelWeergaveService.isTechnischePrijsregel(
                  prijsregel,
                ),
          );

      for (final prijsregel in zichtbareLokalePrijsregels) {
        if (!prijsregel.isGeldig || !prijsregel.teltMeeInOfferteTotaal) {
          continue;
        }

        final omschrijving =
            OffertePrijsregelWeergaveService.omschrijvingVoorOfferte(
              prijsregel,
            ).trim();
        if (omschrijving.isEmpty) {
          continue;
        }

        resultaat.add(
          OffertePdfTechnischeRegel(
            titel: omschrijving,
            waarde: '',
            prijsTekst: prijsregel.toonAfzonderlijkePrijsOpOfferte
                ? '€ ${prijsregel.totaalExclBtw.toStringAsFixed(2)}'
                : '',
          ),
        );
      }
    }

    return OffertePdfArtikelLayoutHelper.combineerTechnischeRegels(resultaat);
  }

  static pw.Widget _bouwPrijsBlok(
    OpmetingOverzichtRaamItem positie, {
    required bool kortingToestaan,
    required bool isOptie,
    required double btwPercentage,
    required String btwRegelLabel,
  }) {
    final resultaat = OfferteArtikelPrijsKoppelingService.resultaatVoorArtikel(
      positie,
      kortingToestaan: kortingToestaan && !isOptie,
    );
    final kortingEffectief = kortingToestaan && !isOptie;
    final totaalVoorKorting = resultaat == null
        ? 0.0
        : resultaat.offerteTotaalExclBtw +
              (kortingEffectief ? resultaat.kortingBedragExclBtw : 0.0);
    final optieTotaal = resultaat?.offerteTotaalExclBtw ?? 0.0;
    final optieBtw = _rond(optieTotaal * btwPercentage);
    final optieIncl = _rond(optieTotaal + optieBtw);
    final heeftPrijs =
        resultaat != null &&
        (resultaat.basisTotaalExclBtw > 0 ||
            resultaat.prijsregelsVoorOfferte.isNotEmpty);

    pw.Widget bedragRegel(
      String omschrijving,
      double bedrag, {
      bool benadrukt = false,
    }) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          children: <pw.Widget>[
            pw.Expanded(
              child: pw.Text(
                omschrijving,
                style: pw.TextStyle(
                  color: benadrukt
                      ? OffertePdfArtikelLayoutHelper.tekstDonker
                      : OffertePdfArtikelLayoutHelper.tekstGrijs,
                  fontSize: benadrukt ? 8.4 : 7.2,
                  fontWeight: benadrukt
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal,
                ),
              ),
            ),
            pw.Text(
              '€ ${bedrag.toStringAsFixed(2)}',
              style: pw.TextStyle(
                color: benadrukt
                    ? OffertePdfArtikelLayoutHelper.oranje
                    : OffertePdfArtikelLayoutHelper.tekstDonker,
                fontSize: benadrukt ? 10.8 : 7.6,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return pw.Container(
      height: isOptie ? _basisOptiePrijsRegelHoogte : _basisPrijsRegelHoogte,
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(7),
        border: pw.Border.all(
          color: OffertePdfArtikelLayoutHelper.rand,
          width: 0.8,
        ),
      ),
      child: isOptie
          ? pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: <pw.Widget>[
                bedragRegel('Totaal optie excl. btw', optieTotaal),
                bedragRegel(btwRegelLabel, optieBtw),
                bedragRegel(
                  'Totaal optie incl. btw',
                  optieIncl,
                  benadrukt: true,
                ),
              ],
            )
          : pw.Row(
              children: <pw.Widget>[
                pw.Expanded(
                  child: pw.Text(
                    'Totaal positie',
                    style: const pw.TextStyle(
                      color: OffertePdfArtikelLayoutHelper.tekstDonker,
                      fontSize: 8.0,
                    ),
                  ),
                ),
                if (totaalVoorKorting <= 0 && !heeftPrijs)
                  pw.Text(
                    'Prijs nog in te vullen',
                    style: const pw.TextStyle(
                      color: OffertePdfArtikelLayoutHelper.tekstGrijs,
                      fontSize: 8.0,
                    ),
                  )
                else
                  pw.Text(
                    '€ ${totaalVoorKorting.toStringAsFixed(2)} excl. btw',
                    style: const pw.TextStyle(
                      color: OffertePdfArtikelLayoutHelper.tekstDonker,
                      fontSize: 8.0,
                    ),
                  ),
              ],
            ),
    );
  }

  static pw.Widget _bouwTekening(
    OpmetingUitvalschermModel model, {
    required double breedte,
    required double hoogte,
  }) {
    return pw.SizedBox(
      width: breedte,
      height: hoogte,
      child: pw.SvgImage(
        svg: OpmetingUitvalschermSvgHelper.bouw(model),
        fit: pw.BoxFit.contain,
      ),
    );
  }

  static double _rond(double waarde) {
    if (!waarde.isFinite || waarde <= 0) {
      return 0;
    }
    return (waarde * 100).roundToDouble() / 100;
  }
}
