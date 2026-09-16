// THIMACO-CONTROLE: ONEDRIVE-KIEZER-PROGRAMMASTIJL-FASE20-20260913
// THIMACO-CONTROLE: ONEDRIVE-KIEZER-TOONT-MAPPEN-EN-BESTANDEN-20260817
// THIMACO-CONTROLE: ONEDRIVE-MAP-KIEZER-MAPPEN-EN-BESTANDSNAAM-20260731
import 'package:flutter/material.dart';

import '../ui/thimaco_huisstijl.dart';
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
  static const Color _accent = ThimacoKleuren.oranje;
  static const Color _achtergrond = ThimacoKleuren.achtergrond;
  static const Color _rand = ThimacoKleuren.rand;
  static const Color _tekstDonker = ThimacoKleuren.antraciet;
  static const Color _tekstGrijs = ThimacoKleuren.tekstGrijs;
  static const Color _rood = ThimacoKleuren.rood;

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
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: _rand),
              ),
              titlePadding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
              contentPadding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
              actionsPadding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              title: const ThimacoSectieTitel(
                tekst: 'Nieuwe map aanmaken',
                compact: false,
              ),
              content: SizedBox(
                width: 420,
                child: TextField(
                  controller: naamController,
                  autofocus: true,
                  cursorColor: _accent,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => bevestig(),
                  decoration: InputDecoration(
                    labelText: 'Naam van de nieuwe map',
                    hintText: 'Bijvoorbeeld Opmeting of Offerte',
                    errorText: dialoogFout.isEmpty ? null : dialoogFout,
                    prefixIcon: const Icon(
                      Icons.create_new_folder_outlined,
                      color: _tekstDonker,
                      size: 19,
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
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _accent, width: 1.4),
                    ),
                  ),
                ),
              ),
              actions: <Widget>[
                ThimacoTekstActie(
                  tekst: 'Annuleren',
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                ThimacoTekstActie(
                  tekst: 'Map aanmaken',
                  onPressed: bevestig,
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
          backgroundColor: _rood,
        ),
      );
    } catch (fout) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('De nieuwe map kon niet worden aangemaakt.\n$fout'),
          backgroundColor: _rood,
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
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: _rand),
      ),
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
      padding: const EdgeInsets.fromLTRB(18, 15, 10, 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.cloud_outlined,
              color: _tekstDonker,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const ThimacoSectieTitel(
                  tekst: 'Opslaan naar OneDrive klanten',
                  compact: false,
                ),
                const SizedBox(height: 7),
                Text(
                  klantInfo.isEmpty ? 'Klant niet ingevuld' : klantInfo,
                  style: const TextStyle(
                    color: _tekstGrijs,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Kies een bestaande map of maak hier een nieuwe map aan. Pas daarna eventueel de PDF-bestandsnaam aan.',
                  style: TextStyle(
                    color: _tekstGrijs,
                    fontSize: 11.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          ThimacoIcoonActie(
            icoon: Icons.close_rounded,
            tooltip: 'Annuleren',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _bouwNavigatie() {
    return Container(
      color: _achtergrond,
      padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;

          final broodkruimel = Row(
            children: <Widget>[
              ThimacoIcoonActie(
                icoon: Icons.arrow_back_rounded,
                tooltip: 'Een map terug',
                onPressed: _pad.length > 1 && !_laden ? _gaEenMapTerug : null,
              ),
              const SizedBox(width: 3),
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
                              size: 17,
                              color: _tekstGrijs,
                            ),
                          ),
                        if (index < _pad.length - 1)
                          ThimacoTekstActie(
                            tekst: _pad[index].naam,
                            compact: true,
                            onPressed: !_laden
                                ? () => _gaNaarPadIndex(index)
                                : null,
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              _pad[index].naam,
                              style: const TextStyle(
                                color: _tekstDonker,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
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
            cursorColor: _accent,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Zoek in deze map',
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 19,
                color: _tekstDonker,
              ),
              suffixIcon: _zoekController.text.isEmpty
                  ? null
                  : ThimacoIcoonActie(
                      icoon: Icons.close_rounded,
                      tooltip: 'Zoekterm wissen',
                      grootte: 17,
                      onPressed: () {
                        _zoekController.clear();
                        setState(() {});
                      },
                    ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: _rand),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: _rand),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: _accent, width: 1.4),
              ),
            ),
          );

          final nieuweMapActie = Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (_mapAanmaken) ...<Widget>[
                const SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _accent,
                  ),
                ),
                const SizedBox(width: 5),
              ],
              ThimacoTekstActie(
                tekst: 'Nieuwe map',
                onPressed:
                    _laden || _mapAanmaken ? null : _nieuweMapAanmaken,
              ),
            ],
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
                    nieuweMapActie,
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
              nieuweMapActie,
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
            CircularProgressIndicator(color: _accent),
            SizedBox(height: 14),
            Text(
              'OneDrive-mappen laden…',
              style: TextStyle(
                color: _tekstGrijs,
                fontWeight: FontWeight.w600,
              ),
            ),
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
                size: 42,
                color: _rood,
              ),
              const SizedBox(height: 12),
              Text(
                _fout,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _rood,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 13),
              ThimacoTekstActie(
                tekst: 'Opnieuw proberen',
                onPressed: _laadHuidigeMap,
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
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: _rand),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              dense: true,
              hoverColor: ThimacoKleuren.oranjeLicht.withValues(alpha: 0.45),
              leading: Icon(
                _icoonVoorItem(item),
                color: item.isMap ? _tekstDonker : _kleurVoorBestand(item),
              ),
              title: Text(
                item.naam,
                style: TextStyle(
                  color: _tekstDonker,
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
                  ? const Icon(
                      Icons.chevron_right_rounded,
                      color: _tekstGrijs,
                    )
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
      return _rood;
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
            cursorColor: _accent,
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
              prefixIcon: const Icon(
                Icons.picture_as_pdf_outlined,
                color: _tekstDonker,
                size: 19,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: _rand),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: _rand),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: _accent, width: 1.4),
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

              final acties = Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ThimacoTekstActie(
                    tekst: 'Annuleren',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 7),
                  ThimacoTekstActie(
                    tekst: 'Opslaan in deze map',
                    onPressed: kanKiezen ? _kiesHuidigeMap : null,
                  ),
                ],
              );

              if (constraints.maxWidth < 620) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    padTekst,
                    const SizedBox(height: 9),
                    Align(alignment: Alignment.centerRight, child: acties),
                  ],
                );
              }

              return Row(
                children: <Widget>[
                  Expanded(child: padTekst),
                  const SizedBox(width: 12),
                  acties,
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
