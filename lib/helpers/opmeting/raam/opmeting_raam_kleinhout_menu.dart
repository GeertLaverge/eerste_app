import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'opmeting_raam_kleinhout_model.dart';

class OpmetingRaamKleinhoutMenu extends StatefulWidget {
  const OpmetingRaamKleinhoutMenu({
    super.key,
    required this.geselecteerdType,
    required this.geselecteerdPatroon,
    required this.horizontaleHoogteController,
    required this.aantalHorizontaalController,
    required this.aantalVerticaalController,
    required this.aantalGeselecteerdeVlakken,
    required this.totaalAantalGevuldeVlakken,
    required this.selectieKanKleinhoutenKrijgen,
    required this.selectieHeeftKleinhouten,
    required this.onTypeGewijzigd,
    required this.onPatroonGewijzigd,
    required this.onWaardeGewijzigd,
    required this.onToepassen,
    required this.onVerwijderen,
    required this.onAlleGevuldeVlakkenSelecteren,
    required this.onSelectieWissen,
  });

  final OpmetingRaamKleinhoutType geselecteerdType;
  final OpmetingRaamKleinhoutPatroon geselecteerdPatroon;

  final TextEditingController horizontaleHoogteController;
  final TextEditingController aantalHorizontaalController;
  final TextEditingController aantalVerticaalController;

  final int aantalGeselecteerdeVlakken;
  final int totaalAantalGevuldeVlakken;

  final bool selectieKanKleinhoutenKrijgen;
  final bool selectieHeeftKleinhouten;

  final ValueChanged<OpmetingRaamKleinhoutType> onTypeGewijzigd;

  final ValueChanged<OpmetingRaamKleinhoutPatroon> onPatroonGewijzigd;

  final VoidCallback onWaardeGewijzigd;
  final VoidCallback onToepassen;
  final VoidCallback onVerwijderen;
  final VoidCallback onAlleGevuldeVlakkenSelecteren;
  final VoidCallback onSelectieWissen;

  @override
  State<OpmetingRaamKleinhoutMenu> createState() {
    return _OpmetingRaamKleinhoutMenuState();
  }
}

class _OpmetingRaamKleinhoutMenuState extends State<OpmetingRaamKleinhoutMenu> {
  static const Color groen = Color(0xFF0B7A3B);
  static const Color lichtGroen = Color(0xFFE7F6EC);
  static const Color rand = Color(0xFFD1D5DB);
  static const Color lichteRand = Color(0xFFE5E7EB);
  static const Color tekstGrijs = Color(0xFF6B7280);

  bool _typeOpen = false;
  bool _verdelingOpen = false;
  bool _instellingenOpen = false;

  bool get _heeftSelectie {
    return widget.aantalGeselecteerdeVlakken > 0;
  }

  bool get _kanToepassen {
    return _heeftSelectie && widget.selectieKanKleinhoutenKrijgen;
  }

  bool get _isBovenverdeling {
    return widget.geselecteerdPatroon ==
        OpmetingRaamKleinhoutPatroon.bovenverdeling;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: rand),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _bouwCompacteStatus(),
          const SizedBox(height: 6),
          _bouwUitklapSectie(
            titel: 'Type kleinhout',
            samenvatting: widget.geselecteerdType.korteNaam,
            isOpen: _typeOpen,
            onTap: () {
              setState(() {
                _typeOpen = !_typeOpen;
              });
            },
            inhoud: _bouwTypeKeuzes(),
          ),
          const SizedBox(height: 6),
          _bouwUitklapSectie(
            titel: 'Verdeling',
            samenvatting: widget.geselecteerdPatroon.korteNaam,
            isOpen: _verdelingOpen,
            onTap: () {
              setState(() {
                _verdelingOpen = !_verdelingOpen;
              });
            },
            inhoud: _bouwVerdelingKeuzes(),
          ),
          const SizedBox(height: 6),
          _bouwUitklapSectie(
            titel: 'Instellingen',
            samenvatting: _instellingenSamenvatting(),
            isOpen: _instellingenOpen,
            onTap: () {
              setState(() {
                _instellingenOpen = !_instellingenOpen;
              });
            },
            inhoud: _bouwInstellingen(),
          ),
          const SizedBox(height: 7),
          _bouwSelectieActies(),
          const SizedBox(height: 7),
          _bouwHoofdActies(),
        ],
      ),
    );
  }

  Widget _bouwCompacteStatus() {
    final Color kleur;
    final Color achtergrond;
    final IconData icoon;
    final String tekst;

    if (widget.totaalAantalGevuldeVlakken == 0) {
      kleur = const Color(0xFFB45309);
      achtergrond = const Color(0xFFFFF7ED);
      icoon = Icons.info_outline;
      tekst = 'Voeg eerst een opvulling toe.';
    } else if (!_heeftSelectie) {
      kleur = const Color(0xFFB45309);
      achtergrond = const Color(0xFFFFF7ED);
      icoon = Icons.touch_app_outlined;
      tekst = 'Selecteer een gevuld glasvlak.';
    } else if (!widget.selectieKanKleinhoutenKrijgen) {
      kleur = const Color(0xFFB45309);
      achtergrond = const Color(0xFFFFF7ED);
      icoon = Icons.warning_amber_outlined;
      tekst = 'Selectie bevat een leeg glasvlak.';
    } else {
      kleur = groen;
      achtergrond = lichtGroen;
      icoon = Icons.check_circle_outline;

      tekst = widget.aantalGeselecteerdeVlakken == 1
          ? '1 glasvlak geselecteerd'
          : '${widget.aantalGeselecteerdeVlakken} glasvlakken geselecteerd';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: achtergrond,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: kleur.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icoon, size: 16, color: kleur),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              tekst,
              style: TextStyle(
                color: kleur,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Text(
            '25 mm',
            style: TextStyle(
              color: tekstGrijs,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwUitklapSectie({
    required String titel,
    required String samenvatting,
    required bool isOpen,
    required VoidCallback onTap,
    required Widget inhoud,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOpen ? groen : lichteRand,
          width: isOpen ? 1.3 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(7),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        titel,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        samenvatting,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: groen,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      isOpen
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 18,
                      color: groen,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isOpen) ...[
            const Divider(height: 1, color: lichteRand),
            Padding(padding: const EdgeInsets.all(7), child: inhoud),
          ],
        ],
      ),
    );
  }

  Widget _bouwTypeKeuzes() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: OpmetingRaamKleinhoutType.values.map((type) {
        return _compacteKeuze(
          geselecteerd: type == widget.geselecteerdType,
          tekst: type.naam,
          onTap: () {
            widget.onTypeGewijzigd(type);

            setState(() {
              _typeOpen = false;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _bouwVerdelingKeuzes() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _compacteKeuze(
          geselecteerd:
              widget.geselecteerdPatroon ==
              OpmetingRaamKleinhoutPatroon.bovenverdeling,
          tekst: 'Bovenverdeling',
          ondertekst: '1 horizontaal, verticale kleinhouten erboven',
          onTap: () {
            widget.onPatroonGewijzigd(
              OpmetingRaamKleinhoutPatroon.bovenverdeling,
            );

            setState(() {
              _verdelingOpen = false;
            });
          },
        ),
        _compacteKeuze(
          geselecteerd:
              widget.geselecteerdPatroon ==
              OpmetingRaamKleinhoutPatroon.volledigRaster,
          tekst: 'Volledig raster',
          ondertekst: 'Horizontaal en verticaal gelijk verdeeld',
          onTap: () {
            widget.onPatroonGewijzigd(
              OpmetingRaamKleinhoutPatroon.volledigRaster,
            );

            setState(() {
              _verdelingOpen = false;
            });
          },
        ),
      ],
    );
  }

  Widget _compacteKeuze({
    required bool geselecteerd,
    required String tekst,
    required VoidCallback onTap,
    String? ondertekst,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: BoxDecoration(
              color: geselecteerd ? lichtGroen : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: geselecteerd ? groen : lichteRand),
            ),
            child: Row(
              children: [
                Icon(
                  geselecteerd
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 16,
                  color: geselecteerd ? groen : tekstGrijs,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tekst,
                        style: TextStyle(
                          color: geselecteerd ? groen : const Color(0xFF111827),
                          fontSize: 10.5,
                          fontWeight: geselecteerd
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                      if (ondertekst != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          ondertekst,
                          style: const TextStyle(
                            color: tekstGrijs,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _instellingenSamenvatting() {
    if (_isBovenverdeling) {
      final hoogte = widget.horizontaleHoogteController.text.trim();

      final verticaal = widget.aantalVerticaalController.text.trim();

      return '${hoogte.isEmpty ? '-' : hoogte} mm · '
          'vert ${verticaal.isEmpty ? '0' : verticaal}';
    }

    final horizontaal = widget.aantalHorizontaalController.text.trim();

    final verticaal = widget.aantalVerticaalController.text.trim();

    return 'hor ${horizontaal.isEmpty ? '0' : horizontaal} · '
        'vert ${verticaal.isEmpty ? '0' : verticaal}';
  }

  Widget _bouwInstellingen() {
    if (_isBovenverdeling) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _kommaGetalVeld(
            controller: widget.horizontaleHoogteController,
            label: 'Hoogte horizontaal',
            suffix: 'mm',
          ),
          const SizedBox(height: 7),
          _geheelGetalVeld(
            controller: widget.aantalVerticaalController,
            label: 'Aantal verticaal erboven',
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _geheelGetalVeld(
            controller: widget.aantalHorizontaalController,
            label: 'Horizontaal',
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _geheelGetalVeld(
            controller: widget.aantalVerticaalController,
            label: 'Verticaal',
          ),
        ),
      ],
    );
  }

  Widget _kommaGetalVeld({
    required TextEditingController controller,
    required String label,
    required String suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
      onChanged: (_) {
        widget.onWaardeGewijzigd();
        setState(() {});
      },
      style: const TextStyle(fontSize: 11),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _geheelGetalVeld({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (_) {
        widget.onWaardeGewijzigd();
        setState(() {});
      },
      style: const TextStyle(fontSize: 11),
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _bouwSelectieActies() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: widget.totaalAantalGevuldeVlakken > 0
                ? widget.onAlleGevuldeVlakkenSelecteren
                : null,
            icon: const Icon(Icons.select_all, size: 15),
            label: const Text('Alles'),
            style: OutlinedButton.styleFrom(
              foregroundColor: groen,
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
              textStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _heeftSelectie ? widget.onSelectieWissen : null,
            icon: const Icon(Icons.deselect, size: 15),
            label: const Text('Deselecteer'),
            style: OutlinedButton.styleFrom(
              foregroundColor: tekstGrijs,
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
              textStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bouwHoofdActies() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _kanToepassen ? widget.onToepassen : null,
            icon: Icon(
              widget.selectieHeeftKleinhouten ? Icons.edit_outlined : Icons.add,
              size: 17,
            ),
            label: Text(
              widget.selectieHeeftKleinhouten
                  ? 'Kleinhouten aanpassen'
                  : 'Kleinhouten toepassen',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: groen,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFD1D5DB),
              disabledForegroundColor: const Color(0xFF9CA3AF),
              padding: const EdgeInsets.symmetric(vertical: 9),
              textStyle: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        if (widget.selectieHeeftKleinhouten) ...[
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.onVerwijderen,
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('Kleinhouten wissen'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFDC2626)),
                padding: const EdgeInsets.symmetric(vertical: 8),
                textStyle: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
