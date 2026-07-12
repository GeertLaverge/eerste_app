import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  factory OpmetingRaamTechnischeTekeningConcept.kopieVan(
    OpmetingRaamTechnischeTekeningConcept bron,
  ) {
    return OpmetingRaamTechnischeTekeningConcept.vanInstelling(
      bron.naarInstelling(),
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

class OpmetingRaamTechnischeTekeningEditor extends StatefulWidget {
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

  @override
  State<OpmetingRaamTechnischeTekeningEditor> createState() {
    return _OpmetingRaamTechnischeTekeningEditorState();
  }
}

class _OpmetingRaamTechnischeTekeningEditorState
    extends State<OpmetingRaamTechnischeTekeningEditor> {
  static const Color groen = Color(0xFF0B7A3B);
  static const Color lichtGroen = Color(0xFFE7F6EC);
  static const Color rand = Color(0xFFD1D5DB);

  OpmetingRaamTechnischeTekeningConcept get concept {
    return widget.concept;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: rand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: lichtGroen,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: groen),
                ),
                child: Text(
                  widget.volgnummer.toString(),
                  style: const TextStyle(
                    color: groen,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Extra rechthoekige tekening',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Rechthoek verwijderen',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                onPressed: widget.onVerwijderen,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 19,
                  color: Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _bouwMaatRij(
            titel: 'Breedte',
            waarde: concept.breedteKeuze,
            vasteWaardeLabel: 'Breedte',
            controller: concept.breedteController,
            keuzes: const [
              DropdownMenuItem(
                value: OpmetingRaamTechnischeMaatKeuze.vasteMaat,
                child: Text('Vaste maat'),
              ),
              DropdownMenuItem(
                value: OpmetingRaamTechnischeMaatKeuze.volledigeRaammaat,
                child: Text('Volledige raambreedte'),
              ),
            ],
            onKeuzeGewijzigd: (waarde) {
              setState(() {
                concept.breedteKeuze = waarde;
              });
              widget.onGewijzigd();
            },
          ),
          const SizedBox(height: 8),
          _bouwMaatRij(
            titel: 'Hoogte',
            waarde: concept.hoogteKeuze,
            vasteWaardeLabel: 'Hoogte',
            controller: concept.hoogteController,
            keuzes: const [
              DropdownMenuItem(
                value: OpmetingRaamTechnischeMaatKeuze.vasteMaat,
                child: Text('Vaste maat'),
              ),
              DropdownMenuItem(
                value: OpmetingRaamTechnischeMaatKeuze.volledigeRaammaat,
                child: Text('Volledige raamhoogte'),
              ),
            ],
            onKeuzeGewijzigd: (waarde) {
              setState(() {
                concept.hoogteKeuze = waarde;
              });
              widget.onGewijzigd();
            },
          ),
          const SizedBox(height: 8),
          _bouwTweeKolommen(
            links: DropdownButtonFormField<OpmetingRaamTechnischePositie>(
              value: concept.positie,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Positie',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: OpmetingRaamTechnischePositie.values.map((positie) {
                return DropdownMenuItem(
                  value: positie,
                  child: Text(positie.label),
                );
              }).toList(),
              onChanged: (waarde) {
                if (waarde == null) {
                  return;
                }

                setState(() {
                  concept.positie = waarde;
                });
                widget.onGewijzigd();
              },
            ),
            rechts: const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          _bouwTweeKolommen(
            links: DropdownButtonFormField<OpmetingRaamTechnischeMaatPlaatsing>(
              value: concept.maatPlaatsing,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Plaatsing',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: OpmetingRaamTechnischeMaatPlaatsing.values.map((
                plaatsing,
              ) {
                return DropdownMenuItem(
                  value: plaatsing,
                  child: Text(plaatsing.label),
                );
              }).toList(),
              onChanged: (waarde) {
                if (waarde == null) {
                  return;
                }

                setState(() {
                  concept.maatPlaatsing = waarde;
                });
                widget.onGewijzigd();
              },
            ),
            rechts: TextField(
              controller: concept.afstandController,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
              ],
              onChanged: (_) {
                widget.onGewijzigd();
              },
              decoration: const InputDecoration(
                labelText: 'Afstand tot raamkader',
                suffixText: 'mm',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _bouwTweeKolommen(
            links: DropdownButtonFormField<OpmetingRaamTechnischeInhoudType>(
              value: concept.inhoudType,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Invulling',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: OpmetingRaamTechnischeInhoudType.values.map((type) {
                return DropdownMenuItem(value: type, child: Text(type.label));
              }).toList(),
              onChanged: (waarde) {
                if (waarde == null) {
                  return;
                }

                setState(() {
                  concept.inhoudType = waarde;
                });
                widget.onGewijzigd();
              },
            ),
            rechts:
                concept.inhoudType == OpmetingRaamTechnischeInhoudType.raster
                ? DropdownButtonFormField<OpmetingRaamTechnischRasterPatroon>(
                    value: concept.rasterPatroon,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Rasterpatroon',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: OpmetingRaamTechnischRasterPatroon.values.map((
                      patroon,
                    ) {
                      return DropdownMenuItem(
                        value: patroon,
                        child: Text(patroon.label),
                      );
                    }).toList(),
                    onChanged: (waarde) {
                      if (waarde == null) {
                        return;
                      }

                      setState(() {
                        concept.rasterPatroon = waarde;
                      });
                      widget.onGewijzigd();
                    },
                  )
                : TextField(
                    controller: concept.tekstController,
                    onChanged: (_) {
                      widget.onGewijzigd();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Tekst',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _bouwMaatRij({
    required String titel,
    required OpmetingRaamTechnischeMaatKeuze waarde,
    required String vasteWaardeLabel,
    required TextEditingController controller,
    required List<DropdownMenuItem<OpmetingRaamTechnischeMaatKeuze>> keuzes,
    required ValueChanged<OpmetingRaamTechnischeMaatKeuze> onKeuzeGewijzigd,
  }) {
    return _bouwTweeKolommen(
      links: DropdownButtonFormField<OpmetingRaamTechnischeMaatKeuze>(
        value: waarde,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: titel,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: keuzes,
        onChanged: (nieuweWaarde) {
          if (nieuweWaarde == null) {
            return;
          }

          onKeuzeGewijzigd(nieuweWaarde);
        },
      ),
      rechts: waarde == OpmetingRaamTechnischeMaatKeuze.vasteMaat
          ? TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) {
                widget.onGewijzigd();
              },
              decoration: InputDecoration(
                labelText: vasteWaardeLabel,
                suffixText: 'mm',
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _bouwTweeKolommen({required Widget links, required Widget rechts}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: links),
        const SizedBox(width: 8),
        Expanded(child: rechts),
      ],
    );
  }
}
