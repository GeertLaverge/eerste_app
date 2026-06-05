import 'dart:io';

import 'package:flutter/material.dart';

import 'klantenfiche_foto_editor_controller.dart';
import 'klantenfiche_foto_tekening_painter.dart';
import 'dart:ui' as ui;

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
  final GlobalKey repaintKey = GlobalKey();

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

  Future<void> _tekstToevoegen(Offset positie) async {
    final tekstController = TextEditingController();

    final tekst = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tekst toevoegen'),
          content: TextField(
            controller: tekstController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Typ tekst...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Annuleren',
                style: TextStyle(
                  color: Color(0xFF0B7A3B),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  tekstController.text.trim(),
                );
              },
              child: const Text(
                'Toevoegen',
                style: TextStyle(
                  color: Color(0xFF0B7A3B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    tekstController.dispose();

    if (tekst == null || tekst.isEmpty) return;

    setState(() {
      controller.voegTekstToe(
        positie: positie,
        tekst: tekst,
      );

      controller.actieveTool = FotoEditorTool.tekenen;
    });
  }

  Future<void> _opslaanFoto() async {
    try {
      final boundary = repaintKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;

      final image = await boundary.toImage(
        pixelRatio: 3,
      );

      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();

      await widget.bestand.writeAsBytes(
        bytes,
        flush: true,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Foto opgeslagen',
          ),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
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
            onPressed: () => _opslaanFoto(),
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

            if (handleGevonden) return;
            final vormHandleGevonden = controller.selecteerVormHandleOpPunt(
              details.localPosition,
            );

            if (vormHandleGevonden) return;

            controller.selecteerVormOpPunt(
              details.localPosition,
            );

            if (controller.geselecteerdeVorm != null) return;

            controller.selecteerTekstOpPunt(
              details.localPosition,
            );

            if (controller.geselecteerdeTekst != null) return;

            controller.selecteerLijnOpPunt(
              details.localPosition,
            );

            if (controller.geselecteerdeLijn != null) return;
          });

          if (controller.actieveTool == FotoEditorTool.tekst) {
            _tekstToevoegen(details.localPosition);
          }
        },
        onPanStart: (details) {
          setState(() {
            final handleGevonden = controller.selecteerHandleOpPunt(
              details.localPosition,
            );

            if (handleGevonden) return;
            final vormHandleGevonden = controller.selecteerVormHandleOpPunt(
              details.localPosition,
            );

            if (vormHandleGevonden) return;

            if (controller.geselecteerdeVorm != null) {
              controller.startVormVerplaatsen(
                details.localPosition,
              );
              return;
            }

            if (controller.geselecteerdeTekst != null) {
              controller.startTekstVerplaatsen(
                details.localPosition,
              );
              return;
            }

            if (controller.geselecteerdeLijn != null) {
              controller.startVerplaatsen(
                details.localPosition,
              );
              return;
            }

            if (controller.actieveTool == FotoEditorTool.tekst) {
              return;
            }

            if (controller.actieveTool == FotoEditorTool.rechteLijn ||
                controller.actieveTool == FotoEditorTool.pijl) {
              controller.rechteLijnStart = details.localPosition;
              controller.deselecteerAlles();
              return;
            }

            if (controller.actieveTool == FotoEditorTool.rechthoek ||
                controller.actieveTool == FotoEditorTool.cirkel) {
              controller.vormStart = details.localPosition;
              controller.deselecteerAlles();
              return;
            }

            controller.startNieuweLijn(
              details.localPosition,
            );
          });
        },
        onPanUpdate: (details) {
          if (controller.geselecteerdeVormHandleIndex != null) {
            setState(() {
              controller.verplaatsVormHandle(
                details.localPosition,
              );
            });
            return;
          }
          if (controller.vormWordtVerplaatst) {
            setState(() {
              controller.verplaatsGeselecteerdeVorm(
                details.localPosition,
              );
            });
            return;
          }
          if (controller.tekstWordtVerplaatst) {
            setState(() {
              controller.verplaatsGeselecteerdeTekst(
                details.localPosition,
              );
            });
            return;
          }
          if (controller.geselecteerdHandleIndex != null) {
            setState(() {
              controller.verplaatsHandle(
                details.localPosition,
              );
            });
            return;
          }

          if (controller.lijnWordtVerplaatst) {
            setState(() {
              controller.verplaatsGeselecteerdeLijn(
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
            controller.geselecteerdeVormHandleIndex = null;

            if (controller.vormWordtVerplaatst) {
              controller.stopVormVerplaatsen();
              return;
            }

            if (controller.lijnWordtVerplaatst) {
              controller.stopVerplaatsen();
              return;
            }

            if ((controller.actieveTool == FotoEditorTool.rechteLijn ||
                    controller.actieveTool == FotoEditorTool.pijl) &&
                controller.rechteLijnStart != null) {
              final eindPunt = details.localPosition;

              controller.lijnen.add(
                TekenLijn(
                  punten: [
                    controller.rechteLijnStart!,
                    eindPunt,
                  ],
                  kleur: controller.actieveKleur,
                  type: controller.actieveTool,
                ),
              );

              controller.rechteLijnStart = null;
              return;
            }
            if ((controller.actieveTool == FotoEditorTool.rechthoek ||
                    controller.actieveTool == FotoEditorTool.cirkel) &&
                controller.vormStart != null) {
              controller.voegVormToe(
                start: controller.vormStart!,
                einde: details.localPosition,
                type: controller.actieveTool,
              );

              controller.vormStart = null;
              return;
            }

            controller.eindigLijn();
          });
        },
        child: Center(
          child: RepaintBoundary(
            key: repaintKey,
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
                    teksten: controller.teksten,
                    vormen: controller.vormen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: 6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        controller.actieveTool = FotoEditorTool.tekenen;
                        controller.deselecteerAlles();
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
                        controller.deselecteerAlles();
                      });
                    },
                    icon: Icon(
                      Icons.horizontal_rule,
                      color: controller.actieveTool == FotoEditorTool.rechteLijn
                          ? const Color(0xFF0B7A3B)
                          : Colors.grey,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        controller.actieveTool = FotoEditorTool.pijl;
                        controller.deselecteerAlles();
                      });
                    },
                    icon: Icon(
                      Icons.arrow_forward,
                      color: controller.actieveTool == FotoEditorTool.pijl
                          ? const Color(0xFF0B7A3B)
                          : Colors.grey,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        controller.actieveTool = FotoEditorTool.rechthoek;
                        controller.deselecteerAlles();
                      });
                    },
                    icon: Icon(
                      Icons.crop_square,
                      color: controller.actieveTool == FotoEditorTool.rechthoek
                          ? const Color(0xFF0B7A3B)
                          : Colors.grey,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        controller.actieveTool = FotoEditorTool.cirkel;
                        controller.deselecteerAlles();
                      });
                    },
                    icon: Icon(
                      Icons.circle_outlined,
                      color: controller.actieveTool == FotoEditorTool.cirkel
                          ? const Color(0xFF0B7A3B)
                          : Colors.grey,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        controller.actieveTool = FotoEditorTool.tekst;
                        controller.deselecteerAlles();
                      });
                    },
                    icon: Icon(
                      Icons.text_fields,
                      color: controller.actieveTool == FotoEditorTool.tekst
                          ? const Color(0xFF0B7A3B)
                          : Colors.grey,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (controller.geselecteerdeVorm != null) {
                        setState(() {
                          controller.verwijderGeselecteerdeVorm();
                        });
                        return;
                      }

                      if (controller.geselecteerdeTekst != null) {
                        setState(() {
                          controller.verwijderGeselecteerdeTekst();
                        });
                        return;
                      }

                      if (controller.geselecteerdeLijn != null) {
                        setState(() {
                          controller.verwijderGeselecteerdeLijn();
                        });
                        return;
                      }

                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Alle tekeningen wissen?'),
                            content: const Text(
                              'Er is geen lijn, tekst of vorm geselecteerd. Wilt u alle tekeningen verwijderen?',
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
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _kleurKnop(const Color(0xFF0B7A3B)),
                  const SizedBox(width: 14),
                  _kleurKnop(Colors.red),
                  const SizedBox(width: 14),
                  _kleurKnop(Colors.blue),
                  const SizedBox(width: 14),
                  _kleurKnop(Colors.amber),
                  const SizedBox(width: 14),
                  _kleurKnop(Colors.black),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
