// THIMACO-CONTROLE: INSTELLINGEN-VOORZETSCREENS-BEDIENINGEN-20260730-2115
import 'package:flutter/material.dart';

import '../../../helpers/app_storage.dart';
import '../../../helpers/opmeting/toebehoren/voorzetscreen/opmeting_voorzetscreen_instellingen_model.dart';

class OpmetingVoorzetscreenInstellingenPagina extends StatefulWidget {
  const OpmetingVoorzetscreenInstellingenPagina({super.key});

  @override
  State<OpmetingVoorzetscreenInstellingenPagina> createState() {
    return _OpmetingVoorzetscreenInstellingenPaginaState();
  }
}

class _OpmetingVoorzetscreenInstellingenPaginaState
    extends State<OpmetingVoorzetscreenInstellingenPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekst = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  final TextEditingController _poederController = TextEditingController();
  final TextEditingController _doekenController = TextEditingController();
  final TextEditingController _motorenController = TextEditingController();
  final TextEditingController _zonnecelMotorenController =
      TextEditingController();
  final TextEditingController _bedieningenController = TextEditingController();

  bool _laden = true;
  bool _bewaren = false;

  @override
  void initState() {
    super.initState();
    for (final controller in _controllers) {
      controller.addListener(_verversVoorbeeld);
    }
    _laad();
  }

  List<TextEditingController> get _controllers => <TextEditingController>[
    _poederController,
    _doekenController,
    _motorenController,
    _zonnecelMotorenController,
    _bedieningenController,
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.removeListener(_verversVoorbeeld);
      controller.dispose();
    }
    super.dispose();
  }

  void _verversVoorbeeld() {
    if (mounted) setState(() {});
  }

  Future<void> _laad() async {
    final instellingen =
        await AppStorage.laadOpmetingVoorzetscreenInstellingen();
    if (!mounted) return;

    _poederController.text = _poederNaarTekst(instellingen.poederkleuren);
    _doekenController.text = _doekenNaarTekst(instellingen.screendoeken);
    _motorenController.text = _motorenNaarTekst(instellingen.motoren);
    _zonnecelMotorenController.text = _motorenNaarTekst(
      instellingen.zonnecelMotoren,
    );
    _bedieningenController.text = instellingen.bedieningen.join('\n');

    setState(() => _laden = false);
  }

  void _laadStandaardlijsten() {
    _poederController.text = _poederNaarTekst(
      OpmetingVoorzetscreenInstellingen.standaardPoederkleuren,
    );
    _doekenController.text = _doekenNaarTekst(
      OpmetingVoorzetscreenInstellingen.standaardScreendoeken,
    );
    _motorenController.text = _motorenNaarTekst(
      OpmetingVoorzetscreenInstellingen.standaardMotoren,
    );
    _zonnecelMotorenController.text = _motorenNaarTekst(
      OpmetingVoorzetscreenInstellingen.standaardZonnecelMotoren,
    );
    _bedieningenController.text = OpmetingVoorzetscreenInstellingen
        .standaardBedieningen
        .join('\n');
  }

  String _poederNaarTekst(Iterable<OpmetingVoorzetscreenPoederkleur> kleuren) {
    return kleuren
        .map(
          (kleur) => <String>[
            kleur.benaming,
            kleur.poedercode,
            kleur.poederlakMogelijk ? 'x' : '-',
            kleur.natlakMogelijk ? 'x' : '-',
          ].join('\t'),
        )
        .join('\n');
  }

  String _doekenNaarTekst(Iterable<OpmetingVoorzetscreenDoek> doeken) {
    return doeken.map((doek) => '${doek.code}\t${doek.kleur}').join('\n');
  }

  String _motorenNaarTekst(Iterable<OpmetingVoorzetscreenMotor> motoren) {
    return motoren
        .map(
          (motor) =>
              <String>[motor.type, motor.merk, motor.omschrijving].join('\t'),
        )
        .join('\n');
  }

  List<String> _nietLegeRegels(String tekst) {
    return tekst
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .map((regel) => regel.trim())
        .where((regel) => regel.isNotEmpty)
        .toList(growable: false);
  }

  List<String> _parseBedieningen() {
    final resultaat = <String>[];
    final gebruikt = <String>{};
    final delen = _bedieningenController.text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split(RegExp(r'[\n;\t]+'));

    for (final deel in delen) {
      final waarde = deel.trim();
      if (waarde.isEmpty || !gebruikt.add(waarde.toLowerCase())) continue;
      resultaat.add(waarde);
    }
    return List<String>.unmodifiable(resultaat);
  }

  List<String> _kolommen(String regel) {
    return regel
        .split(RegExp(r'[\t;]+'))
        .map((deel) => deel.trim())
        .where((deel) => deel.isNotEmpty)
        .toList(growable: false);
  }

  bool _isKoptekst(String waarde) {
    final klein = waarde.trim().toLowerCase();
    return klein == 'code' ||
        klein == 'benaming' ||
        klein == 'kleur' ||
        klein == 'colour' ||
        klein == 'type' ||
        klein == 'merk' ||
        klein == 'description' ||
        klein == 'omschrijving';
  }

  bool _isMogelijk(String waarde) {
    final klein = waarde.trim().toLowerCase();
    return klein == 'x' || klein == 'ja' || klein == 'yes' || klein == '1';
  }

  List<OpmetingVoorzetscreenPoederkleur> _parsePoederkleuren() {
    final regels = _nietLegeRegels(_poederController.text);
    final resultaat = <OpmetingVoorzetscreenPoederkleur>[];
    final gebruikt = <String>{};
    final losseWaarden = <String>[];

    void voegToe(List<String> waarden) {
      if (waarden.length < 4 || _isKoptekst(waarden.first)) return;
      final kleur = OpmetingVoorzetscreenPoederkleur(
        benaming: waarden[0],
        poedercode: waarden[1],
        poederlakMogelijk: _isMogelijk(waarden[2]),
        natlakMogelijk: _isMogelijk(waarden[3]),
      );
      if (kleur.benaming.trim().isNotEmpty && gebruikt.add(kleur.id)) {
        resultaat.add(kleur);
      }
    }

    for (final regel in regels) {
      final waarden = _kolommen(regel);
      if (waarden.length >= 4) {
        voegToe(waarden);
      } else {
        losseWaarden.addAll(waarden);
      }
    }

    for (var index = 0; index + 3 < losseWaarden.length; index += 4) {
      voegToe(losseWaarden.sublist(index, index + 4));
    }
    return List<OpmetingVoorzetscreenPoederkleur>.unmodifiable(resultaat);
  }

  List<OpmetingVoorzetscreenDoek> _parseDoeken() {
    final regels = _nietLegeRegels(_doekenController.text);
    final resultaat = <OpmetingVoorzetscreenDoek>[];
    final gebruikt = <String>{};
    final losseWaarden = <String>[];

    void voegToe(String code, String kleur) {
      final schoonCode = code.trim().toUpperCase();
      if (schoonCode.isEmpty || _isKoptekst(schoonCode)) return;
      final hex = OpmetingVoorzetscreenDoek.standaardKleurenVoorCode(
        schoonCode,
      );
      final doek = OpmetingVoorzetscreenDoek(
        code: schoonCode,
        kleur: kleur.trim(),
        voorzijdeHex: hex.$1,
        achterzijdeHex: hex.$2,
      );
      if (gebruikt.add(doek.id)) resultaat.add(doek);
    }

    for (final regel in regels) {
      final waarden = _kolommen(regel);
      if (waarden.length >= 2) {
        voegToe(waarden[0], waarden[1]);
      } else {
        losseWaarden.addAll(waarden);
      }
    }

    for (var index = 0; index + 1 < losseWaarden.length; index += 2) {
      voegToe(losseWaarden[index], losseWaarden[index + 1]);
    }
    return List<OpmetingVoorzetscreenDoek>.unmodifiable(resultaat);
  }

  List<OpmetingVoorzetscreenMotor> _parseMotoren(
    TextEditingController controller,
  ) {
    final regels = _nietLegeRegels(controller.text);
    final resultaat = <OpmetingVoorzetscreenMotor>[];
    final gebruikt = <String>{};
    final losseWaarden = <String>[];

    void voegToe(List<String> waarden) {
      if (waarden.length < 3 || _isKoptekst(waarden.first)) return;
      final motor = OpmetingVoorzetscreenMotor(
        type: waarden[0].trim(),
        merk: waarden[1].trim().toUpperCase(),
        omschrijving: OpmetingVoorzetscreenMotor.schoonOmschrijving(
          waarden.sublist(2).join(' '),
        ),
      );
      if (motor.omschrijving.isNotEmpty && gebruikt.add(motor.id)) {
        resultaat.add(motor);
      }
    }

    for (final regel in regels) {
      final waarden = _kolommen(regel);
      if (waarden.length >= 3) {
        voegToe(waarden);
      } else {
        losseWaarden.addAll(waarden);
      }
    }

    for (var index = 0; index + 2 < losseWaarden.length; index += 3) {
      voegToe(losseWaarden.sublist(index, index + 3));
    }
    return List<OpmetingVoorzetscreenMotor>.unmodifiable(resultaat);
  }

  Future<void> _bewaar() async {
    if (_bewaren) return;
    setState(() => _bewaren = true);

    try {
      final instellingen = OpmetingVoorzetscreenInstellingen(
        poederkleuren: _parsePoederkleuren(),
        screendoeken: _parseDoeken(),
        motoren: _parseMotoren(_motorenController),
        zonnecelMotoren: _parseMotoren(_zonnecelMotorenController),
        bedieningen: _parseBedieningen(),
      ).metWijzigingsDatum();

      await AppStorage.bewaarOpmetingVoorzetscreenInstellingen(instellingen);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Voorzetscreens bewaard: '
            '${instellingen.poederkleuren.length} poederkleuren, '
            '${instellingen.screendoeken.length} doeken, '
            '${instellingen.motoren.length} motoren en '
            '${instellingen.zonnecelMotoren.length} zonnecelmotoren en '
            '${instellingen.bedieningen.length} bedieningen.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _bewaren = false);
    }
  }

  void _verwijderPoeder(OpmetingVoorzetscreenPoederkleur kleur) {
    _poederController.text = _poederNaarTekst(
      _parsePoederkleuren().where((item) => item.id != kleur.id),
    );
  }

  void _verwijderDoek(OpmetingVoorzetscreenDoek doek) {
    _doekenController.text = _doekenNaarTekst(
      _parseDoeken().where((item) => item.id != doek.id),
    );
  }

  void _verwijderMotor(
    TextEditingController controller,
    OpmetingVoorzetscreenMotor motor,
  ) {
    controller.text = _motorenNaarTekst(
      _parseMotoren(controller).where((item) => item.id != motor.id),
    );
  }

  void _verwijderBediening(String bediening) {
    _bedieningenController.text = _parseBedieningen()
        .where((item) => item.toLowerCase() != bediening.toLowerCase())
        .join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final poederkleuren = _laden
        ? const <OpmetingVoorzetscreenPoederkleur>[]
        : _parsePoederkleuren();
    final doeken = _laden
        ? const <OpmetingVoorzetscreenDoek>[]
        : _parseDoeken();
    final motoren = _laden
        ? const <OpmetingVoorzetscreenMotor>[]
        : _parseMotoren(_motorenController);
    final zonnecelMotoren = _laden
        ? const <OpmetingVoorzetscreenMotor>[]
        : _parseMotoren(_zonnecelMotorenController);
    final bedieningen = _laden ? const <String>[] : _parseBedieningen();

    return Scaffold(
      backgroundColor: _achtergrond,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _tekst,
        elevation: 0,
        title: const Text(
          'Instellingen Voorzetscreens',
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
                  'Plak tabellen uit Excel of Word. Gebruik één rij per item. '
                  'Tabs en puntkomma’s worden verwerkt. Motorwaarden zoals '
                  '2/7, 2/10 en 10/12 worden automatisch uit de omschrijving verwijderd.',
                  style: TextStyle(
                    color: _tekstGrijs,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: _laadStandaardlijsten,
                    icon: const Icon(
                      Icons.playlist_add_check_rounded,
                      size: 18,
                    ),
                    label: const Text('Standaardlijsten laden'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _groen,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFCDEBD6)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _PlakTabelKaart(
                  titel: 'Poederkleuren',
                  uitleg: 'Benaming · poedercode · poederlak x/- · natlak x/-.',
                  hint: 'Antracietgrijs Rolluiken\t317032213\tx\tx',
                  controller: _poederController,
                  aantalTekst: '${poederkleuren.length} kleuren',
                  rijen: poederkleuren
                      .map(
                        (kleur) => _VoorbeeldRij(
                          kolommen: <String>[
                            kleur.benaming,
                            kleur.poedercode,
                            kleur.poederlakMogelijk ? 'x' : '-',
                            kleur.natlakMogelijk ? 'x' : '-',
                          ],
                          onVerwijderen: () => _verwijderPoeder(kleur),
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: 14),
                _PlakTabelKaart(
                  titel: 'Screendoeken',
                  uitleg: 'Doekcode · kleuromschrijving.',
                  hint: 'SC0202\tWhite',
                  controller: _doekenController,
                  aantalTekst: '${doeken.length} doeken',
                  rijen: doeken
                      .map(
                        (doek) => _VoorbeeldRij(
                          kolommen: <String>[doek.code, doek.kleur],
                          onVerwijderen: () => _verwijderDoek(doek),
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: 14),
                _PlakTabelKaart(
                  titel: 'Motoren',
                  uitleg: 'Type · merk · omschrijving.',
                  hint: 'Bekabeld\tSOMFY\tAltea ZIP 50 WT',
                  controller: _motorenController,
                  aantalTekst: '${motoren.length} motoren',
                  rijen: motoren
                      .map(
                        (motor) => _VoorbeeldRij(
                          kolommen: <String>[
                            motor.type,
                            motor.merk,
                            motor.omschrijving,
                          ],
                          onVerwijderen: () =>
                              _verwijderMotor(_motorenController, motor),
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: 14),
                _PlakTabelKaart(
                  titel: 'Motoren met zonnecel',
                  uitleg: 'Type · merk · omschrijving.',
                  hint: 'Draadloos\tBREL\tBrel Solaris 35mm BLE35-13SHU (13Nm)',
                  controller: _zonnecelMotorenController,
                  aantalTekst: '${zonnecelMotoren.length} motoren',
                  rijen: zonnecelMotoren
                      .map(
                        (motor) => _VoorbeeldRij(
                          kolommen: <String>[
                            motor.type,
                            motor.merk,
                            motor.omschrijving,
                          ],
                          onVerwijderen: () => _verwijderMotor(
                            _zonnecelMotorenController,
                            motor,
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: 14),
                _PlakTabelKaart(
                  titel: 'Bediening',
                  uitleg:
                      'Eén bediening per regel. Deze keuzes verschijnen als radioknoppen op de opmeetfiche.',
                  hint: 'Inbouwschakelaar',
                  controller: _bedieningenController,
                  aantalTekst: '${bedieningen.length} bedieningen',
                  rijen: bedieningen
                      .map(
                        (bediening) => _VoorbeeldRij(
                          kolommen: <String>[bediening],
                          onVerwijderen: () => _verwijderBediening(bediening),
                        ),
                      )
                      .toList(growable: false),
                ),
              ],
            ),
    );
  }
}

class _VoorbeeldRij {
  const _VoorbeeldRij({required this.kolommen, required this.onVerwijderen});

  final List<String> kolommen;
  final VoidCallback onVerwijderen;
}

class _PlakTabelKaart extends StatefulWidget {
  const _PlakTabelKaart({
    required this.titel,
    required this.uitleg,
    required this.hint,
    required this.controller,
    required this.aantalTekst,
    required this.rijen,
  });

  final String titel;
  final String uitleg;
  final String hint;
  final TextEditingController controller;
  final String aantalTekst;
  final List<_VoorbeeldRij> rijen;

  @override
  State<_PlakTabelKaart> createState() => _PlakTabelKaartState();
}

class _PlakTabelKaartState extends State<_PlakTabelKaart> {
  final ScrollController _rijenScrollController = ScrollController();

  @override
  void dispose() {
    _rijenScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rijen = widget.rijen;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _OpmetingVoorzetscreenInstellingenPaginaState._rand,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.titel,
                  style: const TextStyle(
                    color: _OpmetingVoorzetscreenInstellingenPaginaState._tekst,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                widget.aantalTekst,
                style: const TextStyle(
                  color: _OpmetingVoorzetscreenInstellingenPaginaState._groen,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.uitleg,
            style: const TextStyle(
              color: _OpmetingVoorzetscreenInstellingenPaginaState._tekstGrijs,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: widget.controller,
            minLines: 6,
            maxLines: 14,
            decoration: InputDecoration(
              hintText: widget.hint,
              filled: true,
              fillColor: const Color(0xFFFCFCFD),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: _OpmetingVoorzetscreenInstellingenPaginaState._rand,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: _OpmetingVoorzetscreenInstellingenPaginaState._groen,
                  width: 1.5,
                ),
              ),
            ),
          ),
          if (rijen.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'Opgeslagen regels',
                    style: TextStyle(
                      color:
                          _OpmetingVoorzetscreenInstellingenPaginaState._tekst,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  'Scroll door alle ${rijen.length} regels',
                  style: const TextStyle(
                    color: _OpmetingVoorzetscreenInstellingenPaginaState
                        ._tekstGrijs,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Container(
              height: 290,
              decoration: BoxDecoration(
                color: const Color(0xFFFCFCFD),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _OpmetingVoorzetscreenInstellingenPaginaState._rand,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Scrollbar(
                controller: _rijenScrollController,
                thumbVisibility: true,
                trackVisibility: true,
                child: ListView.separated(
                  controller: _rijenScrollController,
                  primary: false,
                  padding: const EdgeInsets.fromLTRB(7, 7, 11, 7),
                  itemCount: rijen.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 5),
                  itemBuilder: (context, index) {
                    final rij = rijen[index];
                    return Container(
                      padding: const EdgeInsets.fromLTRB(9, 5, 3, 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAF9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _OpmetingVoorzetscreenInstellingenPaginaState
                              ._rand,
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              rij.kolommen.join(' · '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11.5),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Regel verwijderen',
                            visualDensity: VisualDensity.compact,
                            onPressed: rij.onVerwijderen,
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
