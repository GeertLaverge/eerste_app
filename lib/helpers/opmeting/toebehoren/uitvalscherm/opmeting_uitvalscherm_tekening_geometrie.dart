import 'dart:math' as math;

import 'opmeting_uitvalscherm_model.dart';

enum OpmetingUitvalschermKastVorm { rechthoekig, schuin500X }

class OpmetingUitvalschermTekeningGeometrie {
  const OpmetingUitvalschermTekeningGeometrie({
    required this.kastVorm,
    required this.kastHoogteMm,
    required this.kastDiepteMm,
    required this.frontHoogteMm,
    required this.kastX,
    required this.kastY,
    required this.kastBreedte,
    required this.kastHoogte,
    required this.doekStartX,
    required this.doekStartY,
    required this.doekEindX,
    required this.doekEindY,
    required this.armStartX,
    required this.armStartY,
    required this.armKnikX,
    required this.armKnikY,
    required this.armEindX,
    required this.armEindY,
    required this.voorplaatX,
    required this.voorplaatY,
    required this.voorplaatBreedte,
    required this.voorplaatHoogte,
    required this.frontLinks,
    required this.frontBoven,
    required this.frontBreedte,
    required this.frontHoogte,
    required this.toon500XLabel,
  });

  static const double viewBreedte = 900;
  static const double viewHoogte = 600;

  static const double muurZijX = 82;
  static const double muurZijY = 62;
  static const double muurZijBreedte = 34;
  static const double muurZijHoogte = 205;

  static const double kleurCirkelX = 770;
  static const double kleurCirkelY = 135;
  static const double kleurCirkelStraal = 62;

  final OpmetingUitvalschermKastVorm kastVorm;
  final int kastHoogteMm;
  final int kastDiepteMm;
  final int frontHoogteMm;

  final double kastX;
  final double kastY;
  final double kastBreedte;
  final double kastHoogte;

  final double doekStartX;
  final double doekStartY;
  final double doekEindX;
  final double doekEindY;

  final double armStartX;
  final double armStartY;
  final double armKnikX;
  final double armKnikY;
  final double armEindX;
  final double armEindY;

  final double voorplaatX;
  final double voorplaatY;
  final double voorplaatBreedte;
  final double voorplaatHoogte;

  final double frontLinks;
  final double frontBoven;
  final double frontBreedte;
  final double frontHoogte;
  final bool toon500XLabel;

  double get kastRechts => kastX + kastBreedte;
  double get kastOnder => kastY + kastHoogte;
  double get frontRechts => frontLinks + frontBreedte;
  double get frontOnder => frontBoven + frontHoogte;

  static OpmetingUitvalschermTekeningGeometrie voorModel(
    OpmetingUitvalschermModel model,
  ) {
    late final OpmetingUitvalschermKastVorm vorm;
    late final int kastHoogteMm;
    late final int kastDiepteMm;
    late final int frontHoogteMm;

    if (model.type.is500X) {
      vorm = OpmetingUitvalschermKastVorm.schuin500X;
      kastHoogteMm = 109;
      kastDiepteMm = 259;
      frontHoogteMm = 180;
    } else {
      // 700 LX en 700 X gebruiken exact dezelfde rechthoekige kast.
      vorm = OpmetingUitvalschermKastVorm.rechthoekig;
      kastHoogteMm = 230;
      kastDiepteMm = 150;
      frontHoogteMm = 210;
    }

    const dimensieSchaal = 0.38;
    final kastHoogte = kastHoogteMm * dimensieSchaal;
    final kastBreedte = kastDiepteMm * dimensieSchaal;
    const kastX = 116.0;
    final kastY = 150 - kastHoogte / 2;

    final uitvalLengte = _schaalUitval(model.uitvalMm);
    final doekStartX = kastX + kastBreedte;
    final doekStartY = kastY + kastHoogte * 0.31;
    final double doekEindX = math.min<double>(doekStartX + uitvalLengte, 650.0);
    final helling = model.type.is500X ? 0.12 : 0.15;
    final doekEindY = doekStartY + (doekEindX - doekStartX) * helling;

    // Laat de arm net buiten de kast starten zodat hij niet op de kast getekend wordt.
    final armStartX = kastX + kastBreedte + 3.0;
    final armStartY = kastY + kastHoogte * 0.80;
    final double armEindX = doekEindX - 13.0;
    final armEindY = doekEindY + 14;
    // Scharnierpunt in het midden houden en licht naar beneden verplaatsen
    // zodat de arm een kleine knik krijgt zoals op de referentie.
    final armKnikX = (armStartX + armEindX) / 2;
    final armKnikY = ((armStartY + armEindY) / 2) + 8.0;

    final frontBreedte = _schaalBreedte(
      breedteMm: model.breedteMm,
      maximumBreedteMm: model.maximumBreedteMm,
    );
    final frontHoogte = frontHoogteMm * 0.40;
    final frontLinks = 430 - frontBreedte / 2;
    const frontBoven = 395.0;

    return OpmetingUitvalschermTekeningGeometrie(
      kastVorm: vorm,
      kastHoogteMm: kastHoogteMm,
      kastDiepteMm: kastDiepteMm,
      frontHoogteMm: frontHoogteMm,
      kastX: kastX,
      kastY: kastY,
      kastBreedte: kastBreedte,
      kastHoogte: kastHoogte,
      doekStartX: doekStartX,
      doekStartY: doekStartY,
      doekEindX: doekEindX,
      doekEindY: doekEindY,
      armStartX: armStartX,
      armStartY: armStartY,
      armKnikX: armKnikX,
      armKnikY: armKnikY,
      armEindX: armEindX,
      armEindY: armEindY,
      voorplaatX: doekEindX - 7,
      voorplaatY: doekEindY - 16,
      voorplaatBreedte: 14,
      voorplaatHoogte: 35,
      frontLinks: frontLinks,
      frontBoven: frontBoven,
      frontBreedte: frontBreedte,
      frontHoogte: frontHoogte,
      toon500XLabel: model.type.is500X,
    );
  }

  static double _schaalUitval(int uitvalMm) {
    final waarde = uitvalMm.clamp(500, 3500).toDouble();
    return 110.0 + ((waarde - 500.0) / 3000.0) * 330.0;
  }

  static double _schaalBreedte({
    required int breedteMm,
    required int maximumBreedteMm,
  }) {
    final maximum = math.max(2300, maximumBreedteMm).toInt();
    final begrensd = breedteMm.clamp(2300, maximum).toDouble();
    final verhouding = maximum == 2300
        ? 1.0
        : (begrensd - 2300.0) / (maximum - 2300.0);
    return 300.0 + verhouding * 300.0;
  }
}
