import 'package:flutter/material.dart';

import '../modellen/leverancier.dart';
import '../helpers/widgets/onder_navigatie_balk.dart';

class LeveranciersPagina extends StatefulWidget {
  final List<Leverancier> leveranciers;
  final Future<void> Function() onGewijzigd;

  const LeveranciersPagina({
    super.key,
    required this.leveranciers,
    required this.onGewijzigd,
  });

  @override
  State<LeveranciersPagina> createState() => _LeveranciersPaginaState();
}

class _LeveranciersPaginaState extends State<LeveranciersPagina> {
  final TextEditingController zoekController = TextEditingController();
  final TextEditingController nieuweLeverancierController =
      TextEditingController();

  String zoekterm = '';
  bool toonNieuwLeverancierFormulier = false;

  @override
  void dispose() {
    zoekController.dispose();
    nieuweLeverancierController.dispose();
    super.dispose();
  }

  List<Leverancier> get leveranciersGesorteerd {
    final lijst = [...widget.leveranciers];

    lijst.sort((a, b) {
      return a.naam.toLowerCase().compareTo(b.naam.toLowerCase());
    });

    if (zoekterm.trim().isEmpty) return lijst;

    return lijst.where((leverancier) {
      final zoek = zoekterm.toLowerCase();

      return leverancier.naam.toLowerCase().contains(zoek) ||
          leverancier.artikelen.any(
            (artikel) => artikel.toLowerCase().contains(zoek),
          );
    }).toList();
  }

  int get aantalArtikelen {
    return widget.leveranciers.fold<int>(
      0,
      (totaal, leverancier) => totaal + leverancier.artikelen.length,
    );
  }

  Future<void> voegLeverancierToe() async {
    final naam = nieuweLeverancierController.text.trim();
    if (naam.isEmpty) return;

    final bestaatAl = widget.leveranciers.any(
      (leverancier) => leverancier.naam.toLowerCase() == naam.toLowerCase(),
    );

    if (bestaatAl) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deze leverancier bestaat al.'),
        ),
      );
      return;
    }

    setState(() {
      widget.leveranciers.add(
        Leverancier(
          naam: naam,
          artikelen: [],
        ),
      );

      nieuweLeverancierController.clear();
      toonNieuwLeverancierFormulier = false;
    });

    await widget.onGewijzigd();
  }

  Future<void> voegArtikelToe(Leverancier leverancier) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Artikel toevoegen bij ${leverancier.naam}'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Artikelnaam',
              hintText: 'bv. Beton C25/30',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuleren'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final artikel = controller.text.trim();
                if (artikel.isEmpty) return;

                final bestaatAl = leverancier.artikelen.any(
                  (bestaand) => bestaand.toLowerCase() == artikel.toLowerCase(),
                );

                if (!bestaatAl) {
                  setState(() {
                    leverancier.artikelen.add(artikel);
                    leverancier.artikelen.sort(
                      (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
                    );
                  });

                  await widget.onGewijzigd();
                }

                if (mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Toevoegen'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  Future<void> wisArtikel(Leverancier leverancier, int index) async {
    final artikel = leverancier.artikelen[index];

    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Artikel wissen'),
          content: Text('Wil je "$artikel" zeker wissen?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Nee'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ja'),
            ),
          ],
        );
      },
    );

    if (bevestigen == true) {
      setState(() {
        leverancier.artikelen.removeAt(index);
      });

      await widget.onGewijzigd();
    }
  }

  Future<void> wisLeverancier(Leverancier leverancier) async {
    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Leverancier wissen'),
          content: Text(
            'Wil je leverancier "${leverancier.naam}" zeker wissen?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Nee'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ja'),
            ),
          ],
        );
      },
    );

    if (bevestigen == true) {
      setState(() {
        widget.leveranciers.remove(leverancier);
      });

      await widget.onGewijzigd();
    }
  }

  String initialen(String naam) {
    final delen = naam.trim().split(' ').where((deel) => deel.isNotEmpty);

    if (delen.isEmpty) return '?';

    if (delen.length == 1) {
      return delen.first.characters.first.toUpperCase();
    }

    return '${delen.first.characters.first}${delen.last.characters.first}'
        .toUpperCase();
  }

  Widget statistiekKaart({
    required IconData icoon,
    required String titel,
    required String waarde,
    required String subtitel,
    required Color kleur,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 58,
              width: 58,
              decoration: BoxDecoration(
                color: kleur.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                icoon,
                color: kleur,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titel,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    waarde,
                    style: TextStyle(
                      color: kleur,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitel,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget zoekBalk() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: zoekController,
            onChanged: (waarde) {
              setState(() {
                zoekterm = waarde;
              });
            },
            decoration: InputDecoration(
              hintText: 'Zoek leverancier of artikel...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: zoekterm.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        zoekController.clear();
                        setState(() {
                          zoekterm = '';
                        });
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(
                Icons.filter_list,
                color: Colors.green.shade700,
              ),
              const SizedBox(width: 8),
              const Text(
                'Filter',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget nieuwLeverancierFormulier() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: !toonNieuwLeverancierFormulier
          ? const SizedBox.shrink()
          : Container(
              key: const ValueKey('nieuwLeverancierFormulier'),
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nieuweLeverancierController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Naam van de leverancier',
                        prefixIcon: const Icon(Icons.store),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onSubmitted: (_) => voegLeverancierToe(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: voegLeverancierToe,
                      icon: const Icon(Icons.save),
                      label: const Text('Opslaan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget leverancierKaart(Leverancier leverancier) {
    final artikelen = [...leverancier.artikelen]
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.green.withValues(alpha: 0.12),
          child: Text(
            initialen(leverancier.naam),
            style: TextStyle(
              color: Colors.green.shade800,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          leverancier.naam,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _ChipLabel(
                tekst: '${leverancier.artikelen.length} artikelen',
                kleur: Colors.green,
              ),
              if (leverancier.artikelen.isEmpty)
                _ChipLabel(
                  tekst: 'nog geen artikelen',
                  kleur: Colors.orange,
                ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Artikel toevoegen',
              onPressed: () => voegArtikelToe(leverancier),
              icon: const Icon(Icons.add_box_outlined),
              color: Colors.green,
            ),
            IconButton(
              tooltip: 'Leverancier wissen',
              onPressed: () => wisLeverancier(leverancier),
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => voegArtikelToe(leverancier),
              icon: const Icon(Icons.add),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Artikel toevoegen'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (artikelen.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Text(
                'Nog geen artikelen toegevoegd.',
                textAlign: TextAlign.center,
              ),
            )
          else
            ...List.generate(artikelen.length, (index) {
              final artikel = artikelen[index];
              final echteIndex = leverancier.artikelen.indexOf(artikel);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 34,
                      width: 34,
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        size: 18,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        artikel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Artikel wissen',
                      onPressed: () => wisArtikel(leverancier, echteIndex),
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leveranciers = leveranciersGesorteerd;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      bottomNavigationBar: OnderNavigatieBalk(
        huidigePagina: 'andere',
        onAgenda: () {
          Navigator.popUntil(context, (route) => route.isFirst);
          // later eventueel rechtstreeks naar agenda
        },
        onKlanten: () {
          Navigator.popUntil(context, (route) => route.isFirst);
          // later eventueel rechtstreeks naar klanten
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0B7A3B),
                    Color(0xFF23B15F),
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Leveranciers',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          toonNieuwLeverancierFormulier =
                              !toonNieuwLeverancierFormulier;
                        });
                      },
                      icon: const Icon(Icons.add),
                      color: Colors.green,
                      iconSize: 30,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Row(
                    children: [
                      statistiekKaart(
                        icoon: Icons.store,
                        titel: 'Totaal leveranciers',
                        waarde: '${widget.leveranciers.length}',
                        subtitel: 'Actieve leveranciers',
                        kleur: Colors.green,
                      ),
                      const SizedBox(width: 14),
                      statistiekKaart(
                        icoon: Icons.inventory_2_outlined,
                        titel: 'Artikelen',
                        waarde: '$aantalArtikelen',
                        subtitel: 'Gekoppelde artikelen',
                        kleur: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  zoekBalk(),
                  nieuwLeverancierFormulier(),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Text(
                        'Overzicht leveranciers',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${leveranciers.length} zichtbaar',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (leveranciers.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Text(
                        'Geen leverancier gevonden.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ...leveranciers.map(leverancierKaart),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  final String tekst;
  final Color kleur;

  const _ChipLabel({
    required this.tekst,
    required this.kleur,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: kleur.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        tekst,
        style: TextStyle(
          color: kleur,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
