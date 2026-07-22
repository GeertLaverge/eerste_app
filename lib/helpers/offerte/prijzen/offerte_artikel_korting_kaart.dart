import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef OfferteArtikelPercentageGewijzigd =
    void Function(double percentage, bool toepassenOpAlleArtikelen);

typedef OfferteArtikelToepassenOpGeopend = void Function(double percentage);

class OfferteArtikelKortingKaart extends StatefulWidget {
  const OfferteArtikelKortingKaart({
    super.key,
    required this.beginWinstmargePercentage,
    required this.beginKortingPercentage,
    required this.winstmargeBasisExclBtw,
    required this.winstmargeBedragExclBtw,
    required this.kortingBasisExclBtw,
    required this.kortingBedragExclBtw,
    required this.onWinstmargeGewijzigd,
    required this.onKortingGewijzigd,
    this.winstmargeToepassenOpSamenvatting,
    this.kortingToepassenOpSamenvatting,
    this.onWinstmargeToepassenOpOpenen,
    this.onKortingToepassenOpOpenen,
    this.winstmargeVoorAlleArtikelen = false,
    this.kortingVoorAlleArtikelen = false,
    this.kortingToestaan = true,
  });

  final double beginWinstmargePercentage;
  final double beginKortingPercentage;
  final double winstmargeBasisExclBtw;
  final double winstmargeBedragExclBtw;
  final double kortingBasisExclBtw;
  final double kortingBedragExclBtw;
  final OfferteArtikelPercentageGewijzigd onWinstmargeGewijzigd;
  final OfferteArtikelPercentageGewijzigd onKortingGewijzigd;
  final String? winstmargeToepassenOpSamenvatting;
  final String? kortingToepassenOpSamenvatting;
  final OfferteArtikelToepassenOpGeopend? onWinstmargeToepassenOpOpenen;
  final OfferteArtikelToepassenOpGeopend? onKortingToepassenOpOpenen;
  final bool winstmargeVoorAlleArtikelen;
  final bool kortingVoorAlleArtikelen;
  final bool kortingToestaan;

  @override
  State<OfferteArtikelKortingKaart> createState() {
    return _OfferteArtikelKortingKaartState();
  }
}

class _OfferteArtikelKortingKaartState
    extends State<OfferteArtikelKortingKaart> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  late final TextEditingController _winstmargeController;
  late final TextEditingController _kortingController;
  late final FocusNode _winstmargeFocusNode;
  late final FocusNode _kortingFocusNode;

  bool _winstmargeVoorAlleArtikelen = false;
  bool _kortingVoorAlleArtikelen = false;

  @override
  void initState() {
    super.initState();
    _winstmargeController = TextEditingController(
      text: _percentageTekst(widget.beginWinstmargePercentage),
    );
    _kortingController = TextEditingController(
      text: _percentageTekst(widget.beginKortingPercentage),
    );
    _winstmargeFocusNode = FocusNode()
      ..addListener(_verwerkWinstmargeFocusWijziging);
    _kortingFocusNode = FocusNode()..addListener(_verwerkKortingFocusWijziging);
    _winstmargeVoorAlleArtikelen = widget.winstmargeVoorAlleArtikelen;
    _kortingVoorAlleArtikelen =
        widget.kortingVoorAlleArtikelen && widget.kortingToestaan;
  }

  @override
  void didUpdateWidget(covariant OfferteArtikelKortingKaart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_winstmargeFocusNode.hasFocus &&
        oldWidget.beginWinstmargePercentage !=
            widget.beginWinstmargePercentage) {
      _zetControllerTekst(
        _winstmargeController,
        _percentageTekst(widget.beginWinstmargePercentage),
      );
    }

    if (!_kortingFocusNode.hasFocus &&
        oldWidget.beginKortingPercentage != widget.beginKortingPercentage) {
      _zetControllerTekst(
        _kortingController,
        _percentageTekst(widget.beginKortingPercentage),
      );
    }

    if (oldWidget.winstmargeVoorAlleArtikelen !=
        widget.winstmargeVoorAlleArtikelen) {
      _winstmargeVoorAlleArtikelen = widget.winstmargeVoorAlleArtikelen;
    }

    if (oldWidget.kortingVoorAlleArtikelen != widget.kortingVoorAlleArtikelen ||
        oldWidget.kortingToestaan != widget.kortingToestaan) {
      _kortingVoorAlleArtikelen =
          widget.kortingVoorAlleArtikelen && widget.kortingToestaan;
    }
  }

  @override
  void dispose() {
    _winstmargeFocusNode
      ..removeListener(_verwerkWinstmargeFocusWijziging)
      ..dispose();
    _kortingFocusNode
      ..removeListener(_verwerkKortingFocusWijziging)
      ..dispose();
    _winstmargeController.dispose();
    _kortingController.dispose();
    super.dispose();
  }

  String _percentageTekst(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) {
      return '';
    }

    var tekst = waarde.toStringAsFixed(2).replaceAll('.', ',');
    tekst = tekst.replaceFirst(RegExp(r'0+$'), '');
    tekst = tekst.replaceFirst(RegExp(r',$'), '');
    return tekst;
  }

  double _leesPercentage(String tekst, {required double maximum}) {
    final gelezen = double.tryParse(tekst.trim().replaceAll(',', '.')) ?? 0.0;
    if (!gelezen.isFinite || gelezen <= 0.0) {
      return 0.0;
    }
    return gelezen.clamp(0.0, maximum).toDouble();
  }

  void _zetControllerTekst(TextEditingController controller, String tekst) {
    controller.value = TextEditingValue(
      text: tekst,
      selection: TextSelection.collapsed(offset: tekst.length),
    );
  }

  void _verwerkWinstmargeFocusWijziging() {
    if (_winstmargeFocusNode.hasFocus) {
      return;
    }

    final percentage = _leesPercentage(
      _winstmargeController.text,
      maximum: 500.0,
    );
    _zetControllerTekst(_winstmargeController, _percentageTekst(percentage));
  }

  void _verwerkKortingFocusWijziging() {
    if (_kortingFocusNode.hasFocus) {
      return;
    }

    final percentage = _leesPercentage(_kortingController.text, maximum: 100.0);
    _zetControllerTekst(_kortingController, _percentageTekst(percentage));
  }

  String _bedrag(double waarde) {
    return waarde.toStringAsFixed(2).replaceAll('.', ',');
  }

  TextInputFormatter _percentageFormatter(double maximum) {
    return TextInputFormatter.withFunction((oudeWaarde, nieuweWaarde) {
      final geldig = RegExp(r'^\d{0,3}([,.]\d{0,2})?$');
      if (!geldig.hasMatch(nieuweWaarde.text)) {
        return oudeWaarde;
      }

      final rauw = double.tryParse(
        nieuweWaarde.text.trim().replaceAll(',', '.'),
      );
      if (rauw != null && rauw > maximum) {
        return oudeWaarde;
      }
      return nieuweWaarde;
    });
  }

  Widget _bouwPercentagePaneel({
    required String titel,
    required String veldLabel,
    required TextEditingController controller,
    required FocusNode focusNode,
    required double maximum,
    required double basisExclBtw,
    required double bedragExclBtw,
    required bool toepassenOpAlle,
    required ValueChanged<bool> onAlleGewijzigd,
    String? toepassenOpSamenvatting,
    OfferteArtikelToepassenOpGeopend? onToepassenOpOpenen,
    required ValueChanged<String> onTekstGewijzigd,
    required VoidCallback onInvoerBevestigd,
    required bool isKorting,
  }) {
    final heeftBedrag = bedragExclBtw > 0.0;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  titel,
                  style: const TextStyle(
                    color: _groen,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (onToepassenOpOpenen != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        final percentage = _leesPercentage(
                          controller.text,
                          maximum: maximum,
                        );
                        focusNode.unfocus();
                        onToepassenOpOpenen(percentage);
                      },
                      icon: const Icon(
                        Icons.library_add_check_rounded,
                        size: 16,
                      ),
                      label: const Text('Toepassen op…'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _groen,
                        side: const BorderSide(color: _rand),
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 7,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: Text(
                        toepassenOpSamenvatting ?? 'Huidig artikel',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: _tekstGrijs,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                )
              else ...[
                Checkbox(
                  value: toepassenOpAlle,
                  onChanged: (waarde) {
                    onAlleGewijzigd(waarde ?? false);
                  },
                  activeColor: _groen,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const Text(
                  'Alle artikelen',
                  style: TextStyle(
                    color: _tekstGrijs,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              SizedBox(
                width: 112,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: <TextInputFormatter>[
                    _percentageFormatter(maximum),
                  ],
                  decoration: InputDecoration(
                    labelText: veldLabel,
                    hintText: '0',
                    suffixText: '%',
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.fromLTRB(11, 12, 11, 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(color: _rand),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(color: _groen, width: 1.5),
                    ),
                  ),
                  onChanged: onTekstGewijzigd,
                  onSubmitted: (_) {
                    onInvoerBevestigd();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      heeftBedrag
                          ? '${isKorting ? '- ' : '+ '}€ ${_bedrag(bedragExclBtw)}'
                          : isKorting
                          ? 'Geen korting'
                          : 'Geen winstmarge',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: heeftBedrag ? _groen : _tekstGrijs,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Basis: € ${_bedrag(basisExclBtw)} excl. btw',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: _tekstDonker,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Prijs per stuk - Winstmarge en korting enkel gerekend op stukprijs',
            style: TextStyle(
              color: _groen,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final winstmargePaneel = _bouwPercentagePaneel(
                titel: 'Winstmarge',
                veldLabel: 'Winst',
                controller: _winstmargeController,
                focusNode: _winstmargeFocusNode,
                maximum: 500.0,
                basisExclBtw: widget.winstmargeBasisExclBtw,
                bedragExclBtw: widget.winstmargeBedragExclBtw,
                toepassenOpAlle: _winstmargeVoorAlleArtikelen,
                onAlleGewijzigd: (waarde) {
                  setState(() {
                    _winstmargeVoorAlleArtikelen = waarde;
                  });
                  widget.onWinstmargeGewijzigd(
                    _leesPercentage(_winstmargeController.text, maximum: 500.0),
                    waarde,
                  );
                },
                toepassenOpSamenvatting:
                    widget.winstmargeToepassenOpSamenvatting,
                onToepassenOpOpenen: widget.onWinstmargeToepassenOpOpenen,
                onTekstGewijzigd: (tekst) {
                  widget.onWinstmargeGewijzigd(
                    _leesPercentage(tekst, maximum: 500.0),
                    _winstmargeVoorAlleArtikelen,
                  );
                },
                onInvoerBevestigd: _verwerkWinstmargeFocusWijziging,
                isKorting: false,
              );

              final kortingPaneel = widget.kortingToestaan
                  ? _bouwPercentagePaneel(
                      titel: 'Korting',
                      veldLabel: 'Korting',
                      controller: _kortingController,
                      focusNode: _kortingFocusNode,
                      maximum: 100.0,
                      basisExclBtw: widget.kortingBasisExclBtw,
                      bedragExclBtw: widget.kortingBedragExclBtw,
                      toepassenOpAlle: _kortingVoorAlleArtikelen,
                      onAlleGewijzigd: (waarde) {
                        setState(() {
                          _kortingVoorAlleArtikelen = waarde;
                        });
                        widget.onKortingGewijzigd(
                          _leesPercentage(
                            _kortingController.text,
                            maximum: 100.0,
                          ),
                          waarde,
                        );
                      },
                      toepassenOpSamenvatting:
                          widget.kortingToepassenOpSamenvatting,
                      onToepassenOpOpenen: widget.onKortingToepassenOpOpenen,
                      onTekstGewijzigd: (tekst) {
                        widget.onKortingGewijzigd(
                          _leesPercentage(tekst, maximum: 100.0),
                          _kortingVoorAlleArtikelen,
                        );
                      },
                      onInvoerBevestigd: _verwerkKortingFocusWijziging,
                      isKorting: true,
                    )
                  : Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFED7AA)),
                      ),
                      child: const Text(
                        'Geen korting toegestaan voor een optiepositie.',
                        style: TextStyle(
                          color: Color(0xFFEA580C),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );

              if (constraints.maxWidth < 520) {
                return Column(
                  children: [
                    winstmargePaneel,
                    const SizedBox(height: 8),
                    kortingPaneel,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: winstmargePaneel),
                  const SizedBox(width: 8),
                  Expanded(child: kortingPaneel),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
