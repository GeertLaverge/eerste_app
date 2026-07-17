import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'opmeting_schuifraam_model.dart';
import 'opmeting_schuifraam_opbouw_storage_helper.dart';
import 'opmeting_schuifraam_teken_helper.dart';

class OpmetingSchuifraamSamenstellingResultaat {
  const OpmetingSchuifraamSamenstellingResultaat({
    required this.samenstelling,
    required this.breedteMm,
    required this.hoogteMm,
  });

  final OpmetingSchuifraamSamenstelling samenstelling;
  final int breedteMm;
  final int hoogteMm;
}

Future<OpmetingSchuifraamSamenstellingResultaat?>
toonOpmetingSchuifraamSamenstellingDialog({
  required BuildContext context,
  required int breedteMm,
  required int hoogteMm,
  OpmetingSchuifraamSamenstelling? bestaandeSamenstelling,
}) {
  const groen = Color(0xFF0B7A3B);
  const lichtGroen = Color(0xFFE7F6EC);

  return showDialog<OpmetingSchuifraamSamenstellingResultaat>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final basisTheme = Theme.of(dialogContext);
      final basisKleuren = basisTheme.colorScheme;

      return Theme(
        data: basisTheme.copyWith(
          colorScheme: basisKleuren.copyWith(
            primary: groen,
            secondary: groen,
            primaryContainer: lichtGroen,
            secondaryContainer: lichtGroen,
            onPrimaryContainer: groen,
            onSecondaryContainer: groen,
          ),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: groen,
            selectionHandleColor: groen,
          ),
          inputDecorationTheme: basisTheme.inputDecorationTheme.copyWith(
            floatingLabelStyle: const TextStyle(
              color: groen,
              fontWeight: FontWeight.w800,
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: groen, width: 2),
            ),
          ),
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: groen,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: groen),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: groen,
              foregroundColor: Colors.white,
            ),
          ),
          iconButtonTheme: IconButtonThemeData(
            style: IconButton.styleFrom(foregroundColor: groen),
          ),
        ),
        child: _OpmetingSchuifraamSamenstellingDialog(
          bestaandeSamenstelling: bestaandeSamenstelling,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
        ),
      );
    },
  );
}

enum _SchuifraamBreedteKeuze { helft, derde, kwart }

extension _SchuifraamBreedteKeuzeInfo on _SchuifraamBreedteKeuze {
  String get label {
    switch (this) {
      case _SchuifraamBreedteKeuze.helft:
        return '1/2';
      case _SchuifraamBreedteKeuze.derde:
        return '1/3';
      case _SchuifraamBreedteKeuze.kwart:
        return '1/4';
    }
  }

  int get noemer {
    switch (this) {
      case _SchuifraamBreedteKeuze.helft:
        return 2;
      case _SchuifraamBreedteKeuze.derde:
        return 3;
      case _SchuifraamBreedteKeuze.kwart:
        return 4;
    }
  }

  double get schuifFractie => 1 / noemer;
}

class _OpmetingSchuifraamSamenstellingDialog extends StatefulWidget {
  const _OpmetingSchuifraamSamenstellingDialog({
    required this.bestaandeSamenstelling,
    required this.breedteMm,
    required this.hoogteMm,
  });

  final OpmetingSchuifraamSamenstelling? bestaandeSamenstelling;
  final int breedteMm;
  final int hoogteMm;

  @override
  State<_OpmetingSchuifraamSamenstellingDialog> createState() {
    return _OpmetingSchuifraamSamenstellingDialogState();
  }
}

class _OpmetingSchuifraamSamenstellingDialogState
    extends State<_OpmetingSchuifraamSamenstellingDialog> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _achtergrond = Color(0xFFF9FAFB);
  static const Color _rood = Color(0xFFDC2626);

  late OpmetingSchuifraamSysteem _systeem;
  late OpmetingSchuifraamType _type;
  late _SchuifraamBreedteKeuze _breedteKeuze;
  late final TextEditingController _verschuivingController;
  late final TextEditingController _breedteController;
  late final TextEditingController _hoogteController;
  late final List<TextEditingController> _vakControllers;

  List<OpmetingSchuifraamOpbouwType> _opbouwen =
      <OpmetingSchuifraamOpbouwType>[];
  String? _geselecteerdeOpbouwId;
  bool _opbouwEditorOpen = false;
  bool _opbouwenLaden = true;
  String? _foutmelding;

  @override
  void initState() {
    super.initState();

    final bestaand =
        widget.bestaandeSamenstelling ??
        const OpmetingSchuifraamSamenstelling();

    _systeem = bestaand.systeem;
    _type = _systeem.verplichtType;
    _breedteKeuze = _bepaalBreedteKeuze(bestaand);
    _verschuivingController = TextEditingController(
      text: _zonderNuttelozeDecimalen(
        bestaand.genormaliseerdeScheidingVerschuivingenMm.isEmpty
            ? 0
            : bestaand.genormaliseerdeScheidingVerschuivingenMm.first.abs(),
      ),
    );
    _breedteController = TextEditingController(
      text: math.max(1, widget.breedteMm).toString(),
    );
    _hoogteController = TextEditingController(
      text: math.max(1, widget.hoogteMm).toString(),
    );
    _vakControllers = List<TextEditingController>.generate(
      4,
      (_) => TextEditingController(),
    );

    _laadOpbouwen();
  }

  @override
  void dispose() {
    _verschuivingController.dispose();
    _breedteController.dispose();
    _hoogteController.dispose();

    for (final controller in _vakControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _laadOpbouwen() async {
    final geladen = await OpmetingSchuifraamOpbouwStorageHelper.laad();
    final opbouwen = List<OpmetingSchuifraamOpbouwType>.from(geladen);
    final bestaand =
        widget.bestaandeSamenstelling ??
        const OpmetingSchuifraamSamenstelling();
    final bestaandeSleutel = bestaand.vakken.map((vak) => vak.code).join();

    String? geselecteerdeId;

    for (final opbouw in opbouwen) {
      if (opbouw.opslagSleutel == bestaandeSleutel) {
        geselecteerdeId = opbouw.id;
        break;
      }
    }

    if (geselecteerdeId == null) {
      final startOpbouw = OpmetingSchuifraamOpbouwType(
        id: 'schuifraam_opbouw_${DateTime.now().microsecondsSinceEpoch}',
        vakken: List<OpmetingSchuifraamVakType>.unmodifiable(bestaand.vakken),
      );

      if (startOpbouw.isGeldig) {
        opbouwen.add(startOpbouw);
        geselecteerdeId = startOpbouw.id;
        await OpmetingSchuifraamOpbouwStorageHelper.bewaar(opbouwen);
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _opbouwen = opbouwen;
      _geselecteerdeOpbouwId = geselecteerdeId;
      _opbouwenLaden = false;
    });
  }

  String _zonderNuttelozeDecimalen(double waarde) {
    if (waarde == 0) {
      return '';
    }

    if (waarde == waarde.roundToDouble()) {
      return waarde.round().toString();
    }

    return waarde.toStringAsFixed(1);
  }

  _SchuifraamBreedteKeuze _bepaalBreedteKeuze(
    OpmetingSchuifraamSamenstelling samenstelling,
  ) {
    if (!_isEnkelVastEnSchuif(samenstelling.vakken)) {
      return _SchuifraamBreedteKeuze.helft;
    }

    final schuifIndex = samenstelling.vakken.indexOf(
      OpmetingSchuifraamVakType.schuif,
    );
    final breedtes = samenstelling.genormaliseerdeBreedtes;

    if (schuifIndex < 0 || schuifIndex >= breedtes.length) {
      return _SchuifraamBreedteKeuze.helft;
    }

    final schuifFractie = breedtes[schuifIndex];

    return _SchuifraamBreedteKeuze.values.reduce((eerste, tweede) {
      final eersteVerschil = (eerste.schuifFractie - schuifFractie).abs();
      final tweedeVerschil = (tweede.schuifFractie - schuifFractie).abs();

      return eersteVerschil <= tweedeVerschil ? eerste : tweede;
    });
  }

  bool _isEnkelVastEnSchuif(List<OpmetingSchuifraamVakType> vakken) {
    return vakken.length == 2 &&
        vakken.where((vak) => vak == OpmetingSchuifraamVakType.vast).length ==
            1 &&
        vakken.where((vak) => vak == OpmetingSchuifraamVakType.schuif).length ==
            1;
  }

  OpmetingSchuifraamOpbouwType? get _geselecteerdeOpbouw {
    final id = _geselecteerdeOpbouwId;

    if (id == null) {
      return null;
    }

    for (final opbouw in _opbouwen) {
      if (opbouw.id == id) {
        return opbouw;
      }
    }

    return null;
  }

  bool get _heeftEnkelVastEnSchuif {
    final opbouw = _geselecteerdeOpbouw;
    return opbouw != null && _isEnkelVastEnSchuif(opbouw.vakken);
  }

  List<OpmetingSchuifraamVakType>? _leesNieuweOpbouw() {
    final resultaat = <OpmetingSchuifraamVakType>[];
    var leegGezien = false;

    for (final controller in _vakControllers) {
      final tekst = controller.text.trim().toUpperCase();

      if (tekst.isEmpty) {
        leegGezien = true;
        continue;
      }

      if (leegGezien) {
        _foutmelding = 'Vul de vakken aansluitend van links naar rechts in.';
        return null;
      }

      final vak = OpmetingSchuifraamVakTypeInfo.vanCode(tekst);

      if (vak == null) {
        _foutmelding = 'Gebruik uitsluitend V voor vast of S voor schuif.';
        return null;
      }

      resultaat.add(vak);
    }

    if (resultaat.length < 2) {
      _foutmelding = 'Vul minstens twee vakken in.';
      return null;
    }

    if (!resultaat.contains(OpmetingSchuifraamVakType.schuif)) {
      _foutmelding = 'Een schuifraam moet minstens één schuifdeel bevatten.';
      return null;
    }

    return resultaat;
  }

  Future<void> _voegOpbouwToe() async {
    setState(() {
      _foutmelding = null;
    });

    final vakken = _leesNieuweOpbouw();

    if (vakken == null) {
      setState(() {});
      return;
    }

    final sleutel = vakken.map((vak) => vak.code).join();
    final bestaandeIndex = _opbouwen.indexWhere(
      (opbouw) => opbouw.opslagSleutel == sleutel,
    );

    if (bestaandeIndex >= 0) {
      setState(() {
        _geselecteerdeOpbouwId = _opbouwen[bestaandeIndex].id;
        _opbouwEditorOpen = false;
        _breedteKeuze = _SchuifraamBreedteKeuze.helft;
        _verschuivingController.clear();
        _foutmelding = 'Deze opbouw bestaat al en werd geselecteerd.';
      });
      _wisNieuweOpbouwVelden();
      return;
    }

    final nieuweOpbouw = OpmetingSchuifraamOpbouwType(
      id: 'schuifraam_opbouw_${DateTime.now().microsecondsSinceEpoch}',
      vakken: List<OpmetingSchuifraamVakType>.unmodifiable(vakken),
    );
    final nieuweLijst = <OpmetingSchuifraamOpbouwType>[
      ..._opbouwen,
      nieuweOpbouw,
    ];

    await OpmetingSchuifraamOpbouwStorageHelper.bewaar(nieuweLijst);

    if (!mounted) {
      return;
    }

    setState(() {
      _opbouwen = nieuweLijst;
      _geselecteerdeOpbouwId = nieuweOpbouw.id;
      _opbouwEditorOpen = false;
      _breedteKeuze = _SchuifraamBreedteKeuze.helft;
      _verschuivingController.clear();
      _foutmelding = null;
    });

    _wisNieuweOpbouwVelden();
  }

  void _wisNieuweOpbouwVelden() {
    for (final controller in _vakControllers) {
      controller.clear();
    }
  }

  void _selecteerOpbouw(OpmetingSchuifraamOpbouwType opbouw) {
    setState(() {
      _geselecteerdeOpbouwId = opbouw.id;
      _breedteKeuze = _SchuifraamBreedteKeuze.helft;
      _verschuivingController.clear();
      _foutmelding = null;
    });
  }

  Future<void> _verwijderOpbouw(OpmetingSchuifraamOpbouwType opbouw) async {
    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Text('Schuifraamtype wissen?'),
          content: Text(
            'De opbouw “${opbouw.code}” wordt uit het keuzemenu verwijderd.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuleren'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _rood),
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Wissen'),
            ),
          ],
        );
      },
    );

    if (bevestigen != true) {
      return;
    }

    final nieuweLijst = _opbouwen
        .where((item) => item.id != opbouw.id)
        .toList(growable: false);

    await OpmetingSchuifraamOpbouwStorageHelper.bewaar(nieuweLijst);

    if (!mounted) {
      return;
    }

    setState(() {
      _opbouwen = nieuweLijst;

      if (_geselecteerdeOpbouwId == opbouw.id) {
        _geselecteerdeOpbouwId = nieuweLijst.isEmpty
            ? null
            : nieuweLijst.first.id;
        _breedteKeuze = _SchuifraamBreedteKeuze.helft;
        _verschuivingController.clear();
      }

      _foutmelding = null;
    });
  }

  void _kiesSysteem(OpmetingSchuifraamSysteem systeem) {
    setState(() {
      _systeem = systeem;
      _type = systeem.verplichtType;
      _foutmelding = null;
    });
  }

  double? _leesVerschuivingMm({bool zetFoutmelding = true}) {
    if (!_heeftEnkelVastEnSchuif) {
      return 0;
    }

    final tekst = _verschuivingController.text.trim().replaceAll(',', '.');
    final waarde = tekst.isEmpty ? 0.0 : double.tryParse(tekst);

    if (waarde == null || waarde < 0) {
      if (zetFoutmelding) {
        _foutmelding =
            'Vul een geldige positieve verschuiving in millimeter in.';
      }
      return null;
    }

    return waarde;
  }

  List<double> _breedteDelenVoor(List<OpmetingSchuifraamVakType> vakken) {
    if (!_isEnkelVastEnSchuif(vakken)) {
      return List<double>.filled(vakken.length, 1);
    }

    final resultaat = List<double>.filled(vakken.length, 1);
    final schuifIndex = vakken.indexOf(OpmetingSchuifraamVakType.schuif);
    final vastIndex = vakken.indexOf(OpmetingSchuifraamVakType.vast);

    resultaat[schuifIndex] = 1;
    resultaat[vastIndex] = (_breedteKeuze.noemer - 1).toDouble();

    return resultaat;
  }

  List<double> _verschuivingenVoor(
    List<OpmetingSchuifraamVakType> vakken,
    double verschuivingMm,
  ) {
    if (!_isEnkelVastEnSchuif(vakken)) {
      return List<double>.filled(math.max(0, vakken.length - 1), 0);
    }

    final schuifLinks = vakken.first == OpmetingSchuifraamVakType.schuif;

    return <double>[schuifLinks ? -verschuivingMm : verschuivingMm];
  }

  int? _leesMaatMm(
    TextEditingController controller, {
    required String naam,
    required int terugval,
    bool zetFoutmelding = true,
  }) {
    final tekst = controller.text.trim();

    if (tekst.isEmpty) {
      if (zetFoutmelding) {
        _foutmelding = 'Vul de $naam van het schuifraam in.';
        return null;
      }

      return math.max(1, terugval).toInt();
    }

    final waarde = int.tryParse(tekst);

    if (waarde == null || waarde <= 0) {
      if (zetFoutmelding) {
        _foutmelding = 'Vul een geldige $naam in millimeter in.';
        return null;
      }

      return math.max(1, terugval).toInt();
    }

    return waarde;
  }

  int get _voorbeeldBreedteMm {
    return _leesMaatMm(
          _breedteController,
          naam: 'breedte',
          terugval: widget.breedteMm,
          zetFoutmelding: false,
        ) ??
        math.max(1, widget.breedteMm).toInt();
  }

  int get _voorbeeldHoogteMm {
    return _leesMaatMm(
          _hoogteController,
          naam: 'hoogte',
          terugval: widget.hoogteMm,
          zetFoutmelding: false,
        ) ??
        math.max(1, widget.hoogteMm).toInt();
  }

  OpmetingSchuifraamSamenstelling? _maakHuidigeSamenstelling({
    bool controleerInvoer = false,
  }) {
    final opbouw = _geselecteerdeOpbouw;

    if (opbouw == null || !opbouw.isGeldig) {
      if (controleerInvoer) {
        _foutmelding = 'Voeg eerst een schuifraamopbouw toe en selecteer deze.';
      }
      return null;
    }

    final verschuivingMm = _leesVerschuivingMm(
      zetFoutmelding: controleerInvoer,
    );

    if (verschuivingMm == null) {
      return null;
    }

    return OpmetingSchuifraamSamenstelling(
      systeem: _systeem,
      type: _systeem.verplichtType,
      vakken: List<OpmetingSchuifraamVakType>.unmodifiable(opbouw.vakken),
      breedteDelen: List<double>.unmodifiable(_breedteDelenVoor(opbouw.vakken)),
      scheidingVerschuivingenMm: List<double>.unmodifiable(
        _verschuivingenVoor(opbouw.vakken, verschuivingMm),
      ),
      onderkantVloerpasMm: widget.bestaandeSamenstelling?.onderkantVloerpasMm,
    );
  }

  void _bewaar() {
    setState(() {
      _foutmelding = null;
    });

    final samenstelling = _maakHuidigeSamenstelling(controleerInvoer: true);
    final breedteMm = _leesMaatMm(
      _breedteController,
      naam: 'breedte',
      terugval: widget.breedteMm,
    );
    final hoogteMm = _leesMaatMm(
      _hoogteController,
      naam: 'hoogte',
      terugval: widget.hoogteMm,
    );

    if (samenstelling == null || breedteMm == null || hoogteMm == null) {
      setState(() {});
      return;
    }

    Navigator.pop(
      context,
      OpmetingSchuifraamSamenstellingResultaat(
        samenstelling: samenstelling,
        breedteMm: breedteMm,
        hoogteMm: hoogteMm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final samenstellingVoorbeeld = _maakHuidigeSamenstelling();
    final voorbeeldBreedteMm = _voorbeeldBreedteMm;
    final voorbeeldHoogteMm = _voorbeeldHoogteMm;

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
        decoration: const BoxDecoration(
          color: _lichtGroen,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: const Row(
          children: [
            Icon(Icons.view_week_outlined, color: _groen),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Schuifraam samenstellen',
                style: TextStyle(color: _groen, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: 720,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Schuifraamsysteem',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<OpmetingSchuifraamSysteem>(
                value: _systeem,
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Systeem',
                ),
                items: OpmetingSchuifraamSysteem.values.map((systeem) {
                  return DropdownMenuItem<OpmetingSchuifraamSysteem>(
                    value: systeem,
                    child: Text(systeem.label),
                  );
                }).toList(),
                onChanged: (waarde) {
                  if (waarde != null) {
                    _kiesSysteem(waarde);
                  }
                },
              ),
              const SizedBox(height: 8),
              Text(
                _systeem == OpmetingSchuifraamSysteem.xmovePvcLi82
                    ? 'Bij XMove PVC LI82 is alleen Mono beschikbaar.'
                    : 'Bij ${_systeem.label} is alleen Duo beschikbaar.',
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
              const SizedBox(height: 14),
              SegmentedButton<OpmetingSchuifraamType>(
                segments: OpmetingSchuifraamType.values.map((type) {
                  return ButtonSegment<OpmetingSchuifraamType>(
                    value: type,
                    enabled: _systeem.ondersteuntType(type),
                    label: Text(type.label),
                    icon: Icon(
                      type == OpmetingSchuifraamType.mono
                          ? Icons.filter_1_outlined
                          : Icons.filter_2_outlined,
                    ),
                  );
                }).toList(),
                selected: <OpmetingSchuifraamType>{_type},
                onSelectionChanged: (selectie) {
                  if (selectie.isEmpty ||
                      !_systeem.ondersteuntType(selectie.first)) {
                    return;
                  }

                  setState(() {
                    _type = selectie.first;
                    _foutmelding = null;
                  });
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Opbouw van links naar rechts',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: _opbouwEditorOpen
                        ? 'Invoer sluiten'
                        : 'Nieuwe opbouw maken',
                    onPressed: () {
                      setState(() {
                        _opbouwEditorOpen = !_opbouwEditorOpen;
                        _foutmelding = null;
                      });
                    },
                    icon: Icon(
                      _opbouwEditorOpen
                          ? Icons.remove_rounded
                          : Icons.add_rounded,
                    ),
                  ),
                ],
              ),
              const Text(
                'Klik op + om zelf een opbouw met V en S te maken.',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: !_opbouwEditorOpen
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _rand),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'V = vast · S = schuif. Laat ongebruikte vakken rechts leeg.',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: List<Widget>.generate(4, (index) {
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        right: index == 3 ? 0 : 8,
                                      ),
                                      child: TextField(
                                        controller: _vakControllers[index],
                                        textAlign: TextAlign.center,
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        maxLength: 1,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp('[vVsS]'),
                                          ),
                                          LengthLimitingTextInputFormatter(1),
                                        ],
                                        onChanged: (_) {
                                          setState(() {
                                            _foutmelding = null;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          counterText: '',
                                          labelText: 'Vak ${index + 1}',
                                          border: const OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: FilledButton.icon(
                                  onPressed: _voegOpbouwToe,
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('Toevoegen'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              if (_opbouwenLaden)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_opbouwen.isEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _achtergrond,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _rand),
                  ),
                  child: const Text(
                    'Nog geen schuifraamtypes. Klik op + om de eerste opbouw toe te voegen.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _opbouwen.map(_bouwOpbouwTegel).toList(),
                ),
              const SizedBox(height: 18),
              const Text(
                'Breedte schuifdeel',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                _heeftEnkelVastEnSchuif
                    ? 'Kies welk deel van de beschikbare breedte het schuifdeel inneemt.'
                    : 'Deze keuze is alleen beschikbaar bij één vast en één schuivend deel.',
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
              const SizedBox(height: 10),
              SegmentedButton<_SchuifraamBreedteKeuze>(
                segments: _SchuifraamBreedteKeuze.values.map((keuze) {
                  return ButtonSegment<_SchuifraamBreedteKeuze>(
                    value: keuze,
                    enabled: _heeftEnkelVastEnSchuif,
                    label: Text(keuze.label),
                  );
                }).toList(),
                selected: <_SchuifraamBreedteKeuze>{_breedteKeuze},
                onSelectionChanged: (selectie) {
                  if (selectie.isEmpty || !_heeftEnkelVastEnSchuif) {
                    return;
                  }

                  setState(() {
                    _breedteKeuze = selectie.first;
                    _foutmelding = null;
                  });
                },
              ),
              const SizedBox(height: 18),
              const Text(
                'Scheiding verschuiven',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              const Text(
                'De maat verschuift de stijl automatisch in de richting van het schuifdeel. Daardoor wordt de schuifvleugel kleiner.',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _verschuivingController,
                enabled: _heeftEnkelVastEnSchuif,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9,.]')),
                ],
                onChanged: (_) {
                  setState(() {
                    _foutmelding = null;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Verschuiving',
                  suffixText: 'mm',
                  hintText: '0',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _breedteController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) {
                        setState(() {
                          _foutmelding = null;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Breedte schuifraam',
                        suffixText: 'mm',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _hoogteController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) {
                        setState(() {
                          _foutmelding = null;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Hoogte schuifraam',
                        suffixText: 'mm',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 225,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _rand),
                ),
                child: samenstellingVoorbeeld == null
                    ? const Center(
                        child: Text(
                          'Selecteer eerst een schuifraamtype.',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                      )
                    : CustomPaint(
                        painter: _SchuifraamVoorbeeldPainter(
                          samenstelling: samenstellingVoorbeeld,
                          breedteMm: voorbeeldBreedteMm,
                          hoogteMm: voorbeeldHoogteMm,
                        ),
                        child: const SizedBox.expand(),
                      ),
              ),
              const SizedBox(height: 10),
              Text(
                samenstellingVoorbeeld?.samenvatting ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _groen,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (_foutmelding != null) ...[
                const SizedBox(height: 12),
                Text(
                  _foutmelding!,
                  style: TextStyle(
                    color: _foutmelding!.contains('bestaat al')
                        ? _groen
                        : _rood,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuleren'),
        ),
        FilledButton.icon(
          onPressed: _bewaar,
          icon: const Icon(Icons.check_rounded),
          label: const Text('Toepassen'),
        ),
      ],
    );
  }

  Widget _bouwOpbouwTegel(OpmetingSchuifraamOpbouwType opbouw) {
    final geselecteerd = opbouw.id == _geselecteerdeOpbouwId;
    final voorbeeldSamenstelling = OpmetingSchuifraamSamenstelling(
      systeem: _systeem,
      type: _systeem.verplichtType,
      vakken: opbouw.vakken,
      breedteDelen: List<double>.filled(opbouw.vakken.length, 1),
      scheidingVerschuivingenMm: List<double>.filled(
        math.max(0, opbouw.vakken.length - 1),
        0,
      ),
    );

    return SizedBox(
      width: 150,
      child: Material(
        color: geselecteerd ? _lichtGroen : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _selecteerOpbouw(opbouw),
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: geselecteerd ? _groen : _rand,
                width: geselecteerd ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        opbouw.code,
                        style: TextStyle(
                          color: geselecteerd
                              ? _groen
                              : const Color(0xFF111827),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Type wissen',
                      onPressed: () => _verwijderOpbouw(opbouw),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: _rood,
                        size: 19,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 76,
                  child: CustomPaint(
                    painter: _SchuifraamMiniatuurPainter(
                      samenstelling: voorbeeldSamenstelling,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SchuifraamMiniatuurPainter extends CustomPainter {
  const _SchuifraamMiniatuurPainter({required this.samenstelling});

  final OpmetingSchuifraamSamenstelling samenstelling;

  @override
  void paint(Canvas canvas, Size size) {
    final buiten = Rect.fromLTWH(4, 4, size.width - 8, size.height - 8);
    final geometrie =
        OpmetingSchuifraamTekenHelper.berekenGeometrieVoorBuitenKader(
          buitenKader: buiten,
          breedteMm: 2500,
          hoogteMm: 2200,
          samenstelling: samenstelling,
        );

    OpmetingSchuifraamTekenHelper.tekenProfielen(
      canvas: canvas,
      geometrie: geometrie,
    );
    OpmetingSchuifraamTekenHelper.tekenSymbolen(
      canvas: canvas,
      samenstelling: samenstelling,
      geometrie: geometrie,
    );
  }

  @override
  bool shouldRepaint(covariant _SchuifraamMiniatuurPainter oldDelegate) {
    return oldDelegate.samenstelling.toJson().toString() !=
        samenstelling.toJson().toString();
  }
}

class _SchuifraamVoorbeeldPainter extends CustomPainter {
  const _SchuifraamVoorbeeldPainter({
    required this.samenstelling,
    required this.breedteMm,
    required this.hoogteMm,
  });

  final OpmetingSchuifraamSamenstelling samenstelling;
  final int breedteMm;
  final int hoogteMm;

  @override
  void paint(Canvas canvas, Size size) {
    final effectieveBreedteMm = math.max(1, breedteMm);
    final effectieveHoogteMm = math.max(1, hoogteMm);
    final beschikbareBreedte = math.max(40.0, size.width - 20);
    final beschikbareHoogte = math.max(40.0, size.height - 66);
    final schaal = math.min(
      beschikbareBreedte / effectieveBreedteMm,
      beschikbareHoogte / effectieveHoogteMm,
    );
    final getekendeBreedte = effectieveBreedteMm * schaal;
    final getekendeHoogte = effectieveHoogteMm * schaal;
    final buiten = Rect.fromLTWH(
      (size.width - getekendeBreedte) / 2,
      8 + (beschikbareHoogte - getekendeHoogte) / 2,
      getekendeBreedte,
      getekendeHoogte,
    );
    final geometrie =
        OpmetingSchuifraamTekenHelper.berekenGeometrieVoorBuitenKader(
          buitenKader: buiten,
          breedteMm: effectieveBreedteMm,
          hoogteMm: effectieveHoogteMm,
          samenstelling: samenstelling,
        );

    OpmetingSchuifraamTekenHelper.tekenProfielen(
      canvas: canvas,
      geometrie: geometrie,
    );
    OpmetingSchuifraamTekenHelper.tekenSymbolen(
      canvas: canvas,
      samenstelling: samenstelling,
      geometrie: geometrie,
    );
    OpmetingSchuifraamTekenHelper.tekenBreedteMaatvoering(
      canvas: canvas,
      geometrie: geometrie,
      breedteMm: effectieveBreedteMm,
      maatLijnY: geometrie.buitenKader.bottom + 16,
      totaleMaatLijnY: geometrie.buitenKader.bottom + 43,
    );
  }

  @override
  bool shouldRepaint(covariant _SchuifraamVoorbeeldPainter oldDelegate) {
    return oldDelegate.breedteMm != breedteMm ||
        oldDelegate.hoogteMm != hoogteMm ||
        oldDelegate.samenstelling.toJson().toString() !=
            samenstelling.toJson().toString();
  }
}
