import 'package:flutter/material.dart';

import '../kader_samenstelling/opmeting_kader_samenstelling_model.dart';
import 'opmeting_raam_basis_maten.dart';
import 'opmeting_raam_keuzemenu_model.dart';
import 'opmeting_raam_kleinhout_helper.dart';
import 'opmeting_raam_model.dart';
import 'opmeting_raam_notities.dart';
import 'opmeting_raam_technische_keuzes_paneel.dart';
import 'opmeting_raam_tekenvlak.dart';
import 'opmeting_raam_toolbalk.dart';
import 'opmeting_raam_vulling_helper.dart';
import '../overzicht/opmeting_overzicht_model.dart';

class OpmetingRaamFormulierLayout extends StatelessWidget {
  const OpmetingRaamFormulierLayout({
    super.key,
    required this.klantNaam,
    this.formulierTitel = 'Opmeting raam',
    this.toonDeurKnoppen = false,
    this.deurVleugelSamenvatting = '',
    this.profielSamenvatting = '',
    this.onDeurVleugel,
    this.onDeurPanelen,
    required this.onTerug,
    required this.onToevoegen,
    required this.onAnnuleren,
    required this.dagmaatHoogteController,
    required this.dagmaatBreedteController,
    required this.raammaatHoogteController,
    required this.raammaatBreedteController,
    required this.slagLinksController,
    required this.slagRechtsController,
    required this.slagBovenController,
    required this.slagOnderController,
    required this.binnenTabletController,
    required this.buitenTabletController,
    required this.uitzagenTandController,
    required this.buitensteLipController,
    required this.raammaatBreedte,
    required this.raammaatHoogte,
    required this.verschilTablet,
    required this.dagmatenVergrendeld,
    required this.onMatenGewijzigd,
    required this.onDagmaatGewijzigd,
    required this.onRaammaatGewijzigd,
    required this.tekenvlakController,
    required this.actieveTool,
    required this.vleugelMenuOpenSignaal,
    required this.tStijlMenuOpenSignaal,
    required this.opvullingMenuOpenSignaal,
    required this.kleinhoutMenuOpenSignaal,
    required this.positieController,
    required this.technischeTekeningen,
    required this.technischeTekeningenPerKader,
    required this.technischeTekeningenPerKaderGroep,
    required this.technischeKaderGroepen,
    required this.beginTekeningData,
    required this.onGeselecteerdeKaderIdsGewijzigd,
    required this.onOverzichtTekeningGewijzigd,
    required this.onOpvullingenGewijzigd,
    required this.onKleinhoutenGewijzigd,
    required this.kaderSamenstelling,
    required this.onKaderSamenstellingGewijzigd,
    required this.onToolGekozen,
    required this.notitiesController,
    required this.gekozenOpvullingen,
    required this.gekozenKleinhouten,
    required this.keuzemenus,
    required this.keuzemenusLaden,
    required this.keuzemenusBewaren,
    required this.menuBeheerOntgrendeld,
    required this.opvullingenOpen,
    required this.kleinhoutenOpen,
    required this.onOpvullingenOpenGewijzigd,
    required this.onKleinhoutenOpenGewijzigd,
    required this.geselecteerdeOptieIdVoorMenu,
    required this.onOptieGekozen,
    required this.onMenuToevoegen,
    required this.onBeheerSlotWisselen,
    required this.onMenuAanpassen,
    required this.onMenuOmhoog,
    required this.onMenuOmlaag,
    required this.onMenuVerwijderen,
  });

  final String? klantNaam;
  final String formulierTitel;
  final bool toonDeurKnoppen;
  final String deurVleugelSamenvatting;
  final String profielSamenvatting;
  final VoidCallback? onDeurVleugel;
  final VoidCallback? onDeurPanelen;
  final Future<void> Function() onTerug;
  final Future<void> Function() onToevoegen;
  final Future<void> Function() onAnnuleren;

  final TextEditingController dagmaatHoogteController;
  final TextEditingController dagmaatBreedteController;
  final TextEditingController raammaatHoogteController;
  final TextEditingController raammaatBreedteController;
  final TextEditingController slagLinksController;
  final TextEditingController slagRechtsController;
  final TextEditingController slagBovenController;
  final TextEditingController slagOnderController;
  final TextEditingController binnenTabletController;
  final TextEditingController buitenTabletController;
  final TextEditingController uitzagenTandController;
  final TextEditingController buitensteLipController;

  final int raammaatBreedte;
  final int raammaatHoogte;
  final int verschilTablet;
  final bool dagmatenVergrendeld;
  final VoidCallback onMatenGewijzigd;
  final VoidCallback onDagmaatGewijzigd;
  final VoidCallback onRaammaatGewijzigd;

  final OpmetingRaamTekenvlakController tekenvlakController;
  final String actieveTool;
  final int vleugelMenuOpenSignaal;
  final int tStijlMenuOpenSignaal;
  final int opvullingMenuOpenSignaal;
  final int kleinhoutMenuOpenSignaal;
  final TextEditingController positieController;

  final List<OpmetingRaamTechnischeTekeningInstelling> technischeTekeningen;
  final Map<String, List<OpmetingRaamTechnischeTekeningInstelling>>
  technischeTekeningenPerKader;
  final Map<String, List<OpmetingRaamTechnischeTekeningInstelling>>
  technischeTekeningenPerKaderGroep;
  final Map<String, Set<String>> technischeKaderGroepen;
  final OpmetingOverzichtTekeningData? beginTekeningData;

  final ValueChanged<Set<String>> onGeselecteerdeKaderIdsGewijzigd;
  final ValueChanged<OpmetingOverzichtTekeningData>
  onOverzichtTekeningGewijzigd;
  final ValueChanged<List<OpmetingRaamVullingLegendaItem>>
  onOpvullingenGewijzigd;
  final ValueChanged<List<OpmetingRaamKleinhoutLegendaItem>>
  onKleinhoutenGewijzigd;
  final OpmetingKaderSamenstelling kaderSamenstelling;
  final ValueChanged<OpmetingKaderSamenstelling> onKaderSamenstellingGewijzigd;

  final ValueChanged<String> onToolGekozen;
  final TextEditingController notitiesController;

  final List<OpmetingRaamVullingLegendaItem> gekozenOpvullingen;
  final List<OpmetingRaamKleinhoutLegendaItem> gekozenKleinhouten;
  final List<OpmetingRaamKeuzeMenu> keuzemenus;
  final bool keuzemenusLaden;
  final bool keuzemenusBewaren;
  final bool menuBeheerOntgrendeld;
  final bool opvullingenOpen;
  final bool kleinhoutenOpen;
  final ValueChanged<bool> onOpvullingenOpenGewijzigd;
  final ValueChanged<bool> onKleinhoutenOpenGewijzigd;
  final String? Function(OpmetingRaamKeuzeMenu menu)
  geselecteerdeOptieIdVoorMenu;
  final Future<void> Function(OpmetingRaamKeuzeMenu menu, String optieId)
  onOptieGekozen;
  final Future<void> Function() onMenuToevoegen;
  final Future<void> Function() onBeheerSlotWisselen;
  final Future<void> Function(OpmetingRaamKeuzeMenu menu) onMenuAanpassen;
  final void Function(OpmetingRaamKeuzeMenu menu) onMenuOmhoog;
  final void Function(OpmetingRaamKeuzeMenu menu) onMenuOmlaag;
  final Future<void> Function(OpmetingRaamKeuzeMenu menu) onMenuVerwijderen;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        await onTerug();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0B7A3B),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () {
              onTerug();
            },
          ),
          title: Text(
            klantNaam == null || klantNaam!.trim().isEmpty
                ? formulierTitel
                : '$formulierTitel · $klantNaam',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton.icon(
                onPressed: () {
                  onToevoegen();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0B7A3B),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Toevoegen'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ElevatedButton.icon(
                onPressed: () {
                  onAnnuleren();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0B7A3B),
                ),
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Annuleren'),
              ),
            ),
          ],
        ),
        body: Row(
          children: [
            Expanded(
              flex: 60,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
                child: Column(
                  children: [
                    Expanded(
                      child: OpmetingRaamTekenvlak(
                        breedteMm: raammaatBreedte,
                        hoogteMm: raammaatHoogte,
                        actieveTool: actieveTool,
                        vleugelMenuOpenSignaal: vleugelMenuOpenSignaal,
                        tStijlMenuOpenSignaal: tStijlMenuOpenSignaal,
                        opvullingMenuOpenSignaal: opvullingMenuOpenSignaal,
                        kleinhoutMenuOpenSignaal: kleinhoutMenuOpenSignaal,
                        positieController: positieController,
                        controller: tekenvlakController,
                        technischeTekeningen: technischeTekeningen,
                        technischeTekeningenPerKader:
                            technischeTekeningenPerKader,
                        technischeTekeningenPerKaderGroep:
                            technischeTekeningenPerKaderGroep,
                        technischeKaderGroepen: technischeKaderGroepen,
                        beginTekeningData: beginTekeningData,
                        onGeselecteerdeKaderIdsGewijzigd:
                            onGeselecteerdeKaderIdsGewijzigd,
                        onOverzichtTekeningGewijzigd:
                            onOverzichtTekeningGewijzigd,
                        onOpvullingenGewijzigd: onOpvullingenGewijzigd,
                        onKleinhoutenGewijzigd: onKleinhoutenGewijzigd,
                        kaderSamenstelling: kaderSamenstelling,
                        onKaderSamenstellingGewijzigd:
                            onKaderSamenstellingGewijzigd,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: tekenvlakController,
                      builder: (context, child) {
                        return OpmetingRaamToolbalk(
                          actieveTool: actieveTool,
                          onToolGekozen: onToolGekozen,
                          kanOngedaanMaken:
                              tekenvlakController.kanOngedaanMaken,
                          kanHerstellen: tekenvlakController.kanHerstellen,
                          onOngedaanMaken: tekenvlakController.ongedaanMaken,
                          onHerstellen: tekenvlakController.herstellen,
                          toonDeurTools: toonDeurKnoppen,
                          onDeurVleugel: onDeurVleugel,
                          onDeurPanelen: onDeurPanelen,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    OpmetingRaamNotities(controller: notitiesController),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 40,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 12, 12, 12),
                child: ListView(
                  children: [
                    OpmetingRaamBasisMaten(
                      dagmaatHoogteController: dagmaatHoogteController,
                      dagmaatBreedteController: dagmaatBreedteController,
                      raammaatHoogteController: raammaatHoogteController,
                      raammaatBreedteController: raammaatBreedteController,
                      slagLinksController: slagLinksController,
                      slagRechtsController: slagRechtsController,
                      slagBovenController: slagBovenController,
                      slagOnderController: slagOnderController,
                      binnenTabletController: binnenTabletController,
                      buitenTabletController: buitenTabletController,
                      uitzagenTandController: uitzagenTandController,
                      buitensteLipController: buitensteLipController,
                      raammaatBreedte: raammaatBreedte,
                      raammaatHoogte: raammaatHoogte,
                      verschilTablet: verschilTablet,
                      dagmatenVergrendeld: dagmatenVergrendeld,
                      onChanged: onMatenGewijzigd,
                      onDagmaatGewijzigd: onDagmaatGewijzigd,
                      onRaammaatGewijzigd: onRaammaatGewijzigd,
                    ),
                    const SizedBox(height: 8),
                    OpmetingRaamTechnischeKeuzesPaneel(
                      deurVleugelSamenvatting: deurVleugelSamenvatting,
                      profielSamenvatting: profielSamenvatting,
                      gekozenOpvullingen: gekozenOpvullingen,
                      gekozenKleinhouten: gekozenKleinhouten,
                      keuzemenus: keuzemenus,
                      keuzemenusLaden: keuzemenusLaden,
                      keuzemenusBewaren: keuzemenusBewaren,
                      menuBeheerOntgrendeld: menuBeheerOntgrendeld,
                      opvullingenOpen: opvullingenOpen,
                      kleinhoutenOpen: kleinhoutenOpen,
                      onOpvullingenOpenGewijzigd: onOpvullingenOpenGewijzigd,
                      onKleinhoutenOpenGewijzigd: onKleinhoutenOpenGewijzigd,
                      geselecteerdeOptieIdVoorMenu:
                          geselecteerdeOptieIdVoorMenu,
                      onOptieGekozen: onOptieGekozen,
                      onMenuToevoegen: () {
                        onMenuToevoegen();
                      },
                      onBeheerSlotWisselen: () {
                        onBeheerSlotWisselen();
                      },
                      onMenuAanpassen: (menu) {
                        onMenuAanpassen(menu);
                      },
                      onMenuOmhoog: onMenuOmhoog,
                      onMenuOmlaag: onMenuOmlaag,
                      onMenuVerwijderen: (menu) {
                        onMenuVerwijderen(menu);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
