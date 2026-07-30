// THIMACO-CONTROLE: VELUX-TECHNISCHE-AFWERKING-MOMENTOPNAME-20260730
// THIMACO-CONTROLE: EERSTE-PRIJS-SNAPSHOT-STIL-20260724
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../app_storage.dart';
import '../../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../../opmeting/project/opmeting_project_titelhoofd_model.dart';
import 'offerte_algemeen_artikel_prijs_service.dart';
import 'offerte_artikel_prijs_koppeling_service.dart';
import 'offerte_prijs_berekening_service.dart';
import 'offerte_prijs_categorie.dart';
import 'offerte_prijsinstellingen_momentopname.dart';
import 'offerte_prijsprofiel_model.dart';
import 'offerte_prijsregel_model.dart';
import 'offerte_technische_prijs_momentopname_service.dart';
import 'offerte_verdeelkost_service.dart';
import 'offerte_gekoppelde_verdeelkost_service.dart';

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
  static const Color _tekstGrijs = Color(0xFF6B7280);

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
  List<OffertePrijsinstellingenWijziging> _wachtendeWijzigingen =
      <OffertePrijsinstellingenWijziging>[];
  String _genegeerdePrijsinstellingenSignatuur = '';

  bool get isHerberekeningBezig => _herberekeningBezig;

  void startAutomatischeControle() {
    _controleTimer?.cancel();
    _controleTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      unawaited(controleerOpenOfferteOpPrijsinstellingen());
    });
  }

  void dispose() {
    _controleTimer?.cancel();
  }

  void wisGenegeerdePrijsinstellingenSignatuur() {
    _genegeerdePrijsinstellingenSignatuur = '';
  }

  void negeerHuidigePrijsinstellingen(
    Iterable<OffertePrijsinstellingenMomentopname> momentopnames,
  ) {
    _genegeerdePrijsinstellingenSignatuur =
        _samengesteldePrijsinstellingenSignatuur(momentopnames);
  }

  String _normaliseerFormulierType(String waarde) {
    return waarde.trim().toLowerCase().replaceAll('_', '').replaceAll(' ', '');
  }

  Future<OffertePrijsprofielModel> laadPrijsprofielVoorFormulierType(
    String formulierType,
  ) async {
    final canoniekFormulierType =
        OfferteArtikelPrijsKoppelingService.canoniekFormulierType(
          formulierType,
        );
    final formulierNaam = _formulierNaamVoorPrijsType(canoniekFormulierType);

    return await AppStorage.laadOffertePrijsProfiel(canoniekFormulierType) ??
        OffertePrijsprofielModel.leeg(
          formulierType: canoniekFormulierType,
          formulierNaam: formulierNaam,
        );
  }

  Future<OffertePrijsprofielModel> laadVasteInzethorPrijsprofiel() {
    return laadPrijsprofielVoorFormulierType('vasteInzethor');
  }

  Future<Map<String, OffertePrijsprofielModel>>
  laadOndersteundePrijsprofielen() async {
    final resultaat = <String, OffertePrijsprofielModel>{};
    for (final formulierType
        in OfferteArtikelPrijsKoppelingService.ondersteundeFormulierTypes) {
      resultaat[formulierType] = await laadPrijsprofielVoorFormulierType(
        formulierType,
      );
    }
    return resultaat;
  }

  String _formulierNaamVoorPrijsType(String formulierType) {
    return OfferteArtikelPrijsKoppelingService.formulierNaamVoor(formulierType);
  }

  OffertePrijsprofielModel _algemeenPrijsprofielVoorMomentopname(
    OffertePrijsprofielModel profiel,
  ) {
    return profiel.copyWith(
      prijsregels: profiel.prijsregels
          .where(
            (regel) =>
                regel.categorie ==
                    OffertePrijsCategorie.technischeKeuzePerArtikel ||
                regel.categorie == OffertePrijsCategorie.vrijPerArtikel ||
                regel.categorie == OffertePrijsCategorie.alleArtikelen,
          )
          .toList(growable: false),
    );
  }

  OffertePrijsinstellingenMomentopname maakPrijsinstellingenMomentopname(
    OffertePrijsprofielModel profiel,
  ) {
    final koppeling =
        OfferteArtikelPrijsKoppelingService.koppelingVoorFormulierType(
          profiel.formulierType,
        );
    final profielVoorMomentopname = koppeling?.isAlgemeenArtikel == true
        ? _algemeenPrijsprofielVoorMomentopname(profiel)
        : profiel;
    return OffertePrijsinstellingenMomentopname.vanProfiel(
      profielVoorMomentopname,
    );
  }

  OffertePrijsinstellingenMomentopname?
  _filterOudePrijsinstellingenMomentopname(
    OffertePrijsinstellingenMomentopname? momentopname,
  ) {
    if (momentopname == null) return null;
    return maakPrijsinstellingenMomentopname(momentopname.naarProfiel());
  }

  Map<String, OffertePrijsinstellingenMomentopname>
  maakHuidigePrijsinstellingenMomentopnames(
    Map<String, OffertePrijsprofielModel> profielen,
  ) {
    return <String, OffertePrijsinstellingenMomentopname>{
      for (final formulierType
          in OfferteArtikelPrijsKoppelingService.ondersteundeFormulierTypes)
        formulierType: maakPrijsinstellingenMomentopname(
          profielen[formulierType] ??
              OffertePrijsprofielModel.leeg(
                formulierType: formulierType,
                formulierNaam: _formulierNaamVoorPrijsType(formulierType),
              ),
        ),
    };
  }

  Map<String, OffertePrijsinstellingenMomentopname?>
  leesOudePrijsinstellingenMomentopnames(OpmetingProjectTitelhoofd titelhoofd) {
    return <String, OffertePrijsinstellingenMomentopname?>{
      for (final formulierType
          in OfferteArtikelPrijsKoppelingService.ondersteundeFormulierTypes)
        formulierType: _filterOudePrijsinstellingenMomentopname(
          titelhoofd.prijsinstellingenMomentopnameVoor(formulierType),
        ),
    };
  }

  String _samengesteldePrijsinstellingenSignatuur(
    Iterable<OffertePrijsinstellingenMomentopname> momentopnames,
  ) {
    final gesorteerd = momentopnames.toList(growable: false)
      ..sort(
        (eerste, tweede) => _normaliseerFormulierType(
          eerste.formulierType,
        ).compareTo(_normaliseerFormulierType(tweede.formulierType)),
      );

    return jsonEncode(<String, String>{
      for (final momentopname in gesorteerd)
        _normaliseerFormulierType(momentopname.formulierType):
            momentopname.signatuur,
    });
  }

  Future<OfferteTechnischePrijsMomentopnameResultaat>
  werkTechnischePrijsMomentopnamesBij({
    required List<OpmetingOverzichtRaamItem> alleOpmetingen,
    required String klantNaam,
    required bool berekenPrijzen,
    Map<String, OffertePrijsprofielModel>? prijsprofielen,
    List<OffertePrijsregelModel> tijdelijkeProjectPrijsregels =
        const <OffertePrijsregelModel>[],
    bool forceerPrijsinstellingen = false,
  }) async {
    if (!berekenPrijzen || klantNaam.trim().isEmpty) {
      return OfferteTechnischePrijsMomentopnameResultaat(
        opmetingen: alleOpmetingen,
        gewijzigd: false,
      );
    }

    OffertePrijsprofielModel combineerProjectRegels(
      OffertePrijsprofielModel basis,
    ) {
      final formulierSleutel = _normaliseerFormulierType(basis.formulierType);
      final regelsPerId = <String, OffertePrijsregelModel>{
        for (final regel in basis.prijsregels) regel.id: regel,
      };

      for (final regel in tijdelijkeProjectPrijsregels) {
        if (regel.categorie != OffertePrijsCategorie.alleArtikelen ||
            _normaliseerFormulierType(regel.formulierType) !=
                formulierSleutel) {
          continue;
        }

        regelsPerId[regel.id] = regel.copyWith(
          categorie: OffertePrijsCategorie.alleArtikelen,
          formulierType: basis.formulierType,
        );
      }

      return basis.copyWith(
        prijsregels: regelsPerId.values.toList(growable: false),
      );
    }

    final basisProfielen =
        prijsprofielen ?? await laadOndersteundePrijsprofielen();
    final profielen = <String, OffertePrijsprofielModel>{
      for (final formulierType
          in OfferteArtikelPrijsKoppelingService.ondersteundeFormulierTypes)
        formulierType: combineerProjectRegels(
          basisProfielen[formulierType] ??
              OffertePrijsprofielModel.leeg(
                formulierType: formulierType,
                formulierNaam: _formulierNaamVoorPrijsType(formulierType),
              ),
        ),
    };
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
          if (koppeling == null) return opmeting;

          final profiel = profielen[koppeling.formulierType];
          if (profiel == null) return opmeting;

          if (koppeling.isVasteInzethor) {
            final model = opmeting.vasteInzethorData;
            if (model == null) return opmeting;

            var bijgewerktModel = model;
            var modelGewijzigd = false;

            if (OffertePrijsBerekeningService.moetTechnischeMomentopnameBijwerken(
              bijgewerktModel,
            )) {
              bijgewerktModel =
                  OffertePrijsBerekeningService.maakTechnischeMomentopname(
                    model: bijgewerktModel,
                  );
              modelGewijzigd = true;
            }

            var prijsData = bijgewerktModel.prijsData;
            if (OfferteAlgemeenArtikelPrijsService.moetVrijeArtikelMomentopnameBijwerken(
              prijsData: prijsData,
              profiel: profiel,
              artikelSignatuur: bijgewerktModel.prijsBerekeningSignatuur,
              forceer: forceerPrijsinstellingen,
            )) {
              prijsData =
                  OfferteAlgemeenArtikelPrijsService.maakVrijeArtikelMomentopname(
                    prijsData: prijsData,
                    profiel: profiel,
                    artikelSignatuur: bijgewerktModel.prijsBerekeningSignatuur,
                  );
              bijgewerktModel = bijgewerktModel.copyWithPrijsData(prijsData);
              modelGewijzigd = true;
            }

            if (!modelGewijzigd) return opmeting;

            gewijzigd = true;
            return opmeting
                .copyWith(vasteInzethorData: bijgewerktModel)
                .metNieuweWijzigingsDatum();
          }

          var prijsData = opmeting.offertePrijsData;
          var prijsDataGewijzigd = false;

          final veluxModel = opmeting.veluxDakraamData;
          if (koppeling.ondersteuntTechnischeKeuzeprijzen &&
              veluxModel != null) {
            final artikelSignatuur = jsonEncode(<String, Object>{
              'formulierType': 'veluxDakraam',
              'productCode': veluxModel.productCode,
              'maatCode': veluxModel.maatCode,
              'breedteMm': veluxModel.breedteMm,
              'hoogteMm': veluxModel.hoogteMm,
              'aantal': veluxModel.veiligAantal,
              'afwerkingType': veluxModel.afwerkingType.name,
            });

            if (OfferteTechnischePrijsMomentopnameService.moetMomentopnameBijwerken(
              prijsData: prijsData,
              profiel: profiel,
              artikelSignatuur: artikelSignatuur,
              forceer: forceerPrijsinstellingen,
            )) {
              prijsData =
                  OfferteTechnischePrijsMomentopnameService.maakMomentopname(
                    prijsData: prijsData,
                    profiel: profiel,
                    breedteMm: veluxModel.breedteMm,
                    hoogteMm: veluxModel.hoogteMm,
                    aantal: veluxModel.veiligAantal,
                    artikelSignatuur: artikelSignatuur,
                    keuzeIsGeselecteerd: (keuze) {
                      return _normaliseerFormulierType(keuze.formulierType) ==
                              'veluxdakraam' &&
                          keuze.menuId.trim() == 'veluxAfwerking' &&
                          keuze.keuzeId.trim() ==
                              veluxModel.afwerkingType.name &&
                          veluxModel.afwerkingType.name != 'geen';
                    },
                  );
              prijsDataGewijzigd = true;
            }
          } else if (koppeling.ondersteuntTechnischeKeuzeprijzen &&
              OfferteAlgemeenArtikelPrijsService.moetTechnischeMomentopnameBijwerken(
                prijsData: prijsData,
                profiel: profiel,
                keuzeSelectiesPerKader: opmeting.keuzeSelectiesPerKader,
                breedteMm: opmeting.raammaatBreedteMm,
                hoogteMm: opmeting.raammaatHoogteMm,
                forceer: forceerPrijsinstellingen,
              )) {
            prijsData =
                OfferteAlgemeenArtikelPrijsService.maakTechnischeMomentopname(
                  prijsData: prijsData,
                  profiel: profiel,
                  keuzeSelectiesPerKader: opmeting.keuzeSelectiesPerKader,
                  breedteMm: opmeting.raammaatBreedteMm,
                  hoogteMm: opmeting.raammaatHoogteMm,
                );
            prijsDataGewijzigd = true;
          }

          if (OfferteAlgemeenArtikelPrijsService.moetVrijeArtikelMomentopnameBijwerken(
            prijsData: prijsData,
            profiel: profiel,
            forceer: forceerPrijsinstellingen,
          )) {
            prijsData =
                OfferteAlgemeenArtikelPrijsService.maakVrijeArtikelMomentopname(
                  prijsData: prijsData,
                  profiel: profiel,
                );
            prijsDataGewijzigd = true;
          }

          if (!prijsDataGewijzigd) return opmeting;

          gewijzigd = true;
          return OfferteArtikelPrijsKoppelingService.schrijfPrijsData(
            artikel: opmeting,
            prijsData: prijsData,
          ).metNieuweWijzigingsDatum();
        })
        .toList(growable: false);

    var verdeelkostOpmetingen = bijgewerkteOpmetingen;
    var verdeelkostenGewijzigd = false;

    // Iedere profielgebonden artikelgroep wordt herberekend. De eerdere
    // hardcodering voor alleen vaste inzethor en PVC raam sloeg vijf groepen
    // volledig over.
    for (final formulierType
        in OfferteArtikelPrijsKoppelingService.ondersteundeFormulierTypes) {
      final profiel = profielen[formulierType];
      if (profiel == null) continue;

      final resultaat = OfferteVerdeelkostService.werkMomentopnamesBij(
        alleOpmetingen: verdeelkostOpmetingen,
        klantNaam: klantNaam,
        profiel: profiel,
        forceer: forceerPrijsinstellingen,
      );
      verdeelkostOpmetingen = resultaat.opmetingen;
      verdeelkostenGewijzigd = verdeelkostenGewijzigd || resultaat.gewijzigd;
    }

    // Voeg automatische interne kosten met dezelfde omschrijving uit
    // verschillende artikeltypes eerst samen tot één projectkost.
    //
    // Voorbeeld:
    // PVC raam: Transport € 40
    // Vaste inzethor: Transport € 40
    //
    // Resultaat: één kost van € 40, verdeeld over alle betrokken artikelen.
    final gekoppeldeVerdeelkostenResultaat =
        OfferteGekoppeldeVerdeelkostService.werkBij(
          alleOpmetingen: verdeelkostOpmetingen,
          klantNaam: klantNaam,
          profielen: profielen,
        );

    verdeelkostOpmetingen = gekoppeldeVerdeelkostenResultaat.opmetingen;

    verdeelkostenGewijzigd =
        verdeelkostenGewijzigd || gekoppeldeVerdeelkostenResultaat.gewijzigd;

    // Expliciet gekozen posities vormen één gezamenlijke verdeelgroep, ook
    // wanneer verschillende artikeltypes werden geselecteerd. Hierdoor doet
    // ook de handmatig geprijsde vliegendeur correct mee.
    final geselecteerdeVerdeelkostenResultaat =
        OfferteVerdeelkostService.werkGeselecteerdeProjectVerdeelkostenBij(
          alleOpmetingen: verdeelkostOpmetingen,
          klantNaam: klantNaam,
          profielen: profielen,
        );

    return OfferteTechnischePrijsMomentopnameResultaat(
      opmetingen: geselecteerdeVerdeelkostenResultaat.opmetingen,
      gewijzigd:
          gewijzigd ||
          verdeelkostenGewijzigd ||
          geselecteerdeVerdeelkostenResultaat.gewijzigd,
    );
  }

  List<OffertePrijsinstellingenWijziging> bepaalPrijsinstellingenWijzigingen({
    required OffertePrijsinstellingenMomentopname? oud,
    required OffertePrijsinstellingenMomentopname huidig,
  }) {
    if (oud == null) {
      return huidig.eersteKoppelingWijzigingen();
    }

    return oud.wijzigingenNaar(huidig);
  }

  Future<void> controleerOpenOfferteOpPrijsinstellingen() async {
    if (_controleBezig ||
        leesIsLaden() ||
        !leesHeeftOpenBestand() ||
        !leesTitelhoofd().berekenPrijzen) {
      _toonWachtendeAutomatischePrijsMeldingIndienMogelijk();
      return;
    }

    _controleBezig = true;

    try {
      final huidigeProfielen = await laadOndersteundePrijsprofielen();
      final huidigeMomentopnames = maakHuidigePrijsinstellingenMomentopnames(
        huidigeProfielen,
      );
      final oudeMomentopnames = leesOudePrijsinstellingenMomentopnames(
        leesTitelhoofd(),
      );
      final huidigeSamengesteldeSignatuur =
          _samengesteldePrijsinstellingenSignatuur(huidigeMomentopnames.values);

      if (_genegeerdePrijsinstellingenSignatuur ==
          huidigeSamengesteldeSignatuur) {
        _toonWachtendeAutomatischePrijsMeldingIndienMogelijk();
        return;
      }

      bool isOngewijzigd(String formulierType) {
        final oud = oudeMomentopnames[formulierType];
        final huidig = huidigeMomentopnames[formulierType]!;
        // Een ontbrekende momentopname is een eerste nulmeting, geen
        // inhoudelijke prijswijziging. Ze wordt bij het laden stil opgeslagen.
        return oud == null ? true : oud.heeftZelfdeInhoudAls(huidig);
      }

      final gewijzigdeFormulierTypes = OfferteArtikelPrijsKoppelingService
          .ondersteundeFormulierTypes
          .where((formulierType) => !isOngewijzigd(formulierType))
          .toList(growable: false);

      if (gewijzigdeFormulierTypes.isEmpty) {
        _toonWachtendeAutomatischePrijsMeldingIndienMogelijk();
        return;
      }

      final wijzigingen = <OffertePrijsinstellingenWijziging>[
        for (final formulierType in gewijzigdeFormulierTypes)
          ...bepaalPrijsinstellingenWijzigingen(
            oud: oudeMomentopnames[formulierType],
            huidig: huidigeMomentopnames[formulierType]!,
          ),
      ];

      final klantNaam = leesKlantNaam();
      await herlaadOpmetingen(klantNaam, true);

      if (!isMounted()) return;
      if (!context.mounted) return;

      if (ModalRoute.of(context)?.isCurrent == true) {
        _toonAutomatischePrijsMelding(wijzigingen);
      } else {
        _wachtendeWijzigingen = wijzigingen;
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
    wisGenegeerdePrijsinstellingenSignatuur();

    try {
      final huidigeProfielen = await laadOndersteundePrijsprofielen();
      final huidigeMomentopnames = maakHuidigePrijsinstellingenMomentopnames(
        huidigeProfielen,
      );
      final oudeMomentopnames = leesOudePrijsinstellingenMomentopnames(
        leesTitelhoofd(),
      );
      final wijzigingen = <OffertePrijsinstellingenWijziging>[
        for (final formulierType
            in OfferteArtikelPrijsKoppelingService.ondersteundeFormulierTypes)
          ...bepaalPrijsinstellingenWijzigingen(
            oud: oudeMomentopnames[formulierType],
            huidig: huidigeMomentopnames[formulierType]!,
          ),
      ];

      await herlaadOpmetingen(leesKlantNaam(), true);

      if (!isMounted()) return;

      if (wijzigingen.isEmpty) {
        toonMelding(
          'Offerte opnieuw berekend met de huidige instellingen.',
          false,
        );
      } else {
        _toonAutomatischePrijsMelding(wijzigingen);
      }
    } finally {
      _stelHerberekeningBezigIn(false);
    }
  }

  void _stelHerberekeningBezigIn(bool waarde) {
    if (_herberekeningBezig == waarde) return;
    _herberekeningBezig = waarde;
    if (isMounted()) {
      onHerberekeningStatusGewijzigd();
    }
  }

  void _toonWachtendeAutomatischePrijsMeldingIndienMogelijk() {
    if (!isMounted() ||
        _wachtendeWijzigingen.isEmpty ||
        ModalRoute.of(context)?.isCurrent != true) {
      return;
    }

    final wijzigingen = List<OffertePrijsinstellingenWijziging>.from(
      _wachtendeWijzigingen,
    );
    _wachtendeWijzigingen = <OffertePrijsinstellingenWijziging>[];
    _toonAutomatischePrijsMelding(wijzigingen);
  }

  void _toonAutomatischePrijsMelding(
    List<OffertePrijsinstellingenWijziging> wijzigingen,
  ) {
    if (!isMounted()) return;

    final aantal = wijzigingen.length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _groen,
        content: Text(
          aantal == 0
              ? 'Offerte automatisch herberekend.'
              : 'Offerte automatisch herberekend na $aantal prijswijziging(en).',
        ),
        action: aantal == 0
            ? null
            : SnackBarAction(
                label: 'Bekijken',
                textColor: Colors.white,
                onPressed: () {
                  _toonPrijsinstellingenDetails(wijzigingen);
                },
              ),
      ),
    );
  }

  Future<bool?> vraagPrijsinstellingenOvernemen({
    required List<OffertePrijsinstellingenWijziging> wijzigingen,
    required bool eersteKoppeling,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: <Widget>[
              const Icon(Icons.post_add_outlined, color: _groen),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  eersteKoppeling
                      ? 'Prijsinstellingen koppelen?'
                      : 'Prijsinstellingen gewijzigd',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 560,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  eersteKoppeling
                      ? 'Voor deze oudere offerte is nog geen prijsinstellingenmomentopname opgeslagen. Wilt u de huidige instellingen toepassen?'
                      : 'Onderstaande prijsinstellingen verschillen van de instellingen waarmee deze offerte het laatst werd berekend.',
                  style: const TextStyle(
                    color: _tekstGrijs,
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _bouwPrijsWijzigingenLijst(wijzigingen),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Oude prijzen behouden'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _groen),
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Nieuwe instellingen toepassen'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toonPrijsinstellingenDetails(
    List<OffertePrijsinstellingenWijziging> wijzigingen,
  ) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Verwerkte prijswijzigingen',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: SizedBox(
            width: 560,
            child: _bouwPrijsWijzigingenLijst(wijzigingen),
          ),
          actions: <Widget>[
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _groen),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Sluiten'),
            ),
          ],
        );
      },
    );
  }

  Widget _bouwPrijsWijzigingenLijst(
    List<OffertePrijsinstellingenWijziging> wijzigingen,
  ) {
    if (wijzigingen.isEmpty) {
      return const Text(
        'Er zijn geen inhoudelijke wijzigingen gevonden. De offerte wordt wel volledig opnieuw berekend.',
        style: TextStyle(color: _tekstGrijs, fontWeight: FontWeight.w600),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 360),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: wijzigingen.length,
        separatorBuilder: (_, _) => const Divider(height: 18),
        itemBuilder: (context, index) {
          final wijziging = wijzigingen[index];
          final icoon = switch (wijziging.type) {
            OffertePrijsinstellingenWijzigingType.toegevoegd =>
              Icons.add_circle_outline_rounded,
            OffertePrijsinstellingenWijzigingType.verwijderd =>
              Icons.remove_circle_outline_rounded,
            OffertePrijsinstellingenWijzigingType.gewijzigd =>
              Icons.edit_outlined,
          };
          final kleur = switch (wijziging.type) {
            OffertePrijsinstellingenWijzigingType.toegevoegd => _groen,
            OffertePrijsinstellingenWijzigingType.verwijderd => const Color(
              0xFFDC2626,
            ),
            OffertePrijsinstellingenWijzigingType.gewijzigd => const Color(
              0xFFF15A24,
            ),
          };

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icoon, color: kleur, size: 21),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      wijziging.titel,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    if (wijziging.details.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 4),
                      ...wijziging.details.map(
                        (detail) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            detail,
                            style: const TextStyle(
                              color: _tekstGrijs,
                              fontSize: 12.5,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
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
