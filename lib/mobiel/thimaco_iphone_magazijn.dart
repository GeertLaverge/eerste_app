// THIMACO-iPHONE-MAGAZIJN-V12-20261117
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../helpers/magazijn/thimaco_iphone_magazijn_service.dart';

class ThimacoIphoneMagazijn extends StatefulWidget {
  const ThimacoIphoneMagazijn({super.key});

  @override
  ThimacoIphoneMagazijnState createState() => ThimacoIphoneMagazijnState();
}

class ThimacoIphoneMagazijnState extends State<ThimacoIphoneMagazijn> {
  static const _oranje = Color(0xFFF15A24);
  static const _zwart = Color(0xFF20252B);
  static const _rand = Color(0xFFE5E7EB);
  static const _grijs = Color(0xFF66717D);
  final _service = ThimacoIphoneMagazijnService();
  final _zoekController = TextEditingController();
  final _wielController = FixedExtentScrollController(initialItem: 100);

  List<IphoneMagazijnArtikel> _artikelen = const [];
  IphoneMagazijnArtikel? _artikel;
  int _verschil = 0;
  bool _laden = false;
  bool _opslaan = false;
  String? _fout;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _vernieuw();
  }

  @override
  void dispose() {
    _zoekController.dispose();
    _wielController.dispose();
    super.dispose();
  }

  void _melding(String bericht) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(bericht), duration: const Duration(seconds: 5)),
    );
  }

  Future<void> _vernieuw() async {
    if (_laden || _opslaan) return;
    setState(() { _laden = true; _fout = null; });
    try {
      final artikelen = await _service.laadArtikelen();
      if (!mounted) return;
      setState(() {
        _artikelen = artikelen;
        final id = _artikel?.id;
        _artikel = id == null ? null : _zoekArtikel(id, artikelen);
      });
    } catch (fout) {
      if (mounted) setState(() => _fout = fout.toString());
    } finally {
      if (mounted) setState(() => _laden = false);
    }
  }

  /// Vernieuwen vanuit de gedeelde zwarte Magazijn-balk.
  Future<void> vernieuw() => _vernieuw();

  IphoneMagazijnArtikel? _zoekArtikel(String tekst,
      [List<IphoneMagazijnArtikel>? inLijst]) {
    final id = _service.artikelIdUitQr(tekst) ?? tekst.trim();
    for (final a in inLijst ?? _artikelen) {
      if (a.id == id) return a;
    }
    return null;
  }

  void _kiesArtikel(IphoneMagazijnArtikel artikel) {
    setState(() {
      _artikel = artikel;
      _verschil = 0;
      _status = '';
      _fout = null;
      _zoekController.clear();
    });
    if (_wielController.hasClients) _wielController.jumpToItem(100);
    FocusScope.of(context).unfocus();
  }

  Future<void> _toonScanner() async {
    if (_laden || _opslaan) return;
    // De Windows-testpreview heeft geen native mobile_scanner-camera.
    if (kIsWeb || (!kIsWeb && Platform.isWindows)) {
      _melding('Op Windows: geef de QR-code of artikelnaam hieronder in. Op iPhone opent de camera.');
      return;
    }
    final scan = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const _QrScannerScherm()),
    );
    if (!mounted || scan == null) return;
    final artikel = _zoekArtikel(scan);
    if (artikel == null) {
      _melding('QR-code niet gevonden in het Thimaco-magazijn. Vernieuw eerst de voorraad.');
      return;
    }
    _kiesArtikel(artikel);
  }

  bool get heeftOnbevestigdeWijzigingen => _verschil != 0;
  bool get bevestigingBezig => _opslaan;

  Future<void> bevestig() async {
    if (_laden || _opslaan) return;
    final artikel = _artikel;
    if (artikel == null) {
      _melding('Scan of kies eerst een artikel.');
      return;
    }
    if (_verschil == 0) {
      _melding('Kies met het scrollwiel een positieve of negatieve waarde.');
      return;
    }
    if (artikel.stock + _verschil < 0) {
      _melding('Onvoldoende voorraad: ${artikel.stock} ${artikel.eenheid}.');
      return;
    }
    setState(() => _opslaan = true);
    try {
      final resultaat = await _service.bevestigMutatie(
        artikelId: artikel.id, verschil: _verschil,
      );
      if (!mounted) return;
      setState(() {
        _artikel = resultaat.artikel;
        _artikelen = _artikelen.map((a) => a.id == resultaat.artikel.id
            ? resultaat.artikel : a).toList(growable: false);
        _verschil = 0;
        _status = resultaat.naarBureauAangeboden
            ? 'Opgeslagen in OneDrive. De bureau-app ontvangt de nieuwe voorraad bij synchronisatie.'
            : 'Lokaal bewaard in de Windows-testpreview. Cloudontvangst niet bevestigd.';
      });
      if (_wielController.hasClients) _wielController.jumpToItem(100);
      _melding(_status);
    } catch (e) {
      _melding('Niet opgeslagen: $e');
    } finally {
      if (mounted) setState(() => _opslaan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final term = _zoekController.text.trim().toLowerCase();
    final resultaten = term.isEmpty
        ? const <IphoneMagazijnArtikel>[]
        : _artikelen.where((a) =>
              a.naam.toLowerCase().contains(term) ||
              a.id.toLowerCase().contains(term)).take(12).toList();

    // Vaste opbouw: de magazijninhoud kan scrollen, maar het zoekveld blijft
    // altijd onmiddellijk boven de gedeelde onderste navigatie staan.
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            children: [
              OutlinedButton.icon(
                onPressed: _laden || _opslaan ? null : _toonScanner,
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 22),
                label: const Text('QR-code scannen'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _zwart,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: _rand),
                  minimumSize: const Size(0, 52),
                ),
              ),
              if (_laden)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator(color: _oranje)),
                ),
              if (_fout != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _fout!,
                    style: const TextStyle(color: Color(0xFFB42318), fontSize: 12),
                  ),
                ),
              if (_artikel != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: _rand),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Artikel', style: TextStyle(fontSize: 12, color: _grijs)),
                      const SizedBox(height: 4),
                      Text(_artikel!.naam,
                        style: const TextStyle(fontSize: 19,
                          fontWeight: FontWeight.w700, color: _zwart)),
                      const SizedBox(height: 16),
                      const Text('Aantal in stock',
                        style: TextStyle(fontSize: 12, color: _grijs)),
                      const SizedBox(height: 4),
                      Text('${_artikel!.stock} ${_artikel!.eenheid}',
                        style: const TextStyle(fontSize: 26,
                          fontWeight: FontWeight.w600, color: _zwart)),
                      const Divider(height: 28),
                      const Text('Wijzig voorraad (+ of −)',
                        style: TextStyle(fontSize: 14, color: _zwart)),
                      SizedBox(
                        height: 168,
                        child: CupertinoPicker(
                          scrollController: _wielController,
                          itemExtent: 43,
                          selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                            background: _oranje.withValues(alpha: 0.09),
                          ),
                          onSelectedItemChanged: (index) =>
                              setState(() => _verschil = index - 100),
                          children: [
                            for (var n = -100; n <= 100; n++)
                              Center(
                                child: Text(
                                  n > 0 ? '+$n' : '$n',
                                  style: TextStyle(
                                    fontSize: 23,
                                    fontWeight: n == 0
                                        ? FontWeight.w400 : FontWeight.w600,
                                    color: n > 0
                                        ? const Color(0xFF147D47)
                                        : (n < 0 ? const Color(0xFFB42318) : _zwart),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Center(
                        child: Text(
                          _verschil == 0
                              ? 'Kies een voorraadwijziging'
                              : 'Nieuwe voorraad: ${_artikel!.stock + _verschil} ${_artikel!.eenheid}',
                          style: const TextStyle(fontSize: 13, color: _grijs),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_status.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_status,
                    style: const TextStyle(fontSize: 12, color: _grijs)),
                ),
              const SizedBox(height: 10),
              if (_artikelen.isEmpty && !_laden && _fout == null)
                const Text(
                  'Nog geen magazijngegevens beschikbaar. Op de iPhone '
                  'worden deze na Microsoft-aanmelding opgehaald.',
                  style: TextStyle(color: _grijs, fontSize: 12),
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: _rand)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (term.isNotEmpty) ...[
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 190),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: _rand),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: [
                        for (final a in resultaten)
                          ListTile(
                            dense: true,
                            title: Text(a.naam, maxLines: 2),
                            subtitle: Text('${a.stock} ${a.eenheid} op voorraad'),
                            onTap: () => _kiesArtikel(a),
                          ),
                        if (resultaten.isEmpty && !_laden)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('Geen artikel gevonden.'),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              TextField(
                controller: _zoekController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Zoek op artikelnaam of artikel-ID',
                  prefixIcon: const Icon(Icons.search, color: _zwart),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QrScannerScherm extends StatefulWidget {
  const _QrScannerScherm();
  @override
  State<_QrScannerScherm> createState() => _QrScannerSchermState();
}

class _QrScannerSchermState extends State<_QrScannerScherm> {
  bool _afgehandeld = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      title: const Text('Scan Thimaco QR-code'),
      foregroundColor: Colors.white,
      backgroundColor: const Color(0xFF20252B),
    ),
    body: MobileScanner(
      errorBuilder: (context, fout) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            fout.errorCode == MobileScannerErrorCode.permissionDenied
                ? 'Zet camera aan voor Thimaco bij Instellingen → Privacy en beveiliging → Camera. Open daarna de QR-scanner opnieuw.'
                : 'Camera kon niet worden gestart. Sluit de scanner en probeer opnieuw.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      onDetect: (capture) {
        if (_afgehandeld || capture.barcodes.isEmpty) return;
        final waarde = capture.barcodes.first.rawValue;
        if (waarde == null || waarde.trim().isEmpty) return;
        _afgehandeld = true;
        Navigator.of(context).pop(waarde);
      },
    ),
  );
}
