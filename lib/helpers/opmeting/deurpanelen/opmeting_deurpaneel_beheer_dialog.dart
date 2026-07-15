import 'package:flutter/material.dart';

import 'opmeting_deurpaneel_bibliotheek.dart' as panelen_bibliotheek;
import 'opmeting_deurpaneel_dxf_bibliotheek.dart' as dxf_bibliotheek;
import 'opmeting_deurpaneel_filter_helper.dart';
import 'opmeting_deurpaneel_import_helper.dart';
import 'opmeting_deurpaneel_model.dart';

class OpmetingDeurpaneelBeheerDialog extends StatefulWidget {
  const OpmetingDeurpaneelBeheerDialog({super.key});

  @override
  State<OpmetingDeurpaneelBeheerDialog> createState() {
    return _OpmetingDeurpaneelBeheerDialogState();
  }
}

class _OpmetingDeurpaneelBeheerDialogState
    extends State<OpmetingDeurpaneelBeheerDialog> {
  static const Color groen = Color(0xFF0B7A3B);
  static const Color lichtGroen = Color(0xFFE7F6EC);
  static const Color rand = Color(0xFFE5E7EB);
  static const Color tekstDonker = Color(0xFF111827);
  static const Color tekstGrijs = Color(0xFF6B7280);

  final TextEditingController _zoekController = TextEditingController();

  String _zoekTekst = '';
  bool _toonInactievePanelen = true;
  bool _laden = true;
  bool _bewaren = false;

  @override
  void initState() {
    super.initState();
    _laadPanelen();
  }

  Future<void> _laadPanelen() async {
    setState(() {
      _laden = true;
    });

    try {
      await panelen_bibliotheek.OpmetingDeurpaneelBibliotheek.laad();
      await dxf_bibliotheek.OpmetingDeurpaneelDxfBibliotheek.laad();
    } catch (_) {
      if (mounted) {
        _toonMelding('Deurpanelen konden niet worden geladen.', fout: true);
      }
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(18, 16, 12, 0),
      contentPadding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      actionsPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      title: Row(
        children: [
          const Expanded(
            child: Text(
              'Deurpanelen beheren',
              style: TextStyle(color: groen, fontWeight: FontWeight.w900),
            ),
          ),
          IconButton(
            tooltip: 'Sluiten',
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      content: SizedBox(
        width: 760,
        height: 560,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _bouwUitlegBlok(),
            const SizedBox(height: 10),
            _bouwZoekEnActies(),
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
        TextButton(
          style: TextButton.styleFrom(foregroundColor: tekstGrijs),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Sluiten'),
        ),
      ],
    );
  }

  Widget _bouwUitlegBlok() {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: lichtGroen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCDEBD6)),
      ),
      child: const Text(
        'Beheer hier centraal de panelenlijst en de bijhorende DXF-tekeningen van de leverancier. De Excel-lijst bepaalt welk paneel welke tekening gebruikt; via DXF plakken laad je de originele tekening onder dezelfde bestandsnaam in.',
        style: TextStyle(
          color: tekstDonker,
          fontSize: 12,
          height: 1.25,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _bouwZoekEnActies() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _zoekController,
            decoration: const InputDecoration(
              isDense: true,
              prefixIcon: Icon(Icons.search_rounded),
              labelText: 'Zoeken op ID, naam of DXF',
              border: OutlineInputBorder(),
            ),
            onChanged: (waarde) {
              setState(() {
                _zoekTekst = waarde.trim().toLowerCase();
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(foregroundColor: groen),
          onPressed: _openExcelPlakDialog,
          icon: const Icon(Icons.table_chart_outlined, size: 18),
          label: const Text('Excel plakken'),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(foregroundColor: groen),
          onPressed: _openDxfPlakDialog,
          icon: const Icon(Icons.description_outlined, size: 18),
          label: const Text('DXF plakken'),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          tooltip: 'Meer opties',
          onSelected: (actie) {
            if (actie == 'toon_inactief') {
              setState(() {
                _toonInactievePanelen = !_toonInactievePanelen;
              });
            } else if (actie == 'reset') {
              _resetNaarTestPanelen();
            } else if (actie == 'test_dxf') {
              _laadTestDxfBestanden();
            } else if (actie == 'wis_dxf') {
              _wisDxfBestanden();
            }
          },
          itemBuilder: (context) {
            return [
              PopupMenuItem<String>(
                value: 'toon_inactief',
                child: Text(
                  _toonInactievePanelen
                      ? 'Inactieve panelen verbergen'
                      : 'Inactieve panelen tonen',
                ),
              ),
              const PopupMenuItem<String>(
                value: 'reset',
                child: Text('Testlijst terugzetten'),
              ),
              const PopupMenuItem<String>(
                value: 'test_dxf',
                child: Text('Test-DXF’s laden'),
              ),
              const PopupMenuItem<String>(
                value: 'wis_dxf',
                child: Text('Alle DXF’s wissen'),
              ),
            ];
          },
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              border: Border.all(color: rand),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.more_vert_rounded),
          ),
        ),
      ],
    );
  }

  Widget _bouwPanelenLijst() {
    return ValueListenableBuilder<List<OpmetingDeurpaneel>>(
      valueListenable:
          panelen_bibliotheek.OpmetingDeurpaneelBibliotheek.panelen,
      builder: (context, panelen, _) {
        final gefilterd = OpmetingDeurpaneelFilterHelper.filterVoorBeheer(
          panelen: panelen,
          zoekTekst: _zoekTekst,
          toonInactievePanelen: _toonInactievePanelen,
        );

        if (gefilterd.isEmpty) {
          return const Center(
            child: Text(
              'Geen deurpanelen gevonden.',
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
    final dxfStatus =
        dxf_bibliotheek.OpmetingDeurpaneelDxfBibliotheek.statusVoorBestandsnaam(
          paneel.tekeningBestandsnaam,
        );

    return Container(
      decoration: BoxDecoration(
        color: paneel.actief ? Colors.white : const Color(0xFFF9FAFB),
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
            color: lichtGroen,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFCDEBD6)),
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
          style: TextStyle(
            color: paneel.actief ? tekstDonker : tekstGrijs,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${paneel.tekeningBestandsnaam} · ${paneel.typeLabel} · Cilinder: ${paneel.cilinderZijde.label} · $dxfStatus',
            style: const TextStyle(color: tekstGrijs, fontSize: 12),
          ),
        ),
        trailing: IconButton(
          tooltip: paneel.actief ? 'Paneel deactiveren' : 'Paneel activeren',
          onPressed: _bewaren
              ? null
              : () {
                  _wisselPaneelActief(paneel);
                },
          icon: Icon(
            paneel.actief
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: paneel.actief ? groen : tekstGrijs,
          ),
        ),
      ),
    );
  }

  Future<void> _openDxfPlakDialog() async {
    final resultaat = await showDialog<_DxfPlakResultaat>(
      context: context,
      builder: (dialogContext) {
        return const _DeurpaneelDxfPlakDialog();
      },
    );

    if (resultaat == null ||
        resultaat.bestandsnaam.trim().isEmpty ||
        resultaat.inhoud.trim().isEmpty) {
      return;
    }

    await _voerBewaarActieUit(
      actie: () {
        return dxf_bibliotheek.OpmetingDeurpaneelDxfBibliotheek.bewaarDxf(
          bestandsnaam: resultaat.bestandsnaam,
          inhoud: resultaat.inhoud,
        );
      },
      melding: 'DXF ${resultaat.bestandsnaam.trim()} ingeladen.',
    );
  }

  Future<void> _laadTestDxfBestanden() async {
    await _voerBewaarActieUit(
      actie: dxf_bibliotheek.OpmetingDeurpaneelDxfBibliotheek.laadTestBestanden,
      melding: 'Test-DXF’s ingeladen.',
    );
  }

  Future<void> _wisDxfBestanden() async {
    final wissen = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Alle DXF’s wissen?',
            style: TextStyle(color: groen, fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'Hiermee wis je enkel de ingeladen DXF-tekeningen. De Excel-lijst met panelen blijft behouden.',
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: tekstGrijs),
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Annuleren'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Wissen'),
            ),
          ],
        );
      },
    );

    if (wissen != true) {
      return;
    }

    await _voerBewaarActieUit(
      actie: dxf_bibliotheek.OpmetingDeurpaneelDxfBibliotheek.wisAlleDxfs,
      melding: 'Alle DXF’s gewist.',
    );
  }

  Future<void> _openExcelPlakDialog() async {
    final tekst = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return const _DeurpaneelExcelPlakDialog();
      },
    );

    if (tekst == null || tekst.trim().isEmpty) {
      return;
    }

    final panelen = OpmetingDeurpaneelImportHelper.leesExcelPlakTekst(tekst);

    if (!mounted) {
      return;
    }

    if (panelen.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Geen geldige deurpanelen gevonden in de geplakte lijst.',
          ),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    await _voerBewaarActieUit(
      actie: () {
        return panelen_bibliotheek.OpmetingDeurpaneelBibliotheek.vervangPanelen(
          panelen,
        );
      },
      melding:
          '${panelen.length} deurpaneel${panelen.length == 1 ? '' : 'en'} ingeladen.',
    );
  }

  Future<void> _resetNaarTestPanelen() async {
    await _voerBewaarActieUit(
      actie: panelen_bibliotheek
          .OpmetingDeurpaneelBibliotheek
          .resetNaarTestPanelen,
      melding: 'Testlijst deurpanelen teruggezet.',
    );
  }

  Future<void> _wisselPaneelActief(OpmetingDeurpaneel paneel) async {
    await _voerBewaarActieUit(
      actie: () {
        return panelen_bibliotheek.OpmetingDeurpaneelBibliotheek.wisselActief(
          paneel.id,
        );
      },
      melding: paneel.actief
          ? '${paneel.naam} gedeactiveerd.'
          : '${paneel.naam} geactiveerd.',
    );
  }

  Future<void> _voerBewaarActieUit({
    required Future<void> Function() actie,
    required String melding,
  }) async {
    if (_bewaren) {
      return;
    }

    setState(() {
      _bewaren = true;
    });

    try {
      await actie();

      if (mounted) {
        _toonMelding(melding);
      }
    } catch (_) {
      if (mounted) {
        _toonMelding(
          'Deurpanelen of DXF’s konden niet worden bewaard.',
          fout: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _bewaren = false;
        });
      }
    }
  }

  void _toonMelding(String tekst, {bool fout = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tekst),
        backgroundColor: fout ? const Color(0xFFDC2626) : groen,
      ),
    );
  }
}

class _DxfPlakResultaat {
  const _DxfPlakResultaat({required this.bestandsnaam, required this.inhoud});

  final String bestandsnaam;
  final String inhoud;
}

class _DeurpaneelDxfPlakDialog extends StatefulWidget {
  const _DeurpaneelDxfPlakDialog();

  @override
  State<_DeurpaneelDxfPlakDialog> createState() {
    return _DeurpaneelDxfPlakDialogState();
  }
}

class _DeurpaneelDxfPlakDialogState extends State<_DeurpaneelDxfPlakDialog> {
  static const Color groen = Color(0xFF0B7A3B);
  static const Color tekstGrijs = Color(0xFF6B7280);

  late final TextEditingController _bestandsnaamController;
  late final TextEditingController _inhoudController;

  @override
  void initState() {
    super.initState();
    _bestandsnaamController = TextEditingController();
    _inhoudController = TextEditingController();
  }

  @override
  void dispose() {
    _bestandsnaamController.dispose();
    _inhoudController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'DXF-tekening plakken',
        style: TextStyle(color: groen, fontWeight: FontWeight.w900),
      ),
      content: SizedBox(
        width: 720,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Gebruik exact dezelfde bestandsnaam als in de kolom Tekening van de Excel-lijst.',
              style: TextStyle(
                color: tekstGrijs,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bestandsnaamController,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                labelText: 'Bestandsnaam, bv. LD1211AN.dxf',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _inhoudController,
              maxLines: 16,
              decoration: const InputDecoration(
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
                labelText: 'Plak hier de volledige DXF-inhoud',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: tekstGrijs),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Annuleren'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: groen,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(
              context,
              _DxfPlakResultaat(
                bestandsnaam: _bestandsnaamController.text.trim(),
                inhoud: _inhoudController.text,
              ),
            );
          },
          child: const Text('DXF bewaren'),
        ),
      ],
    );
  }
}

class _DeurpaneelExcelPlakDialog extends StatefulWidget {
  const _DeurpaneelExcelPlakDialog();

  @override
  State<_DeurpaneelExcelPlakDialog> createState() {
    return _DeurpaneelExcelPlakDialogState();
  }
}

class _DeurpaneelExcelPlakDialogState
    extends State<_DeurpaneelExcelPlakDialog> {
  static const Color groen = Color(0xFF0B7A3B);
  static const Color tekstGrijs = Color(0xFF6B7280);

  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text:
          'ID\tNaam\tTekening\tType\tCilinder\n'
          'MI251\tJEF\tMI2510BN.dxf\tVleugel\tRechts\n'
          'LD121\tHERMITAGE\tLD1211AN.dxf\tBeide\t\n'
          'VF011\tVEDUDO\tVF0110BN.dxf\tNiet-vleugel\t',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Excel-lijst plakken',
        style: TextStyle(color: groen, fontWeight: FontWeight.w900),
      ),
      content: SizedBox(
        width: 620,
        child: TextField(
          controller: _controller,
          maxLines: 12,
          decoration: const InputDecoration(
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
            labelText: 'Plak hier de rijen uit Excel',
            helperText: 'Kolommen: ID, Naam, Tekening, Type, Cilinder',
          ),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: tekstGrijs),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Annuleren'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: groen,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context, _controller.text);
          },
          child: const Text('Importeren'),
        ),
      ],
    );
  }
}
