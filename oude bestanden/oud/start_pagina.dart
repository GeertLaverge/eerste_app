import 'package:flutter/material.dart';

import '../../lib/helpers/app_storage.dart';
import '../../lib/modellen/klant.dart';
import '../../lib/modellen/leverancier.dart';
import '../../agenda_pagina.dart';
import 'klanten_pagina.dart';
import '../../lib/helpers/widgets/onder_navigatie_balk.dart';

class StartPagina extends StatefulWidget {
  const StartPagina({super.key});

  @override
  State<StartPagina> createState() => _StartPaginaState();
}

class _StartPaginaState extends State<StartPagina> {
  List<Klant> alleKlanten = [];
  List<Leverancier> leveranciers = [];
  List<DateTime> vakantieDagen = [];
  bool isLaden = true;

  @override
  void initState() {
    super.initState();
    laadData();
  }

  Future<void> laadData() async {
    final geladenKlanten = await AppStorage.laadKlanten();
    final geladenLeveranciers = await AppStorage.laadLeveranciers();
    final geladenVakantieDagen = await AppStorage.laadVakantieDagen();

    if (!mounted) return;

    setState(() {
      alleKlanten = geladenKlanten;
      leveranciers = geladenLeveranciers;
      vakantieDagen = geladenVakantieDagen;
      isLaden = false;
    });
  }

  Future<void> bewaarAlles() async {
    await AppStorage.bewaarAlles(
      klanten: alleKlanten,
      leveranciers: leveranciers,
      vakantieDagen: vakantieDagen,
    );
  }

  Widget tegel({
    required BuildContext context,
    required String titel,
    required IconData icoon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.blueGrey.shade50,
            border: Border.all(color: Colors.blueGrey.shade100),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icoon,
                  size: 42,
                  color: Colors.blueGrey.shade700,
                ),
                const SizedBox(height: 14),
                Text(
                  titel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void toonNogInOpbouw(BuildContext context, String naam) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$naam is nog in opbouw.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLaden) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoofdpagina'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    tegel(
                      context: context,
                      titel: 'Agenda',
                      icoon: Icons.calendar_month,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AgendaPagina(
                              alleKlanten: alleKlanten,
                              leveranciers: leveranciers,
                              vakantieDagen: vakantieDagen,
                              onGewijzigd: bewaarAlles,
                              startInMonthView: false,
                            ),
                          ),
                        ).then((_) async {
                          await laadData();
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    tegel(
                      context: context,
                      titel: 'Klanten',
                      icoon: Icons.people,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const KlantenPagina(),
                          ),
                        ).then((_) async {
                          await laadData();
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    tegel(
                      context: context,
                      titel: 'Magazijn',
                      icoon: Icons.warehouse,
                      onTap: () => toonNogInOpbouw(context, 'Magazijn'),
                    ),
                    const SizedBox(width: 16),
                    tegel(
                      context: context,
                      titel: 'Bestellen',
                      icoon: Icons.shopping_cart,
                      onTap: () => toonNogInOpbouw(context, 'Bestellen'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
