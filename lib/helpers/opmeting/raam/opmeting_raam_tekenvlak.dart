import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../deurpanelen/opmeting_deurpaneel_actie_helper.dart';
import '../deurpanelen/opmeting_deurpaneel_actieve_keuze_controller.dart';
import '../deurpanelen/opmeting_deurpaneel_geometrie_helper.dart';
import '../deurpanelen/opmeting_deurpaneel_dxf_bibliotheek.dart';
import '../deurpanelen/opmeting_deurpaneel_teken_helper.dart';
import '../deurpanelen/opmeting_deurpaneel_toewijzing_model.dart';
import 'opmeting_raam_kleinhout_model.dart';
import 'opmeting_raam_model.dart';
import 'opmeting_raam_opvulling_model.dart';
import 'opmeting_raam_tekenvlak_controller.dart';
import 'opmeting_raam_tekenvlak_geschiedenis.dart';
import 'opmeting_raam_vulling_helper.dart';
import 'opmeting_raam_zwevende_menus_controller.dart';
import 'opmeting_raam_menu_overlay.dart';
import 'opmeting_raam_schaal_controller.dart';
import 'opmeting_raam_schaal_aanpassing_helper.dart';
import 'opmeting_raam_legenda_melding_controller.dart';
import 'opmeting_raam_tekening_opschoning_helper.dart';
import 'opmeting_raam_opvulling_laad_helper.dart';
import 'opmeting_raam_menu_zichtbaarheid_controller.dart';
import 'opmeting_raam_tstijl_verplaatsing_actie_helper.dart';
import 'opmeting_raam_opvulling_actie_helper.dart';
import 'opmeting_raam_kleinhout_actie_helper.dart';
import 'opmeting_raam_tstijl_actie_helper.dart';
import 'opmeting_raam_tstijl_helper.dart';
import 'opmeting_raam_vleugel_actie_helper.dart';
import 'opmeting_raam_vleugel_helper.dart';
import 'opmeting_raam_vlak_helper.dart';
import 'opmeting_raam_kleinhout_instellingen_helper.dart';
import 'opmeting_raam_kleinhout_helper.dart';
import 'opmeting_raam_tekenvlak_weergave_status_helper.dart';
import 'opmeting_raam_vulvlak_berekening_helper.dart';
import 'opmeting_raam_tekenvlak_tekenlaag.dart';
import 'opmeting_raam_tekenvlak_overzicht_data_helper.dart';
import 'opmeting_raam_tekenvlak_schaal_data_helper.dart';
import 'opmeting_raam_snackbar_helper.dart';
import 'opmeting_raam_tekenvlak_kader.dart';
import 'menus/opmeting_raam_kader_menus.dart';
import 'opmeting_raam_keuzemenu_model.dart';
import 'opmeting_raam_kader_helper.dart';
import 'opmeting_raam_technische_layout_helper.dart';
import '../kader_samenstelling/opmeting_kader_samenstelling_model.dart';
import '../kader_samenstelling/opmeting_kader_samenstelling_layout_helper.dart';
import '../kader_samenstelling/opmeting_kader_samenstelling_teken_helper.dart';
import '../overzicht/opmeting_overzicht_model.dart';

export 'opmeting_raam_tekenvlak_controller.dart';

class OpmetingRaamTekenvlak extends StatefulWidget {
  const OpmetingRaamTekenvlak({
    super.key,
    required this.breedteMm,
    required this.hoogteMm,
    required this.actieveTool,
    required this.vleugelMenuOpenSignaal,
    required this.positieController,
    this.tStijlMenuOpenSignaal = 0,
    this.opvullingMenuOpenSignaal = 0,
    this.kleinhoutMenuOpenSignaal = 0,
    this.controller,
    this.onOpvullingenGewijzigd,
    this.onKleinhoutenGewijzigd,
    this.kaderSamenstelling,
    this.onKaderSamenstellingGewijzigd,
    this.onGeselecteerdeKaderIdsGewijzigd,
    this.onOverzichtTekeningGewijzigd,
    this.beginTekeningData,
    this.technischeTekeningen =
        const <OpmetingRaamTechnischeTekeningInstelling>[],
    this.technischeTekeningenPerKader =
        const <String, List<OpmetingRaamTechnischeTekeningInstelling>>{},
    this.technischeTekeningenPerKaderGroep =
        const <String, List<OpmetingRaamTechnischeTekeningInstelling>>{},
    this.technischeKaderGroepen = const <String, Set<String>>{},
  });

  final int breedteMm;
  final int hoogteMm;
  final String actieveTool;

  final int vleugelMenuOpenSignaal;
  final int tStijlMenuOpenSignaal;
  final int opvullingMenuOpenSignaal;
  final int kleinhoutMenuOpenSignaal;

  final TextEditingController positieController;

  final OpmetingRaamTekenvlakController? controller;

  final ValueChanged<List<OpmetingRaamVullingLegendaItem>>?
  onOpvullingenGewijzigd;

  final ValueChanged<List<OpmetingRaamKleinhoutLegendaItem>>?
  onKleinhoutenGewijzigd;

  final OpmetingKaderSamenstelling? kaderSamenstelling;

  final ValueChanged<OpmetingKaderSamenstelling>? onKaderSamenstellingGewijzigd;

  final ValueChanged<Set<String>>? onGeselecteerdeKaderIdsGewijzigd;

  final ValueChanged<OpmetingOverzichtTekeningData>?
  onOverzichtTekeningGewijzigd;

  final OpmetingOverzichtTekeningData? beginTekeningData;

  final List<OpmetingRaamTechnischeTekeningInstelling> technischeTekeningen;

  final Map<String, List<OpmetingRaamTechnischeTekeningInstelling>>
  technischeTekeningenPerKader;

  final Map<String, List<OpmetingRaamTechnischeTekeningInstelling>>
  technischeTekeningenPerKaderGroep;

  final Map<String, Set<String>> technischeKaderGroepen;

  @override
  State<OpmetingRaamTekenvlak> createState() {
    return _OpmetingRaamTekenvlakState();
  }
}

class _OpmetingRaamTekenvlakState extends State<OpmetingRaamTekenvlak> {
  OpmetingRaamLijn? _geselecteerdeLijn;

  String _positieType = 'mm';

  OpmetingRaamVleugelType _geselecteerdVleugelType =
      OpmetingRaamVleugelType.enkelOpenRechts;

  final List<OpmetingRaamTStijl> _tStijlen = <OpmetingRaamTStijl>[];

  final List<OpmetingRaamVleugel> _vleugels = <OpmetingRaamVleugel>[];

  final List<OpmetingRaamOpvullingModel> _opvullingen =
      <OpmetingRaamOpvullingModel>[];

  final List<OpmetingRaamVullingToewijzing> _vullingToewijzingen =
      <OpmetingRaamVullingToewijzing>[];

  final Set<String> _geselecteerdeVulvlakIds = <String>{};

  final List<OpmetingRaamKleinhout> _kleinhouten = <OpmetingRaamKleinhout>[];

  final List<OpmetingDeurpaneelToewijzing> _deurpaneelToewijzingen =
      <OpmetingDeurpaneelToewijzing>[];

  final Set<String> _geselecteerdeKleinhoutVlakIds = <String>{};

  OpmetingRaamKleinhoutType _geselecteerdKleinhoutType =
      OpmetingRaamKleinhoutType.opGlasRecht;

  OpmetingRaamKleinhoutPatroon _geselecteerdKleinhoutPatroon =
      OpmetingRaamKleinhoutPatroon.bovenverdeling;

  final TextEditingController _kleinhoutHorizontaleHoogteController =
      TextEditingController(text: '500');

  final TextEditingController _kleinhoutAantalHorizontaalController =
      TextEditingController(text: '1');

  final TextEditingController _kleinhoutAantalVerticaalController =
      TextEditingController(text: '2');

  final OpmetingRaamTekenvlakGeschiedenis _geschiedenis =
      OpmetingRaamTekenvlakGeschiedenis(maximumAantalStappen: 50);

  final Map<String, List<OpmetingRaamTStijl>> _tStijlenPerKader =
      <String, List<OpmetingRaamTStijl>>{};

  final Map<String, List<OpmetingRaamVleugel>> _vleugelsPerKader =
      <String, List<OpmetingRaamVleugel>>{};

  final Map<String, List<OpmetingRaamVullingToewijzing>>
  _vullingToewijzingenPerKader =
      <String, List<OpmetingRaamVullingToewijzing>>{};

  final Map<String, Set<String>> _geselecteerdeVulvlakIdsPerKader =
      <String, Set<String>>{};

  final Map<String, List<OpmetingRaamKleinhout>> _kleinhoutenPerKader =
      <String, List<OpmetingRaamKleinhout>>{};

  final Map<String, Set<String>> _geselecteerdeKleinhoutVlakIdsPerKader =
      <String, Set<String>>{};

  String? _actiefTStijlKaderId;
  String? _actiefVleugelKaderId;
  String? _actiefOpvullingKaderId;
  String? _actiefKleinhoutKaderId;

  bool _kaderSelectieOnderdrukt = false;

  final Set<String> _geselecteerdeKaderIds = <String>{};

  String _laatsteOverzichtTekeningSignatuur = '';
  bool _deurpaneelToewijzingenUitControllerBijwerken = false;

  final TextEditingController _kaderBreedteController = TextEditingController();
  final TextEditingController _kaderHoogteController = TextEditingController();

  final FocusNode _kaderBreedteFocusNode = FocusNode();
  final FocusNode _kaderHoogteFocusNode = FocusNode();

  Timer? _kaderMaatAutoUpdateTimer;
  bool _kaderWijzigMenuGesloten = false;
  bool _kaderToevoegMenuGesloten = false;

  Offset _kaderMenuPositie = const Offset(24, 120);
  String? _laatsteKaderMenuKaderId;

  final TextEditingController _toevoegKaderBreedteController =
      TextEditingController(text: '300');
  final TextEditingController _toevoegKaderHoogteController =
      TextEditingController(text: '300');
  final TextEditingController _toevoegKaderVrijeOffsetController =
      TextEditingController(text: '0');

  final FocusNode _toevoegKaderBreedteFocusNode = FocusNode();
  final FocusNode _toevoegKaderHoogteFocusNode = FocusNode();
  final FocusNode _toevoegKaderVrijeOffsetFocusNode = FocusNode();

  Offset _kaderToevoegMenuPositie = const Offset(340, 120);
  String? _toevoegKaderId;
  String? _toevoegAnkerKaderId;
  OpmetingKaderZijde? _toevoegKaderZijde;
  OpmetingKaderUitlijning? _toevoegKaderUitlijning;
  OpmetingKaderUitlijning _toevoegKaderVrijeBasisUitlijning =
      OpmetingKaderUitlijning.begin;

  final OpmetingRaamZwevendeMenusController _zwevendeMenus =
      OpmetingRaamZwevendeMenusController();

  bool _opvullingenLaden = true;
  String? _geselecteerdeOpvullingId;

  final OpmetingRaamMenuZichtbaarheidController _menuZichtbaarheid =
      OpmetingRaamMenuZichtbaarheidController();

  final OpmetingRaamSchaalController _schaalController =
      OpmetingRaamSchaalController();

  late final OpmetingRaamLegendaMeldingController _legendaMeldingen;

  bool get _kanOngedaanMaken {
    return _geschiedenis.kanOngedaanMaken;
  }

  bool get _kanHerstellen {
    return _geschiedenis.kanHerstellen;
  }

  bool get _isTekenToolActief {
    return widget.actieveTool == 'tstijl' ||
        widget.actieveTool == 'vleugel' ||
        widget.actieveTool == 'deurvleugel' ||
        widget.actieveTool == 'deurpanelen' ||
        widget.actieveTool == 'opvulling' ||
        widget.actieveTool == 'kleinhout';
  }

  String? get _actiefKaderIdVoorWeergave {
    if (_bruikbareKaderSamenstelling == null) {
      return null;
    }

    if (_kaderSelectieOnderdrukt ||
        widget.actieveTool == 'opvulling' ||
        widget.actieveTool == 'kleinhout') {
      return '';
    }

    return widget.kaderSamenstelling?.actiefKaderId;
  }

  Set<String> get _gevuldeVlakIds {
    return _vullingToewijzingen.map((toewijzing) => toewijzing.vlakId).toSet();
  }

  void _laadBeginTekeningData() {
    OpmetingRaamTekenvlakOverzichtDataHelper.laadBeginTekeningData(
      data: widget.beginTekeningData,
      tStijlen: _tStijlen,
      tStijlenPerKader: _tStijlenPerKader,
      vleugels: _vleugels,
      vleugelsPerKader: _vleugelsPerKader,
      vullingToewijzingen: _vullingToewijzingen,
      vullingToewijzingenPerKader: _vullingToewijzingenPerKader,
      kleinhouten: _kleinhouten,
      kleinhoutenPerKader: _kleinhoutenPerKader,
    );
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

  void _verwerkDeurpaneelToewijzingenUitController() {
    if (_deurpaneelToewijzingenUitControllerBijwerken) {
      return;
    }

    final nieuweToewijzingen =
        OpmetingDeurpaneelActieveKeuzeController.toewijzingen.value;

    if (_zijnDeurpaneelToewijzingenGelijk(
      _deurpaneelToewijzingen,
      nieuweToewijzingen,
    )) {
      return;
    }

    if (!mounted) {
      _deurpaneelToewijzingen
        ..clear()
        ..addAll(nieuweToewijzingen);
      return;
    }

    setState(() {
      _deurpaneelToewijzingen
        ..clear()
        ..addAll(nieuweToewijzingen);
    });
  }

  void _werkDeurpaneelControllerBij() {
    _deurpaneelToewijzingenUitControllerBijwerken = true;
    OpmetingDeurpaneelActieveKeuzeController.werkToewijzingenBij(
      _deurpaneelToewijzingen,
    );
    _deurpaneelToewijzingenUitControllerBijwerken = false;
  }

  void _verwerkDxfBibliotheekWijziging() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _laadBeginTekeningData();
    _verwerkDeurpaneelToewijzingenUitController();
    OpmetingDeurpaneelActieveKeuzeController.toewijzingen.addListener(
      _verwerkDeurpaneelToewijzingenUitController,
    );
    OpmetingDeurpaneelDxfBibliotheek.versie.addListener(
      _verwerkDxfBibliotheekWijziging,
    );
    unawaited(OpmetingDeurpaneelDxfBibliotheek.laad());

    _legendaMeldingen = OpmetingRaamLegendaMeldingController(
      isMounted: () => mounted,
      actueleTekenvlakGrootte: _actueleTekenvlakGrootte,
      bepaalVulvlakken: _bepaalVulvlakken,
      vullingToewijzingen: () => _vullingToewijzingen,
      kleinhouten: () => _kleinhouten,
      opvullingCallback: () => widget.onOpvullingenGewijzigd,
      kleinhoutCallback: () => widget.onKleinhoutenGewijzigd,
    );

    _schaalController.initialiseer(
      breedteMm: widget.breedteMm,
      hoogteMm: widget.hoogteMm,
    );

    _actiefTStijlKaderId = 'basis';
    _actiefVleugelKaderId = 'basis';
    _actiefOpvullingKaderId = 'basis';
    _actiefKleinhoutKaderId = 'basis';

    _koppelController(widget.controller);
    _laadOpvullingen();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _zwevendeMenus.toonOverlay();
    });
  }

  @override
  void didUpdateWidget(covariant OpmetingRaamTekenvlak oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller?.ontkoppel(eigenaar: this);
      _koppelController(widget.controller);
    }

    _verwerkToolWijziging(oldWidget);
    _verwerkMenuOpenSignalen(oldWidget);
    _verwerkKaderSamenstellingWijziging(oldWidget);

    _schaalController.werkMatenBij(
      breedteMm: _bruikbareKaderSamenstelling == null
          ? widget.breedteMm
          : _effectieveBreedteMm,
      hoogteMm: _bruikbareKaderSamenstelling == null
          ? widget.hoogteMm
          : _effectieveHoogteMm,
      onAanpassen: _voerVolledigeSchaalAanpassingUit,
    );
  }

  @override
  void dispose() {
    OpmetingDeurpaneelActieveKeuzeController.toewijzingen.removeListener(
      _verwerkDeurpaneelToewijzingenUitController,
    );
    OpmetingDeurpaneelDxfBibliotheek.versie.removeListener(
      _verwerkDxfBibliotheekWijziging,
    );

    _schaalController.dispose();

    widget.controller?.ontkoppel(eigenaar: this);

    _kleinhoutHorizontaleHoogteController.dispose();
    _kleinhoutAantalHorizontaalController.dispose();
    _kleinhoutAantalVerticaalController.dispose();

    _kaderMaatAutoUpdateTimer?.cancel();
    _kaderBreedteController.dispose();
    _kaderHoogteController.dispose();
    _kaderBreedteFocusNode.dispose();
    _kaderHoogteFocusNode.dispose();

    _toevoegKaderBreedteController.dispose();
    _toevoegKaderHoogteController.dispose();
    _toevoegKaderVrijeOffsetController.dispose();
    _toevoegKaderBreedteFocusNode.dispose();
    _toevoegKaderHoogteFocusNode.dispose();
    _toevoegKaderVrijeOffsetFocusNode.dispose();

    super.dispose();
  }

  void _koppelController(OpmetingRaamTekenvlakController? controller) {
    controller?.koppel(
      eigenaar: this,
      onOngedaanMaken: _ongedaanMaken,
      onHerstellen: _herstellen,
      kanOngedaanMaken: _kanOngedaanMaken,
      kanHerstellen: _kanHerstellen,
    );
  }

  void _werkGeschiedenisStatusBij() {
    widget.controller?.werkStatusBij(
      eigenaar: this,
      kanOngedaanMaken: _kanOngedaanMaken,
      kanHerstellen: _kanHerstellen,
    );
  }

  void _wisTekeningSelecties() {
    _geselecteerdeLijn = null;
    _geselecteerdeVulvlakIds.clear();
    _geselecteerdeKleinhoutVlakIds.clear();
  }

  void _vervangVulvlakSelectie(Iterable<String> vlakIds) {
    _geselecteerdeVulvlakIds
      ..clear()
      ..addAll(vlakIds);
  }

  void _vervangKleinhoutVlakSelectie(Iterable<String> vlakIds) {
    _geselecteerdeKleinhoutVlakIds
      ..clear()
      ..addAll(vlakIds);
  }

  void _vervangTStijlen(Iterable<OpmetingRaamTStijl> tStijlen) {
    _tStijlen
      ..clear()
      ..addAll(tStijlen);
  }

  void _vervangVleugels(Iterable<OpmetingRaamVleugel> vleugels) {
    _vleugels
      ..clear()
      ..addAll(vleugels);
  }

  void _vervangVullingToewijzingen(
    Iterable<OpmetingRaamVullingToewijzing> toewijzingen,
  ) {
    _vullingToewijzingen
      ..clear()
      ..addAll(toewijzingen);
  }

  void _vervangKleinhouten(Iterable<OpmetingRaamKleinhout> kleinhouten) {
    _kleinhouten
      ..clear()
      ..addAll(kleinhouten);
  }

  void _planAlleLegendaMeldingen() {
    _legendaMeldingen.planOpvullingMelding();
    _legendaMeldingen.planKleinhoutMelding();
  }

  void _vervangVolledigeTekening({
    required Iterable<OpmetingRaamTStijl> tStijlen,
    required Iterable<OpmetingRaamVleugel> vleugels,
    required Iterable<OpmetingRaamVullingToewijzing> vullingToewijzingen,
    required Iterable<OpmetingRaamKleinhout> kleinhouten,
  }) {
    _vervangTStijlen(tStijlen);
    _vervangVleugels(vleugels);
    _vervangVullingToewijzingen(vullingToewijzingen);
    _vervangKleinhouten(kleinhouten);
  }

  OpmetingRaamTekeningMoment _maakGeschiedenisMoment() {
    return OpmetingRaamTekeningMoment(
      tStijlen: List<OpmetingRaamTStijl>.unmodifiable(_tStijlen),
      vleugels: List<OpmetingRaamVleugel>.unmodifiable(_vleugels),
      vullingToewijzingen: List<OpmetingRaamVullingToewijzing>.unmodifiable(
        _vullingToewijzingen,
      ),
      kleinhouten: List<OpmetingRaamKleinhout>.unmodifiable(_kleinhouten),
    );
  }

  void _bewaarVoorWijziging() {
    _geschiedenis.bewaarVoorWijziging(_maakGeschiedenisMoment());
    _werkGeschiedenisStatusBij();
  }

  void _wisGeschiedenis() {
    if (!_geschiedenis.heeftGeschiedenis) {
      return;
    }

    _geschiedenis.wis();
    _werkGeschiedenisStatusBij();
  }

  void _pasGeschiedenisMomentToe(OpmetingRaamTekeningMoment? moment) {
    if (moment == null) {
      return;
    }

    setState(() {
      _herstelTekeningMoment(moment);
    });

    _werkGeschiedenisStatusBij();
    _planAlleLegendaMeldingen();
  }

  void _ongedaanMaken() {
    final vorigMoment = _geschiedenis.ongedaanMaken(
      huidigMoment: _maakGeschiedenisMoment(),
    );

    _pasGeschiedenisMomentToe(vorigMoment);
  }

  void _herstellen() {
    final volgendMoment = _geschiedenis.herstellen(
      huidigMoment: _maakGeschiedenisMoment(),
    );

    _pasGeschiedenisMomentToe(volgendMoment);
  }

  void _herstelTekeningMoment(OpmetingRaamTekeningMoment moment) {
    _vervangVolledigeTekening(
      tStijlen: moment.tStijlen,
      vleugels: moment.vleugels,
      vullingToewijzingen: moment.vullingToewijzingen,
      kleinhouten: moment.kleinhouten,
    );

    _wisTekeningSelecties();
    _schoonVullingEnKleinhoutenOp();
  }

  Future<void> _laadOpvullingen() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _opvullingenLaden = true;
    });

    final resultaat = await OpmetingRaamOpvullingLaadHelper.laad(
      huidigeGeselecteerdeOpvullingId: _geselecteerdeOpvullingId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      if (resultaat != null) {
        _opvullingen
          ..clear()
          ..addAll(resultaat.opvullingen);

        _geselecteerdeOpvullingId = resultaat.geselecteerdeOpvullingId;
      }

      _opvullingenLaden = false;
    });
  }

  void _verwerkToolWijziging(OpmetingRaamTekenvlak oldWidget) {
    if (oldWidget.actieveTool == widget.actieveTool) {
      return;
    }

    _geselecteerdeLijn = null;

    if (widget.actieveTool == 'kader') {
      _kaderWijzigMenuGesloten = false;
    }

    if (widget.actieveTool == 'kadertoevoegen') {
      _kaderToevoegMenuGesloten = false;
    }

    if (_isTekenToolActief) {
      _kaderSelectieOnderdrukt = true;
    }

    if (widget.actieveTool != 'opvulling') {
      _geselecteerdeVulvlakIds.clear();
      _geselecteerdeVulvlakIdsPerKader.clear();
    }

    if (widget.actieveTool != 'kleinhout') {
      _geselecteerdeKleinhoutVlakIds.clear();
      _geselecteerdeKleinhoutVlakIdsPerKader.clear();
    }

    final opvullingenLaden = _menuZichtbaarheid.verwerkToolWijziging(
      oudeTool: oldWidget.actieveTool,
      nieuweTool: widget.actieveTool,
    );

    if (opvullingenLaden) {
      _laadOpvullingen();
    }
  }

  void _verwerkMenuOpenSignalen(OpmetingRaamTekenvlak oldWidget) {
    final opvullingenLaden = _menuZichtbaarheid.verwerkMenuOpenSignalen(
      actieveTool: widget.actieveTool,
      oudVleugelSignaal: oldWidget.vleugelMenuOpenSignaal,
      nieuwVleugelSignaal: widget.vleugelMenuOpenSignaal,
      oudTStijlSignaal: oldWidget.tStijlMenuOpenSignaal,
      nieuwTStijlSignaal: widget.tStijlMenuOpenSignaal,
      oudOpvullingSignaal: oldWidget.opvullingMenuOpenSignaal,
      nieuwOpvullingSignaal: widget.opvullingMenuOpenSignaal,
      oudKleinhoutSignaal: oldWidget.kleinhoutMenuOpenSignaal,
      nieuwKleinhoutSignaal: widget.kleinhoutMenuOpenSignaal,
    );

    if (opvullingenLaden) {
      _laadOpvullingen();
    }
  }

  void _verwerkKaderSamenstellingWijziging(OpmetingRaamTekenvlak oldWidget) {
    final samenstelling = _bruikbareKaderSamenstelling;

    if (samenstelling == null || samenstelling.kaders.isEmpty) {
      if (_actiefTStijlKaderId != 'basis' ||
          _actiefVleugelKaderId != 'basis' ||
          _actiefOpvullingKaderId != 'basis' ||
          _actiefKleinhoutKaderId != 'basis') {
        _actiefTStijlKaderId = 'basis';
        _actiefVleugelKaderId = 'basis';
        _actiefOpvullingKaderId = 'basis';
        _actiefKleinhoutKaderId = 'basis';
        _wisTekeningSelecties();
      }

      return;
    }

    final geldigeKaderIds = samenstelling.kaders
        .map((kader) => kader.id)
        .where((id) => id.trim().isNotEmpty)
        .toSet();

    if (geldigeKaderIds.isEmpty) {
      return;
    }

    _normaliseerTStijlBasisKader();
    _normaliseerVleugelBasisKader();

    final huidigeTStijlKaderId = _huidigTStijlKaderId;
    final huidigeVleugelKaderId = _huidigVleugelKaderId;

    if (geldigeKaderIds.contains(huidigeTStijlKaderId)) {
      _tStijlenPerKader[huidigeTStijlKaderId] =
          List<OpmetingRaamTStijl>.unmodifiable(_tStijlen);
    }

    if (geldigeKaderIds.contains(huidigeVleugelKaderId)) {
      _vleugelsPerKader[huidigeVleugelKaderId] =
          List<OpmetingRaamVleugel>.unmodifiable(_vleugels);
    }

    if (geldigeKaderIds.contains(_huidigOpvullingKaderId)) {
      _bewaarOpvullingVoorActiefKader();
    }

    if (geldigeKaderIds.contains(_huidigKleinhoutKaderId)) {
      _bewaarKleinhoutenVoorActiefKader();
    }

    _schaalKaderDataBijMaatwijzigingen(
      oudeSamenstelling: _bruikbareSamenstellingVan(
        oldWidget.kaderSamenstelling,
      ),
      nieuweSamenstelling: samenstelling,
    );

    _verwijderDataVanNietBestaandeKaders(geldigeKaderIds);

    final nieuwActiefKaderId =
        geldigeKaderIds.contains(samenstelling.actiefKaderId)
        ? samenstelling.actiefKaderId
        : samenstelling.kaders.first.id;

    _geselecteerdeKaderIds.removeWhere((id) => !geldigeKaderIds.contains(id));

    if (_geselecteerdeKaderIds.isEmpty) {
      _geselecteerdeKaderIds.add(nieuwActiefKaderId);
    }

    _actiefTStijlKaderId = nieuwActiefKaderId;
    _actiefVleugelKaderId = nieuwActiefKaderId;

    if (!geldigeKaderIds.contains(_huidigOpvullingKaderId)) {
      _actiefOpvullingKaderId = nieuwActiefKaderId;
      _laadOpvullingVoorKader(nieuwActiefKaderId);
    }

    if (!geldigeKaderIds.contains(_huidigKleinhoutKaderId)) {
      _actiefKleinhoutKaderId = nieuwActiefKaderId;
      _laadKleinhoutenVoorKader(nieuwActiefKaderId);
    }

    _laadTStijlenVoorKader(nieuwActiefKaderId);
    _laadVleugelsVoorKader(nieuwActiefKaderId);
  }

  OpmetingKaderSamenstelling? _bruikbareSamenstellingVan(
    OpmetingKaderSamenstelling? samenstelling,
  ) {
    if (samenstelling == null) {
      return null;
    }

    if (samenstelling.kaders.isEmpty) {
      return null;
    }

    return samenstelling;
  }

  void _schaalKaderDataBijMaatwijzigingen({
    required OpmetingKaderSamenstelling? oudeSamenstelling,
    required OpmetingKaderSamenstelling nieuweSamenstelling,
  }) {
    OpmetingRaamTekenvlakSchaalDataHelper.schaalKaderDataBijMaatwijzigingen(
      oudeSamenstelling: oudeSamenstelling,
      nieuweSamenstelling: nieuweSamenstelling,
      size: _actueleTekenvlakGrootte(),
      tStijlenPerKader: _tStijlenPerKader,
      vleugelsPerKader: _vleugelsPerKader,
    );
  }

  void _verwijderDataVanNietBestaandeKaders(Set<String> geldigeKaderIds) {
    bool isOngeldig(String kaderId) {
      return kaderId != 'basis' && !geldigeKaderIds.contains(kaderId);
    }

    _tStijlenPerKader.removeWhere((kaderId, _) => isOngeldig(kaderId));
    _vleugelsPerKader.removeWhere((kaderId, _) => isOngeldig(kaderId));
    _vullingToewijzingenPerKader.removeWhere(
      (kaderId, _) => isOngeldig(kaderId),
    );
    _geselecteerdeVulvlakIdsPerKader.removeWhere(
      (kaderId, _) => isOngeldig(kaderId),
    );
    _kleinhoutenPerKader.removeWhere((kaderId, _) => isOngeldig(kaderId));
    _geselecteerdeKleinhoutVlakIdsPerKader.removeWhere(
      (kaderId, _) => isOngeldig(kaderId),
    );
  }

  void _registreerTekenvlakGrootte(Size size) {
    _schaalController.registreerTekenvlakGrootte(
      size: size,
      breedteMm: _bruikbareKaderSamenstelling == null
          ? widget.breedteMm
          : _effectieveBreedteMm,
      hoogteMm: _bruikbareKaderSamenstelling == null
          ? widget.hoogteMm
          : _effectieveHoogteMm,
      onAanpassen: _voerVolledigeSchaalAanpassingUit,
    );
  }

  void _voerVolledigeSchaalAanpassingUit() {
    if (!mounted) {
      return;
    }

    final wijziging = _schaalController.huidigeWijziging;

    if (wijziging == null) {
      return;
    }

    final samenstelling = _bruikbareKaderSamenstelling;
    final heeftMeerdereKaders = (samenstelling?.kaders.length ?? 0) > 1;

    // Bij meerdere kaders wordt de samenstelling zelf via de kaderlayout
    // getransformeerd. Bij één kader moet de opgeslagen tekening wél mee
    // schalen met het actuele tekenvlak, anders blijft een deurvleugel op
    // oude canvas-pixels staan na schermrotatie of venstergrootte wijzigen.
    if (heeftMeerdereKaders) {
      _schaalController.bevestigWijziging(wijziging);
      return;
    }

    final oudeVleugelsVoorSchaal = List<OpmetingRaamVleugel>.from(_vleugels);

    final resultaat = OpmetingRaamSchaalAanpassingHelper.bereken(
      wijziging: wijziging,
      bestaandeTStijlen: _tStijlen,
      bestaandeVleugels: _vleugels,
      bestaandeVullingToewijzingen: _vullingToewijzingen,
      bestaandeKleinhouten: _kleinhouten,
    );

    if (resultaat == null) {
      return;
    }

    final geschaaldeVleugels = _herstelDeurVleugelGegevensNaSchaal(
      oudeVleugels: oudeVleugelsVoorSchaal,
      nieuweVleugels: resultaat.vleugels,
    );

    setState(() {
      _vervangVolledigeTekening(
        tStijlen: resultaat.tStijlen,
        vleugels: geschaaldeVleugels,
        vullingToewijzingen: resultaat.vullingToewijzingen,
        kleinhouten: resultaat.kleinhouten,
      );

      if (samenstelling != null) {
        _bewaarTStijlenVoorActiefKader();
        _bewaarVleugelsVoorActiefKader();
      }

      _wisTekeningSelecties();
    });

    _schaalController.bevestigWijziging(wijziging);

    _wisGeschiedenis();
    _planAlleLegendaMeldingen();
  }

  List<OpmetingRaamVleugel> _herstelDeurVleugelGegevensNaSchaal({
    required List<OpmetingRaamVleugel> oudeVleugels,
    required List<OpmetingRaamVleugel> nieuweVleugels,
  }) {
    if (oudeVleugels.isEmpty || nieuweVleugels.isEmpty) {
      return nieuweVleugels;
    }

    final oudeVleugelPerId = <String, OpmetingRaamVleugel>{
      for (final vleugel in oudeVleugels) vleugel.id: vleugel,
    };

    final nieuweVleugelPerId = <String, OpmetingRaamVleugel>{
      for (final vleugel in nieuweVleugels) vleugel.id: vleugel,
    };

    bool zelfdeGroep(OpmetingRaamVleugel eerste, OpmetingRaamVleugel tweede) {
      final eersteGroep = eerste.deurVleugelGroepId.trim();
      final tweedeGroep = tweede.deurVleugelGroepId.trim();

      if (eersteGroep.isNotEmpty || tweedeGroep.isNotEmpty) {
        return eersteGroep.isNotEmpty && eersteGroep == tweedeGroep;
      }

      return eerste.id == tweede.id;
    }

    Rect groepRectVanNieuweVleugels(List<OpmetingRaamVleugel> oudeGroep) {
      Rect? rect;

      for (final oudeVleugel in oudeGroep) {
        final nieuweVleugel = nieuweVleugelPerId[oudeVleugel.id];

        if (nieuweVleugel == null) {
          continue;
        }

        rect = rect == null
            ? nieuweVleugel.vlak
            : rect!.expandToInclude(nieuweVleugel.vlak);
      }

      return rect ?? oudeGroep.first.vlak;
    }

    double splitXVoorDubbeleDeur({
      required Rect groepVlak,
      required OpmetingRaamVleugel basisVleugel,
    }) {
      if (groepVlak.width <= 0) {
        return groepVlak.center.dx;
      }

      final size = _actueleTekenvlakGrootte();
      double schaalX = 0;

      if (size != null && _effectieveBreedteMm > 0) {
        final buitenKader = OpmetingRaamKaderHelper.buitenKader(
          size: size,
          breedteMm: _effectieveBreedteMm,
          hoogteMm: _effectieveHoogteMm,
        );

        if (buitenKader.width > 0) {
          schaalX = buitenKader.width / _effectieveBreedteMm;
        }
      }

      if (schaalX <= 0 || !schaalX.isFinite) {
        schaalX = groepVlak.width / 1000;
      }

      final verschuivingPx =
          basisVleugel.deurVleugelMiddenVerschuivingMm * schaalX;

      final minimaleVleugelBreedte = groepVlak.width * 0.22;

      return (groepVlak.center.dx + verschuivingPx)
          .clamp(
            groepVlak.left + minimaleVleugelBreedte,
            groepVlak.right - minimaleVleugelBreedte,
          )
          .toDouble();
    }

    final resultaat = <OpmetingRaamVleugel>[];
    final verwerkteDubbeleDeurGroepen = <String>{};

    for (final nieuweVleugel in nieuweVleugels) {
      final oudeVleugel = oudeVleugelPerId[nieuweVleugel.id];

      if (oudeVleugel == null || !oudeVleugel.isDeurVleugel) {
        resultaat.add(nieuweVleugel);
        continue;
      }

      if (!oudeVleugel.isDubbeleDeurVleugel) {
        resultaat.add(oudeVleugel.copyWith(vlak: nieuweVleugel.vlak));
        continue;
      }

      final groepSleutel = oudeVleugel.deurVleugelGroepId.trim().isEmpty
          ? oudeVleugel.id
          : oudeVleugel.deurVleugelGroepId.trim();

      if (!verwerkteDubbeleDeurGroepen.add(groepSleutel)) {
        continue;
      }

      final oudeGroep = oudeVleugels.where((vleugel) {
        return vleugel.isDeurVleugel &&
            vleugel.isDubbeleDeurVleugel &&
            zelfdeGroep(vleugel, oudeVleugel);
      }).toList();

      if (oudeGroep.length < 2) {
        resultaat.add(oudeVleugel.copyWith(vlak: nieuweVleugel.vlak));
        continue;
      }

      final groepVlak = groepRectVanNieuweVleugels(oudeGroep);

      if (groepVlak.width <= 24 || groepVlak.height <= 24) {
        for (final oudeDeel in oudeGroep) {
          final nieuwDeel = nieuweVleugelPerId[oudeDeel.id];

          if (nieuwDeel == null) {
            continue;
          }

          resultaat.add(oudeDeel.copyWith(vlak: nieuwDeel.vlak));
        }

        continue;
      }

      final splitX = splitXVoorDubbeleDeur(
        groepVlak: groepVlak,
        basisVleugel: oudeVleugel,
      );

      final linksVlak = Rect.fromLTRB(
        groepVlak.left,
        groepVlak.top,
        splitX,
        groepVlak.bottom,
      );

      final rechtsVlak = Rect.fromLTRB(
        splitX,
        groepVlak.top,
        groepVlak.right,
        groepVlak.bottom,
      );

      for (final oudeDeel in oudeGroep) {
        final deelVlak =
            oudeDeel.deurVleugelDeel == OpmetingRaamDeurVleugelDeel.links
            ? linksVlak
            : rechtsVlak;

        resultaat.add(oudeDeel.copyWith(vlak: deelVlak));
      }
    }

    return resultaat;
  }

  Size? _actueleTekenvlakGrootte() {
    return _schaalController.actueleTekenvlakGrootte;
  }

  OpmetingKaderSamenstelling? get _bruikbareKaderSamenstelling {
    final samenstelling = widget.kaderSamenstelling;

    if (samenstelling == null) {
      return null;
    }

    if (samenstelling.kaders.isEmpty) {
      return null;
    }

    return samenstelling;
  }

  OpmetingKaderSamenstellingLayoutResultaat? get _kaderSamenstellingLayout {
    final samenstelling = _bruikbareKaderSamenstelling;

    if (samenstelling == null) {
      return null;
    }

    return OpmetingKaderSamenstellingLayoutHelper.bereken(
      kaders: samenstelling.kaders,
    );
  }

  int get _effectieveBreedteMm {
    return _kaderSamenstellingLayout?.breedteMm ?? widget.breedteMm;
  }

  int get _effectieveHoogteMm {
    return _kaderSamenstellingLayout?.hoogteMm ?? widget.hoogteMm;
  }

  Rect _totaleKaderSamenstellingRect(Size size) {
    return OpmetingRaamKaderHelper.buitenKader(
      size: size,
      breedteMm: _effectieveBreedteMm,
      hoogteMm: _effectieveHoogteMm,
    );
  }

  Rect _werkRectVoorKader({
    required Size size,
    required OpmetingKaderDeel kader,
  }) {
    return OpmetingRaamKaderHelper.buitenKader(
      size: size,
      breedteMm: kader.breedteMm,
      hoogteMm: kader.hoogteMm,
    );
  }

  OpmetingKaderDeel? _zoekKaderVoorId(String kaderId) {
    final samenstelling = _bruikbareKaderSamenstelling;

    if (samenstelling == null) {
      return null;
    }

    for (final kader in samenstelling.kaders) {
      if (kader.id == kaderId) {
        return kader;
      }
    }

    return null;
  }

  OpmetingKaderDeel? get _actiefTStijlKader {
    return _zoekKaderVoorId(_huidigTStijlKaderId);
  }

  int get _actiefTStijlBreedteMm {
    return _actiefTStijlKader?.breedteMm ?? widget.breedteMm;
  }

  int get _actiefTStijlHoogteMm {
    return _actiefTStijlKader?.hoogteMm ?? widget.hoogteMm;
  }

  OpmetingKaderDeel? get _actiefVleugelKader {
    return _zoekKaderVoorId(_huidigVleugelKaderId);
  }

  int get _actiefVleugelBreedteMm {
    return _actiefVleugelKader?.breedteMm ?? widget.breedteMm;
  }

  int get _actiefVleugelHoogteMm {
    return _actiefVleugelKader?.hoogteMm ?? widget.hoogteMm;
  }

  int get _actiefWerkBreedteMm {
    if (widget.actieveTool == 'vleugel' ||
        widget.actieveTool == 'deurvleugel') {
      return _actiefVleugelBreedteMm;
    }

    if (widget.actieveTool == 'tstijl') {
      return _actiefTStijlBreedteMm;
    }

    return widget.breedteMm;
  }

  int get _actiefWerkHoogteMm {
    if (widget.actieveTool == 'vleugel' ||
        widget.actieveTool == 'deurvleugel') {
      return _actiefVleugelHoogteMm;
    }

    if (widget.actieveTool == 'tstijl') {
      return _actiefTStijlHoogteMm;
    }

    return widget.hoogteMm;
  }

  Map<String, List<OpmetingRaamTStijl>> _tStijlenPerKaderVoorWeergave() {
    return OpmetingRaamTekenvlakOverzichtDataHelper.lijstMapVoorWeergave(
      heeftSamenstelling: _bruikbareKaderSamenstelling != null,
      bewaardePerKader: _tStijlenPerKader,
      actieveKaderId: _huidigTStijlKaderId,
      actieveLijst: _tStijlen,
    );
  }

  Map<String, List<OpmetingRaamVleugel>> _vleugelsPerKaderVoorWeergave() {
    return OpmetingRaamTekenvlakOverzichtDataHelper.lijstMapVoorWeergave(
      heeftSamenstelling: _bruikbareKaderSamenstelling != null,
      bewaardePerKader: _vleugelsPerKader,
      actieveKaderId: _huidigVleugelKaderId,
      actieveLijst: _vleugels,
    );
  }

  Map<String, List<OpmetingRaamVullingToewijzing>>
  _vullingToewijzingenPerKaderVoorWeergave() {
    return OpmetingRaamTekenvlakOverzichtDataHelper.lijstMapVoorWeergave(
      heeftSamenstelling: _bruikbareKaderSamenstelling != null,
      bewaardePerKader: _vullingToewijzingenPerKader,
    );
  }

  Map<String, Set<String>> _geselecteerdeVulvlakIdsPerKaderVoorWeergave() {
    return OpmetingRaamTekenvlakOverzichtDataHelper.setMapVoorWeergave(
      heeftSamenstelling: _bruikbareKaderSamenstelling != null,
      bewaardePerKader: _geselecteerdeVulvlakIdsPerKader,
    );
  }

  Map<String, List<OpmetingRaamKleinhout>> _kleinhoutenPerKaderVoorWeergave() {
    return OpmetingRaamTekenvlakOverzichtDataHelper.lijstMapVoorWeergave(
      heeftSamenstelling: _bruikbareKaderSamenstelling != null,
      bewaardePerKader: _kleinhoutenPerKader,
    );
  }

  Map<String, Set<String>>
  _geselecteerdeKleinhoutVlakIdsPerKaderVoorWeergave() {
    return OpmetingRaamTekenvlakOverzichtDataHelper.setMapVoorWeergave(
      heeftSamenstelling: _bruikbareKaderSamenstelling != null,
      bewaardePerKader: _geselecteerdeKleinhoutVlakIdsPerKader,
    );
  }

  String get _huidigOpvullingKaderId {
    final samenstelling = _bruikbareKaderSamenstelling;

    if (_actiefOpvullingKaderId != null && _actiefOpvullingKaderId != 'basis') {
      return _actiefOpvullingKaderId!;
    }

    if (samenstelling != null && samenstelling.kaders.isNotEmpty) {
      return samenstelling.kaders.first.id;
    }

    return 'basis';
  }

  String get _huidigKleinhoutKaderId {
    final samenstelling = _bruikbareKaderSamenstelling;

    if (_actiefKleinhoutKaderId != null && _actiefKleinhoutKaderId != 'basis') {
      return _actiefKleinhoutKaderId!;
    }

    if (samenstelling != null && samenstelling.kaders.isNotEmpty) {
      return samenstelling.kaders.first.id;
    }

    return 'basis';
  }

  String get _huidigTStijlKaderId {
    final samenstelling = _bruikbareKaderSamenstelling;

    if (_actiefTStijlKaderId != null && _actiefTStijlKaderId != 'basis') {
      return _actiefTStijlKaderId!;
    }

    if (samenstelling != null && samenstelling.kaders.isNotEmpty) {
      return samenstelling.kaders.first.id;
    }

    return 'basis';
  }

  String get _huidigVleugelKaderId {
    final samenstelling = _bruikbareKaderSamenstelling;

    if (_actiefVleugelKaderId != null && _actiefVleugelKaderId != 'basis') {
      return _actiefVleugelKaderId!;
    }

    if (samenstelling != null && samenstelling.kaders.isNotEmpty) {
      return samenstelling.kaders.first.id;
    }

    return 'basis';
  }

  void _normaliseerTStijlBasisKader() {
    final samenstelling = _bruikbareKaderSamenstelling;

    if (samenstelling == null || samenstelling.kaders.isEmpty) {
      return;
    }

    final eersteKaderId = samenstelling.kaders.first.id;
    final oudeBasisTStijlen = _tStijlenPerKader.remove('basis');

    if (oudeBasisTStijlen != null &&
        !_tStijlenPerKader.containsKey(eersteKaderId)) {
      _tStijlenPerKader[eersteKaderId] = List<OpmetingRaamTStijl>.unmodifiable(
        oudeBasisTStijlen,
      );
    }

    if (_actiefTStijlKaderId == null || _actiefTStijlKaderId == 'basis') {
      _actiefTStijlKaderId = eersteKaderId;
    }
  }

  void _normaliseerVleugelBasisKader() {
    final samenstelling = _bruikbareKaderSamenstelling;

    if (samenstelling == null || samenstelling.kaders.isEmpty) {
      return;
    }

    final eersteKaderId = samenstelling.kaders.first.id;
    final oudeBasisVleugels = _vleugelsPerKader.remove('basis');

    if (oudeBasisVleugels != null &&
        !_vleugelsPerKader.containsKey(eersteKaderId)) {
      _vleugelsPerKader[eersteKaderId] = List<OpmetingRaamVleugel>.unmodifiable(
        oudeBasisVleugels,
      );
    }

    if (_actiefVleugelKaderId == null || _actiefVleugelKaderId == 'basis') {
      _actiefVleugelKaderId = eersteKaderId;
    }
  }

  void _bewaarTStijlenVoorActiefKader() {
    _normaliseerTStijlBasisKader();

    final kaderId = _huidigTStijlKaderId;

    _tStijlenPerKader[kaderId] = List<OpmetingRaamTStijl>.unmodifiable(
      _tStijlen,
    );
  }

  void _bewaarVleugelsVoorActiefKader() {
    _normaliseerVleugelBasisKader();

    final kaderId = _huidigVleugelKaderId;

    _vleugelsPerKader[kaderId] = List<OpmetingRaamVleugel>.unmodifiable(
      _vleugels,
    );
  }

  void _laadTStijlenVoorKader(String kaderId) {
    final tStijlen = _tStijlenPerKader[kaderId];

    _vervangTStijlen(<OpmetingRaamTStijl>[
      ...(tStijlen ?? const <OpmetingRaamTStijl>[]),
    ]);
    _wisTekeningSelecties();
  }

  void _laadVleugelsVoorKader(String kaderId) {
    final vleugels = _vleugelsPerKader[kaderId];

    _vervangVleugels(<OpmetingRaamVleugel>[
      ...(vleugels ?? const <OpmetingRaamVleugel>[]),
    ]);
    _wisTekeningSelecties();
  }

  void _bewaarOpvullingVoorActiefKader() {
    final samenstelling = _bruikbareKaderSamenstelling;

    if (samenstelling == null) {
      return;
    }

    final kaderId = _actiefOpvullingKaderId;

    if (kaderId == null || kaderId == 'basis') {
      return;
    }

    final kaderBestaat = samenstelling.kaders.any((kader) {
      return kader.id == kaderId;
    });

    if (!kaderBestaat) {
      return;
    }

    if (!_vullingToewijzingenPerKader.containsKey(kaderId) &&
        _vullingToewijzingen.isNotEmpty) {
      _vullingToewijzingenPerKader[kaderId] =
          List<OpmetingRaamVullingToewijzing>.unmodifiable(
            _vullingToewijzingen,
          );
    }

    if (_geselecteerdeVulvlakIds.isNotEmpty) {
      _geselecteerdeVulvlakIdsPerKader[kaderId] = Set<String>.unmodifiable(
        _geselecteerdeVulvlakIds,
      );
    }
  }

  void _bewaarKleinhoutenVoorActiefKader() {
    final samenstelling = _bruikbareKaderSamenstelling;

    if (samenstelling == null) {
      return;
    }

    final kaderId = _actiefKleinhoutKaderId;

    if (kaderId == null || kaderId == 'basis') {
      return;
    }

    final kaderBestaat = samenstelling.kaders.any((kader) {
      return kader.id == kaderId;
    });

    if (!kaderBestaat) {
      return;
    }

    if (!_kleinhoutenPerKader.containsKey(kaderId) && _kleinhouten.isNotEmpty) {
      _kleinhoutenPerKader[kaderId] = List<OpmetingRaamKleinhout>.unmodifiable(
        _kleinhouten,
      );
    }

    if (_geselecteerdeKleinhoutVlakIds.isNotEmpty) {
      _geselecteerdeKleinhoutVlakIdsPerKader[kaderId] =
          Set<String>.unmodifiable(_geselecteerdeKleinhoutVlakIds);
    }
  }

  void _laadOpvullingVoorKader(String kaderId) {
    _vervangVullingToewijzingen(
      _vullingToewijzingenPerKader[kaderId] ??
          const <OpmetingRaamVullingToewijzing>[],
    );

    _vervangVulvlakSelectie(
      _geselecteerdeVulvlakIdsPerKader[kaderId] ?? const <String>{},
    );
  }

  void _laadKleinhoutenVoorKader(String kaderId) {
    _vervangKleinhouten(
      _kleinhoutenPerKader[kaderId] ?? const <OpmetingRaamKleinhout>[],
    );

    _vervangKleinhoutVlakSelectie(
      _geselecteerdeKleinhoutVlakIdsPerKader[kaderId] ?? const <String>{},
    );
  }

  List<OpmetingRaamVullingToewijzing> _vullingToewijzingenVoorKader(
    String kaderId,
  ) {
    final samenstelling = _bruikbareKaderSamenstelling;

    if (samenstelling == null) {
      return List<OpmetingRaamVullingToewijzing>.unmodifiable(
        _vullingToewijzingen,
      );
    }

    return List<OpmetingRaamVullingToewijzing>.unmodifiable(
      _vullingToewijzingenPerKader[kaderId] ??
          const <OpmetingRaamVullingToewijzing>[],
    );
  }

  List<OpmetingRaamKleinhout> _kleinhoutenVoorKader(String kaderId) {
    final samenstelling = _bruikbareKaderSamenstelling;

    if (samenstelling == null) {
      return List<OpmetingRaamKleinhout>.unmodifiable(_kleinhouten);
    }

    return List<OpmetingRaamKleinhout>.unmodifiable(
      _kleinhoutenPerKader[kaderId] ?? const <OpmetingRaamKleinhout>[],
    );
  }

  Set<String> _gevuldeVlakIdsVoorKader(String kaderId) {
    return Set<String>.unmodifiable(
      _vullingToewijzingenVoorKader(
        kaderId,
      ).map((toewijzing) => toewijzing.vlakId),
    );
  }

  void _activeerKaderVoorTStijl({
    required String kaderId,
    required OpmetingKaderSamenstelling samenstelling,
  }) {
    _normaliseerTStijlBasisKader();

    final huidigeKaderId = _huidigTStijlKaderId;

    if (huidigeKaderId != kaderId) {
      setState(() {
        _tStijlenPerKader[huidigeKaderId] =
            List<OpmetingRaamTStijl>.unmodifiable(_tStijlen);

        _actiefTStijlKaderId = kaderId;
        _kaderSelectieOnderdrukt = false;
        _laadTStijlenVoorKader(kaderId);
      });
    }

    if (samenstelling.actiefKaderId != kaderId) {
      widget.onKaderSamenstellingGewijzigd?.call(
        samenstelling.copyWith(actiefKaderId: kaderId),
      );
    }
  }

  void _activeerKaderVoorVleugel({
    required String kaderId,
    required OpmetingKaderSamenstelling samenstelling,
  }) {
    _normaliseerTStijlBasisKader();
    _normaliseerVleugelBasisKader();

    final huidigeTStijlKaderId = _huidigTStijlKaderId;
    final huidigeVleugelKaderId = _huidigVleugelKaderId;

    if (huidigeTStijlKaderId != kaderId || huidigeVleugelKaderId != kaderId) {
      setState(() {
        _tStijlenPerKader[huidigeTStijlKaderId] =
            List<OpmetingRaamTStijl>.unmodifiable(_tStijlen);

        _vleugelsPerKader[huidigeVleugelKaderId] =
            List<OpmetingRaamVleugel>.unmodifiable(_vleugels);

        _actiefTStijlKaderId = kaderId;
        _actiefVleugelKaderId = kaderId;
        _kaderSelectieOnderdrukt = false;

        _laadTStijlenVoorKader(kaderId);
        _laadVleugelsVoorKader(kaderId);
      });
    }

    if (samenstelling.actiefKaderId != kaderId) {
      widget.onKaderSamenstellingGewijzigd?.call(
        samenstelling.copyWith(actiefKaderId: kaderId),
      );
    }
  }

  OpmetingKaderDeel? _kaderVoorPuntInSamenstelling({
    required Offset basisPunt,
    required Size size,
  }) {
    final samenstelling = widget.kaderSamenstelling;

    if (samenstelling == null || samenstelling.kaders.isEmpty) {
      return null;
    }

    if (samenstelling.kaders.length == 1) {
      final kader = samenstelling.kaders.first;
      final rect = OpmetingRaamKaderHelper.buitenKader(
        size: size,
        breedteMm: kader.breedteMm,
        hoogteMm: kader.hoogteMm,
      );

      return rect.contains(basisPunt) ? kader : null;
    }

    final tekenGebied = _totaleKaderSamenstellingRect(size);

    final weergave = OpmetingKaderSamenstellingTekenHelper.berekenWeergave(
      tekenGebied: tekenGebied,
      samenstelling: samenstelling,
    );

    for (final kader in weergave.layout.kaders.reversed) {
      final rect = weergave.rectVoorKaderId(kader.id);

      if (rect == null) {
        continue;
      }

      if (rect.contains(basisPunt)) {
        return kader;
      }
    }

    return null;
  }

  bool get _ctrlOfCommandIngedrukt {
    final ingedrukteToetsen = HardwareKeyboard.instance.logicalKeysPressed;

    return ingedrukteToetsen.contains(LogicalKeyboardKey.controlLeft) ||
        ingedrukteToetsen.contains(LogicalKeyboardKey.controlRight) ||
        ingedrukteToetsen.contains(LogicalKeyboardKey.metaLeft) ||
        ingedrukteToetsen.contains(LogicalKeyboardKey.metaRight);
  }

  void _meldGeselecteerdeKadersAanPagina() {
    widget.onGeselecteerdeKaderIdsGewijzigd?.call(
      Set<String>.unmodifiable(_geselecteerdeKaderIds),
    );
  }

  bool _selecteerKaderViaTekening({
    required Offset basisPunt,
    required Size size,
  }) {
    final samenstelling = widget.kaderSamenstelling;

    if (samenstelling == null || samenstelling.kaders.isEmpty) {
      return false;
    }

    final aangekliktKader = _kaderVoorPuntInSamenstelling(
      basisPunt: basisPunt,
      size: size,
    );

    if (aangekliktKader == null) {
      return false;
    }

    if (_bruikbareKaderSamenstelling == null) {
      final kaderId = aangekliktKader.id;

      setState(() {
        _geselecteerdeKaderIds
          ..clear()
          ..add(kaderId);
        _kaderSelectieOnderdrukt = false;
      });

      _meldGeselecteerdeKadersAanPagina();

      if (samenstelling.actiefKaderId != kaderId) {
        widget.onKaderSamenstellingGewijzigd?.call(
          samenstelling.copyWith(actiefKaderId: kaderId),
        );
      }

      _synchroniseerKaderMenuVelden(
        kader: aangekliktKader,
        forceer: widget.actieveTool == 'kader',
      );

      return true;
    }

    _normaliseerTStijlBasisKader();
    _normaliseerVleugelBasisKader();

    final huidigeTStijlKaderId = _huidigTStijlKaderId;
    final huidigeVleugelKaderId = _huidigVleugelKaderId;
    final kaderId = aangekliktKader.id;

    final nieuweSelectie = <String>{..._geselecteerdeKaderIds};

    final meerdereKadersSelecteren =
        _ctrlOfCommandIngedrukt || widget.actieveTool == 'kadergroep';

    if (meerdereKadersSelecteren) {
      if (nieuweSelectie.contains(kaderId)) {
        nieuweSelectie.remove(kaderId);
      } else {
        nieuweSelectie.add(kaderId);
      }

      if (nieuweSelectie.isEmpty) {
        nieuweSelectie.add(kaderId);
      }
    } else {
      nieuweSelectie
        ..clear()
        ..add(kaderId);
    }

    setState(() {
      if (huidigeTStijlKaderId != kaderId) {
        _tStijlenPerKader[huidigeTStijlKaderId] =
            List<OpmetingRaamTStijl>.unmodifiable(_tStijlen);
      }

      if (huidigeVleugelKaderId != kaderId) {
        _vleugelsPerKader[huidigeVleugelKaderId] =
            List<OpmetingRaamVleugel>.unmodifiable(_vleugels);
      }

      _actiefTStijlKaderId = kaderId;
      _actiefVleugelKaderId = kaderId;
      _actiefOpvullingKaderId = kaderId;
      _actiefKleinhoutKaderId = kaderId;
      _kaderSelectieOnderdrukt = false;

      _geselecteerdeKaderIds
        ..clear()
        ..addAll(nieuweSelectie);

      _laadTStijlenVoorKader(kaderId);
      _laadVleugelsVoorKader(kaderId);
      _laadOpvullingVoorKader(kaderId);
      _laadKleinhoutenVoorKader(kaderId);

      _geselecteerdeLijn = null;
    });

    _meldGeselecteerdeKadersAanPagina();

    if (samenstelling.actiefKaderId != kaderId) {
      widget.onKaderSamenstellingGewijzigd?.call(
        samenstelling.copyWith(actiefKaderId: kaderId),
      );
    }

    _synchroniseerKaderMenuVelden(
      kader: aangekliktKader,
      forceer: widget.actieveTool == 'kader',
    );

    return true;
  }

  Offset? _puntVoorKader({
    required Offset basisPunt,
    required Size size,
    required String kaderId,
  }) {
    final samenstelling = _bruikbareKaderSamenstelling;

    if (samenstelling == null) {
      return basisPunt;
    }

    final kader = _zoekKaderVoorId(kaderId);

    if (kader == null) {
      return null;
    }

    final tekenGebied = _totaleKaderSamenstellingRect(size);

    final kaderRect = OpmetingKaderSamenstellingTekenHelper.rectVoorKaderId(
      tekenGebied: tekenGebied,
      samenstelling: samenstelling,
      kaderId: kaderId,
    );

    if (kaderRect == null) {
      return null;
    }

    if (!kaderRect.contains(basisPunt)) {
      return null;
    }

    final enkelKaderRect = _werkRectVoorKader(size: size, kader: kader);

    final lokaleX =
        enkelKaderRect.left +
        ((basisPunt.dx - kaderRect.left) / kaderRect.width) *
            enkelKaderRect.width;

    final lokaleY =
        enkelKaderRect.top +
        ((basisPunt.dy - kaderRect.top) / kaderRect.height) *
            enkelKaderRect.height;

    return Offset(lokaleX, lokaleY);
  }

  List<OpmetingRaamVulvlak> _bepaalVulvlakken(Size size) {
    return OpmetingRaamVulvlakBerekeningHelper.bereken(
      tekenvlakGrootte: size,
      breedteMm: _actiefWerkBreedteMm,
      hoogteMm: _actiefWerkHoogteMm,
      tStijlen: _tStijlen,
      vleugels: _vleugels,
    );
  }

  List<OpmetingRaamVulvlak> _bepaalVulvlakkenVoorKader({
    required Size size,
    required String kaderId,
  }) {
    final samenstelling = _bruikbareKaderSamenstelling;

    if (samenstelling == null) {
      return _bepaalVulvlakken(size);
    }

    final kader = _zoekKaderVoorId(kaderId);

    if (kader == null) {
      return const <OpmetingRaamVulvlak>[];
    }

    final kaderTStijlen = kaderId == _huidigTStijlKaderId
        ? _tStijlen
        : _tStijlenPerKader[kaderId] ?? const <OpmetingRaamTStijl>[];

    final kaderVleugels = kaderId == _huidigVleugelKaderId
        ? _vleugels
        : _vleugelsPerKader[kaderId] ?? const <OpmetingRaamVleugel>[];

    return OpmetingRaamVulvlakBerekeningHelper.bereken(
      tekenvlakGrootte: size,
      breedteMm: kader.breedteMm,
      hoogteMm: kader.hoogteMm,
      tStijlen: kaderTStijlen,
      vleugels: kaderVleugels,
    );
  }

  Map<String, List<OpmetingRaamVulvlak>> _vulvlakkenPerKaderVoorWeergave(
    Size size,
  ) {
    final samenstelling = _bruikbareKaderSamenstelling;

    if (samenstelling == null) {
      return const <String, List<OpmetingRaamVulvlak>>{};
    }

    final resultaat = <String, List<OpmetingRaamVulvlak>>{};

    for (final kader in samenstelling.kaders) {
      resultaat[kader.id] = List<OpmetingRaamVulvlak>.unmodifiable(
        _bepaalVulvlakkenVoorKader(size: size, kaderId: kader.id),
      );
    }

    return Map<String, List<OpmetingRaamVulvlak>>.unmodifiable(resultaat);
  }

  OpmetingRaamTechnischeLayout _berekenTechnischeLayout(Size size) {
    final breedteMm = _effectieveBreedteMm;
    final hoogteMm = _effectieveHoogteMm;

    final totaleMaatRect = OpmetingRaamKaderHelper.buitenKader(
      size: size,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    return OpmetingRaamTechnischeLayoutHelper.bereken(
      totaleMaatRect: totaleMaatRect,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      technischeTekeningen: widget.technischeTekeningen,
    );
  }

  Future<void> _klikTekenvlak(TapDownDetails details) async {
    final size = _actueleTekenvlakGrootte();

    if (size == null) {
      return;
    }

    late final Offset basisPunt;

    if (_bruikbareKaderSamenstelling == null) {
      final technischeLayout = _berekenTechnischeLayout(size);

      if (!technischeLayout.bevatRaamPunt(details.localPosition)) {
        return;
      }

      basisPunt = technischeLayout.naarBasisPunt(details.localPosition);
    } else {
      basisPunt = details.localPosition;
    }

    if (widget.actieveTool == 'tstijl') {
      final samenstelling = _bruikbareKaderSamenstelling;

      if (samenstelling == null) {
        _selecteerTStijlStartLijn(basisPunt);
        return;
      }

      final aangekliktKader = _kaderVoorPuntInSamenstelling(
        basisPunt: basisPunt,
        size: size,
      );

      if (aangekliktKader == null) {
        return;
      }

      final werkPunt = _puntVoorKader(
        basisPunt: basisPunt,
        size: size,
        kaderId: aangekliktKader.id,
      );

      if (werkPunt == null) {
        return;
      }

      _activeerKaderVoorTStijl(
        kaderId: aangekliktKader.id,
        samenstelling: samenstelling,
      );

      _selecteerTStijlStartLijn(werkPunt);
      return;
    }

    if (widget.actieveTool == 'vleugel' ||
        widget.actieveTool == 'deurvleugel') {
      final samenstelling = _bruikbareKaderSamenstelling;
      final isDeurVleugelTool = widget.actieveTool == 'deurvleugel';

      if (samenstelling == null) {
        if (isDeurVleugelTool) {
          await _pasDeurVleugelToe(basisPunt);
        } else {
          _pasVleugelToe(basisPunt);
        }
        return;
      }

      final aangekliktKader = _kaderVoorPuntInSamenstelling(
        basisPunt: basisPunt,
        size: size,
      );

      if (aangekliktKader == null) {
        return;
      }

      final werkPunt = _puntVoorKader(
        basisPunt: basisPunt,
        size: size,
        kaderId: aangekliktKader.id,
      );

      if (werkPunt == null) {
        return;
      }

      _activeerKaderVoorVleugel(
        kaderId: aangekliktKader.id,
        samenstelling: samenstelling,
      );

      if (isDeurVleugelTool) {
        await _pasDeurVleugelToe(werkPunt);
      } else {
        _pasVleugelToe(werkPunt);
      }
      return;
    }

    if (widget.actieveTool == 'deurpanelen') {
      final samenstelling = _bruikbareKaderSamenstelling;

      if (samenstelling == null) {
        _pasDeurpaneelToeOpPunt(basisPunt);
        return;
      }

      final aangekliktKader = _kaderVoorPuntInSamenstelling(
        basisPunt: basisPunt,
        size: size,
      );

      if (aangekliktKader == null) {
        return;
      }

      final werkPunt = _puntVoorKader(
        basisPunt: basisPunt,
        size: size,
        kaderId: aangekliktKader.id,
      );

      if (werkPunt == null) {
        return;
      }

      _activeerKaderVoorVleugel(
        kaderId: aangekliktKader.id,
        samenstelling: samenstelling,
      );

      _pasDeurpaneelToeOpPunt(werkPunt);
      return;
    }

    switch (widget.actieveTool) {
      case 'opvulling':
        _selecteerVulvlak(basisPunt);
        return;

      case 'kleinhout':
        _selecteerKleinhoutVlak(basisPunt);
        return;

      case 'kader':
        _selecteerKaderViaTekening(basisPunt: basisPunt, size: size);
        return;

      case 'kadertoevoegen':
        final aangekliktKader = _kaderVoorPuntInSamenstelling(
          basisPunt: basisPunt,
          size: size,
        );

        if (aangekliktKader != null && aangekliktKader.id != _toevoegKaderId) {
          _toevoegAnkerKaderId = aangekliktKader.id;
        }

        if (_selecteerKaderViaTekening(basisPunt: basisPunt, size: size)) {
          _tekenOfWijzigToevoegKader();
        }
        return;

      default:
        _selecteerKaderViaTekening(basisPunt: basisPunt, size: size);
        return;
    }
  }

  void _pasDeurpaneelToeOpPunt(Offset punt) {
    final keuze = OpmetingDeurpaneelActieveKeuzeController.huidigeKeuze;

    if (keuze == null) {
      OpmetingRaamSnackBarHelper.toonWaarschuwing(
        context,
        'Kies eerst een deurpaneel via de knop Deur panelen.',
      );
      return;
    }

    final deurVleugel =
        OpmetingDeurpaneelGeometrieHelper.vindDeurVleugelVoorPunt(
          punt: punt,
          vleugels: _vleugels,
        );

    if (deurVleugel == null) {
      OpmetingRaamSnackBarHelper.toonWaarschuwing(
        context,
        'Klik op een bestaande deurvleugel om het deurpaneel te plaatsen.',
      );
      return;
    }

    final resultaat = OpmetingDeurpaneelActieHelper.plaatsOfVervang(
      deurVleugel: deurVleugel,
      keuze: keuze,
      huidigeToewijzingen: _deurpaneelToewijzingen,
    );

    if (!resultaat.gelukt) {
      OpmetingRaamSnackBarHelper.toonWaarschuwing(context, resultaat.melding);
      return;
    }

    setState(() {
      _deurpaneelToewijzingen
        ..clear()
        ..addAll(resultaat.toewijzingen);
    });

    _werkDeurpaneelControllerBij();

    OpmetingRaamSnackBarHelper.toonWaarschuwing(context, resultaat.melding);
  }

  void _selecteerVulvlak(Offset punt) {
    final size = _actueleTekenvlakGrootte();

    if (size == null) {
      return;
    }

    final samenstelling = _bruikbareKaderSamenstelling;

    if (samenstelling == null) {
      final resultaat = OpmetingRaamOpvullingActieHelper.wisselSelectie(
        punt: punt,
        vulvlakken: _bepaalVulvlakken(size),
        huidigeGeselecteerdeVlakIds: _geselecteerdeVulvlakIds,
        toewijzingen: _vullingToewijzingen,
        opvullingen: _opvullingen,
        huidigeGeselecteerdeOpvullingId: _geselecteerdeOpvullingId,
      );

      if (!resultaat.vlakGevonden) {
        return;
      }

      setState(() {
        _vervangVulvlakSelectie(resultaat.geselecteerdeVlakIds);
        _geselecteerdeOpvullingId = resultaat.geselecteerdeOpvullingId;
      });

      return;
    }

    final aangekliktKader = _kaderVoorPuntInSamenstelling(
      basisPunt: punt,
      size: size,
    );

    if (aangekliktKader == null) {
      return;
    }

    final werkPunt = _puntVoorKader(
      basisPunt: punt,
      size: size,
      kaderId: aangekliktKader.id,
    );

    if (werkPunt == null) {
      return;
    }

    final kaderId = aangekliktKader.id;
    final vulvlakken = _bepaalVulvlakkenVoorKader(size: size, kaderId: kaderId);

    final resultaat = OpmetingRaamOpvullingActieHelper.wisselSelectie(
      punt: werkPunt,
      vulvlakken: vulvlakken,
      huidigeGeselecteerdeVlakIds:
          _geselecteerdeVulvlakIdsPerKader[kaderId] ?? const <String>{},
      toewijzingen: _vullingToewijzingenVoorKader(kaderId),
      opvullingen: _opvullingen,
      huidigeGeselecteerdeOpvullingId: _geselecteerdeOpvullingId,
    );

    if (!resultaat.vlakGevonden) {
      return;
    }

    setState(() {
      _actiefOpvullingKaderId = kaderId;

      _vervangVullingToewijzingen(_vullingToewijzingenVoorKader(kaderId));
      _vervangVulvlakSelectie(resultaat.geselecteerdeVlakIds);

      _geselecteerdeVulvlakIdsPerKader[kaderId] = Set<String>.unmodifiable(
        resultaat.geselecteerdeVlakIds,
      );

      _geselecteerdeOpvullingId = resultaat.geselecteerdeOpvullingId;
    });
  }

  Set<String> _samengevoegdeKleinhoutSelectie() {
    final selectie = <String>{..._geselecteerdeKleinhoutVlakIds};

    for (final vlakIds in _geselecteerdeKleinhoutVlakIdsPerKader.values) {
      selectie.addAll(vlakIds);
    }

    return Set<String>.unmodifiable(selectie);
  }

  int _aantalGeselecteerdeVulvlakkenVoorMenu() {
    final samenstelling = _bruikbareKaderSamenstelling;

    if (samenstelling == null) {
      return _geselecteerdeVulvlakIds.length;
    }

    var totaal = 0;

    for (final selectie in _geselecteerdeVulvlakIdsPerKader.values) {
      totaal += selectie.length;
    }

    return totaal;
  }

  int _aantalGeselecteerdeKleinhoutVlakkenVoorMenu() {
    final samenstelling = _bruikbareKaderSamenstelling;

    if (samenstelling == null) {
      return _geselecteerdeKleinhoutVlakIds.length;
    }

    var totaal = 0;

    for (final selectie in _geselecteerdeKleinhoutVlakIdsPerKader.values) {
      totaal += selectie.length;
    }

    return totaal;
  }

  int _totaalAantalVulvlakkenVoorMenu(List<OpmetingRaamVulvlak> vulvlakken) {
    final samenstelling = _bruikbareKaderSamenstelling;
    final size = _actueleTekenvlakGrootte();

    if (samenstelling == null || size == null) {
      return vulvlakken.length;
    }

    final geldigeKaderIds = samenstelling.kaders.map((kader) {
      return kader.id;
    }).toSet();

    final doelKaderIds = _geselecteerdeKaderIds.where((kaderId) {
      return geldigeKaderIds.contains(kaderId);
    }).toList();

    if (doelKaderIds.isEmpty) {
      final actiefKaderId = _actiefOpvullingKaderId;

      if (actiefKaderId != null && geldigeKaderIds.contains(actiefKaderId)) {
        doelKaderIds.add(actiefKaderId);
      } else if (geldigeKaderIds.contains(samenstelling.actiefKaderId)) {
        doelKaderIds.add(samenstelling.actiefKaderId);
      } else if (samenstelling.kaders.isNotEmpty) {
        doelKaderIds.add(samenstelling.kaders.first.id);
      }
    }

    var totaal = 0;

    for (final kaderId in doelKaderIds) {
      totaal += _bepaalVulvlakkenVoorKader(size: size, kaderId: kaderId).length;
    }

    return totaal;
  }

  int _totaalAantalGevuldeKleinhoutVlakkenVoorMenu(
    OpmetingRaamTekenvlakWeergaveStatus weergaveStatus,
  ) {
    final samenstelling = _bruikbareKaderSamenstelling;

    if (samenstelling == null) {
      return weergaveStatus.totaalAantalGevuldeVlakken;
    }

    var totaal = 0;

    for (final kader in samenstelling.kaders) {
      totaal += _gevuldeVlakIdsVoorKader(kader.id).length;
    }

    return totaal;
  }

  bool _kleinhoutSelectieIsVolledigGevuldVoorMenu(
    OpmetingRaamTekenvlakWeergaveStatus weergaveStatus,
  ) {
    final samenstelling = _bruikbareKaderSamenstelling;

    if (samenstelling == null) {
      return weergaveStatus.kleinhoutSelectieIsVolledigGevuld;
    }

    if (_aantalGeselecteerdeKleinhoutVlakkenVoorMenu() == 0) {
      return false;
    }

    for (final entry in _geselecteerdeKleinhoutVlakIdsPerKader.entries) {
      if (entry.value.isEmpty) {
        continue;
      }

      final gevuldeVlakIds = _gevuldeVlakIdsVoorKader(entry.key);

      for (final vlakId in entry.value) {
        if (!gevuldeVlakIds.contains(vlakId)) {
          return false;
        }
      }
    }

    return true;
  }

  bool _kleinhoutSelectieHeeftKleinhoutenVoorMenu(
    OpmetingRaamTekenvlakWeergaveStatus weergaveStatus,
  ) {
    final samenstelling = _bruikbareKaderSamenstelling;

    if (samenstelling == null) {
      return weergaveStatus.kleinhoutSelectieHeeftKleinhouten;
    }

    for (final entry in _geselecteerdeKleinhoutVlakIdsPerKader.entries) {
      if (entry.value.isEmpty) {
        continue;
      }

      final kleinhoutVlakIds = _kleinhoutenVoorKader(
        entry.key,
      ).map((kleinhout) => kleinhout.vlakId).toSet();

      for (final vlakId in entry.value) {
        if (kleinhoutVlakIds.contains(vlakId)) {
          return true;
        }
      }
    }

    return false;
  }

  void _selecteerKleinhoutVlak(Offset punt) {
    final size = _actueleTekenvlakGrootte();

    if (size == null) {
      return;
    }

    final samenstelling = _bruikbareKaderSamenstelling;

    if (samenstelling == null) {
      final oudeSelectie = Set<String>.from(_geselecteerdeKleinhoutVlakIds);

      final resultaat = OpmetingRaamOpvullingActieHelper.wisselSelectie(
        punt: punt,
        vulvlakken: _bepaalVulvlakken(size),
        huidigeGeselecteerdeVlakIds: oudeSelectie,
        toewijzingen: _vullingToewijzingen,
        opvullingen: _opvullingen,
        huidigeGeselecteerdeOpvullingId: _geselecteerdeOpvullingId,
      );

      if (!resultaat.vlakGevonden) {
        return;
      }

      final toegevoegdeVlakIds = resultaat.geselecteerdeVlakIds.where(
        (vlakId) => !oudeSelectie.contains(vlakId),
      );

      final gevuld = _gevuldeVlakIds;
      final bevatLeegNieuwVlak = toegevoegdeVlakIds.any(
        (vlakId) => !gevuld.contains(vlakId),
      );

      if (bevatLeegNieuwVlak) {
        OpmetingRaamSnackBarHelper.toonWaarschuwing(
          context,
          'Voeg eerst een opvulling toe aan dit vlak.',
        );
        return;
      }

      final selectie = resultaat.geselecteerdeVlakIds
          .where((vlakId) => gevuld.contains(vlakId))
          .toSet();

      setState(() {
        _vervangKleinhoutVlakSelectie(selectie);

        if (selectie.isNotEmpty) {
          _laadKleinhoutInstellingenVoorVlak(selectie.last);
        }

        _menuZichtbaarheid.toonKleinhoutMenu();
      });

      return;
    }

    final aangekliktKader = _kaderVoorPuntInSamenstelling(
      basisPunt: punt,
      size: size,
    );

    if (aangekliktKader == null) {
      return;
    }

    final werkPunt = _puntVoorKader(
      basisPunt: punt,
      size: size,
      kaderId: aangekliktKader.id,
    );

    if (werkPunt == null) {
      return;
    }

    final kaderId = aangekliktKader.id;
    final vulvlakken = _bepaalVulvlakkenVoorKader(size: size, kaderId: kaderId);

    final oudeSelectie = Set<String>.from(
      _geselecteerdeKleinhoutVlakIdsPerKader[kaderId] ?? const <String>{},
    );

    final resultaat = OpmetingRaamOpvullingActieHelper.wisselSelectie(
      punt: werkPunt,
      vulvlakken: vulvlakken,
      huidigeGeselecteerdeVlakIds: oudeSelectie,
      toewijzingen: _vullingToewijzingenVoorKader(kaderId),
      opvullingen: _opvullingen,
      huidigeGeselecteerdeOpvullingId: _geselecteerdeOpvullingId,
    );

    if (!resultaat.vlakGevonden) {
      return;
    }

    final gevuldeVlakIds = _gevuldeVlakIdsVoorKader(kaderId);
    final toegevoegdeVlakIds = resultaat.geselecteerdeVlakIds.where(
      (vlakId) => !oudeSelectie.contains(vlakId),
    );

    final bevatLeegNieuwVlak = toegevoegdeVlakIds.any(
      (vlakId) => !gevuldeVlakIds.contains(vlakId),
    );

    if (bevatLeegNieuwVlak) {
      OpmetingRaamSnackBarHelper.toonWaarschuwing(
        context,
        'Voeg eerst een opvulling toe aan dit vlak.',
      );
      return;
    }

    final selectie = resultaat.geselecteerdeVlakIds
        .where((vlakId) => gevuldeVlakIds.contains(vlakId))
        .toSet();

    setState(() {
      _actiefKleinhoutKaderId = kaderId;

      _vervangKleinhouten(_kleinhoutenVoorKader(kaderId));
      _vervangKleinhoutVlakSelectie(selectie);

      if (selectie.isEmpty) {
        _geselecteerdeKleinhoutVlakIdsPerKader.remove(kaderId);
      } else {
        _geselecteerdeKleinhoutVlakIdsPerKader[kaderId] =
            Set<String>.unmodifiable(selectie);
      }

      final totaleSelectie = _samengevoegdeKleinhoutSelectie();
      _vervangKleinhoutVlakSelectie(totaleSelectie);

      if (selectie.isNotEmpty) {
        _laadKleinhoutInstellingenVoorVlak(selectie.last);
      }

      _menuZichtbaarheid.toonKleinhoutMenu();
    });
  }

  void _laadKleinhoutInstellingenVoorVlak(String vlakId) {
    final instellingen = OpmetingRaamKleinhoutInstellingenHelper.laadVoorVlak(
      vlakId: vlakId,
      kleinhouten: _kleinhouten,
    );

    if (instellingen == null) {
      return;
    }

    _geselecteerdKleinhoutType = instellingen.type;
    _geselecteerdKleinhoutPatroon = instellingen.patroon;

    _kleinhoutAantalHorizontaalController.text =
        instellingen.aantalHorizontaalTekst;

    _kleinhoutAantalVerticaalController.text =
        instellingen.aantalVerticaalTekst;

    _kleinhoutHorizontaleHoogteController.text =
        instellingen.horizontaleHoogteTekst;
  }

  void _verwerkOpvullingWijziging({
    required bool actieBeschikbaar,
    required bool gewijzigd,
    required Iterable<OpmetingRaamVullingToewijzing> toewijzingen,
  }) {
    if (!actieBeschikbaar) {
      return;
    }

    if (!gewijzigd) {
      setState(() {
        _geselecteerdeVulvlakIds.clear();
      });

      return;
    }

    _bewaarVoorWijziging();

    setState(() {
      _vervangVullingToewijzingen(toewijzingen);
      _geselecteerdeVulvlakIds.clear();
      _schoonKleinhoutenOp();
    });

    _planAlleLegendaMeldingen();
  }

  void _pasOpvullingToe() {
    final size = _actueleTekenvlakGrootte();

    if (size == null) {
      return;
    }

    final samenstelling = _bruikbareKaderSamenstelling;

    if (samenstelling == null) {
      final resultaat = OpmetingRaamOpvullingActieHelper.pasToe(
        vulvlakken: _bepaalVulvlakken(size),
        geselecteerdeVlakIds: _geselecteerdeVulvlakIds,
        bestaandeToewijzingen: _vullingToewijzingen,
        opvullingen: _opvullingen,
        geselecteerdeOpvullingId: _geselecteerdeOpvullingId,
      );

      _verwerkOpvullingWijziging(
        actieBeschikbaar: resultaat.actieBeschikbaar,
        gewijzigd: resultaat.gewijzigd,
        toewijzingen: resultaat.toewijzingen,
      );

      return;
    }

    final kaderIds = _geselecteerdeVulvlakIdsPerKader.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => entry.key)
        .toList();

    if (kaderIds.isEmpty) {
      return;
    }

    var heeftWijziging = false;
    final nieuweToewijzingenPerKader =
        <String, List<OpmetingRaamVullingToewijzing>>{};

    for (final kaderId in kaderIds) {
      final selectie =
          _geselecteerdeVulvlakIdsPerKader[kaderId] ?? const <String>{};

      if (selectie.isEmpty) {
        continue;
      }

      final resultaat = OpmetingRaamOpvullingActieHelper.pasToe(
        vulvlakken: _bepaalVulvlakkenVoorKader(size: size, kaderId: kaderId),
        geselecteerdeVlakIds: selectie,
        bestaandeToewijzingen: _vullingToewijzingenVoorKader(kaderId),
        opvullingen: _opvullingen,
        geselecteerdeOpvullingId: _geselecteerdeOpvullingId,
      );

      if (!resultaat.actieBeschikbaar) {
        return;
      }

      nieuweToewijzingenPerKader[kaderId] = resultaat.toewijzingen;
      heeftWijziging = heeftWijziging || resultaat.gewijzigd;
    }

    if (!heeftWijziging) {
      setState(() {
        _geselecteerdeVulvlakIds.clear();
        _geselecteerdeVulvlakIdsPerKader.clear();
      });

      return;
    }

    _bewaarVoorWijziging();

    setState(() {
      for (final entry in nieuweToewijzingenPerKader.entries) {
        _vullingToewijzingenPerKader[entry.key] =
            List<OpmetingRaamVullingToewijzing>.unmodifiable(entry.value);
      }

      _geselecteerdeVulvlakIds.clear();
      _geselecteerdeVulvlakIdsPerKader.clear();

      final actiefKaderId = _actiefOpvullingKaderId;

      if (actiefKaderId != null &&
          _vullingToewijzingenPerKader.containsKey(actiefKaderId)) {
        _vervangVullingToewijzingen(
          _vullingToewijzingenPerKader[actiefKaderId] ??
              const <OpmetingRaamVullingToewijzing>[],
        );
      }
    });

    _planAlleLegendaMeldingen();
  }

  void _verwijderOpvullingUitSelectie() {
    final samenstelling = _bruikbareKaderSamenstelling;

    if (samenstelling == null) {
      final resultaat = OpmetingRaamOpvullingActieHelper.verwijder(
        geselecteerdeVlakIds: _geselecteerdeVulvlakIds,
        bestaandeToewijzingen: _vullingToewijzingen,
      );

      if (!resultaat.actieBeschikbaar) {
        return;
      }

      _verwerkOpvullingWijziging(
        actieBeschikbaar: resultaat.actieBeschikbaar,
        gewijzigd: resultaat.gewijzigd,
        toewijzingen: resultaat.toewijzingen,
      );

      return;
    }

    final kaderIds = _geselecteerdeVulvlakIdsPerKader.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => entry.key)
        .toList();

    if (kaderIds.isEmpty) {
      return;
    }

    var heeftWijziging = false;
    final nieuweToewijzingenPerKader =
        <String, List<OpmetingRaamVullingToewijzing>>{};

    for (final kaderId in kaderIds) {
      final resultaat = OpmetingRaamOpvullingActieHelper.verwijder(
        geselecteerdeVlakIds:
            _geselecteerdeVulvlakIdsPerKader[kaderId] ?? const <String>{},
        bestaandeToewijzingen: _vullingToewijzingenVoorKader(kaderId),
      );

      if (!resultaat.actieBeschikbaar) {
        continue;
      }

      nieuweToewijzingenPerKader[kaderId] = resultaat.toewijzingen;
      heeftWijziging = heeftWijziging || resultaat.gewijzigd;
    }

    if (!heeftWijziging) {
      return;
    }

    _bewaarVoorWijziging();

    setState(() {
      for (final entry in nieuweToewijzingenPerKader.entries) {
        _vullingToewijzingenPerKader[entry.key] =
            List<OpmetingRaamVullingToewijzing>.unmodifiable(entry.value);
      }

      _geselecteerdeVulvlakIds.clear();
      _geselecteerdeVulvlakIdsPerKader.clear();

      final actiefKaderId = _actiefOpvullingKaderId;

      if (actiefKaderId != null &&
          _vullingToewijzingenPerKader.containsKey(actiefKaderId)) {
        _vervangVullingToewijzingen(
          _vullingToewijzingenPerKader[actiefKaderId] ??
              const <OpmetingRaamVullingToewijzing>[],
        );
      }
    });

    _planAlleLegendaMeldingen();
  }

  void _selecteerAlleVulvlakken() {
    final size = _actueleTekenvlakGrootte();

    if (size == null) {
      return;
    }

    final samenstelling = _bruikbareKaderSamenstelling;

    setState(() {
      if (samenstelling == null) {
        final selectie = OpmetingRaamOpvullingActieHelper.selecteerAlles(
          _bepaalVulvlakken(size),
        );

        _vervangVulvlakSelectie(selectie);
        return;
      }

      final geldigeKaderIds = samenstelling.kaders.map((kader) {
        return kader.id;
      }).toSet();

      final doelKaderIds = _geselecteerdeKaderIds.where((kaderId) {
        return geldigeKaderIds.contains(kaderId);
      }).toList();

      if (doelKaderIds.isEmpty) {
        final actiefKaderId = _actiefOpvullingKaderId;

        if (actiefKaderId != null && geldigeKaderIds.contains(actiefKaderId)) {
          doelKaderIds.add(actiefKaderId);
        } else if (geldigeKaderIds.contains(samenstelling.actiefKaderId)) {
          doelKaderIds.add(samenstelling.actiefKaderId);
        } else if (samenstelling.kaders.isNotEmpty) {
          doelKaderIds.add(samenstelling.kaders.first.id);
        }
      }

      _geselecteerdeVulvlakIds.clear();
      _geselecteerdeVulvlakIdsPerKader.clear();

      for (final kaderId in doelKaderIds) {
        final selectie = OpmetingRaamOpvullingActieHelper.selecteerAlles(
          _bepaalVulvlakkenVoorKader(size: size, kaderId: kaderId),
        );

        if (selectie.isNotEmpty) {
          _geselecteerdeVulvlakIdsPerKader[kaderId] = Set<String>.unmodifiable(
            selectie,
          );
        }
      }

      if (doelKaderIds.isNotEmpty) {
        final actiefKaderId = doelKaderIds.first;

        _actiefOpvullingKaderId = actiefKaderId;
        _vervangVullingToewijzingen(
          _vullingToewijzingenVoorKader(actiefKaderId),
        );
        _vervangVulvlakSelectie(
          _geselecteerdeVulvlakIdsPerKader[actiefKaderId] ?? const <String>{},
        );
      }
    });
  }

  void _wisVulvlakSelectie() {
    if (_geselecteerdeVulvlakIds.isEmpty &&
        _geselecteerdeVulvlakIdsPerKader.values.every((set) => set.isEmpty)) {
      return;
    }

    setState(() {
      _geselecteerdeVulvlakIds.clear();
      _geselecteerdeVulvlakIdsPerKader.clear();
    });
  }

  void _selecteerAlleGevuldeKleinhoutVlakken() {
    final size = _actueleTekenvlakGrootte();

    if (size == null) {
      return;
    }

    final samenstelling = _bruikbareKaderSamenstelling;

    if (samenstelling == null) {
      final selectie =
          OpmetingRaamKleinhoutActieHelper.selecteerAlleGevuldeVlakken(
            vulvlakken: _bepaalVulvlakken(size),
            gevuldeVlakIds: _gevuldeVlakIds,
          );

      setState(() {
        _vervangKleinhoutVlakSelectie(selectie);

        if (selectie.isNotEmpty) {
          _laadKleinhoutInstellingenVoorVlak(selectie.first);
        }
      });

      return;
    }

    setState(() {
      _geselecteerdeKleinhoutVlakIds.clear();
      _geselecteerdeKleinhoutVlakIdsPerKader.clear();

      String? eersteSelectie;
      String? eersteKaderId;

      for (final kader in samenstelling.kaders) {
        final selectie =
            OpmetingRaamKleinhoutActieHelper.selecteerAlleGevuldeVlakken(
              vulvlakken: _bepaalVulvlakkenVoorKader(
                size: size,
                kaderId: kader.id,
              ),
              gevuldeVlakIds: _gevuldeVlakIdsVoorKader(kader.id),
            );

        if (selectie.isNotEmpty) {
          _geselecteerdeKleinhoutVlakIdsPerKader[kader.id] =
              Set<String>.unmodifiable(selectie);
          eersteSelectie ??= selectie.first;
          eersteKaderId ??= kader.id;
        }
      }

      if (eersteKaderId != null) {
        _actiefKleinhoutKaderId = eersteKaderId;
        _vervangKleinhouten(_kleinhoutenVoorKader(eersteKaderId!));
        _vervangKleinhoutVlakSelectie(
          _geselecteerdeKleinhoutVlakIdsPerKader[eersteKaderId] ??
              const <String>{},
        );
      }

      if (eersteSelectie != null) {
        _laadKleinhoutInstellingenVoorVlak(eersteSelectie!);
      }
    });
  }

  void _wisKleinhoutSelectie() {
    if (_geselecteerdeKleinhoutVlakIds.isEmpty &&
        _geselecteerdeKleinhoutVlakIdsPerKader.values.every(
          (set) => set.isEmpty,
        )) {
      return;
    }

    setState(() {
      _geselecteerdeKleinhoutVlakIds.clear();
      _geselecteerdeKleinhoutVlakIdsPerKader.clear();
    });
  }

  void _verwerkKleinhoutWijziging({
    required bool gewijzigd,
    required Iterable<OpmetingRaamKleinhout> kleinhouten,
  }) {
    if (!gewijzigd) {
      return;
    }

    _bewaarVoorWijziging();

    setState(() {
      _vervangKleinhouten(kleinhouten);
    });

    _legendaMeldingen.planKleinhoutMelding();
  }

  void _pasKleinhoutenToe() {
    final size = _actueleTekenvlakGrootte();

    if (size == null) {
      return;
    }

    final samenstelling = _bruikbareKaderSamenstelling;

    if (samenstelling == null) {
      final resultaat = OpmetingRaamKleinhoutActieHelper.pasToe(
        tekenvlakGrootte: size,
        breedteMm: widget.breedteMm,
        hoogteMm: widget.hoogteMm,
        vulvlakken: _bepaalVulvlakken(size),
        geselecteerdeVlakIds: _geselecteerdeKleinhoutVlakIds,
        gevuldeVlakIds: _gevuldeVlakIds,
        bestaandeKleinhouten: _kleinhouten,
        type: _geselecteerdKleinhoutType,
        patroon: _geselecteerdKleinhoutPatroon,
        aantalHorizontaalTekst: _kleinhoutAantalHorizontaalController.text,
        aantalVerticaalTekst: _kleinhoutAantalVerticaalController.text,
        horizontaleHoogteTekst: _kleinhoutHorizontaleHoogteController.text,
      );

      if (!resultaat.actieBeschikbaar) {
        return;
      }

      final foutmelding = resultaat.foutmelding;

      if (foutmelding != null) {
        OpmetingRaamSnackBarHelper.toonFout(context, foutmelding);
        return;
      }

      _verwerkKleinhoutWijziging(
        gewijzigd: resultaat.gewijzigd,
        kleinhouten: resultaat.kleinhouten,
      );

      return;
    }

    final kaderIds = _geselecteerdeKleinhoutVlakIdsPerKader.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => entry.key)
        .toList();

    if (kaderIds.isEmpty) {
      return;
    }

    var heeftWijziging = false;
    final nieuweKleinhoutenPerKader = <String, List<OpmetingRaamKleinhout>>{};

    for (final kaderId in kaderIds) {
      final kader = _zoekKaderVoorId(kaderId);

      if (kader == null) {
        continue;
      }

      final resultaat = OpmetingRaamKleinhoutActieHelper.pasToe(
        tekenvlakGrootte: size,
        breedteMm: kader.breedteMm,
        hoogteMm: kader.hoogteMm,
        vulvlakken: _bepaalVulvlakkenVoorKader(size: size, kaderId: kaderId),
        geselecteerdeVlakIds:
            _geselecteerdeKleinhoutVlakIdsPerKader[kaderId] ?? const <String>{},
        gevuldeVlakIds: _gevuldeVlakIdsVoorKader(kaderId),
        bestaandeKleinhouten: _kleinhoutenVoorKader(kaderId),
        type: _geselecteerdKleinhoutType,
        patroon: _geselecteerdKleinhoutPatroon,
        aantalHorizontaalTekst: _kleinhoutAantalHorizontaalController.text,
        aantalVerticaalTekst: _kleinhoutAantalVerticaalController.text,
        horizontaleHoogteTekst: _kleinhoutHorizontaleHoogteController.text,
      );

      if (!resultaat.actieBeschikbaar) {
        continue;
      }

      final foutmelding = resultaat.foutmelding;

      if (foutmelding != null) {
        OpmetingRaamSnackBarHelper.toonFout(context, foutmelding);
        return;
      }

      nieuweKleinhoutenPerKader[kaderId] = resultaat.kleinhouten;
      heeftWijziging = heeftWijziging || resultaat.gewijzigd;
    }

    if (!heeftWijziging) {
      return;
    }

    _bewaarVoorWijziging();

    setState(() {
      for (final entry in nieuweKleinhoutenPerKader.entries) {
        _kleinhoutenPerKader[entry.key] =
            List<OpmetingRaamKleinhout>.unmodifiable(entry.value);
      }

      _geselecteerdeKleinhoutVlakIds.clear();
      _geselecteerdeKleinhoutVlakIdsPerKader.clear();

      final actiefKaderId = _actiefKleinhoutKaderId;

      if (actiefKaderId != null) {
        if (_kleinhoutenPerKader.containsKey(actiefKaderId)) {
          _vervangKleinhouten(
            _kleinhoutenPerKader[actiefKaderId] ??
                const <OpmetingRaamKleinhout>[],
          );
        }
      }
    });

    _legendaMeldingen.planKleinhoutMelding();
  }

  void _verwijderGeselecteerdeKleinhouten() {
    final samenstelling = _bruikbareKaderSamenstelling;

    if (samenstelling == null) {
      final resultaat = OpmetingRaamKleinhoutActieHelper.verwijder(
        geselecteerdeVlakIds: _geselecteerdeKleinhoutVlakIds,
        bestaandeKleinhouten: _kleinhouten,
      );

      if (!resultaat.actieBeschikbaar) {
        return;
      }

      _verwerkKleinhoutWijziging(
        gewijzigd: resultaat.gewijzigd,
        kleinhouten: resultaat.kleinhouten,
      );

      return;
    }

    final kaderIds = _geselecteerdeKleinhoutVlakIdsPerKader.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => entry.key)
        .toList();

    if (kaderIds.isEmpty) {
      return;
    }

    var heeftWijziging = false;
    final nieuweKleinhoutenPerKader = <String, List<OpmetingRaamKleinhout>>{};

    for (final kaderId in kaderIds) {
      final resultaat = OpmetingRaamKleinhoutActieHelper.verwijder(
        geselecteerdeVlakIds:
            _geselecteerdeKleinhoutVlakIdsPerKader[kaderId] ?? const <String>{},
        bestaandeKleinhouten: _kleinhoutenVoorKader(kaderId),
      );

      if (!resultaat.actieBeschikbaar) {
        continue;
      }

      nieuweKleinhoutenPerKader[kaderId] = resultaat.kleinhouten;
      heeftWijziging = heeftWijziging || resultaat.gewijzigd;
    }

    if (!heeftWijziging) {
      return;
    }

    _bewaarVoorWijziging();

    setState(() {
      for (final entry in nieuweKleinhoutenPerKader.entries) {
        _kleinhoutenPerKader[entry.key] =
            List<OpmetingRaamKleinhout>.unmodifiable(entry.value);
      }

      _geselecteerdeKleinhoutVlakIds.clear();
      _geselecteerdeKleinhoutVlakIdsPerKader.clear();

      final actiefKaderId = _actiefKleinhoutKaderId;

      if (actiefKaderId != null) {
        if (_kleinhoutenPerKader.containsKey(actiefKaderId)) {
          _vervangKleinhouten(
            _kleinhoutenPerKader[actiefKaderId] ??
                const <OpmetingRaamKleinhout>[],
          );
        }
      }
    });

    _legendaMeldingen.planKleinhoutMelding();
  }

  void _schoonVullingEnKleinhoutenOp() {
    final size = _actueleTekenvlakGrootte();

    if (size == null) {
      return;
    }

    final vulvlakken = _bepaalVulvlakken(size);

    final resultaat = OpmetingRaamTekeningOpschoningHelper.schoonAllesOp(
      huidigeVulvlakken: vulvlakken,
      bestaandeVullingToewijzingen: _vullingToewijzingen,
      geselecteerdeVulvlakIds: _geselecteerdeVulvlakIds,
      bestaandeKleinhouten: _kleinhouten,
      geselecteerdeKleinhoutVlakIds: _geselecteerdeKleinhoutVlakIds,
    );

    _vervangVullingToewijzingen(resultaat.vullingToewijzingen);
    _vervangVulvlakSelectie(resultaat.geselecteerdeVulvlakIds);
    _vervangKleinhouten(resultaat.kleinhouten);
    _vervangKleinhoutVlakSelectie(resultaat.geselecteerdeKleinhoutVlakIds);
  }

  void _schoonKleinhoutenOp({List<OpmetingRaamVulvlak>? vulvlakken}) {
    final size = _actueleTekenvlakGrootte();

    if (size == null) {
      return;
    }

    final huidigeVulvlakken = vulvlakken ?? _bepaalVulvlakken(size);

    final resultaat = OpmetingRaamTekeningOpschoningHelper.schoonKleinhoutenOp(
      huidigeVulvlakken: huidigeVulvlakken,
      vullingToewijzingen: _vullingToewijzingen,
      bestaandeKleinhouten: _kleinhouten,
      geselecteerdeKleinhoutVlakIds: _geselecteerdeKleinhoutVlakIds,
    );

    _vervangKleinhouten(resultaat.kleinhouten);
    _vervangKleinhoutVlakSelectie(resultaat.geselecteerdeVlakIds);
  }

  void _selecteerTStijlStartLijn(Offset punt) {
    final size = _actueleTekenvlakGrootte();

    if (size == null) {
      return;
    }

    final deurLijnInfo = _vindDeurVleugelBinnenLijn(punt: punt, size: size);

    final lijn =
        deurLijnInfo?.lijn ??
        OpmetingRaamTStijlActieHelper.vindStartLijn(
          punt: punt,
          tekenvlakGrootte: size,
          breedteMm: _actiefTStijlBreedteMm,
          hoogteMm: _actiefTStijlHoogteMm,
          tStijlen: _tStijlen,
          vleugels: _vleugels,
        );

    setState(() {
      _geselecteerdeLijn = lijn;

      if (lijn != null) {
        _menuZichtbaarheid.toonTStijlMenu();
      }
    });
  }

  _DeurVleugelBinnenLijnInfo? _vindDeurVleugelBinnenLijn({
    required Offset punt,
    required Size size,
  }) {
    final lijnen = _deurVleugelBinnenLijnen(size);

    _DeurVleugelBinnenLijnInfo? besteInfo;
    var besteAfstand = double.infinity;

    for (final info in lijnen) {
      final afstand = _afstandTotLijnstuk(
        punt: punt,
        start: info.lijn.start,
        einde: info.lijn.einde,
      );

      if (afstand > 14 || afstand >= besteAfstand) {
        continue;
      }

      besteAfstand = afstand;
      besteInfo = info;
    }

    return besteInfo;
  }

  List<_DeurVleugelBinnenLijnInfo> _deurVleugelBinnenLijnen(Size size) {
    if (_vleugels.isEmpty ||
        _actiefTStijlBreedteMm <= 0 ||
        _actiefTStijlHoogteMm <= 0) {
      return const <_DeurVleugelBinnenLijnInfo>[];
    }

    final buitenKader = OpmetingRaamKaderHelper.buitenKader(
      size: size,
      breedteMm: _actiefTStijlBreedteMm,
      hoogteMm: _actiefTStijlHoogteMm,
    );

    if (buitenKader.width <= 0 || buitenKader.height <= 0) {
      return const <_DeurVleugelBinnenLijnInfo>[];
    }

    final resultaat = <_DeurVleugelBinnenLijnInfo>[];

    for (final vleugel in _vleugels) {
      if (!vleugel.isDeurVleugel) {
        continue;
      }

      final binnenRect = _deurVleugelBinnenRect(
        vleugel: vleugel,
        buitenKader: buitenKader,
      );

      if (binnenRect == null ||
          binnenRect.width <= 8 ||
          binnenRect.height <= 8) {
        continue;
      }

      void voegLijnToe({
        required String zijde,
        required Offset start,
        required Offset einde,
      }) {
        resultaat.add(
          _DeurVleugelBinnenLijnInfo(
            vleugel: vleugel,
            binnenRect: binnenRect,
            zijde: zijde,
            lijn: OpmetingRaamLijn(
              id: 'deurvleugel:${vleugel.id}:$zijde',
              start: start,
              einde: einde,
            ),
          ),
        );
      }

      voegLijnToe(
        zijde: 'links',
        start: binnenRect.topLeft,
        einde: binnenRect.bottomLeft,
      );
      voegLijnToe(
        zijde: 'rechts',
        start: binnenRect.topRight,
        einde: binnenRect.bottomRight,
      );
      voegLijnToe(
        zijde: 'boven',
        start: binnenRect.topLeft,
        einde: binnenRect.topRight,
      );
      voegLijnToe(
        zijde: 'onder',
        start: binnenRect.bottomLeft,
        einde: binnenRect.bottomRight,
      );
    }

    for (final stijl in _tStijlen) {
      if (!stijl.werkvlakId.startsWith('deurvleugel_')) {
        continue;
      }

      final vleugelId = stijl.werkvlakId.substring('deurvleugel_'.length);
      OpmetingRaamVleugel? deurVleugel;

      for (final vleugel in _vleugels) {
        if (vleugel.id == vleugelId && vleugel.isDeurVleugel) {
          deurVleugel = vleugel;
          break;
        }
      }

      if (deurVleugel == null) {
        continue;
      }

      final binnenRect = _deurVleugelBinnenRect(
        vleugel: deurVleugel,
        buitenKader: buitenKader,
      );

      if (binnenRect == null) {
        continue;
      }

      final actueleLijn = _lijnVoorTStijlInDeurWerkvlak(
        stijl: stijl,
        werkvlak: binnenRect,
      );

      resultaat.add(
        _DeurVleugelBinnenLijnInfo(
          vleugel: deurVleugel,
          binnenRect: binnenRect,
          zijde: stijl.richting == 'verticaal'
              ? 'tstijl_verticaal'
              : 'tstijl_horizontaal',
          lijn: OpmetingRaamLijn(
            id: 'deurvleugel:${deurVleugel.id}:tstijl:${stijl.id}',
            start: actueleLijn.start,
            einde: actueleLijn.einde,
          ),
        ),
      );
    }

    return List<_DeurVleugelBinnenLijnInfo>.unmodifiable(resultaat);
  }

  Rect? _deurVleugelBinnenRect({
    required OpmetingRaamVleugel vleugel,
    required Rect buitenKader,
  }) {
    if (_actiefTStijlBreedteMm <= 0 || _actiefTStijlHoogteMm <= 0) {
      return null;
    }

    final schaalX = buitenKader.width / _actiefTStijlBreedteMm;
    final schaalY = buitenKader.height / _actiefTStijlHoogteMm;

    if (!schaalX.isFinite ||
        !schaalY.isFinite ||
        schaalX <= 0 ||
        schaalY <= 0) {
      return null;
    }

    final maximaleProfielBreedteX = buitenKader.width / 3;
    final maximaleProfielBreedteY = buitenKader.height / 3;

    if (maximaleProfielBreedteX < 5 || maximaleProfielBreedteY < 5) {
      return null;
    }

    final profielBreedteX = (vleugel.deurVleugelBreedteMm * schaalX)
        .abs()
        .clamp(5.0, maximaleProfielBreedteX)
        .toDouble();
    final profielBreedteY = (vleugel.deurVleugelBreedteMm * schaalY)
        .abs()
        .clamp(5.0, maximaleProfielBreedteY)
        .toDouble();
    final onderAfstandPx = (vleugel.deurVleugelOnderAfstandMm * schaalY)
        .abs()
        .clamp(0.0, buitenKader.height / 4)
        .toDouble();

    final deurRect = Rect.fromLTRB(
      vleugel.vlak.left,
      vleugel.vlak.top,
      vleugel.vlak.right,
      buitenKader.bottom - onderAfstandPx,
    );

    if (deurRect.width <= profielBreedteX * 2 + 8 ||
        deurRect.height <= profielBreedteY * 2 + 8) {
      return null;
    }

    return Rect.fromLTRB(
      deurRect.left + profielBreedteX,
      deurRect.top + profielBreedteY,
      deurRect.right - profielBreedteX,
      deurRect.bottom - profielBreedteY,
    );
  }

  double _afstandTotLijnstuk({
    required Offset punt,
    required Offset start,
    required Offset einde,
  }) {
    final dx = einde.dx - start.dx;
    final dy = einde.dy - start.dy;
    final lengteKwadraat = dx * dx + dy * dy;

    if (lengteKwadraat <= 0) {
      return (punt - start).distance;
    }

    final t =
        (((punt.dx - start.dx) * dx + (punt.dy - start.dy) * dy) /
                lengteKwadraat)
            .clamp(0.0, 1.0)
            .toDouble();

    final projectie = Offset(start.dx + dx * t, start.dy + dy * t);

    return (punt - projectie).distance;
  }

  void _meldOverzichtTekeningGewijzigd({
    required Size tekenvlakGrootte,
    required List<OpmetingRaamVulvlak> vulvlakken,
    required Map<String, List<OpmetingRaamVulvlak>> vulvlakkenPerKader,
    required Map<String, List<OpmetingRaamTStijl>> tStijlenPerKader,
    required Map<String, List<OpmetingRaamVleugel>> vleugelsPerKader,
    required Map<String, List<OpmetingRaamVullingToewijzing>>
    vullingToewijzingenPerKader,
    required Map<String, List<OpmetingRaamKleinhout>> kleinhoutenPerKader,
  }) {
    final callback = widget.onOverzichtTekeningGewijzigd;

    if (callback == null) {
      return;
    }

    final data = OpmetingRaamTekenvlakOverzichtDataHelper.maakTekeningData(
      tekenvlakGrootte: tekenvlakGrootte,
      tStijlen: _tStijlen,
      tStijlenPerKader: tStijlenPerKader,
      vleugels: _vleugels,
      vleugelsPerKader: vleugelsPerKader,
      vulvlakken: vulvlakken,
      vulvlakkenPerKader: vulvlakkenPerKader,
      vullingToewijzingen: _vullingToewijzingen,
      vullingToewijzingenPerKader: vullingToewijzingenPerKader,
      kleinhouten: _kleinhouten,
      kleinhoutenPerKader: kleinhoutenPerKader,
      technischeTekeningen: widget.technischeTekeningen,
      technischeTekeningenPerKader: widget.technischeTekeningenPerKader,
      technischeTekeningenPerKaderGroep:
          widget.technischeTekeningenPerKaderGroep,
      technischeKaderGroepen: widget.technischeKaderGroepen,
    );

    final signatuur = data.wijzigingsSignatuur;

    if (signatuur == _laatsteOverzichtTekeningSignatuur) {
      return;
    }

    _laatsteOverzichtTekeningSignatuur = signatuur;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      callback(data);
    });
  }

  Offset? _previewPunt(Size size) {
    return OpmetingRaamTStijlActieHelper.bepaalPreviewPunt(
      geselecteerdeLijn: _geselecteerdeLijn,
      tekenvlakGrootte: size,
      breedteMm: _actiefTStijlBreedteMm,
      hoogteMm: _actiefTStijlHoogteMm,
      positieType: _positieType,
      positieTekst: widget.positieController.text,
    );
  }

  void _tStijlToevoegen() {
    final size = _actueleTekenvlakGrootte();

    if (size == null) {
      return;
    }

    if (_voegTStijlToeInDeurVleugel(size)) {
      return;
    }

    final resultaat = OpmetingRaamTStijlActieHelper.voegToe(
      geselecteerdeLijn: _geselecteerdeLijn,
      tekenvlakGrootte: size,
      breedteMm: _actiefTStijlBreedteMm,
      hoogteMm: _actiefTStijlHoogteMm,
      positieType: _positieType,
      positieTekst: widget.positieController.text,
      bestaandeTStijlen: _tStijlen,
      bestaandeVleugels: _vleugels,
    );

    if (!resultaat.gewijzigd) {
      return;
    }

    _bewaarVoorWijziging();

    setState(() {
      _vervangTStijlen(resultaat.tStijlen);

      _bewaarTStijlenVoorActiefKader();

      _wisTekeningSelecties();
      _schoonVullingEnKleinhoutenOp();
    });

    _planAlleLegendaMeldingen();
  }

  bool _voegTStijlToeInDeurVleugel(Size size) {
    final lijn = _geselecteerdeLijn;

    if (lijn == null || !lijn.id.startsWith('deurvleugel:')) {
      return false;
    }

    _DeurVleugelBinnenLijnInfo? info;

    for (final kandidaat in _deurVleugelBinnenLijnen(size)) {
      if (kandidaat.lijn.id == lijn.id) {
        info = kandidaat;
        break;
      }
    }

    if (info == null) {
      return false;
    }

    final binnenRect = info.binnenRect;

    if (binnenRect.width <= 12 || binnenRect.height <= 12) {
      return false;
    }

    final geselecteerdeLijnIsHorizontaal = info.lijn.isHorizontaal;
    final richting = geselecteerdeLijnIsHorizontaal
        ? 'verticaal'
        : 'horizontaal';

    final positie = geselecteerdeLijnIsHorizontaal
        ? _berekenTStijlPositieInDeurVleugel(
            lengtePx: binnenRect.width,
            lengteMm: _actiefTStijlBreedteMm,
          )
        : _berekenTStijlPositieInDeurVleugel(
            lengtePx: binnenRect.height,
            lengteMm: _actiefTStijlHoogteMm,
          );

    final marge = 6.0;

    late final Offset start;
    late final Offset einde;

    if (geselecteerdeLijnIsHorizontaal) {
      final x = (binnenRect.left + positie)
          .clamp(binnenRect.left + marge, binnenRect.right - marge)
          .toDouble();
      start = Offset(x, binnenRect.top);
      einde = Offset(x, binnenRect.bottom);
    } else {
      final y = (binnenRect.top + positie)
          .clamp(binnenRect.top + marge, binnenRect.bottom - marge)
          .toDouble();
      start = Offset(binnenRect.left, y);
      einde = Offset(binnenRect.right, y);
    }

    final positieFractie = geselecteerdeLijnIsHorizontaal
        ? ((start.dx - binnenRect.left) / binnenRect.width)
              .clamp(0.0, 1.0)
              .toDouble()
        : ((start.dy - binnenRect.top) / binnenRect.height)
              .clamp(0.0, 1.0)
              .toDouble();

    final nieuweTStijl = OpmetingRaamTStijl(
      id: 'tstijl_${DateTime.now().microsecondsSinceEpoch}',
      richting: richting,
      start: start,
      einde: einde,
      breedteMm: 90,
      werkvlakId: 'deurvleugel_${info.vleugel.id}',
      positieFractie: positieFractie,
    );

    _bewaarVoorWijziging();

    setState(() {
      _vervangTStijlen(<OpmetingRaamTStijl>[..._tStijlen, nieuweTStijl]);

      _bewaarTStijlenVoorActiefKader();

      _wisTekeningSelecties();
      _schoonVullingEnKleinhoutenOp();
    });

    _planAlleLegendaMeldingen();

    return true;
  }

  double _berekenTStijlPositieInDeurVleugel({
    required double lengtePx,
    required int lengteMm,
  }) {
    final fractie = _fractieVoorTStijlPositieType(_positieType);

    if (fractie != null) {
      return lengtePx * fractie;
    }

    final tekst = widget.positieController.text.trim().replaceAll(',', '.');
    final mm = double.tryParse(tekst) ?? 0;

    if (lengteMm <= 0) {
      return lengtePx / 2;
    }

    return (mm * lengtePx / lengteMm).clamp(0.0, lengtePx).toDouble();
  }

  double? _fractieVoorTStijlPositieType(String waarde) {
    switch (waarde) {
      case '1/2':
        return 0.5;
      case '1/3':
        return 1 / 3;
      case '2/3':
        return 2 / 3;
      case '1/4':
        return 0.25;
      case '2/4':
        return 0.5;
      case '3/4':
        return 0.75;
      default:
        return null;
    }
  }

  void _verplaatsGeselecteerdeTStijl() {
    final size = _actueleTekenvlakGrootte();

    if (size == null) {
      return;
    }

    final resultaat = OpmetingRaamTStijlVerplaatsingActieHelper.verplaats(
      geselecteerdeLijn: _geselecteerdeLijn,
      tekenvlakGrootte: size,
      breedteMm: _actiefTStijlBreedteMm,
      hoogteMm: _actiefTStijlHoogteMm,
      positieType: _positieType,
      positieTekst: widget.positieController.text,
      bestaandeTStijlen: _tStijlen,
      bestaandeVleugels: _vleugels,
      bestaandeVullingToewijzingen: _vullingToewijzingen,
      bestaandeKleinhouten: _kleinhouten,
    );

    if (!resultaat.gewijzigd) {
      OpmetingRaamSnackBarHelper.toonFoutIndienAanwezig(
        context,
        resultaat.foutmelding,
      );

      return;
    }

    _bewaarVoorWijziging();

    setState(() {
      _vervangVolledigeTekening(
        tStijlen: resultaat.tStijlen,
        vleugels: resultaat.vleugels,
        vullingToewijzingen: resultaat.vullingToewijzingen,
        kleinhouten: resultaat.kleinhouten,
      );

      _bewaarTStijlenVoorActiefKader();

      _wisTekeningSelecties();
    });

    _planAlleLegendaMeldingen();
  }

  void _wisTStijlVanGeselecteerdeLijn() {
    final size = _actueleTekenvlakGrootte();

    if (size == null) {
      return;
    }

    final resultaat = OpmetingRaamTStijlActieHelper.verwijder(
      geselecteerdeLijn: _geselecteerdeLijn,
      tekenvlakGrootte: size,
      breedteMm: _actiefTStijlBreedteMm,
      hoogteMm: _actiefTStijlHoogteMm,
      bestaandeTStijlen: _tStijlen,
      bestaandeVleugels: _vleugels,
    );

    if (!resultaat.gewijzigd) {
      OpmetingRaamSnackBarHelper.toonFoutIndienAanwezig(
        context,
        resultaat.foutmelding,
      );

      return;
    }

    _bewaarVoorWijziging();

    setState(() {
      _vervangTStijlen(resultaat.tStijlen);

      _bewaarTStijlenVoorActiefKader();

      _wisTekeningSelecties();
      _schoonVullingEnKleinhoutenOp();
    });

    _planAlleLegendaMeldingen();
  }

  void _pasVleugelToe(Offset punt) {
    final size = _actueleTekenvlakGrootte();

    if (size == null) {
      return;
    }

    final resultaat = OpmetingRaamVleugelActieHelper.pasToe(
      punt: punt,
      tekenvlakGrootte: size,
      breedteMm: _actiefVleugelBreedteMm,
      hoogteMm: _actiefVleugelHoogteMm,
      geselecteerdVleugelType: _geselecteerdVleugelType,
      bestaandeTStijlen: _tStijlen,
      bestaandeVleugels: _vleugels,
      bestaandeVullingToewijzingen: _vullingToewijzingen,
      bestaandeKleinhouten: _kleinhouten,
    );

    if (!resultaat.gewijzigd) {
      return;
    }

    _bewaarVoorWijziging();

    setState(() {
      _vervangVolledigeTekening(
        tStijlen: resultaat.tStijlen,
        vleugels: resultaat.vleugels,
        vullingToewijzingen: resultaat.vullingToewijzingen,
        kleinhouten: resultaat.kleinhouten,
      );

      _bewaarTStijlenVoorActiefKader();
      _bewaarVleugelsVoorActiefKader();

      _geselecteerdeLijn = null;

      _vervangVulvlakSelectie(resultaat.geselecteerdeVulvlakIds);
      _vervangKleinhoutVlakSelectie(resultaat.geselecteerdeKleinhoutVlakIds);
    });

    _planAlleLegendaMeldingen();
  }

  Future<void> _pasDeurVleugelToe(Offset punt) async {
    final size = _actueleTekenvlakGrootte();

    if (size == null) {
      return;
    }

    final bestaandeGroep = _deurVleugelGroepVoorPunt(punt);

    if (bestaandeGroep.isNotEmpty) {
      final bestaandeVleugel = bestaandeGroep.first;

      final keuze = await _toonDeurVleugelKeuzeMenu(
        bestaandeVleugel: bestaandeVleugel,
        toonWissen: true,
      );

      if (!mounted || keuze == null) {
        return;
      }

      final groepId = bestaandeVleugel.deurVleugelGroepId.trim();
      final bestaandeIds = bestaandeGroep.map((vleugel) => vleugel.id).toSet();

      bool hoortBijBestaandeGroep(OpmetingRaamVleugel vleugel) {
        if (!vleugel.isDeurVleugel) {
          return false;
        }

        if (groepId.isNotEmpty) {
          return vleugel.deurVleugelGroepId == groepId;
        }

        return bestaandeIds.contains(vleugel.id);
      }

      if (keuze.wissen) {
        final teVerwijderenWerkvlakIds = _deurVleugelWerkvlakIdsVoorVleugels(
          bestaandeGroep,
        );

        _bewaarVoorWijziging();

        setState(() {
          _vervangVleugels(
            _vleugels.where((vleugel) {
              return !hoortBijBestaandeGroep(vleugel);
            }).toList(),
          );

          _vervangTStijlen(
            _tStijlen.where((stijl) {
              return !teVerwijderenWerkvlakIds.contains(stijl.werkvlakId);
            }).toList(),
          );

          _bewaarVleugelsVoorActiefKader();
          _bewaarTStijlenVoorActiefKader();
          _geselecteerdeLijn = null;
          _wisTekeningSelecties();
          _schoonVullingEnKleinhoutenOp();
        });

        _planAlleLegendaMeldingen();
        return;
      }

      final bestaandVlak = OpmetingRaamVulvlak(
        id: 'bestaande_deurvleugel_${bestaandeVleugel.id}',
        werkvlakId: 'kader',
        vlak: _samengevoegdVlakVoorDeurVleugels(bestaandeGroep),
      );

      final gemaakteDeurVleugels = keuze.isDubbel
          ? _maakDubbeleDeurVleugels(
              vulvlak: bestaandVlak,
              size: size,
              keuze: keuze,
            )
          : <OpmetingRaamVleugel>[
              _maakEnkeleDeurVleugel(vulvlak: bestaandVlak, keuze: keuze),
            ];

      if (gemaakteDeurVleugels.isEmpty) {
        OpmetingRaamSnackBarHelper.toonWaarschuwing(
          context,
          'De dubbele deur kan niet in dit te smalle vlak geplaatst worden.',
        );
        return;
      }

      final nieuweDeurVleugels = _behoudBestaandeDeurVleugelIds(
        oudeGroep: bestaandeGroep,
        nieuweGroep: gemaakteDeurVleugels,
      );

      final aangepasteTStijlen = _pasTStijlenAanVoorGewijzigdeDeurVleugel(
        size: size,
        oudeDeurVleugels: bestaandeGroep,
        nieuweDeurVleugels: nieuweDeurVleugels,
        bestaandeTStijlen: _tStijlen,
      );

      _bewaarVoorWijziging();

      setState(() {
        _vervangVleugels(<OpmetingRaamVleugel>[
          ..._vleugels.where((vleugel) {
            return !hoortBijBestaandeGroep(vleugel);
          }),
          ...nieuweDeurVleugels,
        ]);

        _vervangTStijlen(aangepasteTStijlen);

        _bewaarVleugelsVoorActiefKader();
        _bewaarTStijlenVoorActiefKader();
        _geselecteerdeLijn = null;
        _wisTekeningSelecties();
        _schoonVullingEnKleinhoutenOp();
      });

      _planAlleLegendaMeldingen();
      return;
    }

    final vulvlak = OpmetingRaamVullingHelper.vindVulvlak(
      punt: punt,
      vulvlakken: _bepaalVulvlakken(size),
    );

    if (vulvlak == null) {
      OpmetingRaamSnackBarHelper.toonWaarschuwing(
        context,
        'Klik binnen een leeg deurvlak om een deurvleugel te plaatsen.',
      );
      return;
    }

    final keuze = await _toonDeurVleugelKeuzeMenu();

    if (!mounted || keuze == null || keuze.wissen) {
      return;
    }

    final nieuweDeurVleugels = keuze.isDubbel
        ? _maakDubbeleDeurVleugels(vulvlak: vulvlak, size: size, keuze: keuze)
        : <OpmetingRaamVleugel>[
            _maakEnkeleDeurVleugel(vulvlak: vulvlak, keuze: keuze),
          ];

    if (nieuweDeurVleugels.isEmpty) {
      OpmetingRaamSnackBarHelper.toonWaarschuwing(
        context,
        'De dubbele deur kan niet in dit te smalle vlak geplaatst worden.',
      );
      return;
    }

    final nieuweVlak = vulvlak.vlak.inflate(2);

    _bewaarVoorWijziging();

    setState(() {
      _vervangVleugels(<OpmetingRaamVleugel>[
        ..._vleugels.where((vleugel) {
          if (!vleugel.isDeurVleugel) {
            return true;
          }

          return !nieuweVlak.overlaps(vleugel.vlak.inflate(2));
        }),
        ...nieuweDeurVleugels,
      ]);

      _bewaarVleugelsVoorActiefKader();

      _geselecteerdeLijn = null;
      _wisTekeningSelecties();
      _schoonVullingEnKleinhoutenOp();
    });

    _planAlleLegendaMeldingen();
  }

  List<OpmetingRaamVleugel> _deurVleugelGroepVoorPunt(Offset punt) {
    final aangeklikteDeurVleugel = _vleugels.where((vleugel) {
      return vleugel.isDeurVleugel && vleugel.vlak.inflate(8).contains(punt);
    }).toList();

    if (aangeklikteDeurVleugel.isEmpty) {
      return const <OpmetingRaamVleugel>[];
    }

    final basisVleugel = aangeklikteDeurVleugel.first;
    final groepId = basisVleugel.deurVleugelGroepId.trim();

    if (groepId.isEmpty) {
      return <OpmetingRaamVleugel>[basisVleugel];
    }

    return _vleugels.where((vleugel) {
      return vleugel.isDeurVleugel && vleugel.deurVleugelGroepId == groepId;
    }).toList();
  }

  Rect _samengevoegdVlakVoorDeurVleugels(
    List<OpmetingRaamVleugel> deurVleugels,
  ) {
    if (deurVleugels.isEmpty) {
      return Rect.zero;
    }

    var vlak = deurVleugels.first.vlak;

    for (final deurVleugel in deurVleugels.skip(1)) {
      vlak = vlak.expandToInclude(deurVleugel.vlak);
    }

    return vlak;
  }

  List<OpmetingRaamVleugel> _behoudBestaandeDeurVleugelIds({
    required List<OpmetingRaamVleugel> oudeGroep,
    required List<OpmetingRaamVleugel> nieuweGroep,
  }) {
    if (oudeGroep.isEmpty || nieuweGroep.isEmpty) {
      return nieuweGroep;
    }

    String? bestaandeGroepId;

    for (final oudeVleugel in oudeGroep) {
      final groepId = oudeVleugel.deurVleugelGroepId.trim();

      if (groepId.isNotEmpty) {
        bestaandeGroepId = groepId;
        break;
      }
    }

    final oudePerDeel = <OpmetingRaamDeurVleugelDeel, OpmetingRaamVleugel>{};

    for (final oudeVleugel in oudeGroep) {
      oudePerDeel[oudeVleugel.deurVleugelDeel] = oudeVleugel;
    }

    return nieuweGroep.map((nieuweVleugel) {
      final overeenkomstigeOudeVleugel =
          oudePerDeel[nieuweVleugel.deurVleugelDeel];

      if (overeenkomstigeOudeVleugel == null) {
        return nieuweVleugel.copyWith(
          deurVleugelGroepId:
              bestaandeGroepId ?? nieuweVleugel.deurVleugelGroepId,
        );
      }

      return nieuweVleugel.copyWith(
        id: overeenkomstigeOudeVleugel.id,
        deurVleugelGroepId:
            bestaandeGroepId ?? overeenkomstigeOudeVleugel.deurVleugelGroepId,
      );
    }).toList();
  }

  List<OpmetingRaamTStijl> _pasTStijlenAanVoorGewijzigdeDeurVleugel({
    required Size size,
    required List<OpmetingRaamVleugel> oudeDeurVleugels,
    required List<OpmetingRaamVleugel> nieuweDeurVleugels,
    required List<OpmetingRaamTStijl> bestaandeTStijlen,
  }) {
    final buitenKader = OpmetingRaamKaderHelper.buitenKader(
      size: size,
      breedteMm: _actiefTStijlBreedteMm,
      hoogteMm: _actiefTStijlHoogteMm,
    );

    if (buitenKader.width <= 0 || buitenKader.height <= 0) {
      return bestaandeTStijlen;
    }

    final oudeWerkvlakken = _deurVleugelWerkvlakkenVoorVleugels(
      deurVleugels: oudeDeurVleugels,
      buitenKader: buitenKader,
    );
    final nieuweWerkvlakken = _deurVleugelWerkvlakkenVoorVleugels(
      deurVleugels: nieuweDeurVleugels,
      buitenKader: buitenKader,
    );

    if (oudeWerkvlakken.isEmpty) {
      return bestaandeTStijlen;
    }

    final werkvlakKoppelingen = <String, String>{};

    for (final oudeVleugel in oudeDeurVleugels) {
      OpmetingRaamVleugel? nieuweVleugel;

      for (final kandidaat in nieuweDeurVleugels) {
        if (kandidaat.id == oudeVleugel.id &&
            kandidaat.deurVleugelDeel == oudeVleugel.deurVleugelDeel) {
          nieuweVleugel = kandidaat;
          break;
        }
      }

      if (nieuweVleugel == null) {
        continue;
      }

      werkvlakKoppelingen[_deurVleugelWerkvlakId(oudeVleugel)] =
          _deurVleugelWerkvlakId(nieuweVleugel);
    }

    final resultaat = <OpmetingRaamTStijl>[];

    for (final stijl in bestaandeTStijlen) {
      final oudWerkvlakId = _vindOudDeurWerkvlakIdVoorTStijl(
        stijl: stijl,
        oudeWerkvlakken: oudeWerkvlakken,
      );

      if (oudWerkvlakId == null) {
        resultaat.add(stijl);
        continue;
      }

      final oudWerkvlak = oudeWerkvlakken[oudWerkvlakId];
      final nieuwWerkvlakId = werkvlakKoppelingen[oudWerkvlakId];
      final nieuwWerkvlak = nieuwWerkvlakId == null
          ? null
          : nieuweWerkvlakken[nieuwWerkvlakId];

      if (oudWerkvlak == null ||
          nieuwWerkvlak == null ||
          oudWerkvlak.width <= 0 ||
          oudWerkvlak.height <= 0 ||
          nieuwWerkvlak.width <= 0 ||
          nieuwWerkvlak.height <= 0) {
        continue;
      }

      resultaat.add(
        _schaalTStijlBinnenDeurWerkvlak(
          stijl: stijl,
          oudWerkvlak: oudWerkvlak,
          nieuwWerkvlak: nieuwWerkvlak,
          nieuwWerkvlakId: nieuwWerkvlakId!,
        ),
      );
    }

    return resultaat;
  }

  String? _vindOudDeurWerkvlakIdVoorTStijl({
    required OpmetingRaamTStijl stijl,
    required Map<String, Rect> oudeWerkvlakken,
  }) {
    if (oudeWerkvlakken.containsKey(stijl.werkvlakId)) {
      return stijl.werkvlakId;
    }

    // Oudere of fout aangemaakte T-stijlen in een deurvleugel kunnen nog
    // werkvlakId 'kader' hebben. Die moeten bij een middenverschuiving toch
    // mee naar het juiste deurdeel. Daarom zoeken we niet enkel op werkvlakId,
    // maar ook op de echte positie van de T-stijl binnen de oude deurvlakken.
    final controlePunt = _controlePuntVoorTStijl(stijl);

    String? besteWerkvlakId;
    var besteAfstand = double.infinity;

    for (final entry in oudeWerkvlakken.entries) {
      final vlak = entry.value;

      if (vlak.inflate(8).contains(controlePunt)) {
        return entry.key;
      }

      if (_tStijlLijnRect(stijl).overlaps(vlak.inflate(8))) {
        return entry.key;
      }

      final afstand = (controlePunt - vlak.center).distance;

      if (afstand < besteAfstand) {
        besteAfstand = afstand;
        besteWerkvlakId = entry.key;
      }
    }

    if (stijl.werkvlakId.startsWith('deurvleugel_')) {
      return besteWerkvlakId;
    }

    // Voor T-stijlen die per ongeluk nog op 'kader' staan, koppelen we enkel
    // automatisch wanneer het lijnstuk duidelijk in of tegen een oud
    // deurwerkvlak ligt. Zo verplaatsen gewone kader-T-stijlen niet mee.
    for (final entry in oudeWerkvlakken.entries) {
      final vlak = entry.value.inflate(18);
      final lijnRect = _tStijlLijnRect(stijl);

      if (lijnRect.overlaps(vlak) || vlak.contains(controlePunt)) {
        return entry.key;
      }
    }

    return null;
  }

  Offset _controlePuntVoorTStijl(OpmetingRaamTStijl stijl) {
    return Offset(
      (stijl.start.dx + stijl.einde.dx) / 2,
      (stijl.start.dy + stijl.einde.dy) / 2,
    );
  }

  Rect _tStijlLijnRect(OpmetingRaamTStijl stijl) {
    const marge = 3.0;

    final left = stijl.start.dx < stijl.einde.dx
        ? stijl.start.dx
        : stijl.einde.dx;
    final right = stijl.start.dx > stijl.einde.dx
        ? stijl.start.dx
        : stijl.einde.dx;
    final top = stijl.start.dy < stijl.einde.dy
        ? stijl.start.dy
        : stijl.einde.dy;
    final bottom = stijl.start.dy > stijl.einde.dy
        ? stijl.start.dy
        : stijl.einde.dy;

    return Rect.fromLTRB(left, top, right, bottom).inflate(marge);
  }

  Set<String> _deurVleugelWerkvlakIdsVoorVleugels(
    List<OpmetingRaamVleugel> deurVleugels,
  ) {
    return deurVleugels
        .where((vleugel) => vleugel.isDeurVleugel)
        .map(_deurVleugelWerkvlakId)
        .toSet();
  }

  Map<String, Rect> _deurVleugelWerkvlakkenVoorVleugels({
    required List<OpmetingRaamVleugel> deurVleugels,
    required Rect buitenKader,
  }) {
    final resultaat = <String, Rect>{};

    for (final deurVleugel in deurVleugels) {
      if (!deurVleugel.isDeurVleugel) {
        continue;
      }

      final binnenRect = _deurVleugelBinnenRect(
        vleugel: deurVleugel,
        buitenKader: buitenKader,
      );

      if (binnenRect == null ||
          binnenRect.width <= 0 ||
          binnenRect.height <= 0) {
        continue;
      }

      resultaat[_deurVleugelWerkvlakId(deurVleugel)] = binnenRect;
    }

    return resultaat;
  }

  String _deurVleugelWerkvlakId(OpmetingRaamVleugel deurVleugel) {
    return 'deurvleugel_${deurVleugel.id}';
  }

  OpmetingRaamTStijl _schaalTStijlBinnenDeurWerkvlak({
    required OpmetingRaamTStijl stijl,
    required Rect oudWerkvlak,
    required Rect nieuwWerkvlak,
    required String nieuwWerkvlakId,
  }) {
    final fractie = _positieFractieVoorTStijlInWerkvlak(
      stijl: stijl,
      werkvlak: oudWerkvlak,
    );
    final actueleLijn = _lijnVoorTStijlInDeurWerkvlak(
      stijl: stijl.copyWith(
        werkvlakId: nieuwWerkvlakId,
        positieFractie: fractie,
      ),
      werkvlak: nieuwWerkvlak,
    );

    return stijl.copyWith(
      start: actueleLijn.start,
      einde: actueleLijn.einde,
      werkvlakId: nieuwWerkvlakId,
      positieFractie: fractie,
    );
  }

  double _positieFractieVoorTStijlInWerkvlak({
    required OpmetingRaamTStijl stijl,
    required Rect werkvlak,
  }) {
    final opgeslagenFractie = stijl.positieFractie;

    if (opgeslagenFractie != null && opgeslagenFractie.isFinite) {
      return opgeslagenFractie.clamp(0.0, 1.0).toDouble();
    }

    if (stijl.richting == 'verticaal') {
      if (werkvlak.width <= 0) {
        return 0.5;
      }

      return ((stijl.start.dx - werkvlak.left) / werkvlak.width)
          .clamp(0.0, 1.0)
          .toDouble();
    }

    if (werkvlak.height <= 0) {
      return 0.5;
    }

    return ((stijl.start.dy - werkvlak.top) / werkvlak.height)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  OpmetingRaamLijn _lijnVoorTStijlInDeurWerkvlak({
    required OpmetingRaamTStijl stijl,
    required Rect werkvlak,
  }) {
    final fractie = _positieFractieVoorTStijlInWerkvlak(
      stijl: stijl,
      werkvlak: werkvlak,
    );

    if (stijl.richting == 'verticaal') {
      final x = (werkvlak.left + werkvlak.width * fractie)
          .clamp(werkvlak.left, werkvlak.right)
          .toDouble();

      return OpmetingRaamLijn(
        id: stijl.id,
        start: Offset(x, werkvlak.top),
        einde: Offset(x, werkvlak.bottom),
      );
    }

    final y = (werkvlak.top + werkvlak.height * fractie)
        .clamp(werkvlak.top, werkvlak.bottom)
        .toDouble();

    return OpmetingRaamLijn(
      id: stijl.id,
      start: Offset(werkvlak.left, y),
      einde: Offset(werkvlak.right, y),
    );
  }

  OpmetingRaamVleugel _maakEnkeleDeurVleugel({
    required OpmetingRaamVulvlak vulvlak,
    required _DeurVleugelPlaatsKeuze keuze,
  }) {
    final tijd = DateTime.now().microsecondsSinceEpoch;

    return OpmetingRaamVleugel(
      id: 'deurvleugel_$tijd',
      vlak: vulvlak.vlak,
      type: OpmetingRaamVleugelType.vastDubbeleKader,
      isDeurVleugel: true,
      deurVleugelBreedteMm: 100,
      deurVleugelOnderAfstandMm: 5,
      deurVleugelSoort: OpmetingRaamDeurVleugelSoort.achterdeur,
      deurVleugelKrukType: keuze.krukType,
      deurVleugelKrukZijde: keuze.krukZijde,
      deurDraairichting: keuze.draairichting,
      deurVleugelAantal: OpmetingRaamDeurVleugelAantal.enkel,
      deurVleugelDeel: OpmetingRaamDeurVleugelDeel.enkel,
      deurKrukPlaatsing: keuze.krukPlaatsing,
      deurVleugelMiddenVerschuivingMm: 0,
      deurVleugelGroepId: 'deurvleugelgroep_$tijd',
    );
  }

  List<OpmetingRaamVleugel> _maakDubbeleDeurVleugels({
    required OpmetingRaamVulvlak vulvlak,
    required Size size,
    required _DeurVleugelPlaatsKeuze keuze,
  }) {
    final buitenKader = OpmetingRaamKaderHelper.buitenKader(
      size: size,
      breedteMm: _actiefVleugelBreedteMm,
      hoogteMm: _actiefVleugelHoogteMm,
    );

    if (buitenKader.width <= 0 || _actiefVleugelBreedteMm <= 0) {
      return const <OpmetingRaamVleugel>[];
    }

    final schaalX = buitenKader.width / _actiefVleugelBreedteMm;
    final verschuivingPx = keuze.middenVerschuivingMm * schaalX;
    final minimaleVleugelBreedte = vulvlak.vlak.width * 0.22;

    final splitX = (vulvlak.vlak.center.dx + verschuivingPx)
        .clamp(
          vulvlak.vlak.left + minimaleVleugelBreedte,
          vulvlak.vlak.right - minimaleVleugelBreedte,
        )
        .toDouble();

    final linksVlak = Rect.fromLTRB(
      vulvlak.vlak.left,
      vulvlak.vlak.top,
      splitX,
      vulvlak.vlak.bottom,
    );

    final rechtsVlak = Rect.fromLTRB(
      splitX,
      vulvlak.vlak.top,
      vulvlak.vlak.right,
      vulvlak.vlak.bottom,
    );

    if (linksVlak.width < 24 || rechtsVlak.width < 24) {
      return const <OpmetingRaamVleugel>[];
    }

    final tijd = DateTime.now().microsecondsSinceEpoch;
    final groepId = 'deurvleugelgroep_$tijd';

    OpmetingRaamVleugel maakDeel({
      required Rect vlak,
      required OpmetingRaamDeurVleugelDeel deel,
    }) {
      return OpmetingRaamVleugel(
        id: '${groepId}_${deel.opslagWaarde}',
        vlak: vlak,
        type: OpmetingRaamVleugelType.vastDubbeleKader,
        isDeurVleugel: true,
        deurVleugelBreedteMm: 100,
        deurVleugelOnderAfstandMm: 5,
        deurVleugelSoort: OpmetingRaamDeurVleugelSoort.achterdeur,
        deurVleugelKrukType: keuze.krukType,
        deurVleugelKrukZijde: keuze.krukZijde,
        deurDraairichting: keuze.draairichting,
        deurVleugelAantal: OpmetingRaamDeurVleugelAantal.dubbel,
        deurVleugelDeel: deel,
        deurKrukPlaatsing: keuze.krukPlaatsing,
        deurVleugelMiddenVerschuivingMm: keuze.middenVerschuivingMm,
        deurVleugelGroepId: groepId,
      );
    }

    return <OpmetingRaamVleugel>[
      maakDeel(vlak: linksVlak, deel: OpmetingRaamDeurVleugelDeel.links),
      maakDeel(vlak: rechtsVlak, deel: OpmetingRaamDeurVleugelDeel.rechts),
    ];
  }

  String _deurVleugelMenuKeuzeVoorBestaandeVleugel(
    OpmetingRaamVleugel? bestaandeVleugel,
  ) {
    if (bestaandeVleugel == null) {
      return 'enkel_links';
    }

    final zijde =
        bestaandeVleugel.deurVleugelKrukZijde == OpmetingRaamKrukZijde.rechts
        ? 'rechts'
        : 'links';

    if (bestaandeVleugel.isDubbeleDeurVleugel) {
      return 'dubbel_$zijde';
    }

    return 'enkel_$zijde';
  }

  Future<_DeurVleugelPlaatsKeuze?> _toonDeurVleugelKeuzeMenu({
    OpmetingRaamVleugel? bestaandeVleugel,
    bool toonWissen = false,
  }) {
    return showDialog<_DeurVleugelPlaatsKeuze>(
      context: context,
      builder: (dialogContext) {
        var draairichting =
            bestaandeVleugel?.deurDraairichting ??
            OpmetingRaamDeurDraairichting.binnendraaiend;
        var vleugelKeuze = _deurVleugelMenuKeuzeVoorBestaandeVleugel(
          bestaandeVleugel,
        );
        var krukPlaatsing =
            bestaandeVleugel?.deurKrukPlaatsing ??
            OpmetingRaamDeurKrukPlaatsing.binnen;
        var rolluikkruk =
            bestaandeVleugel?.deurVleugelKrukType ==
            OpmetingRaamDeurVleugelKrukType.rolluikkruk;
        final verschuivingController = TextEditingController(
          text: '${bestaandeVleugel?.deurVleugelMiddenVerschuivingMm ?? 0}',
        );

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDubbel = vleugelKeuze.startsWith('dubbel');

            Widget sectieTitel(String tekst) {
              return Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 7),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    tekst,
                    style: const TextStyle(
                      color: Color(0xFF0B7A3B),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              );
            }

            Widget keuzeKnop({
              required bool geselecteerd,
              required String titel,
              required VoidCallback onTap,
            }) {
              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: geselecteerd
                        ? const Color(0xFFE7F6EC)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: geselecteerd
                          ? const Color(0xFF0B7A3B)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        geselecteerd
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 17,
                        color: geselecteerd
                            ? const Color(0xFF0B7A3B)
                            : const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          titel,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: geselecteerd
                                ? const Color(0xFF0B7A3B)
                                : const Color(0xFF111827),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            Widget deurVleugelKaart({
              required String keuzeWaarde,
              required String titel,
              required String ondertitel,
              required OpmetingRaamDeurVleugelAantal aantal,
              required OpmetingRaamKrukZijde krukZijde,
            }) {
              final geselecteerd = vleugelKeuze == keuzeWaarde;

              return SizedBox(
                width: 246,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setDialogState(() {
                      vleugelKeuze = keuzeWaarde;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: geselecteerd
                          ? const Color(0xFFE7F6EC)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: geselecteerd
                            ? const Color(0xFF0B7A3B)
                            : const Color(0xFFE5E7EB),
                        width: geselecteerd ? 1.6 : 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F111827),
                          blurRadius: 7,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 76,
                          height: 86,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: geselecteerd
                                  ? const Color(0xFF0B7A3B)
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: CustomPaint(
                            painter: _DeurVleugelVoorbeeldPainter(
                              aantal: aantal,
                              krukZijde: krukZijde,
                              draairichting: draairichting,
                              geselecteerd: geselecteerd,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    geselecteerd
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                    size: 17,
                                    color: geselecteerd
                                        ? const Color(0xFF0B7A3B)
                                        : const Color(0xFF9CA3AF),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      titel,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: geselecteerd
                                            ? const Color(0xFF0B7A3B)
                                            : const Color(0xFF111827),
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                ondertitel,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                draairichting ==
                                        OpmetingRaamDeurDraairichting
                                            .binnendraaiend
                                    ? 'Binnendraaiend'
                                    : 'Buitendraaiend',
                                style: TextStyle(
                                  color: geselecteerd
                                      ? const Color(0xFF0B7A3B)
                                      : const Color(0xFF374151),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              titlePadding: const EdgeInsets.fromLTRB(18, 16, 12, 0),
              contentPadding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
              actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      toonWissen
                          ? 'Deurvleugel aanpassen'
                          : 'Deurvleugel selecteren',
                      style: const TextStyle(
                        color: Color(0xFF0B7A3B),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    icon: const Icon(Icons.close_rounded),
                    color: const Color(0xFF0B7A3B),
                  ),
                ],
              ),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      sectieTitel('Draairichting'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          keuzeKnop(
                            geselecteerd:
                                draairichting ==
                                OpmetingRaamDeurDraairichting.binnendraaiend,
                            titel: 'Binnendraaiend',
                            onTap: () {
                              setDialogState(() {
                                draairichting = OpmetingRaamDeurDraairichting
                                    .binnendraaiend;
                              });
                            },
                          ),
                          keuzeKnop(
                            geselecteerd:
                                draairichting ==
                                OpmetingRaamDeurDraairichting.buitendraaiend,
                            titel: 'Buitendraaiend',
                            onTap: () {
                              setDialogState(() {
                                draairichting = OpmetingRaamDeurDraairichting
                                    .buitendraaiend;
                              });
                            },
                          ),
                        ],
                      ),
                      sectieTitel('Vleugel en krukkant'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          deurVleugelKaart(
                            keuzeWaarde: 'enkel_links',
                            titel: 'Enkele vleugel',
                            ondertitel: 'Kruk links',
                            aantal: OpmetingRaamDeurVleugelAantal.enkel,
                            krukZijde: OpmetingRaamKrukZijde.links,
                          ),
                          deurVleugelKaart(
                            keuzeWaarde: 'enkel_rechts',
                            titel: 'Enkele vleugel',
                            ondertitel: 'Kruk rechts',
                            aantal: OpmetingRaamDeurVleugelAantal.enkel,
                            krukZijde: OpmetingRaamKrukZijde.rechts,
                          ),
                          deurVleugelKaart(
                            keuzeWaarde: 'dubbel_rechts',
                            titel: 'Dubbele vleugel',
                            ondertitel: 'Kruk rechterdeel',
                            aantal: OpmetingRaamDeurVleugelAantal.dubbel,
                            krukZijde: OpmetingRaamKrukZijde.rechts,
                          ),
                          deurVleugelKaart(
                            keuzeWaarde: 'dubbel_links',
                            titel: 'Dubbele vleugel',
                            ondertitel: 'Kruk linkerdeel',
                            aantal: OpmetingRaamDeurVleugelAantal.dubbel,
                            krukZijde: OpmetingRaamKrukZijde.links,
                          ),
                        ],
                      ),
                      sectieTitel('Kruk'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          keuzeKnop(
                            geselecteerd:
                                krukPlaatsing ==
                                OpmetingRaamDeurKrukPlaatsing.binnen,
                            titel: 'Kruk binnen',
                            onTap: () {
                              setDialogState(() {
                                krukPlaatsing =
                                    OpmetingRaamDeurKrukPlaatsing.binnen;
                              });
                            },
                          ),
                          keuzeKnop(
                            geselecteerd:
                                krukPlaatsing ==
                                OpmetingRaamDeurKrukPlaatsing.binnenEnBuiten,
                            titel: 'Kruk binnen\nen buiten',
                            onTap: () {
                              setDialogState(() {
                                krukPlaatsing = OpmetingRaamDeurKrukPlaatsing
                                    .binnenEnBuiten;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      CheckboxListTile(
                        value: rolluikkruk,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        activeColor: const Color(0xFF0B7A3B),
                        title: const Text(
                          'Rolluikkruk',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (waarde) {
                          setDialogState(() {
                            rolluikkruk = waarde == true;
                          });
                        },
                      ),
                      if (isDubbel) ...[
                        sectieTitel('Verdeling dubbele deur'),
                        TextField(
                          controller: verschuivingController,
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Verschuiving vanaf midden in mm',
                            helperText:
                                '100 = rechterdeel 100 mm kleiner · -100 = linkerdeel 100 mm kleiner',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                if (toonWissen)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                    ),
                    onPressed: () {
                      Navigator.pop(
                        dialogContext,
                        _DeurVleugelPlaatsKeuze.wissen(),
                      );
                    },
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Wissen'),
                  ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF0B7A3B),
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Annuleren'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0B7A3B),
                  ),
                  onPressed: () {
                    final isDubbel = vleugelKeuze.startsWith('dubbel');
                    final krukZijde = vleugelKeuze.endsWith('rechts')
                        ? OpmetingRaamKrukZijde.rechts
                        : OpmetingRaamKrukZijde.links;

                    Navigator.pop(
                      dialogContext,
                      _DeurVleugelPlaatsKeuze(
                        draairichting: draairichting,
                        aantal: isDubbel
                            ? OpmetingRaamDeurVleugelAantal.dubbel
                            : OpmetingRaamDeurVleugelAantal.enkel,
                        krukZijde: krukZijde,
                        krukPlaatsing: krukPlaatsing,
                        krukType: rolluikkruk
                            ? OpmetingRaamDeurVleugelKrukType.rolluikkruk
                            : OpmetingRaamDeurVleugelKrukType.kruk,
                        middenVerschuivingMm: isDubbel
                            ? int.tryParse(
                                    verschuivingController.text
                                        .trim()
                                        .replaceAll(',', '.'),
                                  ) ??
                                  0
                            : 0,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Plaatsen'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _voerMenuWijzigingUit(VoidCallback wijziging) {
    setState(wijziging);
  }

  void _sluitTStijlMenu() {
    _voerMenuWijzigingUit(_menuZichtbaarheid.sluitTStijlMenu);
  }

  void _sluitVleugelMenu() {
    _voerMenuWijzigingUit(_menuZichtbaarheid.sluitVleugelMenu);
  }

  void _sluitOpvullingMenu() {
    _voerMenuWijzigingUit(_menuZichtbaarheid.sluitOpvullingMenu);
  }

  void _sluitKleinhoutMenu() {
    _voerMenuWijzigingUit(_menuZichtbaarheid.sluitKleinhoutMenu);
  }

  void _wijzigPositieType(String waarde) {
    setState(() {
      _positieType = waarde;
    });
  }

  void _verversTStijlMaat() {
    setState(() {});
  }

  void _wijzigVleugelType(OpmetingRaamVleugelType type) {
    setState(() {
      _geselecteerdVleugelType = type;
    });
  }

  void _wijzigGeselecteerdeOpvulling(String? opvullingId) {
    setState(() {
      _geselecteerdeOpvullingId = opvullingId;
    });
  }

  void _wijzigKleinhoutType(OpmetingRaamKleinhoutType type) {
    setState(() {
      _geselecteerdKleinhoutType = type;
    });
  }

  void _wijzigKleinhoutPatroon(OpmetingRaamKleinhoutPatroon patroon) {
    setState(() {
      _geselecteerdKleinhoutPatroon = patroon;
    });
  }

  void _verversKleinhoutWaarde() {
    setState(() {});
  }

  void _verplaatsMenu({
    required String menuId,
    required DragUpdateDetails details,
    required BuildContext overlayContext,
    required Size schermGrootte,
    required Size menuGrootte,
  }) {
    final gewijzigd = _zwevendeMenus.verplaatsMenu(
      menuId: menuId,
      details: details,
      overlayContext: overlayContext,
      schermGrootte: schermGrootte,
      menuGrootte: menuGrootte,
    );

    if (!gewijzigd || !mounted) {
      return;
    }

    setState(() {});
  }

  OpmetingKaderDeel? get _actiefKaderVoorKaderMenu {
    final samenstelling = widget.kaderSamenstelling;

    if (samenstelling == null) {
      return null;
    }

    final actiefKader = samenstelling.actiefKader;

    if (actiefKader != null) {
      return actiefKader;
    }

    if (samenstelling.kaders.isNotEmpty) {
      return samenstelling.kaders.first;
    }

    return null;
  }

  void _synchroniseerKaderMenuVelden({
    OpmetingKaderDeel? kader,
    bool forceer = false,
  }) {
    final actiefKader = kader ?? _actiefKaderVoorKaderMenu;

    if (actiefKader == null) {
      _laatsteKaderMenuKaderId = null;
      return;
    }

    final kaderGewijzigd = _laatsteKaderMenuKaderId != actiefKader.id;

    if (forceer || kaderGewijzigd || !_kaderBreedteFocusNode.hasFocus) {
      _kaderBreedteController.text = actiefKader.breedteMm.toString();
    }

    if (forceer || kaderGewijzigd || !_kaderHoogteFocusNode.hasFocus) {
      _kaderHoogteController.text = actiefKader.hoogteMm.toString();
    }

    _laatsteKaderMenuKaderId = actiefKader.id;
  }

  int? _leesKaderMenuMaat(String tekst) {
    final waarde = double.tryParse(tekst.trim().replaceAll(',', '.'));

    if (waarde == null) {
      return null;
    }

    return waarde.round();
  }

  void _pasActieveKaderMatenToe({bool toonFout = true}) {
    final samenstelling = widget.kaderSamenstelling;
    final actiefKader = _actiefKaderVoorKaderMenu;

    if (samenstelling == null || actiefKader == null) {
      if (toonFout) {
        OpmetingRaamSnackBarHelper.toonFout(
          context,
          'Selecteer eerst een kader in de tekening.',
        );
      }
      return;
    }

    final breedteMm = _leesKaderMenuMaat(_kaderBreedteController.text);
    final hoogteMm = _leesKaderMenuMaat(_kaderHoogteController.text);

    if (breedteMm == null || breedteMm <= 0) {
      if (toonFout) {
        OpmetingRaamSnackBarHelper.toonFout(
          context,
          'Vul een geldige kaderbreedte in.',
        );
      }
      return;
    }

    if (hoogteMm == null || hoogteMm <= 0) {
      if (toonFout) {
        OpmetingRaamSnackBarHelper.toonFout(
          context,
          'Vul een geldige kaderhoogte in.',
        );
      }
      return;
    }

    final nieuweKaders =
        OpmetingKaderSamenstellingLayoutHelper.wijzigKaderAfmetingen(
          kaders: samenstelling.kaders,
          kaderId: actiefKader.id,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
        );

    widget.onKaderSamenstellingGewijzigd?.call(
      samenstelling.copyWith(
        kaders: nieuweKaders,
        actiefKaderId: actiefKader.id,
      ),
    );

    _synchroniseerKaderMenuVelden(
      kader: actiefKader.copyWith(breedteMm: breedteMm, hoogteMm: hoogteMm),
      forceer: toonFout,
    );
  }

  void _planKaderMaatAutoUpdate() {
    _kaderMaatAutoUpdateTimer?.cancel();
    _kaderMaatAutoUpdateTimer = Timer(const Duration(milliseconds: 350), () {
      if (!mounted || widget.actieveTool != 'kader') {
        return;
      }

      _pasActieveKaderMatenToe(toonFout: false);
    });
  }

  Future<void> _bevestigEnVerwijderActiefKader() async {
    final samenstelling = widget.kaderSamenstelling;
    final actiefKader = _actiefKaderVoorKaderMenu;

    if (samenstelling == null || actiefKader == null) {
      OpmetingRaamSnackBarHelper.toonFout(
        context,
        'Selecteer eerst een kader in de tekening.',
      );
      return;
    }

    if (samenstelling.kaders.length <= 1) {
      OpmetingRaamSnackBarHelper.toonFout(
        context,
        'Het laatste kader kan niet gewist worden.',
      );
      return;
    }

    final heeftGekoppeldeKaders = samenstelling.kaders.any((kader) {
      return kader.gekoppeldAanKaderId == actiefKader.id;
    });

    if (heeftGekoppeldeKaders) {
      OpmetingRaamSnackBarHelper.toonFout(
        context,
        'Verwijder eerst de kaders die aan dit kader gekoppeld zijn.',
      );
      return;
    }

    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(Icons.delete_outline_rounded, color: Color(0xFF0B7A3B)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Kader wissen?',
                  style: TextStyle(
                    color: Color(0xFF064E3B),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Wilt u ${actiefKader.naam} definitief uit deze opmeting wissen?',
            style: const TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Annuleren'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0B7A3B),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('Wissen'),
            ),
          ],
        );
      },
    );

    if (bevestigen != true || !mounted) {
      return;
    }

    final overblijvendeKaders = samenstelling.kaders.where((kader) {
      return kader.id != actiefKader.id;
    }).toList();

    if (overblijvendeKaders.isEmpty) {
      return;
    }

    final nieuweActieveKaderId = overblijvendeKaders.first.id;
    final herberekendeKaders =
        OpmetingKaderSamenstellingLayoutHelper.herberekenGekoppeldeKaders(
          kaders: overblijvendeKaders,
        );

    setState(() {
      _geselecteerdeKaderIds
        ..clear()
        ..add(nieuweActieveKaderId);
      _actiefTStijlKaderId = nieuweActieveKaderId;
      _actiefVleugelKaderId = nieuweActieveKaderId;
      _actiefOpvullingKaderId = nieuweActieveKaderId;
      _actiefKleinhoutKaderId = nieuweActieveKaderId;
      _kaderWijzigMenuGesloten = false;
      _geselecteerdeLijn = null;
    });

    widget.onKaderSamenstellingGewijzigd?.call(
      samenstelling.copyWith(
        kaders: herberekendeKaders,
        actiefKaderId: nieuweActieveKaderId,
      ),
    );

    _meldGeselecteerdeKadersAanPagina();
  }

  Widget _bouwKaderWijzigMenuOverlay() {
    final actiefKader = _actiefKaderVoorKaderMenu;

    if (actiefKader == null || _kaderWijzigMenuGesloten) {
      return const SizedBox.shrink();
    }

    _synchroniseerKaderMenuVelden(kader: actiefKader);

    return OpmetingRaamKaderWijzigMenuOverlay(
      actiefKader: actiefKader,
      positie: _kaderMenuPositie,
      onPositieGewijzigd: (positie) {
        if (!mounted) {
          return;
        }

        setState(() {
          _kaderMenuPositie = positie;
        });
      },
      breedteController: _kaderBreedteController,
      hoogteController: _kaderHoogteController,
      breedteFocusNode: _kaderBreedteFocusNode,
      hoogteFocusNode: _kaderHoogteFocusNode,
      onMaatGewijzigd: _planKaderMaatAutoUpdate,
      onSluiten: () {
        if (!mounted) {
          return;
        }

        setState(() {
          _kaderWijzigMenuGesloten = true;
        });
      },
      onVerwijderen: _bevestigEnVerwijderActiefKader,
    );
  }

  OpmetingKaderDeel? get _ankerKaderVoorToevoegMenu {
    final samenstelling = widget.kaderSamenstelling;

    if (samenstelling == null || samenstelling.kaders.isEmpty) {
      return null;
    }

    OpmetingKaderDeel? zoek(String? kaderId) {
      if (kaderId == null || kaderId.trim().isEmpty) {
        return null;
      }

      for (final kader in samenstelling.kaders) {
        if (kader.id == kaderId && kader.id != _toevoegKaderId) {
          return kader;
        }
      }

      return null;
    }

    final ankerUitState = zoek(_toevoegAnkerKaderId);

    if (ankerUitState != null) {
      return ankerUitState;
    }

    final actiefKader = samenstelling.actiefKader;

    if (actiefKader != null && actiefKader.id != _toevoegKaderId) {
      return actiefKader;
    }

    for (final kader in samenstelling.kaders) {
      if (kader.id != _toevoegKaderId) {
        return kader;
      }
    }

    return samenstelling.kaders.first;
  }

  int? _leesToevoegKaderMaat(String tekst) {
    final waarde = double.tryParse(tekst.trim().replaceAll(',', '.'));

    if (waarde == null) {
      return null;
    }

    return waarde.round();
  }

  int? _leesToevoegKaderOffset() {
    return _leesToevoegKaderMaat(_toevoegKaderVrijeOffsetController.text);
  }

  OpmetingKaderDeel? _bestaandToevoegKader(
    OpmetingKaderSamenstelling samenstelling,
  ) {
    final kaderId = _toevoegKaderId;

    if (kaderId == null) {
      return null;
    }

    for (final kader in samenstelling.kaders) {
      if (kader.id == kaderId) {
        return kader;
      }
    }

    return null;
  }

  void _selecteerToevoegKaderPositie({
    required OpmetingKaderZijde zijde,
    required OpmetingKaderUitlijning uitlijning,
  }) {
    setState(() {
      _toevoegKaderZijde = zijde;
      _toevoegKaderUitlijning = uitlijning;

      if (uitlijning == OpmetingKaderUitlijning.begin ||
          uitlijning == OpmetingKaderUitlijning.einde) {
        _toevoegKaderVrijeBasisUitlijning = uitlijning;
      }
    });

    _tekenOfWijzigToevoegKader();
  }

  void _activeerToevoegVrijePositie({
    required OpmetingKaderZijde zijde,
    required OpmetingKaderUitlijning basisUitlijning,
  }) {
    setState(() {
      _toevoegKaderZijde = zijde;
      _toevoegKaderUitlijning = OpmetingKaderUitlijning.vrij;
      _toevoegKaderVrijeBasisUitlijning = basisUitlijning;
    });

    _tekenOfWijzigToevoegKader();
  }

  int _berekenVrijeOffsetVanafGekozenHoek({
    required OpmetingKaderZijde zijde,
    required OpmetingKaderUitlijning basisUitlijning,
    required int offsetMm,
    required OpmetingKaderDeel ankerKader,
    required int nieuwKaderBreedteMm,
    required int nieuwKaderHoogteMm,
  }) {
    final maximaleOffset =
        zijde == OpmetingKaderZijde.boven || zijde == OpmetingKaderZijde.onder
        ? ankerKader.breedteMm - nieuwKaderBreedteMm
        : ankerKader.hoogteMm - nieuwKaderHoogteMm;

    final veiligeMax = maximaleOffset < 0 ? 0 : maximaleOffset;
    final veiligeOffset = offsetMm.clamp(0, veiligeMax).toInt();

    if (basisUitlijning == OpmetingKaderUitlijning.einde) {
      return veiligeMax - veiligeOffset;
    }

    return veiligeOffset;
  }

  void _tekenOfWijzigToevoegKader() {
    final samenstelling = widget.kaderSamenstelling;
    final ankerKader = _ankerKaderVoorToevoegMenu;
    final zijde = _toevoegKaderZijde;
    final uitlijning = _toevoegKaderUitlijning;

    if (samenstelling == null || ankerKader == null) {
      OpmetingRaamSnackBarHelper.toonFout(
        context,
        'Er is geen kader beschikbaar om tegen te koppelen.',
      );
      return;
    }

    if (zijde == null || uitlijning == null) {
      return;
    }

    final breedteMm = _leesToevoegKaderMaat(
      _toevoegKaderBreedteController.text,
    );

    final hoogteMm = _leesToevoegKaderMaat(_toevoegKaderHoogteController.text);

    if (breedteMm == null || breedteMm <= 0) {
      return;
    }

    if (hoogteMm == null || hoogteMm <= 0) {
      return;
    }

    var vrijeOffsetMm = 0;

    if (uitlijning == OpmetingKaderUitlijning.vrij) {
      final offset = _leesToevoegKaderOffset();

      if (offset == null) {
        return;
      }

      vrijeOffsetMm = _berekenVrijeOffsetVanafGekozenHoek(
        zijde: zijde,
        basisUitlijning: _toevoegKaderVrijeBasisUitlijning,
        offsetMm: offset,
        ankerKader: ankerKader,
        nieuwKaderBreedteMm: breedteMm,
        nieuwKaderHoogteMm: hoogteMm,
      );
    }

    final bestaandKader = _bestaandToevoegKader(samenstelling);
    final kaderId =
        bestaandKader?.id ??
        _toevoegKaderId ??
        'kader_${DateTime.now().microsecondsSinceEpoch}';

    final basisKaders = samenstelling.kaders.where((kader) {
      return kader.id != kaderId;
    }).toList();

    final ankerBestaat = basisKaders.any((kader) {
      return kader.id == ankerKader.id;
    });

    if (!ankerBestaat) {
      return;
    }

    final nieuwKader = OpmetingKaderDeel(
      id: kaderId,
      naam: bestaandKader?.naam ?? 'Kader ${basisKaders.length + 1}',
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    final nieuweKaders = OpmetingKaderSamenstellingLayoutHelper.voegKaderToe(
      bestaandeKaders: basisKaders,
      nieuwKader: nieuwKader,
      gekoppeldAanKaderId: ankerKader.id,
      zijde: zijde,
      uitlijning: uitlijning,
      vrijeOffsetMm: vrijeOffsetMm,
    );

    _toevoegKaderId = kaderId;
    _toevoegAnkerKaderId = ankerKader.id;

    widget.onKaderSamenstellingGewijzigd?.call(
      samenstelling.copyWith(
        kaders: nieuweKaders,
        actiefKaderId: ankerKader.id,
      ),
    );
  }

  Widget _bouwKaderToevoegMenuOverlay() {
    final ankerKader = _ankerKaderVoorToevoegMenu;

    if (widget.kaderSamenstelling == null ||
        ankerKader == null ||
        _kaderToevoegMenuGesloten) {
      return const SizedBox.shrink();
    }

    return OpmetingRaamKaderToevoegMenuOverlay(
      ankerKader: ankerKader,
      positie: _kaderToevoegMenuPositie,
      onPositieGewijzigd: (positie) {
        if (!mounted) {
          return;
        }

        setState(() {
          _kaderToevoegMenuPositie = positie;
        });
      },
      onSluiten: () {
        if (!mounted) {
          return;
        }

        setState(() {
          _kaderToevoegMenuGesloten = true;
        });
      },
      geselecteerdeZijde: _toevoegKaderZijde,
      geselecteerdeUitlijning: _toevoegKaderUitlijning,
      geselecteerdeVrijeBasisUitlijning: _toevoegKaderVrijeBasisUitlijning,
      onPositieGekozen: _selecteerToevoegKaderPositie,
      onVrijePositieActiveren: _activeerToevoegVrijePositie,
      onKaderWijziging: _tekenOfWijzigToevoegKader,
      breedteController: _toevoegKaderBreedteController,
      hoogteController: _toevoegKaderHoogteController,
      vrijeOffsetController: _toevoegKaderVrijeOffsetController,
      breedteFocusNode: _toevoegKaderBreedteFocusNode,
      hoogteFocusNode: _toevoegKaderHoogteFocusNode,
      vrijeOffsetFocusNode: _toevoegKaderVrijeOffsetFocusNode,
    );
  }

  Widget _bouwMenuOverlay({
    required List<OpmetingRaamVulvlak> vulvlakken,
    required OpmetingRaamTekenvlakWeergaveStatus weergaveStatus,
  }) {
    return OpmetingRaamMenuOverlay(
      actieveTool: widget.actieveTool,
      zwevendeMenus: _zwevendeMenus,
      heeftGeselecteerdeLijn: _geselecteerdeLijn != null,
      bestaandeTStijlGeselecteerd: weergaveStatus.bestaandeTStijlGeselecteerd,
      alleenVerplaatsenVoorGeselecteerdeTStijl:
          weergaveStatus.alleenVerplaatsenVoorGeselecteerdeTStijl,
      vleugelMenuZichtbaar: _menuZichtbaarheid.vleugelMenuZichtbaar,
      tStijlMenuZichtbaar: _menuZichtbaarheid.tStijlMenuZichtbaar,
      opvullingMenuZichtbaar: _menuZichtbaarheid.opvullingMenuZichtbaar,
      kleinhoutMenuZichtbaar: _menuZichtbaarheid.kleinhoutMenuZichtbaar,
      positieType: _positieType,
      positieController: widget.positieController,
      geselecteerdVleugelType: _geselecteerdVleugelType,
      opvullingen: _opvullingen,
      opvullingenLaden: _opvullingenLaden,
      geselecteerdeOpvullingId: _geselecteerdeOpvullingId,
      aantalGeselecteerdeVulvlakken: _aantalGeselecteerdeVulvlakkenVoorMenu(),
      totaalAantalVlakken: _totaalAantalVulvlakkenVoorMenu(vulvlakken),
      geselecteerdKleinhoutType: _geselecteerdKleinhoutType,
      geselecteerdKleinhoutPatroon: _geselecteerdKleinhoutPatroon,
      kleinhoutHorizontaleHoogteController:
          _kleinhoutHorizontaleHoogteController,
      kleinhoutAantalHorizontaalController:
          _kleinhoutAantalHorizontaalController,
      kleinhoutAantalVerticaalController: _kleinhoutAantalVerticaalController,
      aantalGeselecteerdeKleinhoutVlakken:
          _aantalGeselecteerdeKleinhoutVlakkenVoorMenu(),
      totaalAantalGevuldeVlakken: _totaalAantalGevuldeKleinhoutVlakkenVoorMenu(
        weergaveStatus,
      ),
      kleinhoutSelectieIsVolledigGevuld:
          _kleinhoutSelectieIsVolledigGevuldVoorMenu(weergaveStatus),
      kleinhoutSelectieHeeftKleinhouten:
          _kleinhoutSelectieHeeftKleinhoutenVoorMenu(weergaveStatus),
      onMenuVerslepen: _verplaatsMenu,
      onTStijlMenuSluiten: _sluitTStijlMenu,
      onVleugelMenuSluiten: _sluitVleugelMenu,
      onOpvullingMenuSluiten: _sluitOpvullingMenu,
      onKleinhoutMenuSluiten: _sluitKleinhoutMenu,
      onPositieTypeGewijzigd: _wijzigPositieType,
      onTStijlMaatGewijzigd: _verversTStijlMaat,
      onTStijlToevoegen: _tStijlToevoegen,
      onTStijlVerplaatsen: _verplaatsGeselecteerdeTStijl,
      onTStijlWissen: _wisTStijlVanGeselecteerdeLijn,
      onVleugelTypeGekozen: _wijzigVleugelType,
      onOpvullingGekozen: _wijzigGeselecteerdeOpvulling,
      onOpvullingToepassen: _pasOpvullingToe,
      onOpvullingVerwijderen: _verwijderOpvullingUitSelectie,
      onAlleVulvlakkenSelecteren: _selecteerAlleVulvlakken,
      onVulvlakSelectieWissen: _wisVulvlakSelectie,
      onKleinhoutTypeGewijzigd: _wijzigKleinhoutType,
      onKleinhoutPatroonGewijzigd: _wijzigKleinhoutPatroon,
      onKleinhoutWaardeGewijzigd: _verversKleinhoutWaarde,
      onKleinhoutToepassen: _pasKleinhoutenToe,
      onKleinhoutVerwijderen: _verwijderGeselecteerdeKleinhouten,
      onAlleGevuldeKleinhoutVlakkenSelecteren:
          _selecteerAlleGevuldeKleinhoutVlakken,
      onKleinhoutSelectieWissen: _wisKleinhoutSelectie,
    );
  }

  Widget _bouwTekenvlakInhoud(Size size) {
    _registreerTekenvlakGrootte(size);

    _legendaMeldingen.planEersteMeldingen();

    final preview = _previewPunt(size);

    final vulvlakken = _bepaalVulvlakken(size);

    final vulvlakkenPerKaderVoorWeergave = _vulvlakkenPerKaderVoorWeergave(
      size,
    );

    final tStijlenPerKaderVoorWeergave = _tStijlenPerKaderVoorWeergave();

    final vleugelsPerKaderVoorWeergave = _vleugelsPerKaderVoorWeergave();

    final vullingToewijzingenPerKaderVoorWeergave =
        _vullingToewijzingenPerKaderVoorWeergave();

    final geselecteerdeVulvlakIdsPerKaderVoorWeergave =
        _geselecteerdeVulvlakIdsPerKaderVoorWeergave();

    final kleinhoutenPerKaderVoorWeergave = _kleinhoutenPerKaderVoorWeergave();

    final geselecteerdeKleinhoutVlakIdsPerKaderVoorWeergave =
        _geselecteerdeKleinhoutVlakIdsPerKaderVoorWeergave();

    final weergaveStatus = OpmetingRaamTekenvlakWeergaveStatusHelper.bereken(
      tekenvlakGrootte: size,
      breedteMm: widget.breedteMm,
      hoogteMm: widget.hoogteMm,
      geselecteerdeLijn: _geselecteerdeLijn,
      tStijlen: _tStijlen,
      vleugels: _vleugels,
      vulvlakken: vulvlakken,
      vullingToewijzingen: _vullingToewijzingen,
      geselecteerdeKleinhoutVlakIds: _geselecteerdeKleinhoutVlakIds,
      kleinhouten: _kleinhouten,
    );

    _meldOverzichtTekeningGewijzigd(
      tekenvlakGrootte: size,
      vulvlakken: vulvlakken,
      vulvlakkenPerKader: vulvlakkenPerKaderVoorWeergave,
      tStijlenPerKader: tStijlenPerKaderVoorWeergave,
      vleugelsPerKader: vleugelsPerKaderVoorWeergave,
      vullingToewijzingenPerKader: vullingToewijzingenPerKaderVoorWeergave,
      kleinhoutenPerKader: kleinhoutenPerKaderVoorWeergave,
    );

    return OverlayPortal(
      controller: _zwevendeMenus.overlayController,
      overlayChildBuilder: (_) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            _bouwMenuOverlay(
              vulvlakken: vulvlakken,
              weergaveStatus: weergaveStatus,
            ),
            if (widget.actieveTool == 'kader') _bouwKaderWijzigMenuOverlay(),
            if (widget.actieveTool == 'kadertoevoegen')
              _bouwKaderToevoegMenuOverlay(),
          ],
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          OpmetingRaamTekenvlakTekenlaag(
            breedteMm: widget.breedteMm,
            hoogteMm: widget.hoogteMm,
            onTapDown: (details) {
              unawaited(_klikTekenvlak(details));
            },
            geselecteerdeLijn: _geselecteerdeLijn,
            previewPunt: preview,
            tStijlen: _tStijlen,
            tStijlenPerKader: tStijlenPerKaderVoorWeergave,
            vleugels: _vleugels,
            vleugelsPerKader: vleugelsPerKaderVoorWeergave,
            vulvlakken: vulvlakken,
            vulvlakkenPerKader: vulvlakkenPerKaderVoorWeergave,
            vullingToewijzingen: _vullingToewijzingen,
            vullingToewijzingenPerKader:
                vullingToewijzingenPerKaderVoorWeergave,
            geselecteerdeVulvlakIds: _geselecteerdeVulvlakIds,
            geselecteerdeVulvlakIdsPerKader:
                geselecteerdeVulvlakIdsPerKaderVoorWeergave,
            kleinhouten: _kleinhouten,
            kleinhoutenPerKader: kleinhoutenPerKaderVoorWeergave,
            geselecteerdeKleinhoutVlakIds: _geselecteerdeKleinhoutVlakIds,
            geselecteerdeKleinhoutVlakIdsPerKader:
                geselecteerdeKleinhoutVlakIdsPerKaderVoorWeergave,
            technischeTekeningen: widget.technischeTekeningen,
            technischeTekeningenPerKader: widget.technischeTekeningenPerKader,
            technischeTekeningenPerKaderGroep:
                widget.technischeTekeningenPerKaderGroep,
            technischeKaderGroepen: widget.technischeKaderGroepen,
            geselecteerdeKaderIds: Set<String>.unmodifiable(
              _geselecteerdeKaderIds,
            ),
            kaderSamenstelling: widget.kaderSamenstelling,
            actiefKaderId: _actiefKaderIdVoorWeergave,
          ),
          IgnorePointer(
            child: CustomPaint(
              painter: OpmetingDeurpaneelTekenvlakPainter(
                breedteMm: widget.breedteMm,
                hoogteMm: widget.hoogteMm,
                vleugels: List<OpmetingRaamVleugel>.unmodifiable(_vleugels),
                vleugelsPerKader: vleugelsPerKaderVoorWeergave,
                kaderSamenstelling: widget.kaderSamenstelling,
                toewijzingen: List<OpmetingDeurpaneelToewijzing>.unmodifiable(
                  _deurpaneelToewijzingen,
                ),
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OpmetingRaamTekenvlakKader(inhoudBuilder: _bouwTekenvlakInhoud);
  }
}

class _DeurVleugelVoorbeeldPainter extends CustomPainter {
  const _DeurVleugelVoorbeeldPainter({
    required this.aantal,
    required this.krukZijde,
    required this.draairichting,
    required this.geselecteerd,
  });

  final OpmetingRaamDeurVleugelAantal aantal;
  final OpmetingRaamKrukZijde krukZijde;
  final OpmetingRaamDeurDraairichting draairichting;
  final bool geselecteerd;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final buiten = Rect.fromLTWH(9, 8, size.width - 18, size.height - 18);

    final lijn = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 1.35
      ..style = PaintingStyle.stroke;

    final dunneLijn = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 1.05
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final accent = Paint()
      ..color = geselecteerd ? const Color(0xFF0B7A3B) : const Color(0xFF374151)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final profielVulling = Paint()
      ..color = const Color(0xFFF9FAFB)
      ..style = PaintingStyle.fill;

    final tekstPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final bovenTekst =
        draairichting == OpmetingRaamDeurDraairichting.binnendraaiend
        ? 'BIN'
        : 'BUIT';

    tekstPainter.text = TextSpan(
      text: bovenTekst,
      style: TextStyle(
        color: geselecteerd ? const Color(0xFF0B7A3B) : const Color(0xFF6B7280),
        fontSize: 8.5,
        fontWeight: FontWeight.w900,
      ),
    );
    tekstPainter.layout(maxWidth: size.width);
    tekstPainter.paint(
      canvas,
      Offset((size.width - tekstPainter.width) / 2, size.height - 10),
    );

    if (aantal == OpmetingRaamDeurVleugelAantal.dubbel) {
      _tekenDubbel(canvas, buiten, lijn, dunneLijn, accent, profielVulling);
    } else {
      _tekenEnkel(canvas, buiten, lijn, dunneLijn, accent, profielVulling);
    }
  }

  void _tekenEnkel(
    Canvas canvas,
    Rect buiten,
    Paint lijn,
    Paint dunneLijn,
    Paint accent,
    Paint profielVulling,
  ) {
    final deur = buiten.deflate(2);
    final binnen = deur.deflate(7);

    canvas.drawRect(deur, profielVulling);
    canvas.drawRect(deur, lijn);
    canvas.drawRect(binnen, dunneLijn);

    final krukLinks = krukZijde == OpmetingRaamKrukZijde.links;
    final krukX = krukLinks ? deur.left + 5.2 : deur.right - 5.2;
    final scharnierX = krukLinks ? binnen.right : binnen.left;
    final puntX = krukLinks ? binnen.left : binnen.right;
    final puntY = _puntY(binnen);

    _tekenOpeningsLijnen(
      canvas: canvas,
      scharnierX: scharnierX,
      bovenY: binnen.top,
      onderY: binnen.bottom,
      punt: Offset(puntX, puntY),
      paint: accent,
    );

    _tekenKruk(
      canvas: canvas,
      x: krukX,
      y: puntY,
      naarRechts: krukLinks,
      paint: lijn,
    );

    _tekenScharnieren(
      canvas: canvas,
      x: scharnierX,
      bovenY: binnen.top + 8,
      onderY: binnen.bottom - 8,
      paint: dunneLijn,
    );
  }

  void _tekenDubbel(
    Canvas canvas,
    Rect buiten,
    Paint lijn,
    Paint dunneLijn,
    Paint accent,
    Paint profielVulling,
  ) {
    final deur = buiten.deflate(2);
    final binnen = deur.deflate(6.5);
    final middenX = (deur.left + deur.right) / 2;
    final middenBinnenX = (binnen.left + binnen.right) / 2;
    final puntY = _puntY(binnen);

    canvas.drawRect(deur, profielVulling);
    canvas.drawRect(deur, lijn);
    canvas.drawLine(
      Offset(middenX, deur.top),
      Offset(middenX, deur.bottom),
      lijn,
    );

    final linksBinnen = Rect.fromLTRB(
      binnen.left,
      binnen.top,
      middenBinnenX - 1.5,
      binnen.bottom,
    );
    final rechtsBinnen = Rect.fromLTRB(
      middenBinnenX + 1.5,
      binnen.top,
      binnen.right,
      binnen.bottom,
    );

    canvas.drawRect(linksBinnen, dunneLijn);
    canvas.drawRect(rechtsBinnen, dunneLijn);

    _tekenOpeningsLijnen(
      canvas: canvas,
      scharnierX: linksBinnen.left,
      bovenY: linksBinnen.top,
      onderY: linksBinnen.bottom,
      punt: Offset(linksBinnen.right, puntY),
      paint: accent,
    );
    _tekenOpeningsLijnen(
      canvas: canvas,
      scharnierX: rechtsBinnen.right,
      bovenY: rechtsBinnen.top,
      onderY: rechtsBinnen.bottom,
      punt: Offset(rechtsBinnen.left, puntY),
      paint: accent,
    );

    final krukOpRechterdeel = krukZijde == OpmetingRaamKrukZijde.rechts;
    if (krukOpRechterdeel) {
      _tekenKruk(
        canvas: canvas,
        x: rechtsBinnen.left + 3.5,
        y: puntY,
        naarRechts: true,
        paint: lijn,
      );
    } else {
      _tekenKruk(
        canvas: canvas,
        x: linksBinnen.right - 3.5,
        y: puntY,
        naarRechts: false,
        paint: lijn,
      );
    }

    _tekenScharnieren(
      canvas: canvas,
      x: linksBinnen.left,
      bovenY: linksBinnen.top + 8,
      onderY: linksBinnen.bottom - 8,
      paint: dunneLijn,
    );
    _tekenScharnieren(
      canvas: canvas,
      x: rechtsBinnen.right,
      bovenY: rechtsBinnen.top + 8,
      onderY: rechtsBinnen.bottom - 8,
      paint: dunneLijn,
    );
  }

  double _puntY(Rect binnen) {
    final midden = (binnen.top + binnen.bottom) / 2;
    final verschuiving = (binnen.height * 0.08).clamp(1.0, 4.5).toDouble();

    if (draairichting == OpmetingRaamDeurDraairichting.binnendraaiend) {
      return midden - verschuiving;
    }

    return midden + verschuiving;
  }

  void _tekenOpeningsLijnen({
    required Canvas canvas,
    required double scharnierX,
    required double bovenY,
    required double onderY,
    required Offset punt,
    required Paint paint,
  }) {
    canvas.drawLine(Offset(scharnierX, bovenY), punt, paint);
    canvas.drawLine(Offset(scharnierX, onderY), punt, paint);
  }

  void _tekenKruk({
    required Canvas canvas,
    required double x,
    required double y,
    required bool naarRechts,
    required Paint paint,
  }) {
    final lengte = naarRechts ? 8.5 : -8.5;
    canvas.drawLine(Offset(x, y), Offset(x + lengte, y), paint);
    canvas.drawCircle(
      Offset(x, y),
      1.8,
      Paint()..color = const Color(0xFF111827),
    );
  }

  void _tekenScharnieren({
    required Canvas canvas,
    required double x,
    required double bovenY,
    required double onderY,
    required Paint paint,
  }) {
    canvas.drawLine(Offset(x - 2.5, bovenY), Offset(x + 2.5, bovenY), paint);
    canvas.drawLine(Offset(x - 2.5, onderY), Offset(x + 2.5, onderY), paint);
  }

  @override
  bool shouldRepaint(covariant _DeurVleugelVoorbeeldPainter oldDelegate) {
    return oldDelegate.aantal != aantal ||
        oldDelegate.krukZijde != krukZijde ||
        oldDelegate.draairichting != draairichting ||
        oldDelegate.geselecteerd != geselecteerd;
  }
}

class _DeurVleugelPlaatsKeuze {
  const _DeurVleugelPlaatsKeuze({
    required this.draairichting,
    required this.aantal,
    required this.krukZijde,
    required this.krukPlaatsing,
    required this.krukType,
    required this.middenVerschuivingMm,
    this.wissen = false,
  });

  factory _DeurVleugelPlaatsKeuze.wissen() {
    return const _DeurVleugelPlaatsKeuze(
      draairichting: OpmetingRaamDeurDraairichting.binnendraaiend,
      aantal: OpmetingRaamDeurVleugelAantal.enkel,
      krukZijde: OpmetingRaamKrukZijde.links,
      krukPlaatsing: OpmetingRaamDeurKrukPlaatsing.binnen,
      krukType: OpmetingRaamDeurVleugelKrukType.kruk,
      middenVerschuivingMm: 0,
      wissen: true,
    );
  }

  final OpmetingRaamDeurDraairichting draairichting;
  final OpmetingRaamDeurVleugelAantal aantal;
  final OpmetingRaamKrukZijde krukZijde;
  final OpmetingRaamDeurKrukPlaatsing krukPlaatsing;
  final OpmetingRaamDeurVleugelKrukType krukType;
  final int middenVerschuivingMm;
  final bool wissen;

  bool get isDubbel {
    return aantal == OpmetingRaamDeurVleugelAantal.dubbel;
  }
}

class _DeurVleugelBinnenLijnInfo {
  const _DeurVleugelBinnenLijnInfo({
    required this.vleugel,
    required this.binnenRect,
    required this.zijde,
    required this.lijn,
  });

  final OpmetingRaamVleugel vleugel;
  final Rect binnenRect;
  final String zijde;
  final OpmetingRaamLijn lijn;
}
