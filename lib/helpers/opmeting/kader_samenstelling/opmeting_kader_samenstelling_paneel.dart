import 'package:flutter/material.dart';

import 'opmeting_kader_samenstelling_layout_helper.dart';
import 'opmeting_kader_samenstelling_model.dart';

class OpmetingKaderSamenstellingPaneel extends StatefulWidget {
  const OpmetingKaderSamenstellingPaneel({
    super.key,
    required this.samenstelling,
    required this.onGewijzigd,
    this.initieelOpen = false,
    this.bewerkenToegestaan = true,
  });

  final OpmetingKaderSamenstelling samenstelling;
  final ValueChanged<OpmetingKaderSamenstelling> onGewijzigd;

  final bool initieelOpen;
  final bool bewerkenToegestaan;

  @override
  State<OpmetingKaderSamenstellingPaneel> createState() {
    return _OpmetingKaderSamenstellingPaneelState();
  }
}

class _OpmetingKaderSamenstellingPaneelState
    extends State<OpmetingKaderSamenstellingPaneel> {
  static const Color groen = Color(0xFF0B7A3B);
  static const Color lichtGroen = Color(0xFFE7F6EC);
  static const Color rand = Color(0xFFE5E7EB);
  static const Color tekstDonker = Color(0xFF111827);
  static const Color tekstGrijs = Color(0xFF6B7280);

  late bool _open;

  final TextEditingController _naamController = TextEditingController();
  final TextEditingController _breedteController = TextEditingController();
  final TextEditingController _hoogteController = TextEditingController();
  final TextEditingController _actieveVrijeOffsetController =
      TextEditingController(text: '0');

  final TextEditingController _nieuwBreedteController = TextEditingController(
    text: '300',
  );
  final TextEditingController _nieuwHoogteController = TextEditingController(
    text: '300',
  );
  final TextEditingController _nieuwVrijeOffsetController =
      TextEditingController(text: '0');

  final FocusNode _naamFocusNode = FocusNode();
  final FocusNode _breedteFocusNode = FocusNode();
  final FocusNode _hoogteFocusNode = FocusNode();
  final FocusNode _actieveVrijeOffsetFocusNode = FocusNode();

  OpmetingKaderZijde _nieuweKaderZijde = OpmetingKaderZijde.rechts;
  OpmetingKaderUitlijning _nieuweKaderUitlijning =
      OpmetingKaderUitlijning.begin;

  String? _laatsteActiefKaderId;
  String? _foutmelding;

  @override
  void initState() {
    super.initState();

    _open = widget.initieelOpen;
    _synchroniseerActiefKader(forceer: true);
  }

  @override
  void didUpdateWidget(covariant OpmetingKaderSamenstellingPaneel oldWidget) {
    super.didUpdateWidget(oldWidget);

    _synchroniseerActiefKader();
  }

  @override
  void dispose() {
    _naamController.dispose();
    _breedteController.dispose();
    _hoogteController.dispose();
    _actieveVrijeOffsetController.dispose();

    _nieuwBreedteController.dispose();
    _nieuwHoogteController.dispose();
    _nieuwVrijeOffsetController.dispose();

    _naamFocusNode.dispose();
    _breedteFocusNode.dispose();
    _hoogteFocusNode.dispose();
    _actieveVrijeOffsetFocusNode.dispose();

    super.dispose();
  }

  OpmetingKaderDeel? get _actiefKader {
    return widget.samenstelling.actiefKader;
  }

  void _synchroniseerActiefKader({bool forceer = false}) {
    final actiefKader = _actiefKader;

    if (actiefKader == null) {
      _laatsteActiefKaderId = null;
      return;
    }

    final actiefKaderGewijzigd = _laatsteActiefKaderId != actiefKader.id;

    if (forceer || actiefKaderGewijzigd || !_naamFocusNode.hasFocus) {
      _naamController.text = actiefKader.naam;
    }

    if (forceer || actiefKaderGewijzigd || !_breedteFocusNode.hasFocus) {
      _breedteController.text = actiefKader.breedteMm.toString();
    }

    if (forceer || actiefKaderGewijzigd || !_hoogteFocusNode.hasFocus) {
      _hoogteController.text = actiefKader.hoogteMm.toString();
    }

    if (forceer ||
        actiefKaderGewijzigd ||
        !_actieveVrijeOffsetFocusNode.hasFocus) {
      _actieveVrijeOffsetController.text = actiefKader.vrijeOffsetMm.toString();
    }

    _laatsteActiefKaderId = actiefKader.id;
  }

  @override
  Widget build(BuildContext context) {
    final layout = OpmetingKaderSamenstellingLayoutHelper.bereken(
      kaders: widget.samenstelling.kaders,
    );

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: rand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _bouwKop(layout),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState: _open
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  _bouwKaderSelectie(),
                  const SizedBox(height: 10),
                  _bouwActiefKaderFormulier(context),
                  const SizedBox(height: 10),
                  _bouwNieuwKaderMenu(),
                  if (_foutmelding != null) ...[
                    const SizedBox(height: 10),
                    _bouwFoutmelding(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwKop(OpmetingKaderSamenstellingLayoutResultaat layout) {
    final aantalKaders = widget.samenstelling.kaders.length;
    final actiefKader = _actiefKader;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() {
          _open = !_open;
        });
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 9, 8, 9),
        child: Row(
          children: [
            Icon(
              _open ? Icons.expand_less : Icons.expand_more,
              color: groen,
              size: 22,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kadersamenstelling',
                    style: TextStyle(
                      color: tekstDonker,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$aantalKaders kader(s) · '
                    '${layout.breedteMm} × ${layout.hoogteMm} mm',
                    style: const TextStyle(
                      color: tekstGrijs,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (actiefKader != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Actief: ${actiefKader.naam}',
                      style: const TextStyle(
                        color: groen,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: lichtGroen,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFB7E3C6)),
              ),
              child: Text(
                _open ? 'Open' : 'Gesloten',
                style: const TextStyle(
                  color: groen,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bouwKaderSelectie() {
    if (widget.samenstelling.kaders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFCD34D)),
        ),
        child: const Text(
          'Er zijn nog geen kaders.',
          style: TextStyle(
            color: Color(0xFF92400E),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: rand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Kader selecteren',
            style: TextStyle(
              color: tekstDonker,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Klik op een kader hieronder. Technische keuzes worden aan het actieve kader gekoppeld.',
            style: TextStyle(
              color: tekstGrijs,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: widget.samenstelling.kaders.map((kader) {
              final geselecteerd =
                  kader.id == widget.samenstelling.actiefKaderId;

              return ChoiceChip(
                label: Text(
                  '${kader.naam} · ${kader.breedteMm}×${kader.hoogteMm}',
                  overflow: TextOverflow.ellipsis,
                ),
                selected: geselecteerd,
                onSelected: (_) {
                  _selecteerKader(kader.id);
                },
                selectedColor: lichtGroen,
                labelStyle: TextStyle(
                  color: geselecteerd ? groen : tekstDonker,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
                side: BorderSide(color: geselecteerd ? groen : rand),
                avatar: Icon(
                  geselecteerd
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 17,
                  color: geselecteerd ? groen : tekstGrijs,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _bouwActiefKaderFormulier(BuildContext context) {
    final actiefKader = _actiefKader;

    if (actiefKader == null) {
      return const SizedBox.shrink();
    }

    final isBasis = actiefKader.isBasisKader;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: rand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.crop_square, size: 18, color: groen),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Actief kader: ${actiefKader.naam}',
                  style: const TextStyle(
                    color: tekstDonker,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          TextField(
            controller: _naamController,
            focusNode: _naamFocusNode,
            enabled: widget.bewerkenToegestaan,
            decoration: const InputDecoration(
              labelText: 'Naam kader',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onSubmitted: (_) {
              _bewaarActiefKader();
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _breedteController,
                  focusNode: _breedteFocusNode,
                  enabled: widget.bewerkenToegestaan,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Breedte kader',
                    suffixText: 'mm',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) {
                    _bewaarActiefKader();
                  },
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: TextField(
                  controller: _hoogteController,
                  focusNode: _hoogteFocusNode,
                  enabled: widget.bewerkenToegestaan,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Hoogte kader',
                    suffixText: 'mm',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) {
                    _bewaarActiefKader();
                  },
                ),
              ),
            ],
          ),
          if (!isBasis) ...[
            const SizedBox(height: 10),
            const Text(
              'Koppeling van actief kader',
              style: TextStyle(
                color: tekstDonker,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            _bouwZijdeKeuzes(
              huidigeZijde:
                  actiefKader.gekoppeldeZijde ?? OpmetingKaderZijde.rechts,
              onGewijzigd: (zijde) {
                _pasActiefKaderAan(gekoppeldeZijde: zijde);
              },
            ),
            const SizedBox(height: 8),
            _bouwUitlijningKeuzes(
              zijde: actiefKader.gekoppeldeZijde ?? OpmetingKaderZijde.rechts,
              huidigeUitlijning: actiefKader.uitlijning,
              onGewijzigd: (uitlijning) {
                _pasActiefKaderAan(uitlijning: uitlijning);
              },
            ),
            if (actiefKader.uitlijning == OpmetingKaderUitlijning.vrij) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _actieveVrijeOffsetController,
                focusNode: _actieveVrijeOffsetFocusNode,
                enabled: widget.bewerkenToegestaan,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: _vrijeOffsetLabelVoorZijde(
                    actiefKader.gekoppeldeZijde ?? OpmetingKaderZijde.rechts,
                  ),
                  suffixText: 'mm',
                  helperText: 'Negatieve waarden zijn toegestaan.',
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) {
                  _bewaarActiefKader();
                },
              ),
            ],
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: groen,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: widget.bewerkenToegestaan
                      ? _bewaarActiefKader
                      : null,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Kader bewaren'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                tooltip: 'Actief kader verwijderen',
                onPressed: widget.bewerkenToegestaan
                    ? () {
                        _verwijderActiefKader(context);
                      }
                    : null,
                color: const Color(0xFFDC2626),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bouwNieuwKaderMenu() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: lichtGroen,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFB7E3C6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Extra kader toevoegen',
            style: TextStyle(
              color: Color(0xFF064E3B),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Kies waar het nieuwe kader moet komen. '
            'Er wordt standaard een kader van 300 × 300 mm toegevoegd. '
            'De maten kun je meteen aanpassen.',
            style: TextStyle(
              color: Color(0xFF065F46),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          _bouwZijdeKeuzes(
            huidigeZijde: _nieuweKaderZijde,
            onGewijzigd: (zijde) {
              setState(() {
                _nieuweKaderZijde = zijde;
                _foutmelding = null;
              });
            },
          ),
          const SizedBox(height: 8),
          _bouwUitlijningKeuzes(
            zijde: _nieuweKaderZijde,
            huidigeUitlijning: _nieuweKaderUitlijning,
            onGewijzigd: (uitlijning) {
              setState(() {
                _nieuweKaderUitlijning = uitlijning;
                _foutmelding = null;
              });
            },
          ),
          if (_nieuweKaderUitlijning == OpmetingKaderUitlijning.vrij) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _nieuwVrijeOffsetController,
              enabled: widget.bewerkenToegestaan,
              keyboardType: const TextInputType.numberWithOptions(
                signed: true,
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: _vrijeOffsetLabelVoorZijde(_nieuweKaderZijde),
                suffixText: 'mm',
                helperText: 'Negatieve waarden zijn toegestaan.',
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nieuwBreedteController,
                  enabled: widget.bewerkenToegestaan,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Breedte nieuw kader',
                    suffixText: 'mm',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: TextField(
                  controller: _nieuwHoogteController,
                  enabled: widget.bewerkenToegestaan,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Hoogte nieuw kader',
                    suffixText: 'mm',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: groen,
              foregroundColor: Colors.white,
            ),
            onPressed: widget.bewerkenToegestaan ? _voegKaderToe : null,
            icon: const Icon(Icons.add_box_outlined, size: 18),
            label: const Text('Kader toevoegen'),
          ),
        ],
      ),
    );
  }

  Widget _bouwZijdeKeuzes({
    required OpmetingKaderZijde huidigeZijde,
    required ValueChanged<OpmetingKaderZijde> onGewijzigd,
  }) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: OpmetingKaderZijde.values.map((zijde) {
        final geselecteerd = zijde == huidigeZijde;

        return ChoiceChip(
          label: Text(zijde.label),
          selected: geselecteerd,
          onSelected: widget.bewerkenToegestaan
              ? (_) {
                  onGewijzigd(zijde);
                }
              : null,
          selectedColor: lichtGroen,
          labelStyle: TextStyle(
            color: geselecteerd ? groen : tekstDonker,
            fontWeight: FontWeight.w700,
          ),
          side: BorderSide(color: geselecteerd ? groen : rand),
        );
      }).toList(),
    );
  }

  Widget _bouwUitlijningKeuzes({
    required OpmetingKaderZijde zijde,
    required OpmetingKaderUitlijning huidigeUitlijning,
    required ValueChanged<OpmetingKaderUitlijning> onGewijzigd,
  }) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: OpmetingKaderUitlijning.values.map((uitlijning) {
        final geselecteerd = uitlijning == huidigeUitlijning;

        return ChoiceChip(
          label: Text(uitlijning.labelVoorZijde(zijde)),
          selected: geselecteerd,
          onSelected: widget.bewerkenToegestaan
              ? (_) {
                  onGewijzigd(uitlijning);
                }
              : null,
          selectedColor: lichtGroen,
          labelStyle: TextStyle(
            color: geselecteerd ? groen : tekstDonker,
            fontWeight: FontWeight.w700,
          ),
          side: BorderSide(color: geselecteerd ? groen : rand),
        );
      }).toList(),
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
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _selecteerKader(String kaderId) {
    if (kaderId.trim().isEmpty) {
      return;
    }

    if (kaderId == widget.samenstelling.actiefKaderId) {
      return;
    }

    widget.onGewijzigd(widget.samenstelling.copyWith(actiefKaderId: kaderId));

    setState(() {
      _open = true;
      _foutmelding = null;
    });
  }

  void _bewaarActiefKader() {
    final naam = _naamController.text.trim();
    final breedteMm = _leesMm(_breedteController.text);
    final hoogteMm = _leesMm(_hoogteController.text);
    final vrijeOffsetMm = _leesMm(_actieveVrijeOffsetController.text);

    if (naam.isEmpty) {
      setState(() {
        _foutmelding = 'Vul een naam in voor het actieve kader.';
      });

      return;
    }

    if (breedteMm == null || breedteMm <= 0) {
      setState(() {
        _foutmelding = 'Vul een geldige breedte in voor het actieve kader.';
      });

      return;
    }

    if (hoogteMm == null || hoogteMm <= 0) {
      setState(() {
        _foutmelding = 'Vul een geldige hoogte in voor het actieve kader.';
      });

      return;
    }

    if (vrijeOffsetMm == null) {
      setState(() {
        _foutmelding = 'Vul een geldige vrije positie in.';
      });

      return;
    }

    _pasActiefKaderAan(
      naam: naam,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      vrijeOffsetMm: vrijeOffsetMm,
    );
  }

  void _pasActiefKaderAan({
    String? naam,
    int? breedteMm,
    int? hoogteMm,
    OpmetingKaderZijde? gekoppeldeZijde,
    OpmetingKaderUitlijning? uitlijning,
    int? vrijeOffsetMm,
  }) {
    final actiefKader = _actiefKader;

    if (actiefKader == null) {
      return;
    }

    final nieuweKaders = widget.samenstelling.kaders.map((kader) {
      if (kader.id != actiefKader.id) {
        return kader;
      }

      return kader.copyWith(
        naam: naam ?? kader.naam,
        breedteMm: breedteMm ?? kader.breedteMm,
        hoogteMm: hoogteMm ?? kader.hoogteMm,
        gekoppeldeZijde: gekoppeldeZijde ?? kader.gekoppeldeZijde,
        uitlijning: uitlijning ?? kader.uitlijning,
        vrijeOffsetMm: vrijeOffsetMm ?? kader.vrijeOffsetMm,
      );
    }).toList();

    final herberekendeKaders =
        OpmetingKaderSamenstellingLayoutHelper.herberekenGekoppeldeKaders(
          kaders: nieuweKaders,
        );

    widget.onGewijzigd(
      widget.samenstelling.copyWith(
        kaders: herberekendeKaders,
        actiefKaderId: actiefKader.id,
      ),
    );

    setState(() {
      _foutmelding = null;
    });
  }

  void _voegKaderToe() {
    final actiefKader = _actiefKader;

    if (actiefKader == null) {
      setState(() {
        _foutmelding = 'Er is geen actief kader gekozen.';
      });

      return;
    }

    final breedteMm = _leesMm(_nieuwBreedteController.text);
    final hoogteMm = _leesMm(_nieuwHoogteController.text);

    if (breedteMm == null || breedteMm <= 0) {
      setState(() {
        _foutmelding = 'Vul een geldige breedte in voor het nieuwe kader.';
      });

      return;
    }

    if (hoogteMm == null || hoogteMm <= 0) {
      setState(() {
        _foutmelding = 'Vul een geldige hoogte in voor het nieuwe kader.';
      });

      return;
    }

    var vrijeOffsetMm = 0;

    if (_nieuweKaderUitlijning == OpmetingKaderUitlijning.vrij) {
      final offset = _leesMm(_nieuwVrijeOffsetController.text);

      if (offset == null) {
        setState(() {
          _foutmelding = 'Vul een geldige vrije positie in.';
        });

        return;
      }

      vrijeOffsetMm = offset;
    }

    final nieuwKaderId = 'kader_${DateTime.now().microsecondsSinceEpoch}';

    final nieuwKader = OpmetingKaderDeel(
      id: nieuwKaderId,
      naam: 'Kader ${widget.samenstelling.kaders.length + 1}',
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    final nieuweKaders = OpmetingKaderSamenstellingLayoutHelper.voegKaderToe(
      bestaandeKaders: widget.samenstelling.kaders,
      nieuwKader: nieuwKader,
      gekoppeldAanKaderId: actiefKader.id,
      zijde: _nieuweKaderZijde,
      uitlijning: _nieuweKaderUitlijning,
      vrijeOffsetMm: vrijeOffsetMm,
    );

    widget.onGewijzigd(
      widget.samenstelling.copyWith(
        kaders: nieuweKaders,
        actiefKaderId: nieuwKaderId,
      ),
    );

    setState(() {
      _open = true;
      _foutmelding = null;
    });
  }

  Future<void> _verwijderActiefKader(BuildContext context) async {
    final actiefKader = _actiefKader;

    if (actiefKader == null) {
      return;
    }

    if (widget.samenstelling.kaders.length <= 1) {
      setState(() {
        _foutmelding = 'Er moet minstens één kader behouden blijven.';
      });

      return;
    }

    final meeTeVerwijderenIds = _zoekAfhankelijkeKaders(
      teVerwijderenKaderId: actiefKader.id,
    );

    final aantalMeeTeVerwijderen = meeTeVerwijderenIds.length - 1;

    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Kader verwijderen?'),
          content: Text(
            aantalMeeTeVerwijderen > 0
                ? 'Het kader “${actiefKader.naam}” wordt verwijderd.\n\n'
                      'Er zijn ook $aantalMeeTeVerwijderen gekoppelde '
                      'kader(s) die aan dit kader vasthangen. '
                      'Deze worden mee verwijderd.'
                : 'Het kader “${actiefKader.naam}” wordt verwijderd.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Annuleren'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Verwijderen'),
            ),
          ],
        );
      },
    );

    if (bevestigen != true || !context.mounted) {
      return;
    }

    final resterendeKaders = widget.samenstelling.kaders.where((kader) {
      return !meeTeVerwijderenIds.contains(kader.id);
    }).toList();

    if (resterendeKaders.isEmpty) {
      setState(() {
        _foutmelding =
            'Dit kader kan niet verwijderd worden omdat er geen kader overblijft.';
      });

      return;
    }

    final herberekendeKaders =
        OpmetingKaderSamenstellingLayoutHelper.herberekenGekoppeldeKaders(
          kaders: resterendeKaders,
        );

    widget.onGewijzigd(
      widget.samenstelling.copyWith(
        kaders: herberekendeKaders,
        actiefKaderId: herberekendeKaders.first.id,
      ),
    );

    setState(() {
      _foutmelding = null;
    });
  }

  Set<String> _zoekAfhankelijkeKaders({required String teVerwijderenKaderId}) {
    final ids = <String>{teVerwijderenKaderId};

    var gewijzigd = true;

    while (gewijzigd) {
      gewijzigd = false;

      for (final kader in widget.samenstelling.kaders) {
        final gekoppeldAan = kader.gekoppeldAanKaderId ?? '';

        if (gekoppeldAan.isEmpty) {
          continue;
        }

        if (!ids.contains(gekoppeldAan)) {
          continue;
        }

        if (ids.add(kader.id)) {
          gewijzigd = true;
        }
      }
    }

    return ids;
  }

  String _vrijeOffsetLabelVoorZijde(OpmetingKaderZijde zijde) {
    if (zijde == OpmetingKaderZijde.links ||
        zijde == OpmetingKaderZijde.rechts) {
      return 'Afstand vanaf boven';
    }

    return 'Afstand vanaf links';
  }

  int? _leesMm(String tekst) {
    final opgeschoond = tekst.trim().replaceAll(',', '.');

    final getal = double.tryParse(opgeschoond);

    if (getal == null) {
      return null;
    }

    return getal.round();
  }
}
