import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../helpers/bibliotheek/bibliotheek_model.dart';
import '../helpers/bibliotheek/bibliotheek_onedrive_service.dart';
import 'thimaco_iphone_bureaugegevens.dart';

class ThimacoIphoneBibliotheek extends StatefulWidget {
  const ThimacoIphoneBibliotheek({super.key});

  @override
  State<ThimacoIphoneBibliotheek> createState() =>
      ThimacoIphoneBibliotheekState();
}

class ThimacoIphoneBibliotheekState extends State<ThimacoIphoneBibliotheek> {
  final _bron = ThimacoIphoneBureaugegevens();
  final _pdf = BibliotheekOneDriveService();
  BibliotheekData? _data;
  bool _laden = false;
  String? _fout;

  Future<void> vernieuw({bool aanmelden = false}) async {
    if (_laden || (!aanmelden && _data != null)) return;
    setState(() {
      _laden = true;
      _fout = null;
    });
    try {
      final data = await _bron.laadBibliotheek(aanmelden: aanmelden);
      if (mounted) setState(() => _data = data);
    } catch (fout) {
      if (mounted) setState(() => _fout = fout.toString());
    } finally {
      if (mounted) setState(() => _laden = false);
    }
  }

  void _openPdf(BibliotheekFolder folder) {
    final Future<Uint8List> inhoud = _pdf.downloadPdf(folder.onedriveItemId);
    Navigator.of(context).push<void>(MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: Text(folder.naam)),
        body: FutureBuilder<Uint8List>(
          future: inhoud,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('PDF openen mislukt: ${snapshot.error}'));
            }
            final bytes = snapshot.data;
            if (bytes == null) return const Center(child: CircularProgressIndicator());
            return PdfPreview(
              build: (_) async => bytes,
              allowPrinting: false,
              allowSharing: false,
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
            );
          },
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final leveranciers = _data?.leveranciers ?? const <BibliotheekLeverancier>[];
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      children: [
        if (_laden) const LinearProgressIndicator(),
        if (_fout != null) ListTile(title: Text(_fout!)),
        if (!_laden && _fout == null && leveranciers.isEmpty)
          const ListTile(title: Text('Geen bibliotheekdocumenten.')),
        for (final leverancier in leveranciers)
          ExpansionTile(
            title: Text(leverancier.naam),
            children: [
              for (final schap in leverancier.schappen)
                ExpansionTile(
                  title: Text(schap.naam),
                  children: [
                    for (final folder in schap.folders)
                      ListTile(
                        title: Text(folder.naam),
                        enabled: folder.heeftPdf,
                        onTap: folder.heeftPdf ? () => _openPdf(folder) : null,
                      ),
                  ],
                ),
            ],
          ),
      ],
    );
  }
}
