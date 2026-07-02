import 'package:flutter/material.dart';

import 'opmeting_raam_opvulling_model.dart';

class OpmetingRaamOpvullingMenu extends StatelessWidget {
  const OpmetingRaamOpvullingMenu({
    super.key,
    required this.opvullingen,
    required this.isLaden,
    required this.geselecteerdeOpvullingId,
    required this.aantalGeselecteerdeVlakken,
    required this.totaalAantalVlakken,
    required this.onOpvullingGekozen,
    required this.onToepassen,
    required this.onOpvullingVerwijderen,
    required this.onAllesSelecteren,
    required this.onSelectieWissen,
  });

  static const Color groen = Color(0xFF0B7A3B);
  static const Color rand = Color(0xFFD1D5DB);
  static const Color tekstGrijs = Color(0xFF6B7280);

  final List<OpmetingRaamOpvullingModel> opvullingen;
  final bool isLaden;
  final String? geselecteerdeOpvullingId;
  final int aantalGeselecteerdeVlakken;
  final int totaalAantalVlakken;

  final ValueChanged<String?> onOpvullingGekozen;
  final VoidCallback onToepassen;
  final VoidCallback onOpvullingVerwijderen;
  final VoidCallback onAllesSelecteren;
  final VoidCallback onSelectieWissen;

  OpmetingRaamOpvullingModel? get geselecteerdeOpvulling {
    for (final opvulling in opvullingen) {
      if (opvulling.id == geselecteerdeOpvullingId) {
        return opvulling;
      }
    }

    return null;
  }

  bool get kanToepassen {
    return aantalGeselecteerdeVlakken > 0 && geselecteerdeOpvulling != null;
  }

  bool get kanOpvullingVerwijderen {
    return aantalGeselecteerdeVlakken > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
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
      child: isLaden ? _laadWeergave() : _menuInhoud(),
    );
  }

  Widget _laadWeergave() {
    return const SizedBox(
      height: 110,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: groen),
            ),
            SizedBox(height: 10),
            Text(
              'Opvullingen laden…',
              style: TextStyle(fontSize: 12, color: tekstGrijs),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuInhoud() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            Icon(Icons.format_color_fill_outlined, size: 20, color: groen),
            SizedBox(width: 7),
            Expanded(
              child: Text(
                'Opvulling',
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
          'Tik op één of meerdere vlakken in het raam.',
          style: TextStyle(fontSize: 11, color: tekstGrijs),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: aantalGeselecteerdeVlakken > 0
                ? const Color(0xFFFFF7ED)
                : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: aantalGeselecteerdeVlakken > 0
                  ? const Color(0xFFF97316)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Icon(
                aantalGeselecteerdeVlakken > 0
                    ? Icons.check_box_outlined
                    : Icons.check_box_outline_blank,
                size: 18,
                color: aantalGeselecteerdeVlakken > 0
                    ? const Color(0xFFF97316)
                    : tekstGrijs,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  aantalGeselecteerdeVlakken == 0
                      ? 'Nog geen vlak geselecteerd'
                      : '$aantalGeselecteerdeVlakken van '
                            '$totaalAantalVlakken vlakken geselecteerd',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: aantalGeselecteerdeVlakken > 0
                        ? FontWeight.w800
                        : FontWeight.w500,
                    color: aantalGeselecteerdeVlakken > 0
                        ? const Color(0xFF9A3412)
                        : tekstGrijs,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: totaalAantalVlakken > 0 ? onAllesSelecteren : null,
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
                onPressed: aantalGeselecteerdeVlakken > 0
                    ? onSelectieWissen
                    : null,
                icon: const Icon(Icons.deselect, size: 17),
                label: const Text('Geen', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: tekstGrijs,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (opvullingen.isEmpty) _geenOpvullingen() else _opvullingKeuze(),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: kanToepassen ? onToepassen : null,
            icon: const Icon(Icons.format_color_fill, size: 18),
            label: Text(
              aantalGeselecteerdeVlakken <= 1
                  ? 'Opvulling toepassen'
                  : 'Opvulling toepassen op '
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
            onPressed: kanOpvullingVerwijderen ? onOpvullingVerwijderen : null,
            icon: const Icon(Icons.format_color_reset_outlined, size: 18),
            label: const Text(
              'Opvulling uit selectie verwijderen',
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

  Widget _geenOpvullingen() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: Color(0xFFB45309)),
          SizedBox(width: 7),
          Expanded(
            child: Text(
              'Er zijn nog geen opvullingen. Voeg ze eerst toe via '
              'Instellingen → Opvullingen.',
              style: TextStyle(
                color: Color(0xFF92400E),
                fontSize: 11,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _opvullingKeuze() {
    final gekozen = geselecteerdeOpvulling;

    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Kies een opvulling',
        isDense: true,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: gekozen?.id,
          isExpanded: true,
          hint: const Text(
            'Selecteer een opvulling',
            style: TextStyle(fontSize: 12),
          ),
          items: opvullingen.map((opvulling) {
            return DropdownMenuItem<String>(
              value: opvulling.id,
              child: Row(
                children: [
                  _kleurVak(
                    kleur: opvulling.weergaveKleur,
                    basisKleur: opvulling.kleur,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      opvulling.naam,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    '${opvulling.transparantiePercentage}%',
                    style: const TextStyle(fontSize: 10, color: tekstGrijs),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onOpvullingGekozen,
        ),
      ),
    );
  }

  Widget _kleurVak({required Color kleur, required Color basisKleur}) {
    return Container(
      width: 28,
      height: 24,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: kleur,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: basisKleur.withOpacity(0.55)),
        ),
      ),
    );
  }
}
