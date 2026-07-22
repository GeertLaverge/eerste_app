import 'package:flutter/material.dart';

import '../../../paginas/instellingen/offerte_prijzen/offerte_prijsregel_dialog.dart';
import 'offerte_prijs_categorie.dart';
import 'offerte_prijsregel_model.dart';

/// De actie die onderaan een tijdelijk prijsregelvenster gekozen werd.
enum OffertePrijsregelsVensterActie {
  toepassenOpDezePositie,
  toepassenOpAlleGelijkePosities,
  toepassenOpOfferte,
  bewarenInInstellingen,
}

class OffertePrijsregelsVensterResultaat {
  const OffertePrijsregelsVensterResultaat({
    required this.actie,
    required this.prijsregels,
    this.gekozenPrijsregel,
  });

  final OffertePrijsregelsVensterActie actie;
  final List<OffertePrijsregelModel> prijsregels;
  final OffertePrijsregelModel? gekozenPrijsregel;
}

Future<OffertePrijsregelsVensterResultaat?>
toonOffertePrijsregelsZwevendVenster({
  required BuildContext context,
  required String titel,
  required String subtitel,
  required String formulierType,
  required OffertePrijsCategorie categorie,
  List<OffertePrijsregelModel> beginPrijsregels =
      const <OffertePrijsregelModel>[],
  bool toonToepassenOpDezePositie = false,
  bool toonToepassenOpAlleGelijkePosities = false,
  bool toonToepassenOpOfferte = false,
  bool behoudFormulierTypePerRegel = false,
  Map<String, String> formulierTypeLabels = const <String, String>{},
  bool toonBeheerActies = true,
  bool toonFormulierTypeBijRegel = false,
}) {
  return showGeneralDialog<OffertePrijsregelsVensterResultaat>(
    context: context,
    barrierDismissible: false,
    barrierLabel: titel,
    barrierColor: Colors.black.withValues(alpha: 0.20),
    transitionDuration: const Duration(milliseconds: 160),
    pageBuilder: (dialogContext, animatie, tweedeAnimatie) {
      return _OffertePrijsregelsZwevendVenster(
        titel: titel,
        subtitel: subtitel,
        formulierType: formulierType,
        categorie: categorie,
        beginPrijsregels: beginPrijsregels,
        toonToepassenOpDezePositie: toonToepassenOpDezePositie,
        toonToepassenOpAlleGelijkePosities: toonToepassenOpAlleGelijkePosities,
        toonToepassenOpOfferte: toonToepassenOpOfferte,
        behoudFormulierTypePerRegel: behoudFormulierTypePerRegel,
        formulierTypeLabels: formulierTypeLabels,
        toonBeheerActies: toonBeheerActies,
        toonFormulierTypeBijRegel: toonFormulierTypeBijRegel,
      );
    },
    transitionBuilder: (context, animatie, tweedeAnimatie, child) {
      return FadeTransition(opacity: animatie, child: child);
    },
  );
}

class _OffertePrijsregelsZwevendVenster extends StatefulWidget {
  const _OffertePrijsregelsZwevendVenster({
    required this.titel,
    required this.subtitel,
    required this.formulierType,
    required this.categorie,
    required this.beginPrijsregels,
    required this.toonToepassenOpDezePositie,
    required this.toonToepassenOpAlleGelijkePosities,
    required this.toonToepassenOpOfferte,
    required this.behoudFormulierTypePerRegel,
    required this.formulierTypeLabels,
    required this.toonBeheerActies,
    required this.toonFormulierTypeBijRegel,
  });

  final String titel;
  final String subtitel;
  final String formulierType;
  final OffertePrijsCategorie categorie;
  final List<OffertePrijsregelModel> beginPrijsregels;
  final bool toonToepassenOpDezePositie;
  final bool toonToepassenOpAlleGelijkePosities;
  final bool toonToepassenOpOfferte;
  final bool behoudFormulierTypePerRegel;
  final Map<String, String> formulierTypeLabels;
  final bool toonBeheerActies;
  final bool toonFormulierTypeBijRegel;

  @override
  State<_OffertePrijsregelsZwevendVenster> createState() =>
      _OffertePrijsregelsZwevendVensterState();
}

class _OffertePrijsregelsZwevendVensterState
    extends State<_OffertePrijsregelsZwevendVenster> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  late List<OffertePrijsregelModel> _regels;
  String? _gekozenPrijsregelSleutel;
  Offset? _positie;

  @override
  void initState() {
    super.initState();
    _regels = widget.beginPrijsregels
        .map(
          (regel) => regel.copyWith(
            categorie: widget.categorie,
            formulierType: widget.behoudFormulierTypePerRegel
                ? regel.formulierType
                : widget.formulierType,
          ),
        )
        .toList(growable: true);
    _sorteerRegels();
    _kiesEersteBeschikbarePrijsregel();
  }

  List<OffertePrijsregelFormulierOptie> get _formulierTypeOpties {
    return widget.formulierTypeLabels.entries
        .map((entry) {
          return OffertePrijsregelFormulierOptie(
            formulierType: entry.key,
            label: entry.value,
          );
        })
        .toList(growable: false);
  }

  OffertePrijsregelModel? get _gekozenPrijsregel {
    final gekozenSleutel = _gekozenPrijsregelSleutel;
    if (gekozenSleutel == null) return null;

    for (final regel in _regels) {
      if (_regelSleutel(regel) == gekozenSleutel &&
          regel.actief &&
          regel.isGeldig &&
          regel.prijsExclBtw > 0.0) {
        return regel;
      }
    }
    return null;
  }

  void _kiesEersteBeschikbarePrijsregel() {
    final huidigeKeuze = _gekozenPrijsregel;
    if (huidigeKeuze != null) return;

    _gekozenPrijsregelSleutel = null;
    for (final regel in _regels) {
      if (regel.actief && regel.isGeldig && regel.prijsExclBtw > 0.0) {
        _gekozenPrijsregelSleutel = _regelSleutel(regel);
        return;
      }
    }
  }

  void _kiesPrijsregel(OffertePrijsregelModel regel) {
    if (!regel.actief || !regel.isGeldig || regel.prijsExclBtw <= 0.0) {
      return;
    }
    setState(() {
      _gekozenPrijsregelSleutel = _regelSleutel(regel);
    });
  }

  String _regelSleutel(OffertePrijsregelModel regel) {
    return '${_normaliseerFormulierType(regel.formulierType)}|${regel.id}';
  }

  static String _normaliseerFormulierType(String waarde) {
    return waarde.trim().toLowerCase().replaceAll('_', '').replaceAll(' ', '');
  }

  void _sorteerRegels() {
    _regels.sort((eerste, tweede) {
      if (widget.behoudFormulierTypePerRegel) {
        final formulierVergelijking = _formulierTypeLabel(eerste.formulierType)
            .toLowerCase()
            .compareTo(_formulierTypeLabel(tweede.formulierType).toLowerCase());
        if (formulierVergelijking != 0) return formulierVergelijking;
      }

      final volgorde = eerste.volgorde.compareTo(tweede.volgorde);
      if (volgorde != 0) return volgorde;
      return eerste.omschrijving.toLowerCase().compareTo(
        tweede.omschrijving.toLowerCase(),
      );
    });
  }

  int get _volgendeVolgorde {
    if (_regels.isEmpty) return 0;
    final hoogste = _regels
        .map((regel) => regel.volgorde)
        .reduce((eerste, tweede) => eerste > tweede ? eerste : tweede);
    return hoogste + 10;
  }

  Future<void> _voegRegelToe() async {
    final resultaat = await toonOffertePrijsregelDialog(
      context: context,
      categorie: widget.categorie,
      formulierType: widget.formulierType,
      volgendeVolgorde: _volgendeVolgorde,
      formulierTypeOpties: _formulierTypeOpties,
      bevestigKnopTekst: 'Toepassen',
      bevestigKnopIcoon: Icons.check_rounded,
    );

    if (resultaat == null || !mounted) return;

    setState(() {
      _regels.add(resultaat);
      _sorteerRegels();
      if (resultaat.actief &&
          resultaat.isGeldig &&
          resultaat.prijsExclBtw > 0.0) {
        _gekozenPrijsregelSleutel = _regelSleutel(resultaat);
      }
    });
  }

  Future<void> _bewerkRegel(OffertePrijsregelModel regel) async {
    final resultaat = await toonOffertePrijsregelDialog(
      context: context,
      categorie: widget.categorie,
      formulierType: regel.formulierType,
      volgendeVolgorde: regel.volgorde,
      formulierTypeOpties: _formulierTypeOpties,
      bestaandePrijsregel: regel,
      bevestigKnopTekst: 'Toepassen',
      bevestigKnopIcoon: Icons.check_rounded,
    );

    if (resultaat == null || !mounted) return;

    setState(() {
      final index = _regels.indexWhere(
        (item) => _regelSleutel(item) == _regelSleutel(regel),
      );
      if (index >= 0) {
        _regels[index] = resultaat;
      }
      _sorteerRegels();
      if (_gekozenPrijsregelSleutel == _regelSleutel(regel)) {
        _gekozenPrijsregelSleutel = _regelSleutel(resultaat);
      }
      _kiesEersteBeschikbarePrijsregel();
    });
  }

  Future<void> _verwijderRegel(OffertePrijsregelModel regel) async {
    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Prijsregel verwijderen',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            'De prijsregel “${regel.omschrijving}” wordt uit dit prijsregelmenu verwijderd.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuleren'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Verwijderen'),
            ),
          ],
        );
      },
    );

    if (bevestigen != true || !mounted) return;

    setState(() {
      _regels.removeWhere(
        (item) => _regelSleutel(item) == _regelSleutel(regel),
      );
      if (_gekozenPrijsregelSleutel == _regelSleutel(regel)) {
        _gekozenPrijsregelSleutel = null;
      }
      _hernummerVolgorde();
      _kiesEersteBeschikbarePrijsregel();
    });
  }

  void _wisselActief(OffertePrijsregelModel regel, bool actief) {
    setState(() {
      final index = _regels.indexWhere(
        (item) => _regelSleutel(item) == _regelSleutel(regel),
      );
      if (index < 0) return;
      _regels[index] = regel.copyWith(
        actief: actief,
        gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
      );
      if (!actief && _gekozenPrijsregelSleutel == _regelSleutel(regel)) {
        _gekozenPrijsregelSleutel = null;
      }
      _kiesEersteBeschikbarePrijsregel();
    });
  }

  void _verplaatsRegel(OffertePrijsregelModel regel, int richting) {
    final index = _regels.indexWhere(
      (item) => _regelSleutel(item) == _regelSleutel(regel),
    );
    final nieuweIndex = index + richting;
    if (index < 0 || nieuweIndex < 0 || nieuweIndex >= _regels.length) return;

    setState(() {
      final verplaatst = _regels.removeAt(index);
      _regels.insert(nieuweIndex, verplaatst);
      _hernummerVolgorde();
    });
  }

  void _hernummerVolgorde() {
    if (!widget.behoudFormulierTypePerRegel) {
      for (var index = 0; index < _regels.length; index++) {
        _regels[index] = _regels[index].copyWith(volgorde: index * 10);
      }
      return;
    }

    final volgendePerFormulierType = <String, int>{};
    for (var index = 0; index < _regels.length; index++) {
      final regel = _regels[index];
      final sleutel = _normaliseerFormulierType(regel.formulierType);
      final volgnummer = volgendePerFormulierType[sleutel] ?? 0;
      _regels[index] = regel.copyWith(volgorde: volgnummer * 10);
      volgendePerFormulierType[sleutel] = volgnummer + 1;
    }
  }

  void _sluitMetActie(OffertePrijsregelsVensterActie actie) {
    _hernummerVolgorde();
    Navigator.pop(
      context,
      OffertePrijsregelsVensterResultaat(
        actie: actie,
        prijsregels: List<OffertePrijsregelModel>.unmodifiable(_regels),
        gekozenPrijsregel: _gekozenPrijsregel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scherm = MediaQuery.sizeOf(context);
    final vensterBreedte = scherm.width < 592
        ? (scherm.width - 16).clamp(280.0, scherm.width).toDouble()
        : (scherm.width - 32).clamp(560.0, 920.0).toDouble();
    final vensterHoogte = scherm.height < 468
        ? (scherm.height - 16).clamp(300.0, scherm.height).toDouble()
        : (scherm.height - 48).clamp(420.0, 720.0).toDouble();

    final beginPositie = Offset(
      ((scherm.width - vensterBreedte) / 2).clamp(8.0, scherm.width).toDouble(),
      ((scherm.height - vensterHoogte) / 2)
          .clamp(8.0, scherm.height)
          .toDouble(),
    );
    final positie = _positie ?? beginPositie;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: positie.dx,
            top: positie.dy,
            width: vensterBreedte,
            height: vensterHoogte,
            child: Material(
              color: Colors.white,
              elevation: 22,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (details) {
                      final huidige = _positie ?? beginPositie;
                      final maximumX = scherm.width - vensterBreedte - 8;
                      final maximumY = scherm.height - vensterHoogte - 8;
                      setState(() {
                        _positie = Offset(
                          (huidige.dx + details.delta.dx)
                              .clamp(8.0, maximumX < 8.0 ? 8.0 : maximumX)
                              .toDouble(),
                          (huidige.dy + details.delta.dy)
                              .clamp(8.0, maximumY < 8.0 ? 8.0 : maximumY)
                              .toDouble(),
                        );
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(18, 12, 8, 12),
                      color: _lichtGroen,
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.euro_rounded,
                              color: _groen,
                              size: 21,
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  widget.titel,
                                  style: const TextStyle(
                                    color: _tekstDonker,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.subtitel,
                                  style: const TextStyle(
                                    color: _tekstGrijs,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.open_with_rounded,
                            color: _tekstGrijs,
                            size: 19,
                          ),
                          IconButton(
                            tooltip: 'Sluiten',
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 11, 16, 11),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: _rand)),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            widget.categorie.benaming,
                            style: const TextStyle(
                              color: _groen,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _lichtGroen,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${_regels.length}',
                            style: const TextStyle(
                              color: _groen,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (widget.toonBeheerActies) ...<Widget>[
                          const SizedBox(width: 10),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: _groen,
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: _voegRegelToe,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Toevoegen'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    child: _regels.isEmpty
                        ? const Center(
                            child: Text(
                              'Nog geen prijsregels toegevoegd. Gebruik Toevoegen om de eerste prijsregel te maken.',
                              style: TextStyle(
                                color: _tekstGrijs,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            itemCount: _regels.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1, color: _rand),
                            itemBuilder: (context, index) {
                              final regel = _regels[index];
                              return _bouwPrijsregelRij(regel, index);
                            },
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFAFAFA),
                      border: Border(top: BorderSide(color: _rand)),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Annuleren'),
                        ),
                        if (widget.toonToepassenOpDezePositie)
                          OutlinedButton(
                            onPressed: () => _sluitMetActie(
                              OffertePrijsregelsVensterActie
                                  .toepassenOpDezePositie,
                            ),
                            child: const Text('Toepassen'),
                          ),
                        if (widget.toonToepassenOpAlleGelijkePosities)
                          OutlinedButton(
                            onPressed: () => _sluitMetActie(
                              OffertePrijsregelsVensterActie
                                  .toepassenOpAlleGelijkePosities,
                            ),
                            child: const Text(
                              'Toepassen op alle gelijke posities',
                            ),
                          ),
                        if (widget.toonToepassenOpOfferte)
                          OutlinedButton.icon(
                            onPressed: _gekozenPrijsregel == null
                                ? null
                                : () => _sluitMetActie(
                                    OffertePrijsregelsVensterActie
                                        .toepassenOpOfferte,
                                  ),
                            icon: const Icon(
                              Icons.rule_folder_outlined,
                              size: 18,
                            ),
                            label: const Text('Kies uw artikelen'),
                          ),
                        if (widget.toonBeheerActies)
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: _groen,
                            ),
                            onPressed: () => _sluitMetActie(
                              OffertePrijsregelsVensterActie
                                  .bewarenInInstellingen,
                            ),
                            icon: const Icon(Icons.save_outlined, size: 18),
                            label: const Text('Bewaren'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwPrijsregelRij(OffertePrijsregelModel regel, int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (widget.toonToepassenOpOfferte) ...<Widget>[
            IconButton(
              tooltip: _gekozenPrijsregelSleutel == _regelSleutel(regel)
                  ? 'Gekozen prijsregel'
                  : 'Deze prijsregel kiezen',
              visualDensity: VisualDensity.compact,
              onPressed:
                  regel.actief && regel.isGeldig && regel.prijsExclBtw > 0.0
                  ? () => _kiesPrijsregel(regel)
                  : null,
              icon: Icon(
                _gekozenPrijsregelSleutel == _regelSleutel(regel)
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: _gekozenPrijsregelSleutel == _regelSleutel(regel)
                    ? _groen
                    : _tekstGrijs,
              ),
            ),
            const SizedBox(width: 2),
          ],
          if (widget.toonBeheerActies) ...<Widget>[
            Switch.adaptive(
              value: regel.actief,
              activeThumbColor: _groen,
              onChanged: (waarde) => _wisselActief(regel, waarde),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  regel.omschrijving,
                  style: TextStyle(
                    color: regel.actief ? _tekstDonker : _tekstGrijs,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (widget.toonFormulierTypeBijRegel) ...<Widget>[
                  const SizedBox(height: 3),
                  Text(
                    _formulierTypeLabel(regel.formulierType),
                    style: const TextStyle(
                      color: _groen,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                const SizedBox(height: 3),
                Text(
                  '${regel.eenheid.benaming}  ·  ${regel.uitschrijfmodus.benaming}',
                  style: const TextStyle(
                    color: _tekstGrijs,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_formatteerEuro(regel.prijsExclBtw)} excl. btw',
                  style: const TextStyle(
                    color: _tekstDonker,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          if (widget.toonBeheerActies)
            Column(
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      tooltip: 'Omhoog',
                      visualDensity: VisualDensity.compact,
                      onPressed: index > 0
                          ? () => _verplaatsRegel(regel, -1)
                          : null,
                      icon: const Icon(Icons.keyboard_arrow_up_rounded),
                    ),
                    IconButton(
                      tooltip: 'Omlaag',
                      visualDensity: VisualDensity.compact,
                      onPressed: index < _regels.length - 1
                          ? () => _verplaatsRegel(regel, 1)
                          : null,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      tooltip: 'Aanpassen',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _bewerkRegel(regel),
                      icon: const Icon(Icons.edit_outlined, color: _groen),
                    ),
                    IconButton(
                      tooltip: 'Verwijderen',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _verwijderRegel(regel),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  static String _formulierTypeLabel(String formulierType) {
    return switch (formulierType.trim()) {
      'pvcRaam' => 'PVC raam',
      'aluRaam' => 'ALU raam',
      'pvcSchuifraam' => 'PVC schuifraam',
      'aluSchuifraam' => 'ALU schuifraam',
      'pvcDeur' => 'PVC deur',
      'aluDeur' => 'ALU deur',
      'vasteInzethor' => 'Vaste inzethor',
      final String waarde when waarde.isNotEmpty => waarde,
      _ => 'Artikel',
    };
  }

  static String _formatteerEuro(double waarde) {
    final veilig = waarde.isFinite ? waarde : 0.0;
    return '€ ${veilig.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}
