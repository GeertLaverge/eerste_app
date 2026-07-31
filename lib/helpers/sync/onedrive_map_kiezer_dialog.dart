// THIMACO-CONTROLE: ONEDRIVE-MAP-KIEZER-KLANTEN-20260731
import 'package:flutter/material.dart';

import 'onedrive_klantdocument_service.dart';

class OneDriveMapKiezerDialog extends StatefulWidget {
  const OneDriveMapKiezerDialog({
    super.key,
    required this.service,
    required this.klantNaam,
    required this.klantnummer,
  });

  final OneDriveKlantdocumentService service;
  final String klantNaam;
  final String klantnummer;

  static Future<OneDriveGekozenMap?> toon({
    required BuildContext context,
    required OneDriveKlantdocumentService service,
    required String klantNaam,
    required String klantnummer,
  }) {
    return showDialog<OneDriveGekozenMap>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return OneDriveMapKiezerDialog(
          service: service,
          klantNaam: klantNaam,
          klantnummer: klantnummer,
        );
      },
    );
  }

  @override
  State<OneDriveMapKiezerDialog> createState() {
    return _OneDriveMapKiezerDialogState();
  }
}

class _OneDriveMapKiezerDialogState extends State<OneDriveMapKiezerDialog> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  final TextEditingController _zoekController = TextEditingController();
  final List<_OneDrivePadStap> _pad = <_OneDrivePadStap>[
    const _OneDrivePadStap(id: null, naam: 'OneDrive'),
  ];

  List<OneDriveMapItem> _mappen = <OneDriveMapItem>[];
  bool _laden = true;
  String _fout = '';
  int _laadVersie = 0;

  @override
  void initState() {
    super.initState();
    _laadHuidigeMap();
  }

  @override
  void dispose() {
    _zoekController.dispose();
    super.dispose();
  }

  _OneDrivePadStap get _huidigeStap => _pad.last;

  String get _huidigePad => _pad.map((stap) => stap.naam).join(' / ');

  List<OneDriveMapItem> get _gefilterdeMappen {
    final zoekterm = _zoekController.text.trim().toLowerCase();
    if (zoekterm.isEmpty) return _mappen;

    return _mappen
        .where((map) => map.naam.toLowerCase().contains(zoekterm))
        .toList(growable: false);
  }

  Future<void> _laadHuidigeMap() async {
    final versie = ++_laadVersie;

    setState(() {
      _laden = true;
      _fout = '';
      _mappen = <OneDriveMapItem>[];
    });

    try {
      final mappen = await widget.service.laadMappen(
        bovenliggendeMapId: _huidigeStap.id,
      );

      if (!mounted || versie != _laadVersie) return;

      setState(() {
        _mappen = mappen;
        _laden = false;
      });
    } on OneDriveKlantdocumentException catch (fout) {
      if (!mounted || versie != _laadVersie) return;

      setState(() {
        _laden = false;
        _fout = fout.bericht;
      });
    } catch (fout) {
      if (!mounted || versie != _laadVersie) return;

      setState(() {
        _laden = false;
        _fout = 'De OneDrive-map kon niet worden geopend.\n$fout';
      });
    }
  }

  Future<void> _openMap(OneDriveMapItem map) async {
    FocusScope.of(context).unfocus();
    _zoekController.clear();
    _pad.add(_OneDrivePadStap(id: map.id, naam: map.naam));
    await _laadHuidigeMap();
  }

  Future<void> _gaNaarPadIndex(int index) async {
    if (index < 0 || index >= _pad.length - 1) return;

    FocusScope.of(context).unfocus();
    _zoekController.clear();
    _pad.removeRange(index + 1, _pad.length);
    await _laadHuidigeMap();
  }

  Future<void> _gaEenMapTerug() async {
    if (_pad.length <= 1) return;

    FocusScope.of(context).unfocus();
    _zoekController.clear();
    _pad.removeLast();
    await _laadHuidigeMap();
  }

  void _kiesHuidigeMap() {
    final mapId = _huidigeStap.id;
    if (mapId == null || mapId.isEmpty) return;

    final mapPad = _pad.skip(1).map((stap) => stap.naam).join('/');
    Navigator.of(context).pop(OneDriveGekozenMap(id: mapId, pad: mapPad));
  }

  @override
  Widget build(BuildContext context) {
    final klantInfo = <String>[
      if (widget.klantnummer.trim().isNotEmpty) widget.klantnummer.trim(),
      if (widget.klantNaam.trim().isNotEmpty) widget.klantNaam.trim(),
    ].join(' · ');

    return Dialog(
      insetPadding: const EdgeInsets.all(18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 680),
        child: Column(
          children: <Widget>[
            _bouwKop(klantInfo),
            const Divider(height: 1, color: _rand),
            _bouwNavigatie(),
            const Divider(height: 1, color: _rand),
            Expanded(child: _bouwInhoud()),
            const Divider(height: 1, color: _rand),
            _bouwOnderbalk(),
          ],
        ),
      ),
    );
  }

  Widget _bouwKop(String klantInfo) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F6EC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.cloud_outlined, color: _groen),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Opslaan naar OneDrive klanten',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  klantInfo.isEmpty ? 'Klant niet ingevuld' : klantInfo,
                  style: const TextStyle(
                    color: _tekstGrijs,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Open Klanten, kies de bestaande klant en daarna de gewenste bestaande submap.',
                  style: TextStyle(color: _tekstGrijs, fontSize: 11.5),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Annuleren',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _bouwNavigatie() {
    return Container(
      color: _achtergrond,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;

          final broodkruimel = Row(
            children: <Widget>[
              IconButton(
                tooltip: 'Een map terug',
                onPressed: _pad.length > 1 && !_laden ? _gaEenMapTerug : null,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Row(
                    children: <Widget>[
                      for (var index = 0; index < _pad.length; index++) ...[
                        if (index > 0)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 3),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: _tekstGrijs,
                            ),
                          ),
                        TextButton(
                          onPressed: index < _pad.length - 1 && !_laden
                              ? () => _gaNaarPadIndex(index)
                              : null,
                          child: Text(
                            _pad[index].naam,
                            style: TextStyle(
                              color: index == _pad.length - 1
                                  ? const Color(0xFF111827)
                                  : _groen,
                              fontWeight: index == _pad.length - 1
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );

          final zoekveld = TextField(
            controller: _zoekController,
            enabled: !_laden,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Zoek in deze map',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _zoekController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Zoekterm wissen',
                      onPressed: () {
                        _zoekController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close_rounded, size: 18),
                    ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _rand),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _rand),
              ),
            ),
          );

          if (compact) {
            return Column(
              children: <Widget>[
                broodkruimel,
                const SizedBox(height: 8),
                zoekveld,
              ],
            );
          }

          return Row(
            children: <Widget>[
              Expanded(child: broodkruimel),
              const SizedBox(width: 12),
              SizedBox(width: 250, child: zoekveld),
            ],
          );
        },
      ),
    );
  }

  Widget _bouwInhoud() {
    if (_laden) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(color: _groen),
            SizedBox(height: 14),
            Text('OneDrive-mappen laden…'),
          ],
        ),
      );
    }

    if (_fout.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.cloud_off_rounded,
                size: 44,
                color: Color(0xFFB91C1C),
              ),
              const SizedBox(height: 12),
              Text(
                _fout,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFB91C1C),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _laadHuidigeMap,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Opnieuw proberen'),
              ),
            ],
          ),
        ),
      );
    }

    final zichtbareMappen = _gefilterdeMappen;

    if (zichtbareMappen.isEmpty) {
      return Center(
        child: Text(
          _zoekController.text.trim().isEmpty
              ? 'Deze map bevat geen submappen.'
              : 'Geen map gevonden voor “${_zoekController.text.trim()}”.',
          style: const TextStyle(color: _tekstGrijs),
        ),
      );
    }

    return Scrollbar(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        itemCount: zichtbareMappen.length,
        separatorBuilder: (_, _) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final map = zichtbareMappen[index];

          return Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
              side: const BorderSide(color: _rand),
            ),
            child: ListTile(
              dense: true,
              leading: const Icon(Icons.folder_rounded, color: _groen),
              title: Text(
                map.naam,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _openMap(map),
            ),
          );
        },
      ),
    );
  }

  Widget _bouwOnderbalk() {
    final kanKiezen = _huidigeStap.id != null && !_laden && _fout.isEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final padTekst = Text(
            _huidigePad,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _tekstGrijs,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          );

          final knoppen = Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuleren'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _groen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),
                ),
                onPressed: kanKiezen ? _kiesHuidigeMap : null,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Deze map kiezen'),
              ),
            ],
          );

          if (constraints.maxWidth < 580) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                padTekst,
                const SizedBox(height: 10),
                Align(alignment: Alignment.centerRight, child: knoppen),
              ],
            );
          }

          return Row(
            children: <Widget>[
              Expanded(child: padTekst),
              const SizedBox(width: 12),
              knoppen,
            ],
          );
        },
      ),
    );
  }
}

class _OneDrivePadStap {
  const _OneDrivePadStap({required this.id, required this.naam});

  final String? id;
  final String naam;
}
