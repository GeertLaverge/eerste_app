import 'opmeting_deurpaneel_dxf_model.dart';

class OpmetingDeurpaneelDxfParser {
  const OpmetingDeurpaneelDxfParser._();

  static OpmetingDeurpaneelDxfTekening parse(
    String inhoud, {
    String bestandsnaam = '',
  }) {
    final groepen = _leesGroepen(inhoud);
    final entities = <OpmetingDeurpaneelDxfEntity>[];

    var index = 0;

    while (index < groepen.length) {
      final groep = groepen[index];

      if (groep.code != 0) {
        index++;
        continue;
      }

      final type = groep.waarde.trim().toUpperCase();

      switch (type) {
        case 'LINE':
          final resultaat = _parseLine(groepen, index + 1);
          if (resultaat.entity != null) {
            entities.add(resultaat.entity!);
          }
          index = resultaat.volgendeIndex;
          break;

        case 'LWPOLYLINE':
          final resultaat = _parseLwPolyline(groepen, index + 1);
          if (resultaat.entity != null) {
            entities.add(resultaat.entity!);
          }
          index = resultaat.volgendeIndex;
          break;

        case 'POLYLINE':
          final resultaat = _parsePolyline(groepen, index + 1);
          if (resultaat.entity != null) {
            entities.add(resultaat.entity!);
          }
          index = resultaat.volgendeIndex;
          break;

        case 'CIRCLE':
          final resultaat = _parseCircle(groepen, index + 1);
          if (resultaat.entity != null) {
            entities.add(resultaat.entity!);
          }
          index = resultaat.volgendeIndex;
          break;

        case 'ARC':
          final resultaat = _parseArc(groepen, index + 1);
          if (resultaat.entity != null) {
            entities.add(resultaat.entity!);
          }
          index = resultaat.volgendeIndex;
          break;

        default:
          index++;
          break;
      }
    }

    return OpmetingDeurpaneelDxfTekening(
      bestandsnaam: bestandsnaam,
      entities: List<OpmetingDeurpaneelDxfEntity>.unmodifiable(entities),
    );
  }

  static List<_DxfGroep> _leesGroepen(String inhoud) {
    final regels = inhoud
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n');

    final groepen = <_DxfGroep>[];

    for (var index = 0; index + 1 < regels.length; index += 2) {
      final codeTekst = regels[index].trim();
      final waarde = regels[index + 1].trim();
      final code = int.tryParse(codeTekst);

      if (code == null) {
        continue;
      }

      groepen.add(_DxfGroep(code: code, waarde: waarde));
    }

    return groepen;
  }

  static _ParseResult _parseLine(List<_DxfGroep> groepen, int startIndex) {
    double? x1;
    double? y1;
    double? x2;
    double? y2;

    var index = startIndex;

    while (index < groepen.length && groepen[index].code != 0) {
      final groep = groepen[index];
      final waarde = _doubleWaarde(groep.waarde);

      switch (groep.code) {
        case 10:
          x1 = waarde;
          break;
        case 20:
          y1 = waarde;
          break;
        case 11:
          x2 = waarde;
          break;
        case 21:
          y2 = waarde;
          break;
      }

      index++;
    }

    if (x1 == null || y1 == null || x2 == null || y2 == null) {
      return _ParseResult(volgendeIndex: index);
    }

    return _ParseResult(
      volgendeIndex: index,
      entity: OpmetingDeurpaneelDxfEntity.line(
        start: OpmetingDeurpaneelDxfPoint(x: x1, y: y1),
        einde: OpmetingDeurpaneelDxfPoint(x: x2, y: y2),
      ),
    );
  }

  static _ParseResult _parseLwPolyline(
    List<_DxfGroep> groepen,
    int startIndex,
  ) {
    final punten = <OpmetingDeurpaneelDxfPoint>[];
    var gesloten = false;
    double? x;

    var index = startIndex;

    while (index < groepen.length && groepen[index].code != 0) {
      final groep = groepen[index];

      switch (groep.code) {
        case 10:
          x = _doubleWaarde(groep.waarde);
          break;
        case 20:
          final huidigeX = x;
          final y = _doubleWaarde(groep.waarde);
          if (huidigeX != null && y != null) {
            punten.add(OpmetingDeurpaneelDxfPoint(x: huidigeX, y: y));
          }
          x = null;
          break;
        case 70:
          final vlag = int.tryParse(groep.waarde.trim()) ?? 0;
          gesloten = vlag & 1 == 1;
          break;
      }

      index++;
    }

    if (punten.length < 2) {
      return _ParseResult(volgendeIndex: index);
    }

    final puntenVoorEntity = List<OpmetingDeurpaneelDxfPoint>.from(punten);

    if (gesloten &&
        !_zelfdePunt(puntenVoorEntity.first, puntenVoorEntity.last)) {
      puntenVoorEntity.add(puntenVoorEntity.first);
    }

    return _ParseResult(
      volgendeIndex: index,
      entity: OpmetingDeurpaneelDxfEntity.polyline(points: puntenVoorEntity),
    );
  }

  static _ParseResult _parsePolyline(List<_DxfGroep> groepen, int startIndex) {
    final punten = <OpmetingDeurpaneelDxfPoint>[];
    var gesloten = false;
    var index = startIndex;

    while (index < groepen.length) {
      final groep = groepen[index];

      if (groep.code == 70) {
        final vlag = int.tryParse(groep.waarde.trim()) ?? 0;
        gesloten = vlag & 1 == 1;
        index++;
        continue;
      }

      if (groep.code == 0 && groep.waarde.trim().toUpperCase() == 'VERTEX') {
        final resultaat = _parseVertex(groepen, index + 1);
        if (resultaat.punt != null) {
          punten.add(resultaat.punt!);
        }
        index = resultaat.volgendeIndex;
        continue;
      }

      if (groep.code == 0 && groep.waarde.trim().toUpperCase() == 'SEQEND') {
        index++;
        break;
      }

      if (groep.code == 0) {
        break;
      }

      index++;
    }

    if (punten.length < 2) {
      return _ParseResult(volgendeIndex: index);
    }

    final puntenVoorEntity = List<OpmetingDeurpaneelDxfPoint>.from(punten);

    if (gesloten &&
        !_zelfdePunt(puntenVoorEntity.first, puntenVoorEntity.last)) {
      puntenVoorEntity.add(puntenVoorEntity.first);
    }

    return _ParseResult(
      volgendeIndex: index,
      entity: OpmetingDeurpaneelDxfEntity.polyline(points: puntenVoorEntity),
    );
  }

  static _VertexResult _parseVertex(List<_DxfGroep> groepen, int startIndex) {
    double? x;
    double? y;
    var index = startIndex;

    while (index < groepen.length && groepen[index].code != 0) {
      final groep = groepen[index];
      final waarde = _doubleWaarde(groep.waarde);

      switch (groep.code) {
        case 10:
          x = waarde;
          break;
        case 20:
          y = waarde;
          break;
      }

      index++;
    }

    if (x == null || y == null) {
      return _VertexResult(volgendeIndex: index);
    }

    return _VertexResult(
      volgendeIndex: index,
      punt: OpmetingDeurpaneelDxfPoint(x: x, y: y),
    );
  }

  static _ParseResult _parseCircle(List<_DxfGroep> groepen, int startIndex) {
    double? x;
    double? y;
    double? radius;
    var index = startIndex;

    while (index < groepen.length && groepen[index].code != 0) {
      final groep = groepen[index];
      final waarde = _doubleWaarde(groep.waarde);

      switch (groep.code) {
        case 10:
          x = waarde;
          break;
        case 20:
          y = waarde;
          break;
        case 40:
          radius = waarde;
          break;
      }

      index++;
    }

    if (x == null || y == null || radius == null || radius <= 0) {
      return _ParseResult(volgendeIndex: index);
    }

    return _ParseResult(
      volgendeIndex: index,
      entity: OpmetingDeurpaneelDxfEntity.circle(
        center: OpmetingDeurpaneelDxfPoint(x: x, y: y),
        radius: radius,
      ),
    );
  }

  static _ParseResult _parseArc(List<_DxfGroep> groepen, int startIndex) {
    double? x;
    double? y;
    double? radius;
    double? startAngle;
    double? endAngle;
    var index = startIndex;

    while (index < groepen.length && groepen[index].code != 0) {
      final groep = groepen[index];
      final waarde = _doubleWaarde(groep.waarde);

      switch (groep.code) {
        case 10:
          x = waarde;
          break;
        case 20:
          y = waarde;
          break;
        case 40:
          radius = waarde;
          break;
        case 50:
          startAngle = waarde;
          break;
        case 51:
          endAngle = waarde;
          break;
      }

      index++;
    }

    if (x == null ||
        y == null ||
        radius == null ||
        radius <= 0 ||
        startAngle == null ||
        endAngle == null) {
      return _ParseResult(volgendeIndex: index);
    }

    return _ParseResult(
      volgendeIndex: index,
      entity: OpmetingDeurpaneelDxfEntity.arc(
        center: OpmetingDeurpaneelDxfPoint(x: x, y: y),
        radius: radius,
        startAngleDeg: startAngle,
        endAngleDeg: endAngle,
      ),
    );
  }

  static double? _doubleWaarde(String tekst) {
    return double.tryParse(tekst.trim().replaceAll(',', '.'));
  }

  static bool _zelfdePunt(
    OpmetingDeurpaneelDxfPoint eerste,
    OpmetingDeurpaneelDxfPoint tweede,
  ) {
    return eerste.x == tweede.x && eerste.y == tweede.y;
  }
}

class _DxfGroep {
  const _DxfGroep({required this.code, required this.waarde});

  final int code;
  final String waarde;
}

class _ParseResult {
  const _ParseResult({required this.volgendeIndex, this.entity});

  final int volgendeIndex;
  final OpmetingDeurpaneelDxfEntity? entity;
}

class _VertexResult {
  const _VertexResult({required this.volgendeIndex, this.punt});

  final int volgendeIndex;
  final OpmetingDeurpaneelDxfPoint? punt;
}
