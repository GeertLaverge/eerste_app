import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_storage.dart';
import '../../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../../sync/onedrive_sync_service.dart';
import '../offerte_controller.dart';
import 'offerte_artikel_prijs_koppeling_service.dart';
import 'offerte_artikel_prijs_mutatie_service.dart';
import 'offerte_artikel_toepassen_op_dialog.dart';

class OfferteArtikelPrijscorrectieController {
  OfferteArtikelPrijscorrectieController({
    required this.context,
    required this.offerteController,
    required this.isMounted,
    required this.leesArtikelen,
    required this.vervangArtikelen,
    required this.herberekenPrijsMomentopnames,
    required this.onDoelSelectieGewijzigd,
  });

  final BuildContext context;
  final OfferteController offerteController;
  final bool Function() isMounted;
  final List<OpmetingOverzichtRaamItem> Function() leesArtikelen;
  final void Function(List<OpmetingOverzichtRaamItem> artikelen)
  vervangArtikelen;
  final Future<void> Function(String klantNaam) herberekenPrijsMomentopnames;
  final VoidCallback onDoelSelectieGewijzigd;

  final Set<String> _winstmargeDoelArtikelIds = <String>{};
  final Set<String> _kortingDoelArtikelIds = <String>{};

  Timer? _prijsHerberekenTimer;

  void dispose() {
    _prijsHerberekenTimer?.cancel();
  }

  void wisDoelSelecties() {
    _winstmargeDoelArtikelIds.clear();
    _kortingDoelArtikelIds.clear();
  }

  Future<void> wijzigArtikelPrijs(
    OpmetingOverzichtRaamItem item,
    double prijsPerStukExclBtw,
  ) async {
    final adapter = OfferteArtikelPrijsMutatieService.adapterVoor(item);
    if (adapter == null) {
      return;
    }

    final resultaat = OfferteArtikelPrijsMutatieService.wijzigPrijsPerStuk(
      artikelen: leesArtikelen(),
      artikel: item,
      prijsPerStukExclBtw: prijsPerStukExclBtw,
      adapter: adapter,
    );
    if (!resultaat.isGewijzigd) {
      return;
    }

    if (resultaat.lijstGewijzigd && isMounted()) {
      vervangArtikelen(resultaat.artikelen);
    }

    for (final bijgewerkt in resultaat.gewijzigdeArtikelen) {
      await AppStorage.werkOpmetingBij(bijgewerkt);
    }

    await OneDriveSyncService.registreerLokaleWijziging();

    // Iedere wijziging aan een artikelprijs kan de aankooplimiet beïnvloeden.
    // Daarom herberekenen we voor ieder ondersteund artikeltype.
    final bijgewerkt = resultaat.gewijzigdeArtikelen.first;

    _prijsHerberekenTimer?.cancel();
    _prijsHerberekenTimer = Timer(const Duration(milliseconds: 450), () {
      unawaited(herberekenPrijsMomentopnames(bijgewerkt.klantNaam));
    });

    // De ingegeven artikelprijs moet ook naar OneDrive worden doorgestuurd,
    // zelfs wanneer de limietcontrole geen verdeelde prijsregels wijzigt.
    OneDriveSyncService().uploadBackupOpAchtergrond();
  }

  Future<void> wijzigArtikelKorting(
    OpmetingOverzichtRaamItem item,
    double kortingPercentage,
  ) {
    return _wijzigArtikelPrijsCorrectie(
      item: item,
      kortingPercentage: kortingPercentage,
      doelArtikelIds: _prijsCorrectieDoelIdsVoorArtikel(
        artikel: item,
        isKorting: true,
      ),
    );
  }

  Future<void> wijzigArtikelWinstmarge(
    OpmetingOverzichtRaamItem item,
    double winstmargePercentage,
  ) {
    return _wijzigArtikelPrijsCorrectie(
      item: item,
      winstmargePercentage: winstmargePercentage,
      doelArtikelIds: _prijsCorrectieDoelIdsVoorArtikel(
        artikel: item,
        isKorting: false,
      ),
    );
  }

  String prijsCorrectieDoelSamenvatting({
    required OpmetingOverzichtRaamItem artikel,
    required bool isKorting,
  }) {
    final geselecteerdeIds = _prijsCorrectieDoelIdsVoorArtikel(
      artikel: artikel,
      isKorting: isKorting,
    );
    final beschikbareIds = _beschikbarePrijsCorrectieDoelIds(
      isKorting: isKorting,
    );

    if (geselecteerdeIds.length == 1 && geselecteerdeIds.contains(artikel.id)) {
      return 'Huidig artikel';
    }

    if (beschikbareIds.isNotEmpty &&
        geselecteerdeIds.length == beschikbareIds.length &&
        geselecteerdeIds.containsAll(beschikbareIds)) {
      return 'Alle ${beschikbareIds.length} artikelen';
    }

    final artikelen = leesArtikelen();
    final geselecteerdeArtikelen = artikelen
        .where((huidig) => geselecteerdeIds.contains(huidig.id))
        .toList(growable: false);
    if (geselecteerdeArtikelen.isNotEmpty) {
      final eersteKoppeling =
          OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(
            geselecteerdeArtikelen.first,
          );
      if (eersteKoppeling != null &&
          geselecteerdeArtikelen.every(
            (huidig) =>
                OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(
                  huidig,
                )?.adapterId ==
                eersteKoppeling.adapterId,
          )) {
        final groepIds = artikelen
            .where((huidig) {
              final koppeling =
                  OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(
                    huidig,
                  );
              return !huidig.isVerwijderd &&
                  koppeling?.adapterId == eersteKoppeling.adapterId &&
                  (!isKorting || !huidig.isOfferteOptie);
            })
            .map((huidig) => huidig.id)
            .toSet();
        if (groepIds.isNotEmpty &&
            geselecteerdeIds.length == groepIds.length &&
            geselecteerdeIds.containsAll(groepIds)) {
          return 'Hele groep: ${eersteKoppeling.formulierNaam}';
        }
      }
    }

    final aantal = geselecteerdeIds.length;
    return aantal == 1
        ? '1 geselecteerd artikel'
        : '$aantal geselecteerde artikelen';
  }

  Future<void> openPrijsCorrectieToepassenOpDialog({
    required OpmetingOverzichtRaamItem item,
    required bool isKorting,
    required double percentage,
  }) async {
    final startAdapter = OfferteArtikelPrijsMutatieService.adapterVoor(item);
    if (startAdapter == null) {
      return;
    }

    final artikelen = leesArtikelen();
    final positieLabelPerId = offerteController.positiesService
        .maakBronPositieLabels(artikelen);
    final geordendeItems = offerteController.positiesService
        .groepeerBronPositiesVoorOverzicht(artikelen);

    final keuzes = geordendeItems
        .where((huidig) => !huidig.isVerwijderd)
        .map((huidig) {
          final doelAdapter = OfferteArtikelPrijsMutatieService.adapterVoor(
            huidig,
          );
          final koppeling =
              OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(huidig);
          final beschikbaar =
              doelAdapter != null && (!isKorting || !huidig.isOfferteOptie);
          final nietBeschikbaarReden = doelAdapter == null
              ? 'Dit artikeltype ondersteunt nog geen gezamenlijke prijsaanpassing.'
              : isKorting && huidig.isOfferteOptie
              ? 'Optiepositie — korting is niet toegestaan.'
              : '';

          return OfferteArtikelToepassenOpKeuze(
            artikelId: huidig.id,
            positieLabel: positieLabelPerId[huidig.id] ?? 'Positie',
            artikelLabel: _artikelKeuzeOmschrijving(huidig),
            groepId: koppeling?.adapterId ?? huidig.formulierTypeGenormaliseerd,
            groepLabel: koppeling?.formulierNaam ?? huidig.formulierTypeLabel,
            berekenCorrectieBedragExclBtw: (gekozenPercentage) {
              if (!beschikbaar) {
                return 0.0;
              }
              return _berekenPrijsCorrectieBedragVoorArtikel(
                artikel: huidig,
                isKorting: isKorting,
                percentage: gekozenPercentage,
              );
            },
            isHuidigArtikel: huidig.id == item.id,
            beschikbaar: beschikbaar,
            nietBeschikbaarReden: nietBeschikbaarReden,
          );
        })
        .toList(growable: false);

    final dialoogResultaat = await toonOfferteArtikelToepassenOpDialog(
      context: context,
      titel: isKorting ? 'Korting' : 'Winstmarge',
      isKorting: isKorting,
      percentage: percentage,
      keuzes: keuzes,
      initieelGeselecteerdeArtikelIds: _prijsCorrectieDoelIdsVoorArtikel(
        artikel: item,
        isKorting: isKorting,
      ),
    );
    if (!isMounted() ||
        dialoogResultaat == null ||
        dialoogResultaat.artikelIds.isEmpty ||
        dialoogResultaat.percentage <= 0.0) {
      return;
    }

    final definitiefPercentage = dialoogResultaat.percentage;
    final geldigeDoelIds = _geldigePrijsCorrectieDoelIds(
      artikel: item,
      isKorting: isKorting,
      voorgesteldeDoelIds: dialoogResultaat.artikelIds,
    );
    if (geldigeDoelIds.isEmpty) {
      return;
    }

    final doelSet = _prijsCorrectieDoelSet(isKorting: isKorting);
    doelSet
      ..clear()
      ..addAll(geldigeDoelIds);
    onDoelSelectieGewijzigd();

    await _wijzigArtikelPrijsCorrectie(
      item: item,
      kortingPercentage: isKorting ? definitiefPercentage : null,
      winstmargePercentage: isKorting ? null : definitiefPercentage,
      doelArtikelIds: geldigeDoelIds,
    );
  }

  Future<void> _wijzigArtikelPrijsCorrectie({
    required OpmetingOverzichtRaamItem item,
    double? kortingPercentage,
    double? winstmargePercentage,
    required Set<String> doelArtikelIds,
  }) async {
    final adapter = OfferteArtikelPrijsMutatieService.adapterVoor(item);
    if (adapter == null ||
        doelArtikelIds.isEmpty ||
        (kortingPercentage != null && item.isOfferteOptie)) {
      return;
    }

    final resultaat = OfferteArtikelPrijsMutatieService.wijzigPrijsCorrecties(
      artikelen: leesArtikelen(),
      artikel: item,
      adapter: adapter,
      kortingPercentage: kortingPercentage,
      winstmargePercentage: winstmargePercentage,
      doelArtikelIds: doelArtikelIds,
    );
    if (!resultaat.isGewijzigd) {
      return;
    }

    if (isMounted()) {
      vervangArtikelen(resultaat.artikelen);
    }

    for (final bijgewerkt in resultaat.gewijzigdeArtikelen) {
      await AppStorage.werkOpmetingBij(bijgewerkt);
    }

    await OneDriveSyncService.registreerLokaleWijziging();
    OneDriveSyncService().uploadBackupOpAchtergrond();
  }

  Set<String> _prijsCorrectieDoelSet({required bool isKorting}) {
    return isKorting ? _kortingDoelArtikelIds : _winstmargeDoelArtikelIds;
  }

  Set<String> _beschikbarePrijsCorrectieDoelIds({required bool isKorting}) {
    return leesArtikelen()
        .where(
          (huidig) =>
              !huidig.isVerwijderd &&
              OfferteArtikelPrijsMutatieService.adapterVoor(huidig) != null &&
              (!isKorting || !huidig.isOfferteOptie),
        )
        .map((huidig) => huidig.id)
        .toSet();
  }

  Set<String> _geldigePrijsCorrectieDoelIds({
    required OpmetingOverzichtRaamItem artikel,
    required bool isKorting,
    Set<String>? voorgesteldeDoelIds,
  }) {
    final beschikbareIds = _beschikbarePrijsCorrectieDoelIds(
      isKorting: isKorting,
    );
    if (beschikbareIds.isEmpty) {
      return <String>{};
    }

    final geldigeSelectie = (voorgesteldeDoelIds ?? const <String>{})
        .intersection(beschikbareIds);
    if (geldigeSelectie.isNotEmpty) {
      return geldigeSelectie;
    }

    if (beschikbareIds.contains(artikel.id)) {
      return <String>{artikel.id};
    }

    return <String>{beschikbareIds.first};
  }

  Set<String> _prijsCorrectieDoelIdsVoorArtikel({
    required OpmetingOverzichtRaamItem artikel,
    required bool isKorting,
  }) {
    return _geldigePrijsCorrectieDoelIds(
      artikel: artikel,
      isKorting: isKorting,
      voorgesteldeDoelIds: _prijsCorrectieDoelSet(isKorting: isKorting),
    );
  }

  double _berekenPrijsCorrectieBedragVoorArtikel({
    required OpmetingOverzichtRaamItem artikel,
    required bool isKorting,
    required double percentage,
  }) {
    final adapter = OfferteArtikelPrijsMutatieService.adapterVoor(artikel);
    if (adapter == null || (isKorting && artikel.isOfferteOptie)) {
      return 0.0;
    }

    final tijdelijkArtikel = adapter.schrijfPrijsCorrecties(
      artikel: artikel,
      kortingPercentage: isKorting ? percentage : null,
      winstmargePercentage: isKorting ? null : percentage,
    );
    final resultaat = OfferteArtikelPrijsKoppelingService.resultaatVoorArtikel(
      tijdelijkArtikel,
      kortingToestaan: !tijdelijkArtikel.isOfferteOptie,
    );
    if (resultaat == null) {
      return 0.0;
    }

    return isKorting
        ? resultaat.kortingBedragExclBtw
        : resultaat.winstmargeBedragExclBtw;
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
}
