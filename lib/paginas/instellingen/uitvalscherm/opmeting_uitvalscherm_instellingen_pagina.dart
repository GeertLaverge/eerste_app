// THIMACO-CONTROLE: UITVALSCHERM-ANALYZE-CORRECTIE-20260801
import 'package:flutter/material.dart';

import '../../../helpers/app_storage.dart';
import '../../../helpers/opmeting/toebehoren/uitvalscherm/opmeting_uitvalscherm_instellingen_model.dart';

class OpmetingUitvalschermInstellingenPagina extends StatefulWidget {
  const OpmetingUitvalschermInstellingenPagina({super.key});

  @override
  State<OpmetingUitvalschermInstellingenPagina> createState() =>
      _OpmetingUitvalschermInstellingenPaginaState();
}

class _OpmetingUitvalschermInstellingenPaginaState
    extends State<OpmetingUitvalschermInstellingenPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);

  OpmetingUitvalschermInstellingen _instellingen =
      const OpmetingUitvalschermInstellingen();
  bool _laden = true;
  bool _bewaren = false;

  @override
  void initState() {
    super.initState();
    _laad();
  }

  Future<void> _laad() async {
    final instellingen =
        await AppStorage.laadOpmetingUitvalschermInstellingen();
    if (!mounted) return;
    setState(() {
      _instellingen = instellingen;
      _laden = false;
    });
  }

  Future<void> _bewaar() async {
    if (_bewaren) return;
    setState(() => _bewaren = true);
    try {
      await AppStorage.bewaarOpmetingUitvalschermInstellingen(_instellingen);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Instellingen Uitvalscherm bewaard.')),
      );
    } finally {
      if (mounted) setState(() => _bewaren = false);
    }
  }

  void _herstelStandaard() {
    setState(() {
      _instellingen = const OpmetingUitvalschermInstellingen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: _groen,
        foregroundColor: Colors.white,
        title: const Text(
          'Instellingen Uitvalscherm',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: <Widget>[
          TextButton.icon(
            onPressed: _laden || _bewaren ? null : _herstelStandaard,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('Standaardlijsten'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilledButton.icon(
              onPressed: _laden || _bewaren ? null : _bewaar,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _groen,
              ),
              icon: _bewaren
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text('Bewaren'),
            ),
          ),
        ],
      ),
      body: _laden
          ? const Center(child: CircularProgressIndicator(color: _groen))
          : DefaultTabController(
              length: 4,
              child: Column(
                children: <Widget>[
                  Container(
                    color: Colors.white,
                    child: const TabBar(
                      labelColor: _groen,
                      unselectedLabelColor: Color(0xFF6B7280),
                      indicatorColor: _groen,
                      tabs: <Widget>[
                        Tab(text: 'Doeken'),
                        Tab(text: 'Motoren'),
                        Tab(text: 'Bedieningen'),
                        Tab(text: 'Draagstructuur'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: <Widget>[
                        _bouwDoeken(),
                        _bouwMotoren(),
                        _bouwBedieningen(),
                        _bouwKleuren(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _kaartLijst({
    required String uitleg,
    required VoidCallback onToevoegen,
    required List<Widget> kinderen,
  }) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  uitleg,
                  style: const TextStyle(
                    color: Color(0xFF4B5563),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: onToevoegen,
                style: FilledButton.styleFrom(backgroundColor: _groen),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Toevoegen'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: kinderen.isEmpty
                ? const Center(child: Text('De lijst is leeg.'))
                : ListView.separated(
                    itemCount: kinderen.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 7),
                    itemBuilder: (context, index) => kinderen[index],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _bouwDoeken() {
    return _kaartLijst(
      uitleg:
          'Unieke SunCollection-doeken. De cirkel in de tekening gebruikt de ingestelde HEX-kleur.',
      onToevoegen: () => _bewerkDoek(),
      kinderen: <Widget>[
        for (var index = 0; index < _instellingen.doeken.length; index++)
          _lijstKaart(
            leading: _kleurCirkel(_instellingen.doeken[index].hex),
            titel: _instellingen.doeken[index].label,
            subtitel: _instellingen.doeken[index].hex,
            onBewerken: () => _bewerkDoek(index: index),
            onVerwijderen: () {
              final lijst = [..._instellingen.doeken]..removeAt(index);
              setState(
                () => _instellingen = _instellingen.copyWith(doeken: lijst),
              );
            },
          ),
      ],
    );
  }

  Widget _bouwMotoren() {
    return _kaartLijst(
      uitleg:
          '700 LX gebruikt uitsluitend een draadloze motor. 700 X en 500 X kunnen beide motortypes gebruiken.',
      onToevoegen: () => _bewerkMotor(),
      kinderen: <Widget>[
        for (var index = 0; index < _instellingen.motoren.length; index++)
          _lijstKaart(
            leading: const Icon(Icons.settings_remote_outlined, color: _groen),
            titel: _instellingen.motoren[index].label,
            subtitel: _instellingen.motoren[index].type,
            onBewerken: () => _bewerkMotor(index: index),
            onVerwijderen: () {
              final lijst = [..._instellingen.motoren]..removeAt(index);
              setState(
                () => _instellingen = _instellingen.copyWith(motoren: lijst),
              );
            },
          ),
      ],
    );
  }

  Widget _bouwBedieningen() {
    return _kaartLijst(
      uitleg:
          'De bediening voor 700 LX wordt automatisch op Handzender Somfy Situo 5 Var gezet.',
      onToevoegen: () => _bewerkTekstLijst(type: 'Bediening'),
      kinderen: <Widget>[
        for (var index = 0; index < _instellingen.bedieningen.length; index++)
          _lijstKaart(
            leading: const Icon(Icons.sensors_outlined, color: _groen),
            titel: _instellingen.bedieningen[index],
            onBewerken: () =>
                _bewerkTekstLijst(type: 'Bediening', index: index),
            onVerwijderen: () {
              final lijst = [..._instellingen.bedieningen]..removeAt(index);
              setState(
                () =>
                    _instellingen = _instellingen.copyWith(bedieningen: lijst),
              );
            },
          ),
      ],
    );
  }

  Widget _bouwKleuren() {
    return _kaartLijst(
      uitleg:
          'Deze lijst wordt gebruikt wanneer Standaard poederkleur wordt gekozen.',
      onToevoegen: () => _bewerkKleur(),
      kinderen: <Widget>[
        for (
          var index = 0;
          index < _instellingen.draagstructuurKleuren.length;
          index++
        )
          _lijstKaart(
            leading: const Icon(Icons.palette_outlined, color: _groen),
            titel: _instellingen.draagstructuurKleuren[index].label,
            onBewerken: () => _bewerkKleur(index: index),
            onVerwijderen: () {
              final lijst = [..._instellingen.draagstructuurKleuren]
                ..removeAt(index);
              setState(
                () => _instellingen = _instellingen.copyWith(
                  draagstructuurKleuren: lijst,
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _lijstKaart({
    required Widget leading,
    required String titel,
    String subtitel = '',
    required VoidCallback onBewerken,
    required VoidCallback onVerwijderen,
  }) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _rand),
      ),
      child: ListTile(
        leading: SizedBox(width: 34, height: 34, child: Center(child: leading)),
        title: Text(titel, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: subtitel.isEmpty ? null : Text(subtitel),
        trailing: Wrap(
          children: <Widget>[
            IconButton(
              tooltip: 'Bewerken',
              onPressed: onBewerken,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Verwijderen',
              onPressed: onVerwijderen,
              icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kleurCirkel(String hex) {
    final waarde =
        int.tryParse(
          OpmetingUitvalschermDoek.normaliseerHex(hex).substring(1),
          radix: 16,
        ) ??
        0x8C8C8A;
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF000000 | waarde),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF9CA3AF)),
      ),
    );
  }

  Future<void> _bewerkDoek({int? index}) async {
    final bestaand = index == null ? null : _instellingen.doeken[index];
    final code = TextEditingController(text: bestaand?.code ?? '');
    final kleur = TextEditingController(text: bestaand?.kleur ?? '');
    final hex = TextEditingController(text: bestaand?.hex ?? '#8C8C8A');
    final resultaat = await _toonFormulier(
      titel: index == null ? 'Doek toevoegen' : 'Doek bewerken',
      velden: <Widget>[
        TextField(
          controller: code,
          decoration: const InputDecoration(labelText: 'Code'),
        ),
        TextField(
          controller: kleur,
          decoration: const InputDecoration(labelText: 'Kleur'),
        ),
        TextField(
          controller: hex,
          decoration: const InputDecoration(labelText: 'HEX-kleur'),
        ),
      ],
    );
    if (resultaat != true || !mounted) return;
    final item = OpmetingUitvalschermDoek(
      code: code.text.trim().toUpperCase(),
      kleur: kleur.text.trim(),
      hex: OpmetingUitvalschermDoek.normaliseerHex(hex.text),
    );
    if (item.code.isEmpty) return;
    final dubbelIndex = _instellingen.doeken.indexWhere(
      (doek) => doek.id == item.id,
    );
    if (dubbelIndex >= 0 && dubbelIndex != index) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Doekcode ${item.code} bestaat al. Er wordt geen dubbele doek toegevoegd.',
          ),
        ),
      );
      return;
    }

    final lijst = [..._instellingen.doeken];
    if (index == null) {
      lijst.add(item);
    } else {
      lijst[index] = item;
    }
    setState(() => _instellingen = _instellingen.copyWith(doeken: lijst));
  }

  Future<void> _bewerkMotor({int? index}) async {
    final bestaand = index == null ? null : _instellingen.motoren[index];
    var type = bestaand?.type ?? 'Draadloos';
    final merk = TextEditingController(text: bestaand?.merk ?? 'SOMFY');
    final omschrijving = TextEditingController(
      text: bestaand?.omschrijving ?? '',
    );
    final resultaat = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(index == null ? 'Motor toevoegen' : 'Motor bewerken'),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DropdownButtonFormField<String>(
                  initialValue: type,
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem(
                      value: 'Bekabeld',
                      child: Text('Bekabeld'),
                    ),
                    DropdownMenuItem(
                      value: 'Draadloos',
                      child: Text('Draadloos'),
                    ),
                  ],
                  onChanged: (waarde) =>
                      setDialogState(() => type = waarde ?? type),
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                TextField(
                  controller: merk,
                  decoration: const InputDecoration(labelText: 'Merk'),
                ),
                TextField(
                  controller: omschrijving,
                  decoration: const InputDecoration(labelText: 'Omschrijving'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuleren'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Bewaren'),
            ),
          ],
        ),
      ),
    );
    if (resultaat != true || !mounted) return;
    final item = OpmetingUitvalschermMotor(
      type: type,
      merk: merk.text.trim(),
      omschrijving: omschrijving.text.trim(),
    );
    if (item.omschrijving.isEmpty) return;
    final lijst = [..._instellingen.motoren];
    if (index == null) {
      lijst.removeWhere((motor) => motor.id == item.id);
      lijst.add(item);
    } else {
      lijst[index] = item;
    }
    setState(() => _instellingen = _instellingen.copyWith(motoren: lijst));
  }

  Future<void> _bewerkTekstLijst({required String type, int? index}) async {
    final controller = TextEditingController(
      text: index == null ? '' : _instellingen.bedieningen[index],
    );
    final resultaat = await _toonFormulier(
      titel: '$type ${index == null ? 'toevoegen' : 'bewerken'}',
      velden: <Widget>[
        TextField(
          controller: controller,
          decoration: InputDecoration(labelText: type),
        ),
      ],
    );
    if (resultaat != true || !mounted || controller.text.trim().isEmpty) return;
    final lijst = [..._instellingen.bedieningen];
    if (index == null) {
      if (!lijst.any(
        (item) => item.toLowerCase() == controller.text.trim().toLowerCase(),
      )) {
        lijst.add(controller.text.trim());
      }
    } else {
      lijst[index] = controller.text.trim();
    }
    setState(() => _instellingen = _instellingen.copyWith(bedieningen: lijst));
  }

  Future<void> _bewerkKleur({int? index}) async {
    final bestaand = index == null
        ? null
        : _instellingen.draagstructuurKleuren[index];
    final naam = TextEditingController(text: bestaand?.naam ?? '');
    final code = TextEditingController(text: bestaand?.code ?? '');
    final resultaat = await _toonFormulier(
      titel: index == null ? 'Poederkleur toevoegen' : 'Poederkleur bewerken',
      velden: <Widget>[
        TextField(
          controller: naam,
          decoration: const InputDecoration(labelText: 'Benaming'),
        ),
        TextField(
          controller: code,
          decoration: const InputDecoration(labelText: 'Code'),
        ),
      ],
    );
    if (resultaat != true || !mounted || naam.text.trim().isEmpty) return;
    final item = OpmetingUitvalschermKleur(
      naam: naam.text.trim(),
      code: code.text.trim(),
    );
    final lijst = [..._instellingen.draagstructuurKleuren];
    if (index == null) {
      lijst.removeWhere((kleur) => kleur.id == item.id);
      lijst.add(item);
    } else {
      lijst[index] = item;
    }
    setState(
      () =>
          _instellingen = _instellingen.copyWith(draagstructuurKleuren: lijst),
    );
  }

  Future<bool?> _toonFormulier({
    required String titel,
    required List<Widget> velden,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(titel),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (var index = 0; index < velden.length; index++) ...<Widget>[
                velden[index],
                if (index < velden.length - 1) const SizedBox(height: 10),
              ],
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Bewaren'),
          ),
        ],
      ),
    );
  }
}
