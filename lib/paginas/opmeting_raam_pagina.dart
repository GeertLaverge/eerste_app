import 'package:flutter/material.dart';

import '../helpers/opmeting/raam/opmeting_raam_basis_maten.dart';
import '../helpers/opmeting/raam/opmeting_raam_kleinhout_helper.dart';
import '../helpers/opmeting/raam/opmeting_raam_notities.dart';
import '../helpers/opmeting/raam/opmeting_raam_technische_keuzes.dart';
import '../helpers/opmeting/raam/opmeting_raam_toolbalk.dart';
import '../helpers/opmeting/raam/opmeting_raam_tekenvlak.dart';
import '../helpers/opmeting/raam/opmeting_raam_vulling_helper.dart';

class OpmetingRaamPagina extends StatefulWidget {
  const OpmetingRaamPagina({super.key});

  @override
  State<OpmetingRaamPagina> createState() {
    return _OpmetingRaamPaginaState();
  }
}

class _OpmetingRaamPaginaState extends State<OpmetingRaamPagina> {
  final TextEditingController dagmaatHoogteController = TextEditingController(
    text: '2000',
  );

  final TextEditingController dagmaatBreedteController = TextEditingController(
    text: '1000',
  );

  final TextEditingController slagLinksController = TextEditingController(
    text: '20',
  );

  final TextEditingController slagRechtsController = TextEditingController(
    text: '20',
  );

  final TextEditingController slagBovenController = TextEditingController(
    text: '20',
  );

  final TextEditingController slagOnderController = TextEditingController(
    text: '20',
  );

  final TextEditingController binnenTabletController = TextEditingController(
    text: '80',
  );

  final TextEditingController buitenTabletController = TextEditingController(
    text: '105',
  );

  final TextEditingController notitiesController = TextEditingController();

  final TextEditingController positieController = TextEditingController();

  final OpmetingRaamTekenvlakController tekenvlakController =
      OpmetingRaamTekenvlakController();

  String actieveTool = 'lijn';

  int vleugelMenuOpenSignaal = 0;
  int tStijlMenuOpenSignaal = 0;
  int opvullingMenuOpenSignaal = 0;
  int kleinhoutMenuOpenSignaal = 0;

  String vleugelprofiel = 'Classic';
  String dorpel = 'Standaard';
  String binnenkastprofiel = '4047';
  String rolluik = 'Geen';
  String vliegenraam = 'Geen';
  String verbredingsprofielen = 'Niet gebruikt';
  String koppelprofielen = 'Niet gebruikt';
  String ventilatierooster = 'Geen';
  String hoekprofielen = 'Geen';
  String binnenafwerking = 'Geen';
  String rolluikkast = 'Geen';
  String vensterbanken = 'Geen';
  String afwerkingslatten = 'Geen';

  List<OpmetingRaamVullingLegendaItem> gekozenOpvullingen =
      <OpmetingRaamVullingLegendaItem>[];

  List<OpmetingRaamKleinhoutLegendaItem> gekozenKleinhouten =
      <OpmetingRaamKleinhoutLegendaItem>[];

  @override
  void dispose() {
    dagmaatHoogteController.dispose();
    dagmaatBreedteController.dispose();

    slagLinksController.dispose();
    slagRechtsController.dispose();
    slagBovenController.dispose();
    slagOnderController.dispose();

    binnenTabletController.dispose();
    buitenTabletController.dispose();

    notitiesController.dispose();
    positieController.dispose();

    tekenvlakController.dispose();

    super.dispose();
  }

  double _waarde(TextEditingController controller) {
    return double.tryParse(controller.text.trim().replaceAll(',', '.')) ?? 0;
  }

  int get raammaatBreedte {
    return (_waarde(dagmaatBreedteController) +
            _waarde(slagLinksController) +
            _waarde(slagRechtsController))
        .round();
  }

  int get raammaatHoogte {
    return (_waarde(dagmaatHoogteController) +
            _waarde(slagBovenController) +
            _waarde(slagOnderController))
        .round();
  }

  int get verschilTablet {
    return (_waarde(buitenTabletController) - _waarde(binnenTabletController))
        .round();
  }

  void _herbereken() {
    setState(() {});
  }

  void _toolGekozen(String tool) {
    setState(() {
      actieveTool = tool;

      switch (tool) {
        case 'tstijl':
          tStijlMenuOpenSignaal++;
          break;

        case 'vleugel':
          vleugelMenuOpenSignaal++;
          break;

        case 'opvulling':
          opvullingMenuOpenSignaal++;
          break;

        case 'kleinhout':
          kleinhoutMenuOpenSignaal++;
          break;
      }
    });
  }

  void _verwerkOpvullingen(
    List<OpmetingRaamVullingLegendaItem> nieuweOpvullingen,
  ) {
    if (_zijnOpvullingenGelijk(gekozenOpvullingen, nieuweOpvullingen)) {
      return;
    }

    setState(() {
      gekozenOpvullingen = List<OpmetingRaamVullingLegendaItem>.unmodifiable(
        nieuweOpvullingen,
      );
    });
  }

  void _verwerkKleinhouten(
    List<OpmetingRaamKleinhoutLegendaItem> nieuweKleinhouten,
  ) {
    if (_zijnKleinhoutenGelijk(gekozenKleinhouten, nieuweKleinhouten)) {
      return;
    }

    setState(() {
      gekozenKleinhouten = List<OpmetingRaamKleinhoutLegendaItem>.unmodifiable(
        nieuweKleinhouten,
      );
    });
  }

  bool _zijnOpvullingenGelijk(
    List<OpmetingRaamVullingLegendaItem> eerste,
    List<OpmetingRaamVullingLegendaItem> tweede,
  ) {
    if (eerste.length != tweede.length) {
      return false;
    }

    for (var index = 0; index < eerste.length; index++) {
      final eersteItem = eerste[index];
      final tweedeItem = tweede[index];

      if (eersteItem.nummer != tweedeItem.nummer ||
          eersteItem.naam != tweedeItem.naam ||
          eersteItem.kleur.value != tweedeItem.kleur.value ||
          eersteItem.weergaveKleur.value != tweedeItem.weergaveKleur.value) {
        return false;
      }
    }

    return true;
  }

  bool _zijnKleinhoutenGelijk(
    List<OpmetingRaamKleinhoutLegendaItem> eerste,
    List<OpmetingRaamKleinhoutLegendaItem> tweede,
  ) {
    if (eerste.length != tweede.length) {
      return false;
    }

    for (var index = 0; index < eerste.length; index++) {
      final eersteItem = eerste[index];
      final tweedeItem = tweede[index];

      if (eersteItem.nummer != tweedeItem.nummer ||
          eersteItem.type != tweedeItem.type ||
          eersteItem.patroon != tweedeItem.patroon ||
          eersteItem.aantalHorizontaal != tweedeItem.aantalHorizontaal ||
          eersteItem.aantalVerticaal != tweedeItem.aantalVerticaal ||
          eersteItem.horizontaleHoogteMm != tweedeItem.horizontaleHoogteMm ||
          !_zelfdeTeksten(eersteItem.vlakIds, tweedeItem.vlakIds)) {
        return false;
      }
    }

    return true;
  }

  bool _zelfdeTeksten(List<String> eerste, List<String> tweede) {
    if (eerste.length != tweede.length) {
      return false;
    }

    for (var index = 0; index < eerste.length; index++) {
      if (eerste[index] != tweede[index]) {
        return false;
      }
    }

    return true;
  }

  Future<void> _opslaan() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opmeting raam voorlopig lokaal getest.'),
        backgroundColor: Color(0xFF0B7A3B),
      ),
    );
  }

  void _technischeKeuzeGewijzigd(String veld, String waarde) {
    setState(() {
      switch (veld) {
        case 'vleugelprofiel':
          vleugelprofiel = waarde;
          break;

        case 'dorpel':
          dorpel = waarde;
          break;

        case 'binnenkastprofiel':
          binnenkastprofiel = waarde;
          break;

        case 'rolluik':
          rolluik = waarde;
          break;

        case 'vliegenraam':
          vliegenraam = waarde;
          break;

        case 'verbredingsprofielen':
          verbredingsprofielen = waarde;
          break;

        case 'koppelprofielen':
          koppelprofielen = waarde;
          break;

        case 'ventilatierooster':
          ventilatierooster = waarde;
          break;

        case 'hoekprofielen':
          hoekprofielen = waarde;
          break;

        case 'binnenafwerking':
          binnenafwerking = waarde;
          break;

        case 'rolluikkast':
          rolluikkast = waarde;
          break;

        case 'vensterbanken':
          vensterbanken = waarde;
          break;

        case 'afwerkingslatten':
          afwerkingslatten = waarde;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B7A3B),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Opmeting raam',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.copy_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline)),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ElevatedButton(
              onPressed: _opslaan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0B7A3B),
              ),
              child: const Text('Opslaan'),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 50,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
              child: Column(
                children: [
                  Expanded(
                    child: OpmetingRaamTekenvlak(
                      breedteMm: raammaatBreedte,
                      hoogteMm: raammaatHoogte,
                      actieveTool: actieveTool,
                      vleugelMenuOpenSignaal: vleugelMenuOpenSignaal,
                      tStijlMenuOpenSignaal: tStijlMenuOpenSignaal,
                      opvullingMenuOpenSignaal: opvullingMenuOpenSignaal,
                      kleinhoutMenuOpenSignaal: kleinhoutMenuOpenSignaal,
                      positieController: positieController,
                      controller: tekenvlakController,
                      onOpvullingenGewijzigd: _verwerkOpvullingen,
                      onKleinhoutenGewijzigd: _verwerkKleinhouten,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedBuilder(
                    animation: tekenvlakController,
                    builder: (context, child) {
                      return OpmetingRaamToolbalk(
                        actieveTool: actieveTool,
                        onToolGekozen: _toolGekozen,
                        kanOngedaanMaken: tekenvlakController.kanOngedaanMaken,
                        kanHerstellen: tekenvlakController.kanHerstellen,
                        onOngedaanMaken: tekenvlakController.ongedaanMaken,
                        onHerstellen: tekenvlakController.herstellen,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  OpmetingRaamNotities(controller: notitiesController),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 50,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 12, 12, 12),
              child: ListView(
                children: [
                  OpmetingRaamBasisMaten(
                    dagmaatHoogteController: dagmaatHoogteController,
                    dagmaatBreedteController: dagmaatBreedteController,
                    slagLinksController: slagLinksController,
                    slagRechtsController: slagRechtsController,
                    slagBovenController: slagBovenController,
                    slagOnderController: slagOnderController,
                    binnenTabletController: binnenTabletController,
                    buitenTabletController: buitenTabletController,
                    raammaatBreedte: raammaatBreedte,
                    raammaatHoogte: raammaatHoogte,
                    verschilTablet: verschilTablet,
                    onChanged: _herbereken,
                  ),
                  const SizedBox(height: 10),
                  OpmetingRaamTechnischeKeuzes(
                    vleugelprofiel: vleugelprofiel,
                    dorpel: dorpel,
                    opvullingen: gekozenOpvullingen,
                    kleinhouten: gekozenKleinhouten,
                    binnenkastprofiel: binnenkastprofiel,
                    rolluik: rolluik,
                    vliegenraam: vliegenraam,
                    verbredingsprofielen: verbredingsprofielen,
                    koppelprofielen: koppelprofielen,
                    ventilatierooster: ventilatierooster,
                    hoekprofielen: hoekprofielen,
                    binnenafwerking: binnenafwerking,
                    rolluikkast: rolluikkast,
                    vensterbanken: vensterbanken,
                    afwerkingslatten: afwerkingslatten,
                    onChanged: _technischeKeuzeGewijzigd,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
