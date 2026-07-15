import 'package:flutter/material.dart';

import '../../app_storage.dart';
import 'opmeting_raam_opvulling_model.dart';

class OpmetingRaamOpvullingenPagina extends StatefulWidget {
  const OpmetingRaamOpvullingenPagina({super.key});

  @override
  State<OpmetingRaamOpvullingenPagina> createState() {
    return _OpmetingRaamOpvullingenPaginaState();
  }
}

class _OpmetingRaamOpvullingenPaginaState
    extends State<OpmetingRaamOpvullingenPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  final List<OpmetingRaamOpvullingGroepModel> _groepen = [];
  final List<OpmetingRaamOpvullingModel> _opvullingen = [];

  bool _laden = true;
  bool _bewaren = false;

  @override
  void initState() {
    super.initState();
    _laadOpvullingen();
  }

  Future<void> _laadOpvullingen() async {
    setState(() {
      _laden = true;
    });

    final geladen = await AppStorage.laadOpmetingRaamOpvullingen();
    final groepen = _leesGroepenUitOpslag(geladen);
    final opvullingen = geladen
        .where((opvulling) => !opvulling.isGroepDefinitie)
        .toList();

    _vulOntbrekendeGroepenAan(groepen, opvullingen);
    groepen.sort(_sorteerGroepen);
    opvullingen.sort(_sorteerOpvullingen);

    if (!mounted) {
      return;
    }

    setState(() {
      _groepen
        ..clear()
        ..addAll(groepen);
      _opvullingen
        ..clear()
        ..addAll(opvullingen);
      _laden = false;
    });
  }

  List<OpmetingRaamOpvullingGroepModel> _leesGroepenUitOpslag(
    List<OpmetingRaamOpvullingModel> geladen,
  ) {
    final map = <String, OpmetingRaamOpvullingGroepModel>{};

    for (final item in geladen) {
      if (!item.isGroepDefinitie) {
        continue;
      }

      map[item.groepId] = OpmetingRaamOpvullingGroepModel(
        id: item.groepId,
        naam: item.groepNaam,
        sorteerIndex: item.groepSorteerIndex,
      );
    }

    if (map.isEmpty) {
      for (final groep in OpmetingRaamOpvullingGroepModel.standaardGroepen) {
        map[groep.id] = groep;
      }
    }

    return map.values.toList();
  }

  void _vulOntbrekendeGroepenAan(
    List<OpmetingRaamOpvullingGroepModel> groepen,
    List<OpmetingRaamOpvullingModel> opvullingen,
  ) {
    final bestaandeGroepen = <String>{for (final groep in groepen) groep.id};

    for (final opvulling in opvullingen) {
      if (bestaandeGroepen.contains(opvulling.groepId)) {
        continue;
      }

      groepen.add(
        OpmetingRaamOpvullingGroepModel(
          id: opvulling.groepId,
          naam: opvulling.groepNaam,
          sorteerIndex: opvulling.groepSorteerIndex,
        ),
      );
      bestaandeGroepen.add(opvulling.groepId);
    }

    if (groepen.isEmpty) {
      groepen.addAll(OpmetingRaamOpvullingGroepModel.standaardGroepen);
    }
  }

  Future<void> _bewaarAlles({
    List<OpmetingRaamOpvullingGroepModel>? groepen,
    List<OpmetingRaamOpvullingModel>? opvullingen,
  }) async {
    final nieuweGroepen = List<OpmetingRaamOpvullingGroepModel>.from(
      groepen ?? _groepen,
    )..sort(_sorteerGroepen);
    final nieuweOpvullingen = List<OpmetingRaamOpvullingModel>.from(
      opvullingen ?? _opvullingen,
    )..sort(_sorteerOpvullingen);

    setState(() {
      _bewaren = true;
      _groepen
        ..clear()
        ..addAll(nieuweGroepen);
      _opvullingen
        ..clear()
        ..addAll(nieuweOpvullingen);
    });

    final opslagLijst = <OpmetingRaamOpvullingModel>[
      ...nieuweGroepen.map(OpmetingRaamOpvullingModel.groepDefinitie),
      ...nieuweOpvullingen,
    ];

    await AppStorage.bewaarOpmetingRaamOpvullingen(opslagLijst);

    if (!mounted) {
      return;
    }

    setState(() {
      _bewaren = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _tekstDonker,
        elevation: 0,
        title: const Text(
          'Opvullingen',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'Submenu toevoegen',
            onPressed: _bewaren ? null : () => _openGroepEditor(),
            icon: const Icon(Icons.create_new_folder_outlined, color: _groen),
          ),
          IconButton(
            tooltip: 'Standaard submenu’s en types toevoegen',
            onPressed: _bewaren ? null : _voegStandaardTypesToe,
            icon: const Icon(Icons.playlist_add_rounded, color: _groen),
          ),
          IconButton(
            tooltip: 'Nieuwe opvulling',
            onPressed: _bewaren ? null : () => _openEditor(),
            icon: const Icon(Icons.add_rounded, color: _groen),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _laden ? _laadWeergave() : _inhoud(),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _groen,
        foregroundColor: Colors.white,
        onPressed: _bewaren ? null : () => _openEditor(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Type toevoegen'),
      ),
    );
  }

  Widget _laadWeergave() {
    return const Center(child: CircularProgressIndicator(color: _groen));
  }

  Widget _inhoud() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 96),
      children: [
        _uitlegKaart(),
        const SizedBox(height: 14),
        _knoppenKaart(),
        const SizedBox(height: 14),
        if (_groepen.isEmpty) _legeKaart() else ..._groepKaarten(),
      ],
    );
  }

  Widget _uitlegKaart() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rand),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: _groen, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Maak zelf submenu’s aan, bijvoorbeeld Niet gelaagd, 1 zijde gelaagd, 2 zijden gelaagd of een eigen groep. Onder elk submenu voeg je types toe zoals Helder, Gezandstraald of Ornament. Deze lijst wordt gebruikt in PVC raam, ALU raam en PVC deur.',
              style: TextStyle(
                color: _tekstGrijs,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _knoppenKaart() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rand),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          ElevatedButton.icon(
            onPressed: _bewaren ? null : () => _openGroepEditor(),
            icon: const Icon(Icons.create_new_folder_outlined, size: 18),
            label: const Text('Submenu toevoegen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _groen,
              foregroundColor: Colors.white,
            ),
          ),
          OutlinedButton.icon(
            onPressed: _bewaren ? null : () => _openEditor(),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Type toevoegen'),
            style: OutlinedButton.styleFrom(foregroundColor: _groen),
          ),
          OutlinedButton.icon(
            onPressed: _bewaren ? null : _voegStandaardTypesToe,
            icon: const Icon(Icons.playlist_add_rounded, size: 18),
            label: const Text('Standaard types'),
            style: OutlinedButton.styleFrom(foregroundColor: _tekstDonker),
          ),
        ],
      ),
    );
  }

  Widget _legeKaart() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rand),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: _lichtGroen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.folder_open_outlined,
              color: _groen,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Nog geen submenu’s',
            style: TextStyle(
              color: _tekstDonker,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Maak eerst een submenu en voeg daarna types toe.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _tekstGrijs, fontSize: 12),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => _openGroepEditor(),
            icon: const Icon(Icons.create_new_folder_outlined, size: 18),
            label: const Text('Submenu toevoegen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _groen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _groepKaarten() {
    final groepen = List<OpmetingRaamOpvullingGroepModel>.from(_groepen)
      ..sort(_sorteerGroepen);

    return groepen.map((groep) {
      final items =
          _opvullingen
              .where((opvulling) => opvulling.groepId == groep.id)
              .toList()
            ..sort(_sorteerOpvullingen);

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _groepKaart(groep: groep, items: items),
      );
    }).toList();
  }

  Widget _groepKaart({
    required OpmetingRaamOpvullingGroepModel groep,
    required List<OpmetingRaamOpvullingModel> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rand),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        key: PageStorageKey<String>('opvulling_groep_${groep.id}'),
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        iconColor: _groen,
        collapsedIconColor: _tekstGrijs,
        title: Row(
          children: [
            Expanded(
              child: Text(
                groep.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _tekstDonker,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Submenu wijzigen',
              visualDensity: VisualDensity.compact,
              onPressed: () => _openGroepEditor(groep: groep),
              icon: const Icon(
                Icons.edit_outlined,
                color: _tekstGrijs,
                size: 20,
              ),
            ),
            IconButton(
              tooltip: 'Submenu wissen',
              visualDensity: VisualDensity.compact,
              onPressed: () => _bevestigGroepWissen(groep),
              icon: const Icon(
                Icons.delete_outline,
                color: Color(0xFFDC2626),
                size: 20,
              ),
            ),
          ],
        ),
        subtitle: Text(
          items.isEmpty ? 'Geen types' : '${items.length} types',
          style: const TextStyle(color: _tekstGrijs, fontSize: 11),
        ),
        children: [
          if (items.isEmpty)
            _legeGroepRij(groep)
          else
            ...items.map(_opvullingRij),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => _openEditor(beginGroep: groep),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text('Type toevoegen bij ${groep.label}'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _groen,
                side: const BorderSide(color: _groen),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legeGroepRij(OpmetingRaamOpvullingGroepModel groep) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rand),
      ),
      child: Text(
        'Nog geen types in ${groep.label}.',
        style: const TextStyle(color: _tekstGrijs, fontSize: 12),
      ),
    );
  }

  Widget _opvullingRij(OpmetingRaamOpvullingModel opvulling) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 9, 6, 9),
      decoration: BoxDecoration(
        color: opvulling.actief ? Colors.white : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rand),
      ),
      child: Row(
        children: [
          _kleurVak(opvulling),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  opvulling.naam,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: opvulling.actief ? _tekstDonker : _tekstGrijs,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${opvulling.groepLabel} · ${opvulling.transparantiePercentage}% zichtbaar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _tekstGrijs, fontSize: 11),
                ),
              ],
            ),
          ),
          if (!opvulling.actief)
            Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Inactief',
                style: TextStyle(
                  color: _tekstGrijs,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          IconButton(
            tooltip: opvulling.actief ? 'Inactief zetten' : 'Actief zetten',
            onPressed: () => _wisselActief(opvulling),
            icon: Icon(
              opvulling.actief
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: opvulling.actief ? _groen : _tekstGrijs,
              size: 20,
            ),
          ),
          IconButton(
            tooltip: 'Bewerken',
            onPressed: () => _openEditor(opvulling: opvulling),
            icon: const Icon(Icons.edit_outlined, color: _tekstGrijs, size: 20),
          ),
          IconButton(
            tooltip: 'Wissen',
            onPressed: () => _bevestigWissen(opvulling),
            icon: const Icon(
              Icons.delete_outline,
              color: Color(0xFFDC2626),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _kleurVak(OpmetingRaamOpvullingModel opvulling) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: opvulling.weergaveKleur,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: opvulling.kleur.withOpacity(0.95),
          width: 1.5,
        ),
      ),
    );
  }

  Future<void> _openGroepEditor({
    OpmetingRaamOpvullingGroepModel? groep,
  }) async {
    final controller = TextEditingController(text: groep?.naam ?? '');
    String? foutmelding;

    try {
      final resultaat = await showDialog<OpmetingRaamOpvullingGroepModel>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  groep == null ? 'Submenu toevoegen' : 'Submenu wijzigen',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                content: SizedBox(
                  width: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: controller,
                        autofocus: true,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Naam submenu',
                          hintText:
                              'bv. Niet gelaagd, Structuurglas, Veiligheidsglas',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      if (foutmelding != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          foutmelding!,
                          style: const TextStyle(
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuleren'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _groen,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      final naam = controller.text.trim();

                      if (naam.isEmpty) {
                        setDialogState(() {
                          foutmelding = 'Vul een naam in voor het submenu.';
                        });
                        return;
                      }

                      final bestaatAl = _groepen.any((item) {
                        if (groep != null && item.id == groep.id) {
                          return false;
                        }
                        return item.naam.trim().toLowerCase() ==
                            naam.toLowerCase();
                      });

                      if (bestaatAl) {
                        setDialogState(() {
                          foutmelding = 'Dit submenu bestaat al.';
                        });
                        return;
                      }

                      Navigator.pop(
                        context,
                        OpmetingRaamOpvullingGroepModel(
                          id: groep?.id ?? _maakGroepId(naam),
                          naam: naam,
                          sorteerIndex:
                              groep?.sorteerIndex ?? _volgendeGroepIndex(),
                        ),
                      );
                    },
                    child: const Text('Bewaren'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (resultaat == null) {
        return;
      }

      final nieuweGroepen = List<OpmetingRaamOpvullingGroepModel>.from(
        _groepen,
      );
      final nieuweOpvullingen = List<OpmetingRaamOpvullingModel>.from(
        _opvullingen,
      );
      final index = nieuweGroepen.indexWhere((item) => item.id == resultaat.id);

      if (index >= 0) {
        nieuweGroepen[index] = resultaat;

        for (var i = 0; i < nieuweOpvullingen.length; i++) {
          final item = nieuweOpvullingen[i];
          if (item.groepId != resultaat.id) {
            continue;
          }

          nieuweOpvullingen[i] = item.copyWith(
            groepNaam: resultaat.naam,
            groepSorteerIndex: resultaat.sorteerIndex,
          );
        }
      } else {
        nieuweGroepen.add(resultaat);
      }

      await _bewaarAlles(
        groepen: nieuweGroepen,
        opvullingen: nieuweOpvullingen,
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _openEditor({
    OpmetingRaamOpvullingModel? opvulling,
    OpmetingRaamOpvullingGroepModel? beginGroep,
  }) async {
    if (_groepen.isEmpty) {
      await _openGroepEditor();
      if (_groepen.isEmpty) {
        return;
      }
    }

    final naamController = TextEditingController(text: opvulling?.naam ?? '');

    var groep = _zoekGroep(opvulling?.groepId) ?? beginGroep ?? _groepen.first;
    var kleurWaarde = opvulling?.kleurWaarde ?? 0xFFB3E5FC;
    var transparantie = opvulling?.transparantie ?? 0.25;
    var actief = opvulling?.actief ?? true;
    String? foutmelding;

    try {
      final resultaat = await showDialog<OpmetingRaamOpvullingModel>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  opvulling == null
                      ? 'Opvulling toevoegen'
                      : 'Opvulling wijzigen',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                content: SizedBox(
                  width: 460,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<String>(
                          value: groep.id,
                          decoration: const InputDecoration(
                            labelText: 'Submenu',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: _groepen.map((item) {
                            return DropdownMenuItem(
                              value: item.id,
                              child: Text(item.label),
                            );
                          }).toList(),
                          onChanged: (waarde) {
                            final gevonden = _zoekGroep(waarde);
                            if (gevonden == null) {
                              return;
                            }

                            setDialogState(() {
                              groep = gevonden;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: naamController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            hintText: 'bv. Helder, Gezandstraald, Ornament',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Kleur op de tekening',
                          style: TextStyle(
                            color: _tekstDonker,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _kleurKeuzes.map((waarde) {
                            final gekozen = waarde == kleurWaarde;
                            return InkWell(
                              borderRadius: BorderRadius.circular(9),
                              onTap: () {
                                setDialogState(() {
                                  kleurWaarde = waarde;
                                });
                              },
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Color(waarde).withOpacity(
                                    transparantie.clamp(0.05, 1.0).toDouble(),
                                  ),
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(
                                    color: gekozen ? _groen : _rand,
                                    width: gekozen ? 2 : 1,
                                  ),
                                ),
                                child: gekozen
                                    ? const Icon(
                                        Icons.check_rounded,
                                        color: _groen,
                                        size: 20,
                                      )
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Zichtbaarheid kleur',
                                style: TextStyle(
                                  color: _tekstDonker,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Text(
                              '${(transparantie * 100).round()}%',
                              style: const TextStyle(
                                color: _tekstGrijs,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: transparantie.clamp(0.05, 1.0).toDouble(),
                          min: 0.05,
                          max: 1.0,
                          divisions: 19,
                          activeColor: _groen,
                          onChanged: (waarde) {
                            setDialogState(() {
                              transparantie = waarde;
                            });
                          },
                        ),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          value: actief,
                          activeColor: _groen,
                          title: const Text(
                            'Actief tonen in opmeetfiche',
                            style: TextStyle(
                              color: _tekstDonker,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          onChanged: (waarde) {
                            setDialogState(() {
                              actief = waarde;
                            });
                          },
                        ),
                        if (foutmelding != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            foutmelding!,
                            style: const TextStyle(
                              color: Color(0xFFDC2626),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuleren'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _groen,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      final naam = naamController.text.trim();

                      if (naam.isEmpty) {
                        setDialogState(() {
                          foutmelding = 'Vul een type in.';
                        });
                        return;
                      }

                      Navigator.pop(
                        context,
                        OpmetingRaamOpvullingModel(
                          id:
                              opvulling?.id ??
                              _maakOpvullingId(groep: groep, naam: naam),
                          naam: naam,
                          kleurWaarde: kleurWaarde,
                          transparantie: transparantie,
                          groepId: groep.id,
                          groepNaam: groep.naam,
                          groepSorteerIndex: groep.sorteerIndex,
                          actief: actief,
                        ),
                      );
                    },
                    child: const Text('Bewaren'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (resultaat == null) {
        return;
      }

      final nieuweLijst = List<OpmetingRaamOpvullingModel>.from(_opvullingen);
      final index = nieuweLijst.indexWhere((item) => item.id == resultaat.id);

      if (index >= 0) {
        nieuweLijst[index] = resultaat;
      } else {
        nieuweLijst.add(resultaat);
      }

      await _bewaarAlles(opvullingen: nieuweLijst);
    } finally {
      naamController.dispose();
    }
  }

  Future<void> _wisselActief(OpmetingRaamOpvullingModel opvulling) async {
    final nieuweLijst = _opvullingen.map((item) {
      if (item.id != opvulling.id) {
        return item;
      }

      return item.copyWith(actief: !item.actief);
    }).toList();

    await _bewaarAlles(opvullingen: nieuweLijst);
  }

  Future<void> _bevestigWissen(OpmetingRaamOpvullingModel opvulling) async {
    final magWissen = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Opvulling wissen?'),
          content: Text(
            'Wil je “${opvulling.volledigeNaam}” verwijderen?\n\n'
            'Bestaande opmetingen behouden hun reeds toegepaste tekst en kleur.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuleren'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Wissen'),
            ),
          ],
        );
      },
    );

    if (magWissen != true) {
      return;
    }

    final nieuweLijst = _opvullingen
        .where((item) => item.id != opvulling.id)
        .toList();

    await _bewaarAlles(opvullingen: nieuweLijst);
  }

  Future<void> _bevestigGroepWissen(
    OpmetingRaamOpvullingGroepModel groep,
  ) async {
    final aantalTypes = _opvullingen
        .where((opvulling) => opvulling.groepId == groep.id)
        .length;

    final magWissen = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Submenu wissen?'),
          content: Text(
            aantalTypes == 0
                ? 'Wil je het submenu “${groep.label}” verwijderen?'
                : 'Wil je het submenu “${groep.label}” verwijderen?\n\nOok de $aantalTypes types in dit submenu worden verwijderd.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuleren'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Wissen'),
            ),
          ],
        );
      },
    );

    if (magWissen != true) {
      return;
    }

    final nieuweGroepen = _groepen
        .where((item) => item.id != groep.id)
        .toList();
    final nieuweOpvullingen = _opvullingen
        .where((item) => item.groepId != groep.id)
        .toList();

    await _bewaarAlles(groepen: nieuweGroepen, opvullingen: nieuweOpvullingen);
  }

  Future<void> _voegStandaardTypesToe() async {
    final nieuweGroepen = List<OpmetingRaamOpvullingGroepModel>.from(_groepen);
    final nieuweLijst = List<OpmetingRaamOpvullingModel>.from(_opvullingen);
    var toegevoegd = 0;

    for (final standaardGroep
        in OpmetingRaamOpvullingGroepModel.standaardGroepen) {
      var groep = _zoekGroepInLijst(nieuweGroepen, standaardGroep.id);
      if (groep == null) {
        groep = standaardGroep;
        nieuweGroepen.add(groep);
        toegevoegd++;
      }

      final groepVoorStandaard = groep;

      for (final standaard in _standaardTypes) {
        final bestaatAl = nieuweLijst.any((item) {
          return item.groepId == groepVoorStandaard.id &&
              item.naam.trim().toLowerCase() == standaard.naam.toLowerCase();
        });

        if (bestaatAl) {
          continue;
        }

        nieuweLijst.add(
          OpmetingRaamOpvullingModel(
            id: _maakOpvullingIdInLijst(
              opvullingen: nieuweLijst,
              groep: groepVoorStandaard,
              naam: standaard.naam,
            ),
            naam: standaard.naam,
            kleurWaarde: standaard.kleurWaarde,
            transparantie: standaard.transparantie,
            groepId: groepVoorStandaard.id,
            groepNaam: groepVoorStandaard.naam,
            groepSorteerIndex: groepVoorStandaard.sorteerIndex,
          ),
        );
        toegevoegd++;
      }
    }

    if (toegevoegd == 0) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alle standaard submenu’s en types bestaan al.'),
        ),
      );
      return;
    }

    await _bewaarAlles(groepen: nieuweGroepen, opvullingen: nieuweLijst);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$toegevoegd standaard onderdelen toegevoegd.')),
    );
  }

  OpmetingRaamOpvullingGroepModel? _zoekGroep(String? groepId) {
    return _zoekGroepInLijst(_groepen, groepId);
  }

  OpmetingRaamOpvullingGroepModel? _zoekGroepInLijst(
    List<OpmetingRaamOpvullingGroepModel> groepen,
    String? groepId,
  ) {
    if (groepId == null) {
      return null;
    }

    for (final groep in groepen) {
      if (groep.id == groepId) {
        return groep;
      }
    }

    return null;
  }

  String _maakGroepId(String naam) {
    final basis = OpmetingRaamOpvullingGroepModel.maakId(naam);
    var id = basis;
    var teller = 2;

    while (_groepen.any((groep) => groep.id == id)) {
      id = '${basis}_$teller';
      teller++;
    }

    return id;
  }

  String _maakOpvullingId({
    required OpmetingRaamOpvullingGroepModel groep,
    required String naam,
  }) {
    return _maakOpvullingIdInLijst(
      opvullingen: _opvullingen,
      groep: groep,
      naam: naam,
    );
  }

  String _maakOpvullingIdInLijst({
    required List<OpmetingRaamOpvullingModel> opvullingen,
    required OpmetingRaamOpvullingGroepModel groep,
    required String naam,
  }) {
    final basis = '${groep.id}_${naam.trim().toLowerCase()}'
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    var id = basis.isEmpty
        ? DateTime.now().microsecondsSinceEpoch.toString()
        : basis;
    var teller = 2;

    while (opvullingen.any((item) => item.id == id)) {
      id = '${basis}_$teller';
      teller++;
    }

    return id;
  }

  int _volgendeGroepIndex() {
    if (_groepen.isEmpty) {
      return 0;
    }

    var hoogste = _groepen.first.sorteerIndex;
    for (final groep in _groepen) {
      if (groep.sorteerIndex > hoogste) {
        hoogste = groep.sorteerIndex;
      }
    }

    return hoogste + 1;
  }

  int _sorteerGroepen(
    OpmetingRaamOpvullingGroepModel eerste,
    OpmetingRaamOpvullingGroepModel tweede,
  ) {
    final indexVergelijking = eerste.sorteerIndex.compareTo(
      tweede.sorteerIndex,
    );
    if (indexVergelijking != 0) {
      return indexVergelijking;
    }

    return eerste.naam.toLowerCase().compareTo(tweede.naam.toLowerCase());
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

  static const List<int> _kleurKeuzes = [
    0xFFB3E5FC,
    0xFFC8E6C9,
    0xFFFFF9C4,
    0xFFFFCCBC,
    0xFFD1C4E9,
    0xFFFFCDD2,
    0xFFE0E0E0,
    0xFFFFFFFF,
    0xFF90CAF9,
    0xFFA5D6A7,
    0xFFFFE082,
    0xFFFFAB91,
  ];

  static const List<_StandaardOpvulling> _standaardTypes = [
    _StandaardOpvulling('Helder', 0xFFB3E5FC, 0.22),
    _StandaardOpvulling('Gezandstraald', 0xFFE0E0E0, 0.34),
    _StandaardOpvulling('Ornament', 0xFFD1C4E9, 0.30),
    _StandaardOpvulling('Mat', 0xFFFFFFFF, 0.42),
    _StandaardOpvulling('Melkglas', 0xFFFFF9C4, 0.36),
  ];
}

class _StandaardOpvulling {
  const _StandaardOpvulling(this.naam, this.kleurWaarde, this.transparantie);

  final String naam;
  final int kleurWaarde;
  final double transparantie;
}
