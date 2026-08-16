// THIMACO-CONTROLE: PRIJS-VERDEELD-OVER-AANTAL-STUKS-HERBEREKEN-SIGNATUUR-20260816
// THIMACO-CONTROLE: PRIJS-VERDEELD-OVER-GEWOGEN-OP-AANTAL-STUKS-20260816
// THIMACO-CONTROLE: PRIJS-VERDEELD-OVER-AUTOMATISCH-UIT-INSTELLINGEN-20260815
// THIMACO-CONTROLE: PRIJS-VERDEELD-OVER-PROJECTSERVICE-20260815
import 'dart:convert';

import '../../opmeting/overzicht/opmeting_overzicht_model.dart';
import 'offerte_artikel_prijs_data_model.dart';
import 'offerte_artikel_prijs_koppeling_service.dart';
import 'offerte_prijs_verdeeld_over_template_model.dart';
import 'offerte_prijs_voor_alle_posities_regel_model.dart';
import 'offerte_prijs_voor_alle_posities_service.dart';

/// Bouwt "Prijzen verdeeld over…" volledig bovenop de actieve
/// [OffertePrijsVoorAllePositiesRegelModel]-opslag.
///
/// Eén verdeelgroep wordt opgeslagen als één projectregel per gekozen positie.
/// Alle deelregels dragen dezelfde groeps-id in hun prijsregel-id. Daardoor is
/// geen extra project- of JSON-model nodig en blijven berekening, PDF en
/// prijsoverzicht de bestaande prijs-voor-alle-positiesroute gebruiken.
class OffertePrijsVerdeeldOverService {
  const OffertePrijsVerdeeldOverService._();

  static const String _idPrefix = 'verdeeldOver::';

  static bool isVerdeeldOverRegel(
    OffertePrijsVoorAllePositiesRegelModel regel,
  ) {
    return _leesMeta(regel.id) != null;
  }

  /// Werkelijk aantal stuks waarmee een automatische verdeelkost moet rekenen.
  ///
  /// Voor vaste inzethorren lezen we bewust rechtstreeks het eigen `aantal`-veld
  /// uit. Daardoor kan een positie met 2 inzethorren nooit als één positie/stuk
  /// behandeld worden. Voor de andere artikeltypes gebruiken we dezelfde centrale
  /// artikelkoppeling als de offerteberekening.
  static int aantalStuksVoorVerdeling(OpmetingOverzichtRaamItem positie) {
    final vasteInzethorAantal = positie.vasteInzethorData?.aantal;
    if (vasteInzethorAantal != null) {
      return vasteInzethorAantal < 1 ? 1 : vasteInzethorAantal;
    }

    final berekening = OfferteArtikelPrijsKoppelingService.resultaatVoorArtikel(
      positie,
      kortingToestaan: !positie.isOfferteOptie,
    );
    final aantal =
        berekening?.aantalArtikelen ??
        OfferteArtikelPrijsKoppelingService.aantalVoorArtikel(positie);
    return aantal < 1 ? 1 : aantal;
  }

  /// Signatuur voor de onzichtbare synchronisator in het overzicht.
  /// Een wijziging van bijvoorbeeld 1 naar 2 vaste inzethorren verandert hierdoor
  /// altijd de widget-key en dwingt een nieuwe automatische verdeling af.
  static String verdeelSynchronisatieSignatuur(
    Iterable<OpmetingOverzichtRaamItem> posities,
  ) {
    return posities
        .map((positie) {
          return <Object?>[
            positie.id.trim(),
            positie.formulierTypeGenormaliseerd,
            aantalStuksVoorVerdeling(positie),
            positie.isVerwijderd,
            positie.isNietRekenen,
            positie.teltMeeInHoofdofferte,
          ].join(':');
        })
        .join('|');
  }

  /// Bouwt de automatisch toegepaste verdeelregels volledig opnieuw op uit de
  /// centrale Instellingen. Bestaande gewone "Prijs voor alle posities"-regels
  /// blijven onaangeroerd. Oude handmatig verdeelde regels worden vervangen door
  /// de actuele automatische toestand.
  ///
  /// De grens [maximaalTotaalExclBtw] wordt per instelling getest op het
  /// gezamenlijke offertetotaal van alleen de gekozen fichetypes, vóór enige
  /// automatische verdeelkost. Daardoor is de berekening stabiel en niet
  /// afhankelijk van de volgorde van verdeelregels.
  static List<OffertePrijsVoorAllePositiesRegelModel> synchroniseerAutomatisch({
    required List<OffertePrijsVoorAllePositiesRegelModel> bestaandeRegels,
    required List<OffertePrijsVerdeeldOverTemplateModel> templates,
    required List<OpmetingOverzichtRaamItem> posities,
  }) {
    final basisRegels = bestaandeRegels
        .where((regel) => !isVerdeeldOverRegel(regel))
        .toList(growable: false);
    var resultaat = <OffertePrijsVoorAllePositiesRegelModel>[...basisRegels];

    final actieveTemplates =
        templates
            .where((template) => template.isAutomatischGeldig)
            .toList(growable: true)
          ..sort((a, b) {
            final volgorde = a.volgorde.compareTo(b.volgorde);
            if (volgorde != 0) {
              return volgorde;
            }
            return a.id.compareTo(b.id);
          });

    for (final template in actieveTemplates) {
      final doelPosities = posities
          .where((positie) {
            if (positie.isVerwijderd ||
                positie.isNietRekenen ||
                !positie.teltMeeInHoofdofferte ||
                positie.id.trim().isEmpty ||
                !OfferteArtikelPrijsKoppelingService.isOndersteundArtikel(
                  positie,
                )) {
              return false;
            }
            return template.pastBijFormulierType(
              positie.formulierTypeGenormaliseerd,
            );
          })
          .toList(growable: false);

      if (doelPosities.isEmpty) {
        continue;
      }

      final totaalVoorGrens = _totaalVoorGrensExclBtw(
        posities: doelPosities,
        gewonePrijsVoorAllePositiesRegels: basisRegels,
      );
      if (template.heeftMaximumTotaal &&
          totaalVoorGrens - template.veiligMaximaalTotaalExclBtw > 0.0049) {
        continue;
      }

      resultaat = pasToeGewogen(
        bestaandeRegels: resultaat,
        template: template,
        totaalExclBtw: template.veiligTeVerdelenBedragExclBtw,
        geselecteerdePositieIds: doelPosities
            .map((positie) => positie.id.trim())
            .toList(growable: false),
        gewichten: doelPosities
            .map(aantalStuksVoorVerdeling)
            .toList(growable: false),
        bestaandeGroepId: _automatischeGroepId(template.id),
      );
    }

    return List<OffertePrijsVoorAllePositiesRegelModel>.unmodifiable(resultaat);
  }

  static double _totaalVoorGrensExclBtw({
    required List<OpmetingOverzichtRaamItem> posities,
    required List<OffertePrijsVoorAllePositiesRegelModel>
    gewonePrijsVoorAllePositiesRegels,
  }) {
    var totaal = 0.0;
    for (final positie in posities) {
      final geprojecteerd =
          OffertePrijsVoorAllePositiesService.projecteerOpArtikel(
            artikel: positie,
            regels: gewonePrijsVoorAllePositiesRegels,
          );
      final berekening =
          OfferteArtikelPrijsKoppelingService.resultaatVoorArtikel(
            geprojecteerd,
            kortingToestaan: !positie.isOfferteOptie,
          );
      if (berekening == null) {
        continue;
      }
      totaal += berekening.offerteTotaalExclBtw;
    }
    return _rondBedragAf(totaal);
  }

  static String _automatischeGroepId(String templateId) {
    return 'auto_${templateId.trim()}';
  }

  /// Stabiele vergelijking voor de onzichtbare synchronisator in het overzicht.
  static bool regelsZijnGelijk(
    List<OffertePrijsVoorAllePositiesRegelModel> eerste,
    List<OffertePrijsVoorAllePositiesRegelModel> tweede,
  ) {
    if (identical(eerste, tweede)) {
      return true;
    }
    if (eerste.length != tweede.length) {
      return false;
    }
    return jsonEncode(eerste.map((regel) => regel.toJson()).toList()) ==
        jsonEncode(tweede.map((regel) => regel.toJson()).toList());
  }

  /// Verdeelt een bedrag cent-nauwkeurig. De eerste posities krijgen zo nodig
  /// één restcent. De som is daardoor altijd exact gelijk aan het ingevoerde
  /// totaalbedrag.
  static List<double> verdeelBedragExclBtw({
    required double totaalExclBtw,
    required int aantalPosities,
  }) {
    if (!totaalExclBtw.isFinite ||
        totaalExclBtw <= 0.0 ||
        aantalPosities <= 0) {
      return const <double>[];
    }

    final totaalCenten = (totaalExclBtw * 100.0).round();
    if (totaalCenten <= 0) {
      return const <double>[];
    }

    final basisCenten = totaalCenten ~/ aantalPosities;
    final restCenten = totaalCenten % aantalPosities;

    return List<double>.generate(aantalPosities, (index) {
      final centen = basisCenten + (index < restCenten ? 1 : 0);
      return centen / 100.0;
    }, growable: false);
  }

  /// Verdeelt een bedrag cent-nauwkeurig volgens het aantal stuks per positie.
  /// Een positie met 2 stuks krijgt dus tweemaal het gewicht van een positie
  /// met 1 stuk. Restcenten gaan deterministisch naar de grootste restfractie.
  static List<double> verdeelBedragExclBtwGewogen({
    required double totaalExclBtw,
    required List<int> gewichten,
  }) {
    if (!totaalExclBtw.isFinite || totaalExclBtw <= 0.0 || gewichten.isEmpty) {
      return const <double>[];
    }

    final veiligeGewichten = gewichten
        .map((gewicht) => gewicht < 1 ? 1 : gewicht)
        .toList(growable: false);
    final totaalGewicht = veiligeGewichten.fold<int>(0, (som, gewicht) {
      return som + gewicht;
    });
    if (totaalGewicht <= 0) {
      return const <double>[];
    }

    final totaalCenten = (totaalExclBtw * 100.0).round();
    if (totaalCenten <= 0) {
      return const <double>[];
    }

    final centenPerPositie = List<int>.filled(veiligeGewichten.length, 0);
    final restfracties = <({int index, int rest})>[];
    var toegewezenCenten = 0;

    for (var index = 0; index < veiligeGewichten.length; index++) {
      final teller = totaalCenten * veiligeGewichten[index];
      final basisCenten = teller ~/ totaalGewicht;
      final rest = teller % totaalGewicht;
      centenPerPositie[index] = basisCenten;
      toegewezenCenten += basisCenten;
      restfracties.add((index: index, rest: rest));
    }

    restfracties.sort((eerste, tweede) {
      final restVergelijking = tweede.rest.compareTo(eerste.rest);
      if (restVergelijking != 0) {
        return restVergelijking;
      }
      return eerste.index.compareTo(tweede.index);
    });

    var resterendeCenten = totaalCenten - toegewezenCenten;
    for (
      var index = 0;
      index < restfracties.length && resterendeCenten > 0;
      index++
    ) {
      centenPerPositie[restfracties[index].index] += 1;
      resterendeCenten--;
    }

    return centenPerPositie
        .map((centen) => centen / 100.0)
        .toList(growable: false);
  }

  static double berekenVerkoopTotaalExclBtw({
    required OffertePrijsVerdeeldOverTemplateModel template,
    required double invoerTotaalExclBtw,
    required int aantalPosities,
  }) {
    final delen = verdeelBedragExclBtw(
      totaalExclBtw: invoerTotaalExclBtw,
      aantalPosities: aantalPosities,
    );

    final totaal = delen.fold<double>(0.0, (som, deel) {
      final regel = OffertePrijsPerPositieRegelModel(
        id: 'voorbeeld',
        omschrijving: template.omschrijving,
        type: template.type,
        aantal: 1,
        eenheid: 'st',
        eenheidsPrijsExclBtw: deel,
        winstPercentage: template.veiligeStandaardWinstPercentage,
        offerteWeergave: template.offerteWeergave,
      );
      return som + regel.eindTotaalExclBtw;
    });

    return _rondBedragAf(totaal);
  }

  static List<OffertePrijsVoorAllePositiesRegelModel> pasToe({
    required List<OffertePrijsVoorAllePositiesRegelModel> bestaandeRegels,
    required OffertePrijsVerdeeldOverTemplateModel template,
    required double totaalExclBtw,
    required List<String> geselecteerdePositieIds,
    String? bestaandeGroepId,
  }) {
    final positieIds = _uniekePositieIds(geselecteerdePositieIds);
    final delen = verdeelBedragExclBtw(
      totaalExclBtw: totaalExclBtw,
      aantalPosities: positieIds.length,
    );
    return _pasToeMetDelen(
      bestaandeRegels: bestaandeRegels,
      template: template,
      totaalExclBtw: totaalExclBtw,
      positieIds: positieIds,
      delen: delen,
      bestaandeGroepId: bestaandeGroepId,
    );
  }

  static List<OffertePrijsVoorAllePositiesRegelModel> pasToeGewogen({
    required List<OffertePrijsVoorAllePositiesRegelModel> bestaandeRegels,
    required OffertePrijsVerdeeldOverTemplateModel template,
    required double totaalExclBtw,
    required List<String> geselecteerdePositieIds,
    required List<int> gewichten,
    String? bestaandeGroepId,
  }) {
    final positieIds = _uniekePositieIds(geselecteerdePositieIds);
    if (positieIds.length != gewichten.length) {
      return List<OffertePrijsVoorAllePositiesRegelModel>.unmodifiable(
        bestaandeRegels,
      );
    }

    final delen = verdeelBedragExclBtwGewogen(
      totaalExclBtw: totaalExclBtw,
      gewichten: gewichten,
    );
    return _pasToeMetDelen(
      bestaandeRegels: bestaandeRegels,
      template: template,
      totaalExclBtw: totaalExclBtw,
      positieIds: positieIds,
      delen: delen,
      bestaandeGroepId: bestaandeGroepId,
    );
  }

  static List<OffertePrijsVoorAllePositiesRegelModel> _pasToeMetDelen({
    required List<OffertePrijsVoorAllePositiesRegelModel> bestaandeRegels,
    required OffertePrijsVerdeeldOverTemplateModel template,
    required double totaalExclBtw,
    required List<String> positieIds,
    required List<double> delen,
    String? bestaandeGroepId,
  }) {
    if (!template.isGeldig || !totaalExclBtw.isFinite || totaalExclBtw <= 0.0) {
      return List<OffertePrijsVoorAllePositiesRegelModel>.unmodifiable(
        bestaandeRegels,
      );
    }
    if (positieIds.isEmpty || delen.length != positieIds.length) {
      return List<OffertePrijsVoorAllePositiesRegelModel>.unmodifiable(
        bestaandeRegels,
      );
    }

    final huidigGroepId = bestaandeGroepId?.trim() ?? '';
    final oudeGroepRegels = huidigGroepId.isEmpty
        ? const <OffertePrijsVoorAllePositiesRegelModel>[]
        : bestaandeRegels
              .where((regel) {
                return _leesMeta(regel.id)?.groepId == huidigGroepId;
              })
              .toList(growable: false);

    final overigeRegels = bestaandeRegels
        .where((regel) {
          if (huidigGroepId.isEmpty) {
            return true;
          }
          return _leesMeta(regel.id)?.groepId != huidigGroepId;
        })
        .toList(growable: true);

    final groepId = huidigGroepId.isNotEmpty
        ? huidigGroepId
        : 'groep_${DateTime.now().microsecondsSinceEpoch}';
    final beginVolgorde = oudeGroepRegels.isNotEmpty
        ? oudeGroepRegels
              .map((regel) => regel.volgorde)
              .reduce((a, b) => a < b ? a : b)
        : _volgendeVolgorde(overigeRegels);

    for (var index = 0; index < positieIds.length; index++) {
      final positieId = positieIds[index];
      final id = _maakRegelId(
        groepId: groepId,
        templateId: template.id,
        positieId: positieId,
      );
      final prijsregel = OffertePrijsPerPositieRegelModel(
        id: id,
        omschrijving: template.omschrijving,
        type: template.type,
        aantal: 1,
        eenheid: 'st',
        eenheidsPrijsExclBtw: delen[index],
        winstPercentage: template.veiligeStandaardWinstPercentage,
        offerteWeergave: template.offerteWeergave,
      );

      overigeRegels.add(
        OffertePrijsVoorAllePositiesRegelModel(
          prijsregel: prijsregel,
          geselecteerdePositieIds: <String>{positieId},
          toepassenOpAllePosities: false,
          volgorde: beginVolgorde + index,
        ),
      );
    }

    return List<OffertePrijsVoorAllePositiesRegelModel>.unmodifiable(
      overigeRegels,
    );
  }

  static List<OffertePrijsVoorAllePositiesRegelModel> verwijderGroep({
    required List<OffertePrijsVoorAllePositiesRegelModel> bestaandeRegels,
    required String groepId,
  }) {
    final sleutel = groepId.trim();
    if (sleutel.isEmpty) {
      return List<OffertePrijsVoorAllePositiesRegelModel>.unmodifiable(
        bestaandeRegels,
      );
    }

    return List<OffertePrijsVoorAllePositiesRegelModel>.unmodifiable(
      bestaandeRegels.where((regel) => _leesMeta(regel.id)?.groepId != sleutel),
    );
  }

  static List<OffertePrijsVerdeeldOverGroep> leesGroepen(
    List<OffertePrijsVoorAllePositiesRegelModel> regels,
  ) {
    final perGroep = <String, List<_VerdeeldOverRegelMetMeta>>{};

    for (final regel in regels) {
      final meta = _leesMeta(regel.id);
      if (meta == null) {
        continue;
      }
      perGroep
          .putIfAbsent(meta.groepId, () => <_VerdeeldOverRegelMetMeta>[])
          .add(_VerdeeldOverRegelMetMeta(regel: regel, meta: meta));
    }

    final groepen = <OffertePrijsVerdeeldOverGroep>[];
    for (final entry in perGroep.entries) {
      final delen = entry.value;
      if (delen.isEmpty) {
        continue;
      }

      delen.sort((a, b) {
        final volgorde = a.regel.volgorde.compareTo(b.regel.volgorde);
        if (volgorde != 0) {
          return volgorde;
        }
        return a.meta.positieId.compareTo(b.meta.positieId);
      });

      final eerste = delen.first;
      final prijsregel = eerste.regel.prijsregel;
      final positieIds = <String>[];
      final gezien = <String>{};
      var invoerTotaal = 0.0;
      var verkoopTotaal = 0.0;
      var eersteVolgorde = eerste.regel.volgorde;

      for (final deel in delen) {
        if (gezien.add(deel.meta.positieId)) {
          positieIds.add(deel.meta.positieId);
        }
        invoerTotaal += deel.regel.prijsregel.basisTotaalExclBtw;
        verkoopTotaal += deel.regel.prijsregel.eindTotaalExclBtw;
        if (deel.regel.volgorde < eersteVolgorde) {
          eersteVolgorde = deel.regel.volgorde;
        }
      }

      groepen.add(
        OffertePrijsVerdeeldOverGroep(
          groepId: entry.key,
          templateId: eerste.meta.templateId,
          omschrijving: prijsregel.omschrijving,
          type: prijsregel.type,
          winstPercentage: prijsregel.veiligWinstPercentage,
          offerteWeergave: prijsregel.offerteWeergave,
          positieIds: List<String>.unmodifiable(positieIds),
          invoerTotaalExclBtw: _rondBedragAf(invoerTotaal),
          verkoopTotaalExclBtw: _rondBedragAf(verkoopTotaal),
          volgorde: eersteVolgorde,
        ),
      );
    }

    groepen.sort((a, b) {
      final volgorde = a.volgorde.compareTo(b.volgorde);
      if (volgorde != 0) {
        return volgorde;
      }
      return a.omschrijving.toLowerCase().compareTo(
        b.omschrijving.toLowerCase(),
      );
    });

    return List<OffertePrijsVerdeeldOverGroep>.unmodifiable(groepen);
  }

  static List<String> _uniekePositieIds(Iterable<String> ids) {
    final resultaat = <String>[];
    final gezien = <String>{};
    for (final id in ids) {
      final sleutel = id.trim();
      if (sleutel.isEmpty || !gezien.add(sleutel)) {
        continue;
      }
      resultaat.add(sleutel);
    }
    return resultaat;
  }

  static int _volgendeVolgorde(
    Iterable<OffertePrijsVoorAllePositiesRegelModel> regels,
  ) {
    var hoogste = -1;
    for (final regel in regels) {
      if (regel.volgorde > hoogste) {
        hoogste = regel.volgorde;
      }
    }
    return hoogste < 0 ? 0 : hoogste + 10;
  }

  static String _maakRegelId({
    required String groepId,
    required String templateId,
    required String positieId,
  }) {
    return '$_idPrefix${Uri.encodeComponent(groepId)}::'
        '${Uri.encodeComponent(templateId)}::${Uri.encodeComponent(positieId)}';
  }

  static _VerdeeldOverMeta? _leesMeta(String id) {
    final tekst = id.trim();
    if (!tekst.startsWith(_idPrefix)) {
      return null;
    }

    final delen = tekst.split('::');
    if (delen.length != 4 || delen.first != 'verdeeldOver') {
      return null;
    }

    try {
      final groepId = Uri.decodeComponent(delen[1]).trim();
      final templateId = Uri.decodeComponent(delen[2]).trim();
      final positieId = Uri.decodeComponent(delen[3]).trim();
      if (groepId.isEmpty || templateId.isEmpty || positieId.isEmpty) {
        return null;
      }
      return _VerdeeldOverMeta(
        groepId: groepId,
        templateId: templateId,
        positieId: positieId,
      );
    } catch (_) {
      return null;
    }
  }

  static double _rondBedragAf(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) {
      return 0.0;
    }
    return (waarde * 100.0).roundToDouble() / 100.0;
  }
}

class OffertePrijsVerdeeldOverGroep {
  const OffertePrijsVerdeeldOverGroep({
    required this.groepId,
    required this.templateId,
    required this.omschrijving,
    required this.type,
    required this.winstPercentage,
    required this.offerteWeergave,
    required this.positieIds,
    required this.invoerTotaalExclBtw,
    required this.verkoopTotaalExclBtw,
    required this.volgorde,
  });

  final String groepId;
  final String templateId;
  final String omschrijving;
  final OffertePrijsPerPositieType type;
  final double winstPercentage;
  final OffertePrijsPerPositieWeergave offerteWeergave;
  final List<String> positieIds;
  final double invoerTotaalExclBtw;
  final double verkoopTotaalExclBtw;
  final int volgorde;

  bool get isAankoop => type.isAankoop;
  bool get isVerkoop => type.isVerkoop;
}

class _VerdeeldOverMeta {
  const _VerdeeldOverMeta({
    required this.groepId,
    required this.templateId,
    required this.positieId,
  });

  final String groepId;
  final String templateId;
  final String positieId;
}

class _VerdeeldOverRegelMetMeta {
  const _VerdeeldOverRegelMetMeta({required this.regel, required this.meta});

  final OffertePrijsVoorAllePositiesRegelModel regel;
  final _VerdeeldOverMeta meta;
}
