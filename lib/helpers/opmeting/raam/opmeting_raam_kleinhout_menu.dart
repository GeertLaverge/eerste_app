import 'package:flutter/material.dart';

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
  });

  static const Color groen = Color(0xFF0B7A3B);
  static const Color rand = Color(0xFFD1D5DB);
  static const Color tekstGrijs = Color(0xFF6B7280);

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

  bool get _isBovenverdeling {
    return geselecteerdPatroon.name == 'bovenverdeling';
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
      width: 310,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rand),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _menuInhoud(),
    );
  }

  Widget _menuInhoud() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            Icon(Icons.grid_on_outlined, size: 20, color: groen),
            SizedBox(width: 7),
            Expanded(
              child: Text(
                'Kleinhouten',
                style: TextStyle(
                  color: groen,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        const Text(
          'Tik op één of meerdere gevulde vlakken om ze te selecteren of te deselecteren.',
          style: TextStyle(fontSize: 11, color: tekstGrijs),
        ),
        const SizedBox(height: 10),
        _typeKeuze(),
        const SizedBox(height: 10),
        _patroonKeuze(),
        const SizedBox(height: 10),
        if (_isBovenverdeling) ...[
          _tekstVeld(
            controller: horizontaleHoogteController,
            label: 'Horizontale verdeling vanaf bovenkant vulling',
            suffix: 'mm',
            onGewijzigd: onWaardeGewijzigd,
          ),
          const SizedBox(height: 8),
          _tekstVeld(
            controller: aantalVerticaalController,
            label: 'Aantal verticale kleinhouten bovenaan',
            suffix: 'st.',
            onGewijzigd: onWaardeGewijzigd,
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: _tekstVeld(
                  controller: aantalHorizontaalController,
                  label: 'Horizontaal',
                  suffix: 'st.',
                  onGewijzigd: onWaardeGewijzigd,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _tekstVeld(
                  controller: aantalVerticaalController,
                  label: 'Verticaal',
                  suffix: 'st.',
                  onGewijzigd: onWaardeGewijzigd,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        if (aantalGeselecteerdeVlakken > 0 && !selectieKanKleinhoutenKrijgen)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 17, color: Color(0xFFB45309)),
                  SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Kleinhouten kunnen alleen op gevulde vlakken geplaatst worden.',
                      style: TextStyle(
                        color: Color(0xFF92400E),
                        fontSize: 11,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _kanToepassen ? onToepassen : null,
            icon: const Icon(Icons.grid_on, size: 18),
            label: const Text(
              'Kleinhouten toepassen',
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
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text(
              'Kleinhouten uit selectie verwijderen',
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

  Widget _typeKeuze() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Type kleinhout',
        isDense: true,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<OpmetingRaamKleinhoutType>(
          value: geselecteerdType,
          isExpanded: true,
          items: OpmetingRaamKleinhoutType.values.map((type) {
            return DropdownMenuItem<OpmetingRaamKleinhoutType>(
              value: type,
              child: Text(
                _typeLabel(type),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }).toList(),
          onChanged: (type) {
            if (type == null) {
              return;
            }

            onTypeGewijzigd(type);
          },
        ),
      ),
    );
  }

  Widget _patroonKeuze() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Verdeling',
        isDense: true,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<OpmetingRaamKleinhoutPatroon>(
          value: geselecteerdPatroon,
          isExpanded: true,
          items: OpmetingRaamKleinhoutPatroon.values.map((patroon) {
            return DropdownMenuItem<OpmetingRaamKleinhoutPatroon>(
              value: patroon,
              child: Text(
                _patroonLabel(patroon),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }).toList(),
          onChanged: (patroon) {
            if (patroon == null) {
              return;
            }

            onPatroonGewijzigd(patroon);
          },
        ),
      ),
    );
  }

  Widget _tekstVeld({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required VoidCallback onGewijzigd,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) {
        onGewijzigd();
      },
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        isDense: true,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      ),
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
    );
  }

  String _typeLabel(OpmetingRaamKleinhoutType type) {
    switch (type) {
      case OpmetingRaamKleinhoutType.opGlasRecht:
        return 'Op glas recht';

      case OpmetingRaamKleinhoutType.opGlasSteelLook:
        return 'Op glas steel-look';

      case OpmetingRaamKleinhoutType.inGlas:
        return 'In glas';
    }
  }

  String _patroonLabel(OpmetingRaamKleinhoutPatroon patroon) {
    switch (patroon.name) {
      case 'bovenverdeling':
        return 'Bovenverdeling';

      case 'volledigRaster':
        return 'Volledig raster';

      default:
        return _maakLeesbaar(patroon.name);
    }
  }

  String _maakLeesbaar(String tekst) {
    final buffer = StringBuffer();

    for (var index = 0; index < tekst.length; index++) {
      final teken = tekst[index];

      if (index > 0 &&
          teken.toUpperCase() == teken &&
          teken != teken.toLowerCase()) {
        buffer.write(' ');
      }

      if (index == 0) {
        buffer.write(teken.toUpperCase());
      } else {
        buffer.write(teken);
      }
    }

    return buffer.toString();
  }
}
