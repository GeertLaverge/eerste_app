// THIMACO-CONTROLE: MAGAZIJN-GRAFISCH-MUISWIEL-20260804

import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../helpers/magazijn/magazijn_controller.dart';
import '../../helpers/magazijn/magazijn_model.dart';

class MagazijnScanPagina extends StatefulWidget {
  const MagazijnScanPagina({super.key, required this.controller});

  final MagazijnController controller;

  @override
  State<MagazijnScanPagina> createState() => _MagazijnScanPaginaState();
}

class _MagazijnScanPaginaState extends State<MagazijnScanPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _lichtGroen = Color(0xFFE7F6EC);

  final MobileScannerController _scannerController = MobileScannerController();

  MagazijnArtikel? _artikel;
  int _wijziging = 0;
  bool _scannerOpen = false;
  bool _bezig = false;
  bool _scanWordtVerwerkt = false;
  double _sleepRest = 0;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _resetWiel() {
    setState(() {
      _wijziging = 0;
      _sleepRest = 0;
    });
  }

  void _wijzigAantal(int stappen) {
    if (stappen == 0) return;

    setState(() {
      _wijziging = (_wijziging + stappen).clamp(-50, 50).toInt();
    });
  }

  void _verwerkSleep(double deltaY) {
    _sleepRest += deltaY;

    const pixelsPerStap = 12.0;
    while (_sleepRest.abs() >= pixelsPerStap) {
      if (_sleepRest < 0) {
        _wijzigAantal(1);
        _sleepRest += pixelsPerStap;
      } else {
        _wijzigAantal(-1);
        _sleepRest -= pixelsPerStap;
      }
    }
  }

  void _verwerkMuisWiel(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (event.scrollDelta.dy == 0) return;

    _wijzigAantal(event.scrollDelta.dy < 0 ? 1 : -1);
  }

  Future<void> _verwerkScan(String waarde) async {
    if (_scanWordtVerwerkt) return;
    _scanWordtVerwerkt = true;

    final artikel = widget.controller.artikelVoorQr(waarde);
    if (artikel == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deze QR-code hoort niet bij een artikel.'),
        ),
      );
      _scanWordtVerwerkt = false;
      return;
    }

    await _scannerController.stop();
    if (!mounted) return;

    setState(() {
      _artikel = artikel;
      _scannerOpen = false;
      _wijziging = 0;
      _sleepRest = 0;
      _scanWordtVerwerkt = false;
    });
  }

  Future<void> _bevestig() async {
    final artikel = _artikel;
    if (artikel == null || _wijziging == 0 || _bezig) {
      return;
    }

    setState(() => _bezig = true);

    await widget.controller.wijzigVoorraad(
      artikelId: artikel.id,
      verschil: _wijziging,
      reden: _wijziging < 0 ? 'Verbruik via QR-scan' : 'Aanvulling via QR-scan',
    );

    final bijgewerkt = widget.controller.data.artikelen.firstWhere(
      (item) => item.id == artikel.id,
    );

    if (!mounted) return;

    setState(() {
      _artikel = bijgewerkt;
      _bezig = false;
      _wijziging = 0;
      _sleepRest = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Stock aangepast naar ${bijgewerkt.stock} '
          '${bijgewerkt.eenheidVoorAantal(bijgewerkt.stock)}.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final artikel = _artikel;
    final nieuweStock = artikel == null
        ? 0
        : (artikel.stock + _wijziging).clamp(0, 999999).toInt();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _groen,
              minimumSize: const Size.fromHeight(62),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            onPressed: () async {
              setState(() {
                _scannerOpen = !_scannerOpen;
              });

              if (_scannerOpen) {
                await _scannerController.start();
              } else {
                await _scannerController.stop();
              }
            },
            icon: const Icon(Icons.qr_code_scanner, size: 28),
            label: Text(_scannerOpen ? 'Scanner sluiten' : 'Artikel scannen'),
          ),
        ),
        if (artikel != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(
            artikel.omschrijving,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ],
        if (_scannerOpen) ...<Widget>[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 280,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final scanGrootte = math.min(
                    180.0,
                    constraints.maxWidth - 48,
                  );
                  final scanRect = Rect.fromCenter(
                    center: Offset(
                      constraints.maxWidth / 2,
                      constraints.maxHeight / 2,
                    ),
                    width: scanGrootte,
                    height: scanGrootte,
                  );

                  return Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      MobileScanner(
                        controller: _scannerController,
                        scanWindow: scanRect,
                        onDetect: (capture) {
                          if (capture.barcodes.isEmpty) return;
                          final waarde = capture.barcodes.first.rawValue;
                          if (waarde != null) {
                            _verwerkScan(waarde);
                          }
                        },
                      ),
                      IgnorePointer(
                        child: Center(
                          child: Container(
                            width: scanGrootte,
                            height: scanGrootte,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _rand),
          ),
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: _lichtGroen,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Text(
                  artikel == null
                      ? 'Huidige stock: —'
                      : 'Huidige stock: ${artikel.stock} '
                            '${artikel.eenheidVoorAantal(artikel.stock)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _groen,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                child: Listener(
                  onPointerSignal: _verwerkMuisWiel,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragUpdate: (details) {
                      _verwerkSleep(details.delta.dy);
                    },
                    onVerticalDragEnd: (_) {
                      _sleepRest = 0;
                    },
                    child: Column(
                      children: <Widget>[
                        const Text(
                          'Draai het wiel omhoog om toe te voegen '
                          'en omlaag om af te nemen',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 210,
                          height: 190,
                          child: CustomPaint(
                            painter: _MuisWielPainter(
                              stand: _wijziging,
                              actief: artikel != null,
                            ),
                            child: const SizedBox.expand(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _wijziging == 0
                              ? 'Geen voorraadwijziging'
                              : _wijziging > 0
                              ? '$_wijziging '
                                    '${artikel?.eenheidVoorAantal(_wijziging) ?? ''} '
                                    'toevoegen'
                              : '${-_wijziging} '
                                    '${artikel?.eenheidVoorAantal(-_wijziging) ?? ''} '
                                    'afnemen',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _wijziging < 0
                                ? const Color(0xFFB91C1C)
                                : _groen,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          artikel == null
                              ? 'Nieuwe stock: —'
                              : 'Nieuwe stock: $nieuweStock '
                                    '${artikel.eenheidVoorAantal(nieuweStock)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (_wijziging != 0) ...<Widget>[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: _groen,
                            ),
                            onPressed: _resetWiel,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Terug naar nul'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: _groen,
            minimumSize: const Size.fromHeight(52),
          ),
          onPressed: artikel != null && _wijziging != 0 && !_bezig
              ? _bevestig
              : null,
          child: Text(_bezig ? 'Bezig...' : 'Stock aanpassen'),
        ),
        if (artikel != null) ...<Widget>[
          const SizedBox(height: 14),
          _ArtikelInfoKaart(artikel: artikel),
        ],
      ],
    );
  }
}

class _MuisWielPainter extends CustomPainter {
  const _MuisWielPainter({required this.stand, required this.actief});

  final int stand;
  final bool actief;

  static const Color _groen = Color(0xFF0B7A3B);

  @override
  void paint(Canvas canvas, Size size) {
    final midden = Offset(size.width / 2, size.height / 2);

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: midden,
        width: size.width * 0.76,
        height: size.height * 0.94,
      ),
      Radius.circular(size.width * 0.36),
    );

    final schaduwPad = Path()..addRRect(bodyRect);
    canvas.drawShadow(
      schaduwPad,
      Colors.black.withValues(alpha: 0.24),
      10,
      true,
    );

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFFF8FAFC),
          Color(0xFFD1D5DB),
          Color(0xFFF9FAFB),
        ],
      ).createShader(bodyRect.outerRect);
    canvas.drawRRect(bodyRect, bodyPaint);

    final randPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = actief ? _groen : const Color(0xFF9CA3AF);
    canvas.drawRRect(bodyRect, randPaint);

    final middenLijnPaint = Paint()
      ..color = const Color(0x33000000)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(midden.dx, bodyRect.top + 14),
      Offset(midden.dx, bodyRect.bottom - 14),
      middenLijnPaint,
    );

    final wheelRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: midden,
        width: size.width * 0.26,
        height: size.height * 0.50,
      ),
      Radius.circular(size.width * 0.13),
    );

    final wheelPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: actief
            ? const <Color>[
                Color(0xFF043D20),
                Color(0xFF0B7A3B),
                Color(0xFF15A34A),
                Color(0xFF0B7A3B),
                Color(0xFF043D20),
              ]
            : const <Color>[
                Color(0xFF6B7280),
                Color(0xFF9CA3AF),
                Color(0xFF6B7280),
              ],
      ).createShader(wheelRect.outerRect);
    canvas.drawRRect(wheelRect, wheelPaint);

    canvas.save();
    canvas.clipRRect(wheelRect);

    const aantalLijnen = 11;
    final afstand = wheelRect.height / 8;
    final offset = (stand % 8) * afstand / 8;

    final ribbelPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.62)
      ..strokeWidth = 2;

    for (var i = -2; i < aantalLijnen; i++) {
      final y = wheelRect.top + i * afstand + offset;
      canvas.drawLine(
        Offset(wheelRect.left + 6, y),
        Offset(wheelRect.right - 6, y),
        ribbelPaint,
      );
    }
    canvas.restore();

    final centrumMarkering = Paint()
      ..color = Colors.white
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(wheelRect.left + 5, wheelRect.center.dy),
      Offset(wheelRect.right - 5, wheelRect.center.dy),
      centrumMarkering,
    );

    final symboolStijl = TextStyle(
      color: actief ? _groen : const Color(0xFF9CA3AF),
      fontSize: 30,
      fontWeight: FontWeight.w900,
    );

    final plusPainter = TextPainter(
      text: TextSpan(text: '+', style: symboolStijl),
      textDirection: TextDirection.ltr,
    )..layout();
    plusPainter.paint(
      canvas,
      Offset(midden.dx - plusPainter.width / 2, bodyRect.top + 8),
    );

    final minPainter = TextPainter(
      text: TextSpan(text: '−', style: symboolStijl),
      textDirection: TextDirection.ltr,
    )..layout();
    minPainter.paint(
      canvas,
      Offset(
        midden.dx - minPainter.width / 2,
        bodyRect.bottom - minPainter.height - 8,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _MuisWielPainter oldDelegate) {
    return oldDelegate.stand != stand || oldDelegate.actief != actief;
  }
}

class _ArtikelInfoKaart extends StatelessWidget {
  const _ArtikelInfoKaart({required this.artikel});

  final MagazijnArtikel artikel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            artikel.omschrijving,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'Stock: ${artikel.stock} '
            '${artikel.eenheidVoorAantal(artikel.stock)}',
          ),
          Text('Minimum: ${artikel.minimumStock}'),
          Text(
            'Meebestellen vanaf: '
            '${artikel.meebestelgrens}',
          ),
          Text('Maximum: ${artikel.maximumStock}'),
        ],
      ),
    );
  }
}
