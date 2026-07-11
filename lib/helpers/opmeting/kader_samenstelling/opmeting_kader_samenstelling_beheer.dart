import 'package:flutter/material.dart';

import 'opmeting_kader_samenstelling_layout_helper.dart';
import 'opmeting_kader_samenstelling_model.dart';
import 'opmeting_kader_samenstelling_preview.dart';
import 'opmeting_kader_toevoegen_dialoog.dart';

class OpmetingKaderSamenstellingBeheer extends StatelessWidget {
  const OpmetingKaderSamenstellingBeheer({
    super.key,
    required this.samenstelling,
    required this.onGewijzigd,
    this.bewerkenToegestaan = true,
  });

  final OpmetingKaderSamenstelling samenstelling;
  final ValueChanged<OpmetingKaderSamenstelling> onGewijzigd;
  final bool bewerkenToegestaan;

  static const Color groen = Color(0xFF0B7A3B);
  static const Color rand = Color(0xFFE5E7EB);
  static const Color tekstGrijs = Color(0xFF6B7280);

  OpmetingKaderDeel? get _actiefKader {
    return samenstelling.actiefKader;
  }

  @override
  Widget build(BuildContext context) {
    final layout = OpmetingKaderSamenstellingLayoutHelper.bereken(
      kaders: samenstelling.kaders,
    );

    final actiefKader = _actiefKader;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: rand),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _bouwTitelRij(context),
            const SizedBox(height: 8),
            OpmetingKaderSamenstellingPreview(
              kaders: samenstelling.kaders,
              actiefKaderId: samenstelling.actiefKaderId,
              hoogte: 170,
              toonMaten: true,
              onKaderGekozen: (kader) {
                _kiesKader(kader);
              },
            ),
            const SizedBox(height: 8),
            _bouwMaatInfo(
              layoutBreedteMm: layout.breedteMm,
              layoutHoogteMm: layout.hoogteMm,
            ),
            if (actiefKader != null) ...[
              const SizedBox(height: 8),
              _bouwActiefKaderInfo(actiefKader),
            ],
          ],
        ),
      ),
    );
  }

  Widget _bouwTitelRij(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Kadersamenstelling',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ),
        SizedBox(
          width: 34,
          height: 34,
          child: IconButton(
            tooltip: 'Kader toevoegen',
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed: bewerkenToegestaan
                ? () {
                    _voegKaderToe(context);
                  }
                : null,
            icon: const Icon(Icons.add_box_outlined, size: 21, color: groen),
          ),
        ),
        SizedBox(
          width: 34,
          height: 34,
          child: IconButton(
            tooltip: 'Actief kader verwijderen',
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed: bewerkenToegestaan && samenstelling.kaders.length > 1
                ? () {
                    _verwijderActiefKader(context);
                  }
                : null,
            icon: Icon(
              Icons.delete_outline,
              size: 21,
              color: bewerkenToegestaan && samenstelling.kaders.length > 1
                  ? Colors.red
                  : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bouwMaatInfo({
    required int layoutBreedteMm,
    required int layoutHoogteMm,
  }) {
    final totaleBreedteMetSlag =
        OpmetingKaderSamenstellingLayoutHelper.totaleBreedteMetSlag(
          samenstellingBreedteMm: layoutBreedteMm,
          slagLinksMm: samenstelling.slagLinksMm,
          slagRechtsMm: samenstelling.slagRechtsMm,
        );

    final totaleHoogteMetSlag =
        OpmetingKaderSamenstellingLayoutHelper.totaleHoogteMetSlag(
          samenstellingHoogteMm: layoutHoogteMm,
          slagBovenMm: samenstelling.slagBovenMm,
          slagOnderMm: samenstelling.slagOnderMm,
        );

    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: rand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _bouwInfoRegel(
            label: 'Samenstelling',
            waarde: '$layoutBreedteMm × $layoutHoogteMm mm',
          ),
          const SizedBox(height: 4),
          _bouwInfoRegel(
            label: 'Met slag',
            waarde: '$totaleBreedteMetSlag × $totaleHoogteMetSlag mm',
          ),
        ],
      ),
    );
  }

  Widget _bouwActiefKaderInfo(OpmetingKaderDeel kader) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F6EC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB7E3C6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.crop_square, size: 17, color: groen),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              'Actief kader: ${kader.naam} · '
              '${kader.breedteMm} × ${kader.hoogteMm} mm',
              style: const TextStyle(
                color: Color(0xFF064E3B),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwInfoRegel({required String label, required String waarde}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: tekstGrijs,
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
    );
  }

  void _kiesKader(OpmetingKaderDeel kader) {
    if (kader.id == samenstelling.actiefKaderId) {
      return;
    }

    onGewijzigd(samenstelling.copyWith(actiefKaderId: kader.id));
  }

  Future<void> _voegKaderToe(BuildContext context) async {
    final resultaat = await toonOpmetingKaderToevoegenDialoog(
      context: context,
      bestaandeKaders: samenstelling.kaders,
      actiefKaderId: samenstelling.actiefKaderId,
    );

    if (resultaat == null) {
      return;
    }

    final nieuwKaderId = 'kader_${DateTime.now().microsecondsSinceEpoch}';

    final nieuwKader = OpmetingKaderDeel(
      id: nieuwKaderId,
      naam: resultaat.naam,
      breedteMm: resultaat.breedteMm,
      hoogteMm: resultaat.hoogteMm,
    );

    final nieuweKaders = OpmetingKaderSamenstellingLayoutHelper.voegKaderToe(
      bestaandeKaders: samenstelling.kaders,
      nieuwKader: nieuwKader,
      gekoppeldAanKaderId: resultaat.gekoppeldAanKaderId,
      zijde: resultaat.zijde,
      uitlijning: resultaat.uitlijning,
      vrijeOffsetMm: resultaat.vrijeOffsetMm,
    );

    onGewijzigd(
      samenstelling.copyWith(kaders: nieuweKaders, actiefKaderId: nieuwKaderId),
    );
  }

  Future<void> _verwijderActiefKader(BuildContext context) async {
    final actiefKader = _actiefKader;

    if (actiefKader == null) {
      return;
    }

    if (samenstelling.kaders.length <= 1) {
      _toonMelding(
        context,
        'Er moet minstens één kader behouden blijven.',
        fout: true,
      );

      return;
    }

    final meeTeVerwijderenIds = _zoekAfhankelijkeKaders(
      teVerwijderenKaderId: actiefKader.id,
    );

    final aantalMeeTeVerwijderen = meeTeVerwijderenIds.length - 1;

    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Kader verwijderen?'),
          content: Text(
            aantalMeeTeVerwijderen > 0
                ? 'Het kader “${actiefKader.naam}” wordt verwijderd.\n\n'
                      'Er zijn ook $aantalMeeTeVerwijderen gekoppelde '
                      'kader(s) die aan dit kader vasthangen. '
                      'Deze worden mee verwijderd.'
                : 'Het kader “${actiefKader.naam}” wordt verwijderd.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Annuleren'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Verwijderen'),
            ),
          ],
        );
      },
    );

    if (bevestigen != true) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    final resterendeKaders = samenstelling.kaders.where((kader) {
      return !meeTeVerwijderenIds.contains(kader.id);
    }).toList();

    if (resterendeKaders.isEmpty) {
      _toonMelding(
        context,
        'Dit kader kan niet verwijderd worden omdat er geen kader overblijft.',
        fout: true,
      );

      return;
    }

    final herberekendeKaders =
        OpmetingKaderSamenstellingLayoutHelper.herberekenGekoppeldeKaders(
          kaders: resterendeKaders,
        );

    final nieuwActiefKaderId = herberekendeKaders.isNotEmpty
        ? herberekendeKaders.first.id
        : '';

    onGewijzigd(
      samenstelling.copyWith(
        kaders: herberekendeKaders,
        actiefKaderId: nieuwActiefKaderId,
      ),
    );
  }

  Set<String> _zoekAfhankelijkeKaders({required String teVerwijderenKaderId}) {
    final ids = <String>{teVerwijderenKaderId};

    var gewijzigd = true;

    while (gewijzigd) {
      gewijzigd = false;

      for (final kader in samenstelling.kaders) {
        final gekoppeldAan = kader.gekoppeldAanKaderId ?? '';

        if (gekoppeldAan.isEmpty) {
          continue;
        }

        if (!ids.contains(gekoppeldAan)) {
          continue;
        }

        if (ids.add(kader.id)) {
          gewijzigd = true;
        }
      }
    }

    return ids;
  }

  void _toonMelding(BuildContext context, String tekst, {bool fout = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tekst),
        backgroundColor: fout ? const Color(0xFFDC2626) : groen,
      ),
    );
  }
}
