import 'package:flutter/material.dart';

import 'opmeting_project_kleur_model.dart';

Future<String?> toonOpmetingProjectKleurKeuzeDialoog({
  required BuildContext context,
  required List<OpmetingProjectKleurSubmenu> kleurMenus,
  required String huidigeWaarde,
}) {
  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return _OpmetingProjectKleurKeuzeDialoog(
        kleurMenus: kleurMenus,
        huidigeWaarde: huidigeWaarde,
      );
    },
  );
}

class _OpmetingProjectKleurKeuzeDialoog extends StatefulWidget {
  const _OpmetingProjectKleurKeuzeDialoog({
    required this.kleurMenus,
    required this.huidigeWaarde,
  });

  final List<OpmetingProjectKleurSubmenu> kleurMenus;
  final String huidigeWaarde;

  @override
  State<_OpmetingProjectKleurKeuzeDialoog> createState() {
    return _OpmetingProjectKleurKeuzeDialoogState();
  }
}

class _OpmetingProjectKleurKeuzeDialoogState
    extends State<_OpmetingProjectKleurKeuzeDialoog> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  final TextEditingController _zoekController = TextEditingController();
  OpmetingProjectKleurSubmenu? _gekozenSubmenu;

  @override
  void dispose() {
    _zoekController.dispose();
    super.dispose();
  }

  List<OpmetingProjectKleurSubmenu> get _zichtbareSubmenus {
    return widget.kleurMenus.where((submenu) {
      return submenu.actief &&
          submenu.naam.trim().isNotEmpty &&
          submenu.actieveKleuren.isNotEmpty;
    }).toList();
  }

  List<OpmetingProjectKleur> get _zichtbareKleuren {
    final submenu = _gekozenSubmenu;

    if (submenu == null) {
      return const <OpmetingProjectKleur>[];
    }

    final zoekterm = _zoekController.text.trim().toLowerCase();

    return submenu.actieveKleuren.where((kleur) {
      return zoekterm.isEmpty || kleur.naam.toLowerCase().contains(zoekterm);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scherm = MediaQuery.sizeOf(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(22),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: scherm.height - 44,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _bouwKop(),
            Flexible(
              child: _gekozenSubmenu == null
                  ? _bouwSubmenuLijst()
                  : _bouwKleurenLijst(),
            ),
            _bouwActies(),
          ],
        ),
      ),
    );
  }

  Widget _bouwKop() {
    final submenu = _gekozenSubmenu;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: const BoxDecoration(
        color: _lichtGroen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Row(
        children: [
          if (submenu != null) ...[
            IconButton(
              tooltip: 'Terug naar submenu’s',
              visualDensity: VisualDensity.compact,
              onPressed: () {
                setState(() {
                  _gekozenSubmenu = null;
                  _zoekController.clear();
                });
              },
              icon: const Icon(Icons.arrow_back_rounded, color: _groen),
            ),
            const SizedBox(width: 2),
          ] else
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.palette_outlined, color: _groen),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  submenu?.naam ?? 'Projectkleur kiezen',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _tekstDonker,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  submenu == null
                      ? 'Kies eerst een submenu.'
                      : 'Kies daarna de gewenste kleur.',
                  style: const TextStyle(
                    color: _tekstGrijs,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Sluiten',
            visualDensity: VisualDensity.compact,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _bouwSubmenuLijst() {
    final submenus = _zichtbareSubmenus;

    if (submenus.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Er zijn nog geen kleurensubmenu’s ingesteld.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _tekstGrijs, fontWeight: FontWeight.w800),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.all(14),
      itemCount: submenus.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final submenu = submenus[index];

        return Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
            side: const BorderSide(color: _rand),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(13),
            onTap: () {
              setState(() {
                _gekozenSubmenu = submenu;
                _zoekController.clear();
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _lichtGroen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.folder_open_outlined,
                      color: _groen,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      submenu.naam,
                      style: const TextStyle(
                        color: _tekstDonker,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '${submenu.actieveKleuren.length}',
                    style: const TextStyle(
                      color: _tekstGrijs,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right_rounded, color: _groen),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _bouwKleurenLijst() {
    final kleuren = _zichtbareKleuren;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
          child: TextField(
            controller: _zoekController,
            decoration: InputDecoration(
              hintText: 'Zoek kleur of RAL-nummer',
              isDense: true,
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              prefixIcon: const Icon(Icons.search_rounded, size: 19),
              suffixIcon: _zoekController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Zoektekst wissen',
                      onPressed: () {
                        setState(_zoekController.clear);
                      },
                      icon: const Icon(Icons.close_rounded, size: 18),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _rand),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _rand),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _groen, width: 1.4),
              ),
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),
        ),
        Expanded(
          child: kleuren.isEmpty
              ? const Center(
                  child: Text(
                    'Geen kleuren gevonden.',
                    style: TextStyle(
                      color: _tekstGrijs,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                  itemCount: kleuren.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 7),
                  itemBuilder: (context, index) {
                    final kleur = kleuren[index];
                    final geselecteerd =
                        kleur.naam.trim().toLowerCase() ==
                        widget.huidigeWaarde.trim().toLowerCase();

                    return Material(
                      color: geselecteerd ? _lichtGroen : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: geselecteerd ? _groen : _rand),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.pop(context, kleur.naam);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 11,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: _kleurSwatchVoorTekst(kleur.naam),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  kleur.naam,
                                  style: const TextStyle(
                                    color: _tekstDonker,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (geselecteerd)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: _groen,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _bouwActies() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _rand)),
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context, '');
            },
            icon: const Icon(Icons.backspace_outlined, size: 17),
            label: const Text('Kleur leegmaken'),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Annuleren'),
          ),
        ],
      ),
    );
  }

  Color _kleurSwatchVoorTekst(String tekst) {
    final lower = tekst.toLowerCase();

    if (lower.contains('white') ||
        lower.contains('weiß') ||
        lower.contains('wit') ||
        lower.contains('9010') ||
        lower.contains('9016')) {
      return Colors.white;
    }

    if (lower.contains('black') ||
        lower.contains('schwarz') ||
        lower.contains('zwart') ||
        lower.contains('9005')) {
      return const Color(0xFF111827);
    }

    if (lower.contains('7016') ||
        lower.contains('anthrazit') ||
        lower.contains('antraciet') ||
        lower.contains('graphite')) {
      return const Color(0xFF374151);
    }

    if (lower.contains('oak') ||
        lower.contains('eik') ||
        lower.contains('nussbaum') ||
        lower.contains('winchester') ||
        lower.contains('toffee') ||
        lower.contains('malt')) {
      return const Color(0xFFB7791F);
    }

    if (lower.contains('bronze') || lower.contains('copper')) {
      return const Color(0xFF8B5E3C);
    }

    if (lower.contains('silver') ||
        lower.contains('aluminium') ||
        lower.contains('9006') ||
        lower.contains('9007')) {
      return const Color(0xFF9CA3AF);
    }

    if (lower.contains('beige') || lower.contains('cream')) {
      return const Color(0xFFD6C6A5);
    }

    return const Color(0xFFE5E7EB);
  }
}
