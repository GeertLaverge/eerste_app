import '../../overzicht/opmeting_overzicht_model.dart';
import 'opmeting_uitvalscherm_model.dart';

class OpmetingUitvalschermTechnischeRegelsHelper {
  const OpmetingUitvalschermTechnischeRegelsHelper._();

  static List<OpmetingOverzichtTechnischeRegel> bouw(
    OpmetingUitvalschermModel model,
  ) {
    final regels = <OpmetingOverzichtTechnischeRegel>[];

    void voegToe(String titel, Object? waarde) {
      final tekst = waarde?.toString().trim() ?? '';
      if (tekst.isEmpty) return;
      regels.add(OpmetingOverzichtTechnischeRegel(titel: titel, waarde: tekst));
    }

    voegToe('Positie', model.positie);
    voegToe('Aantal', model.aantal);
    voegToe('Type tent', model.type.label);
    if (model.type.is700LX) voegToe('Uitvoering', model.lxOmschrijving);
    voegToe('Breedte', '${model.breedteMm} mm');
    voegToe('Uitval', '${model.uitvalMm} mm');
    voegToe('Bediening', model.bedieningElektrisch);
    voegToe('Kleur draagstructuur', model.kleurSamenvatting);
    voegToe('Type doek', model.doekSamenvatting);
    if (model.volant) voegToe('Volant', '${model.volantHoogteMm} mm');
    voegToe('Type motor', model.motorSamenvatting);
    voegToe('Bedieningswijze', model.bediening);
    voegToe('Kabellengte', model.kabellengteSamenvatting);
    voegToe('Kabeluitgang (van buitengezien)', model.uitgang);
    voegToe('Eolis 3D', model.eolis3D ? 'Ja' : 'Nee');

    return List<OpmetingOverzichtTechnischeRegel>.unmodifiable(regels);
  }
}
