// THIMACO-CONTROLE: TOEBEHOREN-PROJECTKLEUR-SYNC-SCHUIFVLIEGENDEUR-20260728
import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_storage.dart';
import '../../sync/onedrive_sync_service.dart';
import '../overzicht/opmeting_overzicht_model.dart';
import '../toebehoren/vaste_inzethor/opmeting_vaste_inzethor_model.dart';
import '../toebehoren/schuifvliegendeur/opmeting_schuifvliegendeur_technische_regels_helpers.dart';
import '../toebehoren/vliegendeur/opmeting_vliegendeur_model.dart';
import 'opmeting_project_titelhoofd_kaart.dart';
import 'opmeting_project_titelhoofd_model.dart';

class OpmetingProjectTitelhoofdController {
  OpmetingProjectTitelhoofdController({
    required this.context,
    required this.isMounted,
    required this.leesKlantNaam,
    required this.leesTitelhoofd,
    required this.leesOpmetingen,
    required this.vervangProjectState,
    required this.herlaadOpmetingen,
    required this.toonMelding,
  });

  final BuildContext context;
  final bool Function() isMounted;
  final String Function() leesKlantNaam;
  final OpmetingProjectTitelhoofd Function() leesTitelhoofd;
  final List<OpmetingOverzichtRaamItem> Function() leesOpmetingen;
  final void Function(
    OpmetingProjectTitelhoofd titelhoofd,
    String klantNaam,
    List<OpmetingOverzichtRaamItem> opmetingen,
  )
  vervangProjectState;
  final Future<void> Function(String klantNaam) herlaadOpmetingen;
  final void Function(String tekst, bool fout) toonMelding;

  Timer? _bewaarTimer;

  void dispose() {
    _bewaarTimer?.cancel();
  }

  String normaliseerKlantNaam(String waarde) {
    return opmetingKlantNaamSleutel(waarde);
  }

  Future<OpmetingProjectTitelhoofd> vulAanUitKlantenfiche({
    required String klantNaam,
    required OpmetingProjectTitelhoofd basis,
  }) async {
    final sleutel = normaliseerKlantNaam(klantNaam);

    if (sleutel.isEmpty) {
      return basis;
    }

    final klanten = await AppStorage.laadKlantenVoorOpmeting();
    OpmetingAgendaKlantInfo? gevonden;

    for (final klant in klanten) {
      if (normaliseerKlantNaam(klant.klantNaam) == sleutel) {
        gevonden = klant;
        break;
      }
    }

    if (gevonden == null) {
      return basis.klantNaam.trim().isEmpty
          ? basis.copyWith(klantNaam: klantNaam.trim())
          : basis;
    }

    String behoudOfVul(String bestaand, String bron) {
      return bestaand.trim().isNotEmpty ? bestaand : bron.trim();
    }

    return basis.copyWith(
      aanspreking: behoudOfVul(basis.aanspreking, gevonden.aanspreking),
      klantNaam: behoudOfVul(basis.klantNaam, gevonden.klantNaam),
      klantnummer: behoudOfVul(basis.klantnummer, gevonden.klantnummer),
      contactpersoon: behoudOfVul(
        basis.contactpersoon,
        gevonden.contactpersoon,
      ),
      adres: behoudOfVul(basis.adres, gevonden.adres),
      huisnummer: behoudOfVul(basis.huisnummer, gevonden.huisnummer),
      busNummer: behoudOfVul(basis.busNummer, gevonden.busNummer),
      postcode: behoudOfVul(basis.postcode, gevonden.postcode),
      gemeente: behoudOfVul(basis.gemeente, gevonden.gemeente),
      gsm: behoudOfVul(basis.gsm, gevonden.gsm),
      telefoon: behoudOfVul(basis.telefoon, gevonden.telefoon),
      email: behoudOfVul(basis.email, gevonden.email),
    );
  }

  void verwerkWijziging(OpmetingProjectTitelhoofd titelhoofd) {
    final bestaandeKlantNaam = leesKlantNaam().trim();
    final huidigTitelhoofd = leesTitelhoofd();
    final nieuweKlantNaam = titelhoofd.klantNaam.trim();
    final berekeningWerdAangezet =
        !huidigTitelhoofd.berekenPrijzen && titelhoofd.berekenPrijzen;
    final ralKleurToebehorenGewijzigd =
        huidigTitelhoofd.ralKleurToebehoren.trim() !=
        titelhoofd.ralKleurToebehoren.trim();

    final naamVoorBestand = nieuweKlantNaam.isNotEmpty
        ? nieuweKlantNaam
        : bestaandeKlantNaam;
    final titelhoofdVoorState = titelhoofd.copyWith(
      gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
    );

    var bijgewerkteOpmetingen = List<OpmetingOverzichtRaamItem>.from(
      leesOpmetingen(),
    );

    if (naamVoorBestand.isNotEmpty && naamVoorBestand != bestaandeKlantNaam) {
      bijgewerkteOpmetingen = bijgewerkteOpmetingen
          .map((item) {
            return item
                .copyWith(klantNaam: naamVoorBestand)
                .metNieuweWijzigingsDatum();
          })
          .toList(growable: false);
    }

    if (ralKleurToebehorenGewijzigd) {
      bijgewerkteOpmetingen = synchroniseerProjectkleurInToebehorenPosities(
        bijgewerkteOpmetingen,
        klantNaam: naamVoorBestand,
        projectkleur: titelhoofdVoorState.ralKleurToebehoren,
      ).opmetingen;
    }

    vervangProjectState(
      titelhoofdVoorState,
      naamVoorBestand,
      bijgewerkteOpmetingen,
    );

    _bewaarTimer?.cancel();
    _bewaarTimer = Timer(const Duration(milliseconds: 700), () {
      unawaited(_bewaarTitelhoofdOpAchtergrond(titelhoofdVoorState));
    });

    if (ralKleurToebehorenGewijzigd) {
      unawaited(_bewaarRalKleurToebehorenInPosities());
    }

    if (berekeningWerdAangezet && naamVoorBestand.isNotEmpty) {
      unawaited(_activeerPrijsberekening(titelhoofdVoorState));
    }
  }

  ({List<OpmetingOverzichtRaamItem> opmetingen, bool gewijzigd})
  synchroniseerProjectkleurInToebehorenPosities(
    Iterable<OpmetingOverzichtRaamItem> opmetingen, {
    required String klantNaam,
    required String projectkleur,
  }) {
    final klantSleutel = klantNaam.trim().toLowerCase();
    final netteProjectkleur = projectkleur.trim();
    final resultaat = <OpmetingOverzichtRaamItem>[];
    var gewijzigd = false;

    for (final item in opmetingen) {
      final hoortBijActieveKlant =
          klantSleutel.isNotEmpty &&
          !item.isVerwijderd &&
          item.klantNaam.trim().toLowerCase() == klantSleutel;

      if (!hoortBijActieveKlant) {
        resultaat.add(item);
        continue;
      }

      var bijgewerktItem = item;
      var itemGewijzigd = false;

      final vasteInzethor = bijgewerktItem.vasteInzethorData;
      if (vasteInzethor?.isProjectkleur == true) {
        final bijgewerktModel =
            vasteInzethor!.ralKleurToebehorenWaarde.trim() == netteProjectkleur
            ? vasteInzethor
            : vasteInzethor.copyWith(
                ralKleurToebehorenWaarde: netteProjectkleur,
              );
        final bijgewerkteTechnischeRegels =
            _werkProjectkleurBijInTechnischeRegels(
              bijgewerktItem.technischeRegels,
              projectkleur: netteProjectkleur,
            );
        final technischeRegelsGewijzigd = !_zijnTechnischeRegelsGelijk(
          bijgewerktItem.technischeRegels,
          bijgewerkteTechnischeRegels,
        );

        if (!identical(bijgewerktModel, vasteInzethor) ||
            technischeRegelsGewijzigd) {
          bijgewerktItem = bijgewerktItem.copyWith(
            vasteInzethorData: bijgewerktModel,
            technischeRegels: bijgewerkteTechnischeRegels,
          );
          itemGewijzigd = true;
        }
      }

      final vliegendeur = bijgewerktItem.vliegendeurData;
      if (vliegendeur?.isProjectKleur == true) {
        final bijgewerkteTechnischeRegels =
            _werkVliegendeurProjectkleurBijInTechnischeRegels(
              bijgewerktItem.technischeRegels,
              projectkleur: netteProjectkleur,
            );

        if (!_zijnTechnischeRegelsGelijk(
          bijgewerktItem.technischeRegels,
          bijgewerkteTechnischeRegels,
        )) {
          bijgewerktItem = bijgewerktItem.copyWith(
            technischeRegels: bijgewerkteTechnischeRegels,
          );
          itemGewijzigd = true;
        }
      }

      final schuifvliegendeur = bijgewerktItem.schuifvliegendeurData;
      if (schuifvliegendeur?.gebruiktProjectKleur == true) {
        final bijgewerktModel =
            schuifvliegendeur!.ralKleurToebehorenWaarde.trim() ==
                netteProjectkleur
            ? schuifvliegendeur
            : schuifvliegendeur.copyWith(
                ralKleurToebehorenWaarde: netteProjectkleur,
              );
        final bijgewerkteTechnischeRegels =
            OpmetingSchuifvliegendeurTechnischeRegelsHelper.bouw(
              bijgewerktModel,
            );
        final technischeRegelsGewijzigd = !_zijnTechnischeRegelsGelijk(
          bijgewerktItem.technischeRegels,
          bijgewerkteTechnischeRegels,
        );

        if (!identical(bijgewerktModel, schuifvliegendeur) ||
            technischeRegelsGewijzigd) {
          bijgewerktItem = bijgewerktItem.copyWith(
            schuifvliegendeurData: bijgewerktModel,
            technischeRegels: bijgewerkteTechnischeRegels,
          );
          itemGewijzigd = true;
        }
      }

      if (!itemGewijzigd) {
        resultaat.add(item);
        continue;
      }

      gewijzigd = true;
      resultaat.add(bijgewerktItem.metNieuweWijzigingsDatum());
    }

    return (
      opmetingen: List<OpmetingOverzichtRaamItem>.unmodifiable(resultaat),
      gewijzigd: gewijzigd,
    );
  }

  /// Behoudt de bestaande publieke methode voor code die deze naam al gebruikt.
  ({List<OpmetingOverzichtRaamItem> opmetingen, bool gewijzigd})
  synchroniseerProjectkleurInVasteInzethorPosities(
    Iterable<OpmetingOverzichtRaamItem> opmetingen, {
    required String klantNaam,
    required String projectkleur,
  }) {
    return synchroniseerProjectkleurInToebehorenPosities(
      opmetingen,
      klantNaam: klantNaam,
      projectkleur: projectkleur,
    );
  }

  List<OpmetingOverzichtTechnischeRegel>
  _werkVliegendeurProjectkleurBijInTechnischeRegels(
    List<OpmetingOverzichtTechnischeRegel> technischeRegels, {
    required String projectkleur,
  }) {
    final waarde = projectkleur.trim().isEmpty
        ? OpmetingVliegendeurModel.kleurNogTeBepalen
        : projectkleur.trim();
    final resultaat = <OpmetingOverzichtTechnischeRegel>[];
    var kleurRegelToegevoegd = false;

    for (final regel in technischeRegels) {
      final titelSleutel = _normaliseerTechnischeRegelTitelVoorProjectkleur(
        regel.titel,
      );

      if (titelSleutel != 'kleur') {
        resultaat.add(regel);
        continue;
      }

      if (!kleurRegelToegevoegd) {
        resultaat.add(
          OpmetingOverzichtTechnischeRegel(
            titel: regel.titel.trim().isEmpty ? 'Kleur' : regel.titel,
            waarde: waarde,
          ),
        );
        kleurRegelToegevoegd = true;
      }
    }

    if (!kleurRegelToegevoegd) {
      resultaat.add(
        OpmetingOverzichtTechnischeRegel(titel: 'Kleur', waarde: waarde),
      );
    }

    return List<OpmetingOverzichtTechnischeRegel>.unmodifiable(resultaat);
  }

  List<OpmetingOverzichtTechnischeRegel> _werkProjectkleurBijInTechnischeRegels(
    List<OpmetingOverzichtTechnischeRegel> technischeRegels, {
    required String projectkleur,
  }) {
    final waarde = projectkleur.trim().isEmpty
        ? 'Nog niet ingevuld'
        : projectkleur.trim();
    final resultaat = <OpmetingOverzichtTechnischeRegel>[];
    var kleurRegelToegevoegd = false;

    for (final regel in technischeRegels) {
      final titelSleutel = _normaliseerTechnischeRegelTitelVoorProjectkleur(
        regel.titel,
      );
      final isProjectkleurRegel = const <String>{
        'kleur',
        'projectkleur',
        'ralkleurtoebehoren',
      }.contains(titelSleutel);

      if (!isProjectkleurRegel) {
        resultaat.add(regel);
        continue;
      }

      if (!kleurRegelToegevoegd) {
        resultaat.add(
          OpmetingOverzichtTechnischeRegel(
            titel: OpmetingVasteInzethorModel.kleurProjectLabel,
            waarde: waarde,
          ),
        );
        kleurRegelToegevoegd = true;
      }
    }

    if (!kleurRegelToegevoegd) {
      resultaat.add(
        OpmetingOverzichtTechnischeRegel(
          titel: OpmetingVasteInzethorModel.kleurProjectLabel,
          waarde: waarde,
        ),
      );
    }

    return List<OpmetingOverzichtTechnischeRegel>.unmodifiable(resultaat);
  }

  bool _zijnTechnischeRegelsGelijk(
    List<OpmetingOverzichtTechnischeRegel> eerste,
    List<OpmetingOverzichtTechnischeRegel> tweede,
  ) {
    if (eerste.length != tweede.length) {
      return false;
    }

    for (var index = 0; index < eerste.length; index++) {
      if (eerste[index].titel != tweede[index].titel ||
          eerste[index].waarde != tweede[index].waarde) {
        return false;
      }
    }

    return true;
  }

  String _normaliseerTechnischeRegelTitelVoorProjectkleur(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  Future<void> _bewaarRalKleurToebehorenInPosities() async {
    final bijgewerktPerId = <String, OpmetingOverzichtRaamItem>{
      for (final item in leesOpmetingen())
        if (item.vasteInzethorData?.isRalKleurToebehoren == true ||
            item.vliegendeurData?.isProjectKleur == true ||
            item.schuifvliegendeurData?.gebruiktProjectKleur == true)
          item.id: item,
    };

    if (bijgewerktPerId.isEmpty) {
      return;
    }

    final alleOpmetingen = await AppStorage.laadOpmetingenVoorSync();
    var gewijzigd = false;

    final resultaat = alleOpmetingen
        .map((item) {
          final bijgewerkt = bijgewerktPerId[item.id];
          if (bijgewerkt == null) {
            return item;
          }

          final oudeVasteInzethorWaarde =
              item.vasteInzethorData?.ralKleurToebehorenWaarde.trim() ?? '';
          final nieuweVasteInzethorWaarde =
              bijgewerkt.vasteInzethorData?.ralKleurToebehorenWaarde.trim() ??
              '';
          final oudeSchuifvliegendeurWaarde =
              item.schuifvliegendeurData?.ralKleurToebehorenWaarde.trim() ?? '';
          final nieuweSchuifvliegendeurWaarde =
              bijgewerkt.schuifvliegendeurData?.ralKleurToebehorenWaarde
                  .trim() ??
              '';
          final technischeRegelsZijnGelijk = _zijnTechnischeRegelsGelijk(
            item.technischeRegels,
            bijgewerkt.technischeRegels,
          );

          if (oudeVasteInzethorWaarde == nieuweVasteInzethorWaarde &&
              oudeSchuifvliegendeurWaarde == nieuweSchuifvliegendeurWaarde &&
              technischeRegelsZijnGelijk) {
            return item;
          }

          gewijzigd = true;
          return bijgewerkt;
        })
        .toList(growable: false);

    if (!gewijzigd) {
      return;
    }

    await AppStorage.bewaarOpmetingenVoorSync(resultaat);
    await OneDriveSyncService.registreerLokaleWijziging();
    OneDriveSyncService().uploadBackupOpAchtergrond();
  }

  Future<void> _activeerPrijsberekening(
    OpmetingProjectTitelhoofd titelhoofd,
  ) async {
    await AppStorage.bewaarOpmetingProjectTitelhoofd(titelhoofd);

    if (!isMounted()) {
      return;
    }

    await herlaadOpmetingen(titelhoofd.klantNaam);
  }

  Future<void> _bewaarTitelhoofdOpAchtergrond(
    OpmetingProjectTitelhoofd titelhoofd,
  ) async {
    final klantNaam = titelhoofd.klantNaam.trim();

    if (klantNaam.isEmpty) {
      return;
    }

    await AppStorage.bewaarOpmetingProjectTitelhoofd(titelhoofd);

    final opmetingen = leesOpmetingen();
    if (opmetingen.isNotEmpty) {
      final ids = opmetingen.map((item) => item.id).toSet();
      final alleOpmetingen = await AppStorage.laadOpmetingenVoorSync();
      var gewijzigd = false;

      final bijgewerkteOpmetingen = alleOpmetingen
          .map((item) {
            if (!ids.contains(item.id) || item.klantNaam == klantNaam) {
              return item;
            }

            gewijzigd = true;
            return item
                .copyWith(klantNaam: klantNaam)
                .metNieuweWijzigingsDatum();
          })
          .toList(growable: false);

      if (gewijzigd) {
        await AppStorage.bewaarOpmetingenVoorSync(bijgewerkteOpmetingen);
        await OneDriveSyncService.registreerLokaleWijziging();
        OneDriveSyncService().uploadBackupOpAchtergrond();
      }
    }
  }

  Future<List<OpmetingAgendaKlantInfo>>
  _laadBlauweAgendaKlantenMetFicheAanvulling() async {
    final agendaKlanten = await AppStorage.laadAgendaKlantenVoorOpmeting();
    final klantenFiches = await AppStorage.laadKlantenVoorOpmeting();
    final perKlant = <String, OpmetingAgendaKlantInfo>{};

    void voegToe(OpmetingAgendaKlantInfo klant) {
      final sleutel = normaliseerKlantNaam(klant.klantNaam);
      if (sleutel.isEmpty) return;
      final bestaand = perKlant[sleutel];
      perKlant[sleutel] = bestaand == null
          ? klant
          : bestaand.combineerMet(klant);
    }

    for (final klant in agendaKlanten) {
      voegToe(klant);
    }
    for (final klant in klantenFiches) {
      voegToe(klant);
    }

    final resultaat = perKlant.values.toList()
      ..sort((eerste, tweede) {
        return eerste.klantNaamMetAanspreking.toLowerCase().compareTo(
          tweede.klantNaamMetAanspreking.toLowerCase(),
        );
      });

    return resultaat;
  }

  Future<void> laadKlantUitBlauweAgenda() async {
    final klanten = await _laadBlauweAgendaKlantenMetFicheAanvulling();

    if (!isMounted()) {
      return;
    }
    if (!context.mounted) {
      return;
    }

    if (klanten.isEmpty) {
      toonMelding('Geen klanten gevonden in de blauwe agenda.', true);
      return;
    }

    final keuze = await toonOpmetingAgendaKlantKeuzeDialog(
      context: context,
      klanten: klanten,
    );

    if (keuze == null || !isMounted()) {
      return;
    }

    final bestaand = await AppStorage.laadOpmetingProjectTitelhoofd(
      keuze.klantNaam,
    );
    final titelhoofd = keuze
        .naarTitelhoofd(bestaand: bestaand, overschrijfKlantnummer: true)
        .copyWith(
          aanspreking: keuze.aanspreking,
          klantNaam: opmetingKlantNaamZonderAanspreking(keuze.klantNaam),
        )
        .metWijzigingsDatum();

    await AppStorage.bewaarOpmetingProjectTitelhoofd(titelhoofd);

    if (!isMounted()) {
      return;
    }

    vervangProjectState(
      titelhoofd,
      keuze.klantNaam,
      List<OpmetingOverzichtRaamItem>.from(leesOpmetingen()),
    );

    await herlaadOpmetingen(keuze.klantNaam);

    if (isMounted()) {
      toonMelding('Klantgegevens geladen uit de blauwe agenda.', false);
    }
  }
}
