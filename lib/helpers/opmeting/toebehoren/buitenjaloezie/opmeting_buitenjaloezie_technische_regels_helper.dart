// THIMACO-CONTROLE: BUITENJALOEZIE-TECHNISCHE-REGELS-KAST-UITSTEEK-20260804

import '../../overzicht/opmeting_overzicht_model.dart';
import 'opmeting_buitenjaloezie_model.dart';

class OpmetingBuitenjaloezieTechnischeRegelsHelper {
  const OpmetingBuitenjaloezieTechnischeRegelsHelper._();

  static List<OpmetingOverzichtTechnischeRegel> bouw(
    OpmetingBuitenjaloezieModel model,
  ) {
    final regels = <OpmetingOverzichtTechnischeRegel>[];

    void voegToe(String titel, Object? waarde) {
      final tekst = waarde?.toString().trim() ?? '';
      if (tekst.isEmpty) return;
      regels.add(OpmetingOverzichtTechnischeRegel(titel: titel, waarde: tekst));
    }

    voegToe('Referentie', model.referentie);
    voegToe('Aantal', model.aantal);
    voegToe('Systeem', model.systeemSamenvatting);
    voegToe(
      'Breedte',
      '${model.breedteMm} mm · ${model.breedteMeetwijzeTekst}',
    );
    voegToe('Totale breedte', '${model.totaleBreedteMm} mm');
    voegToe('Hoogte', '${model.hoogteMm} mm · ${model.hoogteMeetwijzeTekst}');
    voegToe('Kasthoogte', '${model.kastHoogteMm} mm');
    voegToe(
      'Uitsteek lamellenpakket',
      model.lamellenpakketUitsteekMm == 0
          ? '0 mm · volledig in de kast'
          : '${model.lamellenpakketUitsteekMm} mm onder de kast',
    );
    voegToe('Totale hoogte', '${model.totaleHoogteMm} mm');
    voegToe('Lameltype', model.lameltype.label);
    voegToe('Kleur lamellen', model.lamelkleurSamenvatting);
    voegToe('Ladderkoord', model.ladderkoord.label);
    voegToe('Type motor', model.motorType.label);
    voegToe('Bediening', model.bediening);
    voegToe('Motorkabel', '${model.motorkabelMeter} m');
    voegToe(
      'Bedieningszijde',
      '${model.bedieningszijde.label} · van binnen gezien',
    );
    voegToe('Kabeluitgang', model.kabeluitgang);
    voegToe('Boring', model.boring.label);
    voegToe('Afschuining geleiders', '${model.afschuiningGeleidersGraden}°');
    voegToe('Type geleiders', model.geleiderSamenvatting);
    voegToe('Klinkeruitvoering', model.klinkeruitvoering ? 'Ja' : 'Neen');
    voegToe('Onder gesloten', model.onderGesloten ? 'Ja' : 'Neen');

    return List<OpmetingOverzichtTechnischeRegel>.unmodifiable(regels);
  }
}
