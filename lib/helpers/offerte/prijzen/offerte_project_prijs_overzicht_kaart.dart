import 'package:flutter/material.dart';

import 'offerte_prijs_eenheid.dart';
import 'offerte_prijs_uitschrijfmodus.dart';
import 'offerte_project_prijs_service.dart';
import 'offerte_toegepaste_prijsregel_model.dart';

class OfferteProjectPrijsOverzichtKaart extends StatelessWidget {
  const OfferteProjectPrijsOverzichtKaart({
    super.key,
    required this.resultaat,
    this.onBewerken,
  });

  final OfferteProjectPrijsResultaat resultaat;
  final VoidCallback? onBewerken;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final regels = resultaat.regelsVoorOverzicht;

    if (regels.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _rand),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _lichtGroen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_tree_outlined,
                  color: _groen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Bijkomende werken/materiaal',
                      style: TextStyle(
                        color: _tekstDonker,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Eenmalig berekend over de gekozen posities van deze offerte.',
                      style: TextStyle(
                        color: _tekstGrijs,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (onBewerken != null) ...<Widget>[
                IconButton(
                  tooltip: 'Bijkomende werken/materiaal bewerken',
                  onPressed: onBewerken,
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: _groen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 2),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _rand),
                ),
                child: Text(
                  '${resultaat.aantalArtikelen} artikel${resultaat.aantalArtikelen == 1 ? '' : 'en'}',
                  style: const TextStyle(
                    color: _tekstGrijs,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: _rand),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: List<Widget>.generate(regels.length, (index) {
                final regel = regels[index];
                return _ProjectPrijsRegel(
                  regel: regel,
                  toonOnderRand: index < regels.length - 1,
                );
              }),
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Bijkomende werken/materiaal excl. btw',
                  style: TextStyle(
                    color: _tekstDonker,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                _euro(resultaat.totaalOverzichtExclBtw),
                style: const TextStyle(
                  color: _groen,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _euro(double waarde) {
    return '€ ${waarde.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

class _ProjectPrijsRegel extends StatelessWidget {
  const _ProjectPrijsRegel({required this.regel, required this.toonOnderRand});

  final OfferteToegepastePrijsregelModel regel;
  final bool toonOnderRand;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final alleenIntern =
        regel.uitschrijfmodus == OffertePrijsUitschrijfmodus.alleenOverzicht;
    final isOptie = regel.uitschrijfmodus.isOptie;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        border: toonOnderRand
            ? const Border(bottom: BorderSide(color: _rand, width: 0.8))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        regel.omschrijving,
                        style: const TextStyle(
                          color: _tekstDonker,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (alleenIntern || isOptie) ...<Widget>[
                      const SizedBox(width: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          isOptie ? 'optie' : 'intern',
                          style: const TextStyle(
                            color: Color(0xFFEA580C),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _berekeningTekst(regel),
                  style: const TextStyle(
                    color: _tekstGrijs,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Text(
            _euro(regel.totaalExclBtw),
            style: const TextStyle(
              color: _groen,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  static String _berekeningTekst(OfferteToegepastePrijsregelModel regel) {
    if (regel.eenheid == OffertePrijsEenheid.vast) {
      return 'Vaste projectprijs';
    }

    final hoeveelheid = regel.hoeveelheid
        .toStringAsFixed(4)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'[.,]$'), '')
        .replaceAll('.', ',');
    final suffix = regel.eenheid == OffertePrijsEenheid.oppervlakte
        ? 'm²'
        : 'm';

    return '$hoeveelheid $suffix × ${_euro(regel.prijsExclBtw)}';
  }

  static String _euro(double waarde) {
    return '€ ${waarde.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}
