// THIMACO-CONTROLE: SCHUCO-FOLIEKLEUREN-VOLGORDE-OMHOOG-OMLAAG-20260808-1930
// THIMACO-CONTROLE: SCHUCO-FOLIEKLEUREN-PAGINA-MODEL-IMPORTFIX-20260808-1813

import 'package:flutter/material.dart';

import '../../../helpers/opmeting/project/schuco_folie_kleur_model.dart';
import '../../../helpers/opmeting/project/schuco_folie_kleuren_storage.dart';

class SchucoFolieKleurenPagina extends StatefulWidget {
  const SchucoFolieKleurenPagina({super.key});

  @override
  State<SchucoFolieKleurenPagina> createState() =>
      _SchucoFolieKleurenPaginaState();
}

class _SchucoFolieKleurenPaginaState extends State<SchucoFolieKleurenPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);
  static const Color _rood = Color(0xFFDC2626);

  final TextEditingController _zoekController = TextEditingController();

  bool _laden = true;
  bool _bewaren = false;
  List<SchucoFolieKleur> _kleuren = <SchucoFolieKleur>[];

  @override
  void initState() {
    super.initState();
    _laad();
  }

  @override
  void dispose() {
    _zoekController.dispose();
    super.dispose();
  }

  Future<void> _laad() async {
    final kleuren = await SchucoFolieKleurenStorage.laad();
    if (!mounted) return;
    setState(() {
      _kleuren = kleuren;
      _laden = false;
    });
  }

  List<SchucoFolieKleur> get _zichtbareKleuren {
    final zoek = _zoekController.text.trim().toLowerCase();
    if (zoek.isEmpty) return _kleuren;
    return _kleuren.where((kleur) => kleur.zoekTekst.contains(zoek)).toList();
  }

  Future<void> _bewaar(List<SchucoFolieKleur> kleuren) async {
    setState(() {
      _kleuren = kleuren;
      _bewaren = true;
    });

    try {
      await SchucoFolieKleurenStorage.bewaar(kleuren);
    } finally {
      if (mounted) {
        setState(() => _bewaren = false);
      }
    }
  }

  Future<void> _verplaatsKleur(SchucoFolieKleur kleur, int richting) async {
    if (_bewaren || richting == 0) return;

    final zichtbaar = _zichtbareKleuren;
    final zichtbaarIndex = zichtbaar.indexWhere((item) => item.id == kleur.id);
    final doelZichtbaarIndex = zichtbaarIndex + richting;

    if (zichtbaarIndex < 0 ||
        doelZichtbaarIndex < 0 ||
        doelZichtbaarIndex >= zichtbaar.length) {
      return;
    }

    final doelKleur = zichtbaar[doelZichtbaarIndex];
    final bronIndex = _kleuren.indexWhere((item) => item.id == kleur.id);
    final doelIndex = _kleuren.indexWhere((item) => item.id == doelKleur.id);

    if (bronIndex < 0 || doelIndex < 0 || bronIndex == doelIndex) return;

    final nieuweKleuren = List<SchucoFolieKleur>.from(_kleuren);
    final tijdelijk = nieuweKleuren[bronIndex];
    nieuweKleuren[bronIndex] = nieuweKleuren[doelIndex];
    nieuweKleuren[doelIndex] = tijdelijk;

    await _bewaar(nieuweKleuren);
  }

  String _nieuwId() => 'schuco_custom_${DateTime.now().microsecondsSinceEpoch}';

  Future<void> _voegKleurToe() async {
    final kleur = await _toonKleurDialog(
      titel: 'Schüco foliekleur toevoegen',
      begin: SchucoFolieKleur(id: _nieuwId(), naam: '', folieNummer: ''),
    );
    if (kleur == null) return;
    await _bewaar(<SchucoFolieKleur>[..._kleuren, kleur]);
  }

  Future<void> _bewerkKleur(SchucoFolieKleur kleur) async {
    final gewijzigd = await _toonKleurDialog(
      titel: 'Schüco foliekleur aanpassen',
      begin: kleur,
    );
    if (gewijzigd == null) return;

    await _bewaar(
      _kleuren
          .map((item) => item.id == kleur.id ? gewijzigd : item)
          .toList(growable: true),
    );
  }

  Future<void> _verwijderKleur(SchucoFolieKleur kleur) async {
    final bevestig = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Kleur verwijderen?'),
        content: Text(
          kleur.folieNummer.trim().isEmpty
              ? '“${kleur.naam}” wordt uit de Schüco folielijst verwijderd.'
              : '“${kleur.naam}” · ${kleur.folieNummer} wordt uit de Schüco folielijst verwijderd.',
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

    if (bevestig != true) return;
    await _bewaar(
      _kleuren.where((item) => item.id != kleur.id).toList(growable: true),
    );
  }

  Future<void> _herstelStandaard() async {
    final bevestig = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Standaardlijst herstellen?'),
        content: const Text(
          'De Schüco folielijst wordt teruggezet naar de 73 oorspronkelijke kleuren. Zelf toegevoegde wijzigingen worden vervangen.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _groen),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Herstellen'),
          ),
        ],
      ),
    );

    if (bevestig != true) return;
    setState(() => _bewaren = true);
    try {
      final kleuren = await SchucoFolieKleurenStorage.herstelStandaard();
      if (!mounted) return;
      setState(() => _kleuren = kleuren);
    } finally {
      if (mounted) setState(() => _bewaren = false);
    }
  }

  Future<SchucoFolieKleur?> _toonKleurDialog({
    required String titel,
    required SchucoFolieKleur begin,
  }) async {
    final naamController = TextEditingController(text: begin.naam);
    final folieController = TextEditingController(text: begin.folieNummer);
    final hexController = TextEditingController(text: begin.hex);

    try {
      return await showDialog<SchucoFolieKleur>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(titel),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: naamController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nederlandse benaming',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: folieController,
                  decoration: const InputDecoration(
                    labelText: 'Volledig folie-/Dessin-nummer',
                    hintText: 'bv. 436-5003A',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: hexController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Schermkleur (optioneel)',
                    hintText: '#383E42',
                    helperText:
                        'Alleen voor de kleurweergave; het folienummer blijft leidend.',
                    border: OutlineInputBorder(),
                    isDense: true,
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
                final naam = naamController.text.trim();
                if (naam.isEmpty) return;
                Navigator.pop(
                  dialogContext,
                  begin.copyWith(
                    naam: naam,
                    folieNummer: folieController.text.trim(),
                    hex: hexController.text.trim(),
                  ),
                );
              },
              child: const Text('Bewaren'),
            ),
          ],
        ),
      );
    } finally {
      naamController.dispose();
      folieController.dispose();
      hexController.dispose();
    }
  }

  Color _kleurVanHex(String hex) {
    var waarde = hex.trim().replaceFirst('#', '');
    if (waarde.length != 6) return const Color(0xFFE5E7EB);
    final rgb = int.tryParse(waarde, radix: 16);
    if (rgb == null) return const Color(0xFFE5E7EB);
    return Color(0xFF000000 | rgb);
  }

  @override
  Widget build(BuildContext context) {
    final zichtbaar = _zichtbareKleuren;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _tekstDonker,
        elevation: 0,
        title: const Text(
          'Schüco folie kleuren',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: <Widget>[
          if (_bewaren)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              tooltip: 'Standaardlijst herstellen',
              onPressed: _herstelStandaard,
              icon: const Icon(Icons.refresh_rounded),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _groen,
        foregroundColor: Colors.white,
        onPressed: _voegKleurToe,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Kleur toevoegen'),
      ),
      body: _laden
          ? const Center(child: CircularProgressIndicator(color: _groen))
          : Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _lichtGroen,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFCDEBD6)),
                  ),
                  child: const Text(
                    'Aparte Schüco foliebibliotheek voor Binnenkleur en Buitenkleur op het opmeetoverzicht. De bestaande projectkleuren worden niet gewijzigd. De kleurvakjes zijn een schermbenadering; controleer steeds de foliebenaming en het Dessin-nummer.',
                    style: TextStyle(
                      color: _groen,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: TextField(
                    controller: _zoekController,
                    decoration: InputDecoration(
                      hintText: 'Zoek op kleur of folienummer',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _zoekController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _zoekController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _rand),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _rand),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 2,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${zichtbaar.length} van ${_kleuren.length} kleur(en)',
                      style: const TextStyle(
                        color: _tekstGrijs,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: zichtbaar.isEmpty
                      ? const Center(
                          child: Text(
                            'Geen Schüco foliekleuren gevonden.',
                            style: TextStyle(
                              color: _tekstGrijs,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                          itemCount: zichtbaar.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 7),
                          itemBuilder: (context, index) {
                            final kleur = zichtbaar[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(color: _rand),
                              ),
                              child: ListTile(
                                dense: true,
                                leading: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: _kleurVanHex(kleur.hex),
                                    borderRadius: BorderRadius.circular(9),
                                    border: Border.all(
                                      color: const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  kleur.naam,
                                  style: const TextStyle(
                                    color: _tekstDonker,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                subtitle: kleur.folieNummer.trim().isEmpty
                                    ? const Text('Geen folienummer')
                                    : Text(
                                        'Folie/Dessin: ${kleur.folieNummer}',
                                      ),
                                trailing: Wrap(
                                  spacing: 0,
                                  children: <Widget>[
                                    IconButton(
                                      tooltip: 'Omhoog',
                                      visualDensity: VisualDensity.compact,
                                      constraints:
                                          const BoxConstraints.tightFor(
                                            width: 34,
                                            height: 34,
                                          ),
                                      onPressed: index > 0 && !_bewaren
                                          ? () => _verplaatsKleur(kleur, -1)
                                          : null,
                                      icon: const Icon(
                                        Icons.arrow_upward_rounded,
                                        size: 18,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Omlaag',
                                      visualDensity: VisualDensity.compact,
                                      constraints:
                                          const BoxConstraints.tightFor(
                                            width: 34,
                                            height: 34,
                                          ),
                                      onPressed:
                                          index < zichtbaar.length - 1 &&
                                              !_bewaren
                                          ? () => _verplaatsKleur(kleur, 1)
                                          : null,
                                      icon: const Icon(
                                        Icons.arrow_downward_rounded,
                                        size: 18,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Aanpassen',
                                      visualDensity: VisualDensity.compact,
                                      constraints:
                                          const BoxConstraints.tightFor(
                                            width: 34,
                                            height: 34,
                                          ),
                                      onPressed: _bewaren
                                          ? null
                                          : () => _bewerkKleur(kleur),
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: _groen,
                                        size: 18,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Verwijderen',
                                      visualDensity: VisualDensity.compact,
                                      constraints:
                                          const BoxConstraints.tightFor(
                                            width: 34,
                                            height: 34,
                                          ),
                                      onPressed: _bewaren
                                          ? null
                                          : () => _verwijderKleur(kleur),
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: _rood,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
