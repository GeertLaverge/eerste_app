// THIMACO-CONTROLE: BIBLIOTHEEK-PDF-KIEZER-GROENE-MENUS-20260802

import 'package:flutter/material.dart';

import 'bibliotheek_onedrive_service.dart';

const Color _bibliotheekGroen = Color(0xFF0B7A3B);
const Color _bibliotheekRand = Color(0xFFE5E7EB);

ThemeData _bouwBibliotheekGroenThema(BuildContext context) {
  final basis = Theme.of(context);
  final kleurenschema = basis.colorScheme.copyWith(
    primary: _bibliotheekGroen,
    secondary: _bibliotheekGroen,
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
  );

  return basis.copyWith(
    colorScheme: kleurenschema,
    primaryColor: _bibliotheekGroen,
    focusColor: _bibliotheekGroen.withValues(alpha: 0.12),
    hoverColor: _bibliotheekGroen.withValues(alpha: 0.07),
    splashColor: _bibliotheekGroen.withValues(alpha: 0.10),
    highlightColor: _bibliotheekGroen.withValues(alpha: 0.06),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: _bibliotheekGroen,
      selectionColor: Color(0x5534A764),
      selectionHandleColor: _bibliotheekGroen,
    ),
    inputDecorationTheme: InputDecorationTheme(
      floatingLabelStyle: const TextStyle(color: _bibliotheekGroen),
      prefixIconColor: _bibliotheekGroen,
      suffixIconColor: _bibliotheekGroen,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _bibliotheekGroen, width: 1.6),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _bibliotheekGroen),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _bibliotheekGroen,
        foregroundColor: Colors.white,
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      iconColor: _bibliotheekGroen,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: _bibliotheekRand),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _bibliotheekGroen,
    ),
  );
}

class BibliotheekPdfKiezerDialog extends StatefulWidget {
  const BibliotheekPdfKiezerDialog({super.key, required this.service});

  final BibliotheekOneDriveService service;

  static Future<BibliotheekOneDriveItem?> toon({
    required BuildContext context,
    required BibliotheekOneDriveService service,
  }) {
    return showDialog<BibliotheekOneDriveItem>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Theme(
        data: _bouwBibliotheekGroenThema(dialogContext),
        child: BibliotheekPdfKiezerDialog(service: service),
      ),
    );
  }

  @override
  State<BibliotheekPdfKiezerDialog> createState() {
    return _BibliotheekPdfKiezerDialogState();
  }
}

class _BibliotheekPdfKiezerDialogState
    extends State<BibliotheekPdfKiezerDialog> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _achtergrond = Color(0xFFF7F8FA);

  final TextEditingController _zoekController = TextEditingController();
  final List<_PadStap> _pad = <_PadStap>[
    const _PadStap(id: null, naam: 'OneDrive'),
  ];

  List<BibliotheekOneDriveItem> _items = <BibliotheekOneDriveItem>[];
  bool _laden = true;
  String _fout = '';
  int _laadVersie = 0;

  _PadStap get _huidigeStap => _pad.last;

  List<BibliotheekOneDriveItem> get _zichtbareItems {
    final zoekterm = _zoekController.text.trim().toLowerCase();
    if (zoekterm.isEmpty) return _items;

    return _items
        .where((item) => item.naam.toLowerCase().contains(zoekterm))
        .toList(growable: false);
  }

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

  Future<void> _laadHuidigeMap() async {
    final versie = ++_laadVersie;

    setState(() {
      _laden = true;
      _fout = '';
      _items = <BibliotheekOneDriveItem>[];
    });

    try {
      final items = await widget.service.laadItems(mapId: _huidigeStap.id);
      if (!mounted || versie != _laadVersie) return;

      setState(() {
        _items = items;
        _laden = false;
      });
    } catch (e) {
      if (!mounted || versie != _laadVersie) return;

      setState(() {
        _laden = false;
        _fout = e.toString();
      });
    }
  }

  Future<void> _openMap(BibliotheekOneDriveItem item) async {
    if (!item.isMap) return;

    setState(() {
      _pad.add(_PadStap(id: item.id, naam: item.naam));
      _zoekController.clear();
    });

    await _laadHuidigeMap();
  }

  Future<void> _gaNaarPadIndex(int index) async {
    if (index < 0 || index >= _pad.length || index == _pad.length - 1) {
      return;
    }

    setState(() {
      _pad.removeRange(index + 1, _pad.length);
      _zoekController.clear();
    });

    await _laadHuidigeMap();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _bouwBibliotheekGroenThema(context),
      child: Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760, maxHeight: 700),
          child: Column(
            children: <Widget>[
              _bouwKop(),
              const Divider(height: 1, color: _rand),
              _bouwPad(),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                child: TextField(
                  controller: _zoekController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Zoek map of PDF',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _zoekController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _zoekController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                    filled: true,
                    fillColor: _achtergrond,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _rand),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _rand),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _groen, width: 1.6),
                    ),
                  ),
                ),
              ),
              Expanded(child: _bouwInhoud()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bouwKop() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'PDF uit OneDrive kiezen',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 3),
                Text(
                  'Alleen PDF-bestanden worden getoond.',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Sluiten',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _bouwPad() {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: _pad.length,
        separatorBuilder: (_, __) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 3),
          child: Icon(Icons.chevron_right_rounded, size: 18),
        ),
        itemBuilder: (context, index) {
          final stap = _pad[index];
          final actief = index == _pad.length - 1;

          return TextButton(
            onPressed: actief ? null : () => _gaNaarPadIndex(index),
            child: Text(
              stap.naam,
              style: TextStyle(
                color: _groen,
                fontWeight: actief ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _bouwInhoud() {
    if (_laden) {
      return const Center(child: CircularProgressIndicator(color: _groen));
    }

    if (_fout.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.cloud_off_outlined,
                size: 38,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(height: 12),
              Text(_fout, textAlign: TextAlign.center),
              const SizedBox(height: 14),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: _groen),
                onPressed: _laadHuidigeMap,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Opnieuw proberen'),
              ),
            ],
          ),
        ),
      );
    }

    final items = _zichtbareItems;
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Geen mappen of PDF-bestanden gevonden.',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 7),
      itemBuilder: (context, index) {
        final item = items[index];

        return Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: _rand),
          ),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: Icon(
              item.isMap
                  ? Icons.folder_outlined
                  : Icons.picture_as_pdf_outlined,
              color: item.isMap ? _groen : const Color(0xFFDC2626),
            ),
            title: Text(
              item.naam,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: item.isMap
                ? const Text('Map')
                : Text(_formateerGrootte(item.grootte)),
            trailing: Icon(
              item.isMap
                  ? Icons.chevron_right_rounded
                  : Icons.add_circle_outline_rounded,
              color: _groen,
            ),
            onTap: item.isMap
                ? () => _openMap(item)
                : () => Navigator.pop(context, item),
          ),
        );
      },
    );
  }

  String _formateerGrootte(int bytes) {
    if (bytes <= 0) return 'PDF';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _PadStap {
  const _PadStap({required this.id, required this.naam});

  final String? id;
  final String naam;
}
