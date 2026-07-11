import 'package:flutter/material.dart';

import 'opmeting_raam_technisch_item_model.dart';

class OpmetingRaamExtraItemMenu extends StatefulWidget {
  const OpmetingRaamExtraItemMenu({super.key});

  static Future<OpmetingRaamTechnischItemModel?> toon(BuildContext context) {
    return showDialog<OpmetingRaamTechnischItemModel>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const OpmetingRaamExtraItemMenu();
      },
    );
  }

  @override
  State<OpmetingRaamExtraItemMenu> createState() {
    return _OpmetingRaamExtraItemMenuState();
  }
}

class _OpmetingRaamExtraItemMenuState extends State<OpmetingRaamExtraItemMenu> {
  static const Color groen = Color(0xFF0B7A3B);
  static const Color rand = Color(0xFFE5E7EB);

  final TextEditingController _titelController = TextEditingController();

  final TextEditingController _soortenController = TextEditingController();

  final TextEditingController _breedteController = TextEditingController();

  final TextEditingController _hoogteController = TextEditingController(
    text: '60',
  );

  bool _extraTekeningToevoegen = false;
  bool _volledigeRaambreedte = true;
  bool _inDeMaat = true;

  OpmetingRaamExtraTekeningPositie _positie =
      OpmetingRaamExtraTekeningPositie.boven;

  OpmetingRaamRasterPatroon _rasterPatroon =
      OpmetingRaamRasterPatroon.horizontaleStrepen;

  String? _foutmelding;

  @override
  void dispose() {
    _titelController.dispose();
    _soortenController.dispose();
    _breedteController.dispose();
    _hoogteController.dispose();

    super.dispose();
  }

  List<String> _leesSoorten() {
    return _soortenController.text
        .split(RegExp(r'[\n,;]+'))
        .map((waarde) => waarde.trim())
        .where((waarde) => waarde.isNotEmpty)
        .toSet()
        .toList();
  }

  void _opslaan() {
    final titel = _titelController.text.trim();
    final soorten = _leesSoorten();

    if (titel.isEmpty) {
      setState(() {
        _foutmelding = 'Vul een titel in.';
      });

      return;
    }

    if (soorten.isEmpty) {
      setState(() {
        _foutmelding = 'Voeg minstens één soort toe.';
      });

      return;
    }

    OpmetingRaamExtraTekeningModel? extraTekening;

    if (_extraTekeningToevoegen) {
      final hoogteMm = int.tryParse(_hoogteController.text.trim());

      if (hoogteMm == null || hoogteMm <= 0) {
        setState(() {
          _foutmelding = 'Vul een geldige hoogte in.';
        });

        return;
      }

      int? breedteMm;

      if (!_volledigeRaambreedte) {
        breedteMm = int.tryParse(_breedteController.text.trim());

        if (breedteMm == null || breedteMm <= 0) {
          setState(() {
            _foutmelding = 'Vul een geldige breedte in.';
          });

          return;
        }
      }

      extraTekening = OpmetingRaamExtraTekeningModel(
        breedteMm: breedteMm,
        hoogteMm: hoogteMm,
        positie: _positie,
        inDeMaat: _inDeMaat,
        rasterPatroon: _rasterPatroon,
      );
    }

    final item = OpmetingRaamTechnischItemModel(
      id: 'extra_${DateTime.now().microsecondsSinceEpoch}',
      titel: titel,
      soorten: soorten,
      gekozenSoort: soorten.first,
      extraTekening: extraTekening,
    );

    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(20),
      contentPadding: EdgeInsets.zero,
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _kop(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _titelVeld(),
                    const SizedBox(height: 14),
                    _soortenVeld(),
                    const SizedBox(height: 14),
                    _extraTekeningSchakelaar(),
                    if (_extraTekeningToevoegen) ...[
                      const SizedBox(height: 12),
                      _tekeningInstellingen(),
                    ],
                    if (_foutmelding != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _foutmelding!,
                        style: const TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _actiebalk(),
          ],
        ),
      ),
    );
  }

  Widget _kop() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: const BoxDecoration(
        color: Color(0xFFE7F6EC),
        border: Border(bottom: BorderSide(color: rand)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Extra technisch item',
              style: TextStyle(
                color: groen,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Sluiten',
            visualDensity: VisualDensity.compact,
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close, size: 20, color: Color(0xFF4B5563)),
          ),
        ],
      ),
    );
  }

  Widget _titelVeld() {
    return TextField(
      controller: _titelController,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Titel',
        hintText: 'Bijvoorbeeld ventilatierooster',
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _soortenVeld() {
    return TextField(
      controller: _soortenController,
      minLines: 3,
      maxLines: 6,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Soorten',
        hintText:
            'Plaats iedere soort op een nieuwe lijn.\n'
            'Bijvoorbeeld:\n'
            'Geen\n'
            'Invisivent\n'
            'Glasrooster',
        helperText: 'Je mag soorten ook scheiden met een komma.',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _extraTekeningSchakelaar() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: rand),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SwitchListTile(
        dense: true,
        value: _extraTekeningToevoegen,
        activeTrackColor: groen,
        title: const Text(
          'Extra rechthoek tekenen',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        subtitle: const Text(
          'Bijvoorbeeld een ventilatierooster.',
          style: TextStyle(fontSize: 11),
        ),
        onChanged: (waarde) {
          setState(() {
            _extraTekeningToevoegen = waarde;
            _foutmelding = null;
          });
        },
      ),
    );
  }

  Widget _tekeningInstellingen() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: rand),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Instellingen extra tekening',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: _volledigeRaambreedte,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
              'Breedte gelijk aan raam',
              style: TextStyle(fontSize: 12),
            ),
            onChanged: (waarde) {
              setState(() {
                _volledigeRaambreedte = waarde ?? true;
              });
            },
          ),
          if (!_volledigeRaambreedte) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _breedteController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Breedte',
                suffixText: 'mm',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
          const SizedBox(height: 10),
          TextField(
            controller: _hoogteController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Hoogte',
              suffixText: 'mm',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<OpmetingRaamExtraTekeningPositie>(
            initialValue: _positie,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Positie',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: OpmetingRaamExtraTekeningPositie.values.map((positie) {
              return DropdownMenuItem<OpmetingRaamExtraTekeningPositie>(
                value: positie,
                child: Text(positie.label),
              );
            }).toList(),
            onChanged: (waarde) {
              if (waarde == null) {
                return;
              }

              setState(() {
                _positie = waarde;
              });
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<OpmetingRaamRasterPatroon>(
            initialValue: _rasterPatroon,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Rasteropvulling',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: OpmetingRaamRasterPatroon.values.map((patroon) {
              return DropdownMenuItem<OpmetingRaamRasterPatroon>(
                value: patroon,
                child: Text(patroon.label, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (waarde) {
              if (waarde == null) {
                return;
              }

              setState(() {
                _rasterPatroon = waarde;
              });
            },
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: _inDeMaat,
            activeTrackColor: groen,
            title: const Text(
              'In de raammaat',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              _inDeMaat
                  ? 'De rechthoek valt binnen de ingegeven maat.'
                  : 'De rechthoek komt buiten de ingegeven maat.',
              style: const TextStyle(fontSize: 10.5),
            ),
            onChanged: (waarde) {
              setState(() {
                _inDeMaat = waarde;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _actiebalk() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: rand)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Annuleren'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: groen),
            onPressed: _opslaan,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Toevoegen'),
          ),
        ],
      ),
    );
  }
}
