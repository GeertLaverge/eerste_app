import 'package:flutter/material.dart';

import '../../../helpers/offerte/prijzen/offerte_prijs_categorie.dart';
import '../../../helpers/offerte/prijzen/offerte_prijsregel_weergave_service.dart';
import '../../../helpers/offerte/prijzen/offerte_prijsregel_model.dart';

class OffertePrijstabelWidget extends StatelessWidget {
  const OffertePrijstabelWidget({
    super.key,
    required this.categorie,
    required this.prijsregels,
    required this.uitleg,
    required this.onToevoegen,
    required this.onWijzigen,
    required this.onVerwijderen,
    required this.onActiefGewijzigd,
    required this.onVerplaats,
  });

  final OffertePrijsCategorie categorie;
  final List<OffertePrijsregelModel> prijsregels;
  final String uitleg;
  final VoidCallback onToevoegen;
  final ValueChanged<OffertePrijsregelModel> onWijzigen;
  final ValueChanged<OffertePrijsregelModel> onVerwijderen;
  final void Function(OffertePrijsregelModel prijsregel, bool actief)
  onActiefGewijzigd;
  final void Function(OffertePrijsregelModel prijsregel, int richting)
  onVerplaats;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _rand),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 13),
            decoration: const BoxDecoration(
              color: _lichtGroen,
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(Icons.euro_rounded, color: _groen, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        categorie.benaming,
                        style: const TextStyle(
                          color: _tekstDonker,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        uitleg,
                        style: const TextStyle(
                          color: _tekstGrijs,
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: _rand),
                      ),
                      child: Text(
                        '${prijsregels.length}',
                        style: const TextStyle(
                          color: _groen,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: _groen,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 9,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: onToevoegen,
                      icon: const Icon(Icons.add_rounded, size: 17),
                      label: const Text('Toevoegen'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (prijsregels.isEmpty)
            const Padding(
              padding: EdgeInsets.all(18),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF9CA3AF),
                    size: 19,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Nog geen prijsregels ingesteld.',
                      style: TextStyle(
                        color: _tekstGrijs,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: prijsregels.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return _bouwPrijsregel(
                  prijsregel: prijsregels[index],
                  index: index,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _bouwPrijsregel({
    required OffertePrijsregelModel prijsregel,
    required int index,
  }) {
    final prijsTekst = prijsregel.prijsExclBtw
        .toStringAsFixed(2)
        .replaceAll('.', ',');
    final technischeKeuze = prijsregel.technischeKeuze;
    final isVerdeelKost = prijsregel.isVerdeeldeProjectkost;
    final limietTekst = prijsregel.heeftVerdeelAankooplimiet
        ? 'Niet toepassen vanaf € ${prijsregel.verdeelLimietBedragExclBtw.toStringAsFixed(2).replaceAll('.', ',')}'
        : isVerdeelKost
        ? 'Zonder aankooplimiet'
        : '';
    final keuzeTekst = technischeKeuze?.hoeUitschrijven.trim() ?? '';
    final isTechnischePrijs =
        prijsregel.categorie == OffertePrijsCategorie.technischeKeuzePerArtikel;
    final hoofdOmschrijving = isTechnischePrijs && keuzeTekst.isNotEmpty
        ? keuzeTekst
        : prijsregel.omschrijving;
    final toonGekoppeldeKeuze = !isTechnischePrijs && keuzeTekst.isNotEmpty;

    return Opacity(
      opacity: prijsregel.actief ? 1 : 0.64,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 11, 10, 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Switch.adaptive(
                value: prijsregel.actief,
                activeThumbColor: _groen,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (waarde) {
                  onActiefGewijzigd(prijsregel, waarde);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    hoofdOmschrijving,
                    style: const TextStyle(
                      color: _tekstDonker,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (toonGekoppeldeKeuze) ...<Widget>[
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        const Icon(Icons.link_rounded, color: _groen, size: 15),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            keuzeTekst,
                            style: const TextStyle(
                              color: _groen,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 3,
                    children: <Widget>[
                      Text(
                        isVerdeelKost
                            ? 'Vast projectbedrag — gelijk verdelen'
                            : '${prijsregel.eenheid.benaming} (${prijsregel.eenheid.formuleBenaming})',
                        style: const TextStyle(
                          color: _tekstGrijs,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        OffertePrijsregelWeergaveService.benamingVoorUitschrijfmodus(
                          prijsregel.uitschrijfmodus,
                        ),
                        style: const TextStyle(
                          color: _tekstGrijs,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (limietTekst.isNotEmpty)
                        Text(
                          limietTekst,
                          style: const TextStyle(
                            color: _tekstGrijs,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isVerdeelKost
                        ? '€ $prijsTekst excl. btw te verdelen'
                        : '€ $prijsTekst excl. btw',
                    style: const TextStyle(
                      color: _tekstDonker,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      tooltip: 'Omhoog',
                      visualDensity: VisualDensity.compact,
                      onPressed: index == 0
                          ? null
                          : () => onVerplaats(prijsregel, -1),
                      icon: const Icon(Icons.keyboard_arrow_up_rounded),
                    ),
                    IconButton(
                      tooltip: 'Omlaag',
                      visualDensity: VisualDensity.compact,
                      onPressed: index >= prijsregels.length - 1
                          ? null
                          : () => onVerplaats(prijsregel, 1),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      tooltip: 'Wijzigen',
                      visualDensity: VisualDensity.compact,
                      color: _groen,
                      onPressed: () => onWijzigen(prijsregel),
                      icon: const Icon(Icons.edit_outlined, size: 20),
                    ),
                    IconButton(
                      tooltip: 'Verwijderen',
                      visualDensity: VisualDensity.compact,
                      color: const Color(0xFFDC2626),
                      onPressed: () => onVerwijderen(prijsregel),
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
