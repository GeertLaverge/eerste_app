// THIMACO-CONTROLE: OVERZICHT-PRIJS-LOCAL-FIRST-10S-20260922
import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_storage.dart';
import '../../opmeting/overzicht/opmeting_overzicht_model.dart';
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

  // THIMACO-CONTROLE: OVERZICHT-PRIJS-LOCAL-FIRST-10S-20260922
  Timer? _bewaarTimer;
  final Set<String> _openstaandeArtikelIds = <String>{};
  String _klantVoorHerberekening = '';
  bool _herberekenNaBewaren = false;

  void dispose() {
    _bewaarTimer?.cancel();

    // Een pagina mag niet verdwijnen met nog niet lokaal bewaarde prijsinvoer.
    // De laatste in-memory waarden worden nog veilig naar AppStorage gestuurd.
    if (_openstaandeArtikelIds.isNotEmpty) {
      unawaited(_bewaarOpenstaandeWijzigingen());
    }
  }

  void planBewarenArtikelIds(
    Iterable<String> artikelIds, {
    String klantNaam = '',
    bool herberekenNaBewaren = false,
  }) {
    for (final id in artikelIds) {
      final netteId = id.trim();
      if (netteId.isNotEmpty) {
        _openstaandeArtikelIds.add(netteId);
      }
    }

    if (klantNaam.trim().isNotEmpty) {
      _klantVoorHerberekening = klantNaam.trim();
    }
    _herberekenNaBewaren = _herberekenNaBewaren || herberekenNaBewaren;

    _bewaarTimer?.cancel();
    _bewaarTimer = Timer(const Duration(seconds: 10), () {
      unawaited(_bewaarOpenstaandeWijzigingen());
    });
  }

  Future<void> bewaarOpenstaandeWijzigingenNu() async {
    _bewaarTimer?.cancel();
    _bewaarTimer = null;
    await _bewaarOpenstaandeWijzigingen();
  }

  Future<void> _bewaarOpenstaandeWijzigingen() async {
    if (_openstaandeArtikelIds.isEmpty) {
      return;
    }

    final ids = Set<String>.from(_openstaandeArtikelIds);
    _openstaandeArtikelIds.removeAll(ids);

    final klantNaam = _klantVoorHerberekening;
    final moetHerberekenen = _herberekenNaBewaren;
    _klantVoorHerberekening = '';
    _herberekenNaBewaren = false;

    // Belangrijk: lees pas NU de nieuwste in-memory artikelen. Zo kan een
    // oudere debounce-snapshot nooit recentere invoer terug overschrijven.
    final nieuwsteArtikelen = List<OpmetingOverzichtRaamItem>.from(
      leesArtikelen(),
    );

    try {
      for (final artikel in nieuwsteArtikelen) {
        if (ids.contains(artikel.id.trim())) {
          await AppStorage.werkOpmetingBij(artikel);
        }
      }

      if (moetHerberekenen && klantNaam.isNotEmpty && isMounted()) {
        await herberekenPrijsMomentopnames(klantNaam);
      }
    } catch (_) {
      // Bij een tijdelijke opslagfout blijven de betrokken IDs openstaan en
      // probeert de volgende wijziging/save opnieuw. De UI blijft responsief.
      _openstaandeArtikelIds.addAll(ids);
      if (klantNaam.isNotEmpty) {
        _klantVoorHerberekening = klantNaam;
      }
      _herberekenNaBewaren = _herberekenNaBewaren || moetHerberekenen;
    }
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

    // Eerst uitsluitend het in-memory model/UI aanpassen. Geen schijf- of
    // OneDrive-werk in de typelus.
    if (resultaat.lijstGewijzigd && isMounted()) {
      vervangArtikelen(resultaat.artikelen);
    }

    planBewarenArtikelIds(
      resultaat.gewijzigdeArtikelen.map((artikel) => artikel.id),
      klantNaam: resultaat.gewijzigdeArtikelen.first.klantNaam,
      herberekenNaBewaren: true,
    );
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
                  !huidig.isNietRekenen &&
                  koppeling?.adapterId == eersteKoppeling.adapterId &&
                  (!isKorting || !huidig.isZichtbareOfferteOptie);
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
        .where((huidig) => !huidig.isVerwijderd && !huidig.isNietRekenen)
        .map((huidig) {
          final doelAdapter = OfferteArtikelPrijsMutatieService.adapterVoor(
            huidig,
          );
          final koppeling =
              OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(huidig);
          final beschikbaar =
              doelAdapter != null &&
              !huidig.isNietRekenen &&
              (!isKorting || !huidig.isZichtbareOfferteOptie);

          final nietBeschikbaarReden = doelAdapter == null
              ? 'Dit artikeltype ondersteunt nog geen gezamenlijke prijsaanpassing.'
              : huidig.isNietRekenen
              ? 'Deze groep staat op niet rekenen.'
              : isKorting && huidig.isZichtbareOfferteOptie
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
        item.isNietRekenen ||
        doelArtikelIds.isEmpty ||
        (kortingPercentage != null && item.isZichtbareOfferteOptie)) {
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

    // De correctie staat nu onmiddellijk in het in-memory model. Bewaren
    // gebeurt pas na 10 seconden rust, buiten de typelus.
    planBewarenArtikelIds(
      resultaat.gewijzigdeArtikelen.map((artikel) => artikel.id),
      klantNaam: resultaat.gewijzigdeArtikelen.first.klantNaam,
      herberekenNaBewaren: true,
    );
  }

  Set<String> _prijsCorrectieDoelSet({required bool isKorting}) {
    return isKorting ? _kortingDoelArtikelIds : _winstmargeDoelArtikelIds;
  }

  Set<String> _beschikbarePrijsCorrectieDoelIds({required bool isKorting}) {
    return leesArtikelen()
        .where(
          (huidig) =>
              !huidig.isVerwijderd &&
              !huidig.isNietRekenen &&
              OfferteArtikelPrijsMutatieService.adapterVoor(huidig) != null &&
              (!isKorting || !huidig.isZichtbareOfferteOptie),
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
    if (adapter == null ||
        artikel.isNietRekenen ||
        (isKorting && artikel.isZichtbareOfferteOptie)) {
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
