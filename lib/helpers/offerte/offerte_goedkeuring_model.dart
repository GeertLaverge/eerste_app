import 'dart:convert';
import 'dart:typed_data';

class OfferteGoedkeuring {
  const OfferteGoedkeuring({
    required this.naam,
    required this.getekendOp,
    required this.handtekeningPng,
  });

  final String naam;
  final DateTime getekendOp;
  final Uint8List handtekeningPng;

  bool get isOndertekend =>
      naam.trim().isNotEmpty && handtekeningPng.isNotEmpty;

  factory OfferteGoedkeuring.leeg() {
    return OfferteGoedkeuring(
      naam: '',
      getekendOp: DateTime.fromMillisecondsSinceEpoch(0),
      handtekeningPng: Uint8List(0),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'naam': naam,
      'getekendOp': getekendOp.toUtc().toIso8601String(),
      'handtekeningPngBase64': base64Encode(handtekeningPng),
    };
  }

  factory OfferteGoedkeuring.fromJson(Map<String, dynamic> json) {
    final base64Waarde = json['handtekeningPngBase64']?.toString() ?? '';
    Uint8List handtekening = Uint8List(0);

    if (base64Waarde.trim().isNotEmpty) {
      try {
        handtekening = Uint8List.fromList(base64Decode(base64Waarde));
      } catch (_) {
        handtekening = Uint8List(0);
      }
    }

    return OfferteGoedkeuring(
      naam: json['naam']?.toString() ?? '',
      getekendOp:
          DateTime.tryParse(json['getekendOp']?.toString() ?? '')?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      handtekeningPng: handtekening,
    );
  }
}
