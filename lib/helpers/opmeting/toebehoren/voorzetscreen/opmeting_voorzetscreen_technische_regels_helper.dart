// THIMACO-CONTROLE: VOORZETSCREEN-TECHNISCHE-REGELS-BEDIENING-20260730-2115
import '../../overzicht/opmeting_overzicht_model.dart';
import 'opmeting_voorzetscreen_model.dart';

class OpmetingVoorzetscreenTechnischeRegelsHelper {
  const OpmetingVoorzetscreenTechnischeRegelsHelper._();

  static List<OpmetingOverzichtTechnischeRegel> bouw(
    OpmetingVoorzetscreenModel model,
  ) {
    final regels = <OpmetingOverzichtTechnischeRegel>[];

    void voegToe(String titel, Object? waarde) {
      final tekst = waarde?.toString().trim() ?? '';
      if (tekst.isEmpty) return;
      regels.add(OpmetingOverzichtTechnischeRegel(titel: titel, waarde: tekst));
    }

    voegToe('Positie', model.positie);
    voegToe('Aantal', model.aantal);
    voegToe(
      'Breedte',
      '${model.breedteMm} mm · ${model.breedteMeetwijzeTekst}',
    );
    voegToe('Hoogte', '${model.hoogteMm} mm · ${model.hoogteMeetwijzeTekst}');
    voegToe('Kast', model.kastSamenvatting);
    voegToe('Type doek', model.doekSamenvatting);
    voegToe('Kleur kast, geleiders en onderlat', model.kleurSamenvatting);
    voegToe('Zonnecel', model.zonnecel ? 'Ja' : 'Nee');
    voegToe('Bediening', model.bedieningSamenvatting);
    voegToe('Type motor', model.motorSamenvatting);
    voegToe('Kabellengte', model.kabellengteSamenvatting);
    voegToe('Uitgang kabel', model.uitgangKabel);

    return List<OpmetingOverzichtTechnischeRegel>.unmodifiable(regels);
  }
}
