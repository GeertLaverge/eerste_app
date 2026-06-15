import 'package:flutter/material.dart';

import '../helpers/opmeting/raam/opmeting_raam_basis_maten.dart';
import '../helpers/opmeting/raam/opmeting_raam_notities.dart';
import '../helpers/opmeting/raam/opmeting_raam_technische_keuzes.dart';
import '../helpers/opmeting/raam/opmeting_raam_tekenvlak.dart';
import '../helpers/opmeting/raam/opmeting_raam_toolbalk.dart';

class OpmetingRaamPagina extends StatefulWidget {
  const OpmetingRaamPagina({super.key});

  @override
  State<OpmetingRaamPagina> createState() => _OpmetingRaamPaginaState();
}

class _OpmetingRaamPaginaState extends State<OpmetingRaamPagina> {
  final dagmaatHoogteController = TextEditingController(text: '2000');
  final dagmaatBreedteController = TextEditingController(text: '1000');
  final slagLinksController = TextEditingController(text: '20');
  final slagRechtsController = TextEditingController(text: '20');
  final slagBovenController = TextEditingController(text: '20');
  final slagOnderController = TextEditingController(text: '20');
  final binnenTabletController = TextEditingController(text: '80');
  final buitenTabletController = TextEditingController(text: '105');
  final notitiesController = TextEditingController();

  String actieveTool = 'lijn';

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
    super.dispose();
  }

  double _waarde(TextEditingController controller) {
    return double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;
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

  Future<void> _opslaan() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opmeting raam voorlopig lokaal getest.'),
        backgroundColor: Color(0xFF0B7A3B),
      ),
    );
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Opmeting raam',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.copy_outlined),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete_outline),
          ),
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
            flex: 60,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
              child: Column(
                children: [
                  Expanded(
                    child: OpmetingRaamTekenvlak(
                      breedteMm: raammaatBreedte,
                      hoogteMm: raammaatHoogte,
                      actieveTool: actieveTool,
                    ),
                  ),
                  const SizedBox(height: 10),
                  OpmetingRaamToolbalk(
                    actieveTool: actieveTool,
                    onToolGekozen: (tool) {
                      setState(() {
                        actieveTool = tool;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  OpmetingRaamNotities(
                    controller: notitiesController,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 40,
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
                    onChanged: (veld, waarde) {
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
                    },
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
