import 'dart:async';

import 'package:flutter/material.dart';

import '../helpers/Agenda/agenda_datum_helper.dart';
import '../helpers/app_storage.dart';
import '../helpers/Agenda/agenda_item.dart';
import '../helpers/Agenda/agenda_kleur_service.dart';
import '../helpers/Agenda/agenda_repository.dart';
import '../helpers/Agenda/agenda_toevoeg_service.dart';
import '../helpers/sync/onedrive_auth_service.dart';
import '../helpers/sync/onedrive_sync_service.dart';
import '../helpers/sync/sync_navigatie_helper.dart';
import 'thimaco_iphone_afspraak_dialoog.dart';
import 'thimaco_iphone_dagweergave.dart';

/// iPhone-achtige agenda met een schermvullend weekraster en kleine
/// afspraaktegels. Alle gegevens komen uit de bestaande AgendaRepository.
/// Geen extra opslag en geen aanpassing van de Windows-agenda.
class ThimacoIphoneAgenda extends StatefulWidget {
  const ThimacoIphoneAgenda({super.key, this.onTerugNaarDashboard});

  final VoidCallback? onTerugNaarDashboard;

  @override
  State<ThimacoIphoneAgenda> createState() => ThimacoIphoneAgendaState();
}

class ThimacoIphoneAgendaState extends State<ThimacoIphoneAgenda> {
  static const Color _oranje = Color(0xFFF15A24);
  static const Color _donker = Color(0xFF20252B);
  static const Color _rand = Color(0xFFE9EBEF);
  static const Color _blauw = Color(0xFF2563EB);
  static const Color _subtekst = Color(0xFF66717D);
  static const List<String> _weekdagen = ['M', 'D', 'W', 'D', 'V', 'Z', 'Z'];
  static const List<String> _maandnamen = [
    'Januari', 'Februari', 'Maart', 'April', 'Mei', 'Juni',
    'Juli', 'Augustus', 'September', 'Oktober', 'November', 'December',
  ];
  static const int _maxTegelsPerDag = 5;

  // Mobiele filter is onafhankelijk van de filters in de Windows-app.
  // Bij openen staan uitsluitend blauwe afspraken en verlof aan.
  static const Set<String> _standaardFilters = {'blauw', 'verlof', 'showroom'};
  static const List<(String, String, Color)> _filterKeuzes = [
    ('blauw', 'Blauwe afspraken', Color(0xFF2563EB)),
    ('verlof', 'Verlof', Color(0xFFE24A4A)),
    ('planning', 'Planning / plaatsing', Color(0xFF374151)),
    ('opvolging', 'Opvolging', Color(0xFFEAB308)),
    ('nadienst', 'Nadienst', Color(0xFF9333EA)),
    ('showroom', 'Website-showroom', Color(0xFF5092CE)),
    ('dagtaak', 'Dagtaken', Color(0xFFF06418)),
    ('kraan', 'Kraan', Color(0xFF795548)),
    ('andere', 'Andere', Color(0xFF9CA3AF)),
  ];
  Set<String> _actieveFilters = {..._standaardFilters};

  DateTime _maand = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _dag = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  Map<String, List<AgendaItem>> _items = {};
  bool _laden = true;
  bool _bewaren = false;
  Future<void>? _lopendeSync;
  String? _fout;
  int _laatsteDownloadVersie = 0;
  VoidCallback? _verversDag;
  List<GlobalKey> _weekSleutels = [];
  bool _eersteScroll = true;
  double _horizontaleSleep = 0;

  @override
  void initState() {
    super.initState();
    _maakWeekSleutels();
    _laatsteDownloadVersie = SyncNavigatieHelper.downloadVersie.value;
    SyncNavigatieHelper.downloadVersie.addListener(_naDownload);
    unawaited(_herlaad());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _eersteScroll) {
        _eersteScroll = false;
        _scrollNaarDag(_dag, geanimeerd: false);
      }
    });
  }

  @override
  void dispose() {
    SyncNavigatieHelper.downloadVersie.removeListener(_naDownload);
    super.dispose();
  }

  Future<void> synchroniseer({bool handmatig = false, bool naWijziging = false}) async {
    if (_bewaren || !mounted) return;
    final lopend = _lopendeSync;
    if (lopend != null) {
      await lopend;
      if (!handmatig || !mounted || _bewaren) return;
      if (_lopendeSync != null) return;
    }
    final taak = _synchroniseer(handmatig: handmatig, naWijziging: naWijziging);
    _lopendeSync = taak;
    try {
      await taak;
    } finally {
      if (identical(_lopendeSync, taak)) _lopendeSync = null;
    }
  }

  Future<void> _synchroniseer({required bool handmatig, required bool naWijziging}) async {
    final sync = OneDriveSyncService();
    try {
      var resultaat = await sync.syncAgendaSnel();
      if (handmatig && mounted &&
          resultaat == 'SYNC_AGENDA_GEEN_ONEDRIVE_LOGIN') {
        final login = await OneDriveAuthService().loginInteractief();
        if (login.isNotEmpty && !login.startsWith('FOUT')) {
          resultaat = await sync.syncAgendaSnel();
        }
      }
      if (!mounted) return;
      if (resultaat == 'IMPORT_OK_AGENDA' || resultaat == 'SYNC_AGENDA_OK') {
        await _herlaad();
        _verversDag?.call();
        if ((handmatig || naWijziging) && mounted) _syncMelding('Agenda gesynchroniseerd.');
      } else if (handmatig || naWijziging) {
        _syncMelding(resultaat == 'SYNC_AGENDA_GEEN_ONEDRIVE_LOGIN'
            ? 'Meld je aan bij Microsoft om de bureauagenda te synchroniseren.'
            : naWijziging
                ? 'Lokaal bewaard. Synchronisatie met bureau nog niet gelukt.'
                : 'Agenda synchroniseren mislukt. Probeer opnieuw.');
      }
    } catch (_) {
      if ((handmatig || naWijziging) && mounted) {
        _syncMelding('Agenda synchroniseren mislukt. Probeer opnieuw.');
      }
    }
  }

  void _syncMelding(String melding) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(melding)),
    );
  }

  void _naDownload() {
    final versie = SyncNavigatieHelper.downloadVersie.value;
    if (versie <= _laatsteDownloadVersie) return;
    _laatsteDownloadVersie = versie;
    if (!_bewaren) unawaited(_herlaad());
  }

  Future<void> _herlaad() async {
    if (!mounted) return;
    setState(() {
      _laden = true;
      _fout = null;
    });
    try {
      final nieuw = await AgendaRepository.laadItems();
      if (!mounted) return;
      setState(() {
        _items = nieuw;
        _laden = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _fout = 'Agenda laden mislukt: $e';
        _laden = false;
      });
    }
  }

  String _filterType(AgendaItem item) {
    if (item.type == 'afspraak') {
      // Handmatige showroomafspraken zijn gewone blauwe afspraken met huisje.
      // Websiteboekingen houden hun afzonderlijke showroomfilter.
      return item.isWebsiteShowroomAfspraak ? 'showroom' : 'blauw';
    }
    return switch (item.type) {
      'verlof' => 'verlof',
      'planning' => 'planning',
      'opvolging' => 'opvolging',
      'nadienst' => 'nadienst',
      'dagtaak' => 'dagtaak',
      'kraan' => 'kraan',
      _ => 'andere',
    };
  }

  List<AgendaItem> _itemsVoor(DateTime dag) {
    final sleutel = AgendaDatumHelper.datumKey(dag);
    final lijst = (_items[sleutel] ?? const <AgendaItem>[])
        .where((item) => !item.isVerwijderd &&
            _actieveFilters.contains(_filterType(item)))
        .toList();
    lijst.sort((a, b) {
      final au = a.startUur ?? -1;
      final bu = b.startUur ?? -1;
      final c = au.compareTo(bu);
      return c != 0 ? c : (a.startMinuut ?? 0).compareTo(b.startMinuut ?? 0);
    });
    return lijst;
  }

  bool _zelfdeDag(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime get _eersteWeekdag {
    final eerste = DateTime(_maand.year, _maand.month, 1);
    return eerste.subtract(Duration(days: eerste.weekday - 1));
  }

  int get _aantalWeken {
    final offset = DateTime(_maand.year, _maand.month, 1).weekday - 1;
    final dagen = DateTime(_maand.year, _maand.month + 1, 0).day;
    return (offset + dagen + 6) ~/ 7;
  }

  void _maakWeekSleutels() {
    _weekSleutels = List<GlobalKey>.generate(
      _aantalWeken, (_) => GlobalKey(),
    );
  }

  void _scrollNaarDag(DateTime dag, {bool geanimeerd = true}) {
    if (dag.year != _maand.year || dag.month != _maand.month) return;
    final index = (DateTime(_maand.year, _maand.month, 1).weekday - 1 + dag.day - 1) ~/ 7;
    if (index < 0 || index >= _weekSleutels.length) return;
    final doel = _weekSleutels[index].currentContext;
    if (doel == null) return;
    Scrollable.ensureVisible(
      doel,
      alignment: 0,
      duration: geanimeerd ? const Duration(milliseconds: 260) : Duration.zero,
      curve: Curves.easeOutCubic,
    );
  }

  void _kiesMaand(int verschil) {
    final volgende = DateTime(_maand.year, _maand.month + verschil);
    setState(() {
      _maand = volgende;
      final laatste = DateTime(volgende.year, volgende.month + 1, 0).day;
      _dag = DateTime(volgende.year, volgende.month, _dag.day.clamp(1, laatste));
      _maakWeekSleutels();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollNaarDag(DateTime(_maand.year, _maand.month, 1), geanimeerd: false);
    });
  }

  void _vandaag() {
    final nu = DateTime.now();
    final nieuw = DateTime(nu.year, nu.month, nu.day);
    setState(() {
      _dag = nieuw;
      if (_maand.year != nieuw.year || _maand.month != nieuw.month) {
        _maand = DateTime(nieuw.year, nieuw.month);
        _maakWeekSleutels();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollNaarDag(nieuw);
    });
  }

  String _tijdKort(AgendaItem item) {
    if (item.volledigeDag || item.startUur == null) return 'Hele dag';
    return '${item.startUur!.toString().padLeft(2, '0')}:${(item.startMinuut ?? 0).toString().padLeft(2, '0')}';
  }

  String _tijd(AgendaItem a) {
    if (a.volledigeDag || a.startUur == null) return 'Hele dag';
    String t(int? uur, int? minuut) =>
        '${(uur ?? 0).toString().padLeft(2, '0')}:${(minuut ?? 0).toString().padLeft(2, '0')}';
    return '${t(a.startUur, a.startMinuut)} – ${t(a.eindUur, a.eindMinuut)}';
  }

  String _tegelTitel(AgendaItem item) {
    final klant = item.naamKlant.trim();
    final titel = item.titel.trim();
    if (klant.isEmpty) return titel.isEmpty ? 'Afspraak' : titel;
    if (titel.isEmpty || klant.toLowerCase() == titel.toLowerCase()) return klant;
    return '$klant · $titel';
  }

  Color _itemKleur(AgendaItem item) {
    // Handmatige showroomafspraken blijven blauw, met een extra huisje.
    if (item.type == 'afspraak' && !item.isWebsiteShowroomAfspraak) return _blauw;
    return AgendaKleurService.kleur(item.type);
  }

  Widget _tekstKnop(String tekst, VoidCallback? actie) => TextButton(
        onPressed: actie,
        style: TextButton.styleFrom(
          foregroundColor: _donker,
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(tekst, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          const SizedBox(height: 3),
          Container(height: 2, width: 30, color: _oranje),
        ]),
      );

  bool _verplaatsbaar(AgendaItem item) =>
      item.type == 'afspraak' && !item.isWebsiteShowroomAfspraak;

  Future<bool> _wijzigTijd(DateTime dag, AgendaItem item) async {
    final start = await toonThimacoAgendaKlok(
      context,
      TimeOfDay(hour: item.startUur ?? 9, minute: item.startMinuut ?? 0),
      'Nieuw beginuur',
    );
    if (!mounted || start == null) return false;
    final begin = start.hour * 60 + start.minute;
    final oudBegin = (item.startUur ?? 9) * 60 + (item.startMinuut ?? 0);
    final oudEinde = (item.eindUur ?? 10) * 60 + (item.eindMinuut ?? 0);
    final eindMinuten = (begin + (oudEinde - oudBegin).clamp(5, 1435))
        .clamp(0, 1435).toInt();
    final eind = await toonThimacoAgendaKlok(
      context, TimeOfDay(hour: eindMinuten ~/ 60, minute: eindMinuten % 60),
      'Nieuw einduur',
    );
    if (!mounted || eind == null) return false;
    return _verplaatsAfspraak(dag, item, dag, begin, eind.hour * 60 + eind.minute);
  }

  Future<bool> _verplaatsAfspraak(
    DateTime van, AgendaItem item, DateTime naar, int? begin, [int? einde]
  ) async {
    if (!_verplaatsbaar(item) || _bewaren || !mounted) return false;
    setState(() => _bewaren = true);
    var gewijzigd = false;
    try {
      await _lopendeSync;
      if (!mounted) return false;
      final actueel = await AppStorage.laadAgendaItemsNieuwVoorSync();
      final bron = AgendaDatumHelper.datumKey(van);
      final doel = AgendaDatumHelper.datumKey(naar);
      final lijst = actueel[bron] ?? <AgendaItem>[];
      final index = lijst.indexWhere((a) => a.id == item.id && !a.isVerwijderd);
      if (index < 0 || lijst[index].updatedAt != item.updatedAt) {
        _syncMelding('Deze afspraak is gewijzigd. Vernieuw de agenda.');
        return false;
      }
      final huidig = lijst[index];
      final gegevens = huidig.toJson();
      if (begin != null) {
        final oudBegin = (huidig.startUur ?? 9) * 60 + (huidig.startMinuut ?? 0);
        final oudEinde = (huidig.eindUur ?? 10) * 60 + (huidig.eindMinuut ?? 0);
        final stop = einde ?? (begin + (oudEinde - oudBegin).clamp(5, 1439))
            .clamp(0, 1439).toInt();
        if (stop <= begin) {
          _syncMelding('Het einduur moet na het beginuur liggen.');
          return false;
        }
        gegevens.addAll({
          'volledigeDag': false,
          'startUur': begin ~/ 60,
          'startMinuut': begin % 60,
          'eindUur': stop ~/ 60,
          'eindMinuut': stop % 60,
        });
      }
      gegevens['updatedAt'] = DateTime.now().toUtc().toIso8601String();
      final verplaatst = AgendaItem.fromJson(gegevens);
      actueel[bron] = [...lijst]..removeAt(index);
      final overlap = AgendaToevoegService.kanItemToevoegen(
        dag: naar, nieuwItem: verplaatst, itemsPerDag: actueel,
      );
      if (!mounted) return false;
      if (overlap != null && overlap.isNotEmpty) {
        final akkoord = await showDialog<bool>(
          context: context,
          builder: (dialoog) => AlertDialog(
            title: const Text('Mogelijke overlap'),
            content: Text(overlap),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialoog, false),
                child: const Text('Annuleren')),
              TextButton(onPressed: () => Navigator.pop(dialoog, true),
                child: const Text('Toch bewaren')),
            ],
          ),
        );
        if (!mounted || akkoord != true) return false;
      }
      actueel[doel] = [...?actueel[doel], verplaatst];
      await AppStorage.bewaarAgendaItemsNieuw(actueel);
      final bewaard = await AppStorage.laadAgendaItemsNieuwVoorSync();
      gewijzigd = (bewaard[doel] ?? const <AgendaItem>[]).any(
        (a) => a.syncId == verplaatst.syncId &&
            a.updatedAt == verplaatst.updatedAt &&
            a.startUur == verplaatst.startUur &&
            a.startMinuut == verplaatst.startMinuut &&
            a.eindUur == verplaatst.eindUur &&
            a.eindMinuut == verplaatst.eindMinuut,
      );
      if (!gewijzigd) {
        if (mounted) _syncMelding('Afspraak kon niet worden verplaatst. Vernieuw de agenda.');
        return false;
      }
      await _herlaad();
      _verversDag?.call();
      return true;
    } catch (fout) {
      if (mounted) _syncMelding('Afspraak aanpassen mislukt: $fout');
      return false;
    } finally {
      if (mounted) {
        setState(() => _bewaren = false);
        if (gewijzigd) unawaited(synchroniseer(naWijziging: true));
      }
    }
  }

  Widget _sleepbareTegel(AgendaItem item, DateTime dag) {
    final tegel = _afspraakTegel(item, dag);
    if (!_verplaatsbaar(item)) return tegel;
    return LongPressDraggable<({DateTime dag, AgendaItem item})>(
      data: (dag: dag, item: item),
      feedback: Material(
        color: Colors.white, elevation: 4,
        child: Padding(padding: const EdgeInsets.all(8), child: Text(_tegelTitel(item))),
      ),
      child: tegel,
    );
  }

  Widget _afspraakTegel(AgendaItem item, DateTime dag) {
    final kleur = _itemKleur(item);
    final achtergrond = Color.lerp(Colors.white, kleur, 0.21)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: achtergrond,
        borderRadius: BorderRadius.circular(5),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: () => _toonDag(dag, geselecteerd: item),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 46),
            padding: const EdgeInsets.fromLTRB(4, 4, 2, 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (item.isShowroomAfspraak) ...[
                    const Icon(Icons.home_outlined, size: 11, color: _donker),
                    const SizedBox(width: 2),
                  ],
                  Expanded(child: Text(
                    _tegelTitel(item),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _donker, fontWeight: FontWeight.w700,
                      fontSize: 10.5, height: 1.17,
                    ),
                  )),
                ]),
                const SizedBox(height: 2),
                Text(
                  _tijdKort(item),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    color: Color.lerp(_donker, kleur, 0.52),
                    fontSize: 10, height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dagKolom(DateTime datum) {
    final binnenMaand = datum.month == _maand.month && datum.year == _maand.year;
    if (!binnenMaand) return const SizedBox.shrink();
    final afspraken = _itemsVoor(datum);
    final vandaag = _zelfdeDag(datum, DateTime.now());
    final geselecteerd = _zelfdeDag(datum, _dag);
    final weekend = datum.weekday >= 6;
    final accent = vandaag ? _oranje : (geselecteerd ? _donker : Colors.transparent);
    final kolom = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 43,
            child: Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => _toonDag(datum),
                child: Container(
                  alignment: Alignment.center,
                  width: 29,
                  height: 29,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    '${datum.day}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: vandaag || geselecteerd
                          ? Colors.white
                          : (weekend ? const Color(0xFF9BA0A7) : _donker),
                    ),
                  ),
                ),
              ),
            ),
          ),
          for (final item in afspraken.take(_maxTegelsPerDag))
            _sleepbareTegel(item, datum),
          if (afspraken.length > _maxTegelsPerDag)
            InkWell(
              onTap: () => _toonDag(datum),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Text(
                  '+${afspraken.length - _maxTegelsPerDag} meer',
                  style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w800, color: _donker,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    return DragTarget<({DateTime dag, AgendaItem item})>(
      onWillAcceptWithDetails: (details) => !_zelfdeDag(details.data.dag, datum),
      onAcceptWithDetails: (details) {
        _verplaatsAfspraak(details.data.dag, details.data.item, datum, null);
      },
      builder: (context, kandidaten, _) => DecoratedBox(
        decoration: BoxDecoration(
          color: kandidaten.isEmpty ? Colors.transparent : const Color(0xFFFFEEE5),
        ),
        child: kolom,
      ),
    );
  }

  Widget _weekRij(int nummer) {
    final maandag = _eersteWeekdag.add(Duration(days: nummer * 7));
    final dagen = List<DateTime>.generate(
      7, (index) => maandag.add(Duration(days: index)),
    );
    return Container(
      key: _weekSleutels[nummer],
      constraints: const BoxConstraints(minHeight: 150),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _rand, width: 1)),
      ),
      padding: const EdgeInsets.only(top: 4, bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final dag in dagen)
            Expanded(child: _dagKolom(dag)),
        ],
      ),
    );
  }

  Future<void> _toonDag(DateTime dag, {AgendaItem? geselecteerd}) async {
    if (!mounted) return;
    setState(() => _dag = dag);
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ThimacoIphoneDagweergave(
          beginDag: dag,
          geselecteerd: geselecteerd,
          itemsVoor: _itemsVoor,
          wijzigTijd: _wijzigTijd,
          verplaatsAfspraak: _verplaatsAfspraak,
          registreerVerversing: (actie) => _verversDag = actie,
          dagGewijzigd: (datum) => _dag = datum,
          herlaad: _herlaad,
          verwijderAfspraak: _verwijderAfspraak,
        ),
      ),
    );
    _verversDag = null;
    if (mounted) unawaited(_herlaad());
  }

  Future<void> _openFilters() async {
    final tijdelijk = <String>{..._actieveFilters};
    final gekozen = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: FractionallySizedBox(
          heightFactor: 0.72,
          child: StatefulBuilder(builder: (context, wijzig) =>
            Column(children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: _rand)),
                ),
                child: Row(children: [
                  Container(width: 3, height: 23, color: _oranje),
                  const SizedBox(width: 10),
                  const Expanded(child: Text('Agenda filteren',
                      style: TextStyle(
                        fontSize: 18, color: _donker,
                        fontWeight: FontWeight.w800,
                      ))),
                  IconButton(
                    tooltip: 'Filters toepassen',
                    onPressed: () => Navigator.of(sheetContext).pop(tijdelijk),
                    style: IconButton.styleFrom(
                      backgroundColor: _oranje, foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.check_rounded),
                  ),
                ]),
              ),
              Expanded(child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 7),
                children: [
                  for (final (code, titel, kleur) in _filterKeuzes)
                    InkWell(
                      onTap: () => wijzig(() {
                        if (!tijdelijk.remove(code)) tijdelijk.add(code);
                      }),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 17, vertical: 11),
                        child: Row(children: [
                          Container(width: 8, height: 8,
                              decoration: BoxDecoration(
                                color: kleur, shape: BoxShape.circle,
                              )),
                          const SizedBox(width: 12),
                          Expanded(child: Text(titel,
                              style: const TextStyle(color: _donker))),
                          Icon(
                            tijdelijk.contains(code)
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 25,
                            color: tijdelijk.contains(code)
                                ? _donker : _subtekst,
                          ),
                        ]),
                      ),
                    ),
                ],
              )),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: Row(children: [
                  _tekstKnop('Standaard', () => wijzig(() {
                    tijdelijk..clear()..addAll(_standaardFilters);
                  })),
                  const Spacer(),
                  _tekstKnop('Toepassen',
                      () => Navigator.of(sheetContext).pop(tijdelijk)),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
    if (!mounted || gekozen == null) return;
    setState(() => _actieveFilters = {...gekozen});
  }

  Future<void> _zoek() async {
    final controller = TextEditingController();
    final gekozen = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        final schermHoogte = MediaQuery.sizeOf(sheetContext).height;
        final toetsenbord = MediaQuery.viewInsetsOf(sheetContext).bottom;
        final beschikbareHoogte = (schermHoogte - toetsenbord - 48).clamp(160.0, schermHoogte).toDouble();
        final zoekHoogte = (schermHoogte * 0.58).clamp(160.0, beschikbareHoogte).toDouble();
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, toetsenbord + 12),
          child: SizedBox(
            height: zoekHoogte,
            child: StatefulBuilder(builder: (ctx, wijzig) {
            final vraag = controller.text.trim().toLowerCase();
            final dagen = DateTime(_maand.year, _maand.month + 1, 0).day;
            final matches = <DateTime>[];
            if (vraag.isNotEmpty) {
              for (var d = 1; d <= dagen; d++) {
                final dag = DateTime(_maand.year, _maand.month, d);
                if (_itemsVoor(dag).any((item) =>
                    '${item.naamKlant} ${item.titel} ${item.opmerkingen}'
                        .toLowerCase().contains(vraag))) {
                  matches.add(dag);
                }
              }
            }
            return Column(children: [
              TextField(
                controller: controller,
                autofocus: true,
                onChanged: (_) => wijzig(() {}),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  hintText: 'Zoek afspraken in ${_maandnamen[_maand.month - 1]}',
                  filled: true,
                  fillColor: const Color(0xFFF5F6F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(child: ListView.builder(
                itemCount: matches.length,
                itemBuilder: (ctx, index) {
                  final dag = matches[index];
                  final items = _itemsVoor(dag).where((item) =>
                      '${item.naamKlant} ${item.titel} ${item.opmerkingen}'
                          .toLowerCase().contains(vraag)).toList();
                  return ListTile(
                    title: Text('${dag.day} ${_maandnamen[dag.month - 1]}'),
                    subtitle: Text(items.map(_tegelTitel).join(' · '),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(sheetContext).pop(dag),
                  );
                },
              )),
            ]);
            }),
          ),
        );
      },
    );
    controller.dispose();
    if (!mounted || gekozen == null) return;
    await _toonDag(gekozen);
  }

  Future<bool> _verwijderAfspraak(DateTime dag, AgendaItem item) async {
    if (!mounted || item.type != 'afspraak') return false;
    final bevestigd = await showDialog<bool>(
      context: context,
      builder: (dialoogContext) => AlertDialog(
        title: const Text('Afspraak wissen?'),
        content: Text('Wil je de afspraak van ${_tegelTitel(item)} definitief wissen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialoogContext, false),
            child: const Text('Annuleren'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialoogContext, true),
            child: const Text('Wissen', style: TextStyle(color: _oranje)),
          ),
        ],
      ),
    );
    if (bevestigd != true || !mounted || _bewaren) return false;
    setState(() => _bewaren = true);
    var gewijzigd = false;
    try {
      await _lopendeSync;
      if (!mounted) return false;
      final actueel = await AgendaRepository.laadItems();
      final sleutel = AgendaDatumHelper.datumKey(dag);
      final bestaat = (actueel[sleutel] ?? const <AgendaItem>[])
          .any((a) => !a.isVerwijderd && a.id == item.id);
      if (!bestaat) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Deze afspraak is intussen gewijzigd of verwijderd.'),
          ));
        }
        return false;
      }
      final opgeslagen = await AgendaRepository.verwijder(
        dag: dag, item: item, itemsPerDag: actueel,
      );
      if (!mounted) return false;
      gewijzigd = true;
      setState(() => _items = opgeslagen);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Afspraak verwijderd uit de Thimaco-agenda.'),
      ));
      return true;
    } catch (fout) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Afspraak wissen mislukt: $fout'),
        ));
      }
      return false;
    } finally {
      if (mounted) {
        setState(() => _bewaren = false);
        if (gewijzigd) unawaited(synchroniseer(naWijziging: true));
      }
    }
  }

  Future<void> _nieuweAfspraak({DateTime? voorDag}) async {
    final datum = voorDag ?? _dag;
    final resultaat = await showDialog<AgendaItem>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ThimacoIphoneAfspraakDialoog(datum: datum),
    );
    if (resultaat == null || !mounted || _bewaren) return;
    setState(() => _bewaren = true);
    var gewijzigd = false;
    try {
      await _lopendeSync;
      if (!mounted) return;
      // Altijd kort voor opslaan opnieuw laden: geen oude maandcache terugschrijven.
      final actueel = await AgendaRepository.laadItems();
      final melding = AgendaToevoegService.kanItemToevoegen(
        dag: datum, nieuwItem: resultaat, itemsPerDag: actueel);
      if (melding != null && melding.isNotEmpty) {
        if (!mounted) return;
        final doorgaan = await showDialog<bool>(context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Mogelijke overlap'), content: Text(melding),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuleren')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Toch bewaren'))],
          ));
        if (doorgaan != true) return;
      }
      final opgeslagen = await AgendaRepository.voegToe(
        dag: datum, item: resultaat, itemsPerDag: actueel);
      if (!mounted) return;
      gewijzigd = true;
      setState(() => _items = opgeslagen);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Afspraak opgeslagen in de Thimaco-agenda.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opslaan mislukt: $e')));
    } finally {
      if (mounted) {
        setState(() => _bewaren = false);
        if (gewijzigd) unawaited(synchroniseer(naWijziging: true));
      }
    }
  }

  // Hoofdscherm beheert de vaste zwarte balk; deze acties worden van daaruit
  // aangeroepen, ook wanneer het dagoverzicht boven de maandagenda ligt.
  void openFilters() { _openFilters(); }
  void zoekAfspraken() { _zoek(); }
  void voegAfspraakToe() {
    if (!_bewaren) {
      unawaited(_nieuweAfspraak().then((_) => _verversDag?.call()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${_maandnamen[_maand.month - 1]} ${_maand.year}',
                      style: const TextStyle(
                        color: _donker, fontSize: 25,
                        fontWeight: FontWeight.w400, letterSpacing: -0.2,
                        height: 1.15,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Row(children: [
                    for (final weekdag in _weekdagen)
                      Expanded(child: Center(child: Text(weekdag,
                        style: const TextStyle(color: _donker,
                          fontSize: 12, fontWeight: FontWeight.w400, height: 1.0),
                      ))),
                  ]),
                ),
                const SizedBox(height: 7),
                const Divider(height: 1, color: _rand),
                if (_laden) const LinearProgressIndicator(
                  minHeight: 2, color: _oranje,
                ),
                if (_fout != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(_fout!, style: const TextStyle(color: Colors.red)),
                  ),
                Expanded(child: RefreshIndicator(
                  onRefresh: _herlaad,
                  color: _oranje,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragStart: (_) => _horizontaleSleep = 0,
                    onHorizontalDragUpdate: (details) {
                      _horizontaleSleep += details.primaryDelta ?? 0;
                    },
                    onHorizontalDragEnd: (details) {
                      // Zowel een rustige veeg als een snelle swipe moet werken.
                      // Verticaal door weken scrollen blijft mogelijk.
                      final snelheid = details.primaryVelocity ?? 0;
                      final beweging = _horizontaleSleep;
                      _horizontaleSleep = 0;
                      if (beweging < -45 || (beweging < -12 && snelheid < -250)) {
                        _kiesMaand(1);
                      } else if (beweging > 45 || (beweging > 12 && snelheid > 250)) {
                        _kiesMaand(-1);
                      }
                    },
                    onHorizontalDragCancel: () => _horizontaleSleep = 0,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        for (var index = 0; index < _aantalWeken; index++)
                          _weekRij(index),
                      ],
                    ),
                  ),
                )),
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 7, 14, 6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: _rand)),
                  ),
                  child: Row(children: [
                    OutlinedButton(
                      onPressed: _vandaag,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _donker,
                        side: const BorderSide(color: _rand),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Vandaag', style: TextStyle(
                        fontWeight: FontWeight.w600,
                      )),
                    ),
                    const Spacer(),
                    _tekstKnop('Dagoverzicht', () => _toonDag(_dag)),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
