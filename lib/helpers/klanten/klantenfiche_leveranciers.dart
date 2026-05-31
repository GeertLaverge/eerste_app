import 'package:flutter/material.dart';

import 'klanten_leverancier_service.dart';

class KlantenficheLeveranciers extends StatefulWidget {
  const KlantenficheLeveranciers({
    super.key,
  });

  @override
  State<KlantenficheLeveranciers> createState() =>
      _KlantenficheLeveranciersState();
}

class _KlantenficheLeveranciersState extends State<KlantenficheLeveranciers> {
  List<KlantenLeverancier> leveranciers = [];

  String? geselecteerdeLeverancier;
  String? geselecteerdArtikel;
  final geselecteerdeArtikelen = <KlantenArtikelRegel>[];

  @override
  void initState() {
    super.initState();
    laadLeveranciers();
  }

  Future<void> laadLeveranciers() async {
    final lijst = await KlantenLeverancierService.laadLeveranciers();

    if (!mounted) return;

    setState(() {
      leveranciers = lijst;
    });
  }

  List<String> get artikelen {
    if (geselecteerdeLeverancier == null) {
      return [];
    }

    final leverancier = leveranciers.firstWhere(
      (l) => l.naam == geselecteerdeLeverancier,
    );

    return leverancier.artikelen;
  }

  String get bestelStatusTekst {
    if (geselecteerdeArtikelen.isEmpty) {
      return 'Geen artikels';
    }

    final allesGeleverd =
        geselecteerdeArtikelen.every((regel) => regel.geleverd);

    final allesBesteld = geselecteerdeArtikelen.every((regel) => regel.besteld);

    if (allesGeleverd) return 'Alles geleverd';
    if (allesBesteld) return 'Alles besteld';

    return 'Niet alles besteld';
  }

  Color get bestelStatusKleur {
    if (geselecteerdeArtikelen.isEmpty) {
      return Colors.grey;
    }

    final allesGeleverd =
        geselecteerdeArtikelen.every((regel) => regel.geleverd);

    final allesBesteld = geselecteerdeArtikelen.every((regel) => regel.besteld);

    if (allesGeleverd) {
      return const Color(0xFF0B7A3B);
    }

    if (allesBesteld) {
      return Colors.blue;
    }

    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: geselecteerdeLeverancier,
                decoration: const InputDecoration(
                  labelText: 'Leverancier',
                ),
                items: leveranciers.map((leverancier) {
                  return DropdownMenuItem(
                    value: leverancier.naam,
                    child: Text(
                      leverancier.naam,
                    ),
                  );
                }).toList(),
                onChanged: (waarde) {
                  setState(() {
                    geselecteerdeLeverancier = waarde;
                    geselecteerdArtikel = null;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: geselecteerdArtikel,
                decoration: const InputDecoration(
                  labelText: 'Artikel',
                ),
                items: artikelen.map((artikel) {
                  return DropdownMenuItem(
                    value: artikel,
                    child: Text(
                      artikel,
                    ),
                  );
                }).toList(),
                onChanged: (waarde) {
                  setState(() {
                    geselecteerdArtikel = waarde;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              if (geselecteerdeLeverancier == null ||
                  geselecteerdArtikel == null) {
                return;
              }

              setState(() {
                geselecteerdeArtikelen.add(
                  KlantenArtikelRegel(
                    leverancier: geselecteerdeLeverancier!,
                    artikel: geselecteerdArtikel!,
                  ),
                );
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Toevoegen'),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: bestelStatusKleur.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: bestelStatusKleur.withOpacity(0.35),
            ),
          ),
          child: Text(
            bestelStatusTekst,
            style: TextStyle(
              color: bestelStatusKleur,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...geselecteerdeArtikelen.map((regel) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${regel.leverancier} · ${regel.artikel}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      'Besteld',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Checkbox(
                      value: regel.geleverd,
                      activeColor: const Color(0xFF0B7A3B),
                      onChanged: regel.besteld
                          ? (waarde) {
                              setState(() {
                                regel.geleverd = waarde ?? false;
                              });
                            }
                          : null,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Geleverd',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Checkbox(
                      value: regel.geleverd,
                      onChanged: (waarde) {
                        setState(() {
                          regel.geleverd = waarde ?? false;

                          if (regel.geleverd) {
                            regel.besteld = true;
                          }
                        });
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        final bestaatAl = geselecteerdeArtikelen.any(
                          (regel) =>
                              regel.leverancier == geselecteerdeLeverancier &&
                              regel.artikel == geselecteerdArtikel,
                        );

                        if (bestaatAl) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Artikel staat reeds in de lijst',
                              ),
                            ),
                          );
                          return;
                        }
                        setState(() {
                          geselecteerdeArtikelen.remove(regel);
                        });
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class KlantenArtikelRegel {
  String leverancier;
  String artikel;

  bool besteld;
  bool geleverd;

  KlantenArtikelRegel({
    required this.leverancier,
    required this.artikel,
    this.besteld = false,
    this.geleverd = false,
  });
}
