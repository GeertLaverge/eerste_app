class OpmetingRaamTechnischeGroep {
  const OpmetingRaamTechnischeGroep({
    required this.id,
    required this.naam,
    required this.volgorde,
    this.zichtbaar = true,
  });

  final String id;
  final String naam;
  final int volgorde;
  final bool zichtbaar;

  OpmetingRaamTechnischeGroep copyWith({
    String? id,
    String? naam,
    int? volgorde,
    bool? zichtbaar,
  }) {
    return OpmetingRaamTechnischeGroep(
      id: id ?? this.id,
      naam: naam ?? this.naam,
      volgorde: volgorde ?? this.volgorde,
      zichtbaar: zichtbaar ?? this.zichtbaar,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'naam': naam,
      'volgorde': volgorde,
      'zichtbaar': zichtbaar,
    };
  }

  factory OpmetingRaamTechnischeGroep.fromJson(Map<String, dynamic> json) {
    final ruweVolgorde = json['volgorde'];
    final volgorde = ruweVolgorde is int
        ? ruweVolgorde
        : int.tryParse(ruweVolgorde?.toString() ?? '') ?? 0;

    return OpmetingRaamTechnischeGroep(
      id: json['id']?.toString().trim() ?? '',
      naam: json['naam']?.toString().trim() ?? '',
      volgorde: volgorde,
      zichtbaar: json['zichtbaar'] != false,
    );
  }
}
