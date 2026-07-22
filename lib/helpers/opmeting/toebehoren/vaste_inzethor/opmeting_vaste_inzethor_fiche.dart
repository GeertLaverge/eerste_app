import 'package:flutter/material.dart';

import '../../../app_storage.dart';
import '../../../offerte/prijzen/offerte_artikel_prijs_data_model.dart';
import '../../fotos/opmeting_foto_model.dart';
import '../../kader_samenstelling/opmeting_kader_samenstelling_model.dart';
import '../../overzicht/opmeting_overzicht_model.dart';
import '../../raam/opmeting_raam_notities.dart';
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
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);

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

    if (_model.isRalKleurToebehoren &&
        widget.ralKleurToebehoren.trim().isNotEmpty) {
      _model = _model.copyWith(
        ralKleurToebehorenWaarde: widget.ralKleurToebehoren.trim(),
      );
    }

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
    setState(() {
      _model = model.copyWith(
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

    final buitenBreedteMm = _model.buitenBreedteMm.round();
    final buitenHoogteMm = _model.buitenHoogteMm.round();
    final binnenBreedteMm = _model.binnenBreedteMm.round();
    final binnenHoogteMm = _model.binnenHoogteMm.round();

    final basis = OpmetingOverzichtRaamItem(
      id: widget.bestaandeOpmeting?.id ?? '',
      titel: _model.stukReferentie.trim().isEmpty
          ? 'Vaste inzethor'
          : _model.stukReferentie.trim(),
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
      technischeRegels: _maakTechnischeRegels(),
      technischeContainers: const <OpmetingOverzichtTechnischeContainer>[],
      fotos: List<OpmetingFoto>.unmodifiable(_model.fotos),
      notities: _notitiesController.text.trim(),
      vasteInzethorData: _model.copyWith(
        notities: _notitiesController.text.trim(),
        fotos: List<OpmetingFoto>.unmodifiable(_model.fotos),
      ),
    );

    return basis;
  }

  List<OpmetingOverzichtTechnischeRegel> _maakTechnischeRegels() {
    final regels = <OpmetingOverzichtTechnischeRegel>[];

    void voegToe(String titel, String waarde) {
      if (waarde.trim().isEmpty) {
        return;
      }

      regels.add(
        OpmetingOverzichtTechnischeRegel(titel: titel, waarde: waarde.trim()),
      );
    }

    voegToe('Stuk referentie', _model.stukReferentie);
    voegToe('Aantal', '${_model.aantal}');
    voegToe('Soort', _model.soort);

    if (_model.isInzetvliegenraam) {
      voegToe('Speling', _model.speling);

      if (_model.isVr033Ultra) {
        voegToe('Flens diepte', _model.flensDiepteVoorOverzicht);

        if (_model.isFlensOpMaat) {
          voegToe('Maat rand flens', _model.maatRandFlens);
        }
      }
    }

    voegToe('Profiel', _model.profiel);
    voegToe('Maatsoort', _model.maatType);
    voegToe('Breedte', '${_model.breedteMm} mm');
    voegToe('Hoogte', '${_model.hoogteMm} mm');
    voegToe('Traversen', _model.traverseType);

    final traversePosities = _model.actieveTraversePositiesMm;
    voegToe('Aantal traversen', '${traversePosities.length}');

    for (var index = 0; index < traversePosities.length; index++) {
      voegToe(
        'Traverse ${index + 1}',
        '${_formatteerMm(traversePosities[index])} mm',
      );
    }

    voegToe('Kleur', _model.kleurVoorOverzicht);
    voegToe('Gaas', _model.gaas);
    voegToe('Kleur pees', _model.kleurPees);
    voegToe('Borstels', _model.borstels);
    voegToe('Bevestiging', _model.bevestiging);

    if (_model.heeftClipsen) {
      voegToe('Soort clipsen', _model.soortClipsen);
      voegToe('Soort bevestiging', _model.soortBevestiging);
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
                ? 'Opmeting Vaste inzethor'
                : 'Opmeting Vaste inzethor · $klantNaam',
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
