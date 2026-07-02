import 'package:flutter/material.dart';

import 'opmeting_raam_model.dart';
import 'opmeting_raam_vleugel_helper.dart';

class OpmetingRaamVleugelKeuzeRaster extends StatelessWidget {
  const OpmetingRaamVleugelKeuzeRaster({
    super.key,
    required this.geselecteerdType,
    required this.onTypeGeselecteerd,
  });

  final OpmetingRaamVleugelType geselecteerdType;
  final ValueChanged<OpmetingRaamVleugelType> onTypeGeselecteerd;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFD1D5DB);
  static const Color _tekst = Color(0xFF111827);
  static const Color _subtekst = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final types = OpmetingRaamVleugelType.values;

    return Container(
      width: 420,
      height: 590,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rand),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Vleugeltype',
            style: TextStyle(
              color: _groen,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Links en rechts bekeken vanaf de binnenzijde',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: _subtekst),
          ),
          const SizedBox(height: 10),
          _GeselecteerdeVleugelBalk(type: geselecteerdType),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(right: 4, bottom: 4),
              itemCount: types.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.35,
              ),
              itemBuilder: (context, index) {
                final type = types[index];

                return _VleugelKeuzeTegel(
                  type: type,
                  geselecteerd: type == geselecteerdType,
                  onTap: () {
                    onTypeGeselecteerd(type);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kies een tegel en klik daarna in het gewenste vlak.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: _subtekst),
          ),
        ],
      ),
    );
  }
}

class _GeselecteerdeVleugelBalk extends StatelessWidget {
  const _GeselecteerdeVleugelBalk({required this.type});

  final OpmetingRaamVleugelType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F6EC),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFF0B7A3B), width: 1.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            height: 42,
            child: CustomPaint(painter: _VleugelVoorbeeldPainter(type: type)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              type.naam,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF0B7A3B),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.check_circle, color: Color(0xFF0B7A3B), size: 20),
        ],
      ),
    );
  }
}

class _VleugelKeuzeTegel extends StatelessWidget {
  const _VleugelKeuzeTegel({
    required this.type,
    required this.geselecteerd,
    required this.onTap,
  });

  final OpmetingRaamVleugelType type;
  final bool geselecteerd;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final achtergrond = geselecteerd
        ? const Color(0xFFE7F6EC)
        : const Color(0xFFF9FAFB);

    final randKleur = geselecteerd
        ? const Color(0xFF0B7A3B)
        : const Color(0xFFD1D5DB);

    final tekstKleur = geselecteerd
        ? const Color(0xFF0B7A3B)
        : const Color(0xFF111827);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.fromLTRB(7, 7, 7, 6),
          decoration: BoxDecoration(
            color: achtergrond,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: randKleur, width: geselecteerd ? 2 : 1),
            boxShadow: geselecteerd
                ? [
                    BoxShadow(
                      color: const Color(0xFF0B7A3B).withOpacity(0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 2),
                      child: CustomPaint(
                        painter: _VleugelVoorbeeldPainter(type: type),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 31,
                    child: Center(
                      child: Text(
                        type.naam,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: tekstKleur,
                          fontSize: 10.5,
                          height: 1.15,
                          fontWeight: geselecteerd
                              ? FontWeight.w900
                              : FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (geselecteerd)
                const Positioned(
                  right: 0,
                  top: 0,
                  child: Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Color(0xFF0B7A3B),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VleugelVoorbeeldPainter extends CustomPainter {
  const _VleugelVoorbeeldPainter({required this.type});

  final OpmetingRaamVleugelType type;

  @override
  void paint(Canvas canvas, Size size) {
    final voorbeeldVlak = Rect.fromLTRB(4, 3, size.width - 4, size.height - 3);

    if (voorbeeldVlak.width <= 0 || voorbeeldVlak.height <= 0) {
      return;
    }

    final achtergrond = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final buitenLijn = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;

    canvas.drawRect(voorbeeldVlak, achtergrond);

    canvas.drawRect(voorbeeldVlak, buitenLijn);

    if (type == OpmetingRaamVleugelType.geenVleugel) {
      final wisLijn = Paint()
        ..color = const Color(0xFF9CA3AF)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        voorbeeldVlak.topLeft,
        voorbeeldVlak.bottomRight,
        wisLijn,
      );

      canvas.drawLine(
        voorbeeldVlak.topRight,
        voorbeeldVlak.bottomLeft,
        wisLijn,
      );

      return;
    }

    final voorbeeldVleugel = OpmetingRaamVleugel(
      id: 'voorbeeld',
      vlak: voorbeeldVlak,
      type: type,
    );

    OpmetingRaamVleugelHelper.tekenVleugel(
      canvas: canvas,
      vleugel: voorbeeldVleugel,
      buitenKader: voorbeeldVlak,
      breedteMm: 1000,
      hoogteMm: 800,
    );
  }

  @override
  bool shouldRepaint(covariant _VleugelVoorbeeldPainter oldDelegate) {
    return oldDelegate.type != type;
  }
}
