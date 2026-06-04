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
  Widget _kleurKnop(Color kleur) {
    final actief = controller.actieveKleur == kleur;

    return GestureDetector(
      onTap: () {
        setState(() {
          controller.kiesKleur(kleur);
        });
      },
      child: Container(
        width: actief ? 28 : 22,
        height: actief ? 28 : 22,
        decoration: BoxDecoration(
          color: kleur,
          shape: BoxShape.circle,
          border: Border.all(
            color: actief ? Colors.black : Colors.grey.shade300,
            width: actief ? 3 : 1,
          ),
        ),
      ),
    );
  }

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
        onTapDown: (details) {
          setState(() {
            controller.selecteerLijnOpPunt(
              details.localPosition,
            );
          });
        },
        onPanStart: (details) {
          setState(() {
            controller.startNieuweLijn(
              details.localPosition,
            );
          });
        },
        onPanUpdate: (details) {
          setState(() {
            controller.voegPuntToe(
              details.localPosition,
            );
          });
        },
        onPanEnd: (_) {
          setState(() {
            controller.eindigLijn();
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
                  lijnen: controller.lijnen,
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
              _kleurKnop(const Color(0xFF0B7A3B)),
              _kleurKnop(Colors.red),
              _kleurKnop(Colors.blue),
              _kleurKnop(Colors.amber),
              _kleurKnop(Colors.black),
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
