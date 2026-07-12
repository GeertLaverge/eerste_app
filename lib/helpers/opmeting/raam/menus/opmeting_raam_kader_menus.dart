import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../kader_samenstelling/opmeting_kader_samenstelling_model.dart';

typedef OpmetingRaamKaderPositieGekozen =
    void Function({
      required OpmetingKaderZijde zijde,
      required OpmetingKaderUitlijning uitlijning,
    });

typedef OpmetingRaamKaderVrijePositieActiveren =
    void Function({
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

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  static const Size _menuGrootte = Size(300, 188);

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
                      positie: begrensdePositie + (details.delta * 2.0),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF064E3B),
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: onSluiten,
                        child: const Padding(
                          padding: EdgeInsets.all(3),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: _groen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
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
                              signed: false,
                              decimal: false,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
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
                              signed: false,
                              decimal: false,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
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
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: Text(
                            'Tik op een kader in de tekening om een ander kader actief te maken.',
                            style: TextStyle(
                              color: _tekstGrijs,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: 'Kader wissen',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: onVerwijderen,
                            child: Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _lichtGroen,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFCDEBD6),
                                ),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                size: 19,
                                color: _groen,
                              ),
                            ),
                          ),
                        ),
                      ],
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
  final OpmetingKaderUitlijning? geselecteerdeVrijeBasisUitlijning;

  final OpmetingRaamKaderPositieGekozen onPositieGekozen;
  final OpmetingRaamKaderVrijePositieActiveren onVrijePositieActiveren;
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

  static const Size _menuGrootte = Size(410, 438);

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
                      positie: begrensdePositie + (details.delta * 2.0),
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
                      InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: onSluiten,
                        child: const Padding(
                          padding: EdgeInsets.all(3),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: _groen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _bouwZijdeBalk(
                        context: context,
                        titel: 'Boven',
                        zijde: OpmetingKaderZijde.boven,
                        beginLabel: 'Links',
                        eindeLabel: 'Rechts',
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _bouwZijkantKolom(
                            context: context,
                            titel: 'Links',
                            zijde: OpmetingKaderZijde.links,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Center(child: _bouwVoorbeeldRechthoek()),
                          ),
                          const SizedBox(width: 8),
                          _bouwZijkantKolom(
                            context: context,
                            titel: 'Rechts',
                            zijde: OpmetingKaderZijde.rechts,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _bouwZijdeBalk(
                        context: context,
                        titel: 'Onder',
                        zijde: OpmetingKaderZijde.onder,
                        beginLabel: 'Links',
                        eindeLabel: 'Rechts',
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: breedteController,
                              focusNode: breedteFocusNode,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    signed: false,
                                    decimal: false,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
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
                                    signed: false,
                                    decimal: false,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
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
      showCheckmark: false,
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

  OpmetingKaderUitlijning _basisUitlijningVoorVrijVeld({
    required OpmetingKaderZijde zijde,
  }) {
    if (geselecteerdeZijde != zijde) {
      return OpmetingKaderUitlijning.begin;
    }

    if (geselecteerdeUitlijning == OpmetingKaderUitlijning.einde) {
      return OpmetingKaderUitlijning.einde;
    }

    if (geselecteerdeUitlijning == OpmetingKaderUitlijning.vrij &&
        geselecteerdeVrijeBasisUitlijning == OpmetingKaderUitlijning.einde) {
      return OpmetingKaderUitlijning.einde;
    }

    return OpmetingKaderUitlijning.begin;
  }

  String _vrijVeldLabel({
    required OpmetingKaderZijde zijde,
    required OpmetingKaderUitlijning basisUitlijning,
  }) {
    if (zijde == OpmetingKaderZijde.boven ||
        zijde == OpmetingKaderZijde.onder) {
      return basisUitlijning == OpmetingKaderUitlijning.einde
          ? 'Vanaf rechts'
          : 'Vanaf links';
    }

    return basisUitlijning == OpmetingKaderUitlijning.einde
        ? 'Vanaf onder'
        : 'Vanaf boven';
  }

  Widget _bouwVrijVeld({
    required BuildContext context,
    required OpmetingKaderZijde zijde,
  }) {
    final geselecteerd =
        geselecteerdeZijde == zijde &&
        geselecteerdeUitlijning == OpmetingKaderUitlijning.vrij;

    final basisUitlijning = _basisUitlijningVoorVrijVeld(zijde: zijde);
    final label = _vrijVeldLabel(
      zijde: zijde,
      basisUitlijning: basisUitlijning,
    );

    if (!geselecteerd) {
      return InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          onVrijePositieActiveren(
            zijde: zijde,
            basisUitlijning: basisUitlijning,
          );

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) {
              return;
            }

            FocusScope.of(context).requestFocus(vrijeOffsetFocusNode);
          });
        },
        child: Container(
          width: 86,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _rand),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _tekstDonker,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: 98,
      child: TextField(
        controller: vrijeOffsetController,
        focusNode: vrijeOffsetFocusNode,
        keyboardType: const TextInputType.numberWithOptions(
          signed: false,
          decimal: false,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: label,
          suffixText: 'mm',
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 9,
          ),
        ),
        onTap: () {
          if (geselecteerdeZijde != zijde ||
              geselecteerdeUitlijning != OpmetingKaderUitlijning.vrij ||
              geselecteerdeVrijeBasisUitlijning != basisUitlijning) {
            onVrijePositieActiveren(
              zijde: zijde,
              basisUitlijning: basisUitlijning,
            );
          }
        },
        onChanged: (_) {
          if (geselecteerdeZijde != zijde ||
              geselecteerdeUitlijning != OpmetingKaderUitlijning.vrij ||
              geselecteerdeVrijeBasisUitlijning != basisUitlijning) {
            onVrijePositieActiveren(
              zijde: zijde,
              basisUitlijning: basisUitlijning,
            );
            return;
          }

          onKaderWijziging();
        },
        onSubmitted: (_) {
          onKaderWijziging();
        },
      ),
    );
  }

  Widget _bouwZijdeBalk({
    required BuildContext context,
    required String titel,
    required OpmetingKaderZijde zijde,
    required String beginLabel,
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
              _bouwVrijVeld(context: context, zijde: zijde),
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
    required BuildContext context,
    required String titel,
    required OpmetingKaderZijde zijde,
  }) {
    return SizedBox(
      width: 122,
      child: _bouwZijdeBalk(
        context: context,
        titel: titel,
        zijde: zijde,
        beginLabel: 'Boven',
        eindeLabel: 'Onder',
      ),
    );
  }

  Widget _bouwVoorbeeldRechthoek() {
    return Container(
      width: 96,
      height: 100,
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
