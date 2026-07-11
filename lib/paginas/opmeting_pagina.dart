import 'package:flutter/material.dart';

import '../helpers/opmeting/overzicht/opmeting_overzicht_model.dart';
import '../helpers/opmeting/overzicht/opmeting_overzicht_kaart.dart';
import 'opmeting_raam_pagina.dart';

class OpmetingPagina extends StatefulWidget {
  const OpmetingPagina({super.key});

  @override
  State<OpmetingPagina> createState() {
    return _OpmetingPaginaState();
  }
}

class _OpmetingPaginaState extends State<OpmetingPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  String _klantNaam = '';
  final List<OpmetingOverzichtRaamItem> _raamOpmetingen =
      <OpmetingOverzichtRaamItem>[];

  Future<void> _nieuwBestand() async {
    final naam = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _NieuwBestandDialog(beginWaarde: _klantNaam);
      },
    );

    if (naam == null || naam.trim().isEmpty) {
      return;
    }

    setState(() {
      _klantNaam = naam.trim();
      _raamOpmetingen.clear();
    });
  }

  void _openBestand() {
    _toonMelding('Open bestand wordt in de volgende stap gekoppeld.');
  }

  void _opslaanBestand() {
    if (_klantNaam.trim().isEmpty) {
      _toonMelding('Maak eerst een nieuw bestand met klantnaam.', fout: true);
      return;
    }

    _toonMelding('Opslaan bestand wordt in de volgende stap gekoppeld.');
  }

  Future<void> _openRaamopmeting() async {
    if (_klantNaam.trim().isEmpty) {
      _toonMelding(
        'Maak eerst een nieuw bestand via Bestand > Nieuw bestand, of open een bestaand bestand.',
        fout: true,
      );
      return;
    }

    if (!mounted) {
      return;
    }

    final resultaat = await Navigator.push<OpmetingOverzichtRaamItem>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return OpmetingRaamPagina(klantNaam: _klantNaam);
        },
      ),
    );

    if (resultaat == null || !mounted) {
      return;
    }

    setState(() {
      _raamOpmetingen.add(resultaat);
    });
  }

  Future<void> _bewerkRaamopmeting(int index) async {
    if (index < 0 || index >= _raamOpmetingen.length) {
      return;
    }

    final huidigeOpmeting = _raamOpmetingen[index];

    final resultaat = await Navigator.push<OpmetingOverzichtRaamItem>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return OpmetingRaamPagina(
            klantNaam: _klantNaam,
            bestaandeOpmeting: huidigeOpmeting,
          );
        },
      ),
    );

    if (resultaat == null || !mounted) {
      return;
    }

    setState(() {
      _raamOpmetingen[index] = resultaat;
    });
  }

  void _toonMelding(String tekst, {bool fout = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tekst),
        backgroundColor: fout ? const Color(0xFFDC2626) : _groen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _achtergrond,
      body: SafeArea(
        child: Column(
          children: [
            _bouwBovenbalk(),
            Expanded(
              child: _raamOpmetingen.isEmpty
                  ? _bouwLegeFiche()
                  : _bouwOverzichtslijst(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bouwBovenbalk() {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _rand)),
      ),
      child: Row(
        children: [
          PopupMenuButton<String>(
            tooltip: 'Bestand',
            onSelected: (waarde) {
              if (waarde == 'nieuw') {
                _nieuwBestand();
              } else if (waarde == 'open') {
                _openBestand();
              } else if (waarde == 'opslaan') {
                _opslaanBestand();
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(value: 'nieuw', child: Text('Nieuw bestand')),
                PopupMenuItem(value: 'open', child: Text('Open bestand')),
                PopupMenuItem(value: 'opslaan', child: Text('Opslaan bestand')),
              ];
            },
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                color: _lichtGroen,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: const Color(0xFFCDEBD6)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.folder_open_rounded, color: _groen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Bestand',
                    style: TextStyle(
                      color: _groen,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, color: _groen, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _klantNaam.trim().isEmpty ? 'Nieuw opmeetblad' : _klantNaam,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _tekstDonker,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            tooltip: 'Formulier toevoegen',
            onSelected: (waarde) {
              if (waarde == 'raam') {
                _openRaamopmeting();
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(value: 'raam', child: Text('Raamopmeting')),
              ];
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _groen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwLegeFiche() {
    final heeftKlant = _klantNaam.trim().isNotEmpty;

    return Center(
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _rand),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: _lichtGroen,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: _groen,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              heeftKlant
                  ? 'Nog geen opmetingen toegevoegd'
                  : 'Start via Bestand',
              style: const TextStyle(
                color: _tekstDonker,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              heeftKlant
                  ? 'Voeg rechtsboven een raamopmeting toe via de plusknop.'
                  : 'Maak eerst een nieuw bestand aan of open een bestaand bestand. Daarna kan u rechtsboven een raamopmeting toevoegen.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _tekstGrijs,
                fontSize: 14,
                height: 1.35,
              ),
            ),
            if (!heeftKlant) ...[
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _nieuwBestand,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Nieuw bestand'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _groen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: _openBestand,
                    icon: const Icon(Icons.folder_open_rounded),
                    label: const Text('Open bestand'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _groen,
                      side: const BorderSide(color: _groen),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _bouwOverzichtslijst() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      itemCount: _raamOpmetingen.length,
      itemBuilder: (context, index) {
        final item = _raamOpmetingen[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: OpmetingOverzichtKaart(
            item: item,
            volgnummer: index + 1,
            onBewerken: () {
              _bewerkRaamopmeting(index);
            },
            onVerwijderen: () {
              setState(() {
                _raamOpmetingen.removeAt(index);
              });
            },
          ),
        );
      },
    );
  }
}

class _NieuwBestandDialog extends StatefulWidget {
  const _NieuwBestandDialog({required this.beginWaarde});

  final String beginWaarde;

  @override
  State<_NieuwBestandDialog> createState() {
    return _NieuwBestandDialogState();
  }
}

class _NieuwBestandDialogState extends State<_NieuwBestandDialog> {
  late final TextEditingController _controller;
  bool _afgesloten = false;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.beginWaarde);
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void _annuleer() {
    if (_afgesloten) {
      return;
    }

    _afgesloten = true;
    Navigator.pop(context);
  }

  void _bewaar() {
    if (_afgesloten) {
      return;
    }

    final naam = _controller.text.trim();

    if (naam.isEmpty) {
      return;
    }

    _afgesloten = true;
    Navigator.pop(context, naam);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nieuw opmeetbestand'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'Naam klant',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) {
          _bewaar();
        },
      ),
      actions: [
        TextButton(onPressed: _annuleer, child: const Text('Annuleren')),
        ElevatedButton(onPressed: _bewaar, child: const Text('Aanmaken')),
      ],
    );
  }
}
