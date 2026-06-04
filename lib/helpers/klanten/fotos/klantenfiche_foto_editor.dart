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
      body: GestureDetector(
        onPanStart: (details) {
          setState(() {
            controller.tekenPunten.add(
              details.localPosition,
            );
          });
        },
        onPanUpdate: (details) {
          setState(() {
            controller.tekenPunten.add(
              details.localPosition,
            );
          });
        },
        onPanEnd: (_) {
          setState(() {
            controller.tekenPunten.add(null);
          });
        },
        child: Center(
          child: Stack(
            children: [
              Image.file(
                widget.bestand,
                fit: BoxFit.contain,
              ),
              CustomPaint(
                size: Size.infinite,
                painter: KlantenficheFotoTekeningPainter(
                  punten: controller.tekenPunten,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 60,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Icon(
                Icons.edit,
                color: Color(0xFF0B7A3B),
              ),
              const Icon(Icons.text_fields),
              const Icon(Icons.arrow_upward),
              const Icon(Icons.circle_outlined),
              const Icon(Icons.crop_square),
              IconButton(
                onPressed: () {
                  setState(() {
                    controller.wisAlles();
                  });
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
