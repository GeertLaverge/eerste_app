import 'package:flutter/material.dart';

import '../../../app_storage.dart';
import '../../../offerte/prijzen/offerte_artikel_prijs_data_model.dart';
import '../../fotos/opmeting_foto_model.dart';
import '../../kader_samenstelling/opmeting_kader_samenstelling_model.dart';
import '../../overzicht/opmeting_overzicht_model.dart';
import '../../raam/opmeting_raam_notities.dart';
import '../../../ui/thimaco_huisstijl.dart';
import 'opmeting_vliegendeur_model.dart';
import 'opmeting_vliegendeur_rechterkolom.dart';
import 'opmeting_vliegendeur_tekenvlak.dart';

class OpmetingVliegendeurFiche extends StatefulWidget {
  const OpmetingVliegendeurFiche({
    super.key,
    this.klantNaam,
    this.bestaandeOpmeting,
    this.projectRalKleur = '',
  });

  final String? klantNaam;
  final OpmetingOverzichtRaamItem? bestaandeOpmeting;
  final String projectRalKleur;

  @override
  State<OpmetingVliegendeurFiche> createState() {
    return _OpmetingVliegendeurFicheState();
  }
}

class _OpmetingVliegendeurFicheState extends State<OpmetingVliegendeurFiche> {
  static const Color _rand = ThimacoKleuren.rand;

  final TextEditingController _notitiesController = TextEditingController();

  late OpmetingVliegendeurModel _model;
  bool _bewarenBezig = false;

  @override
  void initState() {
    super.initState();
    _model =
        widget.bestaandeOpmeting?.vliegendeurData ??
        const OpmetingVliegendeurModel();
    _notitiesController.text = _model.notities;
    _notitiesController.addListener(_verwerkNotities);
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

  void _verwerkRechterkolom(OpmetingVliegendeurModel model) {
    setState(() {
      _model = model.copyWith(
        notities: _notitiesController.text,
        fotos: _model.fotos,
      );
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
          content: Text('Vliegendeur opslaan is niet gelukt: $fout'),
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
    final modelVoorOpslag = _model.copyWith(
      notities: _notitiesController.text.trim(),
      fotos: List<OpmetingFoto>.unmodifiable(_model.fotos),
    );

    return OpmetingOverzichtRaamItem(
      id: widget.bestaandeOpmeting?.id ?? '',
      titel: modelVoorOpslag.stukReferentie.trim().isEmpty
          ? 'Vliegendeur'
          : modelVoorOpslag.stukReferentie.trim(),
      klantNaam: klantNaam,
      formulierType: 'vliegendeur',
      gewijzigdOp: widget.bestaandeOpmeting?.gewijzigdOp ?? '',
      isVerwijderd: widget.bestaandeOpmeting?.isVerwijderd ?? false,
      isOfferteOptie: widget.bestaandeOpmeting?.isOfferteOptie ?? false,
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
      technischeRegels: _maakTechnischeRegels(modelVoorOpslag),
      technischeContainers: const <OpmetingOverzichtTechnischeContainer>[],
      fotos: modelVoorOpslag.fotos,
      notities: modelVoorOpslag.notities,
      offertePrijsData:
          widget.bestaandeOpmeting?.offertePrijsData ??
          const OfferteArtikelPrijsDataModel(),
      vliegendeurData: modelVoorOpslag,
    );
  }

  String _kleurVoorTechnischeRegel(OpmetingVliegendeurModel model) {
    if (!model.isProjectKleur) {
      return model.kleurVoorOverzicht;
    }

    final projectkleur = widget.projectRalKleur.trim();
    return projectkleur.isEmpty
        ? OpmetingVliegendeurModel.kleurNogTeBepalen
        : projectkleur;
  }

  List<OpmetingOverzichtTechnischeRegel> _maakTechnischeRegels(
    OpmetingVliegendeurModel model,
  ) {
    final regels = <OpmetingOverzichtTechnischeRegel>[];

    void voegToe(String titel, String waarde) {
      if (waarde.trim().isEmpty) return;
      regels.add(
        OpmetingOverzichtTechnischeRegel(titel: titel, waarde: waarde.trim()),
      );
    }

    voegToe('Stuk referentie', model.stukReferentie);
    voegToe('Aantal', '${model.aantal}');
    voegToe('Breedte buitenmaat', '${model.breedteMm} mm');
    voegToe('Hoogte buitenmaat', '${model.hoogteMm} mm');
    voegToe('Soort', model.soort);
    voegToe('Traverse', model.traverseType);
    voegToe('Aantal traversen', '${model.aantalTraversen}');

    final doorgangHoogtes = model.actieveDoorgangHoogtesMm;
    for (var index = 0; index < doorgangHoogtes.length; index++) {
      voegToe('Doorganghoogte ${index + 1}', '${doorgangHoogtes[index]} mm');
    }

    voegToe('Kleursoort', model.kleursoort);
    voegToe('Kleur', _kleurVoorTechnischeRegel(model));
    voegToe('Kleur PVC', model.kleurPvc);
    voegToe('Kaderuitvoering', model.kaderuitvoering);
    voegToe('Scharnierkant', model.scharnierkant);
    voegToe('Dierenluik', model.dierenluik);
    voegToe('Schopplaat', model.schopplaat);

    if (model.isSchopplaatOpMaat) {
      voegToe('Hoogte schopplaat', '${model.schopplaatHoogteOpMaatMm} mm');
    }

    voegToe('Gaas', model.gaas);
    voegToe('Gaas onder T1', model.gaasOnderT1);
    voegToe('Sluiting', model.sluiting);
    voegToe('Pomp', model.pomp);
    voegToe('Afdekkappen', model.afdekkappen);
    voegToe('Kleur pees', model.kleurPees);
    voegToe('Kleur borstel', model.kleurBorstel);
    return regels;
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
            klantNaam.isEmpty
                ? 'Opmeting Vliegendeur'
                : 'Opmeting Vliegendeur · $klantNaam',
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
                onPressed: _sluitFiche,
              ),
            ),
            const SizedBox(width: 6),
            Center(
              child: SizedBox(
                height: 32,
                child: ElevatedButton.icon(
                  onPressed: _bewarenBezig ? null : _voegToeAanOverzicht,
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
                  icon: _bewarenBezig
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
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 60,
                child: Container(
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
                      Expanded(
                        child: OpmetingVliegendeurTekenvlak(model: _model),
                      ),
                      const SizedBox(height: 10),
                      OpmetingRaamNotities(
                        controller: _notitiesController,
                        fotos: _model.fotos,
                        onFotosGewijzigd: _verwerkFotos,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 40,
                child: OpmetingVliegendeurRechterkolom(
                  model: _model,
                  projectRalKleur: widget.projectRalKleur,
                  onGewijzigd: _verwerkRechterkolom,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
