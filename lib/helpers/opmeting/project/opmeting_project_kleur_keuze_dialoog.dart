// THIMACO-CONTROLE: PROJECTKLEUR-DIALOOG-PROGRAMMASTIJL-FASE16-20260913
// THIMACO-CONTROLE: LEGE-KLEURENSUBMENUS-ZICHTBAAR-20260808-1902
import 'package:flutter/material.dart';

import '../../ui/thimaco_huisstijl.dart';
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
  static const Color _accent = ThimacoKleuren.oranje;
  static const Color _accentLicht = ThimacoKleuren.oranjeLicht;
  static const Color _rand = ThimacoKleuren.rand;
  static const Color _tekstDonker = ThimacoKleuren.antraciet;
  static const Color _tekstGrijs = ThimacoKleuren.tekstGrijs;

  final TextEditingController _zoekController = TextEditingController();
  OpmetingProjectKleurSubmenu? _gekozenSubmenu;

  @override
  void dispose() {
    _zoekController.dispose();
    super.dispose();
  }

  List<OpmetingProjectKleurSubmenu> get _zichtbareSubmenus {
    return widget.kleurMenus.where((submenu) {
      return submenu.actief && submenu.naam.trim().isNotEmpty;
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
      surfaceTintColor: Colors.white,
      shadowColor: Colors.black.withValues(alpha: 0.14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: _rand),
      ),
      clipBehavior: Clip.antiAlias,
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
      padding: const EdgeInsets.fromLTRB(14, 11, 10, 11),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        border: Border(bottom: BorderSide(color: _rand)),
      ),
      child: Row(
        children: <Widget>[
          if (submenu != null) ...<Widget>[
            ThimacoIcoonActie(
              icoon: Icons.arrow_back_rounded,
              tooltip: 'Terug naar submenu’s',
              grootte: 19,
              onPressed: () {
                setState(() {
                  _gekozenSubmenu = null;
                  _zoekController.clear();
                });
              },
            ),
            const SizedBox(width: 4),
          ] else
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _rand),
              ),
              child: const Icon(
                Icons.palette_outlined,
                color: _tekstDonker,
                size: 19,
              ),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ThimacoSectieTitel(
                  tekst: submenu?.naam ?? 'Projectkleur kiezen',
                  compact: false,
                ),
                const SizedBox(height: 4),
                Text(
                  submenu == null
                      ? 'Kies eerst een submenu.'
                      : 'Kies daarna de gewenste kleur.',
                  style: const TextStyle(
                    color: _tekstGrijs,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ThimacoIcoonActie(
            icoon: Icons.close_rounded,
            tooltip: 'Sluiten',
            grootte: 19,
            onPressed: () {
              Navigator.pop(context);
            },
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
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: _rand),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            hoverColor: _accentLicht.withValues(alpha: 0.55),
            onTap: () {
              setState(() {
                _gekozenSubmenu = submenu;
                _zoekController.clear();
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8F9),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.folder_open_outlined,
                      color: _tekstDonker,
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
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '${submenu.actieveKleuren.length}',
                    style: const TextStyle(
                      color: _tekstGrijs,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: _tekstGrijs,
                    size: 20,
                  ),
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
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
          child: TextField(
            controller: _zoekController,
            cursorColor: _accent,
            decoration: InputDecoration(
              hintText: 'Zoek kleur of RAL-nummer',
              isDense: true,
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 19,
                color: _tekstDonker,
              ),
              suffixIcon: _zoekController.text.isEmpty
                  ? null
                  : ThimacoIcoonActie(
                      icoon: Icons.close_rounded,
                      tooltip: 'Zoektekst wissen',
                      grootte: 17,
                      onPressed: () {
                        setState(_zoekController.clear);
                      },
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
                borderSide: const BorderSide(color: _accent, width: 1.4),
              ),
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),
        ),
        Expanded(
          child: kleuren.isEmpty
              ? Center(
                  child: Text(
                    _zoekController.text.trim().isEmpty
                        ? 'Nog geen kleuren in dit submenu.'
                        : 'Geen kleuren gevonden.',
                    style: const TextStyle(
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
                      color: geselecteerd ? _accentLicht : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: geselecteerd ? _accent : _rand,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        hoverColor: _accentLicht.withValues(alpha: 0.5),
                        onTap: () {
                          Navigator.pop(context, kleur.naam);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 11,
                          ),
                          child: Row(
                            children: <Widget>[
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
                                  color: _accent,
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
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _rand)),
      ),
      child: Row(
        children: <Widget>[
          ThimacoTekstActie(
            tekst: 'Kleur leegmaken',
            onPressed: () {
              Navigator.pop(context, '');
            },
          ),
          const Spacer(),
          ThimacoTekstActie(
            tekst: 'Annuleren',
            onPressed: () {
              Navigator.pop(context);
            },
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
