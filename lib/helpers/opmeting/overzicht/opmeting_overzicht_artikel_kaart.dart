// THIMACO-CONTROLE: ALGEMENE-OPMETING-EIGEN-AANKOOP-VERKOOP-PRIJSZONE-20260817
// THIMACO-CONTROLE: TECHNISCHE-KEUZE-DYNAMISCHE-REGELHOOGTE-20260817
// THIMACO-CONTROLE: PRIJS-VOOR-ALLE-POSITIES-NIET-MEER-PER-ARTIKEL-20260816
// THIMACO-CONTROLE: VERDEELDE-KOST-HOOGTE-IN-PRIJSZONE-20260816
// THIMACO-CONTROLE: PRIJS-VOOR-ALLE-POSITIES-FASE2-ARTIKELKAART-20260815
// THIMACO-CONTROLE: TECHNISCHE-LEEGTE-UNIFORM-20260814
// THIMACO-CONTROLE: PRIJS-PER-POSITIE-TABEL-KAART-20260813
// THIMACO-CONTROLE: COMPACTE-PRIJSBEREKENING-RECHTERKOLOM-20260813
// THIMACO-CONTROLE: PRIJS-PER-POSITIE-HELPER-UITSPLITSING-20260813
// THIMACO-CONTROLE: OUDE-VRIJE-PRIJS-KNOP-UIT-OVERZICHT-20260813
// THIMACO-CONTROLE: BUITENJALOEZIE-DEFINITIEF-OVERZICHT-20260803
// THIMACO-CONTROLE: BUITENJALOEZIE-OVERZICHT-WINST-KORTING-ACTIEF-20260803
// THIMACO-CONTROLE: BUITENJALOEZIE-OVERZICHT-VOLLEDIG-FASE-4-20260803
// THIMACO-CONTROLE: ALGEMENE-OPMETING-PRIJSUITSPITSING-OVERZICHT-20260802
// THIMACO-CONTROLE: ALGEMENE-OPMETING-VOLLEDIG-AFGEWERKT-OVERZICHT-20260802
// THIMACO-CONTROLE: UITVALSCHERM-OVERZICHT-VOLLEDIG-20260801
// THIMACO-CONTROLE: VOORZETROLLUIK-OVERZICHT-VOLLEDIG-20260731
// THIMACO-CONTROLE: VELUX-GEEN-STUKPRIJS-NAAST-OMSCHRIJVING-20260730
// THIMACO-CONTROLE: VELUX-KLANTOMSCHRIJVING-VERKOOPPRIJS-20260730
// THIMACO-CONTROLE: VELUX-OVERZICHT-EN-CATALOGUSPRIJS-20260729-2212
// THIMACO-CONTROLE: TECHNISCHE-PRIJSREGELS-IN-PRIJSBEREKENING-20260729-1415
// THIMACO-CONTROLE: SEKTIONALE-POORTEN-OVERZICHT-KAART-20260729
// THIMACO-CONTROLE: PLOOIWERKEN-OVERZICHT-VOLLEDIGE-RECHTERKOLOM-20260728-2205
// THIMACO-CONTROLE: PLOOIWERKEN-OVERZICHT-TEKENVLAK-MODEL-HERSTEL-20260728
// THIMACO-CONTROLE: PLOOIWERKEN-OVERZICHT-KOPPELING-20260728
// THIMACO-CONTROLE: SCHUIFVLIEGENDEUR-OVERZICHT-PRIJSBLOK-20260728
// THIMACO-CONTROLE: SCHUIFVLIEGENDEUR-OVERZICHT-KOPPELING-20260728
// THIMACO-CONTROLE: OVERZICHT-ARTIKEL-OMSCHRIJVING-GELIJK-OFFERTE-20260727
// THIMACO-CONTROLE: OVERZICHT-ARTIKEL-KAART-GEDEELDE-PRIJSOPBOUW-20260721
import 'package:flutter/material.dart';

import '../../offerte/prijzen/offerte_artikel_prijs_koppeling_service.dart';
import '../../offerte/prijzen/offerte_artikel_prijs_data_model.dart';
import '../../offerte/prijzen/offerte_prijs_voor_alle_posities_regel_model.dart';
import '../../offerte/prijzen/offerte_berekening_resultaat.dart';
import '../../offerte/prijzen/offerte_toegepaste_prijsregel_model.dart';
import '../fotos/opmeting_foto_model.dart';
import '../algemene_opmeting/opmeting_algemene_opmeting_model.dart';
import '../algemene_opmeting/opmeting_algemene_opmeting_technische_regels_helper.dart';
import '../algemene_opmeting/opmeting_algemene_opmeting_tekenvlak.dart';
import '../toebehoren/vliegendeur/opmeting_vliegendeur_model.dart';
import '../toebehoren/vliegendeur/opmeting_vliegendeur_tekenvlak.dart';
import '../toebehoren/schuifvliegendeur/opmeting_schuifvliegendeur_model.dart';
import '../toebehoren/schuifvliegendeur/opmeting_schuifvliegendeur_tekenvlak.dart';
import '../toebehoren/plooiwerken/opmeting_plooiwerken_model.dart';
import '../toebehoren/plooiwerken/opmeting_plooiwerken_technische_regels_helper.dart';
import '../toebehoren/plooiwerken/opmeting_plooiwerken_tekenvlak.dart';
import '../toebehoren/voorzetscreen/opmeting_voorzetscreen_model.dart';
import '../toebehoren/voorzetscreen/opmeting_voorzetscreen_technische_regels_helper.dart';
import '../toebehoren/voorzetscreen/opmeting_voorzetscreen_tekenvlak.dart';
import '../toebehoren/buitenjaloezie/opmeting_buitenjaloezie_model.dart';
import '../toebehoren/buitenjaloezie/opmeting_buitenjaloezie_technische_regels_helper.dart';
import '../toebehoren/buitenjaloezie/opmeting_buitenjaloezie_tekenvlak.dart';
import '../toebehoren/voorzetrolluik/opmeting_voorzetrolluik_model.dart';
import '../toebehoren/voorzetrolluik/opmeting_voorzetrolluik_technische_regels_helper.dart';
import '../toebehoren/voorzetrolluik/opmeting_voorzetrolluik_tekenvlak.dart';
import '../toebehoren/uitvalscherm/opmeting_uitvalscherm_model.dart';
import '../toebehoren/uitvalscherm/opmeting_uitvalscherm_technische_regels_helper.dart';
import '../toebehoren/uitvalscherm/opmeting_uitvalscherm_tekenvlak.dart';
import '../toebehoren/sektionale_poort/opmeting_sektionale_poort_model.dart';
import '../toebehoren/sektionale_poort/opmeting_sektionale_poort_technische_regels_helper.dart';
import '../toebehoren/sektionale_poort/opmeting_sektionale_poort_tekenvlak.dart';
import '../toebehoren/velux_dakramen/opmeting_velux_dakraam_model.dart';
import '../toebehoren/velux_dakramen/opmeting_velux_dakraam_omschrijving_helper.dart';
import '../toebehoren/velux_dakramen/opmeting_velux_dakraam_painter.dart';
import '../toebehoren/vaste_inzethor/opmeting_vaste_inzethor_model.dart';
import '../toebehoren/vaste_inzethor/opmeting_vaste_inzethor_tekenvlak.dart';
import 'opmeting_artikel_type_omschrijving_helper.dart';
import 'opmeting_overzicht_artikel_layout_helper.dart';
import 'opmeting_overzicht_model.dart';
import 'opmeting_overzicht_prijs_per_positie.dart';
import 'opmeting_overzicht_prijs_voor_alle_posities.dart';
import 'opmeting_overzicht_technische_prijs_koppel_helper.dart';
import 'opmeting_overzicht_tekening.dart';

class OpmetingOverzichtArtikelKaart extends StatelessWidget {
  const OpmetingOverzichtArtikelKaart({
    super.key,
    required this.item,
    required this.positieLabel,
    required this.berekenPrijzen,
    required this.onOpenen,
    required this.onVerwijderen,
    required this.onKopieren,
    required this.onOptieWijzigen,
    this.onNietRekenenWijzigen,
    required this.onPrijsGewijzigd,
    required this.onWinstmargeGewijzigd,
    required this.onKortingGewijzigd,
    required this.onPrijsPerPositieRegelsGewijzigd,
    required this.prijsVoorAllePositiesRegels,
    required this.prijsDoelPosities,
    required this.onPrijsVoorAllePositiesRegelsGewijzigd,
    this.toonPrijsVoorAllePosities = true,
    required this.onOmhoog,
    required this.onOmlaag,
  });

  final OpmetingOverzichtRaamItem item;
  final String positieLabel;
  final bool berekenPrijzen;
  final VoidCallback onOpenen;
  final VoidCallback onVerwijderen;
  final VoidCallback onKopieren;
  final VoidCallback onOptieWijzigen;
  final VoidCallback? onNietRekenenWijzigen;
  final ValueChanged<double> onPrijsGewijzigd;
  final ValueChanged<double> onWinstmargeGewijzigd;
  final ValueChanged<double> onKortingGewijzigd;
  final ValueChanged<List<OffertePrijsPerPositieRegelModel>>
  onPrijsPerPositieRegelsGewijzigd;
  final List<OffertePrijsVoorAllePositiesRegelModel>
  prijsVoorAllePositiesRegels;
  final List<OpmetingOverzichtPrijsDoelPositie> prijsDoelPosities;
  final ValueChanged<List<OffertePrijsVoorAllePositiesRegelModel>>
  onPrijsVoorAllePositiesRegelsGewijzigd;
  final bool toonPrijsVoorAllePosities;
  final VoidCallback? onOmhoog;
  final VoidCallback? onOmlaag;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);
  static const Color _rood = Color(0xFFDC2626);
  static const Color _roodLicht = Color(0xFFFEF2F2);
  static const Color _roodRand = Color(0xFFFCA5A5);

  @override
  Widget build(BuildContext context) {
    final technischeRegels =
        OpmetingOverzichtArtikelLayoutHelper.combineerTechnischeRegels(
          _technischeRegelsZonderMaten(item.zichtbareTechnischeRegels),
        );
    final vasteInzethor = item.vasteInzethorData;
    final vliegendeur = item.vliegendeurData;
    final schuifvliegendeur = item.schuifvliegendeurData;
    final plooiwerken = item.plooiwerkenData;
    final voorzetscreen = item.voorzetscreenData;
    final buitenjaloezie = item.buitenjaloezieData;
    final voorzetrolluik = item.voorzetrolluikData;
    final uitvalscherm = item.uitvalschermData;
    final algemeneOpmeting = item.algemeneOpmetingData;
    final sektionalePoort = item.sektionalePoortData;
    final veluxDakraam = item.veluxDakraamData;
    final vliegendeurTechnischeRegels = vliegendeur == null
        ? const <OpmetingOverzichtTechnischeRegel>[]
        : OpmetingOverzichtArtikelLayoutHelper.combineerTechnischeRegels(
            _vliegendeurRegelsZonderAfmetingen(item.zichtbareTechnischeRegels),
          );
    final schuifvliegendeurTechnischeRegels = schuifvliegendeur == null
        ? const <OpmetingOverzichtTechnischeRegel>[]
        : OpmetingOverzichtArtikelLayoutHelper.combineerTechnischeRegels(
            _schuifvliegendeurRegelsVoorOverzicht(
              item.zichtbareTechnischeRegels,
            ),
          );
    final plooiwerkenTechnischeRegels = plooiwerken == null
        ? const <OpmetingOverzichtTechnischeRegel>[]
        : OpmetingOverzichtArtikelLayoutHelper.combineerTechnischeRegels(
            _plooiwerkenRegelsVoorOverzicht(
              OpmetingPlooiwerkenTechnischeRegelsHelper.bouw(plooiwerken),
            ),
          );
    final voorzetscreenTechnischeRegels = voorzetscreen == null
        ? const <OpmetingOverzichtTechnischeRegel>[]
        : OpmetingOverzichtArtikelLayoutHelper.combineerTechnischeRegels(
            OpmetingVoorzetscreenTechnischeRegelsHelper.bouw(voorzetscreen),
          );
    final buitenjaloezieTechnischeRegels = buitenjaloezie == null
        ? const <OpmetingOverzichtTechnischeRegel>[]
        : OpmetingOverzichtArtikelLayoutHelper.combineerTechnischeRegels(
            OpmetingBuitenjaloezieTechnischeRegelsHelper.bouw(buitenjaloezie),
          );
    final voorzetrolluikTechnischeRegels = voorzetrolluik == null
        ? const <OpmetingOverzichtTechnischeRegel>[]
        : OpmetingOverzichtArtikelLayoutHelper.combineerTechnischeRegels(
            OpmetingVoorzetrolluikTechnischeRegelsHelper.bouw(voorzetrolluik),
          );
    final uitvalschermTechnischeRegels = uitvalscherm == null
        ? const <OpmetingOverzichtTechnischeRegel>[]
        : OpmetingOverzichtArtikelLayoutHelper.combineerTechnischeRegels(
            OpmetingUitvalschermTechnischeRegelsHelper.bouw(uitvalscherm),
          );
    final sektionalePoortTechnischeRegels = sektionalePoort == null
        ? const <OpmetingOverzichtTechnischeRegel>[]
        : OpmetingOverzichtArtikelLayoutHelper.combineerTechnischeRegels(
            _sektionalePoortRegelsVoorOverzicht(
              OpmetingSektionalePoortTechnischeRegelsHelper.bouw(
                sektionalePoort,
              ),
            ),
          );
    final uitvoeringsRegels =
        OpmetingArtikelTypeOmschrijvingHelper.omschrijvingRegelsVoor(item);
    final algemenePositieLabel = algemeneOpmeting == null
        ? positieLabel
        : '$positieLabel · ${algemeneOpmeting.effectieveTitel}';
    final artikelOmschrijving = algemeneOpmeting != null
        ? ''
        : buitenjaloezie != null
        ? <String>[
            item.formulierTypeLabel.trim(),
            buitenjaloezie.systeem.label,
            buitenjaloezie.lameltype.label,
            buitenjaloezie.lamelkleurSamenvatting,
          ].where((regel) => regel.trim().isNotEmpty).join('  -  ')
        : veluxDakraam == null
        ? <String>[
            item.formulierTypeLabel.trim(),
            ...uitvoeringsRegels.map((regel) => regel.trim()),
          ].where((regel) => regel.isNotEmpty).join('  -  ')
        : _veluxTitel(veluxDakraam);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.isNietRekenen
            ? const Color(0xFFFFFAFA)
            : item.isOfferteOptie
            ? const Color(0xFFFFFBF5)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isNietRekenen
              ? _roodRand
              : item.isOfferteOptie
              ? const Color(0xFFF15A24)
              : _rand,
          width: item.isNietRekenen ? 1.25 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: item.isNietRekenen ? _roodLicht : _lichtGroen,
                  borderRadius: BorderRadius.circular(999),
                  border: item.isNietRekenen
                      ? Border.all(color: _roodRand)
                      : null,
                ),
                child: Text(
                  item.isNietRekenen
                      ? 'NIET REKENEN'
                      : item.isOfferteOptie
                      ? item.isOfferteOptieOpPositie
                            ? '$algemenePositieLabel · IN OFFERTE'
                            : '$algemenePositieLabel · APARTE PAGINA'
                      : algemenePositieLabel,
                  style: TextStyle(
                    color: item.isNietRekenen ? _rood : _groen,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (artikelOmschrijving.isNotEmpty) ...<Widget>[
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      artikelOmschrijving,
                      style: const TextStyle(
                        color: _tekstGrijs,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        height: 1.25,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                flex: 6,
                child: Align(
                  alignment: Alignment.topRight,
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 6,
                    children: <Widget>[
                      if (item.isNietRekenen) ...<Widget>[
                        if (onNietRekenenWijzigen != null)
                          _ArtikelActieTekstKnop(
                            tekst: 'Groep terug rekenen',
                            onPressed: onNietRekenenWijzigen,
                          ),
                      ] else ...<Widget>[
                        _ArtikelActieTekstKnop(
                          tekst: 'Aanpassen',
                          onPressed: onOpenen,
                        ),
                        _ArtikelActieTekstKnop(
                          tekst: 'Groep kopiëren',
                          onPressed: onKopieren,
                        ),
                        _ArtikelActieTekstKnop(
                          tekst: 'Groep in optie plaatsen',
                          onPressed: onOptieWijzigen,
                        ),
                        if (onNietRekenenWijzigen != null)
                          _ArtikelActieTekstKnop(
                            tekst: 'Groep niet rekenen',
                            onPressed: onNietRekenenWijzigen,
                          ),
                        IconButton(
                          tooltip: 'Verwijderen',
                          onPressed: onVerwijderen,
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                        _PositieVerplaatsKnop(
                          onOmhoog: onOmhoog,
                          onOmlaag: onOmlaag,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (vasteInzethor != null)
            _bouwVasteInzethorOverzicht(vasteInzethor, technischeRegels)
          else if (vliegendeur != null)
            _bouwVliegendeurOverzicht(vliegendeur, vliegendeurTechnischeRegels)
          else if (schuifvliegendeur != null)
            _bouwSchuifvliegendeurOverzicht(
              schuifvliegendeur,
              schuifvliegendeurTechnischeRegels,
            )
          else if (plooiwerken != null)
            _bouwPlooiwerkenOverzicht(plooiwerken, plooiwerkenTechnischeRegels)
          else if (voorzetscreen != null)
            _bouwVoorzetscreenOverzicht(
              voorzetscreen,
              voorzetscreenTechnischeRegels,
            )
          else if (buitenjaloezie != null)
            _bouwBuitenjaloezieOverzicht(
              buitenjaloezie,
              buitenjaloezieTechnischeRegels,
            )
          else if (voorzetrolluik != null)
            _bouwVoorzetrolluikOverzicht(
              voorzetrolluik,
              voorzetrolluikTechnischeRegels,
            )
          else if (uitvalscherm != null)
            _bouwUitvalschermOverzicht(
              uitvalscherm,
              uitvalschermTechnischeRegels,
            )
          else if (algemeneOpmeting != null)
            _bouwAlgemeneOpmetingOverzicht(algemeneOpmeting)
          else if (sektionalePoort != null)
            _bouwSektionalePoortOverzicht(
              sektionalePoort,
              sektionalePoortTechnischeRegels,
            )
          else if (veluxDakraam != null)
            _bouwVeluxDakraamOverzicht(veluxDakraam)
          else if (OfferteArtikelPrijsKoppelingService.isAlgemeenArtikel(item))
            _bouwAlgemeenArtikelOverzicht(technischeRegels)
          else ...[
            Text(
              'Raammaat: ${item.raammaatBreedteMm} × ${item.raammaatHoogteMm} mm',
              style: const TextStyle(
                color: _tekstDonker,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 330,
                  child: AspectRatio(
                    aspectRatio: 1.45,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _rand),
                      ),
                      child: CustomPaint(
                        painter: OpmetingOverzichtTekening(item: item),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: technischeRegels.isEmpty
                      ? OpmetingOverzichtArtikelLayoutHelper.bouwLegeTechnischeContainer()
                      : _bouwTechnischeTekst(technischeRegels),
                ),
              ],
            ),
          ],
          if (item.notities.trim().isNotEmpty || item.fotos.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _rand),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (item.notities.trim().isNotEmpty)
                    Text(
                      item.notities.trim(),
                      style: const TextStyle(
                        color: _tekstDonker,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  if (item.notities.trim().isNotEmpty && item.fotos.isNotEmpty)
                    const SizedBox(height: 9),
                  if (item.fotos.isNotEmpty)
                    SizedBox(
                      height: 74,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: item.fotos.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return _OverzichtFotoMiniatuur(
                            foto: item.fotos[index],
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bouwVliegendeurOverzicht(
    OpmetingVliegendeurModel model,
    List<OpmetingOverzichtTechnischeRegel> technischeRegels,
  ) {
    final tekenvlak = OpmetingOverzichtArtikelLayoutHelper.bouwTekenvlak(
      maatTitel: 'Afmetingen',
      maatWaarde: model.maatSamenvatting,
      tekening: OpmetingVliegendeurTekenvlak(model: model, schaalFactor: 0.55),
    );
    final prijsResultaat =
        OfferteArtikelPrijsKoppelingService.resultaatVoorArtikel(
          item,
          kortingToestaan: !item.isOfferteOptie,
        );

    if (prijsResultaat == null) {
      final gemeenschappelijkeHoogte =
          OpmetingOverzichtArtikelLayoutHelper.berekenNietScrollbareTechnischeHoogte(
            technischeRegels: technischeRegels,
          );

      return OpmetingOverzichtArtikelLayoutHelper.bouwLayout(
        hoogte: gemeenschappelijkeHoogte,
        tekenvlak: tekenvlak,
        rechterkolom: OpmetingOverzichtArtikelLayoutHelper.bouwRechterkolom(
          technischeRegels: technischeRegels,
          legeTekst: 'Geen technische kenmerken ingevuld.',
          scrollbaar: false,
          toonPrijsZone: false,
        ),
      );
    }

    return _bouwGeprijsdArtikelOverzicht(
      tekenvlak: tekenvlak,
      technischeRegels: technischeRegels,
      prijsData: item.offertePrijsData,
      prijsResultaat: prijsResultaat,
      aantal: model.aantal,
      technischeRegelsScrollbaar: false,
      toonTechnischePrijsZone: false,
    );
  }

  Widget _bouwSchuifvliegendeurOverzicht(
    OpmetingSchuifvliegendeurModel model,
    List<OpmetingOverzichtTechnischeRegel> technischeRegels,
  ) {
    final tekenvlak = OpmetingOverzichtArtikelLayoutHelper.bouwTekenvlak(
      maatTitel: 'Afmetingen',
      maatWaarde: model.maatSamenvatting,
      tekening: OpmetingSchuifvliegendeurTekenvlak(model: model),
    );
    final prijsResultaat =
        OfferteArtikelPrijsKoppelingService.resultaatVoorArtikel(
          item,
          kortingToestaan: !item.isOfferteOptie,
        );

    if (prijsResultaat == null) {
      final gemeenschappelijkeHoogte =
          OpmetingOverzichtArtikelLayoutHelper.berekenNietScrollbareTechnischeHoogte(
            technischeRegels: technischeRegels,
          );

      return OpmetingOverzichtArtikelLayoutHelper.bouwLayout(
        hoogte: gemeenschappelijkeHoogte,
        tekenvlak: tekenvlak,
        rechterkolom: OpmetingOverzichtArtikelLayoutHelper.bouwRechterkolom(
          technischeRegels: technischeRegels,
          legeTekst: 'Geen technische kenmerken ingevuld.',
          scrollbaar: false,
          toonPrijsZone: false,
        ),
      );
    }

    return _bouwGeprijsdArtikelOverzicht(
      tekenvlak: tekenvlak,
      technischeRegels: technischeRegels,
      prijsData: item.offertePrijsData,
      prijsResultaat: prijsResultaat,
      aantal: model.aantal,
      technischeRegelsScrollbaar: false,
      toonTechnischePrijsZone: false,
    );
  }

  Widget _bouwPlooiwerkenOverzicht(
    OpmetingPlooiwerkenModel model,
    List<OpmetingOverzichtTechnischeRegel> technischeRegels,
  ) {
    final tekenvlak = OpmetingOverzichtArtikelLayoutHelper.bouwTekenvlak(
      maatTitel: 'Totale Lengte',
      maatWaarde: '${model.totaleLengteMm} mm',
      tekening: OpmetingPlooiwerkenTekenvlak(model: model),
    );
    final prijsResultaat =
        OfferteArtikelPrijsKoppelingService.resultaatVoorArtikel(
          item,
          kortingToestaan: !item.isOfferteOptie,
        );

    if (prijsResultaat == null) {
      final gemeenschappelijkeHoogte =
          OpmetingOverzichtArtikelLayoutHelper.berekenNietScrollbareTechnischeHoogte(
            technischeRegels: technischeRegels,
          );

      return OpmetingOverzichtArtikelLayoutHelper.bouwLayout(
        hoogte: gemeenschappelijkeHoogte,
        tekenvlak: tekenvlak,
        rechterkolom: OpmetingOverzichtArtikelLayoutHelper.bouwRechterkolom(
          technischeRegels: technischeRegels,
          legeTekst: 'Geen technische kenmerken ingevuld.',
          scrollbaar: false,
          toonPrijsZone: false,
        ),
      );
    }

    return _bouwGeprijsdArtikelOverzicht(
      tekenvlak: tekenvlak,
      technischeRegels: technischeRegels,
      prijsData: item.offertePrijsData,
      prijsResultaat: prijsResultaat,
      aantal: model.aantal,
      technischeRegelsScrollbaar: false,
      toonTechnischePrijsZone: false,
    );
  }

  Widget _bouwAlgemeneOpmetingOverzicht(OpmetingAlgemeneOpmetingModel model) {
    final technischeRegels = <OpmetingOverzichtTechnischeRegel>[];
    final technischeRegelsMetPrijs = <OpmetingOverzichtTechnischeRegelPrijs>[];

    if (model.omschrijving.trim().isNotEmpty) {
      final regel = OpmetingOverzichtTechnischeRegel(
        titel: 'Omschrijving',
        waarde: model.omschrijving.trim(),
      );
      technischeRegels.add(regel);
      technischeRegelsMetPrijs.add(
        OpmetingOverzichtTechnischeRegelPrijs(regel: regel),
      );
    }

    for (final blok in model.blokken) {
      final regel = OpmetingOverzichtTechnischeRegel(
        titel: blok.isPrijs
            ? '${blok.prijsSoort.cirkelTeken} ${blok.zichtbareTitel}'
            : blok.zichtbareTitel,
        waarde: blok.isPrijs
            ? OpmetingAlgemeneOpmetingTechnischeRegelsHelper.prijsSamenvatting(
                blok,
                toonBedrag: false,
              )
            : blok.omschrijving.trim(),
      );
      technischeRegels.add(regel);
      technischeRegelsMetPrijs.add(
        OpmetingOverzichtTechnischeRegelPrijs(
          regel: regel,
          bedragExclBtw: blok.isPrijs ? blok.totaalExclBtw : null,
        ),
      );
    }

    final tekenvlak = Container(
      decoration: BoxDecoration(
        color: OpmetingOverzichtArtikelLayoutHelper.vlakAchtergrond,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OpmetingOverzichtArtikelLayoutHelper.rand),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: OpmetingAlgemeneOpmetingTekenvlak(
          fotos: model.fotos,
          actiesZichtbaar: false,
        ),
      ),
    );
    final prijsResultaat =
        OfferteArtikelPrijsKoppelingService.resultaatVoorArtikel(
          item,
          kortingToestaan: !item.isOfferteOptie,
        );

    if (prijsResultaat == null) {
      final hoogte =
          OpmetingOverzichtArtikelLayoutHelper.berekenNietScrollbareTechnischeHoogte(
            technischeRegels: technischeRegels,
          );
      return OpmetingOverzichtArtikelLayoutHelper.bouwLayout(
        hoogte: hoogte,
        tekenvlak: tekenvlak,
        rechterkolom: OpmetingOverzichtArtikelLayoutHelper.bouwRechterkolom(
          technischeRegels: technischeRegels,
          technischeRegelsMetPrijs: berekenPrijzen
              ? technischeRegelsMetPrijs
              : null,
          legeTekst: 'Geen tekst- of prijscontainers ingevuld.',
          scrollbaar: false,
          toonPrijsZone: berekenPrijzen,
        ),
      );
    }

    return _bouwGeprijsdArtikelOverzicht(
      tekenvlak: tekenvlak,
      technischeRegels: technischeRegels,
      technischeRegelsMetPrijsOverride: berekenPrijzen
          ? technischeRegelsMetPrijs
          : null,
      prijsData: item.offertePrijsData,
      prijsResultaat: prijsResultaat,
      aantal: 1,
      technischeRegelsScrollbaar: false,
      toonTechnischePrijsZone: true,
      toonPrijsPerStukVeld: false,
      toonWinstEnKorting: true,
      toonTechnischePrijsregelsInSamenvatting: false,
      toonPrijsPerPositieRegelsBlok: false,
      algemeneVerkoopPrijsTotaalExclBtw: model.verkoopPrijsTotaalExclBtw,
      algemeneAankoopPrijsTotaalExclBtw: model.aankoopPrijsTotaalExclBtw,
    );
  }

  Widget _bouwAlgemeenArtikelOverzicht(
    List<OpmetingOverzichtTechnischeRegel> technischeRegels,
  ) {
    final prijsData = OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(
      item,
    )!;
    final prijsResultaat =
        OfferteArtikelPrijsKoppelingService.resultaatVoorArtikel(
          item,
          kortingToestaan: !item.isOfferteOptie,
        )!;

    return _bouwGeprijsdArtikelOverzicht(
      tekenvlak: OpmetingOverzichtArtikelLayoutHelper.bouwTekenvlak(
        maatTitel: 'Totale Raammaat',
        maatWaarde: '${item.raammaatBreedteMm} × ${item.raammaatHoogteMm} mm',
        tekening: LayoutBuilder(
          builder: (context, constraints) {
            return ClipRect(
              child: Center(
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: CustomPaint(
                    painter: OpmetingOverzichtTekening(
                      item: item,
                      toonAchtergrondRaster: false,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      technischeRegels: technischeRegels,
      prijsData: prijsData,
      prijsResultaat: prijsResultaat,
      aantal: OfferteArtikelPrijsKoppelingService.aantalVoorArtikel(item),
    );
  }

  Widget _bouwVoorzetscreenOverzicht(
    OpmetingVoorzetscreenModel model,
    List<OpmetingOverzichtTechnischeRegel> technischeRegels,
  ) {
    final tekenvlak = OpmetingOverzichtArtikelLayoutHelper.bouwTekenvlak(
      maatTitel: 'Afmetingen',
      maatWaarde: model.maatSamenvatting,
      tekening: OpmetingVoorzetscreenTekenvlak(model: model),
    );
    final prijsResultaat =
        OfferteArtikelPrijsKoppelingService.resultaatVoorArtikel(
          item,
          kortingToestaan: !item.isOfferteOptie,
        );

    if (prijsResultaat == null) {
      final gemeenschappelijkeHoogte =
          OpmetingOverzichtArtikelLayoutHelper.berekenNietScrollbareTechnischeHoogte(
            technischeRegels: technischeRegels,
          );

      return OpmetingOverzichtArtikelLayoutHelper.bouwLayout(
        hoogte: gemeenschappelijkeHoogte,
        tekenvlak: tekenvlak,
        rechterkolom: OpmetingOverzichtArtikelLayoutHelper.bouwRechterkolom(
          technischeRegels: technischeRegels,
          legeTekst: 'Geen technische kenmerken ingevuld.',
          scrollbaar: false,
          toonPrijsZone: false,
        ),
      );
    }

    return _bouwGeprijsdArtikelOverzicht(
      tekenvlak: tekenvlak,
      technischeRegels: technischeRegels,
      prijsData: item.offertePrijsData,
      prijsResultaat: prijsResultaat,
      aantal: model.aantal,
      technischeRegelsScrollbaar: false,
      toonTechnischePrijsZone: false,
    );
  }

  Widget _bouwBuitenjaloezieOverzicht(
    OpmetingBuitenjaloezieModel model,
    List<OpmetingOverzichtTechnischeRegel> technischeRegels,
  ) {
    final maatSamenvatting =
        '${model.totaleBreedteMm} × ${model.totaleHoogteMm} mm';

    final tekenvlak = OpmetingOverzichtArtikelLayoutHelper.bouwTekenvlak(
      maatTitel: 'Totale afmetingen',
      maatWaarde: maatSamenvatting,
      tekening: OpmetingBuitenjaloezieTekenvlak(model: model),
    );

    final prijsResultaat =
        OfferteArtikelPrijsKoppelingService.resultaatVoorArtikel(
          item,
          kortingToestaan: !item.isOfferteOptie,
        );

    if (prijsResultaat == null) {
      final gemeenschappelijkeHoogte =
          OpmetingOverzichtArtikelLayoutHelper.berekenNietScrollbareTechnischeHoogte(
            technischeRegels: technischeRegels,
          );

      return OpmetingOverzichtArtikelLayoutHelper.bouwLayout(
        hoogte: gemeenschappelijkeHoogte,
        tekenvlak: tekenvlak,
        rechterkolom: OpmetingOverzichtArtikelLayoutHelper.bouwRechterkolom(
          technischeRegels: technischeRegels,
          legeTekst: 'Geen technische kenmerken ingevuld.',
          scrollbaar: false,
          toonPrijsZone: false,
        ),
      );
    }

    return _bouwGeprijsdArtikelOverzicht(
      tekenvlak: tekenvlak,
      technischeRegels: technischeRegels,
      prijsData: item.offertePrijsData,
      prijsResultaat: prijsResultaat,
      aantal: model.aantal,
      technischeRegelsScrollbaar: false,
      toonTechnischePrijsZone: false,
      toonPrijsPerStukVeld: true,
      toonWinstEnKorting: true,
    );
  }

  Widget _bouwVoorzetrolluikOverzicht(
    OpmetingVoorzetrolluikModel model,
    List<OpmetingOverzichtTechnischeRegel> technischeRegels,
  ) {
    final tekenvlak = OpmetingOverzichtArtikelLayoutHelper.bouwTekenvlak(
      maatTitel: 'Afmetingen',
      maatWaarde: model.maatSamenvatting,
      tekening: OpmetingVoorzetrolluikTekenvlak(model: model),
    );
    final prijsResultaat =
        OfferteArtikelPrijsKoppelingService.resultaatVoorArtikel(
          item,
          kortingToestaan: !item.isOfferteOptie,
        );

    if (prijsResultaat == null) {
      final gemeenschappelijkeHoogte =
          OpmetingOverzichtArtikelLayoutHelper.berekenNietScrollbareTechnischeHoogte(
            technischeRegels: technischeRegels,
          );

      return OpmetingOverzichtArtikelLayoutHelper.bouwLayout(
        hoogte: gemeenschappelijkeHoogte,
        tekenvlak: tekenvlak,
        rechterkolom: OpmetingOverzichtArtikelLayoutHelper.bouwRechterkolom(
          technischeRegels: technischeRegels,
          legeTekst: 'Geen technische kenmerken ingevuld.',
          scrollbaar: false,
          toonPrijsZone: false,
        ),
      );
    }

    return _bouwGeprijsdArtikelOverzicht(
      tekenvlak: tekenvlak,
      technischeRegels: technischeRegels,
      prijsData: item.offertePrijsData,
      prijsResultaat: prijsResultaat,
      aantal: model.aantal,
      technischeRegelsScrollbaar: false,
      toonTechnischePrijsZone: false,
    );
  }

  Widget _bouwUitvalschermOverzicht(
    OpmetingUitvalschermModel model,
    List<OpmetingOverzichtTechnischeRegel> technischeRegels,
  ) {
    final tekenvlak = OpmetingOverzichtArtikelLayoutHelper.bouwTekenvlak(
      maatTitel: 'Breedte × uitval',
      maatWaarde: model.maatSamenvatting,
      tekening: OpmetingUitvalschermTekenvlak(model: model),
    );
    final prijsResultaat =
        OfferteArtikelPrijsKoppelingService.resultaatVoorArtikel(
          item,
          kortingToestaan: !item.isOfferteOptie,
        );

    if (prijsResultaat == null) {
      final gemeenschappelijkeHoogte =
          OpmetingOverzichtArtikelLayoutHelper.berekenNietScrollbareTechnischeHoogte(
            technischeRegels: technischeRegels,
          );

      return OpmetingOverzichtArtikelLayoutHelper.bouwLayout(
        hoogte: gemeenschappelijkeHoogte,
        tekenvlak: tekenvlak,
        rechterkolom: OpmetingOverzichtArtikelLayoutHelper.bouwRechterkolom(
          technischeRegels: technischeRegels,
          legeTekst: 'Geen technische kenmerken ingevuld.',
          scrollbaar: false,
          toonPrijsZone: false,
        ),
      );
    }

    return _bouwGeprijsdArtikelOverzicht(
      tekenvlak: tekenvlak,
      technischeRegels: technischeRegels,
      prijsData: item.offertePrijsData,
      prijsResultaat: prijsResultaat,
      aantal: model.aantal,
      technischeRegelsScrollbaar: false,
      toonTechnischePrijsZone: false,
    );
  }

  Widget _bouwSektionalePoortOverzicht(
    OpmetingSektionalePoortModel model,
    List<OpmetingOverzichtTechnischeRegel> technischeRegels,
  ) {
    final tekenvlak = OpmetingOverzichtArtikelLayoutHelper.bouwTekenvlak(
      maatTitel: 'Poortafmetingen',
      maatWaarde: '${model.breedteMm} × ${model.hoogteMm} mm',
      tekening: OpmetingSektionalePoortTekenvlak(
        model: model,
        toonKop: false,
        toonKader: false,
      ),
    );
    final prijsResultaat =
        OfferteArtikelPrijsKoppelingService.resultaatVoorArtikel(
          item,
          kortingToestaan: !item.isOfferteOptie,
        );

    if (prijsResultaat == null) {
      final gemeenschappelijkeHoogte =
          OpmetingOverzichtArtikelLayoutHelper.berekenNietScrollbareTechnischeHoogte(
            technischeRegels: technischeRegels,
          );

      return OpmetingOverzichtArtikelLayoutHelper.bouwLayout(
        hoogte: gemeenschappelijkeHoogte,
        tekenvlak: tekenvlak,
        rechterkolom: OpmetingOverzichtArtikelLayoutHelper.bouwRechterkolom(
          technischeRegels: technischeRegels,
          legeTekst: 'Geen technische kenmerken ingevuld.',
          scrollbaar: false,
          toonPrijsZone: false,
        ),
      );
    }

    return _bouwGeprijsdArtikelOverzicht(
      tekenvlak: tekenvlak,
      technischeRegels: technischeRegels,
      prijsData: item.offertePrijsData,
      prijsResultaat: prijsResultaat,
      aantal: model.aantal,
      technischeRegelsScrollbaar: false,
      toonTechnischePrijsZone: false,
    );
  }

  Widget _bouwVeluxDakraamOverzicht(OpmetingVeluxDakraamModel model) {
    final catalogusRegels = _veluxCatalogusRegels(model);
    final prijsResultaat =
        OfferteArtikelPrijsKoppelingService.resultaatVoorArtikel(
          item,
          kortingToestaan: false,
        );
    final technischePrijsregels = prijsResultaat == null
        ? const <OfferteToegepastePrijsregelModel>[]
        : prijsResultaat.technischePrijsregels
              .where(
                (regel) =>
                    regel.isGeldig &&
                    regel.totaalExclBtw > 0.0 &&
                    regel.toonOpOverzicht,
              )
              .toList(growable: false);

    final technischeRegels = <OpmetingOverzichtTechnischeRegel>[];
    final technischeRegelsMetPrijs = <OpmetingOverzichtTechnischeRegelPrijs>[];

    for (final regel in catalogusRegels) {
      final technischeRegel = OpmetingOverzichtTechnischeRegel(
        titel: OpmetingVeluxDakraamOmschrijvingHelper.metAantal(
          regel.omschrijving,
          regel.aantal,
        ),
        waarde: '',
      );
      technischeRegels.add(technischeRegel);
      technischeRegelsMetPrijs.add(
        OpmetingOverzichtTechnischeRegelPrijs(
          regel: technischeRegel,
          bedragExclBtw: regel.totaalExclBtw,
        ),
      );
    }

    for (final prijsregel in technischePrijsregels) {
      final omschrijving = prijsregel.isOptie
          ? '${prijsregel.omschrijving} · optie'
          : prijsregel.omschrijving;
      final technischeRegel = OpmetingOverzichtTechnischeRegel(
        titel: OpmetingVeluxDakraamOmschrijvingHelper.metAantal(
          omschrijving,
          model.veiligAantal,
        ),
        waarde: '',
      );
      technischeRegels.add(technischeRegel);
      technischeRegelsMetPrijs.add(
        OpmetingOverzichtTechnischeRegelPrijs(
          regel: technischeRegel,
          bedragExclBtw: prijsregel.totaalExclBtw,
        ),
      );
    }

    final tekenvlak = OpmetingOverzichtArtikelLayoutHelper.bouwTekenvlak(
      maatTitel: model.alleenToebehoren
          ? 'Velux accessoires'
          : 'Velux ${model.productCode}',
      maatWaarde: model.alleenToebehoren
          ? 'Catalogus ${model.catalogusJaar}'
          : '· ${model.maatCode} · ${_veluxAfmetingCm(model)}',
      tekening: CustomPaint(
        painter: OpmetingVeluxDakraamPainter(model: model),
        child: const SizedBox.expand(),
      ),
    );

    if (prijsResultaat == null) {
      final hoogte =
          OpmetingOverzichtArtikelLayoutHelper.berekenGemeenschappelijkeHoogte(
            aantalTechnischeRegels: technischeRegels.length,
          );

      return OpmetingOverzichtArtikelLayoutHelper.bouwLayout(
        hoogte: hoogte,
        tekenvlak: tekenvlak,
        rechterkolom: OpmetingOverzichtArtikelLayoutHelper.bouwRechterkolom(
          technischeRegels: technischeRegels,
          technischeRegelsMetPrijs: technischeRegelsMetPrijs,
          legeTekst: 'Geen technische kenmerken ingevuld.',
          scrollbaar: true,
          toonPrijsZone: true,
        ),
      );
    }

    return _bouwGeprijsdArtikelOverzicht(
      tekenvlak: tekenvlak,
      technischeRegels: technischeRegels,
      technischeRegelsMetPrijsOverride: technischeRegelsMetPrijs,
      prijsData: item.offertePrijsData,
      prijsResultaat: prijsResultaat,
      aantal: model.veiligAantal,
      toonPrijsPerStukVeld: false,
      basisOmschrijving: model.alleenToebehoren
          ? 'Catalogustotaal Velux-accessoires'
          : 'Catalogustotaal · ${model.veiligAantal} stuks',
      toonTechnischePrijsZone: true,
      toonWinstEnKorting: false,
      toonTechnischePrijsregelsInSamenvatting: false,
    );
  }

  List<_VeluxCatalogusRegel> _veluxCatalogusRegels(
    OpmetingVeluxDakraamModel model,
  ) {
    final regels = <_VeluxCatalogusRegel>[];

    void voegToe({
      required String omschrijving,
      required int aantal,
      required double prijsPerStukExclBtw,
    }) {
      if (omschrijving.trim().isEmpty || aantal < 1) {
        return;
      }
      regels.add(
        _VeluxCatalogusRegel(
          omschrijving: omschrijving.trim(),
          aantal: aantal,
          prijsPerStukExclBtw: prijsPerStukExclBtw,
        ),
      );
    }

    if (!model.alleenToebehoren) {
      voegToe(
        omschrijving: OpmetingVeluxDakraamOmschrijvingHelper.dakvenster(model),
        aantal: model.veiligAantal,
        prijsPerStukExclBtw: model.basisPrijsPerStukExclBtw,
      );
      if (model.gootstukType != OpmetingVeluxGootstukType.geen) {
        voegToe(
          omschrijving: OpmetingVeluxDakraamOmschrijvingHelper.gootstukken(
            model,
          ),
          aantal: model.veiligAantal,
          prijsPerStukExclBtw: model.gootstukPrijsPerStukExclBtw,
        );
      }
    }

    if (model.rolluikType != OpmetingVeluxRolluikType.geen) {
      voegToe(
        omschrijving: OpmetingVeluxDakraamOmschrijvingHelper.rolluik(model),
        aantal: model.effectiefRolluikAantal,
        prijsPerStukExclBtw: model.rolluikPrijsPerStukExclBtw,
      );
    }
    if (model.screenType != OpmetingVeluxScreenType.geen) {
      voegToe(
        omschrijving: OpmetingVeluxDakraamOmschrijvingHelper.buitenscherm(
          model,
        ),
        aantal: model.effectiefScreenAantal,
        prijsPerStukExclBtw: model.screenPrijsPerStukExclBtw,
      );
    }
    if (model.verduisteringsgordijnDkl) {
      voegToe(
        omschrijving:
            OpmetingVeluxDakraamOmschrijvingHelper.verduisteringsgordijn(model),
        aantal: model.effectiefDklAantal,
        prijsPerStukExclBtw: model.dklPrijsPerStukExclBtw,
      );
    }
    if (model.muggengaas) {
      voegToe(
        omschrijving: OpmetingVeluxDakraamOmschrijvingHelper.muggengaas(model),
        aantal: model.effectiefMuggengaasAantal,
        prijsPerStukExclBtw: model.muggengaasPrijsPerStukExclBtw,
      );
    }
    if (model.kux110) {
      voegToe(
        omschrijving:
            OpmetingVeluxDakraamOmschrijvingHelper.stroomvoorziening(),
        aantal: model.kuxAantal.clamp(1, 99).toInt(),
        prijsPerStukExclBtw: model.kuxPrijsPerStukExclBtw,
      );
    }
    return List<_VeluxCatalogusRegel>.unmodifiable(regels);
  }

  String _veluxTitel(OpmetingVeluxDakraamModel model) {
    if (model.alleenToebehoren) {
      return 'Velux accessoires';
    }
    return 'Velux ${model.productCode} · ${model.maatCode} · '
        '${_veluxAfmetingCm(model)}';
  }

  String _veluxAfmetingCm(OpmetingVeluxDakraamModel model) {
    return '${_mmNaarCm(model.breedteMm)} × ${_mmNaarCm(model.hoogteMm)} cm';
  }

  String _mmNaarCm(int millimeter) {
    final centimeter = millimeter / 10.0;
    if (centimeter == centimeter.roundToDouble()) {
      return centimeter.toInt().toString();
    }
    return centimeter.toStringAsFixed(1).replaceAll('.', ',');
  }

  Widget _bouwVasteInzethorOverzicht(
    OpmetingVasteInzethorModel model,
    List<OpmetingOverzichtTechnischeRegel> technischeRegels,
  ) {
    final prijsData = model.prijsData;
    final prijsResultaat =
        OfferteArtikelPrijsKoppelingService.resultaatVoorArtikel(
          item,
          kortingToestaan: !item.isOfferteOptie,
        )!;

    return _bouwGeprijsdArtikelOverzicht(
      tekenvlak: OpmetingVasteInzethorTekenvlak(
        model: model,
        schaalFactor: 0.55,
      ),
      technischeRegels: technischeRegels,
      prijsData: prijsData,
      prijsResultaat: prijsResultaat,
      aantal: model.aantal,
    );
  }

  Widget _bouwGeprijsdArtikelOverzicht({
    required Widget tekenvlak,
    required List<OpmetingOverzichtTechnischeRegel> technischeRegels,
    required OfferteArtikelPrijsDataModel prijsData,
    required OfferteBerekeningResultaat prijsResultaat,
    required int aantal,
    List<OpmetingOverzichtTechnischeRegelPrijs>?
    technischeRegelsMetPrijsOverride,
    bool technischeRegelsScrollbaar = true,
    bool toonTechnischePrijsZone = true,
    bool toonPrijsPerStukVeld = true,
    bool toonWinstEnKorting = true,
    bool toonTechnischePrijsregelsInSamenvatting = false,
    bool toonPrijsPerPositieRegelsBlok = true,
    String? basisOmschrijving,
    double? algemeneVerkoopPrijsTotaalExclBtw,
    double? algemeneAankoopPrijsTotaalExclBtw,
  }) {
    final heeftAlgemenePrijsUitsplitsing =
        algemeneVerkoopPrijsTotaalExclBtw != null &&
        algemeneAankoopPrijsTotaalExclBtw != null;
    final prijsSamenvattingHoogte =
        OpmetingOverzichtPrijsPerPositie.berekenSamenvattingHoogte(
          berekenPrijzen: berekenPrijzen,
          prijsResultaat: prijsResultaat,
          toonPrijsPerStukVeld: toonPrijsPerStukVeld,
          toonWinstEnKorting: toonWinstEnKorting,
          toonTechnischePrijsregels: toonTechnischePrijsregelsInSamenvatting,
          heeftAlgemenePrijsUitsplitsing: heeftAlgemenePrijsUitsplitsing,
          toonPrijsPerPositieRegelsBlok: toonPrijsPerPositieRegelsBlok,
          prijsVoorAllePositiesRegels: prijsVoorAllePositiesRegels,
          huidigePositieId: item.id,
          toonPrijsVoorAllePositiesEditor: toonPrijsVoorAllePosities,
        );

    final technischeRegelsMetPrijs =
        technischeRegelsMetPrijsOverride ??
        (berekenPrijzen
            ? OpmetingOverzichtTechnischePrijsKoppelHelper.koppelTechnischePrijzenAanRegels(
                technischeRegels: technischeRegels,
                technischePrijsregels: prijsResultaat.technischePrijsregels,
              )
            : null);

    final prijsWidgets = OpmetingOverzichtPrijsPerPositie.bouwWidgets(
      berekenPrijzen: berekenPrijzen,
      prijsData: prijsData,
      prijsResultaat: prijsResultaat,
      aantal: aantal,
      toonPrijsPerStukVeld: toonPrijsPerStukVeld,
      toonWinstEnKorting: toonWinstEnKorting,
      toonTechnischePrijsregelsInSamenvatting:
          toonTechnischePrijsregelsInSamenvatting,
      toonPrijsPerPositieRegelsBlok: toonPrijsPerPositieRegelsBlok,
      kortingToestaan: !item.isOfferteOptie,
      onPrijsGewijzigd: onPrijsGewijzigd,
      onWinstmargeGewijzigd: onWinstmargeGewijzigd,
      onKortingGewijzigd: onKortingGewijzigd,
      onPrijsPerPositieRegelsGewijzigd: onPrijsPerPositieRegelsGewijzigd,
      // De regels blijven altijd beschikbaar voor het positietotaal. Alleen
      // de editor zelf wordt in het artikel verborgen wanneer hij één keer
      // onderaan het volledige overzicht wordt getoond.
      prijsVoorAllePositiesRegels: prijsVoorAllePositiesRegels,
      huidigePositieId: item.id,
      prijsDoelPosities: prijsDoelPosities,
      onPrijsVoorAllePositiesRegelsGewijzigd: toonPrijsVoorAllePosities
          ? onPrijsVoorAllePositiesRegelsGewijzigd
          : null,
      basisOmschrijving: basisOmschrijving,
      algemeneVerkoopPrijsTotaalExclBtw: algemeneVerkoopPrijsTotaalExclBtw,
      algemeneAankoopPrijsTotaalExclBtw: algemeneAankoopPrijsTotaalExclBtw,
    );
    final geblokkeerdePrijsWidgets = item.isNietRekenen
        ? prijsWidgets
              .map((widget) {
                return IgnorePointer(
                  ignoring: true,
                  child: Opacity(opacity: 0.62, child: widget),
                );
              })
              .toList(growable: false)
        : prijsWidgets;

    final regelsVoorHoogte =
        technischeRegelsMetPrijs ??
        technischeRegels
            .map((regel) => OpmetingOverzichtTechnischeRegelPrijs(regel: regel))
            .toList(growable: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final technischeKolomBreedte =
            OpmetingOverzichtArtikelLayoutHelper.berekenTechnischeKolomBreedte(
              constraints.maxWidth,
            );
        final dynamischeTechnischeHoogte =
            OpmetingOverzichtArtikelLayoutHelper.berekenTechnischeRegelsHoogte(
              technischeRegels: regelsVoorHoogte,
              beschikbareBreedte: technischeKolomBreedte,
              toonPrijsZone: toonTechnischePrijsZone,
              textDirection: Directionality.of(context),
            );

        final standaardGemeenschappelijkeHoogte =
            OpmetingOverzichtArtikelLayoutHelper.berekenGemeenschappelijkeHoogte(
              aantalTechnischeRegels: technischeRegels.length,
              toonPrijzen: berekenPrijzen,
              prijsVeldHoogte: 0,
              prijsCorrectieVeldHoogte: 0,
              prijsSamenvattingHoogte: prijsSamenvattingHoogte,
            );

        final dynamischeTotaleHoogte =
            dynamischeTechnischeHoogte +
            (berekenPrijzen ? prijsSamenvattingHoogte + 27.0 : 0.0);
        final gemeenschappelijkeHoogte =
            dynamischeTotaleHoogte > standaardGemeenschappelijkeHoogte
            ? dynamischeTotaleHoogte
            : standaardGemeenschappelijkeHoogte;

        return OpmetingOverzichtArtikelLayoutHelper.bouwLayout(
          hoogte: gemeenschappelijkeHoogte,
          tekenvlak: tekenvlak,
          rechterkolom: OpmetingOverzichtArtikelLayoutHelper.bouwRechterkolom(
            technischeRegels: technischeRegels,
            technischeRegelsMetPrijs: technischeRegelsMetPrijs,
            onderWidgets: geblokkeerdePrijsWidgets,
            scrollbaar: technischeRegelsScrollbaar,
            toonPrijsZone: toonTechnischePrijsZone,
          ),
        );
      },
    );
  }

  List<OpmetingOverzichtTechnischeRegel> _plooiwerkenRegelsVoorOverzicht(
    List<OpmetingOverzichtTechnischeRegel> regels,
  ) {
    return regels
        .where((regel) {
          final sleutel = regel.titel.trim().toLowerCase().replaceAll(
            RegExp(r'\s+'),
            ' ',
          );
          final waarde = regel.waarde.trim();

          if (sleutel.isEmpty && waarde.isEmpty) {
            return false;
          }

          return !const <String>{'totale lengte', 'lengte'}.contains(sleutel);
        })
        .toList(growable: false);
  }

  List<OpmetingOverzichtTechnischeRegel> _sektionalePoortRegelsVoorOverzicht(
    List<OpmetingOverzichtTechnischeRegel> regels,
  ) {
    return regels
        .where((regel) {
          final sleutel = regel.titel.trim().toLowerCase().replaceAll(
            RegExp(r'\s+'),
            ' ',
          );
          final waarde = regel.waarde.trim();

          if (sleutel.isEmpty && waarde.isEmpty) {
            return false;
          }

          return !const <String>{
            'bestelmaat',
            'poortafmetingen',
          }.contains(sleutel);
        })
        .toList(growable: false);
  }

  List<OpmetingOverzichtTechnischeRegel> _vliegendeurRegelsZonderAfmetingen(
    List<OpmetingOverzichtTechnischeRegel> regels,
  ) {
    return regels
        .where((regel) {
          final titel = regel.titel.trim();
          final waarde = regel.waarde.trim();

          if (titel.isEmpty && waarde.isEmpty) {
            return false;
          }

          return !_isVliegendeurAfmetingsRegel(titel);
        })
        .toList(growable: false);
  }

  List<OpmetingOverzichtTechnischeRegel> _schuifvliegendeurRegelsVoorOverzicht(
    List<OpmetingOverzichtTechnischeRegel> regels,
  ) {
    return regels
        .where((regel) {
          final sleutel = regel.titel.trim().toLowerCase().replaceAll(
            RegExp(r'\s+'),
            ' ',
          );
          final waarde = regel.waarde.trim();

          if (sleutel.isEmpty && waarde.isEmpty) {
            return false;
          }

          return !const <String>{
            'breedte buitenmaat vleugel',
            'hoogte inclusief rails',
            'soort',
          }.contains(sleutel);
        })
        .toList(growable: false);
  }

  bool _isVliegendeurAfmetingsRegel(String titel) {
    final sleutel = titel.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

    return const <String>{
      'afmetingen',
      'maat',
      'maten',
      'buitenmaat',
      'breedte',
      'hoogte',
      'breedte buitenmaat',
      'hoogte buitenmaat',
      'buitenmaat breedte',
      'buitenmaat hoogte',
      'binnenmaat/doorkijkmaat',
    }.contains(sleutel);
  }

  List<OpmetingOverzichtTechnischeRegel> _technischeRegelsZonderMaten(
    List<OpmetingOverzichtTechnischeRegel> regels,
  ) {
    return regels.where((regel) {
      final titel = regel.titel.trim().toLowerCase();
      final waarde = regel.waarde.trim().toLowerCase();

      if (titel.isEmpty && waarde.isEmpty) {
        return false;
      }

      if (OpmetingArtikelTypeOmschrijvingHelper.isVerplaatsteTechnischeRegelTitel(
        regel.titel,
      )) {
        return false;
      }

      if (titel == 'maten' ||
          titel == 'maat' ||
          titel == 'afmeting' ||
          titel == 'afmetingen') {
        return false;
      }

      if (titel.contains('raammaat') ||
          titel.contains('dagmaat') ||
          waarde.startsWith('raammaat') ||
          waarde.startsWith('dagmaat')) {
        return false;
      }

      return true;
    }).toList();
  }

  Widget _bouwTechnischeTekst(
    List<OpmetingOverzichtTechnischeRegel> technischeRegels,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: technischeRegels.map((regel) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                regel.titel,
                style: const TextStyle(
                  color: _tekstGrijs,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                regel.waarde,
                style: const TextStyle(
                  color: _tekstDonker,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  height: 1.22,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _VeluxCatalogusRegel {
  const _VeluxCatalogusRegel({
    required this.omschrijving,
    required this.aantal,
    required this.prijsPerStukExclBtw,
  });

  final String omschrijving;
  final int aantal;
  final double prijsPerStukExclBtw;

  double get totaalExclBtw => prijsPerStukExclBtw * aantal;
}

class _ArtikelActieTekstKnop extends StatelessWidget {
  const _ArtikelActieTekstKnop({required this.tekst, required this.onPressed});

  final String tekst;
  final VoidCallback? onPressed;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: _groen,
        backgroundColor: Colors.white,
        disabledForegroundColor: _groen.withValues(alpha: 0.45),
        side: const BorderSide(color: _rand),
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
      onPressed: onPressed,
      child: Text(tekst),
    );
  }
}

class _OverzichtFotoMiniatuur extends StatelessWidget {
  const _OverzichtFotoMiniatuur({required this.foto});

  final OpmetingFoto foto;

  Future<void> _toonGroot(BuildContext context) async {
    final bytes = foto.bytes;

    if (bytes.isEmpty) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(dialogContext).width - 48,
                  maxHeight: MediaQuery.sizeOf(dialogContext).height - 48,
                ),
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 5,
                  child: Image.memory(bytes, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bytes = foto.bytes;

    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: bytes.isEmpty ? null : () => _toonGroot(context),
      child: Container(
        width: 96,
        height: 72,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: bytes.isEmpty
            ? const Icon(Icons.broken_image_outlined, color: Color(0xFF9CA3AF))
            : Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true),
      ),
    );
  }
}

class _PositieVerplaatsKnop extends StatelessWidget {
  const _PositieVerplaatsKnop({required this.onOmhoog, required this.onOmlaag});

  final VoidCallback? onOmhoog;
  final VoidCallback? onOmlaag;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 40,
      margin: const EdgeInsets.only(left: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _rand),
      ),
      child: Column(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              onTap: onOmhoog,
              child: Center(
                child: Icon(
                  Icons.keyboard_arrow_up_rounded,
                  size: 19,
                  color: onOmhoog == null ? Colors.grey.shade300 : _groen,
                ),
              ),
            ),
          ),
          Container(height: 1, color: _rand),
          Expanded(
            child: InkWell(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(8),
              ),
              onTap: onOmlaag,
              child: Center(
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 19,
                  color: onOmlaag == null ? Colors.grey.shade300 : _groen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
