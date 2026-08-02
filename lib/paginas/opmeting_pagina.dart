// THIMACO-CONTROLE: ALGEMENE-OPMETING-BOVENBALK-ACTIES-20260801
// THIMACO-CONTROLE: ALGEMENE-OPMETING-HOOFDPAGINA-20260801
// THIMACO-CONTROLE: UITVALSCHERM-HOOFDPAGINA-20260801
// THIMACO-CONTROLE: ONEDRIVE-KLANTDOCUMENTEN-STAP-2-20260731
// THIMACO-CONTROLE: GENEREREN-OFFERTE-OPMETING-20260731
// THIMACO-CONTROLE: VOORZETROLLUIK-MENU-NAVIGATIE-20260731-1025
// THIMACO-CONTROLE: VELUX-GEEN-ONTERECHTE-PRIJSWAARSCHUWING-20260730
// THIMACO-CONTROLE: VELUX-DAKRAMEN-OPMETING-PAGINA-FASE-1-2-20260729-2030
// THIMACO-CONTROLE: SEKTIONALE-POORTEN-HOOFDPAGINA-20260729
// THIMACO-CONTROLE: PLOOIWERKEN-CENTRALE-PAGINA-KOPPELING-20260728
// THIMACO-CONTROLE: SCHUIFVLIEGENDEUR-CENTRALE-PAGINA-KOPPELING-20260728
// THIMACO-CONTROLE: BESTAANDE-PROJECTPRIJSREGEL-ROUTE-20260725
import 'package:flutter/material.dart';

import '../helpers/app_storage.dart';
import '../helpers/offerte/offerte_controller.dart';
import '../helpers/offerte/offerte_validatie_service.dart';
import '../helpers/offerte/offerte_pdf_preview_pagina.dart';
import '../helpers/offerte/opmeting_pdf_preview_pagina.dart';
import 'offerte_prijs_overzicht_pagina.dart';
import '../helpers/offerte/prijzen/offerte_artikel_prijs_koppeling_service.dart';
import '../helpers/offerte/prijzen/offerte_artikel_prijscorrectie_controller.dart';
import '../helpers/offerte/prijzen/offerte_project_prijsregel_controller.dart';
import '../helpers/offerte/prijzen/offerte_prijsinstellingen_controller.dart';
import '../helpers/sync/onedrive_klantdocument_service.dart';
import '../helpers/sync/onedrive_sync_service.dart';
import '../helpers/opmeting/overzicht/opmeting_overzicht_model.dart';
import '../helpers/offerte/artikelen/offerte_artikel_register.dart';
import '../helpers/offerte/artikelen/offerte_positie_beheer_controller.dart';
import '../helpers/opmeting/overzicht/opmeting_overzicht_bovenbalk.dart';
import '../helpers/opmeting/overzicht/opmeting_overzicht_lijst.dart';
import '../helpers/opmeting/project/opmeting_project_kleur_model.dart';
import '../helpers/opmeting/project/opmeting_project_titelhoofd_model.dart'
    show OpmetingProjectTitelhoofd;
import '../helpers/opmeting/project/opmeting_project_titelhoofd_controller.dart';
import '../helpers/opmeting/project/opmeting_project_bestand_controller.dart';
import '../helpers/opmeting/navigatie/opmeting_formulier_navigatie_controller.dart';

class OpmetingPagina extends StatefulWidget {
  const OpmetingPagina({super.key});

  @override
  State<OpmetingPagina> createState() {
    return _OpmetingPaginaState();
  }
}

class _OpmetingPaginaState extends State<OpmetingPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  String _klantNaam = '';
  bool _laden = false;

  final List<OpmetingOverzichtRaamItem> _raamOpmetingen =
      <OpmetingOverzichtRaamItem>[];

  OpmetingProjectTitelhoofd _projectTitelhoofd =
      const OpmetingProjectTitelhoofd();

  List<OpmetingProjectKleurSubmenu> _projectKleurMenus =
      <OpmetingProjectKleurSubmenu>[];

  Set<String> _verborgenFormulierTypes = <String>{};
  Set<String> _verborgenNietRekenenPositieIds = <String>{};

  final OfferteController _offerteController = OfferteController.standaard();

  late final OffertePrijsinstellingenController _prijsinstellingenController;

  late final OfferteArtikelPrijscorrectieController
  _artikelPrijscorrectieController;

  late final OfferteProjectPrijsregelController _projectPrijsregelController;

  late final OffertePositieBeheerController _positieBeheerController;

  late final OpmetingProjectTitelhoofdController _projectTitelhoofdController;

  late final OpmetingProjectBestandController _projectBestandController;

  late final OpmetingFormulierNavigatieController _formulierNavigatieController;

  bool get _heeftOpenBestand {
    return _klantNaam.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();

    _prijsinstellingenController = OffertePrijsinstellingenController(
      context: context,
      isMounted: () => mounted,
      leesIsLaden: () => _laden,
      leesHeeftOpenBestand: () => _heeftOpenBestand,
      leesKlantNaam: () => _klantNaam,
      leesTitelhoofd: () => _projectTitelhoofd,
      herlaadOpmetingen: (klantNaam, forceerPrijsinstellingen) {
        return _projectBestandController.laadOpmetingenVanOpslag(
          klantNaam: klantNaam,
          forceerPrijsinstellingen: forceerPrijsinstellingen,
        );
      },
      toonMelding: (tekst, fout) {
        _toonMelding(tekst, fout: fout);
      },
      onHerberekeningStatusGewijzigd: () {
        if (!mounted) {
          return;
        }

        setState(() {});
      },
    );

    _artikelPrijscorrectieController = OfferteArtikelPrijscorrectieController(
      context: context,
      offerteController: _offerteController,
      isMounted: () => mounted,
      leesArtikelen: () => _raamOpmetingen,
      vervangArtikelen: (artikelen) {
        if (!mounted) {
          return;
        }

        setState(() {
          _raamOpmetingen
            ..clear()
            ..addAll(artikelen);
        });
      },
      herberekenPrijsMomentopnames: (klantNaam) {
        return _herberekenPrijsMomentopnamesNaPrijswijziging(
          klantNaam: klantNaam,
        );
      },
      onDoelSelectieGewijzigd: () {
        if (!mounted) {
          return;
        }

        setState(() {});
      },
    );

    _projectPrijsregelController = OfferteProjectPrijsregelController(
      context: context,
      offerteController: _offerteController,
      isMounted: () => mounted,
      leesArtikelen: () => _raamOpmetingen,
      leesTitelhoofd: () => _projectTitelhoofd,
      leesKlantNaam: () => _klantNaam,
      laadPrijsprofiel:
          _prijsinstellingenController.laadPrijsprofielVoorFormulierType,
      maakPrijsinstellingenMomentopname:
          _prijsinstellingenController.maakPrijsinstellingenMomentopname,
      herberekenPrijsMomentopnames: (klantNaam) {
        return _herberekenPrijsMomentopnamesNaPrijswijziging(
          klantNaam: klantNaam,
        );
      },
      vervangArtikelen: (artikelen) {
        if (!mounted) {
          return;
        }

        setState(() {
          _raamOpmetingen
            ..clear()
            ..addAll(artikelen);
        });
      },
      vervangTitelhoofd: (titelhoofd) {
        if (!mounted) {
          return;
        }

        setState(() {
          _projectTitelhoofd = titelhoofd;
        });
      },
      toonMelding: (tekst, fout) {
        _toonMelding(tekst, fout: fout);
      },
    );

    _positieBeheerController = OffertePositieBeheerController(
      context: context,
      offerteController: _offerteController,
      isMounted: () => mounted,
      leesArtikelen: () => _raamOpmetingen,
      leesKlantNaam: () => _klantNaam,
      herlaadOpmetingen: (klantNaam) {
        return _projectBestandController.laadOpmetingenVanOpslag(
          klantNaam: klantNaam,
        );
      },
      herberekenPrijsMomentopnames: (klantNaam) {
        return _herberekenPrijsMomentopnamesNaPrijswijziging(
          klantNaam: klantNaam,
        );
      },
      verplaatsArtikelLokaal: (huidigeIndex, nieuweIndex) {
        if (!mounted) {
          return;
        }

        setState(() {
          final opmeting = _raamOpmetingen.removeAt(huidigeIndex);
          _raamOpmetingen.insert(nieuweIndex, opmeting);
        });
      },
      toonMelding: (tekst) {
        _toonMelding(tekst);
      },
    );

    _projectTitelhoofdController = OpmetingProjectTitelhoofdController(
      context: context,
      isMounted: () => mounted,
      leesKlantNaam: () => _klantNaam,
      leesTitelhoofd: () => _projectTitelhoofd,
      leesOpmetingen: () => _raamOpmetingen,
      vervangProjectState: (titelhoofd, klantNaam, opmetingen) {
        if (!mounted) {
          return;
        }

        setState(() {
          _klantNaam = klantNaam;
          _projectTitelhoofd = titelhoofd;
          _raamOpmetingen
            ..clear()
            ..addAll(opmetingen);
        });
      },
      herlaadOpmetingen: (klantNaam) {
        return _projectBestandController.laadOpmetingenVanOpslag(
          klantNaam: klantNaam,
        );
      },
      toonMelding: (tekst, fout) {
        _toonMelding(tekst, fout: fout);
      },
    );

    _projectBestandController = OpmetingProjectBestandController(
      context: context,
      isMounted: () => mounted,
      leesKlantNaam: () => _klantNaam,
      leesTitelhoofd: () => _projectTitelhoofd,
      leesOpmetingen: () => _raamOpmetingen,
      leesVerborgenFormulierTypes: () => _verborgenFormulierTypes,
      prijsinstellingenController: _prijsinstellingenController,
      projectTitelhoofdController: _projectTitelhoofdController,
      artikelPrijscorrectieController: _artikelPrijscorrectieController,
      vervangProjectState:
          (klantNaam, titelhoofd, opmetingen, verborgenFormulierTypes, laden) {
            if (!mounted) {
              return;
            }

            setState(() {
              _klantNaam = klantNaam;
              _projectTitelhoofd = titelhoofd;
              _raamOpmetingen
                ..clear()
                ..addAll(opmetingen);
              _verborgenFormulierTypes = verborgenFormulierTypes;
              _verborgenNietRekenenPositieIds = <String>{};
              _laden = laden;
            });
          },
      vervangProjectKleuren: (kleuren) {
        if (!mounted) {
          return;
        }

        setState(() {
          _projectKleurMenus = kleuren;
        });
      },
      zetLaden: (laden) {
        if (!mounted) {
          return;
        }

        setState(() {
          _laden = laden;
        });
      },
      toonMelding: (tekst, fout) {
        _toonMelding(tekst, fout: fout);
      },
    );

    _formulierNavigatieController = OpmetingFormulierNavigatieController(
      context: context,
      isMounted: () => mounted,
      leesKlantNaam: () => _klantNaam,
      leesTitelhoofd: () => _projectTitelhoofd,
      zorgVoorActieveKlant: _projectBestandController.zorgVoorActieveKlant,
      laadVasteInzethorPrijsprofiel:
          _prijsinstellingenController.laadVasteInzethorPrijsprofiel,
      herlaadOpmetingen: (klantNaam) {
        return _projectBestandController.laadOpmetingenVanOpslag(
          klantNaam: klantNaam,
        );
      },
    );

    _projectBestandController.laadProjectKleuren();
    _prijsinstellingenController.startAutomatischeControle();
  }

  @override
  void dispose() {
    _projectTitelhoofdController.dispose();
    _artikelPrijscorrectieController.dispose();
    _prijsinstellingenController.dispose();
    super.dispose();
  }

  Future<void> _openRaamopmeting({String formulierType = 'pvcRaam'}) {
    return _formulierNavigatieController.openRaamopmeting(
      formulierType: formulierType,
    );
  }

  Future<void> _openVasteInzethor({
    OpmetingOverzichtRaamItem? bestaandeOpmeting,
  }) {
    return _formulierNavigatieController.openVasteInzethor(
      bestaandeOpmeting: bestaandeOpmeting,
    );
  }

  Future<void> _openVliegendeur({
    OpmetingOverzichtRaamItem? bestaandeOpmeting,
  }) {
    return _formulierNavigatieController.openVliegendeur(
      bestaandeOpmeting: bestaandeOpmeting,
    );
  }

  Future<void> _openSchuifvliegendeur({
    OpmetingOverzichtRaamItem? bestaandeOpmeting,
  }) {
    return _formulierNavigatieController.openSchuifvliegendeur(
      bestaandeOpmeting: bestaandeOpmeting,
    );
  }

  Future<void> _openPlooiwerken({
    OpmetingOverzichtRaamItem? bestaandeOpmeting,
  }) {
    return _formulierNavigatieController.openPlooiwerken(
      bestaandeOpmeting: bestaandeOpmeting,
    );
  }

  Future<void> _openVoorzetscreen({
    OpmetingOverzichtRaamItem? bestaandeOpmeting,
  }) {
    return _formulierNavigatieController.openVoorzetscreen(
      bestaandeOpmeting: bestaandeOpmeting,
    );
  }

  Future<void> _openVoorzetrolluik({
    OpmetingOverzichtRaamItem? bestaandeOpmeting,
  }) {
    return _formulierNavigatieController.openVoorzetrolluik(
      bestaandeOpmeting: bestaandeOpmeting,
    );
  }

  Future<void> _openUitvalscherm({
    OpmetingOverzichtRaamItem? bestaandeOpmeting,
  }) {
    return _formulierNavigatieController.openUitvalscherm(
      bestaandeOpmeting: bestaandeOpmeting,
    );
  }

  Future<void> _openAlgemeneOpmeting({
    OpmetingOverzichtRaamItem? bestaandeOpmeting,
  }) {
    return _formulierNavigatieController.openAlgemeneOpmeting(
      bestaandeOpmeting: bestaandeOpmeting,
    );
  }

  Future<void> _openSektionalePoort({
    OpmetingOverzichtRaamItem? bestaandeOpmeting,
  }) {
    return _formulierNavigatieController.openSektionalePoort(
      bestaandeOpmeting: bestaandeOpmeting,
    );
  }

  Future<void> _openVeluxDakraam({
    OpmetingOverzichtRaamItem? bestaandeOpmeting,
  }) {
    return _formulierNavigatieController.openVeluxDakraam(
      bestaandeOpmeting: bestaandeOpmeting,
    );
  }

  Future<void> _openVrijePrijsPerArtikelVenster(
    OpmetingOverzichtRaamItem item, {
    required String positieLabel,
  }) {
    return _projectPrijsregelController.openVrijePrijsPerArtikelVenster(
      item,
      positieLabel: positieLabel,
    );
  }

  Future<void> _openPrijsVoorAlleArtikelenVenster() {
    return _projectPrijsregelController.openPrijsVoorAlleArtikelenVenster();
  }

  Future<void> _herberekenPrijsMomentopnamesNaPrijswijziging({
    required String klantNaam,
  }) async {
    if (!_projectTitelhoofd.berekenPrijzen || klantNaam.trim().isEmpty) {
      return;
    }

    final alleOpmetingen = await AppStorage.laadOpmetingenVoorSync();

    final resultaat = await _prijsinstellingenController
        .werkTechnischePrijsMomentopnamesBij(
          alleOpmetingen: alleOpmetingen,
          klantNaam: klantNaam,
          berekenPrijzen: true,
          tijdelijkeProjectPrijsregels:
              _projectTitelhoofd.tijdelijkeProjectPrijsregels,
        );

    if (!resultaat.gewijzigd) {
      return;
    }

    await AppStorage.bewaarOpmetingenVoorSync(resultaat.opmetingen);
    await OneDriveSyncService.registreerLokaleWijziging();
    OneDriveSyncService().uploadBackupOpAchtergrond();

    if (!mounted ||
        _klantNaam.trim().toLowerCase() != klantNaam.trim().toLowerCase()) {
      return;
    }

    final klantSleutel = klantNaam.trim().toLowerCase();

    final zichtbareOpmetingen = resultaat.opmetingen
        .where((opmeting) {
          return !opmeting.isVerwijderd &&
              opmeting.klantNaam.trim().toLowerCase() == klantSleutel;
        })
        .toList(growable: false);

    setState(() {
      _raamOpmetingen
        ..clear()
        ..addAll(zichtbareOpmetingen);
    });
  }

  Future<void> _bewerkRaamopmeting(OpmetingOverzichtRaamItem item) async {
    if (item.isNietRekenen) {
      _toonMelding(
        'Deze groep staat op “niet rekenen”. Zet de groep eerst opnieuw actief '
        'om ze aan te passen.',
      );
      return;
    }

    await _formulierNavigatieController.bewerkOpmeting(item);
  }

  Future<void> _verwijderRaamopmeting(OpmetingOverzichtRaamItem item) {
    return _positieBeheerController.verwijderPositie(item);
  }

  Future<void> _kopieerRaamopmeting(OpmetingOverzichtRaamItem item) {
    return _positieBeheerController.kopieerPositie(item);
  }

  Future<void> _wisselRaamopmetingOptie(OpmetingOverzichtRaamItem item) {
    return _positieBeheerController.wisselOptieplaatsing(item);
  }

  Future<void> _wisselRaamopmetingNietRekenen(
    OpmetingOverzichtRaamItem item,
  ) async {
    await _positieBeheerController.wisselNietRekenen(item);

    if (!mounted) {
      return;
    }

    setState(() {
      _verborgenNietRekenenPositieIds = Set<String>.from(
        _verborgenNietRekenenPositieIds,
      )..remove(item.id);
    });
  }

  Future<void> _verplaatsRaamopmeting(
    OpmetingOverzichtRaamItem item,
    int richting,
  ) {
    return _positieBeheerController.verplaatsPositie(item, richting);
  }

  Future<void> _wijzigArtikelPrijs(
    OpmetingOverzichtRaamItem item,
    double prijs,
  ) {
    return _artikelPrijscorrectieController.wijzigArtikelPrijs(item, prijs);
  }

  Future<void> _wijzigArtikelWinstmarge(
    OpmetingOverzichtRaamItem item,
    double percentage,
  ) {
    return _artikelPrijscorrectieController.wijzigArtikelWinstmarge(
      item,
      percentage,
    );
  }

  Future<void> _wijzigArtikelKorting(
    OpmetingOverzichtRaamItem item,
    double percentage,
  ) {
    return _artikelPrijscorrectieController.wijzigArtikelKorting(
      item,
      percentage,
    );
  }

  List<OpmetingOverzichtRaamItem> _selecteerOndersteundeOffertePosities(
    Iterable<OpmetingOverzichtRaamItem> posities,
  ) {
    return List<OpmetingOverzichtRaamItem>.unmodifiable(
      posities.where((positie) {
        if (positie.isVerwijderd || positie.isNietRekenen) {
          return false;
        }

        return positie.algemeneOpmetingData != null ||
            positie.vliegendeurData != null ||
            OfferteArtikelPrijsKoppelingService.isOndersteundArtikel(positie);
      }),
    );
  }

  List<OpmetingOverzichtRaamItem> _selecteerOndersteundeOpmetingPosities(
    Iterable<OpmetingOverzichtRaamItem> posities,
  ) {
    return List<OpmetingOverzichtRaamItem>.unmodifiable(
      posities.where((positie) {
        if (positie.isVerwijderd) return false;

        return positie.algemeneOpmetingData != null ||
            positie.vliegendeurData != null ||
            OfferteArtikelPrijsKoppelingService.isOndersteundArtikel(positie);
      }),
    );
  }

  void _toggleFormulierTypeZichtbaarheid(String typeKey) {
    setState(() {
      final nieuweVerborgenTypes = Set<String>.from(_verborgenFormulierTypes);

      if (nieuweVerborgenTypes.contains(typeKey)) {
        nieuweVerborgenTypes.remove(typeKey);
      } else {
        nieuweVerborgenTypes.add(typeKey);
      }

      _verborgenFormulierTypes = nieuweVerborgenTypes;
    });
  }

  void _toggleNietRekenenPositieZichtbaarheid(String positieId) {
    setState(() {
      final nieuweVerborgenPositieIds = Set<String>.from(
        _verborgenNietRekenenPositieIds,
      );

      if (nieuweVerborgenPositieIds.contains(positieId)) {
        nieuweVerborgenPositieIds.remove(positieId);
      } else {
        nieuweVerborgenPositieIds.add(positieId);
      }

      _verborgenNietRekenenPositieIds = nieuweVerborgenPositieIds;
    });
  }

  Future<bool> _bevestigOfferteMetOntbrekendePrijsgegevens(
    List<OpmetingOverzichtRaamItem> offertePosities,
  ) async {
    if (!_projectTitelhoofd.berekenPrijzen) {
      return true;
    }

    final teValiderenPosities = offertePosities
        .where((positie) => positie.veluxDakraamData == null)
        .toList(growable: false);

    if (teValiderenPosities.isEmpty) {
      return true;
    }

    final validatie = _offerteController.valideerPrijsgegevens(
      teValiderenPosities,
    );

    if (validatie.isGeldig) {
      return true;
    }

    Widget bouwSectie({
      required String titel,
      required List<OfferteValidatieMelding> meldingen,
    }) {
      if (meldingen.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFED7AA)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              titel,
              style: const TextStyle(
                color: Color(0xFF9A3412),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            ...meldingen.map((melding) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  '${melding.positieLabel} · '
                  '${melding.artikel.zichtbareOmschrijving}',
                  style: const TextStyle(
                    color: Color(0xFF9A3412),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }),
          ],
        ),
      );
    }

    final doorgaan = await showDialog<bool>(
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
              Icon(Icons.warning_amber_rounded, color: Color(0xFFEA580C)),
              SizedBox(width: 10),
              Expanded(child: Text('Prijsgegevens ontbreken')),
            ],
          ),
          content: SizedBox(
            width: 540,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Controleer onderstaande posities voordat je de offerte '
                  'opent.',
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        bouwSectie(
                          titel: 'Geen prijs per stuk ingevuld',
                          meldingen: validatie.zonderPrijsPerStuk,
                        ),
                        bouwSectie(
                          titel: 'Geen winstmarge ingevuld',
                          meldingen: validatie.zonderWinstmarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Vul de ontbrekende prijsgegevens bij voorkeur eerst in. '
                  'Je kunt de offerte toch openen om ze te controleren.',
                  style: TextStyle(
                    color: _tekstGrijs,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Terug naar overzicht'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _groen),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Toch offerte openen'),
            ),
          ],
        );
      },
    );

    return doorgaan == true;
  }

  Future<void> _openPrijsOverzicht() async {
    await _prijsinstellingenController
        .controleerOpenOfferteOpPrijsinstellingen();

    if (!mounted) {
      return;
    }

    final overzichtPosities = _selecteerOndersteundeOffertePosities(
      _raamOpmetingen,
    );

    if (overzichtPosities.isEmpty) {
      _toonMelding(
        'Er zijn geen ondersteunde artikelfiches voor het prijsoverzicht.',
        fout: true,
      );
      return;
    }

    final basisTitelhoofd = _projectTitelhoofd.klantNaam.trim().isEmpty
        ? _projectTitelhoofd.copyWith(klantNaam: _klantNaam.trim())
        : _projectTitelhoofd;

    final titelhoofd = await _projectTitelhoofdController.vulAanUitKlantenfiche(
      klantNaam: basisTitelhoofd.klantNaam,
      basis: basisTitelhoofd,
    );

    if (!mounted) {
      return;
    }

    await AppStorage.bewaarOpmetingProjectTitelhoofd(
      titelhoofd.metWijzigingsDatum(),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _projectTitelhoofd = titelhoofd;
    });

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) {
          return OffertePrijsOverzichtPagina(
            titelhoofd: titelhoofd,
            posities: overzichtPosities,
          );
        },
      ),
    );
  }

  Future<void> _openOffertePreview() async {
    await _prijsinstellingenController
        .controleerOpenOfferteOpPrijsinstellingen();

    if (!mounted) {
      return;
    }

    final offertePosities = _selecteerOndersteundeOffertePosities(
      _raamOpmetingen,
    );

    if (offertePosities.isEmpty) {
      _toonMelding(
        'Er zijn geen ondersteunde artikelfiches om op de offerte te plaatsen.',
        fout: true,
      );
      return;
    }

    final magOfferteOpenen = await _bevestigOfferteMetOntbrekendePrijsgegevens(
      offertePosities,
    );

    if (!magOfferteOpenen || !mounted) {
      return;
    }

    final basisTitelhoofd = _projectTitelhoofd.klantNaam.trim().isEmpty
        ? _projectTitelhoofd.copyWith(klantNaam: _klantNaam.trim())
        : _projectTitelhoofd;

    final titelhoofd = await _projectTitelhoofdController.vulAanUitKlantenfiche(
      klantNaam: basisTitelhoofd.klantNaam,
      basis: basisTitelhoofd,
    );

    if (titelhoofd.klantNaam.trim().isEmpty) {
      _toonMelding(
        'Vul eerst de klantgegevens bovenaan de opmeting in.',
        fout: true,
      );
      return;
    }

    await AppStorage.bewaarOpmetingProjectTitelhoofd(
      titelhoofd.metWijzigingsDatum(),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _projectTitelhoofd = titelhoofd;
    });

    await _projectBestandController.opslaanBestand(toonMeldingNaOpslaan: false);

    if (!mounted) return;

    final oneDriveResultaat = await Navigator.of(context)
        .push<OneDriveKlantdocumentResultaat>(
          MaterialPageRoute<OneDriveKlantdocumentResultaat>(
            builder: (context) {
              return OffertePdfPreviewPagina(
                titelhoofd: titelhoofd,
                posities: offertePosities,
              );
            },
          ),
        );

    if (!mounted || oneDriveResultaat == null) return;

    _toonMelding(
      '${oneDriveResultaat.documentType} opgeslagen in OneDrive: '
      '${oneDriveResultaat.volledigPad}',
    );
  }

  Future<void> _openOpmetingPreview() async {
    final opmetingPosities = _selecteerOndersteundeOpmetingPosities(
      _raamOpmetingen,
    );

    if (opmetingPosities.isEmpty) {
      _toonMelding(
        'Er zijn geen ondersteunde artikelfiches om op de opmeting te plaatsen.',
        fout: true,
      );
      return;
    }

    final basisTitelhoofd = _projectTitelhoofd.klantNaam.trim().isEmpty
        ? _projectTitelhoofd.copyWith(klantNaam: _klantNaam.trim())
        : _projectTitelhoofd;

    final titelhoofd = await _projectTitelhoofdController.vulAanUitKlantenfiche(
      klantNaam: basisTitelhoofd.klantNaam,
      basis: basisTitelhoofd,
    );

    if (!mounted) return;

    if (titelhoofd.klantNaam.trim().isEmpty) {
      _toonMelding(
        'Vul eerst de klantgegevens bovenaan de opmeting in.',
        fout: true,
      );
      return;
    }

    await AppStorage.bewaarOpmetingProjectTitelhoofd(
      titelhoofd.metWijzigingsDatum(),
    );

    if (!mounted) return;

    setState(() {
      _projectTitelhoofd = titelhoofd;
    });

    await _projectBestandController.opslaanBestand(toonMeldingNaOpslaan: false);

    if (!mounted) return;

    final oneDriveResultaat = await Navigator.of(context)
        .push<OneDriveKlantdocumentResultaat>(
          MaterialPageRoute<OneDriveKlantdocumentResultaat>(
            builder: (context) {
              return OpmetingPdfPreviewPagina(
                titelhoofd: titelhoofd,
                posities: opmetingPosities,
              );
            },
          ),
        );

    if (!mounted || oneDriveResultaat == null) return;

    _toonMelding(
      '${oneDriveResultaat.documentType} opgeslagen in OneDrive: '
      '${oneDriveResultaat.volledigPad}',
    );
  }

  void _toonMelding(String tekst, {bool fout = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tekst),
        backgroundColor: fout ? const Color(0xFFDC2626) : _groen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _achtergrond,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _bouwBovenbalk(),
            Expanded(
              child: _laden
                  ? const Center(
                      child: CircularProgressIndicator(color: _groen),
                    )
                  : !_heeftOpenBestand
                  ? _bouwGeenBestandGeopend()
                  : _bouwOverzichtslijst(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bouwBovenbalk() {
    return OpmetingOverzichtBovenbalk(
      titel: _titelBovenbalk(),
      heeftOpenBestand: _heeftOpenBestand,
      heeftOndersteundeOffertePosities: _selecteerOndersteundeOpmetingPosities(
        _raamOpmetingen,
      ).isNotEmpty,
      berekenPrijzen: _projectTitelhoofd.berekenPrijzen,
      prijsHerberekeningBezig:
          _prijsinstellingenController.isHerberekeningBezig,
      onNieuwBestand: _projectBestandController.nieuwBestand,
      onOpenBestand: _projectBestandController.openBestand,
      onOpslaanBestand: _projectBestandController.opslaanBestand,
      onWisBestand: _projectBestandController.wisBestand,
      onEindeOpmeting: _projectBestandController.eindeOpmeting,
      onHerberekenOfferte:
          _prijsinstellingenController.herberekenOfferteHandmatig,
      onOpenPrijsOverzicht: _openPrijsOverzicht,
      onOpenOffertePreview: _openOffertePreview,
      onOpenOpmetingPreview: _openOpmetingPreview,
      onFormulierGekozen: _openGeregistreerdFormulier,
    );
  }

  Future<void> _openGeregistreerdFormulier(
    OfferteArtikelRegistratie registratie,
  ) async {
    switch (registratie.openType) {
      case OfferteArtikelOpenType.raamopmeting:
        await _openRaamopmeting(formulierType: registratie.formulierType);
        break;

      case OfferteArtikelOpenType.vasteInzethor:
        await _openVasteInzethor();
        break;

      case OfferteArtikelOpenType.vliegendeur:
        await _openVliegendeur();
        break;

      case OfferteArtikelOpenType.schuifvliegendeur:
        await _openSchuifvliegendeur();
        break;

      case OfferteArtikelOpenType.plooiwerken:
        await _openPlooiwerken();
        break;

      case OfferteArtikelOpenType.voorzetscreen:
        await _openVoorzetscreen();
        break;

      case OfferteArtikelOpenType.voorzetrolluik:
        await _openVoorzetrolluik();
        break;

      case OfferteArtikelOpenType.uitvalscherm:
        await _openUitvalscherm();
        break;

      case OfferteArtikelOpenType.algemeneOpmeting:
        await _openAlgemeneOpmeting();
        break;

      case OfferteArtikelOpenType.sektionalePoort:
        await _openSektionalePoort();
        break;

      case OfferteArtikelOpenType.veluxDakraam:
        await _openVeluxDakraam();
        break;
    }
  }

  String _titelBovenbalk() {
    if (_klantNaam.trim().isNotEmpty) {
      return _klantNaam.trim();
    }

    return 'Opmetingen';
  }

  Widget _bouwGeenBestandGeopend() {
    return const SizedBox.expand();
  }

  Widget _bouwOverzichtslijst() {
    return OpmetingOverzichtLijst(
      klantNaam: _klantNaam,
      projectTitelhoofd: _projectTitelhoofd,
      opmetingen: _raamOpmetingen,
      verborgenFormulierTypes: _verborgenFormulierTypes,
      verborgenNietRekenenPositieIds: _verborgenNietRekenenPositieIds,
      projectKleurMenus: _projectKleurMenus,
      offerteController: _offerteController,
      onTitelhoofdGewijzigd: _projectTitelhoofdController.verwerkWijziging,
      onKlantLaden: _projectTitelhoofdController.laadKlantUitBlauweAgenda,
      onToggleFormulierType: _toggleFormulierTypeZichtbaarheid,
      onToggleNietRekenenPositie: _toggleNietRekenenPositieZichtbaarheid,
      onArtikelOpenen: _bewerkRaamopmeting,
      onArtikelVerwijderen: _verwijderRaamopmeting,
      onArtikelKopieren: _kopieerRaamopmeting,
      onArtikelOptieWijzigen: _wisselRaamopmetingOptie,
      onArtikelNietRekenenWijzigen: _wisselRaamopmetingNietRekenen,
      onPrijsMenuOpenen: (item, positieLabel) {
        return _openVrijePrijsPerArtikelVenster(
          item,
          positieLabel: positieLabel,
        );
      },
      onPrijsGewijzigd: _wijzigArtikelPrijs,
      onWinstmargeGewijzigd: _wijzigArtikelWinstmarge,
      onKortingGewijzigd: _wijzigArtikelKorting,
      prijsCorrectieDoelSamenvatting:
          _artikelPrijscorrectieController.prijsCorrectieDoelSamenvatting,
      onPrijsCorrectieToepassenOpOpenen:
          _artikelPrijscorrectieController.openPrijsCorrectieToepassenOpDialog,
      onArtikelVerplaatsen: _verplaatsRaamopmeting,

      // Beide projectbrede prijsregelknoppen gebruiken opnieuw
      // uitsluitend de bestaande, werkende prijsregelcontroller.
      onAlgemenePrijsregelOpenen: _openPrijsVoorAlleArtikelenVenster,
      onBestaandeProjectPrijsregelsBewerken: _openPrijsVoorAlleArtikelenVenster,
    );
  }
}
