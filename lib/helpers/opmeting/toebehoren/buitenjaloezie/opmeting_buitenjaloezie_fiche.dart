// THIMACO-CONTROLE: BUITENJALOEZIE-DEFINITIEVE-FICHE-ZOALS-VOORZETSCREEN-20260803
// THIMACO-CONTROLE: BUITENJALOEZIE-CENTRAAL-BEWAREN-FASE-3B-20260803
// THIMACO-CONTROLE: BUITENJALOEZIE-ZELFSTANDIGE-FICHE-FASE-2-20260803

import 'package:flutter/material.dart';

import '../../../app_storage.dart';
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
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);

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
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: _groen,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: _sluitFiche,
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          title: Text(
            titel,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton.icon(
                onPressed: _bewaren ? null : _bewaar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _groen,
                ),
                icon: _bewaren
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _groen,
                        ),
                      )
                    : const Icon(Icons.save_outlined, size: 18),
                label: Text(
                  widget.bestaandeOpmeting == null ? 'Toevoegen' : 'Bewaren',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ElevatedButton.icon(
                onPressed: _bewaren ? null : _sluitFiche,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _groen,
                ),
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Sluiten'),
              ),
            ),
          ],
        ),
        body: _laden
            ? const Center(child: CircularProgressIndicator(color: _groen))
            : LayoutBuilder(
                builder: (context, constraints) {
                  final breedScherm = constraints.maxWidth >= 900;

                  if (!breedScherm) {
                    return Column(
                      children: <Widget>[
                        SizedBox(
                          height: constraints.maxHeight * 0.42,
                          child: _tekenKaart(),
                        ),
                        Expanded(
                          child: OpmetingBuitenjaloezieRechterkolom(
                            model: _model,
                            instellingen: _instellingen,
                            onChanged: (model) {
                              setState(() => _model = model);
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: <Widget>[
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: _tekenKaart(),
                        ),
                      ),
                      Container(width: 1, color: _rand),
                      Expanded(
                        flex: 5,
                        child: OpmetingBuitenjaloezieRechterkolom(
                          model: _model,
                          instellingen: _instellingen,
                          onChanged: (model) => setState(() => _model = model),
                        ),
                      ),
                    ],
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: const BoxDecoration(
              color: Color(0xFFE7F6EC),
              border: Border(bottom: BorderSide(color: Color(0xFFCDEBD6))),
            ),
            child: Text(
              '${_model.systeem.label} · ${_model.lameltype.label} · '
              '${_model.totaleBreedteMm} × ${_model.totaleHoogteMm} mm',
              style: const TextStyle(
                color: _groen,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
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
