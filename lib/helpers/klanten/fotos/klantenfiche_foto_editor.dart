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
            final handleGevonden = controller.selecteerHandleOpPunt(
              details.localPosition,
            );

            if (!handleGevonden) {
              controller.selecteerLijnOpPunt(
                details.localPosition,
              );
            }
          });
        },
        onPanStart: (details) {
          setState(() {
            if (controller.actieveTool == FotoEditorTool.rechteLijn) {
              controller.rechteLijnStart = details.localPosition;
              controller.deselecteerAlles();
              return;
            }

            controller.startNieuweLijn(
              details.localPosition,
            );
          });
        },
        onPanUpdate: (details) {
          if (controller.geselecteerdHandleIndex != null) {
            setState(() {
              controller.verplaatsHandle(
                details.localPosition,
              );
            });
            return;
          }

          if (controller.actieveTool != FotoEditorTool.tekenen) {
            return;
          }

          setState(() {
            controller.voegPuntToe(
              details.localPosition,
            );
          });
        },
        onPanEnd: (details) {
          setState(() {
            controller.geselecteerdHandleIndex = null;
            if (controller.actieveTool == FotoEditorTool.rechteLijn &&
                controller.rechteLijnStart != null) {
              final eindPunt = details.localPosition;

              controller.lijnen.add(
                TekenLijn(
                  punten: [
                    controller.rechteLijnStart!,
                    eindPunt,
                  ],
                  kleur: controller.actieveKleur,
                ),
              );

              controller.rechteLijnStart = null;
              return;
            }

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
              IconButton(
                onPressed: () {
                  setState(() {
                    controller.actieveTool = FotoEditorTool.tekenen;
                  });
                },
                icon: Icon(
                  Icons.edit,
                  color: controller.actieveTool == FotoEditorTool.tekenen
                      ? const Color(0xFF0B7A3B)
                      : Colors.grey,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    controller.actieveTool = FotoEditorTool.rechteLijn;
                  });
                },
                icon: Icon(
                  Icons.horizontal_rule,
                  color: controller.actieveTool == FotoEditorTool.rechteLijn
                      ? const Color(0xFF0B7A3B)
                      : Colors.grey,
                ),
              ),
              _kleurKnop(const Color(0xFF0B7A3B)),
              _kleurKnop(Colors.red),
              _kleurKnop(Colors.blue),
              _kleurKnop(Colors.amber),
              _kleurKnop(Colors.black),
              IconButton(
                onPressed: () {
                  setState(() {
                    if (controller.geselecteerdeLijn != null) {
                      controller.verwijderGeselecteerdeLijn();
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text(
                              'Alle tekeningen wissen?',
                            ),
                            content: const Text(
                              'Er is geen lijn geselecteerd. Wilt u alle tekeningen verwijderen?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Annuleren'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);

                                  setState(() {
                                    controller.wisAlles();
                                  });
                                },
                                child: const Text(
                                  'Wissen',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }
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
