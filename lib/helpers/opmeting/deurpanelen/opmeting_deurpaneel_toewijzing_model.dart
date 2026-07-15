import 'package:flutter/foundation.dart';

import 'opmeting_deurpaneel_model.dart';

@immutable
class OpmetingDeurpaneelToewijzing {
  const OpmetingDeurpaneelToewijzing({
    required this.id,
    required this.deurVleugelId,
    required this.paneelId,
    required this.paneelNaam,
    required this.tekeningBestandsnaam,
    required this.uitvoering,
    this.cilinderZijde = OpmetingDeurpaneelCilinderZijde.geen,
    this.gewijzigdOp,
  });

  final String id;
  final String deurVleugelId;
  final String paneelId;
  final String paneelNaam;
  final String tekeningBestandsnaam;
  final OpmetingDeurpaneelUitvoering uitvoering;
  final OpmetingDeurpaneelCilinderZijde cilinderZijde;
  final DateTime? gewijzigdOp;

  factory OpmetingDeurpaneelToewijzing.vanKeuze({
    required String deurVleugelId,
    required OpmetingDeurpaneelKeuze keuze,
  }) {
    return OpmetingDeurpaneelToewijzing(
      id: '${deurVleugelId.trim()}::${keuze.paneel.id.trim()}',
      deurVleugelId: deurVleugelId.trim(),
      paneelId: keuze.paneel.id.trim(),
      paneelNaam: keuze.paneel.naam.trim(),
      tekeningBestandsnaam: keuze.paneel.tekeningBestandsnaam.trim(),
      uitvoering: keuze.uitvoering,
      cilinderZijde: keuze.paneel.cilinderZijde,
      gewijzigdOp: DateTime.now(),
    );
  }

  OpmetingDeurpaneelToewijzing copyWith({
    String? id,
    String? deurVleugelId,
    String? paneelId,
    String? paneelNaam,
    String? tekeningBestandsnaam,
    OpmetingDeurpaneelUitvoering? uitvoering,
    OpmetingDeurpaneelCilinderZijde? cilinderZijde,
    DateTime? gewijzigdOp,
  }) {
    return OpmetingDeurpaneelToewijzing(
      id: id ?? this.id,
      deurVleugelId: deurVleugelId ?? this.deurVleugelId,
      paneelId: paneelId ?? this.paneelId,
      paneelNaam: paneelNaam ?? this.paneelNaam,
      tekeningBestandsnaam: tekeningBestandsnaam ?? this.tekeningBestandsnaam,
      uitvoering: uitvoering ?? this.uitvoering,
      cilinderZijde: cilinderZijde ?? this.cilinderZijde,
      gewijzigdOp: gewijzigdOp ?? this.gewijzigdOp,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'deurVleugelId': deurVleugelId,
      'paneelId': paneelId,
      'paneelNaam': paneelNaam,
      'tekeningBestandsnaam': tekeningBestandsnaam,
      'uitvoering': uitvoering.opslagWaarde,
      'cilinderZijde': cilinderZijde.opslagWaarde,
      'gewijzigdOp': gewijzigdOp?.toIso8601String(),
    };
  }

  factory OpmetingDeurpaneelToewijzing.fromJson(Map<String, dynamic> json) {
    return OpmetingDeurpaneelToewijzing(
      id: json['id']?.toString() ?? '',
      deurVleugelId: json['deurVleugelId']?.toString() ?? '',
      paneelId: json['paneelId']?.toString() ?? '',
      paneelNaam: json['paneelNaam']?.toString() ?? '',
      tekeningBestandsnaam: json['tekeningBestandsnaam']?.toString() ?? '',
      uitvoering: OpmetingDeurpaneelUitvoeringInfo.vanOpslagWaarde(
        json['uitvoering'],
      ),
      cilinderZijde: OpmetingDeurpaneelCilinderZijdeInfo.vanTekst(
        json['cilinderZijde'],
      ),
      gewijzigdOp: _leesDatum(json['gewijzigdOp']),
    );
  }

  static DateTime? _leesDatum(Object? waarde) {
    if (waarde == null) {
      return null;
    }

    return DateTime.tryParse(waarde.toString());
  }
}
