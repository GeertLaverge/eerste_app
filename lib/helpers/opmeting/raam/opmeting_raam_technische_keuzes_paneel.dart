import 'package:flutter/material.dart';

import 'opmeting_raam_compact_keuzemenu_rij.dart';
import 'opmeting_raam_compacte_technische_rij.dart';
import 'opmeting_raam_keuzemenu_model.dart';
import 'opmeting_raam_kleinhout_helper.dart';
import 'opmeting_raam_kleinhout_model.dart';
import 'opmeting_raam_vulling_helper.dart';

class OpmetingRaamTechnischeKeuzesPaneel extends StatelessWidget {
  const OpmetingRaamTechnischeKeuzesPaneel({
    super.key,
    required this.gekozenOpvullingen,
    required this.gekozenKleinhouten,
    required this.keuzemenus,
    required this.keuzemenusLaden,
    required this.keuzemenusBewaren,
    required this.menuBeheerOntgrendeld,
    required this.opvullingenOpen,
    required this.kleinhoutenOpen,
    required this.onOpvullingenOpenGewijzigd,
    required this.onKleinhoutenOpenGewijzigd,
    required this.geselecteerdeOptieIdVoorMenu,
    required this.onOptieGekozen,
    required this.onMenuToevoegen,
    required this.onBeheerSlotWisselen,
    required this.onMenuAanpassen,
    required this.onMenuOmhoog,
    required this.onMenuOmlaag,
    required this.onMenuVerwijderen,
  });

  final List<OpmetingRaamVullingLegendaItem> gekozenOpvullingen;
  final List<OpmetingRaamKleinhoutLegendaItem> gekozenKleinhouten;
  final List<OpmetingRaamKeuzeMenu> keuzemenus;

  final bool keuzemenusLaden;
  final bool keuzemenusBewaren;
  final bool menuBeheerOntgrendeld;
  final bool opvullingenOpen;
  final bool kleinhoutenOpen;

  final ValueChanged<bool> onOpvullingenOpenGewijzigd;
  final ValueChanged<bool> onKleinhoutenOpenGewijzigd;

  final String? Function(OpmetingRaamKeuzeMenu menu)
  geselecteerdeOptieIdVoorMenu;

  final Future<void> Function(OpmetingRaamKeuzeMenu menu, String optieId)
  onOptieGekozen;

  final VoidCallback onMenuToevoegen;
  final VoidCallback onBeheerSlotWisselen;
  final ValueChanged<OpmetingRaamKeuzeMenu> onMenuAanpassen;
  final ValueChanged<OpmetingRaamKeuzeMenu> onMenuOmhoog;
  final ValueChanged<OpmetingRaamKeuzeMenu> onMenuOmlaag;
  final ValueChanged<OpmetingRaamKeuzeMenu> onMenuVerwijderen;

  @override
  Widget build(BuildContext context) {
    final zichtbareMenus = keuzemenus.where((menu) {
      return menuBeheerOntgrendeld || menu.actief;
    }).toList();

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Technische keuzes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                if (keuzemenusBewaren)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                SizedBox(
                  width: 34,
                  height: 34,
                  child: IconButton(
                    tooltip: 'Technisch item toevoegen',
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    onPressed: onMenuToevoegen,
                    icon: const Icon(
                      Icons.add_circle_outline,
                      size: 22,
                      color: Color(0xFF0B7A3B),
                    ),
                  ),
                ),
                SizedBox(
                  width: 34,
                  height: 34,
                  child: IconButton(
                    tooltip: menuBeheerOntgrendeld
                        ? 'Menu-beheer vergrendelen'
                        : 'Menu-beheer ontgrendelen',
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    onPressed: onBeheerSlotWisselen,
                    icon: Icon(
                      menuBeheerOntgrendeld
                          ? Icons.lock_open
                          : Icons.lock_outline,
                      size: 19,
                      color: menuBeheerOntgrendeld
                          ? const Color(0xFFB45309)
                          : const Color(0xFF0B7A3B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _bouwCompacteOpvullingRij(),
            _bouwCompacteKleinhoutRij(),
            if (keuzemenusLaden)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (zichtbareMenus.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    menuBeheerOntgrendeld
                        ? 'Voeg een technisch item toe met +.'
                        : 'Nog geen technische keuzes toegevoegd.',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                ),
              )
            else
              ...zichtbareMenus.map(_bouwKeuzemenuKaart),
          ],
        ),
      ),
    );
  }

  Widget _bouwCompacteOpvullingRij() {
    return OpmetingRaamCompacteTechnischeRij(
      titel: 'Opvulling',
      waarde: _opvullingSamenvatting(),
      isOpen: opvullingenOpen,
      heeftWaarde: gekozenOpvullingen.isNotEmpty,
      onTap: () {
        onOpvullingenOpenGewijzigd(!opvullingenOpen);
      },
      inhoud: _bouwOpvullingDetails(),
    );
  }

  Widget _bouwCompacteKleinhoutRij() {
    return OpmetingRaamCompacteTechnischeRij(
      titel: 'Kleinhouten',
      waarde: _kleinhoutSamenvatting(),
      isOpen: kleinhoutenOpen,
      heeftWaarde: gekozenKleinhouten.isNotEmpty,
      onTap: () {
        onKleinhoutenOpenGewijzigd(!kleinhoutenOpen);
      },
      inhoud: _bouwKleinhoutDetails(),
    );
  }

  String _opvullingSamenvatting() {
    if (gekozenOpvullingen.isEmpty) {
      return 'Geen gekozen';
    }

    if (gekozenOpvullingen.length == 1) {
      return gekozenOpvullingen.first.naam;
    }

    return '${gekozenOpvullingen.length} gekozen';
  }

  String _kleinhoutSamenvatting() {
    if (gekozenKleinhouten.isEmpty) {
      return 'Geen gekozen';
    }

    if (gekozenKleinhouten.length == 1) {
      final kleinhout = gekozenKleinhouten.first;

      return _maakLeesbaar(kleinhout.type.name);
    }

    return '${gekozenKleinhouten.length} gekozen';
  }

  Widget _bouwOpvullingDetails() {
    if (gekozenOpvullingen.isEmpty) {
      return const Text(
        'Kies de tool Opvulling en selecteer een glasvlak.',
        style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
      );
    }

    return Column(
      children: gekozenOpvullingen.map((opvulling) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            children: [
              Container(
                width: 17,
                height: 17,
                decoration: BoxDecoration(
                  color: opvulling.weergaveKleur,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: const Color(0xFF9CA3AF)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${opvulling.nummer}. '
                  '${opvulling.naam}',
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _bouwKleinhoutDetails() {
    if (gekozenKleinhouten.isEmpty) {
      return const Text(
        'Kies de tool Kleinhout en selecteer een gevuld glasvlak.',
        style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
      );
    }

    return Column(
      children: gekozenKleinhouten.map((kleinhout) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${kleinhout.nummer}. '
              '${_maakLeesbaar(kleinhout.type.name)} · '
              '${_maakLeesbaar(kleinhout.patroon.name)}',
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _bouwKeuzemenuKaart(OpmetingRaamKeuzeMenu menu) {
    return OpmetingRaamCompactKeuzemenuRij(
      menu: menu,
      geselecteerdeOptieId: geselecteerdeOptieIdVoorMenu(menu) ?? '',
      onGekozen: (optieId) async {
        await onOptieGekozen(menu, optieId);
      },
      beheerKnop: menuBeheerOntgrendeld ? _bouwKeuzemenuBeheerKnop(menu) : null,
    );
  }

  Widget _bouwKeuzemenuBeheerKnop(OpmetingRaamKeuzeMenu menu) {
    return SizedBox(
      width: 34,
      height: 34,
      child: PopupMenuButton<String>(
        tooltip: 'Technische keuze aanpassen',
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF6B7280)),
        onSelected: (actie) {
          switch (actie) {
            case 'aanpassen':
              onMenuAanpassen(menu);
              break;

            case 'omhoog':
              onMenuOmhoog(menu);
              break;

            case 'omlaag':
              onMenuOmlaag(menu);
              break;

            case 'verwijderen':
              onMenuVerwijderen(menu);
              break;
          }
        },
        itemBuilder: (context) {
          return const [
            PopupMenuItem<String>(
              value: 'aanpassen',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(Icons.edit_outlined, color: Color(0xFF0B7A3B)),
                title: Text('Technische keuze aanpassen'),
              ),
            ),
            PopupMenuItem<String>(
              value: 'omhoog',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(Icons.arrow_upward),
                title: Text('Naar boven'),
              ),
            ),
            PopupMenuItem<String>(
              value: 'omlaag',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(Icons.arrow_downward),
                title: Text('Naar onder'),
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'verwijderen',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text('Verwijderen', style: TextStyle(color: Colors.red)),
              ),
            ),
          ];
        },
      ),
    );
  }

  static String _maakLeesbaar(String tekst) {
    if (tekst.isEmpty) {
      return tekst;
    }

    final buffer = StringBuffer();

    for (var index = 0; index < tekst.length; index++) {
      final teken = tekst[index];

      if (index > 0 &&
          teken.toUpperCase() == teken &&
          teken.toLowerCase() != teken) {
        buffer.write(' ');
      }

      buffer.write(teken);
    }

    final resultaat = buffer.toString();

    return resultaat[0].toUpperCase() + resultaat.substring(1);
  }
}
