import 'package:flutter/material.dart';

import 'opmeting_raam_opvulling_model.dart';

class OpmetingRaamOpvullingMenu extends StatelessWidget {
  const OpmetingRaamOpvullingMenu({
    super.key,
    required this.opvullingen,
    required this.isLaden,
    required this.geselecteerdeOpvullingId,
    required this.aantalGeselecteerdeVlakken,
    required this.totaalAantalVlakken,
    required this.onOpvullingGekozen,
    required this.onToepassen,
    required this.onOpvullingVerwijderen,
    required this.onAllesSelecteren,
    required this.onSelectieWissen,
    this.breedte = 300,
    this.maxHoogte,
    this.onSluiten,
    this.onVerslepen,
  });

  static const Color groen = Color(0xFF0B7A3B);
  static const Color lichtGroen = Color(0xFFE7F6EC);
  static const Color rand = Color(0xFFE5E7EB);
  static const Color tekstDonker = Color(0xFF111827);
  static const Color tekstGrijs = Color(0xFF6B7280);

  final double breedte;
  final double? maxHoogte;

  final List<OpmetingRaamOpvullingModel> opvullingen;
  final bool isLaden;
  final String? geselecteerdeOpvullingId;
  final int aantalGeselecteerdeVlakken;
  final int totaalAantalVlakken;

  final ValueChanged<String?> onOpvullingGekozen;
  final VoidCallback onToepassen;
  final VoidCallback onOpvullingVerwijderen;
  final VoidCallback onAllesSelecteren;
  final VoidCallback onSelectieWissen;

  final VoidCallback? onSluiten;
  final ValueChanged<DragUpdateDetails>? onVerslepen;

  List<OpmetingRaamOpvullingModel> get echteOpvullingen {
    return opvullingen
        .where((opvulling) => !opvulling.isGroepDefinitie)
        .toList();
  }

  OpmetingRaamOpvullingModel? get geselecteerdeOpvulling {
    for (final opvulling in echteOpvullingen) {
      if (opvulling.id == geselecteerdeOpvullingId) {
        return opvulling;
      }
    }

    return null;
  }

  bool get kanToepassen {
    return aantalGeselecteerdeVlakken > 0 && geselecteerdeOpvulling != null;
  }

  bool get kanOpvullingVerwijderen {
    return aantalGeselecteerdeVlakken > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: breedte,
      constraints: BoxConstraints(maxHeight: maxHoogte ?? double.infinity),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: rand),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _kop(),
          Flexible(child: isLaden ? _laadWeergave() : _menuInhoud()),
        ],
      ),
    );
  }

  Widget _kop() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: onVerslepen,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 9),
        decoration: const BoxDecoration(
          color: lichtGroen,
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.format_color_fill_outlined,
              size: 18,
              color: groen,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Opvulling',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF064E3B),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (onSluiten != null)
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onSluiten,
                child: const Padding(
                  padding: EdgeInsets.all(3),
                  child: Icon(Icons.close_rounded, size: 18, color: groen),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _laadWeergave() {
    return const SizedBox(
      height: 110,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: groen),
            ),
            SizedBox(height: 10),
            Text(
              'Opvullingen laden...',
              style: TextStyle(
                color: tekstGrijs,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuInhoud() {
    final opvullingLijst = echteOpvullingen;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _selectieInfo(),
          const SizedBox(height: 10),
          _actieKnoppen(),
          const SizedBox(height: 10),
          if (opvullingLijst.isEmpty) _geenOpvullingen() else _opvullingKeuze(),
          const SizedBox(height: 12),
          _toepassenKnop(),
          const SizedBox(height: 8),
          _verwijderenKnop(),
        ],
      ),
    );
  }

  Widget _selectieInfo() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: rand),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.dashboard_customize_outlined,
            size: 18,
            color: groen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              aantalGeselecteerdeVlakken == 0
                  ? 'Selecteer één of meerdere vlakken.'
                  : '$aantalGeselecteerdeVlakken van $totaalAantalVlakken vlakken geselecteerd',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: tekstDonker,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actieKnoppen() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: totaalAantalVlakken > 0 ? onAllesSelecteren : null,
            icon: const Icon(Icons.select_all, size: 17),
            label: const Text('Alles', style: TextStyle(fontSize: 11)),
            style: OutlinedButton.styleFrom(
              foregroundColor: groen,
              padding: const EdgeInsets.symmetric(vertical: 9),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: aantalGeselecteerdeVlakken > 0 ? onSelectieWissen : null,
            icon: const Icon(Icons.deselect, size: 17),
            label: const Text('Geen', style: TextStyle(fontSize: 11)),
            style: OutlinedButton.styleFrom(
              foregroundColor: tekstGrijs,
              padding: const EdgeInsets.symmetric(vertical: 9),
            ),
          ),
        ),
      ],
    );
  }

  Widget _geenOpvullingen() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: Color(0xFFB45309)),
          SizedBox(width: 7),
          Expanded(
            child: Text(
              'Er zijn nog geen opvullingen. Voeg eerst submenu’s en types toe via Instellingen → Opvullingen.',
              style: TextStyle(
                color: Color(0xFF92400E),
                fontSize: 11,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _opvullingKeuze() {
    final gekozen = geselecteerdeOpvulling;
    final actieveOpvullingen =
        echteOpvullingen.where((opvulling) => opvulling.actief).toList()
          ..sort(_sorteerOpvullingen);

    if (actieveOpvullingen.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFCD34D)),
        ),
        child: const Text(
          'Alle opvullingen staan inactief. Activeer ze via Instellingen.',
          style: TextStyle(
            color: Color(0xFF92400E),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final groepen = OpmetingRaamOpvullingGroepModel.groepenUitOpvullingen(
      actieveOpvullingen,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Kies eerst het submenu en daarna het type.',
          style: TextStyle(
            color: tekstGrijs,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (gekozen != null) ...[
          const SizedBox(height: 8),
          _gekozenOpvullingSamenvatting(gekozen),
        ],
        const SizedBox(height: 8),
        ...groepen.map((groep) {
          final items =
              actieveOpvullingen
                  .where((opvulling) => opvulling.groepId == groep.id)
                  .toList()
                ..sort(_sorteerOpvullingen);

          return _groepTegel(
            groep: groep,
            items: items,
            isGekozenGroep: gekozen?.groepId == groep.id,
          );
        }),
      ],
    );
  }

  Widget _gekozenOpvullingSamenvatting(OpmetingRaamOpvullingModel gekozen) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: lichtGroen,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: groen),
      ),
      child: Row(
        children: [
          _kleurVak(kleur: gekozen.weergaveKleur, basisKleur: gekozen.kleur),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              gekozen.volledigeNaam,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF064E3B),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            '${gekozen.transparantiePercentage}%',
            style: const TextStyle(
              color: Color(0xFF064E3B),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _groepTegel({
    required OpmetingRaamOpvullingGroepModel groep,
    required List<OpmetingRaamOpvullingModel> items,
    required bool isGekozenGroep,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isGekozenGroep ? groen : rand),
        color: isGekozenGroep ? const Color(0xFFF0FDF4) : Colors.white,
      ),
      child: ExpansionTile(
        key: PageStorageKey<String>('opvulling_${groep.id}'),
        initiallyExpanded: isGekozenGroep,
        tilePadding: const EdgeInsets.symmetric(horizontal: 10),
        childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        iconColor: groen,
        collapsedIconColor: tekstGrijs,
        title: Text(
          groep.label,
          style: TextStyle(
            color: isGekozenGroep ? groen : tekstDonker,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          items.isEmpty ? 'Geen types' : '${items.length} types',
          style: const TextStyle(fontSize: 10, color: tekstGrijs),
        ),
        children: items.isEmpty
            ? <Widget>[
                const Padding(
                  padding: EdgeInsets.fromLTRB(2, 2, 2, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Nog geen opvullingen in dit submenu.',
                      style: TextStyle(fontSize: 11, color: tekstGrijs),
                    ),
                  ),
                ),
              ]
            : items.map(_opvullingRij).toList(),
      ),
    );
  }

  Widget _opvullingRij(OpmetingRaamOpvullingModel opvulling) {
    final geselecteerd = opvulling.id == geselecteerdeOpvullingId;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        onOpvullingGekozen(opvulling.id);
      },
      child: Container(
        margin: const EdgeInsets.only(top: 5),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
        decoration: BoxDecoration(
          color: geselecteerd ? lichtGroen : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: geselecteerd ? groen : rand),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: opvulling.id,
              groupValue: geselecteerdeOpvullingId,
              activeColor: groen,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: onOpvullingGekozen,
            ),
            const SizedBox(width: 3),
            _kleurVak(
              kleur: opvulling.weergaveKleur,
              basisKleur: opvulling.kleur,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                opvulling.naam,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: geselecteerd ? const Color(0xFF064E3B) : tekstDonker,
                  fontSize: 12,
                  fontWeight: geselecteerd ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${opvulling.transparantiePercentage}%',
              style: const TextStyle(
                color: tekstGrijs,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toepassenKnop() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: kanToepassen ? onToepassen : null,
        icon: const Icon(Icons.format_color_fill, size: 18),
        label: Text(
          aantalGeselecteerdeVlakken <= 1
              ? 'Opvulling toepassen'
              : 'Opvulling toepassen op $aantalGeselecteerdeVlakken vlakken',
          overflow: TextOverflow.ellipsis,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: groen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFD1D5DB),
          disabledForegroundColor: const Color(0xFF6B7280),
          padding: const EdgeInsets.symmetric(vertical: 11),
        ),
      ),
    );
  }

  Widget _verwijderenKnop() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: kanOpvullingVerwijderen ? onOpvullingVerwijderen : null,
        icon: Icon(
          Icons.delete_outline,
          size: 18,
          color: kanOpvullingVerwijderen
              ? const Color(0xFFDC2626)
              : const Color(0xFF9CA3AF),
        ),
        label: Text(
          'Opvulling uit selectie verwijderen',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: kanOpvullingVerwijderen ? tekstDonker : tekstGrijs,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
          visualDensity: VisualDensity.compact,
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  Widget _kleurVak({required Color kleur, required Color basisKleur}) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: kleur,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: basisKleur.withOpacity(0.95), width: 1.4),
      ),
    );
  }

  int _sorteerOpvullingen(
    OpmetingRaamOpvullingModel eerste,
    OpmetingRaamOpvullingModel tweede,
  ) {
    final groepVergelijking = eerste.groepSorteerIndex.compareTo(
      tweede.groepSorteerIndex,
    );

    if (groepVergelijking != 0) {
      return groepVergelijking;
    }

    final groepNaamVergelijking = eerste.groepNaam.toLowerCase().compareTo(
      tweede.groepNaam.toLowerCase(),
    );

    if (groepNaamVergelijking != 0) {
      return groepNaamVergelijking;
    }

    return eerste.naam.toLowerCase().compareTo(tweede.naam.toLowerCase());
  }
}
