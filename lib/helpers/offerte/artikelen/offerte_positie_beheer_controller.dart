// THIMACO-CONTROLE: NIET-REKENEN-TERUG-ACTIVEREN-HUIDIGE-PAGINA-20260810_0942
// THIMACO-CONTROLE: POSITIEBEHEER-MET-WISSEL-NIET-REKENEN-20260728
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

  bool _blokkeerActieVoorNietRekenen(OpmetingOverzichtRaamItem item) {
    if (!item.isNietRekenen) {
      return false;
    }

    toonMelding(
      'Deze groep staat op “niet rekenen”. Zet de groep eerst opnieuw actief.',
    );
    return true;
  }

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
    if (_blokkeerActieVoorNietRekenen(item)) {
      return;
    }

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
    final kopieBronId =
        item.isOfferteOptie && item.offerteOptieHoofdpositieId.trim().isNotEmpty
        ? item.offerteOptieHoofdpositieId.trim()
        : item.id;

    var kopie = item.copyWith(
      id: nieuweId,
      gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
      isVerwijderd: false,
      gekopieerdVanPositieId: kopieBronId,
    );

    if (kopie.isOfferteOptie) {
      kopie = _wisOptiePrijsgegevens(kopie, wisVerdeeldePrijsregels: false);
    }

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
    if (_blokkeerActieVoorNietRekenen(item)) {
      return;
    }

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

    final hoofdpositieId = wordtOptie ? _bepaalOptieHoofdpositieId(item) : '';
    var bijgewerkt = item.copyWith(
      isOfferteOptie: wordtOptie,
      isNietRekenen: false,
      offerteOptiePlaatsing: plaatsing,
      offerteOptieHoofdpositieId: hoofdpositieId,
    );

    if (wordtOptie) {
      bijgewerkt = _wisOptiePrijsgegevens(
        bijgewerkt,
        wisVerdeeldePrijsregels: true,
      );
    }

    bijgewerkt = bijgewerkt.metNieuweWijzigingsDatum();

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

  OpmetingOverzichtRaamItem _wisOptiePrijsgegevens(
    OpmetingOverzichtRaamItem item, {
    required bool wisVerdeeldePrijsregels,
  }) {
    final prijsData = OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(
      item,
    );

    if (prijsData == null) {
      return item;
    }

    final bijgewerktePrijsData =
        OfferteArtikelPrijsKoppelingService.wijzigPrijsData(
          prijsData: prijsData,
          artikelKortingPercentage: 0.0,
          toegepasteVerdeeldePrijsregels: wisVerdeeldePrijsregels
              ? const <OfferteToegepastePrijsregelModel>[]
              : null,
          verdeeldePrijsSignatuur: wisVerdeeldePrijsregels ? '' : null,
        );

    return OfferteArtikelPrijsKoppelingService.schrijfPrijsData(
      artikel: item,
      prijsData: bijgewerktePrijsData,
    );
  }

  Future<void> wisselNietRekenen(OpmetingOverzichtRaamItem item) async {
    // Bepaal eerst expliciet welke eindtoestand de gebruiker heeft gekozen.
    // Zo kan een ouder kaartobject de status tijdens een herlaad- of
    // herberekeningscyclus niet opnieuw in de verkeerde richting toggelen.
    final gewensteNietRekenen = !item.isNietRekenen;

    if (gewensteNietRekenen) {
      final bevestigen = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: <Widget>[
                Icon(Icons.block_outlined, color: Color(0xFFDC2626)),
                SizedBox(width: 10),
                Expanded(child: Text('Groep niet rekenen?')),
              ],
            ),
            content: const SizedBox(
              width: 520,
              child: Text(
                'Deze groep blijft bewaard en zichtbaar in de fiche, '
                'maar wordt volledig uit de offerte gehaald.\n\n'
                'De groep telt niet meer mee in de positienummering, '
                'aantallen, prijsberekening, projectkosten, korting, '
                'btw en het eindtotaal.\n\n'
                'De groep kan later opnieuw geactiveerd worden.',
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(foregroundColor: _groen),
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                child: const Text('Annuleren'),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                icon: const Icon(Icons.block_outlined, size: 18),
                label: const Text('Groep niet rekenen'),
              ),
            ],
          );
        },
      );

      if (bevestigen != true || !isMounted()) {
        return;
      }
    }

    // Lees onmiddellijk vóór het opslaan opnieuw de laatste versie van deze
    // positie uit de opslag. Andere prijs-, sync- of navigatieacties kunnen
    // intussen een nieuwer exemplaar met dezelfde ID hebben opgeslagen.
    final alleOpmetingen = await AppStorage.laadOpmetingenVoorSync();
    final opgeslagenIndex = alleOpmetingen.indexWhere(
      (opmeting) => opmeting.id == item.id,
    );
    final actueleOpmeting = opgeslagenIndex >= 0
        ? alleOpmetingen[opgeslagenIndex]
        : item;

    if (actueleOpmeting.isNietRekenen != gewensteNietRekenen) {
      final bijgewerkt = actueleOpmeting
          .copyWith(
            isNietRekenen: gewensteNietRekenen,

            // Een groep kan niet tegelijk een offerteoptie en volledig
            // uitgesloten zijn.
            isOfferteOptie: gewensteNietRekenen
                ? false
                : actueleOpmeting.isOfferteOptie,

            // Wanneer de groep niet gerekend wordt, heeft een koppeling met
            // een hoofdpositie geen betekenis.
            offerteOptieHoofdpositieId: gewensteNietRekenen
                ? ''
                : actueleOpmeting.offerteOptieHoofdpositieId,
          )
          .metNieuweWijzigingsDatum();

      // AppStorage bewaart de positie en start zelf de normale sync-backup.
      // Hier dus geen tweede losse OneDrive-sync meer starten.
      await AppStorage.werkOpmetingBij(bijgewerkt);
    }

    if (!isMounted()) {
      return;
    }

    // Eén normale herlaadcyclus volstaat. De pagina voert tijdens die cyclus
    // zelf reeds de noodzakelijke prijs- en verdeelkostherberekening uit.
    // De vroegere tweede expliciete herberekening maakte deze statuswijziging
    // onnodig kwetsbaar voor een race tussen twee opslagcycli.
    await herlaadOpmetingen(leesKlantNaam());

    if (!isMounted()) {
      return;
    }

    // Controleer na de volledige cyclus wat werkelijk opgeslagen is.
    // Mocht een gelijktijdige actie de status toch opnieuw veranderd hebben,
    // herstel dan uitsluitend deze vlag op het nieuwste object.
    final controleOpmetingen = await AppStorage.laadOpmetingenVoorSync();
    final controleIndex = controleOpmetingen.indexWhere(
      (opmeting) => opmeting.id == item.id,
    );

    if (controleIndex >= 0 &&
        controleOpmetingen[controleIndex].isNietRekenen !=
            gewensteNietRekenen) {
      final nieuwste = controleOpmetingen[controleIndex];
      final hersteld = nieuwste
          .copyWith(
            isNietRekenen: gewensteNietRekenen,
            isOfferteOptie: gewensteNietRekenen
                ? false
                : nieuwste.isOfferteOptie,
            offerteOptieHoofdpositieId: gewensteNietRekenen
                ? ''
                : nieuwste.offerteOptieHoofdpositieId,
          )
          .metNieuweWijzigingsDatum();

      await AppStorage.werkOpmetingBij(hersteld);

      if (!isMounted()) {
        return;
      }

      await herlaadOpmetingen(leesKlantNaam());

      if (!isMounted()) {
        return;
      }
    }

    toonMelding(
      gewensteNietRekenen
          ? 'Groep wordt niet meer meegerekend en verschijnt niet op de offerte.'
          : 'Groep is opnieuw actief en wordt opnieuw meegerekend.',
    );
  }

  Future<void> verplaatsPositie(
    OpmetingOverzichtRaamItem item,
    int richting,
  ) async {
    if (_blokkeerActieVoorNietRekenen(item)) {
      return;
    }

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
