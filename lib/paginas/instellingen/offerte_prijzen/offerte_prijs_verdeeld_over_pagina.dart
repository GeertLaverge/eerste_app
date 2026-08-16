// THIMACO-CONTROLE: PRIJS-VERDEELD-OVER-ALLES-IN-INSTELLINGEN-GROEN-20260815
// THIMACO-CONTROLE: PRIJS-VERDEELD-OVER-INSTELLINGEN-PAGINA-20260815
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../helpers/app_storage.dart';
import '../../../helpers/offerte/prijzen/offerte_artikel_prijs_data_model.dart';
import '../../../helpers/offerte/prijzen/offerte_prijs_verdeeld_over_template_model.dart';

class OffertePrijsVerdeeldOverPagina extends StatefulWidget {
  const OffertePrijsVerdeeldOverPagina({super.key});

  @override
  State<OffertePrijsVerdeeldOverPagina> createState() =>
      _OffertePrijsVerdeeldOverPaginaState();
}

class _OffertePrijsVerdeeldOverPaginaState
    extends State<OffertePrijsVerdeeldOverPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);
  static const Color _rood = Color(0xFFDC2626);

  List<OffertePrijsVerdeeldOverTemplateModel> _templates =
      <OffertePrijsVerdeeldOverTemplateModel>[];
  bool _laden = true;
  bool _opslaan = false;
  String? _foutmelding;

  @override
  void initState() {
    super.initState();
    _laad();
  }

  Future<void> _laad() async {
    try {
      final templates =
          await AppStorage.laadOffertePrijsVerdeeldOverTemplates();
      templates.sort(_vergelijkTemplates);
      if (!mounted) {
        return;
      }
      setState(() {
        _templates = templates;
        _laden = false;
        _foutmelding = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _laden = false;
        _foutmelding = 'De instellingen konden niet worden geladen: $e';
      });
    }
  }

  static int _vergelijkTemplates(
    OffertePrijsVerdeeldOverTemplateModel eerste,
    OffertePrijsVerdeeldOverTemplateModel tweede,
  ) {
    final volgorde = eerste.volgorde.compareTo(tweede.volgorde);
    if (volgorde != 0) {
      return volgorde;
    }
    return eerste.omschrijving.toLowerCase().compareTo(
      tweede.omschrijving.toLowerCase(),
    );
  }

  Future<bool> _bewaar(
    List<OffertePrijsVerdeeldOverTemplateModel> nieuweTemplates,
  ) async {
    if (_opslaan) {
      return false;
    }
    setState(() => _opslaan = true);
    try {
      await AppStorage.bewaarOffertePrijsVerdeeldOverTemplates(nieuweTemplates);
      if (!mounted) {
        return true;
      }
      setState(() {
        _templates = List<OffertePrijsVerdeeldOverTemplateModel>.from(
          nieuweTemplates,
        )..sort(_vergelijkTemplates);
      });
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: _rood,
            content: Text('Bewaren mislukt: $e'),
          ),
        );
      }
      return false;
    } finally {
      if (mounted) {
        setState(() => _opslaan = false);
      }
    }
  }

  Future<void> _voegToe() async {
    final volgendeVolgorde = _templates.isEmpty
        ? 10
        : _templates.map((e) => e.volgorde).reduce((a, b) => a > b ? a : b) +
              10;
    final nieuw = await _toonTemplateDialog(
      begin: OffertePrijsVerdeeldOverTemplateModel(
        id: 'prijs_verdeeld_over_${DateTime.now().microsecondsSinceEpoch}',
        omschrijving: '',
        type: OffertePrijsPerPositieType.aankoop,
        teVerdelenBedragExclBtw: 0,
        maximaalTotaalExclBtw: 0,
        formulierTypes: const <String>{},
        standaardWinstPercentage: 0,
        offerteWeergave: OffertePrijsPerPositieWeergave.uit,
        volgorde: volgendeVolgorde,
      ),
      nieuw: true,
    );
    if (nieuw == null) {
      return;
    }
    await _bewaar(<OffertePrijsVerdeeldOverTemplateModel>[
      ..._templates,
      nieuw,
    ]);
  }

  Future<void> _wijzig(OffertePrijsVerdeeldOverTemplateModel template) async {
    final gewijzigd = await _toonTemplateDialog(begin: template, nieuw: false);
    if (gewijzigd == null) {
      return;
    }
    await _bewaar(
      _templates
          .map((item) => item.id == template.id ? gewijzigd : item)
          .toList(growable: false),
    );
  }

  Future<void> _verwijder(
    OffertePrijsVerdeeldOverTemplateModel template,
  ) async {
    final bevestigd = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Verdeelregel verwijderen?',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text(
          '“${template.omschrijving}” wordt uit de centrale instellingen verwijderd. '
          'Bij de volgende berekening wordt deze automatische verdeelkost ook uit offertes verwijderd.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _rood),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Verwijderen'),
          ),
        ],
      ),
    );
    if (bevestigd != true) {
      return;
    }
    await _bewaar(
      _templates
          .where((item) => item.id != template.id)
          .toList(growable: false),
    );
  }

  Future<void> _verplaats(
    OffertePrijsVerdeeldOverTemplateModel item,
    int richting,
  ) async {
    final lijst = List<OffertePrijsVerdeeldOverTemplateModel>.from(_templates)
      ..sort(_vergelijkTemplates);
    final index = lijst.indexWhere((e) => e.id == item.id);
    final nieuwIndex = index + richting;
    if (index < 0 || nieuwIndex < 0 || nieuwIndex >= lijst.length) {
      return;
    }

    final verplaatst = lijst.removeAt(index);
    lijst.insert(nieuwIndex, verplaatst);
    final nu = DateTime.now().toUtc().toIso8601String();
    final hernummerd = List<OffertePrijsVerdeeldOverTemplateModel>.generate(
      lijst.length,
      (i) => lijst[i].copyWith(
        volgorde: (i + 1) * 10,
        gewijzigdOp: lijst[i].id == item.id ? nu : lijst[i].gewijzigdOp,
      ),
      growable: false,
    );
    setState(() => _templates = hernummerd);
    if (!await _bewaar(hernummerd)) {
      await _laad();
    }
  }

  Future<OffertePrijsVerdeeldOverTemplateModel?> _toonTemplateDialog({
    required OffertePrijsVerdeeldOverTemplateModel begin,
    required bool nieuw,
  }) async {
    final omschrijvingController = TextEditingController(
      text: begin.omschrijving,
    );
    final bedragController = TextEditingController(
      text: begin.veiligTeVerdelenBedragExclBtw <= 0
          ? ''
          : _getal(begin.veiligTeVerdelenBedragExclBtw),
    );
    final maximumController = TextEditingController(
      text: begin.veiligMaximaalTotaalExclBtw <= 0
          ? ''
          : _getal(begin.veiligMaximaalTotaalExclBtw),
    );
    final winstController = TextEditingController(
      text: begin.veiligeStandaardWinstPercentage <= 0
          ? ''
          : _getal(begin.veiligeStandaardWinstPercentage),
    );
    var type = begin.type;
    var offerteWeergave = begin.offerteWeergave;
    final gekozenTypes = <String>{...begin.formulierTypes};

    try {
      return await showDialog<OffertePrijsVerdeeldOverTemplateModel>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFCDE9D5)),
                ),
                titlePadding: EdgeInsets.zero,
                title: Container(
                  padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
                  decoration: const BoxDecoration(
                    color: _groen,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.call_split_rounded, color: Colors.white),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          nieuw
                              ? 'Verdeelregel toevoegen'
                              : 'Verdeelregel wijzigen',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                content: SizedBox(
                  width: 760,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 680),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _lichtGroen,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFCDE9D5),
                              ),
                            ),
                            child: const Text(
                              'Deze regel wordt volledig automatisch toegepast. Het grensbedrag is het gezamenlijke '
                              'offertetotaal excl. btw van de aangevinkte fichetypes vóór deze verdeelkost. '
                              'Laat “Toepassen tot” leeg voor geen maximum.',
                              style: TextStyle(
                                color: _tekstDonker,
                                fontSize: 11.5,
                                height: 1.4,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: omschrijvingController,
                            autofocus: nieuw,
                            maxLength: 80,
                            decoration: _invoerDecoratie(
                              label: 'Omschrijving',
                              hint: 'Bijvoorbeeld Transportkosten',
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child:
                                    DropdownButtonFormField<
                                      OffertePrijsPerPositieType
                                    >(
                                      initialValue: type,
                                      decoration: _invoerDecoratie(
                                        label: 'A / V',
                                      ),
                                      items: OffertePrijsPerPositieType.values
                                          .map(
                                            (waarde) => DropdownMenuItem(
                                              value: waarde,
                                              child: Text(
                                                waarde.isAankoop
                                                    ? 'A — aankoopkost'
                                                    : 'V — verkoopbedrag',
                                              ),
                                            ),
                                          )
                                          .toList(growable: false),
                                      onChanged: (waarde) {
                                        if (waarde == null) {
                                          return;
                                        }
                                        setDialogState(() {
                                          type = waarde;
                                          if (type.isVerkoop) {
                                            winstController.clear();
                                          }
                                        });
                                      },
                                    ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  controller: bedragController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9,.]'),
                                    ),
                                  ],
                                  decoration: _invoerDecoratie(
                                    label: 'Te verdelen bedrag excl. btw',
                                    prefix: '€ ',
                                  ),
                                ),
                              ),
                              if (type.isAankoop) ...<Widget>[
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: winstController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9,.]'),
                                      ),
                                    ],
                                    decoration: _invoerDecoratie(
                                      label: 'Winstmarge',
                                      suffix: '%',
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: TextField(
                                  controller: maximumController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9,.]'),
                                    ),
                                  ],
                                  decoration: _invoerDecoratie(
                                    label: 'Toepassen tot totaal excl. btw',
                                    hint: 'Leeg = geen maximum',
                                    prefix: '€ ',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child:
                                    DropdownButtonFormField<
                                      OffertePrijsPerPositieWeergave
                                    >(
                                      initialValue: offerteWeergave,
                                      decoration: _invoerDecoratie(
                                        label: 'Zichtbaarheid op offerte',
                                      ),
                                      items:
                                          const <
                                                OffertePrijsPerPositieWeergave
                                              >[
                                                OffertePrijsPerPositieWeergave
                                                    .uit,
                                                OffertePrijsPerPositieWeergave
                                                    .tekst,
                                                OffertePrijsPerPositieWeergave
                                                    .prijs,
                                              ]
                                              .map(
                                                (waarde) => DropdownMenuItem(
                                                  value: waarde,
                                                  child: Text(
                                                    _weergaveTekst(waarde),
                                                  ),
                                                ),
                                              )
                                              .toList(growable: false),
                                      onChanged: (waarde) {
                                        if (waarde == null) {
                                          return;
                                        }
                                        setDialogState(
                                          () => offerteWeergave = waarde,
                                        );
                                      },
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FBF9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFB9E1C6),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    const Expanded(
                                      child: Text(
                                        'Verdelen over deze fiches',
                                        style: TextStyle(
                                          color: _groen,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setDialogState(() {
                                          gekozenTypes
                                            ..clear()
                                            ..addAll(
                                              OffertePrijsVerdeeldOverFicheType
                                                  .alle
                                                  .map((item) => item.id),
                                            );
                                        });
                                      },
                                      child: const Text('Alles'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setDialogState(gekozenTypes.clear);
                                      },
                                      child: const Text('Geen'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final breedte = constraints.maxWidth >= 640
                                        ? (constraints.maxWidth - 8) / 2
                                        : constraints.maxWidth;
                                    return Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children:
                                          OffertePrijsVerdeeldOverFicheType.alle
                                              .map((fiche) {
                                                final gekozen = gekozenTypes
                                                    .contains(fiche.id);
                                                return SizedBox(
                                                  width: breedte,
                                                  child: CheckboxListTile(
                                                    value: gekozen,
                                                    dense: true,
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    activeColor: _groen,
                                                    controlAffinity:
                                                        ListTileControlAffinity
                                                            .leading,
                                                    title: Text(
                                                      fiche.label,
                                                      style: TextStyle(
                                                        color: gekozen
                                                            ? _groen
                                                            : _tekstDonker,
                                                        fontSize: 11.5,
                                                        fontWeight: gekozen
                                                            ? FontWeight.w800
                                                            : FontWeight.w600,
                                                      ),
                                                    ),
                                                    onChanged: (waarde) {
                                                      setDialogState(() {
                                                        if (waarde == true) {
                                                          gekozenTypes.add(
                                                            fiche.id,
                                                          );
                                                        } else {
                                                          gekozenTypes.remove(
                                                            fiche.id,
                                                          );
                                                        }
                                                      });
                                                    },
                                                  ),
                                                );
                                              })
                                              .toList(growable: false),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Annuleren'),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: _groen),
                    onPressed: () {
                      final omschrijving = omschrijvingController.text.trim();
                      final bedrag = _leesBedrag(bedragController.text);
                      final maximum = _leesBedrag(maximumController.text);
                      if (omschrijving.isEmpty) {
                        _toonDialogFout('Vul een omschrijving in.');
                        return;
                      }
                      if (bedrag <= 0.0) {
                        _toonDialogFout('Vul het te verdelen bedrag in.');
                        return;
                      }
                      if (gekozenTypes.isEmpty) {
                        _toonDialogFout(
                          'Kies minstens één fiche waarop de regel van toepassing is.',
                        );
                        return;
                      }

                      Navigator.pop(
                        dialogContext,
                        begin.copyWith(
                          omschrijving: omschrijving,
                          type: type,
                          teVerdelenBedragExclBtw: bedrag,
                          maximaalTotaalExclBtw: maximum,
                          formulierTypes: gekozenTypes,
                          standaardWinstPercentage: type.isAankoop
                              ? _leesPercentage(winstController.text)
                              : 0.0,
                          offerteWeergave: offerteWeergave,
                          gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Bewaren'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      omschrijvingController.dispose();
      bedragController.dispose();
      maximumController.dispose();
      winstController.dispose();
    }
  }

  void _toonDialogFout(String tekst) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(backgroundColor: _rood, content: Text(tekst)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _achtergrond,
      appBar: AppBar(
        title: const Text(
          'Prijzen verdeeld over…',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: _groen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: <Widget>[
          if (_opslaan)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _laden || _opslaan ? null : _voegToe,
        backgroundColor: _groen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nieuwe verdeelregel'),
      ),
      body: _bouwInhoud(),
    );
  }

  Widget _bouwInhoud() {
    if (_laden) {
      return const Center(child: CircularProgressIndicator(color: _groen));
    }
    if (_foutmelding != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_foutmelding!, style: const TextStyle(color: _rood)),
        ),
      );
    }

    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: _lichtGroen,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFB9E1C6)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.auto_awesome_rounded, color: _groen, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Alles wordt hier ingesteld: fichetypes, te verdelen bedrag, winstmarge, '
                      'zichtbaarheid en het maximum totaal excl. btw. In het opmetingsoverzicht '
                      'verschijnt geen aparte bediening meer; de kost wordt automatisch toegepast.',
                      style: TextStyle(
                        color: _tekstDonker,
                        fontSize: 12.5,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (_templates.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _rand),
                ),
                child: const Text(
                  'Nog geen verdeelregels. Voeg bijvoorbeeld “Transportkosten” toe.',
                  style: TextStyle(
                    color: _tekstGrijs,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              ...List<Widget>.generate(_templates.length, (index) {
                final template = _templates[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: _bouwTemplateKaart(template, index),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _bouwTemplateKaart(
    OffertePrijsVerdeeldOverTemplateModel template,
    int index,
  ) {
    final types = template.formulierTypes.toList(growable: false)
      ..sort(
        (a, b) => OffertePrijsVerdeeldOverFicheType.labelVoor(
          a,
        ).compareTo(OffertePrijsVerdeeldOverFicheType.labelVoor(b)),
      );
    final typeTekst = types.isEmpty
        ? 'Nog geen fiches gekozen'
        : types.length == OffertePrijsVerdeeldOverFicheType.alle.length
        ? 'Alle fiches'
        : types.map(OffertePrijsVerdeeldOverFicheType.labelVoor).join(' · ');
    final maximumTekst = template.heeftMaximumTotaal
        ? 'tot ${_euro(template.veiligMaximaalTotaalExclBtw)} excl. btw'
        : 'geen maximum';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: template.isAutomatischGeldig ? const Color(0xFFB9E1C6) : _rand,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _lichtGroen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              template.type.label,
              style: const TextStyle(
                color: _groen,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        template.omschrijving,
                        style: const TextStyle(
                          color: _tekstDonker,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (!template.isAutomatischGeldig)
                      const Text(
                        'Nog in te stellen',
                        style: TextStyle(
                          color: _rood,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Verdelen ${_euro(template.veiligTeVerdelenBedragExclBtw)} · $maximumTekst'
                  '${template.isAankoop && template.veiligeStandaardWinstPercentage > 0 ? ' · winst ${_getal(template.veiligeStandaardWinstPercentage)} %' : ''}'
                  ' · ${_weergaveTekst(template.offerteWeergave)}',
                  style: const TextStyle(
                    color: _groen,
                    fontSize: 10.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  typeTekst,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _tekstGrijs,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Omhoog',
            onPressed: index == 0 || _opslaan
                ? null
                : () => _verplaats(template, -1),
            icon: const Icon(Icons.keyboard_arrow_up_rounded),
          ),
          IconButton(
            tooltip: 'Omlaag',
            onPressed: index == _templates.length - 1 || _opslaan
                ? null
                : () => _verplaats(template, 1),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
          IconButton(
            tooltip: 'Wijzigen',
            onPressed: _opslaan ? null : () => _wijzig(template),
            icon: const Icon(Icons.edit_outlined, color: _groen),
          ),
          IconButton(
            tooltip: 'Verwijderen',
            onPressed: _opslaan ? null : () => _verwijder(template),
            icon: const Icon(Icons.delete_outline_rounded),
            color: _rood,
          ),
        ],
      ),
    );
  }

  static InputDecoration _invoerDecoratie({
    required String label,
    String? hint,
    String? prefix,
    String? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefix,
      suffixText: suffix,
      counterText: '',
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: _rand),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: _groen, width: 1.5),
      ),
    );
  }

  static String _weergaveTekst(OffertePrijsPerPositieWeergave waarde) {
    return switch (waarde) {
      OffertePrijsPerPositieWeergave.uit => 'Alleen intern',
      OffertePrijsPerPositieWeergave.tekst => 'Omschrijving op offerte',
      OffertePrijsPerPositieWeergave.prijs => 'Omschrijving + prijs op offerte',
    };
  }

  static double _leesBedrag(String tekst) {
    final waarde = double.tryParse(tekst.trim().replaceAll(',', '.')) ?? 0.0;
    if (!waarde.isFinite || waarde <= 0.0) {
      return 0.0;
    }
    return (waarde * 100.0).roundToDouble() / 100.0;
  }

  static double _leesPercentage(String tekst) {
    final waarde = double.tryParse(tekst.trim().replaceAll(',', '.')) ?? 0.0;
    if (!waarde.isFinite || waarde <= 0.0) {
      return 0.0;
    }
    if (waarde >= 500.0) {
      return 500.0;
    }
    return (waarde * 100.0).roundToDouble() / 100.0;
  }

  static String _getal(double waarde) {
    final afgerond = (waarde * 100).roundToDouble() / 100;
    if (afgerond == afgerond.roundToDouble()) {
      return afgerond.toInt().toString();
    }
    return afgerond.toStringAsFixed(2).replaceAll('.', ',');
  }

  static String _euro(double waarde) {
    return '€ ${waarde.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}
