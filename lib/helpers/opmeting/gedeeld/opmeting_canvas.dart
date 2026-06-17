import 'package:flutter/material.dart';

import 'opmeting_driehoek_service.dart';
import 'opmeting_rechthoek_service.dart';
import 'opmeting_snap_service.dart';
import 'opmeting_teken_model.dart';
import 'opmeting_teken_painter.dart';
import 'opmeting_tstijl_service.dart';

class OpmetingCanvas extends StatefulWidget {
  const OpmetingCanvas({
    super.key,
    required this.breedteMm,
    required this.hoogteMm,
    required this.actieveTool,
    required this.positieController,
  });

  final int breedteMm;
  final int hoogteMm;
  final String actieveTool;
  final TextEditingController positieController;

  @override
  State<OpmetingCanvas> createState() => _OpmetingCanvasState();
}

class _OpmetingCanvasState extends State<OpmetingCanvas> {
  Offset? _startPunt;
  Offset? _eindPunt;
  Rect? _rechthoek;

  final List<OpmetingLijn> _lijnen = [];
  final List<OpmetingDriehoek> _driehoeken = [];
  final List<OpmetingTStijl> _tStijlen = [];

  Offset? _lijnStart;
  Offset? _driehoekPunt1;
  Offset? _driehoekPunt2;
  Offset? _actiefSnappunt;

  final tStijlMaatController = TextEditingController(text: '500');

  String _tStijlRichting = 'verticaal';
  String _tStijlVanaf = 'links';
  String _tStijlPositieType = 'mm';

  Offset? _actieveTStijlKandidaat;
  String? _geselecteerdeTStijlId;
  Offset _tStijlPaneelPositie = const Offset(40, 120);
  bool _tStijlMenuOpen = false;

  static const double raster10cm = 200;
  static const double raster5mm = raster10cm / 20;
  static const double snapAfstand = 46;

  @override
  void dispose() {
    tStijlMaatController.dispose();
    super.dispose();
  }

  Offset _snapRaster(Offset punt) {
    final x = (punt.dx / raster5mm).round() * raster5mm;
    final y = (punt.dy / raster5mm).round() * raster5mm;
    return Offset(x, y);
  }

  OpmetingTStijlInstellingen _tStijlInstellingen() {
    final positieMm = double.tryParse(
          tStijlMaatController.text.trim().replaceAll(',', '.'),
        ) ??
        0;

    return OpmetingTStijlInstellingen(
      richting: _tStijlRichting,
      vanaf: _tStijlVanaf,
      positieType: _tStijlPositieType,
      positieMm: positieMm,
    );
  }

  List<OpmetingLijn> _basisLijnen() {
    if (_rechthoek == null) return [];

    final r = _rechthoek!;

    return [
      OpmetingLijn(id: 'boven', start: r.topLeft, einde: r.topRight),
      OpmetingLijn(id: 'rechts', start: r.topRight, einde: r.bottomRight),
      OpmetingLijn(id: 'onder', start: r.bottomLeft, einde: r.bottomRight),
      OpmetingLijn(id: 'links', start: r.topLeft, einde: r.bottomLeft),
    ];
  }

  List<OpmetingLijn> _alleLijnen() {
    final alle = <OpmetingLijn>[
      ..._basisLijnen(),
      ..._lijnen,
    ];

    for (var i = 0; i < _tStijlen.length; i++) {
      final stijl = _tStijlen[i];

      alle.add(
        OpmetingLijn(
          id: 'tstijl_$i',
          start: stijl.start,
          einde: stijl.einde,
        ),
      );
    }

    for (var i = 0; i < _driehoeken.length; i++) {
      final d = _driehoeken[i];

      alle.addAll([
        OpmetingLijn(id: 'driehoek_${i}_1', start: d.punt1, einde: d.punt2),
        OpmetingLijn(id: 'driehoek_${i}_2', start: d.punt1, einde: d.punt3),
        OpmetingLijn(id: 'driehoek_${i}_3', start: d.punt2, einde: d.punt3),
      ]);
    }

    return alle;
  }

  List<Offset> _snappunten() {
    return OpmetingSnapService.snappuntenVanLijnen(
      _alleLijnen(),
    );
  }

  List<Offset> _tStijlKandidaten() {
    if (_rechthoek == null ||
        widget.actieveTool != 'tstijl' ||
        !_tStijlMenuOpen) {
      return [];
    }

    return OpmetingTStijlService.kandidaatSnappunten(
      instellingen: _tStijlInstellingen(),
      buitenKader: _rechthoek!,
      breedteMm: widget.breedteMm,
      hoogteMm: widget.hoogteMm,
      bestaandeTStijlen: _tStijlen,
    );
  }

  Offset? _dichtsteSnappunt(Offset punt) {
    return OpmetingSnapService.dichtsteSnappunt(
      punt: punt,
      snappunten: _snappunten(),
      snapAfstand: snapAfstand,
    );
  }

  Offset _snapNaarPuntOfRaster(Offset punt) {
    return _dichtsteSnappunt(punt) ?? _snapRaster(punt);
  }

  void _updateAanwijzing(Offset punt) {
    setState(() {
      _actiefSnappunt = _tStijlMenuOpen ? _dichtsteSnappunt(punt) : null;

      if (widget.actieveTool == 'tstijl' && _tStijlMenuOpen) {
        Offset? beste;
        var besteAfstand = double.infinity;

        for (final kandidaat in _tStijlKandidaten()) {
          final afstand = (kandidaat - punt).distance;

          if (afstand < besteAfstand) {
            besteAfstand = afstand;
            beste = kandidaat;
          }
        }

        _actieveTStijlKandidaat =
            beste != null && besteAfstand <= snapAfstand ? beste : null;
      } else {
        _actieveTStijlKandidaat = null;
      }
    });
  }

  void _startRechthoek(DragStartDetails details) {
    if (_rechthoek != null) return;

    final punt = _snapRaster(details.localPosition);

    setState(() {
      _startPunt = punt;
      _eindPunt = punt;
    });
  }

  void _updateRechthoek(DragUpdateDetails details) {
    if (_rechthoek != null) return;

    setState(() {
      _eindPunt = _snapRaster(details.localPosition);
    });
  }

  void _stopRechthoek(DragEndDetails details) {
    if (_rechthoek != null) return;
    if (_startPunt == null || _eindPunt == null) return;

    final rect = OpmetingRechthoekService.maakRechthoek(
      startPunt: _startPunt!,
      eindPunt: _eindPunt!,
      breedteMm: widget.breedteMm.toDouble(),
      hoogteMm: widget.hoogteMm.toDouble(),
    );

    if (rect == null) return;

    setState(() {
      _rechthoek = rect;
    });
  }

  void _klikCanvas(TapDownDetails details) {
    if (_rechthoek == null) return;

    if (widget.actieveTool == 'tstijl') {
      if (!_tStijlMenuOpen) {
        setState(() {
          _geselecteerdeTStijlId = null;
          _actieveTStijlKandidaat = null;
          _actiefSnappunt = null;
        });
        return;
      }

      _selecteerTStijl(details.localPosition);

      if (_geselecteerdeTStijlId != null) {
        return;
      }

      _klikTStijl(details.localPosition);
      return;
    }

    final punt = _snapNaarPuntOfRaster(details.localPosition);

    if (widget.actieveTool == 'lijn') {
      _klikLijn(punt);
      return;
    }

    if (widget.actieveTool == 'driehoek') {
      _klikDriehoek(
        punt,
        details.localPosition,
      );
    }
  }

  void _klikLijn(Offset punt) {
    setState(() {
      if (_lijnStart == null) {
        _lijnStart = punt;
        return;
      }

      if ((_lijnStart! - punt).distance < 1) return;

      _lijnen.add(
        OpmetingLijn(
          id: 'lijn_${_lijnen.length}',
          start: _lijnStart!,
          einde: punt,
        ),
      );

      _lijnStart = null;
    });
  }

  void _klikDriehoek(
    Offset snapPunt,
    Offset vrijeKlik,
  ) {
    setState(() {
      if (_driehoekPunt1 == null) {
        _driehoekPunt1 = snapPunt;
        return;
      }

      if (_driehoekPunt2 == null) {
        _driehoekPunt2 = snapPunt;
        return;
      }

      final top = OpmetingDriehoekService.berekenDriehoekPunt(
        punt1: _driehoekPunt1!,
        punt2: _driehoekPunt2!,
        richtingKlik: vrijeKlik,
        lijnen: _alleLijnen(),
      );

      if (top == null) {
        _driehoekPunt1 = null;
        _driehoekPunt2 = null;
        return;
      }

      _driehoeken.add(
        OpmetingDriehoek(
          punt1: _driehoekPunt1!,
          punt2: _driehoekPunt2!,
          punt3: top,
        ),
      );

      _driehoekPunt1 = null;
      _driehoekPunt2 = null;
    });
  }

  void _klikTStijl(Offset klikPunt) {
    if (_rechthoek == null) return;

    Offset? beste;
    var besteAfstand = double.infinity;

    for (final kandidaat in _tStijlKandidaten()) {
      final afstand = (kandidaat - klikPunt).distance;

      if (afstand < besteAfstand) {
        besteAfstand = afstand;
        beste = kandidaat;
      }
    }

    if (beste == null || besteAfstand > snapAfstand) return;

    final stijl = OpmetingTStijlService.maakTStijlVanafSnappunt(
      snappunt: beste,
      instellingen: _tStijlInstellingen(),
      buitenKader: _rechthoek!,
      breedteMm: widget.breedteMm,
      hoogteMm: widget.hoogteMm,
      bestaandeTStijlen: _tStijlen,
    );

    if (stijl == null) return;

    setState(() {
      _tStijlen.add(stijl);
      _geselecteerdeTStijlId = stijl.id;
      _actieveTStijlKandidaat = null;
    });
  }

  void _undo() {
    setState(() {
      if (_tStijlen.isNotEmpty) {
        _tStijlen.removeLast();
        return;
      }

      if (_driehoeken.isNotEmpty) {
        _driehoeken.removeLast();
        return;
      }

      if (_lijnen.isNotEmpty) {
        _lijnen.removeLast();
        return;
      }

      _rechthoek = null;
      _startPunt = null;
      _eindPunt = null;
      _lijnStart = null;
      _driehoekPunt1 = null;
      _driehoekPunt2 = null;
    });
  }

  void _allesWissen() {
    setState(() {
      _startPunt = null;
      _eindPunt = null;
      _rechthoek = null;
      _lijnen.clear();
      _driehoeken.clear();
      _tStijlen.clear();
      _actieveTStijlKandidaat = null;
      _geselecteerdeTStijlId = null;
      _lijnStart = null;
      _driehoekPunt1 = null;
      _driehoekPunt2 = null;
      _actiefSnappunt = null;
    });
  }

  @override
  void didUpdateWidget(covariant OpmetingCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.actieveTool != widget.actieveTool) {
      setState(() {
        _lijnStart = null;
        _driehoekPunt1 = null;
        _driehoekPunt2 = null;
        _actieveTStijlKandidaat = null;
        _geselecteerdeTStijlId = null;
        _actiefSnappunt = null;
        _tStijlMenuOpen = widget.actieveTool == 'tstijl';
      });
    }

    if (oldWidget.breedteMm != widget.breedteMm ||
        oldWidget.hoogteMm != widget.hoogteMm) {
      setState(() {
        _rechthoek = null;
        _startPunt = null;
        _eindPunt = null;
        _lijnen.clear();
        _driehoeken.clear();
        _tStijlen.clear();
        _actieveTStijlKandidaat = null;
        _geselecteerdeTStijlId = null;
        _actiefSnappunt = null;
      });
    }
  }

  void _selecteerTStijl(Offset klikPunt) {
    String? besteId;
    var besteAfstand = double.infinity;

    for (final stijl in _tStijlen) {
      final afstand = _afstandTotLijnstuk(
        punt: klikPunt,
        start: stijl.start,
        einde: stijl.einde,
      );

      if (afstand < besteAfstand) {
        besteAfstand = afstand;
        besteId = stijl.id;
      }
    }

    setState(() {
      _geselecteerdeTStijlId =
          besteId != null && besteAfstand <= 22 ? besteId : null;
    });
  }

  bool _magTStijlWissen(OpmetingTStijl stijl) {
    for (final andere in _tStijlen) {
      if (andere.id == stijl.id) continue;

      if (_puntRaaktTStijlProfiel(punt: andere.start, stijl: stijl)) {
        return false;
      }

      if (_puntRaaktTStijlProfiel(punt: andere.einde, stijl: stijl)) {
        return false;
      }
    }

    return true;
  }

  bool _puntRaaktTStijlProfiel({
    required Offset punt,
    required OpmetingTStijl stijl,
  }) {
    if (_rechthoek == null) return false;

    final r = _rechthoek!;

    final halveBreedtePx = stijl.richting == 'verticaal'
        ? (r.width / widget.breedteMm) * (stijl.breedteMm / 2)
        : (r.height / widget.hoogteMm) * (stijl.breedteMm / 2);

    final afstand = _afstandTotLijnstuk(
      punt: punt,
      start: stijl.start,
      einde: stijl.einde,
    );

    return afstand <= halveBreedtePx + 4;
  }

  double _afstandTotLijnstuk({
    required Offset punt,
    required Offset start,
    required Offset einde,
  }) {
    final dx = einde.dx - start.dx;
    final dy = einde.dy - start.dy;

    if (dx == 0 && dy == 0) {
      return (punt - start).distance;
    }

    final t = (((punt.dx - start.dx) * dx) + ((punt.dy - start.dy) * dy)) /
        ((dx * dx) + (dy * dy));

    final begrensd = t.clamp(0.0, 1.0);

    final projectie = Offset(
      start.dx + (begrensd * dx),
      start.dy + (begrensd * dy),
    );

    return (punt - projectie).distance;
  }

  Future<void> _wisGeselecteerdeTStijl() async {
    if (_geselecteerdeTStijlId == null) return;

    final index = _tStijlen.indexWhere(
      (stijl) => stijl.id == _geselecteerdeTStijlId,
    );

    if (index == -1) return;

    final stijl = _tStijlen[index];

    if (!_magTStijlWissen(stijl)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Deze T-stijl kan niet gewist worden omdat er een andere T-stijl tegen staat.',
          ),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('T-stijl wissen?'),
          content: const Text('Wilt u deze T-stijl verwijderen?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Annuleren'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Ja, wissen'),
            ),
          ],
        );
      },
    );

    if (bevestigen != true) return;

    setState(() {
      _tStijlen.removeAt(index);
      _geselecteerdeTStijlId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final kandidaten = widget.actieveTool == 'tstijl' && _tStijlMenuOpen
        ? _tStijlKandidaten()
        : <Offset>[];

    return Container(
      decoration: _kaartDecoratie(),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxLeft = constraints.maxWidth - 260;
          final maxTop = constraints.maxHeight - 260;

          final paneelLinks = _tStijlPaneelPositie.dx.clamp(0.0, maxLeft);
          final paneelTop = _tStijlPaneelPositie.dy.clamp(0.0, maxTop);

          return Stack(
            children: [
              Positioned.fill(
                child: Listener(
                  onPointerMove: (event) {
                    _updateAanwijzing(event.localPosition);
                  },
                  onPointerDown: (event) {
                    _updateAanwijzing(event.localPosition);
                  },
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: _klikCanvas,
                    onPanStart: _startRechthoek,
                    onPanUpdate: _updateRechthoek,
                    onPanEnd: _stopRechthoek,
                    child: CustomPaint(
                      painter: OpmetingTekenPainter(
                        startPunt: _startPunt,
                        eindPunt: _eindPunt,
                        rechthoek: _rechthoek,
                        lijnen: _alleLijnen(),
                        tStijlen: _tStijlen,
                        tStijlKandidaten: kandidaten,
                        actieveTStijlKandidaat: _actieveTStijlKandidaat,
                        snappunten: _snappunten(),
                        actiefSnappunt: _actiefSnappunt,
                        lijnStart: _lijnStart,
                        driehoekPunt1: _driehoekPunt1,
                        driehoekPunt2: _driehoekPunt2,
                        breedteMm: widget.breedteMm,
                        hoogteMm: widget.hoogteMm,
                        geselecteerdeTStijlId: _geselecteerdeTStijlId,
                        tStijlMenuOpen: _tStijlMenuOpen,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: _positieVeld(),
              ),
              if (widget.actieveTool == 'tstijl' && _tStijlMenuOpen)
                Positioned(
                  left: paneelLinks,
                  top: paneelTop,
                  child: _tStijlPaneel(),
                ),
              if (widget.actieveTool == 'tstijl' && !_tStijlMenuOpen)
                Positioned(
                  left: 10,
                  top: 10,
                  child: _kleineKnop(
                    icoon: Icons.view_column_outlined,
                    tekst: 'T-stijl menu openen',
                    onTap: () {
                      setState(() {
                        _tStijlMenuOpen = true;
                        _actieveTStijlKandidaat = null;
                        _geselecteerdeTStijlId = null;
                        _actiefSnappunt = null;
                      });
                    },
                  ),
                ),
              Positioned(
                left: 10,
                bottom: 10,
                child: Row(
                  children: [
                    _kleineKnop(
                      icoon: Icons.undo,
                      tekst: 'Undo',
                      onTap: _undo,
                    ),
                    const SizedBox(width: 8),
                    _kleineKnop(
                      icoon: Icons.delete_outline,
                      tekst: 'Wis',
                      onTap: _allesWissen,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _positieVeld() {
    return Container(
      width: 190,
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFD1D5DB),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Pos:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0B7A3B),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: widget.positieController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tStijlPaneel() {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _tStijlPaneelPositie += details.delta;
        });
      },
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.97),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD1D5DB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'T-stijlen',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0B7A3B),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _tStijlMenuOpen = false;
                      _actieveTStijlKandidaat = null;
                      _geselecteerdeTStijlId = null;
                      _actiefSnappunt = null;
                    });
                  },
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _titel('Richting'),
            Row(
              children: [
                _keuzeKnop(
                  tekst: 'Verticaal',
                  actief: _tStijlRichting == 'verticaal',
                  onTap: () {
                    setState(() {
                      _tStijlRichting = 'verticaal';
                      _tStijlVanaf = 'links';
                      _actieveTStijlKandidaat = null;
                      _geselecteerdeTStijlId = null;
                    });
                  },
                ),
                const SizedBox(width: 6),
                _keuzeKnop(
                  tekst: 'Horizontaal',
                  actief: _tStijlRichting == 'horizontaal',
                  onTap: () {
                    setState(() {
                      _tStijlRichting = 'horizontaal';
                      _tStijlVanaf = 'boven';
                      _actieveTStijlKandidaat = null;
                      _geselecteerdeTStijlId = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            _titel('Vanaf'),
            Row(
              children: _tStijlRichting == 'verticaal'
                  ? [
                      _keuzeKnop(
                        tekst: 'Links',
                        actief: _tStijlVanaf == 'links',
                        onTap: () {
                          setState(() {
                            _tStijlVanaf = 'links';
                            _actieveTStijlKandidaat = null;
                          });
                        },
                      ),
                      const SizedBox(width: 6),
                      _keuzeKnop(
                        tekst: 'Rechts',
                        actief: _tStijlVanaf == 'rechts',
                        onTap: () {
                          setState(() {
                            _tStijlVanaf = 'rechts';
                            _actieveTStijlKandidaat = null;
                          });
                        },
                      ),
                    ]
                  : [
                      _keuzeKnop(
                        tekst: 'Boven',
                        actief: _tStijlVanaf == 'boven',
                        onTap: () {
                          setState(() {
                            _tStijlVanaf = 'boven';
                            _actieveTStijlKandidaat = null;
                          });
                        },
                      ),
                      const SizedBox(width: 6),
                      _keuzeKnop(
                        tekst: 'Onder',
                        actief: _tStijlVanaf == 'onder',
                        onTap: () {
                          setState(() {
                            _tStijlVanaf = 'onder';
                            _actieveTStijlKandidaat = null;
                          });
                        },
                      ),
                    ],
            ),
            const SizedBox(height: 8),
            _titel('Positie'),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                'mm',
                '1/2',
                '1/3',
                '2/3',
                '1/4',
                '2/4',
                '3/4',
              ].map((waarde) {
                return _keuzeKnop(
                  tekst: waarde,
                  actief: _tStijlPositieType == waarde,
                  breedte: 54,
                  onTap: () {
                    setState(() {
                      _tStijlPositieType = waarde;
                      _actieveTStijlKandidaat = null;
                      _geselecteerdeTStijlId = null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Maat mm',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 76,
                  height: 32,
                  child: TextField(
                    controller: tStijlMaatController,
                    enabled: _tStijlPositieType == 'mm',
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (_) {
                      setState(() {
                        _actieveTStijlKandidaat = null;
                        _geselecteerdeTStijlId = null;
                      });
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 7,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_geselecteerdeTStijlId != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 34,
                child: ElevatedButton.icon(
                  onPressed: _wisGeselecteerdeTStijl,
                  icon: const Icon(Icons.delete_outline, size: 17),
                  label: const Text('T-stijl wissen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            const Text(
              'Klik op een rood punt om de T-stijl te plaatsen.',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titel(String tekst) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        tekst,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Color(0xFF0B7A3B),
        ),
      ),
    );
  }

  Widget _keuzeKnop({
    required String tekst,
    required bool actief,
    required VoidCallback onTap,
    double? breedte,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: breedte,
        height: 32,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: actief ? const Color(0xFF0B7A3B) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: actief ? const Color(0xFF0B7A3B) : const Color(0xFFD1D5DB),
          ),
        ),
        child: Text(
          tekst,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: actief ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _kleineKnop({
    required IconData icoon,
    required String tekst,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFD1D5DB),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icoon,
              size: 17,
              color: const Color(0xFF0B7A3B),
            ),
            const SizedBox(width: 5),
            Text(
              tekst,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0B7A3B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _kaartDecoratie() {
    return BoxDecoration(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xFFD1D5DB),
      ),
    );
  }
}
