// THIMACO-CONTROLE: MAGAZIJN-BESTELBON-MAILTEKST-REPOSITORY-20260804

import '../../app_storage.dart';
import 'offerte_mail_tekst_model.dart';

class OfferteMailTekstenRepository {
  const OfferteMailTekstenRepository._();

  static Future<OfferteMailTekstenData> laad() async {
    final opgeslagen = await AppStorage.laadOfferteMailTeksten();
    final heeftBestelbon = opgeslagen.blokken.any(
      (blok) => blok.gebruik == OfferteMailBerichtGebruik.bestelbon,
    );
    if (heeftBestelbon) return opgeslagen;

    final standaardBestelbon = OfferteMailTekstenData.standaard().blokken
        .firstWhere(
          (blok) => blok.gebruik == OfferteMailBerichtGebruik.bestelbon,
        );
    final aangevuld = opgeslagen.copyWith(
      blokken: <OfferteMailTekstBlok>[
        ...opgeslagen.blokken,
        standaardBestelbon,
      ],
    );
    await AppStorage.bewaarOfferteMailTeksten(aangevuld);
    return aangevuld;
  }

  static Future<void> bewaar(OfferteMailTekstenData data) {
    return AppStorage.bewaarOfferteMailTeksten(data);
  }
}
