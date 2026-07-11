import 'package:flutter/material.dart';

import 'opmeting_raam_kleinhout_menu.dart';
import 'opmeting_raam_kleinhout_model.dart';
import 'opmeting_raam_model.dart';
import 'opmeting_raam_opvulling_menu.dart';
import 'opmeting_raam_opvulling_model.dart';
import 'opmeting_raam_tekenvlak_acties.dart';
import 'opmeting_raam_tekenvlak_menus.dart';
import 'opmeting_raam_verplaatsbaar_menu.dart';
import 'opmeting_raam_zwevende_menus_controller.dart';

typedef OpmetingRaamMenuVersleepCallback =
    void Function({
      required String menuId,
      required DragUpdateDetails details,
      required BuildContext overlayContext,
      required Size schermGrootte,
      required Size menuGrootte,
    });

class OpmetingRaamMenuOverlay extends StatelessWidget {
  const OpmetingRaamMenuOverlay({
    super.key,
    required this.actieveTool,
    required this.zwevendeMenus,
    required this.heeftGeselecteerdeLijn,
    required this.bestaandeTStijlGeselecteerd,
    required this.alleenVerplaatsenVoorGeselecteerdeTStijl,
    required this.vleugelMenuZichtbaar,
    required this.tStijlMenuZichtbaar,
    required this.opvullingMenuZichtbaar,
    required this.kleinhoutMenuZichtbaar,
    required this.positieType,
    required this.positieController,
    required this.geselecteerdVleugelType,
    required this.opvullingen,
    required this.opvullingenLaden,
    required this.geselecteerdeOpvullingId,
    required this.aantalGeselecteerdeVulvlakken,
    required this.totaalAantalVlakken,
    required this.geselecteerdKleinhoutType,
    required this.geselecteerdKleinhoutPatroon,
    required this.kleinhoutHorizontaleHoogteController,
    required this.kleinhoutAantalHorizontaalController,
    required this.kleinhoutAantalVerticaalController,
    required this.aantalGeselecteerdeKleinhoutVlakken,
    required this.totaalAantalGevuldeVlakken,
    required this.kleinhoutSelectieIsVolledigGevuld,
    required this.kleinhoutSelectieHeeftKleinhouten,
    required this.onMenuVerslepen,
    required this.onTStijlMenuSluiten,
    required this.onVleugelMenuSluiten,
    required this.onOpvullingMenuSluiten,
    required this.onKleinhoutMenuSluiten,
    required this.onPositieTypeGewijzigd,
    required this.onTStijlMaatGewijzigd,
    required this.onTStijlToevoegen,
    required this.onTStijlVerplaatsen,
    required this.onTStijlWissen,
    required this.onVleugelTypeGekozen,
    required this.onOpvullingGekozen,
    required this.onOpvullingToepassen,
    required this.onOpvullingVerwijderen,
    required this.onAlleVulvlakkenSelecteren,
    required this.onVulvlakSelectieWissen,
    required this.onKleinhoutTypeGewijzigd,
    required this.onKleinhoutPatroonGewijzigd,
    required this.onKleinhoutWaardeGewijzigd,
    required this.onKleinhoutToepassen,
    required this.onKleinhoutVerwijderen,
    required this.onAlleGevuldeKleinhoutVlakkenSelecteren,
    required this.onKleinhoutSelectieWissen,
  });

  final String actieveTool;

  final OpmetingRaamZwevendeMenusController zwevendeMenus;

  final bool heeftGeselecteerdeLijn;
  final bool bestaandeTStijlGeselecteerd;
  final bool alleenVerplaatsenVoorGeselecteerdeTStijl;

  final bool vleugelMenuZichtbaar;
  final bool tStijlMenuZichtbaar;
  final bool opvullingMenuZichtbaar;
  final bool kleinhoutMenuZichtbaar;

  final String positieType;
  final TextEditingController positieController;

  final OpmetingRaamVleugelType geselecteerdVleugelType;

  final List<OpmetingRaamOpvullingModel> opvullingen;
  final bool opvullingenLaden;
  final String? geselecteerdeOpvullingId;
  final int aantalGeselecteerdeVulvlakken;
  final int totaalAantalVlakken;

  final OpmetingRaamKleinhoutType geselecteerdKleinhoutType;
  final OpmetingRaamKleinhoutPatroon geselecteerdKleinhoutPatroon;

  final TextEditingController kleinhoutHorizontaleHoogteController;
  final TextEditingController kleinhoutAantalHorizontaalController;
  final TextEditingController kleinhoutAantalVerticaalController;

  final int aantalGeselecteerdeKleinhoutVlakken;
  final int totaalAantalGevuldeVlakken;

  final bool kleinhoutSelectieIsVolledigGevuld;
  final bool kleinhoutSelectieHeeftKleinhouten;

  final OpmetingRaamMenuVersleepCallback onMenuVerslepen;

  final VoidCallback onTStijlMenuSluiten;
  final VoidCallback onVleugelMenuSluiten;
  final VoidCallback onOpvullingMenuSluiten;
  final VoidCallback onKleinhoutMenuSluiten;

  final ValueChanged<String> onPositieTypeGewijzigd;
  final VoidCallback onTStijlMaatGewijzigd;
  final VoidCallback onTStijlToevoegen;
  final VoidCallback onTStijlVerplaatsen;
  final VoidCallback onTStijlWissen;

  final ValueChanged<OpmetingRaamVleugelType> onVleugelTypeGekozen;

  final ValueChanged<String?> onOpvullingGekozen;
  final VoidCallback onOpvullingToepassen;
  final VoidCallback onOpvullingVerwijderen;
  final VoidCallback onAlleVulvlakkenSelecteren;
  final VoidCallback onVulvlakSelectieWissen;

  final ValueChanged<OpmetingRaamKleinhoutType> onKleinhoutTypeGewijzigd;

  final ValueChanged<OpmetingRaamKleinhoutPatroon> onKleinhoutPatroonGewijzigd;

  final VoidCallback onKleinhoutWaardeGewijzigd;
  final VoidCallback onKleinhoutToepassen;
  final VoidCallback onKleinhoutVerwijderen;
  final VoidCallback onAlleGevuldeKleinhoutVlakkenSelecteren;
  final VoidCallback onKleinhoutSelectieWissen;

  @override
  Widget build(BuildContext context) {
    final schermGrootte = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);

    final ruweBeschikbareBreedte =
        schermGrootte.width - padding.left - padding.right - 24;

    final beschikbareBreedte = ruweBeschikbareBreedte > 0
        ? ruweBeschikbareBreedte
        : schermGrootte.width;

    final ruweBeschikbareHoogte =
        schermGrootte.height -
        padding.top -
        kToolbarHeight -
        padding.bottom -
        16;

    final beschikbareHoogte = ruweBeschikbareHoogte > 80
        ? ruweBeschikbareHoogte
        : 80.0;

    double begrensMenuBreedte({
      required double minimum,
      required double maximum,
    }) {
      if (beschikbareBreedte <= minimum) {
        return beschikbareBreedte;
      }

      return beschikbareBreedte.clamp(minimum, maximum).toDouble();
    }

    final tStijlMenuBreedte = begrensMenuBreedte(minimum: 220, maximum: 260);

    final opvullingMenuBreedte = begrensMenuBreedte(minimum: 220, maximum: 310);

    final kleinhoutMenuBreedte = begrensMenuBreedte(minimum: 280, maximum: 320);

    final vleugelMenuGrootte =
        OpmetingRaamTekenvlakActies.berekenVleugelMenuGrootte(
          Size(beschikbareBreedte, beschikbareHoogte),
        );

    final tStijlMenuGrootte = zwevendeMenus.meetMenuGrootte(
      menuKey: zwevendeMenus.tStijlMenuKey,
      standaardBreedte: tStijlMenuBreedte,
      standaardHoogte: beschikbareHoogte < 280 ? beschikbareHoogte : 280,
    );

    final opvullingMenuGrootte = zwevendeMenus.meetMenuGrootte(
      menuKey: zwevendeMenus.opvullingMenuKey,
      standaardBreedte: opvullingMenuBreedte,
      standaardHoogte: beschikbareHoogte < 420 ? beschikbareHoogte : 420,
    );

    final kleinhoutMenuGrootte = zwevendeMenus.meetMenuGrootte(
      menuKey: zwevendeMenus.kleinhoutMenuKey,
      standaardBreedte: kleinhoutMenuBreedte,
      standaardHoogte: beschikbareHoogte < 520 ? beschikbareHoogte : 520,
    );

    final vleugelMenuPositie = zwevendeMenus.effectieveMenuPositie(
      overlayContext: context,
      opgeslagenPositie: zwevendeMenus.vleugelMenuPositie,
      schermGrootte: schermGrootte,
      menuGrootte: vleugelMenuGrootte,
    );

    final tStijlMenuPositie = zwevendeMenus.effectieveMenuPositie(
      overlayContext: context,
      opgeslagenPositie: zwevendeMenus.tStijlMenuPositie,
      schermGrootte: schermGrootte,
      menuGrootte: tStijlMenuGrootte,
    );

    final opvullingMenuPositie = zwevendeMenus.effectieveMenuPositie(
      overlayContext: context,
      opgeslagenPositie: zwevendeMenus.opvullingMenuPositie,
      schermGrootte: schermGrootte,
      menuGrootte: opvullingMenuGrootte,
    );

    final kleinhoutMenuPositie = zwevendeMenus.effectieveMenuPositie(
      overlayContext: context,
      opgeslagenPositie: zwevendeMenus.kleinhoutMenuPositie,
      schermGrootte: schermGrootte,
      menuGrootte: kleinhoutMenuGrootte,
    );

    final maximaleMenuInhoudHoogte = beschikbareHoogte > 46
        ? beschikbareHoogte - 46
        : 34.0;

    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (actieveTool == 'tstijl' &&
              heeftGeselecteerdeLijn &&
              tStijlMenuZichtbaar)
            Positioned(
              left: tStijlMenuPositie.dx,
              top: tStijlMenuPositie.dy,
              child: Material(
                type: MaterialType.transparency,
                child: OpmetingRaamVerplaatsbaarMenu(
                  menuKey: zwevendeMenus.tStijlMenuKey,
                  breedte: tStijlMenuBreedte,
                  titel: 'T-stijlmenu verplaatsen',
                  onSleepStart: (details) {
                    zwevendeMenus.startMenuSleep(
                      menuId: 'tstijl',
                      globaleCursorPositie: details.globalPosition,
                      huidigeMenuPositie: tStijlMenuPositie,
                    );
                  },
                  onVerslepen: (details) {
                    onMenuVerslepen(
                      menuId: 'tstijl',
                      details: details,
                      overlayContext: context,
                      schermGrootte: schermGrootte,
                      menuGrootte: tStijlMenuGrootte,
                    );
                  },
                  onSleepEinde: (_) {
                    zwevendeMenus.stopMenuSleep('tstijl');
                  },
                  onSleepAnnuleren: () {
                    zwevendeMenus.stopMenuSleep('tstijl');
                  },
                  onSluiten: onTStijlMenuSluiten,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: maximaleMenuInhoudHoogte,
                    ),
                    child: SingleChildScrollView(
                      child: OpmetingRaamTStijlMenu(
                        positieType: positieType,
                        positieController: positieController,
                        toonToevoegKnop:
                            !alleenVerplaatsenVoorGeselecteerdeTStijl,
                        toonWisKnop:
                            bestaandeTStijlGeselecteerd &&
                            !alleenVerplaatsenVoorGeselecteerdeTStijl,
                        toonVerplaatsKnop: bestaandeTStijlGeselecteerd,
                        onPositieTypeGewijzigd: onPositieTypeGewijzigd,
                        onMaatGewijzigd: (_) {
                          onTStijlMaatGewijzigd();
                        },
                        onToevoegen: onTStijlToevoegen,
                        onVerplaatsen: onTStijlVerplaatsen,
                        onWissen: onTStijlWissen,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (actieveTool == 'vleugel' && vleugelMenuZichtbaar)
            Positioned(
              left: vleugelMenuPositie.dx,
              top: vleugelMenuPositie.dy,
              child: Material(
                type: MaterialType.transparency,
                child: Listener(
                  onPointerDown: (event) {
                    zwevendeMenus.startMenuSleep(
                      menuId: 'vleugel',
                      globaleCursorPositie: event.position,
                      huidigeMenuPositie: vleugelMenuPositie,
                    );
                  },
                  onPointerUp: (_) {
                    zwevendeMenus.stopMenuSleep('vleugel');
                  },
                  onPointerCancel: (_) {
                    zwevendeMenus.stopMenuSleep('vleugel');
                  },
                  child: OpmetingRaamVleugelMenu(
                    menuGrootte: vleugelMenuGrootte,
                    geselecteerdType: geselecteerdVleugelType,
                    onTypeGekozen: onVleugelTypeGekozen,
                    onSluiten: onVleugelMenuSluiten,
                    onVerslepen: (details) {
                      onMenuVerslepen(
                        menuId: 'vleugel',
                        details: details,
                        overlayContext: context,
                        schermGrootte: schermGrootte,
                        menuGrootte: vleugelMenuGrootte,
                      );
                    },
                  ),
                ),
              ),
            ),
          if (actieveTool == 'opvulling' && opvullingMenuZichtbaar)
            Positioned(
              left: opvullingMenuPositie.dx,
              top: opvullingMenuPositie.dy,
              child: Material(
                type: MaterialType.transparency,
                child: OpmetingRaamVerplaatsbaarMenu(
                  menuKey: zwevendeMenus.opvullingMenuKey,
                  breedte: opvullingMenuBreedte,
                  titel: 'Opvulmenu verplaatsen',
                  onSleepStart: (details) {
                    zwevendeMenus.startMenuSleep(
                      menuId: 'opvulling',
                      globaleCursorPositie: details.globalPosition,
                      huidigeMenuPositie: opvullingMenuPositie,
                    );
                  },
                  onVerslepen: (details) {
                    onMenuVerslepen(
                      menuId: 'opvulling',
                      details: details,
                      overlayContext: context,
                      schermGrootte: schermGrootte,
                      menuGrootte: opvullingMenuGrootte,
                    );
                  },
                  onSleepEinde: (_) {
                    zwevendeMenus.stopMenuSleep('opvulling');
                  },
                  onSleepAnnuleren: () {
                    zwevendeMenus.stopMenuSleep('opvulling');
                  },
                  onSluiten: onOpvullingMenuSluiten,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: maximaleMenuInhoudHoogte,
                    ),
                    child: SingleChildScrollView(
                      child: OpmetingRaamOpvullingMenu(
                        opvullingen: opvullingen,
                        isLaden: opvullingenLaden,
                        geselecteerdeOpvullingId: geselecteerdeOpvullingId,
                        aantalGeselecteerdeVlakken:
                            aantalGeselecteerdeVulvlakken,
                        totaalAantalVlakken: totaalAantalVlakken,
                        onOpvullingGekozen: onOpvullingGekozen,
                        onToepassen: onOpvullingToepassen,
                        onOpvullingVerwijderen: onOpvullingVerwijderen,
                        onAllesSelecteren: onAlleVulvlakkenSelecteren,
                        onSelectieWissen: onVulvlakSelectieWissen,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (actieveTool == 'kleinhout' && kleinhoutMenuZichtbaar)
            Positioned(
              left: kleinhoutMenuPositie.dx,
              top: kleinhoutMenuPositie.dy,
              child: Material(
                type: MaterialType.transparency,
                child: OpmetingRaamVerplaatsbaarMenu(
                  menuKey: zwevendeMenus.kleinhoutMenuKey,
                  breedte: kleinhoutMenuBreedte,
                  titel: 'Kleinhoutmenu verplaatsen',
                  onSleepStart: (details) {
                    zwevendeMenus.startMenuSleep(
                      menuId: 'kleinhout',
                      globaleCursorPositie: details.globalPosition,
                      huidigeMenuPositie: kleinhoutMenuPositie,
                    );
                  },
                  onVerslepen: (details) {
                    onMenuVerslepen(
                      menuId: 'kleinhout',
                      details: details,
                      overlayContext: context,
                      schermGrootte: schermGrootte,
                      menuGrootte: kleinhoutMenuGrootte,
                    );
                  },
                  onSleepEinde: (_) {
                    zwevendeMenus.stopMenuSleep('kleinhout');
                  },
                  onSleepAnnuleren: () {
                    zwevendeMenus.stopMenuSleep('kleinhout');
                  },
                  onSluiten: onKleinhoutMenuSluiten,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: maximaleMenuInhoudHoogte,
                    ),
                    child: SingleChildScrollView(
                      child: OpmetingRaamKleinhoutMenu(
                        geselecteerdType: geselecteerdKleinhoutType,
                        geselecteerdPatroon: geselecteerdKleinhoutPatroon,
                        horizontaleHoogteController:
                            kleinhoutHorizontaleHoogteController,
                        aantalHorizontaalController:
                            kleinhoutAantalHorizontaalController,
                        aantalVerticaalController:
                            kleinhoutAantalVerticaalController,
                        aantalGeselecteerdeVlakken:
                            aantalGeselecteerdeKleinhoutVlakken,
                        totaalAantalGevuldeVlakken: totaalAantalGevuldeVlakken,
                        selectieKanKleinhoutenKrijgen:
                            kleinhoutSelectieIsVolledigGevuld,
                        selectieHeeftKleinhouten:
                            kleinhoutSelectieHeeftKleinhouten,
                        onTypeGewijzigd: onKleinhoutTypeGewijzigd,
                        onPatroonGewijzigd: onKleinhoutPatroonGewijzigd,
                        onWaardeGewijzigd: onKleinhoutWaardeGewijzigd,
                        onToepassen: onKleinhoutToepassen,
                        onVerwijderen: onKleinhoutVerwijderen,
                        onAlleGevuldeVlakkenSelecteren:
                            onAlleGevuldeKleinhoutVlakkenSelecteren,
                        onSelectieWissen: onKleinhoutSelectieWissen,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
