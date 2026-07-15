import 'dart:math' as math;

enum OpmetingDeurpaneelDxfEntityType { line, polyline, circle, arc }

class OpmetingDeurpaneelDxfPoint {
  const OpmetingDeurpaneelDxfPoint({required this.x, required this.y});

  final double x;
  final double y;

  @override
  String toString() {
    return 'OpmetingDeurpaneelDxfPoint(x: $x, y: $y)';
  }
}

class OpmetingDeurpaneelDxfBounds {
  const OpmetingDeurpaneelDxfBounds({
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
  });

  factory OpmetingDeurpaneelDxfBounds.leeg() {
    return const OpmetingDeurpaneelDxfBounds(
      minX: 0,
      minY: 0,
      maxX: 0,
      maxY: 0,
    );
  }

  factory OpmetingDeurpaneelDxfBounds.vanPunten(
    Iterable<OpmetingDeurpaneelDxfPoint> punten,
  ) {
    var heeftPunten = false;
    var minX = 0.0;
    var minY = 0.0;
    var maxX = 0.0;
    var maxY = 0.0;

    for (final punt in punten) {
      if (!heeftPunten) {
        minX = punt.x;
        maxX = punt.x;
        minY = punt.y;
        maxY = punt.y;
        heeftPunten = true;
        continue;
      }

      minX = math.min(minX, punt.x);
      maxX = math.max(maxX, punt.x);
      minY = math.min(minY, punt.y);
      maxY = math.max(maxY, punt.y);
    }

    if (!heeftPunten) {
      return OpmetingDeurpaneelDxfBounds.leeg();
    }

    return OpmetingDeurpaneelDxfBounds(
      minX: minX,
      minY: minY,
      maxX: maxX,
      maxY: maxY,
    );
  }

  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  double get width {
    return maxX - minX;
  }

  double get height {
    return maxY - minY;
  }

  bool get isLeeg {
    return width == 0 && height == 0;
  }

  OpmetingDeurpaneelDxfBounds voegSamen(OpmetingDeurpaneelDxfBounds andere) {
    if (isLeeg) {
      return andere;
    }

    if (andere.isLeeg) {
      return this;
    }

    return OpmetingDeurpaneelDxfBounds(
      minX: math.min(minX, andere.minX),
      minY: math.min(minY, andere.minY),
      maxX: math.max(maxX, andere.maxX),
      maxY: math.max(maxY, andere.maxY),
    );
  }
}

class OpmetingDeurpaneelDxfEntity {
  const OpmetingDeurpaneelDxfEntity._({
    required this.type,
    this.points = const <OpmetingDeurpaneelDxfPoint>[],
    this.center,
    this.radius,
    this.startAngleDeg,
    this.endAngleDeg,
  });

  factory OpmetingDeurpaneelDxfEntity.line({
    required OpmetingDeurpaneelDxfPoint start,
    required OpmetingDeurpaneelDxfPoint einde,
  }) {
    return OpmetingDeurpaneelDxfEntity._(
      type: OpmetingDeurpaneelDxfEntityType.line,
      points: <OpmetingDeurpaneelDxfPoint>[start, einde],
    );
  }

  factory OpmetingDeurpaneelDxfEntity.polyline({
    required List<OpmetingDeurpaneelDxfPoint> points,
  }) {
    return OpmetingDeurpaneelDxfEntity._(
      type: OpmetingDeurpaneelDxfEntityType.polyline,
      points: List<OpmetingDeurpaneelDxfPoint>.unmodifiable(points),
    );
  }

  factory OpmetingDeurpaneelDxfEntity.circle({
    required OpmetingDeurpaneelDxfPoint center,
    required double radius,
  }) {
    return OpmetingDeurpaneelDxfEntity._(
      type: OpmetingDeurpaneelDxfEntityType.circle,
      center: center,
      radius: radius,
    );
  }

  factory OpmetingDeurpaneelDxfEntity.arc({
    required OpmetingDeurpaneelDxfPoint center,
    required double radius,
    required double startAngleDeg,
    required double endAngleDeg,
  }) {
    return OpmetingDeurpaneelDxfEntity._(
      type: OpmetingDeurpaneelDxfEntityType.arc,
      center: center,
      radius: radius,
      startAngleDeg: startAngleDeg,
      endAngleDeg: endAngleDeg,
    );
  }

  final OpmetingDeurpaneelDxfEntityType type;
  final List<OpmetingDeurpaneelDxfPoint> points;
  final OpmetingDeurpaneelDxfPoint? center;
  final double? radius;
  final double? startAngleDeg;
  final double? endAngleDeg;

  OpmetingDeurpaneelDxfBounds get bounds {
    switch (type) {
      case OpmetingDeurpaneelDxfEntityType.line:
      case OpmetingDeurpaneelDxfEntityType.polyline:
        return OpmetingDeurpaneelDxfBounds.vanPunten(points);

      case OpmetingDeurpaneelDxfEntityType.circle:
        final middelpunt = center;
        final straal = radius ?? 0;

        if (middelpunt == null || straal <= 0) {
          return OpmetingDeurpaneelDxfBounds.leeg();
        }

        return OpmetingDeurpaneelDxfBounds(
          minX: middelpunt.x - straal,
          minY: middelpunt.y - straal,
          maxX: middelpunt.x + straal,
          maxY: middelpunt.y + straal,
        );

      case OpmetingDeurpaneelDxfEntityType.arc:
        return OpmetingDeurpaneelDxfBounds.vanPunten(
          sampleArcPunten(aantalSegmenten: 40),
        );
    }
  }

  List<OpmetingDeurpaneelDxfPoint> sampleCirclePunten({
    int aantalSegmenten = 64,
  }) {
    final middelpunt = center;
    final straal = radius ?? 0;

    if (middelpunt == null || straal <= 0 || aantalSegmenten < 4) {
      return const <OpmetingDeurpaneelDxfPoint>[];
    }

    final punten = <OpmetingDeurpaneelDxfPoint>[];

    for (var index = 0; index <= aantalSegmenten; index++) {
      final hoek = (math.pi * 2 * index) / aantalSegmenten;
      punten.add(
        OpmetingDeurpaneelDxfPoint(
          x: middelpunt.x + math.cos(hoek) * straal,
          y: middelpunt.y + math.sin(hoek) * straal,
        ),
      );
    }

    return punten;
  }

  List<OpmetingDeurpaneelDxfPoint> sampleArcPunten({int aantalSegmenten = 40}) {
    final middelpunt = center;
    final straal = radius ?? 0;
    final start = startAngleDeg;
    final einde = endAngleDeg;

    if (middelpunt == null ||
        straal <= 0 ||
        start == null ||
        einde == null ||
        aantalSegmenten < 2) {
      return const <OpmetingDeurpaneelDxfPoint>[];
    }

    var startRad = _gradenNaarRadialen(start);
    var eindeRad = _gradenNaarRadialen(einde);

    while (eindeRad < startRad) {
      eindeRad += math.pi * 2;
    }

    final punten = <OpmetingDeurpaneelDxfPoint>[];

    for (var index = 0; index <= aantalSegmenten; index++) {
      final fractie = index / aantalSegmenten;
      final hoek = startRad + ((eindeRad - startRad) * fractie);
      punten.add(
        OpmetingDeurpaneelDxfPoint(
          x: middelpunt.x + math.cos(hoek) * straal,
          y: middelpunt.y + math.sin(hoek) * straal,
        ),
      );
    }

    return punten;
  }

  static double _gradenNaarRadialen(double graden) {
    return graden * math.pi / 180.0;
  }
}

class OpmetingDeurpaneelDxfTekening {
  const OpmetingDeurpaneelDxfTekening({
    required this.bestandsnaam,
    required this.entities,
  });

  final String bestandsnaam;
  final List<OpmetingDeurpaneelDxfEntity> entities;

  bool get isLeeg {
    return entities.isEmpty;
  }

  OpmetingDeurpaneelDxfBounds get bounds {
    if (entities.isEmpty) {
      return OpmetingDeurpaneelDxfBounds.leeg();
    }

    var samengevoegd = entities.first.bounds;

    for (final entity in entities.skip(1)) {
      samengevoegd = samengevoegd.voegSamen(entity.bounds);
    }

    return samengevoegd;
  }
}
