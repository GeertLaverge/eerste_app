import 'package:flutter/material.dart';

import '../gedeeld/opmeting_canvas.dart';

class OpmetingRaamTekenvlak extends StatelessWidget {
  const OpmetingRaamTekenvlak({
    super.key,
    required this.breedteMm,
    required this.hoogteMm,
    required this.actieveTool,
    required this.positieController,
  });

  final int breedteMm;
  final int hoogteMm;
  final String actieveTool;
  final TextEditingController positieController;

  @override
  Widget build(BuildContext context) {
    return OpmetingCanvas(
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      actieveTool: actieveTool,
      positieController: positieController,
    );
  }
}
