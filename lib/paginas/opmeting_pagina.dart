// THIMACO-CONTROLE: PROGRAMMASTIJL-VALIDATIEDIALOOG-FASE14-20260913
// THIMACO-CONTROLE: ZWEVENDE-PANELEN-RUSTIGE-PROGRAMMASTIJL-FASE13-20260913
// THIMACO-CONTROLE: PROGRAMMAWERKGEBIED-ZWEVENDE-PANELEN-FASE7-20260913
// THIMACO-CONTROLE: OFFERTE-PDF-ALLEEN-AFDRUKKEN-EN-ONEDRIVE-20260912
// THIMACO-CONTROLE: PROJECTTITEL-MET-BESTANDSVERSIE-FASE4-20260912
// THIMACO-CONTROLE: ACTIEF-OFFERTEBESTAND-FASE2-20260912
// THIMACO-CONTROLE: CENTRAAL-BESTANDMENU-PROJECT-VARIANT-TITEL-FASE3-20260912
// THIMACO-CONTROLE: PRIJSARCHITECTUUR-OPRUIMEN-STAP2-LEGACY-BEREKENING-UIT-20260814
// THIMACO-CONTROLE: PRIJSARCHITECTUUR-OPRUIMEN-STAP1-LEGACY-UI-20260814
// THIMACO-CONTROLE: PRIJS-PER-POSITIE-TABEL-OPSLAAN-20260813
// THIMACO-CONTROLE: OUDE-PROJECTPRIJS-TOEVOEGROUTE-UIT-20260813
// THIMACO-CONTROLE: OUDE-VRIJE-PRIJS-PER-ARTIKEL-ROUTE-UIT-20260813
// THIMACO-CONTROLE: GROEPSGEWIJZE-WINST-KORTING-UI-LOS-20260813
// THIMACO-CONTROLE: OPMETING-OVERZICHT-SCROLLPOSITIE-BEHOUDEN-20260812
// THIMACO-CONTROLE: VEILIGE-POSITIE-MUTATIES-FASE1-20260810_113219
// THIMACO-CONTROLE: VERBORGEN-NIET-REKENEN-POSITIES-BLIJVEND-BEWAREN-20260809-2040
// THIMACO-CONTROLE: OFFERTEVERSIES-CONCEPTEN-WERKVERSIE-20260806
// THIMACO-CONTROLE: BUITENJALOEZIE-HOOFDPAGINA-FASE-3B-20260803
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
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helpers/app_storage.dart';
import '../helpers/ui/thimaco_huisstijl.dart';
import '../helpers/offerte/offerte_controller.dart';
import '../helpers/offerte/offerte_validatie_service.dart';
import '../helpers/offerte/offerte_pdf_preview_pagina.dart';
import '../helpers/offerte/opmeting_pdf_preview_pagina.dart';
import 'offerte_prijs_overzicht_pagina.dart';
import '../helpers/offerte/prijzen/offerte_artikel_prijs_koppeling_service.dart';
import '../helpers/offerte/prijzen/offerte_artikel_prijs_data_model.dart';
import '../helpers/offerte/prijzen/offerte_artikel_prijs_mutatie_service.dart';
import '../helpers/offerte/prijzen/offerte_artikel_prijscorrectie_controller.dart';
import '../helpers/offerte/prijzen/offerte_prijsinstellingen_controller.dart';
import '../helpers/sync/onedrive_klantdocument_service.dart';
import '../helpers/opmeting/overzicht/opmeting_overzicht_model.dart';
import '../helpers/opmeting/opslag/opmeting_veilige_mutatie_service.dart';
import '../helpers/offerte/artikelen/offerte_artikel_register.dart';
import '../helpers/offerte/artikelen/offerte_positie_beheer_controller.dart';
import '../helpers/opmeting/overzicht/opmeting_overzicht_bovenbalk.dart';
import '../helpers/opmeting/overzicht/opmeting_overzicht_lijst.dart';
import '../helpers/opmeting/project/opmeting_project_kleur_model.dart';
import '../helpers/opmeting/project/opmeting_project_titelhoofd_kaart.dart';
import '../helpers/opmeting/project/opmeting_project_titelhoofd_model.dart'
    show OpmetingProjectTitelhoofd, opmetingLegacyProjectBestandId;
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
  static const Color _accent = ThimacoKleuren.oranje;
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _rand = ThimacoKleuren.rand;
  static const Color _tekstDonker = ThimacoKleuren.antraciet;
  static const Color _tekstGrijs = ThimacoKleuren.tekstGrijs;

  String _klantNaam = '';
  bool _laden = false;

  int _veiligePrijsHerberekenGeneratie = 0;

  final ScrollController _overzichtScrollController = ScrollController(
    keepScrollOffset: true,
    debugLabel: 'opmeting-overzicht',
  );

  final List<OpmetingOverzichtRaamItem> _raamOpmetingen =
      <OpmetingOverzichtRaamItem>[];

  OpmetingProjectTitelhoofd _projectTitelhoofd =
      const OpmetingProjectTitelhoofd();

  List<OpmetingProjectKleurSubmenu> _projectKleurMenus =
      <OpmetingProjectKleurSubmenu>[];

  Set<String> _verborgenFormulierTypes = <String>{};
  Set<String> _verborgenNietRekenenPositieIds = <String>{};

  OpmetingProjectPaneel? _actiefProjectPaneel;
  final Map<OpmetingProjectPaneel, Offset> _projectPaneelPosities =
      <OpmetingProjectPaneel, Offset>{};

  final OfferteController _offerteController = OfferteController.standaard();

  late final OffertePrijsinstellingenController _prijsinstellingenController;

  late final OfferteArtikelPrijscorrectieController
  _artikelPrijscorrectieController;

  late final OffertePositieBeheerController _positieBeheerController;

  late final OpmetingProjectTitelhoofdController _projectTitelhoofdController;

  late final OpmetingProjectBestandController _projectBestandController;

  late final OpmetingFormulierNavigatieController _formulierNavigatieController;

  bool get _heeftOpenBestand {
    return _klantNaam.trim().isNotEmpty &&
        _projectTitelhoofd.projectBestandId.trim().isNotEmpty;
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
      leesProjectBestandId: () => _projectTitelhoofd.projectBestandId,
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

    _positieBeheerController = OffertePositieBeheerController(
      context: context,
      offerteController: _offerteController,
      isMounted: () => mounted,
      leesArtikelen: () => _raamOpmetingen,
      leesKlantNaam: () => _klantNaam,
      leesProjectBestandId: () => _projectTitelhoofd.projectBestandId,
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
          _verborgenNietRekenenPositieIds = Set<String>.from(
            titelhoofd.verborgenNietRekenenPositieIds,
          );
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
              _verborgenNietRekenenPositieIds = Set<String>.from(
                titelhoofd.verborgenNietRekenenPositieIds,
              );
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
    _overzichtScrollController.dispose();
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

  Future<void> _openBuitenjaloezie({
    OpmetingOverzichtRaamItem? bestaandeOpmeting,
  }) {
    return _formulierNavigatieController.openBuitenjaloezie(
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

  Future<void> _herberekenPrijsMomentopnamesNaPrijswijziging({
    required String klantNaam,
  }) async {
    final projectBestandId = _projectTitelhoofd.projectBestandId.trim();
    if (!_projectTitelhoofd.berekenPrijzen ||
        klantNaam.trim().isEmpty ||
        projectBestandId.isEmpty) {
      return;
    }

    final basisOpmetingen = await AppStorage.laadOpmetingenVoorSync();

    final resultaat = await _prijsinstellingenController
        .werkTechnischePrijsMomentopnamesBij(
          alleOpmetingen: basisOpmetingen,
          klantNaam: klantNaam,
          projectBestandId: projectBestandId,
          berekenPrijzen: true,
        );

    if (!resultaat.gewijzigd) {
      return;
    }

    final veiligResultaat =
        await OpmetingVeiligeMutatieService.bewaarBerekendeWijzigingen(
          basis: basisOpmetingen,
          gewijzigd: resultaat.opmetingen,
        );

    if (!mounted ||
        _projectTitelhoofd.projectBestandId.trim() != projectBestandId) {
      return;
    }

    final zichtbareOpmetingen = veiligResultaat.opmetingen.where((opmeting) {
      if (opmeting.isVerwijderd) return false;
      final id = opmeting.projectBestandId.trim().isNotEmpty
          ? opmeting.projectBestandId.trim()
          : opmetingLegacyProjectBestandId(opmeting.klantNaam);
      return id == projectBestandId;
    }).toList(growable: false);

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

    final nieuweVerborgenPositieIds = Set<String>.from(
      _verborgenNietRekenenPositieIds,
    )..remove(item.id);

    _projectTitelhoofdController.verwerkWijziging(
      _projectTitelhoofd.copyWith(
        verborgenNietRekenenPositieIds: nieuweVerborgenPositieIds,
      ),
    );
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
  ) async {
    final positieId = item.id.trim();
    if (positieId.isEmpty) {
      return;
    }

    OpmetingVeiligeMutatieResultaat veiligResultaat;

    try {
      veiligResultaat = await OpmetingVeiligeMutatieService.wijzigPositie(
        positieId: positieId,
        wijziging: (actueel) {
          final adapter = OfferteArtikelPrijsMutatieService.adapterVoor(
            actueel,
          );

          if (adapter == null) {
            return actueel;
          }

          // De nieuwe prijs wordt op de nieuwste opgeslagen positie gezet.
          return adapter.schrijfPrijsPerStuk(
            artikel: actueel,
            prijsPerStukExclBtw: prijs,
          );
        },
      );
    } catch (fout) {
      if (mounted) {
        _toonMelding(
          'Eenheidsprijs bewaren is niet gelukt.\n$fout',
          fout: true,
        );
      }
      return;
    }

    if (!veiligResultaat.gewijzigd || !mounted) {
      return;
    }

    // Lokaal eveneens slechts deze ene positie vervangen.
    final lokaal = List<OpmetingOverzichtRaamItem>.from(_raamOpmetingen);
    final index = lokaal.indexWhere(
      (opmeting) => opmeting.id == veiligResultaat.positie.id,
    );

    if (index >= 0) {
      lokaal[index] = veiligResultaat.positie;

      setState(() {
        _raamOpmetingen
          ..clear()
          ..addAll(lokaal);
      });
    }

    // Debounce behouden zonder een oudere positielijst vast te houden.
    final generatie = ++_veiligePrijsHerberekenGeneratie;
    await Future<void>.delayed(const Duration(milliseconds: 450));

    if (!mounted || generatie != _veiligePrijsHerberekenGeneratie) {
      return;
    }

    await _herberekenPrijsMomentopnamesNaPrijswijziging(
      klantNaam: veiligResultaat.positie.klantNaam,
    );
  }

  Future<void> _wijzigPrijsPerPositieRegels(
    OpmetingOverzichtRaamItem item,
    List<OffertePrijsPerPositieRegelModel> prijsregels,
  ) async {
    final positieId = item.id.trim();
    if (positieId.isEmpty) {
      return;
    }

    OpmetingVeiligeMutatieResultaat veiligResultaat;

    try {
      veiligResultaat = await OpmetingVeiligeMutatieService.wijzigPositie(
        positieId: positieId,
        wijziging: (actueel) {
          return OfferteArtikelPrijsKoppelingService.schrijfPrijsPerPositieRegels(
            artikel: actueel,
            prijsregels: prijsregels,
          );
        },
      );
    } catch (fout) {
      if (mounted) {
        _toonMelding(
          'Prijs per positie bewaren is niet gelukt.\n$fout',
          fout: true,
        );
      }
      return;
    }

    if (!veiligResultaat.gewijzigd || !mounted) {
      return;
    }

    final lokaal = List<OpmetingOverzichtRaamItem>.from(_raamOpmetingen);
    final index = lokaal.indexWhere(
      (opmeting) => opmeting.id == veiligResultaat.positie.id,
    );

    if (index < 0) {
      return;
    }

    lokaal[index] = veiligResultaat.positie;

    setState(() {
      _raamOpmetingen
        ..clear()
        ..addAll(lokaal);
    });
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
    final nieuweVerborgenPositieIds = Set<String>.from(
      _verborgenNietRekenenPositieIds,
    );

    if (nieuweVerborgenPositieIds.contains(positieId)) {
      nieuweVerborgenPositieIds.remove(positieId);
    } else {
      nieuweVerborgenPositieIds.add(positieId);
    }

    _projectTitelhoofdController.verwerkWijziging(
      _projectTitelhoofd.copyWith(
        verborgenNietRekenenPositieIds: nieuweVerborgenPositieIds,
      ),
    );
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
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: _rand),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Row(
                children: <Widget>[
                  Icon(
                    Icons.warning_amber_rounded,
                    color: _accent,
                    size: 20,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Prijsgegevens ontbreken',
                      style: TextStyle(
                        color: _tekstDonker,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 42,
                  height: 1.5,
                  color: _accent.withValues(alpha: 0.72),
                ),
              ),
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
          actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
          actions: <Widget>[
            ThimacoTekstActie(
              tekst: 'Terug naar overzicht',
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
            ),
            ThimacoTekstActie(
              tekst: 'Toch offerte openen',
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
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
        backgroundColor: fout ? ThimacoKleuren.rood : ThimacoKleuren.antraciet,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape &&
            _actiefProjectPaneel != null) {
          setState(() {
            _actiefProjectPaneel = null;
          });
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        backgroundColor: _achtergrond,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      _bouwBovenbalk(),
                      Expanded(
                        child: _laden
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: _accent,
                                ),
                              )
                            : !_heeftOpenBestand
                            ? _bouwGeenBestandGeopend()
                            : _bouwOverzichtslijst(),
                      ),
                    ],
                  ),
                  if (_heeftOpenBestand && _actiefProjectPaneel != null)
                    _bouwZwevendProjectPaneel(constraints),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _wisselProjectPaneel(OpmetingProjectPaneel paneel) {
    setState(() {
      _actiefProjectPaneel = _actiefProjectPaneel == paneel ? null : paneel;
    });
  }

  Widget _bouwZwevendProjectPaneel(BoxConstraints constraints) {
    final paneel = _actiefProjectPaneel!;
    final gewensteGrootte = _gewenstePaneelGrootte(paneel);
    final maxBreedte = math.max(300.0, constraints.maxWidth - 24).toDouble();
    final maxHoogte = math.max(280.0, constraints.maxHeight - 86).toDouble();
    final breedte = math.min(gewensteGrootte.width, maxBreedte).toDouble();
    final hoogte = math.min(gewensteGrootte.height, maxHoogte).toDouble();

    final standaardPositie = Offset(
      math.max(12.0, (constraints.maxWidth - breedte) / 2).toDouble(),
      math
          .max(70.0, 70 + (constraints.maxHeight - 70 - hoogte) / 2)
          .toDouble(),
    );
    final positie = _begrensPaneelPositie(
      _projectPaneelPosities[paneel] ?? standaardPositie,
      constraints: constraints,
      breedte: breedte,
      hoogte: hoogte,
    );

    final paneelTitelhoofd = _projectTitelhoofd.klantNaam.trim().isEmpty &&
            _klantNaam.trim().isNotEmpty
        ? _projectTitelhoofd.copyWith(klantNaam: _klantNaam.trim())
        : _projectTitelhoofd;

    return Positioned(
      left: positie.dx,
      top: positie.dy,
      width: breedte,
      height: hoogte,
      child: Material(
        color: Colors.transparent,
        elevation: 18,
        shadowColor: const Color(0x33000000),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _rand),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: <Widget>[
              MouseRegion(
                cursor: SystemMouseCursors.move,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) {
                    final huidige =
                        _projectPaneelPosities[paneel] ?? standaardPositie;
                    final nieuwe = _begrensPaneelPositie(
                      huidige + details.delta,
                      constraints: constraints,
                      breedte: breedte,
                      hoogte: hoogte,
                    );
                    setState(() {
                      _projectPaneelPosities[paneel] = nieuwe;
                    });
                  },
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.only(left: 14, right: 7),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(bottom: BorderSide(color: _rand)),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          _paneelIcoon(paneel),
                          color: _tekstDonker,
                          size: 18,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _paneelTitel(paneel),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _tekstDonker,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                width: 34,
                                height: 1.5,
                                decoration: BoxDecoration(
                                  color: _accent.withValues(alpha: 0.72),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: ThimacoIcoonActie(
                            icoon: Icons.close_rounded,
                            tooltip: 'Sluiten',
                            grootte: 19,
                            onPressed: () {
                              setState(() {
                                _actiefProjectPaneel = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: OpmetingProjectTitelhoofdKaart(
                  key: ValueKey<String>(
                    '${_projectTitelhoofd.projectBestandId}-${paneel.name}',
                  ),
                  titelhoofd: paneelTitelhoofd,
                  opmetingen: _raamOpmetingen,
                  verborgenFormulierTypes: _verborgenFormulierTypes,
                  verborgenNietRekenenPositieIds:
                      _verborgenNietRekenenPositieIds,
                  kleurMenus: _projectKleurMenus,
                  onTitelhoofdGewijzigd:
                      _projectTitelhoofdController.verwerkWijziging,
                  onKlantLaden: () {
                    unawaited(
                      _projectTitelhoofdController.laadKlantUitBlauweAgenda(),
                    );
                  },
                  onToggleFormulierType: _toggleFormulierTypeZichtbaarheid,
                  onToggleNietRekenenPositie:
                      _toggleNietRekenenPositieZichtbaarheid,
                  paneel: paneel,
                  zwevendeWeergave: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Offset _begrensPaneelPositie(
    Offset positie, {
    required BoxConstraints constraints,
    required double breedte,
    required double hoogte,
  }) {
    const marge = 12.0;
    const bovenbalkOndergrens = 70.0;
    final maxX = math
        .max(marge, constraints.maxWidth - breedte - marge)
        .toDouble();
    final maxY = math
        .max(
          bovenbalkOndergrens,
          constraints.maxHeight - hoogte - marge,
        )
        .toDouble();

    return Offset(
      positie.dx.clamp(marge, maxX).toDouble(),
      positie.dy.clamp(bovenbalkOndergrens, maxY).toDouble(),
    );
  }

  Size _gewenstePaneelGrootte(OpmetingProjectPaneel paneel) {
    return switch (paneel) {
      OpmetingProjectPaneel.klantgegevens => const Size(650, 470),
      OpmetingProjectPaneel.projectkleur => const Size(560, 430),
      OpmetingProjectPaneel.inhoudFiche => const Size(560, 440),
      OpmetingProjectPaneel.offerteInstellingen => const Size(580, 500),
    };
  }

  String _paneelTitel(OpmetingProjectPaneel paneel) {
    return switch (paneel) {
      OpmetingProjectPaneel.klantgegevens => 'Klantgegevens',
      OpmetingProjectPaneel.projectkleur => 'Projectkleur',
      OpmetingProjectPaneel.inhoudFiche => 'Inhoud fiche',
      OpmetingProjectPaneel.offerteInstellingen => 'Offerte-instellingen',
    };
  }

  IconData _paneelIcoon(OpmetingProjectPaneel paneel) {
    return switch (paneel) {
      OpmetingProjectPaneel.klantgegevens => Icons.person_outline_rounded,
      OpmetingProjectPaneel.projectkleur => Icons.palette_outlined,
      OpmetingProjectPaneel.inhoudFiche => Icons.format_list_bulleted_rounded,
      OpmetingProjectPaneel.offerteInstellingen =>
        Icons.receipt_long_outlined,
    };
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
      onNieuwProject: _projectBestandController.nieuwProject,
      onOpenProject: _projectBestandController.openProject,
      onNieuweVariant: _projectBestandController.nieuweVariant,
      onOpenHuidigProjectBestand:
          _projectBestandController.openHuidigProjectBestand,
      onOpslaanBestand: _projectBestandController.opslaanBestand,
      onOpslaanAlsBestand: _projectBestandController.opslaanAlsBestand,
      onWisBestand: _projectBestandController.wisBestand,
      onEindeOpmeting: _projectBestandController.eindeOpmeting,
      onHerberekenOfferte:
          _prijsinstellingenController.herberekenOfferteHandmatig,
      onOpenPrijsOverzicht: _openPrijsOverzicht,
      onOpenOffertePreview: _openOffertePreview,
      onOpenOpmetingPreview: _openOpmetingPreview,
      onFormulierGekozen: _openGeregistreerdFormulier,
      actiefPaneel: _actiefProjectPaneel,
      onPaneelGekozen: _wisselProjectPaneel,
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

      case OfferteArtikelOpenType.buitenjaloezie:
        await _openBuitenjaloezie();
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
    final klant = _naamWeergave(_klantNaam.trim());
    final bestand = _zinWeergave(_projectTitelhoofd.bestandsNaam.trim());
    final versie = _projectTitelhoofd.veiligeBestandVersieNummer;
    if (klant.isNotEmpty && bestand.isNotEmpty) {
      return '$klant · $bestand V$versie';
    }
    if (klant.isNotEmpty) return klant;
    return 'Opmetingen';
  }

  String _naamWeergave(String waarde) {
    if (waarde.isEmpty) return '';
    return waarde
        .split(RegExp(r'\s+'))
        .where((deel) => deel.isNotEmpty)
        .map((deel) {
          if (deel.length <= 4 && deel == deel.toUpperCase()) return deel;
          return '${deel[0].toUpperCase()}${deel.substring(1)}';
        })
        .join(' ');
  }

  String _zinWeergave(String waarde) {
    if (waarde.isEmpty) return '';
    return '${waarde[0].toUpperCase()}${waarde.substring(1)}';
  }

  Widget _bouwGeenBestandGeopend() {
    return const SizedBox.expand();
  }

  Widget _bouwOverzichtslijst() {
    return OpmetingOverzichtLijst(
      scrollController: _overzichtScrollController,
      scrollStorageKey: PageStorageKey<String>(
        'opmeting-overzicht-${_projectTitelhoofd.projectBestandId.trim()}',
      ),
      projectTitelhoofd: _projectTitelhoofd,
      opmetingen: _raamOpmetingen,
      verborgenFormulierTypes: _verborgenFormulierTypes,
      verborgenNietRekenenPositieIds: _verborgenNietRekenenPositieIds,
      offerteController: _offerteController,
      onTitelhoofdGewijzigd: _projectTitelhoofdController.verwerkWijziging,
      onArtikelOpenen: _bewerkRaamopmeting,
      onArtikelVerwijderen: _verwijderRaamopmeting,
      onArtikelKopieren: _kopieerRaamopmeting,
      onArtikelOptieWijzigen: _wisselRaamopmetingOptie,
      onArtikelNietRekenenWijzigen: _wisselRaamopmetingNietRekenen,
      onPrijsGewijzigd: _wijzigArtikelPrijs,
      onWinstmargeGewijzigd: _wijzigArtikelWinstmarge,
      onKortingGewijzigd: _wijzigArtikelKorting,
      onPrijsPerPositieRegelsGewijzigd: _wijzigPrijsPerPositieRegels,
      onArtikelVerplaatsen: _verplaatsRaamopmeting,
    );
  }
}
