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

  final List<OpmetingLijn> _extraLijnen = [];
  Offset? _vrijeLijnStart;
  Offset? _vrijeLijnHuidig;

  String _modus = 'rechthoek';
  String _tStijlRichting = 'Verticaal';
  String _tStijlVanaf = 'Links';

  double? _tStijlAfstandMm;

  final Map<String, int> _snappuntenPerLijn = {};

  String? _lijnAanHetVerdelen;
  int _startAantalVerdeling = 0;
  int _huidigAantalVerdeling = 0;

  static const double raster10cm = 200;
  static const double raster5mm = raster10cm / 20;

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
    final tLijn = _tStijlLijn();

    if (tLijn == null) {
      lijnen.addAll([
        OpmetingLijn(
          id: 'boven',
          start: r.topLeft,
          einde: r.topRight,
        ),
        OpmetingLijn(
          id: 'rechts',
          start: r.topRight,
          einde: r.bottomRight,
        ),
        OpmetingLijn(
          id: 'onder',
          start: r.bottomLeft,
          einde: r.bottomRight,
        ),
        OpmetingLijn(
          id: 'links',
          start: r.topLeft,
          einde: r.bottomLeft,
        ),
      ]);

      return lijnen;
    }

    if (_tStijlRichting == 'Verticaal') {
      final x = tLijn.start.dx;
      final bovenPunt = Offset(x, r.top);
      final onderPunt = Offset(x, r.bottom);

      lijnen.addAll([
        OpmetingLijn(
          id: 'boven_links',
          start: r.topLeft,
          einde: bovenPunt,
        ),
        OpmetingLijn(
          id: 'boven_rechts',
          start: bovenPunt,
          einde: r.topRight,
        ),
        OpmetingLijn(
          id: 'onder_links',
          start: r.bottomLeft,
          einde: onderPunt,
        ),
        OpmetingLijn(
          id: 'onder_rechts',
          start: onderPunt,
          einde: r.bottomRight,
        ),
        OpmetingLijn(
          id: 'links',
          start: r.topLeft,
          einde: r.bottomLeft,
        ),
        OpmetingLijn(
          id: 'rechts',
          start: r.topRight,
          einde: r.bottomRight,
        ),
        OpmetingLijn(
          id: 'tstijl',
          start: bovenPunt,
          einde: onderPunt,
        ),
      ]);
    } else {
      final y = tLijn.start.dy;
      final linksPunt = Offset(r.left, y);
      final rechtsPunt = Offset(r.right, y);

      lijnen.addAll([
        OpmetingLijn(
          id: 'links_boven',
          start: r.topLeft,
          einde: linksPunt,
        ),
        OpmetingLijn(
          id: 'links_onder',
          start: linksPunt,
          einde: r.bottomLeft,
        ),
        OpmetingLijn(
          id: 'rechts_boven',
          start: r.topRight,
          einde: rechtsPunt,
        ),
        OpmetingLijn(
          id: 'rechts_onder',
          start: rechtsPunt,
          einde: r.bottomRight,
        ),
        OpmetingLijn(
          id: 'boven',
          start: r.topLeft,
          einde: r.topRight,
        ),
        OpmetingLijn(
          id: 'onder',
          start: r.bottomLeft,
          einde: r.bottomRight,
        ),
        OpmetingLijn(
          id: 'tstijl',
          start: linksPunt,
          einde: rechtsPunt,
        ),
      ]);
    }

    return lijnen;
  }

  List<OpmetingLijn> _alleLijnen() {
    final lijnen = <OpmetingLijn>[
      ..._basisLijnen(),
    ];

    for (int i = 0; i < _extraLijnen.length; i++) {
      final lijn = _extraLijnen[i];
      lijnen.add(
        OpmetingLijn(
          id: 'extra_$i',
          start: lijn.start,
          einde: lijn.einde,
        ),
      );
    }

    return lijnen;
  }

  List<Offset> _snappunten() {
    final punten = <Offset>[];

    for (final lijn in _alleLijnen()) {
      punten.add(lijn.start);
      punten.add(lijn.einde);

      final aantal = _snappuntenPerLijn[lijn.id] ?? 0;

      for (int i = 1; i <= aantal; i++) {
        final factor = i / (aantal + 1);

        punten.add(
          Offset(
            lijn.start.dx + ((lijn.einde.dx - lijn.start.dx) * factor),
            lijn.start.dy + ((lijn.einde.dy - lijn.start.dy) * factor),
          ),
        );
      }
    }

    return punten;
  }

  Offset _snapNaarPuntOfRaster(Offset punt) {
    final punten = _snappunten();

    Offset? beste;
    double besteAfstand = 999999;

    for (final p in punten) {
      final afstand = (p - punt).distance;

      if (afstand < besteAfstand) {
        besteAfstand = afstand;
        beste = p;
      }
    }

    if (beste != null && besteAfstand <= 24) {
      return beste;
    }

    return _snapRaster(punt);
  }

  void _startTekenen(DragStartDetails details) {
    if (_lijnAanHetVerdelen != null) return;

    final punt = _modus == 'lijn'
        ? _snapNaarPuntOfRaster(details.localPosition)
        : _snapRaster(details.localPosition);

    setState(() {
      if (_modus == 'lijn' && _rechthoek != null) {
        _vrijeLijnStart = punt;
        _vrijeLijnHuidig = punt;
      } else {
        _startPunt = punt;
        _eindPunt = punt;
        _rechthoek = null;
        _extraLijnen.clear();
        _snappuntenPerLijn.clear();
        _tStijlAfstandMm = null;
      }
    });
  }

  void _updateTekenen(DragUpdateDetails details) {
    if (_lijnAanHetVerdelen != null) return;

    final punt = _modus == 'lijn'
        ? _snapNaarPuntOfRaster(details.localPosition)
        : _snapRaster(details.localPosition);

    setState(() {
      if (_modus == 'lijn' && _rechthoek != null) {
        _vrijeLijnHuidig = punt;
      } else {
        _eindPunt = punt;
      }
    });
  }

  void _stopTekenen(DragEndDetails details) {
    if (_lijnAanHetVerdelen != null) return;

    if (_modus == 'lijn' && _rechthoek != null) {
      _stopVrijeLijn();
    } else {
      _maakRechthoek();
    }
  }

  void _stopVrijeLijn() {
    if (_vrijeLijnStart == null || _vrijeLijnHuidig == null) return;

    if ((_vrijeLijnStart! - _vrijeLijnHuidig!).distance < 1) {
      setState(() {
        _vrijeLijnStart = null;
        _vrijeLijnHuidig = null;
      });
      return;
    }

    setState(() {
      _extraLijnen.add(
        OpmetingLijn(
          id: 'extra_${_extraLijnen.length}',
          start: _vrijeLijnStart!,
          einde: _vrijeLijnHuidig!,
        ),
      );

      _vrijeLijnStart = null;
      _vrijeLijnHuidig = null;
    });
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
      _modus = 'lijn';
    });
  }

  OpmetingLijn? _tStijlLijn() {
    if (_rechthoek == null || _tStijlAfstandMm == null) return null;

    final breedteMm = _getal(_breedteController);
    final hoogteMm = _getal(_hoogteController);

    if (breedteMm == null || hoogteMm == null) return null;

    final r = _rechthoek!;

    if (_tStijlRichting == 'Verticaal') {
      final afstandPx = r.width * (_tStijlAfstandMm! / breedteMm);

      final x =
          _tStijlVanaf == 'Links' ? r.left + afstandPx : r.right - afstandPx;

      if (x <= r.left || x >= r.right) return null;

      return OpmetingLijn(
        id: 'tstijl',
        start: Offset(x, r.top),
        einde: Offset(x, r.bottom),
      );
    }

    final afstandPx = r.height * (_tStijlAfstandMm! / hoogteMm);

    final y =
        _tStijlVanaf == 'Links' ? r.top + afstandPx : r.bottom - afstandPx;

    if (y <= r.top || y >= r.bottom) return null;

    return OpmetingLijn(
      id: 'tstijl',
      start: Offset(r.left, y),
      einde: Offset(r.right, y),
    );
  }

  void _tStijlInvoegen() {
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
      _tStijlAfstandMm = afstand;
      _snappuntenPerLijn.remove('boven');
      _snappuntenPerLijn.remove('onder');
      _snappuntenPerLijn.remove('links');
      _snappuntenPerLijn.remove('rechts');
    });
  }

  void _startVerdelen(LongPressStartDetails details) {
    final lijn = _lijnDichtstBij(details.localPosition);

    if (lijn == null) return;

    setState(() {
      _lijnAanHetVerdelen = lijn.id;
      _startAantalVerdeling = _snappuntenPerLijn[lijn.id] ?? 0;
      _huidigAantalVerdeling = _startAantalVerdeling;
    });
  }

  void _updateVerdelen(LongPressMoveUpdateDetails details) {
    if (_lijnAanHetVerdelen == null) return;

    final verschil = details.offsetFromOrigin.dx;
    final stap = (verschil / 28).round();

    final nieuwAantal = (_startAantalVerdeling + stap).clamp(0, 12);

    setState(() {
      _huidigAantalVerdeling = nieuwAantal;
      _snappuntenPerLijn[_lijnAanHetVerdelen!] = nieuwAantal;
    });
  }

  void _stopVerdelen(LongPressEndDetails details) {
    setState(() {
      _lijnAanHetVerdelen = null;
    });
  }

  OpmetingLijn? _lijnDichtstBij(Offset punt) {
    OpmetingLijn? besteLijn;
    double besteAfstand = 999999;

    for (final lijn in _alleLijnen()) {
      final afstand = _afstandTotLijnstuk(
        punt,
        lijn.start,
        lijn.einde,
      );

      if (afstand < besteAfstand) {
        besteAfstand = afstand;
        besteLijn = lijn;
      }
    }

    if (besteAfstand <= 20) {
      return besteLijn;
    }

    return null;
  }

  double _afstandTotLijnstuk(
    Offset punt,
    Offset start,
    Offset einde,
  ) {
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

  void _undo() {
    setState(() {
      if (_extraLijnen.isNotEmpty) {
        _snappuntenPerLijn.remove('extra_${_extraLijnen.length - 1}');
        _extraLijnen.removeLast();
        return;
      }

      if (_tStijlAfstandMm != null) {
        _snappuntenPerLijn.remove('tstijl');
        _tStijlAfstandMm = null;
        return;
      }

      _rechthoek = null;
      _startPunt = null;
      _eindPunt = null;
      _snappuntenPerLijn.clear();
      _modus = 'rechthoek';
    });
  }

  void _allesWissen() {
    setState(() {
      _startPunt = null;
      _eindPunt = null;
      _rechthoek = null;
      _extraLijnen.clear();
      _vrijeLijnStart = null;
      _vrijeLijnHuidig = null;
      _tStijlAfstandMm = null;
      _snappuntenPerLijn.clear();
      _lijnAanHetVerdelen = null;
      _modus = 'rechthoek';
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

  @override
  Widget build(BuildContext context) {
    final instructie = _lijnAanHetVerdelen != null
        ? 'Verdelen: $_huidigAantalVerdeling snappunten'
        : _rechthoek == null
            ? 'Teken eerste lijn voor rechthoek'
            : 'Teken lijnen via snappunten · lang drukken + schuiven = verdelen';

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
                    });
                  },
                ),
                _veld(
                  controller: _tStijlAfstandController,
                  label: 'Afstand mm',
                ),
                _keuze(
                  waarde: _tStijlVanaf,
                  opties: const ['Links', 'Rechts'],
                  onChanged: (waarde) {
                    setState(() {
                      _tStijlVanaf = waarde;
                    });
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B7A3B),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _tStijlInvoegen,
                  child: const Text('T-stijl'),
                ),
                Text(
                  instructie,
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
                child: GestureDetector(
                  onPanStart: _startTekenen,
                  onPanUpdate: _updateTekenen,
                  onPanEnd: _stopTekenen,
                  onLongPressStart: _startVerdelen,
                  onLongPressMoveUpdate: _updateVerdelen,
                  onLongPressEnd: _stopVerdelen,
                  child: CustomPaint(
                    painter: _OpmetingPainter(
                      startPunt: _startPunt,
                      eindPunt: _eindPunt,
                      rechthoek: _rechthoek,
                      vrijeLijnStart: _vrijeLijnStart,
                      vrijeLijnHuidig: _vrijeLijnHuidig,
                      lijnen: _alleLijnen(),
                      tStijlLijnId: 'tstijl',
                      geselecteerdeLijnId: _lijnAanHetVerdelen,
                      snappunten: _snappunten(),
                      raster10cm: raster10cm,
                      raster5mm: raster5mm,
                    ),
                    child: const SizedBox.expand(),
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
  OpmetingLijn({
    required this.id,
    required this.start,
    required this.einde,
  });

  final String id;
  final Offset start;
  final Offset einde;
}

class _OpmetingPainter extends CustomPainter {
  _OpmetingPainter({
    required this.startPunt,
    required this.eindPunt,
    required this.rechthoek,
    required this.vrijeLijnStart,
    required this.vrijeLijnHuidig,
    required this.lijnen,
    required this.tStijlLijnId,
    required this.geselecteerdeLijnId,
    required this.snappunten,
    required this.raster10cm,
    required this.raster5mm,
  });

  final Offset? startPunt;
  final Offset? eindPunt;
  final Rect? rechthoek;

  final Offset? vrijeLijnStart;
  final Offset? vrijeLijnHuidig;

  final List<OpmetingLijn> lijnen;
  final String tStijlLijnId;
  final String? geselecteerdeLijnId;
  final List<Offset> snappunten;

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

    final gewoneLijn = Paint()
      ..color = const Color(0xFF0B7A3B)
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round;

    final geselecteerdeLijn = Paint()
      ..color = const Color(0xFFF97316)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final previewLijn = Paint()
      ..color = const Color(0xFF0B7A3B).withOpacity(0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final snapPaint = Paint()
      ..color = const Color(0xFF0B7A3B)
      ..style = PaintingStyle.fill;

    final snapZacht = Paint()
      ..color = const Color(0xFF0B7A3B).withOpacity(0.12)
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
      canvas.drawLine(startPunt!, eindPunt!, previewLijn);
      canvas.drawCircle(startPunt!, 4, previewLijn);
      canvas.drawCircle(eindPunt!, 4, previewLijn);
    }

    for (final lijn in lijnen) {
      final paint =
          lijn.id == geselecteerdeLijnId ? geselecteerdeLijn : gewoneLijn;

      canvas.drawLine(
        lijn.start,
        lijn.einde,
        paint,
      );
    }

    if (vrijeLijnStart != null && vrijeLijnHuidig != null) {
      canvas.drawLine(
        vrijeLijnStart!,
        vrijeLijnHuidig!,
        previewLijn,
      );
    }

    for (final punt in snappunten) {
      canvas.drawCircle(punt, 7, snapZacht);
      canvas.drawCircle(punt, 4.2, snapPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OpmetingPainter oldDelegate) {
    return true;
  }
}
