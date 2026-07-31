// THIMACO-CONTROLE: PROJECTPRIJS-IDENTIEKE-REGELS-EENMAAL-MET-ARTIKELGROEPEN-20260731
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../app_storage.dart';
import '../offerte_controller.dart';
import '../../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../../opmeting/project/opmeting_project_titelhoofd_model.dart';
import '../../sync/onedrive_sync_service.dart';
import 'offerte_algemeen_artikel_prijs_service.dart';
import 'offerte_artikel_prijs_koppeling_service.dart';
import 'offerte_prijs_categorie.dart';
import 'offerte_prijsinstellingen_momentopname.dart';
import 'offerte_prijsprofiel_model.dart';
import 'offerte_prijsregel_beheer_service.dart';
import 'offerte_prijsregel_model.dart';
import 'offerte_prijsregels_zwevend_venster.dart';
import 'offerte_verdeelkost_service.dart';

class OfferteProjectPrijsregelController {
  const OfferteProjectPrijsregelController({
    required this.context,
    required this.offerteController,
    required this.isMounted,
    required this.leesArtikelen,
    required this.leesTitelhoofd,
    required this.leesKlantNaam,
    required this.laadPrijsprofiel,
    required this.maakPrijsinstellingenMomentopname,
    required this.herberekenPrijsMomentopnames,
    required this.vervangArtikelen,
    required this.vervangTitelhoofd,
    required this.toonMelding,
  });

  final BuildContext context;
  final OfferteController offerteController;
  final bool Function() isMounted;
  final List<OpmetingOverzichtRaamItem> Function() leesArtikelen;
  final OpmetingProjectTitelhoofd Function() leesTitelhoofd;
  final String Function() leesKlantNaam;
  final Future<OffertePrijsprofielModel> Function(String formulierType)
  laadPrijsprofiel;
  final OffertePrijsinstellingenMomentopname Function(
    OffertePrijsprofielModel profiel,
  )
  maakPrijsinstellingenMomentopname;
  final Future<void> Function(String klantNaam) herberekenPrijsMomentopnames;
  final void Function(List<OpmetingOverzichtRaamItem> artikelen)
  vervangArtikelen;
  final void Function(OpmetingProjectTitelhoofd titelhoofd) vervangTitelhoofd;
  final void Function(String tekst, bool fout) toonMelding;

  String _formulierNaamVoorPrijsType(String formulierType) {
    return OfferteArtikelPrijsKoppelingService.formulierNaamVoor(formulierType);
  }

  String _normaliseerPrijsFormulierType(String waarde) {
    return waarde.trim().toLowerCase().replaceAll('_', '').replaceAll(' ', '');
  }

  void _toonMelding(String tekst, {bool fout = false}) {
    toonMelding(tekst, fout);
  }

  Future<void> openVrijePrijsPerArtikelVenster(
    OpmetingOverzichtRaamItem item, {
    required String positieLabel,
  }) async {
    final koppeling = OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(
      item,
    );
    if (koppeling == null || !isMounted()) return;

    final formulierType = koppeling.formulierType;
    final profiel = await laadPrijsprofiel(formulierType);
    if (!isMounted()) return;

    final bewaardeRegels =
        OffertePrijsregelBeheerService.bewaardePrijsregelsVoorCategorie(
          profiel: profiel,
          categorie: OffertePrijsCategorie.vrijPerArtikel,
          formulierType: formulierType,
        );
    final prijsData = OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(
      item,
    );
    if (prijsData == null) return;

    final tijdelijkeRegels =
        OfferteAlgemeenArtikelPrijsService.tijdelijkeVrijeArtikelPrijsregels(
          prijsData,
          formulierType: formulierType,
        );
    final huidigeRegels =
        OffertePrijsregelBeheerService.combineerBewaardeEnTijdelijkePrijsregels(
          bewaardePrijsregels: bewaardeRegels,
          tijdelijkePrijsregels: tijdelijkeRegels,
          categorie: OffertePrijsCategorie.vrijPerArtikel,
          formulierType: formulierType,
        );

    if (!context.mounted) return;

    final resultaat = await toonOffertePrijsregelsZwevendVenster(
      context: context,
      titel: 'Vrije prijs per artikel',
      subtitel:
          '$positieLabel · ${_formulierNaamVoorPrijsType(formulierType)} · bewaarde en eenmalige prijsregels',
      formulierType: formulierType,
      categorie: OffertePrijsCategorie.vrijPerArtikel,
      beginPrijsregels: huidigeRegels,
      toonToepassenOpDezePositie: true,
      toonToepassenOpAlleGelijkePosities: true,
    );

    if (resultaat == null || !isMounted()) return;

    switch (resultaat.actie) {
      case OffertePrijsregelsVensterActie.toepassenOpDezePositie:
        await _pasTijdelijkeVrijePrijsregelsToe(
          bronItem: item,
          prijsregels: resultaat.prijsregels,
          bewaardePrijsregels: bewaardeRegels,
          toepassenOpAlleGelijkePosities: false,
        );
        break;
      case OffertePrijsregelsVensterActie.toepassenOpAlleGelijkePosities:
        await _pasTijdelijkeVrijePrijsregelsToe(
          bronItem: item,
          prijsregels: resultaat.prijsregels,
          bewaardePrijsregels: bewaardeRegels,
          toepassenOpAlleGelijkePosities: true,
        );
        break;
      case OffertePrijsregelsVensterActie.bewarenInInstellingen:
        await _bewaarVrijePrijsregelsInInstellingen(
          bronItem: item,
          prijsregels: resultaat.prijsregels,
        );
        break;
      case OffertePrijsregelsVensterActie.toevoegenNietBewaren:
      case OffertePrijsregelsVensterActie.toevoegenEnBewaren:
        break;
    }
  }

  Future<void> _pasTijdelijkeVrijePrijsregelsToe({
    required OpmetingOverzichtRaamItem bronItem,
    required List<OffertePrijsregelModel> prijsregels,
    required List<OffertePrijsregelModel> bewaardePrijsregels,
    required bool toepassenOpAlleGelijkePosities,
    bool toonMelding = true,
  }) async {
    final bronKoppeling =
        OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(bronItem);
    if (bronKoppeling == null) return;

    final formulierType = bronKoppeling.formulierType;
    final regels =
        OffertePrijsregelBeheerService.maakTijdelijkePrijsregelVerschillen(
          prijsregels: prijsregels,
          bewaardePrijsregels: bewaardePrijsregels,
          categorie: OffertePrijsCategorie.vrijPerArtikel,
          formulierType: formulierType,
        );

    bool isGeldigDoel(OpmetingOverzichtRaamItem positie) {
      if (positie.isVerwijderd) return false;
      return OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(
            positie,
          )?.adapterId ==
          bronKoppeling.adapterId;
    }

    final artikelen = leesArtikelen();
    final doelIds = toepassenOpAlleGelijkePosities
        ? artikelen.where(isGeldigDoel).map((positie) => positie.id).toSet()
        : <String>{bronItem.id};

    final nieuweLijst = List<OpmetingOverzichtRaamItem>.from(artikelen);
    final gewijzigdeItems = <OpmetingOverzichtRaamItem>[];

    for (var index = 0; index < nieuweLijst.length; index++) {
      final huidig = nieuweLijst[index];
      if (!doelIds.contains(huidig.id) || !isGeldigDoel(huidig)) continue;

      final huidigePrijsData =
          OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(huidig);
      if (huidigePrijsData == null) continue;

      final bijgewerktePrijsData =
          OfferteAlgemeenArtikelPrijsService.metTijdelijkeVrijeArtikelPrijsregels(
            prijsData: huidigePrijsData,
            prijsregels: regels,
          );
      final bijgewerkt = OfferteArtikelPrijsKoppelingService.schrijfPrijsData(
        artikel: huidig,
        prijsData: bijgewerktePrijsData,
      ).metNieuweWijzigingsDatum();

      nieuweLijst[index] = bijgewerkt;
      gewijzigdeItems.add(bijgewerkt);
    }

    if (gewijzigdeItems.isEmpty) return;

    if (isMounted()) {
      vervangArtikelen(nieuweLijst);
    }

    for (final bijgewerkt in gewijzigdeItems) {
      await AppStorage.werkOpmetingBij(bijgewerkt);
    }
    await OneDriveSyncService.registreerLokaleWijziging();
    OneDriveSyncService().uploadBackupOpAchtergrond();

    await herberekenPrijsMomentopnames(bronItem.klantNaam);

    if (toonMelding && isMounted()) {
      _toonMelding(
        toepassenOpAlleGelijkePosities
            ? 'Vrije prijsregels toegepast op alle ${_formulierNaamVoorPrijsType(formulierType).toLowerCase()}-posities.'
            : 'Vrije prijsregels toegepast op deze positie.',
      );
    }
  }

  Future<void> _bewaarVrijePrijsregelsInInstellingen({
    required OpmetingOverzichtRaamItem bronItem,
    required List<OffertePrijsregelModel> prijsregels,
  }) async {
    final koppeling = OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(
      bronItem,
    );
    if (koppeling == null) return;

    final formulierType = koppeling.formulierType;
    var profiel = await laadPrijsprofiel(formulierType);
    profiel = OffertePrijsregelBeheerService.vervangPrijsregelsVoorCategorie(
      profiel: profiel,
      categorie: OffertePrijsCategorie.vrijPerArtikel,
      formulierType: formulierType,
      prijsregels: prijsregels,
    );
    await AppStorage.bewaarOffertePrijsProfiel(profiel);

    final momentopname = maakPrijsinstellingenMomentopname(profiel);
    final nieuwTitelhoofd = leesTitelhoofd()
        .metPrijsinstellingenMomentopname(momentopname)
        .metWijzigingsDatum();
    await AppStorage.bewaarOpmetingProjectTitelhoofd(nieuwTitelhoofd);
    if (isMounted()) {
      vervangTitelhoofd(nieuwTitelhoofd);
    }

    final bewaardeRegels =
        OffertePrijsregelBeheerService.bewaardePrijsregelsVoorCategorie(
          profiel: profiel,
          categorie: OffertePrijsCategorie.vrijPerArtikel,
          formulierType: formulierType,
        );
    await _pasTijdelijkeVrijePrijsregelsToe(
      bronItem: bronItem,
      prijsregels: bewaardeRegels,
      bewaardePrijsregels: bewaardeRegels,
      toepassenOpAlleGelijkePosities: true,
      toonMelding: false,
    );

    if (isMounted()) {
      _toonMelding(
        'Vrije prijsregels bewaard in Instellingen → Offerteprijzen → ${_formulierNaamVoorPrijsType(formulierType)}.',
      );
    }
  }

  bool get heeftBeschikbarePrijsregelBronGroepen {
    return _beschikbarePrijsregelBronGroepen().isNotEmpty;
  }

  List<OfferteArtikelPrijsKoppeling> _beschikbarePrijsregelBronGroepen() {
    final artikelen = leesArtikelen();
    final resultaat = <OfferteArtikelPrijsKoppeling>[];

    for (final groep in OfferteArtikelPrijsKoppelingService.alleKoppelingen) {
      final aanwezig = artikelen.any((artikel) {
        if (artikel.isVerwijderd) return false;
        return OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(
              artikel,
            )?.adapterId ==
            groep.adapterId;
      });
      if (aanwezig) {
        resultaat.add(groep);
      }
    }

    return List<OfferteArtikelPrijsKoppeling>.unmodifiable(resultaat);
  }

  String _normaliseerPrijsregelOmschrijving(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _projectPrijsregelInhoudSleutel(OffertePrijsregelModel regel) {
    final inhoud = Map<String, dynamic>.from(regel.toJson())
      ..remove('id')
      ..remove('formulierType')
      ..remove('volgorde')
      ..remove('gewijzigdOp');

    inhoud['omschrijving'] = _normaliseerPrijsregelOmschrijving(
      regel.omschrijving,
    );

    return jsonEncode(inhoud);
  }

  String _projectPrijsregelGroepSleutel(OffertePrijsregelModel regel) {
    if (regel.isVerdeeldeProjectkost) {
      final verdeelSleutel =
          OfferteVerdeelkostService.gekoppeldeVerdeelkostSleutel(regel);
      if (verdeelSleutel.isNotEmpty) {
        return 'verdeelkost::$verdeelSleutel';
      }
    }

    // Een algemene prijsregel kan in meerdere artikelprofielen met een ander
    // technisch ID opgeslagen zijn. Voor het projectvenster is het echter één
    // regel wanneer omschrijving, bedrag, eenheid en overige prijsinstellingen
    // gelijk zijn. ID, formulierType, volgorde en wijzigingsdatum bepalen enkel
    // waar de regel bewaard is en mogen dus geen dubbele zichtbare rij maken.
    return 'prijsregel-inhoud::${_projectPrijsregelInhoudSleutel(regel)}';
  }

  Map<String, List<OffertePrijsregelModel>>
  _maakGekoppeldeProjectPrijsregelBronnenPerRegelId(
    List<OffertePrijsregelModel> prijsregels,
  ) {
    final perSleutel = <String, List<OffertePrijsregelModel>>{};

    for (final regel in prijsregels) {
      final sleutel = _projectPrijsregelGroepSleutel(regel);
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

      if (regel.gewijzigdOp.compareTo(bestaand.gewijzigdOp) > 0) {
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
    required List<OfferteArtikelPrijsKoppeling> bronGroepen,
    required Map<String, List<OffertePrijsregelModel>>
    gekoppeldeBronnenPerRegelId,
  }) {
    final resultaat = <OffertePrijsregelModel>[];
    final bronGroepPerSleutel = <String, OfferteArtikelPrijsKoppeling>{
      for (final bronGroep in bronGroepen)
        _normaliseerPrijsFormulierType(bronGroep.formulierType): bronGroep,
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
        final sleutel = _normaliseerPrijsFormulierType(formulierType);
        final bronGroep = bronGroepPerSleutel[sleutel];

        if (bronGroep == null || !toegevoegdeSleutels.add(sleutel)) {
          continue;
        }

        OffertePrijsregelModel? bestaandeBronRegel;
        for (final bron in gekoppeldeBronnen) {
          if (_normaliseerPrijsFormulierType(bron.formulierType) == sleutel) {
            bestaandeBronRegel = bron;
            break;
          }
        }

        resultaat.add(
          regel.copyWith(
            id: bestaandeBronRegel?.id ?? regel.id,
            categorie: OffertePrijsCategorie.alleArtikelen,
            formulierType: bronGroep.formulierType,
            volgorde: bestaandeBronRegel?.volgorde ?? regel.volgorde,
          ),
        );
      }
    }

    return List<OffertePrijsregelModel>.unmodifiable(resultaat);
  }

  Future<void> openPrijsVoorAlleArtikelenVenster() async {
    if (!isMounted()) return;

    final bronGroepen = _beschikbarePrijsregelBronGroepen();
    if (bronGroepen.isEmpty) return;

    final beginRegels = <OffertePrijsregelModel>[];
    for (final bronGroep in bronGroepen) {
      final formulierType = bronGroep.formulierType;
      final profiel = await laadPrijsprofiel(formulierType);
      if (!isMounted()) return;

      final bewaardeRegels =
          OffertePrijsregelBeheerService.bewaardePrijsregelsVoorCategorie(
            profiel: profiel,
            categorie: OffertePrijsCategorie.alleArtikelen,
            formulierType: formulierType,
          );
      final gecombineerdeRegels =
          OffertePrijsregelBeheerService.combineerBewaardeEnTijdelijkePrijsregels(
            bewaardePrijsregels: bewaardeRegels,
            tijdelijkePrijsregels:
                leesTitelhoofd().tijdelijkeProjectPrijsregels,
            categorie: OffertePrijsCategorie.alleArtikelen,
            formulierType: formulierType,
          );
      beginRegels.addAll(gecombineerdeRegels);
    }

    final gekoppeldeBronnenPerRegelId =
        _maakGekoppeldeProjectPrijsregelBronnenPerRegelId(beginRegels);
    final huidigeRegels = _combineerProjectPrijsregelsVoorVenster(beginRegels);
    final formulierTypeSelectiesPerPrijsregelId =
        _maakFormulierTypeSelectiesPerPrijsregelId(
          allePrijsregels: beginRegels,
          zichtbarePrijsregels: huidigeRegels,
        );
    final formulierTypeLabels = <String, String>{
      for (final bronGroep in bronGroepen)
        bronGroep.formulierType: bronGroep.formulierNaam,
    };

    if (!context.mounted) return;

    final resultaat = await toonOffertePrijsregelsZwevendVenster(
      context: context,
      titel: 'Prijsregel toepassen op…',
      subtitel:
          'Beheer tijdelijke projectprijsregels en algemene offerteprijzen',
      formulierType: bronGroepen.first.formulierType,
      categorie: OffertePrijsCategorie.alleArtikelen,
      beginPrijsregels: huidigeRegels,
      toonProjectActies: true,
      behoudFormulierTypePerRegel: true,
      formulierTypeLabels: formulierTypeLabels,
      beginFormulierTypesPerPrijsregelId: formulierTypeSelectiesPerPrijsregelId,
      toonFormulierTypeBijRegel: true,
    );

    if (resultaat == null || !isMounted()) return;

    switch (resultaat.actie) {
      case OffertePrijsregelsVensterActie.toevoegenNietBewaren:
        await _verwerkProjectPrijsregels(
          prijsregels: resultaat.prijsregels,
          formulierTypesPerPrijsregelId:
              resultaat.formulierTypesPerPrijsregelId,
          bronGroepen: bronGroepen,
          gekoppeldeBronnenPerRegelId: gekoppeldeBronnenPerRegelId,
          toevoegenAanProject: true,
          bewarenInInstellingen: false,
        );
        break;
      case OffertePrijsregelsVensterActie.toevoegenEnBewaren:
        await _verwerkProjectPrijsregels(
          prijsregels: resultaat.prijsregels,
          formulierTypesPerPrijsregelId:
              resultaat.formulierTypesPerPrijsregelId,
          bronGroepen: bronGroepen,
          gekoppeldeBronnenPerRegelId: gekoppeldeBronnenPerRegelId,
          toevoegenAanProject: true,
          bewarenInInstellingen: true,
        );
        break;
      case OffertePrijsregelsVensterActie.bewarenInInstellingen:
        await _verwerkProjectPrijsregels(
          prijsregels: resultaat.prijsregels,
          formulierTypesPerPrijsregelId:
              resultaat.formulierTypesPerPrijsregelId,
          bronGroepen: bronGroepen,
          gekoppeldeBronnenPerRegelId: gekoppeldeBronnenPerRegelId,
          toevoegenAanProject: false,
          bewarenInInstellingen: true,
        );
        break;
      case OffertePrijsregelsVensterActie.toepassenOpDezePositie:
      case OffertePrijsregelsVensterActie.toepassenOpAlleGelijkePosities:
        break;
    }
  }

  Future<void> _verwerkProjectPrijsregels({
    required List<OffertePrijsregelModel> prijsregels,
    required Map<String, Set<String>> formulierTypesPerPrijsregelId,
    required List<OfferteArtikelPrijsKoppeling> bronGroepen,
    required Map<String, List<OffertePrijsregelModel>>
    gekoppeldeBronnenPerRegelId,
    required bool toevoegenAanProject,
    required bool bewarenInInstellingen,
  }) async {
    if (!toevoegenAanProject && !bewarenInInstellingen) return;

    final prijsregelsVoorOpslag = _breidProjectPrijsregelsUitVoorFormulierTypes(
      prijsregels: prijsregels,
      formulierTypesPerPrijsregelId: formulierTypesPerPrijsregelId,
      bronGroepen: bronGroepen,
      gekoppeldeBronnenPerRegelId: gekoppeldeBronnenPerRegelId,
    );
    final betrokkenFormulierTypes = bronGroepen
        .map((groep) => _normaliseerPrijsFormulierType(groep.formulierType))
        .toSet();
    final profielenPerFormulierType = <String, OffertePrijsprofielModel>{};

    Future<OffertePrijsprofielModel> laadProfiel(
      OfferteArtikelPrijsKoppeling bronGroep,
    ) async {
      final sleutel = _normaliseerPrijsFormulierType(bronGroep.formulierType);
      final bestaand = profielenPerFormulierType[sleutel];
      if (bestaand != null) return bestaand;

      final profiel = await laadPrijsprofiel(bronGroep.formulierType);
      profielenPerFormulierType[sleutel] = profiel;
      return profiel;
    }

    List<OffertePrijsregelModel> regelsVoor(
      OfferteArtikelPrijsKoppeling bronGroep,
    ) {
      final formulierSleutel = _normaliseerPrijsFormulierType(
        bronGroep.formulierType,
      );
      return prijsregelsVoorOpslag
          .where((regel) {
            return regel.categorie == OffertePrijsCategorie.alleArtikelen &&
                _normaliseerPrijsFormulierType(regel.formulierType) ==
                    formulierSleutel;
          })
          .toList(growable: false);
    }

    var nieuwTitelhoofd = leesTitelhoofd();

    if (toevoegenAanProject) {
      final overigeTijdelijkeRegels = nieuwTitelhoofd
          .tijdelijkeProjectPrijsregels
          .where((regel) {
            return regel.categorie != OffertePrijsCategorie.alleArtikelen ||
                !betrokkenFormulierTypes.contains(
                  _normaliseerPrijsFormulierType(regel.formulierType),
                );
          })
          .toList(growable: true);
      final tijdelijkeVerschillen = <OffertePrijsregelModel>[];

      for (final bronGroep in bronGroepen) {
        final formulierType = bronGroep.formulierType;
        final profiel = await laadProfiel(bronGroep);
        final bewaardeRegels =
            OffertePrijsregelBeheerService.bewaardePrijsregelsVoorCategorie(
              profiel: profiel,
              categorie: OffertePrijsCategorie.alleArtikelen,
              formulierType: formulierType,
            );
        tijdelijkeVerschillen.addAll(
          OffertePrijsregelBeheerService.maakTijdelijkePrijsregelVerschillen(
            prijsregels: regelsVoor(bronGroep),
            bewaardePrijsregels: bewaardeRegels,
            categorie: OffertePrijsCategorie.alleArtikelen,
            formulierType: formulierType,
          ),
        );
      }

      nieuwTitelhoofd = nieuwTitelhoofd.copyWith(
        tijdelijkeProjectPrijsregels: <OffertePrijsregelModel>[
          ...overigeTijdelijkeRegels,
          ...tijdelijkeVerschillen,
        ],
      );
    }

    if (bewarenInInstellingen) {
      for (final bronGroep in bronGroepen) {
        final formulierType = bronGroep.formulierType;
        var profiel = await laadProfiel(bronGroep);
        profiel =
            OffertePrijsregelBeheerService.vervangPrijsregelsVoorCategorie(
              profiel: profiel,
              categorie: OffertePrijsCategorie.alleArtikelen,
              formulierType: formulierType,
              prijsregels: regelsVoor(bronGroep),
            );
        await AppStorage.bewaarOffertePrijsProfiel(profiel);
        nieuwTitelhoofd = nieuwTitelhoofd.metPrijsinstellingenMomentopname(
          maakPrijsinstellingenMomentopname(profiel),
        );
      }
    }

    nieuwTitelhoofd = nieuwTitelhoofd.metWijzigingsDatum();
    await AppStorage.bewaarOpmetingProjectTitelhoofd(nieuwTitelhoofd);
    await OneDriveSyncService.registreerLokaleWijziging();
    OneDriveSyncService().uploadBackupOpAchtergrond();

    if (!isMounted()) return;
    vervangTitelhoofd(nieuwTitelhoofd);
    await herberekenPrijsMomentopnames(leesKlantNaam());

    if (!isMounted()) return;
    if (toevoegenAanProject && bewarenInInstellingen) {
      _toonMelding(
        'Prijsregels toegevoegd aan deze offerte en bewaard in '
        'Instellingen → Offerteprijzen.',
      );
    } else if (toevoegenAanProject) {
      _toonMelding(
        'Prijsregels toegevoegd aan deze offerte zonder ze in '
        'Instellingen te bewaren.',
      );
    } else {
      _toonMelding(
        'Prijsregels bewaard in Instellingen → Offerteprijzen bij de '
        'juiste artikelgroepen.',
      );
    }
  }
}
