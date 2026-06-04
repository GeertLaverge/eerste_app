import 'dart:io';

import 'package:flutter/material.dart';

import 'klantenfiche_foto_editor_controller.dart';
import 'klantenfiche_foto_tekening_painter.dart';

class KlantenficheFotoEditor extends StatefulWidget {
  final File bestand;

  const KlantenficheFotoEditor({
    super.key,
    required this.bestand,
  });

  @override
  State<KlantenficheFotoEditor> createState() => _KlantenficheFotoEditorState();
}

class _KlantenficheFotoEditorState extends State<KlantenficheFotoEditor> {
  final controller = KlantenficheFotoEditorController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Foto bewerken'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Opslaan',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Stack(
          children: [
            Image.file(
              widget.bestand,
              fit: BoxFit.contain,
            ),
            IgnorePointer(
              child: CustomPaint(
                size: Size.infinite,
                painter: KlantenficheFotoTekeningPainter(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 60,
          color: Colors.white,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.edit),
              Icon(Icons.text_fields),
              Icon(Icons.arrow_upward),
              Icon(Icons.circle_outlined),
              Icon(Icons.crop_square),
              Icon(Icons.delete_outline),
            ],
          ),
        ),
      ),
    );
  }
}
