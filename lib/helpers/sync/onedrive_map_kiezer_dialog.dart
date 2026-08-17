// THIMACO-CONTROLE: ONEDRIVE-KIEZER-TOONT-MAPPEN-EN-BESTANDEN-20260817
// THIMACO-CONTROLE: ONEDRIVE-MAP-KIEZER-MAPPEN-EN-BESTANDSNAAM-20260731
import 'package:flutter/material.dart';

import 'onedrive_klantdocument_service.dart';

class OneDriveMapKiezerDialog extends StatefulWidget {
  const OneDriveMapKiezerDialog({
    super.key,
    required this.service,
    required this.klantNaam,
    required this.klantnummer,
    required this.initieleBestandsnaam,
  });

  final OneDriveKlantdocumentService service;
  final String klantNaam;
  final String klantnummer;
  final String initieleBestandsnaam;

  static Future<OneDriveGekozenMap?> toon({
    required BuildContext context,
    required OneDriveKlantdocumentService service,
    required String klantNaam,
    required String klantnummer,
    required String initieleBestandsnaam,
  }) {
    return showDialog<OneDriveGekozenMap>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return OneDriveMapKiezerDialog(
          service: service,
          klantNaam: klantNaam,
          klantnummer: klantnummer,
          initieleBestandsnaam: initieleBestandsnaam,
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
  late final TextEditingController _bestandsnaamController;
  final List<_OneDrivePadStap> _pad = <_OneDrivePadStap>[
    const _OneDrivePadStap(id: null, naam: 'OneDrive'),
  ];

  List<OneDriveMapItem> _items = <OneDriveMapItem>[];
  bool _laden = true;
  bool _mapAanmaken = false;
  String _fout = '';
  String _bestandsnaamFout = '';
  int _laadVersie = 0;

  @override
  void initState() {
    super.initState();
    _bestandsnaamController = TextEditingController(
      text: OneDriveKlantdocumentService.normaliseerPdfBestandsnaam(
        widget.initieleBestandsnaam,
      ),
    );
    _laadHuidigeMap();
  }

  @override
  void dispose() {
    _zoekController.dispose();
    _bestandsnaamController.dispose();
    super.dispose();
  }

  _OneDrivePadStap get _huidigeStap => _pad.last;

  String get _huidigePad => _pad.map((stap) => stap.naam).join(' / ');

  List<OneDriveMapItem> get _gefilterdeItems {
    final zoekterm = _zoekController.text.trim().toLowerCase();
    if (zoekterm.isEmpty) return _items;

    return _items
        .where((item) => item.naam.toLowerCase().contains(zoekterm))
        .toList(growable: false);
  }

  Future<void> _laadHuidigeMap() async {
    final versie = ++_laadVersie;

    setState(() {
      _laden = true;
      _fout = '';
      _items = <OneDriveMapItem>[];
    });

    try {
      final items = await widget.service.laadItems(
        bovenliggendeMapId: _huidigeStap.id,
      );

      if (!mounted || versie != _laadVersie) return;

      setState(() {
        _items = items;
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

  Future<void> _nieuweMapAanmaken() async {
    if (_laden || _mapAanmaken) return;

    final naamController = TextEditingController();
    String dialoogFout = '';

    final mapNaam = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            void bevestig() {
              final fout = OneDriveKlantdocumentService.valideerMapNaam(
                naamController.text,
              );

              if (fout != null) {
                setDialogState(() {
                  dialoogFout = fout;
                });
                return;
              }

              Navigator.of(dialogContext).pop(naamController.text.trim());
            }

            return AlertDialog(
              title: const Text('Nieuwe map aanmaken'),
              content: SizedBox(
                width: 420,
                child: TextField(
                  controller: naamController,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => bevestig(),
                  decoration: InputDecoration(
                    labelText: 'Naam van de nieuwe map',
                    hintText: 'Bijvoorbeeld Opmeting of Offerte',
                    errorText: dialoogFout.isEmpty ? null : dialoogFout,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuleren'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: _groen),
                  onPressed: bevestig,
                  icon: const Icon(Icons.create_new_folder_outlined),
                  label: const Text('Map aanmaken'),
                ),
              ],
            );
          },
        );
      },
    );

    naamController.dispose();
    if (mapNaam == null || !mounted) return;

    setState(() {
      _mapAanmaken = true;
    });

    try {
      final nieuweMap = await widget.service.maakMap(
        bovenliggendeMapId: _huidigeStap.id,
        naam: mapNaam,
      );

      if (!mounted) return;

      FocusScope.of(context).unfocus();
      _zoekController.clear();
      _pad.add(_OneDrivePadStap(id: nieuweMap.id, naam: nieuweMap.naam));
      await _laadHuidigeMap();
    } on OneDriveKlantdocumentException catch (fout) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(fout.bericht),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } catch (fout) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('De nieuwe map kon niet worden aangemaakt.\n$fout'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _mapAanmaken = false;
        });
      }
    }
  }

  void _kiesHuidigeMap() {
    final mapId = _huidigeStap.id;
    if (mapId == null || mapId.isEmpty) return;

    final bestandsnaam =
        OneDriveKlantdocumentService.normaliseerPdfBestandsnaam(
          _bestandsnaamController.text,
        );
    final bestandsnaamFout =
        OneDriveKlantdocumentService.valideerPdfBestandsnaam(bestandsnaam);

    if (bestandsnaamFout != null) {
      setState(() {
        _bestandsnaamFout = bestandsnaamFout;
      });
      return;
    }

    _bestandsnaamController.value = TextEditingValue(
      text: bestandsnaam,
      selection: TextSelection.collapsed(offset: bestandsnaam.length),
    );

    final mapPad = _pad.skip(1).map((stap) => stap.naam).join('/');
    Navigator.of(context).pop(
      OneDriveGekozenMap(id: mapId, pad: mapPad, bestandsnaam: bestandsnaam),
    );
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
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 760),
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
                  'Kies een bestaande map of maak hier een nieuwe map aan. Pas daarna eventueel de PDF-bestandsnaam aan.',
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

          final nieuweMapKnop = OutlinedButton.icon(
            onPressed: _laden || _mapAanmaken ? null : _nieuweMapAanmaken,
            icon: _mapAanmaken
                ? const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.create_new_folder_outlined),
            label: const Text('Nieuwe map'),
          );

          if (compact) {
            return Column(
              children: <Widget>[
                broodkruimel,
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(child: zoekveld),
                    const SizedBox(width: 8),
                    nieuweMapKnop,
                  ],
                ),
              ],
            );
          }

          return Row(
            children: <Widget>[
              Expanded(child: broodkruimel),
              const SizedBox(width: 12),
              SizedBox(width: 250, child: zoekveld),
              const SizedBox(width: 8),
              nieuweMapKnop,
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

    final zichtbareItems = _gefilterdeItems;

    if (zichtbareItems.isEmpty) {
      return Center(
        child: Text(
          _zoekController.text.trim().isEmpty
              ? 'Deze map is leeg.'
              : 'Geen map of bestand gevonden voor “${_zoekController.text.trim()}”.',
          style: const TextStyle(color: _tekstGrijs),
        ),
      );
    }

    return Scrollbar(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        itemCount: zichtbareItems.length,
        separatorBuilder: (_, _) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final item = zichtbareItems[index];

          return Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
              side: const BorderSide(color: _rand),
            ),
            child: ListTile(
              dense: true,
              leading: Icon(
                _icoonVoorItem(item),
                color: item.isMap ? _groen : _kleurVoorBestand(item),
              ),
              title: Text(
                item.naam,
                style: TextStyle(
                  fontWeight: item.isMap ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
              subtitle: item.isMap
                  ? null
                  : Text(
                      _bestandSubtitel(item),
                      style: const TextStyle(color: _tekstGrijs, fontSize: 11),
                    ),
              trailing: item.isMap
                  ? const Icon(Icons.chevron_right_rounded)
                  : null,
              onTap: item.isMap ? () => _openMap(item) : null,
            ),
          );
        },
      ),
    );
  }

  IconData _icoonVoorItem(OneDriveMapItem item) {
    if (item.isMap) return Icons.folder_rounded;

    final naam = item.naam.toLowerCase();
    final mime = item.mimeType.toLowerCase();

    if (naam.endsWith('.pdf') || mime == 'application/pdf') {
      return Icons.picture_as_pdf_rounded;
    }

    if (mime.startsWith('image/') ||
        naam.endsWith('.jpg') ||
        naam.endsWith('.jpeg') ||
        naam.endsWith('.png') ||
        naam.endsWith('.webp')) {
      return Icons.image_outlined;
    }

    if (naam.endsWith('.xlsx') || naam.endsWith('.xls')) {
      return Icons.table_chart_outlined;
    }

    if (naam.endsWith('.docx') || naam.endsWith('.doc')) {
      return Icons.description_outlined;
    }

    return Icons.insert_drive_file_outlined;
  }

  Color _kleurVoorBestand(OneDriveMapItem item) {
    final naam = item.naam.toLowerCase();
    final mime = item.mimeType.toLowerCase();

    if (naam.endsWith('.pdf') || mime == 'application/pdf') {
      return const Color(0xFFB91C1C);
    }

    return _tekstGrijs;
  }

  String _bestandSubtitel(OneDriveMapItem item) {
    final delen = <String>[];
    final naam = item.naam.toLowerCase();
    final mime = item.mimeType.toLowerCase();

    if (naam.endsWith('.pdf') || mime == 'application/pdf') {
      delen.add('PDF');
    } else {
      final punt = item.naam.lastIndexOf('.');
      if (punt >= 0 && punt < item.naam.length - 1) {
        delen.add(item.naam.substring(punt + 1).toUpperCase());
      } else {
        delen.add('Bestand');
      }
    }

    if (item.grootteBytes > 0) {
      delen.add(_formatteerBestandsgrootte(item.grootteBytes));
    }

    return delen.join(' · ');
  }

  String _formatteerBestandsgrootte(int bytes) {
    if (bytes < 1024) return '$bytes B';

    final kb = bytes / 1024.0;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(kb >= 100 ? 0 : 1)} KB';
    }

    final mb = kb / 1024.0;
    if (mb < 1024) {
      return '${mb.toStringAsFixed(mb >= 100 ? 0 : 1)} MB';
    }

    final gb = mb / 1024.0;
    return '${gb.toStringAsFixed(gb >= 100 ? 0 : 1)} GB';
  }

  Widget _bouwOnderbalk() {
    final kanKiezen =
        _huidigeStap.id != null && !_laden && !_mapAanmaken && _fout.isEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _bestandsnaamController,
            enabled: !_laden && !_mapAanmaken,
            textInputAction: TextInputAction.done,
            onChanged: (_) {
              if (_bestandsnaamFout.isNotEmpty) {
                setState(() {
                  _bestandsnaamFout = '';
                });
              }
            },
            onSubmitted: (_) {
              if (kanKiezen) _kiesHuidigeMap();
            },
            decoration: InputDecoration(
              labelText: 'PDF-bestandsnaam',
              hintText: 'Geef de gewenste bestandsnaam in',
              helperText: 'De extensie .pdf wordt automatisch toegevoegd.',
              errorText: _bestandsnaamFout.isEmpty ? null : _bestandsnaamFout,
              prefixIcon: const Icon(Icons.picture_as_pdf_outlined),
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
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
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
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Opslaan in deze map'),
                  ),
                ],
              );

              if (constraints.maxWidth < 620) {
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
        ],
      ),
    );
  }
}

class _OneDrivePadStap {
  const _OneDrivePadStap({required this.id, required this.naam});

  final String? id;
  final String naam;
}
