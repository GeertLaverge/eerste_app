import 'package:flutter/material.dart';

import '../../../app_storage.dart';
import '../../../offerte/prijzen/offerte_artikel_prijs_data_model.dart';
import '../../fotos/opmeting_foto_model.dart';
import '../../kader_samenstelling/opmeting_kader_samenstelling_model.dart';
import '../../overzicht/opmeting_overzicht_model.dart';
import '../../raam/opmeting_raam_notities.dart';
import '../../../ui/thimaco_huisstijl.dart';
import 'opmeting_vaste_inzethor_model.dart';
import 'opmeting_vaste_inzethor_rechterkolom.dart';
import 'opmeting_vaste_inzethor_tekenvlak.dart';

class OpmetingVasteInzethorFiche extends StatefulWidget {
  const OpmetingVasteInzethorFiche({
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
  State<OpmetingVasteInzethorFiche> createState() {
    return _OpmetingVasteInzethorFicheState();
  }
}

class _OpmetingVasteInzethorFicheState
    extends State<OpmetingVasteInzethorFiche> {
  static const Color _rand = ThimacoKleuren.rand;

  final TextEditingController _notitiesController = TextEditingController();

  late OpmetingVasteInzethorModel _model;
  bool _bewarenBezig = false;

  @override
  void initState() {
    super.initState();

    _model =
        widget.bestaandeOpmeting?.vasteInzethorData ??
        OpmetingVasteInzethorModel(
          prijsData: OfferteArtikelPrijsDataModel(
            prijsPerStukExclBtw: widget.standaardPrijsPerStukExclBtw,
            artikelWinstmargePercentage: widget.standaardWinstmargePercentage,
            artikelKortingPercentage: widget.standaardKortingPercentage,
          ),
        );

    _model = _synchroniseerProjectkleur(_model);

    _notitiesController.text = _model.notities;
    _notitiesController.addListener(_verwerkNotities);
  }

  @override
  void didUpdateWidget(covariant OpmetingVasteInzethorFiche oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.ralKleurToebehoren.trim() ==
        widget.ralKleurToebehoren.trim()) {
      return;
    }

    _model = _synchroniseerProjectkleur(_model);
  }

  String get _actueleProjectkleur => widget.ralKleurToebehoren.trim();

  OpmetingVasteInzethorModel _synchroniseerProjectkleur(
    OpmetingVasteInzethorModel model,
  ) {
    if (!model.isProjectkleur) {
      return model;
    }

    final actueleProjectkleur = _actueleProjectkleur;

    if (model.ralKleurToebehorenWaarde.trim() == actueleProjectkleur) {
      return model;
    }

    return model.copyWith(ralKleurToebehorenWaarde: actueleProjectkleur);
  }

  @override
  void dispose() {
    _notitiesController.removeListener(_verwerkNotities);
    _notitiesController.dispose();
    super.dispose();
  }

  void _verwerkNotities() {
    final tekst = _notitiesController.text;

    if (tekst == _model.notities) {
      return;
    }

    setState(() {
      _model = _model.copyWith(notities: tekst);
    });
  }

  void _verwerkFotos(List<OpmetingFoto> fotos) {
    setState(() {
      _model = _model.copyWith(fotos: List<OpmetingFoto>.unmodifiable(fotos));
    });
  }

  void _verwerkRechterkolom(OpmetingVasteInzethorModel model) {
    final modelMetActueleProjectkleur = _synchroniseerProjectkleur(model);

    setState(() {
      _model = modelMetActueleProjectkleur.copyWith(
        notities: _notitiesController.text,
        fotos: _model.fotos,
      );
    });
  }

  Future<void> _sluitFiche() async {
    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  Future<void> _voegToeAanOverzicht() async {
    if (_bewarenBezig) {
      return;
    }

    setState(() {
      _bewarenBezig = true;
    });

    try {
      final opmeting = _maakOverzichtItem();

      final bewaardeOpmeting = widget.bestaandeOpmeting == null
          ? await AppStorage.voegOpmetingToe(opmeting)
          : await AppStorage.werkOpmetingBij(opmeting);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(bewaardeOpmeting);
    } catch (fout) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text('Vaste inzethor opslaan is niet gelukt: $fout'),
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
    final actueelModel = _synchroniseerProjectkleur(_model)
        .copyWithGesynchroniseerdeTraversen()
        .genormaliseerdVoorProduct()
        .copyWith(
          notities: _notitiesController.text.trim(),
          fotos: List<OpmetingFoto>.unmodifiable(_model.fotos),
        );

    final buitenBreedteMm = actueelModel.buitenBreedteMm.round();
    final buitenHoogteMm = actueelModel.buitenHoogteMm.round();
    final binnenBreedteMm = actueelModel.binnenBreedteMm.round();
    final binnenHoogteMm = actueelModel.binnenHoogteMm.round();

    return OpmetingOverzichtRaamItem(
      id: widget.bestaandeOpmeting?.id ?? '',
      titel: actueelModel.stukReferentie.trim().isEmpty
          ? 'Vaste inzethor'
          : actueelModel.stukReferentie.trim(),
      klantNaam: klantNaam,
      formulierType: 'vasteInzethor',
      gewijzigdOp: widget.bestaandeOpmeting?.gewijzigdOp ?? '',
      isVerwijderd: widget.bestaandeOpmeting?.isVerwijderd ?? false,
      isOfferteOptie: widget.bestaandeOpmeting?.isOfferteOptie ?? false,
      offerteOptiePlaatsing:
          widget.bestaandeOpmeting?.offerteOptiePlaatsing ??
          OfferteOptiePlaatsing.apartePagina,
      dagmaatBreedteMm: binnenBreedteMm,
      dagmaatHoogteMm: binnenHoogteMm,
      raammaatBreedteMm: buitenBreedteMm,
      raammaatHoogteMm: buitenHoogteMm,
      kaderSamenstelling: OpmetingKaderSamenstelling.basis(
        breedteMm: buitenBreedteMm,
        hoogteMm: buitenHoogteMm,
      ),
      tekeningData: OpmetingOverzichtTekeningData.leeg(),
      technischeRegels: _maakTechnischeRegels(actueelModel),
      technischeContainers: const <OpmetingOverzichtTechnischeContainer>[],
      fotos: actueelModel.fotos,
      notities: actueelModel.notities,
      vasteInzethorData: actueelModel,
    );
  }

  List<OpmetingOverzichtTechnischeRegel> _maakTechnischeRegels(
    OpmetingVasteInzethorModel model,
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
    voegToe('Soort', model.soortVoorWeergave);

    if (model.isInzetvliegenraam) {
      voegToe('Profiel', model.inzetProfielVoorWeergave);
      if (model.isVr033Inzet) {
        voegToe('Speling', model.spelingVoorOverzicht);
        if (model.heeftStandaardSpeling) {
          voegToe(
            'Vaste speling',
            'Breedte ${OpmetingVasteInzethorModel.standaardSpelingBreedteMm} mm · '
                'hoogte ${OpmetingVasteInzethorModel.standaardSpelingHoogteMm} mm',
          );
        }
        voegToe('Flens', '5 mm buiten het kader');
      } else {
        voegToe('Flensdiepte', model.flensDiepteVoorOverzicht);
      }
    } else {
      voegToe('Profiel', model.profielVoorWeergave);
    }

    voegToe('Maatsoort', model.maatSamenvattingTitel);
    voegToe('Breedte', '${model.breedteMm} mm');
    voegToe(
      model.isVliegenraamDubbel ? 'H · Hoogte hoofdraam' : 'Hoogte',
      '${model.hoogteMm} mm',
    );
    if (model.isVliegenraamDubbel) {
      voegToe(
        'L5 · Hoogte onderste kader',
        '${model.hoogteOndersteKaderMm} mm',
      );
    }

    voegToe('Traversen', model.traverseType);
    final traversePosities = model.actieveTraversePositiesMm;
    voegToe('Aantal traversen', '${traversePosities.length}');
    for (var index = 0; index < traversePosities.length; index++) {
      voegToe(
        'Traverse ${index + 1}',
        '${_formatteerMm(traversePosities[index])} mm',
      );
    }

    if (model.isProjectkleur) {
      final projectkleur = model.ralKleurToebehorenWaarde.trim();
      voegToe(
        OpmetingVasteInzethorModel.kleurProjectLabel,
        projectkleur.isEmpty ? 'Nog niet ingevuld' : projectkleur,
      );
    } else {
      voegToe('Kleur', model.kleurVoorOverzicht);
    }

    voegToe('Gaas', model.gaasVoorWeergave);
    voegToe('Kleur pees', model.kleurPees);
    voegToe('Borstels', model.borstels);
    voegToe('Bevestiging', model.bevestiging);
    if (model.heeftClipsen) {
      voegToe('Soort clipsen', model.soortClipsen);
      voegToe('Soort bevestiging', model.soortBevestigingVoorWeergave);
    }

    return regels;
  }

  String _formatteerMm(double waarde) {
    if (waarde == waarde.roundToDouble()) {
      return waarde.round().toString();
    }

    return waarde.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final klantNaam =
        (widget.klantNaam ?? widget.bestaandeOpmeting?.klantNaam ?? '').trim();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _sluitFiche();
        }
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
                ? 'Opmeting Vaste inzethor'
                : 'Opmeting Vaste inzethor · $klantNaam',
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
                        child: OpmetingVasteInzethorTekenvlak(model: _model),
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
                child: OpmetingVasteInzethorRechterkolom(
                  model: _model,
                  ralKleurToebehoren: widget.ralKleurToebehoren,
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
