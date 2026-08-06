// THIMACO-CONTROLE: OFFERTEVERSIE-ALS-WERKVERSIE-20260806
// THIMACO-CONTROLE: OPMEETBESTAND-SYNC-ALTIJD-SILENT-20260805
// THIMACO-CONTROLE: UNIFORME-OPMEETBESTAND-DIALOGEN-20260730
// THIMACO-CONTROLE: OPENEN-ZONDER-ONTERECHTE-PRIJSVRAAG-20260724
import 'package:flutter/material.dart';

import '../../app_storage.dart';
import '../../offerte/prijzen/offerte_artikel_prijs_koppeling_service.dart';
import '../../offerte/prijzen/offerte_artikel_prijscorrectie_controller.dart';
import '../../offerte/prijzen/offerte_prijsinstellingen_controller.dart';
import '../../offerte/prijzen/offerte_prijsinstellingen_momentopname.dart';
import '../../offerte/prijzen/offerte_prijsprofiel_model.dart';
import '../../sync/onedrive_sync_service.dart';
import '../overzicht/opmeting_overzicht_model.dart';
import 'opmeting_project_kleur_model.dart';
import 'opmeting_project_titelhoofd_controller.dart';
import 'opmeting_project_titelhoofd_model.dart';

class OpmetingProjectBestandController {
  OpmetingProjectBestandController({
    required this.context,
    required this.isMounted,
    required this.leesKlantNaam,
    required this.leesTitelhoofd,
    required this.leesOpmetingen,
    required this.leesVerborgenFormulierTypes,
    required this.prijsinstellingenController,
    required this.projectTitelhoofdController,
    required this.artikelPrijscorrectieController,
    required this.vervangProjectState,
    required this.vervangProjectKleuren,
    required this.zetLaden,
    required this.toonMelding,
  });

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);
  static const Color _rood = Color(0xFFDC2626);

  final BuildContext context;
  final bool Function() isMounted;
  final String Function() leesKlantNaam;
  final OpmetingProjectTitelhoofd Function() leesTitelhoofd;
  final List<OpmetingOverzichtRaamItem> Function() leesOpmetingen;
  final Set<String> Function() leesVerborgenFormulierTypes;
  final OffertePrijsinstellingenController prijsinstellingenController;
  final OpmetingProjectTitelhoofdController projectTitelhoofdController;
  final OfferteArtikelPrijscorrectieController artikelPrijscorrectieController;
  final void Function(
    String klantNaam,
    OpmetingProjectTitelhoofd titelhoofd,
    List<OpmetingOverzichtRaamItem> opmetingen,
    Set<String> verborgenFormulierTypes,
    bool laden,
  )
  vervangProjectState;
  final void Function(List<OpmetingProjectKleurSubmenu> kleuren)
  vervangProjectKleuren;
  final void Function(bool laden) zetLaden;
  final void Function(String tekst, bool fout) toonMelding;

  Future<void> laadOpmetingenVanOpslag({
    String? klantNaam,
    bool vraagPrijsinstellingenOvernemen = false,
    bool forceerPrijsinstellingen = false,
  }) async {
    zetLaden(true);

    final huidigeKlantNaam = leesKlantNaam();
    final actieveKlantNaam = (klantNaam ?? huidigeKlantNaam).trim();
    final klantGewijzigd =
        projectTitelhoofdController.normaliseerKlantNaam(actieveKlantNaam) !=
        projectTitelhoofdController.normaliseerKlantNaam(huidigeKlantNaam);

    if (klantGewijzigd) {
      prijsinstellingenController.wisGenegeerdePrijsinstellingenSignatuur();
    }

    final opgeslagenTitelhoofd = await AppStorage.laadOpmetingProjectTitelhoofd(
      actieveKlantNaam,
    );
    var titelhoofd = await projectTitelhoofdController.vulAanUitKlantenfiche(
      klantNaam: actieveKlantNaam,
      basis: opgeslagenTitelhoofd,
    );
    final alleOpmetingenVoorSync = await AppStorage.laadOpmetingenVoorSync();

    final huidigeProfielen = await prijsinstellingenController
        .laadOndersteundePrijsprofielen();
    final huidigeMomentopnames = prijsinstellingenController
        .maakHuidigePrijsinstellingenMomentopnames(huidigeProfielen);
    final oudeMomentopnames = prijsinstellingenController
        .leesOudePrijsinstellingenMomentopnames(titelhoofd);

    bool isGewijzigd(
      OffertePrijsinstellingenMomentopname? oud,
      OffertePrijsinstellingenMomentopname huidig,
    ) {
      // Oudere bestanden zonder momentopname krijgen de huidige inhoud als
      // stille uitgangssituatie. Alleen een bestaande, afwijkende snapshot
      // veroorzaakt nog de vraag om nieuwe prijsinstellingen toe te passen.
      return oud == null ? false : !oud.heeftZelfdeInhoudAls(huidig);
    }

    final gewijzigdeFormulierTypes = OfferteArtikelPrijsKoppelingService
        .ondersteundeFormulierTypes
        .where(
          (formulierType) => isGewijzigd(
            oudeMomentopnames[formulierType],
            huidigeMomentopnames[formulierType]!,
          ),
        )
        .toList(growable: false);
    final prijsinstellingenGewijzigd = gewijzigdeFormulierTypes.isNotEmpty;
    final wijzigingen = <OffertePrijsinstellingenWijziging>[
      for (final formulierType in gewijzigdeFormulierTypes)
        ...prijsinstellingenController.bepaalPrijsinstellingenWijzigingen(
          oud: oudeMomentopnames[formulierType],
          huidig: huidigeMomentopnames[formulierType]!,
        ),
    ];

    var huidigeInstellingenToepassen = true;
    final profielenVoorBerekening = Map<String, OffertePrijsprofielModel>.from(
      huidigeProfielen,
    );

    if (titelhoofd.berekenPrijzen &&
        prijsinstellingenGewijzigd &&
        vraagPrijsinstellingenOvernemen &&
        !forceerPrijsinstellingen) {
      if (!isMounted()) return;

      final keuze = await prijsinstellingenController
          .vraagPrijsinstellingenOvernemen(
            wijzigingen: wijzigingen,
            eersteKoppeling: gewijzigdeFormulierTypes.any(
              (formulierType) => oudeMomentopnames[formulierType] == null,
            ),
          );
      huidigeInstellingenToepassen = keuze == true;

      if (huidigeInstellingenToepassen) {
        prijsinstellingenController.wisGenegeerdePrijsinstellingenSignatuur();
      } else {
        prijsinstellingenController.negeerHuidigePrijsinstellingen(
          huidigeMomentopnames.values,
        );
      }

      if (!huidigeInstellingenToepassen) {
        for (final formulierType
            in OfferteArtikelPrijsKoppelingService.ondersteundeFormulierTypes) {
          profielenVoorBerekening[formulierType] =
              oudeMomentopnames[formulierType]?.naarProfiel() ??
              OffertePrijsprofielModel.leeg(
                formulierType: formulierType,
                formulierNaam:
                    OfferteArtikelPrijsKoppelingService.formulierNaamVoor(
                      formulierType,
                    ),
              );
        }
      }
    }

    final magPrijsberekeningUitvoeren =
        titelhoofd.berekenPrijzen &&
        (huidigeInstellingenToepassen ||
            oudeMomentopnames.values.any(
              (momentopname) => momentopname != null,
            ));

    final momentopnameResultaat = magPrijsberekeningUitvoeren
        ? await prijsinstellingenController.werkTechnischePrijsMomentopnamesBij(
            alleOpmetingen: alleOpmetingenVoorSync,
            klantNaam: actieveKlantNaam,
            berekenPrijzen: true,
            prijsprofielen: profielenVoorBerekening,
            tijdelijkeProjectPrijsregels:
                titelhoofd.tijdelijkeProjectPrijsregels,
            forceerPrijsinstellingen:
                forceerPrijsinstellingen ||
                (prijsinstellingenGewijzigd && huidigeInstellingenToepassen),
          )
        : OfferteTechnischePrijsMomentopnameResultaat(
            opmetingen: alleOpmetingenVoorSync,
            gewijzigd: false,
          );

    final projectkleurResultaat = projectTitelhoofdController
        .synchroniseerProjectkleurInVasteInzethorPosities(
          momentopnameResultaat.opmetingen,
          klantNaam: actieveKlantNaam,
          projectkleur: titelhoofd.ralKleurToebehoren,
        );
    final opmetingenNaProjectkleurSynchronisatie =
        projectkleurResultaat.opmetingen;

    if (titelhoofd.berekenPrijzen && huidigeInstellingenToepassen) {
      for (final momentopname in huidigeMomentopnames.values) {
        titelhoofd = titelhoofd.metPrijsinstellingenMomentopname(momentopname);
      }
      titelhoofd = titelhoofd.metWijzigingsDatum();
      await AppStorage.bewaarOpmetingProjectTitelhoofd(titelhoofd);
    }

    if (momentopnameResultaat.gewijzigd || projectkleurResultaat.gewijzigd) {
      await AppStorage.bewaarOpmetingenVoorSync(
        opmetingenNaProjectkleurSynchronisatie,
      );
      await OneDriveSyncService.registreerLokaleWijziging();
      OneDriveSyncService().uploadBackupOpAchtergrond();
    }

    final klantFilter = actieveKlantNaam.toLowerCase();
    final zichtbareOpmetingen = klantFilter.isEmpty
        ? <OpmetingOverzichtRaamItem>[]
        : opmetingenNaProjectkleurSynchronisatie.where((opmeting) {
            return !opmeting.isVerwijderd &&
                opmeting.klantNaam.trim().toLowerCase() == klantFilter;
          }).toList();

    if (!isMounted()) return;

    final bestaandeTypes = zichtbareOpmetingen
        .map((opmeting) => opmeting.formulierTypeGenormaliseerd)
        .toSet();
    final verborgenFormulierTypes = leesVerborgenFormulierTypes()
        .where(bestaandeTypes.contains)
        .toSet();

    if (klantGewijzigd) {
      artikelPrijscorrectieController.wisDoelSelecties();
    }

    vervangProjectState(
      actieveKlantNaam,
      titelhoofd.klantNaam.trim().isEmpty && actieveKlantNaam.isNotEmpty
          ? titelhoofd.copyWith(klantNaam: actieveKlantNaam)
          : titelhoofd,
      zichtbareOpmetingen,
      verborgenFormulierTypes,
      false,
    );
  }

  Future<void> laadProjectKleuren() async {
    final kleuren = await AppStorage.laadOpmetingProjectKleuren();
    if (!isMounted()) return;
    vervangProjectKleuren(kleuren);
  }

  Future<List<OpmetingAgendaKlantInfo>> _laadKlantenVoorNieuweOpmeting() async {
    final bronnen = await Future.wait<List<OpmetingAgendaKlantInfo>>(
      <Future<List<OpmetingAgendaKlantInfo>>>[
        AppStorage.laadKlantenVoorOpmeting(),
        AppStorage.laadAgendaKlantenVoorOpmeting(),
      ],
    );
    final perKlant = <String, OpmetingAgendaKlantInfo>{};

    void voegToe(OpmetingAgendaKlantInfo klant) {
      final sleutel = opmetingKlantNaamSleutel(klant.klantNaam);
      if (sleutel.isEmpty) return;

      final bestaand = perKlant[sleutel];
      perKlant[sleutel] = bestaand == null
          ? klant
          : bestaand.combineerMet(klant);
    }

    // Klantenfiches worden eerst toegevoegd. Gegevens uit de blauwe agenda
    // vullen daarna alleen ontbrekende klantgegevens aan.
    for (final klant in bronnen[0]) {
      voegToe(klant);
    }
    for (final klant in bronnen[1]) {
      voegToe(klant);
    }

    final klanten = perKlant.values.toList()
      ..sort((eerste, tweede) {
        return eerste.klantNaamMetAanspreking.toLowerCase().compareTo(
          tweede.klantNaamMetAanspreking.toLowerCase(),
        );
      });

    return klanten;
  }

  Future<_NieuweOpmetingKlantResultaat?> _vraagKlantNaam() async {
    final huidigeContext = context;
    final klanten = await _laadKlantenVoorNieuweOpmeting();
    if (!isMounted()) return null;
    if (!huidigeContext.mounted) return null;

    final resultaat = await showDialog<_NieuweOpmetingKlantResultaat>(
      context: huidigeContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _KlantNaamDialog(beginNaam: leesKlantNaam(), klanten: klanten);
      },
    );

    await Future<void>.delayed(Duration.zero);
    if (isMounted()) {
      await WidgetsBinding.instance.endOfFrame;
    }

    return resultaat;
  }

  Future<OpmetingProjectTitelhoofd> _maakTitelhoofdVoorNieuweKlant(
    _NieuweOpmetingKlantResultaat keuze,
  ) async {
    final bestaand = await AppStorage.laadOpmetingProjectTitelhoofd(
      keuze.klantNaam,
    );
    final basis = bestaand.copyWith(klantNaam: keuze.klantNaam);
    final uitKlantenfiche = keuze.klantFiche?.naarTitelhoofd(
      bestaand: basis,
      overschrijfKlantnummer: true,
    );

    final aangevuld =
        uitKlantenfiche ??
        await projectTitelhoofdController.vulAanUitKlantenfiche(
          klantNaam: keuze.klantNaam,
          basis: basis,
        );

    return aangevuld.metWijzigingsDatum();
  }

  Future<String?> zorgVoorActieveKlant() async {
    final huidigeKlantNaam = leesKlantNaam().trim();
    if (huidigeKlantNaam.isNotEmpty) {
      return huidigeKlantNaam;
    }

    final keuze = await _vraagKlantNaam();
    if (keuze == null || keuze.klantNaam.trim().isEmpty || !isMounted()) {
      return null;
    }

    final klantNaam = keuze.klantNaam.trim();
    final titelhoofd = await _maakTitelhoofdVoorNieuweKlant(keuze);
    if (!isMounted()) return null;

    await AppStorage.bewaarOpmetingProjectTitelhoofd(titelhoofd);
    if (!isMounted()) return null;

    artikelPrijscorrectieController.wisDoelSelecties();
    vervangProjectState(
      klantNaam,
      titelhoofd,
      <OpmetingOverzichtRaamItem>[],
      Set<String>.from(leesVerborgenFormulierTypes()),
      false,
    );

    return klantNaam;
  }

  Future<void> nieuwBestand() async {
    final keuze = await _vraagKlantNaam();
    if (keuze == null || keuze.klantNaam.trim().isEmpty || !isMounted()) {
      return;
    }

    final klantNaam = keuze.klantNaam.trim();
    final titelhoofd = await _maakTitelhoofdVoorNieuweKlant(keuze);
    if (!isMounted()) return;

    await AppStorage.bewaarOpmetingProjectTitelhoofd(titelhoofd);
    if (!isMounted()) return;

    artikelPrijscorrectieController.wisDoelSelecties();
    vervangProjectState(
      klantNaam,
      titelhoofd,
      <OpmetingOverzichtRaamItem>[],
      <String>{},
      false,
    );
  }

  Map<String, List<OpmetingOverzichtRaamItem>> _groepeerOpmetingenPerKlant(
    List<OpmetingOverzichtRaamItem> opmetingen,
  ) {
    final klanten = <String, List<OpmetingOverzichtRaamItem>>{};

    for (final opmeting in opmetingen) {
      final klantNaam = opmeting.klantNaam.trim().isEmpty
          ? 'Zonder klantnaam'
          : opmeting.klantNaam.trim();
      klanten
          .putIfAbsent(klantNaam, () => <OpmetingOverzichtRaamItem>[])
          .add(opmeting);
    }

    return klanten;
  }

  List<String> _gesorteerdeKlantNamen(
    Map<String, List<OpmetingOverzichtRaamItem>> klanten,
  ) {
    return klanten.keys.toList()..sort((eerste, tweede) {
      return eerste.toLowerCase().compareTo(tweede.toLowerCase());
    });
  }

  Future<void> openBestand() async {
    await OneDriveSyncService().slimmeSync();
    if (!isMounted()) return;

    final alleOpmetingen = await AppStorage.laadOpmetingen();
    if (!isMounted()) return;

    if (alleOpmetingen.isEmpty) {
      toonMelding('Er zijn nog geen opgeslagen opmetingen.', true);
      return;
    }

    final klanten = _groepeerOpmetingenPerKlant(alleOpmetingen);
    final klantNamen = _gesorteerdeKlantNamen(klanten);
    final gekozenKlant = await _kiesKlantBestand(
      titel: 'Opmeetbestand openen',
      klantNamen: klantNamen,
      klanten: klanten,
      wissen: false,
    );

    if (gekozenKlant == null) return;

    await laadOpmetingenVanOpslag(
      klantNaam: gekozenKlant,
      vraagPrijsinstellingenOvernemen: true,
    );
    if (!isMounted()) return;

    toonMelding('Opmeetbestand “$gekozenKlant” is geopend.', false);
  }

  Widget _bouwBestandDialoogKop({
    required String titel,
    required IconData icoon,
    Color kleur = _groen,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: const BoxDecoration(
        color: _lichtGroen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: Color(0xFFCDEBD6))),
      ),
      child: Row(
        children: <Widget>[
          Icon(icoon, color: kleur, size: 20),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              titel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: kleur,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _secundaireDialoogKnopStijl() {
    return OutlinedButton.styleFrom(
      foregroundColor: _groen,
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFB9E1C6)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontWeight: FontWeight.w800),
    );
  }

  ButtonStyle _primaireDialoogKnopStijl({Color kleur = _groen}) {
    return FilledButton.styleFrom(
      backgroundColor: kleur,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontWeight: FontWeight.w800),
    );
  }

  Future<String?> _kiesKlantBestand({
    required String titel,
    required List<String> klantNamen,
    required Map<String, List<OpmetingOverzichtRaamItem>> klanten,
    required bool wissen,
  }) {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _rand),
          ),
          titlePadding: EdgeInsets.zero,
          title: _bouwBestandDialoogKop(
            titel: titel,
            icoon: wissen
                ? Icons.delete_outline_rounded
                : Icons.folder_open_outlined,
          ),
          contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
          content: SizedBox(
            width: 440,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 410),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: klantNamen.length,
                separatorBuilder: (_, __) => const SizedBox(height: 7),
                itemBuilder: (context, index) {
                  final klantNaam = klantNamen[index];
                  final aantal = klanten[klantNaam]?.length ?? 0;

                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        Navigator.pop(dialogContext, klantNaam);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFB9E1C6)),
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: _lichtGroen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.description_outlined,
                                color: _groen,
                                size: 17,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                klantNaam,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _groen,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '$aantal positie${aantal == 1 ? '' : 's'}',
                              style: const TextStyle(
                                color: _tekstGrijs,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: _groen,
                              size: 17,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
          actions: <Widget>[
            OutlinedButton(
              style: _secundaireDialoogKnopStijl(),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Annuleren'),
            ),
          ],
        );
      },
    );
  }

  Future<void> wisBestand() async {
    final huidigeContext = context;

    await OneDriveSyncService().slimmeSync();
    if (!isMounted()) return;

    final alleOpmetingen = await AppStorage.laadOpmetingen();
    if (!isMounted()) return;

    if (alleOpmetingen.isEmpty) {
      toonMelding('Er zijn nog geen opgeslagen opmeetbestanden.', true);
      return;
    }

    final klanten = _groepeerOpmetingenPerKlant(alleOpmetingen);
    final klantNamen = _gesorteerdeKlantNamen(klanten);
    final gekozenKlant = await _kiesKlantBestand(
      titel: 'Opmeetbestand wissen',
      klantNamen: klantNamen,
      klanten: klanten,
      wissen: true,
    );

    if (gekozenKlant == null || !isMounted()) return;
    if (!huidigeContext.mounted) return;

    final teWissenOpmetingen =
        klanten[gekozenKlant] ?? const <OpmetingOverzichtRaamItem>[];
    if (teWissenOpmetingen.isEmpty) {
      toonMelding('Dit bestand kon niet gevonden worden.', true);
      return;
    }

    final bevestigen = await showDialog<bool>(
      context: huidigeContext,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _rand),
          ),
          titlePadding: EdgeInsets.zero,
          title: _bouwBestandDialoogKop(
            titel: 'Bestand definitief wissen?',
            icoon: Icons.warning_amber_rounded,
            kleur: _rood,
          ),
          contentPadding: const EdgeInsets.fromLTRB(16, 15, 16, 4),
          content: SizedBox(
            width: 430,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7F7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(
                    color: _tekstDonker,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                  children: <InlineSpan>[
                    const TextSpan(text: 'Het volledige opmeetbestand '),
                    TextSpan(
                      text: '“$gekozenKlant”',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    TextSpan(
                      text:
                          ' en alle ${teWissenOpmetingen.length} positie(s) worden definitief verwijderd.',
                    ),
                  ],
                ),
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          actions: <Widget>[
            OutlinedButton(
              style: _secundaireDialoogKnopStijl(),
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Annuleren'),
            ),
            FilledButton(
              style: _primaireDialoogKnopStijl(kleur: _rood),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Definitief wissen'),
            ),
          ],
        );
      },
    );

    if (bevestigen != true) return;

    zetLaden(true);
    for (final opmeting in teWissenOpmetingen) {
      await AppStorage.verwijderOpmeting(opmeting.id);
    }

    await OneDriveSyncService.registreerLokaleWijziging();
    final syncResultaat = await OneDriveSyncService().slimmeSync();
    if (!isMounted()) return;

    final huidigeKlantNaam = leesKlantNaam();
    final gewisteKlantIsOpen =
        huidigeKlantNaam.trim().toLowerCase() ==
        gekozenKlant.trim().toLowerCase();

    if (gewisteKlantIsOpen) {
      artikelPrijscorrectieController.wisDoelSelecties();
      vervangProjectState(
        '',
        const OpmetingProjectTitelhoofd(),
        <OpmetingOverzichtRaamItem>[],
        <String>{},
        false,
      );
    } else {
      await laadOpmetingenVanOpslag(
        klantNaam: huidigeKlantNaam.trim().isEmpty ? null : huidigeKlantNaam,
      );
    }

    if (!isMounted()) return;

    final syncOk = _isSyncGeslaagd(syncResultaat);
    toonMelding(
      syncOk
          ? 'Opmeetbestand “$gekozenKlant” is gewist en gesynchroniseerd.'
          : 'Opmeetbestand “$gekozenKlant” is lokaal gewist, maar synchronisatie is niet gelukt: $syncResultaat',
      !syncOk,
    );
  }

  Future<bool> opslaanBestand({bool toonMeldingNaOpslaan = true}) async {
    final alleOpmetingen = await AppStorage.laadOpmetingenVoorSync();
    if (!isMounted()) return false;

    if (alleOpmetingen.isEmpty) {
      if (toonMeldingNaOpslaan) {
        toonMelding(
          'Er is nog geen opmeting om op te slaan. Voeg eerst een raamopmeting toe.',
          true,
        );
      }
      return false;
    }

    await AppStorage.bewaarOpmetingenVoorSync(alleOpmetingen);
    await OneDriveSyncService.registreerLokaleWijziging();
    final syncResultaat = await OneDriveSyncService().slimmeSync();
    if (!isMounted()) return false;

    final syncOk = _isSyncGeslaagd(syncResultaat);
    if (toonMeldingNaOpslaan) {
      toonMelding(
        syncOk
            ? 'Bestand opgeslagen en synchronisatie uitgevoerd.'
            : 'Bestand lokaal opgeslagen, maar synchronisatie is niet gelukt: $syncResultaat',
        !syncOk,
      );
    }

    return syncOk;
  }

  Future<bool> openOfferteVersieAlsWerkversie({
    required OpmetingProjectTitelhoofd versieTitelhoofd,
    required List<OpmetingOverzichtRaamItem> versiePosities,
    required String bronVersieId,
    required int bronVersieNummer,
  }) async {
    final huidigeKlantNaam = leesKlantNaam().trim();
    final klantNaam = huidigeKlantNaam.isNotEmpty
        ? huidigeKlantNaam
        : versieTitelhoofd.klantNaam.trim();

    if (klantNaam.isEmpty || versiePosities.isEmpty) {
      toonMelding(
        'Deze offerteversie bevat geen geldige projectgegevens.',
        true,
      );
      return false;
    }

    zetLaden(true);

    try {
      final alleOpmetingen = await AppStorage.laadOpmetingenVoorSync();
      final klantSleutel = klantNaam.toLowerCase();
      final versieIds = <String>{
        for (final positie in versiePosities)
          if (positie.id.trim().isNotEmpty) positie.id.trim(),
      };
      final nu = DateTime.now().toUtc().toIso8601String();
      final samengevoegd = <OpmetingOverzichtRaamItem>[];

      for (final bestaand in alleOpmetingen) {
        if (bestaand.klantNaam.trim().toLowerCase() != klantSleutel) {
          samengevoegd.add(bestaand);
          continue;
        }

        if (versieIds.contains(bestaand.id.trim())) {
          // De momentopname hieronder vervangt deze positie.
          continue;
        }

        if (bestaand.isVerwijderd) {
          samengevoegd.add(bestaand);
        } else {
          // Posities die niet in de gekozen historische versie staan, krijgen
          // een tombstone zodat ze na synchronisatie niet opnieuw verschijnen.
          samengevoegd.add(
            bestaand.copyWith(isVerwijderd: true, gewijzigdOp: nu),
          );
        }
      }

      final hersteldePosities = <OpmetingOverzichtRaamItem>[];
      for (var index = 0; index < versiePosities.length; index++) {
        final positie = versiePosities[index];
        final id = positie.id.trim().isEmpty
            ? 'offerteversie_${DateTime.now().microsecondsSinceEpoch}_$index'
            : positie.id.trim();
        hersteldePosities.add(
          positie.copyWith(
            id: id,
            klantNaam: klantNaam,
            isVerwijderd: false,
            gewijzigdOp: nu,
          ),
        );
      }
      samengevoegd.addAll(hersteldePosities);

      final hersteldTitelhoofd = versieTitelhoofd.copyWith(
        klantNaam: klantNaam,
        offerteBronVersieId: bronVersieId.trim(),
        offerteBronVersieNummer: bronVersieNummer,
        gewijzigdOp: nu,
      );

      await AppStorage.bewaarOpmetingenVoorSync(samengevoegd);
      await AppStorage.bewaarOpmetingProjectTitelhoofd(hersteldTitelhoofd);

      if (!isMounted()) return false;

      artikelPrijscorrectieController.wisDoelSelecties();
      vervangProjectState(
        klantNaam,
        hersteldTitelhoofd,
        hersteldePosities,
        <String>{},
        false,
      );

      toonMelding(
        'Offerteversie $bronVersieNummer is als nieuwe werkversie geopend. '
        'De historische versie zelf blijft ongewijzigd.',
        false,
      );
      return true;
    } catch (fout) {
      if (isMounted()) {
        zetLaden(false);
        toonMelding(
          'De offerteversie kon niet als werkversie worden geopend: $fout',
          true,
        );
      }
      return false;
    }
  }

  Future<void> markeerOfferteVersieAlsWerkBron({
    required String versieId,
    required int versieNummer,
  }) async {
    final huidigTitelhoofd = leesTitelhoofd();
    if (huidigTitelhoofd.klantNaam.trim().isEmpty) return;

    final bijgewerkt = huidigTitelhoofd
        .copyWith(
          offerteBronVersieId: versieId.trim(),
          offerteBronVersieNummer: versieNummer,
        )
        .metWijzigingsDatum();

    await AppStorage.bewaarOpmetingProjectTitelhoofd(bijgewerkt);
    if (!isMounted()) return;

    vervangProjectState(
      leesKlantNaam(),
      bijgewerkt,
      List<OpmetingOverzichtRaamItem>.from(leesOpmetingen()),
      Set<String>.from(leesVerborgenFormulierTypes()),
      false,
    );
  }

  bool _isSyncGeslaagd(String syncResultaat) {
    return !syncResultaat.startsWith('FOUT') &&
        !syncResultaat.contains('FOUT') &&
        !syncResultaat.contains('OVERGESLAGEN');
  }

  Future<void> eindeOpmeting() async {
    final huidigeContext = context;

    final heeftOpmetingen =
        leesOpmetingen().isNotEmpty ||
        (await AppStorage.laadOpmetingenVoorSync()).isNotEmpty;
    if (!isMounted()) return;
    if (!huidigeContext.mounted) return;

    if (!heeftOpmetingen) {
      await Navigator.of(huidigeContext).maybePop();
      return;
    }

    final keuze = await showDialog<String>(
      context: huidigeContext,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _rand),
          ),
          titlePadding: EdgeInsets.zero,
          title: _bouwBestandDialoogKop(
            titel: 'Opmeting beëindigen',
            icoon: Icons.home_outlined,
          ),
          contentPadding: const EdgeInsets.fromLTRB(16, 15, 16, 4),
          content: SizedBox(
            width: 430,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _rand),
              ),
              child: const Text(
                'Wil je het opmeetbestand opslaan en synchroniseren voordat je terugkeert naar Home?',
                style: TextStyle(
                  color: _tekstDonker,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: _tekstGrijs,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
              onPressed: () {
                Navigator.pop(dialogContext, 'annuleren');
              },
              child: const Text('Annuleren'),
            ),
            OutlinedButton(
              style: _secundaireDialoogKnopStijl(),
              onPressed: () {
                Navigator.pop(dialogContext, 'niet_opslaan');
              },
              child: const Text('Niet opslaan'),
            ),
            FilledButton(
              style: _primaireDialoogKnopStijl(),
              onPressed: () {
                Navigator.pop(dialogContext, 'opslaan');
              },
              child: const Text('Opslaan'),
            ),
          ],
        );
      },
    );

    if (keuze == null || keuze == 'annuleren') return;

    if (keuze == 'opslaan') {
      await opslaanBestand(toonMeldingNaOpslaan: false);
      if (!isMounted()) return;
    }

    if (!huidigeContext.mounted) return;
    await Navigator.of(huidigeContext).maybePop();
  }
}

class _NieuweOpmetingKlantResultaat {
  const _NieuweOpmetingKlantResultaat({
    required this.klantNaam,
    this.klantFiche,
  });

  final String klantNaam;
  final OpmetingAgendaKlantInfo? klantFiche;
}

class _KlantNaamDialog extends StatefulWidget {
  const _KlantNaamDialog({required this.beginNaam, required this.klanten});

  final String beginNaam;
  final List<OpmetingAgendaKlantInfo> klanten;

  @override
  State<_KlantNaamDialog> createState() {
    return _KlantNaamDialogState();
  }
}

class _KlantNaamDialogState extends State<_KlantNaamDialog> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _zachteGroeneRand = Color(0xFFB9E1C6);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _veldAchtergrond = Color(0xFFF8FAF9);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  late final TextEditingController _controller;
  late final FocusNode _naamFocusNode;
  OpmetingAgendaKlantInfo? _geselecteerdeKlant;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.beginNaam);
    _naamFocusNode = FocusNode();
    _geselecteerdeKlant = _vindExacteKlant(widget.beginNaam);
  }

  @override
  void dispose() {
    _naamFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  String _normaliseerZoektekst(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _klantWaarde(OpmetingAgendaKlantInfo klant) {
    return _normaliseerZoektekst(klant.klantNaam);
  }

  OpmetingAgendaKlantInfo? _vindExacteKlant(String waarde) {
    final sleutel = _normaliseerZoektekst(waarde);
    if (sleutel.isEmpty) return null;

    for (final klant in widget.klanten) {
      if (_klantWaarde(klant) == sleutel ||
          _normaliseerZoektekst(klant.klantNaamMetAanspreking) == sleutel) {
        return klant;
      }
    }

    return null;
  }

  Iterable<OpmetingAgendaKlantInfo> _bouwSuggesties(TextEditingValue invoer) {
    final zoektekst = _normaliseerZoektekst(invoer.text);
    if (zoektekst.isEmpty) {
      return const <OpmetingAgendaKlantInfo>[];
    }

    final zoekDelen = zoektekst.split(' ');
    final suggesties = widget.klanten.where((klant) {
      final zoekveld = _normaliseerZoektekst(
        <String>[
          klant.klantNaam,
          klant.klantNaamMetAanspreking,
          klant.klantnummer,
          klant.adresRegel,
          klant.plaats,
          klant.email,
        ].where((deel) => deel.trim().isNotEmpty).join(' '),
      );

      return zoekDelen.every(zoekveld.contains);
    }).toList();

    int score(OpmetingAgendaKlantInfo klant) {
      final naam = _klantWaarde(klant);
      if (naam == zoektekst) return 0;
      if (naam.startsWith(zoektekst)) return 1;
      if (naam.split(' ').any((deel) => deel.startsWith(zoektekst))) return 2;
      return 3;
    }

    suggesties.sort((eerste, tweede) {
      final scoreVergelijking = score(eerste).compareTo(score(tweede));
      if (scoreVergelijking != 0) return scoreVergelijking;

      return eerste.klantNaam.toLowerCase().compareTo(
        tweede.klantNaam.toLowerCase(),
      );
    });

    return suggesties.take(10);
  }

  String _klantSubtitel(OpmetingAgendaKlantInfo klant) {
    return <String>[
      klant.adresRegel,
      klant.plaats,
      if (klant.klantnummer.trim().isNotEmpty)
        'Klantnr. ${klant.klantnummer.trim()}',
    ].where((deel) => deel.trim().isNotEmpty).join(' · ');
  }

  void _selecteerKlant(OpmetingAgendaKlantInfo klant) {
    setState(() {
      _geselecteerdeKlant = klant;
      _controller.text = klant.klantNaam;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    });
  }

  void _verwerkNaamWijziging(String waarde) {
    final exacteKlant = _vindExacteKlant(waarde);
    if (identical(exacteKlant, _geselecteerdeKlant)) return;

    setState(() {
      _geselecteerdeKlant = exacteKlant;
    });
  }

  void _aanmaken() {
    final naam = _controller.text.trim();
    if (naam.isEmpty) return;

    final klantFiche = _vindExacteKlant(naam) ?? _geselecteerdeKlant;
    final gekozenNaam =
        klantFiche == null || klantFiche.klantNaam.trim().isEmpty
        ? naam
        : klantFiche.klantNaam.trim();

    Navigator.of(context).pop(
      _NieuweOpmetingKlantResultaat(
        klantNaam: gekozenNaam,
        klantFiche: klantFiche,
      ),
    );
  }

  InputDecoration _compacteVeldDecoratie({
    required String hintText,
    required IconData icoon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: _tekstGrijs,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(icoon, color: _tekstGrijs, size: 17),
      prefixIconConstraints: const BoxConstraints(minWidth: 37, minHeight: 38),
      isDense: true,
      filled: true,
      fillColor: _veldAchtergrond,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: _rand),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: _groen, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: _rand),
      ),
    );
  }

  Widget _veldTitel(String tekst) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 5),
      child: Text(
        tekst,
        style: const TextStyle(
          color: _groen,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final basisTheme = Theme.of(context);
    final geselecteerde = _geselecteerdeKlant;
    final adres = geselecteerde == null
        ? ''
        : <String>[
            geselecteerde.adresRegel,
            geselecteerde.plaats,
          ].where((deel) => deel.trim().isNotEmpty).join(', ');

    return Theme(
      data: basisTheme.copyWith(
        colorScheme: basisTheme.colorScheme.copyWith(
          primary: _groen,
          secondary: _groen,
          surface: Colors.white,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: _groen,
          selectionHandleColor: _groen,
        ),
      ),
      child: AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _rand),
        ),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.fromLTRB(16, 11, 12, 11),
          decoration: const BoxDecoration(
            color: _lichtGroen,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            border: Border(bottom: BorderSide(color: Color(0xFFCDEBD6))),
          ),
          child: const Row(
            children: <Widget>[
              Icon(Icons.note_add_outlined, color: _groen, size: 20),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Nieuw opmeetbestand',
                  style: TextStyle(
                    color: _groen,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _veldTitel('Klant uit klantenfiche of blauwe agenda'),
              DropdownButtonFormField<String>(
                initialValue: geselecteerde == null
                    ? null
                    : _klantWaarde(geselecteerde),
                isExpanded: true,
                menuMaxHeight: 420,
                style: const TextStyle(
                  color: _tekstDonker,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
                hint: Text(
                  widget.klanten.isEmpty
                      ? 'Geen klanten gevonden'
                      : 'Selecteer een klant',
                ),
                decoration: _compacteVeldDecoratie(
                  hintText: widget.klanten.isEmpty
                      ? 'Geen klanten gevonden'
                      : 'Selecteer een klant',
                  icoon: Icons.badge_outlined,
                ),
                items: widget.klanten
                    .map<DropdownMenuItem<String>>((klant) {
                      return DropdownMenuItem<String>(
                        value: _klantWaarde(klant),
                        child: Text(
                          klant.klantNaamMetAanspreking,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    })
                    .toList(growable: false),
                onChanged: widget.klanten.isEmpty
                    ? null
                    : (waarde) {
                        if (waarde == null) return;

                        final klant = widget.klanten.firstWhere(
                          (item) => _klantWaarde(item) == waarde,
                        );
                        _selecteerKlant(klant);
                      },
              ),
              const SizedBox(height: 11),
              _veldTitel('Naam klant'),
              LayoutBuilder(
                builder: (context, constraints) {
                  return RawAutocomplete<OpmetingAgendaKlantInfo>(
                    textEditingController: _controller,
                    focusNode: _naamFocusNode,
                    displayStringForOption: (klant) => klant.klantNaam,
                    optionsBuilder: _bouwSuggesties,
                    onSelected: _selecteerKlant,
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            autofocus: true,
                            cursorColor: _groen,
                            textCapitalization: TextCapitalization.words,
                            style: const TextStyle(
                              color: _tekstDonker,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: _compacteVeldDecoratie(
                              hintText: widget.klanten.isEmpty
                                  ? 'Typ een nieuwe klantnaam'
                                  : 'Typ enkele letters voor suggesties',
                              icoon: Icons.search_outlined,
                            ),
                            onChanged: _verwerkNaamWijziging,
                            onSubmitted: (_) {
                              _aanmaken();
                            },
                          );
                        },
                    optionsViewBuilder: (context, onSelected, opties) {
                      final suggesties = opties.toList(growable: false);

                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 8,
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox(
                            width: constraints.maxWidth,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 280),
                              child: ListView.separated(
                                padding: const EdgeInsets.all(5),
                                shrinkWrap: true,
                                itemCount: suggesties.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 4),
                                itemBuilder: (context, index) {
                                  final klant = suggesties[index];
                                  final gemarkeerd =
                                      AutocompleteHighlightedOption.of(
                                        context,
                                      ) ==
                                      index;
                                  final subtitel = _klantSubtitel(klant);

                                  return InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () => onSelected(klant),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: gemarkeerd
                                            ? _lichtGroen
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: _rand),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          const Padding(
                                            padding: EdgeInsets.only(top: 1),
                                            child: Icon(
                                              Icons.person_outline,
                                              color: _groen,
                                              size: 17,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  klant.klantNaamMetAanspreking,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: _tekstDonker,
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                if (subtitel
                                                    .isNotEmpty) ...<Widget>[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    subtitel,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: _tekstGrijs,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              if (geselecteerde != null) ...<Widget>[
                const SizedBox(height: 11),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: _veldAchtergrond,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: _rand),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(Icons.person_outline, color: _groen, size: 17),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              geselecteerde.klantNaamMetAanspreking,
                              style: const TextStyle(
                                color: _groen,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if (geselecteerde.klantnummer.trim().isNotEmpty)
                              Text(
                                'Klantnr. ${geselecteerde.klantnummer.trim()}',
                                style: const TextStyle(
                                  color: _tekstGrijs,
                                  fontSize: 11,
                                ),
                              ),
                            if (adres.isNotEmpty)
                              Text(
                                adres,
                                style: const TextStyle(
                                  color: _tekstGrijs,
                                  fontSize: 11,
                                ),
                              ),
                            if (geselecteerde.gsm.trim().isNotEmpty)
                              Text(
                                geselecteerde.gsm.trim(),
                                style: const TextStyle(
                                  color: _tekstGrijs,
                                  fontSize: 11,
                                ),
                              ),
                            if (geselecteerde.email.trim().isNotEmpty)
                              Text(
                                geselecteerde.email.trim(),
                                style: const TextStyle(
                                  color: _tekstGrijs,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        actions: <Widget>[
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: _groen,
              backgroundColor: Colors.white,
              side: const BorderSide(color: _zachteGroeneRand),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Annuleren'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _groen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
            onPressed: _aanmaken,
            child: const Text('Aanmaken'),
          ),
        ],
      ),
    );
  }
}
