import 'package:flutter/material.dart';

import '../../../../modellen/klant.dart';
import '../../../../modellen/klant_artikel.dart';
import '../../../../modellen/leverancier.dart';

import '../../klantenfiche/schakel_balk.dart';

class LeveranciersBlok extends StatefulWidget {
  final Klant klant;
  final List<Leverancier> leveranciers;

  final Future<void> Function() onChanged;

  final Function(bool) wijzigGeenArtikelsNodig;
  final VoidCallback voegLeverancierToe;
  final Function(int) wisLeverancier;
  final Function(KlantLeverancier) voegArtikelToe;
  final Function(KlantLeverancier, int) wisArtikel;

  const LeveranciersBlok({
    super.key,
    required this.klant,
    required this.leveranciers,
    required this.onChanged,
    required this.wijzigGeenArtikelsNodig,
    required this.voegLeverancierToe,
    required this.wisLeverancier,
    required this.voegArtikelToe,
    required this.wisArtikel,
  });

  @override
  State<LeveranciersBlok> createState() => _LeveranciersBlokState();
}

class _LeveranciersBlokState extends State<LeveranciersBlok> {
  String? gekozenLeverancier;
  String? gekozenArtikel;

  List<Leverancier> get leveranciersGesorteerd {
    final lijst = [...widget.leveranciers];
    lijst.sort((a, b) => a.naam.toLowerCase().compareTo(b.naam.toLowerCase()));
    return lijst;
  }

  List<String> artikelenVanLeverancier(String? leverancierNaam) {
    if (leverancierNaam == null || leverancierNaam.isEmpty) return [];

    final leverancier = widget.leveranciers.firstWhere(
      (item) => item.naam == leverancierNaam,
      orElse: () => Leverancier(naam: '', artikelen: []),
    );

    final artikelen = [...leverancier.artikelen];
    artikelen.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return artikelen;
  }

  List<_ArtikelLijn> get gekozenLijnenGesorteerd {
    final lijnen = <_ArtikelLijn>[];

    for (final leverancier in widget.klant.klantLeveranciers) {
      for (var i = 0; i < leverancier.gekozenArtikelen.length; i++) {
        lijnen.add(
          _ArtikelLijn(
            leverancier: leverancier,
            artikel: leverancier.gekozenArtikelen[i],
            artikelIndex: i,
          ),
        );
      }
    }

    lijnen.sort((a, b) {
      final leverancierVergelijk = a.leverancier.leverancierNaam
          .toLowerCase()
          .compareTo(b.leverancier.leverancierNaam.toLowerCase());

      if (leverancierVergelijk != 0) return leverancierVergelijk;

      return a.artikel.artikelNaam
          .toLowerCase()
          .compareTo(b.artikel.artikelNaam.toLowerCase());
    });

    return lijnen;
  }

  Future<void> voegGekozenLeverancierArtikelToe() async {
    if (gekozenLeverancier == null || gekozenArtikel == null) return;

    KlantLeverancier klantLeverancier;

    final bestaandeIndex = widget.klant.klantLeveranciers.indexWhere(
      (item) => item.leverancierNaam == gekozenLeverancier,
    );

    if (bestaandeIndex == -1) {
      klantLeverancier = KlantLeverancier(
        leverancierNaam: gekozenLeverancier!,
        gekozenArtikelen: [],
      );

      widget.klant.klantLeveranciers.add(klantLeverancier);
    } else {
      klantLeverancier = widget.klant.klantLeveranciers[bestaandeIndex];
    }

    final bestaatAl = klantLeverancier.gekozenArtikelen.any(
      (artikel) => artikel.artikelNaam == gekozenArtikel,
    );

    if (!bestaatAl) {
      klantLeverancier.gekozenArtikelen.add(
        KlantArtikel(
          artikelNaam: gekozenArtikel!,
        ),
      );
    }

    widget.klant.geenArtikelsNodig = false;

    setState(() {
      gekozenArtikel = null;
    });

    await widget.onChanged();
  }

  Future<void> wijzigBesteld(KlantArtikel artikel, bool waarde) async {
    setState(() {
      artikel.besteld = waarde;

      if (!waarde) {
        artikel.geleverd = false;
      }
    });

    await widget.onChanged();
  }

  Future<void> wijzigGeleverd(KlantArtikel artikel, bool waarde) async {
    setState(() {
      artikel.geleverd = waarde;

      if (waarde) {
        artikel.besteld = true;
      }
    });

    await widget.onChanged();
  }

  Future<void> wisLijn(_ArtikelLijn lijn) async {
    lijn.leverancier.gekozenArtikelen.removeAt(lijn.artikelIndex);

    if (lijn.leverancier.gekozenArtikelen.isEmpty) {
      widget.klant.klantLeveranciers.remove(lijn.leverancier);
    }

    setState(() {});

    await widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final artikelen = artikelenVanLeverancier(gekozenLeverancier);
    final kanToevoegen = gekozenLeverancier != null && gekozenArtikel != null;
    final lijnen = gekozenLijnenGesorteerd;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SchakelBalk(
          titel: 'Geen artikels nodig',
          subtitel: widget.klant.geenArtikelsNodig
              ? 'Alles verborgen'
              : 'Schakel aan indien niets nodig',
          icoon: Icons.check_circle_outline,
          waarde: widget.klant.geenArtikelsNodig,
          onChanged: widget.wijzigGeenArtikelsNodig,
        ),
        if (!widget.klant.geenArtikelsNodig) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: gekozenLeverancier,
                  decoration: _veldDecoratie(
                    label: 'Leverancier',
                    icon: Icons.business,
                  ),
                  items: leveranciersGesorteerd.map((leverancier) {
                    return DropdownMenuItem<String>(
                      value: leverancier.naam,
                      child: Text(
                        leverancier.naam,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (waarde) {
                    setState(() {
                      gekozenLeverancier = waarde;
                      gekozenArtikel = null;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: gekozenArtikel,
                  decoration: _veldDecoratie(
                    label: 'Artikel',
                    icon: Icons.inventory_2_outlined,
                  ),
                  items: artikelen.map((artikel) {
                    return DropdownMenuItem<String>(
                      value: artikel,
                      child: Text(
                        artikel,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: gekozenLeverancier == null
                      ? null
                      : (waarde) {
                          setState(() {
                            gekozenArtikel = waarde;
                          });
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: kanToevoegen ? voegGekozenLeverancierArtikelToe : null,
              icon: const Icon(Icons.add),
              label: const Text('Leverancier / artikel toevoegen'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (lijnen.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Text(
                'Nog geen leveranciers of artikelen toegevoegd.',
                textAlign: TextAlign.center,
              ),
            )
          else
            Column(
              children: [
                _LijstTitel(),
                const SizedBox(height: 8),
                ...lijnen.map((lijn) {
                  return _ArtikelRij(
                    leverancierNaam: lijn.leverancier.leverancierNaam,
                    artikelNaam: lijn.artikel.artikelNaam,
                    besteld: lijn.artikel.besteld,
                    geleverd: lijn.artikel.geleverd,
                    onBesteldChanged: (waarde) {
                      wijzigBesteld(lijn.artikel, waarde ?? false);
                    },
                    onGeleverdChanged: (waarde) {
                      wijzigGeleverd(lijn.artikel, waarde ?? false);
                    },
                    onVerwijderen: () {
                      wisLijn(lijn);
                    },
                  );
                }),
              ],
            ),
        ],
      ],
    );
  }

  InputDecoration _veldDecoratie({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
          color: Colors.blueGrey,
          width: 2,
        ),
      ),
    );
  }
}

class _LijstTitel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          flex: 3,
          child: Text(
            'Leverancier',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            'Artikel',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(width: 78, child: Text('Besteld')),
        SizedBox(width: 82, child: Text('Geleverd')),
        SizedBox(width: 42),
      ],
    );
  }
}

class _ArtikelRij extends StatelessWidget {
  final String leverancierNaam;
  final String artikelNaam;
  final bool besteld;
  final bool geleverd;
  final ValueChanged<bool?> onBesteldChanged;
  final ValueChanged<bool?> onGeleverdChanged;
  final VoidCallback onVerwijderen;

  const _ArtikelRij({
    required this.leverancierNaam,
    required this.artikelNaam,
    required this.besteld,
    required this.geleverd,
    required this.onBesteldChanged,
    required this.onGeleverdChanged,
    required this.onVerwijderen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              leverancierNaam,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              artikelNaam,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 78,
            child: Checkbox(
              value: besteld,
              onChanged: onBesteldChanged,
            ),
          ),
          SizedBox(
            width: 82,
            child: Checkbox(
              value: geleverd,
              onChanged: besteld ? onGeleverdChanged : null,
            ),
          ),
          SizedBox(
            width: 42,
            child: IconButton(
              tooltip: 'Verwijderen',
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              onPressed: onVerwijderen,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtikelLijn {
  final KlantLeverancier leverancier;
  final KlantArtikel artikel;
  final int artikelIndex;

  const _ArtikelLijn({
    required this.leverancier,
    required this.artikel,
    required this.artikelIndex,
  });
}
