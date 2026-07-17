import 'package:flutter/material.dart';

import '../../app_storage.dart';
import 'opmeting_project_kleur_model.dart';

class OpmetingProjectKleurenPagina extends StatefulWidget {
  const OpmetingProjectKleurenPagina({super.key});

  @override
  State<OpmetingProjectKleurenPagina> createState() {
    return _OpmetingProjectKleurenPaginaState();
  }
}

class _OpmetingProjectKleurenPaginaState
    extends State<OpmetingProjectKleurenPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  bool _laden = true;
  bool _bewaren = false;
  List<OpmetingProjectKleurSubmenu> _submenus = <OpmetingProjectKleurSubmenu>[];

  @override
  void initState() {
    super.initState();
    _laad();
  }

  Future<void> _laad() async {
    final geladen = await AppStorage.laadOpmetingProjectKleuren();

    if (!mounted) {
      return;
    }

    setState(() {
      _submenus = geladen;
      _laden = false;
    });
  }

  Future<void> _bewaar(List<OpmetingProjectKleurSubmenu> nieuweSubmenus) async {
    setState(() {
      _submenus = nieuweSubmenus;
      _bewaren = true;
    });

    try {
      await AppStorage.bewaarOpmetingProjectKleuren(nieuweSubmenus);
    } finally {
      if (mounted) {
        setState(() {
          _bewaren = false;
        });
      }
    }
  }

  String _nieuwId(String prefix) {
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}';
  }

  Future<void> _voegSubmenuToe() async {
    final naam = await _vraagTekst(
      titel: 'Submenu toevoegen',
      label: 'Naam submenu',
    );

    if (naam == null || naam.trim().isEmpty) {
      return;
    }

    await _bewaar(<OpmetingProjectKleurSubmenu>[
      ..._submenus,
      OpmetingProjectKleurSubmenu(id: _nieuwId('submenu'), naam: naam.trim()),
    ]);
  }

  Future<void> _bewerkSubmenu(OpmetingProjectKleurSubmenu submenu) async {
    final naam = await _vraagTekst(
      titel: 'Submenu aanpassen',
      label: 'Naam submenu',
      beginWaarde: submenu.naam,
    );

    if (naam == null || naam.trim().isEmpty) {
      return;
    }

    await _bewaar(
      _submenus.map((huidig) {
        if (huidig.id != submenu.id) {
          return huidig;
        }

        return huidig.copyWith(naam: naam.trim());
      }).toList(),
    );
  }

  Future<void> _verwijderSubmenu(OpmetingProjectKleurSubmenu submenu) async {
    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Text('Submenu verwijderen?'),
          content: Text(
            'Submenu “${submenu.naam}” en alle kleuren daaronder worden verwijderd.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Annuleren'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Verwijderen'),
            ),
          ],
        );
      },
    );

    if (bevestigen != true) {
      return;
    }

    await _bewaar(
      _submenus.where((huidig) => huidig.id != submenu.id).toList(),
    );
  }

  Future<void> _voegKleurToe(OpmetingProjectKleurSubmenu submenu) async {
    final naam = await _vraagTekst(
      titel: 'Kleur toevoegen',
      label: 'Kleur / omschrijving',
      hint: 'bv. 7016 Antraciet structuur',
    );

    if (naam == null || naam.trim().isEmpty) {
      return;
    }

    await _bewaar(
      _submenus.map((huidig) {
        if (huidig.id != submenu.id) {
          return huidig;
        }

        return huidig.copyWith(
          kleuren: <OpmetingProjectKleur>[
            ...huidig.kleuren,
            OpmetingProjectKleur(id: _nieuwId('kleur'), naam: naam.trim()),
          ],
        );
      }).toList(),
    );
  }

  Future<void> _bewerkKleur({
    required OpmetingProjectKleurSubmenu submenu,
    required OpmetingProjectKleur kleur,
  }) async {
    final naam = await _vraagTekst(
      titel: 'Kleur aanpassen',
      label: 'Kleur / omschrijving',
      beginWaarde: kleur.naam,
    );

    if (naam == null || naam.trim().isEmpty) {
      return;
    }

    await _bewaar(
      _submenus.map((huidig) {
        if (huidig.id != submenu.id) {
          return huidig;
        }

        return huidig.copyWith(
          kleuren: huidig.kleuren.map((huidigeKleur) {
            if (huidigeKleur.id != kleur.id) {
              return huidigeKleur;
            }

            return huidigeKleur.copyWith(naam: naam.trim());
          }).toList(),
        );
      }).toList(),
    );
  }

  Future<void> _verwijderKleur({
    required OpmetingProjectKleurSubmenu submenu,
    required OpmetingProjectKleur kleur,
  }) async {
    await _bewaar(
      _submenus.map((huidig) {
        if (huidig.id != submenu.id) {
          return huidig;
        }

        return huidig.copyWith(
          kleuren: huidig.kleuren.where((item) => item.id != kleur.id).toList(),
        );
      }).toList(),
    );
  }

  Future<String?> _vraagTekst({
    required String titel,
    required String label,
    String beginWaarde = '',
    String? hint,
  }) async {
    final controller = TextEditingController(text: beginWaarde);

    final resultaat = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(titel),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) {
              Navigator.pop(dialogContext, controller.text.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Annuleren'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _groen,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, controller.text.trim());
              },
              child: const Text('Bewaren'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    return resultaat;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _tekstDonker,
        elevation: 0,
        title: const Text(
          'Kleuren raamleverancier',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          if (_bewaren)
            const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: _laden
          ? const Center(child: CircularProgressIndicator(color: _groen))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: _groen,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _voegSubmenuToe,
                    icon: const Icon(Icons.create_new_folder_outlined),
                    label: const Text('Submenu toevoegen'),
                  ),
                ),
                const SizedBox(height: 14),
                if (_submenus.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _rand),
                    ),
                    child: const Text(
                      'Nog geen submenu’s. Maak bijvoorbeeld PVC kleuren of ALU kleuren aan.',
                      style: TextStyle(
                        color: _tekstGrijs,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  ..._submenus.map(_bouwSubmenuKaart),
              ],
            ),
    );
  }

  Widget _bouwSubmenuKaart(OpmetingProjectKleurSubmenu submenu) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _rand),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        title: Text(
          submenu.naam,
          style: const TextStyle(
            color: _tekstDonker,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text('${submenu.kleuren.length} kleur(en)'),
        trailing: Wrap(
          spacing: 2,
          children: [
            IconButton(
              tooltip: 'Kleur toevoegen',
              onPressed: () {
                _voegKleurToe(submenu);
              },
              icon: const Icon(Icons.add_circle_outline, color: _groen),
            ),
            IconButton(
              tooltip: 'Submenu aanpassen',
              onPressed: () {
                _bewerkSubmenu(submenu);
              },
              icon: const Icon(Icons.edit_outlined, color: _groen),
            ),
            IconButton(
              tooltip: 'Submenu verwijderen',
              onPressed: () {
                _verwijderSubmenu(submenu);
              },
              icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
            ),
          ],
        ),
        children: [
          if (submenu.kleuren.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _lichtGroen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Nog geen kleuren onder dit submenu.',
                style: TextStyle(color: _groen, fontWeight: FontWeight.w700),
              ),
            )
          else
            ...submenu.kleuren.map((kleur) {
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.palette_outlined, color: _groen),
                title: Text(
                  kleur.naam,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                trailing: Wrap(
                  spacing: 2,
                  children: [
                    IconButton(
                      tooltip: 'Kleur aanpassen',
                      onPressed: () {
                        _bewerkKleur(submenu: submenu, kleur: kleur);
                      },
                      icon: const Icon(Icons.edit_outlined, color: _groen),
                    ),
                    IconButton(
                      tooltip: 'Kleur verwijderen',
                      onPressed: () {
                        _verwijderKleur(submenu: submenu, kleur: kleur);
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
