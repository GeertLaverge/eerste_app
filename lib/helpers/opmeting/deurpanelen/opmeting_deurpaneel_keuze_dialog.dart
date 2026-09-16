// THIMACO-CONTROLE: SUBMENU-SELECTIESTIJL-FASE2-20260914
import 'package:flutter/material.dart';

import '../../ui/thimaco_huisstijl.dart';
import 'opmeting_deurpaneel_bibliotheek.dart' as panelen_bibliotheek;
import 'opmeting_deurpaneel_filter_helper.dart';
import 'opmeting_deurpaneel_model.dart';

class OpmetingDeurpaneelKeuzeDialog extends StatefulWidget {
  const OpmetingDeurpaneelKeuzeDialog({
    super.key,
    this.beginUitvoering = OpmetingDeurpaneelUitvoering.nietVleugelOverdekkend,
  });

  final OpmetingDeurpaneelUitvoering beginUitvoering;

  @override
  State<OpmetingDeurpaneelKeuzeDialog> createState() {
    return _OpmetingDeurpaneelKeuzeDialogState();
  }
}

class _OpmetingDeurpaneelKeuzeDialogState
    extends State<OpmetingDeurpaneelKeuzeDialog> {
  static const Color groen = ThimacoKleuren.oranje;
  static const Color rand = ThimacoKleuren.rand;
  static const Color tekstDonker = ThimacoKleuren.antraciet;
  static const Color tekstGrijs = ThimacoKleuren.tekstGrijs;

  final TextEditingController _zoekController = TextEditingController();

  late OpmetingDeurpaneelUitvoering _uitvoering;
  String _zoekTekst = '';
  bool _laden = true;

  @override
  void initState() {
    super.initState();
    _uitvoering = widget.beginUitvoering;
    _laadPanelen();
  }

  Future<void> _laadPanelen() async {
    setState(() {
      _laden = true;
    });

    try {
      await panelen_bibliotheek.OpmetingDeurpaneelBibliotheek.laad();
    } finally {
      if (mounted) {
        setState(() {
          _laden = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _zoekController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(18),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: ThimacoKleuren.rand),
      ),
      titlePadding: const EdgeInsets.fromLTRB(18, 16, 12, 0),
      contentPadding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      actionsPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      title: Row(
        children: [
          const Expanded(
            child: ThimacoSectieTitel(
              tekst: 'Deurpaneel kiezen',
              compact: false,
            ),
          ),
          ThimacoIcoonActie(
            icoon: Icons.close_rounded,
            tooltip: 'Sluiten',
            onPressed: () {
              Navigator.pop(context);
            },
            grootte: 19,
          ),
        ],
      ),
      content: SizedBox(
        width: 720,
        height: 520,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _bouwUitlegBlok(),
            const SizedBox(height: 12),
            _bouwUitvoeringKeuze(),
            const SizedBox(height: 10),
            _bouwZoekveld(),
            const SizedBox(height: 10),
            if (_laden)
              const Expanded(
                child: Center(child: CircularProgressIndicator(color: groen)),
              )
            else
              Expanded(child: _bouwPanelenLijst()),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
          onPressed: () {
            Navigator.pop(context, OpmetingDeurpaneelKeuze.wissen());
          },
          icon: const Icon(Icons.delete_outline, size: 18),
          label: const Text('Paneel wissen'),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: tekstGrijs),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Annuleren'),
        ),
      ],
    );
  }

  Widget _bouwUitlegBlok() {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: ThimacoKleuren.achtergrond,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: rand),
      ),
      child: const Text(
        'Kies eerst de uitvoering. De lijst toont daarna alleen panelen die volgens de centrale panelenlijst toegelaten zijn. Beheer gebeurt via Home > Instellingen > Deurpanelen.',
        style: TextStyle(
          color: tekstDonker,
          fontSize: 12,
          height: 1.25,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _bouwUitvoeringKeuze() {
    return Row(
      children: [
        Expanded(
          child: _bouwUitvoeringKnop(
            uitvoering: OpmetingDeurpaneelUitvoering.nietVleugelOverdekkend,
            titel: 'Niet vleugeloverdekkend',
            uitleg: 'Vanaf binnenlijn. Vleugel blijft zichtbaar.',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _bouwUitvoeringKnop(
            uitvoering: OpmetingDeurpaneelUitvoering.vleugelOverdekkend,
            titel: 'Vleugeloverdekkend',
            uitleg: 'Vanaf buitenlijn. Vleugel wordt afgedekt.',
          ),
        ),
      ],
    );
  }

  Widget _bouwUitvoeringKnop({
    required OpmetingDeurpaneelUitvoering uitvoering,
    required String titel,
    required String uitleg,
  }) {
    final actief = _uitvoering == uitvoering;

    return ThimacoTekstKeuze(
      tekst: titel,
      subtekst: uitleg,
      geselecteerd: actief,
      uitvullen: true,
      compact: false,
      onPressed: () {
        setState(() {
          _uitvoering = uitvoering;
        });
      },
    );
  }

  Widget _bouwZoekveld() {
    return TextField(
      controller: _zoekController,
      decoration: const InputDecoration(
        isDense: true,
        prefixIcon: Icon(Icons.search_rounded),
        labelText: 'Zoeken op ID, naam of DXF',
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: groen, width: 1.5),
        ),
      ),
      onChanged: (waarde) {
        setState(() {
          _zoekTekst = waarde.trim().toLowerCase();
        });
      },
    );
  }

  Widget _bouwPanelenLijst() {
    return ValueListenableBuilder<List<OpmetingDeurpaneel>>(
      valueListenable:
          panelen_bibliotheek.OpmetingDeurpaneelBibliotheek.panelen,
      builder: (context, panelen, _) {
        final gefilterd = OpmetingDeurpaneelFilterHelper.filterVoorKeuze(
          panelen: panelen,
          uitvoering: _uitvoering,
          zoekTekst: _zoekTekst,
        );

        if (gefilterd.isEmpty) {
          return const Center(
            child: Text(
              'Geen deurpanelen gevonden voor deze uitvoering.',
              style: TextStyle(color: tekstGrijs, fontWeight: FontWeight.w600),
            ),
          );
        }

        return ListView.separated(
          itemCount: gefilterd.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return _bouwPaneelKaart(gefilterd[index]);
          },
        );
      },
    );
  }

  Widget _bouwPaneelKaart(OpmetingDeurpaneel paneel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rand),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        leading: Container(
          width: 54,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ThimacoKleuren.achtergrond,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: rand),
          ),
          child: Text(
            paneel.id,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: groen,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        title: Text(
          paneel.naam,
          style: const TextStyle(
            color: tekstDonker,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${paneel.tekeningBestandsnaam} · ${paneel.typeLabel} · Cilinder: ${paneel.cilinderZijde.label}',
            style: const TextStyle(color: tekstGrijs, fontSize: 12),
          ),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: groen,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(
              context,
              OpmetingDeurpaneelKeuze(paneel: paneel, uitvoering: _uitvoering),
            );
          },
          child: const Text('Kiezen'),
        ),
      ),
    );
  }
}
