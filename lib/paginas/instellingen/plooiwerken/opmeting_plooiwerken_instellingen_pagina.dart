// THIMACO-CONTROLE: INSTELLINGEN-PLOOIWERKEN-PLAKLIJSTEN-20260728-2110
import 'package:flutter/material.dart';

import '../../../helpers/app_storage.dart';
import '../../../helpers/opmeting/toebehoren/plooiwerken/opmeting_plooiwerken_instellingen_model.dart';

class OpmetingPlooiwerkenInstellingenPagina extends StatefulWidget {
  const OpmetingPlooiwerkenInstellingenPagina({super.key});

  @override
  State<OpmetingPlooiwerkenInstellingenPagina> createState() {
    return _OpmetingPlooiwerkenInstellingenPaginaState();
  }
}

class _OpmetingPlooiwerkenInstellingenPaginaState
    extends State<OpmetingPlooiwerkenInstellingenPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekst = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  final TextEditingController _kleurenController = TextEditingController();
  final TextEditingController _foliesController = TextEditingController();

  bool _laden = true;
  bool _bewaren = false;

  @override
  void initState() {
    super.initState();
    _laad();
  }

  @override
  void dispose() {
    _kleurenController.dispose();
    _foliesController.dispose();
    super.dispose();
  }

  Future<void> _laad() async {
    final instellingen = await AppStorage.laadOpmetingPlooiwerkenInstellingen();

    if (!mounted) return;
    setState(() {
      _kleurenController.text = instellingen.kleuren.join('\n');
      _foliesController.text = instellingen.folies.join('\n');
      _laden = false;
    });
  }

  List<String> _parseLijst(String tekst) {
    final delen = tekst
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split(RegExp(r'[\n;\t]+'));

    final resultaat = <String>[];
    final gebruikt = <String>{};
    for (final deel in delen) {
      final waarde = deel.trim();
      final sleutel = waarde.toLowerCase();
      if (waarde.isEmpty || !gebruikt.add(sleutel)) continue;
      resultaat.add(waarde);
    }
    return List<String>.unmodifiable(resultaat);
  }

  Future<void> _bewaar() async {
    if (_bewaren) return;
    setState(() => _bewaren = true);

    try {
      final instellingen = OpmetingPlooiwerkenInstellingen(
        kleuren: _parseLijst(_kleurenController.text),
        folies: _parseLijst(_foliesController.text),
      ).metWijzigingsDatum();

      await AppStorage.bewaarOpmetingPlooiwerkenInstellingen(instellingen);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Instellingen Plooiwerken bewaard.')),
      );
    } finally {
      if (mounted) setState(() => _bewaren = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _achtergrond,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _tekst,
        elevation: 0,
        title: const Text(
          'Instellingen Plooiwerken',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _groen),
              onPressed: _laden || _bewaren ? null : _bewaar,
              icon: _bewaren
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: const Text('Bewaren'),
            ),
          ),
        ],
      ),
      body: _laden
          ? const Center(child: CircularProgressIndicator(color: _groen))
          : ListView(
              padding: const EdgeInsets.all(18),
              children: <Widget>[
                const Text(
                  'Plak één waarde per regel. Ook lijsten uit Excel met tabs of puntkomma’s worden verwerkt. Lege regels en dubbele waarden worden automatisch verwijderd.',
                  style: TextStyle(
                    color: _tekstGrijs,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                _LijstKaart(
                  titel: 'Poederlakkleuren',
                  uitleg:
                      'Plak hier de volledige poederlaklijst. Deze waarden verschijnen bij Kleursoort > Poederlak.',
                  controller: _kleurenController,
                ),
                const SizedBox(height: 14),
                _LijstKaart(
                  titel: 'Foliekleuren (Renolit)',
                  uitleg:
                      'Plak hier de volledige Renolit-folielijst. Deze waarden verschijnen bij Kleursoort > Folie (Renolit).',
                  controller: _foliesController,
                ),
              ],
            ),
    );
  }
}

class _LijstKaart extends StatelessWidget {
  const _LijstKaart({
    required this.titel,
    required this.uitleg,
    required this.controller,
  });

  final String titel;
  final String uitleg;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _OpmetingPlooiwerkenInstellingenPaginaState._rand,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            titel,
            style: const TextStyle(
              color: _OpmetingPlooiwerkenInstellingenPaginaState._tekst,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            uitleg,
            style: const TextStyle(
              color: _OpmetingPlooiwerkenInstellingenPaginaState._tekstGrijs,
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            minLines: 8,
            maxLines: 16,
            decoration: InputDecoration(
              hintText: 'Eén waarde per regel',
              filled: true,
              fillColor: const Color(0xFFFCFCFD),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: _OpmetingPlooiwerkenInstellingenPaginaState._rand,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: _OpmetingPlooiwerkenInstellingenPaginaState._groen,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
