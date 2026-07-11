import 'package:flutter/material.dart';

import 'opmeting_overzicht_model.dart';
import 'opmeting_overzicht_tekening.dart';

class OpmetingOverzichtKaart extends StatelessWidget {
  const OpmetingOverzichtKaart({
    required this.item,
    required this.volgnummer,
    required this.onBewerken,
    required this.onVerwijderen,
  });

  final OpmetingOverzichtRaamItem item;
  final int volgnummer;
  final VoidCallback onBewerken;
  final VoidCallback onVerwijderen;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final technischeContainers = item.zichtbareTechnischeContainers;
    final oudeTechnischeRegels = item.zichtbareTechnischeRegels;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _rand),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pos $volgnummer - ${item.titel.trim().isEmpty ? 'Raam' : item.titel.trim()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _tekstDonker,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onBewerken,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Bewerken'),
                style: TextButton.styleFrom(foregroundColor: _groen),
              ),
              IconButton(
                tooltip: 'Verwijderen',
                onPressed: onVerwijderen,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 430,
                child: AspectRatio(
                  aspectRatio: 1.65,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _rand),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CustomPaint(
                        painter: OpmetingOverzichtTekening(item: item),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _bouwTotaleMaatBlok(),
                    const SizedBox(height: 9),
                    if (technischeContainers.isNotEmpty)
                      ...technischeContainers.map(_bouwTechnischeContainer)
                    else if (oudeTechnischeRegels.isNotEmpty)
                      _bouwOudeTechnischeRegels(oudeTechnischeRegels)
                    else
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'Geen technische kenmerken ingevuld.',
                          style: TextStyle(
                            color: _tekstGrijs,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (item.notities.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _rand),
              ),
              child: Text(
                item.notities.trim(),
                style: const TextStyle(
                  color: _tekstDonker,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bouwTotaleMaatBlok() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _lichtGroen,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFCDEBD6)),
      ),
      child: Row(
        children: [
          const Text(
            'Totale raammaat',
            style: TextStyle(
              color: _groen,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Text(
            '${item.raammaatBreedteMm} × ${item.raammaatHoogteMm} mm',
            style: const TextStyle(
              color: _tekstDonker,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwTechnischeContainer(
    OpmetingOverzichtTechnischeContainer technischeContainer,
  ) {
    final regels = technischeContainer.zichtbareRegels;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _rand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  technischeContainer.titel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _groen,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                technischeContainer.afmeting,
                style: const TextStyle(
                  color: _tekstDonker,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          if (regels.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...regels.map(_bouwTechnischeRegel),
          ],
        ],
      ),
    );
  }

  Widget _bouwTechnischeRegel(OpmetingOverzichtTechnischeRegel regel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              regel.titel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _tekstGrijs,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              regel.waarde,
              style: const TextStyle(
                color: _tekstDonker,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwOudeTechnischeRegels(
    List<OpmetingOverzichtTechnischeRegel> regels,
  ) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _rand),
      ),
      child: Column(children: regels.map(_bouwTechnischeRegel).toList()),
    );
  }
}
