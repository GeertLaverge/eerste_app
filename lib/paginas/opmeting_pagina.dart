import 'dart:math' as math;

import 'package:flutter/material.dart';

class OpmetingPagina extends StatefulWidget {
  const OpmetingPagina({super.key});

  @override
  State<OpmetingPagina> createState() => _OpmetingPaginaState();
}

class _OpmetingPaginaState extends State<OpmetingPagina> {
  final TextEditingController _breedteController = TextEditingController();
  final TextEditingController _hoogteController = TextEditingController();
  final TextEditingController _tStijlAfstandController =
      TextEditingController();

  Offset? _startPunt;
  Offset? _eindPunt;
  Rect? _rechthoek;

  String _tool = 'lijn';
  String _tStijlRichting = 'Verticaal';
  String _tStijlVanaf = 'Links';

  final List<double> _tStijlAfstandenMm = [];
  final List<OpmetingLijn> _extraLijnen = [];
  final List<OpmetingDriehoek> _driehoeken = [];

  Offset? _lijnStart;
  Offset? _driehoekPunt1;
  Offset? _driehoekPunt2;

  Offset? _actiefSnappunt;

  static const double raster10cm = 200;
  static const double raster5mm = raster10cm / 20;
  static const double snapAfstand = 46;

  @override
  void dispose() {
    _breedteController.dispose();
    _hoogteController.dispose();
    _tStijlAfstandController.dispose();
    super.dispose();
  }

  double? _getal(TextEditingController controller) {
    return double.tryParse(
      controller.text.trim().replaceAll(',', '.'),
    );
  }

  Offset _snapRaster(Offset punt) {
    final x = (punt.dx / raster5mm).round() * raster5mm;
    final y = (punt.dy / raster5mm).round() * raster5mm;
    return Offset(x, y);
  }

  List<OpmetingLijn> _basisLijnen() {
    final lijnen = <OpmetingLijn>[];

    if (_rechthoek == null) return lijnen;

    final r = _rechthoek!;
    final breedteMm = _getal(_breedteController);
    final hoogteMm = _getal(_hoogteController);

    if (breedteMm == null || hoogteMm == null) return lijnen;

    if (_tStijlAfstandenMm.isEmpty) {
      lijnen.addAll([
        OpmetingLijn(id: 'boven', start: r.topLeft, einde: r.topRight),
        OpmetingLijn(id: 'rechts', start: r.topRight, einde: r.bottomRight),
        OpmetingLijn(id: 'onder', start: r.bottomLeft, einde: r.bottomRight),
        OpmetingLijn(id: 'links', start: r.topLeft, einde: r.bottomLeft),
      ]);

      return lijnen;
    }

    final afstanden = _tStijlAfstandenMm.toList()..sort();

    if (_tStijlRichting == 'Verticaal') {
      final xs = <double>[r.left];

      for (final afstandMm in afstanden) {
        final afstandPx = r.width * (afstandMm / breedteMm);
        final x =
            _tStijlVanaf == 'Links' ? r.left + afstandPx : r.right - afstandPx;

        if (x > r.left && x < r.right) {
          xs.add(x);
        }
      }

      xs.add(r.right);
      xs.sort();

      for (var i = 0; i < xs.length - 1; i++) {
        lijnen.add(
          OpmetingLijn(
            id: 'boven_$i',
            start: Offset(xs[i], r.top),
            einde: Offset(xs[i + 1], r.top),
          ),
        );

        lijnen.add(
          OpmetingLijn(
            id: 'onder_$i',
            start: Offset(xs[i], r.bottom),
            einde: Offset(xs[i + 1], r.bottom),
          ),
        );
      }

      for (var i = 0; i < xs.length; i++) {
        lijnen.add(
          OpmetingLijn(
            id: i == 0
                ? 'links'
                : i == xs.length - 1
                    ? 'rechts'
                    : 'tstijl_v_$i',
            start: Offset(xs[i], r.top),
            einde: Offset(xs[i], r.bottom),
          ),
        );
      }
    } else {
      final ys = <double>[r.top];

      for (final afstandMm in afstanden) {
        final afstandPx = r.height * (afstandMm / hoogteMm);
        final y =
            _tStijlVanaf == 'Links' ? r.top + afstandPx : r.bottom - afstandPx;

        if (y > r.top && y < r.bottom) {
          ys.add(y);
        }
      }

      ys.add(r.bottom);
      ys.sort();

      for (var i = 0; i < ys.length - 1; i++) {
        lijnen.add(
          OpmetingLijn(
            id: 'links_$i',
            start: Offset(r.left, ys[i]),
            einde: Offset(r.left, ys[i + 1]),
          ),
        );

        lijnen.add(
          OpmetingLijn(
            id: 'rechts_$i',
            start: Offset(r.right, ys[i]),
            einde: Offset(r.right, ys[i + 1]),
          ),
        );
      }

      for (var i = 0; i < ys.length; i++) {
        lijnen.add(
          OpmetingLijn(
            id: i == 0
                ? 'boven'
                : i == ys.length - 1
                    ? 'onder'
                    : 'tstijl_h_$i',
            start: Offset(r.left, ys[i]),
            einde: Offset(r.right, ys[i]),
          ),
        );
      }
    }

    return lijnen;
  }

  List<OpmetingLijn> _alleLijnen() {
    final lijnen = <OpmetingLijn>[
      ..._basisLijnen(),
      ..._extraLijnen,
    ];

    for (var i = 0; i < _driehoeken.length; i++) {
      final d = _driehoeken[i];

      lijnen.addAll([
        OpmetingLijn(id: 'driehoek_${i}_1', start: d.punt1, einde: d.punt2),
        OpmetingLijn(id: 'driehoek_${i}_2', start: d.punt1, einde: d.punt3),
        OpmetingLijn(id: 'driehoek_${i}_3', start: d.punt2, einde: d.punt3),
      ]);
    }

    return lijnen;
  }

  List<Offset> _snappunten() {
    final punten = <Offset>[];

    for (final lijn in _alleLijnen()) {
      punten.add(lijn.start);
      punten.add(lijn.einde);

      punten.add(
        Offset(
          (lijn.start.dx + lijn.einde.dx) / 2,
          (lijn.start.dy + lijn.einde.dy) / 2,
        ),
      );
    }

    return _uniekePunten(punten);
  }

  List<Offset> _uniekePunten(List<Offset> punten) {
    final uniek = <Offset>[];

    for (final punt in punten) {
      final bestaat = uniek.any((p) => (p - punt).distance < 0.5);
      if (!bestaat) uniek.add(punt);
    }

    return uniek;
  }

  Offset? _dichtsteSnappunt(Offset punt) {
    Offset? beste;
    var besteAfstand = double.infinity;

    for (final p in _snappunten()) {
      final afstand = (p - punt).distance;

      if (afstand < besteAfstand) {
        besteAfstand = afstand;
        beste = p;
      }
    }

    if (beste != null && besteAfstand <= snapAfstand) {
      return beste;
    }

    return null;
  }

  Offset _snapNaarPuntOfRaster(Offset punt) {
    return _dichtsteSnappunt(punt) ?? _snapRaster(punt);
  }

  void _updateAanwijzing(Offset punt) {
    setState(() {
      _actiefSnappunt = _dichtsteSnappunt(punt);
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
    _maakRechthoek();
  }

  void _maakRechthoek() {
    if (_startPunt == null || _eindPunt == null) return;

    final breedteMm = _getal(_breedteController);
    final hoogteMm = _getal(_hoogteController);

    if (breedteMm == null ||
        hoogteMm == null ||
        breedteMm <= 0 ||
        hoogteMm <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geef eerst breedte en hoogte in mm in.'),
        ),
      );
      return;
    }

    final dx = _eindPunt!.dx - _startPunt!.dx;
    final dy = _eindPunt!.dy - _startPunt!.dy;

    if (dx.abs() < 1 && dy.abs() < 1) return;

    final horizontaal = dx.abs() >= dy.abs();

    late double schermBreedte;
    late double schermHoogte;

    if (horizontaal) {
      schermBreedte = dx.abs();
      schermHoogte = schermBreedte * (hoogteMm / breedteMm);
    } else {
      schermHoogte = dy.abs();
      schermBreedte = schermHoogte * (breedteMm / hoogteMm);
    }

    final naarRechts = dx >= 0;
    final naarBeneden = dy >= 0;

    final left = naarRechts ? _startPunt!.dx : _startPunt!.dx - schermBreedte;
    final top = naarBeneden ? _startPunt!.dy : _startPunt!.dy - schermHoogte;

    setState(() {
      _rechthoek = Rect.fromLTWH(
        left,
        top,
        schermBreedte,
        schermHoogte,
      );
    });
  }

  void _tStijlToevoegen() {
    if (_rechthoek == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Teken eerst een rechthoek.'),
        ),
      );
      return;
    }

    final afstand = _getal(_tStijlAfstandController);

    if (afstand == null || afstand <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geef een geldige afstand in mm in.'),
        ),
      );
      return;
    }

    setState(() {
      _tStijlAfstandenMm.add(afstand);
      _tStijlAfstandController.clear();
    });
  }

  void _klikCanvas(TapDownDetails details) {
    if (_rechthoek == null) return;

    final punt = _snapNaarPuntOfRaster(details.localPosition);

    if (_tool == 'lijn') {
      _klikLijn(punt);
      return;
    }

    if (_tool == 'driehoek') {
      _klikDriehoek(punt, details.localPosition);
      return;
    }
  }

  void _klikLijn(Offset punt) {
    setState(() {
      if (_lijnStart == null) {
        _lijnStart = punt;
        return;
      }

      if ((_lijnStart! - punt).distance < 1) return;

      _extraLijnen.add(
        OpmetingLijn(
          id: 'extra_${_extraLijnen.length}',
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

      final top = _berekenDriehoekPunt(
        punt1: _driehoekPunt1!,
        punt2: _driehoekPunt2!,
        richtingKlik: vrijeKlik,
      );

      if (top == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geen evenwijdige lijn gevonden voor de driehoek.'),
          ),
        );

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

  Offset? _berekenDriehoekPunt({
    required Offset punt1,
    required Offset punt2,
    required Offset richtingKlik,
  }) {
    final basis = punt2 - punt1;
    final basisLengte = basis.distance;

    if (basisLengte < 1) return null;

    final basisUnit = Offset(
      basis.dx / basisLengte,
      basis.dy / basisLengte,
    );

    var normaal = Offset(
      -basisUnit.dy,
      basisUnit.dx,
    );

    final midden = Offset(
      (punt1.dx + punt2.dx) / 2,
      (punt1.dy + punt2.dy) / 2,
    );

    final klikVector = richtingKlik - midden;

    if (_dot(klikVector, normaal) < 0) {
      normaal = -normaal;
    }

    Offset? beste;
    var besteAfstand = double.infinity;

    for (final lijn in _alleLijnen()) {
      if (_isZelfdeLijn(lijn, punt1, punt2)) continue;

      final lijnVector = lijn.einde - lijn.start;
      final lijnLengte = lijnVector.distance;

      if (lijnLengte < 1) continue;

      final lijnUnit = Offset(
        lijnVector.dx / lijnLengte,
        lijnVector.dy / lijnLengte,
      );

      final parallel = _kruis(basisUnit, lijnUnit).abs() < 0.03;

      if (!parallel) continue;

      final afstandOpNormaal = _dot(lijn.start - midden, normaal);

      if (afstandOpNormaal <= 1) continue;

      final kandidaat = midden + (normaal * afstandOpNormaal);

      if (!_puntOpLijnstuk(kandidaat, lijn.start, lijn.einde)) continue;

      if (afstandOpNormaal < besteAfstand) {
        besteAfstand = afstandOpNormaal;
        beste = kandidaat;
      }
    }

    return beste;
  }

  bool _isZelfdeLijn(
    OpmetingLijn lijn,
    Offset punt1,
    Offset punt2,
  ) {
    final d1 = (lijn.start - punt1).distance + (lijn.einde - punt2).distance;
    final d2 = (lijn.start - punt2).distance + (lijn.einde - punt1).distance;

    return d1 < 1 || d2 < 1;
  }

  bool _puntOpLijnstuk(
    Offset punt,
    Offset start,
    Offset einde,
  ) {
    final lijn = einde - start;
    final lengte = lijn.distance;

    if (lengte < 1) return false;

    final afstand = _afstandTotLijnstuk(punt: punt, start: start, einde: einde);

    if (afstand > 1.5) return false;

    final minX = math.min(start.dx, einde.dx) - 1;
    final maxX = math.max(start.dx, einde.dx) + 1;
    final minY = math.min(start.dy, einde.dy) - 1;
    final maxY = math.max(start.dy, einde.dy) + 1;

    return punt.dx >= minX &&
        punt.dx <= maxX &&
        punt.dy >= minY &&
        punt.dy <= maxY;
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

  double _dot(Offset a, Offset b) {
    return (a.dx * b.dx) + (a.dy * b.dy);
  }

  double _kruis(Offset a, Offset b) {
    return (a.dx * b.dy) - (a.dy * b.dx);
  }

  void _undo() {
    setState(() {
      if (_driehoeken.isNotEmpty) {
        _driehoeken.removeLast();
        return;
      }

      if (_extraLijnen.isNotEmpty) {
        _extraLijnen.removeLast();
        return;
      }

      if (_tStijlAfstandenMm.isNotEmpty) {
        _tStijlAfstandenMm.removeLast();
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
      _tStijlAfstandenMm.clear();
      _extraLijnen.clear();
      _driehoeken.clear();
      _lijnStart = null;
      _driehoekPunt1 = null;
      _driehoekPunt2 = null;
      _actiefSnappunt = null;
    });
  }

  Widget _veld({
    required TextEditingController controller,
    required String label,
  }) {
    return SizedBox(
      width: 112,
      height: 42,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _keuze({
    required String waarde,
    required List<String> opties,
    required ValueChanged<String> onChanged,
  }) {
    return SizedBox(
      height: 42,
      child: DropdownButtonHideUnderline(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFE5E7EB),
            ),
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          child: DropdownButton<String>(
            value: waarde,
            isDense: true,
            items: opties.map((optie) {
              return DropdownMenuItem<String>(
                value: optie,
                child: Text(optie),
              );
            }).toList(),
            onChanged: (nieuw) {
              if (nieuw == null) return;
              onChanged(nieuw);
            },
          ),
        ),
      ),
    );
  }

  Widget _toolKnop({
    required String waarde,
    required String tekst,
    required IconData icoon,
  }) {
    final actief = _tool == waarde;

    return InkWell(
      onTap: () {
        setState(() {
          _tool = waarde;
          _lijnStart = null;
          _driehoekPunt1 = null;
          _driehoekPunt2 = null;
        });
      },
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: actief ? const Color(0xFF0B7A3B) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: actief ? const Color(0xFF0B7A3B) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icoon,
              size: 18,
              color: actief ? Colors.white : const Color(0xFF111827),
            ),
            const SizedBox(width: 6),
            Text(
              tekst,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: actief ? Colors.white : const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _instructie {
    if (_rechthoek == null) {
      return 'Geef breedte/hoogte in en teken de eerste lijn.';
    }

    if (_tool == 'lijn') {
      return _lijnStart == null
          ? 'Klik op eerste snappunt voor lijn.'
          : 'Klik op tweede snappunt om lijn te plaatsen.';
    }

    if (_driehoekPunt1 == null) {
      return 'Driehoek: klik hoek 1 op snappunt.';
    }

    if (_driehoekPunt2 == null) {
      return 'Driehoek: klik hoek 2 op snappunt.';
    }

    return 'Klik richting waar de punt van de driehoek moet komen.';
  }

  @override
  Widget build(BuildContext context) {
    final lijnen = _alleLijnen();
    final snappunten = _snappunten();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B7A3B),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home, size: 24),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Opmeting',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Ongedaan maken',
            onPressed: _undo,
            icon: const Icon(Icons.undo),
          ),
          IconButton(
            tooltip: 'Alles wissen',
            onPressed: _allesWissen,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _veld(
                  controller: _breedteController,
                  label: 'Breedte mm',
                ),
                _veld(
                  controller: _hoogteController,
                  label: 'Hoogte mm',
                ),
                _keuze(
                  waarde: _tStijlRichting,
                  opties: const ['Verticaal', 'Horizontaal'],
                  onChanged: (waarde) {
                    setState(() {
                      _tStijlRichting = waarde;
                      _tStijlAfstandenMm.clear();
                    });
                  },
                ),
                _veld(
                  controller: _tStijlAfstandController,
                  label: 'T-stijl mm',
                ),
                _keuze(
                  waarde: _tStijlVanaf,
                  opties: const ['Links', 'Rechts'],
                  onChanged: (waarde) {
                    setState(() {
                      _tStijlVanaf = waarde;
                      _tStijlAfstandenMm.clear();
                    });
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B7A3B),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _tStijlToevoegen,
                  child: const Text('T-stijl'),
                ),
                _toolKnop(
                  waarde: 'lijn',
                  tekst: 'Lijn',
                  icoon: Icons.show_chart,
                ),
                _toolKnop(
                  waarde: 'driehoek',
                  tekst: 'Driehoek',
                  icoon: Icons.change_history,
                ),
                Text(
                  _instructie,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ClipRect(
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
                      painter: _OpmetingPainter(
                        startPunt: _startPunt,
                        eindPunt: _eindPunt,
                        rechthoek: _rechthoek,
                        lijnen: lijnen,
                        snappunten: snappunten,
                        actiefSnappunt: _actiefSnappunt,
                        lijnStart: _lijnStart,
                        driehoekPunt1: _driehoekPunt1,
                        driehoekPunt2: _driehoekPunt2,
                        raster10cm: raster10cm,
                        raster5mm: raster5mm,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OpmetingLijn {
  const OpmetingLijn({
    required this.id,
    required this.start,
    required this.einde,
  });

  final String id;
  final Offset start;
  final Offset einde;
}

class OpmetingDriehoek {
  const OpmetingDriehoek({
    required this.punt1,
    required this.punt2,
    required this.punt3,
  });

  final Offset punt1;
  final Offset punt2;
  final Offset punt3;
}

class _OpmetingPainter extends CustomPainter {
  _OpmetingPainter({
    required this.startPunt,
    required this.eindPunt,
    required this.rechthoek,
    required this.lijnen,
    required this.snappunten,
    required this.actiefSnappunt,
    required this.lijnStart,
    required this.driehoekPunt1,
    required this.driehoekPunt2,
    required this.raster10cm,
    required this.raster5mm,
  });

  final Offset? startPunt;
  final Offset? eindPunt;
  final Rect? rechthoek;

  final List<OpmetingLijn> lijnen;
  final List<Offset> snappunten;
  final Offset? actiefSnappunt;

  final Offset? lijnStart;
  final Offset? driehoekPunt1;
  final Offset? driehoekPunt2;

  final double raster10cm;
  final double raster5mm;

  @override
  void paint(Canvas canvas, Size size) {
    final kleineLijn = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 0.35;

    final groteLijn = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 0.8;

    final lijnPaint = Paint()
      ..color = const Color(0xFF0B7A3B)
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round;

    final previewPaint = Paint()
      ..color = const Color(0xFF0B7A3B).withOpacity(0.45)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final snapPaint = Paint()
      ..color = const Color(0xFF0B7A3B)
      ..style = PaintingStyle.fill;

    final snapZacht = Paint()
      ..color = const Color(0xFF0B7A3B).withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final snapActief = Paint()
      ..color = const Color(0xFFDC2626)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    final gekozenPuntPaint = Paint()
      ..color = const Color(0xFFF97316)
      ..style = PaintingStyle.fill;

    for (double x = 0; x <= size.width; x += raster5mm) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), kleineLijn);
    }

    for (double y = 0; y <= size.height; y += raster5mm) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), kleineLijn);
    }

    for (double x = 0; x <= size.width; x += raster10cm) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), groteLijn);
    }

    for (double y = 0; y <= size.height; y += raster10cm) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), groteLijn);
    }

    if (startPunt != null && eindPunt != null && rechthoek == null) {
      canvas.drawLine(startPunt!, eindPunt!, previewPaint);
      canvas.drawCircle(startPunt!, 4, previewPaint);
      canvas.drawCircle(eindPunt!, 4, previewPaint);
    }

    for (final lijn in lijnen) {
      canvas.drawLine(lijn.start, lijn.einde, lijnPaint);
    }

    for (final punt in snappunten) {
      canvas.drawCircle(punt, 7, snapZacht);
      canvas.drawCircle(punt, 4.2, snapPaint);
    }

    if (actiefSnappunt != null) {
      canvas.drawCircle(actiefSnappunt!, 20, snapActief);
    }

    if (lijnStart != null) {
      canvas.drawCircle(lijnStart!, 6, gekozenPuntPaint);
    }

    if (driehoekPunt1 != null) {
      canvas.drawCircle(driehoekPunt1!, 6, gekozenPuntPaint);
    }

    if (driehoekPunt2 != null) {
      canvas.drawCircle(driehoekPunt2!, 6, gekozenPuntPaint);
      canvas.drawLine(driehoekPunt1!, driehoekPunt2!, previewPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OpmetingPainter oldDelegate) {
    return true;
  }
}
