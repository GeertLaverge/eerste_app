// THIMACO-CONTROLE: OVERZICHT-ARTIKEL-KAART-GEDEELDE-PRIJSOPBOUW-20260721
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../offerte/prijzen/offerte_artikel_prijs_koppeling_service.dart';
import '../../offerte/prijzen/offerte_artikel_korting_kaart.dart';
import '../../offerte/prijzen/offerte_artikel_prijs_data_model.dart';
import '../../offerte/prijzen/offerte_berekening_resultaat.dart';
import '../fotos/opmeting_foto_model.dart';
import '../toebehoren/vliegendeur/opmeting_vliegendeur_model.dart';
import '../toebehoren/vliegendeur/opmeting_vliegendeur_tekenvlak.dart';
import '../toebehoren/vaste_inzethor/opmeting_vaste_inzethor_model.dart';
import '../toebehoren/vaste_inzethor/opmeting_vaste_inzethor_tekenvlak.dart';
import 'opmeting_artikel_type_omschrijving_helper.dart';
import 'opmeting_overzicht_artikel_layout_helper.dart';
import 'opmeting_overzicht_model.dart';
import 'opmeting_overzicht_technische_prijs_koppel_helper.dart';
import 'opmeting_overzicht_tekening.dart';

class OpmetingOverzichtArtikelKaart extends StatelessWidget {
  const OpmetingOverzichtArtikelKaart({
    required this.item,
    required this.positieLabel,
    required this.berekenPrijzen,
    required this.winstmargeToepassenOpSamenvatting,
    required this.kortingToepassenOpSamenvatting,
    required this.onOpenen,
    required this.onVerwijderen,
    required this.onKopieren,
    required this.onOptieWijzigen,
    required this.onPrijsMenuOpenen,
    required this.onPrijsGewijzigd,
    required this.onWinstmargeGewijzigd,
    required this.onKortingGewijzigd,
    required this.onWinstmargeToepassenOpOpenen,
    required this.onKortingToepassenOpOpenen,
    required this.onOmhoog,
    required this.onOmlaag,
  });

  final OpmetingOverzichtRaamItem item;
  final String positieLabel;
  final bool berekenPrijzen;
  final String winstmargeToepassenOpSamenvatting;
  final String kortingToepassenOpSamenvatting;
  final VoidCallback onOpenen;
  final VoidCallback onVerwijderen;
  final VoidCallback onKopieren;
  final VoidCallback onOptieWijzigen;
  final VoidCallback onPrijsMenuOpenen;
  final ValueChanged<double> onPrijsGewijzigd;
  final OfferteArtikelPercentageGewijzigd onWinstmargeGewijzigd;
  final OfferteArtikelPercentageGewijzigd onKortingGewijzigd;
  final OfferteArtikelToepassenOpGeopend onWinstmargeToepassenOpOpenen;
  final OfferteArtikelToepassenOpGeopend onKortingToepassenOpOpenen;
  final VoidCallback? onOmhoog;
  final VoidCallback? onOmlaag;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final technischeRegels =
        OpmetingOverzichtArtikelLayoutHelper.combineerTechnischeRegels(
          _technischeRegelsZonderMaten(item.zichtbareTechnischeRegels),
        );
    final vasteInzethor = item.vasteInzethorData;
    final vliegendeur = item.vliegendeurData;
    final vliegendeurTechnischeRegels = vliegendeur == null
        ? const <OpmetingOverzichtTechnischeRegel>[]
        : OpmetingOverzichtArtikelLayoutHelper.combineerTechnischeRegels(
            _vliegendeurRegelsZonderAfmetingen(item.zichtbareTechnischeRegels),
          );
    final uitvoeringsRegels =
        OpmetingArtikelTypeOmschrijvingHelper.omschrijvingRegelsVoor(item);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.isOfferteOptie ? const Color(0xFFFFFBF5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isOfferteOptie ? const Color(0xFFF15A24) : _rand,
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
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _lichtGroen,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.isOfferteOptie
                      ? item.isOfferteOptieOpPositie
                            ? '$positieLabel · IN OFFERTE'
                            : '$positieLabel · APARTE PAGINA'
                      : positieLabel,
                  style: const TextStyle(
                    color: _groen,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.formulierTypeLabel,
                      style: const TextStyle(
                        color: _tekstDonker,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (uitvoeringsRegels.isNotEmpty) ...<Widget>[
                      const SizedBox(width: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: uitvoeringsRegels
                                .map((regel) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Text(
                                      regel,
                                      style: const TextStyle(
                                        color: _tekstGrijs,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        height: 1.25,
                                      ),
                                    ),
                                  );
                                })
                                .toList(growable: false),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (berekenPrijzen &&
                  OfferteArtikelPrijsKoppelingService.ondersteuntPrijsinstellingenVoorArtikel(
                    item,
                  ))
                IconButton(
                  tooltip: 'Vrije prijsregels bewerken',
                  onPressed: onPrijsMenuOpenen,
                  icon: const Icon(Icons.post_add_outlined, color: _groen),
                ),
              IconButton(
                tooltip: 'Openen',
                onPressed: onOpenen,
                icon: const Icon(Icons.open_in_new_rounded, color: _groen),
              ),
              IconButton(
                tooltip: 'Groep kopiëren',
                onPressed: onKopieren,
                icon: const Icon(Icons.copy_all_outlined, color: _groen),
              ),
              IconButton(
                tooltip: item.isOfferteOptie
                    ? 'Optieweergave aanpassen'
                    : 'Groep in optie plaatsen',
                onPressed: onOptieWijzigen,
                icon: Icon(
                  item.isOfferteOptie
                      ? Icons.check_circle_outline_rounded
                      : Icons.bookmark_add_outlined,
                  color: item.isOfferteOptie ? const Color(0xFFF15A24) : _groen,
                ),
              ),
              IconButton(
                tooltip: 'Verwijderen',
                onPressed: onVerwijderen,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFDC2626),
                ),
              ),
              _PositieVerplaatsKnop(onOmhoog: onOmhoog, onOmlaag: onOmlaag),
            ],
          ),
          const SizedBox(height: 10),
          if (vasteInzethor != null)
            _bouwVasteInzethorOverzicht(vasteInzethor, technischeRegels)
          else if (vliegendeur != null)
            _bouwVliegendeurOverzicht(vliegendeur, vliegendeurTechnischeRegels)
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
                      ? const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'Geen technische kenmerken ingevuld.',
                            style: TextStyle(
                              color: _tekstGrijs,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
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
          legeTekst: 'Geen technische keuzes ingevuld.',
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
    bool technischeRegelsScrollbaar = true,
    bool toonTechnischePrijsZone = true,
  }) {
    final prijsSamenvattingHoogte = berekenPrijzen
        ? 92.0 +
              ((prijsResultaat.vrijeArtikelPrijsregels.length +
                      prijsResultaat.verdeeldePrijsregels.length +
                      (prijsResultaat.heeftArtikelWinstmarge ? 1 : 0) +
                      (prijsResultaat.heeftArtikelKorting ? 1 : 0)) *
                  34.0)
        : 0.0;

    final standaardGemeenschappelijkeHoogte =
        OpmetingOverzichtArtikelLayoutHelper.berekenGemeenschappelijkeHoogte(
          aantalTechnischeRegels: technischeRegels.length,
          toonPrijzen: berekenPrijzen,
          prijsVeldHoogte: 58,
          prijsCorrectieVeldHoogte: 222,
          prijsSamenvattingHoogte: prijsSamenvattingHoogte,
        );
    final nietScrollbareTechnischeHoogte = technischeRegelsScrollbaar
        ? 0.0
        : OpmetingOverzichtArtikelLayoutHelper.berekenNietScrollbareTechnischeHoogte(
            technischeRegels: technischeRegels,
            minimaleHoogte: 0,
          );
    final nietScrollbareTotaleHoogte =
        nietScrollbareTechnischeHoogte +
        (berekenPrijzen ? prijsSamenvattingHoogte + 58.0 + 222.0 + 27.0 : 0.0);
    final gemeenschappelijkeHoogte =
        nietScrollbareTotaleHoogte > standaardGemeenschappelijkeHoogte
        ? nietScrollbareTotaleHoogte
        : standaardGemeenschappelijkeHoogte;

    final technischeRegelsMetPrijs = berekenPrijzen
        ? OpmetingOverzichtTechnischePrijsKoppelHelper.koppelTechnischePrijzenAanRegels(
            technischeRegels: technischeRegels,
            technischePrijsregels: prijsResultaat.technischePrijsregels,
          )
        : null;

    final prijsWidgets = berekenPrijzen
        ? <Widget>[
            _PrijsSamenvattingKaart(resultaat: prijsResultaat, aantal: aantal),
            _PrijsPerStukVeld(
              beginPrijs: prijsData.prijsPerStukExclBtw,
              onGewijzigd: onPrijsGewijzigd,
            ),
            OfferteArtikelKortingKaart(
              beginWinstmargePercentage: prijsData.artikelWinstmargePercentage,
              beginKortingPercentage: prijsData.artikelKortingPercentage,
              winstmargeBasisExclBtw: prijsResultaat.winstmargeBasisExclBtw,
              winstmargeBedragExclBtw: prijsResultaat.winstmargeBedragExclBtw,
              kortingBasisExclBtw: prijsResultaat.kortingBasisExclBtw,
              kortingBedragExclBtw: prijsResultaat.kortingBedragExclBtw,
              onWinstmargeGewijzigd: onWinstmargeGewijzigd,
              onKortingGewijzigd: onKortingGewijzigd,
              winstmargeToepassenOpSamenvatting:
                  winstmargeToepassenOpSamenvatting,
              kortingToepassenOpSamenvatting: kortingToepassenOpSamenvatting,
              onWinstmargeToepassenOpOpenen: onWinstmargeToepassenOpOpenen,
              onKortingToepassenOpOpenen: onKortingToepassenOpOpenen,
              kortingToestaan: !item.isOfferteOptie,
            ),
          ]
        : const <Widget>[];

    return OpmetingOverzichtArtikelLayoutHelper.bouwLayout(
      hoogte: gemeenschappelijkeHoogte,
      tekenvlak: tekenvlak,
      rechterkolom: OpmetingOverzichtArtikelLayoutHelper.bouwRechterkolom(
        technischeRegels: technischeRegels,
        technischeRegelsMetPrijs: technischeRegelsMetPrijs,
        onderWidgets: prijsWidgets,
        scrollbaar: technischeRegelsScrollbaar,
        toonPrijsZone: toonTechnischePrijsZone,
      ),
    );
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

  Widget _bouwTechnischeRijenNaastElkaar(
    List<OpmetingOverzichtTechnischeRegel> technischeRegels,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rand),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: List<Widget>.generate(technischeRegels.length, (index) {
            final regel = technischeRegels[index];

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                border: index == technischeRegels.length - 1
                    ? null
                    : const Border(
                        bottom: BorderSide(color: _rand, width: 0.8),
                      ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 132,
                    child: Text(
                      regel.titel,
                      style: const TextStyle(
                        color: _tekstGrijs,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      regel.waarde,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: _tekstDonker,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
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

class _PrijsSamenvattingKaart extends StatelessWidget {
  const _PrijsSamenvattingKaart({
    required this.resultaat,
    required this.aantal,
  });

  final OfferteBerekeningResultaat resultaat;
  final int aantal;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _rand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Prijsberekening',
            style: TextStyle(
              color: _groen,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          _PrijsSamenvattingRij(
            omschrijving: aantal > 1
                ? 'Prijs per stuk · $aantal stuks'
                : 'Prijs per stuk',
            bedrag: resultaat.basisTotaalExclBtw,
          ),
          if (resultaat.heeftArtikelWinstmarge)
            _PrijsSamenvattingRij(
              omschrijving:
                  'Winst per artikel · ${resultaat.winstmargeOmschrijving}',
              bedrag: resultaat.winstmargeBedragExclBtw,
            ),
          if (resultaat.heeftArtikelKorting)
            _PrijsSamenvattingRij(
              omschrijving:
                  'Korting per artikel · ${resultaat.kortingOmschrijving}',
              bedrag: -resultaat.kortingBedragExclBtw,
              korting: true,
            ),
          ...resultaat.vrijeArtikelPrijsregels.map((prijsregel) {
            final omschrijving = prijsregel.isOptie
                ? '${prijsregel.omschrijving} · optie op offerte'
                : prijsregel.toonAfzonderlijkePrijsOpOfferte
                ? '${prijsregel.omschrijving} · apart op offerte'
                : '${prijsregel.omschrijving} · verwerkt in artikelprijs';
            return _PrijsSamenvattingRij(
              omschrijving: omschrijving,
              bedrag: prijsregel.totaalExclBtw,
              optie: prijsregel.isOptie,
            );
          }),
          ...resultaat.verdeeldePrijsregels.map((prijsregel) {
            final aantalArtikelen = prijsregel.verdeeldOverAantalArtikelen;
            final verdelingTekst = aantalArtikelen > 0
                ? ' · verdeeld over $aantalArtikelen artikelen'
                : ' · verdeelde projectkost';

            return _PrijsSamenvattingRij(
              omschrijving: '${prijsregel.omschrijving}$verdelingTekst',
              bedrag: prijsregel.totaalExclBtw,
              intern: true,
            );
          }),
          const Divider(height: 18, color: _rand),
          _PrijsSamenvattingRij(
            omschrijving: 'Totaal positie excl. btw',
            bedrag: resultaat.totaalExclBtw,
            vet: true,
          ),
          if (!resultaat.heeftTechnischePrijsregels &&
              !resultaat.heeftVrijeArtikelPrijsregels &&
              !resultaat.heeftVerdeeldePrijsregels &&
              !resultaat.heeftArtikelWinstmarge &&
              !resultaat.heeftArtikelKorting) ...[
            const SizedBox(height: 5),
            const Text(
              'Geen bijkomende prijsregels van toepassing.',
              style: TextStyle(
                color: _tekstGrijs,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PrijsSamenvattingRij extends StatelessWidget {
  const _PrijsSamenvattingRij({
    required this.omschrijving,
    required this.bedrag,
    this.vet = false,
    this.intern = false,
    this.optie = false,
    this.korting = false,
  });

  final String omschrijving;
  final double bedrag;
  final bool vet;
  final bool intern;
  final bool optie;
  final bool korting;

  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);
  static const Color _groen = Color(0xFF0B7A3B);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    omschrijving,
                    style: TextStyle(
                      color: vet ? _tekstDonker : _tekstGrijs,
                      fontSize: vet ? 12.5 : 11.5,
                      fontWeight: vet ? FontWeight.w900 : FontWeight.w700,
                    ),
                  ),
                ),
                if (intern || optie) ...<Widget>[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: Text(
                      optie ? 'optie' : 'intern',
                      style: const TextStyle(
                        color: Color(0xFF9A3412),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${_formatteerBedrag(bedrag, korting: korting)} excl. btw',
            style: TextStyle(
              color: korting ? _groen : _tekstDonker,
              fontSize: vet ? 13 : 11.5,
              fontWeight: vet ? FontWeight.w900 : FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatteerBedrag(double bedrag, {bool korting = false}) {
    final absoluut = bedrag.abs().toStringAsFixed(2).replaceAll('.', ',');
    return korting || bedrag < 0 ? '- € $absoluut' : '€ $absoluut';
  }
}

class _PrijsPerStukVeld extends StatefulWidget {
  const _PrijsPerStukVeld({
    required this.beginPrijs,
    required this.onGewijzigd,
  });

  final double beginPrijs;
  final ValueChanged<double> onGewijzigd;

  @override
  State<_PrijsPerStukVeld> createState() => _PrijsPerStukVeldState();
}

class _PrijsPerStukVeldState extends State<_PrijsPerStukVeld> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _prijsTekst(widget.beginPrijs));
    _focusNode = FocusNode()..addListener(_verwerkFocusWijziging);
  }

  @override
  void didUpdateWidget(covariant _PrijsPerStukVeld oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Tijdens het typen mag een opslag/rebuild de invoer niet vervangen door
    // bijvoorbeeld 1,00. Zo blijft de cursor gewoon achter het laatst
    // ingevoerde cijfer staan.
    if (_focusNode.hasFocus || oldWidget.beginPrijs == widget.beginPrijs) {
      return;
    }

    final nieuweTekst = _prijsTekst(widget.beginPrijs);
    if (_controller.text != nieuweTekst) {
      _zetControllerTekst(nieuweTekst);
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_verwerkFocusWijziging)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  String _prijsTekst(double prijs) {
    if (prijs <= 0) {
      return '';
    }

    return prijs.toStringAsFixed(2).replaceAll('.', ',');
  }

  double _leesPrijs(String tekst) {
    return double.tryParse(tekst.trim().replaceAll(',', '.')) ?? 0;
  }

  void _zetControllerTekst(String tekst) {
    _controller.value = TextEditingValue(
      text: tekst,
      selection: TextSelection.collapsed(offset: tekst.length),
    );
  }

  void _verwerkFocusWijziging() {
    if (!_focusNode.hasFocus) {
      _formatteerHuidigeInvoer();
    }
  }

  void _formatteerHuidigeInvoer() {
    final huidigeTekst = _controller.text.trim();
    if (huidigeTekst.isEmpty) {
      return;
    }

    final prijs = _leesPrijs(huidigeTekst);
    final netteTekst = _prijsTekst(prijs);
    if (_controller.text != netteTekst) {
      _zetControllerTekst(netteTekst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        TextInputFormatter.withFunction((oudeWaarde, nieuweWaarde) {
          final geldig = RegExp(r'^\d*([,.]\d{0,2})?$');
          return geldig.hasMatch(nieuweWaarde.text) ? nieuweWaarde : oudeWaarde;
        }),
      ],
      decoration: InputDecoration(
        labelText: 'Prijs per stuk — excl. btw',
        hintText: '0,00',
        prefixText: '€ ',
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFFFFBF5),
        contentPadding: const EdgeInsets.fromLTRB(12, 13, 12, 13),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0xFFFED7AA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0xFF0B7A3B), width: 1.5),
        ),
      ),
      onChanged: (tekst) {
        widget.onGewijzigd(_leesPrijs(tekst));
      },
      onSubmitted: (_) {
        _formatteerHuidigeInvoer();
      },
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
