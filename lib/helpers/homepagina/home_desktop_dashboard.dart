// THIMACO-CONTROLE: HOME-WEER-MAIL-ZONDAG-OVERGESLAGEN-20260915
// THIMACO-CONTROLE: HOME-WINDOWS-DESKTOP-DASHBOARD-FASE-2-20260914
// THIMACO-CONTROLE: HOME-WINDOWS-DESKTOP-DASHBOARD-FASE-1-20260914
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../magazijn/magazijn_controller.dart';
import 'home_mail_service.dart';


// THIMACO-CONTROLE: HOME-WEER-SERVICE-IN-DASHBOARD-20260915
class HomeWeerDag {
  const HomeWeerDag({
    required this.datum,
    required this.weerCode,
    required this.minimumTemperatuur,
    required this.maximumTemperatuur,
    required this.neerslagKans,
    required this.maximumWind,
  });

  final DateTime datum;
  final int weerCode;
  final double minimumTemperatuur;
  final double maximumTemperatuur;
  final int neerslagKans;
  final double maximumWind;
}

class HomeWeerResultaat {
  const HomeWeerResultaat({
    required this.plaats,
    required this.huidigeTemperatuur,
    required this.huidigeWeerCode,
    required this.huidigeWind,
    required this.dagen,
  });

  final String plaats;
  final double huidigeTemperatuur;
  final int huidigeWeerCode;
  final double huidigeWind;
  final List<HomeWeerDag> dagen;
}

class HomeWeerService {
  static const Duration _cacheDuur = Duration(minutes: 20);

  static HomeWeerResultaat? _cache;
  static DateTime? _cacheOp;

  Future<HomeWeerResultaat> laadWeer() async {
    final cache = _cache;
    final cacheOp = _cacheOp;
    if (cache != null &&
        cacheOp != null &&
        DateTime.now().difference(cacheOp) < _cacheDuur) {
      return cache;
    }

    final locatie =
        await _zoekLocatie('Beveren-Leie') ?? await _zoekLocatie('Waregem');

    if (locatie == null) {
      throw const HomeWeerException(
        'Locatie Beveren-Leie kon niet gevonden worden.',
      );
    }

    final uri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      <String, String>{
        'latitude': locatie.latitude.toString(),
        'longitude': locatie.longitude.toString(),
        'current': 'temperature_2m,weather_code,wind_speed_10m',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,'
            'precipitation_probability_max,wind_speed_10m_max',
        'timezone': 'Europe/Brussels',
        'forecast_days': '5',
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw HomeWeerException(
        'Weerbericht kon niet geladen worden (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const HomeWeerException('Ongeldig weerbericht ontvangen.');
    }

    final data = Map<String, dynamic>.from(decoded);
    final current = data['current'];
    final daily = data['daily'];

    if (current is! Map || daily is! Map) {
      throw const HomeWeerException('Onvolledig weerbericht ontvangen.');
    }

    final currentMap = Map<String, dynamic>.from(current);
    final dailyMap = Map<String, dynamic>.from(daily);

    final tijden = _alsLijst(dailyMap['time']);
    final codes = _alsLijst(dailyMap['weather_code']);
    final minima = _alsLijst(dailyMap['temperature_2m_min']);
    final maxima = _alsLijst(dailyMap['temperature_2m_max']);
    final regenKansen = _alsLijst(dailyMap['precipitation_probability_max']);
    final windMax = _alsLijst(dailyMap['wind_speed_10m_max']);

    final aantal = <int>[
      tijden.length,
      codes.length,
      minima.length,
      maxima.length,
      regenKansen.length,
      windMax.length,
    ].reduce((a, b) => a < b ? a : b);

    final dagen = <HomeWeerDag>[];
    for (var index = 0; index < aantal; index++) {
      final datum = DateTime.tryParse(tijden[index].toString());
      if (datum == null) continue;

      dagen.add(
        HomeWeerDag(
          datum: datum,
          weerCode: _alsInt(codes[index]),
          minimumTemperatuur: _alsDouble(minima[index]),
          maximumTemperatuur: _alsDouble(maxima[index]),
          neerslagKans: _alsInt(regenKansen[index]),
          maximumWind: _alsDouble(windMax[index]),
        ),
      );
    }

    if (dagen.isEmpty) {
      throw const HomeWeerException('Geen weersverwachting ontvangen.');
    }

    final resultaat = HomeWeerResultaat(
      plaats: 'Beveren-Leie',
      huidigeTemperatuur: _alsDouble(currentMap['temperature_2m']),
      huidigeWeerCode: _alsInt(currentMap['weather_code']),
      huidigeWind: _alsDouble(currentMap['wind_speed_10m']),
      dagen: List<HomeWeerDag>.unmodifiable(dagen),
    );

    _cache = resultaat;
    _cacheOp = DateTime.now();
    return resultaat;
  }

  Future<_HomeWeerLocatie?> _zoekLocatie(String naam) async {
    try {
      final uri = Uri.https(
        'geocoding-api.open-meteo.com',
        '/v1/search',
        <String, String>{
          'name': naam,
          'count': '5',
          'language': 'nl',
          'format': 'json',
          'countryCode': 'BE',
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return null;

      final results = decoded['results'];
      if (results is! List || results.isEmpty) return null;

      for (final item in results) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);

        final latitude = _probeerDouble(map['latitude']);
        final longitude = _probeerDouble(map['longitude']);
        if (latitude == null || longitude == null) continue;

        return _HomeWeerLocatie(
          latitude: latitude,
          longitude: longitude,
        );
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  static List<dynamic> _alsLijst(dynamic waarde) {
    if (waarde is List) return waarde;
    return const <dynamic>[];
  }

  static int _alsInt(dynamic waarde) {
    if (waarde is int) return waarde;
    if (waarde is num) return waarde.round();
    return int.tryParse(waarde?.toString() ?? '') ?? 0;
  }

  static double _alsDouble(dynamic waarde) {
    return _probeerDouble(waarde) ?? 0;
  }

  static double? _probeerDouble(dynamic waarde) {
    if (waarde is num) return waarde.toDouble();
    return double.tryParse(waarde?.toString() ?? '');
  }
}

class _HomeWeerLocatie {
  const _HomeWeerLocatie({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

class HomeWeerException implements Exception {
  const HomeWeerException(this.bericht);

  final String bericht;

  @override
  String toString() => bericht;
}


Map<String, dynamic> _decodeHomeDesktopBronnen(Map<String, String> bron) {
  dynamic decodeer(String waarde, dynamic fallback) {
    if (waarde.trim().isEmpty) return fallback;
    try {
      return jsonDecode(waarde);
    } catch (_) {
      return fallback;
    }
  }

  final agendaDecoded = decodeer(
    bron['agenda'] ?? '',
    <String, dynamic>{},
  );
  final notitiesDecoded = decodeer(
    bron['notities'] ?? '',
    <dynamic>[],
  );

  return <String, dynamic>{
    'agenda': agendaDecoded is Map
        ? Map<String, dynamic>.from(agendaDecoded)
        : <String, dynamic>{},
    'notities': notitiesDecoded,
  };
}

class HomeDesktopDashboard extends StatefulWidget {
  const HomeDesktopDashboard({
    super.key,
    required this.planningVandaag,
    required this.dagTakenVandaag,
    required this.klantTakenVandaag,
    required this.kraanReservatiesVandaag,
  });

  final List<dynamic> planningVandaag;
  final List<dynamic> dagTakenVandaag;
  final List<dynamic> klantTakenVandaag;
  final List<dynamic> kraanReservatiesVandaag;

  @override
  State<HomeDesktopDashboard> createState() => _HomeDesktopDashboardState();
}

class _HomeDesktopDashboardState extends State<HomeDesktopDashboard> {
  static const Color _oranje = Color(0xFFF15A24);
  static const Color _antraciet = Color(0xFF22272D);
  static const Color _tekstGrijs = Color(0xFF616973);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _groenPlanning = Color(0xFF0B7A3B);
  static const Color _blauwVandaag = Color(0xFF2563EB);
  static const Color _geelNotities = Color(0xFFD97706);
  static const Color _paars = Color(0xFF7C3AED);
  static const Color _rood = Color(0xFFDC2626);

  Timer? _klokTimer;
  Timer? _herlaadTimer;
  DateTime _nu = DateTime.now();

  bool _dashboardActief = true;
  bool _eersteRouteControle = true;
  bool _herlaadNaTerugkeer = false;
  bool _laadBezig = false;
  bool _laadOpnieuwNodig = false;

  List<_WeekDagData> _weekDagen = const <_WeekDagData>[];
  List<_DashboardRegel> _bureauNotities = const <_DashboardRegel>[];
  List<_DashboardRegel> _magazijnRegels = const <_DashboardRegel>[];
  int _teBestellenAantal = 0;
  bool _extraDataLaden = true;

  final HomeWeerService _weerService = HomeWeerService();
  final HomeMailService _mailService = HomeMailService();

  Timer? _netwerkTimer;
  HomeWeerResultaat? _weer;
  HomeMailOverzicht? _mail;
  bool _weerLaden = true;
  bool _mailLaden = true;

  @override
  void initState() {
    super.initState();
    _klokTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted || !_dashboardActief) return;
      setState(() {
        _nu = DateTime.now();
      });
    });
    _laadExtraData();
    _planNetwerkData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final actief = ModalRoute.of(context)?.isCurrent ?? true;

    if (_eersteRouteControle) {
      _eersteRouteControle = false;
      _dashboardActief = actief;
      return;
    }

    if (actief == _dashboardActief) return;

    _dashboardActief = actief;

    if (_dashboardActief && _herlaadNaTerugkeer) {
      _herlaadNaTerugkeer = false;
      _planHerlaad();
      _planNetwerkData();
    }
  }

  @override
  void didUpdateWidget(covariant HomeDesktopDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bronGewijzigd =
        !identical(oldWidget.planningVandaag, widget.planningVandaag) ||
        !identical(oldWidget.dagTakenVandaag, widget.dagTakenVandaag) ||
        !identical(oldWidget.klantTakenVandaag, widget.klantTakenVandaag) ||
        !identical(
          oldWidget.kraanReservatiesVandaag,
          widget.kraanReservatiesVandaag,
        );

    if (!bronGewijzigd) return;

    if (!_dashboardActief) {
      _herlaadNaTerugkeer = true;
      return;
    }

    _planHerlaad();
  }

  void _planHerlaad() {
    _herlaadTimer?.cancel();
    _herlaadTimer = Timer(
      const Duration(milliseconds: 400),
      _laadExtraData,
    );
  }

  void _planNetwerkData() {
    _netwerkTimer?.cancel();

    /*
     * Home moet eerst onmiddellijk bruikbaar zijn.
     * Weer en mail starten pas nadat de eerste UI rustig zichtbaar is.
     */
    _netwerkTimer = Timer(const Duration(milliseconds: 1200), () {
      _netwerkTimer = null;
      unawaited(_laadNetwerkData());
    });
  }

  Future<void> _laadNetwerkData() async {
    if (!mounted || !_dashboardActief) return;

    /*
     * Weer en mail starten tegelijk, maar pas nadat Home al zichtbaar is.
     * Een trage weerverbinding kan de mailkaart dus niet tegenhouden.
     */
    final weerFuture = _weerService.laadWeer();
    final mailFuture = _mailService.laadOngelezen();

    try {
      final weer = await weerFuture;
      if (mounted && _dashboardActief) {
        setState(() {
          _weer = weer;
          _weerLaden = false;
        });
      }
    } catch (_) {
      if (mounted && _dashboardActief) {
        setState(() {
          _weerLaden = false;
        });
      }
    }

    final mail = await mailFuture;
    if (!mounted || !_dashboardActief) return;

    setState(() {
      _mail = mail;
      _mailLaden = false;
    });
  }

  @override
  void dispose() {
    _klokTimer?.cancel();
    _herlaadTimer?.cancel();
    _netwerkTimer?.cancel();
    super.dispose();
  }

  Future<void> _laadExtraData() async {
    if (!_dashboardActief && !_eersteRouteControle) {
      _herlaadNaTerugkeer = true;
      return;
    }

    if (_laadBezig) {
      _laadOpnieuwNodig = true;
      return;
    }

    _laadBezig = true;

    try {
      final prefs = await SharedPreferences.getInstance();

      final agendaJson = prefs.getString('agenda_items_nieuw') ?? '';
      final notitiesJson = prefs.getString('thimaco_notities') ?? '';

      // De grote JSON-decode gebeurt buiten de UI-isolate.
      final decoded = await compute(
        _decodeHomeDesktopBronnen,
        <String, String>{
          'agenda': agendaJson,
          'notities': notitiesJson,
        },
      );

      final weekDagen = _leesWeekplanning(
        Map<String, dynamic>.from(
          decoded['agenda'] as Map? ?? const <String, dynamic>{},
        ),
      );

      final bureauNotities = _leesBureauNotities(
        decoded['notities'],
      );

      // Magazijn wordt alleen bij een echte dashboardherlading gelezen,
      // nooit door de kloktimer.
      final magazijn = await _leesMagazijn();

      if (!mounted) return;

      setState(() {
        _weekDagen = weekDagen;
        _bureauNotities = bureauNotities;
        _magazijnRegels = magazijn.regels;
        _teBestellenAantal = magazijn.aantal;
        _extraDataLaden = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _extraDataLaden = false;
      });
    } finally {
      _laadBezig = false;

      if (_laadOpnieuwNodig) {
        _laadOpnieuwNodig = false;
        if (_dashboardActief) {
          _planHerlaad();
        } else {
          _herlaadNaTerugkeer = true;
        }
      }
    }
  }

  List<_WeekDagData> _leesWeekplanning(Map<String, dynamic> agenda) {
    final nu = DateTime.now();
    final vandaag = DateTime(nu.year, nu.month, nu.day);

    /*
     * Altijd zes planningsdagen tonen, maar zondag bewust overslaan.
     * Daardoor staat bijvoorbeeld na zaterdag onmiddellijk maandag in beeld.
     * Als Home op zondag wordt geopend, begint de planning meteen bij maandag.
     */
    final datums = <DateTime>[];
    var cursor = vandaag;

    while (datums.length < 6) {
      if (cursor.weekday != DateTime.sunday) {
        datums.add(cursor);
      }
      cursor = cursor.add(const Duration(days: 1));
    }

    return datums.map((datum) {
      final sleutel = _datumSleutel(datum);

      dynamic bron = agenda[sleutel];

      if (bron == null) {
        for (final entry in agenda.entries) {
          final parsed = DateTime.tryParse(entry.key);
          if (parsed != null && _zelfdeDag(parsed, datum)) {
            bron = entry.value;
            break;
          }
        }
      }

      final items = <_AgendaRegel>[];

      if (bron is List) {
        for (final item in bron) {
          if (item is! Map) continue;

          final map = Map<String, dynamic>.from(item);
          final deletedAt = map['deletedAt']?.toString().trim() ?? '';
          if (deletedAt.isNotEmpty) continue;

          final titel = _eersteNietLegeTekst(
            map,
            const <String>['titel', 'naamKlant', 'omschrijving'],
          );
          if (titel.isEmpty) continue;

          final type = map['type']?.toString().trim().toLowerCase() ?? '';
          final tijd = _formatteerTijd(map);

          items.add(
            _AgendaRegel(
              titel: titel,
              tijd: tijd,
              kleur: _kleurVoorAgendaType(type),
            ),
          );
        }
      }

      items.sort((a, b) {
        if (a.tijd.isEmpty && b.tijd.isNotEmpty) return -1;
        if (a.tijd.isNotEmpty && b.tijd.isEmpty) return 1;
        return a.tijd.compareTo(b.tijd);
      });

      return _WeekDagData(
        datum: datum,
        items: items,
      );
    }).toList(growable: false);
  }

  List<_DashboardRegel> _leesBureauNotities(dynamic decoded) {
    if (decoded == null) {
      return const <_DashboardRegel>[];
    }

    final gevonden = <_DashboardRegel>[];
    final uniekeSleutels = <String>{};

    void bezoek(dynamic node, DateTime? geerfdeDatum) {
      if (node is List) {
        for (final item in node) {
          bezoek(item, geerfdeDatum);
        }
        return;
      }

      if (node is! Map) return;

      final map = Map<String, dynamic>.from(node);
      var datum = geerfdeDatum;

      for (final sleutel in const <String>[
        'datumKey',
        'datum',
        'date',
        'dag',
        'createdAt',
      ]) {
        final waarde = map[sleutel]?.toString().trim() ?? '';
        if (waarde.isEmpty) continue;
        final parsed = DateTime.tryParse(waarde);
        if (parsed != null) {
          datum = parsed;
          break;
        }
      }

      final tekst = _eersteNietLegeTekst(
        map,
        const <String>[
          'tekst',
          'titel',
          'omschrijving',
          'notitie',
          'inhoud',
          'detail',
        ],
      );

      final afgewerkt = _leesBool(
        map,
        const <String>[
          'afgevinkt',
          'isAfgevinkt',
          'afgewerkt',
          'isAfgewerkt',
          'klaar',
        ],
      );

      if (tekst.isNotEmpty && !afgewerkt) {
        final actie = _eersteNietLegeTekst(
          map,
          const <String>['actieLabel', 'actie', 'label', 'categorie'],
        );

        final datumKey = datum == null ? '' : _datumSleutel(datum);
        final uniek =
            '$datumKey|${tekst.toLowerCase()}|${actie.toLowerCase()}';

        if (uniekeSleutels.add(uniek)) {
          gevonden.add(
            _DashboardRegel(
              titel: tekst,
              subtitel: actie,
              datum: datum,
            ),
          );
        }
      }

      for (final entry in map.entries) {
        DateTime? datumUitSleutel;
        final sleutel = entry.key.toString();
        final parsed = DateTime.tryParse(sleutel);
        if (parsed != null) {
          datumUitSleutel = parsed;
        }

        if (entry.value is List || entry.value is Map) {
          bezoek(entry.value, datumUitSleutel ?? datum);
        }
      }
    }

    bezoek(decoded, null);

    gevonden.sort((a, b) {
      final aDatum = a.datum;
      final bDatum = b.datum;

      if (aDatum == null && bDatum == null) {
        return a.titel.toLowerCase().compareTo(b.titel.toLowerCase());
      }
      if (aDatum == null) return 1;
      if (bDatum == null) return -1;

      final datumVergelijk = aDatum.compareTo(bDatum);
      if (datumVergelijk != 0) return datumVergelijk;

      return a.titel.toLowerCase().compareTo(b.titel.toLowerCase());
    });

    return gevonden;
  }

  Future<_MagazijnResultaat> _leesMagazijn() async {
    final controller = MagazijnController();

    try {
      await controller.laad();

      final regels = <_DashboardRegel>[];
      var totaal = 0;

      for (final leverancier in controller.data.leveranciers) {
        final artikelen =
            controller.bestelArtikelenVoorLeverancier(leverancier.id);

        if (artikelen.isEmpty) continue;

        totaal += artikelen.length;

        for (final artikel in artikelen) {
          final aantal = artikel.aanbevolenBestelaantal;
          final hoeveelheid = aantal > 0
              ? '$aantal ${artikel.eenheid}'
              : 'voorraad ${artikel.stock}';

          regels.add(
            _DashboardRegel(
              titel: artikel.omschrijving,
              subtitel: '${leverancier.naam} · $hoeveelheid',
            ),
          );
        }
      }

      return _MagazijnResultaat(
        aantal: totaal,
        regels: regels.take(10).toList(growable: false),
      );
    } finally {
      controller.dispose();
    }
  }

  List<_DashboardRegel> _leesPlaatsersNotities() {
    final regels = <_DashboardRegel>[];
    final uniek = <String>{};

    for (final item in widget.klantTakenVandaag) {
      final map = _dynamischNaarMap(item);
      if (map == null) continue;

      final klantNaam = _eersteNietLegeTekst(
        map,
        const <String>['naam', 'naamKlant', 'klantNaam'],
      );

      final taken = map['klantTaken'];

      if (taken is List) {
        for (final taak in taken) {
          final taakMap = _dynamischNaarMap(taak);
          if (taakMap == null) continue;

          final afgewerkt = _leesBool(
            taakMap,
            const <String>['isAfgewerkt', 'afgewerkt', 'afgevinkt'],
          );
          if (afgewerkt) continue;

          final tekst = _eersteNietLegeTekst(
            taakMap,
            const <String>['tekst', 'titel', 'omschrijving', 'taak'],
          );
          if (tekst.isEmpty) continue;

          final sleutel = '${klantNaam.toLowerCase()}|${tekst.toLowerCase()}';
          if (!uniek.add(sleutel)) continue;

          regels.add(
            _DashboardRegel(
              titel: tekst,
              subtitel: klantNaam,
            ),
          );
        }
        continue;
      }

      final tekst = _eersteNietLegeTekst(
        map,
        const <String>[
          'tekst',
          'taak',
          'omschrijving',
          'opmerkingen',
          'titel',
        ],
      );
      if (tekst.isEmpty) continue;

      final sleutel = '${klantNaam.toLowerCase()}|${tekst.toLowerCase()}';
      if (!uniek.add(sleutel)) continue;

      regels.add(
        _DashboardRegel(
          titel: tekst,
          subtitel: klantNaam,
        ),
      );
    }

    return regels.take(10).toList(growable: false);
  }

  Map<String, dynamic>? _dynamischNaarMap(dynamic item) {
    if (item is Map) {
      return Map<String, dynamic>.from(item);
    }

    try {
      final json = (item as dynamic).toJson();
      if (json is Map) {
        return Map<String, dynamic>.from(json);
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  String _eersteNietLegeTekst(
    Map<String, dynamic> map,
    List<String> sleutels,
  ) {
    for (final sleutel in sleutels) {
      final waarde = map[sleutel]?.toString().trim() ?? '';
      if (waarde.isNotEmpty && waarde != 'null') {
        return waarde;
      }
    }
    return '';
  }

  bool _leesBool(
    Map<String, dynamic> map,
    List<String> sleutels,
  ) {
    for (final sleutel in sleutels) {
      final waarde = map[sleutel];
      if (waarde is bool) return waarde;
      final tekst = waarde?.toString().trim().toLowerCase();
      if (tekst == 'true' || tekst == '1' || tekst == 'ja') return true;
    }
    return false;
  }

  String _formatteerTijd(Map<String, dynamic> map) {
    final volledigeDag = map['volledigeDag'] == true;
    if (volledigeDag) return 'Hele dag';

    int? leesInt(String sleutel) {
      final waarde = map[sleutel];
      if (waarde is int) return waarde;
      if (waarde is num) return waarde.toInt();
      return int.tryParse(waarde?.toString() ?? '');
    }

    final startUur = leesInt('startUur');
    final startMinuut = leesInt('startMinuut');
    final eindUur = leesInt('eindUur');
    final eindMinuut = leesInt('eindMinuut');

    if (startUur == null || startMinuut == null) return '';

    final start =
        '${startUur.toString().padLeft(2, '0')}:${startMinuut.toString().padLeft(2, '0')}';

    if (eindUur == null || eindMinuut == null) return start;

    final eind =
        '${eindUur.toString().padLeft(2, '0')}:${eindMinuut.toString().padLeft(2, '0')}';

    return '$start – $eind';
  }

  Color _kleurVoorAgendaType(String type) {
    switch (type) {
      case 'planning':
        return _groenPlanning;
      case 'afspraak':
        return _blauwVandaag;
      case 'opvolging':
        return _geelNotities;
      case 'nadienst':
        return _paars;
      case 'dagtaak':
        return _oranje;
      case 'verlof':
        return _rood;
      default:
        return _tekstGrijs;
    }
  }

  String _datumSleutel(DateTime datum) {
    return '${datum.year.toString().padLeft(4, '0')}-'
        '${datum.month.toString().padLeft(2, '0')}-'
        '${datum.day.toString().padLeft(2, '0')}';
  }

  bool _zelfdeDag(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int _isoWeekNummer(DateTime datum) {
    final dag = DateTime(datum.year, datum.month, datum.day);
    final donderdag = dag.add(Duration(days: 4 - dag.weekday));
    final eersteDonderdag = DateTime(donderdag.year, 1, 4);
    final weekEenMaandag = eersteDonderdag.subtract(
      Duration(days: eersteDonderdag.weekday - DateTime.monday),
    );
    final huidigeWeekMaandag = donderdag.subtract(
      Duration(days: donderdag.weekday - DateTime.monday),
    );
    return 1 + huidigeWeekMaandag.difference(weekEenMaandag).inDays ~/ 7;
  }

  String _langeDatum(DateTime datum) {
    const dagen = <String>[
      'maandag',
      'dinsdag',
      'woensdag',
      'donderdag',
      'vrijdag',
      'zaterdag',
      'zondag',
    ];
    const maanden = <String>[
      'januari',
      'februari',
      'maart',
      'april',
      'mei',
      'juni',
      'juli',
      'augustus',
      'september',
      'oktober',
      'november',
      'december',
    ];

    return '${dagen[datum.weekday - 1]} ${datum.day} '
        '${maanden[datum.month - 1]} ${datum.year}';
  }

  String _korteDatumTekst(DateTime datum) {
    final vandaag = DateTime(_nu.year, _nu.month, _nu.day);
    final dag = DateTime(datum.year, datum.month, datum.day);
    final verschil = dag.difference(vandaag).inDays;

    if (verschil == 0) return 'Vandaag';
    if (verschil == -1) return 'Gisteren';
    if (verschil == 1) return 'Morgen';

    return '${datum.day.toString().padLeft(2, '0')}/'
        '${datum.month.toString().padLeft(2, '0')}/'
        '${datum.year}';
  }

  String _tijdTekst(DateTime datum) {
    return '${datum.hour.toString().padLeft(2, '0')}:'
        '${datum.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final plaatsersNotities = _leesPlaatsersNotities();

    return LayoutBuilder(
      builder: (context, constraints) {
        const tussenruimte = 12.0;
        const infoHoogte = 76.0;

        final beschikbareHoogte =
            (constraints.maxHeight - infoHoogte - tussenruimte * 2)
                .clamp(0.0, 2000.0)
                .toDouble();

        final bovenHoogte = beschikbareHoogte * 0.57;
        final onderHoogte = beschikbareHoogte * 0.43;

        return Column(
          children: <Widget>[
            SizedBox(
              height: infoHoogte,
              child: _bouwInfoBalk(),
            ),
            const SizedBox(height: tussenruimte),
            SizedBox(
              height: bovenHoogte,
              child: _DashboardKaart(
                titel: 'Planning · 6 planningsdagen',
                subtitel: 'Zondag overgeslagen · alle agenda-items',
                accent: _groenPlanning,
                child: _bouwWeekplanning(),
              ),
            ),
            const SizedBox(height: tussenruimte),
            SizedBox(
              height: onderHoogte,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: _DashboardKaart(
                      titel: 'Notities plaatsers',
                      subtitel: plaatsersNotities.isEmpty
                          ? null
                          : '${plaatsersNotities.length} open',
                      accent: _geelNotities,
                      child: _bouwRegelLijst(
                        plaatsersNotities,
                        legeTekst: 'Geen open notities voor de plaatsers.',
                      ),
                    ),
                  ),
                  const SizedBox(width: tussenruimte),
                  Expanded(
                    child: _DashboardKaart(
                      titel: 'Notities bureau',
                      subtitel: _bureauNotities.isEmpty
                          ? null
                          : '${_bureauNotities.length} open',
                      accent: _oranje,
                      child: _extraDataLaden
                          ? const _Laden()
                          : _bouwNotitiesPerDatum(
                              _bureauNotities,
                              legeTekst: 'Geen open bureaunotities.',
                            ),
                    ),
                  ),
                  const SizedBox(width: tussenruimte),
                  Expanded(
                    child: _DashboardKaart(
                      titel: 'Magazijn & bestellen',
                      subtitel: _teBestellenAantal == 0
                          ? null
                          : '$_teBestellenAantal te bestellen',
                      accent: _antraciet,
                      child: _extraDataLaden
                          ? const _Laden()
                          : _bouwRegelLijst(
                              _magazijnRegels,
                              legeTekst:
                                  'Geen goederen die nu besteld moeten worden.',
                            ),
                    ),
                  ),
                  const SizedBox(width: tussenruimte),
                  Expanded(
                    child: _DashboardKaart(
                      titel: 'Mail',
                      subtitel: _mailSubtitel(),
                      accent: _blauwVandaag,
                      child: _bouwMailOverzicht(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _bouwInfoBalk() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rand),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: _oranje,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    _langeDatum(_nu),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _antraciet,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                _InfoChip(
                  tekst: 'Week ${_isoWeekNummer(_nu)}',
                  icoon: Icons.date_range_outlined,
                ),
                const SizedBox(width: 10),
                _InfoChip(
                  tekst: _tijdTekst(_nu),
                  icoon: Icons.schedule_rounded,
                ),
              ],
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: _rand,
            margin: const EdgeInsets.symmetric(horizontal: 14),
          ),
          Expanded(
            flex: 6,
            child: _bouwWeerBalk(),
          ),
        ],
      ),
    );
  }

  Widget _bouwWeerBalk() {
    if (_weerLaden) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(
              strokeWidth: 1.8,
              color: _oranje,
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Weer Beveren-Leie laden…',
            style: TextStyle(
              color: _tekstGrijs,
              fontSize: 10.5,
            ),
          ),
        ],
      );
    }

    final weer = _weer;
    if (weer == null) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Icon(
            Icons.cloud_off_outlined,
            size: 18,
            color: _tekstGrijs,
          ),
          SizedBox(width: 7),
          Text(
            'Weerbericht tijdelijk niet beschikbaar',
            style: TextStyle(
              color: _tekstGrijs,
              fontSize: 10.5,
            ),
          ),
        ],
      );
    }

    final dagen = weer.dagen.take(5).toList(growable: false);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '${weer.plaats} · ${weer.huidigeTemperatuur.round()}°',
                style: const TextStyle(
                  color: _antraciet,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_weerOmschrijving(weer.huidigeWeerCode)} · '
                'wind ${weer.huidigeWind.round()} km/u',
                style: const TextStyle(
                  color: _tekstGrijs,
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
        ),
        for (final dag in dagen)
          _WeerDagChip(
            dag: dag,
            icoon: _weerIcoon(dag.weerCode),
            dagTekst: _weerDagTekst(dag.datum),
          ),
      ],
    );
  }

  String _weerDagTekst(DateTime datum) {
    if (_zelfdeDag(datum, _nu)) return 'VANDAAG';
    return _korteDag(datum);
  }

  String _weerOmschrijving(int code) {
    if (code == 0) return 'Helder';
    if (code <= 3) return 'Bewolkt';
    if (code == 45 || code == 48) return 'Mist';
    if (code >= 51 && code <= 57) return 'Motregen';
    if (code >= 61 && code <= 67) return 'Regen';
    if (code >= 71 && code <= 77) return 'Sneeuw';
    if (code >= 80 && code <= 82) return 'Buien';
    if (code >= 85 && code <= 86) return 'Sneeuwbuien';
    if (code >= 95) return 'Onweer';
    return 'Weer';
  }

  IconData _weerIcoon(int code) {
    if (code == 0) return Icons.wb_sunny_outlined;
    if (code <= 3) return Icons.cloud_outlined;
    if (code == 45 || code == 48) return Icons.blur_on_outlined;
    if (code >= 71 && code <= 77) return Icons.ac_unit_outlined;
    if (code >= 85 && code <= 86) return Icons.ac_unit_outlined;
    if (code >= 95) return Icons.thunderstorm_outlined;
    if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) {
      return Icons.water_drop_outlined;
    }
    return Icons.cloud_outlined;
  }

  Widget _bouwWeekplanning() {
    if (_extraDataLaden && _weekDagen.isEmpty) {
      return const _Laden();
    }

    if (_weekDagen.isEmpty) {
      return const _LegeTekst('Planning kon niet geladen worden.');
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List<Widget>.generate(_weekDagen.length, (index) {
        final dag = _weekDagen[index];
        final isVandaag = _zelfdeDag(dag.datum, _nu);

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: index == _weekDagen.length - 1 ? 0 : 8,
            ),
            decoration: BoxDecoration(
              color: isVandaag
                  ? const Color(0xFFF7FBF8)
                  : const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isVandaag
                    ? const Color(0xFFB9D9C4)
                    : _rand,
              ),
            ),
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(9, 8, 9, 7),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: _rand),
                    ),
                  ),
                  child: Text(
                    '${_korteDag(dag.datum)} ${dag.datum.day}/${dag.datum.month}',
                    style: TextStyle(
                      color: isVandaag ? _groenPlanning : _antraciet,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  child: dag.items.isEmpty
                      ? const Center(
                          child: Text(
                            '—',
                            style: TextStyle(
                              color: Color(0xFFB0B5BA),
                              fontSize: 13,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(7),
                          itemCount: dag.items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 5),
                          itemBuilder: (context, itemIndex) {
                            return _WeekItem(
                              item: dag.items[itemIndex],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  String _korteDag(DateTime datum) {
    const dagen = <String>['MA', 'DI', 'WO', 'DO', 'VR', 'ZA', 'ZO'];
    return dagen[datum.weekday - 1];
  }

  Widget _bouwRegelLijst(
    List<_DashboardRegel> regels, {
    required String legeTekst,
  }) {
    if (regels.isEmpty) {
      return _LegeTekst(legeTekst);
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: regels.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        color: _rand,
      ),
      itemBuilder: (context, index) {
        final regel = regels[index];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 5,
                height: 5,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: _oranje,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      regel.titel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _antraciet,
                        fontSize: 12,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (regel.subtitel.trim().isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        regel.subtitel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _tekstGrijs,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bouwNotitiesPerDatum(
    List<_DashboardRegel> regels, {
    required String legeTekst,
  }) {
    if (regels.isEmpty) {
      return _LegeTekst(legeTekst);
    }

    final groepen = <String, List<_DashboardRegel>>{};

    for (final regel in regels) {
      final sleutel = regel.datum == null
          ? 'Zonder datum'
          : _korteDatumTekst(regel.datum!);
      groepen.putIfAbsent(sleutel, () => <_DashboardRegel>[]).add(regel);
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        for (final entry in groepen.entries) ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(
              top: 2,
              bottom: 6,
            ),
            child: Text(
              entry.key,
              style: TextStyle(
                color: entry.key == 'Gisteren'
                    ? _rood
                    : entry.key == 'Vandaag'
                        ? _oranje
                        : _tekstGrijs,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          for (final regel in entry.value)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: const BoxDecoration(
                      color: _oranje,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          regel.titel,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _antraciet,
                            fontSize: 12,
                            height: 1.25,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (regel.subtitel.trim().isNotEmpty) ...<Widget>[
                          const SizedBox(height: 2),
                          Text(
                            regel.subtitel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _tekstGrijs,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (entry.key != groepen.keys.last)
            const Divider(
              height: 10,
              color: _rand,
            ),
        ],
      ],
    );
  }

  String? _mailSubtitel() {
    if (_mailLaden) return 'laden…';

    final mail = _mail;
    if (mail == null || mail.heeftFout) return 'niet beschikbaar';

    return '${mail.ongelezenAantal} ongelezen';
  }

  Widget _bouwMailOverzicht() {
    if (_mailLaden) {
      return const _Laden();
    }

    final mail = _mail;
    if (mail == null) {
      return const _LegeTekst('Mail kon niet geladen worden.');
    }

    if (mail.heeftFout) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.mark_email_unread_outlined,
            size: 28,
            color: _tekstGrijs,
          ),
          const SizedBox(height: 8),
          Text(
            mail.foutmelding ?? 'Mail is niet beschikbaar.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _tekstGrijs,
              fontSize: 10.5,
              height: 1.3,
            ),
          ),
        ],
      );
    }

    if (mail.berichten.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.drafts_outlined,
            size: 28,
            color: _blauwVandaag,
          ),
          const SizedBox(height: 8),
          const Text(
            'Geen ongelezen mails in de recente inbox.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _tekstGrijs,
              fontSize: 10.5,
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () {
              unawaited(_mailService.openInbox());
            },
            child: const Text('Inbox openen'),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: mail.berichten.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        color: _rand,
      ),
      itemBuilder: (context, index) {
        final bericht = mail.berichten[index];

        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            unawaited(_mailService.openBericht(bericht));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: const BoxDecoration(
                    color: _blauwVandaag,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              bericht.afzenderNaam.isEmpty
                                  ? bericht.afzenderAdres
                                  : bericht.afzenderNaam,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _antraciet,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _mailTijdTekst(bericht.ontvangenOp),
                            style: const TextStyle(
                              color: _tekstGrijs,
                              fontSize: 8.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        bericht.onderwerp,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _antraciet,
                          fontSize: 10.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (bericht.preview.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 2),
                        Text(
                          bericht.preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _tekstGrijs,
                            fontSize: 8.8,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _mailTijdTekst(DateTime datum) {
    if (_zelfdeDag(datum, _nu)) return _tijdTekst(datum);

    final gisteren = _nu.subtract(const Duration(days: 1));
    if (_zelfdeDag(datum, gisteren)) return 'gisteren';

    return '${datum.day}/${datum.month}';
  }


}

class _DashboardKaart extends StatelessWidget {
  const _DashboardKaart({
    required this.titel,
    required this.accent,
    required this.child,
    this.subtitel,
  });

  final String titel;
  final String? subtitel;
  final Color accent;
  final Widget child;

  static const Color _antraciet = Color(0xFF22272D);
  static const Color _tekstGrijs = Color(0xFF616973);
  static const Color _rand = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rand),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 3,
            color: accent,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    titel,
                    style: const TextStyle(
                      color: _antraciet,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (subtitel != null && subtitel!.trim().isNotEmpty)
                  Text(
                    subtitel!,
                    style: const TextStyle(
                      color: _tekstGrijs,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            color: _rand,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.tekst,
    required this.icoon,
  });

  final String tekst;
  final IconData icoon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icoon,
            size: 14,
            color: const Color(0xFF616973),
          ),
          const SizedBox(width: 6),
          Text(
            tekst,
            style: const TextStyle(
              color: Color(0xFF22272D),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeerDagChip extends StatelessWidget {
  const _WeerDagChip({
    required this.dag,
    required this.icoon,
    required this.dagTekst,
  });

  final HomeWeerDag dag;
  final IconData icoon;
  final String dagTekst;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      margin: const EdgeInsets.only(left: 5),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icoon,
                size: 13,
                color: const Color(0xFFF15A24),
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  dagTekst,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF22272D),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${dag.maximumTemperatuur.round()}°/'
            '${dag.minimumTemperatuur.round()}°',
            style: const TextStyle(
              color: Color(0xFF22272D),
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '${dag.neerslagKans}% regen',
            style: const TextStyle(
              color: Color(0xFF616973),
              fontSize: 7.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekItem extends StatelessWidget {
  const _WeekItem({
    required this.item,
  });

  final _AgendaRegel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(7, 6, 7, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: item.kleur.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 3,
            height: 26,
            decoration: BoxDecoration(
              color: item.kleur,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (item.tijd.isNotEmpty)
                  Text(
                    item.tijd,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF616973),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                Text(
                  item.titel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF22272D),
                    fontSize: 9.5,
                    height: 1.18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Laden extends StatelessWidget {
  const _Laden();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFFF15A24),
        ),
      ),
    );
  }
}

class _LegeTekst extends StatelessWidget {
  const _LegeTekst(this.tekst);

  final String tekst;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        tekst,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF8A9096),
          fontSize: 11.5,
          height: 1.35,
        ),
      ),
    );
  }
}

class _WeekDagData {
  const _WeekDagData({
    required this.datum,
    required this.items,
  });

  final DateTime datum;
  final List<_AgendaRegel> items;
}

class _AgendaRegel {
  const _AgendaRegel({
    required this.titel,
    required this.tijd,
    required this.kleur,
  });

  final String titel;
  final String tijd;
  final Color kleur;
}

class _DashboardRegel {
  const _DashboardRegel({
    required this.titel,
    this.subtitel = '',
    this.datum,
  });

  final String titel;
  final String subtitel;
  final DateTime? datum;
}

class _MagazijnResultaat {
  const _MagazijnResultaat({
    required this.aantal,
    required this.regels,
  });

  final int aantal;
  final List<_DashboardRegel> regels;
}
