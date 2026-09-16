import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../ui/thimaco_huisstijl.dart';
import '../fotos/opmeting_foto_model.dart';

class OpmetingRaamNotities extends StatefulWidget {
  const OpmetingRaamNotities({
    super.key,
    required this.controller,
    required this.fotos,
    required this.onFotosGewijzigd,
  });

  final TextEditingController controller;
  final List<OpmetingFoto> fotos;
  final ValueChanged<List<OpmetingFoto>> onFotosGewijzigd;

  @override
  State<OpmetingRaamNotities> createState() => _OpmetingRaamNotitiesState();
}

class _OpmetingRaamNotitiesState extends State<OpmetingRaamNotities> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _cameraBezig = false;

  Future<void> _neemFoto() async {
    if (_cameraBezig) {
      return;
    }

    setState(() {
      _cameraBezig = true;
    });

    try {
      final gekozenFoto = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 70,
        requestFullMetadata: false,
      );

      if (gekozenFoto == null) {
        return;
      }

      final bytes = await gekozenFoto.readAsBytes();

      if (bytes.isEmpty) {
        throw StateError('De gemaakte foto bevat geen beeldgegevens.');
      }

      final nu = DateTime.now().toUtc();
      final nieuweFoto = OpmetingFoto(
        id: 'foto_${nu.microsecondsSinceEpoch}',
        bestandsNaam: gekozenFoto.name.trim().isEmpty
            ? 'opmeting_${nu.microsecondsSinceEpoch}.jpg'
            : gekozenFoto.name,
        mimeType: _mimeTypeVoorBestandsNaam(gekozenFoto.name),
        gemaaktOp: nu.toIso8601String(),
        base64Data: base64Encode(bytes),
      );

      widget.onFotosGewijzigd(<OpmetingFoto>[...widget.fotos, nieuweFoto]);
    } catch (fout) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text('Foto nemen is niet gelukt: $fout'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _cameraBezig = false;
        });
      }
    }
  }

  String _mimeTypeVoorBestandsNaam(String bestandsNaam) {
    final naam = bestandsNaam.trim().toLowerCase();

    if (naam.endsWith('.png')) {
      return 'image/png';
    }

    if (naam.endsWith('.webp')) {
      return 'image/webp';
    }

    if (naam.endsWith('.heic') || naam.endsWith('.heif')) {
      return 'image/heic';
    }

    return 'image/jpeg';
  }

  void _verwijderFoto(OpmetingFoto foto) {
    widget.onFotosGewijzigd(
      widget.fotos.where((bestaand) => bestaand.id != foto.id).toList(),
    );
  }

  Future<void> _toonFoto(OpmetingFoto foto) async {
    final bytes = foto.bytes;

    if (bytes.isEmpty) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(dialogContext).width - 48,
                  maxHeight: MediaQuery.sizeOf(dialogContext).height - 48,
                ),
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 5,
                  child: Image.memory(bytes, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ThimacoKleuren.rand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Opmerkingen',
                      style: TextStyle(
                        color: ThimacoKleuren.antraciet,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    SizedBox(
                      width: 32,
                      child: Divider(
                        height: 1.5,
                        thickness: 1.5,
                        color: ThimacoKleuren.oranje,
                      ),
                    ),
                  ],
                ),
              ),
              if (_cameraBezig)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
                      color: ThimacoKleuren.oranje,
                    ),
                  ),
                )
              else
                ThimacoIcoonActie(
                  icoon: Icons.camera_alt_outlined,
                  tooltip: 'Foto nemen',
                  onPressed: _neemFoto,
                  grootte: 19,
                ),
            ],
          ),
          const SizedBox(height: 7),
          TextField(
            controller: widget.controller,
            minLines: 1,
            maxLines: 3,
            textInputAction: TextInputAction.newline,
            cursorColor: ThimacoKleuren.oranje,
            style: const TextStyle(
              color: ThimacoKleuren.antraciet,
              fontSize: 12.5,
            ),
            decoration: InputDecoration(
              hintText: 'Opmerkingen bij deze positie...',
              hintStyle: const TextStyle(
                color: ThimacoKleuren.tekstGrijs,
                fontSize: 12,
              ),
              isDense: true,
              filled: true,
              fillColor: ThimacoKleuren.achtergrond,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 9,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: ThimacoKleuren.rand),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: ThimacoKleuren.rand),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: ThimacoKleuren.oranje,
                  width: 1.4,
                ),
              ),
            ),
          ),
          if (widget.fotos.isNotEmpty) ...[
            const SizedBox(height: 9),
            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.fotos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final foto = widget.fotos[index];
                  final bytes = foto.bytes;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: bytes.isEmpty ? null : () => _toonFoto(foto),
                        child: Container(
                          width: 86,
                          height: 66,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: ThimacoKleuren.achtergrond,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: ThimacoKleuren.rand),
                          ),
                          child: bytes.isEmpty
                              ? const Icon(
                                  Icons.broken_image_outlined,
                                  color: ThimacoKleuren.tekstGrijs,
                                )
                              : Image.memory(
                                  bytes,
                                  fit: BoxFit.cover,
                                  gaplessPlayback: true,
                                ),
                        ),
                      ),
                      Positioned(
                        top: -5,
                        right: -5,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => _verwijderFoto(foto),
                          child: Container(
                            width: 23,
                            height: 23,
                            decoration: BoxDecoration(
                              color: ThimacoKleuren.rood,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
