import 'package:flutter/material.dart';

import 'opmeting_raam_keuzeveld.dart';

class OpmetingRaamTechnischeKeuzes extends StatelessWidget {
  const OpmetingRaamTechnischeKeuzes({
    super.key,
    required this.vleugelprofiel,
    required this.dorpel,
    required this.binnenkastprofiel,
    required this.rolluik,
    required this.vliegenraam,
    required this.verbredingsprofielen,
    required this.koppelprofielen,
    required this.ventilatierooster,
    required this.hoekprofielen,
    required this.binnenafwerking,
    required this.rolluikkast,
    required this.vensterbanken,
    required this.afwerkingslatten,
    required this.onChanged,
  });

  final String vleugelprofiel;
  final String dorpel;
  final String binnenkastprofiel;
  final String rolluik;
  final String vliegenraam;
  final String verbredingsprofielen;
  final String koppelprofielen;
  final String ventilatierooster;
  final String hoekprofielen;
  final String binnenafwerking;
  final String rolluikkast;
  final String vensterbanken;
  final String afwerkingslatten;

  final void Function(String veld, String waarde) onChanged;

  static const groen = Color(0xFF0B7A3B);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _kaartDecoratie(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TECHNISCHE KEUZES',
            style: TextStyle(
              color: groen,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          _keuze(
            'vleugelprofiel',
            'Vleugelprofiel',
            vleugelprofiel,
            ['Classic', 'Softline', 'Steel look', 'Renovatie'],
          ),
          _keuze(
            'dorpel',
            'Dorpel',
            dorpel,
            ['Geen', 'Standaard', 'Blauwe steen', 'Aluminium dorpel'],
          ),
          _keuze(
            'binnenkastprofiel',
            'Binnenkastprofiel',
            binnenkastprofiel,
            ['Geen', '4047', '4048', '4050'],
          ),
          _keuze(
            'rolluik',
            'Rolluik',
            rolluik,
            ['Geen', 'Lintbediend', 'Elektrisch', 'Elektrisch IO', 'Solar IO'],
          ),
          _keuze(
            'vliegenraam',
            'Vliegenraam',
            vliegenraam,
            ['Geen', 'Vast', 'Schuif', 'Hordeur', 'Plissé'],
          ),
          _keuze(
            'verbredingsprofielen',
            'Verbredingsprofielen',
            verbredingsprofielen,
            ['Niet gebruikt', 'Links', 'Rechts', 'Boven', 'Onder', 'Rondom'],
          ),
          _keuze(
            'koppelprofielen',
            'Koppelprofielen',
            koppelprofielen,
            ['Niet gebruikt', 'Links', 'Rechts', 'Boven', 'Onder'],
          ),
          _keuze(
            'ventilatierooster',
            'Ventilatierooster',
            ventilatierooster,
            ['Geen', 'Invisivent', 'Glasrooster', 'Duco'],
          ),
          _keuze(
            'hoekprofielen',
            'Hoekprofielen',
            hoekprofielen,
            ['Geen', 'Standaard', 'Breed', 'Speciaal'],
          ),
          _keuze(
            'binnenafwerking',
            'Binnenafwerking',
            binnenafwerking,
            ['Geen', 'Chambrangs', 'Binnenkast', 'Chambrangs en binnenkasten'],
          ),
          _keuze(
            'rolluikkast',
            'Rolluikkast',
            rolluikkast,
            ['Geen', 'Kast 155', 'Kast 180', 'Kast 205'],
          ),
          _keuze(
            'vensterbanken',
            'Vensterbanken',
            vensterbanken,
            ['Geen', 'Binnen PVC', 'Binnen aluminium', 'Buiten aluminium'],
          ),
          _keuze(
            'afwerkingslatten',
            'Afwerkingslatten buitenzijde',
            afwerkingslatten,
            ['Geen', 'Links', 'Rechts', 'Boven', 'Onder', 'Rondom'],
          ),
        ],
      ),
    );
  }

  Widget _keuze(
    String veld,
    String titel,
    String waarde,
    List<String> keuzes,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: OpmetingRaamKeuzeveld(
        titel: titel,
        waarde: waarde,
        keuzes: keuzes,
        onGekozen: (nieuweWaarde) {
          onChanged(veld, nieuweWaarde);
        },
      ),
    );
  }

  BoxDecoration _kaartDecoratie() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xFFE5E7EB),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.035),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
