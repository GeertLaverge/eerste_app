// THIMACO iPhone V12 - magazijnacties in zwarte balk
import 'thimaco_iphone_agenda.dart';
import 'thimaco_iphone_bibliotheek.dart';
import 'thimaco_iphone_geleverd.dart';
import 'thimaco_iphone_notities_bureau.dart';
import 'thimaco_iphone_magazijn.dart';
import 'package:flutter/material.dart';

/// De mobiele startinterface van Thimaco. In V1 bewust geen opslag- of
/// OneDrive-aanroepen: testdata mogen nooit als echte klantdata verschijnen.
class ThimacoIphoneApp extends StatelessWidget {
  const ThimacoIphoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    const donker = Color(0xFF20252B);
    return MaterialApp(
      title: 'Thimaco Mobiel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F6F7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF15A24),
          primary: const Color(0xFFF15A24),
          surface: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: donker),
          titleMedium: TextStyle(color: donker, fontWeight: FontWeight.w800),
        ),
      ),
      home: const _MobieleHoofdpagina(),
    );
  }
}

class _Onderdeel {
  const _Onderdeel(this.naam, this.icon, this.subtitel);
  final String naam;
  final IconData icon;
  final String subtitel;
}

class _MobieleHoofdpagina extends StatefulWidget {
  const _MobieleHoofdpagina();

  @override
  State<_MobieleHoofdpagina> createState() => _MobieleHoofdpaginaState();
}

class _MobieleHoofdpaginaState extends State<_MobieleHoofdpagina> {
  static const _oranje = Color(0xFFF15A24);
  static const _zwart = Color(0xFF20252B);
  static const _rand = Color(0xFFE5E7EB);

  static const _modules = <_Onderdeel>[
    _Onderdeel('Agenda', Icons.calendar_month_outlined, 'Blauwe afspraken'),
    _Onderdeel('Notities Bureau', Icons.edit_note_rounded, 'Klantnotities'),
    _Onderdeel('Notities Plaatsers', Icons.send_outlined, 'Berichten sturen'),
    _Onderdeel('Magazijn', Icons.qr_code_scanner_rounded, 'QR / voorraad + en −'),
    _Onderdeel('Bibliotheek', Icons.folder_open_outlined, 'Fiches en PDF'),
    _Onderdeel('Geleverd', Icons.inventory_2_outlined, 'Bestelde artikelen'),
  ];

  int _pagina = -1;
  bool _dashboardBezig = false;

  bool get _heeftOnbevestigdeWijzigingen => switch (_pagina) {
    1 => _notitiesKey.currentState?.heeftOnbevestigdeWijzigingen ?? false,
    3 => _magazijnKey.currentState?.heeftOnbevestigdeWijzigingen ?? false,
    5 => _geleverdKey.currentState?.heeftOnbevestigdeWijzigingen ?? false,
    _ => false,
  };

  bool get _bevestigingBezig => switch (_pagina) {
    1 => _notitiesKey.currentState?.bevestigingBezig ?? false,
    3 => _magazijnKey.currentState?.bevestigingBezig ?? false,
    5 => _geleverdKey.currentState?.bevestigingBezig ?? false,
    _ => false,
  };

  Future<void> _naarDashboard() async {
    if (_pagina == -1 || _dashboardBezig) return;
    if (_bevestigingBezig) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wacht tot de bevestiging klaar is.')),
      );
      return;
    }
    _dashboardBezig = true;
    FocusManager.instance.primaryFocus?.unfocus();
    try {
      if (_heeftOnbevestigdeWijzigingen) {
        final bevestig = await showDialog<bool>(
          context: context,
          builder: (dialoogContext) => AlertDialog(
            title: const Text('Onbevestigde wijzigingen'),
            content: const Text(
              'Bevestig je wijzigingen om terug te keren naar het dashboard.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialoogContext).pop(false),
                child: const Text('Op pagina blijven'),
              ),
              _kopCirkel(
                icon: Icons.check_rounded,
                tooltip: 'Bevestigen en naar dashboard',
                actie: () => Navigator.of(dialoogContext).pop(true),
                oranje: true,
              ),
            ],
          ),
        );
        if (!mounted || bevestig != true) return;
        switch (_pagina) {
          case 1:
            await _notitiesKey.currentState?.bewaarVoorVerzending();
            break;
          case 3:
            await _magazijnKey.currentState?.bevestig();
            break;
          case 5:
            await _geleverdKey.currentState?.bevestig();
            break;
        }
        if (!mounted || _heeftOnbevestigdeWijzigingen) return;
      }
      if (mounted) _openPagina(-1);
    } finally {
      _dashboardBezig = false;
    }
  }
  // De agenda heeft zijn eigen Navigator BINNEN het gedeelde scherm.
  // Zo blijven de zwarte bovenbalk en ondernavigatie ook in de dagagenda staan.
  final GlobalKey<NavigatorState> _agendaNavigator = GlobalKey<NavigatorState>();
  final GlobalKey<ThimacoIphoneAgendaState> _agendaSleutel =
      GlobalKey<ThimacoIphoneAgendaState>();
  final GlobalKey<ThimacoIphoneNotitiesBureauState> _notitiesKey =
      GlobalKey<ThimacoIphoneNotitiesBureauState>();
  final _bibliotheekKey = GlobalKey<ThimacoIphoneBibliotheekState>();
  final _geleverdKey = GlobalKey<ThimacoIphoneGeleverdState>();
  final GlobalKey<ThimacoIphoneMagazijnState> _magazijnKey =
      GlobalKey<ThimacoIphoneMagazijnState>();

  void _openPagina(int index) {
    // Via de tab Agenda bereik je altijd het maandoverzicht, ook vanuit
    // de dagagenda of nadat je vanuit een andere module terugkeert.
    if (index == 0) {
      _agendaNavigator.currentState?.popUntil((route) => route.isFirst);
    }
    if (index != _pagina) setState(() => _pagina = index);
    if (index == 4 || index == 5) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _pagina != index) return;
        if (index == 4) {
          _bibliotheekKey.currentState?.vernieuw();
        } else if (!_heeftOnbevestigdeWijzigingen) {
          _geleverdKey.currentState?.vernieuw();
        }
      });
    }
    if (index == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pagina == 0) {
          _agendaSleutel.currentState?.synchroniseer();
        }
      });
    }
  }

  Widget _agendaBinnenNavigatie() => Navigator(
        key: _agendaNavigator,
        onGenerateRoute: (instellingen) => MaterialPageRoute<void>(
          settings: instellingen,
          builder: (_) => ThimacoIphoneAgenda(key: _agendaSleutel),
        ),
      );

  void _agendaActie(VoidCallback actie) {
    _agendaNavigator.currentState?.popUntil((route) => route.isFirst);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _pagina == 0) actie();
    });
  }

  Widget _kopCirkel({
    required IconData icon,
    required String tooltip,
    required VoidCallback actie,
    bool oranje = false,
  }) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: actie,
      customBorder: const CircleBorder(),
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: oranje ? _oranje : Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: oranje ? Colors.white : _zwart, size: 18),
      ),
    ),
  );

  Widget _icoonCirkel(IconData icon) => Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: _oranje,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 21),
      );

  Widget _kaart({required Widget child, EdgeInsets? padding}) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _rand),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: padding ?? const EdgeInsets.all(14),
        child: child,
      );

  Widget _kop(String tekst, {Widget? actie}) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tekst,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 4),
                Container(width: 40, height: 2, color: _oranje),
              ],
            ),
          ),
          if (actie != null) actie,
        ],
      );

  // Dezelfde beeldasset als de witte bovenbalk van de grote Windows-app.
  // Geen handmatig nagetekende letters: daardoor blijft het logo exact gelijk.
  Widget _bovenbalk() => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 9, 16, 10),
        child: SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              height: 52,
              width: 238,
              child: Image.asset(
                'assets/offerte/thimaco_logo.png',
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
        ),
      );

  // Eén 46px zwarte titelbalk voor ALLE pagina's.
  Widget _titelBalk() => Container(
        height: 46,
        margin: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _zwart,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              height: 23,
              width: 3,
              decoration: BoxDecoration(
                color: _oranje,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(_pagina < 0 ? 'Dashboard' : _modules[_pagina].naam,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  )),
            ),
            if (_pagina == 0) ...[
              _kopCirkel(
                icon: Icons.refresh_rounded,
                tooltip: 'Agenda synchroniseren',
                actie: () => _agendaSleutel.currentState?.synchroniseer(handmatig: true),
              ),
              const SizedBox(width: 5),
              _kopCirkel(
                icon: Icons.filter_list_rounded,
                tooltip: 'Agenda filteren',
                actie: () => _agendaActie(() => _agendaSleutel.currentState?.openFilters()),
              ),
              const SizedBox(width: 5),
              _kopCirkel(
                icon: Icons.search_rounded,
                tooltip: 'Afspraken zoeken',
                actie: () => _agendaActie(() => _agendaSleutel.currentState?.zoekAfspraken()),
              ),
              const SizedBox(width: 5),
              _kopCirkel(
                icon: Icons.add_rounded,
                tooltip: 'Nieuwe blauwe afspraak',
                actie: () => _agendaActie(() => _agendaSleutel.currentState?.voegAfspraakToe()),
                oranje: true,
              ),
            ],
            if (_pagina == 3) ...[
              _kopCirkel(
                icon: Icons.refresh_rounded,
                tooltip: 'Magazijn vernieuwen',
                actie: () { _magazijnKey.currentState?.vernieuw(); },
              ),
              const SizedBox(width: 5),
              _kopCirkel(
                icon: Icons.check_rounded,
                tooltip: 'Voorraadwijziging bevestigen',
                actie: () => _magazijnKey.currentState?.bevestig(),
                oranje: true,
              ),
            ],
            if (_pagina == 4 || _pagina == 5)
              _kopCirkel(
                icon: Icons.refresh_rounded,
                tooltip: 'Bureaugegevens vernieuwen',
                actie: () {
                  if (_pagina == 4) {
                    _bibliotheekKey.currentState?.vernieuw(aanmelden: true);
                  } else {
                    _geleverdKey.currentState?.vernieuw(aanmelden: true);
                  }
                },
              ),
            if (_pagina == 5)
              _kopCirkel(
                icon: Icons.check_rounded,
                tooltip: 'Selectie bevestigen',
                actie: () => _geleverdKey.currentState?.bevestig(),
                oranje: true,
              ),
            if (_pagina == 1)
              Tooltip(
                message: 'Notitie en foto’s aanbieden aan bureau via OneDrive',
                child: InkWell(
                  onTap: () => _notitiesKey.currentState?.bewaarVoorVerzending(),
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: _oranje,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
          ],
        ),
      );

  Widget _dashboard() => ListView(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
        children: [
          _kaart(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kop('Snel naar'),
                const SizedBox(height: 12),
                LayoutBuilder(builder: (context, constraints) {
                  final breedte = (constraints.maxWidth - 10) / 2;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (var index = 0; index < _modules.length; index++)
                        if (index != 2) // Notities Plaatsers voorlopig verborgen.
                        SizedBox(
                          width: breedte,
                          child: InkWell(
                            onTap: () => _openPagina(index),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              constraints: const BoxConstraints(minHeight: 116),
                              decoration: BoxDecoration(
                                border: Border.all(color: _rand),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _icoonCirkel(_modules[index].icon),
                                  const SizedBox(height: 9),
                                  Text(_modules[index].naam,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800)),
                                  Text(_modules[index].subtitel,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF66717D))),
                                  const SizedBox(height: 6),
                                  Container(width: 34, height: 2, color: _oranje),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _kaart(
            child: const Row(
              children: [
                Icon(Icons.cloud_off_outlined, color: Color(0xFF66717D)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Microsoft-aanmelding voor bureaunotities: zie Notities Bureau',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _module(int index) {
    final module = _modules[index];
    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
      children: [
        _kaart(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _kop(module.naam),
              const SizedBox(height: 10),
              Text(module.subtitel,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              const Text(
                'Voorbeeldscherm — koppeling met de bestaande Thimaco-gegevens '
                'volgt na controle van de opslag en synchronisatie.',
                style: TextStyle(color: Color(0xFF66717D), fontSize: 13),
              ),
            ],
          ),
        ),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // De navigatie hoort bij de hoofd-Scaffold en wordt nooit afgedekt door
    // Agenda, Dagoverzicht of Notities Bureau. De tabinhoud blijft bewaard.
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (_pagina == -1) _bovenbalk(),
            _titelBalk(),
            Expanded(
              child: IndexedStack(
                index: _pagina + 1,
                children: [
                  _dashboard(),
                  _agendaBinnenNavigatie(),
                  ThimacoIphoneNotitiesBureau(key: _notitiesKey),
                  _module(2),
                  ThimacoIphoneMagazijn(key: _magazijnKey),
                  ThimacoIphoneBibliotheek(key: _bibliotheekKey),
                  ThimacoIphoneGeleverd(key: _geleverdKey),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _pagina < 0 ? null : SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: _rand)),
          ),
          alignment: Alignment.center,
          height: 44,
          child: TextButton.icon(
            onPressed: _naarDashboard,
            icon: const Icon(Icons.home_outlined, size: 17),
            label: const Text('Dashboard'),
            style: TextButton.styleFrom(
              foregroundColor: _zwart,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ),
    );
  }
}
