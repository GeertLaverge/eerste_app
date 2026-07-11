import 'package:flutter/material.dart';

import '../helpers/opmeting/kader_samenstelling/opmeting_kader_samenstelling_beheer.dart';
import '../helpers/opmeting/kader_samenstelling/opmeting_kader_samenstelling_layout_helper.dart';
import '../helpers/opmeting/kader_samenstelling/opmeting_kader_samenstelling_model.dart';

class OpmetingKaderSamenstellingTestPagina extends StatefulWidget {
  const OpmetingKaderSamenstellingTestPagina({super.key});

  @override
  State<OpmetingKaderSamenstellingTestPagina> createState() {
    return _OpmetingKaderSamenstellingTestPaginaState();
  }
}

class _OpmetingKaderSamenstellingTestPaginaState
    extends State<OpmetingKaderSamenstellingTestPagina> {
  static const Color groen = Color(0xFF0B7A3B);
  static const Color rand = Color(0xFFE5E7EB);

  late OpmetingKaderSamenstelling _samenstelling;

  @override
  void initState() {
    super.initState();

    _samenstelling = OpmetingKaderSamenstelling.basis(
      breedteMm: 1000,
      hoogteMm: 2200,
      slagLinksMm: 20,
      slagRechtsMm: 20,
      slagBovenMm: 20,
      slagOnderMm: 20,
    );
  }

  void _wijzigSamenstelling(OpmetingKaderSamenstelling nieuweSamenstelling) {
    setState(() {
      _samenstelling = nieuweSamenstelling;
    });
  }

  void _reset() {
    setState(() {
      _samenstelling = OpmetingKaderSamenstelling.basis(
        breedteMm: 1000,
        hoogteMm: 2200,
        slagLinksMm: 20,
        slagRechtsMm: 20,
        slagBovenMm: 20,
        slagOnderMm: 20,
      );
    });
  }

  void _voorbeeldZijraamRechts() {
    final basis = OpmetingKaderSamenstelling.basis(
      breedteMm: 1000,
      hoogteMm: 2200,
      slagLinksMm: 20,
      slagRechtsMm: 20,
      slagBovenMm: 20,
      slagOnderMm: 20,
    );

    final zijraam = OpmetingKaderDeel(
      id: 'kader_zijraam_rechts',
      naam: 'Zijraam rechts',
      breedteMm: 450,
      hoogteMm: 2200,
    );

    final kaders = OpmetingKaderSamenstellingLayoutHelper.voegKaderToe(
      bestaandeKaders: basis.kaders,
      nieuwKader: zijraam,
      gekoppeldAanKaderId: basis.kaders.first.id,
      zijde: OpmetingKaderZijde.rechts,
      uitlijning: OpmetingKaderUitlijning.begin,
    );

    setState(() {
      _samenstelling = basis.copyWith(
        kaders: kaders,
        actiefKaderId: zijraam.id,
      );
    });
  }

  void _voorbeeldBovenlicht() {
    final basis = OpmetingKaderSamenstelling.basis(
      breedteMm: 1000,
      hoogteMm: 2200,
      slagLinksMm: 20,
      slagRechtsMm: 20,
      slagBovenMm: 20,
      slagOnderMm: 20,
    );

    final bovenlicht = OpmetingKaderDeel(
      id: 'kader_bovenlicht',
      naam: 'Bovenlicht',
      breedteMm: 1000,
      hoogteMm: 450,
    );

    final kaders = OpmetingKaderSamenstellingLayoutHelper.voegKaderToe(
      bestaandeKaders: basis.kaders,
      nieuwKader: bovenlicht,
      gekoppeldAanKaderId: basis.kaders.first.id,
      zijde: OpmetingKaderZijde.boven,
      uitlijning: OpmetingKaderUitlijning.begin,
    );

    setState(() {
      _samenstelling = basis.copyWith(
        kaders: kaders,
        actiefKaderId: bovenlicht.id,
      );
    });
  }

  void _voorbeeldVoordeurMetLinksRechtsEnBoven() {
    final basis = OpmetingKaderSamenstelling.basis(
      breedteMm: 1000,
      hoogteMm: 2200,
      slagLinksMm: 20,
      slagRechtsMm: 20,
      slagBovenMm: 20,
      slagOnderMm: 20,
    );

    final links = OpmetingKaderDeel(
      id: 'kader_links',
      naam: 'Zijraam links',
      breedteMm: 400,
      hoogteMm: 2200,
    );

    final rechts = OpmetingKaderDeel(
      id: 'kader_rechts',
      naam: 'Zijraam rechts',
      breedteMm: 400,
      hoogteMm: 2200,
    );

    final boven = OpmetingKaderDeel(
      id: 'kader_boven',
      naam: 'Bovenlicht',
      breedteMm: 1800,
      hoogteMm: 400,
    );

    var kaders = OpmetingKaderSamenstellingLayoutHelper.voegKaderToe(
      bestaandeKaders: basis.kaders,
      nieuwKader: links,
      gekoppeldAanKaderId: basis.kaders.first.id,
      zijde: OpmetingKaderZijde.links,
      uitlijning: OpmetingKaderUitlijning.begin,
    );

    final deurKaderId = basis.kaders.first.id;

    kaders = OpmetingKaderSamenstellingLayoutHelper.voegKaderToe(
      bestaandeKaders: kaders,
      nieuwKader: rechts,
      gekoppeldAanKaderId: deurKaderId,
      zijde: OpmetingKaderZijde.rechts,
      uitlijning: OpmetingKaderUitlijning.begin,
    );

    final linkerKaderId = links.id;

    kaders = OpmetingKaderSamenstellingLayoutHelper.voegKaderToe(
      bestaandeKaders: kaders,
      nieuwKader: boven,
      gekoppeldAanKaderId: linkerKaderId,
      zijde: OpmetingKaderZijde.boven,
      uitlijning: OpmetingKaderUitlijning.begin,
    );

    setState(() {
      _samenstelling = basis.copyWith(
        kaders: kaders,
        actiefKaderId: deurKaderId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final layout = OpmetingKaderSamenstellingLayoutHelper.bereken(
      kaders: _samenstelling.kaders,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: groen,
        foregroundColor: Colors.white,
        title: const Text(
          'Test kadersamenstelling',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Reset',
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          OpmetingKaderSamenstellingBeheer(
            samenstelling: _samenstelling,
            onGewijzigd: _wijzigSamenstelling,
          ),
          const SizedBox(height: 12),
          _bouwVoorbeeldenKaart(),
          const SizedBox(height: 12),
          _bouwDetailsKaart(
            layoutBreedteMm: layout.breedteMm,
            layoutHoogteMm: layout.hoogteMm,
          ),
        ],
      ),
    );
  }

  Widget _bouwVoorbeeldenKaart() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: rand),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Snelle voorbeelden',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: _voorbeeldZijraamRechts,
                  child: const Text('Zijraam rechts'),
                ),
                OutlinedButton(
                  onPressed: _voorbeeldBovenlicht,
                  child: const Text('Bovenlicht'),
                ),
                OutlinedButton(
                  onPressed: _voorbeeldVoordeurMetLinksRechtsEnBoven,
                  child: const Text('Deur + links/rechts/boven'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bouwDetailsKaart({
    required int layoutBreedteMm,
    required int layoutHoogteMm,
  }) {
    final actiefKader = _samenstelling.actiefKader;

    final totaleBreedteMetSlag =
        OpmetingKaderSamenstellingLayoutHelper.totaleBreedteMetSlag(
          samenstellingBreedteMm: layoutBreedteMm,
          slagLinksMm: _samenstelling.slagLinksMm,
          slagRechtsMm: _samenstelling.slagRechtsMm,
        );

    final totaleHoogteMetSlag =
        OpmetingKaderSamenstellingLayoutHelper.totaleHoogteMetSlag(
          samenstellingHoogteMm: layoutHoogteMm,
          slagBovenMm: _samenstelling.slagBovenMm,
          slagOnderMm: _samenstelling.slagOnderMm,
        );

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: rand),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Controle',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 10),
            _bouwControleRegel(
              label: 'Aantal kaders',
              waarde: _samenstelling.kaders.length.toString(),
            ),
            _bouwControleRegel(
              label: 'Samenstelling',
              waarde: '$layoutBreedteMm × $layoutHoogteMm mm',
            ),
            _bouwControleRegel(
              label: 'Met slag',
              waarde: '$totaleBreedteMetSlag × $totaleHoogteMetSlag mm',
            ),
            _bouwControleRegel(
              label: 'Actief kader',
              waarde: actiefKader == null
                  ? 'Geen'
                  : '${actiefKader.naam} '
                        '${actiefKader.breedteMm} × '
                        '${actiefKader.hoogteMm} mm',
            ),
            const SizedBox(height: 10),
            const Text(
              'Tik op een kader in de preview om dit kader actief te maken. '
              'Met + voeg je een kader toe aan links, rechts, boven of onder. '
              'Met het vuilbakje verwijder je het actieve kader.',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bouwControleRegel({required String label, required String waarde}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            waarde,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
