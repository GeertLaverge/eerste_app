// THIMACO-CONTROLE: VELUX-AFWERKING-VIA-TECHNISCHE-PRIJSREGEL-20260730
// THIMACO-CONTROLE: VELUX-CATALOGUSPRIJS-HELPER-FASE-1-2-20260729-2030
import 'opmeting_velux_dakraam_instellingen_model.dart';
import 'opmeting_velux_dakraam_model.dart';

class OpmetingVeluxDakraamPrijsHelper {
  const OpmetingVeluxDakraamPrijsHelper._();

  static OpmetingVeluxDakraamModel bereken({
    required OpmetingVeluxDakraamModel model,
    required OpmetingVeluxDakraamInstellingen instellingen,
  }) {
    final basis = instellingen.prijsVoorProductEnMaat(
      productCode: model.productCode,
      maatCode: model.maatCode,
    );

    final breedteMm = basis == null ? model.breedteMm : basis.breedteCm * 10;
    final hoogteMm = basis == null ? model.hoogteMm : basis.hoogteCm * 10;

    final gootstuk = model.gootstukType == OpmetingVeluxGootstukType.geen
        ? null
        : instellingen.prijsVoorProductEnMaat(
            productCode: model.gootstukType.productCode,
            maatCode: model.maatCode,
          );

    final rolluik = model.rolluikType == OpmetingVeluxRolluikType.geen
        ? null
        : instellingen.prijsVoorProductEnMaat(
            productCode: model.rolluikType.productCode,
            maatCode: model.maatCode,
          );

    final screenMaat = model.screenType == OpmetingVeluxScreenType.manueelMhl
        ? _manueleScreenMaat(model.maatCode)
        : model.maatCode;
    final screen = model.screenType == OpmetingVeluxScreenType.geen
        ? null
        : instellingen.prijsVoorProductEnMaat(
            productCode: model.screenType.productCode,
            maatCode: screenMaat,
          );

    final dkl = !model.verduisteringsgordijnDkl
        ? null
        : instellingen.prijsVoorProductEnMaat(
            productCode: OpmetingVeluxDakraamInstellingen
                .verduisteringsGordijnProductCode,
            maatCode: model.maatCode,
          );

    final muggengaasBreedte = model.alleenToebehoren
        ? model.muggengaasBreedteMm
        : breedteMm;
    final muggengaasHoogte = model.alleenToebehoren
        ? model.muggengaasHoogteMm
        : hoogteMm;
    final muggengaas = !model.muggengaas
        ? null
        : instellingen.muggengaasPrijsVoorAfmetingen(
            breedteMm: muggengaasBreedte,
            hoogteMm: muggengaasHoogte,
          );

    return model.copyWith(
      aantal: model.veiligAantal,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      rolluikAantal: model.beperkAccessoireAantal(model.rolluikAantal),
      screenAantal: model.beperkAccessoireAantal(model.screenAantal),
      dklAantal: model.beperkAccessoireAantal(model.dklAantal),
      muggengaasAantal: model.beperkAccessoireAantal(model.muggengaasAantal),
      muggengaasBreedteMm: muggengaasBreedte,
      muggengaasHoogteMm: muggengaasHoogte,
      muggengaasProductCode: muggengaas?.productCode ?? '',
      kuxAantal: model.kuxAantal.clamp(1, 99).toInt(),
      catalogusJaar: instellingen.catalogusJaar,
      basisPrijsPerStukExclBtw: model.alleenToebehoren
          ? 0
          : basis?.prijsExclBtw ?? 0,
      gootstukPrijsPerStukExclBtw: model.alleenToebehoren
          ? 0
          : gootstuk?.prijsExclBtw ?? 0,
      rolluikPrijsPerStukExclBtw: rolluik?.prijsExclBtw ?? 0,
      screenPrijsPerStukExclBtw: screen?.prijsExclBtw ?? 0,
      dklPrijsPerStukExclBtw: dkl?.prijsExclBtw ?? 0,
      muggengaasPrijsPerStukExclBtw: muggengaas?.prijsExclBtw ?? 0,
      kuxPrijsPerStukExclBtw: instellingen.kux110PrijsExclBtw,
      afwerkingPrijsPerStukExclBtw: 0,
    );
  }

  static String _manueleScreenMaat(String maatCode) {
    final tekst = maatCode.trim().toUpperCase();
    if (tekst.length < 2) return tekst;
    return '${tekst.substring(0, 2)}00';
  }
}
