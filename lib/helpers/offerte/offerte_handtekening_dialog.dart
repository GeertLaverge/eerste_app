import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'offerte_goedkeuring_model.dart';

class OfferteHandtekeningDialog extends StatefulWidget {
  const OfferteHandtekeningDialog({
    super.key,
    required this.klantNaam,
    required this.offerteNummer,
    required this.totaalTekst,
  });

  final String klantNaam;
  final String offerteNummer;
  final String totaalTekst;

  static Future<OfferteGoedkeuring?> toon({
    required BuildContext context,
    required String klantNaam,
    required String offerteNummer,
    required String totaalTekst,
  }) {
    return showDialog<OfferteGoedkeuring>(
      context: context,
      barrierDismissible: false,
      builder: (context) => OfferteHandtekeningDialog(
        klantNaam: klantNaam,
        offerteNummer: offerteNummer,
        totaalTekst: totaalTekst,
      ),
    );
  }

  @override
  State<OfferteHandtekeningDialog> createState() {
    return _OfferteHandtekeningDialogState();
  }
}

class _OfferteHandtekeningDialogState extends State<OfferteHandtekeningDialog> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _oranje = Color(0xFFF15A24);

  late final TextEditingController _naamController;
  final List<List<Offset>> _streken = <List<Offset>>[];
  Size _tekenGrootte = Size.zero;
  bool _bevestigenBezig = false;

  @override
  void initState() {
    super.initState();
    _naamController = TextEditingController(text: widget.klantNaam.trim());
  }

  @override
  void dispose() {
    _naamController.dispose();
    super.dispose();
  }

  bool get _heeftHandtekening {
    return _streken.any((streek) => streek.length >= 2);
  }

  void _startStreek(DragStartDetails details) {
    setState(() {
      _streken.add(<Offset>[details.localPosition]);
    });
  }

  void _voegPuntToe(DragUpdateDetails details) {
    if (_streken.isEmpty) return;
    setState(() {
      _streken.last.add(details.localPosition);
    });
  }

  void _wisHandtekening() {
    setState(_streken.clear);
  }

  Future<void> _bevestig() async {
    if (_bevestigenBezig) return;

    final naam = _naamController.text.trim();
    if (naam.isEmpty) {
      _toonMelding('Vul de naam van de klant in.');
      return;
    }
    if (!_heeftHandtekening) {
      _toonMelding('Laat de klant eerst tekenen in het witte vlak.');
      return;
    }
    if (_tekenGrootte.width <= 0 || _tekenGrootte.height <= 0) {
      _toonMelding('Het handtekeningvlak is nog niet klaar. Probeer opnieuw.');
      return;
    }

    setState(() {
      _bevestigenBezig = true;
    });

    try {
      final png = await _maakHandtekeningPng();
      if (!mounted) return;

      Navigator.of(context).pop(
        OfferteGoedkeuring(
          naam: naam,
          getekendOp: DateTime.now(),
          handtekeningPng: png,
        ),
      );
    } catch (fout) {
      if (!mounted) return;
      _toonMelding('De handtekening kon niet worden opgeslagen.\n$fout');
      setState(() {
        _bevestigenBezig = false;
      });
    }
  }

  Future<Uint8List> _maakHandtekeningPng() async {
    const uitvoerBreedte = 1400;
    const uitvoerHoogte = 420;
    final schaalX = uitvoerBreedte / _tekenGrootte.width;
    final schaalY = uitvoerHoogte / _tekenGrootte.height;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 3.2 * ((schaalX + schaalY) / 2)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final streek in _streken) {
      if (streek.length < 2) continue;
      final path = Path();
      path.moveTo(streek.first.dx * schaalX, streek.first.dy * schaalY);
      for (final punt in streek.skip(1)) {
        path.lineTo(punt.dx * schaalX, punt.dy * schaalY);
      }
      canvas.drawPath(path, paint);
    }

    final afbeelding = await recorder.endRecording().toImage(
      uitvoerBreedte,
      uitvoerHoogte,
    );
    final byteData = await afbeelding.toByteData(
      format: ui.ImageByteFormat.png,
    );
    afbeelding.dispose();

    if (byteData == null) {
      throw StateError('Geen PNG-gegevens ontvangen.');
    }
    return byteData.buffer.asUint8List();
  }

  void _toonMelding(String tekst) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tekst), backgroundColor: const Color(0xFFB91C1C)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scherm = MediaQuery.sizeOf(context);
    final dialoogBreedte = scherm.width < 760 ? scherm.width - 24 : 720.0;
    final tekenHoogte = scherm.height < 700 ? 210.0 : 260.0;

    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialoogBreedte),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1E8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.draw_outlined, color: _oranje),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Offerte laten ondertekenen',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'De klant kan tekenen met de vinger of Apple Pencil.',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Sluiten',
                    onPressed: _bevestigenBezig
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Wrap(
                  spacing: 18,
                  runSpacing: 5,
                  children: <Widget>[
                    _InfoTekst(
                      label: 'Offerte',
                      waarde: widget.offerteNummer.trim().isEmpty
                          ? 'Zonder nummer'
                          : widget.offerteNummer.trim(),
                    ),
                    _InfoTekst(
                      label: 'Totaal incl. btw',
                      waarde: widget.totaalTekst,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _naamController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Naam klant',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'Handtekening klant',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _streken.isEmpty ? null : _wisHandtekening,
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Wissen'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: tekenHoogte,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    _tekenGrootte = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: _startStreek,
                      onPanUpdate: _voegPuntToe,
                      child: CustomPaint(
                        foregroundPainter: _HandtekeningPainter(_streken),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFD1D5DB),
                              width: 1.2,
                            ),
                          ),
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.only(bottom: 14),
                          child: const Text(
                            'Teken hierboven',
                            style: TextStyle(
                              color: Color(0xFFB0B5BD),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: _bevestigenBezig
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Annuleren'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: _groen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 13,
                      ),
                    ),
                    onPressed: _bevestigenBezig ? null : _bevestig,
                    icon: _bevestigenBezig
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded),
                    label: const Text(
                      'Ondertekening bevestigen',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HandtekeningPainter extends CustomPainter {
  const _HandtekeningPainter(this.streken);

  final List<List<Offset>> streken;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final streek in streken) {
      if (streek.length < 2) continue;
      final path = Path()..moveTo(streek.first.dx, streek.first.dy);
      for (final punt in streek.skip(1)) {
        path.lineTo(punt.dx, punt.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HandtekeningPainter oldDelegate) => true;
}

class _InfoTekst extends StatelessWidget {
  const _InfoTekst({required this.label, required this.waarde});

  final String label;
  final String waarde;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Color(0xFF22272D), fontSize: 12),
        children: <InlineSpan>[
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: waarde),
        ],
      ),
    );
  }
}
