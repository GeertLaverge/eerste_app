// THIMACO-CONTROLE: GEKOPPELDE-VERDEELKOST-MENU-20260724
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
import 'offerte_prijsregel_toepassen_op_dialog.dart';
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

  String _artikelKeuzeOmschrijving(OpmetingOverzichtRaamItem artikel) {
    final aantal = OfferteArtikelPrijsKoppelingService.aantalVoorArtikel(
      artikel,
    );
    final breedte = OfferteArtikelPrijsKoppelingService.breedteMmVoorArtikel(
      artikel,
    );
    final hoogte = OfferteArtikelPrijsKoppelingService.hoogteMmVoorArtikel(
      artikel,
    );
    final maat = '$breedte × $hoogte mm';
    if (aantal > 1) {
      return '$aantal stuks · $maat';
    }
    return maat;
  }

  String _prijsregelArtikelLabel(OpmetingOverzichtRaamItem artikel) {
    final basis = _artikelKeuzeOmschrijving(artikel);
    return artikel.isOfferteOptie ? 'Optie · $basis' : basis;
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
      case OffertePrijsregelsVensterActie.toepassenOpOfferte:
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

  List<OffertePrijsregelModel> _combineerGekoppeldeVerdeelkostenVoorVenster(
    List<OffertePrijsregelModel> prijsregels,
  ) {
    final nieuwstePerSleutel = <String, OffertePrijsregelModel>{};
    for (final regel in prijsregels) {
      final sleutel = OfferteVerdeelkostService.gekoppeldeVerdeelkostSleutel(
        regel,
      );
      if (sleutel.isEmpty) continue;
      final bestaand = nieuwstePerSleutel[sleutel];
      if (bestaand == null ||
          regel.gewijzigdOp.compareTo(bestaand.gewijzigdOp) > 0) {
        nieuwstePerSleutel[sleutel] = regel;
      }
    }

    final resultaat = <OffertePrijsregelModel>[];
    final gezieneSleutels = <String>{};
    for (final regel in prijsregels) {
      final sleutel = OfferteVerdeelkostService.gekoppeldeVerdeelkostSleutel(
        regel,
      );
      if (sleutel.isEmpty) {
        resultaat.add(regel);
      } else if (gezieneSleutels.add(sleutel)) {
        resultaat.add(nieuwstePerSleutel[sleutel] ?? regel);
      }
    }
    return List<OffertePrijsregelModel>.unmodifiable(resultaat);
  }

  List<OffertePrijsregelModel> _breidGekoppeldeVerdeelkostenUitVoorBewaren({
    required List<OffertePrijsregelModel> prijsregels,
    required Map<String, List<OffertePrijsregelModel>>
    gekoppeldeBronnenPerRegelId,
  }) {
    final resultaat = <OffertePrijsregelModel>[];
    for (final regel in prijsregels) {
      if (!regel.isVerdeeldeProjectkost) {
        resultaat.add(regel);
        continue;
      }

      final gekoppeldeBronnen = gekoppeldeBronnenPerRegelId[regel.id];
      if (gekoppeldeBronnen == null || gekoppeldeBronnen.isEmpty) {
        resultaat.add(regel);
        continue;
      }

      for (final bron in gekoppeldeBronnen) {
        resultaat.add(
          regel.copyWith(
            id: bron.id,
            categorie: OffertePrijsCategorie.alleArtikelen,
            formulierType: bron.formulierType,
            volgorde: bron.volgorde,
          ),
        );
      }
    }
    return resultaat;
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
        _maakGekoppeldeVerdeelkostBronnenPerRegelId(beginRegels);
    var huidigeRegels = _combineerGekoppeldeVerdeelkostenVoorVenster(
      beginRegels,
    );
    final formulierTypeLabels = <String, String>{
      for (final bronGroep in bronGroepen)
        bronGroep.formulierType: bronGroep.formulierNaam,
    };

    while (isMounted()) {
      final resultaat = await toonOffertePrijsregelsZwevendVenster(
        context: context,
        titel: 'Prijsregel toepassen op…',
        subtitel:
            'Kies één prijsregel en koppel die daarna één keer aan de gewenste posities',
        formulierType: bronGroepen.first.formulierType,
        categorie: OffertePrijsCategorie.alleArtikelen,
        beginPrijsregels: huidigeRegels,
        toonToepassenOpOfferte: true,
        behoudFormulierTypePerRegel: true,
        formulierTypeLabels: formulierTypeLabels,
        toonFormulierTypeBijRegel: true,
      );

      if (resultaat == null || !isMounted()) return;
      huidigeRegels = resultaat.prijsregels;

      switch (resultaat.actie) {
        case OffertePrijsregelsVensterActie.toepassenOpOfferte:
          final gekozenPrijsregel = resultaat.gekozenPrijsregel;
          if (gekozenPrijsregel == null) {
            _toonMelding('Kies eerst één actieve prijsregel.', fout: true);
            continue;
          }

          final selectie = await _openPrijsregelArtikelSelectie(
            prijsregel: gekozenPrijsregel,
          );
          if (selectie == null || !isMounted()) return;

          await _pasPrijsregelToeOpGeselecteerdePosities(
            prijsregel: gekozenPrijsregel,
            artikelIds: selectie.artikelIds,
          );
          if (!isMounted() || !selectie.kiesNogEenPrijsregel) {
            return;
          }
          break;
        case OffertePrijsregelsVensterActie.bewarenInInstellingen:
          await _bewaarProjectPrijsregelsVoorAlleFormulierTypes(
            resultaat.prijsregels,
            bronGroepen: bronGroepen,
            gekoppeldeBronnenPerRegelId: gekoppeldeBronnenPerRegelId,
          );
          return;
        case OffertePrijsregelsVensterActie.toepassenOpDezePositie:
        case OffertePrijsregelsVensterActie.toepassenOpAlleGelijkePosities:
          return;
      }
    }
  }

  Future<OffertePrijsregelToepassenOpResultaat?>
  _openPrijsregelArtikelSelectie({
    required OffertePrijsregelModel prijsregel,
  }) async {
    final artikelen = leesArtikelen();
    final positieLabelPerId = offerteController.positiesService
        .maakBronPositieLabels(artikelen);
    final geordendeItems = offerteController.positiesService
        .groepeerBronPositiesVoorOverzicht(artikelen);

    final keuzes = geordendeItems
        .where((artikel) => !artikel.isVerwijderd && !artikel.isNietRekenen)
        .map((artikel) {
          final koppeling =
              OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(artikel);
          final prijsData =
              OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(artikel);
          final optieNietBeschikbaar =
              prijsregel.isVerdeeldeProjectkost &&
              !artikel.teltMeeInHoofdofferte;
          final beschikbaar =
              !artikel.isNietRekenen &&
              koppeling != null &&
              prijsData != null &&
              !optieNietBeschikbaar;
          final aantalArtikelen =
              OfferteArtikelPrijsKoppelingService.aantalVoorArtikel(artikel);
          final bedrag = beschikbaar
              ? OfferteAlgemeenArtikelPrijsService.berekenPrijsregelTotaalExclBtw(
                  prijsregel: prijsregel,
                  aantal: aantalArtikelen,
                  breedteMm:
                      OfferteArtikelPrijsKoppelingService.breedteMmVoorArtikel(
                        artikel,
                      ),
                  hoogteMm:
                      OfferteArtikelPrijsKoppelingService.hoogteMmVoorArtikel(
                        artikel,
                      ),
                )
              : 0.0;

          return OffertePrijsregelToepassenOpKeuze(
            artikelId: artikel.id,
            positieLabel: positieLabelPerId[artikel.id] ?? 'Positie',
            artikelLabel: _prijsregelArtikelLabel(artikel),
            groepId:
                koppeling?.adapterId ?? artikel.formulierTypeGenormaliseerd,
            groepLabel: koppeling?.formulierNaam ?? artikel.formulierTypeLabel,
            bedragExclBtw: bedrag,
            aantalArtikelen: aantalArtikelen,
            beschikbaar: beschikbaar,
            nietBeschikbaarReden: optieNietBeschikbaar
                ? 'Optieposities worden niet opgenomen in een interne verdeelkost.'
                : 'Dit artikeltype ondersteunt de gezamenlijke prijsopslag nog niet.',
          );
        })
        .toList(growable: false);

    return toonOffertePrijsregelToepassenOpDialog(
      context: context,
      prijsregelOmschrijving:
          '${prijsregel.omschrijving} · € ${prijsregel.prijsExclBtw.toStringAsFixed(2).replaceAll('.', ',')} excl. btw',
      keuzes: keuzes,
      verdeelProjectTotaalExclBtw: prijsregel.isVerdeeldeProjectkost
          ? prijsregel.prijsExclBtw
          : null,
    );
  }

  Future<void> _pasPrijsregelToeOpGeselecteerdePosities({
    required OffertePrijsregelModel prijsregel,
    required Set<String> artikelIds,
  }) async {
    if (artikelIds.isEmpty) return;

    if (prijsregel.isVerdeeldeProjectkost) {
      await _pasGeselecteerdeVerdeelkostToe(
        prijsregel: prijsregel,
        artikelIds: artikelIds,
      );
      return;
    }

    final nieuweLijst = List<OpmetingOverzichtRaamItem>.from(leesArtikelen());
    final gewijzigdeItems = <OpmetingOverzichtRaamItem>[];

    for (var index = 0; index < nieuweLijst.length; index++) {
      final huidig = nieuweLijst[index];

      if (huidig.isVerwijderd ||
          huidig.isNietRekenen ||
          !artikelIds.contains(huidig.id)) {
        continue;
      }
      final doelKoppeling =
          OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(huidig);
      final huidigePrijsData =
          OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(huidig);
      if (doelKoppeling == null || huidigePrijsData == null) continue;

      final bijgewerktePrijsData =
          OfferteAlgemeenArtikelPrijsService.voegGekozenProjectPrijsregelToe(
            prijsData: huidigePrijsData,
            prijsregel: prijsregel,
            doelFormulierType: doelKoppeling.formulierType,
          );
      final bijgewerkt = OfferteArtikelPrijsKoppelingService.schrijfPrijsData(
        artikel: huidig,
        prijsData: bijgewerktePrijsData,
      ).metNieuweWijzigingsDatum();

      nieuweLijst[index] = bijgewerkt;
      gewijzigdeItems.add(bijgewerkt);
    }

    if (gewijzigdeItems.isEmpty) {
      if (isMounted()) {
        _toonMelding(
          'De prijsregel kon niet op de gekozen posities worden toegepast.',
          fout: true,
        );
      }
      return;
    }

    if (isMounted()) {
      vervangArtikelen(nieuweLijst);
    }

    for (final bijgewerkt in gewijzigdeItems) {
      await AppStorage.werkOpmetingBij(bijgewerkt);
    }
    await OneDriveSyncService.registreerLokaleWijziging();
    OneDriveSyncService().uploadBackupOpAchtergrond();

    await herberekenPrijsMomentopnames(gewijzigdeItems.first.klantNaam);

    if (isMounted()) {
      final aantal = gewijzigdeItems.length;
      _toonMelding(
        'Prijsregel “${prijsregel.omschrijving}” toegepast op '
        '${aantal == 1 ? '1 positie' : '$aantal posities'}.',
      );
    }
  }

  Future<void> _pasGeselecteerdeVerdeelkostToe({
    required OffertePrijsregelModel prijsregel,
    required Set<String> artikelIds,
  }) async {
    final huidigeLijst = List<OpmetingOverzichtRaamItem>.from(leesArtikelen());
    final resultaat =
        OfferteVerdeelkostService.stelGeselecteerdeProjectVerdeelkostDoelenIn(
          alleOpmetingen: huidigeLijst,
          klantNaam: leesKlantNaam(),
          prijsregel: prijsregel,
          artikelIds: artikelIds,
        );

    if (!resultaat.gewijzigd) {
      if (isMounted()) {
        _toonMelding(
          'De verdeelkost kon niet aan de gekozen posities worden gekoppeld.',
          fout: true,
        );
      }
      return;
    }

    if (isMounted()) {
      vervangArtikelen(resultaat.opmetingen);
    }

    // De doelmarkeringen worden in de bestaande vrije-prijsopslag bewaard.
    // De herberekening zet ze daarna om naar één correct verdeeld projectbedrag.
    final oudeWijzigingsdatums = <String, String>{
      for (final artikel in huidigeLijst) artikel.id: artikel.gewijzigdOp,
    };
    for (final artikel in resultaat.opmetingen) {
      if (oudeWijzigingsdatums[artikel.id] == artikel.gewijzigdOp) continue;
      await AppStorage.werkOpmetingBij(artikel);
    }
    await OneDriveSyncService.registreerLokaleWijziging();
    OneDriveSyncService().uploadBackupOpAchtergrond();

    await herberekenPrijsMomentopnames(leesKlantNaam());

    if (isMounted()) {
      final aantal = artikelIds.length;
      _toonMelding(
        'Verdeelkost “${prijsregel.omschrijving}” verdeeld over '
        '${aantal == 1 ? '1 positie' : '$aantal posities'}.',
      );
    }
  }

  Future<void> _bewaarProjectPrijsregelsVoorAlleFormulierTypes(
    List<OffertePrijsregelModel> prijsregels, {
    required List<OfferteArtikelPrijsKoppeling> bronGroepen,
    required Map<String, List<OffertePrijsregelModel>>
    gekoppeldeBronnenPerRegelId,
  }) async {
    final prijsregelsVoorOpslag = _breidGekoppeldeVerdeelkostenUitVoorBewaren(
      prijsregels: prijsregels,
      gekoppeldeBronnenPerRegelId: gekoppeldeBronnenPerRegelId,
    );
    final betrokkenFormulierTypes = bronGroepen
        .map((groep) => _normaliseerPrijsFormulierType(groep.formulierType))
        .toSet();
    final overigeTijdelijkeRegels = leesTitelhoofd()
        .tijdelijkeProjectPrijsregels
        .where((regel) {
          return regel.categorie != OffertePrijsCategorie.alleArtikelen ||
              !betrokkenFormulierTypes.contains(
                _normaliseerPrijsFormulierType(regel.formulierType),
              );
        })
        .toList(growable: false);

    var nieuwTitelhoofd = leesTitelhoofd().copyWith(
      tijdelijkeProjectPrijsregels: overigeTijdelijkeRegels,
    );

    for (final bronGroep in bronGroepen) {
      final formulierType = bronGroep.formulierType;
      final formulierSleutel = _normaliseerPrijsFormulierType(formulierType);
      final regelsVoorFormulierType = prijsregelsVoorOpslag
          .where((regel) {
            return regel.categorie == OffertePrijsCategorie.alleArtikelen &&
                _normaliseerPrijsFormulierType(regel.formulierType) ==
                    formulierSleutel;
          })
          .toList(growable: false);

      var profiel = await laadPrijsprofiel(formulierType);
      profiel = OffertePrijsregelBeheerService.vervangPrijsregelsVoorCategorie(
        profiel: profiel,
        categorie: OffertePrijsCategorie.alleArtikelen,
        formulierType: formulierType,
        prijsregels: regelsVoorFormulierType,
      );
      await AppStorage.bewaarOffertePrijsProfiel(profiel);
      nieuwTitelhoofd = nieuwTitelhoofd.metPrijsinstellingenMomentopname(
        maakPrijsinstellingenMomentopname(profiel),
      );
    }

    nieuwTitelhoofd = nieuwTitelhoofd.metWijzigingsDatum();
    await AppStorage.bewaarOpmetingProjectTitelhoofd(nieuwTitelhoofd);
    await OneDriveSyncService.registreerLokaleWijziging();
    OneDriveSyncService().uploadBackupOpAchtergrond();

    if (!isMounted()) return;
    vervangTitelhoofd(nieuwTitelhoofd);
    await herberekenPrijsMomentopnames(leesKlantNaam());
    if (isMounted()) {
      _toonMelding(
        'Prijsregels bewaard in Instellingen → Offerteprijzen bij de juiste artikelgroepen.',
      );
    }
  }
}
