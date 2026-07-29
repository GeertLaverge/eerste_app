// THIMACO-CONTROLE: PLOOIWERKEN-TECHNISCHE-REGELS-OVERZICHT-20260728-2205
import '../../overzicht/opmeting_overzicht_model.dart';
import 'opmeting_plooiwerken_model.dart';

class OpmetingPlooiwerkenTechnischeRegelsHelper {
  const OpmetingPlooiwerkenTechnischeRegelsHelper._();

  static List<OpmetingOverzichtTechnischeRegel> bouw(
    OpmetingPlooiwerkenModel model,
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
    voegToe('Kleursoort', model.kleursoort.label);

    final kleurTitel = switch (model.kleursoort) {
      OpmetingPlooiwerkenKleursoort.folie => 'Folie (Renolit)',
      OpmetingPlooiwerkenKleursoort.projectKleur => 'Project kleur',
      _ => 'Kleur',
    };
    voegToe(kleurTitel, model.kleurVoorOverzicht);

    voegToe('Dikte', model.dikte.label);
    voegToe('Vorm', model.vorm.label);
    voegToe('Totale lengte', '${model.totaleLengteMm} mm');
    voegToe('Aantal plooien', model.aantalPlooien);

    final lengtes = model.actieveLengtesMm;
    final hoeken = model.actieveHoekenGraden;

    for (var index = 0; index < lengtes.length; index++) {
      final lengte = lengtes[index];
      if (lengte != null) {
        voegToe('Lengte ${index + 1}', '$lengte mm');
      }

      if (index < hoeken.length) {
        final hoek = hoeken[index];
        if (hoek != null) {
          voegToe('Graden ${index + 1}', '$hoek°');
        }
      }
    }

    voegToe('Tekening draaien', '${model.tekeningRotatieGraden}°');

    if (model.toontZichtzijde) {
      voegToe('Zichtzijde', model.lakzijde.label);
    }

    voegToe('Soort ophanging', model.soortOphanging);
    voegToe('Plaats ophanging', model.plaatsOphanging);

    return List<OpmetingOverzichtTechnischeRegel>.unmodifiable(regels);
  }
}
