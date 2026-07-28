// THIMACO-CONTROLE: SCHUIFVLIEGENDEUR-FICHE-FASE-2-20260728
import 'package:flutter/material.dart';

import '../../../app_storage.dart';
import '../../../offerte/prijzen/offerte_artikel_prijs_data_model.dart';
import '../../fotos/opmeting_foto_model.dart';
import '../../kader_samenstelling/opmeting_kader_samenstelling_model.dart';
import '../../overzicht/opmeting_overzicht_model.dart';
import '../../raam/opmeting_raam_notities.dart';
import 'opmeting_schuifvliegendeur_model.dart';
import 'opmeting_schuifvliegendeur_rechterkolom.dart';
import 'opmeting_schuifvliegendeur_technische_regels_helpers.dart';
import 'opmeting_schuifvliegendeur_tekenvlak.dart';

class OpmetingSchuifvliegendeurFiche extends StatefulWidget {
  const OpmetingSchuifvliegendeurFiche({
    super.key,
    this.klantNaam,
    this.bestaandeOpmeting,
    this.ralKleurToebehoren = '',
    this.standaardPrijsPerStukExclBtw = 0,
    this.standaardWinstmargePercentage = 0,
    this.standaardKortingPercentage = 0,
  });

  final String? klantNaam;
  final OpmetingOverzichtRaamItem? bestaandeOpmeting;
  final String ralKleurToebehoren;
  final double standaardPrijsPerStukExclBtw;
  final double standaardWinstmargePercentage;
  final double standaardKortingPercentage;

  @override
  State<OpmetingSchuifvliegendeurFiche> createState() {
    return _OpmetingSchuifvliegendeurFicheState();
  }
}

class _OpmetingSchuifvliegendeurFicheState
    extends State<OpmetingSchuifvliegendeurFiche> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);

  final TextEditingController _notitiesController = TextEditingController();

  late OpmetingSchuifvliegendeurModel _model;
  bool _bewarenBezig = false;

  @override
  void initState() {
    super.initState();
    _model =
        widget.bestaandeOpmeting?.schuifvliegendeurData ??
        OpmetingSchuifvliegendeurModel(
          ralKleurToebehorenWaarde: widget.ralKleurToebehoren.trim(),
        );
    _model = _synchroniseerProjectkleur(_model);
    _notitiesController.text = _model.notities;
    _notitiesController.addListener(_verwerkNotities);
  }

  @override
  void didUpdateWidget(covariant OpmetingSchuifvliegendeurFiche oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ralKleurToebehoren.trim() ==
        widget.ralKleurToebehoren.trim()) {
      return;
    }

    final bijgewerkt = _synchroniseerProjectkleur(_model);
    if (bijgewerkt != _model) {
      setState(() {
        _model = bijgewerkt;
      });
    }
  }

  String get _actueleProjectkleur => widget.ralKleurToebehoren.trim();

  OpmetingSchuifvliegendeurModel _synchroniseerProjectkleur(
    OpmetingSchuifvliegendeurModel model,
  ) {
    if (!model.gebruiktProjectKleur) return model;
    if (model.ralKleurToebehorenWaarde.trim() == _actueleProjectkleur) {
      return model;
    }
    return model.copyWith(ralKleurToebehorenWaarde: _actueleProjectkleur);
  }

  OpmetingSchuifvliegendeurModel _normaliseerVoorOpslag(
    OpmetingSchuifvliegendeurModel model,
  ) {
    var resultaat = _synchroniseerProjectkleur(model);

    if (resultaat.isElegancePlus) {
      resultaat = resultaat.copyWith(
        aantalTraversen: 0,
        traverseHoogtesMm: const <int>[],
        plaat: resultaat.isPlaatTotTussenstijl
            ? OpmetingSchuifvliegendeurModel.plaatGeen
            : resultaat.plaat,
      );
    } else {
      final aantal = resultaat.isTraverseOpMaat
          ? resultaat.aantalTraversen.clamp(1, 3).toInt()
          : 1;
      resultaat = resultaat.copyWith(
        aantalTraversen: aantal,
        traverseHoogtesMm: resultaat.actieveTraverseHoogtesMm,
      );
    }

    return resultaat;
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

  void _verwerkRechterkolom(OpmetingSchuifvliegendeurModel model) {
    setState(() {
      _model = _synchroniseerProjectkleur(
        model,
      ).copyWith(notities: _notitiesController.text, fotos: _model.fotos);
    });
  }

  Future<void> _sluitFiche() async {
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _voegToeAanOverzicht() async {
    if (_bewarenBezig) return;

    setState(() {
      _bewarenBezig = true;
    });

    try {
      final opmeting = _maakOverzichtItem();
      final bewaardeOpmeting = widget.bestaandeOpmeting == null
          ? await AppStorage.voegOpmetingToe(opmeting)
          : await AppStorage.werkOpmetingBij(opmeting);

      if (!mounted) return;
      Navigator.of(context).pop(bewaardeOpmeting);
    } catch (fout) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text('Schuifvliegendeur opslaan is niet gelukt: $fout'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _bewarenBezig = false;
        });
      }
    }
  }

  OpmetingOverzichtRaamItem _maakOverzichtItem() {
    final klantNaam =
        (widget.klantNaam ?? widget.bestaandeOpmeting?.klantNaam ?? '').trim();
    final modelVoorOpslag = _normaliseerVoorOpslag(_model).copyWith(
      notities: _notitiesController.text.trim(),
      fotos: List<OpmetingFoto>.unmodifiable(_model.fotos),
    );

    final standaardPrijsData = OfferteArtikelPrijsDataModel(
      prijsPerStukExclBtw: widget.standaardPrijsPerStukExclBtw,
      artikelWinstmargePercentage: widget.standaardWinstmargePercentage,
      artikelKortingPercentage: widget.standaardKortingPercentage,
    );

    return OpmetingOverzichtRaamItem(
      id: widget.bestaandeOpmeting?.id ?? '',
      titel: modelVoorOpslag.stukReferentie.trim().isEmpty
          ? 'Schuifvliegendeur'
          : modelVoorOpslag.stukReferentie.trim(),
      klantNaam: klantNaam,
      formulierType: 'schuifvliegendeur',
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
      dagmaatBreedteMm: modelVoorOpslag.breedteMm,
      dagmaatHoogteMm: modelVoorOpslag.hoogteMm,
      raammaatBreedteMm: modelVoorOpslag.breedteMm,
      raammaatHoogteMm: modelVoorOpslag.hoogteMm,
      kaderSamenstelling: OpmetingKaderSamenstelling.basis(
        breedteMm: modelVoorOpslag.breedteMm,
        hoogteMm: modelVoorOpslag.hoogteMm,
      ),
      tekeningData: OpmetingOverzichtTekeningData.leeg(),
      technischeRegels: OpmetingSchuifvliegendeurTechnischeRegelsHelper.bouw(
        modelVoorOpslag,
      ),
      technischeContainers: const <OpmetingOverzichtTechnischeContainer>[],
      fotos: modelVoorOpslag.fotos,
      notities: modelVoorOpslag.notities,
      offertePrijsData:
          widget.bestaandeOpmeting?.offertePrijsData ?? standaardPrijsData,
      schuifvliegendeurData: modelVoorOpslag,
    );
  }

  @override
  Widget build(BuildContext context) {
    final klantNaam =
        (widget.klantNaam ?? widget.bestaandeOpmeting?.klantNaam ?? '').trim();

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
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: _sluitFiche,
          ),
          title: Text(
            klantNaam.isEmpty
                ? 'Opmeting Schuifvliegendeur'
                : 'Opmeting Schuifvliegendeur · $klantNaam',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton.icon(
                onPressed: _bewarenBezig ? null : _voegToeAanOverzicht,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _groen,
                ),
                icon: _bewarenBezig
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _groen,
                        ),
                      )
                    : const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  widget.bestaandeOpmeting == null ? 'Toevoegen' : 'Bewaren',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ElevatedButton.icon(
                onPressed: _sluitFiche,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _groen,
                ),
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Annuleren'),
              ),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final liggend = constraints.maxWidth >= 900;
            final tekenKaart = _bouwTekeningEnNotities();
            final rechterkolom = OpmetingSchuifvliegendeurRechterkolom(
              model: _model,
              projectRalKleur: widget.ralKleurToebehoren,
              onGewijzigd: _verwerkRechterkolom,
            );

            return Padding(
              padding: const EdgeInsets.all(12),
              child: liggend
                  ? Row(
                      children: <Widget>[
                        Expanded(flex: 60, child: tekenKaart),
                        const SizedBox(width: 12),
                        Expanded(flex: 40, child: rechterkolom),
                      ],
                    )
                  : Column(
                      children: <Widget>[
                        Expanded(flex: 43, child: tekenKaart),
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

  Widget _bouwTekeningEnNotities() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rand),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0F111827),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Expanded(child: OpmetingSchuifvliegendeurTekenvlak(model: _model)),
          const SizedBox(height: 10),
          OpmetingRaamNotities(
            controller: _notitiesController,
            fotos: _model.fotos,
            onFotosGewijzigd: _verwerkFotos,
          ),
        ],
      ),
    );
  }
}
