import '../../kader_samenstelling/opmeting_kader_samenstelling_model.dart';
import '../../overzicht/opmeting_overzicht_model.dart';
import '../opmeting_raam_keuzemenu_model.dart';
import '../opmeting_raam_kleinhout_helper.dart';
import '../opmeting_raam_kleinhout_model.dart';
import '../opmeting_raam_model.dart';
import '../opmeting_raam_vulling_helper.dart';

class OpmetingRaamOverzichtBuilder {
  const OpmetingRaamOverzichtBuilder._();

  static const String _groepSleutelPrefix = 'groep::';

  static OpmetingOverzichtRaamItem maak({
    required String klantNaam,
    required String formulierType,
    required int dagmaatBreedteMm,
    required int dagmaatHoogteMm,
    required int raammaatBreedteMm,
    required int raammaatHoogteMm,
    required OpmetingKaderSamenstelling kaderSamenstelling,
    required OpmetingOverzichtTekeningData? beginTekeningData,
    required List<OpmetingRaamTechnischeTekeningInstelling>
    actieveTechnischeTekeningen,
    required Map<String, List<OpmetingRaamTechnischeTekeningInstelling>>
    technischeTekeningenPerKader,
    required Map<String, List<OpmetingRaamTechnischeTekeningInstelling>>
    technischeTekeningenPerKaderGroep,
    required Map<String, Set<String>> technischeKaderGroepen,
    required Map<String, Map<String, OpmetingRaamKeuzeSelectie>>
    keuzeSelectiesPerKader,
    required List<OpmetingRaamKeuzeMenu> keuzemenus,
    required List<OpmetingRaamVullingLegendaItem> gekozenOpvullingen,
    required List<OpmetingRaamKleinhoutLegendaItem> gekozenKleinhouten,
    required String notities,
  }) {
    final tekeningData =
        (beginTekeningData ?? OpmetingOverzichtTekeningData.leeg()).copyWith(
          technischeTekeningen: actieveTechnischeTekeningen,
          technischeTekeningenPerKader: technischeTekeningenPerKader,
          technischeTekeningenPerKaderGroep: technischeTekeningenPerKaderGroep,
          technischeKaderGroepen: technischeKaderGroepen,
        );

    final context = _OpmetingRaamOverzichtContext(
      dagmaatBreedteMm: dagmaatBreedteMm,
      dagmaatHoogteMm: dagmaatHoogteMm,
      raammaatBreedteMm: raammaatBreedteMm,
      raammaatHoogteMm: raammaatHoogteMm,
      kaderSamenstelling: kaderSamenstelling,
      tekeningData: tekeningData,
      keuzeSelectiesPerKader: keuzeSelectiesPerKader,
      keuzemenus: keuzemenus,
      gekozenOpvullingen: gekozenOpvullingen,
      gekozenKleinhouten: gekozenKleinhouten,
      technischeKaderGroepen: technischeKaderGroepen,
    );

    final formulierTypeGenormaliseerd = _normaliseerFormulierType(
      formulierType,
    );

    return OpmetingOverzichtRaamItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      titel: _formulierTypeLabel(formulierTypeGenormaliseerd),
      klantNaam: klantNaam.trim(),
      formulierType: formulierTypeGenormaliseerd,
      dagmaatBreedteMm: dagmaatBreedteMm,
      dagmaatHoogteMm: dagmaatHoogteMm,
      raammaatBreedteMm: raammaatBreedteMm,
      raammaatHoogteMm: raammaatHoogteMm,
      kaderSamenstelling: kaderSamenstelling,
      tekeningData: tekeningData,
      technischeRegels: context.maakTechnischeRegels(),
      technischeContainers: context.maakTechnischeContainers(),
      keuzeSelectiesPerKader: _kopieKeuzeSelecties(keuzeSelectiesPerKader),
      notities: notities.trim(),
    );
  }

  static Map<String, Map<String, OpmetingRaamKeuzeSelectie>>
  _kopieKeuzeSelecties(
    Map<String, Map<String, OpmetingRaamKeuzeSelectie>> bron,
  ) {
    return bron.map((sleutel, selecties) {
      return MapEntry(
        sleutel,
        Map<String, OpmetingRaamKeuzeSelectie>.from(selecties),
      );
    });
  }

  static String _normaliseerFormulierType(String waarde) {
    switch (waarde.trim()) {
      case 'aluRaam':
      case 'alu_raam':
      case 'ALU Raam':
        return 'aluRaam';

      case 'pvcRaam':
      case 'pvc_raam':
      case 'PVC Raam':
      case 'raam':
      case '':
        return 'pvcRaam';

      default:
        return waarde.trim().isEmpty ? 'pvcRaam' : waarde.trim();
    }
  }

  static String _formulierTypeLabel(String formulierType) {
    switch (formulierType) {
      case 'aluRaam':
        return 'ALU Raam';

      case 'pvcRaam':
        return 'PVC Raam';

      case 'aluDeur':
        return 'ALU Deur';

      case 'pvcDeur':
        return 'PVC Deur';

      default:
        return formulierType.trim().isEmpty ? 'PVC Raam' : formulierType.trim();
    }
  }
}

class _OpmetingRaamOverzichtContext {
  const _OpmetingRaamOverzichtContext({
    required this.dagmaatBreedteMm,
    required this.dagmaatHoogteMm,
    required this.raammaatBreedteMm,
    required this.raammaatHoogteMm,
    required this.kaderSamenstelling,
    required this.tekeningData,
    required this.keuzeSelectiesPerKader,
    required this.keuzemenus,
    required this.gekozenOpvullingen,
    required this.gekozenKleinhouten,
    required this.technischeKaderGroepen,
  });

  final int dagmaatBreedteMm;
  final int dagmaatHoogteMm;
  final int raammaatBreedteMm;
  final int raammaatHoogteMm;
  final OpmetingKaderSamenstelling kaderSamenstelling;
  final OpmetingOverzichtTekeningData tekeningData;
  final Map<String, Map<String, OpmetingRaamKeuzeSelectie>>
  keuzeSelectiesPerKader;
  final List<OpmetingRaamKeuzeMenu> keuzemenus;
  final List<OpmetingRaamVullingLegendaItem> gekozenOpvullingen;
  final List<OpmetingRaamKleinhoutLegendaItem> gekozenKleinhouten;
  final Map<String, Set<String>> technischeKaderGroepen;

  List<OpmetingOverzichtTechnischeContainer> maakTechnischeContainers() {
    final containers = <OpmetingOverzichtTechnischeContainer>[];

    for (final kader in kaderSamenstelling.kaders) {
      final regels = <OpmetingOverzichtTechnischeRegel>[
        ..._maakTekeningRegelsVoorKader(kader.id),
        ..._maakKeuzeRegelsVoorSleutel(kader.id),
      ];

      containers.add(
        OpmetingOverzichtTechnischeContainer(
          titel: _raamkaderTitelVoorId(kader.id),
          afmeting: '${kader.breedteMm} × ${kader.hoogteMm} mm',
          regels: regels,
        ),
      );
    }

    final groepSleutels = technischeKaderGroepen.keys.toList()..sort();

    for (final sleutel in groepSleutels) {
      final regels = _maakKeuzeRegelsVoorSleutel(sleutel);

      if (regels.isEmpty) {
        continue;
      }

      containers.add(
        OpmetingOverzichtTechnischeContainer(
          titel: _raamkaderTitelVoorSleutel(sleutel),
          afmeting: _afmetingVoorGroepSleutel(sleutel),
          regels: regels,
        ),
      );
    }

    return List<OpmetingOverzichtTechnischeContainer>.unmodifiable(containers);
  }

  List<OpmetingOverzichtTechnischeRegel> maakTechnischeRegels() {
    final regels = <OpmetingOverzichtTechnischeRegel>[];

    regels.add(
      OpmetingOverzichtTechnischeRegel(
        titel: 'Maten',
        waarde: 'Raammaat $raammaatBreedteMm × $raammaatHoogteMm mm',
      ),
    );

    if (kaderSamenstelling.kaders.length > 1) {
      regels.add(
        OpmetingOverzichtTechnischeRegel(
          titel: 'Kaders',
          waarde: '${kaderSamenstelling.kaders.length} kaders',
        ),
      );
    }

    if (gekozenOpvullingen.isNotEmpty) {
      regels.add(
        OpmetingOverzichtTechnischeRegel(
          titel: 'Opvulling',
          waarde: gekozenOpvullingen
              .map((opvulling) {
                return '${opvulling.nummer}. ${opvulling.naam}';
              })
              .join('\n'),
        ),
      );
    }

    if (gekozenKleinhouten.isNotEmpty) {
      regels.add(
        OpmetingOverzichtTechnischeRegel(
          titel: 'Kleinhouten',
          waarde: gekozenKleinhouten
              .map((kleinhout) {
                return '${kleinhout.nummer}. ${_maakLeesbaar(kleinhout.type.name)} · ${_maakLeesbaar(kleinhout.patroon.name)}';
              })
              .join('\n'),
        ),
      );
    }

    final sleutels = keuzeSelectiesPerKader.keys.toList()..sort();

    for (final sleutel in sleutels) {
      final selecties = keuzeSelectiesPerKader[sleutel];

      if (selecties == null || selecties.isEmpty) {
        continue;
      }

      final kaderNaam = _naamVoorOverzichtSleutel(sleutel);

      for (final menu in keuzemenus) {
        if (!menu.actief) {
          continue;
        }

        final selectie = selecties[menu.id];

        if (selectie == null) {
          continue;
        }

        final optie = _optieVoorMenuEnSelectie(menu: menu, selectie: selectie);

        if (optie.isGeenKeuze) {
          continue;
        }

        final waarde = _overzichtTekstVoorOptie(
          optie: optie,
          selectie: selectie,
        );

        if (waarde.trim().isEmpty) {
          continue;
        }

        regels.add(
          OpmetingOverzichtTechnischeRegel(
            titel: '$kaderNaam · ${menu.titel}',
            waarde: waarde,
          ),
        );
      }
    }

    return List<OpmetingOverzichtTechnischeRegel>.unmodifiable(regels);
  }

  List<OpmetingOverzichtTechnischeRegel> _maakTekeningRegelsVoorKader(
    String kaderId,
  ) {
    final regels = <OpmetingOverzichtTechnischeRegel>[];

    final vullingToewijzingen = _lijstVoorKader<OpmetingRaamVullingToewijzing>(
      perKader: tekeningData.vullingToewijzingenPerKader,
      basis: tekeningData.vullingToewijzingen,
      kaderId: kaderId,
    );

    if (vullingToewijzingen.isNotEmpty) {
      regels.add(
        OpmetingOverzichtTechnischeRegel(
          titel: 'Opvulling',
          waarde: _opvullingTekstVoorOverzicht(vullingToewijzingen.length),
        ),
      );
    }

    final kleinhouten = _lijstVoorKader<OpmetingRaamKleinhout>(
      perKader: tekeningData.kleinhoutenPerKader,
      basis: tekeningData.kleinhouten,
      kaderId: kaderId,
    );

    if (kleinhouten.isNotEmpty) {
      regels.add(
        OpmetingOverzichtTechnischeRegel(
          titel: 'Kleinhout',
          waarde: _uniekeTekst(
            kleinhouten.map((kleinhout) {
              return '${_maakLeesbaar(kleinhout.type.name)} · ${_maakLeesbaar(kleinhout.patroon.name)}';
            }),
          ),
        ),
      );
    }

    return regels;
  }

  List<OpmetingOverzichtTechnischeRegel> _maakKeuzeRegelsVoorSleutel(
    String sleutel,
  ) {
    final selecties = keuzeSelectiesPerKader[sleutel];
    final regels = <OpmetingOverzichtTechnischeRegel>[];

    if (selecties == null || selecties.isEmpty) {
      return regels;
    }

    for (final menu in keuzemenus) {
      if (!menu.actief) {
        continue;
      }

      final selectie = selecties[menu.id];

      if (selectie == null) {
        continue;
      }

      final optie = _optieVoorMenuEnSelectie(menu: menu, selectie: selectie);

      if (optie.isGeenKeuze) {
        continue;
      }

      final waarde = _overzichtTekstVoorOptie(optie: optie, selectie: selectie);

      if (waarde.trim().isEmpty) {
        continue;
      }

      regels.add(
        OpmetingOverzichtTechnischeRegel(titel: menu.titel, waarde: waarde),
      );
    }

    return regels;
  }

  List<T> _lijstVoorKader<T>({
    required Map<String, List<T>> perKader,
    required List<T> basis,
    required String kaderId,
  }) {
    final lijst = perKader[kaderId];

    if (lijst != null) {
      return lijst;
    }

    if (kaderSamenstelling.kaders.length <= 1) {
      return basis;
    }

    return <T>[];
  }

  String _opvullingTekstVoorOverzicht(int aantalVlakken) {
    if (gekozenOpvullingen.isNotEmpty) {
      return gekozenOpvullingen
          .map((opvulling) {
            return '${opvulling.nummer}. ${opvulling.naam}';
          })
          .join(', ');
    }

    return '$aantalVlakken vlak${aantalVlakken == 1 ? '' : 'ken'} ingevuld';
  }

  String _uniekeTekst(Iterable<String> waarden) {
    final uniek = <String>[];

    for (final waarde in waarden) {
      final tekst = waarde.trim();

      if (tekst.isEmpty || uniek.contains(tekst)) {
        continue;
      }

      uniek.add(tekst);
    }

    return uniek.join(', ');
  }

  String _raamkaderTitelVoorId(String kaderId) {
    final index = kaderSamenstelling.kaders.indexWhere(
      (kader) => kader.id == kaderId,
    );

    if (index < 0) {
      return 'Raamkader';
    }

    return 'Raamkader ${index + 1}';
  }

  String _raamkaderTitelVoorSleutel(String sleutel) {
    if (!_isGroepSleutel(sleutel)) {
      return _raamkaderTitelVoorId(sleutel);
    }

    final ids = _kaderIdsUitGroepSleutel(sleutel).toList();

    ids.sort((a, b) => _kaderIndexVoorId(a).compareTo(_kaderIndexVoorId(b)));

    if (ids.isEmpty) {
      return 'Raamkader groep';
    }

    final nummers = ids.map((id) => (_kaderIndexVoorId(id) + 1).toString());

    return 'Raamkader ${nummers.join('+')}';
  }

  int _kaderIndexVoorId(String kaderId) {
    final index = kaderSamenstelling.kaders.indexWhere(
      (kader) => kader.id == kaderId,
    );

    return index < 0 ? 9999 : index;
  }

  String _afmetingVoorGroepSleutel(String sleutel) {
    final ids = _isGroepSleutel(sleutel)
        ? _kaderIdsUitGroepSleutel(sleutel)
        : <String>{sleutel};

    int? links;
    int? rechts;
    int? boven;
    int? onder;

    for (final kader in kaderSamenstelling.kaders) {
      if (!ids.contains(kader.id)) {
        continue;
      }

      links = links == null
          ? kader.linksMm
          : (kader.linksMm < links ? kader.linksMm : links);
      rechts = rechts == null
          ? kader.rechtsMm
          : (kader.rechtsMm > rechts ? kader.rechtsMm : rechts);
      boven = boven == null
          ? kader.bovenMm
          : (kader.bovenMm < boven ? kader.bovenMm : boven);
      onder = onder == null
          ? kader.onderMm
          : (kader.onderMm > onder ? kader.onderMm : onder);
    }

    if (links == null || rechts == null || boven == null || onder == null) {
      return '';
    }

    return '${rechts - links} × ${onder - boven} mm';
  }

  String _naamVoorOverzichtSleutel(String sleutel) {
    if (_isGroepSleutel(sleutel)) {
      final ids = _kaderIdsUitGroepSleutel(sleutel).toList()..sort();

      if (ids.isEmpty) {
        return 'Groep';
      }

      return 'Groep ${ids.map(_kaderNaamVoorId).join(' + ')}';
    }

    return _kaderNaamVoorId(sleutel);
  }

  String _kaderNaamVoorId(String kaderId) {
    for (final kader in kaderSamenstelling.kaders) {
      if (kader.id == kaderId) {
        return kader.naam.trim().isEmpty ? 'Kader' : kader.naam.trim();
      }
    }

    return kaderId.trim().isEmpty ? 'Kader' : kaderId;
  }

  OpmetingRaamKeuzeOptie _optieVoorMenuEnSelectie({
    required OpmetingRaamKeuzeMenu menu,
    required OpmetingRaamKeuzeSelectie selectie,
  }) {
    return menu.zoekOptie(selectie.optieId) ?? menu.geenOptie;
  }

  String _overzichtTekstVoorOptie({
    required OpmetingRaamKeuzeOptie optie,
    required OpmetingRaamKeuzeSelectie selectie,
  }) {
    final delen = <String>[];

    if (optie.uitvoerTekst.trim().isNotEmpty) {
      delen.add(optie.uitvoerTekst.trim());
    } else if (optie.naam.trim().isNotEmpty) {
      delen.add(optie.naam.trim());
    }

    for (final veld in optie.extraVelden) {
      final waarde = selectie.extraWaarden[veld.id]?.toString().trim() ?? '';

      if (waarde.isEmpty) {
        continue;
      }

      final eenheid = veld.eenheid.trim().isEmpty
          ? ''
          : ' ${veld.eenheid.trim()}';
      delen.add('${veld.label}: $waarde$eenheid');
    }

    return delen.join('\n');
  }

  bool _isGroepSleutel(String sleutel) {
    return sleutel.startsWith(OpmetingRaamOverzichtBuilder._groepSleutelPrefix);
  }

  Set<String> _kaderIdsUitGroepSleutel(String sleutel) {
    if (!_isGroepSleutel(sleutel)) {
      return <String>{sleutel};
    }

    final zonderPrefix = sleutel.substring(
      OpmetingRaamOverzichtBuilder._groepSleutelPrefix.length,
    );

    return zonderPrefix
        .split('|')
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  static String _maakLeesbaar(String tekst) {
    if (tekst.isEmpty) {
      return tekst;
    }

    final buffer = StringBuffer();

    for (var index = 0; index < tekst.length; index++) {
      final teken = tekst[index];
      final isHoofdletter =
          teken.toUpperCase() == teken && teken.toLowerCase() != teken;

      if (index > 0 && isHoofdletter) {
        buffer.write(' ');
      }

      buffer.write(teken);
    }

    final resultaat = buffer.toString().toLowerCase();

    if (resultaat.isEmpty) {
      return resultaat;
    }

    return resultaat[0].toUpperCase() + resultaat.substring(1);
  }
}
