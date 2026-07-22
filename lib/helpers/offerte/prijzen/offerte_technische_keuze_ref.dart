// THIMACO-CONTROLE: PRIJSREF-HOE-UITSCHRIJVEN-20260720
class OfferteTechnischeKeuzeRef {
  const OfferteTechnischeKeuzeRef({
    this.formulierType = '',
    this.menuId = '',
    this.submenuId = '',
    this.keuzeId = '',
    this.menuTitelMomentopname = '',
    this.submenuTitelMomentopname = '',
    this.keuzeTitelMomentopname = '',
    this.hoeUitschrijvenMomentopname = '',
  });

  final String formulierType;
  final String menuId;
  final String submenuId;
  final String keuzeId;
  final String menuTitelMomentopname;
  final String submenuTitelMomentopname;
  final String keuzeTitelMomentopname;
  final String hoeUitschrijvenMomentopname;

  String get hoeUitschrijven {
    final tekst = hoeUitschrijvenMomentopname.trim();
    if (tekst.isNotEmpty) {
      return tekst;
    }

    final keuzeTitel = keuzeTitelMomentopname.trim();
    if (keuzeTitel.isNotEmpty) {
      return keuzeTitel;
    }

    return <String>[
      menuTitelMomentopname.trim(),
      submenuTitelMomentopname.trim(),
    ].where((deel) => deel.isNotEmpty).join(' · ');
  }

  bool get isLeeg {
    return formulierType.trim().isEmpty &&
        menuId.trim().isEmpty &&
        submenuId.trim().isEmpty &&
        keuzeId.trim().isEmpty &&
        menuTitelMomentopname.trim().isEmpty &&
        submenuTitelMomentopname.trim().isEmpty &&
        keuzeTitelMomentopname.trim().isEmpty &&
        hoeUitschrijvenMomentopname.trim().isEmpty;
  }

  OfferteTechnischeKeuzeRef copyWith({
    String? formulierType,
    String? menuId,
    String? submenuId,
    String? keuzeId,
    String? menuTitelMomentopname,
    String? submenuTitelMomentopname,
    String? keuzeTitelMomentopname,
    String? hoeUitschrijvenMomentopname,
  }) {
    return OfferteTechnischeKeuzeRef(
      formulierType: formulierType ?? this.formulierType,
      menuId: menuId ?? this.menuId,
      submenuId: submenuId ?? this.submenuId,
      keuzeId: keuzeId ?? this.keuzeId,
      menuTitelMomentopname:
          menuTitelMomentopname ?? this.menuTitelMomentopname,
      submenuTitelMomentopname:
          submenuTitelMomentopname ?? this.submenuTitelMomentopname,
      keuzeTitelMomentopname:
          keuzeTitelMomentopname ?? this.keuzeTitelMomentopname,
      hoeUitschrijvenMomentopname:
          hoeUitschrijvenMomentopname ?? this.hoeUitschrijvenMomentopname,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'formulierType': formulierType,
      'menuId': menuId,
      'submenuId': submenuId,
      'keuzeId': keuzeId,
      'menuTitelMomentopname': menuTitelMomentopname,
      'submenuTitelMomentopname': submenuTitelMomentopname,
      'keuzeTitelMomentopname': keuzeTitelMomentopname,
      'hoeUitschrijvenMomentopname': hoeUitschrijvenMomentopname,
    };
  }

  factory OfferteTechnischeKeuzeRef.fromJson(Map<String, dynamic> json) {
    return OfferteTechnischeKeuzeRef(
      formulierType: json['formulierType']?.toString() ?? '',
      menuId: json['menuId']?.toString() ?? '',
      submenuId: json['submenuId']?.toString() ?? '',
      keuzeId: json['keuzeId']?.toString() ?? '',
      menuTitelMomentopname: json['menuTitelMomentopname']?.toString() ?? '',
      submenuTitelMomentopname:
          json['submenuTitelMomentopname']?.toString() ?? '',
      keuzeTitelMomentopname: json['keuzeTitelMomentopname']?.toString() ?? '',
      hoeUitschrijvenMomentopname:
          json['hoeUitschrijvenMomentopname']?.toString() ??
          json['uitvoerTekstMomentopname']?.toString() ??
          '',
    );
  }

  static OfferteTechnischeKeuzeRef? fromJsonWaarde(Object? waarde) {
    if (waarde is! Map) {
      return null;
    }

    final resultaat = OfferteTechnischeKeuzeRef.fromJson(
      Map<String, dynamic>.from(waarde),
    );

    return resultaat.isLeeg ? null : resultaat;
  }
}
