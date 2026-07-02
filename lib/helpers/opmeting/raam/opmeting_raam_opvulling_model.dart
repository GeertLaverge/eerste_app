import 'package:flutter/material.dart';

class OpmetingRaamOpvullingModel {
  const OpmetingRaamOpvullingModel({
    required this.id,
    required this.naam,
    required this.kleurWaarde,
    required this.transparantie,
  });

  final String id;
  final String naam;
  final int kleurWaarde;

  /// Waarde tussen 0.05 en 1.00.
  final double transparantie;

  Color get kleur => Color(kleurWaarde);

  Color get weergaveKleur {
    return kleur.withOpacity(transparantie.clamp(0.05, 1.0).toDouble());
  }

  int get transparantiePercentage {
    return (transparantie * 100).round();
  }

  OpmetingRaamOpvullingModel copyWith({
    String? id,
    String? naam,
    int? kleurWaarde,
    double? transparantie,
  }) {
    return OpmetingRaamOpvullingModel(
      id: id ?? this.id,
      naam: naam ?? this.naam,
      kleurWaarde: kleurWaarde ?? this.kleurWaarde,
      transparantie: transparantie ?? this.transparantie,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'naam': naam,
      'kleurWaarde': kleurWaarde,
      'transparantie': transparantie,
    };
  }

  factory OpmetingRaamOpvullingModel.fromJson(Map<String, dynamic> json) {
    final transparantieWaarde =
        (json['transparantie'] as num?)?.toDouble() ?? 0.25;

    return OpmetingRaamOpvullingModel(
      id:
          json['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      naam: json['naam']?.toString() ?? '',
      kleurWaarde: (json['kleurWaarde'] as num?)?.toInt() ?? 0xFFB3E5FC,
      transparantie: transparantieWaarde.clamp(0.05, 1.0).toDouble(),
    );
  }
}
