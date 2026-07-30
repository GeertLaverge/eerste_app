// THIMACO-CONTROLE: SEKTIONALE-POORTEN-R-PROFIELEN-ALLE-UITSCHRIJVEN-20260729-1415
// THIMACO-CONTROLE: SEKTIONALE-POORTEN-R-PROFIELEN-UITSCHRIJVEN-20260729-1313
// THIMACO-CONTROLE: SEKTIONALE-POORTEN-TECHNISCHE-REGELS-FINAAL-20260729-1214
// THIMACO-CONTROLE: SEKTIONALE-POORTEN-TECHNISCHE-REGELS-P-R-STOPCONTACT-20260729
import '../../overzicht/opmeting_overzicht_model.dart';
import 'opmeting_sektionale_poort_model.dart';

class OpmetingSektionalePoortTechnischeRegelsHelper {
  const OpmetingSektionalePoortTechnischeRegelsHelper._();

  static List<OpmetingOverzichtTechnischeRegel> bouw(
    OpmetingSektionalePoortModel model,
  ) {
    final regels = <OpmetingOverzichtTechnischeRegel>[];

    void voegToe(String titel, Object? waarde) {
      final tekst = waarde?.toString().trim() ?? '';
      if (tekst.isEmpty) return;
      regels.add(OpmetingOverzichtTechnischeRegel(titel: titel, waarde: tekst));
    }

    voegToe('Aantal', model.aantal);
    voegToe('Bestelmaat', '${model.breedteMm} × ${model.hoogteMm} mm');
    voegToe('Slag L', '${model.slagLMm} mm');
    voegToe('Slag R', '${model.slagRMm} mm');
    voegToe('Slag B', '${model.slagBMm} mm');
    voegToe('Type', model.serie.label);
    voegToe('Struktuur', model.structuur.label);
    voegToe('Model', model.modelType.label);

    if (model.modelType == OpmetingSektionalePoortModelType.p) {
      voegToe('Aantal panelen', model.aantalPanelen);
      if (model.geldigeGlasPaneelNummers.isNotEmpty) {
        voegToe(
          'Glaspanelen',
          model.geldigeGlasPaneelNummers.map(model.paneelLabel).join(' · '),
        );
      }
    }

    if (model.modelType == OpmetingSektionalePoortModelType.r) {
      if (model.rVierkantRaamMetKleinhouten) {
        voegToe(
          'Extra profiel',
          'Vierkant raam met kleinhouten · ${model.rAantalVierkanteRamen} kader${model.rAantalVierkanteRamen == 1 ? '' : 's'}',
        );
        voegToe(
          'Raam 1',
          '${model.rRaam1Zijde.label} · ${model.rRaam1AfstandMm} mm',
        );
        if (model.rAantalVierkanteRamen == 2) {
          voegToe(
            'Raam 2',
            '${model.rRaam2Zijde.label} · ${model.rRaam2AfstandMm} mm',
          );
        }
      }
      if (model.rPlintOnderaan) {
        voegToe(
          'Extra profiel',
          'Plint onderaan · ${OpmetingSektionalePoortModel.rPlintHoogteMm} mm',
        );
      }
      if (model.rVoetjeMetMakelaar) {
        voegToe(
          'Extra profiel',
          'Voetje met makelaar · ${OpmetingSektionalePoortModel.rMakelaarBreedteMm} mm',
        );
      }
    }

    voegToe(
      model.gebruiktProjectKleur ? 'Project kleur' : 'Kleur',
      model.kleurVoorWeergave,
    );
    voegToe('Korrelgrootte', model.korrelgrootte.label);
    voegToe('Type motor', model.motor.label);

    for (final bediening in model.bedieningRegels) {
      voegToe('Bediening', bediening);
    }

    voegToe('Bovenlatei + rubber', model.bovenlatei ? 'Ja' : 'Nee');
    voegToe(
      'PVC anti-roestvoetje Premium Pro',
      model.pvcAntiRoestvoetjePremiumPro ? 'Ja' : 'Nee',
    );
    voegToe(
      'Plaatsen en aansluiten stopcontact',
      model.plaatsenEnAansluitenStopcontact ? 'Ja' : 'Nee',
    );
    voegToe('Montage profielen', model.montageProfiel.label);

    switch (model.montageProfiel) {
      case OpmetingSektionalePoortMontageProfiel.geenKaderwerk:
        break;
      case OpmetingSektionalePoortMontageProfiel.afwerkprofielenOverRail:
        _voegProfielMatenToe(regels, model.afwerkprofielMaten, toonX: false);
        break;
      case OpmetingSektionalePoortMontageProfiel.montageProfielDc1:
        _voegProfielMatenToe(regels, model.montageDc1Maten, toonX: true);
        break;
      case OpmetingSektionalePoortMontageProfiel.montageProfielDc2:
        _voegProfielMatenToe(regels, model.montageDc2Maten, toonX: true);
        break;
      case OpmetingSektionalePoortMontageProfiel.kokerprofielen:
        for (final koker in model.kokerMaten.where(
          (item) => item.heeftWaarden,
        )) {
          voegToe(
            'Koker ${koker.profiel}',
            'L ${koker.lMm} mm · R ${koker.rMm} mm · B ${koker.bMm} mm',
          );
        }
        break;
    }

    return List<OpmetingOverzichtTechnischeRegel>.unmodifiable(regels);
  }

  static void _voegProfielMatenToe(
    List<OpmetingOverzichtTechnischeRegel> regels,
    OpmetingSektionalePoortProfielMaten maten, {
    required bool toonX,
  }) {
    void voegToe(String titel, int waarde) {
      if (waarde <= 0) return;
      regels.add(
        OpmetingOverzichtTechnischeRegel(titel: titel, waarde: '$waarde mm'),
      );
    }

    if (toonX) voegToe('Profiel X', maten.xMm);
    voegToe('Profiel L', maten.lMm);
    voegToe('Profiel R', maten.rMm);
    voegToe('Profiel B', maten.bMm);
  }
}
