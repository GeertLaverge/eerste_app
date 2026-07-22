import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef OfferteArtikelCorrectieBedragBerekenaar =
    double Function(double percentage);

class OfferteArtikelToepassenOpResultaat {
  const OfferteArtikelToepassenOpResultaat({
    required this.artikelIds,
    required this.percentage,
  });

  final Set<String> artikelIds;
  final double percentage;
}

class OfferteArtikelToepassenOpKeuze {
  const OfferteArtikelToepassenOpKeuze({
    required this.artikelId,
    required this.positieLabel,
    required this.artikelLabel,
    required this.groepId,
    required this.groepLabel,
    required this.berekenCorrectieBedragExclBtw,
    this.isHuidigArtikel = false,
    this.beschikbaar = true,
    this.nietBeschikbaarReden = '',
  });

  final String artikelId;
  final String positieLabel;
  final String artikelLabel;
  final String groepId;
  final String groepLabel;
  final OfferteArtikelCorrectieBedragBerekenaar berekenCorrectieBedragExclBtw;
  final bool isHuidigArtikel;
  final bool beschikbaar;
  final String nietBeschikbaarReden;
}

Future<OfferteArtikelToepassenOpResultaat?>
toonOfferteArtikelToepassenOpDialog({
  required BuildContext context,
  required String titel,
  required bool isKorting,
  required double percentage,
  required List<OfferteArtikelToepassenOpKeuze> keuzes,
  required Set<String> initieelGeselecteerdeArtikelIds,
}) {
  return showDialog<OfferteArtikelToepassenOpResultaat>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return _OfferteArtikelToepassenOpDialog(
        titel: titel,
        isKorting: isKorting,
        percentage: percentage,
        keuzes: keuzes,
        initieelGeselecteerdeArtikelIds: initieelGeselecteerdeArtikelIds,
      );
    },
  );
}

class _OfferteArtikelToepassenOpDialog extends StatefulWidget {
  const _OfferteArtikelToepassenOpDialog({
    required this.titel,
    required this.isKorting,
    required this.percentage,
    required this.keuzes,
    required this.initieelGeselecteerdeArtikelIds,
  });

  final String titel;
  final bool isKorting;
  final double percentage;
  final List<OfferteArtikelToepassenOpKeuze> keuzes;
  final Set<String> initieelGeselecteerdeArtikelIds;

  @override
  State<_OfferteArtikelToepassenOpDialog> createState() {
    return _OfferteArtikelToepassenOpDialogState();
  }
}

class _OfferteArtikelToepassenOpDialogState
    extends State<_OfferteArtikelToepassenOpDialog> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  late final TextEditingController _percentageController;
  late final FocusNode _percentageFocusNode;
  late Set<String> _geselecteerdeArtikelIds;

  List<OfferteArtikelToepassenOpKeuze> get _beschikbareKeuzes {
    return widget.keuzes
        .where((keuze) => keuze.beschikbaar)
        .toList(growable: false);
  }

  Set<String> get _beschikbareArtikelIds {
    return _beschikbareKeuzes.map((keuze) => keuze.artikelId).toSet();
  }

  Map<String, List<OfferteArtikelToepassenOpKeuze>> get _keuzesPerGroep {
    final groepen = <String, List<OfferteArtikelToepassenOpKeuze>>{};
    for (final keuze in widget.keuzes) {
      groepen.putIfAbsent(
        keuze.groepId,
        () => <OfferteArtikelToepassenOpKeuze>[],
      );
      groepen[keuze.groepId]!.add(keuze);
    }
    return groepen;
  }

  @override
  void initState() {
    super.initState();
    _percentageController = TextEditingController(
      text: _percentageInvoerTekst(widget.percentage),
    );
    _percentageFocusNode = FocusNode();
    _geselecteerdeArtikelIds = widget.initieelGeselecteerdeArtikelIds
        .intersection(_beschikbareArtikelIds);

    if (_geselecteerdeArtikelIds.isEmpty) {
      final huidigeKeuze = widget.keuzes.where(
        (keuze) => keuze.isHuidigArtikel && keuze.beschikbaar,
      );
      if (huidigeKeuze.isNotEmpty) {
        _geselecteerdeArtikelIds = <String>{huidigeKeuze.first.artikelId};
      }
    }
  }

  @override
  void dispose() {
    _percentageController.dispose();
    _percentageFocusNode.dispose();
    super.dispose();
  }

  double get _maximumPercentage => widget.isKorting ? 100.0 : 500.0;

  double get _ingevoerdPercentage {
    final gelezen =
        double.tryParse(
          _percentageController.text.trim().replaceAll(',', '.'),
        ) ??
        0.0;
    if (!gelezen.isFinite || gelezen <= 0.0) {
      return 0.0;
    }
    return gelezen.clamp(0.0, _maximumPercentage).toDouble();
  }

  String _percentageInvoerTekst(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) {
      return '';
    }

    var tekst = waarde
        .clamp(0.0, _maximumPercentage)
        .toDouble()
        .toStringAsFixed(2)
        .replaceAll('.', ',');
    tekst = tekst.replaceFirst(RegExp(r'0+$'), '');
    tekst = tekst.replaceFirst(RegExp(r',$'), '');
    return tekst;
  }

  TextInputFormatter _percentageFormatter() {
    return TextInputFormatter.withFunction((oudeWaarde, nieuweWaarde) {
      final geldig = RegExp(r'^\d{0,3}([,.]\d{0,2})?$');
      if (!geldig.hasMatch(nieuweWaarde.text)) {
        return oudeWaarde;
      }

      final rauw = double.tryParse(
        nieuweWaarde.text.trim().replaceAll(',', '.'),
      );
      if (rauw != null && rauw > _maximumPercentage) {
        return oudeWaarde;
      }
      return nieuweWaarde;
    });
  }

  void _verwerkPercentageWijziging(String _) {
    setState(() {});
  }

  void _normaliseerPercentage() {
    final percentage = _ingevoerdPercentage;
    final tekst = _percentageInvoerTekst(percentage);
    _percentageController.value = TextEditingValue(
      text: tekst,
      selection: TextSelection.collapsed(offset: tekst.length),
    );
    setState(() {});
  }

  void _selecteerAlleBeschikbare() {
    setState(() {
      _geselecteerdeArtikelIds = _beschikbareArtikelIds;
    });
  }

  void _selecteerAlleenHuidigArtikel() {
    final huidigeKeuze = widget.keuzes.where(
      (keuze) => keuze.isHuidigArtikel && keuze.beschikbaar,
    );
    if (huidigeKeuze.isEmpty) {
      return;
    }

    setState(() {
      _geselecteerdeArtikelIds = <String>{huidigeKeuze.first.artikelId};
    });
  }

  void _selecteerHuidigeGroep() {
    final huidigeKeuze = widget.keuzes.where((keuze) => keuze.isHuidigArtikel);
    if (huidigeKeuze.isEmpty) {
      return;
    }

    final groepId = huidigeKeuze.first.groepId;
    final groepIds = widget.keuzes
        .where((keuze) => keuze.groepId == groepId && keuze.beschikbaar)
        .map((keuze) => keuze.artikelId)
        .toSet();
    if (groepIds.isEmpty) {
      return;
    }

    setState(() {
      _geselecteerdeArtikelIds = groepIds;
    });
  }

  void _wisSelectie() {
    setState(() {
      _geselecteerdeArtikelIds = <String>{};
    });
  }

  void _wisselKeuze(OfferteArtikelToepassenOpKeuze keuze, bool geselecteerd) {
    if (!keuze.beschikbaar) {
      return;
    }

    setState(() {
      if (geselecteerd) {
        _geselecteerdeArtikelIds.add(keuze.artikelId);
      } else {
        _geselecteerdeArtikelIds.remove(keuze.artikelId);
      }
    });
  }

  void _wisselGroep(
    List<OfferteArtikelToepassenOpKeuze> groepKeuzes,
    bool geselecteerd,
  ) {
    final groepIds = groepKeuzes
        .where((keuze) => keuze.beschikbaar)
        .map((keuze) => keuze.artikelId)
        .toSet();
    if (groepIds.isEmpty) {
      return;
    }

    setState(() {
      if (geselecteerd) {
        _geselecteerdeArtikelIds.addAll(groepIds);
      } else {
        _geselecteerdeArtikelIds.removeAll(groepIds);
      }
    });
  }

  String _groepTitel(String label, int aantal) {
    if (aantal == 1) {
      return label;
    }

    return switch (label.trim().toLowerCase()) {
      'pvc raam' => 'PVC ramen',
      'alu raam' => 'ALU ramen',
      'pvc schuifraam' => 'PVC schuiframen',
      'alu schuifraam' => 'ALU schuiframen',
      'pvc deur' => 'PVC deuren',
      'alu deur' => 'ALU deuren',
      'vaste inzethor' => 'Vaste inzethorren',
      _ => label,
    };
  }

  String _groepAantalTekst({
    required int totaalAantal,
    required int beschikbaarAantal,
    required int geselecteerdAantal,
    required bool deelsGeselecteerd,
  }) {
    if (deelsGeselecteerd) {
      return '$geselecteerdAantal/$beschikbaarAantal geselecteerd';
    }
    if (beschikbaarAantal < totaalAantal) {
      return '$beschikbaarAantal toepasbaar · $totaalAantal totaal';
    }
    return '$totaalAantal artikel${totaalAantal == 1 ? '' : 'en'}';
  }

  String _selectieTekst() {
    final aantal = _geselecteerdeArtikelIds.length;
    if (aantal == 1) {
      return '1 artikel geselecteerd';
    }
    return '$aantal artikelen geselecteerd';
  }

  double _correctieBedragVoorKeuze(OfferteArtikelToepassenOpKeuze keuze) {
    if (!keuze.beschikbaar || _ingevoerdPercentage <= 0.0) {
      return 0.0;
    }
    final bedrag = keuze.berekenCorrectieBedragExclBtw(_ingevoerdPercentage);
    return bedrag.isFinite ? bedrag : 0.0;
  }

  double _geselecteerdTotaal() {
    return widget.keuzes
        .where(
          (keuze) =>
              keuze.beschikbaar &&
              _geselecteerdeArtikelIds.contains(keuze.artikelId),
        )
        .fold<double>(
          0.0,
          (som, keuze) => som + _correctieBedragVoorKeuze(keuze),
        );
  }

  String _percentageTekst() {
    final tekst = _percentageInvoerTekst(_ingevoerdPercentage);
    return '${tekst.isEmpty ? '0' : tekst}%';
  }

  String _bedrag(double waarde) {
    final absoluut = waarde.abs().toStringAsFixed(2).replaceAll('.', ',');
    return '${widget.isKorting ? '- ' : '+ '}€ $absoluut';
  }

  @override
  Widget build(BuildContext context) {
    final heeftSelectie = _geselecteerdeArtikelIds.isNotEmpty;
    final heeftGeldigPercentage = _ingevoerdPercentage > 0.0;
    final alleBeschikbareGeselecteerd =
        _beschikbareArtikelIds.isNotEmpty &&
        _geselecteerdeArtikelIds.length == _beschikbareArtikelIds.length;
    final groepen = _keuzesPerGroep.entries.toList(growable: false);
    final geselecteerdTotaal = _geselecteerdTotaal();
    final dialoogHoogte = (MediaQuery.sizeOf(context).height - 180.0)
        .clamp(500.0, 690.0)
        .toDouble();

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      actionsPadding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 12, 14),
        decoration: const BoxDecoration(
          color: _lichtGroen,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Row(
          children: [
            const Icon(Icons.library_add_check_rounded, color: _groen),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.titel} toepassen op…',
                    style: const TextStyle(
                      color: _tekstDonker,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Kies afzonderlijke posities, volledige artikelgroepen of alle artikelen.',
                    style: TextStyle(
                      color: _tekstGrijs,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Sluiten',
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close_rounded, color: _tekstGrijs),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: 650,
        height: dialoogHoogte,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _selecteerAlleenHuidigArtikel,
                    icon: const Icon(Icons.radio_button_checked_rounded),
                    label: const Text('Huidig artikel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _groen,
                      side: const BorderSide(color: _rand),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _selecteerHuidigeGroep,
                    icon: const Icon(Icons.view_list_rounded),
                    label: const Text('Huidige groep'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _groen,
                      side: const BorderSide(color: _rand),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: alleBeschikbareGeselecteerd
                        ? null
                        : _selecteerAlleBeschikbare,
                    icon: const Icon(Icons.done_all_rounded),
                    label: const Text('Alle artikelen'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _groen,
                      side: const BorderSide(color: _rand),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: heeftSelectie ? _wisSelectie : null,
                    icon: const Icon(Icons.remove_done_rounded),
                    label: const Text('Selectie wissen'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _tekstGrijs,
                      side: const BorderSide(color: _rand),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
              child: Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: heeftGeldigPercentage
                        ? const Color(0xFFBBF7D0)
                        : const Color(0xFFFCA5A5),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isKorting
                                ? 'Kortingpercentage'
                                : 'Winstmargepercentage',
                            style: const TextStyle(
                              color: _tekstDonker,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            heeftGeldigPercentage
                                ? 'De bedragen hieronder worden meteen herberekend.'
                                : 'Vul eerst een percentage groter dan 0 in.',
                            style: TextStyle(
                              color: heeftGeldigPercentage
                                  ? _tekstGrijs
                                  : const Color(0xFFDC2626),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    SizedBox(
                      width: 132,
                      child: TextField(
                        controller: _percentageController,
                        focusNode: _percentageFocusNode,
                        autofocus: widget.percentage <= 0.0,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: <TextInputFormatter>[
                          _percentageFormatter(),
                        ],
                        decoration: InputDecoration(
                          labelText: widget.isKorting ? 'Korting' : 'Winst',
                          hintText: '0',
                          suffixText: '%',
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.fromLTRB(
                            11,
                            12,
                            11,
                            12,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: BorderSide(
                              color: heeftGeldigPercentage
                                  ? _rand
                                  : const Color(0xFFFCA5A5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: const BorderSide(
                              color: _groen,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onChanged: _verwerkPercentageWijziging,
                        onSubmitted: (_) {
                          _normaliseerPercentage();
                        },
                        onTapOutside: (_) {
                          _percentageFocusNode.unfocus();
                          _normaliseerPercentage();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
              child: Text(
                _selectieTekst(),
                style: TextStyle(
                  color: heeftSelectie ? _groen : const Color(0xFFDC2626),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Divider(height: 1, color: _rand),
            Expanded(
              child: widget.keuzes.isEmpty
                  ? const Center(
                      child: Text(
                        'Geen geschikte artikelen gevonden.',
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
                        final beschikbareGroepKeuzes = groepKeuzes
                            .where((keuze) => keuze.beschikbaar)
                            .toList(growable: false);
                        final geselecteerdAantal = beschikbareGroepKeuzes
                            .where(
                              (keuze) => _geselecteerdeArtikelIds.contains(
                                keuze.artikelId,
                              ),
                            )
                            .length;
                        final groepVolledigGeselecteerd =
                            beschikbareGroepKeuzes.isNotEmpty &&
                            geselecteerdAantal == beschikbareGroepKeuzes.length;
                        final groepDeelsGeselecteerd =
                            geselecteerdAantal > 0 &&
                            !groepVolledigGeselecteerd;

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: groepIndex < groepen.length - 1 ? 12 : 0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(color: _rand),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Material(
                                  color: _lichtGroen,
                                  child: InkWell(
                                    onTap: beschikbareGroepKeuzes.isEmpty
                                        ? null
                                        : () {
                                            _wisselGroep(
                                              groepKeuzes,
                                              !groepVolledigGeselecteerd,
                                            );
                                          },
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        10,
                                        8,
                                        12,
                                        8,
                                      ),
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            value: groepDeelsGeselecteerd
                                                ? null
                                                : groepVolledigGeselecteerd,
                                            tristate: true,
                                            onChanged:
                                                beschikbareGroepKeuzes.isEmpty
                                                ? null
                                                : (_) {
                                                    _wisselGroep(
                                                      groepKeuzes,
                                                      !groepVolledigGeselecteerd,
                                                    );
                                                  },
                                            activeColor: _groen,
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              _groepTitel(
                                                groepKeuzes.first.groepLabel,
                                                groepKeuzes.length,
                                              ),
                                              style: const TextStyle(
                                                color: _tekstDonker,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            _groepAantalTekst(
                                              totaalAantal: groepKeuzes.length,
                                              beschikbaarAantal:
                                                  beschikbareGroepKeuzes.length,
                                              geselecteerdAantal:
                                                  geselecteerdAantal,
                                              deelsGeselecteerd:
                                                  groepDeelsGeselecteerd,
                                            ),
                                            style: const TextStyle(
                                              color: _tekstGrijs,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                ...List<Widget>.generate(groepKeuzes.length, (
                                  index,
                                ) {
                                  final keuze = groepKeuzes[index];
                                  final geselecteerd = _geselecteerdeArtikelIds
                                      .contains(keuze.artikelId);

                                  return Material(
                                    color: keuze.beschikbaar
                                        ? Colors.white
                                        : const Color(0xFFF9FAFB),
                                    child: InkWell(
                                      onTap: keuze.beschikbaar
                                          ? () {
                                              _wisselKeuze(
                                                keuze,
                                                !geselecteerd,
                                              );
                                            }
                                          : null,
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                          10,
                                          7,
                                          12,
                                          7,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                              color: index == 0
                                                  ? _rand
                                                  : const Color(0xFFF0F1F3),
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              value: geselecteerd,
                                              onChanged: keuze.beschikbaar
                                                  ? (waarde) {
                                                      _wisselKeuze(
                                                        keuze,
                                                        waarde ?? false,
                                                      );
                                                    }
                                                  : null,
                                              activeColor: _groen,
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          keuze.positieLabel,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            color:
                                                                keuze
                                                                    .beschikbaar
                                                                ? _tekstDonker
                                                                : _tekstGrijs,
                                                            fontSize: 12.5,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                          ),
                                                        ),
                                                      ),
                                                      if (keuze
                                                          .isHuidigArtikel) ...[
                                                        const SizedBox(
                                                          width: 7,
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 7,
                                                                vertical: 3,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: _lichtGroen,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  99,
                                                                ),
                                                          ),
                                                          child: const Text(
                                                            'HUIDIG',
                                                            style: TextStyle(
                                                              color: _groen,
                                                              fontSize: 8.5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    keuze.artikelLabel,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: _tekstGrijs,
                                                      fontSize: 10.5,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  if (!keuze.beschikbaar &&
                                                      keuze.nietBeschikbaarReden
                                                          .trim()
                                                          .isNotEmpty) ...[
                                                    const SizedBox(height: 3),
                                                    Text(
                                                      keuze.nietBeschikbaarReden
                                                          .trim(),
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFFEA580C,
                                                        ),
                                                        fontSize: 9.5,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              keuze.beschikbaar
                                                  ? _bedrag(
                                                      _correctieBedragVoorKeuze(
                                                        keuze,
                                                      ),
                                                    )
                                                  : 'Niet toepasbaar',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                color: keuze.beschikbaar
                                                    ? _groen
                                                    : _tekstGrijs,
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
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
                        Text(
                          '${widget.isKorting ? 'Totale korting' : 'Totale winstmarge'} op selectie',
                          style: const TextStyle(
                            color: _tekstDonker,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_selectieTekst()} · ${_percentageTekst()}',
                          style: const TextStyle(
                            color: _tekstGrijs,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _bedrag(geselecteerdTotaal),
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
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Annuleren'),
        ),
        FilledButton.icon(
          onPressed: heeftSelectie && heeftGeldigPercentage
              ? () {
                  _normaliseerPercentage();
                  Navigator.of(context).pop(
                    OfferteArtikelToepassenOpResultaat(
                      artikelIds: Set<String>.unmodifiable(
                        _geselecteerdeArtikelIds,
                      ),
                      percentage: _ingevoerdPercentage,
                    ),
                  );
                }
              : null,
          icon: const Icon(Icons.check_rounded),
          label: const Text('Toepassen'),
          style: FilledButton.styleFrom(backgroundColor: _groen),
        ),
      ],
    );
  }
}
