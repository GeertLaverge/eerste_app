// THIMACO-CONTROLE: VOORZETROLLUIK-BEDIENING-ZONNECEL-GELEIDERS-HERSTEL-20260731-1215
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../voorzetscreen/opmeting_voorzetscreen_instellingen_model.dart';
import 'opmeting_voorzetrolluik_instellingen_model.dart';
import 'opmeting_voorzetrolluik_kastmaat_helper.dart';
import 'opmeting_voorzetrolluik_model.dart';

class OpmetingVoorzetrolluikRechterkolom extends StatefulWidget {
  const OpmetingVoorzetrolluikRechterkolom({
    super.key,
    required this.model,
    required this.instellingen,
    required this.poederkleuren,
    required this.projectKleur,
    required this.onGewijzigd,
  });

  final OpmetingVoorzetrolluikModel model;
  final OpmetingVoorzetrolluikInstellingen instellingen;
  final List<OpmetingVoorzetscreenPoederkleur> poederkleuren;
  final String projectKleur;
  final ValueChanged<OpmetingVoorzetrolluikModel> onGewijzigd;

  @override
  State<OpmetingVoorzetrolluikRechterkolom> createState() {
    return _OpmetingVoorzetrolluikRechterkolomState();
  }
}

class _OpmetingVoorzetrolluikRechterkolomState
    extends State<OpmetingVoorzetrolluikRechterkolom> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekst = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  late final TextEditingController _positieController;
  late final TextEditingController _aantalController;
  late final TextEditingController _breedteController;
  late final TextEditingController _hoogteController;
  late final TextEditingController _openLamellenController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _positieController = TextEditingController(text: widget.model.positie);
    _aantalController = TextEditingController(
      text: widget.model.aantal.toString(),
    );
    _breedteController = TextEditingController(
      text: widget.model.breedteMm.toString(),
    );
    _hoogteController = TextEditingController(
      text: widget.model.hoogteMm.toString(),
    );
    _openLamellenController = TextEditingController(
      text: widget.model.openLamellenPercentage.toString(),
    );
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.model.kastmaatVolgensAfmetingen) return;
      final aangepast = _pasAutomatischeKastmaatToe(widget.model);
      if (aangepast.kastmaat != widget.model.kastmaat) {
        widget.onGewijzigd(aangepast);
      }
    });
  }

  @override
  void didUpdateWidget(covariant OpmetingVoorzetrolluikRechterkolom oldWidget) {
    super.didUpdateWidget(oldWidget);
    _synchroniseerController(_positieController, widget.model.positie);
    _synchroniseerController(_aantalController, widget.model.aantal.toString());
    _synchroniseerController(
      _breedteController,
      widget.model.breedteMm.toString(),
    );
    _synchroniseerController(
      _hoogteController,
      widget.model.hoogteMm.toString(),
    );
    _synchroniseerController(
      _openLamellenController,
      widget.model.openLamellenPercentage.toString(),
    );
  }

  void _synchroniseerController(
    TextEditingController controller,
    String waarde,
  ) {
    if (controller.text == waarde) return;
    controller.value = TextEditingValue(
      text: waarde,
      selection: TextSelection.collapsed(offset: waarde.length),
    );
  }

  @override
  void dispose() {
    _positieController.dispose();
    _aantalController.dispose();
    _breedteController.dispose();
    _hoogteController.dispose();
    _openLamellenController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _wijzig(OpmetingVoorzetrolluikModel model) {
    widget.onGewijzigd(model);
  }

  OpmetingVoorzetrolluikModel _pasAutomatischeKastmaatToe(
    OpmetingVoorzetrolluikModel model,
  ) {
    if (!model.kastmaatVolgensAfmetingen) return model;
    final vereiste = OpmetingVoorzetrolluikKastmaatHelper.vereisteKastmaat(
      lamelType: model.lamelType,
      bediening: model.bediening,
      hoogteMm: model.hoogteMm,
    );
    return model.copyWith(kastmaat: vereiste);
  }

  void _wijzigAantal(String tekst) {
    final waarde = int.tryParse(tekst);
    if (waarde == null ||
        waarde < OpmetingVoorzetrolluikModel.aantalMinimum ||
        waarde > OpmetingVoorzetrolluikModel.aantalMaximum) {
      return;
    }
    _wijzig(widget.model.copyWith(aantal: waarde));
  }

  void _wijzigBreedte(String tekst) {
    final waarde = int.tryParse(tekst);
    if (waarde == null ||
        waarde < OpmetingVoorzetrolluikModel.breedteMinimumMm ||
        waarde > OpmetingVoorzetrolluikModel.breedteMaximumMm) {
      return;
    }
    _wijzig(
      _pasAutomatischeKastmaatToe(widget.model.copyWith(breedteMm: waarde)),
    );
  }

  void _wijzigHoogte(String tekst) {
    final waarde = int.tryParse(tekst);
    if (waarde == null ||
        waarde < OpmetingVoorzetrolluikModel.hoogteMinimumMm ||
        waarde > OpmetingVoorzetrolluikModel.hoogteMaximumMm) {
      return;
    }
    _wijzig(
      _pasAutomatischeKastmaatToe(widget.model.copyWith(hoogteMm: waarde)),
    );
  }

  void _wijzigOpenLamellen(String tekst) {
    final waarde = int.tryParse(tekst);
    if (waarde == null || waarde < 0 || waarde > 100) return;
    _wijzig(widget.model.copyWith(openLamellenPercentage: waarde));
  }

  void _kiesAutomatischeKastmaat() {
    _wijzig(
      _pasAutomatischeKastmaatToe(
        widget.model.copyWith(kastmaatVolgensAfmetingen: true),
      ),
    );
  }

  Future<void> _kiesHandmatigeKastmaat(
    OpmetingVoorzetrolluikKastmaat maat,
  ) async {
    final vereist = OpmetingVoorzetrolluikKastmaatHelper.vereisteKastmaat(
      lamelType: widget.model.lamelType,
      bediening: widget.model.bediening,
      hoogteMm: widget.model.hoogteMm,
    );
    final handmatig = widget.model.copyWith(
      kastmaatVolgensAfmetingen: false,
      kastmaat: maat,
    );

    if (maat.millimeter >= vereist.millimeter) {
      _wijzig(handmatig);
      return;
    }

    final behouden = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return _groenDialoogThema(
          dialogContext,
          AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Kastgrootte aanpassen?',
              style: TextStyle(color: _groen, fontWeight: FontWeight.w900),
            ),
            content: Text(
              'Volgens de kasttabel is voor ${widget.model.lamelType}, '
              'as ${OpmetingVoorzetrolluikKastmaatHelper.asDiameterVoor(lamelType: widget.model.lamelType, bediening: widget.model.bediening)} mm '
              'en hoogte ${widget.model.hoogteMm} mm minimaal ${vereist.label} nodig. '
              'De gekozen ${maat.label} is kleiner.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Nee, gekozen maat behouden'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: _groen),
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text('Ja, ${vereist.label} kiezen'),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || behouden == null) return;
    _wijzig(behouden ? handmatig : handmatig.copyWith(kastmaat: vereist));
  }

  void _wijzigLamelType(String lamelType) {
    _wijzig(
      _pasAutomatischeKastmaatToe(widget.model.copyWith(lamelType: lamelType)),
    );
  }

  void _wijzigBediening(OpmetingVoorzetrolluikBediening bediening) {
    if (bediening == OpmetingVoorzetrolluikBediening.lint) {
      _wijzig(
        _pasAutomatischeKastmaatToe(
          widget.model.copyWith(
            bediening: bediening,
            zonnecel: false,
            motorType: '',
            motorMerk: '',
            motorOmschrijving: '',
            motorExtraInfo: '',
            uitgangKabel: '',
          ),
        ),
      );
      return;
    }

    final eerste = widget.instellingen.motoren.isEmpty
        ? null
        : widget.instellingen.motoren.first;
    _wijzig(
      _pasAutomatischeKastmaatToe(
        widget.model.copyWith(
          bediening: bediening,
          motorType: eerste?.type ?? widget.model.motorType,
          motorMerk: eerste?.merk ?? widget.model.motorMerk,
          motorOmschrijving:
              eerste?.omschrijving ?? widget.model.motorOmschrijving,
          motorExtraInfo: eerste?.extraInfo ?? widget.model.motorExtraInfo,
        ),
      ),
    );
  }

  List<OpmetingVoorzetrolluikMotor> get _beschikbareMotoren {
    return widget.model.zonnecel
        ? widget.instellingen.zonnecelMotoren
        : widget.instellingen.motoren;
  }

  List<String> get _beschikbareGeleiders {
    final resultaat = <String>[];
    final gezien = <String>{};

    void voegToe(String waarde) {
      final schoon = waarde.trim();
      if (schoon.isEmpty || !gezien.add(schoon.toLowerCase())) return;
      resultaat.add(schoon);
    }

    // De volledige Wilms-lijst moet altijd op de fiche beschikbaar zijn.
    for (final waarde
        in OpmetingVoorzetrolluikInstellingen.standaardGeleiderTypes) {
      voegToe(waarde);
    }
    for (final waarde in widget.instellingen.geleiderTypes) {
      voegToe(waarde);
    }

    final huidig = widget.model.geleiderType.trim();
    if (huidig.isNotEmpty && !gezien.contains(huidig.toLowerCase())) {
      resultaat.insert(0, huidig);
    }
    return List<String>.unmodifiable(resultaat);
  }

  Future<void> _kiesLamelkleur() async {
    final gekozen = await _toonZoekDialoog<OpmetingVoorzetrolluikLamelkleur>(
      titel: 'Kleur lamellen',
      items: widget.instellingen.lamelkleuren,
      zoekTekst: (item) => '${item.naam} ${item.code}',
      label: (item) => item.samenvatting,
      huidigeId:
          '${widget.model.lamelKleurNaam.trim().toLowerCase()}|'
          '${widget.model.lamelKleurCode.trim().toLowerCase()}',
    );
    if (gekozen == null) return;
    _wijzig(
      widget.model.copyWith(
        lamelKleurNaam: gekozen.naam,
        lamelKleurCode: gekozen.code,
        lamelKleurHex: gekozen.hexKleur,
      ),
    );
  }

  Future<void> _kiesPoederkleur() async {
    final gekozen = await _toonZoekDialoog<OpmetingVoorzetscreenPoederkleur>(
      titel: 'Standaard poederlak',
      items: widget.poederkleuren,
      zoekTekst: (item) => '${item.benaming} ${item.poedercode}',
      label: (item) => item.samenvatting,
      huidigeId:
          '${widget.model.kleurBenaming.trim().toLowerCase()}|'
          '${widget.model.poedercode.trim().toLowerCase()}',
    );
    if (gekozen == null) return;
    _wijzig(
      widget.model.copyWith(
        kleurBenaming: gekozen.benaming,
        poedercode: gekozen.poedercode,
        poederlakMogelijk: gekozen.poederlakMogelijk,
        natlakMogelijk: gekozen.natlakMogelijk,
      ),
    );
  }

  Future<void> _kiesMotor() async {
    final gekozen = await _toonZoekDialoog<OpmetingVoorzetrolluikMotor>(
      titel: widget.model.zonnecel ? 'Motor met zonnecel' : 'Type motor',
      items: _beschikbareMotoren,
      zoekTekst: (item) =>
          '${item.type} ${item.merk} ${item.omschrijving} ${item.extraInfo}',
      label: (item) => item.samenvatting,
      huidigeId: <String>[
        widget.model.motorType.trim().toLowerCase(),
        widget.model.motorMerk.trim().toLowerCase(),
        widget.model.motorOmschrijving.trim().toLowerCase(),
      ].join('|'),
    );
    if (gekozen == null) return;
    _wijzig(
      widget.model.copyWith(
        motorType: gekozen.type,
        motorMerk: gekozen.merk,
        motorOmschrijving: gekozen.omschrijving,
        motorExtraInfo: gekozen.extraInfo,
      ),
    );
  }

  Future<T?> _toonZoekDialoog<T>({
    required String titel,
    required List<T> items,
    required String Function(T item) zoekTekst,
    required String Function(T item) label,
    required String huidigeId,
  }) async {
    final zoekController = TextEditingController();
    try {
      return await showDialog<T>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              final zoekterm = zoekController.text.trim().toLowerCase();
              final zichtbaar = items
                  .where((item) {
                    return zoekterm.isEmpty ||
                        zoekTekst(item).toLowerCase().contains(zoekterm);
                  })
                  .toList(growable: false);

              return _groenDialoogThema(
                dialogContext,
                AlertDialog(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    titel,
                    style: const TextStyle(
                      color: _groen,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  content: SizedBox(
                    width: 560,
                    height: 480,
                    child: Column(
                      children: <Widget>[
                        TextField(
                          controller: zoekController,
                          autofocus: true,
                          onChanged: (_) => setDialogState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Zoeken...',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: zoekController.text.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      zoekController.clear();
                                      setDialogState(() {});
                                    },
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: zichtbaar.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Geen resultaten gevonden.',
                                    style: TextStyle(color: _tekstGrijs),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: zichtbaar.length,
                                  separatorBuilder: (_, _) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final item = zichtbaar[index];
                                    final itemLabel = label(item);
                                    final geselecteerd =
                                        zoekTekst(item).trim().toLowerCase() ==
                                            huidigeId ||
                                        itemLabel.trim().toLowerCase() ==
                                            huidigeId;
                                    return ListTile(
                                      dense: true,
                                      leading: Icon(
                                        geselecteerd
                                            ? Icons.radio_button_checked_rounded
                                            : Icons.radio_button_off_rounded,
                                        color: geselecteerd
                                            ? _groen
                                            : _tekstGrijs,
                                      ),
                                      title: Text(
                                        itemLabel,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      onTap: () =>
                                          Navigator.pop(dialogContext, item),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Sluiten'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } finally {
      zoekController.dispose();
    }
  }

  Future<void> _toonUitgangKabelInfo() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final scherm = MediaQuery.sizeOf(dialogContext);
        final breedte = scherm.width > 820 ? 760.0 : scherm.width - 32;
        final hoogte = scherm.height > 720 ? 640.0 : scherm.height - 32;

        return _groenDialoogThema(
          dialogContext,
          Dialog(
            insetPadding: const EdgeInsets.all(16),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              width: breedte,
              height: hoogte,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 8, 8),
                    color: _lichtGroen,
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.info_outline_rounded,
                          color: _groen,
                          size: 22,
                        ),
                        const SizedBox(width: 9),
                        const Expanded(
                          child: Text(
                            'Uitgang kabel',
                            style: TextStyle(
                              color: _groen,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Sluiten',
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          color: _groen,
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(14),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _rand),
                      ),
                      child: InteractiveViewer(
                        minScale: 0.7,
                        maxScale: 4,
                        child: Center(
                          child: Image.asset(
                            'assets/images/uitgang_voorzet_screens.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Text(
                                  'Afbeelding niet gevonden:\n'
                                  'assets/images/uitgang_voorzet_screens.png',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: _tekstGrijs),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _toonGeleiderInfo() {
    return _toonAfbeeldingInfo(
      titel: 'Keuze geleiders',
      assetPad: 'assets/images/Voorzetrolluik_geleiders.png',
    );
  }

  Future<void> _toonLamellenInfo() {
    return _toonAfbeeldingInfo(
      titel: 'Rolluiklamellen',
      assetPad: 'assets/images/Voorzetrolluik_lamellen.png',
    );
  }

  Future<void> _toonAfbeeldingInfo({
    required String titel,
    required String assetPad,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final scherm = MediaQuery.sizeOf(dialogContext);
        final breedte = scherm.width > 920 ? 860.0 : scherm.width - 32;
        final hoogte = scherm.height > 760 ? 680.0 : scherm.height - 32;

        return _groenDialoogThema(
          dialogContext,
          Dialog(
            insetPadding: const EdgeInsets.all(16),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              width: breedte,
              height: hoogte,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 8, 8),
                    color: _lichtGroen,
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.info_outline_rounded,
                          color: _groen,
                          size: 22,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            titel,
                            style: const TextStyle(
                              color: _groen,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Sluiten',
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          color: _groen,
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(14),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _rand),
                      ),
                      child: InteractiveViewer(
                        minScale: 0.7,
                        maxScale: 4,
                        child: Center(
                          child: Image.asset(
                            assetPad,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  'Afbeelding niet gevonden:\n$assetPad',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: _tekstGrijs),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _groenDialoogThema(BuildContext context, Widget child) {
    final basis = Theme.of(context);
    return Theme(
      data: basis.copyWith(
        colorScheme: basis.colorScheme.copyWith(
          primary: _groen,
          secondary: _groen,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: _groen),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(backgroundColor: _groen),
        ),
        inputDecorationTheme: basis.inputDecorationTheme.copyWith(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _groen, width: 1.5),
          ),
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectKleur = widget.projectKleur.trim().isEmpty
        ? 'Projectkleur nog te kiezen'
        : widget.projectKleur.trim();
    final vereisteKastmaat =
        OpmetingVoorzetrolluikKastmaatHelper.vereisteKastmaat(
          lamelType: widget.model.lamelType,
          bediening: widget.model.bediening,
          hoogteMm: widget.model.hoogteMm,
        );
    final asDiameterMm = OpmetingVoorzetrolluikKastmaatHelper.asDiameterVoor(
      lamelType: widget.model.lamelType,
      bediening: widget.model.bediening,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rand),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0F111827),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            color: _lichtGroen,
            child: const Row(
              children: <Widget>[
                Icon(Icons.blinds_outlined, color: _groen, size: 19),
                SizedBox(width: 8),
                Text(
                  'Voorzetrolluik',
                  style: TextStyle(
                    color: _groen,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(10),
                children: <Widget>[
                  _SectieKaart(
                    titel: '',
                    children: <Widget>[
                      _CompactTekstRij(
                        titel: 'Positie',
                        controller: _positieController,
                        onChanged: (waarde) =>
                            _wijzig(widget.model.copyWith(positie: waarde)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _SectieKaart(
                    titel: 'Maatvoering',
                    children: <Widget>[
                      _JaNeeRij(
                        titel: 'Ingave breedte inclusief geleiders',
                        waarde: widget.model.breedteInclusiefGeleiders,
                        onChanged: (waarde) => _wijzig(
                          widget.model.copyWith(
                            breedteInclusiefGeleiders: waarde,
                          ),
                        ),
                      ),
                      _JaNeeRij(
                        titel: 'Ingave hoogte inclusief kast',
                        waarde: widget.model.hoogteInclusiefKast,
                        onChanged: (waarde) => _wijzig(
                          widget.model.copyWith(hoogteInclusiefKast: waarde),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _bouwKastmaatSectie(vereisteKastmaat, asDiameterMm),
                  const SizedBox(height: 8),
                  _RadioSectie<OpmetingVoorzetrolluikKastvorm>(
                    titel: 'Kastvorm',
                    waarde: widget.model.kastvorm,
                    keuzes: OpmetingVoorzetrolluikKastvorm.values,
                    labelVoor: (waarde) => waarde.label,
                    onChanged: (waarde) =>
                        _wijzig(widget.model.copyWith(kastvorm: waarde)),
                  ),
                  const SizedBox(height: 8),
                  _bouwLamellenSectie(),
                  const SizedBox(height: 8),
                  _SectieKaart(
                    titel: 'Kleur kast, geleiders en onderlat',
                    children: <Widget>[
                      RadioGroup<OpmetingVoorzetrolluikKleurbron>(
                        groupValue: widget.model.kleurbron,
                        onChanged: (waarde) {
                          if (waarde == null) return;
                          _wijzig(
                            widget.model.copyWith(
                              kleurbron: waarde,
                              projectKleurWaarde:
                                  waarde ==
                                      OpmetingVoorzetrolluikKleurbron
                                          .projectKleur
                                  ? widget.projectKleur.trim()
                                  : widget.model.projectKleurWaarde,
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: OpmetingVoorzetrolluikKleurbron.values
                              .map(
                                (waarde) =>
                                    _EenvoudigeRadioKeuze<
                                      OpmetingVoorzetrolluikKleurbron
                                    >(waarde: waarde, label: waarde.label),
                              )
                              .toList(growable: false),
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (widget.model.kleurbron ==
                          OpmetingVoorzetrolluikKleurbron.projectKleur)
                        _WaardeRij(titel: 'Projectkleur', waarde: projectKleur)
                      else
                        _ZoekKeuzeVeld(
                          label: widget.model.kleurSamenvatting,
                          hint: 'Poederkleur zoeken',
                          onTap: _kiesPoederkleur,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _SectieKaart(
                    titel: 'Aantal en afmetingen',
                    children: <Widget>[
                      _CompactGetalRij(
                        titel: 'Aantal',
                        controller: _aantalController,
                        eenheid: 'st.',
                        onChanged: _wijzigAantal,
                      ),
                      const SizedBox(height: 7),
                      _CompactGetalRij(
                        titel: 'Breedte',
                        controller: _breedteController,
                        eenheid: 'mm',
                        onChanged: _wijzigBreedte,
                      ),
                      const SizedBox(height: 7),
                      _CompactGetalRij(
                        titel: 'Hoogte',
                        controller: _hoogteController,
                        eenheid: 'mm',
                        onChanged: _wijzigHoogte,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _RadioSectie<OpmetingVoorzetrolluikBediening>(
                    titel: 'Bediening',
                    waarde: widget.model.bediening,
                    keuzes: OpmetingVoorzetrolluikBediening.values,
                    labelVoor: (waarde) => waarde.label,
                    horizontaal: true,
                    onChanged: _wijzigBediening,
                  ),
                  if (!widget.model.isElektrisch) ...<Widget>[
                    const SizedBox(height: 8),
                    _RadioSectie<OpmetingVoorzetrolluikKantLint>(
                      titel: 'Uitgang lint',
                      actie: IconButton(
                        tooltip: 'Bekijk de uitgangen',
                        onPressed: _toonUitgangKabelInfo,
                        visualDensity: VisualDensity.compact,
                        style: IconButton.styleFrom(
                          foregroundColor: _groen,
                          backgroundColor: _lichtGroen,
                          minimumSize: const Size(32, 32),
                          maximumSize: const Size(32, 32),
                          padding: EdgeInsets.zero,
                        ),
                        icon: const Icon(Icons.info_outline_rounded, size: 19),
                      ),
                      waarde: widget.model.kantLint,
                      keuzes: OpmetingVoorzetrolluikKantLint.values,
                      labelVoor: (waarde) => waarde.label,
                      horizontaal: true,
                      onChanged: (waarde) =>
                          _wijzig(widget.model.copyWith(kantLint: waarde)),
                    ),
                  ],
                  if (widget.model.isElektrisch) ...<Widget>[
                    const SizedBox(height: 8),
                    Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _rand),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Expanded(
                            child: Text(
                              'Zonnecel',
                              style: TextStyle(
                                color: _tekst,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 42,
                            height: 30,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Switch.adaptive(
                                value: widget.model.zonnecel,
                                activeTrackColor: _groen,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                onChanged: (waarde) {
                                  final motoren = waarde
                                      ? widget.instellingen.zonnecelMotoren
                                      : widget.instellingen.motoren;
                                  final eerste = motoren.isEmpty
                                      ? null
                                      : motoren.first;
                                  _wijzig(
                                    widget.model.copyWith(
                                      zonnecel: waarde,
                                      motorType: eerste?.type ?? '',
                                      motorMerk: eerste?.merk ?? '',
                                      motorOmschrijving:
                                          eerste?.omschrijving ?? '',
                                      motorExtraInfo: eerste?.extraInfo ?? '',
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _SectieKaart(
                      titel: 'Type motor',
                      children: <Widget>[
                        _ZoekKeuzeVeld(
                          label: widget.model.motorSamenvatting,
                          hint: 'Motor zoeken',
                          onTap: _beschikbareMotoren.isEmpty
                              ? null
                              : _kiesMotor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _RadioSectie<String>(
                      titel: 'Bediening',
                      waarde: widget.model.elektrischeBediening,
                      keuzes: OpmetingVoorzetrolluikModel
                          .elektrischeBedieningKeuzes,
                      labelVoor: (waarde) => waarde,
                      onChanged: (waarde) => _wijzig(
                        widget.model.copyWith(elektrischeBediening: waarde),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _bouwUitgangKabelSectie(),
                  ],
                  const SizedBox(height: 8),
                  _bouwGeleiderSectie(),
                  const SizedBox(height: 8),
                  _RadioSectie<OpmetingVoorzetrolluikBorenGeleiders>(
                    titel: 'Boren geleiders',
                    waarde: widget.model.borenGeleiders,
                    keuzes: OpmetingVoorzetrolluikBorenGeleiders.values,
                    labelVoor: (waarde) => waarde.label,
                    onChanged: (waarde) =>
                        _wijzig(widget.model.copyWith(borenGeleiders: waarde)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwKastmaatSectie(
    OpmetingVoorzetrolluikKastmaat vereisteKastmaat,
    int asDiameterMm,
  ) {
    return _SectieKaart(
      titel: 'Kastmaat',
      children: <Widget>[
        RadioGroup<bool>(
          groupValue: widget.model.kastmaatVolgensAfmetingen,
          onChanged: (waarde) {
            if (waarde == true) _kiesAutomatischeKastmaat();
          },
          child: _EenvoudigeRadioKeuze<bool>(
            waarde: true,
            label: 'Volgens afmetingen · as $asDiameterMm mm',
          ),
        ),
        RadioGroup<OpmetingVoorzetrolluikKastmaat>(
          groupValue: widget.model.kastmaat,
          onChanged: (maat) {
            if (maat != null) _kiesHandmatigeKastmaat(maat);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: OpmetingVoorzetrolluikKastmaat.values
                .map(
                  (maat) =>
                      _EenvoudigeRadioKeuze<OpmetingVoorzetrolluikKastmaat>(
                        waarde: maat,
                        label: maat.label,
                        tekstGroen:
                            widget.model.kastmaatVolgensAfmetingen &&
                            maat == vereisteKastmaat,
                      ),
                )
                .toList(growable: false),
          ),
        ),
      ],
    );
  }

  Widget _bouwLamellenSectie() {
    final huidig = OpmetingVoorzetrolluikKastmaatHelper.normaliseerLamelType(
      widget.model.lamelType,
    );
    return _SectieKaart(
      titel: 'Rolluiklamellen',
      actie: IconButton(
        tooltip: 'Bekijk de lamellen',
        onPressed: _toonLamellenInfo,
        visualDensity: VisualDensity.compact,
        style: IconButton.styleFrom(
          foregroundColor: _groen,
          backgroundColor: _lichtGroen,
          minimumSize: const Size(32, 32),
          maximumSize: const Size(32, 32),
          padding: EdgeInsets.zero,
        ),
        icon: const Icon(Icons.info_outline_rounded, size: 19),
      ),
      children: <Widget>[
        const Text(
          'Type lamel',
          style: TextStyle(
            color: _tekst,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        RadioGroup<String>(
          groupValue: huidig,
          onChanged: (waarde) {
            if (waarde != null) _wijzigLamelType(waarde);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: OpmetingVoorzetrolluikKastmaatHelper.lamelTypes
                .map(
                  (lamel) => _EenvoudigeRadioKeuze<String>(
                    waarde: lamel,
                    label: lamel,
                    fontSize: 10.5,
                  ),
                )
                .toList(growable: false),
          ),
        ),
        const SizedBox(height: 7),
        _ZoekKeuzeVeld(
          label: widget.model.lamelSamenvatting,
          hint: 'Kleur lamellen kiezen',
          onTap: _kiesLamelkleur,
        ),
        const SizedBox(height: 7),
        _CompactGetalRij(
          titel: 'Open lamellen',
          controller: _openLamellenController,
          eenheid: '%',
          onChanged: _wijzigOpenLamellen,
        ),
        const SizedBox(height: 7),
        _JaNeeRij(
          titel: 'Borstels in de geleiders',
          waarde: widget.model.borstelsInGeleiders,
          onChanged: (waarde) =>
              _wijzig(widget.model.copyWith(borstelsInGeleiders: waarde)),
        ),
      ],
    );
  }

  Widget _bouwUitgangKabelSectie() {
    final geselecteerd = widget.model.uitgangKabel.trim().toUpperCase();
    return _SectieKaart(
      titel: 'Uitgang kabel',
      actie: IconButton(
        tooltip: 'Bekijk de uitgangen',
        onPressed: _toonUitgangKabelInfo,
        visualDensity: VisualDensity.compact,
        style: IconButton.styleFrom(
          foregroundColor: _groen,
          backgroundColor: _lichtGroen,
          minimumSize: const Size(32, 32),
          maximumSize: const Size(32, 32),
          padding: EdgeInsets.zero,
        ),
        icon: const Icon(Icons.info_outline_rounded, size: 19),
      ),
      children: <Widget>[
        RadioGroup<String>(
          groupValue: geselecteerd.isEmpty ? null : geselecteerd,
          onChanged: (code) {
            if (code == null) return;
            _wijzig(widget.model.copyWith(uitgangKabel: code));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (var index = 0; index <= 7; index++) ...<Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _EenvoudigeRadioKeuze<String>(
                        waarde: 'C$index',
                        label: 'C$index',
                      ),
                    ),
                    Expanded(
                      child: _EenvoudigeRadioKeuze<String>(
                        waarde: 'D$index',
                        label: 'D$index',
                      ),
                    ),
                  ],
                ),
                if (index < 7) const SizedBox(height: 2),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _bouwGeleiderSectie() {
    final geleiders = _beschikbareGeleiders;
    return _SectieKaart(
      titel: 'Keuze geleiders',
      actie: IconButton(
        tooltip: 'Bekijk de geleiders',
        onPressed: _toonGeleiderInfo,
        visualDensity: VisualDensity.compact,
        style: IconButton.styleFrom(
          foregroundColor: _groen,
          backgroundColor: _lichtGroen,
          minimumSize: const Size(32, 32),
          maximumSize: const Size(32, 32),
          padding: EdgeInsets.zero,
        ),
        icon: const Icon(Icons.info_outline_rounded, size: 19),
      ),
      children: <Widget>[
        if (geleiders.isEmpty)
          const Text(
            'Voeg eerst geleiders toe via Instellingen → Voorzetrolluiken.',
            style: TextStyle(color: _tekstGrijs, fontSize: 11),
          )
        else
          RadioGroup<String>(
            groupValue: widget.model.geleiderType.trim().isEmpty
                ? null
                : widget.model.geleiderType,
            onChanged: (waarde) {
              if (waarde == null) return;
              _wijzig(widget.model.copyWith(geleiderType: waarde));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: geleiders
                  .map(
                    (waarde) => _EenvoudigeRadioKeuze<String>(
                      waarde: waarde,
                      label: waarde,
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
      ],
    );
  }
}

class _SectieKaart extends StatelessWidget {
  const _SectieKaart({required this.titel, required this.children, this.actie});

  final String titel;
  final List<Widget> children;
  final Widget? actie;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _OpmetingVoorzetrolluikRechterkolomState._rand,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (titel.trim().isNotEmpty || actie != null) ...<Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    titel,
                    style: const TextStyle(
                      color: _OpmetingVoorzetrolluikRechterkolomState._tekst,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (actie != null) actie!,
              ],
            ),
            const SizedBox(height: 7),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _RadioSectie<T> extends StatelessWidget {
  const _RadioSectie({
    required this.titel,
    required this.waarde,
    required this.keuzes,
    required this.labelVoor,
    required this.onChanged,
    this.horizontaal = false,
    this.actie,
  });

  final String titel;
  final T waarde;
  final List<T> keuzes;
  final String Function(T waarde) labelVoor;
  final ValueChanged<T> onChanged;
  final bool horizontaal;
  final Widget? actie;

  @override
  Widget build(BuildContext context) {
    final keuzeWidgets = keuzes
        .map(
          (keuze) =>
              _EenvoudigeRadioKeuze<T>(waarde: keuze, label: labelVoor(keuze)),
        )
        .toList(growable: false);
    return _SectieKaart(
      titel: titel,
      actie: actie,
      children: <Widget>[
        RadioGroup<T>(
          groupValue: waarde,
          onChanged: (nieuw) {
            if (nieuw != null) onChanged(nieuw);
          },
          child: horizontaal
              ? Row(
                  children: keuzeWidgets
                      .map((item) => Expanded(child: item))
                      .toList(growable: false),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: keuzeWidgets,
                ),
        ),
      ],
    );
  }
}

class _JaNeeRij extends StatelessWidget {
  const _JaNeeRij({
    required this.titel,
    required this.waarde,
    required this.onChanged,
  });

  final String titel;
  final bool waarde;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            titel,
            style: const TextStyle(
              color: _OpmetingVoorzetrolluikRechterkolomState._tekst,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        RadioGroup<bool>(
          groupValue: waarde,
          onChanged: (nieuw) {
            if (nieuw != null) onChanged(nieuw);
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _KleineRadio<bool>(waarde: true, label: 'Ja'),
              _KleineRadio<bool>(waarde: false, label: 'Nee'),
            ],
          ),
        ),
      ],
    );
  }
}

class _KleineRadio<T> extends StatelessWidget {
  const _KleineRadio({required this.waarde, required this.label});

  final T waarde;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Radio<T>(
          value: waarde,
          activeColor: _OpmetingVoorzetrolluikRechterkolomState._groen,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _EenvoudigeRadioKeuze<T> extends StatelessWidget {
  const _EenvoudigeRadioKeuze({
    required this.waarde,
    required this.label,
    this.fontSize = 11.5,
    this.tekstGroen = false,
  });

  final T waarde;
  final String label;
  final double fontSize;
  final bool tekstGroen;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Radio<T>(
          value: waarde,
          activeColor: _OpmetingVoorzetrolluikRechterkolomState._groen,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        ),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: tekstGroen
                  ? _OpmetingVoorzetrolluikRechterkolomState._groen
                  : _OpmetingVoorzetrolluikRechterkolomState._tekst,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactTekstRij extends StatelessWidget {
  const _CompactTekstRij({
    required this.titel,
    required this.controller,
    required this.onChanged,
  });

  final String titel;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 112,
          child: Text(
            titel,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: _veldDecoratie(hint: 'Vrij invullen'),
          ),
        ),
      ],
    );
  }
}

class _CompactGetalRij extends StatelessWidget {
  const _CompactGetalRij({
    required this.titel,
    required this.controller,
    required this.onChanged,
    this.eenheid,
  });

  final String titel;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? eenheid;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 112,
          child: Text(
            titel,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: onChanged,
            decoration: _veldDecoratie(suffixText: eenheid),
          ),
        ),
      ],
    );
  }
}

class _WaardeRij extends StatelessWidget {
  const _WaardeRij({required this.titel, required this.waarde});

  final String titel;
  final String waarde;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 112,
          child: Text(
            titel,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            waarde,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _ZoekKeuzeVeld extends StatelessWidget {
  const _ZoekKeuzeVeld({
    required this.label,
    required this.hint,
    required this.onTap,
  });

  final String label;
  final String hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final heeftWaarde = label.trim().isNotEmpty && label != 'Nog te bepalen';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: InputDecorator(
        decoration: _veldDecoratie(
          hint: hint,
          suffixIcon: const Icon(
            Icons.search_rounded,
            color: _OpmetingVoorzetrolluikRechterkolomState._groen,
          ),
        ),
        child: Text(
          heeftWaarde ? label : hint,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: heeftWaarde
                ? _OpmetingVoorzetrolluikRechterkolomState._tekst
                : _OpmetingVoorzetrolluikRechterkolomState._tekstGrijs,
            fontSize: 11.5,
            fontWeight: heeftWaarde ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

InputDecoration _veldDecoratie({
  String? label,
  String? hint,
  String? suffixText,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    suffixText: suffixText,
    suffixIcon: suffixIcon,
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: _OpmetingVoorzetrolluikRechterkolomState._rand,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: _OpmetingVoorzetrolluikRechterkolomState._rand,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: _OpmetingVoorzetrolluikRechterkolomState._groen,
        width: 1.4,
      ),
    ),
  );
}
