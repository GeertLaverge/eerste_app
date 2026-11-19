import 'package:flutter/material.dart';

import 'thimaco_iphone_bureaugegevens.dart';

class ThimacoIphoneGeleverd extends StatefulWidget {
  const ThimacoIphoneGeleverd({super.key});

  @override
  State<ThimacoIphoneGeleverd> createState() => ThimacoIphoneGeleverdState();
}

class ThimacoIphoneGeleverdState extends State<ThimacoIphoneGeleverd> {
  static const _zwart = Color(0xFF20252B);
  static const _rand = Color(0xFFE5E7EB);
  final _bron = ThimacoIphoneBureaugegevens();
  final _klantZoeken = TextEditingController();
  final _leverancierZoeken = TextEditingController();
  final _gekozen = <LeveringRegel>{};
  List<LeveringRegel> _regels = const [];
  bool _laden = false;
  bool _opslaan = false;
  String? _fout;

  bool get heeftOnbevestigdeWijzigingen => _gekozen.isNotEmpty;
  bool get bevestigingBezig => _opslaan;

  Future<void> vernieuw({bool aanmelden = false}) async {
    if (_laden || _opslaan) return;
    setState(() {
      _laden = true;
      _fout = null;
    });
    try {
      final regels = await _bron.laadLeveringen(aanmelden: aanmelden);
      if (!mounted) return;
      setState(() {
        final selectie = _gekozen.intersection(regels.toSet());
        final gewijzigd = selectie.length != _gekozen.length;
        _regels = regels;
        _gekozen
          ..clear()
          ..addAll(selectie);
        if (gewijzigd) {
          _fout = 'Een selectie is op bureau gewijzigd. Controleer je vinkjes opnieuw.';
        }
      });
    } catch (fout) {
      if (mounted) setState(() => _fout = fout.toString());
    } finally {
      if (mounted) setState(() => _laden = false);
    }
  }

  @override
  void dispose() {
    _klantZoeken.dispose();
    _leverancierZoeken.dispose();
    super.dispose();
  }

  Future<void> bevestig() async {
    if (_opslaan || _laden || _gekozen.isEmpty) return;
    FocusScope.of(context).unfocus();
    final selectie = Set<LeveringRegel>.of(_gekozen);
    var bevestigd = false;
    setState(() {
      _opslaan = true;
      _fout = null;
    });
    try {
      await _bron.bevestigLeveringen(selectie);
      bevestigd = true;
      if (!mounted) return;
      setState(() {
        _regels = _regels.where((regel) => !selectie.contains(regel)).toList();
        _gekozen.removeAll(selectie);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leveringen bevestigd in OneDrive.')),
      );
    } catch (fout) {
      if (mounted) setState(() => _fout = fout.toString());
    } finally {
      if (mounted) setState(() => _opslaan = false);
    }
    if (bevestigd && mounted) await vernieuw();
  }

  Widget _zoekveld(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      onChanged: (_) => setState(() {}),
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.search),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final klant = _klantZoeken.text.trim().toLowerCase();
    final leverancier = _leverancierZoeken.text.trim().toLowerCase();
    final artikelen = _regels.where((regel) =>
        regel.klant.toLowerCase().startsWith(klant) &&
        regel.leverancier.toLowerCase().startsWith(leverancier));

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      children: [
        if (_laden || _opslaan) const LinearProgressIndicator(),
        if (_fout != null) ListTile(title: Text(_fout!)),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _rand),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _zoekveld('Klantnaam', _klantZoeken),
                const SizedBox(height: 8),
                _zoekveld('Leverancier', _leverancierZoeken),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 16, 4, 6),
          child: Text('Artikelen', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        if (artikelen.isEmpty) const ListTile(title: Text('Geen artikelen.')),
        for (final regel in artikelen)
          ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              title: Text(regel.artikel, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                klant.isEmpty && leverancier.isNotEmpty
                    ? regel.klant
                    : leverancier.isEmpty && klant.isNotEmpty
                        ? regel.leverancier
                        : '${regel.klant} · ${regel.leverancier}',
              ),
              trailing: Tooltip(
                message: _gekozen.contains(regel) ? 'Geleverd' : 'Markeer als geleverd',
                child: CircleAvatar(
                  radius: 13,
                  backgroundColor: _zwart,
                  child: _gekozen.contains(regel)
                      ? const Icon(Icons.check, size: 17, color: Colors.white)
                      : const CircleAvatar(radius: 12, backgroundColor: Colors.white),
                ),
              ),
              onTap: _laden || _opslaan ? null : () => setState(() {
                if (!_gekozen.remove(regel)) _gekozen.add(regel);
              }),
          ),
      ],
    );
  }
}
