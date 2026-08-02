// THIMACO-CONTROLE: ONEDRIVE-AFBEELDING-DIALOOG-20260801
import 'dart:convert';

import 'package:flutter/material.dart';

import '../opmeting/fotos/opmeting_foto_model.dart';
import 'onedrive_afbeelding_service.dart';

class OneDriveAfbeeldingKiezerDialog extends StatefulWidget {
  const OneDriveAfbeeldingKiezerDialog({super.key, required this.service});

  final OneDriveAfbeeldingService service;

  static Future<OpmetingFoto?> toon({
    required BuildContext context,
    OneDriveAfbeeldingService? service,
  }) {
    return showDialog<OpmetingFoto>(
      context: context,
      barrierDismissible: false,
      builder: (context) => OneDriveAfbeeldingKiezerDialog(
        service: service ?? OneDriveAfbeeldingService(),
      ),
    );
  }

  @override
  State<OneDriveAfbeeldingKiezerDialog> createState() =>
      _OneDriveAfbeeldingKiezerDialogState();
}

class _OneDriveAfbeeldingKiezerDialogState
    extends State<OneDriveAfbeeldingKiezerDialog> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  final TextEditingController _zoekController = TextEditingController();
  final List<_PadStap> _pad = <_PadStap>[
    const _PadStap(id: null, naam: 'OneDrive'),
  ];

  List<OneDriveAfbeeldingItem> _items = const <OneDriveAfbeeldingItem>[];
  bool _laden = true;
  bool _downloaden = false;
  String _fout = '';

  @override
  void initState() {
    super.initState();
    _zoekController.addListener(() => setState(() {}));
    _laadItems();
  }

  @override
  void dispose() {
    _zoekController.dispose();
    super.dispose();
  }

  _PadStap get _huidigeStap => _pad.last;

  List<OneDriveAfbeeldingItem> get _zichtbareItems {
    final zoekterm = _zoekController.text.trim().toLowerCase();
    if (zoekterm.isEmpty) return _items;
    return _items
        .where((item) => item.naam.toLowerCase().contains(zoekterm))
        .toList(growable: false);
  }

  Future<void> _laadItems() async {
    setState(() {
      _laden = true;
      _fout = '';
      _items = const <OneDriveAfbeeldingItem>[];
    });
    try {
      final items = await widget.service.laadItems(mapId: _huidigeStap.id);
      if (!mounted) return;
      setState(() => _items = items);
    } catch (fout) {
      if (!mounted) return;
      setState(() => _fout = fout.toString());
    } finally {
      if (mounted) setState(() => _laden = false);
    }
  }

  Future<void> _openMap(OneDriveAfbeeldingItem item) async {
    _pad.add(_PadStap(id: item.id, naam: item.naam));
    _zoekController.clear();
    await _laadItems();
  }

  Future<void> _gaTerug() async {
    if (_pad.length <= 1) return;
    _pad.removeLast();
    _zoekController.clear();
    await _laadItems();
  }

  Future<void> _kiesAfbeelding(OneDriveAfbeeldingItem item) async {
    if (_downloaden) return;
    setState(() {
      _downloaden = true;
      _fout = '';
    });
    try {
      final download = await widget.service.downloadAfbeelding(item);
      if (!mounted) return;
      final nu = DateTime.now().toUtc();
      Navigator.of(context).pop(
        OpmetingFoto(
          id: 'onedrive_${nu.microsecondsSinceEpoch}',
          bestandsNaam: item.naam,
          mimeType: download.mimeType,
          gemaaktOp: nu.toIso8601String(),
          base64Data: base64Encode(download.bytes),
        ),
      );
    } catch (fout) {
      if (!mounted) return;
      setState(() => _fout = fout.toString());
    } finally {
      if (mounted) setState(() => _downloaden = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _zichtbareItems;
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 12, 8),
      contentPadding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      title: Row(
        children: <Widget>[
          const Icon(Icons.cloud_outlined, color: _groen),
          const SizedBox(width: 9),
          const Expanded(
            child: Text(
              'Afbeelding uit OneDrive',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          IconButton(
            onPressed: _downloaden ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      content: SizedBox(
        width: 680,
        height: 530,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton.filledTonal(
                  tooltip: 'Vorige map',
                  onPressed: _pad.length > 1 && !_laden ? _gaTerug : null,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _pad.map((stap) => stap.naam).join(' / '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _tekstGrijs,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _zoekController,
              decoration: InputDecoration(
                hintText: 'Zoek een map of afbeelding',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _zoekController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: _zoekController.clear,
                        icon: const Icon(Icons.close_rounded),
                      ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _rand),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _rand),
                ),
              ),
            ),
            if (_fout.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _fout,
                  style: const TextStyle(color: Color(0xFFB91C1C)),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Expanded(
              child: _laden
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                  ? const Center(
                      child: Text(
                        'Geen ondersteunde afbeeldingen gevonden.\n'
                        'JPEG en PNG worden ondersteund.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _tekstGrijs),
                      ),
                    )
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          enabled: !_downloaden,
                          leading: CircleAvatar(
                            backgroundColor: item.isMap
                                ? const Color(0xFFE7F6EC)
                                : const Color(0xFFFFF7ED),
                            child: Icon(
                              item.isMap
                                  ? Icons.folder_outlined
                                  : Icons.image_outlined,
                              color: item.isMap
                                  ? _groen
                                  : const Color(0xFFF15A24),
                            ),
                          ),
                          title: Text(
                            item.naam,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: item.isMap
                              ? const Text('Map')
                              : Text(_grootteTekst(item.grootte)),
                          trailing: item.isMap
                              ? const Icon(Icons.chevron_right_rounded)
                              : const Icon(Icons.add_photo_alternate_outlined),
                          onTap: item.isMap
                              ? () => _openMap(item)
                              : () => _kiesAfbeelding(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _downloaden ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuleren'),
        ),
      ],
    );
  }

  String _grootteTekst(int bytes) {
    if (bytes <= 0) return 'Afbeelding';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} kB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _PadStap {
  const _PadStap({required this.id, required this.naam});

  final String? id;
  final String naam;
}
