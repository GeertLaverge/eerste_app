// THIMACO-CONTROLE: INSTELLINGEN-FENEKO-KLEUREN-20260808
import 'package:flutter/material.dart';

import '../../../helpers/app_storage.dart';
import '../../../helpers/opmeting/project/opmeting_project_kleur_model.dart';

class FenekoKleurenPagina extends StatefulWidget {
  const FenekoKleurenPagina({super.key});

  @override
  State<FenekoKleurenPagina> createState() => _FenekoKleurenPaginaState();
}

class _FenekoKleurenPaginaState extends State<FenekoKleurenPagina> {
  static const String _submenuId = 'thimaco_feneko_kleuren';
  static const String _submenuNaam = 'Feneko';

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekst = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  final TextEditingController _kleurenController = TextEditingController();

  List<OpmetingProjectKleurSubmenu> _alleSubmenus =
      const <OpmetingProjectKleurSubmenu>[];
  bool _laden = true;
  bool _bewaren = false;

  @override
  void initState() {
    super.initState();
    _laad();
  }

  @override
  void dispose() {
    _kleurenController.dispose();
    super.dispose();
  }

  Future<void> _laad() async {
    setState(() => _laden = true);

    try {
      final submenus = await AppStorage.laadOpmetingProjectKleuren();
      OpmetingProjectKleurSubmenu? feneko;

      for (final submenu in submenus) {
        if (submenu.id == _submenuId ||
            submenu.naam.trim().toLowerCase() == _submenuNaam.toLowerCase()) {
          feneko = submenu;
          break;
        }
      }

      if (!mounted) return;

      _alleSubmenus = List<OpmetingProjectKleurSubmenu>.from(submenus);
      _kleurenController.text =
          feneko?.kleuren
              .where((kleur) => kleur.naam.trim().isNotEmpty)
              .map((kleur) => kleur.naam.trim())
              .join('\n') ??
          '';
    } finally {
      if (mounted) {
        setState(() => _laden = false);
      }
    }
  }

  List<String> _parseKleuren() {
    final gebruikt = <String>{};
    final resultaat = <String>[];

    for (final regel in _kleurenController.text.split(RegExp(r'\r?\n'))) {
      final kleur = regel.trim();
      if (kleur.isEmpty) continue;

      final sleutel = kleur.toLowerCase();
      if (gebruikt.add(sleutel)) {
        resultaat.add(kleur);
      }
    }

    return resultaat;
  }

  Future<void> _bewaar() async {
    if (_bewaren) return;

    setState(() => _bewaren = true);

    try {
      final namen = _parseKleuren();
      OpmetingProjectKleurSubmenu? bestaand;

      for (final submenu in _alleSubmenus) {
        if (submenu.id == _submenuId ||
            submenu.naam.trim().toLowerCase() == _submenuNaam.toLowerCase()) {
          bestaand = submenu;
          break;
        }
      }

      final bestaandeIdsPerNaam = <String, String>{
        if (bestaand != null)
          for (final kleur in bestaand.kleuren)
            if (kleur.naam.trim().isNotEmpty)
              kleur.naam.trim().toLowerCase(): kleur.id,
      };

      final feneko = OpmetingProjectKleurSubmenu(
        id: _submenuId,
        naam: _submenuNaam,
        actief: true,
        kleuren: List<OpmetingProjectKleur>.generate(namen.length, (index) {
          final naam = namen[index];
          return OpmetingProjectKleur(
            id:
                bestaandeIdsPerNaam[naam.toLowerCase()] ??
                'feneko_${(index + 1).toString().padLeft(4, '0')}',
            naam: naam,
            actief: true,
          );
        }),
      );

      final nieuweSubmenus = <OpmetingProjectKleurSubmenu>[];
      var vervangen = false;

      for (final submenu in _alleSubmenus) {
        final isFeneko =
            submenu.id == _submenuId ||
            submenu.naam.trim().toLowerCase() == _submenuNaam.toLowerCase();

        if (isFeneko) {
          if (!vervangen) {
            nieuweSubmenus.add(feneko);
            vervangen = true;
          }
          continue;
        }

        nieuweSubmenus.add(submenu);
      }

      if (!vervangen) {
        nieuweSubmenus.add(feneko);
      }

      await AppStorage.bewaarOpmetingProjectKleuren(nieuweSubmenus);
      if (!mounted) return;

      _alleSubmenus = nieuweSubmenus;
      _kleurenController.text = namen.join('\n');

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Feneko-kleuren bewaard: ${namen.length} kleur(en).'),
            backgroundColor: _groen,
          ),
        );

      setState(() {});
    } finally {
      if (mounted) {
        setState(() => _bewaren = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final kleuren = _parseKleuren();

    return Scaffold(
      backgroundColor: _achtergrond,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _tekst,
        elevation: 0,
        title: const Text(
          'Feneko',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _groen),
              onPressed: _laden || _bewaren ? null : _bewaar,
              icon: _bewaren
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: const Text('Bewaren'),
            ),
          ),
        ],
      ),
      body: _laden
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _rand),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const Text(
                            'Feneko kleurenlijst',
                            style: TextStyle(
                              color: _tekst,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Voeg hier later de Feneko-kleuren in. '
                            'Gebruik één kleur of omschrijving per regel. '
                            'De lijst wordt via de bestaande Thimaco-sync '
                            'beschikbaar op de andere toestellen.',
                            style: TextStyle(
                              color: _tekstGrijs,
                              fontSize: 11.5,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: TextField(
                              controller: _kleurenController,
                              expands: true,
                              minLines: null,
                              maxLines: null,
                              textAlignVertical: TextAlignVertical.top,
                              style: const TextStyle(
                                color: _tekst,
                                fontSize: 12,
                                height: 1.35,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Bijvoorbeeld:\nRAL 7016 structuur\nZwart mat\n...',
                                alignLabelWithHint: true,
                                filled: true,
                                fillColor: const Color(0xFFF9FAFB),
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _rand),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            color: const Color(0xFFE7F6EC),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Text(
                              'Voorbeeld · ${kleuren.length} kleur(en)',
                              style: const TextStyle(
                                color: _groen,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Expanded(
                            child: kleuren.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Text(
                                        'Nog geen Feneko-kleuren ingevoerd.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: _tekstGrijs,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    itemCount: kleuren.length,
                                    separatorBuilder: (_, __) =>
                                        const Divider(height: 1, color: _rand),
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        dense: true,
                                        leading: const Icon(
                                          Icons.palette_outlined,
                                          color: _groen,
                                          size: 17,
                                        ),
                                        title: Text(
                                          kleuren[index],
                                          style: const TextStyle(
                                            color: _tekst,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
