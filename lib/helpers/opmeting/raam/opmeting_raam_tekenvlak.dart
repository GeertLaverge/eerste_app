import 'package:flutter/material.dart';

import '../../app_storage.dart';
import 'opmeting_raam_kader_helper.dart';
import 'opmeting_raam_kleinhout_helper.dart';
import 'opmeting_raam_kleinhout_menu.dart';
import 'opmeting_raam_kleinhout_model.dart';
import 'opmeting_raam_model.dart';
import 'opmeting_raam_opvulling_menu.dart';
import 'opmeting_raam_opvulling_model.dart';
import 'opmeting_raam_tekenvlak_acties.dart';
import 'opmeting_raam_tekenvlak_maat_wijziging.dart';
import 'opmeting_raam_tekenvlak_menus.dart';
import 'opmeting_raam_tekenvlak_painter.dart';
import 'opmeting_raam_tstijl_helper.dart';
import 'opmeting_raam_tstijl_verplaats_helper.dart';
import 'opmeting_raam_vulling_helper.dart';

class OpmetingRaamTekenvlakController extends ChangeNotifier {
  Object? _eigenaar;

  VoidCallback? _ongedaanMakenActie;
  VoidCallback? _herstellenActie;

  bool _kanOngedaanMaken = false;
  bool _kanHerstellen = false;

  bool get kanOngedaanMaken => _kanOngedaanMaken;

  bool get kanHerstellen => _kanHerstellen;

  void ongedaanMaken() {
    if (!_kanOngedaanMaken) {
      return;
    }

    _ongedaanMakenActie?.call();
  }

  void herstellen() {
    if (!_kanHerstellen) {
      return;
    }

    _herstellenActie?.call();
  }

  void _koppel({
    required Object eigenaar,
    required VoidCallback onOngedaanMaken,
    required VoidCallback onHerstellen,
    required bool kanOngedaanMaken,
    required bool kanHerstellen,
  }) {
    _eigenaar = eigenaar;
    _ongedaanMakenActie = onOngedaanMaken;
    _herstellenActie = onHerstellen;

    _pasStatusAan(
      kanOngedaanMaken: kanOngedaanMaken,
      kanHerstellen: kanHerstellen,
    );
  }

  void _werkStatusBij({
    required Object eigenaar,
    required bool kanOngedaanMaken,
    required bool kanHerstellen,
  }) {
    if (!identical(_eigenaar, eigenaar)) {
      return;
    }

    _pasStatusAan(
      kanOngedaanMaken: kanOngedaanMaken,
      kanHerstellen: kanHerstellen,
    );
  }

  void _ontkoppel({required Object eigenaar}) {
    if (!identical(_eigenaar, eigenaar)) {
      return;
    }

    _eigenaar = null;
    _ongedaanMakenActie = null;
    _herstellenActie = null;

    _pasStatusAan(kanOngedaanMaken: false, kanHerstellen: false);
  }

  void _pasStatusAan({
    required bool kanOngedaanMaken,
    required bool kanHerstellen,
  }) {
    if (_kanOngedaanMaken == kanOngedaanMaken &&
        _kanHerstellen == kanHerstellen) {
      return;
    }

    _kanOngedaanMaken = kanOngedaanMaken;
    _kanHerstellen = kanHerstellen;

    notifyListeners();
  }
}

class _OpmetingRaamTekeningMoment {
  const _OpmetingRaamTekeningMoment({
    required this.tStijlen,
    required this.vleugels,
    required this.vullingToewijzingen,
    required this.kleinhouten,
  });

  final List<OpmetingRaamTStijl> tStijlen;
  final List<OpmetingRaamVleugel> vleugels;

  final List<OpmetingRaamVullingToewijzing> vullingToewijzingen;

  final List<OpmetingRaamKleinhout> kleinhouten;
}

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

  @override
  State<OpmetingRaamTekenvlak> createState() {
    return _OpmetingRaamTekenvlakState();
  }
}

class _OpmetingRaamTekenvlakState extends State<OpmetingRaamTekenvlak> {
  static const int _maximumAantalGeschiedenisStappen = 50;

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

  final List<_OpmetingRaamTekeningMoment> _ongedaanGeschiedenis =
      <_OpmetingRaamTekeningMoment>[];

  final List<_OpmetingRaamTekeningMoment> _herstelGeschiedenis =
      <_OpmetingRaamTekeningMoment>[];

  final GlobalKey _tStijlMenuKey = GlobalKey();
  final GlobalKey _opvullingMenuKey = GlobalKey();
  final GlobalKey _kleinhoutMenuKey = GlobalKey();

  bool _opvullingenLaden = true;
  String? _geselecteerdeOpvullingId;

  Offset _vleugelMenuPositie = const Offset(12, 12);
  Offset _tStijlMenuPositie = const Offset(12, 12);
  Offset _opvullingMenuPositie = const Offset(12, 12);
  Offset _kleinhoutMenuPositie = const Offset(12, 12);

  bool _vleugelMenuZichtbaar = true;
  bool _tStijlMenuZichtbaar = true;
  bool _opvullingMenuZichtbaar = true;
  bool _kleinhoutMenuZichtbaar = true;

  int _laatsteGeldigeBreedteMm = 0;
  int _laatsteGeldigeHoogteMm = 0;
  int _kaderMaatWijzigingVersie = 0;

  Size _laatsteTekenvlakGrootte = Size.zero;

  bool _opvullingMeldingGepland = false;
  bool _eersteOpvullingMeldingGepland = false;

  bool _kleinhoutMeldingGepland = false;
  bool _eersteKleinhoutMeldingGepland = false;

  bool get _kanOngedaanMaken {
    return _ongedaanGeschiedenis.isNotEmpty;
  }

  bool get _kanHerstellen {
    return _herstelGeschiedenis.isNotEmpty;
  }

  bool get _bestaandeTStijlGeselecteerd {
    return (_geselecteerdeLijn?.id ?? '').startsWith('tstijl_');
  }

  Set<String> get _gevuldeVlakIds {
    return _vullingToewijzingen.map((toewijzing) => toewijzing.vlakId).toSet();
  }

  bool get _kleinhoutSelectieHeeftKleinhouten {
    return _geselecteerdeKleinhoutVlakIds.any(
      (vlakId) => _kleinhouten.any((kleinhout) => kleinhout.vlakId == vlakId),
    );
  }

  bool get _kleinhoutSelectieIsVolledigGevuld {
    if (_geselecteerdeKleinhoutVlakIds.isEmpty) {
      return false;
    }

    final gevuldeIds = _gevuldeVlakIds;

    return _geselecteerdeKleinhoutVlakIds.every(gevuldeIds.contains);
  }

  @override
  void initState() {
    super.initState();

    if (widget.breedteMm > 0 && widget.hoogteMm > 0) {
      _laatsteGeldigeBreedteMm = widget.breedteMm;
      _laatsteGeldigeHoogteMm = widget.hoogteMm;
    }

    _koppelController(widget.controller);
    _laadOpvullingen();
  }

  @override
  void didUpdateWidget(covariant OpmetingRaamTekenvlak oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller?._ontkoppel(eigenaar: this);

      _koppelController(widget.controller);
    }

    _verwerkToolWijziging(oldWidget);
    _verwerkMenuOpenSignalen(oldWidget);
    _verwerkKaderMaatWijziging();
  }

  @override
  void dispose() {
    widget.controller?._ontkoppel(eigenaar: this);

    _kleinhoutHorizontaleHoogteController.dispose();
    _kleinhoutAantalHorizontaalController.dispose();
    _kleinhoutAantalVerticaalController.dispose();

    super.dispose();
  }

  void _koppelController(OpmetingRaamTekenvlakController? controller) {
    controller?._koppel(
      eigenaar: this,
      onOngedaanMaken: _ongedaanMaken,
      onHerstellen: _herstellen,
      kanOngedaanMaken: _kanOngedaanMaken,
      kanHerstellen: _kanHerstellen,
    );
  }

  void _werkGeschiedenisStatusBij() {
    widget.controller?._werkStatusBij(
      eigenaar: this,
      kanOngedaanMaken: _kanOngedaanMaken,
      kanHerstellen: _kanHerstellen,
    );
  }

  _OpmetingRaamTekeningMoment _maakGeschiedenisMoment() {
    return _OpmetingRaamTekeningMoment(
      tStijlen: List<OpmetingRaamTStijl>.unmodifiable(_tStijlen),
      vleugels: List<OpmetingRaamVleugel>.unmodifiable(_vleugels),
      vullingToewijzingen: List<OpmetingRaamVullingToewijzing>.unmodifiable(
        _vullingToewijzingen,
      ),
      kleinhouten: List<OpmetingRaamKleinhout>.unmodifiable(_kleinhouten),
    );
  }

  void _bewaarVoorWijziging() {
    _ongedaanGeschiedenis.add(_maakGeschiedenisMoment());

    if (_ongedaanGeschiedenis.length > _maximumAantalGeschiedenisStappen) {
      _ongedaanGeschiedenis.removeAt(0);
    }

    _herstelGeschiedenis.clear();

    _werkGeschiedenisStatusBij();
  }

  void _wisGeschiedenis() {
    if (_ongedaanGeschiedenis.isEmpty && _herstelGeschiedenis.isEmpty) {
      return;
    }

    _ongedaanGeschiedenis.clear();
    _herstelGeschiedenis.clear();

    _werkGeschiedenisStatusBij();
  }

  void _ongedaanMaken() {
    if (_ongedaanGeschiedenis.isEmpty) {
      return;
    }

    final huidigMoment = _maakGeschiedenisMoment();
    final vorigMoment = _ongedaanGeschiedenis.removeLast();

    _herstelGeschiedenis.add(huidigMoment);

    setState(() {
      _herstelTekeningMoment(vorigMoment);
    });

    _werkGeschiedenisStatusBij();
    _planOpvullingMelding();
    _planKleinhoutMelding();
  }

  void _herstellen() {
    if (_herstelGeschiedenis.isEmpty) {
      return;
    }

    final huidigMoment = _maakGeschiedenisMoment();
    final volgendMoment = _herstelGeschiedenis.removeLast();

    _ongedaanGeschiedenis.add(huidigMoment);

    setState(() {
      _herstelTekeningMoment(volgendMoment);
    });

    _werkGeschiedenisStatusBij();
    _planOpvullingMelding();
    _planKleinhoutMelding();
  }

  void _herstelTekeningMoment(_OpmetingRaamTekeningMoment moment) {
    _tStijlen
      ..clear()
      ..addAll(moment.tStijlen);

    _vleugels
      ..clear()
      ..addAll(moment.vleugels);

    _vullingToewijzingen
      ..clear()
      ..addAll(moment.vullingToewijzingen);

    _kleinhouten
      ..clear()
      ..addAll(moment.kleinhouten);

    _geselecteerdeLijn = null;
    _geselecteerdeVulvlakIds.clear();
    _geselecteerdeKleinhoutVlakIds.clear();

    _schoonVullingEnKleinhoutenOp();
  }

  Future<void> _laadOpvullingen() async {
    if (mounted) {
      setState(() {
        _opvullingenLaden = true;
      });
    }

    try {
      final geladenOpvullingen = await AppStorage.laadOpmetingRaamOpvullingen();

      if (!mounted) {
        return;
      }

      final huidigeKeuzeBestaat = geladenOpvullingen.any(
        (opvulling) => opvulling.id == _geselecteerdeOpvullingId,
      );

      setState(() {
        _opvullingen
          ..clear()
          ..addAll(geladenOpvullingen);

        if (!huidigeKeuzeBestaat) {
          _geselecteerdeOpvullingId = geladenOpvullingen.isEmpty
              ? null
              : geladenOpvullingen.first.id;
        }

        _opvullingenLaden = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _opvullingenLaden = false;
      });
    }
  }

  void _verwerkToolWijziging(OpmetingRaamTekenvlak oldWidget) {
    if (oldWidget.actieveTool == widget.actieveTool) {
      return;
    }

    _geselecteerdeLijn = null;

    if (widget.actieveTool != 'opvulling') {
      _geselecteerdeVulvlakIds.clear();
    }

    if (widget.actieveTool != 'kleinhout') {
      _geselecteerdeKleinhoutVlakIds.clear();
    }

    if (widget.actieveTool == 'tstijl') {
      _tStijlMenuZichtbaar = true;
    }

    if (widget.actieveTool == 'vleugel') {
      _vleugelMenuZichtbaar = true;
    }

    if (widget.actieveTool == 'opvulling') {
      _opvullingMenuZichtbaar = true;
      _laadOpvullingen();
    }

    if (widget.actieveTool == 'kleinhout') {
      _kleinhoutMenuZichtbaar = true;
    }
  }

  void _verwerkMenuOpenSignalen(OpmetingRaamTekenvlak oldWidget) {
    final vleugelSignaalGewijzigd =
        oldWidget.vleugelMenuOpenSignaal != widget.vleugelMenuOpenSignaal;

    if (widget.actieveTool == 'vleugel' && vleugelSignaalGewijzigd) {
      _vleugelMenuZichtbaar = true;
    }

    final tStijlSignaalGewijzigd =
        oldWidget.tStijlMenuOpenSignaal != widget.tStijlMenuOpenSignaal;

    if (widget.actieveTool == 'tstijl' && tStijlSignaalGewijzigd) {
      _tStijlMenuZichtbaar = true;
    }

    final opvullingSignaalGewijzigd =
        oldWidget.opvullingMenuOpenSignaal != widget.opvullingMenuOpenSignaal;

    if (widget.actieveTool == 'opvulling' && opvullingSignaalGewijzigd) {
      _opvullingMenuZichtbaar = true;
      _laadOpvullingen();
    }

    final kleinhoutSignaalGewijzigd =
        oldWidget.kleinhoutMenuOpenSignaal != widget.kleinhoutMenuOpenSignaal;

    if (widget.actieveTool == 'kleinhout' && kleinhoutSignaalGewijzigd) {
      _kleinhoutMenuZichtbaar = true;
    }
  }

  void _verwerkKaderMaatWijziging() {
    if (widget.breedteMm <= 0 || widget.hoogteMm <= 0) {
      _kaderMaatWijzigingVersie++;
      return;
    }

    if (_laatsteGeldigeBreedteMm <= 0 || _laatsteGeldigeHoogteMm <= 0) {
      _laatsteGeldigeBreedteMm = widget.breedteMm;

      _laatsteGeldigeHoogteMm = widget.hoogteMm;

      return;
    }

    if (_laatsteGeldigeBreedteMm == widget.breedteMm &&
        _laatsteGeldigeHoogteMm == widget.hoogteMm) {
      return;
    }

    final oudeBreedteMm = _laatsteGeldigeBreedteMm;

    final oudeHoogteMm = _laatsteGeldigeHoogteMm;

    final nieuweBreedteMm = widget.breedteMm;
    final nieuweHoogteMm = widget.hoogteMm;

    final versie = ++_kaderMaatWijzigingVersie;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || versie != _kaderMaatWijzigingVersie) {
        return;
      }

      final aangepast = _pasTekeningAanNieuweKaderMaten(
        oudeBreedteMm: oudeBreedteMm,
        oudeHoogteMm: oudeHoogteMm,
        nieuweBreedteMm: nieuweBreedteMm,
        nieuweHoogteMm: nieuweHoogteMm,
      );

      if (aangepast) {
        _laatsteGeldigeBreedteMm = nieuweBreedteMm;

        _laatsteGeldigeHoogteMm = nieuweHoogteMm;
      }
    });
  }

  Size? _actueleTekenvlakGrootte() {
    if (_laatsteTekenvlakGrootte.width <= 0 ||
        _laatsteTekenvlakGrootte.height <= 0 ||
        !_laatsteTekenvlakGrootte.width.isFinite ||
        !_laatsteTekenvlakGrootte.height.isFinite) {
      return null;
    }

    return _laatsteTekenvlakGrootte;
  }

  void _planOpvullingMelding() {
    if (_opvullingMeldingGepland) {
      return;
    }

    _opvullingMeldingGepland = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _opvullingMeldingGepland = false;

      if (!mounted) {
        return;
      }

      final callback = widget.onOpvullingenGewijzigd;

      final size = _actueleTekenvlakGrootte();

      if (callback == null || size == null) {
        return;
      }

      final vulvlakken = _bepaalVulvlakken(size);

      final legenda = OpmetingRaamVullingHelper.bepaalLegenda(
        vulvlakken: vulvlakken,
        toewijzingen: _vullingToewijzingen,
      );

      callback(List<OpmetingRaamVullingLegendaItem>.unmodifiable(legenda));
    });
  }

  void _planKleinhoutMelding() {
    if (_kleinhoutMeldingGepland) {
      return;
    }

    _kleinhoutMeldingGepland = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _kleinhoutMeldingGepland = false;

      if (!mounted) {
        return;
      }

      final callback = widget.onKleinhoutenGewijzigd;

      final size = _actueleTekenvlakGrootte();

      if (callback == null || size == null) {
        return;
      }

      final vulvlakken = _bepaalVulvlakken(size);

      final legenda = OpmetingRaamKleinhoutHelper.bepaalLegenda(
        vulvlakken: vulvlakken,
        kleinhouten: _kleinhouten,
      );

      callback(List<OpmetingRaamKleinhoutLegendaItem>.unmodifiable(legenda));
    });
  }

  bool _pasTekeningAanNieuweKaderMaten({
    required int oudeBreedteMm,
    required int oudeHoogteMm,
    required int nieuweBreedteMm,
    required int nieuweHoogteMm,
  }) {
    final size = _actueleTekenvlakGrootte();

    if (size == null) {
      return false;
    }

    final oudeVulvlakken = _bepaalVulvlakken(size);

    final resultaat =
        OpmetingRaamTekenvlakMaatWijziging.pasTekeningAanNieuweKaderMaten(
          tekenvlakGrootte: size,
          oudeBreedteMm: oudeBreedteMm,
          oudeHoogteMm: oudeHoogteMm,
          nieuweBreedteMm: nieuweBreedteMm,
          nieuweHoogteMm: nieuweHoogteMm,
          bestaandeTStijlen: _tStijlen,
          bestaandeVleugels: _vleugels,
        );

    if (resultaat == null) {
      return false;
    }

    final nieuweVulvlakken = _bepaalVulvlakkenVoor(
      size: size,
      tStijlen: resultaat.tStijlen,
      vleugels: resultaat.vleugels,
      breedteMm: nieuweBreedteMm,
      hoogteMm: nieuweHoogteMm,
    );

    final nieuweKleinhouten =
        OpmetingRaamKleinhoutHelper.herkoppelKleinhoutenNaVlakWijziging(
          oudeVulvlakken: oudeVulvlakken,
          nieuweVulvlakken: nieuweVulvlakken,
          bestaandeKleinhouten: _kleinhouten,
          nieuweGevuldeVlakIds: _gevuldeVlakIds,
        );

    setState(() {
      _tStijlen
        ..clear()
        ..addAll(resultaat.tStijlen);

      _vleugels
        ..clear()
        ..addAll(resultaat.vleugels);

      _kleinhouten
        ..clear()
        ..addAll(nieuweKleinhouten);

      _geselecteerdeLijn = null;
      _geselecteerdeVulvlakIds.clear();
      _geselecteerdeKleinhoutVlakIds.clear();

      _schoonVullingEnKleinhoutenOp();
    });

    _wisGeschiedenis();
    _planOpvullingMelding();
    _planKleinhoutMelding();

    return true;
  }

  List<OpmetingRaamVulvlak> _bepaalVulvlakken(Size size) {
    return _bepaalVulvlakkenVoor(
      size: size,
      tStijlen: _tStijlen,
      vleugels: _vleugels,
      breedteMm: widget.breedteMm,
      hoogteMm: widget.hoogteMm,
    );
  }

  List<OpmetingRaamVulvlak> _bepaalVulvlakkenVoor({
    required Size size,
    required List<OpmetingRaamTStijl> tStijlen,
    required List<OpmetingRaamVleugel> vleugels,
    int? breedteMm,
    int? hoogteMm,
  }) {
    return OpmetingRaamTekenvlakActies.bepaalVulvlakken(
      tekenvlakGrootte: size,
      breedteMm: breedteMm ?? widget.breedteMm,
      hoogteMm: hoogteMm ?? widget.hoogteMm,
      tStijlen: tStijlen,
      vleugels: vleugels,
    );
  }

  void _klikTekenvlak(TapDownDetails details) {
    switch (widget.actieveTool) {
      case 'opvulling':
        _selecteerVulvlak(details.localPosition);
        return;

      case 'kleinhout':
        _selecteerKleinhoutVlak(details.localPosition);
        return;

      case 'vleugel':
        _pasVleugelToe(details.localPosition);
        return;

      case 'tstijl':
        _selecteerTStijlStartLijn(details.localPosition);
        return;

      default:
        return;
    }
  }

  void _selecteerVulvlak(Offset punt) {
    final size = _actueleTekenvlakGrootte();

    if (size == null) {
      return;
    }

    final vulvlakken = _bepaalVulvlakken(size);

    final resultaat = OpmetingRaamTekenvlakActies.wisselVulvlakSelectie(
      punt: punt,
      vulvlakken: vulvlakken,
      huidigeGeselecteerdeVulvlakIds: _geselecteerdeVulvlakIds,
      toewijzingen: _vullingToewijzingen,
      opvullingen: _opvullingen,
      huidigeGeselecteerdeOpvullingId: _geselecteerdeOpvullingId,
    );

    if (!resultaat.vlakGevonden) {
      return;
    }

    setState(() {
      _geselecteerdeVulvlakIds
        ..clear()
        ..addAll(resultaat.geselecteerdeVulvlakIds);

      _geselecteerdeOpvullingId = resultaat.geselecteerdeOpvullingId;
    });
  }

  void _selecteerKleinhoutVlak(Offset punt) {
    final size = _actueleTekenvlakGrootte();

    if (size == null) {
      return;
    }

    final vulvlakken = _bepaalVulvlakken(size);

    final vulvlak = OpmetingRaamVullingHelper.vindVulvlak(
      punt: punt,
      vulvlakken: vulvlakken,
    );

    if (vulvlak == null) {
      return;
    }

    if (!_gevuldeVlakIds.contains(vulvlak.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Kleinhouten kunnen alleen geplaatst worden wanneer het glasvlak een opvulling heeft.',
          ),
          backgroundColor: Color(0xFFB45309),
        ),
      );

      return;
    }

    final wordtToegevoegd = !_geselecteerdeKleinhoutVlakIds.contains(
      vulvlak.id,
    );

    setState(() {
      if (wordtToegevoegd) {
        _geselecteerdeKleinhoutVlakIds.add(vulvlak.id);

        _laadKleinhoutInstellingenVoorVlak(vulvlak.id);
      } else {
        _geselecteerdeKleinhoutVlakIds.remove(vulvlak.id);
      }

      _kleinhoutMenuZichtbaar = true;
    });
  }

  void _laadKleinhoutInstellingenVoorVlak(String vlakId) {
    OpmetingRaamKleinhout? bestaand;

    for (final kleinhout in _kleinhouten) {
      if (kleinhout.vlakId == vlakId) {
        bestaand = kleinhout;
        break;
      }
    }

    if (bestaand == null) {
      return;
    }

    _geselecteerdKleinhoutType = bestaand.type;

    _geselecteerdKleinhoutPatroon = bestaand.patroon;

    _kleinhoutAantalHorizontaalController.text = bestaand
        .effectiefAantalHorizontaal
        .toString();

    _kleinhoutAantalVerticaalController.text = bestaand.effectiefAantalVerticaal
        .toString();

    _kleinhoutHorizontaleHoogteController.text =
        bestaand.horizontaleHoogteMm == null
        ? ''
        : _formatteerMaat(bestaand.horizontaleHoogteMm!);
  }

  String _formatteerMaat(double waarde) {
    if (waarde == waarde.roundToDouble()) {
      return waarde.round().toString();
    }

    return waarde.toStringAsFixed(1);
  }

  void _pasOpvullingToe() {
    final size = _actueleTekenvlakGrootte();

    if (size == null || _geselecteerdeVulvlakIds.isEmpty) {
      return;
    }

    final opvulling = OpmetingRaamTekenvlakActies.vindGeselecteerdeOpvulling(
      opvullingen: _opvullingen,
      geselecteerdeOpvullingId: _geselecteerdeOpvullingId,
    );

    if (opvulling == null) {
      return;
    }

    final vulvlakken = _bepaalVulvlakken(size);

    final nieuweToewijzingen = OpmetingRaamTekenvlakActies.pasOpvullingToe(
      vulvlakken: vulvlakken,
      geselecteerdeVulvlakIds: _geselecteerdeVulvlakIds,
      bestaandeToewijzingen: _vullingToewijzingen,
      opvulling: opvulling,
    );

    final gewijzigd = !_zelfdeVullingToewijzingen(
      _vullingToewijzingen,
      nieuweToewijzingen,
    );

    if (!gewijzigd) {
      setState(() {
        _geselecteerdeVulvlakIds.clear();
      });

      return;
    }

    _bewaarVoorWijziging();

    setState(() {
      _vullingToewijzingen
        ..clear()
        ..addAll(nieuweToewijzingen);

      _geselecteerdeVulvlakIds.clear();

      _schoonKleinhoutenOp();
    });

    _planOpvullingMelding();
    _planKleinhoutMelding();
  }

  void _verwijderOpvullingUitSelectie() {
    if (_geselecteerdeVulvlakIds.isEmpty) {
      return;
    }

    final nieuweToewijzingen =
        OpmetingRaamTekenvlakActies.verwijderOpvullingUitSelectie(
          bestaandeToewijzingen: _vullingToewijzingen,
          geselecteerdeVulvlakIds: _geselecteerdeVulvlakIds,
        );

    final gewijzigd = !_zelfdeVullingToewijzingen(
      _vullingToewijzingen,
      nieuweToewijzingen,
    );

    if (!gewijzigd) {
      setState(() {
        _geselecteerdeVulvlakIds.clear();
      });

      return;
    }

    _bewaarVoorWijziging();

    setState(() {
      _vullingToewijzingen
        ..clear()
        ..addAll(nieuweToewijzingen);

      _geselecteerdeVulvlakIds.clear();

      _schoonKleinhoutenOp();
    });

    _planOpvullingMelding();
    _planKleinhoutMelding();
  }

  bool _zelfdeVullingToewijzingen(
    List<OpmetingRaamVullingToewijzing> eerste,
    List<OpmetingRaamVullingToewijzing> tweede,
  ) {
    if (eerste.length != tweede.length) {
      return false;
    }

    for (var index = 0; index < eerste.length; index++) {
      final eersteItem = eerste[index];
      final tweedeItem = tweede[index];

      if (eersteItem.vlakId != tweedeItem.vlakId ||
          eersteItem.opvullingId != tweedeItem.opvullingId) {
        return false;
      }
    }

    return true;
  }

  void _selecteerAlleVulvlakken() {
    final size = _actueleTekenvlakGrootte();

    if (size == null) {
      return;
    }

    final vulvlakken = _bepaalVulvlakken(size);

    final selectie = OpmetingRaamTekenvlakActies.selecteerAlleVulvlakken(
      vulvlakken,
    );

    setState(() {
      _geselecteerdeVulvlakIds
        ..clear()
        ..addAll(selectie);
    });
  }

  void _wisVulvlakSelectie() {
    if (_geselecteerdeVulvlakIds.isEmpty) {
      return;
    }

    setState(() {
      _geselecteerdeVulvlakIds.clear();
    });
  }

  void _selecteerAlleGevuldeKleinhoutVlakken() {
    final size = _actueleTekenvlakGrootte();

    if (size == null) {
      return;
    }

    final bestaandeVlakIds = _bepaalVulvlakken(
      size,
    ).map((vlak) => vlak.id).toSet();

    final selectie = _gevuldeVlakIds.where(bestaandeVlakIds.contains).toSet();

    setState(() {
      _geselecteerdeKleinhoutVlakIds
        ..clear()
        ..addAll(selectie);

      if (selectie.isNotEmpty) {
        _laadKleinhoutInstellingenVoorVlak(selectie.first);
      }
    });
  }

  void _wisKleinhoutSelectie() {
    if (_geselecteerdeKleinhoutVlakIds.isEmpty) {
      return;
    }

    setState(() {
      _geselecteerdeKleinhoutVlakIds.clear();
    });
  }

  void _pasKleinhoutenToe() {
    final size = _actueleTekenvlakGrootte();

    if (size == null ||
        _geselecteerdeKleinhoutVlakIds.isEmpty ||
        !_kleinhoutSelectieIsVolledigGevuld) {
      return;
    }

    final aantalHorizontaal =
        int.tryParse(_kleinhoutAantalHorizontaalController.text.trim()) ?? 0;

    final aantalVerticaal =
        int.tryParse(_kleinhoutAantalVerticaalController.text.trim()) ?? 0;

    double? horizontaleHoogteMm;

    if (_geselecteerdKleinhoutPatroon ==
        OpmetingRaamKleinhoutPatroon.bovenverdeling) {
      horizontaleHoogteMm = double.tryParse(
        _kleinhoutHorizontaleHoogteController.text.trim().replaceAll(',', '.'),
      );

      if (horizontaleHoogteMm == null || horizontaleHoogteMm <= 0) {
        _toonKleinhoutFout(
          'Vul een geldige hoogte in voor het horizontale kleinhout.',
        );
        return;
      }

      final maximumHoogte = _kleinsteGeselecteerdeVlakHoogteMm(size);

      if (maximumHoogte != null && horizontaleHoogteMm >= maximumHoogte) {
        _toonKleinhoutFout(
          'De hoogte van het horizontale kleinhout moet kleiner zijn dan de hoogte van het glasvlak.',
        );
        return;
      }
    } else {
      if (aantalHorizontaal <= 0 && aantalVerticaal <= 0) {
        _toonKleinhoutFout(
          'Vul minstens één horizontaal of verticaal kleinhout in.',
        );
        return;
      }
    }

    if (aantalHorizontaal < 0 || aantalVerticaal < 0) {
      _toonKleinhoutFout('Het aantal kleinhouten kan niet negatief zijn.');
      return;
    }

    final vulvlakken = _bepaalVulvlakken(size);

    final geselecteerdeVlakken = vulvlakken.where(
      (vlak) => _geselecteerdeKleinhoutVlakIds.contains(vlak.id),
    );

    final nieuweKleinhouten = OpmetingRaamKleinhoutHelper.pasKleinhoutenToe(
      bestaandeKleinhouten: _kleinhouten,
      geselecteerdeVlakken: geselecteerdeVlakken,
      gevuldeVlakIds: _gevuldeVlakIds,
      type: _geselecteerdKleinhoutType,
      patroon: _geselecteerdKleinhoutPatroon,
      aantalHorizontaal: aantalHorizontaal,
      aantalVerticaal: aantalVerticaal,
      horizontaleHoogteMm: horizontaleHoogteMm,
    );

    if (_zelfdeKleinhouten(_kleinhouten, nieuweKleinhouten)) {
      return;
    }

    _bewaarVoorWijziging();

    setState(() {
      _kleinhouten
        ..clear()
        ..addAll(nieuweKleinhouten);
    });

    _planKleinhoutMelding();
  }

  double? _kleinsteGeselecteerdeVlakHoogteMm(Size size) {
    if (widget.hoogteMm <= 0) {
      return null;
    }

    final buitenKader = OpmetingRaamKaderHelper.buitenKader(
      size: size,
      breedteMm: widget.breedteMm,
      hoogteMm: widget.hoogteMm,
    );

    if (buitenKader.height <= 0) {
      return null;
    }

    final pixelsPerMm = buitenKader.height / widget.hoogteMm;

    if (pixelsPerMm <= 0) {
      return null;
    }

    final geselecteerdeVlakken = _bepaalVulvlakken(
      size,
    ).where((vlak) => _geselecteerdeKleinhoutVlakIds.contains(vlak.id));

    double? kleinsteHoogte;

    for (final vlak in geselecteerdeVlakken) {
      final hoogteMm = vlak.vlak.height / pixelsPerMm;

      if (kleinsteHoogte == null || hoogteMm < kleinsteHoogte) {
        kleinsteHoogte = hoogteMm;
      }
    }

    return kleinsteHoogte;
  }

  void _verwijderGeselecteerdeKleinhouten() {
    if (_geselecteerdeKleinhoutVlakIds.isEmpty) {
      return;
    }

    final nieuweKleinhouten =
        OpmetingRaamKleinhoutHelper.verwijderKleinhoutenUitVlakken(
          bestaandeKleinhouten: _kleinhouten,
          vlakIds: _geselecteerdeKleinhoutVlakIds,
        );

    if (_zelfdeKleinhouten(_kleinhouten, nieuweKleinhouten)) {
      return;
    }

    _bewaarVoorWijziging();

    setState(() {
      _kleinhouten
        ..clear()
        ..addAll(nieuweKleinhouten);
    });

    _planKleinhoutMelding();
  }

  bool _zelfdeKleinhouten(
    List<OpmetingRaamKleinhout> eerste,
    List<OpmetingRaamKleinhout> tweede,
  ) {
    if (eerste.length != tweede.length) {
      return false;
    }

    for (var index = 0; index < eerste.length; index++) {
      final eersteItem = eerste[index];
      final tweedeItem = tweede[index];

      if (eersteItem.id != tweedeItem.id ||
          eersteItem.vlakId != tweedeItem.vlakId ||
          eersteItem.werkvlakId != tweedeItem.werkvlakId ||
          eersteItem.type != tweedeItem.type ||
          eersteItem.patroon != tweedeItem.patroon ||
          eersteItem.effectiefAantalHorizontaal !=
              tweedeItem.effectiefAantalHorizontaal ||
          eersteItem.effectiefAantalVerticaal !=
              tweedeItem.effectiefAantalVerticaal ||
          eersteItem.horizontaleHoogteMm != tweedeItem.horizontaleHoogteMm ||
          eersteItem.breedteMm != tweedeItem.breedteMm) {
        return false;
      }
    }

    return true;
  }

  void _toonKleinhoutFout(String melding) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(melding),
        backgroundColor: const Color(0xFFDC2626),
      ),
    );
  }

  void _schoonVullingEnKleinhoutenOp() {
    final size = _actueleTekenvlakGrootte();

    if (size == null) {
      return;
    }

    final vulvlakken = _bepaalVulvlakken(size);

    final resultaat = OpmetingRaamTekenvlakActies.schoonVullingToewijzingenOp(
      huidigeVulvlakken: vulvlakken,
      bestaandeToewijzingen: _vullingToewijzingen,
      geselecteerdeVulvlakIds: _geselecteerdeVulvlakIds,
    );

    _vullingToewijzingen
      ..clear()
      ..addAll(resultaat.toewijzingen);

    _geselecteerdeVulvlakIds
      ..clear()
      ..addAll(resultaat.geselecteerdeVulvlakIds);

    _schoonKleinhoutenOp(vulvlakken: vulvlakken);
  }

  void _schoonKleinhoutenOp({List<OpmetingRaamVulvlak>? vulvlakken}) {
    final size = _actueleTekenvlakGrootte();

    if (size == null) {
      return;
    }

    final huidigeVulvlakken = vulvlakken ?? _bepaalVulvlakken(size);

    var opgeschoond =
        OpmetingRaamKleinhoutHelper.verwijderNietBestaandeKleinhouten(
          bestaandeKleinhouten: _kleinhouten,
          huidigeVulvlakken: huidigeVulvlakken,
        );

    opgeschoond =
        OpmetingRaamKleinhoutHelper.verwijderKleinhoutenZonderOpvulling(
          bestaandeKleinhouten: opgeschoond,
          gevuldeVlakIds: _gevuldeVlakIds,
        );

    _kleinhouten
      ..clear()
      ..addAll(opgeschoond);

    final bestaandeVlakIds = huidigeVulvlakken.map((vlak) => vlak.id).toSet();

    _geselecteerdeKleinhoutVlakIds.removeWhere(
      (vlakId) =>
          !bestaandeVlakIds.contains(vlakId) ||
          !_gevuldeVlakIds.contains(vlakId),
    );
  }

  void _selecteerTStijlStartLijn(Offset punt) {
    final size = _actueleTekenvlakGrootte();

    if (size == null) {
      return;
    }

    final lijn = OpmetingRaamTekenvlakActies.vindTStijlStartLijn(
      punt: punt,
      tekenvlakGrootte: size,
      breedteMm: widget.breedteMm,
      hoogteMm: widget.hoogteMm,
      tStijlen: _tStijlen,
      vleugels: _vleugels,
    );

    setState(() {
      _geselecteerdeLijn = lijn;

      if (lijn != null) {
        _tStijlMenuZichtbaar = true;
      }
    });
  }

  Offset? _previewPunt(Size size) {
    return OpmetingRaamTekenvlakActies.bepaalTStijlPreviewPunt(
      geselecteerdeLijn: _geselecteerdeLijn,
      tekenvlakGrootte: size,
      breedteMm: widget.breedteMm,
      hoogteMm: widget.hoogteMm,
      positieType: _positieType,
      positieTekst: widget.positieController.text,
    );
  }

  void _tStijlToevoegen() {
    final size = _actueleTekenvlakGrootte();

    if (size == null) {
      return;
    }

    if (_geselecteerdeTStijlHeeftVleugelsLangsBeideZijden(size)) {
      return;
    }

    final stijl = OpmetingRaamTekenvlakActies.maakTStijl(
      geselecteerdeLijn: _geselecteerdeLijn,
      tekenvlakGrootte: size,
      breedteMm: widget.breedteMm,
      hoogteMm: widget.hoogteMm,
      positieType: _positieType,
      positieTekst: widget.positieController.text,
      bestaandeTStijlen: _tStijlen,
      vleugels: _vleugels,
    );

    if (stijl == null) {
      return;
    }

    _bewaarVoorWijziging();

    setState(() {
      _tStijlen.add(stijl);

      _geselecteerdeLijn = null;
      _geselecteerdeVulvlakIds.clear();
      _geselecteerdeKleinhoutVlakIds.clear();

      _schoonVullingEnKleinhoutenOp();
    });

    _planOpvullingMelding();
    _planKleinhoutMelding();
  }

  void _verplaatsGeselecteerdeTStijl() {
    final index = OpmetingRaamTekenvlakActies.indexVanGeselecteerdeTStijlLijn(
      _geselecteerdeLijn,
    );

    final size = _actueleTekenvlakGrootte();

    if (index == null || size == null) {
      return;
    }

    final oudeVulvlakken = _bepaalVulvlakken(size);

    final resultaat = OpmetingRaamTStijlVerplaatsHelper.verplaatsTStijl(
      tekenvlakGrootte: size,
      breedteMm: widget.breedteMm,
      hoogteMm: widget.hoogteMm,
      tStijlIndex: index,
      positieType: _positieType,
      positieTekst: widget.positieController.text,
      bestaandeTStijlen: _tStijlen,
      bestaandeVleugels: _vleugels,
      bestaandeVullingToewijzingen: _vullingToewijzingen,
    );

    if (!resultaat.gewijzigd) {
      final foutmelding = resultaat.foutmelding?.trim();

      if (foutmelding != null && foutmelding.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(foutmelding),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }

      return;
    }

    final nieuweVulvlakken = _bepaalVulvlakkenVoor(
      size: size,
      tStijlen: resultaat.tStijlen,
      vleugels: resultaat.vleugels,
    );

    final nieuweGevuldeVlakIds = resultaat.vullingToewijzingen
        .map((toewijzing) => toewijzing.vlakId)
        .toSet();

    final nieuweKleinhouten =
        OpmetingRaamKleinhoutHelper.herkoppelKleinhoutenNaVlakWijziging(
          oudeVulvlakken: oudeVulvlakken,
          nieuweVulvlakken: nieuweVulvlakken,
          bestaandeKleinhouten: _kleinhouten,
          nieuweGevuldeVlakIds: nieuweGevuldeVlakIds,
        );

    _bewaarVoorWijziging();

    setState(() {
      _tStijlen
        ..clear()
        ..addAll(resultaat.tStijlen);

      _vleugels
        ..clear()
        ..addAll(resultaat.vleugels);

      _vullingToewijzingen
        ..clear()
        ..addAll(resultaat.vullingToewijzingen);

      _kleinhouten
        ..clear()
        ..addAll(nieuweKleinhouten);

      _geselecteerdeLijn = null;
      _geselecteerdeVulvlakIds.clear();
      _geselecteerdeKleinhoutVlakIds.clear();
    });

    _planOpvullingMelding();
    _planKleinhoutMelding();
  }

  void _wisTStijlVanGeselecteerdeLijn() {
    final index = OpmetingRaamTekenvlakActies.indexVanGeselecteerdeTStijlLijn(
      _geselecteerdeLijn,
    );

    final size = _actueleTekenvlakGrootte();

    if (index == null || size == null) {
      return;
    }

    if (_geselecteerdeTStijlHeeftVleugelsLangsBeideZijden(size)) {
      return;
    }

    final magWissen = OpmetingRaamTekenvlakActies.magTStijlWissen(
      index: index,
      tekenvlakGrootte: size,
      breedteMm: widget.breedteMm,
      hoogteMm: widget.hoogteMm,
      tStijlen: _tStijlen,
    );

    if (!magWissen) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Deze T-stijl kan niet gewist worden omdat er een andere T-stijl op aansluit.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    final nieuweTStijlen = OpmetingRaamTekenvlakActies.verwijderTStijl(
      index: index,
      tStijlen: _tStijlen,
    );

    _bewaarVoorWijziging();

    setState(() {
      _tStijlen
        ..clear()
        ..addAll(nieuweTStijlen);

      _geselecteerdeLijn = null;
      _geselecteerdeVulvlakIds.clear();
      _geselecteerdeKleinhoutVlakIds.clear();

      _schoonVullingEnKleinhoutenOp();
    });

    _planOpvullingMelding();
    _planKleinhoutMelding();
  }

  bool _geselecteerdeTStijlHeeftVleugelsLangsBeideZijden(
    Size tekenvlakGrootte,
  ) {
    final index = OpmetingRaamTekenvlakActies.indexVanGeselecteerdeTStijlLijn(
      _geselecteerdeLijn,
    );

    if (index == null || index < 0 || index >= _tStijlen.length) {
      return false;
    }

    final buitenKader = OpmetingRaamKaderHelper.buitenKader(
      size: tekenvlakGrootte,
      breedteMm: widget.breedteMm,
      hoogteMm: widget.hoogteMm,
    );

    return OpmetingRaamTStijlHelper.heeftVleugelLangsBeideZijden(
      tStijlIndex: index,
      tStijlen: _tStijlen,
      vleugels: _vleugels,
      buitenKader: buitenKader,
      breedteMm: widget.breedteMm,
      hoogteMm: widget.hoogteMm,
    );
  }

  void _pasVleugelToe(Offset punt) {
    final size = _actueleTekenvlakGrootte();

    if (size == null) {
      return;
    }

    final resultaat = OpmetingRaamTekenvlakActies.pasVleugelToe(
      punt: punt,
      tekenvlakGrootte: size,
      breedteMm: widget.breedteMm,
      hoogteMm: widget.hoogteMm,
      geselecteerdVleugelType: _geselecteerdVleugelType,
      bestaandeTStijlen: _tStijlen,
      bestaandeVleugels: _vleugels,
    );

    if (!resultaat.gewijzigd) {
      return;
    }

    _bewaarVoorWijziging();

    setState(() {
      _tStijlen
        ..clear()
        ..addAll(resultaat.tStijlen);

      _vleugels
        ..clear()
        ..addAll(resultaat.vleugels);

      _geselecteerdeLijn = null;
      _geselecteerdeVulvlakIds.clear();
      _geselecteerdeKleinhoutVlakIds.clear();

      _schoonVullingEnKleinhoutenOp();
    });

    _planOpvullingMelding();
    _planKleinhoutMelding();
  }

  void _verplaatsVleugelMenu({
    required DragUpdateDetails details,
    required Size tekenvlakGrootte,
    required Size menuGrootte,
  }) {
    final nieuwePositie = OpmetingRaamTekenvlakActies.verplaatsVleugelMenu(
      huidigePositie: _vleugelMenuPositie,
      verplaatsing: details.delta,
      tekenvlakGrootte: tekenvlakGrootte,
      menuGrootte: menuGrootte,
    );

    setState(() {
      _vleugelMenuPositie = nieuwePositie;
    });
  }

  Size _meetMenuGrootte({
    required GlobalKey menuKey,
    required double standaardBreedte,
  }) {
    final menuContext = menuKey.currentContext;

    final renderObject = menuContext?.findRenderObject();

    if (renderObject is RenderBox && renderObject.hasSize) {
      final gemetenGrootte = renderObject.size;

      if (gemetenGrootte.width > 0 &&
          gemetenGrootte.height > 0 &&
          gemetenGrootte.width.isFinite &&
          gemetenGrootte.height.isFinite) {
        return gemetenGrootte;
      }
    }

    return Size(standaardBreedte, 38);
  }

  Offset _begrensVerplaatsbaarMenu({
    required Offset positie,
    required Size tekenvlakGrootte,
    required Size menuGrootte,
  }) {
    final maximaleX = tekenvlakGrootte.width > menuGrootte.width
        ? tekenvlakGrootte.width - menuGrootte.width
        : 0.0;

    final effectieveHoogte = menuGrootte.height > 38
        ? menuGrootte.height
        : 38.0;

    final maximaleY = tekenvlakGrootte.height > effectieveHoogte
        ? tekenvlakGrootte.height - effectieveHoogte
        : 0.0;

    return Offset(
      positie.dx.clamp(0.0, maximaleX).toDouble(),
      positie.dy.clamp(0.0, maximaleY).toDouble(),
    );
  }

  void _verplaatsTStijlMenu({
    required DragUpdateDetails details,
    required Size tekenvlakGrootte,
  }) {
    final menuGrootte = _meetMenuGrootte(
      menuKey: _tStijlMenuKey,
      standaardBreedte: 260,
    );

    final nieuwePositie = _begrensVerplaatsbaarMenu(
      positie: Offset(
        _tStijlMenuPositie.dx + details.delta.dx,
        _tStijlMenuPositie.dy + details.delta.dy,
      ),
      tekenvlakGrootte: tekenvlakGrootte,
      menuGrootte: menuGrootte,
    );

    setState(() {
      _tStijlMenuPositie = nieuwePositie;
    });
  }

  void _verplaatsOpvullingMenu({
    required DragUpdateDetails details,
    required Size tekenvlakGrootte,
    required double menuBreedte,
  }) {
    final menuGrootte = _meetMenuGrootte(
      menuKey: _opvullingMenuKey,
      standaardBreedte: menuBreedte,
    );

    final nieuwePositie = _begrensVerplaatsbaarMenu(
      positie: Offset(
        _opvullingMenuPositie.dx + details.delta.dx,
        _opvullingMenuPositie.dy + details.delta.dy,
      ),
      tekenvlakGrootte: tekenvlakGrootte,
      menuGrootte: menuGrootte,
    );

    setState(() {
      _opvullingMenuPositie = nieuwePositie;
    });
  }

  void _verplaatsKleinhoutMenu({
    required DragUpdateDetails details,
    required Size tekenvlakGrootte,
    required double menuBreedte,
  }) {
    final menuGrootte = _meetMenuGrootte(
      menuKey: _kleinhoutMenuKey,
      standaardBreedte: menuBreedte,
    );

    final nieuwePositie = _begrensVerplaatsbaarMenu(
      positie: Offset(
        _kleinhoutMenuPositie.dx + details.delta.dx,
        _kleinhoutMenuPositie.dy + details.delta.dy,
      ),
      tekenvlakGrootte: tekenvlakGrootte,
      menuGrootte: menuGrootte,
    );

    setState(() {
      _kleinhoutMenuPositie = nieuwePositie;
    });
  }

  Widget _verplaatsbaarMenu({
    required GlobalKey menuKey,
    required double breedte,
    required String titel,
    required ValueChanged<DragUpdateDetails> onVerslepen,
    required VoidCallback onSluiten,
    required Widget child,
  }) {
    return SizedBox(
      key: menuKey,
      width: breedte,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF0B7A3B),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFF086330)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.move,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: onVerslepen,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, right: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.drag_indicator,
                              size: 19,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                titel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.open_with,
                              size: 17,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: IconButton(
                    tooltip: 'Menu sluiten',
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 30,
                      minHeight: 30,
                    ),
                    onPressed: onSluiten,
                    icon: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          _laatsteTekenvlakGrootte = size;

          if (!_eersteOpvullingMeldingGepland) {
            _eersteOpvullingMeldingGepland = true;

            _planOpvullingMelding();
          }

          if (!_eersteKleinhoutMeldingGepland) {
            _eersteKleinhoutMeldingGepland = true;

            _planKleinhoutMelding();
          }

          final preview = _previewPunt(size);

          final vulvlakken = _bepaalVulvlakken(size);

          final alleenVerplaatsenVoorGeselecteerdeTStijl =
              _bestaandeTStijlGeselecteerd &&
              _geselecteerdeTStijlHeeftVleugelsLangsBeideZijden(size);

          final vleugelMenuGrootte =
              OpmetingRaamTekenvlakActies.berekenVleugelMenuGrootte(size);

          final vleugelMenuPositie =
              OpmetingRaamTekenvlakActies.begrensVleugelMenuPositie(
                positie: _vleugelMenuPositie,
                tekenvlakGrootte: size,
                menuGrootte: vleugelMenuGrootte,
              );

          final beschikbareOpvullingMenuBreedte = size.width > 24
              ? size.width - 24
              : size.width;

          final opvullingMenuBreedte = beschikbareOpvullingMenuBreedte
              .clamp(220.0, 310.0)
              .toDouble();

          final kleinhoutMenuBreedte = beschikbareOpvullingMenuBreedte
              .clamp(280.0, 320.0)
              .toDouble();

          final tStijlMenuGrootte = _meetMenuGrootte(
            menuKey: _tStijlMenuKey,
            standaardBreedte: 260,
          );

          final tStijlMenuPositie = _begrensVerplaatsbaarMenu(
            positie: _tStijlMenuPositie,
            tekenvlakGrootte: size,
            menuGrootte: tStijlMenuGrootte,
          );

          final opvullingMenuGrootte = _meetMenuGrootte(
            menuKey: _opvullingMenuKey,
            standaardBreedte: opvullingMenuBreedte,
          );

          final opvullingMenuPositie = _begrensVerplaatsbaarMenu(
            positie: _opvullingMenuPositie,
            tekenvlakGrootte: size,
            menuGrootte: opvullingMenuGrootte,
          );

          final kleinhoutMenuGrootte = _meetMenuGrootte(
            menuKey: _kleinhoutMenuKey,
            standaardBreedte: kleinhoutMenuBreedte,
          );

          final kleinhoutMenuPositie = _begrensVerplaatsbaarMenu(
            positie: _kleinhoutMenuPositie,
            tekenvlakGrootte: size,
            menuGrootte: kleinhoutMenuGrootte,
          );

          final maximaleKleinhoutMenuHoogte = size.height > 70
              ? size.height - 70
              : size.height;

          final totaalAantalGevuldeVlakken = vulvlakken
              .where((vlak) => _gevuldeVlakIds.contains(vlak.id))
              .length;

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: _klikTekenvlak,
                  child: CustomPaint(
                    painter: OpmetingRaamTekenvlakPainter(
                      breedteMm: widget.breedteMm,
                      hoogteMm: widget.hoogteMm,
                      geselecteerdeLijn: _geselecteerdeLijn,
                      previewPunt: preview,
                      tStijlen: _tStijlen,
                      vleugels: _vleugels,
                      vulvlakken: vulvlakken,
                      vullingToewijzingen: _vullingToewijzingen,
                      geselecteerdeVulvlakIds: _geselecteerdeVulvlakIds,
                      kleinhouten: _kleinhouten,
                      geselecteerdeKleinhoutVlakIds:
                          _geselecteerdeKleinhoutVlakIds,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              if (widget.actieveTool == 'tstijl' &&
                  _geselecteerdeLijn != null &&
                  _tStijlMenuZichtbaar)
                Positioned(
                  left: tStijlMenuPositie.dx,
                  top: tStijlMenuPositie.dy,
                  child: _verplaatsbaarMenu(
                    menuKey: _tStijlMenuKey,
                    breedte: 260,
                    titel: 'T-stijlmenu verplaatsen',
                    onVerslepen: (details) {
                      _verplaatsTStijlMenu(
                        details: details,
                        tekenvlakGrootte: size,
                      );
                    },
                    onSluiten: () {
                      setState(() {
                        _tStijlMenuZichtbaar = false;
                      });
                    },
                    child: OpmetingRaamTStijlMenu(
                      positieType: _positieType,
                      positieController: widget.positieController,
                      toonToevoegKnop:
                          !alleenVerplaatsenVoorGeselecteerdeTStijl,
                      toonWisKnop:
                          _bestaandeTStijlGeselecteerd &&
                          !alleenVerplaatsenVoorGeselecteerdeTStijl,
                      toonVerplaatsKnop: _bestaandeTStijlGeselecteerd,
                      onPositieTypeGewijzigd: (waarde) {
                        setState(() {
                          _positieType = waarde;
                        });
                      },
                      onMaatGewijzigd: (_) {
                        setState(() {});
                      },
                      onToevoegen: _tStijlToevoegen,
                      onVerplaatsen: _verplaatsGeselecteerdeTStijl,
                      onWissen: _wisTStijlVanGeselecteerdeLijn,
                    ),
                  ),
                ),
              if (widget.actieveTool == 'vleugel' && _vleugelMenuZichtbaar)
                Positioned(
                  left: vleugelMenuPositie.dx,
                  top: vleugelMenuPositie.dy,
                  child: OpmetingRaamVleugelMenu(
                    menuGrootte: vleugelMenuGrootte,
                    geselecteerdType: _geselecteerdVleugelType,
                    onTypeGekozen: (type) {
                      setState(() {
                        _geselecteerdVleugelType = type;
                      });
                    },
                    onSluiten: () {
                      setState(() {
                        _vleugelMenuZichtbaar = false;
                      });
                    },
                    onVerslepen: (details) {
                      _verplaatsVleugelMenu(
                        details: details,
                        tekenvlakGrootte: size,
                        menuGrootte: vleugelMenuGrootte,
                      );
                    },
                  ),
                ),
              if (widget.actieveTool == 'opvulling' && _opvullingMenuZichtbaar)
                Positioned(
                  left: opvullingMenuPositie.dx,
                  top: opvullingMenuPositie.dy,
                  child: _verplaatsbaarMenu(
                    menuKey: _opvullingMenuKey,
                    breedte: opvullingMenuBreedte,
                    titel: 'Opvulmenu verplaatsen',
                    onVerslepen: (details) {
                      _verplaatsOpvullingMenu(
                        details: details,
                        tekenvlakGrootte: size,
                        menuBreedte: opvullingMenuBreedte,
                      );
                    },
                    onSluiten: () {
                      setState(() {
                        _opvullingMenuZichtbaar = false;
                      });
                    },
                    child: OpmetingRaamOpvullingMenu(
                      opvullingen: _opvullingen,
                      isLaden: _opvullingenLaden,
                      geselecteerdeOpvullingId: _geselecteerdeOpvullingId,
                      aantalGeselecteerdeVlakken:
                          _geselecteerdeVulvlakIds.length,
                      totaalAantalVlakken: vulvlakken.length,
                      onOpvullingGekozen: (opvullingId) {
                        setState(() {
                          _geselecteerdeOpvullingId = opvullingId;
                        });
                      },
                      onToepassen: _pasOpvullingToe,
                      onOpvullingVerwijderen: _verwijderOpvullingUitSelectie,
                      onAllesSelecteren: _selecteerAlleVulvlakken,
                      onSelectieWissen: _wisVulvlakSelectie,
                    ),
                  ),
                ),
              if (widget.actieveTool == 'kleinhout' && _kleinhoutMenuZichtbaar)
                Positioned(
                  left: kleinhoutMenuPositie.dx,
                  top: kleinhoutMenuPositie.dy,
                  child: _verplaatsbaarMenu(
                    menuKey: _kleinhoutMenuKey,
                    breedte: kleinhoutMenuBreedte,
                    titel: 'Kleinhoutmenu verplaatsen',
                    onVerslepen: (details) {
                      _verplaatsKleinhoutMenu(
                        details: details,
                        tekenvlakGrootte: size,
                        menuBreedte: kleinhoutMenuBreedte,
                      );
                    },
                    onSluiten: () {
                      setState(() {
                        _kleinhoutMenuZichtbaar = false;
                      });
                    },
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: maximaleKleinhoutMenuHoogte,
                      ),
                      child: SingleChildScrollView(
                        child: OpmetingRaamKleinhoutMenu(
                          geselecteerdType: _geselecteerdKleinhoutType,
                          geselecteerdPatroon: _geselecteerdKleinhoutPatroon,
                          horizontaleHoogteController:
                              _kleinhoutHorizontaleHoogteController,
                          aantalHorizontaalController:
                              _kleinhoutAantalHorizontaalController,
                          aantalVerticaalController:
                              _kleinhoutAantalVerticaalController,
                          aantalGeselecteerdeVlakken:
                              _geselecteerdeKleinhoutVlakIds.length,
                          totaalAantalGevuldeVlakken:
                              totaalAantalGevuldeVlakken,
                          selectieKanKleinhoutenKrijgen:
                              _kleinhoutSelectieIsVolledigGevuld,
                          selectieHeeftKleinhouten:
                              _kleinhoutSelectieHeeftKleinhouten,
                          onTypeGewijzigd: (type) {
                            setState(() {
                              _geselecteerdKleinhoutType = type;
                            });
                          },
                          onPatroonGewijzigd: (patroon) {
                            setState(() {
                              _geselecteerdKleinhoutPatroon = patroon;
                            });
                          },
                          onWaardeGewijzigd: () {
                            setState(() {});
                          },
                          onToepassen: _pasKleinhoutenToe,
                          onVerwijderen: _verwijderGeselecteerdeKleinhouten,
                          onAlleGevuldeVlakkenSelecteren:
                              _selecteerAlleGevuldeKleinhoutVlakken,
                          onSelectieWissen: _wisKleinhoutSelectie,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
