// THIMACO-IPHONENOTITIES: V8 PREVIEW (2026-11-17)
// Dit scherm bewaart gegevens tijdelijk in een mobiele wachtrij.
// Verzenden naar het bureau wordt PAS actief na verificatie van de
// OneDrive-synchronisatie en foto-upload. Niet als verzonden markeren.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/notities/thimaco_iphone_bureau_inbox_service.dart';

class ThimacoIphoneNotitiesBureau extends StatefulWidget {
  const ThimacoIphoneNotitiesBureau({super.key});

  @override
  State<ThimacoIphoneNotitiesBureau> createState() =>
      ThimacoIphoneNotitiesBureauState();
}

class ThimacoIphoneNotitiesBureauState
    extends State<ThimacoIphoneNotitiesBureau> {
  static const Color _oranje = Color(0xFFF15A24);
  static const Color _donker = Color(0xFF20252B);
  static const Color _rand = Color(0xFFE3E6E9);
  static const Color _grijs = Color(0xFF66717D);
  static const String _wachtrijSleutel =
      'thimaco_iphone_bureaunotities_wachtrij_v1';

  final _klant = TextEditingController();
  final _notitie = TextEditingController();
  final _picker = ImagePicker();
  final _inbox = ThimacoIphoneBureauInboxService();
  final _fotos = <File>[];
  bool _bezig = false;
  int _concepten = 0;
  bool _aanmelden = false;
  String? _openConceptId;

  @override
  void initState() {
    super.initState();
    _leesAantalConcepten();
  }

  @override
  void dispose() {
    _klant.dispose();
    _notitie.dispose();
    super.dispose();
  }

  Future<void> _leesAantalConcepten() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final records = _leesWachtrij(prefs.getString(_wachtrijSleutel));
      if (mounted) setState(() => _concepten = _aantalNogTeVerzenden(records));
    } catch (_) {
      if (mounted) _melding('De lokale notitiewachtrij kon niet geopend worden.');
    }
  }

  List<Map<String, dynamic>> _leesWachtrij(String? bron) {
    if (bron == null || bron.isEmpty) return [];
    try {
      final parsed = jsonDecode(bron);
      if (parsed is! List) return [];
      return parsed
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      // Niet stilzwijgend de bestaande wachtrij overschrijven.
      throw const FormatException('Wachtrij kon niet gelezen worden.');
    }
  }

  int _aantalNogTeVerzenden(List<Map<String, dynamic>> records) =>
      records.where((r) => r['status'] != 'aangeboden_aan_bureau').length;

  Future<void> aanmeldenMicrosoft() async {
    if (_aanmelden || _bezig) return;
    setState(() => _aanmelden = true);
    try {
      await _inbox.aanmeldenMicrosoft();
      if (mounted) _melding('Microsoft aangemeld. Je kunt de notitie nu verzenden.');
    } catch (fout) {
      if (mounted) _melding('Microsoft-aanmelding niet gelukt: $fout');
    } finally {
      if (mounted) setState(() => _aanmelden = false);
    }
  }

  Future<void> _verzendWachtrijOpnieuw() async {
    if (_bezig || _aanmelden) return;
    setState(() => _bezig = true);
    var gelukt = 0;
    var foutmelding = '';
    try {
      final prefs = await SharedPreferences.getInstance();
      final records = _leesWachtrij(prefs.getString(_wachtrijSleutel));
      for (final record in records) {
        if (record['status'] == 'aangeboden_aan_bureau') continue;
        try {
          await _inbox.publiceerNotitie(record);
          record['status'] = 'aangeboden_aan_bureau';
          record['aangebodenOp'] = DateTime.now().toIso8601String();
          if (!await prefs.setString(_wachtrijSleutel, jsonEncode(records))) {
            throw StateError('Ontvangststatus niet lokaal bewaard.');
          }
          gelukt++;
        } catch (fout) {
          foutmelding = '$fout';
          break; // Bij authenticatiefout geen extra uploads proberen.
        }
      }
      if (mounted) {
        setState(() => _concepten = _aantalNogTeVerzenden(records));
        _melding(foutmelding.isEmpty
            ? '$gelukt notitie(s) aangeboden aan de bureau-inbox in OneDrive.'
            : '$gelukt verzonden; volgende poging nodig: $foutmelding');
      }
    } catch (fout) {
      if (mounted) _melding('Wachtrij kon niet worden verzonden: $fout');
    } finally {
      if (mounted) setState(() => _bezig = false);
    }
  }

  Future<Directory> _fotoMap() async {
    final docs = await getApplicationDocumentsDirectory();
    final map = Directory('${docs.path}/thimaco_iphone/bureaunotities/fotos');
    if (!await map.exists()) await map.create(recursive: true);
    return map;
  }

  Future<void> _neemFoto() async {
    if (_bezig) return;
    if (_fotos.length >= 5) {
      _melding('Maximaal vijf foto\'s per notitie.');
      return;
    }
    try {
      // Camera werkt op de echte iPhone. Voor de Windows-preview gebruiken we
      // de bestandskiezer; zo kan de schermindeling alvast getest worden.
      final keuze = await _picker.pickImage(
        source: !kIsWeb && Platform.isIOS
            ? ImageSource.camera
            : ImageSource.gallery,
        imageQuality: 65,
        maxWidth: 1400,
        maxHeight: 1400,
      );
      if (keuze == null) return;
      final map = await _fotoMap();
      final nu = DateTime.now().microsecondsSinceEpoch;
      final naam = keuze.name.toLowerCase();
      final extensie = naam.endsWith('.png') ? 'png' :
          naam.endsWith('.webp') ? 'webp' :
          naam.endsWith('.heic') ? 'heic' : 'jpg';
      final doel = File('${map.path}/notitie_${nu}_${_fotos.length}.$extensie');
      await File(keuze.path).copy(doel.path);
      if (!mounted) return;
      setState(() => _fotos.add(doel));
    } on PlatformException catch (fout) {
      if (!mounted) return;
      if (fout.code == 'camera_access_denied' ||
          fout.code == 'camera_access_restricted') {
        await showDialog<void>(
          context: context,
          builder: (dialoog) => AlertDialog(
            title: const Text('Camera toegang'),
            content: const Text(
              'Zet camera aan voor Thimaco bij Instellingen → Privacy en beveiliging → Camera. Probeer daarna opnieuw een foto te nemen.',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialoog).pop(),
                child: const Text('OK')),
            ],
          ),
        );
      } else {
        _melding('Foto nemen mislukt: $fout');
      }
    } catch (fout) {
      if (mounted) _melding('Foto nemen mislukt: $fout');
    }
  }

  Future<void> _verwijderFoto(File foto) async {
    // Alleen uit het formulier verwijderen. Het bestand blijft voorlopig
    // staan: mogelijk verwijst een reeds opgeslagen concept er nog naar.
    // Definitief opruimen kan pas bij een bevestigde synchronisatie.
    if (mounted) setState(() => _fotos.remove(foto));
  }

  void _melding(String bericht) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(bericht)));
  }

  // Aangeroepen door de centrale zwarte titelbalk, zodat de V op dezelfde
  // positie staat als alle andere titelacties.
  bool get heeftOnbevestigdeWijzigingen =>
      _klant.text.isNotEmpty || _notitie.text.isNotEmpty || _fotos.isNotEmpty;
  bool get bevestigingBezig => _bezig || _aanmelden;

  Future<void> bewaarVoorVerzending() => _bewaarVoorVerzending();

  Future<void> _bewaarVoorVerzending() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_bezig || _aanmelden) return;
    final naam = _klant.text.trim();
    final tekst = _notitie.text.trim();
    if (naam.isEmpty || tekst.isEmpty) {
      _melding('Vul een klantnaam en notitie in.');
      return;
    }
    setState(() => _bezig = true);
    try {
      // Altijd EERST lokaal bewaren. Een ontbrekend internet- of Microsoft-
      // token mag nooit een klantnotitie of foto laten verdwijnen.
      final prefs = await SharedPreferences.getInstance();
      final wachtrij = _leesWachtrij(prefs.getString(_wachtrijSleutel));
      final nu = DateTime.now();
      final oudIndex = _openConceptId == null
          ? -1 : wachtrij.indexWhere((r) => r['id'] == _openConceptId);
      final record = <String, dynamic>{
        'id': oudIndex < 0 ? 'iphone-${nu.microsecondsSinceEpoch}' : _openConceptId!,
        'klantnaam': naam,
        'notitie': tekst,
        'aangemaaktOp': nu.toIso8601String(),
        'fotos': _fotos.map((foto) => foto.path).toList(growable: false),
        'status': 'wacht_op_verzending',
      };
      if (oudIndex < 0) {
        wachtrij.add(record);
      } else {
        wachtrij[oudIndex] = record;
      }
      final bewaard = await prefs.setString(_wachtrijSleutel, jsonEncode(wachtrij));
      if (!bewaard) throw StateError('Lokale opslag niet bevestigd.');

      var aangeboden = false;
      String? foutmelding;
      try {
        await _inbox.publiceerNotitie(record);
        record['status'] = 'aangeboden_aan_bureau';
        record['aangebodenOp'] = DateTime.now().toIso8601String();
        // Bij mislukte lokale statusopslag wordt de upload bij een nieuwe
        // poging met dezelfde ID veilig herhaald (geen dubbele bureaunotitie).
        if (!await prefs.setString(_wachtrijSleutel, jsonEncode(wachtrij))) {
          throw StateError('Ontvangststatus kon niet lokaal worden bewaard.');
        }
        aangeboden = true;
      } catch (fout) {
        foutmelding = '$fout';
      }
      if (!mounted) return;
      setState(() {
        _concepten = _aantalNogTeVerzenden(wachtrij);
        _openConceptId = null;
        _fotos.clear();
        _klant.clear();
        _notitie.clear();
      });
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(aangeboden ? 'Aangeboden aan bureau' : 'Notitie lokaal bewaard'),
          content: Text(aangeboden
              ? 'De notitie en alle foto\'s zijn in OneDrive ontvangen. '
                'De bureau-app moet ze nog ophalen. Controleer de ontvangst op bureau.'
              : 'Notitie en foto\'s staan veilig op dit toestel. '
                'NOG NIET naar bureau verstuurd. '
                'Meld je aan bij Microsoft en probeer de wachtrij opnieuw. '
                'Reden: ${foutmelding ?? 'onbekend'}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Begrepen'),
            ),
          ],
        ),
      );
    } catch (fout) {
      if (mounted) _melding('Notitie kon niet bewaard worden: $fout');
    } finally {
      if (mounted) setState(() => _bezig = false);
    }
  }

  Future<void> _toonWachtrij() async {
    List<Map<String, dynamic>> wachtrij;
    try {
      final prefs = await SharedPreferences.getInstance();
      wachtrij = _leesWachtrij(prefs.getString(_wachtrijSleutel))
          .where((r) => r['status'] != 'aangeboden_aan_bureau').toList();
    } catch (fout) {
      _melding('Wachtrij openen mislukt: $fout');
      return;
    }
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nog niet verzonden', style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Deze notities staan uitsluitend op dit toestel.',
                  style: TextStyle(color: _grijs, fontSize: 13)),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 350),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: wachtrij.length,
                  itemBuilder: (context, index) {
                    final item = wachtrij[index];
                    final titel = (item['klantnaam'] ?? '').toString();
                    final tekst = (item['notitie'] ?? '').toString();
                    final fotos = item['fotos'];
                    final aantal = fotos is List ? fotos.length : 0;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(titel, style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text('$tekst\n$aantal foto’s',
                          maxLines: 3, overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.edit_outlined,
                          color: _oranje),
                      onTap: () async {
                        // Laat niets verdwijnen zonder de gebruiker te waarschuwen.
                        if (_klant.text.isNotEmpty || _notitie.text.isNotEmpty ||
                            _fotos.isNotEmpty) {
                          _melding('Bewaar eerst de notitie die je nu schrijft.');
                          return;
                        }
                        final prefs = await SharedPreferences.getInstance();
                        final actuele = _leesWachtrij(
                            prefs.getString(_wachtrijSleutel));
                        final id = item['id'];
                        final gevonden = actuele.indexWhere((r) => r['id'] == id);
                        if (gevonden == -1) return;
                        final keuze = actuele[gevonden];
                        // De bron blijft in de wachtrij totdat expliciet
                        // opnieuw bewaard wordt: voorkomt verlies bij afsluiten.
                        if (!mounted || !ctx.mounted) return;
                        setState(() {
                          _openConceptId = (keuze['id'] ?? '').toString();
                          _klant.text = (keuze['klantnaam'] ?? '').toString();
                          _notitie.text = (keuze['notitie'] ?? '').toString();
                          _fotos.clear();
                          final bronnen = keuze['fotos'];
                          if (bronnen is List) {
                            _fotos.addAll(bronnen.whereType<String>().map(File.new));
                          }
                        });
                        Navigator.of(ctx).pop();
                        _melding('Concept geopend. Het origineel blijft veilig in de wachtrij.');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cirkel({required IconData icoon, required Color kleur,
      required VoidCallback actie, required String tooltip}) =>
      Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: actie,
          customBorder: const CircleBorder(),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: kleur, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icoon, color: Colors.white, size: 20),
          ),
        ),
      );

  InputDecoration _decoratie(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 14, color: _grijs),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: _rand),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: _oranje),
      borderRadius: BorderRadius.circular(10),
    ),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 3, 14, 20),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: _rand),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Klantnaam', style: TextStyle(
                            color: _donker, fontWeight: FontWeight.w600,
                            fontSize: 13)),
                        const SizedBox(height: 7),
                        TextField(
                          controller: _klant,
                          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          decoration: _decoratie('Naam van de klant'),
                        ),
                        const SizedBox(height: 22),
                        const Text('Notitie', style: TextStyle(
                            color: _donker, fontWeight: FontWeight.w600,
                            fontSize: 13)),
                        const SizedBox(height: 7),
                        TextField(
                          controller: _notitie,
                          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                          minLines: 7,
                          maxLines: 14,
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: _decoratie('Notitie voor de klant hier invullen'),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _cirkel(
                              icoon: Icons.camera_alt_outlined,
                              kleur: _donker,
                              actie: _neemFoto,
                              tooltip: 'Foto maken of kiezen',
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Foto toevoegen (${_fotos.length}/5)',
                                style: const TextStyle(color: _donker,
                                    fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        if (_fotos.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (final foto in _fotos)
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        foto,
                                        width: 85,
                                        height: 85,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      right: -5,
                                      top: -5,
                                      child: InkWell(
                                        onTap: () => _verwijderFoto(foto),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: _oranje,
                                            shape: BoxShape.circle,
                                          ),
                                          width: 25,
                                          height: 25,
                                          alignment: Alignment.center,
                                          child: const Icon(
                                              Icons.delete_outline_rounded,
                                              color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_concepten > 0) ...[
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: _toonWachtrij,
                      icon: const Icon(Icons.inventory_2_outlined,
                          color: _donker, size: 17),
                      label: Text('Wachtrij openen ($_concepten)',
                          style: const TextStyle(color: _donker)),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    if (_concepten > 0)
                      TextButton.icon(
                        onPressed: _bezig || _aanmelden ? null : _verzendWachtrijOpnieuw,
                        icon: const Icon(Icons.cloud_upload_outlined, size: 17),
                        label: Text('Wachtrij versturen ($_concepten)'),
                      ),
                  ]),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
