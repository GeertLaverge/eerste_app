import 'package:flutter/material.dart';

import 'opmeting_kader_samenstelling_model.dart';

class OpmetingKaderToevoegenResultaat {
  const OpmetingKaderToevoegenResultaat({
    required this.naam,
    required this.breedteMm,
    required this.hoogteMm,
    required this.gekoppeldAanKaderId,
    required this.zijde,
    required this.uitlijning,
    required this.vrijeOffsetMm,
  });

  final String naam;
  final int breedteMm;
  final int hoogteMm;

  final String gekoppeldAanKaderId;
  final OpmetingKaderZijde zijde;
  final OpmetingKaderUitlijning uitlijning;

  /// Alleen gebruikt wanneer uitlijning = vrij.
  ///
  /// Bij links/rechts = afstand vanaf boven.
  /// Bij boven/onder = afstand vanaf links.
  final int vrijeOffsetMm;
}

Future<OpmetingKaderToevoegenResultaat?> toonOpmetingKaderToevoegenDialoog({
  required BuildContext context,
  required List<OpmetingKaderDeel> bestaandeKaders,
  String? actiefKaderId,
}) {
  return showDialog<OpmetingKaderToevoegenResultaat>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return OpmetingKaderToevoegenDialoog(
        bestaandeKaders: bestaandeKaders,
        actiefKaderId: actiefKaderId,
      );
    },
  );
}

class OpmetingKaderToevoegenDialoog extends StatefulWidget {
  const OpmetingKaderToevoegenDialoog({
    super.key,
    required this.bestaandeKaders,
    this.actiefKaderId,
  });

  final List<OpmetingKaderDeel> bestaandeKaders;
  final String? actiefKaderId;

  @override
  State<OpmetingKaderToevoegenDialoog> createState() {
    return _OpmetingKaderToevoegenDialoogState();
  }
}

class _OpmetingKaderToevoegenDialoogState
    extends State<OpmetingKaderToevoegenDialoog> {
  static const Color groen = Color(0xFF0B7A3B);

  late final TextEditingController _naamController;
  late final TextEditingController _breedteController;
  late final TextEditingController _hoogteController;
  late final TextEditingController _vrijeOffsetController;

  String? _gekoppeldAanKaderId;
  OpmetingKaderZijde _zijde = OpmetingKaderZijde.rechts;
  OpmetingKaderUitlijning _uitlijning = OpmetingKaderUitlijning.begin;

  String? _foutmelding;

  @override
  void initState() {
    super.initState();

    final kaders = _beschikbareKaders();

    final startKaderId = _bepaalStartKaderId(kaders: kaders);

    _gekoppeldAanKaderId = startKaderId;

    _naamController = TextEditingController(
      text: 'Kader ${widget.bestaandeKaders.length + 1}',
    );

    _breedteController = TextEditingController(text: '1000');

    _hoogteController = TextEditingController(text: '2000');

    _vrijeOffsetController = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _naamController.dispose();
    _breedteController.dispose();
    _hoogteController.dispose();
    _vrijeOffsetController.dispose();

    super.dispose();
  }

  List<OpmetingKaderDeel> _beschikbareKaders() {
    final kaders = widget.bestaandeKaders
        .where((kader) => kader.actief)
        .toList();

    kaders.sort(
      (eerste, tweede) =>
          eerste.naam.toLowerCase().compareTo(tweede.naam.toLowerCase()),
    );

    return kaders;
  }

  String? _bepaalStartKaderId({required List<OpmetingKaderDeel> kaders}) {
    if (kaders.isEmpty) {
      return null;
    }

    final actiefKaderId = widget.actiefKaderId?.trim() ?? '';

    if (actiefKaderId.isNotEmpty) {
      for (final kader in kaders) {
        if (kader.id == actiefKaderId) {
          return kader.id;
        }
      }
    }

    return kaders.first.id;
  }

  OpmetingKaderDeel? _gekozenAnkerKader() {
    final kaderId = _gekoppeldAanKaderId?.trim() ?? '';

    if (kaderId.isEmpty) {
      return null;
    }

    for (final kader in widget.bestaandeKaders) {
      if (kader.id == kaderId) {
        return kader;
      }
    }

    return null;
  }

  void _bewaar() {
    final naam = _naamController.text.trim();

    if (naam.isEmpty) {
      _toonFout('Vul een naam in.');
      return;
    }

    final breedteMm = _leesMm(_breedteController.text);

    if (breedteMm == null || breedteMm <= 0) {
      _toonFout('Vul een geldige breedte in.');
      return;
    }

    final hoogteMm = _leesMm(_hoogteController.text);

    if (hoogteMm == null || hoogteMm <= 0) {
      _toonFout('Vul een geldige hoogte in.');
      return;
    }

    final gekoppeldAanKaderId = _gekoppeldAanKaderId?.trim() ?? '';

    if (gekoppeldAanKaderId.isEmpty) {
      _toonFout('Kies aan welk kader het nieuwe kader moet aansluiten.');
      return;
    }

    var vrijeOffsetMm = 0;

    if (_uitlijning == OpmetingKaderUitlijning.vrij) {
      final offset = _leesMm(_vrijeOffsetController.text);

      if (offset == null) {
        _toonFout(
          'Vul een geldige vrije positie in. '
          'Negatieve waarden zijn toegestaan.',
        );
        return;
      }

      vrijeOffsetMm = offset;
    }

    Navigator.pop(
      context,
      OpmetingKaderToevoegenResultaat(
        naam: naam,
        breedteMm: breedteMm,
        hoogteMm: hoogteMm,
        gekoppeldAanKaderId: gekoppeldAanKaderId,
        zijde: _zijde,
        uitlijning: _uitlijning,
        vrijeOffsetMm: vrijeOffsetMm,
      ),
    );
  }

  void _toonFout(String melding) {
    setState(() {
      _foutmelding = melding;
    });
  }

  int? _leesMm(String tekst) {
    final opgeschoond = tekst.trim().replaceAll(',', '.');

    final getal = double.tryParse(opgeschoond);

    if (getal == null) {
      return null;
    }

    return getal.round();
  }

  @override
  Widget build(BuildContext context) {
    final kaders = _beschikbareKaders();

    return AlertDialog(
      title: const Text('Kader toevoegen'),
      content: SizedBox(
        width: 520,
        child: kaders.isEmpty
            ? const Text(
                'Er is nog geen bestaand kader beschikbaar. '
                'Maak eerst een basiskader aan.',
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _bouwNaamEnMaten(),
                    const SizedBox(height: 14),
                    _bouwAansluiting(kaders),
                    const SizedBox(height: 14),
                    _bouwUitlijning(),
                    if (_uitlijning == OpmetingKaderUitlijning.vrij) ...[
                      const SizedBox(height: 12),
                      _bouwVrijePositie(),
                    ],
                    const SizedBox(height: 12),
                    _bouwUitleg(),
                    if (_foutmelding != null) ...[
                      const SizedBox(height: 12),
                      _bouwFoutmelding(),
                    ],
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Annuleren'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: groen,
            foregroundColor: Colors.white,
          ),
          onPressed: kaders.isEmpty ? null : _bewaar,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Toevoegen'),
        ),
      ],
    );
  }

  Widget _bouwNaamEnMaten() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _naamController,
          decoration: const InputDecoration(
            labelText: 'Naam',
            hintText: 'Bijvoorbeeld: Zijraam rechts',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _breedteController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Breedte',
                  suffixText: 'mm',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _hoogteController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Hoogte',
                  suffixText: 'mm',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _bouwAansluiting(List<OpmetingKaderDeel> kaders) {
    final gekozenKader = _gekozenAnkerKader();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Aansluiten aan',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _gekoppeldAanKaderId,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Bestaand kader',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: kaders.map((kader) {
            return DropdownMenuItem<String>(
              value: kader.id,
              child: Text(
                '${kader.naam} · '
                '${kader.breedteMm} × ${kader.hoogteMm} mm',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (waarde) {
            setState(() {
              _gekoppeldAanKaderId = waarde;
              _foutmelding = null;
            });
          },
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<OpmetingKaderZijde>(
          value: _zijde,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Zijde',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: OpmetingKaderZijde.values.map((zijde) {
            return DropdownMenuItem<OpmetingKaderZijde>(
              value: zijde,
              child: Text(zijde.label),
            );
          }).toList(),
          onChanged: (waarde) {
            if (waarde == null) {
              return;
            }

            setState(() {
              _zijde = waarde;
              _foutmelding = null;
            });
          },
        ),
        if (gekozenKader != null) ...[
          const SizedBox(height: 8),
          Text(
            'Gekozen kader: ${gekozenKader.naam} '
            '(${gekozenKader.breedteMm} × '
            '${gekozenKader.hoogteMm} mm)',
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _bouwUitlijning() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Uitlijning', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        DropdownButtonFormField<OpmetingKaderUitlijning>(
          value: _uitlijning,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Plaatsing langs de raakzijde',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: OpmetingKaderUitlijning.values.map((uitlijning) {
            return DropdownMenuItem<OpmetingKaderUitlijning>(
              value: uitlijning,
              child: Text(uitlijning.labelVoorZijde(_zijde)),
            );
          }).toList(),
          onChanged: (waarde) {
            if (waarde == null) {
              return;
            }

            setState(() {
              _uitlijning = waarde;
              _foutmelding = null;
            });
          },
        ),
      ],
    );
  }

  Widget _bouwVrijePositie() {
    final label =
        _zijde == OpmetingKaderZijde.links ||
            _zijde == OpmetingKaderZijde.rechts
        ? 'Afstand vanaf boven'
        : 'Afstand vanaf links';

    return TextField(
      controller: _vrijeOffsetController,
      keyboardType: const TextInputType.numberWithOptions(
        signed: true,
        decimal: true,
      ),
      decoration: InputDecoration(
        labelText: label,
        suffixText: 'mm',
        helperText: 'Negatieve waarden zijn toegestaan.',
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _bouwUitleg() {
    final isLinksOfRechts =
        _zijde == OpmetingKaderZijde.links ||
        _zijde == OpmetingKaderZijde.rechts;

    final tekst = isLinksOfRechts
        ? 'Bij links of rechts bepaal je de verticale positie '
              'van het nieuwe kader: boven, midden, onder of vrij.'
        : 'Bij boven of onder bepaal je de horizontale positie '
              'van het nieuwe kader: links, midden, rechts of vrij.';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        tekst,
        style: const TextStyle(color: Color(0xFF374151), fontSize: 12),
      ),
    );
  }

  Widget _bouwFoutmelding() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Text(
        _foutmelding!,
        style: const TextStyle(
          color: Color(0xFFB91C1C),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
