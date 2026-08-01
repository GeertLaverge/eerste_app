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
}
