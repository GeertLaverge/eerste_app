// THIMACO-CONTROLE: ALIPLAST-STANDAARD-RAL-VOLGORDE-OMHOOG-OMLAAG-20260808-1930
// THIMACO-CONTROLE: ALIPLAST-STANDAARD-RAL-BEHEER-20260808-1902

import 'package:flutter/material.dart';

import '../../../helpers/opmeting/project/aliplast_standaard_ral_kleuren_storage.dart';
import '../../../helpers/opmeting/project/opmeting_project_kleur_model.dart';

class AliplastStandaardRalKleurenPagina extends StatefulWidget {
  const AliplastStandaardRalKleurenPagina({super.key});

  @override
  State<AliplastStandaardRalKleurenPagina> createState() =>
      _AliplastStandaardRalKleurenPaginaState();
}

class _AliplastStandaardRalKleurenPaginaState
    extends State<AliplastStandaardRalKleurenPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);
  static const Color _rood = Color(0xFFDC2626);

  final TextEditingController _zoekController = TextEditingController();

  bool _laden = true;
  bool _bewaren = false;
  List<OpmetingProjectKleur> _kleuren = <OpmetingProjectKleur>[];

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
    final kleuren = await AliplastStandaardRalKleurenStorage.laad();
    if (!mounted) return;
    setState(() {
      _kleuren = kleuren;
      _laden = false;
    });
  }

  List<OpmetingProjectKleur> get _zichtbareKleuren {
    final zoek = _zoekController.text.trim().toLowerCase();
    if (zoek.isEmpty) return _kleuren;
    return _kleuren
        .where((kleur) => kleur.naam.toLowerCase().contains(zoek))
        .toList(growable: false);
  }

  Future<void> _verplaatsKleur(OpmetingProjectKleur kleur, int richting) async {
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

    final nieuweKleuren = List<OpmetingProjectKleur>.from(_kleuren);
    final tijdelijk = nieuweKleuren[bronIndex];
    nieuweKleuren[bronIndex] = nieuweKleuren[doelIndex];
    nieuweKleuren[doelIndex] = tijdelijk;

    await _bewaar(nieuweKleuren);
  }

  String _nieuwId() =>
      'aliplast_standaard_${DateTime.now().microsecondsSinceEpoch}';

  Future<void> _bewaar(List<OpmetingProjectKleur> kleuren) async {
    setState(() {
      _kleuren = kleuren;
      _bewaren = true;
    });

    try {
      await AliplastStandaardRalKleurenStorage.bewaar(kleuren);
    } finally {
      if (mounted) setState(() => _bewaren = false);
    }
  }

  Future<void> _voegKleurToe() async {
    final naam = await _vraagKleurTekst(
      titel: 'Aliplast standaardkleur toevoegen',
      beginWaarde: '',
    );
    if (naam == null || naam.trim().isEmpty) return;

    await _bewaar(<OpmetingProjectKleur>[
      ..._kleuren,
      OpmetingProjectKleur(id: _nieuwId(), naam: naam.trim()),
    ]);
  }

  Future<void> _bewerkKleur(OpmetingProjectKleur kleur) async {
    final naam = await _vraagKleurTekst(
      titel: 'Aliplast standaardkleur aanpassen',
      beginWaarde: kleur.naam,
    );
    if (naam == null || naam.trim().isEmpty) return;

    await _bewaar(
      _kleuren
          .map(
            (item) =>
                item.id == kleur.id ? item.copyWith(naam: naam.trim()) : item,
          )
          .toList(growable: true),
    );
  }

  Future<void> _verwijderKleur(OpmetingProjectKleur kleur) async {
    final bevestig = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Kleur verwijderen?'),
        content: Text(
          '“${kleur.naam}” wordt uit de standaardlijst verwijderd.',
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

  Future<String?> _vraagKleurTekst({
    required String titel,
    required String beginWaarde,
  }) async {
    final controller = TextEditingController(text: beginWaarde);
    try {
      return await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(titel),
          content: SizedBox(
            width: 430,
            child: TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'RAL kleur / omschrijving',
                hintText: 'bv. RAL 7016 Antracietgrijs mat',
                helperText:
                    'De officiële Aliplast standaardkleuren vullen we later aan.',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) =>
                  Navigator.pop(dialogContext, controller.text.trim()),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuleren'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _groen),
              onPressed: () =>
                  Navigator.pop(dialogContext, controller.text.trim()),
              child: const Text('Bewaren'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final kleuren = _zichtbareKleuren;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _tekstDonker,
        elevation: 0,
        title: const Text(
          'Aliplast standaard RAL kleuren',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: <Widget>[
          if (_bewaren)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Kleur toevoegen',
            onPressed: _laden || _bewaren ? null : _voegKleurToe,
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
      body: _laden
          ? const Center(child: CircularProgressIndicator(color: _groen))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: _lichtGroen,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFCDEBD6)),
                    ),
                    child: const Text(
                      'Dit submenu is al aangemaakt maar start bewust leeg. '
                      'Zodra we de officiële Aliplast standaard RAL-kleuren hebben, '
                      'kun je ze hier zelf toevoegen, aanpassen of wissen.',
                      style: TextStyle(
                        color: _groen,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _zoekController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search_rounded),
                            hintText: 'Zoeken in standaardkleuren',
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: _rand),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: _rand),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: _groen,
                                width: 1.4,
                              ),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: _groen,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _bewaren ? null : _voegKleurToe,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Kleur toevoegen'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _rand),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: kleuren.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Text(
                                  'Nog geen Aliplast standaard RAL-kleuren ingevoerd.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _tekstGrijs,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: kleuren.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1, color: _rand),
                              itemBuilder: (context, index) {
                                final kleur = kleuren[index];
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(
                                    Icons.palette_outlined,
                                    color: _groen,
                                  ),
                                  title: Text(
                                    kleur.naam,
                                    style: const TextStyle(
                                      color: _tekstDonker,
                                      fontWeight: FontWeight.w800,
                                    ),
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
                                            index < kleuren.length - 1 &&
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
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
