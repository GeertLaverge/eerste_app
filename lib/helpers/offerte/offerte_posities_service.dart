import '../opmeting/overzicht/opmeting_overzicht_model.dart';
import 'artikelen/offerte_artikel_model.dart';

class OffertePositiesService {
  const OffertePositiesService();

  List<OfferteArtikelModel> sorteerOpOorspronkelijkeVolgorde(
    Iterable<OfferteArtikelModel> artikelen,
  ) {
    final resultaat = List<OfferteArtikelModel>.from(artikelen)
      ..sort((eerste, tweede) {
        return eerste.oorspronkelijkeIndex.compareTo(
          tweede.oorspronkelijkeIndex,
        );
      });
    return List<OfferteArtikelModel>.unmodifiable(resultaat);
  }

  Map<String, String> maakPositieLabels(
    Iterable<OfferteArtikelModel> artikelen,
  ) {
    final gesorteerd = sorteerOpOorspronkelijkeVolgorde(artikelen);
    final labels = <String, String>{};
    var artikelNummer = 0;
    var optieNummer = 0;

    for (final artikel in gesorteerd) {
      if (artikel.isOptie) {
        optieNummer++;
        labels[artikel.id] = 'Optie ${letterVoorOptieNummer(optieNummer)}';
      } else {
        artikelNummer++;
        labels[artikel.id] = 'Pos $artikelNummer';
      }
    }

    return Map<String, String>.unmodifiable(labels);
  }

  List<OfferteArtikelModel> voorHoofdofferte(
    Iterable<OfferteArtikelModel> artikelen,
  ) {
    return List<OfferteArtikelModel>.unmodifiable(
      sorteerOpOorspronkelijkeVolgorde(artikelen).where((artikel) {
        return !artikel.isOptie || artikel.blijftOpOorspronkelijkePositie;
      }),
    );
  }

  List<OfferteArtikelModel> voorAparteOptiePaginas(
    Iterable<OfferteArtikelModel> artikelen,
  ) {
    return List<OfferteArtikelModel>.unmodifiable(
      sorteerOpOorspronkelijkeVolgorde(
        artikelen,
      ).where((artikel) => artikel.hoortOpAparteOptiePagina),
    );
  }

  Map<String, String> maakBronPositieLabels(
    List<OpmetingOverzichtRaamItem> posities,
  ) {
    final actievePosities = posities
        .where((positie) => !positie.isOfferteOptie)
        .toList(growable: false);
    final optiePosities = posities
        .where((positie) => positie.isOfferteOptie)
        .toList(growable: false);
    final labels = <String, String>{};

    for (var index = 0; index < actievePosities.length; index++) {
      labels[actievePosities[index].id] = 'Pos ${index + 1}';
    }
    for (var index = 0; index < optiePosities.length; index++) {
      labels[optiePosities[index].id] =
          'Optie ${letterVoorOptieNummer(index + 1)}';
    }

    return Map<String, String>.unmodifiable(labels);
  }

  List<OpmetingOverzichtRaamItem> groepeerBronPositiesVoorOverzicht(
    List<OpmetingOverzichtRaamItem> posities,
  ) {
    final actievePosities = posities
        .where((positie) => !positie.isOfferteOptie)
        .toList(growable: false);
    final optiePosities = posities
        .where((positie) => positie.isOfferteOptie)
        .toList(growable: false);
    final resultaat = <OpmetingOverzichtRaamItem>[];
    final toegevoegdeIds = <String>{};

    for (final hoofdpositie in actievePosities) {
      resultaat.add(hoofdpositie);
      toegevoegdeIds.add(hoofdpositie.id);

      for (final optie in optiePosities) {
        if (optie.offerteOptieHoofdpositieId.trim() != hoofdpositie.id) {
          continue;
        }
        resultaat.add(optie);
        toegevoegdeIds.add(optie.id);
      }
    }

    for (final positie in posities) {
      if (toegevoegdeIds.add(positie.id)) {
        resultaat.add(positie);
      }
    }

    return List<OpmetingOverzichtRaamItem>.unmodifiable(resultaat);
  }

  String bepaalOptieHoofdpositieId({
    required List<OpmetingOverzichtRaamItem> posities,
    required String positieId,
  }) {
    final huidigeIndex = posities.indexWhere(
      (positie) => positie.id == positieId,
    );
    if (huidigeIndex < 0) return '';

    final huidig = posities[huidigeIndex];
    final kopieBronId = huidig.gekopieerdVanPositieId.trim();
    if (kopieBronId.isNotEmpty) {
      final bronBestaat = posities.any((positie) {
        return positie.id == kopieBronId && positie.teltMeeInHoofdofferte;
      });
      if (bronBestaat) return kopieBronId;
    }

    for (var index = huidigeIndex - 1; index >= 0; index--) {
      final kandidaat = posities[index];
      if (kandidaat.teltMeeInHoofdofferte) return kandidaat.id;
    }

    for (var index = huidigeIndex + 1; index < posities.length; index++) {
      final kandidaat = posities[index];
      if (kandidaat.teltMeeInHoofdofferte) return kandidaat.id;
    }

    return '';
  }

  String letterVoorOptieNummer(int nummer) {
    var waarde = nummer < 1 ? 1 : nummer;
    final tekens = <int>[];

    while (waarde > 0) {
      waarde--;
      tekens.add(65 + (waarde % 26));
      waarde ~/= 26;
    }

    return String.fromCharCodes(tekens.reversed);
  }
}
