import 'dart:convert';
import 'dart:typed_data';

class OpmetingFoto {
  const OpmetingFoto({
    required this.id,
    required this.bestandsNaam,
    required this.mimeType,
    required this.gemaaktOp,
    required this.base64Data,
  });

  final String id;
  final String bestandsNaam;
  final String mimeType;
  final String gemaaktOp;
  final String base64Data;

  bool get heeftAfbeelding => base64Data.trim().isNotEmpty;

  Uint8List get bytes {
    final data = base64Data.trim();

    if (data.isEmpty) {
      return Uint8List(0);
    }

    try {
      return base64Decode(data);
    } catch (_) {
      return Uint8List(0);
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'bestandsNaam': bestandsNaam,
      'mimeType': mimeType,
      'gemaaktOp': gemaaktOp,
      'base64Data': base64Data,
    };
  }

  factory OpmetingFoto.fromJson(Map<String, dynamic> json) {
    return OpmetingFoto(
      id: json['id']?.toString() ?? '',
      bestandsNaam: json['bestandsNaam']?.toString() ?? '',
      mimeType: json['mimeType']?.toString() ?? 'image/jpeg',
      gemaaktOp: json['gemaaktOp']?.toString() ?? '',
      base64Data: json['base64Data']?.toString() ?? '',
    );
  }
}
