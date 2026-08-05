// THIMACO-CONTROLE: ALGEMENE-OPMETING-AANKOOP-VERKOOP-EN-VRIJE-PRIJS-20260802
import 'package:flutter/material.dart';

import '../../offerte/prijzen/offerte_prijs_categorie.dart';
import '../../offerte/prijzen/offerte_prijs_eenheid.dart';
import '../../offerte/prijzen/offerte_prijsregel_model.dart';
import '../../../paginas/instellingen/offerte_prijzen/offerte_prijsregel_dialog.dart';
import 'opmeting_algemene_opmeting_blok_model.dart';
import 'opmeting_algemene_opmeting_model.dart';

class OpmetingAlgemeneOpmetingRechterkolom extends StatefulWidget {
  const OpmetingAlgemeneOpmetingRechterkolom({
    super.key,
    required this.model,
    required this.prijsregels,
    required this.onPrijsregelsBewaren,
    required this.onGewijzigd,
  });

  final OpmetingAlgemeneOpmetingModel model;
  final List<OffertePrijsregelModel> prijsregels;
  final Future<void> Function(List<OffertePrijsregelModel> prijsregels)
  onPrijsregelsBewaren;
  final ValueChanged<OpmetingAlgemeneOpmetingModel> onGewijzigd;

  @override
  State<OpmetingAlgemeneOpmetingRechterkolom> createState() =>
      _OpmetingAlgemeneOpmetingRechterkolomState();
}

class _OpmetingAlgemeneOpmetingRechterkolomState
    extends State<OpmetingAlgemeneOpmetingRechterkolom> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);

  late final TextEditingController _titelController;

  @override
  void initState() {
    super.initState();
    _titelController = TextEditingController(text: widget.model.titel);
  }

  @override
  void didUpdateWidget(
    covariant OpmetingAlgemeneOpmetingRechterkolom oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (widget.model.titel != _titelController.text) {
      _titelController.value = TextEditingValue(
        text: widget.model.titel,
        selection: TextSelection.collapsed(offset: widget.model.titel.length),
      );
    }
  }

  @override
  void dispose() {
    _titelController.dispose();
    super.dispose();
  }

  List<OffertePrijsregelModel> get _beschikbarePrijsregels {
    final regels = widget.prijsregels
        .where(
          (regel) =>
              regel.actief &&
              regel.isGeldig &&
              regel.categorie == OffertePrijsCategorie.vrijPerArtikel,
        )
        .toList(growable: false);

    regels.sort((eerste, tweede) {
      final volgorde = eerste.volgorde.compareTo(tweede.volgorde);
      if (volgorde != 0) return volgorde;
      return eerste.omschrijving.toLowerCase().compareTo(
        tweede.omschrijving.toLowerCase(),
      );
    });
    return regels;
  }

  void _wijzigTitel(String waarde) {
    widget.onGewijzigd(widget.model.copyWith(titel: waarde));
  }

  void _voegBlokToe(OpmetingAlgemeneOpmetingBlok blok) {
    widget.onGewijzigd(
      widget.model.copyWith(
        blokken: List<OpmetingAlgemeneOpmetingBlok>.unmodifiable(
          <OpmetingAlgemeneOpmetingBlok>[...widget.model.blokken, blok],
        ),
      ),
    );
  }

  void _voegBlokkenToe(List<OpmetingAlgemeneOpmetingBlok> blokken) {
    if (blokken.isEmpty) return;
    widget.onGewijzigd(
      widget.model.copyWith(
        blokken: List<OpmetingAlgemeneOpmetingBlok>.unmodifiable(
          <OpmetingAlgemeneOpmetingBlok>[...widget.model.blokken, ...blokken],
        ),
      ),
    );
  }

  void _wijzigBlok(OpmetingAlgemeneOpmetingBlok gewijzigdBlok) {
    final lijst = List<OpmetingAlgemeneOpmetingBlok>.from(widget.model.blokken);
    final index = lijst.indexWhere((blok) => blok.id == gewijzigdBlok.id);
    if (index < 0) return;
    lijst[index] = gewijzigdBlok;
    widget.onGewijzigd(widget.model.copyWith(blokken: lijst));
  }

  void _verwijderBlok(String blokId) {
    final lijst = List<OpmetingAlgemeneOpmetingBlok>.from(widget.model.blokken)
      ..removeWhere((blok) => blok.id == blokId);
    widget.onGewijzigd(widget.model.copyWith(blokken: lijst));
  }

  void _herordenBlokken(int oudIndex, int nieuwIndex) {
    final lijst = List<OpmetingAlgemeneOpmetingBlok>.from(widget.model.blokken);
    if (oudIndex < 0 || oudIndex >= lijst.length) return;

    var doelIndex = nieuwIndex;
    if (doelIndex > oudIndex) doelIndex -= 1;
    if (doelIndex < 0 || doelIndex >= lijst.length) return;

    final blok = lijst.removeAt(oudIndex);
    lijst.insert(doelIndex, blok);
    widget.onGewijzigd(widget.model.copyWith(blokken: lijst));
  }

  String _nieuwBlokId(String soort) {
    return 'algemene_${soort}_${DateTime.now().microsecondsSinceEpoch}';
  }

  Future<void> _openTekstvlak({OpmetingAlgemeneOpmetingBlok? bestaand}) async {
    final beginBlok =
        bestaand ??
        OpmetingAlgemeneOpmetingBlok(
          id: _nieuwBlokId('tekst'),
          type: OpmetingAlgemeneOpmetingBlokType.tekst,
        );

    final resultaat = await showDialog<OpmetingAlgemeneOpmetingBlok>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _AlgemeneTekstvlakDialog(blok: beginBlok);
      },
    );

    if (resultaat == null || !mounted) return;
    if (bestaand == null) {
      _voegBlokToe(resultaat);
    } else {
      _wijzigBlok(resultaat);
    }
  }

  Future<void> _openTekstvlakMetPrijs({
    OpmetingAlgemeneOpmetingBlok? bestaand,
  }) async {
    final beginBlok =
        bestaand ??
        OpmetingAlgemeneOpmetingBlok(
          id: _nieuwBlokId('prijs'),
          type: OpmetingAlgemeneOpmetingBlokType.prijs,
          hoeveelheid: 1,
          eenheid: OpmetingAlgemenePrijsEenheid.stuk,
          toonPrijsOpOfferte: false,
        );

    final resultaat = await showDialog<OpmetingAlgemeneOpmetingBlok>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _AlgemenePrijsblokDialog(blok: beginBlok);
      },
    );

    if (resultaat == null || !mounted) return;
    if (bestaand == null) {
      _voegBlokToe(resultaat);
    } else {
      _wijzigBlok(resultaat);
    }
  }

  // ignore: unused_element
  Future<void> _openVrijePrijsPerArtikel() async {
    final regels = _beschikbarePrijsregels;
    final reedsToegevoegd = widget.model.blokken
        .map((blok) => blok.bronPrijsregelId.trim())
        .where((id) => id.isNotEmpty)
        .toSet();

    final resultaat = await showGeneralDialog<_VrijePrijsPerArtikelResultaat>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Vrije prijs per artikel',
      barrierColor: Colors.black.withValues(alpha: 0.20),
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (dialogContext, animatie, tweedeAnimatie) {
        return _VrijePrijsPerArtikelDialog(
          prijsregels: regels,
          reedsToegevoegdePrijsregelIds: reedsToegevoegd,
        );
      },
      transitionBuilder: (context, animatie, tweedeAnimatie, child) {
        return FadeTransition(opacity: animatie, child: child);
      },
    );

    if (resultaat == null || !mounted) return;

    if (resultaat.bewarenInInstellingen) {
      try {
        await widget.onPrijsregelsBewaren(resultaat.allePrijsregels);
      } catch (fout) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDC2626),
            content: Text('Vrije prijsregels bewaren is niet gelukt: $fout'),
          ),
        );
        return;
      }
    }

    if (!mounted || resultaat.geselecteerdePrijsregels.isEmpty) return;

    final tijd = DateTime.now().microsecondsSinceEpoch;
    final blokken = <OpmetingAlgemeneOpmetingBlok>[];
    for (
      var index = 0;
      index < resultaat.geselecteerdePrijsregels.length;
      index++
    ) {
      final regel = resultaat.geselecteerdePrijsregels[index];
      final eenheid = _mapPrijsEenheid(regel.eenheid);
      blokken.add(
        OpmetingAlgemeneOpmetingBlok(
          id: 'algemene_vrije_prijs_${tijd}_$index',
          type: OpmetingAlgemeneOpmetingBlokType.prijs,
          titel: regel.omschrijving.trim(),
          hoeveelheid: 1,
          eenheid: eenheid,
          eenheidsprijsExclBtw: regel.prijsExclBtw,
          bronPrijsregelId: regel.id,
          prijsSoort: OpmetingAlgemenePrijsSoort.verkoop,
          toonOpOfferte: _toonOmschrijvingOpOfferte(regel),
          toonPrijsOpOfferte: _toonPrijsOpOfferte(regel),
        ),
      );
    }
    _voegBlokkenToe(blokken);
  }

  Future<void> _bewerkBlok(OpmetingAlgemeneOpmetingBlok blok) async {
    if (blok.isPrijs) {
      await _openTekstvlakMetPrijs(bestaand: blok);
    } else {
      await _openTekstvlak(bestaand: blok);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: TextField(
              controller: _titelController,
              onChanged: _wijzigTitel,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(
                color: _tekstDonker,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
              decoration: InputDecoration(
                labelText: 'Titel',
                hintText: 'Bijvoorbeeld: Vervanging gebroken glas',
                prefixIcon: const Icon(Icons.title_rounded, color: _groen),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: const BorderSide(color: _rand),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: const BorderSide(color: _rand),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: const BorderSide(color: _groen, width: 1.5),
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: _rand),
          Expanded(
            child: widget.model.blokken.isEmpty
                ? const SizedBox.expand()
                : ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
                    buildDefaultDragHandles: false,
                    itemCount: widget.model.blokken.length,
                    onReorder: _herordenBlokken,
                    proxyDecorator: (child, index, animatie) {
                      return Material(
                        color: Colors.transparent,
                        elevation: 8,
                        borderRadius: BorderRadius.circular(12),
                        child: child,
                      );
                    },
                    itemBuilder: (context, index) {
                      final blok = widget.model.blokken[index];
                      return Padding(
                        key: ValueKey<String>(blok.id),
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ResultaatBlokKaart(
                          blok: blok,
                          index: index,
                          onBewerken: () => _bewerkBlok(blok),
                          onVerwijderen: () => _verwijderBlok(blok.id),
                        ),
                      );
                    },
                  ),
          ),
          _bouwActieknoppen(),
        ],
      ),
    );
  }

  Widget _bouwActieknoppen() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _rand)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _Actieknop(
              icoon: Icons.notes_rounded,
              tekst: 'Tekstvlak',
              gevuld: false,
              onPressed: () => _openTekstvlak(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _Actieknop(
              icoon: Icons.euro_rounded,
              tekst: 'Tekstvlak met prijs',
              gevuld: false,
              onPressed: () => _openTekstvlakMetPrijs(),
            ),
          ),
        ],
      ),
    );
  }

  static bool _toonOmschrijvingOpOfferte(OffertePrijsregelModel regel) {
    final waarde = regel.uitschrijfmodus.jsonWaarde;
    return waarde == 'overzichtEnOfferteMetPrijs' ||
        waarde == 'invullenEnOfferteMetPrijs' ||
        waarde == 'invullenEnOfferteZonderPrijs' ||
        waarde == 'optie';
  }

  static bool _toonPrijsOpOfferte(OffertePrijsregelModel regel) {
    final waarde = regel.uitschrijfmodus.jsonWaarde;
    return waarde == 'overzichtEnOfferteMetPrijs' ||
        waarde == 'invullenEnOfferteMetPrijs' ||
        waarde == 'optie';
  }

  static OpmetingAlgemenePrijsEenheid _mapPrijsEenheid(
    OffertePrijsEenheid eenheid,
  ) {
    return switch (eenheid) {
      OffertePrijsEenheid.vast => OpmetingAlgemenePrijsEenheid.vastBedrag,
      OffertePrijsEenheid.oppervlakte =>
        OpmetingAlgemenePrijsEenheid.vierkanteMeter,
      _ => OpmetingAlgemenePrijsEenheid.lopendeMeter,
    };
  }
}

class _Actieknop extends StatelessWidget {
  const _Actieknop({
    required this.icoon,
    required this.tekst,
    required this.gevuld,
    required this.onPressed,
  });

  final IconData icoon;
  final String tekst;
  final bool gevuld;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const groen = Color(0xFF0B7A3B);
    if (gevuld) {
      return FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: groen,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 34),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icoon, size: 16),
        label: Text(
          tekst,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
        ),
      );
    }

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: groen,
        backgroundColor: Colors.white,
        side: const BorderSide(color: groen),
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      icon: Icon(icoon, size: 16),
      label: Text(
        tekst,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ResultaatBlokKaart extends StatelessWidget {
  const _ResultaatBlokKaart({
    required this.blok,
    required this.index,
    required this.onBewerken,
    required this.onVerwijderen,
  });

  final OpmetingAlgemeneOpmetingBlok blok;
  final int index;
  final VoidCallback onBewerken;
  final VoidCallback onVerwijderen;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final vrijePrijs = blok.bronPrijsregelId.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: blok.isPrijs ? const Color(0xFFB9E1C6) : _rand,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(0, 3, 8, 3),
              child: Icon(Icons.drag_indicator_rounded, color: _tekstGrijs),
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _lichtGroen,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              blok.isPrijs ? Icons.euro_rounded : Icons.notes_rounded,
              color: _groen,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: _bouwInhoud(vrijePrijs)),
          IconButton(
            tooltip: 'Aanpassen',
            visualDensity: VisualDensity.compact,
            onPressed: onBewerken,
            icon: const Icon(Icons.edit_outlined, color: _groen, size: 19),
          ),
          IconButton(
            tooltip: 'Verwijderen',
            visualDensity: VisualDensity.compact,
            onPressed: onVerwijderen,
            icon: const Icon(
              Icons.delete_outline,
              color: Color(0xFFDC2626),
              size: 19,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwInhoud(bool vrijePrijs) {
    if (!blok.isPrijs) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          blok.omschrijving.trim(),
          style: const TextStyle(
            color: _tekstDonker,
            fontSize: 13,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (vrijePrijs) ...<Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _lichtGroen,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Vrije prijs per artikel',
              style: TextStyle(
                color: _groen,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 5),
        ],
        Row(
          children: <Widget>[
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _lichtGroen,
                shape: BoxShape.circle,
                border: Border.all(color: _groen, width: 1),
              ),
              child: Text(
                blok.prijsSoort.korteCode,
                style: const TextStyle(
                  color: _groen,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                blok.titel.trim().isEmpty ? 'Prijsregel' : blok.titel.trim(),
                style: const TextStyle(
                  color: _tekstDonker,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        if (blok.omschrijving.trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: 3),
          Text(
            blok.omschrijving.trim(),
            style: const TextStyle(
              color: _tekstGrijs,
              fontSize: 11.5,
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 5),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Text(
              blok.eenheid == OpmetingAlgemenePrijsEenheid.vastBedrag
                  ? 'Vast bedrag'
                  : '${_getal(blok.veiligeHoeveelheid)} ${blok.eenheid.label} × '
                        '${_euro(blok.veiligeEenheidsprijs)}',
              style: const TextStyle(
                color: _tekstGrijs,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '= ${_euro(blok.totaalExclBtw)} excl. btw',
              style: const TextStyle(
                color: _groen,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              blok.toonPrijsOpOfferte
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: blok.toonPrijsOpOfferte ? _groen : _tekstGrijs,
              size: 14,
            ),
            const SizedBox(width: 5),
            Text(
              blok.toonPrijsOpOfferte
                  ? 'Prijs zichtbaar op offerte'
                  : 'Prijs niet zichtbaar op offerte',
              style: TextStyle(
                color: blok.toonPrijsOpOfferte ? _groen : _tekstGrijs,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _getal(double waarde) {
    if (waarde == waarde.roundToDouble()) return waarde.toInt().toString();
    return waarde.toStringAsFixed(2).replaceAll('.', ',');
  }

  static String _euro(double waarde) {
    return '€ ${waarde.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

class _AlgemeneTekstvlakDialog extends StatefulWidget {
  const _AlgemeneTekstvlakDialog({required this.blok});

  final OpmetingAlgemeneOpmetingBlok blok;

  @override
  State<_AlgemeneTekstvlakDialog> createState() =>
      _AlgemeneTekstvlakDialogState();
}

class _AlgemeneTekstvlakDialogState extends State<_AlgemeneTekstvlakDialog> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);

  late final TextEditingController _tekstController;
  String? _foutmelding;

  @override
  void initState() {
    super.initState();
    _tekstController = TextEditingController(text: widget.blok.omschrijving);
  }

  @override
  void dispose() {
    _tekstController.dispose();
    super.dispose();
  }

  void _toevoegen() {
    final tekst = _tekstController.text.trim();
    if (tekst.isEmpty) {
      setState(() => _foutmelding = 'Vul eerst een tekst in.');
      return;
    }
    Navigator.pop(
      context,
      widget.blok.copyWith(
        type: OpmetingAlgemeneOpmetingBlokType.tekst,
        titel: '',
        omschrijving: tekst,
        bronPrijsregelId: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: <Widget>[
          Icon(Icons.notes_rounded, color: _groen),
          SizedBox(width: 10),
          Text('Tekstvlak'),
        ],
      ),
      content: SizedBox(
        width: 560,
        child: TextField(
          controller: _tekstController,
          autofocus: true,
          minLines: 6,
          maxLines: 12,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: 'Tekst',
            hintText: 'Beschrijf de toestand of de uit te voeren werken.',
            errorText: _foutmelding,
            alignLabelWithHint: true,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: _rand),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: _groen, width: 1.5),
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(foregroundColor: _groen),
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuleren'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: _groen),
          onPressed: _toevoegen,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(
            widget.blok.omschrijving.trim().isEmpty ? 'Toevoegen' : 'Aanpassen',
          ),
        ),
      ],
    );
  }
}

class _AlgemenePrijsblokDialog extends StatefulWidget {
  const _AlgemenePrijsblokDialog({required this.blok});

  final OpmetingAlgemeneOpmetingBlok blok;

  @override
  State<_AlgemenePrijsblokDialog> createState() =>
      _AlgemenePrijsblokDialogState();
}

class _AlgemenePrijsblokDialogState extends State<_AlgemenePrijsblokDialog> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  late final TextEditingController _omschrijvingController;
  late final TextEditingController _hoeveelheidController;
  late final TextEditingController _prijsController;
  late OpmetingAlgemenePrijsEenheid _eenheid;
  late OpmetingAlgemenePrijsSoort _prijsSoort;
  late bool _toonPrijsOpOfferte;
  String? _foutmelding;

  @override
  void initState() {
    super.initState();
    _omschrijvingController = TextEditingController(
      text: widget.blok.titel.trim().isNotEmpty
          ? widget.blok.titel
          : widget.blok.omschrijving,
    );
    _hoeveelheidController = TextEditingController(
      text: _getal(widget.blok.hoeveelheid <= 0 ? 1 : widget.blok.hoeveelheid),
    );
    _prijsController = TextEditingController(
      text: widget.blok.eenheidsprijsExclBtw <= 0
          ? ''
          : widget.blok.eenheidsprijsExclBtw
                .toStringAsFixed(2)
                .replaceAll('.', ','),
    );
    _eenheid = widget.blok.eenheid;
    _prijsSoort = widget.blok.prijsSoort;
    _toonPrijsOpOfferte = widget.blok.toonPrijsOpOfferte;
    _hoeveelheidController.addListener(_herbouwResultaat);
    _prijsController.addListener(_herbouwResultaat);
  }

  void _herbouwResultaat() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _omschrijvingController.dispose();
    _hoeveelheidController.dispose();
    _prijsController.dispose();
    super.dispose();
  }

  void _toevoegen() {
    final omschrijving = _omschrijvingController.text.trim();
    final hoeveelheid = _eenheid == OpmetingAlgemenePrijsEenheid.vastBedrag
        ? 1.0
        : _leesDouble(_hoeveelheidController.text);
    final prijs = _leesDouble(_prijsController.text);

    if (omschrijving.isEmpty) {
      setState(() => _foutmelding = 'Vul eerst een omschrijving in.');
      return;
    }
    if (hoeveelheid <= 0) {
      setState(() => _foutmelding = 'De hoeveelheid moet groter zijn dan nul.');
      return;
    }
    if (prijs <= 0) {
      setState(() => _foutmelding = 'De prijs moet groter zijn dan nul.');
      return;
    }

    Navigator.pop(
      context,
      widget.blok.copyWith(
        type: OpmetingAlgemeneOpmetingBlokType.prijs,
        titel: omschrijving,
        omschrijving: '',
        hoeveelheid: hoeveelheid,
        eenheid: _eenheid,
        eenheidsprijsExclBtw: prijs,
        prijsSoort: _prijsSoort,
        toonOpOfferte: widget.blok.isVrijePrijsPerArtikel
            ? widget.blok.toonOpOfferte
            : true,
        toonPrijsOpOfferte: _toonPrijsOpOfferte,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isVrijePrijs = widget.blok.bronPrijsregelId.trim().isNotEmpty;
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _lichtGroen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.euro_rounded, color: _groen),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              isVrijePrijs ? 'Vrije prijs aanpassen' : 'Tekstvlak met prijs',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (isVrijePrijs) ...<Widget>[
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: _lichtGroen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Deze regel is overgenomen uit Instellingen → Offerteprijzen → Vrije prijzen per artikel.',
                    style: TextStyle(
                      color: _groen,
                      fontSize: 11.5,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SegmentedButton<OpmetingAlgemenePrijsSoort>(
                segments: const <ButtonSegment<OpmetingAlgemenePrijsSoort>>[
                  ButtonSegment<OpmetingAlgemenePrijsSoort>(
                    value: OpmetingAlgemenePrijsSoort.aankoop,
                    label: Text('Aankoopprijs'),
                    icon: Text('A'),
                  ),
                  ButtonSegment<OpmetingAlgemenePrijsSoort>(
                    value: OpmetingAlgemenePrijsSoort.verkoop,
                    label: Text('Verkoopprijs'),
                    icon: Text('V'),
                  ),
                ],
                selected: <OpmetingAlgemenePrijsSoort>{_prijsSoort},
                showSelectedIcon: false,
                onSelectionChanged: (selectie) {
                  if (selectie.isEmpty) return;
                  setState(() => _prijsSoort = selectie.first);
                },
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    return states.contains(WidgetState.selected)
                        ? Colors.white
                        : _groen;
                  }),
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    return states.contains(WidgetState.selected)
                        ? _groen
                        : Colors.white;
                  }),
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: _groen,
                title: const Text(
                  'Prijs tonen op offerte',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  _toonPrijsOpOfferte
                      ? 'Omschrijving en bedrag worden op de offerte getoond.'
                      : 'De omschrijving blijft zichtbaar, het bedrag wordt verborgen.',
                  style: const TextStyle(color: _tekstGrijs, fontSize: 11.5),
                ),
                value: _toonPrijsOpOfferte,
                onChanged: (waarde) {
                  setState(() => _toonPrijsOpOfferte = waarde);
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _omschrijvingController,
                autofocus: !isVrijePrijs,
                textCapitalization: TextCapitalization.sentences,
                decoration: _veldDecoratie(
                  label: 'Omschrijving',
                  hint: 'Bijvoorbeeld: Helder glas',
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final smal = constraints.maxWidth < 520;
                  final hoeveelheidVeld = TextField(
                    controller: _hoeveelheidController,
                    enabled:
                        _eenheid != OpmetingAlgemenePrijsEenheid.vastBedrag,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: _veldDecoratie(label: 'Hoeveelheid'),
                  );
                  final eenheidVeld =
                      DropdownButtonFormField<OpmetingAlgemenePrijsEenheid>(
                        initialValue: _eenheid,
                        isExpanded: true,
                        decoration: _veldDecoratie(label: 'Eenheid'),
                        items: OpmetingAlgemenePrijsEenheid.values
                            .map(
                              (eenheid) =>
                                  DropdownMenuItem<
                                    OpmetingAlgemenePrijsEenheid
                                  >(value: eenheid, child: Text(eenheid.label)),
                            )
                            .toList(growable: false),
                        onChanged: (waarde) {
                          if (waarde == null) return;
                          setState(() {
                            _eenheid = waarde;
                            if (_eenheid ==
                                OpmetingAlgemenePrijsEenheid.vastBedrag) {
                              _hoeveelheidController.text = '1';
                            }
                          });
                        },
                      );
                  final prijsVeld = TextField(
                    controller: _prijsController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: _veldDecoratie(
                      label: 'Prijs excl. btw',
                      prefix: '€ ',
                    ),
                  );

                  if (smal) {
                    return Column(
                      children: <Widget>[
                        hoeveelheidVeld,
                        const SizedBox(height: 10),
                        eenheidVeld,
                        const SizedBox(height: 10),
                        prijsVeld,
                      ],
                    );
                  }

                  return Row(
                    children: <Widget>[
                      Expanded(child: hoeveelheidVeld),
                      const SizedBox(width: 10),
                      Expanded(child: eenheidVeld),
                      const SizedBox(width: 10),
                      Expanded(child: prijsVeld),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              _bouwLiveResultaat(),
              if (_foutmelding != null) ...<Widget>[
                const SizedBox(height: 10),
                Text(
                  _foutmelding!,
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Na toevoegen verschijnt alleen het nette resultaat in de rechterkolom.',
                style: const TextStyle(
                  color: _tekstGrijs,
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(foregroundColor: _groen),
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuleren'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: _groen),
          onPressed: _toevoegen,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(
            widget.blok.titel.trim().isEmpty ? 'Toevoegen' : 'Aanpassen',
          ),
        ),
      ],
    );
  }

  Widget _bouwLiveResultaat() {
    final hoeveelheid = _eenheid == OpmetingAlgemenePrijsEenheid.vastBedrag
        ? 1.0
        : _leesDouble(_hoeveelheidController.text);
    final prijs = _leesDouble(_prijsController.text);
    final totaal = hoeveelheid > 0 && prijs > 0 ? hoeveelheid * prijs : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _lichtGroen,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFB9E1C6)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Text(
              _prijsSoort.korteCode,
              style: const TextStyle(
                color: _groen,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _prijsSoort.label,
                  style: const TextStyle(
                    color: _groen,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _eenheid == OpmetingAlgemenePrijsEenheid.vastBedrag
                      ? 'Vast bedrag'
                      : '${_getal(hoeveelheid)} ${_eenheid.label} × '
                            '€ ${prijs.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                    color: _tekstGrijs,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '€ ${totaal.toStringAsFixed(2).replaceAll('.', ',')}',
            style: const TextStyle(
              color: _groen,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _veldDecoratie({
    required String label,
    String? hint,
    String? prefix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefix,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _rand),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _rand),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _groen, width: 1.5),
      ),
    );
  }

  static double _leesDouble(String waarde) {
    return double.tryParse(waarde.trim().replaceAll(',', '.')) ?? 0;
  }

  static String _getal(double waarde) {
    if (waarde == waarde.roundToDouble()) return waarde.toInt().toString();
    return waarde.toStringAsFixed(2).replaceAll('.', ',');
  }
}

class _VrijePrijsPerArtikelResultaat {
  const _VrijePrijsPerArtikelResultaat({
    required this.geselecteerdePrijsregels,
    required this.allePrijsregels,
    required this.bewarenInInstellingen,
  });

  final List<OffertePrijsregelModel> geselecteerdePrijsregels;
  final List<OffertePrijsregelModel> allePrijsregels;
  final bool bewarenInInstellingen;
}

class _VrijePrijsPerArtikelDialog extends StatefulWidget {
  const _VrijePrijsPerArtikelDialog({
    required this.prijsregels,
    required this.reedsToegevoegdePrijsregelIds,
  });

  final List<OffertePrijsregelModel> prijsregels;
  final Set<String> reedsToegevoegdePrijsregelIds;

  @override
  State<_VrijePrijsPerArtikelDialog> createState() =>
      _VrijePrijsPerArtikelDialogState();
}

class _VrijePrijsPerArtikelDialogState
    extends State<_VrijePrijsPerArtikelDialog> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  final Set<String> _geselecteerdeIds = <String>{};
  final TextEditingController _zoekController = TextEditingController();
  late List<OffertePrijsregelModel> _prijsregels;
  String _zoekterm = '';
  Offset? _positie;

  @override
  void initState() {
    super.initState();
    _prijsregels = List<OffertePrijsregelModel>.from(widget.prijsregels);
    _sorteerPrijsregels();
  }

  @override
  void dispose() {
    _zoekController.dispose();
    super.dispose();
  }

  List<OffertePrijsregelModel> get _zichtbareRegels {
    final zoekterm = _zoekterm.trim().toLowerCase();
    if (zoekterm.isEmpty) return _prijsregels;
    return _prijsregels
        .where((regel) => regel.omschrijving.toLowerCase().contains(zoekterm))
        .toList(growable: false);
  }

  int get _volgendeVolgorde {
    if (_prijsregels.isEmpty) return 0;
    var hoogste = _prijsregels.first.volgorde;
    for (final regel in _prijsregels.skip(1)) {
      if (regel.volgorde > hoogste) hoogste = regel.volgorde;
    }
    return hoogste + 10;
  }

  void _sorteerPrijsregels() {
    _prijsregels.sort((eerste, tweede) {
      final volgorde = eerste.volgorde.compareTo(tweede.volgorde);
      if (volgorde != 0) return volgorde;
      return eerste.omschrijving.toLowerCase().compareTo(
        tweede.omschrijving.toLowerCase(),
      );
    });
  }

  Future<void> _voegNieuwePrijsToe() async {
    final regel = await toonOffertePrijsregelDialog(
      context: context,
      categorie: OffertePrijsCategorie.vrijPerArtikel,
      formulierType: 'algemeneOpmeting',
      volgendeVolgorde: _volgendeVolgorde,
      bevestigKnopTekst: 'Toevoegen',
      bevestigKnopIcoon: Icons.add_rounded,
    );

    if (regel == null || !mounted) return;
    final genormaliseerd = regel.copyWith(
      categorie: OffertePrijsCategorie.vrijPerArtikel,
      formulierType: 'algemeneOpmeting',
    );

    setState(() {
      final index = _prijsregels.indexWhere((item) => item.id == regel.id);
      if (index >= 0) {
        _prijsregels[index] = genormaliseerd;
      } else {
        _prijsregels.add(genormaliseerd);
      }
      _geselecteerdeIds.add(genormaliseerd.id);
      _sorteerPrijsregels();
    });
  }

  Future<void> _bewerkPrijsregel(OffertePrijsregelModel regel) async {
    final gewijzigd = await toonOffertePrijsregelDialog(
      context: context,
      categorie: OffertePrijsCategorie.vrijPerArtikel,
      formulierType: 'algemeneOpmeting',
      volgendeVolgorde: regel.volgorde,
      bestaandePrijsregel: regel,
      bevestigKnopTekst: 'Aanpassen',
      bevestigKnopIcoon: Icons.check_rounded,
    );

    if (gewijzigd == null || !mounted) return;
    setState(() {
      final index = _prijsregels.indexWhere((item) => item.id == regel.id);
      if (index >= 0) {
        _prijsregels[index] = gewijzigd.copyWith(
          categorie: OffertePrijsCategorie.vrijPerArtikel,
          formulierType: 'algemeneOpmeting',
        );
      }
      _sorteerPrijsregels();
    });
  }

  void _sluitMetResultaat({required bool bewaren}) {
    final gekozen = _prijsregels
        .where((regel) => _geselecteerdeIds.contains(regel.id))
        .toList(growable: false);
    if (gekozen.isEmpty) return;

    Navigator.pop(
      context,
      _VrijePrijsPerArtikelResultaat(
        geselecteerdePrijsregels: gekozen,
        allePrijsregels: List<OffertePrijsregelModel>.unmodifiable(
          _prijsregels,
        ),
        bewarenInInstellingen: bewaren,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scherm = MediaQuery.sizeOf(context);
    final breedte = (scherm.width - 24).clamp(320.0, 760.0).toDouble();
    final hoogte = (scherm.height - 40).clamp(440.0, 720.0).toDouble();
    final beginPositie = Offset(
      ((scherm.width - breedte) / 2).clamp(8.0, scherm.width).toDouble(),
      ((scherm.height - hoogte) / 2).clamp(8.0, scherm.height).toDouble(),
    );
    final positie = _positie ?? beginPositie;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: positie.dx,
            top: positie.dy,
            width: breedte,
            height: hoogte,
            child: Material(
              color: Colors.white,
              elevation: 22,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (details) {
                      final huidige = _positie ?? beginPositie;
                      final maxX = scherm.width - breedte - 8;
                      final maxY = scherm.height - hoogte - 8;
                      setState(() {
                        _positie = Offset(
                          (huidige.dx + details.delta.dx)
                              .clamp(8.0, maxX < 8 ? 8.0 : maxX)
                              .toDouble(),
                          (huidige.dy + details.delta.dy)
                              .clamp(8.0, maxY < 8 ? 8.0 : maxY)
                              .toDouble(),
                        );
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 11, 8, 11),
                      color: _lichtGroen,
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.library_add_outlined,
                              color: _groen,
                            ),
                          ),
                          const SizedBox(width: 11),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Vrije prijs per artikel',
                                  style: TextStyle(
                                    color: _tekstDonker,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Kies een bestaande regel of maak hier de eerste vrije prijs.',
                                  style: TextStyle(
                                    color: _tekstGrijs,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.open_with_rounded,
                            color: _tekstGrijs,
                            size: 19,
                          ),
                          IconButton(
                            tooltip: 'Sluiten',
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _zoekController,
                            onChanged: (waarde) =>
                                setState(() => _zoekterm = waarde),
                            decoration: InputDecoration(
                              hintText: 'Zoek een vrije prijsregel',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: _groen,
                              ),
                              suffixIcon: _zoekterm.isEmpty
                                  ? null
                                  : IconButton(
                                      onPressed: () {
                                        _zoekController.clear();
                                        setState(() => _zoekterm = '');
                                      },
                                      icon: const Icon(Icons.close_rounded),
                                    ),
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: _rand),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: _rand),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: _groen,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: _groen,
                            minimumSize: const Size(0, 40),
                          ),
                          onPressed: _voegNieuwePrijsToe,
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Nieuwe prijs'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _zichtbareRegels.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Icon(
                                    Icons.price_change_outlined,
                                    color: _groen,
                                    size: 34,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Nog geen vrije prijsregels.',
                                    style: TextStyle(
                                      color: _tekstDonker,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Gebruik Nieuwe prijs om de eerste regel toe te voegen.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _tekstGrijs,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: _groen,
                                      side: const BorderSide(color: _groen),
                                    ),
                                    onPressed: _voegNieuwePrijsToe,
                                    icon: const Icon(Icons.add_rounded),
                                    label: const Text('Eerste vrije prijs'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                            itemCount: _zichtbareRegels.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1, color: _rand),
                            itemBuilder: (context, index) {
                              final regel = _zichtbareRegels[index];
                              final reedsToegevoegd = widget
                                  .reedsToegevoegdePrijsregelIds
                                  .contains(regel.id);
                              final geselecteerd = _geselecteerdeIds.contains(
                                regel.id,
                              );
                              return CheckboxListTile(
                                value: geselecteerd,
                                onChanged: reedsToegevoegd
                                    ? null
                                    : (waarde) {
                                        setState(() {
                                          if (waarde == true) {
                                            _geselecteerdeIds.add(regel.id);
                                          } else {
                                            _geselecteerdeIds.remove(regel.id);
                                          }
                                        });
                                      },
                                activeColor: _groen,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                secondary: IconButton(
                                  tooltip: 'Prijsregel aanpassen',
                                  onPressed: () => _bewerkPrijsregel(regel),
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: _groen,
                                    size: 19,
                                  ),
                                ),
                                title: Text(
                                  regel.omschrijving,
                                  style: TextStyle(
                                    color: reedsToegevoegd
                                        ? _tekstGrijs
                                        : _tekstDonker,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                subtitle: Text(
                                  reedsToegevoegd
                                      ? 'Reeds toegevoegd aan deze fiche'
                                      : '${regel.eenheid.benaming} · '
                                            '€ ${regel.prijsExclBtw.toStringAsFixed(2).replaceAll('.', ',')} excl. btw',
                                  style: TextStyle(
                                    color: reedsToegevoegd
                                        ? _tekstGrijs
                                        : _groen,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: _rand)),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        TextButton(
                          style: TextButton.styleFrom(foregroundColor: _groen),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Annuleren'),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _groen,
                            side: const BorderSide(color: _groen),
                          ),
                          onPressed: _geselecteerdeIds.isEmpty
                              ? null
                              : () => _sluitMetResultaat(bewaren: false),
                          icon: const Icon(
                            Icons.playlist_add_rounded,
                            size: 18,
                          ),
                          label: const Text('Toevoegen'),
                        ),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: _groen,
                          ),
                          onPressed: _geselecteerdeIds.isEmpty
                              ? null
                              : () => _sluitMetResultaat(bewaren: true),
                          icon: const Icon(
                            Icons.library_add_check_outlined,
                            size: 18,
                          ),
                          label: const Text('Toevoegen en bewaren'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
