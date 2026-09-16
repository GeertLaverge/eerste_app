// THIMACO-CONTROLE: SUBMENU-SELECTIESTIJL-FASE2-KADER-API-FIX-20260914
import 'package:flutter/material.dart';

import '../../../ui/thimaco_huisstijl.dart';
import '../../kader_samenstelling/opmeting_kader_samenstelling_model.dart';

typedef OpmetingRaamKaderPositieGekozen = void Function({
  required OpmetingKaderZijde zijde,
  required OpmetingKaderUitlijning uitlijning,
});

typedef OpmetingRaamKaderVrijePositieActiveren = void Function({
  required OpmetingKaderZijde zijde,
  required OpmetingKaderUitlijning basisUitlijning,
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
    required this.onMaatGewijzigd,
    required this.onSluiten,
    required this.onVerwijderen,
  });

  final OpmetingKaderDeel actiefKader;
  final Offset positie;
  final ValueChanged<Offset> onPositieGewijzigd;

  final TextEditingController breedteController;
  final TextEditingController hoogteController;

  final FocusNode breedteFocusNode;
  final FocusNode hoogteFocusNode;

  final VoidCallback onMaatGewijzigd;
  final VoidCallback onSluiten;
  final VoidCallback onVerwijderen;

  static const Color _rand = ThimacoKleuren.rand;
  static const Color _tekstDonker = ThimacoKleuren.antraciet;
  static const Color _tekstGrijs = ThimacoKleuren.tekstGrijs;

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
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    border: Border(
                      bottom: BorderSide(color: ThimacoKleuren.rand),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.open_with_rounded,
                        size: 18,
                        color: ThimacoKleuren.antraciet,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: ThimacoSectieTitel(tekst: 'Kader wijzigen'),
                      ),
                      Flexible(
                        child: Text(
                          actiefKader.naam,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: _tekstGrijs,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      ThimacoIcoonActie(
                        icoon: Icons.close_rounded,
                        tooltip: 'Kadermenu sluiten',
                        onPressed: onSluiten,
                        grootte: 18,
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
                            onChanged: (_) {
                              onMaatGewijzigd();
                            },
                            onSubmitted: (_) {
                              onMaatGewijzigd();
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
                            onChanged: (_) {
                              onMaatGewijzigd();
                            },
                            onSubmitted: (_) {
                              onMaatGewijzigd();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Maten worden automatisch toegepast.',
                            style: TextStyle(
                              color: _tekstGrijs,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ThimacoTekstActie(
                          tekst: 'Kader wissen',
                          destructief: true,
                          onPressed: onVerwijderen,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
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
    required this.onSluiten,
    required this.geselecteerdeZijde,
    required this.geselecteerdeUitlijning,
    required this.geselecteerdeVrijeBasisUitlijning,
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
  final VoidCallback onSluiten;

  final OpmetingKaderZijde? geselecteerdeZijde;
  final OpmetingKaderUitlijning? geselecteerdeUitlijning;
  final OpmetingKaderUitlijning geselecteerdeVrijeBasisUitlijning;

  final OpmetingRaamKaderPositieGekozen onPositieGekozen;
  final OpmetingRaamKaderVrijePositieActiveren onVrijePositieActiveren;
  final VoidCallback onKaderWijziging;

  final TextEditingController breedteController;
  final TextEditingController hoogteController;
  final TextEditingController vrijeOffsetController;

  final FocusNode breedteFocusNode;
  final FocusNode hoogteFocusNode;
  final FocusNode vrijeOffsetFocusNode;

  static const Color _groen = ThimacoKleuren.oranje;
  static const Color _rand = ThimacoKleuren.rand;
  static const Color _tekstDonker = ThimacoKleuren.antraciet;
  static const Color _tekstGrijs = ThimacoKleuren.tekstGrijs;

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
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    border: Border(
                      bottom: BorderSide(color: ThimacoKleuren.rand),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.add_box_outlined,
                        size: 18,
                        color: ThimacoKleuren.antraciet,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: ThimacoSectieTitel(tekst: 'Kader toevoegen'),
                      ),
                      Flexible(
                        child: Text(
                          'tegen ${ankerKader.naam}',
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: _tekstGrijs,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      ThimacoIcoonActie(
                        icoon: Icons.close_rounded,
                        tooltip: 'Kader toevoegen sluiten',
                        onPressed: onSluiten,
                        grootte: 18,
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
                            child: Center(
                              child: _bouwVoorbeeldRechthoek(),
                            ),
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
    final geselecteerd = geselecteerdeZijde == zijde &&
        geselecteerdeUitlijning == uitlijning;

    return ThimacoTekstKeuze(
      tekst: label,
      geselecteerd: geselecteerd,
      onPressed: () {
        onPositieGekozen(zijde: zijde, uitlijning: uitlijning);
      },
    );
  }

  Widget _bouwVrijVeld({
    required OpmetingKaderZijde zijde,
    required String label,
    required String beginLabel,
    required String eindeLabel,
  }) {
    final vrijGeselecteerd = geselecteerdeZijde == zijde &&
        geselecteerdeUitlijning == OpmetingKaderUitlijning.vrij;
    final basisUitlijning =
        geselecteerdeVrijeBasisUitlijning == OpmetingKaderUitlijning.einde
            ? OpmetingKaderUitlijning.einde
            : OpmetingKaderUitlijning.begin;

    void activeerVrij(OpmetingKaderUitlijning basis) {
      onVrijePositieActiveren(zijde: zijde, basisUitlijning: basis);
    }

    return SizedBox(
      width: 124,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 2,
            runSpacing: 0,
            children: [
              ThimacoTekstKeuze(
                tekst: 'Vanaf $beginLabel',
                compact: true,
                geselecteerd: vrijGeselecteerd &&
                    basisUitlijning == OpmetingKaderUitlijning.begin,
                onPressed: () => activeerVrij(OpmetingKaderUitlijning.begin),
              ),
              ThimacoTekstKeuze(
                tekst: 'Vanaf $eindeLabel',
                compact: true,
                geselecteerd: vrijGeselecteerd &&
                    basisUitlijning == OpmetingKaderUitlijning.einde,
                onPressed: () => activeerVrij(OpmetingKaderUitlijning.einde),
              ),
            ],
          ),
          const SizedBox(height: 3),
          TextField(
            controller: vrijeOffsetController,
            focusNode: vrijeOffsetFocusNode,
            keyboardType: const TextInputType.numberWithOptions(
              signed: true,
              decimal: true,
            ),
            decoration: InputDecoration(
              labelText: label,
              suffixText: 'mm',
              border: const OutlineInputBorder(),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: _groen, width: 1.5),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 9,
              ),
            ),
            onTap: () {
              activeerVrij(basisUitlijning);
            },
            onChanged: (_) {
              if (vrijGeselecteerd) {
                onKaderWijziging();
              }
            },
            onSubmitted: (_) {
              activeerVrij(basisUitlijning);
            },
          ),
        ],
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
        color: Colors.white,
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
              color: _tekstDonker,
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
              _bouwVrijVeld(
                zijde: zijde,
                label: vrijLabel,
                beginLabel: beginLabel,
                eindeLabel: eindeLabel,
              ),
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
