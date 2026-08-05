// THIMACO-CONTROLE: VOORZETROLLUIK-DOWNLOADSIGNAAL-FASE12-20260805
// THIMACO-CONTROLE: INSTELLINGEN-VOORZETROLLUIKEN-NIEUWE-LAMELLEN-GROENE-DIALOGEN-20260731-1105
import 'package:flutter/material.dart';

import '../../../helpers/app_storage.dart';
import '../../../helpers/opmeting/toebehoren/voorzetrolluik/opmeting_voorzetrolluik_instellingen_model.dart';
import '../../../helpers/opmeting/toebehoren/voorzetrolluik/opmeting_voorzetrolluik_kastmaat_helper.dart';
import '../../../helpers/sync/sync_navigatie_helper.dart';

class OpmetingVoorzetrolluikInstellingenPagina extends StatefulWidget {
  const OpmetingVoorzetrolluikInstellingenPagina({super.key});

  @override
  State<OpmetingVoorzetrolluikInstellingenPagina> createState() {
    return _OpmetingVoorzetrolluikInstellingenPaginaState();
  }
}

class _OpmetingVoorzetrolluikInstellingenPaginaState
    extends State<OpmetingVoorzetrolluikInstellingenPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekst = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  bool _laden = true;
  bool _bewaren = false;
  bool _lokaleWijzigingen = false;
  bool _downloadHerladenUitgesteld = false;
  bool _herladenNaSync = false;
  bool _nogmaalsHerladenNaSync = false;
  int _laatsteVerwerkteDownloadVersie = 0;
  List<OpmetingVoorzetrolluikLamelkleur> _lamelkleuren =
      <OpmetingVoorzetrolluikLamelkleur>[];
  List<OpmetingVoorzetrolluikMotor> _motoren = <OpmetingVoorzetrolluikMotor>[];
  List<OpmetingVoorzetrolluikMotor> _zonnecelMotoren =
      <OpmetingVoorzetrolluikMotor>[];
  List<String> _geleiderTypes = <String>[];

  @override
  void initState() {
    super.initState();

    _laatsteVerwerkteDownloadVersie = SyncNavigatieHelper.downloadVersie.value;
    SyncNavigatieHelper.downloadVersie.addListener(_verwerkAchtergrondDownload);

    _laad();
  }

  @override
  void dispose() {
    SyncNavigatieHelper.downloadVersie.removeListener(
      _verwerkAchtergrondDownload,
    );
    super.dispose();
  }

  void _verwerkAchtergrondDownload() {
    final nieuweVersie = SyncNavigatieHelper.downloadVersie.value;

    if (nieuweVersie <= _laatsteVerwerkteDownloadVersie) {
      return;
    }

    _laatsteVerwerkteDownloadVersie = nieuweVersie;

    if (_lokaleWijzigingen || _bewaren) {
      _downloadHerladenUitgesteld = true;
      _toonNieuweCloudversieMelding();
      return;
    }

    _herlaadNaSync();
  }

  void _toonNieuweCloudversieMelding() {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Er zijn nieuwere Voorzetrolluik-instellingen ontvangen. '
          'Je niet-opgeslagen wijzigingen blijven behouden.',
        ),
      ),
    );
  }

  Future<void> _herlaadNaSync() async {
    if (_herladenNaSync) {
      _nogmaalsHerladenNaSync = true;
      return;
    }

    _herladenNaSync = true;

    try {
      do {
        _nogmaalsHerladenNaSync = false;
        await _laad(toonLaden: false);
      } while (_nogmaalsHerladenNaSync && mounted);
    } finally {
      _herladenNaSync = false;
    }
  }

  Future<void> _laad({bool toonLaden = true}) async {
    if (toonLaden && mounted) {
      setState(() => _laden = true);
    }

    final instellingen =
        await AppStorage.laadOpmetingVoorzetrolluikInstellingen();
    if (!mounted) return;

    setState(() {
      _lamelkleuren = List<OpmetingVoorzetrolluikLamelkleur>.from(
        instellingen.lamelkleuren,
      );
      _motoren = List<OpmetingVoorzetrolluikMotor>.from(instellingen.motoren);
      _zonnecelMotoren = List<OpmetingVoorzetrolluikMotor>.from(
        instellingen.zonnecelMotoren,
      );
      _geleiderTypes = List<String>.from(instellingen.geleiderTypes);
      _laden = false;
      _lokaleWijzigingen = false;
      _downloadHerladenUitgesteld = false;
    });
  }

  void _markeerGewijzigd() {
    _lokaleWijzigingen = true;
  }

  Future<void> _bewaar() async {
    if (_bewaren) return;
    setState(() => _bewaren = true);
    try {
      await AppStorage.bewaarOpmetingVoorzetrolluikInstellingen(
        OpmetingVoorzetrolluikInstellingen(
          lamelkleuren: _lamelkleuren,
          motoren: _motoren,
          zonnecelMotoren: _zonnecelMotoren,
          geleiderTypes: _geleiderTypes,
        ),
      );
      if (!mounted) return;
      setState(() => _lokaleWijzigingen = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: _groen,
          content: Text('Instellingen voor Voorzetrolluiken bewaard.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _bewaren = false);
    }

    if (_downloadHerladenUitgesteld && mounted && !_lokaleWijzigingen) {
      _downloadHerladenUitgesteld = false;
      await _herlaadNaSync();
    }
  }

  void _herstelStandaardlijsten() {
    setState(() {
      _lamelkleuren = List<OpmetingVoorzetrolluikLamelkleur>.from(
        OpmetingVoorzetrolluikInstellingen.standaardLamelkleuren,
      );
      _motoren = List<OpmetingVoorzetrolluikMotor>.from(
        OpmetingVoorzetrolluikInstellingen.standaardMotoren,
      );
      _zonnecelMotoren = List<OpmetingVoorzetrolluikMotor>.from(
        OpmetingVoorzetrolluikInstellingen.standaardZonnecelMotoren,
      );
      _geleiderTypes = List<String>.from(
        OpmetingVoorzetrolluikInstellingen.standaardGeleiderTypes,
      );
      _markeerGewijzigd();
    });
  }

  Future<void> _voegLamelkleurToe() async {
    final kleur = await _toonLamelkleurDialoog();
    if (kleur == null) return;
    setState(() {
      _lamelkleuren.removeWhere((item) => item.id == kleur.id);
      _lamelkleuren.add(kleur);
      _markeerGewijzigd();
    });
  }

  Future<void> _bewerkLamelkleur(
    int index,
    OpmetingVoorzetrolluikLamelkleur kleur,
  ) async {
    final gewijzigd = await _toonLamelkleurDialoog(bestaand: kleur);
    if (gewijzigd == null) return;
    setState(() {
      _lamelkleuren[index] = gewijzigd;
      _markeerGewijzigd();
    });
  }

  Future<OpmetingVoorzetrolluikLamelkleur?> _toonLamelkleurDialoog({
    OpmetingVoorzetrolluikLamelkleur? bestaand,
  }) async {
    final naam = TextEditingController(text: bestaand?.naam ?? '');
    final code = TextEditingController(text: bestaand?.code ?? '');
    final hex = TextEditingController(text: bestaand?.hexKleur ?? '#D1D5DB');
    try {
      return await showDialog<OpmetingVoorzetrolluikLamelkleur>(
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
              title: Text(
                bestaand == null
                    ? 'Kleur lamellen toevoegen'
                    : 'Kleur wijzigen',
                style: const TextStyle(
                  color: _groen,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: SizedBox(
                width: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: naam,
                      decoration: _decoratie(
                        label: 'Benaming',
                        hint: 'bv. Antracietgrijs 09',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: code,
                      decoration: _decoratie(
                        label: 'Kleurcode',
                        hint: 'bv. +/-7016',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: hex,
                      textCapitalization: TextCapitalization.characters,
                      decoration: _decoratie(
                        label: 'Kleur tekening',
                        hint: '#383E42',
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Annuleren'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: _groen),
                  onPressed: () {
                    final resultaat = OpmetingVoorzetrolluikLamelkleur(
                      naam: naam.text.trim(),
                      code: code.text.trim(),
                      hexKleur: hex.text.trim(),
                    ).copyWith();
                    if (resultaat.naam.isEmpty) return;
                    Navigator.pop(dialogContext, resultaat);
                  },
                  child: const Text('Bewaren'),
                ),
              ],
            ),
          );
        },
      );
    } finally {
      naam.dispose();
      code.dispose();
      hex.dispose();
    }
  }

  Future<void> _voegMotorToe({required bool zonnecel}) async {
    final motor = await _toonMotorDialoog();
    if (motor == null) return;
    setState(() {
      final lijst = zonnecel ? _zonnecelMotoren : _motoren;
      lijst.removeWhere((item) => item.id == motor.id);
      lijst.add(motor);
      _markeerGewijzigd();
    });
  }

  Future<void> _bewerkMotor({
    required bool zonnecel,
    required int index,
    required OpmetingVoorzetrolluikMotor motor,
  }) async {
    final gewijzigd = await _toonMotorDialoog(bestaand: motor);
    if (gewijzigd == null) return;
    setState(() {
      final lijst = zonnecel ? _zonnecelMotoren : _motoren;
      lijst[index] = gewijzigd;
      _markeerGewijzigd();
    });
  }

  Future<OpmetingVoorzetrolluikMotor?> _toonMotorDialoog({
    OpmetingVoorzetrolluikMotor? bestaand,
  }) async {
    final type = TextEditingController(text: bestaand?.type ?? '');
    final merk = TextEditingController(text: bestaand?.merk ?? '');
    final omschrijving = TextEditingController(
      text: bestaand?.omschrijving ?? '',
    );
    final extra = TextEditingController(text: bestaand?.extraInfo ?? '');
    try {
      return await showDialog<OpmetingVoorzetrolluikMotor>(
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
              title: Text(
                bestaand == null ? 'Motor toevoegen' : 'Motor wijzigen',
                style: const TextStyle(
                  color: _groen,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: type,
                      decoration: _decoratie(
                        label: 'Type',
                        hint: 'Bekabeld of Draadloos',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: merk,
                      textCapitalization: TextCapitalization.characters,
                      decoration: _decoratie(label: 'Merk'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: omschrijving,
                      decoration: _decoratie(label: 'Omschrijving'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: extra,
                      decoration: _decoratie(
                        label: 'Extra info',
                        hint: 'optioneel, bv. Te bestellen',
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Annuleren'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: _groen),
                  onPressed: () {
                    final resultaat = OpmetingVoorzetrolluikMotor(
                      type: type.text.trim(),
                      merk: merk.text.trim(),
                      omschrijving: omschrijving.text.trim(),
                      extraInfo: extra.text.trim(),
                    );
                    if (resultaat.omschrijving.isEmpty) return;
                    Navigator.pop(dialogContext, resultaat);
                  },
                  child: const Text('Bewaren'),
                ),
              ],
            ),
          );
        },
      );
    } finally {
      type.dispose();
      merk.dispose();
      omschrijving.dispose();
      extra.dispose();
    }
  }

  Future<void> _voegGeleiderTypeToe() async {
    final waarde = await _toonTekstDialoog(
      titel: 'Geleider toevoegen',
      label: 'Type geleider',
    );
    if (waarde == null) return;
    setState(() {
      _geleiderTypes.removeWhere(
        (item) => item.trim().toLowerCase() == waarde.toLowerCase(),
      );
      _geleiderTypes.add(waarde);
      _markeerGewijzigd();
    });
  }

  Future<void> _bewerkGeleiderType(int index) async {
    final waarde = await _toonTekstDialoog(
      titel: 'Geleider wijzigen',
      label: 'Type geleider',
      beginWaarde: _geleiderTypes[index],
    );
    if (waarde == null) return;
    setState(() {
      _geleiderTypes[index] = waarde;
      _markeerGewijzigd();
    });
  }

  Future<String?> _toonTekstDialoog({
    required String titel,
    required String label,
    String beginWaarde = '',
  }) async {
    final controller = TextEditingController(text: beginWaarde);
    try {
      return await showDialog<String>(
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
              title: Text(
                titel,
                style: const TextStyle(
                  color: _groen,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: SizedBox(
                width: 420,
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  decoration: _decoratie(label: label),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Annuleren'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: _groen),
                  onPressed: () {
                    final waarde = controller.text.trim();
                    if (waarde.isEmpty) return;
                    Navigator.pop(dialogContext, waarde);
                  },
                  child: const Text('Bewaren'),
                ),
              ],
            ),
          );
        },
      );
    } finally {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _achtergrond,
      appBar: AppBar(
        backgroundColor: _groen,
        foregroundColor: Colors.white,
        title: const Text(
          'Voorzetrolluiken',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: <Widget>[
          TextButton.icon(
            onPressed: _laden || _bewaren ? null : _herstelStandaardlijsten,
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('Standaard'),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilledButton.icon(
              onPressed: _laden || _bewaren ? null : _bewaar,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _groen,
              ),
              icon: _bewaren
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _groen,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text('Bewaren'),
            ),
          ),
        ],
      ),
      body: _laden
          ? const Center(child: CircularProgressIndicator(color: _groen))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                _InfoKaart(
                  titel: 'Gedeelde poederkleuren',
                  tekst:
                      'De poederkleuren voor kast, geleiders en onderlat worden '
                      'gedeeld met Voorzetscreens. Beheer deze lijst via '
                      'Instellingen → Voorzetscreens.',
                ),
                const SizedBox(height: 14),
                _bouwKastmaatTabelSectie(),
                const SizedBox(height: 14),
                _bouwLamelkleurenSectie(),
                const SizedBox(height: 14),
                _bouwGeleiderTypesSectie(),
                const SizedBox(height: 14),
                _bouwMotorenSectie(
                  titel: 'Motoren',
                  subtitel: 'Motoren zonder zonnecel',
                  zonnecel: false,
                  lijst: _motoren,
                ),
                const SizedBox(height: 14),
                _bouwMotorenSectie(
                  titel: 'Motoren met zonnecel',
                  subtitel: 'Afzonderlijke lijst voor solaruitvoeringen',
                  zonnecel: true,
                  lijst: _zonnecelMotoren,
                ),
                const SizedBox(height: 30),
              ],
            ),
    );
  }

  Widget _bouwKastmaatTabelSectie() {
    return const _InstellingenSectie(
      titel: 'Kasthoogte bepalen',
      subtitel:
          'Kastmaat volgens lameltype, rolluikhoogte en asdiameter. Lint gebruikt as 40 mm; elektrisch gebruikt as 60 of 70 mm.',
      child: _KastmaatTabel(),
    );
  }

  Widget _bouwGeleiderTypesSectie() {
    return _InstellingenSectie(
      titel: 'Keuze geleiders',
      subtitel: '${_geleiderTypes.length} types',
      onToevoegen: _voegGeleiderTypeToe,
      child: _geleiderTypes.isEmpty
          ? const _LegeLijstMelding(tekst: 'Nog geen geleiders toegevoegd.')
          : Column(
              children: List<Widget>.generate(_geleiderTypes.length, (index) {
                final waarde = _geleiderTypes[index];
                return _LijstRij(
                  leading: const Icon(
                    Icons.view_column_outlined,
                    color: _groen,
                  ),
                  titel: waarde,
                  subtitel: waarde == 'HTF25'
                      ? 'Standaardkeuze op de opmeetfiche'
                      : 'Beschikbaar op de opmeetfiche',
                  onBewerken: () => _bewerkGeleiderType(index),
                  onVerwijderen: () {
                    setState(() {
                      _geleiderTypes.removeAt(index);
                      _markeerGewijzigd();
                    });
                  },
                );
              }),
            ),
    );
  }

  Widget _bouwLamelkleurenSectie() {
    return _InstellingenSectie(
      titel: 'Kleur lamellen',
      subtitel: '${_lamelkleuren.length} kleuren',
      onToevoegen: _voegLamelkleurToe,
      child: _lamelkleuren.isEmpty
          ? const _LegeLijstMelding(tekst: 'Nog geen lamelkleuren toegevoegd.')
          : Column(
              children: List<Widget>.generate(_lamelkleuren.length, (index) {
                final kleur = _lamelkleuren[index];
                return _LijstRij(
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _kleurUitHex(kleur.hexKleur),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: _rand),
                    ),
                  ),
                  titel: kleur.naam,
                  subtitel: kleur.code.trim().isEmpty
                      ? kleur.hexKleur
                      : '${kleur.code} · ${kleur.hexKleur}',
                  onBewerken: () => _bewerkLamelkleur(index, kleur),
                  onVerwijderen: () {
                    setState(() {
                      _lamelkleuren.removeAt(index);
                      _markeerGewijzigd();
                    });
                  },
                );
              }),
            ),
    );
  }

  Widget _bouwMotorenSectie({
    required String titel,
    required String subtitel,
    required bool zonnecel,
    required List<OpmetingVoorzetrolluikMotor> lijst,
  }) {
    return _InstellingenSectie(
      titel: titel,
      subtitel: '$subtitel · ${lijst.length} motoren',
      onToevoegen: () => _voegMotorToe(zonnecel: zonnecel),
      child: lijst.isEmpty
          ? const _LegeLijstMelding(tekst: 'Nog geen motoren toegevoegd.')
          : Column(
              children: List<Widget>.generate(lijst.length, (index) {
                final motor = lijst[index];
                return _LijstRij(
                  leading: Icon(
                    zonnecel ? Icons.solar_power_outlined : Icons.cable_rounded,
                    color: _groen,
                  ),
                  titel: '${motor.type} · ${motor.merk}',
                  subtitel: <String>[
                    motor.omschrijving,
                    motor.extraInfo,
                  ].where((deel) => deel.trim().isNotEmpty).join(' · '),
                  onBewerken: () => _bewerkMotor(
                    zonnecel: zonnecel,
                    index: index,
                    motor: motor,
                  ),
                  onVerwijderen: () {
                    setState(() {
                      lijst.removeAt(index);
                      _markeerGewijzigd();
                    });
                  },
                );
              }),
            ),
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
      ),
      child: child,
    );
  }

  InputDecoration _decoratie({required String label, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Color _kleurUitHex(String waarde) {
    final tekst = waarde.trim().replaceFirst('#', '');
    final getal = int.tryParse(tekst, radix: 16);
    return getal == null ? const Color(0xFFD1D5DB) : Color(0xFF000000 | getal);
  }
}

class _KastmaatTabel extends StatelessWidget {
  const _KastmaatTabel();

  static const double _celBreedte = 62;
  static const double _hoogteCelBreedte = 68;
  static const Color _kopGroen = Color(0xFF86A95B);
  static const Color _subKop = Color(0xFFD1D5DB);
  static const Color _rijAchtergrond = Color(0xFFF3F7ED);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 520,
      child: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _bouwLamelKop(),
                _bouwAsKop(),
                ...OpmetingVoorzetrolluikKastmaatHelper.rijen.map(_bouwRij),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bouwLamelKop() {
    final aantallenPerLamel = <String, int>{};
    for (final kolom in OpmetingVoorzetrolluikKastmaatHelper.kolommen) {
      aantallenPerLamel.update(
        kolom.lamelType,
        (aantal) => aantal + 1,
        ifAbsent: () => 1,
      );
    }

    return Row(
      children: <Widget>[
        _cel('Lamel', breedte: _hoogteCelBreedte, kleur: _kopGroen),
        ...aantallenPerLamel.entries.map(
          (groep) => _cel(
            groep.key,
            breedte: _celBreedte * groep.value,
            kleur: _kopGroen,
          ),
        ),
      ],
    );
  }

  Widget _bouwAsKop() {
    return Row(
      children: <Widget>[
        _cel('H / as', breedte: _hoogteCelBreedte, kleur: _subKop),
        ...OpmetingVoorzetrolluikKastmaatHelper.kolommen.map(
          (kolom) => _cel(
            kolom.asDiameterMm.toString(),
            breedte: _celBreedte,
            kleur: _subKop,
          ),
        ),
      ],
    );
  }

  Widget _bouwRij(OpmetingVoorzetrolluikKasttabelRij rij) {
    return Row(
      children: <Widget>[
        _cel(
          rij.hoogteMm.toString(),
          breedte: _hoogteCelBreedte,
          kleur: _subKop,
        ),
        ...rij.kastmatenMm.map(
          (waarde) => _cel(
            waarde.toString(),
            breedte: _celBreedte,
            kleur: _rijAchtergrond,
          ),
        ),
      ],
    );
  }

  Widget _cel(String tekst, {required double breedte, required Color kleur}) {
    return Container(
      width: breedte,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: kleur,
        border: Border.all(color: const Color(0xFF6B7280), width: 0.6),
      ),
      child: Text(
        tekst,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF111827),
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoKaart extends StatelessWidget {
  const _InfoKaart({required this.titel, required this.tekst});

  final String titel;
  final String tekst;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  titel,
                  style: const TextStyle(
                    color:
                        _OpmetingVoorzetrolluikInstellingenPaginaState._tekst,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tekst,
                  style: const TextStyle(
                    color: _OpmetingVoorzetrolluikInstellingenPaginaState
                        ._tekstGrijs,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InstellingenSectie extends StatelessWidget {
  const _InstellingenSectie({
    required this.titel,
    required this.subtitel,
    this.onToevoegen,
    required this.child,
  });

  final String titel;
  final String subtitel;
  final VoidCallback? onToevoegen;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _OpmetingVoorzetrolluikInstellingenPaginaState._rand,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(14, 11, 10, 11),
            color: const Color(0xFFE7F6EC),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        titel,
                        style: const TextStyle(
                          color: _OpmetingVoorzetrolluikInstellingenPaginaState
                              ._groen,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitel,
                        style: const TextStyle(
                          color: _OpmetingVoorzetrolluikInstellingenPaginaState
                              ._tekstGrijs,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onToevoegen != null)
                  FilledButton.icon(
                    onPressed: onToevoegen,
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          _OpmetingVoorzetrolluikInstellingenPaginaState._groen,
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Toevoegen'),
                  ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(10), child: child),
        ],
      ),
    );
  }
}

class _LijstRij extends StatelessWidget {
  const _LijstRij({
    required this.leading,
    required this.titel,
    required this.subtitel,
    required this.onBewerken,
    required this.onVerwijderen,
  });

  final Widget leading;
  final String titel;
  final String subtitel;
  final VoidCallback onBewerken;
  final VoidCallback onVerwijderen;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _OpmetingVoorzetrolluikInstellingenPaginaState._rand,
        ),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(width: 34, child: Center(child: leading)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  titel,
                  style: const TextStyle(
                    color:
                        _OpmetingVoorzetrolluikInstellingenPaginaState._tekst,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitel.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    subtitel,
                    style: const TextStyle(
                      color: _OpmetingVoorzetrolluikInstellingenPaginaState
                          ._tekstGrijs,
                      fontSize: 10.5,
                      height: 1.25,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Wijzigen',
            onPressed: onBewerken,
            icon: const Icon(Icons.edit_outlined, size: 19),
          ),
          IconButton(
            tooltip: 'Verwijderen',
            onPressed: onVerwijderen,
            color: const Color(0xFFDC2626),
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}

class _LegeLijstMelding extends StatelessWidget {
  const _LegeLijstMelding({required this.tekst});

  final String tekst;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        tekst,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: _OpmetingVoorzetrolluikInstellingenPaginaState._tekstGrijs,
          fontSize: 12,
        ),
      ),
    );
  }
}
