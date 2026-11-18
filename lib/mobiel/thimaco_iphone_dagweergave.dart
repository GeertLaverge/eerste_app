import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../helpers/Agenda/agenda_item.dart';
import '../helpers/Agenda/agenda_kleur_service.dart';

/// Schermvullende dagagenda met tijdlijn van 00:00 tot 24:00.
/// Veeg horizontaal voor een andere dag en verticaal voor andere uren.
class ThimacoIphoneDagweergave extends StatefulWidget {
  const ThimacoIphoneDagweergave({
    super.key,
    required this.beginDag,
    required this.itemsVoor,
    required this.voegAfspraakToe,
    required this.herlaad,
    required this.verwijderAfspraak,
    this.geselecteerd,
  });

  final DateTime beginDag;
  final List<AgendaItem> Function(DateTime dag) itemsVoor;
  final Future<void> Function(DateTime dag) voegAfspraakToe;
  final Future<void> Function() herlaad;
  final Future<bool> Function(DateTime dag, AgendaItem item) verwijderAfspraak;
  final AgendaItem? geselecteerd;

  @override
  State<ThimacoIphoneDagweergave> createState() =>
      _ThimacoIphoneDagweergaveState();
}

class _ThimacoIphoneDagweergaveState extends State<ThimacoIphoneDagweergave> {
  static const Color _oranje = Color(0xFFF15A24);
  static const Color _donker = Color(0xFF20252B);
  static const Color _rand = Color(0xFFE9EBEF);
  static const Color _subtekst = Color(0xFF81858B);
  static const List<String> _dagen = [
    'Ma', 'Di', 'Wo', 'Do', 'Vr', 'Za', 'Zo',
  ];
  static const List<String> _maanden = [
    'januari', 'februari', 'maart', 'april', 'mei', 'juni',
    'juli', 'augustus', 'september', 'oktober', 'november', 'december',
  ];
  static const int _midden = 10000;

  late final DateTime _basis;
  late final PageController _paginaController;
  late DateTime _dag;
  Timer? _klokTimer;

  @override
  void initState() {
    super.initState();
    _basis = DateTime(widget.beginDag.year, widget.beginDag.month, widget.beginDag.day);
    _dag = _basis;
    _paginaController = PageController(initialPage: _midden);
    _klokTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
    if (widget.geselecteerd != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _toonDetails(widget.geselecteerd!);
      });
    }
  }

  @override
  void dispose() {
    _klokTimer?.cancel();
    _paginaController.dispose();
    super.dispose();
  }

  DateTime _dagOpOffset(int offset) =>
      DateTime(_basis.year, _basis.month, _basis.day + offset);

  int _verschilInDagen(DateTime a, DateTime b) =>
      DateTime.utc(a.year, a.month, a.day)
          .difference(DateTime.utc(b.year, b.month, b.day))
          .inDays;

  bool _isVandaag(DateTime datum) {
    final nu = DateTime.now();
    return datum.year == nu.year && datum.month == nu.month && datum.day == nu.day;
  }

  String _titel(AgendaItem item) {
    final klant = item.naamKlant.trim();
    final titel = item.titel.trim();
    if (klant.isEmpty) return titel.isEmpty ? 'Afspraak' : titel;
    if (titel.isEmpty || titel.toLowerCase() == klant.toLowerCase()) return klant;
    return '$klant · $titel';
  }

  String _tijd(AgendaItem item) {
    if (item.volledigeDag || item.startUur == null) return 'Hele dag';
    String t(int? uur, int? minuut) =>
        '${(uur ?? 0).toString().padLeft(2, '0')}:'
        '${(minuut ?? 0).toString().padLeft(2, '0')}';
    return '${t(item.startUur, item.startMinuut)} – '
        '${t(item.eindUur, item.eindMinuut)}';
  }

  Color _kleur(AgendaItem item) =>
      item.type == 'afspraak' && !item.isWebsiteShowroomAfspraak
          ? const Color(0xFF2563EB)
          : AgendaKleurService.kleur(item.type);

  void _kiesDag(DateTime datum) {
    final doel = _midden + _verschilInDagen(datum, _basis);
    if (doel < 0 || doel >= 20000) return;
    _paginaController.animateToPage(
      doel,
      duration: const Duration(milliseconds: 230),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _nieuweAfspraak() async {
    await widget.voegAfspraakToe(_dag);
    if (mounted) setState(() {});
  }

  Future<void> _ververs() async {
    await widget.herlaad();
    if (mounted) setState(() {});
  }

  void _toonDetails(AgendaItem item) {
    final kleur = _kleur(item);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Container(height: 29, width: 4, color: kleur),
                const SizedBox(width: 10),
                Expanded(child: Text(_titel(item),
                    style: const TextStyle(
                      color: _donker, fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ))),
                if (item.type == 'afspraak' && !item.isWebsiteShowroomAfspraak)
                  IconButton(
                    tooltip: 'Afspraak wissen',
                    style: IconButton.styleFrom(
                      backgroundColor: _oranje,
                      foregroundColor: Colors.white,
                      fixedSize: const Size(33, 33),
                      minimumSize: const Size(33, 33),
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () async {
                      final verwijderd = await widget.verwijderAfspraak(_dag, item);
                      if (!mounted || !sheetContext.mounted) return;
                      if (verwijderd) {
                        Navigator.of(sheetContext).pop();
                        await _ververs();
                      }
                    },
                    icon: const Icon(Icons.delete_outline_rounded, size: 19),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  icon: const Icon(Icons.close_rounded),
                ),
              ]),
              if (item.isShowroomAfspraak) ...[
                const SizedBox(height: 7),
                const Row(children: [
                  Icon(Icons.home_outlined, color: _oranje, size: 18),
                  SizedBox(width: 5),
                  Text('Showroom', style: TextStyle(
                    color: _donker, fontSize: 12,
                  )),
                ]),
              ],
              const SizedBox(height: 12),
              Text(_tijd(item), style: const TextStyle(color: _subtekst)),
              if (item.opmerkingen.trim().isNotEmpty) ...[
                const SizedBox(height: 15),
                const Text('Notities',
                    style: TextStyle(color: _donker, fontWeight: FontWeight.w700)),
                const SizedBox(height: 5),
                Text(item.opmerkingen,
                    style: const TextStyle(color: _donker, fontSize: 13)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _dagKnop(DateTime datum) {
    final actief = datum.year == _dag.year &&
        datum.month == _dag.month && datum.day == _dag.day;
    final vandaag = _isVandaag(datum);
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _kiesDag(datum),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_dagen[datum.weekday - 1], style: const TextStyle(
            color: _subtekst, fontSize: 11, fontWeight: FontWeight.w400,
          )),
          const SizedBox(height: 5),
          Container(
            width: 29, height: 29,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: vandaag ? _oranje : Colors.transparent,
              shape: BoxShape.circle,
              border: actief && !vandaag
                  ? Border.all(color: _oranje, width: 1.2) : null,
            ),
            child: Text('${datum.day}', style: TextStyle(
              color: vandaag ? Colors.white : _donker,
              fontSize: 15, fontWeight: FontWeight.w400,
            )),
          ),
          const SizedBox(height: 6),
          Container(
            height: 2, width: 15,
            color: actief ? _oranje : Colors.transparent,
          ),
        ]),
      ),
    );
  }

  Widget _dagenBalk() {
    final maandag = DateTime(_dag.year, _dag.month, _dag.day - (_dag.weekday - 1));
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 8, 9, 9),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _rand)),
      ),
      child: Row(children: [
        for (var i = 0; i < 7; i++)
          _dagKnop(DateTime(maandag.year, maandag.month, maandag.day + i)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 7, 10, 3),
          child: Row(children: [
            IconButton(
              tooltip: 'Maandoverzicht',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.calendar_month_outlined,
                  color: _donker, size: 23),
            ),
            Expanded(child: Text(
              '${_dag.day} ${_maanden[_dag.month - 1]} ${_dag.year}',
              style: const TextStyle(color: _donker,
                fontSize: 20, fontWeight: FontWeight.w700),
            )),
            IconButton(
              tooltip: 'Vernieuwen',
              onPressed: _ververs,
              icon: const Icon(Icons.refresh_rounded, color: _donker),
            ),
            IconButton(
              tooltip: 'Afspraak toevoegen',
              onPressed: _nieuweAfspraak,
              style: IconButton.styleFrom(
                backgroundColor: _oranje, foregroundColor: Colors.white,
                fixedSize: const Size(32, 32),
                minimumSize: const Size(32, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
            ),
          ]),
        ),
        _dagenBalk(),
        Expanded(child: PageView.builder(
          controller: _paginaController,
          onPageChanged: (index) {
            setState(() => _dag = _dagOpOffset(index - _midden));
          },
          itemBuilder: (context, index) {
            final datum = _dagOpOffset(index - _midden);
            return _DagTijdlijn(
              key: ValueKey('${datum.year}-${datum.month}-${datum.day}'),
              dag: datum,
              items: widget.itemsVoor(datum),
              toonDetails: _toonDetails,
            );
          },
        )),
        Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: _rand)),
          ),
          padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
          child: Row(children: [
            TextButton(
              onPressed: () => _kiesDag(DateTime.now()),
              child: const Text('Vandaag',
                  style: TextStyle(color: _donker, fontWeight: FontWeight.w600)),
            ),
            const Spacer(),
            const Text('Veeg links/rechts voor een andere dag',
                style: TextStyle(color: _subtekst, fontSize: 10)),
          ]),
        ),
      ]),
    ),
  );
}

class _DagTijdlijn extends StatefulWidget {
  const _DagTijdlijn({
    super.key,
    required this.dag,
    required this.items,
    required this.toonDetails,
  });

  final DateTime dag;
  final List<AgendaItem> items;
  final ValueChanged<AgendaItem> toonDetails;

  @override
  State<_DagTijdlijn> createState() => _DagTijdlijnState();
}

class _Tijdvak {
  const _Tijdvak(this.item, this.baan, this.aantalBanen);
  final AgendaItem item;
  final int baan;
  final int aantalBanen;
}

class _DagTijdlijnState extends State<_DagTijdlijn> {
  static const Color _oranje = Color(0xFFF15A24);
  static const Color _donker = Color(0xFF20252B);
  static const Color _rand = Color(0xFFE9EBEF);
  // Compacte iPhone-tijdlijn: half zoveel verticale ruimte per uur.
  static const double _uurHoogte = 38;
  static const double _totaalHoogte = 24 * _uurHoogte;
  static const double _tijdBreedte = 54;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final nu = DateTime.now();
      final gewenstUur = _isVandaag() ? math.max(0, nu.hour - 2) : 7;
      final doel = (gewenstUur * _uurHoogte)
          .clamp(0.0, _scrollController.position.maxScrollExtent)
          .toDouble();
      _scrollController.jumpTo(doel);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isVandaag() {
    final nu = DateTime.now();
    return widget.dag.year == nu.year &&
        widget.dag.month == nu.month && widget.dag.day == nu.day;
  }

  int _startMin(AgendaItem item) => math.min(1439,
      math.max(0, (item.startUur ?? 0) * 60 + (item.startMinuut ?? 0)));

  int _eindMin(AgendaItem item) => math.min(1440,
      math.max(0, (item.eindUur ?? item.startUur ?? 0) * 60 + (item.eindMinuut ?? 0)));

  List<_Tijdvak> _berekenBanen(List<AgendaItem> items) {
    final sortering = [...items]..sort((a, b) => _startMin(a).compareTo(_startMin(b)));
    final resultaat = <_Tijdvak>[];
    var groep = <AgendaItem>[];
    var groepEinde = -1;

    void verwerkGroep() {
      if (groep.isEmpty) return;
      final baanEinde = <int>[];
      final toegewezen = <(AgendaItem, int)>[];
      for (final item in groep) {
        final start = _startMin(item);
        var baan = baanEinde.indexWhere((einde) => einde <= start);
        if (baan < 0) {
          baan = baanEinde.length;
          baanEinde.add(0);
        }
        baanEinde[baan] = math.max(_eindMin(item), start + 20);
        toegewezen.add((item, baan));
      }
      for (final (item, baan) in toegewezen) {
        resultaat.add(_Tijdvak(item, baan, baanEinde.length));
      }
      groep = <AgendaItem>[];
      groepEinde = -1;
    }

    for (final item in sortering) {
      final start = _startMin(item);
      if (groep.isNotEmpty && start >= groepEinde) verwerkGroep();
      groep.add(item);
      groepEinde = math.max(groepEinde, math.max(_eindMin(item), start + 20));
    }
    verwerkGroep();
    return resultaat;
  }

  Color _kleur(AgendaItem item) =>
      item.type == 'afspraak' && !item.isWebsiteShowroomAfspraak
          ? const Color(0xFF2563EB)
          : AgendaKleurService.kleur(item.type);

  Widget _afspraakKaart(AgendaItem item, {bool heleDag = false}) {
    final kleur = _kleur(item);
    final naam = item.naamKlant.trim().isNotEmpty
        ? item.naamKlant.trim() : item.titel.trim();
    return Material(
      color: Color.lerp(Colors.white, kleur, 0.16),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => widget.toonDetails(item),
        child: Container(
          padding: const EdgeInsets.fromLTRB(7, 4, 5, 3),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: kleur, width: 3)),
          ),
          child: LayoutBuilder(builder: (context, maat) {
            final compact = !heleDag && maat.maxHeight < 34;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  if (item.isShowroomAfspraak) ...[
                    const Icon(Icons.home_outlined, size: 13, color: _donker),
                    const SizedBox(width: 3),
                  ],
                  Expanded(child: Text(naam.isEmpty ? 'Afspraak' : naam,
                    maxLines: heleDag || compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _donker, fontSize: 12,
                      fontWeight: FontWeight.w600, height: 1.1,
                    ),
                  )),
                ]),
                if (!compact && !heleDag && item.startUur != null)
                  Text('${item.startUur!.toString().padLeft(2, '0')}:'
                      '${(item.startMinuut ?? 0).toString().padLeft(2, '0')}',
                      style: const TextStyle(color: _donker, fontSize: 10)),
              ],
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dagvullend = widget.items.where(
      (item) => item.volledigeDag || item.startUur == null,
    ).toList();
    final tijden = widget.items.where(
      (item) => !item.volledigeDag && item.startUur != null,
    ).toList();
    final vakken = _berekenBanen(tijden);
    final vandaag = _isVandaag();
    final nu = DateTime.now();
    final nuY = (nu.hour * 60 + nu.minute) * _uurHoogte / 60;

    return Column(children: [
      if (dagvullend.isNotEmpty)
        Container(
          constraints: const BoxConstraints(maxHeight: 128),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: _rand)),
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 7),
            children: [
              for (final item in dagvullend)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _afspraakKaart(item, heleDag: true),
                ),
            ],
          ),
        ),
      Expanded(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: LayoutBuilder(builder: (context, constraints) {
            final beschikbareBreedte = math.max(25.0, constraints.maxWidth - _tijdBreedte - 9);
            return SizedBox(
              height: _totaalHoogte + 14,
              child: Stack(children: [
                for (var uur = 0; uur < 24; uur++)
                  Positioned(
                    left: 0, right: 0, top: uur * _uurHoogte,
                    child: SizedBox(
                      height: 14,
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: _tijdBreedte - 5,
                            child: Text('${uur.toString().padLeft(2, '0')}:00',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF969BA2), fontSize: 10,
                              ),
                            ),
                          ),
                          const Expanded(child: SizedBox(
                            height: 1,
                            child: ColoredBox(color: _rand),
                          )),
                        ],
                      ),
                    ),
                  ),
                for (final vak in vakken)
                  Positioned(
                    left: _tijdBreedte +
                        beschikbareBreedte * vak.baan / vak.aantalBanen,
                    width: math.max(4.0,
                        beschikbareBreedte / vak.aantalBanen - 3),
                    // Exact op de uurstreep: 11:00 tot 12:00 is precies 38 px.
                    top: _startMin(vak.item) * _uurHoogte / 60,
                    height: math.min(
                      _totaalHoogte - _startMin(vak.item) * _uurHoogte / 60,
                      math.max(18.0,
                        (math.max(_eindMin(vak.item), _startMin(vak.item) + 1) -
                            _startMin(vak.item)) * _uurHoogte / 60,
                      ),
                    ),
                    child: _afspraakKaart(vak.item),
                  ),
                if (vandaag)
                  Positioned(
                    left: _tijdBreedte - 5, right: 0, top: nuY,
                    child: Row(children: [
                      Container(width: 9, height: 9,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: _oranje,
                        )),
                      const Expanded(child: Divider(
                        color: _oranje, thickness: 1.5, height: 2,
                      )),
                    ]),
                  ),
              ]),
            );
          }),
        ),
      ),
    ]);
  }
}
