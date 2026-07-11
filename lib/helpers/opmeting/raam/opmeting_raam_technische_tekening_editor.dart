import 'package:flutter/material.dart';

import 'opmeting_raam_keuzemenu_model.dart';

class OpmetingRaamTechnischeTekeningConcept {
  OpmetingRaamTechnischeTekeningConcept({
    required this.id,
    required this.breedteController,
    required this.hoogteController,
    required this.afstandController,
    required this.tekstController,
    required this.breedteKeuze,
    required this.hoogteKeuze,
    required this.positie,
    required this.maatPlaatsing,
    required this.inhoudType,
    required this.rasterPatroon,
  });

  factory OpmetingRaamTechnischeTekeningConcept.nieuw() {
    return OpmetingRaamTechnischeTekeningConcept(
      id: 'tekening_${DateTime.now().microsecondsSinceEpoch}',
      breedteController: TextEditingController(text: '100'),
      hoogteController: TextEditingController(text: '60'),
      afstandController: TextEditingController(text: '0'),
      tekstController: TextEditingController(),
      breedteKeuze: OpmetingRaamTechnischeMaatKeuze.volledigeRaammaat,
      hoogteKeuze: OpmetingRaamTechnischeMaatKeuze.vasteMaat,
      positie: OpmetingRaamTechnischePositie.boven,
      maatPlaatsing: OpmetingRaamTechnischeMaatPlaatsing.inDeRaammaat,
      inhoudType: OpmetingRaamTechnischeInhoudType.raster,
      rasterPatroon: OpmetingRaamTechnischRasterPatroon.horizontaleLijnen,
    );
  }

  factory OpmetingRaamTechnischeTekeningConcept.vanInstelling(
    OpmetingRaamTechnischeTekeningInstelling instelling,
  ) {
    return OpmetingRaamTechnischeTekeningConcept(
      id: 'tekening_${DateTime.now().microsecondsSinceEpoch}',
      breedteController: TextEditingController(
        text: instelling.breedteMm.toString(),
      ),
      hoogteController: TextEditingController(
        text: instelling.hoogteMm.toString(),
      ),
      afstandController: TextEditingController(
        text: instelling.afstandMm.toString(),
      ),
      tekstController: TextEditingController(text: instelling.tekst),
      breedteKeuze: instelling.breedteKeuze,
      hoogteKeuze: instelling.hoogteKeuze,
      positie: instelling.positie,
      maatPlaatsing: instelling.maatPlaatsing,
      inhoudType: instelling.inhoudType,
      rasterPatroon: instelling.rasterPatroon,
    );
  }

  final String id;

  final TextEditingController breedteController;
  final TextEditingController hoogteController;
  final TextEditingController afstandController;
  final TextEditingController tekstController;

  OpmetingRaamTechnischeMaatKeuze breedteKeuze;
  OpmetingRaamTechnischeMaatKeuze hoogteKeuze;
  OpmetingRaamTechnischePositie positie;
  OpmetingRaamTechnischeMaatPlaatsing maatPlaatsing;
  OpmetingRaamTechnischeInhoudType inhoudType;
  OpmetingRaamTechnischRasterPatroon rasterPatroon;

  int get breedteMm {
    return int.tryParse(breedteController.text.trim()) ?? 0;
  }

  int get hoogteMm {
    return int.tryParse(hoogteController.text.trim()) ?? 0;
  }

  int get afstandMm {
    return int.tryParse(afstandController.text.trim()) ?? 0;
  }

  OpmetingRaamTechnischeTekeningInstelling naarInstelling() {
    return OpmetingRaamTechnischeTekeningInstelling(
      actief: true,
      breedteKeuze: breedteKeuze,
      breedteMm: breedteMm,
      hoogteKeuze: hoogteKeuze,
      hoogteMm: hoogteMm,
      positie: positie,
      maatPlaatsing: maatPlaatsing,
      afstandMm: afstandMm,
      inhoudType: inhoudType,
      rasterPatroon: rasterPatroon,
      tekst: tekstController.text.trim(),
    );
  }

  void dispose() {
    breedteController.dispose();
    hoogteController.dispose();
    afstandController.dispose();
    tekstController.dispose();
  }
}

class OpmetingRaamTechnischeTekeningEditor extends StatelessWidget {
  const OpmetingRaamTechnischeTekeningEditor({
    super.key,
    required this.volgnummer,
    required this.concept,
    required this.onGewijzigd,
    required this.onVerwijderen,
  });

  final int volgnummer;
  final OpmetingRaamTechnischeTekeningConcept concept;
  final VoidCallback onGewijzigd;
  final VoidCallback onVerwijderen;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFD1D5DB);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Rechthoek $volgnummer',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: 'Rechthoek verwijderen',
                visualDensity: VisualDensity.compact,
                onPressed: onVerwijderen,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 245,
                child: DropdownButtonFormField<OpmetingRaamTechnischeMaatKeuze>(
                  initialValue: concept.breedteKeuze,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Breedte',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: OpmetingRaamTechnischeMaatKeuze.vasteMaat,
                      child: Text('Vaste maat in mm'),
                    ),
                    DropdownMenuItem(
                      value: OpmetingRaamTechnischeMaatKeuze.volledigeRaammaat,
                      child: Text('Volledige raambreedte'),
                    ),
                  ],
                  onChanged: (waarde) {
                    if (waarde == null) return;

                    concept.breedteKeuze = waarde;
                    onGewijzigd();
                  },
                ),
              ),
              if (concept.breedteKeuze ==
                  OpmetingRaamTechnischeMaatKeuze.vasteMaat)
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: concept.breedteController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Breedte',
                      suffixText: 'mm',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              SizedBox(
                width: 245,
                child: DropdownButtonFormField<OpmetingRaamTechnischeMaatKeuze>(
                  initialValue: concept.hoogteKeuze,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Hoogte',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: OpmetingRaamTechnischeMaatKeuze.vasteMaat,
                      child: Text('Vaste maat in mm'),
                    ),
                    DropdownMenuItem(
                      value: OpmetingRaamTechnischeMaatKeuze.volledigeRaammaat,
                      child: Text('Volledige raamhoogte'),
                    ),
                  ],
                  onChanged: (waarde) {
                    if (waarde == null) return;

                    concept.hoogteKeuze = waarde;
                    onGewijzigd();
                  },
                ),
              ),
              if (concept.hoogteKeuze ==
                  OpmetingRaamTechnischeMaatKeuze.vasteMaat)
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: concept.hoogteController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Hoogte',
                      suffixText: 'mm',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              SizedBox(
                width: 215,
                child: DropdownButtonFormField<OpmetingRaamTechnischePositie>(
                  initialValue: concept.positie,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Positie',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: OpmetingRaamTechnischePositie.values
                      .map(
                        (positie) => DropdownMenuItem(
                          value: positie,
                          child: Text(positie.label),
                        ),
                      )
                      .toList(),
                  onChanged: (waarde) {
                    if (waarde == null) return;

                    concept.positie = waarde;
                    onGewijzigd();
                  },
                ),
              ),
              SizedBox(
                width: 245,
                child:
                    DropdownButtonFormField<
                      OpmetingRaamTechnischeMaatPlaatsing
                    >(
                      initialValue: concept.maatPlaatsing,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Plaatsing',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: OpmetingRaamTechnischeMaatPlaatsing.values
                          .map(
                            (plaatsing) => DropdownMenuItem(
                              value: plaatsing,
                              child: Text(plaatsing.label),
                            ),
                          )
                          .toList(),
                      onChanged: (waarde) {
                        if (waarde == null) return;

                        concept.maatPlaatsing = waarde;
                        onGewijzigd();
                      },
                    ),
              ),
              if (concept.maatPlaatsing ==
                  OpmetingRaamTechnischeMaatPlaatsing.buitenDeRaammaat)
                SizedBox(
                  width: 210,
                  child: TextField(
                    controller: concept.afstandController,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Afstand tot raamkader',
                      suffixText: 'mm',
                      helperText: 'Negatief = over het raam',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              SizedBox(
                width: 215,
                child:
                    DropdownButtonFormField<OpmetingRaamTechnischeInhoudType>(
                      initialValue: concept.inhoudType,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Invulling',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: OpmetingRaamTechnischeInhoudType.values
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.label),
                            ),
                          )
                          .toList(),
                      onChanged: (waarde) {
                        if (waarde == null) return;

                        concept.inhoudType = waarde;
                        onGewijzigd();
                      },
                    ),
              ),
              if (concept.inhoudType == OpmetingRaamTechnischeInhoudType.raster)
                SizedBox(
                  width: 245,
                  child:
                      DropdownButtonFormField<
                        OpmetingRaamTechnischRasterPatroon
                      >(
                        initialValue: concept.rasterPatroon,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Rasterpatroon',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: OpmetingRaamTechnischRasterPatroon.values
                            .map(
                              (patroon) => DropdownMenuItem(
                                value: patroon,
                                child: Text(patroon.label),
                              ),
                            )
                            .toList(),
                        onChanged: (waarde) {
                          if (waarde == null) return;

                          concept.rasterPatroon = waarde;
                          onGewijzigd();
                        },
                      ),
                ),
              if (concept.inhoudType == OpmetingRaamTechnischeInhoudType.tekst)
                SizedBox(
                  width: 360,
                  child: TextField(
                    controller: concept.tekstController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Tekst in rechthoek',
                      hintText: 'Bijvoorbeeld: ventilatierooster',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _uitleg,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11.5),
          ),
        ],
      ),
    );
  }

  String get _uitleg {
    if (concept.maatPlaatsing ==
        OpmetingRaamTechnischeMaatPlaatsing.inDeRaammaat) {
      return 'In de raammaat: deze rechthoek neemt ruimte van het '
          'raamkader in. De totale opgegeven raammaat blijft gelijk.';
    }

    return 'Buiten de raammaat: een positieve afstand maakt ruimte '
        'tussen raam en rechthoek. Een negatieve afstand schuift de '
        'rechthoek over het raamkader.';
  }
}
