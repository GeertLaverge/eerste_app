// THIMACO-CONTROLE: BUITENJALOEZIE-DEFINITIEVE-FICHE-ZOALS-VOORZETSCREEN-20260803
// THIMACO-CONTROLE: BUITENJALOEZIE-CENTRAAL-BEWAREN-FASE-3B-20260803
// THIMACO-CONTROLE: BUITENJALOEZIE-ZELFSTANDIGE-FICHE-FASE-2-20260803

import 'package:flutter/material.dart';

import '../../../app_storage.dart';
import '../../../ui/thimaco_huisstijl.dart';
import '../../../offerte/prijzen/offerte_artikel_prijs_data_model.dart';
import '../../kader_samenstelling/opmeting_kader_samenstelling_model.dart';
import '../../overzicht/opmeting_overzicht_model.dart';
import '../../fotos/opmeting_foto_model.dart';
import '../../raam/opmeting_raam_notities.dart';

import 'opmeting_buitenjaloezie_instellingen_model.dart';
import 'opmeting_buitenjaloezie_kasthoogte_helper.dart';
import 'opmeting_buitenjaloezie_model.dart';
import 'opmeting_buitenjaloezie_rechterkolom.dart';
import 'opmeting_buitenjaloezie_tekenvlak.dart';
import 'opmeting_buitenjaloezie_technische_regels_helper.dart';

class OpmetingBuitenjaloezieFiche extends StatefulWidget {
  const OpmetingBuitenjaloezieFiche({
    super.key,
    this.klantNaam,
    this.bestaandeOpmeting,
  });

  final String? klantNaam;
  final OpmetingOverzichtRaamItem? bestaandeOpmeting;

  @override
  State<OpmetingBuitenjaloezieFiche> createState() =>
      _OpmetingBuitenjaloezieFicheState();
}

class _OpmetingBuitenjaloezieFicheState
    extends State<OpmetingBuitenjaloezieFiche> {
  static const Color _rand = ThimacoKleuren.rand;

  final TextEditingController _notitiesController = TextEditingController();

  late OpmetingBuitenjaloezieModel _model;
  OpmetingBuitenjaloezieInstellingen _instellingen =
      const OpmetingBuitenjaloezieInstellingen();
  bool _bewaren = false;
  bool _laden = true;

  @override
  void initState() {
    super.initState();
    _model =
        widget.bestaandeOpmeting?.buitenjaloezieData ??
        const OpmetingBuitenjaloezieModel();
    _notitiesController.text = _model.notities;
    _notitiesController.addListener(_verwerkNotities);
    _laadInstellingen();
  }

  Future<void> _laadInstellingen() async {
    final instellingen =
        await AppStorage.laadOpmetingBuitenjaloezieInstellingen();
    if (!mounted) return;

    setState(() {
      _instellingen = instellingen;
      _model = _normaliseer(_model);
      _laden = false;
    });
  }

  @override
  void dispose() {
    _notitiesController.removeListener(_verwerkNotities);
    _notitiesController.dispose();
    super.dispose();
  }

  void _verwerkNotities() {
    final tekst = _notitiesController.text;
    if (tekst == _model.notities) return;
    setState(() {
      _model = _model.copyWith(notities: tekst);
    });
  }

  void _verwerkFotos(List<OpmetingFoto> fotos) {
    setState(() {
      _model = _model.copyWith(fotos: List<OpmetingFoto>.unmodifiable(fotos));
    });
  }

  Future<void> _sluitFiche() async {
    if (_bewaren || !mounted) return;
    Navigator.of(context).pop();
  }

  OpmetingBuitenjaloezieModel _normaliseer(OpmetingBuitenjaloezieModel model) {
    var resultaat = OpmetingBuitenjaloezieKasthoogteHelper.pasAutomatischToe(
      model,
    );

    final kleuren = _instellingen.kleurenVoor(resultaat.lameltype);
    if (kleuren.isNotEmpty &&
        !kleuren.any((kleur) => kleur.code == resultaat.lamelkleurCode)) {
      final kleur = kleuren.first;
      resultaat = resultaat.copyWith(
        lamelkleurCode: kleur.code,
        lamelkleurNaam: kleur.naam,
        lamelkleurHex: kleur.hexKleur,
      );
    }

    final geleiders = _instellingen.geleidersVoor(resultaat.lameltype);
    if (geleiders.isNotEmpty &&
        !geleiders.any((geleider) => geleider.code == resultaat.geleiderCode)) {
      final geleider = geleiders.first;
      resultaat = resultaat.copyWith(
        geleiderCode: geleider.code,
        geleiderOmschrijving: geleider.omschrijving,
        geleiderBreedteMm: geleider.breedteMm,
      );
    }

    return resultaat;
  }

  Future<void> _bewaar() async {
    if (_bewaren) return;

    setState(() => _bewaren = true);
    try {
      final item = _maakOverzichtItem();
      final bewaard = widget.bestaandeOpmeting == null
          ? await AppStorage.voegOpmetingToe(item)
          : await AppStorage.werkOpmetingBij(item);

      if (!mounted) return;
      Navigator.of(context).pop(bewaard);
    } catch (fout) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Buitenjaloezie opslaan is niet gelukt: $fout'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) setState(() => _bewaren = false);
    }
  }

  OpmetingOverzichtRaamItem _maakOverzichtItem() {
    final klantNaam =
        (widget.klantNaam ?? widget.bestaandeOpmeting?.klantNaam ?? '').trim();
    final bestaandePrijsData =
        widget.bestaandeOpmeting?.offertePrijsData ??
        const OfferteArtikelPrijsDataModel();
    final prijsData = bestaandePrijsData.copyWith(
      toegepasteTechnischePrijsregels: const [],
      technischePrijsSignatuur: '',
    );

    return OpmetingOverzichtRaamItem(
      id: widget.bestaandeOpmeting?.id ?? '',
      titel: 'Buitenjaloezie',
      klantNaam: klantNaam,
      formulierType: 'buitenjaloezie',
      gewijzigdOp: widget.bestaandeOpmeting?.gewijzigdOp ?? '',
      isVerwijderd: widget.bestaandeOpmeting?.isVerwijderd ?? false,
      isOfferteOptie: widget.bestaandeOpmeting?.isOfferteOptie ?? false,
      isNietRekenen: widget.bestaandeOpmeting?.isNietRekenen ?? false,
      offerteOptiePlaatsing:
          widget.bestaandeOpmeting?.offerteOptiePlaatsing ??
          OfferteOptiePlaatsing.apartePagina,
      offerteOptieHoofdpositieId:
          widget.bestaandeOpmeting?.offerteOptieHoofdpositieId ?? '',
      gekopieerdVanPositieId:
          widget.bestaandeOpmeting?.gekopieerdVanPositieId ?? '',
      dagmaatBreedteMm: _model.totaleBreedteMm,
      dagmaatHoogteMm: _model.totaleHoogteMm,
      raammaatBreedteMm: _model.totaleBreedteMm,
      raammaatHoogteMm: _model.totaleHoogteMm,
      kaderSamenstelling: OpmetingKaderSamenstelling.basis(
        breedteMm: _model.totaleBreedteMm,
        hoogteMm: _model.totaleHoogteMm,
      ),
      tekeningData: OpmetingOverzichtTekeningData.leeg(),
      technischeRegels: OpmetingBuitenjaloezieTechnischeRegelsHelper.bouw(
        _model,
      ),
      technischeContainers: const <OpmetingOverzichtTechnischeContainer>[],
      fotos: _model.fotos,
      notities: _notitiesController.text.trim(),
      offertePrijsData: prijsData,
      buitenjaloezieData: _model.copyWith(
        notities: _notitiesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final klantNaam =
        (widget.klantNaam ?? widget.bestaandeOpmeting?.klantNaam ?? '').trim();
    final titel = klantNaam.isEmpty
        ? 'Opmeting Buitenjaloezie'
        : 'Opmeting Buitenjaloezie · $klantNaam';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) await _sluitFiche();
      },
      child: Scaffold(
        backgroundColor: ThimacoKleuren.achtergrond,
        appBar: AppBar(
          toolbarHeight: 47,
          backgroundColor: Colors.white,
          foregroundColor: ThimacoKleuren.antraciet,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          leadingWidth: 46,
          leading: Center(
            child: ThimacoIcoonActie(
              icoon: Icons.arrow_back_rounded,
              tooltip: 'Terug',
              onPressed: _sluitFiche,
            ),
          ),
          titleSpacing: 0,
          title: Text(
            titel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ThimacoKleuren.antraciet,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: <Widget>[
            Center(
              child: ThimacoTekstActie(
                tekst: 'Annuleren',
                onPressed: _bewaren ? null : _sluitFiche,
              ),
            ),
            const SizedBox(width: 6),
            Center(
              child: SizedBox(
                height: 32,
                child: ElevatedButton.icon(
                  onPressed: _bewaren ? null : _bewaar,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: ThimacoKleuren.oranje,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        ThimacoKleuren.oranje.withValues(alpha: 0.45),
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  icon: _bewaren
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          widget.bestaandeOpmeting == null
                              ? Icons.add_rounded
                              : Icons.check_rounded,
                          size: 17,
                        ),
                  label: Text(
                    widget.bestaandeOpmeting == null ? 'Toevoegen' : 'Bewaren',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(
              height: 1,
              thickness: 1,
              color: ThimacoKleuren.rand,
            ),
          ),
        ),
        body: _laden
            ? const Center(
                child: CircularProgressIndicator(
                  color: ThimacoKleuren.oranje,
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final breedScherm = constraints.maxWidth >= 900;
                  final tekening = _tekenKaart();
                  final rechterkolom = OpmetingBuitenjaloezieRechterkolom(
                    model: _model,
                    instellingen: _instellingen,
                    onChanged: (model) => setState(() => _model = model),
                  );

                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: breedScherm
                        ? Row(
                            children: <Widget>[
                              Expanded(flex: 60, child: tekening),
                              const SizedBox(width: 12),
                              Expanded(flex: 40, child: rechterkolom),
                            ],
                          )
                        : Column(
                            children: <Widget>[
                              Expanded(flex: 43, child: tekening),
                              const SizedBox(height: 12),
                              Expanded(flex: 57, child: rechterkolom),
                            ],
                          ),
                  );
                },
              ),
      ),
    );
  }

  Widget _tekenKaart() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _rand),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: ThimacoKleuren.rand)),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.straighten_rounded,
                  color: ThimacoKleuren.oranje,
                  size: 17,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    '${_model.systeem.label} · ${_model.lameltype.label} · '
                    '${_model.totaleBreedteMm} × ${_model.totaleHoogteMm} mm',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ThimacoKleuren.antraciet,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: OpmetingBuitenjaloezieTekenvlak(model: _model)),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: OpmetingRaamNotities(
              controller: _notitiesController,
              fotos: _model.fotos,
              onFotosGewijzigd: _verwerkFotos,
            ),
          ),
        ],
      ),
    );
  }
}
