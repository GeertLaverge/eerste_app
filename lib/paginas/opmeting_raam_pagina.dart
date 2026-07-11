import 'package:flutter/material.dart';

import '../helpers/app_storage.dart';
import '../helpers/opmeting/raam/opmeting_raam_keuzemenu_model.dart';
import '../helpers/opmeting/raam/opmeting_raam_model.dart';
import '../helpers/opmeting/raam/opmeting_raam_kleinhout_helper.dart';
import '../helpers/opmeting/raam/opmeting_raam_kleinhout_model.dart';
import '../helpers/opmeting/raam/opmeting_raam_notities.dart';
import '../helpers/opmeting/raam/opmeting_raam_tekenvlak.dart';
import '../helpers/opmeting/raam/opmeting_raam_toolbalk.dart';
import '../helpers/opmeting/raam/opmeting_raam_vulling_helper.dart';
import '../helpers/opmeting/raam/opmeting_raam_technische_keuzes_paneel.dart';
import 'package:eerste_app/helpers/opmeting/raam/opmeting_raam_keuze_menu_helper.dart';
import 'package:eerste_app/helpers/opmeting/raam/opmeting_raam_menu_beheer_helper.dart';
import 'package:eerste_app/helpers/opmeting/raam/opmeting_raam_maten_helper.dart';
import 'package:eerste_app/helpers/opmeting/raam/opmeting_raam_keuze_conflict_helper.dart';
import 'package:eerste_app/helpers/opmeting/raam/opmeting_raam_keuze_selectie_helper.dart';
import 'package:eerste_app/helpers/opmeting/raam/opmeting_raam_formulier_layout.dart';
import 'package:eerste_app/helpers/opmeting/raam/overzicht/opmeting_raam_overzicht_builder.dart';
import '../helpers/opmeting/kader_samenstelling/opmeting_kader_samenstelling_model.dart';
import '../helpers/opmeting/kader_samenstelling/opmeting_kader_samenstelling_layout_helper.dart';
import '../helpers/opmeting/overzicht/opmeting_overzicht_model.dart';

class OpmetingRaamPagina extends StatefulWidget {
  const OpmetingRaamPagina({super.key, this.klantNaam, this.bestaandeOpmeting});

  final String? klantNaam;
  final OpmetingOverzichtRaamItem? bestaandeOpmeting;

  @override
  State<OpmetingRaamPagina> createState() {
    return _OpmetingRaamPaginaState();
  }
}

class _OpmetingRaamPaginaState extends State<OpmetingRaamPagina> {
  final TextEditingController dagmaatHoogteController = TextEditingController(
    text: '2000',
  );

  final TextEditingController dagmaatBreedteController = TextEditingController(
    text: '1000',
  );

  final TextEditingController slagLinksController = TextEditingController(
    text: '20',
  );

  final TextEditingController slagRechtsController = TextEditingController(
    text: '20',
  );

  final TextEditingController slagBovenController = TextEditingController(
    text: '20',
  );

  final TextEditingController slagOnderController = TextEditingController(
    text: '0',
  );

  final TextEditingController binnenTabletController = TextEditingController(
    text: '80',
  );

  final TextEditingController buitenTabletController = TextEditingController(
    text: '105',
  );

  final TextEditingController notitiesController = TextEditingController();

  final TextEditingController positieController = TextEditingController();

  final OpmetingRaamTekenvlakController tekenvlakController =
      OpmetingRaamTekenvlakController();

  String actieveTool = 'lijn';

  int vleugelMenuOpenSignaal = 0;
  int tStijlMenuOpenSignaal = 0;
  int opvullingMenuOpenSignaal = 0;
  int kleinhoutMenuOpenSignaal = 0;

  List<OpmetingRaamVullingLegendaItem> gekozenOpvullingen =
      <OpmetingRaamVullingLegendaItem>[];

  List<OpmetingRaamKleinhoutLegendaItem> gekozenKleinhouten =
      <OpmetingRaamKleinhoutLegendaItem>[];

  List<OpmetingRaamKeuzeMenu> _keuzemenus = <OpmetingRaamKeuzeMenu>[];
  late OpmetingKaderSamenstelling _kaderSamenstelling;

  final Map<String, Map<String, OpmetingRaamKeuzeSelectie>>
  _keuzeSelectiesPerKader = <String, Map<String, OpmetingRaamKeuzeSelectie>>{};

  Set<String> _geselecteerdeKaderIdsVoorKeuzes = <String>{};

  OpmetingOverzichtTekeningData? _overzichtTekeningData;

  bool _keuzemenusLaden = true;
  bool _keuzemenusBewaren = false;
  bool _menuBeheerOntgrendeld = false;
  bool _opvullingenOpen = false;
  bool _kleinhoutenOpen = false;

  @override
  void initState() {
    super.initState();

    final bestaandeOpmeting = widget.bestaandeOpmeting;

    if (bestaandeOpmeting == null) {
      _kaderSamenstelling = OpmetingKaderSamenstelling.basis(
        breedteMm: raammaatBreedte,
        hoogteMm: raammaatHoogte,
        slagLinksMm: _waarde(slagLinksController).round(),
        slagRechtsMm: _waarde(slagRechtsController).round(),
        slagBovenMm: _waarde(slagBovenController).round(),
        slagOnderMm: 0,
      );
    } else {
      _zetControllerTekst(
        dagmaatBreedteController,
        bestaandeOpmeting.dagmaatBreedteMm,
      );
      _zetControllerTekst(
        dagmaatHoogteController,
        bestaandeOpmeting.dagmaatHoogteMm,
      );
      _zetControllerTekst(
        slagLinksController,
        bestaandeOpmeting.kaderSamenstelling.slagLinksMm,
      );
      _zetControllerTekst(
        slagRechtsController,
        bestaandeOpmeting.kaderSamenstelling.slagRechtsMm,
      );
      _zetControllerTekst(
        slagBovenController,
        bestaandeOpmeting.kaderSamenstelling.slagBovenMm,
      );
      _zetControllerTekst(slagOnderController, 0);
      notitiesController.text = bestaandeOpmeting.notities;

      _kaderSamenstelling = bestaandeOpmeting.kaderSamenstelling.copyWith(
        slagOnderMm: 0,
      );
      _overzichtTekeningData = bestaandeOpmeting.tekeningData;
      _keuzeSelectiesPerKader.addAll(
        _kopieKeuzeSelecties(bestaandeOpmeting.keuzeSelectiesPerKader),
      );
    }

    _laadKeuzemenus();
  }

  @override
  void dispose() {
    dagmaatHoogteController.dispose();
    dagmaatBreedteController.dispose();

    slagLinksController.dispose();
    slagRechtsController.dispose();
    slagBovenController.dispose();
    slagOnderController.dispose();

    binnenTabletController.dispose();
    buitenTabletController.dispose();

    notitiesController.dispose();
    positieController.dispose();

    tekenvlakController.dispose();

    super.dispose();
  }

  double _waarde(TextEditingController controller) {
    return OpmetingRaamMatenHelper.waarde(controller);
  }

  Map<String, Map<String, OpmetingRaamKeuzeSelectie>> _kopieKeuzeSelecties(
    Map<String, Map<String, OpmetingRaamKeuzeSelectie>> bron,
  ) {
    return OpmetingRaamKeuzeMenuHelper.kopieKeuzeSelecties(bron);
  }

  void _zetControllerTekst(TextEditingController controller, int waarde) {
    OpmetingRaamMatenHelper.zetControllerTekst(controller, waarde);
  }

  String get _actiefKaderIdVoorKeuzes {
    return OpmetingRaamKeuzeSelectieHelper.actiefKaderIdVoorKeuzes(
      kaderSamenstelling: _kaderSamenstelling,
    );
  }

  String get _actieveKeuzeSleutel {
    return OpmetingRaamKeuzeSelectieHelper.actieveKeuzeSleutel(
      kaderSamenstelling: _kaderSamenstelling,
      geselecteerdeKaderIdsVoorKeuzes: _geselecteerdeKaderIdsVoorKeuzes,
    );
  }

  Map<String, OpmetingRaamKeuzeSelectie> _selectiesVoorKader(String kaderId) {
    return OpmetingRaamKeuzeSelectieHelper.selectiesVoorSleutel(
      keuzeSelectiesPerKader: _keuzeSelectiesPerKader,
      sleutel: kaderId,
    );
  }

  Map<String, OpmetingRaamKeuzeSelectie> get _actieveKeuzeSelecties {
    return _selectiesVoorKader(_actieveKeuzeSleutel);
  }

  void _verwijderKeuzeSelectiesVanNietBestaandeKaders() {
    _geselecteerdeKaderIdsVoorKeuzes =
        OpmetingRaamKeuzeSelectieHelper.verwijderKeuzeSelectiesVanNietBestaandeKaders(
          kaderSamenstelling: _kaderSamenstelling,
          keuzeSelectiesPerKader: _keuzeSelectiesPerKader,
          geselecteerdeKaderIdsVoorKeuzes: _geselecteerdeKaderIdsVoorKeuzes,
        );
  }

  void _verwerkGeselecteerdeKadersVoorKeuzes(Set<String> kaderIds) {
    setState(() {
      _geselecteerdeKaderIdsVoorKeuzes = kaderIds;
      _normaliseerKeuzeSelecties();
    });
  }

  void _verwerkOverzichtTekeningData(OpmetingOverzichtTekeningData data) {
    _overzichtTekeningData = data;
  }

  void _vulMaatveldenMetActiefKader(OpmetingKaderSamenstelling samenstelling) {
    OpmetingRaamMatenHelper.vulMaatveldenMetActiefKader(
      samenstelling: samenstelling,
      dagmaatBreedteController: dagmaatBreedteController,
      dagmaatHoogteController: dagmaatHoogteController,
      slagLinksController: slagLinksController,
      slagRechtsController: slagRechtsController,
      slagBovenController: slagBovenController,
      slagOnderController: slagOnderController,
    );
  }

  int get raammaatBreedte {
    return OpmetingRaamMatenHelper.berekenRaammaatBreedte(
      dagmaatBreedteController: dagmaatBreedteController,
      slagLinksController: slagLinksController,
      slagRechtsController: slagRechtsController,
    );
  }

  int get raammaatHoogte {
    return OpmetingRaamMatenHelper.berekenRaammaatHoogte(
      dagmaatHoogteController: dagmaatHoogteController,
      slagBovenController: slagBovenController,
    );
  }

  int get verschilTablet {
    return OpmetingRaamMatenHelper.berekenVerschilTablet(
      binnenTabletController: binnenTabletController,
      buitenTabletController: buitenTabletController,
    );
  }

  void _herbereken() {
    setState(() {
      _kaderSamenstelling = OpmetingRaamMatenHelper.herberekenSamenstelling(
        huidigeSamenstelling: _kaderSamenstelling,
        raammaatBreedte: raammaatBreedte,
        raammaatHoogte: raammaatHoogte,
        slagLinksController: slagLinksController,
        slagRechtsController: slagRechtsController,
        slagBovenController: slagBovenController,
        slagOnderController: slagOnderController,
      );
    });
  }

  void _wijzigKaderSamenstelling(
    OpmetingKaderSamenstelling nieuweSamenstelling,
  ) {
    final herberekendeSamenstelling = nieuweSamenstelling.copyWith(
      slagOnderMm: 0,
      kaders: OpmetingKaderSamenstellingLayoutHelper.herberekenGekoppeldeKaders(
        kaders: nieuweSamenstelling.kaders,
      ),
    );

    setState(() {
      _kaderSamenstelling = herberekendeSamenstelling;
      _verwijderKeuzeSelectiesVanNietBestaandeKaders();
      _normaliseerKeuzeSelecties();
    });

    _vulMaatveldenMetActiefKader(herberekendeSamenstelling);
  }

  void _toolGekozen(String tool) {
    setState(() {
      actieveTool = tool;

      switch (tool) {
        case 'tstijl':
          tStijlMenuOpenSignaal++;
          break;

        case 'vleugel':
          vleugelMenuOpenSignaal++;
          break;

        case 'opvulling':
          opvullingMenuOpenSignaal++;
          break;

        case 'kleinhout':
          kleinhoutMenuOpenSignaal++;
          break;
      }
    });
  }

  void _verwerkOpvullingen(
    List<OpmetingRaamVullingLegendaItem> nieuweOpvullingen,
  ) {
    if (_zijnOpvullingenGelijk(gekozenOpvullingen, nieuweOpvullingen)) {
      return;
    }

    setState(() {
      gekozenOpvullingen = List<OpmetingRaamVullingLegendaItem>.unmodifiable(
        nieuweOpvullingen,
      );
    });
  }

  void _verwerkKleinhouten(
    List<OpmetingRaamKleinhoutLegendaItem> nieuweKleinhouten,
  ) {
    if (_zijnKleinhoutenGelijk(gekozenKleinhouten, nieuweKleinhouten)) {
      return;
    }

    setState(() {
      gekozenKleinhouten = List<OpmetingRaamKleinhoutLegendaItem>.unmodifiable(
        nieuweKleinhouten,
      );
    });
  }

  bool _zijnOpvullingenGelijk(
    List<OpmetingRaamVullingLegendaItem> eerste,
    List<OpmetingRaamVullingLegendaItem> tweede,
  ) {
    if (eerste.length != tweede.length) {
      return false;
    }

    for (var index = 0; index < eerste.length; index++) {
      final eersteItem = eerste[index];
      final tweedeItem = tweede[index];

      if (eersteItem.nummer != tweedeItem.nummer ||
          eersteItem.naam != tweedeItem.naam ||
          eersteItem.kleur.value != tweedeItem.kleur.value ||
          eersteItem.weergaveKleur.value != tweedeItem.weergaveKleur.value) {
        return false;
      }
    }

    return true;
  }

  bool _zijnKleinhoutenGelijk(
    List<OpmetingRaamKleinhoutLegendaItem> eerste,
    List<OpmetingRaamKleinhoutLegendaItem> tweede,
  ) {
    if (eerste.length != tweede.length) {
      return false;
    }

    for (var index = 0; index < eerste.length; index++) {
      final eersteItem = eerste[index];
      final tweedeItem = tweede[index];

      if (eersteItem.nummer != tweedeItem.nummer ||
          eersteItem.type != tweedeItem.type ||
          eersteItem.patroon != tweedeItem.patroon ||
          eersteItem.aantalHorizontaal != tweedeItem.aantalHorizontaal ||
          eersteItem.aantalVerticaal != tweedeItem.aantalVerticaal ||
          eersteItem.horizontaleHoogteMm != tweedeItem.horizontaleHoogteMm ||
          !_zelfdeTeksten(eersteItem.vlakIds, tweedeItem.vlakIds)) {
        return false;
      }
    }

    return true;
  }

  bool _zelfdeTeksten(List<String> eerste, List<String> tweede) {
    if (eerste.length != tweede.length) {
      return false;
    }

    for (var index = 0; index < eerste.length; index++) {
      if (eerste[index] != tweede[index]) {
        return false;
      }
    }

    return true;
  }

  Future<void> _laadKeuzemenus() async {
    setState(() {
      _keuzemenusLaden = true;
    });

    try {
      final geladenMenus = await AppStorage.laadOpmetingRaamKeuzemenus();

      final opgeschoondeMenus = _verwijderOngeldigeNietCombineerbareKoppelingen(
        geladenMenus,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _keuzemenus
          ..clear()
          ..addAll(opgeschoondeMenus);

        _normaliseerKeuzeSelecties();

        _keuzemenusLaden = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _keuzemenusLaden = false;
      });

      _toonMelding('De keuzemenu’s konden niet worden geladen.', fout: true);
    }
  }

  List<OpmetingRaamKeuzeMenu> _verwijderOngeldigeNietCombineerbareKoppelingen(
    List<OpmetingRaamKeuzeMenu> menus,
  ) {
    return OpmetingRaamKeuzeMenuHelper.verwijderOngeldigeNietCombineerbareKoppelingen(
      menus,
    );
  }

  Future<void> _bewaarKeuzemenus(
    List<OpmetingRaamKeuzeMenu> nieuweMenus,
  ) async {
    final opgeschoondeMenus = _verwijderOngeldigeNietCombineerbareKoppelingen(
      nieuweMenus,
    );

    final gesorteerdeMenus = OpmetingRaamKeuzeMenuHelper.sorteerMenus(
      opgeschoondeMenus,
    );

    setState(() {
      _keuzemenus
        ..clear()
        ..addAll(gesorteerdeMenus);

      _normaliseerKeuzeSelecties();

      _keuzemenusBewaren = true;
    });

    try {
      await AppStorage.bewaarOpmetingRaamKeuzemenus(gesorteerdeMenus);
    } catch (_) {
      if (mounted) {
        _toonMelding('De keuzemenu’s konden niet worden bewaard.', fout: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _keuzemenusBewaren = false;
        });
      }
    }
  }

  void _normaliseerKeuzeSelecties() {
    _geselecteerdeKaderIdsVoorKeuzes =
        OpmetingRaamKeuzeSelectieHelper.normaliseerKeuzeSelecties(
          kaderSamenstelling: _kaderSamenstelling,
          keuzemenus: _keuzemenus,
          keuzeSelectiesPerKader: _keuzeSelectiesPerKader,
          geselecteerdeKaderIdsVoorKeuzes: _geselecteerdeKaderIdsVoorKeuzes,
        );
  }

  OpmetingRaamKeuzeSelectie _selectieVoorMenu(OpmetingRaamKeuzeMenu menu) {
    return OpmetingRaamKeuzeSelectieHelper.selectieVoorMenu(
      selecties: _actieveKeuzeSelecties,
      menu: menu,
    );
  }

  OpmetingRaamKeuzeOptie _optieVoorSelectie(OpmetingRaamKeuzeMenu menu) {
    return OpmetingRaamKeuzeSelectieHelper.optieVoorSelectie(
      selecties: _actieveKeuzeSelecties,
      menu: menu,
    );
  }

  List<OpmetingRaamTechnischeTekeningInstelling>
  _actieveTechnischeTekeningenVoorKader(String kaderId) {
    return OpmetingRaamKeuzeSelectieHelper.actieveTechnischeTekeningenVoorSleutel(
      sleutel: kaderId,
      keuzeSelectiesPerKader: _keuzeSelectiesPerKader,
      keuzemenus: _keuzemenus,
    );
  }

  Map<String, List<OpmetingRaamTechnischeTekeningInstelling>>
  _technischeTekeningenPerKader() {
    return OpmetingRaamKeuzeSelectieHelper.technischeTekeningenPerKader(
      kaderSamenstelling: _kaderSamenstelling,
      keuzeSelectiesPerKader: _keuzeSelectiesPerKader,
      keuzemenus: _keuzemenus,
    );
  }

  Map<String, List<OpmetingRaamTechnischeTekeningInstelling>>
  _technischeTekeningenPerKaderGroep() {
    return OpmetingRaamKeuzeSelectieHelper.technischeTekeningenPerKaderGroep(
      keuzeSelectiesPerKader: _keuzeSelectiesPerKader,
      keuzemenus: _keuzemenus,
    );
  }

  Map<String, Set<String>> _technischeKaderGroepen() {
    return OpmetingRaamKeuzeSelectieHelper.technischeKaderGroepen(
      keuzeSelectiesPerKader: _keuzeSelectiesPerKader,
    );
  }

  Future<void> _kiesOptie(OpmetingRaamKeuzeMenu menu, String optieId) async {
    OpmetingRaamKeuzeOptie? gevondenOptie;

    for (final optie in menu.opties) {
      if (optie.id == optieId) {
        gevondenOptie = optie;
        break;
      }
    }

    if (gevondenOptie == null) {
      return;
    }

    final gekozenOptie = gevondenOptie;

    setState(() {
      _actieveKeuzeSelecties[menu.id] = OpmetingRaamKeuzeSelectie(
        menuId: menu.id,
        optieId: gekozenOptie.id,
        extraWaarden: _standaardExtraWaarden(gekozenOptie),
      );
    });

    /*
     * Bij "Geen" hoeft geen controle uitgevoerd
     * te worden.
     */
    if (gekozenOptie.isGeenKeuze) {
      return;
    }

    final conflicten = OpmetingRaamKeuzeConflictHelper.zoekConflicten(
      keuzemenus: _keuzemenus,
      keuzeSelecties: _actieveKeuzeSelecties,
      gekozenMenu: menu,
      gekozenOptie: gekozenOptie,
    );

    if (conflicten.isEmpty || !mounted) {
      return;
    }

    await OpmetingRaamKeuzeConflictHelper.toonWaarschuwing(
      context: context,
      gekozenMenu: menu,
      gekozenOptie: gekozenOptie,
      conflicten: conflicten,
    );
  }

  Map<String, dynamic> _standaardExtraWaarden(OpmetingRaamKeuzeOptie optie) {
    return OpmetingRaamKeuzeMenuHelper.standaardExtraWaarden(optie);
  }

  void _werkExtraWaardeBij({
    required OpmetingRaamKeuzeMenu menu,
    required String veldId,
    required dynamic waarde,
  }) {
    final selectie = _selectieVoorMenu(menu);

    final nieuweExtraWaarden = Map<String, dynamic>.from(selectie.extraWaarden);

    nieuweExtraWaarden[veldId] = waarde;

    setState(() {
      _actieveKeuzeSelecties[menu.id] = selectie.copyWith(
        extraWaarden: nieuweExtraWaarden,
      );
    });
  }

  Future<void> _wisselBeheerSlot() async {
    final nieuweWaarde =
        await OpmetingRaamMenuBeheerHelper.vraagBeheerSlotWissel(
          context: context,
          menuBeheerOntgrendeld: _menuBeheerOntgrendeld,
        );

    if (nieuweWaarde == null || !mounted) {
      return;
    }

    setState(() {
      _menuBeheerOntgrendeld = nieuweWaarde;
    });
  }

  Future<void> _voegMenuToe() async {
    final nieuweMenus = await OpmetingRaamMenuBeheerHelper.voegMenuToe(
      context: context,
      keuzemenus: _keuzemenus,
    );

    if (nieuweMenus == null || !mounted) {
      return;
    }

    await _bewaarKeuzemenus(nieuweMenus);
  }

  Future<void> _bewerkTechnischMenu(OpmetingRaamKeuzeMenu menu) async {
    final nieuweMenus = await OpmetingRaamMenuBeheerHelper.bewerkTechnischMenu(
      context: context,
      keuzemenus: _keuzemenus,
      menu: menu,
    );

    if (nieuweMenus == null || !mounted) {
      return;
    }

    await _bewaarKeuzemenus(nieuweMenus);
  }

  Future<void> _verwijderMenu(OpmetingRaamKeuzeMenu menu) async {
    final nieuweMenus = await OpmetingRaamMenuBeheerHelper.verwijderMenu(
      context: context,
      keuzemenus: _keuzemenus,
      menu: menu,
    );

    if (nieuweMenus == null || !mounted) {
      return;
    }

    await _bewaarKeuzemenus(nieuweMenus);
  }

  Future<void> _verplaatsMenu(OpmetingRaamKeuzeMenu menu, int richting) async {
    final nieuweMenus = OpmetingRaamMenuBeheerHelper.verplaatsMenu(
      keuzemenus: _keuzemenus,
      menu: menu,
      richting: richting,
    );

    if (nieuweMenus == null) {
      return;
    }

    await _bewaarKeuzemenus(nieuweMenus);
  }

  Future<void> _opslaan() async {
    final aantalIngevuldeKeuzes = _keuzemenus.where((menu) {
      final optie = _optieVoorSelectie(menu);

      return !optie.isGeenKeuze;
    }).length;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Opmeting raam voorlopig lokaal getest. '
          '$aantalIngevuldeKeuzes technische keuze(s) ingevuld.',
        ),
        backgroundColor: const Color(0xFF0B7A3B),
      ),
    );
  }

  Future<void> _voegOpmetingToeAanOverzicht() async {
    Navigator.pop(context, _maakOverzichtItem());
  }

  Future<void> _vraagToevoegenAanOverzichtBijTerug() async {
    final keuze = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Opmeting toevoegen aan overzicht?'),
          content: const Text(
            'Deze raamopmeting is nog niet toegevoegd aan het overzicht. Wilt u deze opmeting toevoegen?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'niet_toevoegen');
              },
              child: const Text('Niet toevoegen'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'verder_bewerken');
              },
              child: const Text('Verder bewerken'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, 'toevoegen');
              },
              child: const Text('Toevoegen'),
            ),
          ],
        );
      },
    );

    if (!mounted || keuze == null || keuze == 'verder_bewerken') {
      return;
    }

    if (keuze == 'toevoegen') {
      Navigator.pop(context, _maakOverzichtItem());
      return;
    }

    Navigator.pop(context);
  }

  OpmetingOverzichtRaamItem _maakOverzichtItem() {
    return OpmetingRaamOverzichtBuilder.maak(
      klantNaam: widget.klantNaam?.trim() ?? '',
      dagmaatBreedteMm: _waarde(dagmaatBreedteController).round(),
      dagmaatHoogteMm: _waarde(dagmaatHoogteController).round(),
      raammaatBreedteMm: raammaatBreedte,
      raammaatHoogteMm: raammaatHoogte,
      kaderSamenstelling: _kaderSamenstelling,
      beginTekeningData: _overzichtTekeningData,
      actieveTechnischeTekeningen: _actieveTechnischeTekeningenVoorKader(
        _actieveKeuzeSleutel,
      ),
      technischeTekeningenPerKader: _technischeTekeningenPerKader(),
      technischeTekeningenPerKaderGroep: _technischeTekeningenPerKaderGroep(),
      technischeKaderGroepen: _technischeKaderGroepen(),
      keuzeSelectiesPerKader: _keuzeSelectiesPerKader,
      keuzemenus: _keuzemenus,
      gekozenOpvullingen: gekozenOpvullingen,
      gekozenKleinhouten: gekozenKleinhouten,
      notities: notitiesController.text.trim(),
    );
  }

  void _toonMelding(String tekst, {bool fout = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tekst),
        backgroundColor: fout
            ? const Color(0xFFDC2626)
            : const Color(0xFF0B7A3B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final technischeTekeningen = _actieveTechnischeTekeningenVoorKader(
      _actieveKeuzeSleutel,
    );

    final technischeTekeningenPerKader = _technischeTekeningenPerKader();

    final technischeTekeningenPerKaderGroep =
        _technischeTekeningenPerKaderGroep();

    final technischeKaderGroepen = _technischeKaderGroepen();

    return OpmetingRaamFormulierLayout(
      klantNaam: widget.klantNaam,
      onTerug: _vraagToevoegenAanOverzichtBijTerug,
      onToevoegen: _voegOpmetingToeAanOverzicht,
      onOpslaan: _opslaan,
      dagmaatHoogteController: dagmaatHoogteController,
      dagmaatBreedteController: dagmaatBreedteController,
      slagLinksController: slagLinksController,
      slagRechtsController: slagRechtsController,
      slagBovenController: slagBovenController,
      slagOnderController: slagOnderController,
      binnenTabletController: binnenTabletController,
      buitenTabletController: buitenTabletController,
      raammaatBreedte: raammaatBreedte,
      raammaatHoogte: raammaatHoogte,
      verschilTablet: verschilTablet,
      onMatenGewijzigd: _herbereken,
      tekenvlakController: tekenvlakController,
      actieveTool: actieveTool,
      vleugelMenuOpenSignaal: vleugelMenuOpenSignaal,
      tStijlMenuOpenSignaal: tStijlMenuOpenSignaal,
      opvullingMenuOpenSignaal: opvullingMenuOpenSignaal,
      kleinhoutMenuOpenSignaal: kleinhoutMenuOpenSignaal,
      positieController: positieController,
      technischeTekeningen: technischeTekeningen,
      technischeTekeningenPerKader: technischeTekeningenPerKader,
      technischeTekeningenPerKaderGroep: technischeTekeningenPerKaderGroep,
      technischeKaderGroepen: technischeKaderGroepen,
      beginTekeningData: _overzichtTekeningData,
      onGeselecteerdeKaderIdsGewijzigd: _verwerkGeselecteerdeKadersVoorKeuzes,
      onOverzichtTekeningGewijzigd: _verwerkOverzichtTekeningData,
      onOpvullingenGewijzigd: _verwerkOpvullingen,
      onKleinhoutenGewijzigd: _verwerkKleinhouten,
      kaderSamenstelling: _kaderSamenstelling,
      onKaderSamenstellingGewijzigd: _wijzigKaderSamenstelling,
      onToolGekozen: _toolGekozen,
      notitiesController: notitiesController,
      gekozenOpvullingen: gekozenOpvullingen,
      gekozenKleinhouten: gekozenKleinhouten,
      keuzemenus: _keuzemenus,
      keuzemenusLaden: _keuzemenusLaden,
      keuzemenusBewaren: _keuzemenusBewaren,
      menuBeheerOntgrendeld: _menuBeheerOntgrendeld,
      opvullingenOpen: _opvullingenOpen,
      kleinhoutenOpen: _kleinhoutenOpen,
      onOpvullingenOpenGewijzigd: (waarde) {
        setState(() {
          _opvullingenOpen = waarde;
        });
      },
      onKleinhoutenOpenGewijzigd: (waarde) {
        setState(() {
          _kleinhoutenOpen = waarde;
        });
      },
      geselecteerdeOptieIdVoorMenu: (menu) {
        return _selectieVoorMenu(menu).optieId;
      },
      onOptieGekozen: _kiesOptie,
      onMenuToevoegen: _voegMenuToe,
      onBeheerSlotWisselen: _wisselBeheerSlot,
      onMenuAanpassen: _bewerkTechnischMenu,
      onMenuOmhoog: (menu) {
        _verplaatsMenu(menu, -1);
      },
      onMenuOmlaag: (menu) {
        _verplaatsMenu(menu, 1);
      },
      onMenuVerwijderen: _verwijderMenu,
    );
  }
}
