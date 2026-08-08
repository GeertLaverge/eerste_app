// THIMACO-CONTROLE: PROJECTKLEUR-BRONNEN-ALIPLAST-WILMS-FENEKO-20260808
import 'package:flutter/material.dart';

class OpmetingProjectKleurBronOptie {
  const OpmetingProjectKleurBronOptie({
    required this.id,
    required this.label,
    required this.kleuren,
    required this.leegMelding,
  });

  final String id;
  final String label;
  final List<String> kleuren;
  final String leegMelding;
}

Future<String?> toonOpmetingProjectKleurBronKeuzeDialoog({
  required BuildContext context,
  required List<OpmetingProjectKleurBronOptie> bronnen,
  required String huidigeWaarde,
}) {
  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return _OpmetingProjectKleurBronKeuzeDialoog(
        bronnen: bronnen,
        huidigeWaarde: huidigeWaarde,
      );
    },
  );
}

class _OpmetingProjectKleurBronKeuzeDialoog extends StatefulWidget {
  const _OpmetingProjectKleurBronKeuzeDialoog({
    required this.bronnen,
    required this.huidigeWaarde,
  });

  final List<OpmetingProjectKleurBronOptie> bronnen;
  final String huidigeWaarde;

  @override
  State<_OpmetingProjectKleurBronKeuzeDialoog> createState() =>
      _OpmetingProjectKleurBronKeuzeDialoogState();
}

class _OpmetingProjectKleurBronKeuzeDialoogState
    extends State<_OpmetingProjectKleurBronKeuzeDialoog> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  final TextEditingController _zoekController = TextEditingController();
  OpmetingProjectKleurBronOptie? _gekozenBron;

  @override
  void dispose() {
    _zoekController.dispose();
    super.dispose();
  }

  List<String> get _gefilterdeKleuren {
    final bron = _gekozenBron;
    if (bron == null) return const <String>[];

    final zoek = _zoekController.text.trim().toLowerCase();
    if (zoek.isEmpty) return bron.kleuren;

    return bron.kleuren
        .where((kleur) => kleur.toLowerCase().contains(zoek))
        .toList(growable: false);
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
          maxWidth: 590,
          maxHeight: scherm.height - 44,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _bouwKop(),
            Flexible(
              child: _gekozenBron == null ? _bouwBronnen() : _bouwKleuren(),
            ),
            _bouwActies(),
          ],
        ),
      ),
    );
  }

  Widget _bouwKop() {
    final bron = _gekozenBron;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: const BoxDecoration(
        color: _lichtGroen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Row(
        children: <Widget>[
          if (bron != null)
            IconButton(
              tooltip: 'Terug naar kleurbron',
              visualDensity: VisualDensity.compact,
              onPressed: () {
                setState(() {
                  _gekozenBron = null;
                  _zoekController.clear();
                });
              },
              icon: const Icon(Icons.arrow_back_rounded, color: _groen),
            )
          else
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
              children: <Widget>[
                Text(
                  bron?.label ?? 'Projectkleur kiezen',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _tekstDonker,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bron == null
                      ? 'Kies eerst RAL, Aliplast, Wilms of Feneko.'
                      : 'Zoek daarna de gewenste kleur.',
                  style: const TextStyle(
                    color: _tekstGrijs,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwBronnen() {
    return ListView.separated(
      padding: const EdgeInsets.all(14),
      shrinkWrap: true,
      itemCount: widget.bronnen.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final bron = widget.bronnen[index];

        return Material(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                _gekozenBron = bron;
                _zoekController.clear();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: _rand),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _lichtGroen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.format_color_fill_outlined,
                      color: _groen,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      bron.label,
                      style: const TextStyle(
                        color: _tekstDonker,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '${bron.kleuren.length}',
                    style: const TextStyle(
                      color: _tekstGrijs,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded, color: _tekstGrijs),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _bouwKleuren() {
    final bron = _gekozenBron!;
    final kleuren = _gefilterdeKleuren;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: Column(
        children: <Widget>[
          TextField(
            controller: _zoekController,
            autofocus: bron.kleuren.isNotEmpty,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: 'Zoeken in ${bron.label}',
              isDense: true,
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: _rand),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: _rand),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: _groen, width: 1.4),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: bron.kleuren.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        bron.leegMelding,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _tekstGrijs,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  )
                : kleuren.isEmpty
                ? const Center(
                    child: Text(
                      'Geen kleuren gevonden.',
                      style: TextStyle(
                        color: _tekstGrijs,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: kleuren.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: _rand),
                    itemBuilder: (context, index) {
                      final kleur = kleuren[index];
                      final geselecteerd =
                          kleur.trim() == widget.huidigeWaarde.trim();

                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 1,
                        ),
                        leading: Icon(
                          geselecteerd
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color: geselecteerd ? _groen : _tekstGrijs,
                          size: 18,
                        ),
                        title: Text(
                          kleur,
                          style: TextStyle(
                            color: _tekstDonker,
                            fontSize: 12,
                            fontWeight: geselecteerd
                                ? FontWeight.w900
                                : FontWeight.w700,
                          ),
                        ),
                        onTap: () => Navigator.pop(context, kleur),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _bouwActies() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuleren'),
          ),
        ],
      ),
    );
  }
}
