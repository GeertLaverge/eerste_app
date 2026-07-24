import 'package:flutter/material.dart';

import '../../app_storage.dart';
import '../../sync/onedrive_sync_service.dart';
import '../offerte_controller.dart';
import '../prijzen/offerte_artikel_prijs_koppeling_service.dart';
import '../prijzen/offerte_toegepaste_prijsregel_model.dart';
import '../../opmeting/overzicht/opmeting_overzicht_model.dart';

class OffertePositieBeheerController {
  OffertePositieBeheerController({
    required this.context,
    required this.offerteController,
    required this.isMounted,
    required this.leesArtikelen,
    required this.leesKlantNaam,
    required this.herlaadOpmetingen,
    required this.herberekenPrijsMomentopnames,
    required this.verplaatsArtikelLokaal,
    required this.toonMelding,
  });

  static const Color _groen = Color(0xFF0B7A3B);

  final BuildContext context;
  final OfferteController offerteController;
  final bool Function() isMounted;
  final List<OpmetingOverzichtRaamItem> Function() leesArtikelen;
  final String Function() leesKlantNaam;
  final Future<void> Function(String? klantNaam) herlaadOpmetingen;
  final Future<void> Function(String klantNaam) herberekenPrijsMomentopnames;
  final void Function(int huidigeIndex, int nieuweIndex) verplaatsArtikelLokaal;
  final void Function(String tekst) toonMelding;

  Future<void> verwijderPositie(OpmetingOverzichtRaamItem item) async {
    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Opmeting verwijderen?'),
          content: Text('De opmeting “${item.titel}” wordt verwijderd.'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: _groen),
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Annuleren'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Verwijderen'),
            ),
          ],
        );
      },
    );

    if (bevestigen != true) {
      return;
    }

    await AppStorage.verwijderOpmeting(item.id);

    if (!isMounted()) {
      return;
    }

    final klantNaam = leesKlantNaam().trim();
    await herlaadOpmetingen(klantNaam.isEmpty ? null : klantNaam);

    if (!isMounted()) {
      return;
    }

    toonMelding('Opmeting verwijderd en synchronisatie gestart.');
  }

  Future<void> kopieerPositie(OpmetingOverzichtRaamItem item) async {
    final plaats = await showDialog<_PositieKopiePlaats>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Positie kopiëren'),
          content: Text(
            'Waar moet de kopie van “${item.titel}” geplaatst worden?',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(foregroundColor: _groen),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuleren'),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: _groen,
                side: const BorderSide(color: _groen),
              ),
              onPressed: () =>
                  Navigator.pop(dialogContext, _PositieKopiePlaats.boven),
              child: const Text('Boven deze groep'),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: _groen,
                side: const BorderSide(color: _groen),
              ),
              onPressed: () =>
                  Navigator.pop(dialogContext, _PositieKopiePlaats.onder),
              child: const Text('Onder deze groep'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _groen),
              onPressed: () =>
                  Navigator.pop(dialogContext, _PositieKopiePlaats.laatste),
              child: const Text('Naar laatste positie'),
            ),
          ],
        );
      },
    );

    if (plaats == null) return;

    final alleOpmetingen = await AppStorage.laadOpmetingenVoorSync();
    final bronIndex = alleOpmetingen.indexWhere(
      (huidig) => huidig.id == item.id,
    );
    if (bronIndex < 0) return;

    final nieuweId = DateTime.now().microsecondsSinceEpoch.toString();
    final bestaandModel = item.vasteInzethorData;
    final kopieModel = item.isOfferteOptie && bestaandModel != null
        ? bestaandModel.copyWithPrijsData(
            OfferteArtikelPrijsKoppelingService.wijzigPrijsData(
              prijsData: bestaandModel.prijsData,
              artikelKortingPercentage: 0.0,
            ),
          )
        : bestaandModel;
    final kopieBronId =
        item.isOfferteOptie && item.offerteOptieHoofdpositieId.trim().isNotEmpty
        ? item.offerteOptieHoofdpositieId.trim()
        : item.id;
    final kopie = item.copyWith(
      id: nieuweId,
      gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
      isVerwijderd: false,
      gekopieerdVanPositieId: kopieBronId,
      vasteInzethorData: kopieModel,
    );

    var invoegIndex = bronIndex + 1;
    if (plaats == _PositieKopiePlaats.boven) {
      invoegIndex = bronIndex;
    } else if (plaats == _PositieKopiePlaats.laatste) {
      final klantSleutel = item.klantNaam.trim().toLowerCase();
      var laatsteIndex = bronIndex;
      for (var index = 0; index < alleOpmetingen.length; index++) {
        final huidig = alleOpmetingen[index];
        if (!huidig.isVerwijderd &&
            huidig.klantNaam.trim().toLowerCase() == klantSleutel) {
          laatsteIndex = index;
        }
      }
      invoegIndex = laatsteIndex + 1;
    }

    alleOpmetingen.insert(
      invoegIndex.clamp(0, alleOpmetingen.length).toInt(),
      kopie,
    );
    await AppStorage.bewaarOpmetingen(alleOpmetingen);
    await OneDriveSyncService.registreerLokaleWijziging();
    OneDriveSyncService().uploadBackupOpAchtergrond();

    if (!isMounted()) return;
    await herlaadOpmetingen(leesKlantNaam());
    await herberekenPrijsMomentopnames(item.klantNaam);
    if (isMounted()) toonMelding('Positie gekopieerd.');
  }

  Future<void> wisselOptieplaatsing(OpmetingOverzichtRaamItem item) async {
    final actie = await showDialog<_OfferteOptieActie>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: Text(
            item.isOfferteOptie
                ? 'Optieweergave aanpassen'
                : 'Positie in optie plaatsen',
          ),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.view_agenda_outlined,
                    color: _groen,
                  ),
                  title: const Text(
                    'Positie op haar plaats in de offerte behouden',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text(
                    'De positie blijft in de normale volgorde staan, maar wordt duidelijk als optie aangeduid en niet meegerekend in het eindtotaal.',
                  ),
                  onTap: () {
                    Navigator.pop(
                      dialogContext,
                      _OfferteOptieActie.positieBehouden,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.note_add_outlined, color: _groen),
                  title: const Text(
                    'Op een aparte pagina vermelden',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text(
                    'De optie krijgt een afzonderlijke pagina achter de volledige hoofdofferte en de eindberekening, met een eigen totaal excl. btw, btw en totaal incl. btw.',
                  ),
                  onTap: () {
                    Navigator.pop(
                      dialogContext,
                      _OfferteOptieActie.apartePagina,
                    );
                  },
                ),
                if (item.isOfferteOptie) ...<Widget>[
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: _groen,
                    ),
                    title: const Text(
                      'Terug in de hoofdofferte plaatsen',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: const Text(
                      'De positie wordt opnieuw een gewone actieve positie en telt opnieuw mee in de totalen.',
                    ),
                    onTap: () {
                      Navigator.pop(
                        dialogContext,
                        _OfferteOptieActie.hoofdofferte,
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(foregroundColor: _groen),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuleren'),
            ),
          ],
        );
      },
    );

    if (actie == null || !isMounted()) {
      return;
    }

    final wordtOptie = actie != _OfferteOptieActie.hoofdofferte;
    final plaatsing = switch (actie) {
      _OfferteOptieActie.positieBehouden =>
        OfferteOptiePlaatsing.positieBehouden,
      _OfferteOptieActie.apartePagina => OfferteOptiePlaatsing.apartePagina,
      _OfferteOptieActie.hoofdofferte => item.offerteOptiePlaatsing,
    };

    final model = item.vasteInzethorData;
    final hoofdpositieId = wordtOptie ? _bepaalOptieHoofdpositieId(item) : '';
    final bijgewerkt = item
        .copyWith(
          isOfferteOptie: wordtOptie,
          offerteOptiePlaatsing: plaatsing,
          offerteOptieHoofdpositieId: hoofdpositieId,
          vasteInzethorData: wordtOptie && model != null
              ? model.copyWithPrijsData(
                  OfferteArtikelPrijsKoppelingService.wijzigPrijsData(
                    prijsData: model.prijsData,
                    artikelKortingPercentage: 0.0,
                    toegepasteVerdeeldePrijsregels:
                        const <OfferteToegepastePrijsregelModel>[],
                    verdeeldePrijsSignatuur: '',
                  ),
                )
              : model,
        )
        .metNieuweWijzigingsDatum();

    await AppStorage.werkOpmetingBij(bijgewerkt);
    await OneDriveSyncService.registreerLokaleWijziging();
    OneDriveSyncService().uploadBackupOpAchtergrond();

    if (!isMounted()) return;
    await herlaadOpmetingen(leesKlantNaam());
    await herberekenPrijsMomentopnames(item.klantNaam);
    if (!isMounted()) return;

    final melding = switch (actie) {
      _OfferteOptieActie.positieBehouden =>
        'Positie blijft op haar plaats in de offerte en wordt als optie aangeduid. Korting werd verwijderd.',
      _OfferteOptieActie.apartePagina =>
        'Positie wordt op een aparte optiepagina vermeld. Korting werd verwijderd.',
      _OfferteOptieActie.hoofdofferte =>
        'Positie opnieuw in de hoofdofferte geplaatst.',
    };
    toonMelding(melding);
  }

  Future<void> verplaatsPositie(
    OpmetingOverzichtRaamItem item,
    int richting,
  ) async {
    final artikelen = leesArtikelen();
    final huidigeIndex = artikelen.indexWhere(
      (opmeting) => opmeting.id == item.id,
    );
    final nieuweIndex = huidigeIndex + richting;

    if (huidigeIndex < 0 ||
        nieuweIndex < 0 ||
        nieuweIndex >= artikelen.length) {
      return;
    }

    final verplaatst = await AppStorage.verplaatsOpmetingBinnenKlant(
      klantNaam: leesKlantNaam(),
      opmetingId: item.id,
      richting: richting,
    );

    if (!verplaatst || !isMounted()) {
      return;
    }

    verplaatsArtikelLokaal(huidigeIndex, nieuweIndex);
  }

  String _bepaalOptieHoofdpositieId(OpmetingOverzichtRaamItem item) {
    return offerteController.bepaalOptieHoofdpositieId(
      posities: leesArtikelen(),
      positieId: item.id,
    );
  }
}

enum _PositieKopiePlaats { boven, onder, laatste }

enum _OfferteOptieActie { positieBehouden, apartePagina, hoofdofferte }
