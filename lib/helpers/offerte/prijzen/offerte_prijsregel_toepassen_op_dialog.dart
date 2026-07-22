import 'package:flutter/material.dart';

class OffertePrijsregelToepassenOpResultaat {
  const OffertePrijsregelToepassenOpResultaat({
    required this.artikelIds,
    required this.kiesNogEenPrijsregel,
  });

  final Set<String> artikelIds;
  final bool kiesNogEenPrijsregel;
}

class OffertePrijsregelToepassenOpKeuze {
  const OffertePrijsregelToepassenOpKeuze({
    required this.artikelId,
    required this.positieLabel,
    required this.artikelLabel,
    required this.groepId,
    required this.groepLabel,
    required this.bedragExclBtw,
    this.beschikbaar = true,
    this.nietBeschikbaarReden = '',
  });

  final String artikelId;
  final String positieLabel;
  final String artikelLabel;
  final String groepId;
  final String groepLabel;
  final double bedragExclBtw;
  final bool beschikbaar;
  final String nietBeschikbaarReden;
}

Future<OffertePrijsregelToepassenOpResultaat?>
toonOffertePrijsregelToepassenOpDialog({
  required BuildContext context,
  required String prijsregelOmschrijving,
  required List<OffertePrijsregelToepassenOpKeuze> keuzes,
}) {
  return showDialog<OffertePrijsregelToepassenOpResultaat>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return _OffertePrijsregelToepassenOpDialog(
        prijsregelOmschrijving: prijsregelOmschrijving,
        keuzes: keuzes,
      );
    },
  );
}

class _OffertePrijsregelToepassenOpDialog extends StatefulWidget {
  const _OffertePrijsregelToepassenOpDialog({
    required this.prijsregelOmschrijving,
    required this.keuzes,
  });

  final String prijsregelOmschrijving;
  final List<OffertePrijsregelToepassenOpKeuze> keuzes;

  @override
  State<_OffertePrijsregelToepassenOpDialog> createState() {
    return _OffertePrijsregelToepassenOpDialogState();
  }
}

class _OffertePrijsregelToepassenOpDialogState
    extends State<_OffertePrijsregelToepassenOpDialog> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  final Set<String> _geselecteerdeArtikelIds = <String>{};

  List<OffertePrijsregelToepassenOpKeuze> get _beschikbareKeuzes {
    return widget.keuzes
        .where((keuze) => keuze.beschikbaar)
        .toList(growable: false);
  }

  Set<String> get _beschikbareArtikelIds {
    return _beschikbareKeuzes.map((keuze) => keuze.artikelId).toSet();
  }

  Map<String, List<OffertePrijsregelToepassenOpKeuze>> get _keuzesPerGroep {
    final groepen = <String, List<OffertePrijsregelToepassenOpKeuze>>{};
    for (final keuze in widget.keuzes) {
      groepen.putIfAbsent(
        keuze.groepId,
        () => <OffertePrijsregelToepassenOpKeuze>[],
      );
      groepen[keuze.groepId]!.add(keuze);
    }
    return groepen;
  }

  bool get _alleBeschikbareGeselecteerd {
    final beschikbareIds = _beschikbareArtikelIds;
    return beschikbareIds.isNotEmpty &&
        _geselecteerdeArtikelIds.length == beschikbareIds.length &&
        _geselecteerdeArtikelIds.containsAll(beschikbareIds);
  }

  bool get _enkeleBeschikbareGeselecteerd {
    return _geselecteerdeArtikelIds.isNotEmpty && !_alleBeschikbareGeselecteerd;
  }

  double get _selectieTotaalExclBtw {
    var totaal = 0.0;
    for (final keuze in _beschikbareKeuzes) {
      if (_geselecteerdeArtikelIds.contains(keuze.artikelId)) {
        totaal += keuze.bedragExclBtw;
      }
    }
    return _rondBedragAf(totaal);
  }

  void _wisselAlles(bool? geselecteerd) {
    setState(() {
      if (geselecteerd == true) {
        _geselecteerdeArtikelIds
          ..clear()
          ..addAll(_beschikbareArtikelIds);
      } else {
        _geselecteerdeArtikelIds.clear();
      }
    });
  }

  void _wisselGroep(
    List<OffertePrijsregelToepassenOpKeuze> groepKeuzes,
    bool? geselecteerd,
  ) {
    final beschikbareGroepIds = groepKeuzes
        .where((keuze) => keuze.beschikbaar)
        .map((keuze) => keuze.artikelId)
        .toSet();

    setState(() {
      if (geselecteerd == true) {
        _geselecteerdeArtikelIds.addAll(beschikbareGroepIds);
      } else {
        _geselecteerdeArtikelIds.removeAll(beschikbareGroepIds);
      }
    });
  }

  void _wisselArtikel(
    OffertePrijsregelToepassenOpKeuze keuze,
    bool? geselecteerd,
  ) {
    if (!keuze.beschikbaar) return;

    setState(() {
      if (geselecteerd == true) {
        _geselecteerdeArtikelIds.add(keuze.artikelId);
      } else {
        _geselecteerdeArtikelIds.remove(keuze.artikelId);
      }
    });
  }

  bool _heleGroepGeselecteerd(
    List<OffertePrijsregelToepassenOpKeuze> groepKeuzes,
  ) {
    final beschikbareIds = groepKeuzes
        .where((keuze) => keuze.beschikbaar)
        .map((keuze) => keuze.artikelId)
        .toSet();
    return beschikbareIds.isNotEmpty &&
        _geselecteerdeArtikelIds.containsAll(beschikbareIds);
  }

  bool _deelVanGroepGeselecteerd(
    List<OffertePrijsregelToepassenOpKeuze> groepKeuzes,
  ) {
    final beschikbareIds = groepKeuzes
        .where((keuze) => keuze.beschikbaar)
        .map((keuze) => keuze.artikelId)
        .toSet();
    final geselecteerdAantal = beschikbareIds
        .where(_geselecteerdeArtikelIds.contains)
        .length;
    return geselecteerdAantal > 0 && geselecteerdAantal < beschikbareIds.length;
  }

  String _bedrag(double waarde) {
    final veilig = waarde.isFinite && waarde > 0.0 ? waarde : 0.0;
    return '€ ${veilig.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  double _rondBedragAf(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) return 0.0;
    return (waarde * 100.0).roundToDouble() / 100.0;
  }

  void _sluitMetResultaat({required bool kiesNogEenPrijsregel}) {
    if (_geselecteerdeArtikelIds.isEmpty) return;

    Navigator.of(context).pop(
      OffertePrijsregelToepassenOpResultaat(
        artikelIds: Set<String>.unmodifiable(_geselecteerdeArtikelIds),
        kiesNogEenPrijsregel: kiesNogEenPrijsregel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scherm = MediaQuery.sizeOf(context);
    final breedte = (scherm.width - 28).clamp(320.0, 860.0).toDouble();
    final hoogte = (scherm.height - 48).clamp(420.0, 760.0).toDouble();
    final groepen = _keuzesPerGroep.entries.toList(growable: false);
    final heeftSelectie = _geselecteerdeArtikelIds.isNotEmpty;

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.all(14),
      contentPadding: EdgeInsets.zero,
      actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 12, 14),
        decoration: const BoxDecoration(
          color: _lichtGroen,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          border: Border(bottom: BorderSide(color: _rand)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: _rand),
              ),
              child: const Icon(
                Icons.rule_folder_outlined,
                color: _groen,
                size: 21,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kies uw artikelen',
                    style: TextStyle(
                      color: _tekstDonker,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.prijsregelOmschrijving,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _tekstGrijs,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Sluiten',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: breedte,
        height: hoogte,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _rand)),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _alleBeschikbareGeselecteerd
                        ? true
                        : _enkeleBeschikbareGeselecteerd
                        ? null
                        : false,
                    tristate: true,
                    activeColor: _groen,
                    onChanged: _wisselAlles,
                  ),
                  const Expanded(
                    child: Text(
                      'Alle artikelen',
                      style: TextStyle(
                        color: _tekstDonker,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '${_geselecteerdeArtikelIds.length} / ${_beschikbareKeuzes.length}',
                    style: const TextStyle(
                      color: _groen,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: groepen.isEmpty
                  ? const Center(
                      child: Text(
                        'Er zijn geen overzichtsposities beschikbaar.',
                        style: TextStyle(
                          color: _tekstGrijs,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      itemCount: groepen.length,
                      itemBuilder: (context, groepIndex) {
                        final groep = groepen[groepIndex];
                        final groepKeuzes = groep.value;
                        final groepLabel = groepKeuzes.isEmpty
                            ? groep.key
                            : groepKeuzes.first.groepLabel;
                        final heleGroep = _heleGroepGeselecteerd(groepKeuzes);
                        final deelGroep = _deelVanGroepGeselecteerd(
                          groepKeuzes,
                        );
                        final groepBeschikbaar = groepKeuzes.any(
                          (keuze) => keuze.beschikbaar,
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: _rand),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFAFAFA),
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(13),
                                  ),
                                  border: Border(
                                    bottom: BorderSide(color: _rand),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: heleGroep
                                          ? true
                                          : deelGroep
                                          ? null
                                          : false,
                                      tristate: true,
                                      activeColor: _groen,
                                      onChanged: groepBeschikbaar
                                          ? (waarde) => _wisselGroep(
                                              groepKeuzes,
                                              waarde,
                                            )
                                          : null,
                                    ),
                                    Expanded(
                                      child: Text(
                                        groepLabel,
                                        style: const TextStyle(
                                          color: _tekstDonker,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${groepKeuzes.where((keuze) => keuze.beschikbaar).length} posities',
                                      style: const TextStyle(
                                        color: _tekstGrijs,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              for (
                                var index = 0;
                                index < groepKeuzes.length;
                                index++
                              )
                                _bouwArtikelRij(
                                  groepKeuzes[index],
                                  toonOnderRand: index < groepKeuzes.length - 1,
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              decoration: const BoxDecoration(
                color: _lichtGroen,
                border: Border(top: BorderSide(color: _rand)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selectietotaal excl. btw',
                          style: TextStyle(
                            color: _tekstDonker,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _geselecteerdeArtikelIds.length == 1
                              ? '1 geselecteerde positie'
                              : '${_geselecteerdeArtikelIds.length} geselecteerde posities',
                          style: const TextStyle(
                            color: _tekstGrijs,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _bedrag(_selectieTotaalExclBtw),
                    style: const TextStyle(
                      color: _groen,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuleren'),
        ),
        OutlinedButton.icon(
          onPressed: heeftSelectie
              ? () => _sluitMetResultaat(kiesNogEenPrijsregel: true)
              : null,
          icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
          label: const Text('Toepassen en nog een prijsregel kiezen'),
        ),
        FilledButton.icon(
          onPressed: heeftSelectie
              ? () => _sluitMetResultaat(kiesNogEenPrijsregel: false)
              : null,
          style: FilledButton.styleFrom(backgroundColor: _groen),
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('Toepassen op offerte'),
        ),
      ],
    );
  }

  Widget _bouwArtikelRij(
    OffertePrijsregelToepassenOpKeuze keuze, {
    required bool toonOnderRand,
  }) {
    final geselecteerd = _geselecteerdeArtikelIds.contains(keuze.artikelId);

    return InkWell(
      onTap: keuze.beschikbaar
          ? () => _wisselArtikel(keuze, !geselecteerd)
          : null,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
        decoration: BoxDecoration(
          color: geselecteerd ? _lichtGroen.withValues(alpha: 0.42) : null,
          border: toonOnderRand
              ? const Border(bottom: BorderSide(color: _rand))
              : null,
        ),
        child: Row(
          children: [
            Checkbox(
              value: geselecteerd,
              activeColor: _groen,
              onChanged: keuze.beschikbaar
                  ? (waarde) => _wisselArtikel(keuze, waarde)
                  : null,
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    keuze.positieLabel,
                    style: TextStyle(
                      color: keuze.beschikbaar ? _tekstDonker : _tekstGrijs,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    keuze.beschikbaar
                        ? keuze.artikelLabel
                        : keuze.nietBeschikbaarReden,
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
            const SizedBox(width: 10),
            Text(
              keuze.beschikbaar
                  ? _bedrag(keuze.bedragExclBtw)
                  : 'Niet mogelijk',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: keuze.beschikbaar ? _groen : _tekstGrijs,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
