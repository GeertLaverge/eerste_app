// THIMACO-CONTROLE: SCHUIFVLIEGENDEUR-TECHNISCHE-REGELS-MEERVOUDIGE-BESTANDSNAAM-20260728
import '../../overzicht/opmeting_overzicht_model.dart';
import 'opmeting_schuifvliegendeur_model.dart';

class OpmetingSchuifvliegendeurTechnischeRegelsHelper {
  const OpmetingSchuifvliegendeurTechnischeRegelsHelper._();

  static List<OpmetingOverzichtTechnischeRegel> bouw(
    OpmetingSchuifvliegendeurModel model,
  ) {
    final regels = <OpmetingOverzichtTechnischeRegel>[];

    void voegToe(String titel, Object? waarde) {
      final tekst = waarde?.toString().trim() ?? '';
      if (tekst.isEmpty) return;

      regels.add(OpmetingOverzichtTechnischeRegel(titel: titel, waarde: tekst));
    }

    if (model.stukReferentie.trim().isNotEmpty) {
      voegToe('Stuk referentie', model.stukReferentie);
    }

    voegToe('Aantal', model.aantal);
    voegToe('Breedte buitenmaat vleugel', '${model.breedteMm} mm');
    voegToe('Hoogte inclusief rails', '${model.hoogteMm} mm');
    voegToe('Soort', model.soort);
    voegToe(
      model.gebruiktProjectKleur ? 'Project kleur' : 'Kleur',
      model.kleurVoorOverzicht,
    );
    voegToe('Uitvoering', model.uitvoering);

    if (model.heeftRails) {
      voegToe('Onderrail', model.onderrailCode);
      voegToe('Bovenrail', model.bovenrailCode);
      voegToe('Lengte rails', '${model.railLengteMm} mm');
    }

    if (model.heeftTraversen) {
      voegToe('Traversen', model.traverseType);
      voegToe('Aantal traversen', model.actieveTraverseHoogtesMm.length);

      for (
        var index = 0;
        index < model.actieveTraverseHoogtesMm.length;
        index++
      ) {
        voegToe(
          'Hoogte T${index + 1}',
          '${model.actieveTraverseHoogtesMm[index]} mm',
        );
      }
    }

    voegToe('Kleur pees', model.kleurPees);

    if (model.isSmal) {
      voegToe('Stootrubbers', model.stootrubbers);
    }

    voegToe('Kleur PVC', model.kleurPvc);
    voegToe('Pomp', model.pomp);
    voegToe('Eindstoppen', model.eindstoppen);
    voegToe('Dierenluik', model.dierenluik);

    if (model.heeftDierenluik && model.dierenluikNotities.trim().isNotEmpty) {
      voegToe('Notitie dierenluik', model.dierenluikNotities);
    }

    voegToe('Plaat', model.plaat);

    if (model.isPlaatOpMaat) {
      voegToe('Hoogte plaat', '${model.effectievePlaatHoogteMm} mm');
    }

    voegToe('Gaas', model.gaas);

    if (model.heeftTraversen) {
      voegToe('Gaas onder T1', model.gaasOnderT1);
    }

    voegToe('Borstel links', model.borstelLinks);
    voegToe('Borstel rechts', model.borstelRechts);

    return List<OpmetingOverzichtTechnischeRegel>.unmodifiable(regels);
  }
}
