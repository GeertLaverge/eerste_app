// THIMACO-CONTROLE: INSTELLINGEN-ALIPLAST-POEDERLIJST-20260808
import 'package:flutter/material.dart';

import '../../../helpers/opmeting/project/aliplast_kleuren.dart';

class AliplastKleurenPagina extends StatefulWidget {
  const AliplastKleurenPagina({super.key});

  @override
  State<AliplastKleurenPagina> createState() => _AliplastKleurenPaginaState();
}

class _AliplastKleurenPaginaState extends State<AliplastKleurenPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekst = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  final TextEditingController _zoekController = TextEditingController();

  @override
  void dispose() {
    _zoekController.dispose();
    super.dispose();
  }

  List<AliplastKleur> get _zichtbareKleuren {
    return AliplastKleuren.zoek(_zoekController.text);
  }

  @override
  Widget build(BuildContext context) {
    final kleuren = _zichtbareKleuren;

    return Scaffold(
      backgroundColor: _achtergrond,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _tekst,
        elevation: 0,
        title: const Text(
          'Aliplast',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _rand),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Aliplast poederkleuren',
                    style: TextStyle(
                      color: _tekst,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Powder information 03-2025. Alleen Product, '
                    'Productomschrijving en Product crossreferentie worden '
                    'in Thimaco gebruikt.',
                    style: TextStyle(
                      color: _tekstGrijs,
                      fontSize: 11.5,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _zoekController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded),
                      hintText:
                          'Zoeken op product, omschrijving of crossreferentie',
                      isDense: true,
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _rand),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _rand),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _groen, width: 1.4),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${kleuren.length} van ${AliplastKleuren.alle.length} kleuren',
                    style: const TextStyle(
                      color: _tekstGrijs,
                      fontSize: 10.8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _rand),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: <Widget>[
                    const _AliplastTabelRij(
                      product: 'Product',
                      omschrijving: 'Productomschrijving',
                      crossreferentie: 'Product crossreferentie',
                      kop: true,
                    ),
                    const Divider(height: 1, color: _rand),
                    Expanded(
                      child: kleuren.isEmpty
                          ? const Center(
                              child: Text(
                                'Geen Aliplast-kleuren gevonden.',
                                style: TextStyle(
                                  color: _tekstGrijs,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : Scrollbar(
                              child: ListView.separated(
                                itemCount: kleuren.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1, color: _rand),
                                itemBuilder: (context, index) {
                                  final kleur = kleuren[index];
                                  return _AliplastTabelRij(
                                    product: kleur.product,
                                    omschrijving: kleur.productOmschrijving,
                                    crossreferentie:
                                        kleur.productCrossreferentie,
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AliplastTabelRij extends StatelessWidget {
  const _AliplastTabelRij({
    required this.product,
    required this.omschrijving,
    required this.crossreferentie,
    this.kop = false,
  });

  final String product;
  final String omschrijving;
  final String crossreferentie;
  final bool kop;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _tekst = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final stijl = TextStyle(
      color: kop ? _groen : _tekst,
      fontSize: kop ? 11.3 : 11,
      fontWeight: kop ? FontWeight.w900 : FontWeight.w700,
    );

    return Container(
      color: kop ? _lichtGroen : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              product,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: stijl,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Text(
              omschrijving,
              maxLines: kop ? 2 : 3,
              overflow: TextOverflow.ellipsis,
              style: stijl,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Text(
              crossreferentie.isEmpty && !kop ? '-' : crossreferentie,
              maxLines: kop ? 2 : 3,
              overflow: TextOverflow.ellipsis,
              style: crossreferentie.isEmpty && !kop
                  ? stijl.copyWith(color: _tekstGrijs)
                  : stijl,
            ),
          ),
        ],
      ),
    );
  }
}
