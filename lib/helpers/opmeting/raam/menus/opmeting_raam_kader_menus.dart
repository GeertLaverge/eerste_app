import 'package:flutter/material.dart';

import '../../kader_samenstelling/opmeting_kader_samenstelling_model.dart';

typedef OpmetingRaamKaderPositieGekozen =
    void Function({
      required OpmetingKaderZijde zijde,
      required OpmetingKaderUitlijning uitlijning,
    });

class OpmetingRaamKaderWijzigMenuOverlay extends StatelessWidget {
  const OpmetingRaamKaderWijzigMenuOverlay({
    super.key,
    required this.actiefKader,
    required this.positie,
    required this.onPositieGewijzigd,
    required this.breedteController,
    required this.hoogteController,
    required this.breedteFocusNode,
    required this.hoogteFocusNode,
    required this.onBewaren,
  });

  final OpmetingKaderDeel actiefKader;
  final Offset positie;
  final ValueChanged<Offset> onPositieGewijzigd;

  final TextEditingController breedteController;
  final TextEditingController hoogteController;

  final FocusNode breedteFocusNode;
  final FocusNode hoogteFocusNode;

  final VoidCallback onBewaren;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  static const Size _menuGrootte = Size(300, 214);

  @override
  Widget build(BuildContext context) {
    final schermGrootte = MediaQuery.sizeOf(context);

    final begrensdePositie = _begrensMenuPositie(
      context: context,
      positie: positie,
      schermGrootte: schermGrootte,
      menuGrootte: _menuGrootte,
    );

    return Positioned(
      left: begrensdePositie.dx,
      top: begrensdePositie.dy,
      width: _menuGrootte.width,
      child: Material(
        color: Colors.transparent,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _rand),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) {
                  onPositieGewijzigd(
                    _begrensMenuPositie(
                      context: context,
                      positie: begrensdePositie + details.delta,
                      schermGrootte: schermGrootte,
                      menuGrootte: _menuGrootte,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 10, 9),
                  decoration: const BoxDecoration(
                    color: _lichtGroen,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.open_with_rounded,
                        size: 18,
                        color: _groen,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Kader wijzigen',
                          style: TextStyle(
                            color: Color(0xFF064E3B),
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        actiefKader.naam,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _groen,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Actief: ${actiefKader.naam}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _tekstDonker,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: breedteController,
                            focusNode: breedteFocusNode,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Breedte kader',
                              suffixText: 'mm',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onSubmitted: (_) {
                              onBewaren();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: hoogteController,
                            focusNode: hoogteFocusNode,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Hoogte kader',
                              suffixText: 'mm',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onSubmitted: (_) {
                              onBewaren();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: _groen,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(38),
                      ),
                      onPressed: onBewaren,
                      icon: const Icon(Icons.save_outlined, size: 17),
                      label: const Text('Kader bewaren'),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Tik op een kader in de tekening om een ander kader actief te maken.',
                      style: TextStyle(
                        color: _tekstGrijs,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OpmetingRaamKaderToevoegMenuOverlay extends StatelessWidget {
  const OpmetingRaamKaderToevoegMenuOverlay({
    super.key,
    required this.ankerKader,
    required this.positie,
    required this.onPositieGewijzigd,
    required this.geselecteerdeZijde,
    required this.geselecteerdeUitlijning,
    required this.onPositieGekozen,
    required this.onVrijePositieActiveren,
    required this.onKaderWijziging,
    required this.breedteController,
    required this.hoogteController,
    required this.vrijeOffsetController,
    required this.breedteFocusNode,
    required this.hoogteFocusNode,
    required this.vrijeOffsetFocusNode,
  });

  final OpmetingKaderDeel ankerKader;
  final Offset positie;
  final ValueChanged<Offset> onPositieGewijzigd;

  final OpmetingKaderZijde? geselecteerdeZijde;
  final OpmetingKaderUitlijning? geselecteerdeUitlijning;

  final OpmetingRaamKaderPositieGekozen onPositieGekozen;
  final ValueChanged<OpmetingKaderZijde> onVrijePositieActiveren;
  final VoidCallback onKaderWijziging;

  final TextEditingController breedteController;
  final TextEditingController hoogteController;
  final TextEditingController vrijeOffsetController;

  final FocusNode breedteFocusNode;
  final FocusNode hoogteFocusNode;
  final FocusNode vrijeOffsetFocusNode;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  static const Size _menuGrootte = Size(462, 560);

  @override
  Widget build(BuildContext context) {
    final schermGrootte = MediaQuery.sizeOf(context);

    final begrensdePositie = _begrensMenuPositie(
      context: context,
      positie: positie,
      schermGrootte: schermGrootte,
      menuGrootte: _menuGrootte,
    );

    return Positioned(
      left: begrensdePositie.dx,
      top: begrensdePositie.dy,
      width: _menuGrootte.width,
      child: Material(
        color: Colors.transparent,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _rand),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) {
                  onPositieGewijzigd(
                    _begrensMenuPositie(
                      context: context,
                      positie: begrensdePositie + details.delta,
                      schermGrootte: schermGrootte,
                      menuGrootte: _menuGrootte,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 10, 9),
                  decoration: const BoxDecoration(
                    color: _lichtGroen,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.add_box_outlined,
                        size: 18,
                        color: _groen,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Kader toevoegen',
                          style: TextStyle(
                            color: Color(0xFF064E3B),
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        'tegen ${ankerKader.naam}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _groen,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Klik eerst op een positie. Het nieuwe kader wordt meteen getekend en past zich aan bij elke wijziging.',
                        style: TextStyle(
                          color: _tekstGrijs,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _bouwZijdeBalk(
                        titel: 'Boven',
                        zijde: OpmetingKaderZijde.boven,
                        beginLabel: 'Links',
                        vrijLabel: 'Vanaf links',
                        eindeLabel: 'Rechts',
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _bouwZijkantKolom(
                            titel: 'Links',
                            zijde: OpmetingKaderZijde.links,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Center(child: _bouwVoorbeeldRechthoek()),
                          ),
                          const SizedBox(width: 8),
                          _bouwZijkantKolom(
                            titel: 'Rechts',
                            zijde: OpmetingKaderZijde.rechts,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _bouwZijdeBalk(
                        titel: 'Onder',
                        zijde: OpmetingKaderZijde.onder,
                        beginLabel: 'Links',
                        vrijLabel: 'Vanaf links',
                        eindeLabel: 'Rechts',
                      ),
                      const SizedBox(height: 11),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: breedteController,
                              focusNode: breedteFocusNode,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Breedte nieuw kader',
                                suffixText: 'mm',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (_) {
                                onKaderWijziging();
                              },
                              onSubmitted: (_) {
                                onKaderWijziging();
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: hoogteController,
                              focusNode: hoogteFocusNode,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Hoogte nieuw kader',
                                suffixText: 'mm',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (_) {
                                onKaderWijziging();
                              },
                              onSubmitted: (_) {
                                onKaderWijziging();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bouwPositieKnop({
    required OpmetingKaderZijde zijde,
    required OpmetingKaderUitlijning uitlijning,
    required String label,
  }) {
    final geselecteerd =
        geselecteerdeZijde == zijde && geselecteerdeUitlijning == uitlijning;

    return FilterChip(
      label: Text(label),
      selected: geselecteerd,
      showCheckmark: true,
      selectedColor: _lichtGroen,
      side: BorderSide(color: geselecteerd ? _groen : _rand),
      labelStyle: TextStyle(
        color: geselecteerd ? _groen : _tekstDonker,
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
      onSelected: (_) {
        onPositieGekozen(zijde: zijde, uitlijning: uitlijning);
      },
    );
  }

  Widget _bouwVrijVeld({
    required OpmetingKaderZijde zijde,
    required String label,
  }) {
    final geselecteerd =
        geselecteerdeZijde == zijde &&
        geselecteerdeUitlijning == OpmetingKaderUitlijning.vrij;

    return SizedBox(
      width: 118,
      child: TextField(
        controller: vrijeOffsetController,
        focusNode: vrijeOffsetFocusNode,
        keyboardType: const TextInputType.numberWithOptions(
          signed: true,
          decimal: true,
        ),
        decoration: InputDecoration(
          labelText: label,
          suffixText: 'mm',
          prefixIcon: Icon(
            geselecteerd ? Icons.check_box : Icons.check_box_outline_blank,
            size: 17,
            color: geselecteerd ? _groen : _tekstGrijs,
          ),
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 9,
          ),
        ),
        onTap: () {
          onVrijePositieActiveren(zijde);
        },
        onChanged: (_) {
          if (geselecteerdeZijde == zijde &&
              geselecteerdeUitlijning == OpmetingKaderUitlijning.vrij) {
            onKaderWijziging();
          }
        },
        onSubmitted: (_) {
          onVrijePositieActiveren(zijde);
        },
      ),
    );
  }

  Widget _bouwZijdeBalk({
    required String titel,
    required OpmetingKaderZijde zijde,
    required String beginLabel,
    required String vrijLabel,
    required String eindeLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            titel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF064E3B),
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              _bouwPositieKnop(
                zijde: zijde,
                uitlijning: OpmetingKaderUitlijning.begin,
                label: beginLabel,
              ),
              _bouwVrijVeld(zijde: zijde, label: vrijLabel),
              _bouwPositieKnop(
                zijde: zijde,
                uitlijning: OpmetingKaderUitlijning.einde,
                label: eindeLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bouwZijkantKolom({
    required String titel,
    required OpmetingKaderZijde zijde,
  }) {
    return SizedBox(
      width: 132,
      child: _bouwZijdeBalk(
        titel: titel,
        zijde: zijde,
        beginLabel: 'Boven',
        vrijLabel: 'Vanaf boven',
        eindeLabel: 'Onder',
      ),
    );
  }

  Widget _bouwVoorbeeldRechthoek() {
    return Container(
      width: 120,
      height: 118,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _tekstDonker, width: 1.4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.crop_square_rounded, color: _groen),
          const SizedBox(height: 5),
          Text(
            ankerKader.naam,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _tekstDonker,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Nieuw kader komt\ntegen deze zijde',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _tekstGrijs,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

Offset _begrensMenuPositie({
  required BuildContext context,
  required Offset positie,
  required Size schermGrootte,
  required Size menuGrootte,
}) {
  final padding = MediaQuery.paddingOf(context);

  final minX = padding.left + 8;
  final minY = padding.top + 8;
  final maxX = schermGrootte.width - menuGrootte.width - padding.right - 8;
  final maxY = schermGrootte.height - menuGrootte.height - padding.bottom - 8;

  return Offset(
    positie.dx.clamp(minX, maxX < minX ? minX : maxX).toDouble(),
    positie.dy.clamp(minY, maxY < minY ? minY : maxY).toDouble(),
  );
}
