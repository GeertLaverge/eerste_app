// THIMACO-CONTROLE: UITVALSCHERM-RECHTERKOLOM-RADIO-LAYOUT-20260801
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'opmeting_uitvalscherm_instellingen_model.dart';
import 'opmeting_uitvalscherm_model.dart';

class OpmetingUitvalschermRechterkolom extends StatefulWidget {
  const OpmetingUitvalschermRechterkolom({
    super.key,
    required this.model,
    required this.instellingen,
    required this.onGewijzigd,
    this.projectKleur = '',
  });

  final OpmetingUitvalschermModel model;
  final OpmetingUitvalschermInstellingen instellingen;
  final ValueChanged<OpmetingUitvalschermModel> onGewijzigd;
  final String projectKleur;

  @override
  State<OpmetingUitvalschermRechterkolom> createState() {
    return _OpmetingUitvalschermRechterkolomState();
  }
}

class _OpmetingUitvalschermRechterkolomState
    extends State<OpmetingUitvalschermRechterkolom> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekst = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  late final TextEditingController _positieController;
  late final TextEditingController _aantalController;
  late final TextEditingController _breedteController;
  late final TextEditingController _volantController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _positieController = TextEditingController();
    _aantalController = TextEditingController();
    _breedteController = TextEditingController();
    _volantController = TextEditingController();
    _scrollController = ScrollController();
    _synchroniseerControllers();
  }

  @override
  void didUpdateWidget(covariant OpmetingUitvalschermRechterkolom oldWidget) {
    super.didUpdateWidget(oldWidget);
    _synchroniseerControllers();
  }

  @override
  void dispose() {
    _positieController.dispose();
    _aantalController.dispose();
    _breedteController.dispose();
    _volantController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _synchroniseerControllers() {
    _zetTekst(_positieController, widget.model.positie);
    _zetTekst(_aantalController, widget.model.aantal.toString());
    _zetTekst(_breedteController, widget.model.breedteMm.toString());
    _zetTekst(_volantController, widget.model.volantHoogteMm.toString());
  }

  void _zetTekst(TextEditingController controller, String tekst) {
    if (controller.text == tekst) return;
    controller.value = TextEditingValue(
      text: tekst,
      selection: TextSelection.collapsed(offset: tekst.length),
    );
  }

  void _wijzig(OpmetingUitvalschermModel model) {
    widget.onGewijzigd(_vulGeldigeKeuzesAan(model));
  }

  OpmetingUitvalschermModel _vulGeldigeKeuzesAan(
    OpmetingUitvalschermModel model,
  ) {
    var resultaat = model.copyWith(
      projectKleurWaarde:
          model.kleurbron == OpmetingUitvalschermKleurbron.projectKleur
          ? widget.projectKleur.trim()
          : model.projectKleurWaarde,
    );

    final kleuren = widget.instellingen.draagstructuurKleuren;
    if (resultaat.kleurbron ==
            OpmetingUitvalschermKleurbron.standaardPoederkleur &&
        kleuren.isNotEmpty &&
        !kleuren.any(
          (kleur) =>
              kleur.naam == resultaat.draagstructuurKleur &&
              kleur.code == resultaat.draagstructuurKleurCode,
        )) {
      final kleur = kleuren.first;
      resultaat = resultaat.copyWith(
        draagstructuurKleur: kleur.naam,
        draagstructuurKleurCode: kleur.code,
      );
    }

    final doeken = widget.instellingen.doeken;
    if (doeken.isNotEmpty &&
        !doeken.any(
          (doek) => doek.id == resultaat.doekCode.trim().toUpperCase(),
        )) {
      final doek = doeken.first;
      resultaat = resultaat.copyWith(
        doekCode: doek.code,
        doekKleur: doek.kleur,
        doekHex: doek.hex,
      );
    }

    final motoren = _motorenVoor(resultaat);
    final huidigMotorId = _motorIdVanModel(resultaat);
    if (motoren.isNotEmpty &&
        !motoren.any((motor) => motor.id == huidigMotorId)) {
      final motor = motoren.first;
      resultaat = resultaat.copyWith(
        motorType: motor.type,
        motorMerk: motor.merk,
        motorOmschrijving: motor.omschrijving,
      );
    }

    final bedieningen = _bedieningenVoor(resultaat);
    if (bedieningen.isNotEmpty &&
        !bedieningen.contains(resultaat.bediening.trim())) {
      resultaat = resultaat.copyWith(bediening: bedieningen.first);
    }

    return resultaat;
  }

  List<OpmetingUitvalschermMotor> _motorenVoor(
    OpmetingUitvalschermModel model,
  ) {
    if (!model.type.is700LX) {
      return widget.instellingen.motoren;
    }
    return widget.instellingen.motoren
        .where((motor) => motor.isDraadloos)
        .toList(growable: false);
  }

  List<String> _bedieningenVoor(OpmetingUitvalschermModel model) {
    if (model.type.is700LX) {
      return const <String>['Handzender Somfy Situo 5 Var'];
    }
    return widget.instellingen.bedieningen;
  }

  String _motorIdVanModel(OpmetingUitvalschermModel model) {
    return <String>[
      model.motorType,
      model.motorMerk,
      model.motorOmschrijving,
    ].map((deel) => deel.trim().toLowerCase()).join('|');
  }

  @override
  Widget build(BuildContext context) {
    final projectKleur = widget.projectKleur.trim().isEmpty
        ? 'Projectkleur nog te kiezen'
        : widget.projectKleur.trim();
    final beschikbareMotoren = _motorenVoor(widget.model);
    final bedieningen = _bedieningenVoor(widget.model);

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
                Icon(Icons.wb_sunny_outlined, color: _groen, size: 19),
                SizedBox(width: 8),
                Text(
                  'Uitvalscherm',
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
                  _RadioSectie<OpmetingUitvalschermType>(
                    titel: 'Type tent',
                    waarde: widget.model.type,
                    keuzes: OpmetingUitvalschermType.values,
                    labelVoor: (waarde) => waarde.label,
                    onChanged: (waarde) =>
                        _wijzig(widget.model.copyWith(type: waarde)),
                  ),
                  if (widget.model.type.is700LX) ...<Widget>[
                    const SizedBox(height: 8),
                    _InfoBlok(tekst: widget.model.lxOmschrijving),
                  ],
                  const SizedBox(height: 8),
                  _SectieKaart(
                    titel: 'Aantal en afmetingen',
                    children: <Widget>[
                      _CompactGetalRij(
                        titel: 'Aantal',
                        controller: _aantalController,
                        eenheid: 'st.',
                        maxLengte: 3,
                        onChanged: (waarde) {
                          final aantal = int.tryParse(waarde);
                          if (aantal == null) return;
                          _wijzig(widget.model.copyWith(aantal: aantal));
                        },
                      ),
                      const SizedBox(height: 7),
                      _CompactGetalRij(
                        titel: 'Breedte',
                        controller: _breedteController,
                        eenheid: 'mm',
                        maxLengte: 4,
                        hulp: '2300 – ${widget.model.maximumBreedteMm} mm',
                        onChanged: (waarde) {
                          final breedte = int.tryParse(waarde);
                          if (breedte == null || breedte < 2300) return;
                          _wijzig(widget.model.copyWith(breedteMm: breedte));
                        },
                        onEditingComplete: () {
                          final breedte =
                              int.tryParse(_breedteController.text) ??
                              widget.model.breedteMm;
                          _wijzig(widget.model.copyWith(breedteMm: breedte));
                          FocusScope.of(context).unfocus();
                        },
                      ),
                      const SizedBox(height: 7),
                      _CompactDropdownRij<int>(
                        titel: 'Uitval',
                        waarde: widget.model.uitvalMm,
                        waarden: widget.model.toegestaneUitvallen,
                        labelVoor: (waarde) => '$waarde mm',
                        onChanged: (waarde) {
                          if (waarde != null) {
                            _wijzig(widget.model.copyWith(uitvalMm: waarde));
                          }
                        },
                      ),
                      const SizedBox(height: 7),
                      _InfoBlok(
                        tekst:
                            'Voor deze breedte is de maximale uitval '
                            '${widget.model.maximumUitvalMm} mm. '
                            'De keuzes verspringen per 500 mm.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _SectieKaart(
                    titel: 'Kleur draagstructuur',
                    children: <Widget>[
                      RadioGroup<OpmetingUitvalschermKleurbron>(
                        groupValue: widget.model.kleurbron,
                        onChanged: (waarde) {
                          if (waarde == null) return;
                          _wijzig(
                            widget.model.copyWith(
                              kleurbron: waarde,
                              projectKleurWaarde:
                                  waarde ==
                                      OpmetingUitvalschermKleurbron.projectKleur
                                  ? widget.projectKleur.trim()
                                  : widget.model.projectKleurWaarde,
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: OpmetingUitvalschermKleurbron.values
                              .map(
                                (waarde) =>
                                    _EenvoudigeRadioKeuze<
                                      OpmetingUitvalschermKleurbron
                                    >(waarde: waarde, label: waarde.label),
                              )
                              .toList(growable: false),
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (widget.model.kleurbron ==
                          OpmetingUitvalschermKleurbron.projectKleur)
                        _WaardeRij(titel: 'Projectkleur', waarde: projectKleur)
                      else
                        _CompactZoekKeuzeRij<OpmetingUitvalschermKleur>(
                          titel: 'Poederkleur',
                          waarde: _huidigeKleur(),
                          legeTekst: 'Kies een poederkleur',
                          labelVoor: (waarde) => waarde.label,
                          leading: (_) => const Icon(
                            Icons.palette_outlined,
                            color: _groen,
                            size: 19,
                          ),
                          onTap:
                              widget.instellingen.draagstructuurKleuren.isEmpty
                              ? null
                              : () async {
                                  final kleur =
                                      await _toonZoekbareKeuzelijst<
                                        OpmetingUitvalschermKleur
                                      >(
                                        titel: 'Poederkleur kiezen',
                                        zoekHint: 'Zoek op naam of poedercode',
                                        items: widget
                                            .instellingen
                                            .draagstructuurKleuren,
                                        geselecteerd: _huidigeKleur(),
                                        labelVoor: (waarde) => waarde.naam,
                                        ondertitelVoor: (waarde) => waarde.code,
                                        zoekTekstVoor: (waarde) =>
                                            '${waarde.naam} ${waarde.code}',
                                        sleutelVoor: (waarde) => waarde.id,
                                        leading: (_) => const Icon(
                                          Icons.palette_outlined,
                                          color: _groen,
                                          size: 21,
                                        ),
                                      );
                                  if (kleur == null || !mounted) return;
                                  _wijzig(
                                    widget.model.copyWith(
                                      draagstructuurKleur: kleur.naam,
                                      draagstructuurKleurCode: kleur.code,
                                    ),
                                  );
                                },
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _SectieKaart(
                    titel: 'Doek',
                    children: <Widget>[
                      _CompactZoekKeuzeRij<OpmetingUitvalschermDoek>(
                        titel: 'Type doek',
                        waarde: _huidigDoek(),
                        legeTekst: 'Kies een type doek',
                        labelVoor: (waarde) => waarde.label,
                        leading: (waarde) => _doekCirkel(waarde.hex),
                        onTap: widget.instellingen.doeken.isEmpty
                            ? null
                            : () async {
                                final doek =
                                    await _toonZoekbareKeuzelijst<
                                      OpmetingUitvalschermDoek
                                    >(
                                      titel: 'Type doek kiezen',
                                      zoekHint: 'Zoek op doeknaam of doekcode',
                                      items: widget.instellingen.doeken,
                                      geselecteerd: _huidigDoek(),
                                      labelVoor: (waarde) => waarde.kleur,
                                      ondertitelVoor: (waarde) => waarde.code,
                                      zoekTekstVoor: (waarde) =>
                                          '${waarde.kleur} ${waarde.code}',
                                      sleutelVoor: (waarde) => waarde.id,
                                      leading: (waarde) =>
                                          _doekCirkel(waarde.hex),
                                    );
                                if (doek == null || !mounted) return;
                                _wijzig(
                                  widget.model.copyWith(
                                    doekCode: doek.code,
                                    doekKleur: doek.kleur,
                                    doekHex: doek.hex,
                                  ),
                                );
                              },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _SectieKaart(
                    titel: 'Volant',
                    children: <Widget>[
                      _CompactSwitchRij(
                        titel: 'Volant voorzien',
                        waarde: widget.model.volant,
                        onChanged: (waarde) =>
                            _wijzig(widget.model.copyWith(volant: waarde)),
                      ),
                      if (widget.model.volant) ...<Widget>[
                        const SizedBox(height: 7),
                        _CompactGetalRij(
                          titel: 'Hoogte volant',
                          controller: _volantController,
                          eenheid: 'mm',
                          maxLengte: 3,
                          onChanged: (waarde) => _wijzig(
                            widget.model.copyWith(
                              volantHoogteMm: int.tryParse(waarde) ?? 0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  _SectieKaart(
                    titel: 'Bediening',
                    children: const <Widget>[
                      _WaardeRij(titel: 'Bediening', waarde: 'Elektrisch'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _MotorRadioSectie(
                    titel: 'Type motor',
                    motoren: beschikbareMotoren,
                    geselecteerdId: _motorIdVanModel(widget.model),
                    onChanged: (motor) => _wijzig(
                      widget.model.copyWith(
                        motorType: motor.type,
                        motorMerk: motor.merk,
                        motorOmschrijving: motor.omschrijving,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _RadioSectie<String>(
                    titel: 'Bedieningswijze',
                    waarde: _huidigeBediening(bedieningen),
                    keuzes: bedieningen,
                    labelVoor: (waarde) => waarde,
                    onChanged: (waarde) =>
                        _wijzig(widget.model.copyWith(bediening: waarde)),
                  ),
                  const SizedBox(height: 8),
                  _RadioSectie<int>(
                    titel: 'Kabellengte',
                    waarde: widget.model.kabellengteMeter,
                    keuzes: const <int>[5, 10],
                    labelVoor: (waarde) => '$waarde m',
                    horizontaal: true,
                    onChanged: (waarde) => _wijzig(
                      widget.model.copyWith(kabellengteMeter: waarde),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _RadioSectie<String>(
                    titel: 'Kabeluitgang (van buitengezien)',
                    waarde: widget.model.uitgang,
                    keuzes: const <String>['Links', 'Rechts'],
                    labelVoor: (waarde) => waarde,
                    horizontaal: true,
                    onChanged: (waarde) =>
                        _wijzig(widget.model.copyWith(uitgang: waarde)),
                  ),
                  const SizedBox(height: 8),
                  _SectieKaart(
                    titel: 'Windbeveiliging',
                    children: <Widget>[
                      _CompactSwitchRij(
                        titel: 'Eolis 3D',
                        waarde: widget.model.eolis3D,
                        onChanged: (waarde) =>
                            _wijzig(widget.model.copyWith(eolis3D: waarde)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<T?> _toonZoekbareKeuzelijst<T>({
    required String titel,
    required String zoekHint,
    required List<T> items,
    required T? geselecteerd,
    required String Function(T waarde) labelVoor,
    required String Function(T waarde) zoekTekstVoor,
    required String Function(T waarde) sleutelVoor,
    String Function(T waarde)? ondertitelVoor,
    Widget Function(T waarde)? leading,
  }) async {
    final zoekController = TextEditingController();
    var zoekterm = '';

    try {
      return await showDialog<T>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              final genormaliseerdeZoekterm = _normaliseerZoektekst(zoekterm);
              final gefilterdeItems = genormaliseerdeZoekterm.isEmpty
                  ? items
                  : items
                        .where((item) {
                          return _normaliseerZoektekst(
                            zoekTekstVoor(item),
                          ).contains(genormaliseerdeZoekterm);
                        })
                        .toList(growable: false);

              final scherm = MediaQuery.sizeOf(context);
              final dialogBreedte = scherm.width < 640
                  ? scherm.width - 40
                  : 560.0;
              final dialogHoogte = scherm.height < 720
                  ? scherm.height * 0.66
                  : 500.0;

              return AlertDialog(
                titlePadding: const EdgeInsets.fromLTRB(20, 18, 12, 0),
                contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                actionsPadding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        titel,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Sluiten',
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                content: SizedBox(
                  width: dialogBreedte,
                  height: dialogHoogte,
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: zoekController,
                        autofocus: true,
                        textInputAction: TextInputAction.search,
                        onChanged: (waarde) {
                          setDialogState(() => zoekterm = waarde);
                        },
                        decoration: InputDecoration(
                          hintText: zoekHint,
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: zoekterm.trim().isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Zoekopdracht wissen',
                                  onPressed: () {
                                    zoekController.clear();
                                    setDialogState(() => zoekterm = '');
                                  },
                                  icon: const Icon(Icons.clear_rounded),
                                ),
                          isDense: true,
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(11),
                            borderSide: const BorderSide(color: _rand),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(11),
                            borderSide: const BorderSide(color: _rand),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(11),
                            borderSide: const BorderSide(
                              color: _groen,
                              width: 1.4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: gefilterdeItems.isEmpty
                            ? const Center(
                                child: Text(
                                  'Geen resultaten gevonden.',
                                  style: TextStyle(
                                    color: _tekstGrijs,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: gefilterdeItems.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1, color: _rand),
                                itemBuilder: (context, index) {
                                  final item = gefilterdeItems[index];
                                  final geselecteerdItem = geselecteerd;
                                  final isGeselecteerd =
                                      geselecteerdItem != null &&
                                      sleutelVoor(item) ==
                                          sleutelVoor(geselecteerdItem);
                                  final ondertitel = ondertitelVoor == null
                                      ? ''
                                      : ondertitelVoor(item).trim();

                                  return ListTile(
                                    dense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    leading: leading == null
                                        ? null
                                        : SizedBox(
                                            width: 28,
                                            height: 28,
                                            child: Center(child: leading(item)),
                                          ),
                                    title: Text(
                                      labelVoor(item),
                                      style: TextStyle(
                                        color: _tekst,
                                        fontSize: 12,
                                        fontWeight: isGeselecteerd
                                            ? FontWeight.w900
                                            : FontWeight.w700,
                                      ),
                                    ),
                                    subtitle: ondertitel.isEmpty
                                        ? null
                                        : Text(
                                            ondertitel,
                                            style: const TextStyle(
                                              color: _tekstGrijs,
                                              fontSize: 10.5,
                                            ),
                                          ),
                                    trailing: isGeselecteerd
                                        ? const Icon(
                                            Icons.check_circle_rounded,
                                            color: _groen,
                                            size: 20,
                                          )
                                        : null,
                                    onTap: () =>
                                        Navigator.of(dialogContext).pop(item),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Annuleren'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      zoekController.dispose();
    }
  }

  String _normaliseerZoektekst(String waarde) {
    return waarde
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâäãå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôöõ]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  OpmetingUitvalschermDoek? _huidigDoek() {
    for (final doek in widget.instellingen.doeken) {
      if (doek.id == widget.model.doekCode.trim().toUpperCase()) {
        return doek;
      }
    }
    return widget.instellingen.doeken.isEmpty
        ? null
        : widget.instellingen.doeken.first;
  }

  String _huidigeBediening(List<String> bedieningen) {
    final huidig = widget.model.bediening.trim();
    if (bedieningen.contains(huidig)) return huidig;
    return bedieningen.isEmpty ? '' : bedieningen.first;
  }

  OpmetingUitvalschermKleur? _huidigeKleur() {
    for (final kleur in widget.instellingen.draagstructuurKleuren) {
      if (kleur.naam == widget.model.draagstructuurKleur &&
          kleur.code == widget.model.draagstructuurKleurCode) {
        return kleur;
      }
    }
    return widget.instellingen.draagstructuurKleuren.isEmpty
        ? null
        : widget.instellingen.draagstructuurKleuren.first;
  }

  Widget _doekCirkel(String hex) {
    final waarde =
        int.tryParse(hex.replaceFirst('#', ''), radix: 16) ?? 0x8C8C8A;
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF000000 | waarde),
        shape: BoxShape.circle,
        border: Border.all(color: _tekstGrijs),
      ),
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
        border: Border.all(color: _OpmetingUitvalschermRechterkolomState._rand),
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
                      color: _OpmetingUitvalschermRechterkolomState._tekst,
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
  });

  final String titel;
  final T waarde;
  final List<T> keuzes;
  final String Function(T waarde) labelVoor;
  final ValueChanged<T> onChanged;
  final bool horizontaal;

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

class _MotorRadioSectie extends StatelessWidget {
  const _MotorRadioSectie({
    required this.titel,
    required this.motoren,
    required this.geselecteerdId,
    required this.onChanged,
  });

  final String titel;
  final List<OpmetingUitvalschermMotor> motoren;
  final String geselecteerdId;
  final ValueChanged<OpmetingUitvalschermMotor> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SectieKaart(
      titel: titel,
      children: <Widget>[
        if (motoren.isEmpty)
          const Text(
            'Voeg eerst motoren toe via Instellingen → Uitvalschermen.',
            style: TextStyle(
              color: _OpmetingUitvalschermRechterkolomState._tekstGrijs,
              fontSize: 11,
            ),
          )
        else
          RadioGroup<String>(
            groupValue: geselecteerdId,
            onChanged: (nieuwId) {
              if (nieuwId == null) return;
              for (final motor in motoren) {
                if (motor.id == nieuwId) {
                  onChanged(motor);
                  return;
                }
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: motoren
                  .map(
                    (motor) => _EenvoudigeRadioKeuze<String>(
                      waarde: motor.id,
                      label: motor.label,
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
      ],
    );
  }
}

class _EenvoudigeRadioKeuze<T> extends StatelessWidget {
  const _EenvoudigeRadioKeuze({required this.waarde, required this.label});

  final T waarde;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Radio<T>(
          value: waarde,
          activeColor: _OpmetingUitvalschermRechterkolomState._groen,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        ),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              color: _OpmetingUitvalschermRechterkolomState._tekst,
              fontSize: 11.5,
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
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 38,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 11.5),
              decoration: _compacteDecoratie(),
            ),
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
    required this.eenheid,
    required this.onChanged,
    this.maxLengte,
    this.hulp = '',
    this.onEditingComplete,
  });

  final String titel;
  final TextEditingController controller;
  final String eenheid;
  final ValueChanged<String> onChanged;
  final int? maxLengte;
  final String hulp;
  final VoidCallback? onEditingComplete;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: hulp.isEmpty
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 112,
          child: Padding(
            padding: EdgeInsets.only(top: hulp.isEmpty ? 0 : 11),
            child: Text(
              titel,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              if (maxLengte != null)
                LengthLimitingTextInputFormatter(maxLengte),
            ],
            onChanged: onChanged,
            onEditingComplete: onEditingComplete,
            style: const TextStyle(fontSize: 11.5),
            decoration: _compacteDecoratie(
              suffixText: eenheid,
              helperText: hulp.isEmpty ? null : hulp,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactZoekKeuzeRij<T> extends StatelessWidget {
  const _CompactZoekKeuzeRij({
    required this.titel,
    required this.waarde,
    required this.legeTekst,
    required this.labelVoor,
    required this.onTap,
    this.leading,
  });

  final String titel;
  final T? waarde;
  final String legeTekst;
  final String Function(T waarde) labelVoor;
  final VoidCallback? onTap;
  final Widget Function(T waarde)? leading;

  @override
  Widget build(BuildContext context) {
    final huidigeWaarde = waarde;

    return Row(
      children: <Widget>[
        SizedBox(
          width: 112,
          child: Text(
            titel,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: onTap == null ? const Color(0xFFF3F4F6) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _OpmetingUitvalschermRechterkolomState._rand,
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    if (huidigeWaarde != null && leading != null) ...<Widget>[
                      SizedBox(
                        width: 21,
                        height: 21,
                        child: leading!(huidigeWaarde),
                      ),
                      const SizedBox(width: 7),
                    ],
                    Expanded(
                      child: Text(
                        huidigeWaarde == null
                            ? legeTekst
                            : labelVoor(huidigeWaarde),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: huidigeWaarde == null
                              ? _OpmetingUitvalschermRechterkolomState
                                    ._tekstGrijs
                              : _OpmetingUitvalschermRechterkolomState._tekst,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: onTap == null
                          ? _OpmetingUitvalschermRechterkolomState._tekstGrijs
                          : _OpmetingUitvalschermRechterkolomState._groen,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactDropdownRij<T> extends StatelessWidget {
  const _CompactDropdownRij({
    required this.titel,
    required this.waarde,
    required this.waarden,
    required this.labelVoor,
    required this.onChanged,
    this.leading,
  });

  final String titel;
  final T? waarde;
  final List<T> waarden;
  final String Function(T waarde) labelVoor;
  final ValueChanged<T?> onChanged;
  final Widget Function(T waarde)? leading;

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
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 38,
            child: DropdownButtonFormField<T>(
              initialValue: waarde,
              isExpanded: true,
              items: waarden
                  .map((item) {
                    return DropdownMenuItem<T>(
                      value: item,
                      child: Row(
                        children: <Widget>[
                          if (leading != null) ...<Widget>[
                            SizedBox(
                              width: 21,
                              height: 21,
                              child: leading!(item),
                            ),
                            const SizedBox(width: 7),
                          ],
                          Expanded(
                            child: Text(
                              labelVoor(item),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  })
                  .toList(growable: false),
              onChanged: onChanged,
              decoration: _compacteDecoratie(),
            ),
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
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 38,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _OpmetingUitvalschermRechterkolomState._rand,
              ),
            ),
            child: Text(
              waarde,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactSwitchRij extends StatelessWidget {
  const _CompactSwitchRij({
    required this.titel,
    required this.waarde,
    required this.onChanged,
  });

  final String titel;
  final bool waarde;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              titel,
              style: const TextStyle(
                color: _OpmetingUitvalschermRechterkolomState._tekst,
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
                value: waarde,
                activeTrackColor: _OpmetingUitvalschermRechterkolomState._groen,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBlok extends StatelessWidget {
  const _InfoBlok({required this.tekst});

  final String tekst;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: _OpmetingUitvalschermRechterkolomState._lichtGroen,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        tekst,
        style: const TextStyle(
          color: _OpmetingUitvalschermRechterkolomState._groen,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

InputDecoration _compacteDecoratie({String? suffixText, String? helperText}) {
  return InputDecoration(
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    suffixText: suffixText,
    helperText: helperText,
    helperMaxLines: 1,
    helperStyle: const TextStyle(fontSize: 9.5),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: _OpmetingUitvalschermRechterkolomState._rand,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: _OpmetingUitvalschermRechterkolomState._rand,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: _OpmetingUitvalschermRechterkolomState._groen,
        width: 1.4,
      ),
    ),
  );
}
