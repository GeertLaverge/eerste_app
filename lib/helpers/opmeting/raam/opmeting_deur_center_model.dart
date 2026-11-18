// THIMACO-CONTROLE: PVC-CENTERS-MODEL-20261105
/// Geometrie van een PVC-deurcenter, afzonderlijk van de vulling opgeslagen.
enum OpmetingDeurCenterVariant { valseCenter, echteBoog }

enum OpmetingDeurCenterBoog { halveCirkel, segmentboog, korfboog }

class OpmetingDeurCenter {
  const OpmetingDeurCenter({
    required this.variant,
    required this.boog,
    this.startHoogteMm,
  });

  final OpmetingDeurCenterVariant variant;
  final OpmetingDeurCenterBoog boog;

  /// Hoogte van het begin van de boog, vanaf de onderzijde van de deur.
  /// Bij een halve cirkel volgt deze automatisch uit de breedte.
  final int? startHoogteMm;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'variant': variant.name,
    'boog': boog.name,
    if (startHoogteMm != null) 'startHoogteMm': startHoogteMm,
  };

  factory OpmetingDeurCenter.fromJson(Map<String, dynamic> json) {
    T leesEnum<T extends Enum>(List<T> waarden, Object? bron, T standaard) {
      for (final waarde in waarden) {
        if (waarde.name == bron?.toString()) return waarde;
      }
      return standaard;
    }

    return OpmetingDeurCenter(
      variant: leesEnum(OpmetingDeurCenterVariant.values, json['variant'],
          OpmetingDeurCenterVariant.valseCenter),
      boog: leesEnum(OpmetingDeurCenterBoog.values, json['boog'],
          OpmetingDeurCenterBoog.halveCirkel),
      startHoogteMm: int.tryParse(json['startHoogteMm']?.toString() ?? ''),
    );
  }
}
