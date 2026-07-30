// THIMACO-CONTROLE: VELUX-TECHNISCHE-REGELS-FASE-1-2-20260729-2030
import '../../overzicht/opmeting_overzicht_model.dart';
import 'opmeting_velux_dakraam_model.dart';

class OpmetingVeluxDakraamTechnischeRegelsHelper {
  const OpmetingVeluxDakraamTechnischeRegelsHelper._();

  static List<OpmetingOverzichtTechnischeRegel> bouw(
    OpmetingVeluxDakraamModel model,
  ) {
    final regels = <OpmetingOverzichtTechnischeRegel>[];

    void voegToe(String titel, String waarde) {
      final opgeschoond = waarde.trim();
      if (opgeschoond.isEmpty) return;
      regels.add(
        OpmetingOverzichtTechnischeRegel(titel: titel, waarde: opgeschoond),
      );
    }

    if (model.alleenToebehoren) {
      voegToe('Uitvoering', 'Alleen toebehoren');
    } else {
      voegToe('Aantal', model.veiligAantal.toString());
      voegToe(
        'Dakvenster',
        '${model.productCode} ${model.maatCode} · ${model.afmetingLabel}',
      );
      if (model.gootstukType != OpmetingVeluxGootstukType.geen) {
        voegToe(
          'Gootstuk',
          '${model.gootstukType.label} · gootstukken ${model.maatCode}',
        );
      }
    }

    if (model.rolluikType != OpmetingVeluxRolluikType.geen) {
      voegToe(
        'Rolluik',
        '${model.rolluikType.label} · ${model.effectiefRolluikAantal} st.',
      );
    }

    if (model.screenType != OpmetingVeluxScreenType.geen) {
      voegToe(
        'Buitenscreen',
        '${model.screenType.label} · ${model.effectiefScreenAantal} st.',
      );
    }

    if (model.verduisteringsgordijnDkl) {
      voegToe(
        'Verduisteringsgordijn',
        'Manueel DKL · kleur ${model.dklKleur.label} · '
            '${model.effectiefDklAantal} st.',
      );
    }

    if (model.muggengaas) {
      final code = model.muggengaasProductCode.trim().isEmpty
          ? 'maat nog niet beschikbaar'
          : model.muggengaasProductCode.trim();
      voegToe(
        'Muggengaas',
        '$code · ${model.muggengaasBreedteMm} × '
            '${model.muggengaasHoogteMm} mm · '
            '${model.effectiefMuggengaasAantal} st.',
      );
    }

    if (model.kux110) {
      voegToe(
        'Stroomvoorziening',
        'KUX 110 · ${model.kuxAantal.clamp(1, 99).toInt()} st.',
      );
    }

    if (model.afwerkingType != OpmetingVeluxAfwerkingType.geen) {
      voegToe('Afwerken Velux', model.afwerkingType.label);
    }

    voegToe('Catalogus', model.catalogusJaar.toString());
    return List<OpmetingOverzichtTechnischeRegel>.unmodifiable(regels);
  }
}
