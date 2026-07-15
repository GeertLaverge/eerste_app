import 'dart:async';

import 'package:flutter/material.dart';

import '../helpers/app_storage.dart';
import '../helpers/opmeting/deurpanelen/opmeting_deurpaneel_actieve_keuze_controller.dart';
import '../helpers/opmeting/deurpanelen/opmeting_deurpaneel_keuze_dialog.dart';
import '../helpers/opmeting/deurpanelen/opmeting_deurpaneel_model.dart';
import '../helpers/opmeting/deurpanelen/opmeting_deurpaneel_tekst_helper.dart';
import '../helpers/opmeting/deurpanelen/opmeting_deurpaneel_toewijzing_model.dart';
import '../helpers/opmeting/deurpanelen/opmeting_deurpaneel_toewijzing_storage_helper.dart';
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
  const OpmetingRaamPagina({
    super.key,
    this.klantNaam,
    this.bestaandeOpmeting,
    this.formulierType = 'pvcRaam',
  });

  final String? klantNaam;
  final OpmetingOverzichtRaamItem? bestaandeOpmeting;
  final String formulierType;

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

  final TextEditingController raammaatHoogteController = TextEditingController(
    text: '2020',
  );

  final TextEditingController raammaatBreedteController = TextEditingController(
    text: '1040',
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

  final TextEditingController uitzagenTandController = TextEditingController(
    text: '0',
  );

  final TextEditingController buitensteLipController = TextEditingController(
    text: '0',
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

  OpmetingDeurpaneelKeuze? _actieveDeurpaneelKeuze;
  List<OpmetingDeurpaneelToewijzing> _deurpaneelToewijzingen =
      const <OpmetingDeurpaneelToewijzing>[];

  @override
  void initState() {
    super.initState();

    OpmetingDeurpaneelActieveKeuzeController.wisAlles();
    OpmetingDeurpaneelActieveKeuzeController.toewijzingen.addListener(
      _verwerkDeurpaneelToewijzingen,
    );

    final bestaandeOpmeting = widget.bestaandeOpmeting;

    if (bestaandeOpmeting == null) {
      final slagLinksMm = _waarde(slagLinksController).round();
      final slagRechtsMm = _waarde(slagRechtsController).round();
      final slagBovenMm = _waarde(slagBovenController).round();
      final slagOnderMm = _waarde(slagOnderController).round();

      final startRaammaatBreedte =
          OpmetingRaamMatenHelper.berekenRaammaatBreedte(
            dagmaatBreedteController: dagmaatBreedteController,
            slagLinksController: slagLinksController,
            slagRechtsController: slagRechtsController,
          );

      final startRaammaatHoogte = OpmetingRaamMatenHelper.berekenRaammaatHoogte(
        dagmaatHoogteController: dagmaatHoogteController,
        slagBovenController: slagBovenController,
        slagOnderController: slagOnderController,
      );

      _zetControllerTekst(raammaatBreedteController, startRaammaatBreedte);
      _zetControllerTekst(raammaatHoogteController, startRaammaatHoogte);

      _kaderSamenstelling = OpmetingKaderSamenstelling.basis(
        breedteMm: startRaammaatBreedte,
        hoogteMm: startRaammaatHoogte,
        slagLinksMm: slagLinksMm,
        slagRechtsMm: slagRechtsMm,
        slagBovenMm: slagBovenMm,
        slagOnderMm: slagOnderMm,
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
        raammaatBreedteController,
        bestaandeOpmeting.raammaatBreedteMm,
      );
      _zetControllerTekst(
        raammaatHoogteController,
        bestaandeOpmeting.raammaatHoogteMm,
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
      _zetControllerTekst(
        slagOnderController,
        bestaandeOpmeting.kaderSamenstelling.slagOnderMm,
      );
      notitiesController.text = bestaandeOpmeting.notities;

      _kaderSamenstelling = bestaandeOpmeting.kaderSamenstelling;
      _overzichtTekeningData = bestaandeOpmeting.tekeningData;
      _herstelLegendaUitTekeningData(bestaandeOpmeting.tekeningData);
      _keuzeSelectiesPerKader.addAll(
        _kopieKeuzeSelecties(bestaandeOpmeting.keuzeSelectiesPerKader),
      );
    }

    _laadKeuzemenus();

    if (bestaandeOpmeting != null) {
      unawaited(_laadDeurpaneelToewijzingenVoorOpmeting(bestaandeOpmeting.id));
    }
  }

  @override
  void dispose() {
    OpmetingDeurpaneelActieveKeuzeController.toewijzingen.removeListener(
      _verwerkDeurpaneelToewijzingen,
    );

    dagmaatHoogteController.dispose();
    dagmaatBreedteController.dispose();
    raammaatHoogteController.dispose();
    raammaatBreedteController.dispose();

    slagLinksController.dispose();
    slagRechtsController.dispose();
    slagBovenController.dispose();
    slagOnderController.dispose();

    binnenTabletController.dispose();
    buitenTabletController.dispose();
    uitzagenTandController.dispose();
    buitensteLipController.dispose();

    notitiesController.dispose();
    positieController.dispose();

    tekenvlakController.dispose();

    super.dispose();
  }

  String get _formulierType {
    final bestaandeOpmeting = widget.bestaandeOpmeting;

    if (bestaandeOpmeting != null) {
      return bestaandeOpmeting.formulierTypeGenormaliseerd;
    }

    switch (widget.formulierType.trim()) {
      case 'aluRaam':
      case 'alu_raam':
      case 'ALU Raam':
        return 'aluRaam';

      case 'pvcDeur':
      case 'pvc_deur':
      case 'PVC Deur':
        return 'pvcDeur';

      case 'aluDeur':
      case 'alu_deur':
      case 'ALU Deur':
        return 'aluDeur';

      case 'pvcRaam':
      case 'pvc_raam':
      case 'PVC Raam':
      case 'raam':
      case '':
        return 'pvcRaam';

      default:
        return widget.formulierType.trim();
    }
  }

  String get _formulierTitel {
    switch (_formulierType) {
      case 'aluRaam':
        return 'Opmeting ALU Raam';

      case 'pvcDeur':
        return 'Opmeting PVC Deur';

      case 'aluDeur':
        return 'Opmeting ALU Deur';

      case 'pvcRaam':
      default:
        return 'Opmeting PVC Raam';
    }
  }

  bool get _isDeurFiche {
    return _formulierType == 'pvcDeur' || _formulierType == 'aluDeur';
  }

  Future<void> _laadDeurpaneelToewijzingenVoorOpmeting(
    String opmetingId,
  ) async {
    final toewijzingen =
        await OpmetingDeurpaneelToewijzingStorageHelper.laadVoorOpmetingId(
          opmetingId: opmetingId,
        );

    if (!mounted) {
      return;
    }

    setState(() {
      _deurpaneelToewijzingen = List<OpmetingDeurpaneelToewijzing>.unmodifiable(
        toewijzingen,
      );
    });

    OpmetingDeurpaneelActieveKeuzeController.werkToewijzingenBij(toewijzingen);
  }

  void _openDeurVleugel() {
    _toolGekozen(actieveTool == 'deurvleugel' ? 'lijn' : 'deurvleugel');
  }

  void _openDeurPanelen() {
    _toonDeurpanelenDialog();
  }

  Future<void> _toonDeurpanelenDialog() async {
    if (!_isDeurFiche) {
      _toonMelding(
        'Deurpanelen kunnen enkel op een deurfiche worden gekozen.',
        fout: true,
      );
      return;
    }

    final keuze = await showDialog<OpmetingDeurpaneelKeuze>(
      context: context,
      builder: (dialogContext) {
        return const OpmetingDeurpaneelKeuzeDialog();
      },
    );

    if (!mounted || keuze == null) {
      return;
    }

    OpmetingDeurpaneelActieveKeuzeController.kies(keuze);

    setState(() {
      _actieveDeurpaneelKeuze = keuze;
      actieveTool = 'deurpanelen';
    });

    final vervolgTekst = keuze.wissen
        ? 'Klik nu op de deurvleugel waarvan u het paneel wilt verwijderen.'
        : 'Klik nu op de deurvleugel om het paneel te plaatsen.';

    _toonMelding(
      '${OpmetingDeurpaneelTekstHelper.korteMeldingVoorKeuze(keuze)} $vervolgTekst',
    );
  }

  double _waarde(TextEditingController controller) {
    return OpmetingRaamMatenHelper.waarde(controller);
  }

  bool _isMaatveldLeeg(TextEditingController controller) {
    return controller.text.trim().isEmpty;
  }

  bool _isMaatveldNogTijdelijk(TextEditingController controller) {
    final tekst = controller.text.trim();

    return tekst.isNotEmpty && tekst.length < 3;
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
    setState(() {
      _overzichtTekeningData = data;
    });

    _herstelLegendaUitTekeningData(data, metSetState: true);
  }

  void _verwerkDeurpaneelToewijzingen() {
    final nieuweToewijzingen =
        OpmetingDeurpaneelActieveKeuzeController.toewijzingen.value;

    if (_zijnDeurpaneelToewijzingenGelijk(
      _deurpaneelToewijzingen,
      nieuweToewijzingen,
    )) {
      return;
    }

    if (!mounted) {
      _deurpaneelToewijzingen = List<OpmetingDeurpaneelToewijzing>.unmodifiable(
        nieuweToewijzingen,
      );
      return;
    }

    setState(() {
      _deurpaneelToewijzingen = List<OpmetingDeurpaneelToewijzing>.unmodifiable(
        nieuweToewijzingen,
      );
    });
  }

  bool _zijnDeurpaneelToewijzingenGelijk(
    List<OpmetingDeurpaneelToewijzing> eerste,
    List<OpmetingDeurpaneelToewijzing> tweede,
  ) {
    if (eerste.length != tweede.length) {
      return false;
    }

    for (var index = 0; index < eerste.length; index++) {
      final eersteItem = eerste[index];
      final tweedeItem = tweede[index];

      if (eersteItem.id != tweedeItem.id ||
          eersteItem.deurVleugelId != tweedeItem.deurVleugelId ||
          eersteItem.paneelId != tweedeItem.paneelId ||
          eersteItem.paneelNaam != tweedeItem.paneelNaam ||
          eersteItem.tekeningBestandsnaam != tweedeItem.tekeningBestandsnaam ||
          eersteItem.uitvoering != tweedeItem.uitvoering ||
          eersteItem.cilinderZijde != tweedeItem.cilinderZijde) {
        return false;
      }
    }

    return true;
  }

  String get _deurVleugelSamenvatting {
    final data = _overzichtTekeningData;

    if (data == null) {
      return '';
    }

    final deurVleugels = <OpmetingRaamVleugel>[];

    void voegToe(Iterable<OpmetingRaamVleugel> vleugels) {
      for (final vleugel in vleugels) {
        if (!vleugel.isDeurVleugel) {
          continue;
        }

        if (deurVleugels.any((bestaand) => bestaand.id == vleugel.id)) {
          continue;
        }

        deurVleugels.add(vleugel);
      }
    }

    voegToe(data.vleugels);

    for (final lijst in data.vleugelsPerKader.values) {
      voegToe(lijst);
    }

    final regels = <String>[];

    if (deurVleugels.isNotEmpty) {
      regels.add(
        deurVleugels
            .map((vleugel) {
              return vleugel.deurVleugelSamenvatting;
            })
            .toSet()
            .join('\n'),
      );
    }

    final deurpanelenTekst =
        OpmetingDeurpaneelTekstHelper.samenvattingVoorToewijzingen(
          _deurpaneelToewijzingen,
        );

    if (deurpanelenTekst.trim().isNotEmpty) {
      regels.add(deurpanelenTekst);
    } else if (_actieveDeurpaneelKeuze != null) {
      regels.add(
        OpmetingDeurpaneelTekstHelper.samenvattingVoorKeuze(
          _actieveDeurpaneelKeuze!,
        ),
      );
    }

    return regels.where((regel) => regel.trim().isNotEmpty).join('\n');
  }

  void _herstelLegendaUitTekeningData(
    OpmetingOverzichtTekeningData data, {
    bool metSetState = false,
  }) {
    final nieuweOpvullingen = OpmetingRaamVullingHelper.bepaalLegenda(
      vulvlakken: data.vulvlakken,
      toewijzingen: data.vullingToewijzingen,
    );

    final nieuweKleinhouten = OpmetingRaamKleinhoutHelper.bepaalLegenda(
      vulvlakken: data.vulvlakken,
      kleinhouten: data.kleinhouten,
    );

    final opvullingenGelijk = _zijnOpvullingenGelijk(
      gekozenOpvullingen,
      nieuweOpvullingen,
    );

    final kleinhoutenGelijk = _zijnKleinhoutenGelijk(
      gekozenKleinhouten,
      nieuweKleinhouten,
    );

    if (opvullingenGelijk && kleinhoutenGelijk) {
      return;
    }

    void pasAan() {
      gekozenOpvullingen = List<OpmetingRaamVullingLegendaItem>.unmodifiable(
        nieuweOpvullingen,
      );
      gekozenKleinhouten = List<OpmetingRaamKleinhoutLegendaItem>.unmodifiable(
        nieuweKleinhouten,
      );
    }

    if (metSetState && mounted) {
      setState(pasAan);
    } else {
      pasAan();
    }
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

    _synchroniseerRaammaatVeldenMetSamenstelling(samenstelling);
  }

  int get raammaatBreedte {
    if (_kaderSamenstelling.kaders.length <= 1) {
      final waarde = _waarde(raammaatBreedteController).round();

      if (waarde > 0) {
        return waarde;
      }
    }

    return _berekenSamenstellingBreedte(_kaderSamenstelling);
  }

  int get raammaatHoogte {
    if (_kaderSamenstelling.kaders.length <= 1) {
      final waarde = _waarde(raammaatHoogteController).round();

      if (waarde > 0) {
        return waarde;
      }
    }

    return _berekenSamenstellingHoogte(_kaderSamenstelling);
  }

  int get verschilTablet {
    return OpmetingRaamMatenHelper.berekenVerschilTablet(
      binnenTabletController: binnenTabletController,
      buitenTabletController: buitenTabletController,
    );
  }

  String get _profielSamenvatting {
    final uitzagenTand = _waarde(uitzagenTandController).round();
    final buitensteProfiel = _waarde(buitensteLipController).round();

    return 'uitzagen tand $uitzagenTand mm buitenste profiel $buitensteProfiel mm';
  }

  int _positieveMaat(int waarde) {
    return waarde < 0 ? 0 : waarde;
  }

  int _berekenSamenstellingBreedte(OpmetingKaderSamenstelling samenstelling) {
    if (samenstelling.kaders.isEmpty) {
      return _waarde(raammaatBreedteController).round();
    }

    int? links;
    int? rechts;

    for (final kader in samenstelling.kaders) {
      links = links == null
          ? kader.linksMm
          : (kader.linksMm < links ? kader.linksMm : links);
      rechts = rechts == null
          ? kader.rechtsMm
          : (kader.rechtsMm > rechts ? kader.rechtsMm : rechts);
    }

    if (links == null || rechts == null) {
      return _waarde(raammaatBreedteController).round();
    }

    return rechts - links;
  }

  int _berekenSamenstellingHoogte(OpmetingKaderSamenstelling samenstelling) {
    if (samenstelling.kaders.isEmpty) {
      return _waarde(raammaatHoogteController).round();
    }

    int? boven;
    int? onder;

    for (final kader in samenstelling.kaders) {
      boven = boven == null
          ? kader.bovenMm
          : (kader.bovenMm < boven ? kader.bovenMm : boven);
      onder = onder == null
          ? kader.onderMm
          : (kader.onderMm > onder ? kader.onderMm : onder);
    }

    if (boven == null || onder == null) {
      return _waarde(raammaatHoogteController).round();
    }

    return onder - boven;
  }

  void _synchroniseerRaammaatVeldenMetSamenstelling(
    OpmetingKaderSamenstelling samenstelling,
  ) {
    _zetControllerTekst(
      raammaatBreedteController,
      _berekenSamenstellingBreedte(samenstelling),
    );
    _zetControllerTekst(
      raammaatHoogteController,
      _berekenSamenstellingHoogte(samenstelling),
    );
  }

  void _werkRaammaatVeldenBijUitDagmaat() {
    final nieuweRaammaatBreedte =
        _waarde(dagmaatBreedteController).round() +
        _waarde(slagLinksController).round() +
        _waarde(slagRechtsController).round();

    final nieuweRaammaatHoogte =
        _waarde(dagmaatHoogteController).round() +
        _waarde(slagBovenController).round() +
        _waarde(slagOnderController).round();

    _zetControllerTekst(raammaatBreedteController, nieuweRaammaatBreedte);
    _zetControllerTekst(raammaatHoogteController, nieuweRaammaatHoogte);
  }

  void _werkDagmaatVeldenBijUitRaammaat() {
    final nieuweDagmaatBreedte = _positieveMaat(
      _waarde(raammaatBreedteController).round() -
          _waarde(slagLinksController).round() -
          _waarde(slagRechtsController).round(),
    );

    final nieuweDagmaatHoogte = _positieveMaat(
      _waarde(raammaatHoogteController).round() -
          _waarde(slagBovenController).round() -
          _waarde(slagOnderController).round(),
    );

    _zetControllerTekst(dagmaatBreedteController, nieuweDagmaatBreedte);
    _zetControllerTekst(dagmaatHoogteController, nieuweDagmaatHoogte);
  }

  void _herberekenSamenstellingMetRaammaat({
    required int breedte,
    required int hoogte,
  }) {
    late final OpmetingKaderSamenstelling herberekendeSamenstelling;

    setState(() {
      herberekendeSamenstelling =
          OpmetingRaamMatenHelper.herberekenSamenstelling(
            huidigeSamenstelling: _kaderSamenstelling,
            raammaatBreedte: breedte,
            raammaatHoogte: hoogte,
            slagLinksController: slagLinksController,
            slagRechtsController: slagRechtsController,
            slagBovenController: slagBovenController,
            slagOnderController: slagOnderController,
          );

      _kaderSamenstelling = herberekendeSamenstelling;
    });

    _vulMaatveldenMetActiefKader(herberekendeSamenstelling);
  }

  void _herberekenVanDagmaat() {
    if (_isMaatveldLeeg(dagmaatBreedteController) ||
        _isMaatveldLeeg(dagmaatHoogteController) ||
        _isMaatveldNogTijdelijk(dagmaatBreedteController) ||
        _isMaatveldNogTijdelijk(dagmaatHoogteController)) {
      return;
    }

    if (_kaderSamenstelling.kaders.length <= 1) {
      _werkRaammaatVeldenBijUitDagmaat();
    }

    _herberekenSamenstellingMetRaammaat(
      breedte: raammaatBreedte,
      hoogte: raammaatHoogte,
    );
  }

  void _herberekenVanRaammaat() {
    if (_isMaatveldLeeg(raammaatBreedteController) ||
        _isMaatveldLeeg(raammaatHoogteController) ||
        _isMaatveldNogTijdelijk(raammaatBreedteController) ||
        _isMaatveldNogTijdelijk(raammaatHoogteController)) {
      return;
    }

    _werkDagmaatVeldenBijUitRaammaat();

    _herberekenSamenstellingMetRaammaat(
      breedte: raammaatBreedte,
      hoogte: raammaatHoogte,
    );
  }

  void _herbereken() {
    _herberekenVanDagmaat();
  }

  void _wijzigKaderSamenstelling(
    OpmetingKaderSamenstelling nieuweSamenstelling,
  ) {
    final herberekendeSamenstelling = nieuweSamenstelling.copyWith(
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

        case 'deurpanelen':
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
      final geladenMenus =
          await AppStorage.laadOpmetingRaamKeuzemenusVoorFormulier(
            _formulierType,
          );

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
      await AppStorage.bewaarOpmetingRaamKeuzemenusVoorFormulier(
        formulierType: _formulierType,
        menus: gesorteerdeMenus,
      );
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
    final gevondenOptie = menu.zoekOptie(optieId);

    if (gevondenOptie == null) {
      return;
    }

    final gekozenOptie = gevondenOptie;
    final padIds = menu.padIdsVoorOptie(gekozenOptie.id);

    setState(() {
      _actieveKeuzeSelecties[menu.id] = OpmetingRaamKeuzeSelectie(
        menuId: menu.id,
        optieId: gekozenOptie.id,
        padIds: padIds,
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
    final bewaardeOpmeting = await _bewaarHuidigeOpmeting();

    if (!mounted) {
      return;
    }

    Navigator.pop(context, bewaardeOpmeting);
  }

  Future<OpmetingOverzichtRaamItem> _bewaarHuidigeOpmeting() async {
    final opmeting = _maakOverzichtItem();

    late final OpmetingOverzichtRaamItem bewaardeOpmeting;

    if (widget.bestaandeOpmeting == null) {
      bewaardeOpmeting = await AppStorage.voegOpmetingToe(opmeting);
    } else {
      bewaardeOpmeting = await AppStorage.werkOpmetingBij(opmeting);
    }

    await OpmetingDeurpaneelToewijzingStorageHelper.bewaarVoorOpmetingId(
      opmetingId: bewaardeOpmeting.id,
      toewijzingen: _deurpaneelToewijzingen,
    );

    return bewaardeOpmeting;
  }

  Future<void> _vraagToevoegenAanOverzichtBijTerug() async {
    final keuze = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Opmeting toevoegen aan overzicht?',
            style: TextStyle(
              color: Color(0xFF0B7A3B),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Deze raamopmeting is nog niet toegevoegd aan het overzicht. Wilt u deze opmeting toevoegen?',
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0B7A3B),
              ),
              onPressed: () {
                Navigator.pop(context, 'niet_toevoegen');
              },
              child: const Text('Niet toevoegen'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0B7A3B),
              ),
              onPressed: () {
                Navigator.pop(context, 'verder_bewerken');
              },
              child: const Text('Verder bewerken'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B7A3B),
                foregroundColor: Colors.white,
              ),
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
      final bewaardeOpmeting = await _bewaarHuidigeOpmeting();

      if (!mounted) {
        return;
      }

      Navigator.pop(context, bewaardeOpmeting);
      return;
    }

    Navigator.pop(context);
  }

  Future<void> _vraagAnnulerenZonderToevoegen() async {
    final annuleren = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Opmeting annuleren?',
            style: TextStyle(
              color: Color(0xFF0B7A3B),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Wilt u deze opmeting annuleren zonder toe te voegen?',
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0B7A3B),
              ),
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Verder bewerken'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B7A3B),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Annuleren'),
            ),
          ],
        );
      },
    );

    if (!mounted || annuleren != true) {
      return;
    }

    Navigator.pop(context);
  }

  OpmetingOverzichtRaamItem _maakOverzichtItem() {
    final nieuweOpmeting = OpmetingRaamOverzichtBuilder.maak(
      klantNaam: widget.klantNaam?.trim() ?? '',
      formulierType: _formulierType,
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
      deurpaneelToewijzingen: _deurpaneelToewijzingen,
      notities: notitiesController.text.trim(),
    );

    final bestaandeOpmeting = widget.bestaandeOpmeting;

    if (bestaandeOpmeting == null) {
      return nieuweOpmeting;
    }

    return nieuweOpmeting.copyWith(
      id: bestaandeOpmeting.id,
      gewijzigdOp: bestaandeOpmeting.gewijzigdOp,
      isVerwijderd: bestaandeOpmeting.isVerwijderd,
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
      formulierTitel: _formulierTitel,
      toonDeurKnoppen: _isDeurFiche,
      deurVleugelSamenvatting: _isDeurFiche ? _deurVleugelSamenvatting : '',
      profielSamenvatting: _profielSamenvatting,
      onDeurVleugel: _openDeurVleugel,
      onDeurPanelen: _openDeurPanelen,
      onTerug: _vraagToevoegenAanOverzichtBijTerug,
      onToevoegen: _voegOpmetingToeAanOverzicht,
      onAnnuleren: _vraagAnnulerenZonderToevoegen,
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
      dagmatenVergrendeld: _kaderSamenstelling.kaders.length > 1,
      onMatenGewijzigd: _herbereken,
      onDagmaatGewijzigd: _herberekenVanDagmaat,
      onRaammaatGewijzigd: _herberekenVanRaammaat,
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
