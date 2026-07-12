import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'opmeting_raam_kleinhout_model.dart';

class OpmetingRaamKleinhoutMenu extends StatelessWidget {
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
    this.breedte = 300,
    this.maxHoogte,
    this.onSluiten,
    this.onVerslepen,
  });

  static const Color groen = Color(0xFF0B7A3B);
  static const Color lichtGroen = Color(0xFFE7F6EC);
  static const Color rand = Color(0xFFE5E7EB);
  static const Color tekstDonker = Color(0xFF111827);
  static const Color tekstGrijs = Color(0xFF6B7280);

  final double breedte;
  final double? maxHoogte;

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

  final VoidCallback? onSluiten;
  final ValueChanged<DragUpdateDetails>? onVerslepen;

  bool get _isBovenverdeling {
    return _enumNaam(geselecteerdPatroon) == 'bovenverdeling';
  }

  bool get _kanToepassen {
    return aantalGeselecteerdeVlakken > 0 && selectieKanKleinhoutenKrijgen;
  }

  bool get _kanVerwijderen {
    return aantalGeselecteerdeVlakken > 0 && selectieHeeftKleinhouten;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: breedte,
      constraints: BoxConstraints(maxHeight: maxHoogte ?? double.infinity),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: rand),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _kop(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Tik op één of meerdere gevulde vlakken in het raam.',
                    style: TextStyle(fontSize: 11, color: tekstGrijs),
                  ),
                  const SizedBox(height: 10),
                  _selectieBlok(),
                  const SizedBox(height: 8),
                  _selectieKnoppen(),
                  const SizedBox(height: 10),
                  _sectieTitel('Type'),
                  const SizedBox(height: 6),
                  _typeKeuzes(),
                  const SizedBox(height: 10),
                  _sectieTitel('Verdeling'),
                  const SizedBox(height: 6),
                  _patroonKeuzes(),
                  const SizedBox(height: 10),
                  _waardeVelden(),
                  const SizedBox(height: 10),
                  _actieKnoppen(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kop() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: onVerslepen,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 9),
        decoration: const BoxDecoration(
          color: lichtGroen,
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        child: Row(
          children: [
            const Icon(Icons.grid_on_rounded, size: 18, color: groen),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Kleinhout',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF064E3B),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (onSluiten != null)
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onSluiten,
                child: const Padding(
                  padding: EdgeInsets.all(3),
                  child: Icon(Icons.close_rounded, size: 18, color: groen),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _selectieBlok() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: aantalGeselecteerdeVlakken > 0
            ? const Color(0xFFE7F6EC)
            : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: aantalGeselecteerdeVlakken > 0 ? groen : rand,
        ),
      ),
      child: Row(
        children: [
          Icon(
            aantalGeselecteerdeVlakken > 0
                ? Icons.check_box_outlined
                : Icons.check_box_outline_blank,
            size: 18,
            color: aantalGeselecteerdeVlakken > 0 ? groen : tekstGrijs,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              aantalGeselecteerdeVlakken == 0
                  ? 'Nog geen vlak geselecteerd'
                  : '$aantalGeselecteerdeVlakken van '
                        '$totaalAantalGevuldeVlakken gevulde vlakken geselecteerd',
              style: TextStyle(
                fontSize: 11,
                fontWeight: aantalGeselecteerdeVlakken > 0
                    ? FontWeight.w800
                    : FontWeight.w500,
                color: aantalGeselecteerdeVlakken > 0
                    ? const Color(0xFF064E3B)
                    : tekstGrijs,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectieKnoppen() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: totaalAantalGevuldeVlakken > 0
                ? onAlleGevuldeVlakkenSelecteren
                : null,
            icon: const Icon(Icons.select_all, size: 17),
            label: const Text('Alles', style: TextStyle(fontSize: 11)),
            style: OutlinedButton.styleFrom(
              foregroundColor: groen,
              side: const BorderSide(color: groen),
              padding: const EdgeInsets.symmetric(vertical: 9),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: aantalGeselecteerdeVlakken > 0 ? onSelectieWissen : null,
            icon: const Icon(Icons.deselect, size: 17),
            label: const Text('Geen', style: TextStyle(fontSize: 11)),
            style: OutlinedButton.styleFrom(
              foregroundColor: tekstGrijs,
              padding: const EdgeInsets.symmetric(vertical: 9),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectieTitel(String tekst) {
    return Text(
      tekst,
      style: const TextStyle(
        color: tekstDonker,
        fontSize: 11,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _typeKeuzes() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: OpmetingRaamKleinhoutType.values.map((type) {
        final geselecteerd = type == geselecteerdType;

        return ChoiceChip(
          label: Text(
            _labelVoorKleinhoutType(type),
            style: TextStyle(
              fontSize: 11,
              fontWeight: geselecteerd ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
          selected: geselecteerd,
          selectedColor: lichtGroen,
          checkmarkColor: groen,
          side: BorderSide(color: geselecteerd ? groen : rand),
          onSelected: (_) {
            onTypeGewijzigd(type);
          },
        );
      }).toList(),
    );
  }

  Widget _patroonKeuzes() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: OpmetingRaamKleinhoutPatroon.values.map((patroon) {
        final geselecteerd = patroon == geselecteerdPatroon;

        return ChoiceChip(
          label: Text(
            _labelVoorPatroon(patroon),
            style: TextStyle(
              fontSize: 11,
              fontWeight: geselecteerd ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
          selected: geselecteerd,
          selectedColor: lichtGroen,
          checkmarkColor: groen,
          side: BorderSide(color: geselecteerd ? groen : rand),
          onSelected: (_) {
            onPatroonGewijzigd(patroon);
          },
        );
      }).toList(),
    );
  }

  Widget _waardeVelden() {
    if (_isBovenverdeling) {
      return Row(
        children: [
          Expanded(
            child: _getalVeld(
              controller: horizontaleHoogteController,
              label: 'Hoogte',
              suffix: 'mm',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _getalVeld(
              controller: aantalVerticaalController,
              label: 'Verticaal',
              suffix: 'st',
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _getalVeld(
            controller: aantalHorizontaalController,
            label: 'Horizontaal',
            suffix: 'st',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _getalVeld(
            controller: aantalVerticaalController,
            label: 'Verticaal',
            suffix: 'st',
          ),
        ),
      ],
    );
  }

  Widget _getalVeld({
    required TextEditingController controller,
    required String label,
    required String suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        signed: false,
        decimal: false,
      ),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.center,
      onChanged: (_) {
        onWaardeGewijzigd();
      },
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        isDense: true,
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: rand),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: groen, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
    );
  }

  Widget _actieKnoppen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _kanToepassen ? onToepassen : null,
            icon: const Icon(Icons.grid_on_rounded, size: 18),
            label: Text(
              aantalGeselecteerdeVlakken <= 1
                  ? 'Kleinhout toepassen'
                  : 'Kleinhout toepassen op '
                        '$aantalGeselecteerdeVlakken vlakken',
              overflow: TextOverflow.ellipsis,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: groen,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFD1D5DB),
              disabledForegroundColor: const Color(0xFF6B7280),
              padding: const EdgeInsets.symmetric(vertical: 11),
            ),
          ),
        ),
        const SizedBox(height: 7),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _kanVerwijderen ? onVerwijderen : null,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text(
              'Kleinhout uit selectie verwijderen',
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
              side: const BorderSide(color: Color(0xFFDC2626)),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  static String _labelVoorKleinhoutType(OpmetingRaamKleinhoutType type) {
    final naam = _enumNaam(type);

    switch (naam) {
      case 'opGlasRecht':
        return 'Op glas recht';
      case 'opGlasSteelLook':
        return 'Steel look';
      case 'inGlas':
        return 'In glas';
      default:
        return _leesbaarEnumLabel(naam);
    }
  }

  static String _labelVoorPatroon(OpmetingRaamKleinhoutPatroon patroon) {
    final naam = _enumNaam(patroon);

    switch (naam) {
      case 'bovenverdeling':
        return 'Bovenverdeling';
      case 'volledigRaster':
      case 'volledigeVerdeling':
      case 'raster':
        return 'Volledig raster';
      default:
        return _leesbaarEnumLabel(naam);
    }
  }

  static String _enumNaam(Object waarde) {
    final tekst = waarde.toString();
    final puntIndex = tekst.lastIndexOf('.');

    return puntIndex >= 0 ? tekst.substring(puntIndex + 1) : tekst;
  }

  static String _leesbaarEnumLabel(String naam) {
    if (naam.trim().isEmpty) {
      return naam;
    }

    final buffer = StringBuffer();

    for (var index = 0; index < naam.length; index++) {
      final teken = naam[index];
      final isHoofdletter =
          teken.toUpperCase() == teken && teken.toLowerCase() != teken;

      if (index > 0 && isHoofdletter) {
        buffer.write(' ');
      }

      buffer.write(index == 0 ? teken.toUpperCase() : teken);
    }

    return buffer.toString();
  }
}
