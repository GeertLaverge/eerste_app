// THIMACO-CONTROLE: SUBMENU-SELECTIESTIJL-FASE2-20260914
import 'package:flutter/material.dart';

import '../../ui/thimaco_huisstijl.dart';
import 'opmeting_raam_model.dart';
import 'opmeting_raam_vleugel_helper.dart';

class OpmetingRaamVleugelMenu extends StatelessWidget {
  const OpmetingRaamVleugelMenu({
    super.key,
    required this.menuGrootte,
    required this.geselecteerdType,
    required this.onTypeGekozen,
    required this.onSluiten,
    required this.onVerslepen,
  });

  final Size menuGrootte;
  final OpmetingRaamVleugelType geselecteerdType;
  final ValueChanged<OpmetingRaamVleugelType> onTypeGekozen;
  final VoidCallback onSluiten;
  final ValueChanged<DragUpdateDetails> onVerslepen;

  @override
  Widget build(BuildContext context) {
    final aantalKolommen = menuGrootte.width >= 320 ? 3 : 2;

    final geselecteerdIsDubbel = geselecteerdType.isDubbel;

    return Container(
      width: menuGrootte.width,
      height: menuGrootte.height,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ThimacoKleuren.rand),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: MouseRegion(
                  cursor: SystemMouseCursors.move,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: onVerslepen,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 2,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.drag_indicator,
                            size: 18,
                            color: ThimacoKleuren.tekstGrijs,
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.crop_square_rounded,
                            size: 17,
                            color: ThimacoKleuren.antraciet,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Vleugeltype',
                                  style: TextStyle(
                                    color: ThimacoKleuren.antraciet,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  width: 28,
                                  height: 1.5,
                                  decoration: BoxDecoration(
                                    color: ThimacoKleuren.oranje.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            'Versleep',
                            style: TextStyle(
                              fontSize: 9,
                              color: ThimacoKleuren.tekstGrijs,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              ThimacoIcoonActie(
                icoon: Icons.close_rounded,
                tooltip: 'Vleugelmenu sluiten',
                onPressed: onSluiten,
                grootte: 18,
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'Bekeken vanaf de binnenzijde',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: ThimacoKleuren.oranje,
                width: 1.4,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: geselecteerdIsDubbel ? 48 : 34,
                  height: 34,
                  child: CustomPaint(
                    painter: OpmetingRaamVleugelVoorbeeldPainter(
                      type: geselecteerdType,
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    geselecteerdType.naam,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ThimacoKleuren.antraciet,
                      fontSize: 10,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Icon(
                  Icons.check_circle,
                  color: ThimacoKleuren.oranje,
                  size: 17,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(right: 2, bottom: 2),
              itemCount: OpmetingRaamVleugelType.values.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: aantalKolommen,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                childAspectRatio: aantalKolommen == 3 ? 1.35 : 1.55,
              ),
              itemBuilder: (context, index) {
                final type = OpmetingRaamVleugelType.values[index];

                return _OpmetingRaamVleugelKeuzeTegel(
                  type: type,
                  geselecteerd: type == geselecteerdType,
                  onTap: () {
                    onTypeGekozen(type);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Kies een tegel en klik in het vlak.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

class OpmetingRaamTStijlMenu extends StatelessWidget {
  const OpmetingRaamTStijlMenu({
    super.key,
    required this.breedte,
    required this.maxHoogte,
    required this.positieType,
    required this.positieController,
    this.toonToevoegKnop = true,
    this.toonWisKnop = false,
    this.toonVerplaatsKnop = false,
    required this.onSluiten,
    required this.onVerslepen,
    required this.onPositieTypeGewijzigd,
    required this.onMaatGewijzigd,
    required this.onToevoegen,
    this.onVerplaatsen,
    required this.onWissen,
  });

  final double breedte;
  final double maxHoogte;

  final String positieType;
  final TextEditingController positieController;

  final bool toonToevoegKnop;
  final bool toonWisKnop;
  final bool toonVerplaatsKnop;

  final VoidCallback onSluiten;
  final ValueChanged<DragUpdateDetails> onVerslepen;

  final ValueChanged<String> onPositieTypeGewijzigd;
  final ValueChanged<String> onMaatGewijzigd;

  final VoidCallback onToevoegen;
  final VoidCallback? onVerplaatsen;
  final VoidCallback onWissen;

  static const Color _groen = ThimacoKleuren.oranje;
  static const Color _rand = ThimacoKleuren.rand;
  static const Color _tekstGrijs = ThimacoKleuren.tekstGrijs;

  static const List<String> _positieKeuzes = [
    'mm',
    '1/2',
    '1/3',
    '2/3',
    '1/4',
    '2/4',
    '3/4',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: breedte,
      constraints: BoxConstraints(maxHeight: maxHoogte),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rand),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.move,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: onVerslepen,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  border: Border(
                    bottom: BorderSide(color: ThimacoKleuren.rand),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.drag_indicator,
                      size: 18,
                      color: _tekstGrijs,
                    ),
                    const SizedBox(width: 7),
                    const Icon(
                      Icons.view_column_outlined,
                      size: 18,
                      color: ThimacoKleuren.antraciet,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'T-stijl',
                            style: TextStyle(
                              color: ThimacoKleuren.antraciet,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            width: 28,
                            height: 1.5,
                            decoration: BoxDecoration(
                              color: ThimacoKleuren.oranje.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ThimacoIcoonActie(
                      icoon: Icons.close_rounded,
                      tooltip: 'T-stijlmenu sluiten',
                      onPressed: onSluiten,
                      grootte: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 2,
                      children: _positieKeuzes.map((waarde) {
                        return ThimacoTekstKeuze(
                          tekst: waarde,
                          geselecteerd: positieType == waarde,
                          onPressed: () {
                            onPositieTypeGewijzigd(waarde);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: positieController,
                      enabled: positieType == 'mm',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.center,
                      onChanged: onMaatGewijzigd,
                      decoration: const InputDecoration(
                        labelText: 'Maat in mm',
                        isDense: true,
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: _groen, width: 1.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Kaderlijn: meten vanaf buitenlijn. '
                      'T-stijl of vleugellijn: 0 mm = begin van de geselecteerde lijn.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: _tekstGrijs),
                    ),
                    if (toonToevoegKnop) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ThimacoTekstActie(
                          tekst: 'T-stijl toevoegen',
                          onPressed: onToevoegen,
                        ),
                      ),
                    ],
                    if (toonVerplaatsKnop) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ThimacoTekstActie(
                          tekst: 'T-stijl verplaatsen',
                          onPressed: onVerplaatsen,
                        ),
                      ),
                    ],
                    if (toonWisKnop) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ThimacoTekstActie(
                          tekst: 'T-stijl wissen',
                          onPressed: onWissen,
                          destructief: true,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpmetingRaamVleugelKeuzeTegel extends StatelessWidget {
  const _OpmetingRaamVleugelKeuzeTegel({
    required this.type,
    required this.geselecteerd,
    required this.onTap,
  });

  final OpmetingRaamVleugelType type;
  final bool geselecteerd;
  final VoidCallback onTap;

  bool get _isDubbel {
    return type.isDubbel;
  }

  @override
  Widget build(BuildContext context) {
    const tekstKleur = ThimacoKleuren.antraciet;

    return ThimacoSelectieTegel(
      geselecteerd: geselecteerd,
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 3),
      radius: 7,
      toonVinkje: true,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 3, right: 3, top: 1),
              child: _isDubbel
                  ? CustomPaint(
                      painter: OpmetingRaamVleugelVoorbeeldPainter(type: type),
                      child: const SizedBox.expand(),
                    )
                  : Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: CustomPaint(
                          painter: OpmetingRaamVleugelVoorbeeldPainter(
                            type: type,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 23,
            child: Center(
              child: Text(
                type.naam,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: tekstKleur,
                  fontSize: 8.5,
                  height: 1,
                  fontWeight: geselecteerd
                      ? FontWeight.w900
                      : FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OpmetingRaamVleugelVoorbeeldPainter extends CustomPainter {
  const OpmetingRaamVleugelVoorbeeldPainter({required this.type});

  final OpmetingRaamVleugelType type;

  @override
  void paint(Canvas canvas, Size size) {
    final voorbeeldVlak = Rect.fromLTRB(3, 2, size.width - 3, size.height - 2);

    if (voorbeeldVlak.width <= 0 || voorbeeldVlak.height <= 0) {
      return;
    }

    final achtergrond = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRect(voorbeeldVlak, achtergrond);

    if (type == OpmetingRaamVleugelType.geenVleugel) {
      _tekenGeenVleugel(canvas: canvas, vlak: voorbeeldVlak);

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

  void _tekenGeenVleugel({required Canvas canvas, required Rect vlak}) {
    final kaderLijn = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final wisLijn = Paint()
      ..color = const Color(0xFF9CA3AF)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    canvas.drawRect(vlak, kaderLijn);

    canvas.drawLine(vlak.topLeft, vlak.bottomRight, wisLijn);

    canvas.drawLine(vlak.topRight, vlak.bottomLeft, wisLijn);
  }

  @override
  bool shouldRepaint(
    covariant OpmetingRaamVleugelVoorbeeldPainter oldDelegate,
  ) {
    return oldDelegate.type != type;
  }
}
