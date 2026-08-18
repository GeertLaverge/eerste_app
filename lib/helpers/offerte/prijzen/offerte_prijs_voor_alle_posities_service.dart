// THIMACO-CONTROLE: PRIJS-VOOR-ALLE-POSITIES-PDF-MAATEENHEDEN-20260818
// THIMACO-CONTROLE: PRIJS-VOOR-ALLE-POSITIES-PDF-ONDERAAN-ALLE-REGELS-20260818
// THIMACO-CONTROLE: PRIJS-VOOR-ALLE-POSITIES-CENTRALE-BEREKENING-20260815
import '../../opmeting/overzicht/opmeting_overzicht_model.dart';
import 'offerte_artikel_prijs_data_model.dart';
import 'offerte_artikel_prijs_koppeling_service.dart';
import 'offerte_prijs_voor_alle_posities_regel_model.dart';

/// Centrale reken- en projectiehelper voor "Prijs voor alle posities".
///
/// De projectregel blijft één keer in het projecttitelhoofd opgeslagen.
/// Voor schermberekeningen kan tijdelijk een prijs-per-positieregel-kopie in de
/// prijsdata van de doelpositie worden geprojecteerd. De echte opmeting wordt
/// daarbij niet opgeslagen of gewijzigd.
///
/// De offerte-PDF projecteert deze regels bewust niet meer in de afzonderlijke
/// posities. Voor de PDF worden de regels centraal over hun doelposities
/// opgeteld en één keer onder alle artikelen uitgeschreven.
class OffertePrijsVoorAllePositiesService {
  const OffertePrijsVoorAllePositiesService._();

  static const String _synthetischeIdPrefix = 'prijsVoorAllePosities::';

  static bool _regelPastBijArtikel({
    required OffertePrijsVoorAllePositiesRegelModel regel,
    required OpmetingOverzichtRaamItem artikel,
  }) {
    if (!regel.isGeldig || artikel.isVerwijderd || artikel.id.trim().isEmpty) {
      return false;
    }

    // "Alle posities" betekent bewust alle gewone hoofdposities.
    // Een optie krijgt de regel alleen wanneer haar ID later expliciet als
    // doelpositie zou worden gekozen.
    if (regel.toepassenOpAllePosities) {
      return artikel.teltMeeInHoofdofferte;
    }

    return regel.geselecteerdePositieIds.contains(artikel.id.trim());
  }

  static List<OffertePrijsVoorAllePositiesRegelModel> regelsVoorArtikel({
    required OpmetingOverzichtRaamItem artikel,
    required List<OffertePrijsVoorAllePositiesRegelModel> regels,
  }) {
    final resultaat =
        regels
            .where(
              (regel) => _regelPastBijArtikel(regel: regel, artikel: artikel),
            )
            .toList(growable: true)
          ..sort((eerste, tweede) {
            final volgorde = eerste.volgorde.compareTo(tweede.volgorde);
            if (volgorde != 0) {
              return volgorde;
            }
            return eerste.id.compareTo(tweede.id);
          });

    return List<OffertePrijsVoorAllePositiesRegelModel>.unmodifiable(resultaat);
  }

  static List<OffertePrijsVoorAllePositiesRegelModel> regelsVoorPositieId({
    required String positieId,
    required List<OffertePrijsVoorAllePositiesRegelModel> regels,
  }) {
    final sleutel = positieId.trim();
    if (sleutel.isEmpty) {
      return const <OffertePrijsVoorAllePositiesRegelModel>[];
    }

    final resultaat =
        regels
            .where(
              (regel) => regel.isGeldig && regel.isVanToepassingOp(sleutel),
            )
            .toList(growable: true)
          ..sort((eerste, tweede) {
            final volgorde = eerste.volgorde.compareTo(tweede.volgorde);
            if (volgorde != 0) {
              return volgorde;
            }
            return eerste.id.compareTo(tweede.id);
          });

    return List<OffertePrijsVoorAllePositiesRegelModel>.unmodifiable(resultaat);
  }

  static double totaalVoorPositie({
    required String positieId,
    required int breedteMm,
    required int hoogteMm,
    required List<OffertePrijsVoorAllePositiesRegelModel> regels,
  }) {
    final totaal = regelsVoorPositieId(positieId: positieId, regels: regels)
        .fold<double>(0.0, (som, regel) {
          return som +
              regel.prijsregel.eindTotaalExclBtwVoorMaten(
                breedteMm: breedteMm,
                hoogteMm: hoogteMm,
              );
        });

    return _rondBedragAf(totaal);
  }

  static bool heeftToepassingOpPosities({
    required OffertePrijsVoorAllePositiesRegelModel regel,
    required List<OpmetingOverzichtRaamItem> posities,
  }) {
    if (!regel.isGeldig || posities.isEmpty) {
      return false;
    }

    return posities.any(
      (artikel) => _regelPastBijArtikel(regel: regel, artikel: artikel),
    );
  }

  static double totaalVoorRegelOverPosities({
    required OffertePrijsVoorAllePositiesRegelModel regel,
    required List<OpmetingOverzichtRaamItem> posities,
  }) {
    if (!regel.isGeldig || posities.isEmpty) {
      return 0.0;
    }

    var totaal = 0.0;
    for (final artikel in posities) {
      if (!_regelPastBijArtikel(regel: regel, artikel: artikel)) {
        continue;
      }

      final resultaat =
          OfferteArtikelPrijsKoppelingService.resultaatVoorArtikel(
            artikel,
            kortingToestaan: false,
          );
      if (resultaat == null) {
        continue;
      }

      // Gebruik voor projectbrede prijsregels exact dezelfde artikelmaten als
      // het overzicht. Sommige prijsresultaten bevatten voor specifieke
      // artikeltypes geen bruikbare maatvelden, terwijl de centrale
      // artikelkoppeling de actuele breedte/hoogte wel correct kent.
      final breedteMm =
          OfferteArtikelPrijsKoppelingService.breedteMmVoorArtikel(artikel);
      final hoogteMm = OfferteArtikelPrijsKoppelingService.hoogteMmVoorArtikel(
        artikel,
      );

      totaal += regel.prijsregel.eindTotaalExclBtwVoorMaten(
        breedteMm: breedteMm,
        hoogteMm: hoogteMm,
      );
    }

    return _rondBedragAf(totaal);
  }

  static double totaalOverPosities({
    required List<OffertePrijsVoorAllePositiesRegelModel> regels,
    required List<OpmetingOverzichtRaamItem> posities,
  }) {
    if (regels.isEmpty || posities.isEmpty) {
      return 0.0;
    }

    final totaal = regels
        .where((regel) => regel.isGeldig)
        .fold<double>(
          0.0,
          (som, regel) =>
              som +
              totaalVoorRegelOverPosities(regel: regel, posities: posities),
        );

    return _rondBedragAf(totaal);
  }

  static List<OffertePrijsPerPositieRegelModel> _projecteerPrijsregels({
    required OpmetingOverzichtRaamItem artikel,
    required List<OffertePrijsVoorAllePositiesRegelModel> regels,
  }) {
    return regelsVoorArtikel(artikel: artikel, regels: regels)
        .map((regel) {
          return regel.prijsregel.kopieMetNieuwId(
            '$_synthetischeIdPrefix${regel.id}',
          );
        })
        .toList(growable: false);
  }

  /// Geeft een tijdelijke artikelkopie terug waarin de projectbrede regels
  /// alleen voor berekening/PDF als lokale prijsregels zijn toegevoegd.
  ///
  /// De opgeslagen prijsdata in AppStorage blijft ongewijzigd.
  static OpmetingOverzichtRaamItem projecteerOpArtikel({
    required OpmetingOverzichtRaamItem artikel,
    required List<OffertePrijsVoorAllePositiesRegelModel> regels,
  }) {
    final prijsData = OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(
      artikel,
    );
    if (prijsData == null) {
      return artikel;
    }

    final geprojecteerdeRegels = _projecteerPrijsregels(
      artikel: artikel,
      regels: regels,
    );

    // Verwijder eventueel eerder geprojecteerde tijdelijke kopieën. Daarmee is
    // deze methode idempotent en kan ze veilig meer dan één keer worden gebruikt.
    final echteLokaleRegels = prijsData.prijsPerPositieRegels
        .where((regel) => !regel.id.trim().startsWith(_synthetischeIdPrefix))
        .toList(growable: false);

    if (geprojecteerdeRegels.isEmpty &&
        echteLokaleRegels.length == prijsData.prijsPerPositieRegels.length) {
      return artikel;
    }

    final tijdelijkePrijsData = prijsData.copyWith(
      prijsPerPositieRegels: <OffertePrijsPerPositieRegelModel>[
        ...echteLokaleRegels,
        ...geprojecteerdeRegels,
      ],
    );

    return OfferteArtikelPrijsKoppelingService.schrijfPrijsData(
      artikel: artikel,
      prijsData: tijdelijkePrijsData,
    );
  }

  static List<OpmetingOverzichtRaamItem> projecteerOpPosities({
    required List<OpmetingOverzichtRaamItem> posities,
    required List<OffertePrijsVoorAllePositiesRegelModel> regels,
  }) {
    if (posities.isEmpty || regels.isEmpty) {
      return List<OpmetingOverzichtRaamItem>.unmodifiable(posities);
    }

    return List<OpmetingOverzichtRaamItem>.unmodifiable(
      posities.map(
        (positie) => projecteerOpArtikel(artikel: positie, regels: regels),
      ),
    );
  }

  static double _rondBedragAf(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) {
      return 0.0;
    }
    return (waarde * 100.0).roundToDouble() / 100.0;
  }
}
