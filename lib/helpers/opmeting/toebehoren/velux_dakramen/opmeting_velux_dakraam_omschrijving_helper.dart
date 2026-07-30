// THIMACO-CONTROLE: VELUX-AANTAL-ALLEEN-BIJ-MEERDERE-STUKS-20260730
// THIMACO-CONTROLE: VELUX-KLANTVRIENDELIJKE-OMSCHRIJVINGEN-20260730
import 'opmeting_velux_dakraam_model.dart';

class OpmetingVeluxDakraamOmschrijvingHelper {
  const OpmetingVeluxDakraamOmschrijvingHelper._();

  static String metAantal(String omschrijving, int aantal) {
    final tekst = omschrijving.trim();
    if (tekst.isEmpty) return '';
    final veiligAantal = aantal < 1 ? 1 : aantal;
    return veiligAantal > 1 ? '$veiligAantal × $tekst' : tekst;
  }

  static String dakvenster(OpmetingVeluxDakraamModel model) {
    return 'Dakvenster Velux ${model.productCode} : ${model.maatCode}';
  }

  static String gootstukken(OpmetingVeluxDakraamModel model) {
    return 'Gootstukken ${model.gootstukType.productCode} : ${model.maatCode}';
  }

  static String rolluik(OpmetingVeluxDakraamModel model) {
    return 'Rolluik ${model.rolluikType.productCode} - ${model.maatCode} · '
        '${model.rolluikType.label}';
  }

  static String buitenscherm(OpmetingVeluxDakraamModel model) {
    return 'Buitenzonnescherm ${model.screenType.productCode} - '
        '${model.maatCode} · ${model.screenType.label}';
  }

  static String verduisteringsgordijn(OpmetingVeluxDakraamModel model) {
    return 'Verduisteringsgordijn DKL - ${model.maatCode} · '
        'kleur ${model.dklKleur.label}';
  }

  static String muggengaas(OpmetingVeluxDakraamModel model) {
    final productCode = model.muggengaasProductCode.trim();
    final codeTekst = productCode.isEmpty ? '' : ' $productCode';
    return 'Muggengaas$codeTekst : ${model.muggengaasBreedteMm} × '
        '${model.muggengaasHoogteMm} mm';
  }

  static String stroomvoorziening() {
    return 'Stroomvoorziening KUX 110';
  }

  static String afwerking(OpmetingVeluxDakraamModel model) {
    return 'Afwerking Velux : ${model.afwerkingType.label}';
  }
}
