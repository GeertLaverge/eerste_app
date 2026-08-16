// THIMACO-CONTROLE: PRIJS-CONTROLLER-ZONDER-OFFERTE-PRIJS-PROFIELMODEL-20260815
// THIMACO-CONTROLE: VASTE-INZETHOR-STANDAARDPRIJS-LOADER-BEHOUDEN-20260815
// THIMACO-CONTROLE: OUDE-PRIJSPROFIEL-MOMENTOPNAMEFLOW-VERWIJDERD-20260815
// THIMACO-CONTROLE: CENTRALE-TECHNISCHE-PRIJS-ALU-SCHUIFRAAM-SELECTIEFALLBACK-20260815
// THIMACO-CONTROLE: CENTRALE-TECHNISCHE-PRIJS-AUTOMATISCH-HERBEREKENEN-20260815
// THIMACO-CONTROLE: CENTRALE-TECHNISCHE-KEUZEPRIJZEN-ACTIEF-IN-OFFERTE-20260815
// THIMACO-CONTROLE: PRIJSARCHITECTUUR-OPRUIMEN-STAP3-CONTROLLER-ZONDER-LEGACY-OPRUIMBLOKKEN-20260814
// THIMACO-CONTROLE: PRIJSARCHITECTUUR-OPRUIMEN-STAP2-ALLEEN-TECHNISCHE-PRIJSINSTELLINGEN-20260814
// THIMACO-CONTROLE: VOORZETROLLUIK-INBOUWSCHAKELAAR-PRIJS-MOMENTOPNAME-20260731
// THIMACO-CONTROLE: VOORZETSCREEN-INBOUWSCHAKELAAR-TECHNISCHE-MOMENTOPNAME-20260730-2205
// THIMACO-CONTROLE: VELUX-TECHNISCHE-AFWERKING-MOMENTOPNAME-20260730
// THIMACO-CONTROLE: EERSTE-PRIJS-SNAPSHOT-STIL-20260724
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../app_storage.dart';
import '../../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../../opmeting/project/opmeting_project_titelhoofd_model.dart';
import 'offerte_artikel_prijs_koppeling_service.dart';
import 'offerte_centrale_technische_prijs_service.dart';
import 'offerte_prijs_berekening_service.dart';
import 'offerte_technische_keuze_resolver.dart';
import 'offerte_technische_keuze_ref.dart';

class OffertePrijsinstellingenController {
  OffertePrijsinstellingenController({
    required this.context,
    required this.isMounted,
    required this.leesIsLaden,
    required this.leesHeeftOpenBestand,
    required this.leesKlantNaam,
    required this.leesTitelhoofd,
    required this.herlaadOpmetingen,
    required this.toonMelding,
    required this.onHerberekeningStatusGewijzigd,
  });

  static const Color _groen = Color(0xFF0B7A3B);
  final BuildContext context;
  final bool Function() isMounted;
  final bool Function() leesIsLaden;
  final bool Function() leesHeeftOpenBestand;
  final String Function() leesKlantNaam;
  final OpmetingProjectTitelhoofd Function() leesTitelhoofd;
  final Future<void> Function(String klantNaam, bool forceerPrijsinstellingen)
  herlaadOpmetingen;
  final void Function(String tekst, bool fout) toonMelding;
  final VoidCallback onHerberekeningStatusGewijzigd;

  Timer? _controleTimer;
  bool _controleBezig = false;
  bool _herberekeningBezig = false;
  String _laatsteCentraleTechnischePrijsSignatuur = '';

  bool get isHerberekeningBezig => _herberekeningBezig;

  void startAutomatischeControle() {
    _controleTimer?.cancel();

    // Meteen één keer controleren. Zo hoeft een reeds open offerte niet eerst
    // twee seconden te wachten voordat een nieuwe centrale technische prijs
    // zichtbaar kan worden.
    unawaited(controleerOpenOfferteOpPrijsinstellingen());

    _controleTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      unawaited(controleerOpenOfferteOpPrijsinstellingen());
    });
  }

  void dispose() {
    _controleTimer?.cancel();
  }

  String _normaliseerTechnischeTekst(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  bool _technischeKeuzeIsGeselecteerdInArtikel({
    required OfferteTechnischeKeuzeRef keuze,
    required OpmetingOverzichtRaamItem opmeting,
  }) {
    // Nieuwe/normale route: altijd eerst de stabiele lokale menu- en keuze-ID's.
    if (OfferteTechnischeKeuzeResolver.isGeselecteerd(
      keuze: keuze,
      keuzeSelectiesPerKader: opmeting.keuzeSelectiesPerKader,
    )) {
      return true;
    }

    // Compatibiliteit voor reeds gekopieerde/opgeladen technische menu's:
    // de zichtbare technische regel bewijst dat de keuze effectief geselecteerd
    // is, maar oudere menu-/optie-ID's kunnen verschillen tussen fichetypes.
    //
    // We koppelen NIET los op alleen tekst: de menutitel moet ook passen en er
    // mag precies één zichtbare regel overeenkomen.
    final menuTekst = _normaliseerTechnischeTekst(keuze.menuTitelMomentopname);
    final keuzeTeksten = <String>{
      _normaliseerTechnischeTekst(keuze.hoeUitschrijven),
      _normaliseerTechnischeTekst(keuze.keuzeTitelMomentopname),
    }..removeWhere((waarde) => waarde.isEmpty);

    if (keuzeTeksten.isEmpty) {
      return false;
    }

    var aantalOvereenkomsten = 0;

    for (final regel in opmeting.zichtbareTechnischeRegels) {
      final regelTitel = _normaliseerTechnischeTekst(regel.titel);
      final regelWaarde = _normaliseerTechnischeTekst(regel.waarde);

      if (regelWaarde.isEmpty) {
        continue;
      }

      final menuPast =
          menuTekst.isEmpty ||
          regelTitel == menuTekst ||
          regelTitel.contains(menuTekst) ||
          menuTekst.contains(regelTitel);

      if (!menuPast) {
        continue;
      }

      final keuzePast = keuzeTeksten.any((keuzeTekst) {
        return regelWaarde == keuzeTekst || regelWaarde.startsWith(keuzeTekst);
      });

      if (!keuzePast) {
        continue;
      }

      aantalOvereenkomsten++;
      if (aantalOvereenkomsten > 1) {
        return false;
      }
    }

    return aantalOvereenkomsten == 1;
  }

  Future<String> _centraleTechnischePrijsSignatuur() async {
    final prijzen = await AppStorage.laadOfferteTechnischeKeuzePrijzen();
    final records =
        prijzen.map((prijs) => prijs.toJson()).toList(growable: true)
          ..sort((eerste, tweede) {
            final eersteId = eerste['id']?.toString() ?? '';
            final tweedeId = tweede['id']?.toString() ?? '';
            return eersteId.compareTo(tweedeId);
          });

    return jsonEncode(records);
  }

  /// Alleen nog nodig wanneer een NIEUWE vaste inzethor wordt geopend.
  ///
  /// Dit is geen herintroductie van de oude fichegebonden technische
  /// prijsprofiel-/momentopnameflow. De vaste inzethor gebruikt zijn bestaande
  /// standaardprijs per stuk nog als beginwaarde in de fiche.
  Future<
    ({
      double standaardPrijsPerStukExclBtw,
      double standaardWinstmargePercentage,
      double standaardKortingPercentage,
    })
  >
  laadVasteInzethorPrijsprofiel() {
    return AppStorage.laadVasteInzethorStandaardPrijsinstellingen();
  }

  Future<OfferteTechnischePrijsMomentopnameResultaat>
  werkTechnischePrijsMomentopnamesBij({
    required List<OpmetingOverzichtRaamItem> alleOpmetingen,
    required String klantNaam,
    required bool berekenPrijzen,
    bool forceerPrijsinstellingen = false,
  }) async {
    if (!berekenPrijzen || klantNaam.trim().isEmpty) {
      return OfferteTechnischePrijsMomentopnameResultaat(
        opmetingen: alleOpmetingen,
        gewijzigd: false,
      );
    }

    // Technische prijzen worden uitsluitend uit de centrale technische
    // prijslijst opgebouwd. Oude fichegebonden prijsprofielen spelen hier
    // nergens meer een rol.
    final technischeFormulierTypes = OfferteArtikelPrijsKoppelingService
        .alleKoppelingen
        .where((koppeling) => koppeling.ondersteuntTechnischeKeuzeprijzen)
        .map((koppeling) => koppeling.formulierType)
        .toSet();
    final centraleContext =
        await OfferteCentraleTechnischePrijsService.laadContext(
          formulierTypes: technischeFormulierTypes,
        );

    final klantSleutel = klantNaam.trim().toLowerCase();
    var gewijzigd = false;

    final bijgewerkteOpmetingen = alleOpmetingen
        .map((opmeting) {
          if (opmeting.isVerwijderd ||
              opmeting.klantNaam.trim().toLowerCase() != klantSleutel) {
            return opmeting;
          }

          final koppeling =
              OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(
                opmeting,
              );
          if (koppeling == null) {
            return opmeting;
          }

          // Vaste inzethor heeft geen zelf aangemaakte technische-keuzemenu's.
          // Eventuele oude technische momentopnames worden éénmalig opgeruimd.
          if (koppeling.isVasteInzethor) {
            final model = opmeting.vasteInzethorData;
            if (model == null) {
              return opmeting;
            }

            if (!OffertePrijsBerekeningService.moetTechnischeMomentopnameBijwerken(
              model,
            )) {
              return opmeting;
            }

            gewijzigd = true;
            final bijgewerktModel =
                OffertePrijsBerekeningService.maakTechnischeMomentopname(
                  model: model,
                );
            return opmeting
                .copyWith(vasteInzethorData: bijgewerktModel)
                .metNieuweWijzigingsDatum();
          }

          if (!koppeling.ondersteuntTechnischeKeuzeprijzen) {
            return opmeting;
          }

          var prijsData = opmeting.offertePrijsData;
          final formulierType = koppeling.formulierType;
          final voorzetscreenModel = opmeting.voorzetscreenData;
          final voorzetrolluikModel = opmeting.voorzetrolluikData;
          final veluxModel = opmeting.veluxDakraamData;

          String artikelSignatuur;
          int breedteMm;
          int hoogteMm;
          int aantal;
          OfferteCentraleTechnischeKeuzeSelectieTest selectieTest;

          if (voorzetscreenModel != null) {
            artikelSignatuur = jsonEncode(<String, Object>{
              'formulierType': 'voorzetscreen',
              'breedteMm': voorzetscreenModel.breedteMm,
              'hoogteMm': voorzetscreenModel.hoogteMm,
              'aantal': voorzetscreenModel.aantal,
              'bediening': voorzetscreenModel.bediening,
            });
            breedteMm = voorzetscreenModel.breedteMm;
            hoogteMm = voorzetscreenModel.hoogteMm;
            aantal = voorzetscreenModel.aantal;
            selectieTest = (keuze) {
              return keuze.menuId.trim() == 'voorzetscreenBediening' &&
                  keuze.keuzeId.trim() == 'inbouwschakelaar' &&
                  voorzetscreenModel.bediening.trim().toLowerCase() ==
                      'inbouwschakelaar';
            };
          } else if (voorzetrolluikModel != null) {
            artikelSignatuur = jsonEncode(<String, Object>{
              'formulierType': 'voorzetrolluik',
              'breedteMm': voorzetrolluikModel.breedteMm,
              'hoogteMm': voorzetrolluikModel.hoogteMm,
              'aantal': voorzetrolluikModel.aantal,
              'bediening': voorzetrolluikModel.bediening.name,
              'elektrischeBediening': voorzetrolluikModel.elektrischeBediening,
            });
            breedteMm = voorzetrolluikModel.breedteMm;
            hoogteMm = voorzetrolluikModel.hoogteMm;
            aantal = voorzetrolluikModel.aantal;
            selectieTest = (keuze) {
              return keuze.menuId.trim() == 'voorzetrolluikBediening' &&
                  keuze.keuzeId.trim() == 'inbouwschakelaar' &&
                  voorzetrolluikModel.isElektrisch &&
                  voorzetrolluikModel.elektrischeBediening
                          .trim()
                          .toLowerCase() ==
                      'inbouwschakelaar';
            };
          } else if (veluxModel != null) {
            artikelSignatuur = jsonEncode(<String, Object>{
              'formulierType': 'veluxDakraam',
              'productCode': veluxModel.productCode,
              'maatCode': veluxModel.maatCode,
              'breedteMm': veluxModel.breedteMm,
              'hoogteMm': veluxModel.hoogteMm,
              'aantal': veluxModel.veiligAantal,
              'afwerkingType': veluxModel.afwerkingType.name,
            });
            breedteMm = veluxModel.breedteMm;
            hoogteMm = veluxModel.hoogteMm;
            aantal = veluxModel.veiligAantal;
            selectieTest = (keuze) {
              return keuze.menuId.trim() == 'veluxAfwerking' &&
                  keuze.keuzeId.trim() == veluxModel.afwerkingType.name &&
                  veluxModel.afwerkingType.name != 'geen';
            };
          } else {
            breedteMm =
                OfferteArtikelPrijsKoppelingService.breedteMmVoorArtikel(
                  opmeting,
                );
            hoogteMm = OfferteArtikelPrijsKoppelingService.hoogteMmVoorArtikel(
              opmeting,
            );
            aantal = OfferteArtikelPrijsKoppelingService.aantalVoorArtikel(
              opmeting,
            );
            artikelSignatuur = jsonEncode(<String, Object?>{
              'formulierType': formulierType,
              'breedteMm': breedteMm,
              'hoogteMm': hoogteMm,
              'aantal': aantal,
              'selecties': OfferteTechnischeKeuzeResolver.signatuurSelecties(
                opmeting.keuzeSelectiesPerKader,
              ),
              'technischeRegels': opmeting.zichtbareTechnischeRegels
                  .map(
                    (regel) => <String, String>{
                      'titel': regel.titel.trim(),
                      'waarde': regel.waarde.trim(),
                    },
                  )
                  .toList(growable: false),
            });
            selectieTest = (keuze) {
              return _technischeKeuzeIsGeselecteerdInArtikel(
                keuze: keuze,
                opmeting: opmeting,
              );
            };
          }

          if (!OfferteCentraleTechnischePrijsService.moetMomentopnameBijwerken(
            prijsData: prijsData,
            context: centraleContext,
            formulierType: formulierType,
            artikelSignatuur: artikelSignatuur,
            forceer: forceerPrijsinstellingen,
          )) {
            return opmeting;
          }

          prijsData = OfferteCentraleTechnischePrijsService.maakMomentopname(
            prijsData: prijsData,
            context: centraleContext,
            formulierType: formulierType,
            breedteMm: breedteMm,
            hoogteMm: hoogteMm,
            aantal: aantal,
            artikelSignatuur: artikelSignatuur,
            keuzeIsGeselecteerd: selectieTest,
          );

          gewijzigd = true;
          return OfferteArtikelPrijsKoppelingService.schrijfPrijsData(
            artikel: opmeting,
            prijsData: prijsData,
          ).metNieuweWijzigingsDatum();
        })
        .toList(growable: false);

    return OfferteTechnischePrijsMomentopnameResultaat(
      opmetingen: bijgewerkteOpmetingen,
      gewijzigd: gewijzigd,
    );
  }

  Future<void> controleerOpenOfferteOpPrijsinstellingen() async {
    if (_controleBezig ||
        leesIsLaden() ||
        !leesHeeftOpenBestand() ||
        !leesTitelhoofd().berekenPrijzen) {
      return;
    }

    _controleBezig = true;

    try {
      final centraleTechnischePrijsSignatuur =
          await _centraleTechnischePrijsSignatuur();

      // Bij het starten van een reeds open offerte één keer forceren. Zo wordt
      // de actuele centrale technische prijslijst onmiddellijk toegepast.
      if (_laatsteCentraleTechnischePrijsSignatuur.isEmpty) {
        _laatsteCentraleTechnischePrijsSignatuur =
            centraleTechnischePrijsSignatuur;
        await herlaadOpmetingen(leesKlantNaam(), true);
        return;
      }

      if (_laatsteCentraleTechnischePrijsSignatuur ==
          centraleTechnischePrijsSignatuur) {
        return;
      }

      // Prijs, eenheid, A/V, winstmarge of Uit/Tekst/€ is centraal gewijzigd.
      _laatsteCentraleTechnischePrijsSignatuur =
          centraleTechnischePrijsSignatuur;
      await herlaadOpmetingen(leesKlantNaam(), true);

      if (!isMounted() || !context.mounted) {
        return;
      }

      if (ModalRoute.of(context)?.isCurrent == true) {
        _toonAutomatischePrijsMelding();
      }
    } finally {
      _controleBezig = false;
    }
  }

  Future<void> herberekenOfferteHandmatig() async {
    if (_herberekeningBezig ||
        !leesHeeftOpenBestand() ||
        !leesTitelhoofd().berekenPrijzen) {
      return;
    }

    _stelHerberekeningBezigIn(true);

    try {
      await herlaadOpmetingen(leesKlantNaam(), true);
      _laatsteCentraleTechnischePrijsSignatuur =
          await _centraleTechnischePrijsSignatuur();

      if (!isMounted()) {
        return;
      }

      toonMelding(
        'Offerte opnieuw berekend met de huidige prijsinstellingen.',
        false,
      );
    } finally {
      _stelHerberekeningBezigIn(false);
    }
  }

  void _stelHerberekeningBezigIn(bool waarde) {
    if (_herberekeningBezig == waarde) {
      return;
    }

    _herberekeningBezig = waarde;
    if (isMounted()) {
      onHerberekeningStatusGewijzigd();
    }
  }

  void _toonAutomatischePrijsMelding() {
    if (!isMounted() || !context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: _groen,
        content: Text('Offerte automatisch herberekend.'),
      ),
    );
  }
}

class OfferteTechnischePrijsMomentopnameResultaat {
  const OfferteTechnischePrijsMomentopnameResultaat({
    required this.opmetingen,
    required this.gewijzigd,
  });

  final List<OpmetingOverzichtRaamItem> opmetingen;
  final bool gewijzigd;
}
