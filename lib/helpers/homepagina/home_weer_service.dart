// THIMACO-CONTROLE: HOME-WEER-BEVEREN-LEIE-OPEN-METEO-20260915
import 'dart:convert';

import 'package:http/http.dart' as http;

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

