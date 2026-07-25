import 'package:flutter/material.dart';

import '../../../paginas/instellingen/offerte_prijzen/offerte_algemene_prijsregel_dialog.dart';
import '../../app_storage.dart';
import '../../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../../sync/onedrive_sync_service.dart';
import '../offerte_controller.dart';
import 'offerte_algemeen_artikel_prijs_service.dart';
import 'offerte_algemene_prijsregel_model.dart';
import 'offerte_algemene_prijsregel_toepassen_op_dialog.dart';
import 'offerte_algemene_prijsregels_model.dart';
import 'offerte_artikel_prijs_koppeling_service.dart';
import 'offerte_automatische_prijsregel_sync_service.dart';
import 'offerte_prijs_categorie.dart';
import 'offerte_prijsregel_model.dart';
import 'offerte_verdeelkost_service.dart';

class OfferteAlgemenePrijsregelToepassenController {
  const OfferteAlgemenePrijsregelToepassenController({
    required this.context,
    required this.offerteController,
    required this.isMounted,
    required this.leesArtikelen,
    required this.vervangArtikelen,
    required this.herberekenPrijsMomentopnames,
    required this.toonMelding,
  });

  static const OfferteAutomatischePrijsregelSyncService
  _automatischePrijsregelSyncService =
      OfferteAutomatischePrijsregelSyncService();

  final BuildContext context;
  final OfferteController offerteController;
  final bool Function() isMounted;

  final List<OpmetingOverzichtRaamItem> Function() leesArtikelen;

  final void Function(List<OpmetingOverzichtRaamItem> artikelen)
  vervangArtikelen;

  final Future<void> Function(String klantNaam) herberekenPrijsMomentopnames;

  final void Function(String tekst, bool fout) toonMelding;

  Future<void> openSelectieVenster() async {
    try {
      String? initielePrijsregelId;

      OfferteAlgemenePrijsregelModel? tijdelijkePrijsregel;

      while (isMounted() && context.mounted) {
        final opslag = await AppStorage.laadOfferteAlgemenePrijsregels();

        if (!isMounted() || !context.mounted) {
          return;
        }

        final prijsregels = opslag.prijsregels
            .where(
              (prijsregel) =>
                  prijsregel.actief &&
                  prijsregel.isGeldig &&
                  prijsregel.prijsExclBtw > 0,
            )
            .toList(growable: true);

        final tijdelijkeRegel = tijdelijkePrijsregel;

        if (tijdelijkeRegel != null &&
            tijdelijkeRegel.actief &&
            tijdelijkeRegel.isGeldig &&
            tijdelijkeRegel.prijsExclBtw > 0 &&
            !prijsregels.any(
              (prijsregel) => prijsregel.id == tijdelijkeRegel.id,
            )) {
          prijsregels.add(tijdelijkeRegel);
        }

        prijsregels.sort((eerste, tweede) {
          final volgordeVergelijking = eerste.volgorde.compareTo(
            tweede.volgorde,
          );

          if (volgordeVergelijking != 0) {
            return volgordeVergelijking;
          }

          return eerste.omschrijving.toLowerCase().compareTo(
            tweede.omschrijving.toLowerCase(),
          );
        });

        if (prijsregels.isEmpty) {
          final afhandeling = await _maakNieuwePrijsregelVanuitOverzicht(
            opslag: opslag,
          );

          if (!isMounted() || !context.mounted) {
            return;
          }

          if (afhandeling == null) {
            return;
          }

          if (!afhandeling.openArtikelSelectie) {
            return;
          }

          tijdelijkePrijsregel = afhandeling.bewaardInInstellingen
              ? null
              : afhandeling.prijsregel;

          initielePrijsregelId = afhandeling.prijsregel.id;

          continue;
        }

        final actueleArtikelen = leesArtikelen();

        final groepen = _bouwGroepen(
          artikelen: actueleArtikelen,
          prijsregels: prijsregels,
        );

        if (!context.mounted) {
          return;
        }

        final resultaat = await toonOfferteAlgemenePrijsregelToepassenDialog(
          context: context,
          prijsregels: prijsregels,
          groepen: groepen,
          initielePrijsregelId: initielePrijsregelId,
        );

        if (resultaat == null || !isMounted() || !context.mounted) {
          return;
        }

        if (resultaat.actie ==
            OfferteAlgemenePrijsregelToepassenActie.nieuwePrijsregelToevoegen) {
          final afhandeling = await _maakNieuwePrijsregelVanuitOverzicht(
            opslag: opslag,
          );

          if (!isMounted() || !context.mounted) {
            return;
          }

          if (afhandeling == null) {
            continue;
          }

          if (!afhandeling.openArtikelSelectie) {
            return;
          }

          tijdelijkePrijsregel = afhandeling.bewaardInInstellingen
              ? null
              : afhandeling.prijsregel;

          initielePrijsregelId = afhandeling.prijsregel.id;

          continue;
        }

        final prijsregel = resultaat.prijsregel;

        if (prijsregel == null) {
          continue;
        }

        final geselecteerdeArtikelen = actueleArtikelen
            .where((artikel) => resultaat.artikelIds.contains(artikel.id))
            .toList(growable: false);

        final maximumControle = _controleerMaximum(
          prijsregel: prijsregel,
          artikelen: geselecteerdeArtikelen,
        );

        if (!maximumControle.toegelaten) {
          toonMelding(
            'Prijsregel “${prijsregel.omschrijving}” werd niet '
            'toegepast. De totale basisartikelwaarde van '
            '${_bedragTekst(maximumControle.totaleBasisArtikelwaarde)} '
            'is hoger dan het ingestelde maximum van '
            '${_bedragTekst(prijsregel.maximaleTotaleStukprijs)}.',
            true,
          );

          initielePrijsregelId = prijsregel.id;

          continue;
        }

        final toegepast = await _pasHandmatigePrijsregelToe(
          prijsregel: prijsregel,
          artikelIds: resultaat.artikelIds,
          toonMeldingNaToepassen:
              resultaat.actie ==
              OfferteAlgemenePrijsregelToepassenActie.toepassenOpOfferte,
        );

        if (!toegepast || !isMounted()) {
          return;
        }

        if (resultaat.actie ==
            OfferteAlgemenePrijsregelToepassenActie
                .toepassenEnNogEenPrijsregelKiezen) {
          initielePrijsregelId = prijsregel.id;

          continue;
        }

        return;
      }
    } catch (e) {
      if (!isMounted()) {
        return;
      }

      toonMelding(
        'De algemene prijsregels konden niet worden toegepast: $e',
        true,
      );
    }
  }

  Future<_NieuwePrijsregelAfhandeling?> _maakNieuwePrijsregelVanuitOverzicht({
    required OfferteAlgemenePrijsregelsModel opslag,
  }) async {
    if (!context.mounted) {
      return null;
    }

    final nieuwePrijsregel = await toonOfferteAlgemenePrijsregelDialog(
      context: context,
      volgendeVolgorde: _volgendeVolgorde(opslag),
    );

    if (nieuwePrijsregel == null || !isMounted() || !context.mounted) {
      return null;
    }

    final actie = await _kiesNieuwePrijsregelActie(
      prijsregel: nieuwePrijsregel,
    );

    if (actie == null || !isMounted() || !context.mounted) {
      return null;
    }

    switch (actie) {
      case _NieuweAlgemenePrijsregelActie.toepassenOpOfferte:
        return _NieuwePrijsregelAfhandeling(
          prijsregel: nieuwePrijsregel,
          openArtikelSelectie: true,
          bewaardInInstellingen: false,
        );

      case _NieuweAlgemenePrijsregelActie.toepassenOpOfferteEnBewaren:
        final bewaard = await _bewaarNieuwePrijsregel(
          opslag: opslag,
          prijsregel: nieuwePrijsregel,
        );

        if (!bewaard || !isMounted()) {
          return null;
        }

        return _NieuwePrijsregelAfhandeling(
          prijsregel: nieuwePrijsregel,
          openArtikelSelectie: true,
          bewaardInInstellingen: true,
        );

      case _NieuweAlgemenePrijsregelActie.enkelBewaren:
        final bewaard = await _bewaarNieuwePrijsregel(
          opslag: opslag,
          prijsregel: nieuwePrijsregel,
        );

        if (!bewaard) {
          return null;
        }

        if (isMounted()) {
          toonMelding(
            'Prijsregel “${nieuwePrijsregel.omschrijving}” werd '
            'bewaard en nog niet op de offerte toegepast.',
            false,
          );
        }

        return _NieuwePrijsregelAfhandeling(
          prijsregel: nieuwePrijsregel,
          openArtikelSelectie: false,
          bewaardInInstellingen: true,
        );
    }
  }

  Future<_NieuweAlgemenePrijsregelActie?> _kiesNieuwePrijsregelActie({
    required OfferteAlgemenePrijsregelModel prijsregel,
  }) {
    return showDialog<_NieuweAlgemenePrijsregelActie>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: <Widget>[
              Icon(Icons.rule_folder_outlined, color: Color(0xFF0B7A3B)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Wat wilt u met deze prijsregel doen?',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F6EC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBBE4C9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          prijsregel.omschrijving,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${_bedragTekst(prijsregel.prijsExclBtw)} '
                          'excl. btw · ${prijsregel.eenheid.benaming}',
                          style: const TextStyle(
                            color: Color(0xFF0B7A3B),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _NieuwePrijsregelActieTegel(
                    icoon: Icons.check_circle_outline_rounded,
                    titel: 'Toepassen op offerte',
                    uitleg:
                        'De prijsregel wordt niet in Instellingen '
                        'bewaard. Hierna opent opnieuw het venster '
                        '“Prijsregel toepassen op…”. Daar kiest u '
                        'zelf de gewenste artikelen.',
                    onTap: () {
                      Navigator.pop(
                        dialogContext,
                        _NieuweAlgemenePrijsregelActie.toepassenOpOfferte,
                      );
                    },
                  ),
                  const SizedBox(height: 9),
                  _NieuwePrijsregelActieTegel(
                    icoon: Icons.save_as_outlined,
                    titel: 'Toepassen op offerte en bewaren',
                    uitleg:
                        'De prijsregel wordt eerst centraal bewaard. '
                        'Daarna opent de artikelselectie met deze '
                        'nieuwe prijsregel reeds geselecteerd.',
                    onTap: () {
                      Navigator.pop(
                        dialogContext,
                        _NieuweAlgemenePrijsregelActie
                            .toepassenOpOfferteEnBewaren,
                      );
                    },
                  ),
                  const SizedBox(height: 9),
                  _NieuwePrijsregelActieTegel(
                    icoon: Icons.save_outlined,
                    titel: 'Enkel bewaren',
                    uitleg:
                        'De prijsregel wordt toegevoegd aan '
                        'Instellingen, maar nog niet op artikelen '
                        'van deze offerte toegepast.',
                    onTap: () {
                      Navigator.pop(
                        dialogContext,
                        _NieuweAlgemenePrijsregelActie.enkelBewaren,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Annuleren',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _bewaarNieuwePrijsregel({
    required OfferteAlgemenePrijsregelsModel opslag,
    required OfferteAlgemenePrijsregelModel prijsregel,
  }) async {
    try {
      final bijgewerkt = opslag.metPrijsregel(prijsregel).metWijzigingsDatum();

      await AppStorage.bewaarOfferteAlgemenePrijsregels(bijgewerkt);

      return true;
    } catch (e) {
      if (isMounted()) {
        toonMelding(
          'De nieuwe algemene prijsregel kon niet worden '
          'bewaard: $e',
          true,
        );
      }

      return false;
    }
  }

  int _volgendeVolgorde(OfferteAlgemenePrijsregelsModel opslag) {
    var hoogsteVolgorde = -1;

    for (final prijsregel in opslag.prijsregels) {
      if (prijsregel.volgorde > hoogsteVolgorde) {
        hoogsteVolgorde = prijsregel.volgorde;
      }
    }

    return hoogsteVolgorde + 1;
  }

  Future<bool> synchroniseerAutomatischePrijsregels({
    bool toonMeldingNaSynchroniseren = false,
  }) async {
    try {
      final opslag = await AppStorage.laadOfferteAlgemenePrijsregels();

      if (!isMounted()) {
        return false;
      }

      final resultaat = _automatischePrijsregelSyncService.synchroniseer(
        artikelen: leesArtikelen(),
        prijsregels: opslag.prijsregels,
      );

      if (!resultaat.gewijzigd) {
        return false;
      }

      if (!isMounted()) {
        return false;
      }

      vervangArtikelen(resultaat.artikelen);

      final gewijzigdeArtikelen = resultaat.artikelen
          .where(
            (artikel) => resultaat.gewijzigdeArtikelIds.contains(artikel.id),
          )
          .toList(growable: false);

      await _bewaarGewijzigdeArtikelen(gewijzigdeArtikelen);

      if (toonMeldingNaSynchroniseren && isMounted()) {
        final delen = <String>[];

        if (resultaat.toegevoegdAantal > 0) {
          delen.add(
            resultaat.toegevoegdAantal == 1
                ? '1 automatische toepassing toegevoegd'
                : '${resultaat.toegevoegdAantal} automatische '
                      'toepassingen toegevoegd',
          );
        }

        if (resultaat.verwijderdAantal > 0) {
          delen.add(
            resultaat.verwijderdAantal == 1
                ? '1 automatische toepassing verwijderd'
                : '${resultaat.verwijderdAantal} automatische '
                      'toepassingen verwijderd',
          );
        }

        if (delen.isNotEmpty) {
          toonMelding(
            'Algemene prijsregels bijgewerkt: '
            '${delen.join(' en ')}.',
            false,
          );
        }
      }

      return true;
    } catch (e) {
      if (isMounted()) {
        toonMelding(
          'De automatische algemene prijsregels konden niet '
          'worden bijgewerkt: $e',
          true,
        );
      }

      return false;
    }
  }

  Future<bool> pasAutomatischePrijsregelsToe() {
    return synchroniseerAutomatischePrijsregels();
  }

  Future<bool> _pasHandmatigePrijsregelToe({
    required OfferteAlgemenePrijsregelModel prijsregel,
    required Set<String> artikelIds,
    required bool toonMeldingNaToepassen,
  }) async {
    if (prijsregel.uitschrijfmodus.isVerdeeldeInterneKost) {
      return _pasHandmatigeVerdeelkostToe(
        prijsregel: prijsregel,
        artikelIds: artikelIds,
        toonMeldingNaToepassen: toonMeldingNaToepassen,
      );
    }

    final nieuweLijst = List<OpmetingOverzichtRaamItem>.from(leesArtikelen());

    final gewijzigdeArtikelIds = <String>{};

    var toegepastAantal = 0;
    var verwijderdAantal = 0;

    for (var index = 0; index < nieuweLijst.length; index++) {
      final huidig = nieuweLijst[index];

      final koppeling =
          OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(huidig);

      final huidigePrijsData =
          OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(huidig);

      if (koppeling == null || huidigePrijsData == null) {
        continue;
      }

      final prijsregelToegelaten = _prijsregelIsToegelatenVoor(
        prijsregel: prijsregel,
        formulierType: koppeling.formulierType,
      );

      final reedsToegepast =
          OfferteAlgemeenArtikelPrijsService.heeftGekozenProjectPrijsregel(
            prijsData: huidigePrijsData,
            oorspronkelijkPrijsregelId: prijsregel.id,
            doelFormulierType: koppeling.formulierType,
          );

      final artikelActief = !huidig.isVerwijderd && !huidig.isNietRekenen;

      final moetToegepastZijn =
          artikelActief &&
          prijsregelToegelaten &&
          artikelIds.contains(huidig.id);

      if (!moetToegepastZijn && !reedsToegepast) {
        continue;
      }

      final bijgewerktePrijsData = moetToegepastZijn
          ? OfferteAlgemeenArtikelPrijsService.voegGekozenProjectPrijsregelToe(
              prijsData: huidigePrijsData,
              prijsregel: _naarArtikelPrijsregel(
                prijsregel: prijsregel,
                formulierType: koppeling.formulierType,
              ),
              doelFormulierType: koppeling.formulierType,
            )
          : OfferteAlgemeenArtikelPrijsService.verwijderGekozenProjectPrijsregel(
              prijsData: huidigePrijsData,
              oorspronkelijkPrijsregelId: prijsregel.id,
              doelFormulierType: koppeling.formulierType,
            );

      final bijgewerkt = OfferteArtikelPrijsKoppelingService.schrijfPrijsData(
        artikel: huidig,
        prijsData: bijgewerktePrijsData,
      ).metNieuweWijzigingsDatum();

      nieuweLijst[index] = bijgewerkt;
      gewijzigdeArtikelIds.add(bijgewerkt.id);

      if (moetToegepastZijn) {
        toegepastAantal++;
      } else {
        verwijderdAantal++;
      }
    }

    if (gewijzigdeArtikelIds.isEmpty) {
      if (isMounted()) {
        toonMelding(
          'De gekozen selectie bevatte geen toepasbare '
          'wijzigingen.',
          true,
        );
      }

      return false;
    }

    if (!isMounted()) {
      return false;
    }

    vervangArtikelen(nieuweLijst);

    final gewijzigdeArtikelen = nieuweLijst
        .where((artikel) => gewijzigdeArtikelIds.contains(artikel.id))
        .toList(growable: false);

    await _bewaarGewijzigdeArtikelen(gewijzigdeArtikelen);

    if (toonMeldingNaToepassen && isMounted()) {
      final toegepastTekst = toegepastAantal == 1
          ? '1 positie'
          : '$toegepastAantal posities';

      final verwijderdTekst = verwijderdAantal == 1
          ? '1 eerdere positie verwijderd'
          : '$verwijderdAantal eerdere posities verwijderd';

      toonMelding(
        verwijderdAantal > 0
            ? 'Prijsregel “${prijsregel.omschrijving}” '
                  'bijgewerkt: $toegepastTekst geselecteerd '
                  'en $verwijderdTekst.'
            : 'Prijsregel “${prijsregel.omschrijving}” '
                  'toegepast op $toegepastTekst.',
        false,
      );
    }

    return true;
  }

  Future<bool> _pasHandmatigeVerdeelkostToe({
    required OfferteAlgemenePrijsregelModel prijsregel,
    required Set<String> artikelIds,
    required bool toonMeldingNaToepassen,
  }) async {
    final huidigeLijst = List<OpmetingOverzichtRaamItem>.from(leesArtikelen());

    final geselecteerdeArtikelen = huidigeLijst
        .where((artikel) {
          if (!artikelIds.contains(artikel.id) ||
              artikel.isVerwijderd ||
              artikel.isNietRekenen ||
              !artikel.teltMeeInHoofdofferte) {
            return false;
          }

          final koppeling =
              OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(artikel);

          if (koppeling == null) {
            return false;
          }

          return _prijsregelIsToegelatenVoor(
            prijsregel: prijsregel,
            formulierType: koppeling.formulierType,
          );
        })
        .toList(growable: false);

    if (geselecteerdeArtikelen.isEmpty) {
      if (isMounted()) {
        toonMelding(
          'Selecteer minstens één actief hoofdartikel '
          'voor deze verdeelkost.',
          true,
        );
      }

      return false;
    }

    final bronArtikel = geselecteerdeArtikelen.first;

    final bronKoppeling =
        OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(bronArtikel);

    final klantNaam = bronArtikel.klantNaam.trim();

    if (bronKoppeling == null || klantNaam.isEmpty) {
      if (isMounted()) {
        toonMelding(
          'De verdeelkost kon niet aan de gekozen '
          'artikelen worden gekoppeld.',
          true,
        );
      }

      return false;
    }

    final artikelPrijsregel = _naarArtikelPrijsregel(
      prijsregel: prijsregel,
      formulierType: bronKoppeling.formulierType,
    );

    final resultaat =
        OfferteVerdeelkostService.stelGeselecteerdeProjectVerdeelkostDoelenIn(
          alleOpmetingen: huidigeLijst,
          klantNaam: klantNaam,
          prijsregel: artikelPrijsregel,
          artikelIds: geselecteerdeArtikelen
              .map((artikel) => artikel.id)
              .toSet(),
        );

    if (!resultaat.gewijzigd) {
      if (isMounted()) {
        toonMelding(
          'De verdeelkost bevatte geen nieuwe '
          'toepasbare wijziging.',
          true,
        );
      }

      return false;
    }

    if (!isMounted()) {
      return false;
    }

    vervangArtikelen(resultaat.opmetingen);

    final oudeWijzigingsdatums = <String, String>{
      for (final artikel in huidigeLijst) artikel.id: artikel.gewijzigdOp,
    };

    final gewijzigdeArtikelen = resultaat.opmetingen
        .where((artikel) {
          return oudeWijzigingsdatums[artikel.id] != artikel.gewijzigdOp;
        })
        .toList(growable: false);

    await _bewaarGewijzigdeArtikelen(gewijzigdeArtikelen);

    if (toonMeldingNaToepassen && isMounted()) {
      final aantal = geselecteerdeArtikelen.length;

      toonMelding(
        'Verdeelkost “${prijsregel.omschrijving}” '
        'gekoppeld aan '
        '${aantal == 1 ? '1 positie' : '$aantal posities'}.',
        false,
      );
    }

    return true;
  }

  Future<void> _bewaarGewijzigdeArtikelen(
    List<OpmetingOverzichtRaamItem> gewijzigdeArtikelen,
  ) async {
    if (gewijzigdeArtikelen.isEmpty) {
      return;
    }

    final uniekeArtikelen = <String, OpmetingOverzichtRaamItem>{};

    for (final artikel in gewijzigdeArtikelen) {
      uniekeArtikelen[artikel.id] = artikel;
    }

    for (final artikel in uniekeArtikelen.values) {
      await AppStorage.werkOpmetingBij(artikel);
    }

    await OneDriveSyncService.registreerLokaleWijziging();

    OneDriveSyncService().uploadBackupOpAchtergrond();

    final klantNaam = uniekeArtikelen.values
        .map((artikel) => artikel.klantNaam.trim())
        .firstWhere((naam) => naam.isNotEmpty, orElse: () => '');

    if (klantNaam.isNotEmpty) {
      await herberekenPrijsMomentopnames(klantNaam);
    }
  }

  _MaximumPrijsregelControle _controleerMaximum({
    required OfferteAlgemenePrijsregelModel prijsregel,
    required Iterable<OpmetingOverzichtRaamItem> artikelen,
  }) {
    final totaleBasisArtikelwaarde = _berekenTotaleBasisArtikelwaarde(
      artikelen,
    );

    if (!prijsregel.uitschrijfmodus.isVerdeeldeInterneKost) {
      return _MaximumPrijsregelControle(
        toegelaten: true,
        totaleBasisArtikelwaarde: totaleBasisArtikelwaarde,
      );
    }

    final maximum = prijsregel.maximaleTotaleStukprijs;

    if (maximum <= 0) {
      return _MaximumPrijsregelControle(
        toegelaten: true,
        totaleBasisArtikelwaarde: totaleBasisArtikelwaarde,
      );
    }

    return _MaximumPrijsregelControle(
      toegelaten: totaleBasisArtikelwaarde <= maximum + 0.000001,
      totaleBasisArtikelwaarde: totaleBasisArtikelwaarde,
    );
  }

  double _berekenTotaleBasisArtikelwaarde(
    Iterable<OpmetingOverzichtRaamItem> artikelen,
  ) {
    var totaal = 0.0;

    for (final artikel in artikelen) {
      if (artikel.isVerwijderd || artikel.isNietRekenen) {
        continue;
      }

      final prijsData =
          OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(artikel);

      if (prijsData == null) {
        continue;
      }

      final prijsPerStuk = prijsData.prijsPerStukExclBtw;

      final aantal = OfferteArtikelPrijsKoppelingService.aantalVoorArtikel(
        artikel,
      );

      if (!prijsPerStuk.isFinite || prijsPerStuk < 0 || aantal <= 0) {
        continue;
      }

      totaal += prijsPerStuk * aantal;
    }

    return _rondBedragAf(totaal);
  }

  List<OfferteAlgemenePrijsregelToepassenGroep> _bouwGroepen({
    required List<OpmetingOverzichtRaamItem> artikelen,
    required List<OfferteAlgemenePrijsregelModel> prijsregels,
  }) {
    final actieveArtikelen = artikelen
        .where((artikel) {
          return !artikel.isVerwijderd &&
              !artikel.isNietRekenen &&
              OfferteArtikelPrijsKoppelingService.isOndersteundArtikel(artikel);
        })
        .toList(growable: false);

    final positieLabels = offerteController.positiesService
        .maakBronPositieLabels(artikelen);

    final positiesPerSleutel =
        <String, List<OfferteAlgemenePrijsregelToepassenPositie>>{};

    final eersteIndexPerSleutel = <String, int>{};

    for (var index = 0; index < actieveArtikelen.length; index++) {
      final artikel = actieveArtikelen[index];

      final koppeling =
          OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(artikel);

      final prijsData =
          OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(artikel);

      if (koppeling == null || prijsData == null) {
        continue;
      }

      final sleutel = _normaliseerFormulierType(koppeling.formulierType);

      eersteIndexPerSleutel.putIfAbsent(sleutel, () => index);

      final bedragenPerPrijsregelId = <String, double>{};

      final toegepastePrijsregelIds = <String>{};

      for (final prijsregel in prijsregels) {
        if (!_prijsregelIsToegelatenVoor(
          prijsregel: prijsregel,
          formulierType: koppeling.formulierType,
        )) {
          continue;
        }

        final artikelPrijsregel = _naarArtikelPrijsregel(
          prijsregel: prijsregel,
          formulierType: koppeling.formulierType,
        );

        bedragenPerPrijsregelId[prijsregel.id] =
            OfferteAlgemeenArtikelPrijsService.berekenPrijsregelTotaalExclBtw(
              prijsregel: artikelPrijsregel,
              aantal: OfferteArtikelPrijsKoppelingService.aantalVoorArtikel(
                artikel,
              ),
              breedteMm:
                  OfferteArtikelPrijsKoppelingService.breedteMmVoorArtikel(
                    artikel,
                  ),
              hoogteMm: OfferteArtikelPrijsKoppelingService.hoogteMmVoorArtikel(
                artikel,
              ),
            );

        if (OfferteAlgemeenArtikelPrijsService.heeftGekozenProjectPrijsregel(
          prijsData: prijsData,
          oorspronkelijkPrijsregelId: prijsregel.id,
          doelFormulierType: koppeling.formulierType,
        )) {
          toegepastePrijsregelIds.add(prijsregel.id);
        }
      }

      positiesPerSleutel
          .putIfAbsent(
            sleutel,
            () => <OfferteAlgemenePrijsregelToepassenPositie>[],
          )
          .add(
            OfferteAlgemenePrijsregelToepassenPositie(
              artikelId: artikel.id,
              positieLabel: positieLabels[artikel.id] ?? 'Positie ${index + 1}',
              artikelLabel: _artikelKeuzeOmschrijving(artikel),
              bedragenPerPrijsregelId: Map<String, double>.unmodifiable(
                bedragenPerPrijsregelId,
              ),
              toegepastePrijsregelIds: Set<String>.unmodifiable(
                toegepastePrijsregelIds,
              ),
            ),
          );
    }

    final aanwezigeGroepen = <OfferteAlgemenePrijsregelToepassenGroep>[];

    final overigeGroepen = <OfferteAlgemenePrijsregelToepassenGroep>[];

    for (final koppeling
        in OfferteArtikelPrijsKoppelingService.alleKoppelingen) {
      final sleutel = _normaliseerFormulierType(koppeling.formulierType);

      final groep = OfferteAlgemenePrijsregelToepassenGroep(
        formulierType: koppeling.formulierType,
        label: koppeling.formulierNaam,
        posities: List<OfferteAlgemenePrijsregelToepassenPositie>.unmodifiable(
          positiesPerSleutel[sleutel] ??
              const <OfferteAlgemenePrijsregelToepassenPositie>[],
        ),
      );

      if (groep.isAanwezigInOfferte) {
        aanwezigeGroepen.add(groep);
      } else {
        overigeGroepen.add(groep);
      }
    }

    aanwezigeGroepen.sort((eerste, tweede) {
      final eersteIndex =
          eersteIndexPerSleutel[_normaliseerFormulierType(
            eerste.formulierType,
          )] ??
          999999;

      final tweedeIndex =
          eersteIndexPerSleutel[_normaliseerFormulierType(
            tweede.formulierType,
          )] ??
          999999;

      return eersteIndex.compareTo(tweedeIndex);
    });

    return List<OfferteAlgemenePrijsregelToepassenGroep>.unmodifiable(
      <OfferteAlgemenePrijsregelToepassenGroep>[
        ...aanwezigeGroepen,
        ...overigeGroepen,
      ],
    );
  }

  OffertePrijsregelModel _naarArtikelPrijsregel({
    required OfferteAlgemenePrijsregelModel prijsregel,
    required String formulierType,
  }) {
    return OffertePrijsregelModel(
      id: prijsregel.id,
      categorie: OffertePrijsCategorie.vrijPerArtikel,
      formulierType: formulierType,
      omschrijving: prijsregel.omschrijving,
      prijsExclBtw: prijsregel.prijsExclBtw,
      eenheid: prijsregel.eenheid,
      uitschrijfmodus: prijsregel.uitschrijfmodus,
      actief: prijsregel.actief,
      volgorde: prijsregel.volgorde,
      gewijzigdOp: prijsregel.gewijzigdOp,
    );
  }

  bool _prijsregelIsToegelatenVoor({
    required OfferteAlgemenePrijsregelModel prijsregel,
    required String formulierType,
  }) {
    final doelSleutel = _normaliseerFormulierType(formulierType);

    return prijsregel.toepasselijkeFormulierTypes.any(
      (type) => _normaliseerFormulierType(type) == doelSleutel,
    );
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

    final basis = aantal > 1 ? '$aantal stuks · $maat' : maat;

    return artikel.isOfferteOptie ? 'Optie · $basis' : basis;
  }

  static double _rondBedragAf(double bedrag) {
    if (!bedrag.isFinite || bedrag <= 0) {
      return 0;
    }

    return (bedrag * 100).roundToDouble() / 100;
  }

  static String _bedragTekst(double bedrag) {
    final veiligBedrag = bedrag.isFinite && bedrag >= 0 ? bedrag : 0.0;

    return '€ ${veiligBedrag.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  static String _normaliseerFormulierType(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }
}

enum _NieuweAlgemenePrijsregelActie {
  toepassenOpOfferte,
  toepassenOpOfferteEnBewaren,
  enkelBewaren,
}

class _NieuwePrijsregelAfhandeling {
  const _NieuwePrijsregelAfhandeling({
    required this.prijsregel,
    required this.openArtikelSelectie,
    required this.bewaardInInstellingen,
  });

  final OfferteAlgemenePrijsregelModel prijsregel;
  final bool openArtikelSelectie;
  final bool bewaardInInstellingen;
}

class _NieuwePrijsregelActieTegel extends StatelessWidget {
  const _NieuwePrijsregelActieTegel({
    required this.icoon,
    required this.titel,
    required this.uitleg,
    required this.onTap,
  });

  final IconData icoon;
  final String titel;
  final String uitleg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F6EC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icoon, color: const Color(0xFF0B7A3B), size: 20),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      titel,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      uitleg,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 11.5,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MaximumPrijsregelControle {
  const _MaximumPrijsregelControle({
    required this.toegelaten,
    required this.totaleBasisArtikelwaarde,
  });

  final bool toegelaten;
  final double totaleBasisArtikelwaarde;
}
