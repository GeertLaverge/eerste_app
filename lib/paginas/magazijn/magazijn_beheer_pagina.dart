// THIMACO-CONTROLE: MAGAZIJN-LEVERANCIER-ALTIJD-TOEVOEGEN-GROEN-20260804

import 'package:flutter/material.dart';

import '../../helpers/magazijn/magazijn_controller.dart';
import '../../helpers/magazijn/magazijn_instellingen_leveranciers_repository.dart';
import '../../helpers/magazijn/magazijn_model.dart';
import '../../helpers/magazijn/magazijn_qr_etiket_service.dart';

class MagazijnBeheerPagina extends StatelessWidget {
  const MagazijnBeheerPagina({super.key, required this.controller});

  final MagazijnController controller;

  static const Color _groen = Color(0xFF0B7A3B);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(
          context,
        ).colorScheme.copyWith(primary: _groen, secondary: _groen),
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'Leveranciers en artikelen',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: _groen),
                    onPressed: () => _bewerkLeverancier(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Leverancier'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (controller.data.leveranciers.isEmpty)
                const _LegeKaart(
                  tekst:
                      'Nog geen leveranciers. Voeg eerst een leverancier toe.',
                )
              else
                ...controller.data.leveranciers.map((leverancier) {
                  final artikelen = controller.data.artikelen
                      .where((item) => item.leverancierId == leverancier.id)
                      .toList(growable: false);

                  return DragTarget<MagazijnArtikel>(
                    onWillAcceptWithDetails: (details) =>
                        details.data.leverancierId != leverancier.id,
                    onAcceptWithDetails: (details) async {
                      final actie = await _kiesSleepActie(
                        context: context,
                        artikel: details.data,
                        doelLeverancier: leverancier,
                      );
                      if (actie == _ArtikelSleepActie.verplaatsen) {
                        await controller.verplaatsArtikel(
                          artikelId: details.data.id,
                          naarLeverancierId: leverancier.id,
                        );
                      } else if (actie == _ArtikelSleepActie.kopieren) {
                        await controller.kopieerArtikel(
                          artikelId: details.data.id,
                          naarLeverancierId: leverancier.id,
                        );
                      }
                    },
                    builder: (context, kandidaat, geweigerd) {
                      final actiefDoel = kandidaat.isNotEmpty;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: actiefDoel
                              ? Border.all(color: _groen, width: 3)
                              : null,
                        ),
                        child: ExpansionTile(
                          collapsedShape: _vorm(),
                          shape: _vorm(),
                          backgroundColor: Colors.white,
                          collapsedBackgroundColor: Colors.white,
                          title: Text(
                            leverancier.naam,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          subtitle: Text('${artikelen.length} artikelen'),
                          trailing: Wrap(
                            spacing: 2,
                            children: <Widget>[
                              FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: _groen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                onPressed: () =>
                                    _bewerkArtikel(context, leverancier.id),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text(
                                  'Artikel toevoegen',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Leverancier bewerken',
                                onPressed: () => _bewerkLeverancier(
                                  context,
                                  bestaand: leverancier,
                                ),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                            ],
                          ),
                          children: <Widget>[
                            if (artikelen.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(14),
                                child: Text('Nog geen artikelen.'),
                              )
                            else
                              ...artikelen.map((artikel) {
                                final tegel = ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: artikel.onderMinimum
                                        ? const Color(0xFFFFE4E6)
                                        : const Color(0xFFE7F6EC),
                                    child: Icon(
                                      Icons.inventory_2_outlined,
                                      color: artikel.onderMinimum
                                          ? const Color(0xFFBE123C)
                                          : _groen,
                                    ),
                                  ),
                                  title: Text(
                                    artikel.omschrijving,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${artikel.effectiefBestelArtikelnummer.isEmpty ? 'Geen artikelnr.' : artikel.effectiefBestelArtikelnummer} · '
                                    'stock ${artikel.stock} ${artikel.eenheid} · '
                                    '€ ${artikel.prijsPerEenheid.toStringAsFixed(2).replaceAll('.', ',')}/${artikel.eenheid} · '
                                    'min ${artikel.minimumStock} · mee ${artikel.meebestelgrens} · max ${artikel.maximumStock}',
                                  ),
                                  trailing: Wrap(
                                    spacing: 0,
                                    children: <Widget>[
                                      IconButton(
                                        tooltip: 'QR-etiket afdrukken',
                                        onPressed: () =>
                                            MagazijnQrEtiketService.printEtiket(
                                              artikel: artikel,
                                              leverancierNaam: leverancier.naam,
                                            ),
                                        icon: const Icon(Icons.qr_code_2),
                                      ),
                                      IconButton(
                                        tooltip: 'Bewerken',
                                        onPressed: () => _bewerkArtikel(
                                          context,
                                          leverancier.id,
                                          bestaand: artikel,
                                        ),
                                        icon: const Icon(Icons.edit_outlined),
                                      ),
                                      IconButton(
                                        tooltip: 'Verwijderen',
                                        onPressed: () => controller
                                            .verwijderArtikel(artikel.id),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Color(0xFFDC2626),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                return LongPressDraggable<MagazijnArtikel>(
                                  data: artikel,
                                  feedback: Material(
                                    color: Colors.transparent,
                                    child: Container(
                                      width: 360,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _groen,
                                          width: 2,
                                        ),
                                        boxShadow: const <BoxShadow>[
                                          BoxShadow(
                                            color: Color(0x33000000),
                                            blurRadius: 12,
                                            offset: Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        artikel.omschrijving,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                  childWhenDragging: Opacity(
                                    opacity: 0.35,
                                    child: tegel,
                                  ),
                                  child: tegel,
                                );
                              }),
                          ],
                        ),
                      );
                    },
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  RoundedRectangleBorder _vorm() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: Color(0xFFE5E7EB)),
    );
  }

  Future<void> _bewerkLeverancier(
    BuildContext context, {
    MagazijnLeverancier? bestaand,
  }) async {
    final instellingen = await MagazijnInstellingenLeveranciersRepository()
        .laad();
    if (!context.mounted) return;

    InstellingenLeverancierKeuze? gekozen;
    if (bestaand != null) {
      for (final item in instellingen) {
        if (item.naam.toLowerCase() == bestaand.naam.toLowerCase()) {
          gekozen = item;
          break;
        }
      }
    }

    final naamController = TextEditingController(text: bestaand?.naam ?? '');
    final contactController = TextEditingController(
      text: bestaand?.contactpersoon ?? '',
    );
    final emailController = TextEditingController(text: bestaand?.email ?? '');
    final telefoonController = TextEditingController(
      text: bestaand?.telefoon ?? '',
    );
    final gsmController = TextEditingController(text: bestaand?.gsm ?? '');

    var handmatig = instellingen.isEmpty || gekozen == null;
    InstellingenLeverancierKeuze? selectie = gekozen;

    final resultaat = await showDialog<MagazijnLeverancier>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            void neemInstellingenOver(InstellingenLeverancierKeuze? waarde) {
              selectie = waarde;
              if (waarde == null) return;
              naamController.text = waarde.naam;
              emailController.text = waarde.email;
              telefoonController.text = waarde.telefoon;
              gsmController.text = waarde.gsm;
            }

            return Theme(
              data: Theme.of(dialogContext).copyWith(
                colorScheme: Theme.of(
                  dialogContext,
                ).colorScheme.copyWith(primary: _groen, secondary: _groen),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(foregroundColor: _groen),
                ),
                filledButtonTheme: FilledButtonThemeData(
                  style: FilledButton.styleFrom(
                    backgroundColor: _groen,
                    foregroundColor: Colors.white,
                  ),
                ),
                inputDecorationTheme: const InputDecorationTheme(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _groen, width: 2),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              child: AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                title: Text(
                  bestaand == null
                      ? 'Leverancier toevoegen'
                      : 'Leverancier wijzigen',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                content: SizedBox(
                  width: 540,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        if (instellingen.isNotEmpty) ...<Widget>[
                          SegmentedButton<bool>(
                            segments: const <ButtonSegment<bool>>[
                              ButtonSegment<bool>(
                                value: false,
                                icon: Icon(Icons.settings_outlined),
                                label: Text('Uit instellingen'),
                              ),
                              ButtonSegment<bool>(
                                value: true,
                                icon: Icon(Icons.edit_outlined),
                                label: Text('Zelf invullen'),
                              ),
                            ],
                            selected: <bool>{handmatig},
                            onSelectionChanged: (selectieSet) {
                              setDialogState(() {
                                handmatig = selectieSet.first;
                              });
                            },
                            style: ButtonStyle(
                              foregroundColor: WidgetStateProperty.resolveWith(
                                (states) =>
                                    states.contains(WidgetState.selected)
                                    ? Colors.white
                                    : _groen,
                              ),
                              backgroundColor: WidgetStateProperty.resolveWith(
                                (states) =>
                                    states.contains(WidgetState.selected)
                                    ? _groen
                                    : Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (!handmatig && instellingen.isNotEmpty) ...<Widget>[
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final gekozenLeverancier =
                                  await _kiesInstellingenLeverancier(
                                    context: dialogContext,
                                    leveranciers: instellingen,
                                    huidigeSelectie: selectie,
                                  );
                              if (gekozenLeverancier == null) return;
                              setDialogState(() {
                                neemInstellingenOver(gekozenLeverancier);
                              });
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Leverancier uit instellingen',
                                prefixIcon: Icon(Icons.business_outlined),
                                suffixIcon: Icon(Icons.search),
                              ),
                              child: Text(
                                selectie?.naam ?? 'Zoek en kies leverancier',
                                style: TextStyle(
                                  color: selectie == null
                                      ? const Color(0xFF6B7280)
                                      : const Color(0xFF111827),
                                  fontWeight: selectie == null
                                      ? FontWeight.w600
                                      : FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (selectie != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7F6EC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFB7DEC5),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    selectie!.naam,
                                    style: const TextStyle(
                                      color: _groen,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  if (selectie!.email.trim().isNotEmpty)
                                    Text(selectie!.email),
                                  if (selectie!.telefoon.trim().isNotEmpty)
                                    Text(selectie!.telefoon),
                                  if (selectie!.gsm.trim().isNotEmpty)
                                    Text(selectie!.gsm),
                                ],
                              ),
                            ),
                        ] else ...<Widget>[
                          TextField(
                            controller: naamController,
                            decoration: const InputDecoration(
                              labelText: 'Naam leverancier',
                              prefixIcon: Icon(Icons.business_outlined),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: contactController,
                            decoration: const InputDecoration(
                              labelText: 'Contactpersoon',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: telefoonController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Telefoon',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: gsmController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Gsm',
                              prefixIcon: Icon(Icons.smartphone_outlined),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Annuleren'),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      if (!handmatig && selectie != null) {
                        neemInstellingenOver(selectie);
                      }

                      final naam = naamController.text.trim();
                      if (naam.isEmpty) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Vul een naam in of kies een leverancier.',
                            ),
                          ),
                        );
                        return;
                      }

                      Navigator.pop(
                        dialogContext,
                        MagazijnLeverancier(
                          id:
                              bestaand?.id ??
                              'lev-${DateTime.now().microsecondsSinceEpoch}',
                          naam: naam,
                          contactpersoon: contactController.text.trim(),
                          email: emailController.text.trim(),
                          telefoon: telefoonController.text.trim(),
                          gsm: gsmController.text.trim(),
                          klantnummer: bestaand?.klantnummer ?? '',
                          opmerking: bestaand?.opmerking ?? '',
                        ),
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: Text(bestaand == null ? 'Toevoegen' : 'Bewaren'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    naamController.dispose();
    contactController.dispose();
    emailController.dispose();
    telefoonController.dispose();
    gsmController.dispose();

    if (resultaat == null) return;
    await controller.bewaarLeverancier(resultaat);
  }

  Future<InstellingenLeverancierKeuze?> _kiesInstellingenLeverancier({
    required BuildContext context,
    required List<InstellingenLeverancierKeuze> leveranciers,
    required InstellingenLeverancierKeuze? huidigeSelectie,
  }) async {
    final zoekController = TextEditingController();

    try {
      return await showDialog<InstellingenLeverancierKeuze>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              final zoekterm = zoekController.text.trim().toLowerCase();
              final zichtbaar = leveranciers
                  .where((leverancier) {
                    if (zoekterm.isEmpty) return true;
                    return leverancier.naam.toLowerCase().contains(zoekterm) ||
                        leverancier.email.toLowerCase().contains(zoekterm);
                  })
                  .toList(growable: false);

              return Theme(
                data: Theme.of(dialogContext).copyWith(
                  colorScheme: Theme.of(
                    dialogContext,
                  ).colorScheme.copyWith(primary: _groen, secondary: _groen),
                ),
                child: AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  title: const Text(
                    'Leverancier zoeken',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  content: SizedBox(
                    width: 520,
                    height: 430,
                    child: Column(
                      children: <Widget>[
                        TextField(
                          controller: zoekController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            labelText: 'Zoeken op naam of e-mail',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) {
                            setDialogState(() {});
                          },
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: zichtbaar.isEmpty
                              ? const Center(
                                  child: Text('Geen leverancier gevonden.'),
                                )
                              : ListView.separated(
                                  itemCount: zichtbaar.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final leverancier = zichtbaar[index];
                                    final geselecteerd =
                                        huidigeSelectie?.naam ==
                                        leverancier.naam;

                                    return RadioListTile<String>(
                                      value: leverancier.naam,
                                      groupValue: geselecteerd
                                          ? leverancier.naam
                                          : null,
                                      activeColor: _groen,
                                      title: Text(
                                        leverancier.naam,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      subtitle: leverancier.email.trim().isEmpty
                                          ? null
                                          : Text(leverancier.email),
                                      onChanged: (_) {
                                        Navigator.pop(
                                          dialogContext,
                                          leverancier,
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: _groen),
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Annuleren'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } finally {
      zoekController.dispose();
    }
  }

  Future<_ArtikelSleepActie?> _kiesSleepActie({
    required BuildContext context,
    required MagazijnArtikel artikel,
    required MagazijnLeverancier doelLeverancier,
  }) {
    return showDialog<_ArtikelSleepActie>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Artikel neerzetten',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text(
          'Wat wil je doen met "${artikel.omschrijving}" bij '
          '${doelLeverancier.naam}?',
        ),
        actions: <Widget>[
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
            onPressed: () =>
                Navigator.pop(context, _ArtikelSleepActie.kopieren),
            icon: const Icon(Icons.copy_outlined),
            label: const Text('Kopiëren'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _groen,
              foregroundColor: Colors.white,
            ),
            onPressed: () =>
                Navigator.pop(context, _ArtikelSleepActie.verplaatsen),
            icon: const Icon(Icons.drive_file_move_outline),
            label: const Text('Verplaatsen'),
          ),
        ],
      ),
    );
  }

  Future<void> _bewerkArtikel(
    BuildContext context,
    String leverancierId, {
    MagazijnArtikel? bestaand,
  }) async {
    final omschrijving = TextEditingController(
      text: bestaand?.omschrijving ?? '',
    );
    final bestelArtikelnummer = TextEditingController(
      text: bestaand?.effectiefBestelArtikelnummer ?? '',
    );
    final prijs = TextEditingController(
      text: (bestaand?.prijsPerEenheid ?? 0)
          .toStringAsFixed(2)
          .replaceAll('.', ','),
    );
    final stock = TextEditingController(
      text: (bestaand?.stock ?? 0).toString(),
    );
    final minimum = TextEditingController(
      text: (bestaand?.minimumStock ?? 0).toString(),
    );
    final mee = TextEditingController(
      text: (bestaand?.meebestelgrens ?? 0).toString(),
    );
    final maximum = TextEditingController(
      text: (bestaand?.maximumStock ?? 0).toString(),
    );

    var eenheid = bestaand?.eenheid ?? controller.data.eenheden.first;

    final bewaren = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> nieuweEenheid() async {
              final invoer = TextEditingController();
              final waarde = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Eenheid toevoegen'),
                  content: TextField(
                    controller: invoer,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Bijvoorbeeld doos, koker of set',
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuleren'),
                    ),
                    FilledButton(
                      onPressed: () =>
                          Navigator.pop(context, invoer.text.trim()),
                      child: const Text('Toevoegen'),
                    ),
                  ],
                ),
              );

              if (waarde == null || waarde.isEmpty) return;
              await controller.voegEenheidToe(waarde);
              setDialogState(() => eenheid = waarde);
            }

            final eenheden =
                <String>{...controller.data.eenheden, eenheid}.toList(
                  growable: false,
                )..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(
                  context,
                ).colorScheme.copyWith(primary: _groen, secondary: _groen),
                filledButtonTheme: FilledButtonThemeData(
                  style: FilledButton.styleFrom(
                    backgroundColor: _groen,
                    foregroundColor: Colors.white,
                  ),
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(foregroundColor: _groen),
                ),
              ),
              child: AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                title: Text(
                  bestaand == null ? 'Artikel toevoegen' : 'Artikel wijzigen',
                ),
                content: SizedBox(
                  width: 540,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: eenheid,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Eenheid',
                                  border: OutlineInputBorder(),
                                ),
                                items: eenheden
                                    .map((item) {
                                      return DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(item),
                                      );
                                    })
                                    .toList(growable: false),
                                onChanged: (waarde) {
                                  if (waarde == null) return;
                                  setDialogState(() => eenheid = waarde);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filled(
                              tooltip: 'Eenheid toevoegen',
                              onPressed: nieuweEenheid,
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: omschrijving,
                          decoration: const InputDecoration(
                            labelText: 'Omschrijving',
                          ),
                        ),
                        TextField(
                          controller: bestelArtikelnummer,
                          decoration: const InputDecoration(
                            labelText: 'Bestel artikelnr.',
                            helperText:
                                'Het artikelnummer dat de leverancier nodig heeft.',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: prijs,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Prijs per eenheid',
                            prefixText: '€ ',
                            suffixText: '/$eenheid',
                            helperText: 'Bijvoorbeeld € 15,00 per $eenheid',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            Expanded(child: _getalVeld(stock, 'Huidige stock')),
                            const SizedBox(width: 8),
                            Expanded(child: _getalVeld(minimum, 'Minimum')),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _getalVeld(mee, 'Meebestellen vanaf'),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: _getalVeld(maximum, 'Maximum')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Annuleren'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Bewaren'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (bewaren != true || omschrijving.text.trim().isEmpty) return;

    int getal(TextEditingController controller) =>
        int.tryParse(controller.text.trim()) ?? 0;

    final min = getal(minimum);
    final meebestel = getal(mee).clamp(min, 999999).toInt();
    final max = getal(maximum).clamp(meebestel, 999999).toInt();

    await controller.bewaarArtikel(
      (bestaand ??
              MagazijnArtikel(
                id: 'art-${DateTime.now().microsecondsSinceEpoch}',
                leverancierId: leverancierId,
                omschrijving: omschrijving.text.trim(),
              ))
          .copyWith(
            leverancierId: leverancierId,
            omschrijving: omschrijving.text.trim(),
            bestelArtikelnummer: bestelArtikelnummer.text.trim(),
            eenheid: eenheid,
            prijsPerEenheid:
                double.tryParse(prijs.text.trim().replaceAll(',', '.')) ?? 0,
            stock: getal(stock),
            minimumStock: min,
            meebestelgrens: meebestel,
            maximumStock: max,
          ),
    );
  }

  Widget _getalVeld(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _LegeKaart extends StatelessWidget {
  const _LegeKaart({required this.tekst});

  final String tekst;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(tekst),
    );
  }
}

enum _ArtikelSleepActie { kopieren, verplaatsen }
