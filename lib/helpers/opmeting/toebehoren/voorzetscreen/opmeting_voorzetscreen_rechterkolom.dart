// THIMACO-CONTROLE: VOORZETSCREEN-KAST-ZONNECEL-BEDIENING-20260811
// THIMACO-CONTROLE: VOORZETSCREEN-ALLE-KEUZES-RADIOKNOPPEN-20260730-2155
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'opmeting_voorzetscreen_instellingen_model.dart';
import 'opmeting_voorzetscreen_model.dart';

class OpmetingVoorzetscreenRechterkolom extends StatefulWidget {
  const OpmetingVoorzetscreenRechterkolom({
    super.key,
    required this.model,
    required this.instellingen,
    required this.onGewijzigd,
    this.projectKleur = '',
  });

  final OpmetingVoorzetscreenModel model;
  final OpmetingVoorzetscreenInstellingen instellingen;
  final ValueChanged<OpmetingVoorzetscreenModel> onGewijzigd;
  final String projectKleur;

  @override
  State<OpmetingVoorzetscreenRechterkolom> createState() {
    return _OpmetingVoorzetscreenRechterkolomState();
  }
}

class _OpmetingVoorzetscreenRechterkolomState
    extends State<OpmetingVoorzetscreenRechterkolom> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekst = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  late final TextEditingController _positieController;
  late final TextEditingController _aantalController;
  late final TextEditingController _breedteController;
  late final TextEditingController _hoogteController;

  @override
  void initState() {
    super.initState();
    _positieController = TextEditingController();
    _aantalController = TextEditingController();
    _breedteController = TextEditingController();
    _hoogteController = TextEditingController();
    _synchroniseerControllers();
  }

  @override
  void didUpdateWidget(covariant OpmetingVoorzetscreenRechterkolom oldWidget) {
    super.didUpdateWidget(oldWidget);
    _synchroniseerControllers();
  }

  @override
  void dispose() {
    _positieController.dispose();
    _aantalController.dispose();
    _breedteController.dispose();
    _hoogteController.dispose();
    super.dispose();
  }

  void _synchroniseerControllers() {
    _stelTekstIn(_positieController, widget.model.positie);
    _stelTekstIn(_aantalController, widget.model.aantal.toString());
    _stelTekstIn(_breedteController, widget.model.breedteMm.toString());
    _stelTekstIn(_hoogteController, widget.model.hoogteMm.toString());
  }

  void _stelTekstIn(TextEditingController controller, String tekst) {
    if (controller.text == tekst) return;
    controller.value = TextEditingValue(
      text: tekst,
      selection: TextSelection.collapsed(offset: tekst.length),
    );
  }

  List<OpmetingVoorzetscreenMotor> _motorenVoor(
    OpmetingVoorzetscreenModel model,
  ) {
    if (!model.zonnecel) return widget.instellingen.motoren;
    if (model.kastmaat == OpmetingVoorzetscreenKastmaat.mm85) {
      return const <OpmetingVoorzetscreenMotor>[];
    }
    if (model.kastmaat == OpmetingVoorzetscreenKastmaat.mm95) {
      return widget.instellingen.zonnecelMotoren
          .where((motor) => motor.merk.trim().toUpperCase() == 'BREL')
          .toList(growable: false);
    }
    return widget.instellingen.zonnecelMotoren;
  }

  String _motorIdVanModel(OpmetingVoorzetscreenModel model) {
    return <String>[
      model.motorType.trim().toLowerCase(),
      model.motorMerk.trim().toLowerCase(),
      model.motorOmschrijving.trim().toLowerCase(),
    ].join('|');
  }

  OpmetingVoorzetscreenModel _pasMotorToe(
    OpmetingVoorzetscreenModel model,
    OpmetingVoorzetscreenMotor motor,
  ) {
    return model.copyWith(
      motorType: motor.type,
      motorMerk: motor.merk,
      motorOmschrijving: motor.omschrijving,
    );
  }

  OpmetingVoorzetscreenModel _normaliseerMotorKeuze(
    OpmetingVoorzetscreenModel model,
  ) {
    var resultaat = model;
    if (!resultaat.zonnecelBeschikbaar && resultaat.zonnecel) {
      resultaat = resultaat.copyWith(zonnecel: false);
    }

    final motoren = _motorenVoor(resultaat);
    if (motoren.isEmpty) {
      return resultaat.copyWith(
        motorType: '',
        motorMerk: '',
        motorOmschrijving: '',
      );
    }

    final huidigId = _motorIdVanModel(resultaat);
    for (final motor in motoren) {
      if (motor.id == huidigId) return resultaat;
    }

    return _pasMotorToe(resultaat, motoren.first);
  }

  @override
  Widget build(BuildContext context) {
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
                  'Voorzetscreen',
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _bouwPositie(),
                    _bouwMaatvoering(),
                    _bouwKastmaat(),
                    _bouwKastvorm(),
                    _bouwScreendoek(),
                    _bouwKleur(),
                    _bouwAfmetingen(),
                    _bouwZonnecel(),
                    _bouwMotor(),
                    if (!widget.model.zonnecel) _bouwKabellengte(),
                    _bouwBediening(),
                    if (!widget.model.zonnecel) _bouwUitgangKabel(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwPositie() {
    return _SectieKaart(
      children: <Widget>[
        _CompactTekstRij(
          titel: 'Positie',
          controller: _positieController,
          onChanged: (tekst) {
            widget.onGewijzigd(widget.model.copyWith(positie: tekst));
          },
        ),
      ],
    );
  }

  Widget _bouwMaatvoering() {
    return _SectieKaart(
      titel: 'Maatvoering',
      onderschrift:
          'De gekozen meetwijze past de tekening en de maatpijlen aan.',
      children: <Widget>[
        _JaNeeRij(
          titel: 'Ingave breedte inclusief geleiders',
          waarde: widget.model.breedteInclusiefGeleiders,
          onChanged: (waarde) {
            widget.onGewijzigd(
              widget.model.copyWith(breedteInclusiefGeleiders: waarde),
            );
          },
        ),
        const SizedBox(height: 7),
        _JaNeeRij(
          titel: 'Ingave hoogte inclusief kast',
          waarde: widget.model.hoogteInclusiefKast,
          onChanged: (waarde) {
            widget.onGewijzigd(
              widget.model.copyWith(hoogteInclusiefKast: waarde),
            );
          },
        ),
      ],
    );
  }

  Widget _bouwKastmaat() {
    return _SectieKaart(
      titel: 'Kastmaat',
      children: <Widget>[
        RadioGroup<OpmetingVoorzetscreenKastmaat>(
          groupValue: widget.model.kastmaat,
          onChanged: (maat) {
            if (maat == null) return;
            widget.onGewijzigd(
              _normaliseerMotorKeuze(widget.model.metKastmaat(maat)),
            );
          },
          child: Wrap(
            spacing: 18,
            runSpacing: 8,
            children: OpmetingVoorzetscreenKastmaat.values
                .where((maat) => maat != OpmetingVoorzetscreenKastmaat.mm85)
                .map((maat) {
                  return _EenvoudigeRadioKeuze<OpmetingVoorzetscreenKastmaat>(
                    waarde: maat,
                    label: maat.label,
                  );
                })
                .toList(growable: false),
          ),
        ),
      ],
    );
  }

  Widget _bouwKastvorm() {
    return _SectieKaart(
      titel: 'Kastvorm',
      onderschrift: switch (widget.model.kastmaat) {
        OpmetingVoorzetscreenKastmaat.mm95 =>
          'Bij 95 × 95 mm is alleen de rechte kast beschikbaar.',
        OpmetingVoorzetscreenKastmaat.mm120 =>
          'Rechte kast bestaat niet in 120 × 120 mm.',
        _ => null,
      },
      children: <Widget>[
        RadioGroup<OpmetingVoorzetscreenKastvorm>(
          groupValue: widget.model.kastvorm,
          onChanged: (vorm) {
            if (vorm == null) return;
            widget.onGewijzigd(widget.model.metKastvorm(vorm));
          },
          child: Wrap(
            spacing: 18,
            runSpacing: 8,
            children: widget.model.beschikbareKastvormen
                .map((vorm) {
                  return _EenvoudigeRadioKeuze<OpmetingVoorzetscreenKastvorm>(
                    waarde: vorm,
                    label: vorm.label,
                  );
                })
                .toList(growable: false),
          ),
        ),
      ],
    );
  }

  Widget _bouwScreendoek() {
    final doeken = widget.instellingen.screendoeken;
    if (doeken.isEmpty) {
      return const _MeldingKaart(
        titel: 'Type doek',
        tekst:
            'Voeg eerst de screendoeken toe via Instellingen > Voorzetscreens.',
      );
    }

    OpmetingVoorzetscreenDoek? geselecteerd;
    for (final doek in doeken) {
      if (doek.code.trim().toUpperCase() ==
          widget.model.doekCode.trim().toUpperCase()) {
        geselecteerd = doek;
        break;
      }
    }

    return _SectieKaart(
      titel: 'Type doek',
      children: <Widget>[
        _ZoekKeuzeVeld(
          waarde: geselecteerd?.samenvatting ?? 'Kies een screendoek',
          voorloop: Container(
            width: 24,
            height: 18,
            decoration: BoxDecoration(
              color: geselecteerd == null
                  ? const Color(0xFFF3F4F6)
                  : _kleurUitHex(geselecteerd.voorzijdeHex),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _rand),
            ),
          ),
          onTap: () async {
            final doek =
                await _toonZoekbareKeuzelijst<OpmetingVoorzetscreenDoek>(
                  titel: 'Screendoek kiezen',
                  zoekHint: 'Zoek op code of kleur',
                  items: doeken,
                  labelVoor: (item) => item.samenvatting,
                  voorloopVoor: (item) => Container(
                    width: 26,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _kleurUitHex(item.voorzijdeHex),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _rand),
                    ),
                  ),
                );
            if (doek == null || !mounted) return;
            widget.onGewijzigd(
              widget.model.copyWith(
                doekCode: doek.code,
                doekKleur: doek.kleur,
                doekVoorzijdeHex: doek.voorzijdeHex,
                doekAchterzijdeHex: doek.achterzijdeHex,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _bouwKleur() {
    final kleuren = widget.instellingen.poederkleuren;
    final projectKleur = widget.projectKleur.trim();

    return _SectieKaart(
      titel: 'Kleur kast, geleiders en onderlat',
      children: <Widget>[
        RadioGroup<OpmetingVoorzetscreenKleurbron>(
          groupValue: widget.model.kleurbron,
          onChanged: (bron) {
            if (bron == null) return;
            if (bron == OpmetingVoorzetscreenKleurbron.projectKleur) {
              widget.onGewijzigd(
                widget.model.copyWith(
                  kleurbron: bron,
                  projectKleurWaarde: projectKleur,
                  kleurBenaming: '',
                  poedercode: '',
                  poederlakMogelijk: false,
                  natlakMogelijk: false,
                ),
              );
              return;
            }

            widget.onGewijzigd(widget.model.copyWith(kleurbron: bron));
          },
          child: Wrap(
            spacing: 18,
            runSpacing: 8,
            children: OpmetingVoorzetscreenKleurbron.values
                .map((bron) {
                  return _EenvoudigeRadioKeuze<OpmetingVoorzetscreenKleurbron>(
                    waarde: bron,
                    label: bron.label,
                  );
                })
                .toList(growable: false),
          ),
        ),
        const SizedBox(height: 9),
        if (widget.model.kleurbron ==
            OpmetingVoorzetscreenKleurbron.projectKleur)
          _WaardeVeld(
            waarde: projectKleur.isEmpty
                ? 'Projectkleur nog te kiezen'
                : projectKleur,
          )
        else if (kleuren.isEmpty)
          const Text(
            'Voeg eerst poederkleuren toe via Instellingen > Voorzetscreens.',
            style: TextStyle(color: _tekstGrijs, fontSize: 11),
          )
        else
          _bouwPoederZoekveld(kleuren),
      ],
    );
  }

  Widget _bouwPoederZoekveld(List<OpmetingVoorzetscreenPoederkleur> kleuren) {
    OpmetingVoorzetscreenPoederkleur? geselecteerd;
    for (final kleur in kleuren) {
      if (kleur.poedercode.trim() == widget.model.poedercode.trim() &&
          kleur.benaming.trim() == widget.model.kleurBenaming.trim()) {
        geselecteerd = kleur;
        break;
      }
    }

    return _ZoekKeuzeVeld(
      waarde: geselecteerd?.samenvatting ?? 'Zoek een poederkleur',
      voorloop: const Icon(Icons.palette_outlined, color: _groen, size: 19),
      onTap: () async {
        final kleur =
            await _toonZoekbareKeuzelijst<OpmetingVoorzetscreenPoederkleur>(
              titel: 'Poederkleur kiezen',
              zoekHint: 'Zoek op kleurbenaming of poedercode',
              items: kleuren,
              labelVoor: (item) => item.samenvatting,
              ondertitelVoor: (item) {
                final mogelijkheden = <String>[
                  if (item.poederlakMogelijk) 'Poederlak',
                  if (item.natlakMogelijk) 'Natlak',
                ];
                return mogelijkheden.isEmpty
                    ? 'Geen afwerking aangeduid'
                    : mogelijkheden.join(' · ');
              },
            );
        if (kleur == null || !mounted) return;
        widget.onGewijzigd(
          widget.model.copyWith(
            kleurbron: OpmetingVoorzetscreenKleurbron.standaardPoederlak,
            kleurBenaming: kleur.benaming,
            poedercode: kleur.poedercode,
            poederlakMogelijk: kleur.poederlakMogelijk,
            natlakMogelijk: kleur.natlakMogelijk,
          ),
        );
      },
    );
  }

  Widget _bouwAfmetingen() {
    return _SectieKaart(
      titel: 'Aantal en afmetingen',
      children: <Widget>[
        _CompactGetalRij(
          titel: 'Aantal',
          controller: _aantalController,
          eenheid: 'st.',
          onChanged: (tekst) {
            final waarde = int.tryParse(tekst);
            if (waarde == null ||
                waarde < OpmetingVoorzetscreenModel.aantalMinimum ||
                waarde > OpmetingVoorzetscreenModel.aantalMaximum) {
              return;
            }
            widget.onGewijzigd(widget.model.copyWith(aantal: waarde));
          },
        ),
        const SizedBox(height: 5),
        _CompactGetalRij(
          titel: 'Breedte',
          controller: _breedteController,
          eenheid: 'mm',
          onChanged: (tekst) {
            final waarde = int.tryParse(tekst);
            if (waarde == null ||
                waarde < OpmetingVoorzetscreenModel.breedteMinimumMm ||
                waarde > OpmetingVoorzetscreenModel.breedteMaximumMm) {
              return;
            }
            widget.onGewijzigd(widget.model.copyWith(breedteMm: waarde));
          },
        ),
        const SizedBox(height: 5),
        _CompactGetalRij(
          titel: 'Hoogte',
          controller: _hoogteController,
          eenheid: 'mm',
          onChanged: (tekst) {
            final waarde = int.tryParse(tekst);
            if (waarde == null ||
                waarde < OpmetingVoorzetscreenModel.hoogteMinimumMm ||
                waarde > OpmetingVoorzetscreenModel.hoogteMaximumMm) {
              return;
            }
            widget.onGewijzigd(widget.model.copyWith(hoogteMm: waarde));
          },
        ),
      ],
    );
  }

  Widget _bouwZonnecel() {
    final toegestaan = widget.model.zonnecelBeschikbaar;
    return _SectieKaart(
      compact: true,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Zonnecel',
                    style: TextStyle(
                      color: _tekst,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (!toegestaan)
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Text(
                        'Niet beschikbaar bij kast 85 × 85 mm.',
                        style: TextStyle(color: _tekstGrijs, fontSize: 9.5),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 45,
              height: 28,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Switch.adaptive(
                  value: toegestaan && widget.model.zonnecel,
                  activeTrackColor: _groen,
                  onChanged: toegestaan
                      ? (waarde) {
                          widget.onGewijzigd(
                            _normaliseerMotorKeuze(
                              widget.model.copyWith(zonnecel: waarde),
                            ),
                          );
                        }
                      : null,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _bouwMotor() {
    final motoren = _motorenVoor(widget.model);
    final geselecteerdId = _motorIdVanModel(widget.model);
    OpmetingVoorzetscreenMotor? geselecteerd;
    for (final motor in motoren) {
      if (motor.id == geselecteerdId) {
        geselecteerd = motor;
        break;
      }
    }

    return _SectieKaart(
      titel: 'Type motor',
      children: <Widget>[
        if (motoren.isEmpty)
          const Text(
            'Geen passende motoren beschikbaar. Controleer de motortabellen in Instellingen > Voorzetscreens.',
            style: TextStyle(color: _tekstGrijs, fontSize: 11),
          )
        else
          _ZoekKeuzeVeld(
            waarde: geselecteerd?.samenvatting ?? 'Zoek een motor',
            voorloop: const Icon(
              Icons.electrical_services_outlined,
              color: _groen,
              size: 19,
            ),
            onTap: () async {
              final motor =
                  await _toonZoekbareKeuzelijst<OpmetingVoorzetscreenMotor>(
                    titel: 'Motor kiezen',
                    zoekHint: 'Zoek op type, merk of omschrijving',
                    items: motoren,
                    labelVoor: (item) => item.omschrijving,
                    ondertitelVoor: (item) => '${item.type} · ${item.merk}',
                  );
              if (motor == null || !mounted) return;
              widget.onGewijzigd(_pasMotorToe(widget.model, motor));
            },
          ),
      ],
    );
  }

  Widget _bouwKabellengte() {
    const keuzes = <int>[2, 5, 10];
    return _SectieKaart(
      titel: 'Kabellengte',
      children: <Widget>[
        RadioGroup<int>(
          groupValue: widget.model.kabellengteMeter,
          onChanged: (meter) {
            if (meter == null) return;
            widget.onGewijzigd(widget.model.copyWith(kabellengteMeter: meter));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: keuzes
                .map((meter) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: meter == keuzes.last ? 0 : 24,
                    ),
                    child: _EenvoudigeRadioKeuze<int>(
                      waarde: meter,
                      label: '$meter m',
                    ),
                  );
                })
                .toList(growable: false),
          ),
        ),
      ],
    );
  }

  Widget _bouwBediening() {
    final bedieningen = widget.instellingen.beschikbareBedieningen;
    return _SectieKaart(
      titel: 'Bediening',
      children: <Widget>[
        if (bedieningen.isEmpty)
          const Text(
            'Voeg eerst bedieningen toe via Instellingen > Voorzetscreens.',
            style: TextStyle(color: _tekstGrijs, fontSize: 11),
          )
        else
          RadioGroup<String>(
            groupValue: widget.model.bediening.trim().isEmpty
                ? null
                : widget.model.bediening,
            onChanged: (bediening) {
              if (bediening == null) return;
              widget.onGewijzigd(widget.model.copyWith(bediening: bediening));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: bedieningen
                  .map((bediening) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: bediening == bedieningen.last ? 0 : 4,
                      ),
                      child: _EenvoudigeRadioKeuze<String>(
                        waarde: bediening,
                        label: bediening,
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
          ),
      ],
    );
  }

  Widget _bouwUitgangKabel() {
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
            widget.onGewijzigd(widget.model.copyWith(uitgangKabel: code));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (var index = 0; index < 8; index++) ...<Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _EenvoudigeRadioKeuze<String>(
                          waarde: 'C$index',
                          label: 'C$index',
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _EenvoudigeRadioKeuze<String>(
                          waarde: 'D$index',
                          label: 'D$index',
                        ),
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

  Future<void> _toonUitgangKabelInfo() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final scherm = MediaQuery.sizeOf(dialogContext);
        final breedte = scherm.width > 820 ? 760.0 : scherm.width - 32;
        final hoogte = scherm.height > 720 ? 640.0 : scherm.height - 32;

        return Dialog(
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 8, 8),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.info_outline_rounded,
                        color: _groen,
                        size: 22,
                      ),
                      const SizedBox(width: 9),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Uitgang kabel',
                              style: TextStyle(
                                color: _tekst,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Overzicht van de beschikbare kabeluitgangen',
                              style: TextStyle(
                                color: _tekstGrijs,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Sluiten',
                        onPressed: () => Navigator.of(dialogContext).pop(),
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
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    Icons.broken_image_outlined,
                                    color: _tekstGrijs,
                                    size: 38,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Afbeelding niet gevonden:\n'
                                    'assets/images/uitgang_voorzet_screens.png',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _tekstGrijs,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
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
        );
      },
    );
  }

  Future<T?> _toonZoekbareKeuzelijst<T>({
    required String titel,
    required String zoekHint,
    required List<T> items,
    required String Function(T item) labelVoor,
    String Function(T item)? ondertitelVoor,
    Widget Function(T item)? voorloopVoor,
  }) async {
    final zoekController = TextEditingController();
    var zoekterm = '';

    final resultaat = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final klein = zoekterm.trim().toLowerCase();
            final gefilterd = klein.isEmpty
                ? items
                : items
                      .where((item) {
                        final zoektekst = <String>[
                          labelVoor(item),
                          if (ondertitelVoor != null) ondertitelVoor(item),
                        ].join(' ').toLowerCase();
                        return zoektekst.contains(klein);
                      })
                      .toList(growable: false);

            final schermHoogte = MediaQuery.sizeOf(context).height;
            return SafeArea(
              child: Container(
                height: math.min(680.0, schermHoogte * 0.82),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 14, 10, 12),
                      decoration: const BoxDecoration(
                        color: _lichtGroen,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              titel,
                              style: const TextStyle(
                                color: _groen,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Sluiten',
                            onPressed: () => Navigator.pop(sheetContext),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                      child: TextField(
                        controller: zoekController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: zoekHint,
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: zoekterm.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Zoekveld wissen',
                                  onPressed: () {
                                    zoekController.clear();
                                    setModalState(() => zoekterm = '');
                                  },
                                  icon: const Icon(Icons.clear_rounded),
                                ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAF9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(11),
                            borderSide: const BorderSide(color: _rand),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(11),
                            borderSide: const BorderSide(
                              color: _groen,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onChanged: (waarde) {
                          setModalState(() => zoekterm = waarde);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${gefilterd.length} resultaten',
                        style: const TextStyle(
                          color: _tekstGrijs,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                      child: gefilterd.isEmpty
                          ? const Center(
                              child: Text(
                                'Geen resultaten gevonden.',
                                style: TextStyle(color: _tekstGrijs),
                              ),
                            )
                          : Scrollbar(
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  0,
                                  10,
                                  16,
                                ),
                                itemCount: gefilterd.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final item = gefilterd[index];
                                  final ondertitel = ondertitelVoor?.call(item);
                                  return ListTile(
                                    leading: voorloopVoor?.call(item),
                                    title: Text(
                                      labelVoor(item),
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    subtitle:
                                        ondertitel == null ||
                                            ondertitel.trim().isEmpty
                                        ? null
                                        : Text(
                                            ondertitel,
                                            style: const TextStyle(
                                              fontSize: 11,
                                            ),
                                          ),
                                    trailing: const Icon(
                                      Icons.chevron_right_rounded,
                                      color: _groen,
                                    ),
                                    onTap: () =>
                                        Navigator.pop(sheetContext, item),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    zoekController.dispose();
    return resultaat;
  }

  Color _kleurUitHex(String waarde) {
    final tekst = waarde.trim().replaceFirst('#', '');
    final getal = int.tryParse(tekst, radix: 16);
    return getal == null ? const Color(0xFFD8DADD) : Color(0xFF000000 | getal);
  }
}

class _SectieKaart extends StatelessWidget {
  const _SectieKaart({
    required this.children,
    this.titel,
    this.onderschrift,
    this.actie,
    this.compact = false,
  });

  final String? titel;
  final List<Widget> children;
  final String? onderschrift;
  final Widget? actie;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final netteTitel = titel?.trim() ?? '';
    final uitleg = onderschrift?.trim() ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
          : const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: _OpmetingVoorzetscreenRechterkolomState._rand,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (netteTitel.isNotEmpty || actie != null)
            Row(
              children: <Widget>[
                if (netteTitel.isNotEmpty)
                  Expanded(
                    child: Text(
                      netteTitel,
                      style: const TextStyle(
                        color: _OpmetingVoorzetscreenRechterkolomState._tekst,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else
                  const Spacer(),
                if (actie != null) actie!,
              ],
            ),
          if (uitleg.isNotEmpty) ...<Widget>[
            if (netteTitel.isNotEmpty) const SizedBox(height: 2),
            Text(
              uitleg,
              style: const TextStyle(
                color: _OpmetingVoorzetscreenRechterkolomState._tekstGrijs,
                fontSize: 10.5,
              ),
            ),
          ],
          if (netteTitel.isNotEmpty || uitleg.isNotEmpty || actie != null)
            const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _CompactGetalRij extends StatelessWidget {
  const _CompactGetalRij({
    required this.titel,
    required this.controller,
    required this.eenheid,
    required this.onChanged,
  });

  final String titel;
  final TextEditingController controller;
  final String eenheid;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            titel,
            style: const TextStyle(
              color: _OpmetingVoorzetscreenRechterkolomState._tekst,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          width: 112,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            textAlign: TextAlign.right,
            decoration: _compacteVeldDecoratie(suffixText: eenheid),
            onChanged: onChanged,
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
          width: 74,
          child: Text(
            titel,
            style: const TextStyle(
              color: _OpmetingVoorzetscreenRechterkolomState._tekst,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: _compacteVeldDecoratie(),
            onChanged: onChanged,
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Text(
            titel,
            style: const TextStyle(
              color: _OpmetingVoorzetscreenRechterkolomState._tekst,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        RadioGroup<bool>(
          groupValue: waarde,
          onChanged: (nieuweWaarde) {
            if (nieuweWaarde == null) return;
            onChanged(nieuweWaarde);
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _EenvoudigeRadioKeuze<bool>(waarde: true, label: 'Ja'),
              SizedBox(width: 10),
              _EenvoudigeRadioKeuze<bool>(waarde: false, label: 'Nee'),
            ],
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
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Radio<T>(
          value: waarde,
          activeColor: _OpmetingVoorzetscreenRechterkolomState._groen,
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              color: _OpmetingVoorzetscreenRechterkolomState._tekst,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ZoekKeuzeVeld extends StatelessWidget {
  const _ZoekKeuzeVeld({
    required this.waarde,
    required this.onTap,
    this.voorloop,
  });

  final String waarde;
  final VoidCallback onTap;
  final Widget? voorloop;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFCFD),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: _OpmetingVoorzetscreenRechterkolomState._rand,
          ),
        ),
        child: Row(
          children: <Widget>[
            if (voorloop != null) ...<Widget>[
              voorloop!,
              const SizedBox(width: 8),
            ] else ...<Widget>[
              const Icon(
                Icons.search_rounded,
                color: _OpmetingVoorzetscreenRechterkolomState._groen,
                size: 19,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                waarde,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.search_rounded,
              color: _OpmetingVoorzetscreenRechterkolomState._groen,
              size: 19,
            ),
          ],
        ),
      ),
    );
  }
}

class _WaardeVeld extends StatelessWidget {
  const _WaardeVeld({required this.waarde});

  final String waarde;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: _OpmetingVoorzetscreenRechterkolomState._rand,
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.color_lens_outlined,
            color: _OpmetingVoorzetscreenRechterkolomState._groen,
            size: 19,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              waarde,
              style: TextStyle(
                color: waarde == 'Projectkleur nog te kiezen'
                    ? _OpmetingVoorzetscreenRechterkolomState._tekstGrijs
                    : _OpmetingVoorzetscreenRechterkolomState._tekst,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeldingKaart extends StatelessWidget {
  const _MeldingKaart({required this.titel, required this.tekst});

  final String titel;
  final String tekst;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            titel,
            style: const TextStyle(
              color: Color(0xFF92400E),
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            tekst,
            style: const TextStyle(
              color: Color(0xFF92400E),
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _compacteVeldDecoratie({String? suffixText}) {
  return InputDecoration(
    suffixText: suffixText,
    filled: true,
    fillColor: const Color(0xFFFCFCFD),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: _OpmetingVoorzetscreenRechterkolomState._rand,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: _OpmetingVoorzetscreenRechterkolomState._groen,
      ),
    ),
  );
}
