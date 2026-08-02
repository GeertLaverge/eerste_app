// THIMACO-CONTROLE: ALGEMENE-OPMETING-ALLEEN-VRIJE-PRIJZEN-20260801
// THIMACO-CONTROLE: VOORZETSCREEN-INBOUWSCHAKELAAR-ZICHTBAAR-IN-OFFERTEPRIJZEN-20260730-2205
// THIMACO-CONTROLE: VELUX-ZICHTBAAR-BIJ-TECHNISCHE-PRIJSKEUZES-20260730
// THIMACO-CONTROLE: VELUX-OFFERTEPRIJZEN-VRIJE-PRIJZEN-FASE-4-20260729-2257
// THIMACO-CONTROLE: VRIJE-PRIJZEN-TEGEL-ALTIJD-ZICHTBAAR-20260729-1415
// THIMACO-CONTROLE: OFFERTEPRIJZEN-VRIJE-PRIJS-EN-SEKTIONALE-POORTEN-20260729-1313
// THIMACO-CONTROLE: SCHUIFVLIEGENDEUR-INSTELLINGEN-EN-PRIJZEN-20260728
// THIMACO-CONTROLE: PROJECTPRIJS-VERDEELKOST-MEERDERE-FICHES-20260726
import 'package:flutter/material.dart';

import '../../../helpers/app_storage.dart';
import '../../../helpers/offerte/prijzen/offerte_prijs_categorie.dart';
import '../../../helpers/offerte/prijzen/offerte_prijsprofiel_model.dart';
import '../../../helpers/offerte/prijzen/offerte_prijsregel_beheer_service.dart';
import '../../../helpers/offerte/prijzen/offerte_prijsregel_model.dart';
import '../../../helpers/offerte/prijzen/offerte_prijsregels_zwevend_venster.dart';
import '../../../helpers/offerte/prijzen/offerte_verdeelkost_service.dart';
import 'offerte_prijzen_fiche_pagina.dart';

class OffertePrijzenPagina extends StatefulWidget {
  const OffertePrijzenPagina({super.key});

  @override
  State<OffertePrijzenPagina> createState() {
    return _OffertePrijzenPaginaState();
  }
}

class _OffertePrijzenPaginaState extends State<OffertePrijzenPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  static const List<_OffertePrijsFicheKeuze> _fiches =
      <_OffertePrijsFicheKeuze>[
        _OffertePrijsFicheKeuze(
          formulierType: 'vasteInzethor',
          naam: 'Vaste inzethor',
          icoon: Icons.grid_on,
          actief: true,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'vliegendeur',
          naam: 'Vliegendeur',
          icoon: Icons.door_front_door_outlined,
          actief: true,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'schuifvliegendeur',
          naam: 'Schuifvliegendeur',
          icoon: Icons.view_week_outlined,
          actief: true,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'plooiwerken',
          naam: 'Plooiwerken',
          icoon: Icons.polyline_outlined,
          actief: true,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'voorzetscreen',
          naam: 'Voorzetscreen',
          icoon: Icons.blinds_outlined,
          actief: true,
          toonBijTechnischeKeuzes: true,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'sektionalePoort',
          naam: 'Sektionale poorten',
          icoon: Icons.garage_outlined,
          actief: true,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'veluxDakraam',
          naam: 'Velux dakramen',
          icoon: Icons.roofing_outlined,
          actief: true,
          toonBijTechnischeKeuzes: true,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'pvcRaam',
          naam: 'PVC raam',
          icoon: Icons.window_outlined,
          actief: true,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'aluRaam',
          naam: 'ALU raam',
          icoon: Icons.window_outlined,
          actief: true,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'pvcDeur',
          naam: 'PVC deur',
          icoon: Icons.door_front_door_outlined,
          actief: true,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'aluDeur',
          naam: 'ALU deur',
          icoon: Icons.door_front_door_outlined,
          actief: true,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'pvcSchuifraam',
          naam: 'PVC schuifraam',
          icoon: Icons.view_week_outlined,
          actief: true,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'aluSchuifraam',
          naam: 'ALU schuifraam',
          icoon: Icons.view_week_outlined,
          actief: true,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'algemeneOpmeting',
          naam: 'Algemene opmeting',
          icoon: Icons.description_outlined,
          actief: true,
          toonBijTechnischeKeuzes: false,
          toonBijProjectPrijsregels: false,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'zonwering',
          naam: 'Zonwering',
          icoon: Icons.wb_sunny_outlined,
        ),
      ];

  bool _projectPrijsregelsBezig = false;

  List<_OffertePrijsFicheKeuze> get _actieveFiches {
    return _fiches.where((fiche) => fiche.actief).toList(growable: false);
  }

  List<_OffertePrijsFicheKeuze> get _projectPrijsFiches {
    return _actieveFiches
        .where((fiche) => fiche.toonBijProjectPrijsregels)
        .toList(growable: false);
  }

  static String _normaliseerFormulierType(String waarde) {
    return waarde.trim().toLowerCase().replaceAll('_', '').replaceAll(' ', '');
  }

  static bool _isNieuwer(String eerste, String tweede) {
    final eersteDatum = DateTime.tryParse(eerste);
    final tweedeDatum = DateTime.tryParse(tweede);

    if (eersteDatum != null && tweedeDatum != null) {
      return eersteDatum.isAfter(tweedeDatum);
    }

    if (eersteDatum != null) return true;
    if (tweedeDatum != null) return false;

    return eerste.compareTo(tweede) > 0;
  }

  String _projectPrijsregelGroepSleutel(OffertePrijsregelModel regel) {
    if (regel.isVerdeeldeProjectkost) {
      final verdeelSleutel =
          OfferteVerdeelkostService.gekoppeldeVerdeelkostSleutel(regel);
      if (verdeelSleutel.isNotEmpty) {
        return 'verdeelkost::$verdeelSleutel';
      }
    }

    return 'prijsregel::${regel.id}';
  }

  Map<String, List<OffertePrijsregelModel>>
  _maakGekoppeldeVerdeelkostBronnenPerRegelId(
    List<OffertePrijsregelModel> prijsregels,
  ) {
    final perSleutel = <String, List<OffertePrijsregelModel>>{};

    for (final regel in prijsregels) {
      final sleutel = OfferteVerdeelkostService.gekoppeldeVerdeelkostSleutel(
        regel,
      );

      if (sleutel.isEmpty) continue;

      perSleutel
          .putIfAbsent(sleutel, () => <OffertePrijsregelModel>[])
          .add(regel);
    }

    final perRegelId = <String, List<OffertePrijsregelModel>>{};

    for (final gekoppeldeRegels in perSleutel.values) {
      final onwijzigbaar = List<OffertePrijsregelModel>.unmodifiable(
        gekoppeldeRegels,
      );

      for (final regel in gekoppeldeRegels) {
        perRegelId[regel.id] = onwijzigbaar;
      }
    }

    return perRegelId;
  }

  List<OffertePrijsregelModel> _combineerProjectPrijsregelsVoorVenster(
    List<OffertePrijsregelModel> prijsregels,
  ) {
    final resultaat = <OffertePrijsregelModel>[];
    final indexPerGroepSleutel = <String, int>{};

    for (final regel in prijsregels) {
      final groepSleutel = _projectPrijsregelGroepSleutel(regel);
      final bestaandIndex = indexPerGroepSleutel[groepSleutel];

      if (bestaandIndex == null) {
        indexPerGroepSleutel[groepSleutel] = resultaat.length;
        resultaat.add(regel);
        continue;
      }

      final bestaand = resultaat[bestaandIndex];

      if (_isNieuwer(regel.gewijzigdOp, bestaand.gewijzigdOp)) {
        resultaat[bestaandIndex] = regel;
      }
    }

    resultaat.sort((eerste, tweede) {
      final volgorde = eerste.volgorde.compareTo(tweede.volgorde);

      if (volgorde != 0) return volgorde;

      return eerste.omschrijving.toLowerCase().compareTo(
        tweede.omschrijving.toLowerCase(),
      );
    });

    return List<OffertePrijsregelModel>.unmodifiable(resultaat);
  }

  Map<String, Set<String>> _maakFormulierTypeSelectiesPerPrijsregelId({
    required List<OffertePrijsregelModel> allePrijsregels,
    required List<OffertePrijsregelModel> zichtbarePrijsregels,
  }) {
    final formulierTypesPerGroep = <String, Set<String>>{};

    for (final regel in allePrijsregels) {
      if (regel.id.trim().isEmpty) continue;

      formulierTypesPerGroep
          .putIfAbsent(_projectPrijsregelGroepSleutel(regel), () => <String>{})
          .add(regel.formulierType);
    }

    return <String, Set<String>>{
      for (final zichtbareRegel in zichtbarePrijsregels)
        zichtbareRegel.id: Set<String>.unmodifiable(
          formulierTypesPerGroep[_projectPrijsregelGroepSleutel(
                zichtbareRegel,
              )] ??
              <String>{zichtbareRegel.formulierType},
        ),
    };
  }

  List<OffertePrijsregelModel> _breidProjectPrijsregelsUitVoorFormulierTypes({
    required List<OffertePrijsregelModel> prijsregels,
    required Map<String, Set<String>> formulierTypesPerPrijsregelId,
    required Map<String, List<OffertePrijsregelModel>>
    gekoppeldeBronnenPerRegelId,
  }) {
    final resultaat = <OffertePrijsregelModel>[];
    final fichePerSleutel = <String, _OffertePrijsFicheKeuze>{
      for (final fiche in _projectPrijsFiches)
        _normaliseerFormulierType(fiche.formulierType): fiche,
    };

    for (final regel in prijsregels) {
      final geselecteerdeFormulierTypes =
          formulierTypesPerPrijsregelId[regel.id] ??
          <String>{regel.formulierType};
      final gekoppeldeBronnen =
          gekoppeldeBronnenPerRegelId[regel.id] ??
          const <OffertePrijsregelModel>[];
      final toegevoegdeSleutels = <String>{};

      for (final formulierType in geselecteerdeFormulierTypes) {
        final sleutel = _normaliseerFormulierType(formulierType);
        final fiche = fichePerSleutel[sleutel];

        if (fiche == null || !toegevoegdeSleutels.add(sleutel)) {
          continue;
        }

        OffertePrijsregelModel? bestaandeVerdeelkostBron;
        if (regel.isVerdeeldeProjectkost) {
          for (final bron in gekoppeldeBronnen) {
            if (_normaliseerFormulierType(bron.formulierType) == sleutel) {
              bestaandeVerdeelkostBron = bron;
              break;
            }
          }
        }

        resultaat.add(
          regel.copyWith(
            id: bestaandeVerdeelkostBron?.id ?? regel.id,
            categorie: OffertePrijsCategorie.alleArtikelen,
            formulierType: fiche.formulierType,
            volgorde: bestaandeVerdeelkostBron?.volgorde ?? regel.volgorde,
          ),
        );
      }
    }

    return List<OffertePrijsregelModel>.unmodifiable(resultaat);
  }

  Future<void> _openProjectPrijsregelsVenster() async {
    if (_projectPrijsregelsBezig) return;

    setState(() {
      _projectPrijsregelsBezig = true;
    });

    try {
      final profielenPerFormulierType = <String, OffertePrijsprofielModel>{};
      final beginRegels = <OffertePrijsregelModel>[];

      for (final fiche in _projectPrijsFiches) {
        final bestaand = await AppStorage.laadOffertePrijsProfiel(
          fiche.formulierType,
        );

        final profiel =
            bestaand ??
            OffertePrijsprofielModel.leeg(
              formulierType: fiche.formulierType,
              formulierNaam: fiche.naam,
            );

        profielenPerFormulierType[_normaliseerFormulierType(
              fiche.formulierType,
            )] =
            profiel;

        beginRegels.addAll(
          OffertePrijsregelBeheerService.bewaardePrijsregelsVoorCategorie(
            profiel: profiel,
            categorie: OffertePrijsCategorie.alleArtikelen,
            formulierType: fiche.formulierType,
          ),
        );
      }

      if (!mounted) return;

      final gekoppeldeBronnenPerRegelId =
          _maakGekoppeldeVerdeelkostBronnenPerRegelId(beginRegels);

      final huidigeRegels = _combineerProjectPrijsregelsVoorVenster(
        beginRegels,
      );

      final formulierTypeSelectiesPerPrijsregelId =
          _maakFormulierTypeSelectiesPerPrijsregelId(
            allePrijsregels: beginRegels,
            zichtbarePrijsregels: huidigeRegels,
          );

      final formulierTypeLabels = <String, String>{
        for (final fiche in _projectPrijsFiches)
          fiche.formulierType: fiche.naam,
      };

      setState(() {
        _projectPrijsregelsBezig = false;
      });

      final resultaat = await toonOffertePrijsregelsZwevendVenster(
        context: context,
        titel: 'Prijsregel toepassen op…',
        subtitel:
            'Beheer algemene offerteprijzen voor alle soorten opmeetfiches',
        formulierType: _projectPrijsFiches.first.formulierType,
        categorie: OffertePrijsCategorie.alleArtikelen,
        beginPrijsregels: huidigeRegels,
        toonProjectActies: true,
        toonProjectOfferteActies: false,
        behoudFormulierTypePerRegel: true,
        formulierTypeLabels: formulierTypeLabels,
        beginFormulierTypesPerPrijsregelId:
            formulierTypeSelectiesPerPrijsregelId,
        toonFormulierTypeBijRegel: true,
      );

      if (resultaat == null || !mounted) return;

      if (resultaat.actie !=
          OffertePrijsregelsVensterActie.bewarenInInstellingen) {
        return;
      }

      setState(() {
        _projectPrijsregelsBezig = true;
      });

      final prijsregelsVoorOpslag =
          _breidProjectPrijsregelsUitVoorFormulierTypes(
            prijsregels: resultaat.prijsregels,
            formulierTypesPerPrijsregelId:
                resultaat.formulierTypesPerPrijsregelId,
            gekoppeldeBronnenPerRegelId: gekoppeldeBronnenPerRegelId,
          );

      for (final fiche in _projectPrijsFiches) {
        final sleutel = _normaliseerFormulierType(fiche.formulierType);

        final profiel =
            profielenPerFormulierType[sleutel] ??
            OffertePrijsprofielModel.leeg(
              formulierType: fiche.formulierType,
              formulierNaam: fiche.naam,
            );

        final regelsVoorFormulierType = prijsregelsVoorOpslag
            .where((regel) {
              return regel.categorie == OffertePrijsCategorie.alleArtikelen &&
                  _normaliseerFormulierType(regel.formulierType) == sleutel;
            })
            .toList(growable: false);

        final bijgewerkt =
            OffertePrijsregelBeheerService.vervangPrijsregelsVoorCategorie(
              profiel: profiel,
              categorie: OffertePrijsCategorie.alleArtikelen,
              formulierType: fiche.formulierType,
              prijsregels: regelsVoorFormulierType,
            );

        await AppStorage.bewaarOffertePrijsProfiel(bijgewerkt);
      }

      if (!mounted) return;

      _toonMelding('Prijsregels bewaard bij alle gekozen opmeetfiches.');
    } catch (e) {
      if (mounted) {
        _toonMelding(
          'De prijsregels konden niet worden geladen of bewaard: $e',
          fout: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _projectPrijsregelsBezig = false;
        });
      }
    }
  }

  void _toonMelding(String tekst, {bool fout = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: fout ? const Color(0xFFDC2626) : _groen,
        content: Text(tekst),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _achtergrond,
      appBar: AppBar(
        title: const Text(
          'Offerteprijzen',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: <Widget>[
          if (_projectPrijsregelsBezig)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 19,
                  height: 19,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.3,
                    color: _groen,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _rand),
                ),
                child: const Text(
                  'Beheer bovenaan de algemene prijsregels die op één of '
                  'meerdere soorten opmeetfiches kunnen worden toegepast. '
                  'Daaronder beheert u de artikelspecifieke offerteprijzen '
                  'per soort opmeetfiche. Vaste inzethor, Vliegendeur, '
                  'Schuifvliegendeur, Plooiwerken, Voorzetscreen, Algemene opmeting, '
                  'Sektionale poorten, Velux dakramen, PVC en ALU raam, PVC en ALU '
                  'schuifraam en PVC en ALU deur zijn actief. Algemene opmeting '
                  'gebruikt uitsluitend Vrije prijs per artikel. Technische-keuzeprijzen '
                  'zijn onder meer beschikbaar voor Voorzetscreen, Sektionale poorten '
                  'en Velux dakramen. Bij Voorzetscreen wordt alleen Inbouwschakelaar '
                  'afzonderlijk geprijsd; de overige bediening blijft inbegrepen in de '
                  'prijs per stuk. Bij Velux worden de prijzen voor MDF- en '
                  'kunststofbinnenafwerking hier centraal ingesteld.',
                  style: TextStyle(
                    color: _tekstGrijs,
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _bouwProjectPrijsregelsTegel(),
              const SizedBox(height: 12),
              // Bewust onvoorwaardelijk: deze ingang mag nooit afhangen van
              // laden, technische keuzes of het aantal actieve prijsfiches.
              _bouwVrijePrijsPerArtikelTegel(),
              const SizedBox(height: 18),
              const _SectieTitel(
                titel: 'Prijs volgens technische keuze',
                subtitel:
                    'Open een artikeltype en stel prijzen in bij de technische keuzes.',
              ),
              const SizedBox(height: 10),
              ..._fiches.where((fiche) => fiche.toonBijTechnischeKeuzes).map((
                fiche,
              ) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _bouwFicheTegel(context, fiche),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bouwProjectPrijsregelsTegel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: _lichtGroen,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _groen, width: 1.2),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: _groen),
            ),
            child: const Icon(Icons.rule_folder_outlined, color: _groen),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Prijsregels voor meerdere opmeetfiches',
                  style: TextStyle(
                    color: _tekstDonker,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Maak één prijsregel en vink alle opmeetfiches aan waarop '
                  'de regel automatisch mag worden berekend.',
                  style: TextStyle(
                    color: _tekstGrijs,
                    fontSize: 12.2,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _groen,
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            ),
            onPressed: _projectPrijsregelsBezig
                ? null
                : _openProjectPrijsregelsVenster,
            icon: const Icon(Icons.checklist_rounded, size: 18),
            label: const Text(
              'Prijsregel toepassen op…',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwVrijePrijsPerArtikelTegel() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _openVrijePrijsPerArtikelKeuze,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _groen, width: 1.1),
          ),
          child: const Row(
            children: <Widget>[
              _VrijePrijsIcoon(),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Vrije prijzen per artikel',
                      style: TextStyle(
                        color: _tekstDonker,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Beheer handmatig kiesbare prijsregels per artikeltype.',
                      style: TextStyle(
                        color: _tekstGrijs,
                        fontSize: 12.2,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.chevron_right_rounded, color: _groen),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openVrijePrijsPerArtikelKeuze() async {
    final gekozen = await showDialog<_OffertePrijsFicheKeuze>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Vrije prijzen per artikel',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: SizedBox(
            width: 460,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _actieveFiches.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final fiche = _actieveFiches[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _lichtGroen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(fiche.icoon, color: _groen, size: 21),
                  ),
                  title: Text(
                    fiche.naam,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: _groen,
                  ),
                  onTap: () => Navigator.pop(dialogContext, fiche),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuleren'),
            ),
          ],
        );
      },
    );

    if (gekozen == null || !mounted) return;

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) {
          return OffertePrijzenFichePagina(
            formulierType: gekozen.formulierType,
            formulierNaam: gekozen.naam,
            alleenVrijePrijsPerArtikel: true,
          );
        },
      ),
    );
  }

  Widget _bouwFicheTegel(BuildContext context, _OffertePrijsFicheKeuze fiche) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: fiche.actief
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) {
                      return OffertePrijzenFichePagina(
                        formulierType: fiche.formulierType,
                        formulierNaam: fiche.naam,
                      );
                    },
                  ),
                );
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _rand),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: fiche.actief ? _lichtGroen : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  fiche.icoon,
                  color: fiche.actief ? _groen : const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  fiche.naam,
                  style: TextStyle(
                    color: fiche.actief ? _tekstDonker : _tekstGrijs,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (fiche.actief)
                const Icon(Icons.chevron_right_rounded, color: _groen)
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Wordt later gekoppeld',
                    style: TextStyle(
                      color: _tekstGrijs,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VrijePrijsIcoon extends StatelessWidget {
  const _VrijePrijsIcoon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: _OffertePrijzenPaginaState._lichtGroen,
        borderRadius: BorderRadius.circular(11),
      ),
      child: const Icon(
        Icons.price_change_outlined,
        color: _OffertePrijzenPaginaState._groen,
      ),
    );
  }
}

class _SectieTitel extends StatelessWidget {
  const _SectieTitel({required this.titel, required this.subtitel});

  final String titel;
  final String subtitel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            titel,
            style: const TextStyle(
              color: _OffertePrijzenPaginaState._tekstDonker,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitel,
            style: const TextStyle(
              color: _OffertePrijzenPaginaState._tekstGrijs,
              fontSize: 11.8,
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _OffertePrijsFicheKeuze {
  const _OffertePrijsFicheKeuze({
    required this.formulierType,
    required this.naam,
    required this.icoon,
    this.actief = false,
    this.toonBijTechnischeKeuzes = true,
    this.toonBijProjectPrijsregels = true,
  });

  final String formulierType;
  final String naam;
  final IconData icoon;
  final bool actief;
  final bool toonBijTechnischeKeuzes;
  final bool toonBijProjectPrijsregels;
}
