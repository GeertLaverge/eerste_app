// THIMACO-CONTROLE: RAAM-TEKENPROGRAMMA-FASE7-STABIELE-TECHNIEK-WEERGAVE-20260913
// THIMACO-CONTROLE: RAAM-TEKENPROGRAMMA-FASE6-TECHNIEK-KETEN-HERSTEL-20260913
// THIMACO-CONTROLE: ONTBREKENDE-TITELS-ANDERE-ARTIKELTYPES-FASE-4-20260727
// THIMACO-CONTROLE: COMPACTE-BOOM-KOPIEREN-VANUIT-BOOM-FASE-3-20260727
// THIMACO-CONTROLE: COMPACTE-BOOM-AANMAKEN-VANUIT-BOOM-FASE-2-20260727
import 'package:flutter/material.dart';

import '../../ui/thimaco_huisstijl.dart';

import '../fotos/opmeting_foto_model.dart';
import '../kader_samenstelling/opmeting_kader_samenstelling_model.dart';
import 'opmeting_raam_basis_maten.dart';
import 'opmeting_raam_keuzemenu_model.dart';
import 'opmeting_raam_kleinhout_helper.dart';
import 'opmeting_raam_notities.dart';
import 'opmeting_raam_technische_keuzes_ribbon.dart';
import 'opmeting_raam_tekenvlak.dart';
import 'opmeting_raam_toolbalk.dart';
import 'opmeting_raam_vulling_helper.dart';
import '../overzicht/opmeting_overzicht_model.dart';
import '../schuifraam/opmeting_schuifraam_model.dart';

enum OpmetingRaamProgrammaRibbon { geen, tekenen, technischeKeuzes }

class OpmetingRaamFormulierLayout extends StatelessWidget {
  const OpmetingRaamFormulierLayout({
    super.key,
    required this.klantNaam,
    this.formulierTitel = 'Opmeting raam',
    this.toonDeurKnoppen = false,
    this.raamVleugelSamenvatting = '',
    this.deurVleugelSamenvatting = '',
    this.profielSamenvatting = '',
    this.onDeurVleugel,
    this.onDeurPanelen,
    this.toonSchuifraamKnoppen = false,
    this.schuifraamSamenstelling,
    this.schuifraamSamenvatting = '',
    this.onSchuifraamSamenstellen,
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
    required this.onderkantSchuifraamController,
    required this.onOnderkantSchuifraamGewijzigd,
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
    required this.fotos,
    required this.onFotosGewijzigd,
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
    this.onTitelOpladen,
    required this.onKeuzeToevoegen,
    required this.onSubmenuToevoegen,
    required this.onMenuKopieren,
    required this.onItemKopieren,
    required this.onBeheerSlotWisselen,
    required this.onMenuAanpassen,
    required this.onMenuOmhoog,
    required this.onMenuOmlaag,
    required this.onMenuVerwijderen,
    required this.onMenuVolgordeGewijzigd,
    required this.openRibbon,
    required this.onOpenRibbonGewijzigd,
    required this.technischeKeuzeSamenvatting,
  });

  final String? klantNaam;
  final String formulierTitel;
  final bool toonDeurKnoppen;
  final String raamVleugelSamenvatting;
  final String deurVleugelSamenvatting;
  final String profielSamenvatting;
  final VoidCallback? onDeurVleugel;
  final VoidCallback? onDeurPanelen;
  final bool toonSchuifraamKnoppen;
  final OpmetingSchuifraamSamenstelling? schuifraamSamenstelling;
  final String schuifraamSamenvatting;
  final VoidCallback? onSchuifraamSamenstellen;
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
  final TextEditingController onderkantSchuifraamController;
  final VoidCallback onOnderkantSchuifraamGewijzigd;

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
  final List<OpmetingFoto> fotos;
  final ValueChanged<List<OpmetingFoto>> onFotosGewijzigd;

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
  final Future<void> Function()? onTitelOpladen;
  final Future<void> Function(
    OpmetingRaamKeuzeMenu menu,
    String? ouderSubmenuId,
  )
  onKeuzeToevoegen;
  final Future<void> Function(
    OpmetingRaamKeuzeMenu menu,
    String? ouderSubmenuId,
  )
  onSubmenuToevoegen;
  final Future<void> Function(OpmetingRaamKeuzeMenu menu) onMenuKopieren;
  final Future<void> Function(
    OpmetingRaamKeuzeMenu menu,
    OpmetingRaamKeuzeMenuItem item,
  )
  onItemKopieren;
  final Future<void> Function() onBeheerSlotWisselen;
  final Future<void> Function(OpmetingRaamKeuzeMenu menu) onMenuAanpassen;
  final void Function(OpmetingRaamKeuzeMenu menu) onMenuOmhoog;
  final void Function(OpmetingRaamKeuzeMenu menu) onMenuOmlaag;
  final Future<void> Function(OpmetingRaamKeuzeMenu menu) onMenuVerwijderen;
  final Future<void> Function(List<String> menuIdsInVolgorde)
  onMenuVolgordeGewijzigd;
  final OpmetingRaamProgrammaRibbon openRibbon;
  final ValueChanged<OpmetingRaamProgrammaRibbon> onOpenRibbonGewijzigd;
  final Map<String, String> technischeKeuzeSamenvatting;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await onTerug();
      },
      child: Scaffold(
        backgroundColor: ThimacoKleuren.achtergrond,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              _bouwProgrammaBovenbalk(),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final eigenschappenBreedte = constraints.maxWidth >= 1320
                        ? 390.0
                        : constraints.maxWidth >= 1080
                        ? 360.0
                        : 330.0;

                    return Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
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
                              schuifraamSamenstelling: schuifraamSamenstelling,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: eigenschappenBreedte,
                          child: _bouwEigenschappenPaneel(),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bouwProgrammaBovenbalk() {
    final titel = klantNaam == null || klantNaam!.trim().isEmpty
        ? formulierTitel
        : '$formulierTitel · $klantNaam';

    final technischeKeuzesRibbon = OpmetingRaamTechnischeKeuzesRibbon(
      keuzemenus: keuzemenus,
      keuzemenusLaden: keuzemenusLaden,
      keuzemenusBewaren: keuzemenusBewaren,
      menuBeheerOntgrendeld: menuBeheerOntgrendeld,
      gekozenOpvullingen: gekozenOpvullingen,
      gekozenKleinhouten: gekozenKleinhouten,
      opvullingenOpen: opvullingenOpen,
      kleinhoutenOpen: kleinhoutenOpen,
      onOpvullingenOpenGewijzigd: onOpvullingenOpenGewijzigd,
      onKleinhoutenOpenGewijzigd: onKleinhoutenOpenGewijzigd,
      geselecteerdeOptieIdVoorMenu: geselecteerdeOptieIdVoorMenu,
      onOptieGekozen: onOptieGekozen,
      onMenuToevoegen: onMenuToevoegen,
      onTitelOpladen: onTitelOpladen,
      onKeuzeToevoegen: onKeuzeToevoegen,
      onSubmenuToevoegen: onSubmenuToevoegen,
      onMenuKopieren: onMenuKopieren,
      onItemKopieren: onItemKopieren,
      onBeheerSlotWisselen: onBeheerSlotWisselen,
      onMenuAanpassen: onMenuAanpassen,
      onMenuOmhoog: onMenuOmhoog,
      onMenuOmlaag: onMenuOmlaag,
      onMenuVerwijderen: onMenuVerwijderen,
      onMenuVolgordeGewijzigd: onMenuVolgordeGewijzigd,
      samenvattingPerMenu: technischeKeuzeSamenvatting,
    );

    return _OpmetingRaamProgrammaKop(
      titel: titel,
      onTerug: onTerug,
      onToevoegen: onToevoegen,
      onAnnuleren: onAnnuleren,
      tekenvlakController: tekenvlakController,
      actieveTool: actieveTool,
      onToolGekozen: onToolGekozen,
      toonDeurTools: toonDeurKnoppen,
      onDeurVleugel: onDeurVleugel,
      onDeurPanelen: onDeurPanelen,
      toonSchuifraamTools: toonSchuifraamKnoppen,
      onSchuifraamSamenstellen: onSchuifraamSamenstellen,
      technischeKeuzesRibbon: technischeKeuzesRibbon,
      openRibbon: openRibbon,
      onOpenRibbonGewijzigd: onOpenRibbonGewijzigd,
    );
  }

  Widget _bouwEigenschappenPaneel() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: ThimacoKleuren.rand),
        ),
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 11, 14, 5),
              child: ThimacoSectieTitel(
                tekst: 'Eigenschappen',
                compact: false,
              ),
            ),
            const TabBar(
              labelColor: ThimacoKleuren.antraciet,
              unselectedLabelColor: ThimacoKleuren.tekstGrijs,
              indicatorColor: ThimacoKleuren.oranje,
              indicatorWeight: 2,
              dividerColor: ThimacoKleuren.rand,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              tabs: <Widget>[
                Tab(text: 'Maten'),
                Tab(text: 'Techniek'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  ListView(
                    key: const PageStorageKey<String>(
                      'opmeting-raam-eigenschappen-maten',
                    ),
                    primary: false,
                    padding: const EdgeInsets.all(10),
                    children: <Widget>[
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
                        onderkantSchuifraamController:
                            onderkantSchuifraamController,
                        isSchuifraam: toonSchuifraamKnoppen,
                        isDeur: toonDeurKnoppen,
                        onOnderkantSchuifraamGewijzigd:
                            onOnderkantSchuifraamGewijzigd,
                        raammaatBreedte: raammaatBreedte,
                        raammaatHoogte: raammaatHoogte,
                        verschilTablet: verschilTablet,
                        dagmatenVergrendeld: dagmatenVergrendeld,
                        onChanged: onMatenGewijzigd,
                        onDagmaatGewijzigd: onDagmaatGewijzigd,
                        onRaammaatGewijzigd: onRaammaatGewijzigd,
                      ),
                    ],
                  ),
                  SingleChildScrollView(
                    key: const PageStorageKey<String>(
                      'opmeting-raam-eigenschappen-techniek-v2',
                    ),
                    primary: false,
                    padding: const EdgeInsets.all(10),
                    child: _OpmetingRaamTechniekSamenvatting(
                      raamVleugelSamenvatting: raamVleugelSamenvatting,
                      deurVleugelSamenvatting: deurVleugelSamenvatting,
                      schuifraamSamenvatting: schuifraamSamenvatting,
                      profielSamenvatting: profielSamenvatting,
                      gekozenOpvullingen: gekozenOpvullingen,
                      gekozenKleinhouten: gekozenKleinhouten,
                      keuzemenus: keuzemenus,
                      samenvattingPerMenu: technischeKeuzeSamenvatting,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: ThimacoKleuren.rand),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: OpmetingRaamNotities(
                controller: notitiesController,
                fotos: fotos,
                onFotosGewijzigd: onFotosGewijzigd,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _OpmetingRaamTechniekSamenvatting extends StatelessWidget {
  const _OpmetingRaamTechniekSamenvatting({
    required this.raamVleugelSamenvatting,
    required this.deurVleugelSamenvatting,
    required this.schuifraamSamenvatting,
    required this.profielSamenvatting,
    required this.gekozenOpvullingen,
    required this.gekozenKleinhouten,
    required this.keuzemenus,
    required this.samenvattingPerMenu,
  });

  final String raamVleugelSamenvatting;
  final String deurVleugelSamenvatting;
  final String schuifraamSamenvatting;
  final String profielSamenvatting;
  final List<OpmetingRaamVullingLegendaItem> gekozenOpvullingen;
  final List<OpmetingRaamKleinhoutLegendaItem> gekozenKleinhouten;
  final List<OpmetingRaamKeuzeMenu> keuzemenus;
  final Map<String, String> samenvattingPerMenu;

  @override
  Widget build(BuildContext context) {
    final regels = <Widget>[];

    void voegToe(String titel, String waarde) {
      final tekst = waarde.trim();
      if (tekst.isEmpty) return;
      if (regels.isNotEmpty) regels.add(const SizedBox(height: 6));
      regels.add(_regel(titel: titel, waarde: tekst));
    }

    voegToe('Raamvleugel', raamVleugelSamenvatting);
    voegToe('Deurvleugel', deurVleugelSamenvatting);
    voegToe('Schuifraam', schuifraamSamenvatting);

    if (gekozenOpvullingen.isNotEmpty) {
      final namen = gekozenOpvullingen
          .map((item) => item.naam.trim())
          .where((naam) => naam.isNotEmpty)
          .toSet()
          .toList();
      voegToe('Opvulling', namen.join(' • '));
    }

    if (gekozenKleinhouten.isNotEmpty) {
      final namen = gekozenKleinhouten
          .map((item) => _maakLeesbaar(item.type.name))
          .where((naam) => naam.isNotEmpty)
          .toSet()
          .toList();
      voegToe('Kleinhouten', namen.join(' • '));
    }

    voegToe('Profiel', profielSamenvatting);

    final menus = List<OpmetingRaamKeuzeMenu>.from(keuzemenus)
      ..sort((eerste, tweede) {
        final volgorde = eerste.volgorde.compareTo(tweede.volgorde);
        if (volgorde != 0) return volgorde;
        return eerste.titel.toLowerCase().compareTo(tweede.titel.toLowerCase());
      });

    for (final menu in menus) {
      if (!menu.actief) continue;
      voegToe(menu.titel, samenvattingPerMenu[menu.id] ?? '');
    }

    if (regels.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Nog geen technische keuzes geselecteerd.',
          style: TextStyle(
            color: ThimacoKleuren.tekstGrijs,
            fontSize: 11.5,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: regels,
    );
  }

  Widget _regel({required String titel, required String waarde}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 7, 9, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          top: BorderSide(color: ThimacoKleuren.rand),
          left: BorderSide(color: ThimacoKleuren.rand),
          right: BorderSide(color: ThimacoKleuren.rand),
          bottom: BorderSide(color: ThimacoKleuren.oranje, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            titel.trim().isEmpty ? 'Technische keuze' : titel.trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ThimacoKleuren.tekstGrijs,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            waarde,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ThimacoKleuren.antraciet,
              fontSize: 11.5,
              height: 1.15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _maakLeesbaar(String waarde) {
    final tekst = waarde.replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
    if (tekst.isEmpty) return tekst;
    return '${tekst[0].toUpperCase()}${tekst.substring(1)}';
  }
}

class _OpmetingRaamProgrammaKop extends StatefulWidget {
  const _OpmetingRaamProgrammaKop({
    required this.titel,
    required this.onTerug,
    required this.onToevoegen,
    required this.onAnnuleren,
    required this.tekenvlakController,
    required this.actieveTool,
    required this.onToolGekozen,
    required this.toonDeurTools,
    required this.onDeurVleugel,
    required this.onDeurPanelen,
    required this.toonSchuifraamTools,
    required this.onSchuifraamSamenstellen,
    required this.technischeKeuzesRibbon,
    required this.openRibbon,
    required this.onOpenRibbonGewijzigd,
  });

  final String titel;
  final Future<void> Function() onTerug;
  final Future<void> Function() onToevoegen;
  final Future<void> Function() onAnnuleren;
  final OpmetingRaamTekenvlakController tekenvlakController;
  final String actieveTool;
  final ValueChanged<String> onToolGekozen;
  final bool toonDeurTools;
  final VoidCallback? onDeurVleugel;
  final VoidCallback? onDeurPanelen;
  final bool toonSchuifraamTools;
  final VoidCallback? onSchuifraamSamenstellen;
  final Widget technischeKeuzesRibbon;
  final OpmetingRaamProgrammaRibbon openRibbon;
  final ValueChanged<OpmetingRaamProgrammaRibbon> onOpenRibbonGewijzigd;

  @override
  State<_OpmetingRaamProgrammaKop> createState() =>
      _OpmetingRaamProgrammaKopState();
}

class _OpmetingRaamProgrammaKopState
    extends State<_OpmetingRaamProgrammaKop> {
  void _wisselRibbon(OpmetingRaamProgrammaRibbon ribbon) {
    widget.onOpenRibbonGewijzigd(
      widget.openRibbon == ribbon
          ? OpmetingRaamProgrammaRibbon.geen
          : ribbon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 47,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: ThimacoKleuren.rand),
            ),
          ),
          child: Row(
            children: <Widget>[
              ThimacoIcoonActie(
                icoon: Icons.arrow_back_rounded,
                tooltip: 'Terug',
                onPressed: () {
                  widget.onTerug();
                },
              ),
              const SizedBox(width: 3),
              _bouwOpmeetficheMenu(),
              const SizedBox(width: 11),
              Container(width: 1, height: 24, color: ThimacoKleuren.rand),
              const SizedBox(width: 7),
              AnimatedBuilder(
                animation: widget.tekenvlakController,
                builder: (context, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ThimacoIcoonActie(
                        icoon: Icons.undo_rounded,
                        tooltip: 'Ongedaan maken',
                        onPressed: widget.tekenvlakController.kanOngedaanMaken
                            ? widget.tekenvlakController.ongedaanMaken
                            : null,
                      ),
                      ThimacoIcoonActie(
                        icoon: Icons.redo_rounded,
                        tooltip: 'Herstellen',
                        onPressed: widget.tekenvlakController.kanHerstellen
                            ? widget.tekenvlakController.herstellen
                            : null,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 5),
              _bouwRibbonTab(
                label: 'Tekenen',
                ribbon: OpmetingRaamProgrammaRibbon.tekenen,
              ),
              const SizedBox(width: 2),
              _bouwRibbonTab(
                label: 'Technische keuzes',
                ribbon: OpmetingRaamProgrammaRibbon.technischeKeuzes,
              ),
              const Spacer(),
              Text(
                widget.titel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ThimacoKleuren.antraciet,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: switch (widget.openRibbon) {
            OpmetingRaamProgrammaRibbon.tekenen => AnimatedBuilder(
              animation: widget.tekenvlakController,
              builder: (context, child) {
                return OpmetingRaamToolbalk(
                  actieveTool: widget.actieveTool,
                  onToolGekozen: widget.onToolGekozen,
                  kanOngedaanMaken:
                      widget.tekenvlakController.kanOngedaanMaken,
                  kanHerstellen: widget.tekenvlakController.kanHerstellen,
                  onOngedaanMaken:
                      widget.tekenvlakController.ongedaanMaken,
                  onHerstellen: widget.tekenvlakController.herstellen,
                  toonDeurTools: widget.toonDeurTools,
                  onDeurVleugel: widget.onDeurVleugel,
                  onDeurPanelen: widget.onDeurPanelen,
                  toonSchuifraamTools: widget.toonSchuifraamTools,
                  onSchuifraamSamenstellen:
                      widget.onSchuifraamSamenstellen,
                );
              },
            ),
            OpmetingRaamProgrammaRibbon.technischeKeuzes =>
              widget.technischeKeuzesRibbon,
            OpmetingRaamProgrammaRibbon.geen => const SizedBox.shrink(),
          },
        ),
      ],
    );
  }

  Widget _bouwRibbonTab({
    required String label,
    required OpmetingRaamProgrammaRibbon ribbon,
  }) {
    final open = widget.openRibbon == ribbon;

    return Tooltip(
      message: open ? '$label sluiten' : '$label openen',
      child: InkWell(
        onTap: () {
          _wisselRibbon(ribbon);
        },
        hoverColor: ThimacoKleuren.oranje.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 7, 8, 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    label,
                    style: const TextStyle(
                      color: ThimacoKleuren.antraciet,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    open
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: ThimacoKleuren.tekstGrijs,
                  ),
                ],
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                height: 1.5,
                width: label == 'Tekenen' ? 54 : 105,
                decoration: BoxDecoration(
                  color: open
                      ? ThimacoKleuren.oranje
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bouwOpmeetficheMenu() {
    return PopupMenuButton<String>(
      tooltip: 'Opmeetfiche',
      offset: const Offset(0, 34),
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: ThimacoKleuren.rand),
      ),
      onSelected: (waarde) {
        switch (waarde) {
          case 'toevoegen':
            widget.onToevoegen();
            break;
          case 'annuleren':
            widget.onAnnuleren();
            break;
        }
      },
      itemBuilder: (context) => const <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'toevoegen',
          child: Row(
            children: <Widget>[
              Icon(
                Icons.add_rounded,
                size: 18,
                color: ThimacoKleuren.antraciet,
              ),
              SizedBox(width: 9),
              Text('Toevoegen aan fiche'),
            ],
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'annuleren',
          child: Row(
            children: <Widget>[
              Icon(
                Icons.close_rounded,
                size: 18,
                color: ThimacoKleuren.rood,
              ),
              SizedBox(width: 9),
              Text(
                'Annuleren',
                style: TextStyle(color: ThimacoKleuren.rood),
              ),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Opmeetfiche',
                  style: TextStyle(
                    color: ThimacoKleuren.antraciet,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 3),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 17,
                  color: ThimacoKleuren.tekstGrijs,
                ),
              ],
            ),
            const SizedBox(height: 3),
            Container(
              height: 1.5,
              width: 73,
              decoration: BoxDecoration(
                color: ThimacoKleuren.oranje.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

