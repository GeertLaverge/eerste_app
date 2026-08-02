// THIMACO-CONTROLE: OFFERTE-MAIL-TEKSTEN-REPOSITORY-20260802

import '../../app_storage.dart';
import 'offerte_mail_tekst_model.dart';

class OfferteMailTekstenRepository {
  const OfferteMailTekstenRepository._();

  static Future<OfferteMailTekstenData> laad() {
    return AppStorage.laadOfferteMailTeksten();
  }

  static Future<void> bewaar(OfferteMailTekstenData data) {
    return AppStorage.bewaarOfferteMailTeksten(data);
  }
}
