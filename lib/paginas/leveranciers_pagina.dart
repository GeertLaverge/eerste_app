import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeveranciersPagina extends StatefulWidget {
  const LeveranciersPagina({super.key});

  @override
  State<LeveranciersPagina> createState() => _LeveranciersPaginaState();
}

class _LeveranciersPaginaState extends State<LeveranciersPagina> {
  static const groen = Color(0xFF0B7A3B);
  static const achtergrond = Color(0xFFF5F5F5);
  static const rand = Color(0xFFE5E7EB);

  final zoekController = TextEditingController();

  List<Leverancier> leveranciers = [];
  String zoekTekst = '';

  @override
  void initState() {
    super.initState();
    laadLeveranciers();
  }

  @override
  void dispose() {
    zoekController.dispose();
    super.dispose();
  }

  Future<void> laadLeveranciers() async {
    final prefs = await SharedPreferences.getInstance();
    final tekst = prefs.getString('leveranciers_lijst') ?? '[]';
    final lijst = jsonDecode(tekst) as List;

    setState(() {
      leveranciers = lijst.map((e) => Leverancier.fromJson(e)).toList();
    });
  }

  Future<void> bewaarLeveranciers() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'leveranciers_lijst',
      jsonEncode(
        leveranciers.map((e) => e.toJson()).toList(),
      ),
    );
  }

  List<Leverancier> get gefilterdeLeveranciers {
    if (zoekTekst.trim().isEmpty) return leveranciers;

    final zoek = zoekTekst.toLowerCase().replaceAll(' ', '');

    return leveranciers.where((leverancier) {
      final naam = leverancier.naam.toLowerCase().replaceAll(' ', '');
      return naam.contains(zoek) || _lijktOp(naam, zoek);
    }).toList();
  }

  bool _lijktOp(String tekst, String zoek) {
    if (zoek.length < 3) return false;

    int fouten = 0;
    final kortste = tekst.length < zoek.length ? tekst.length : zoek.length;

    for (int i = 0; i < kortste; i++) {
      if (tekst[i] != zoek[i]) fouten++;
      if (fouten > 2) return false;
    }

    return true;
  }

  Future<Leverancier?> _openLeverancierDialog({
    required String titel,
    Leverancier? bestaand,
  }) async {
    final naam = TextEditingController(text: bestaand?.naam ?? '');
    final straat = TextEditingController(text: bestaand?.straat ?? '');
    final huisNr = TextEditingController(text: bestaand?.huisNr ?? '');
    final postcode = TextEditingController(text: bestaand?.postcode ?? '');
    final gemeente = TextEditingController(text: bestaand?.gemeente ?? '');
    final telefoon = TextEditingController(text: bestaand?.telefoon ?? '');
    final gsm = TextEditingController(text: bestaand?.gsm ?? '');
    final email = TextEditingController(text: bestaand?.email ?? '');

    return showDialog<Leverancier>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titel,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _veld(naam, 'Naam leverancier'),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _veld(straat, 'Straat'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _veld(huisNr, 'Nr'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _veld(postcode, 'Postcode'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: _veld(gemeente, 'Gemeente'),
                      ),
                    ],
                  ),
                  _veld(telefoon, 'Vaste telefoon'),
                  _veld(gsm, 'GSM'),
                  _veld(email, 'Email'),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (naam.text.trim().isEmpty) return;

                        Navigator.pop(
                          context,
                          Leverancier(
                            naam: naam.text.trim(),
                            straat: straat.text.trim(),
                            huisNr: huisNr.text.trim(),
                            postcode: postcode.text.trim(),
                            gemeente: gemeente.text.trim(),
                            telefoon: telefoon.text.trim(),
                            gsm: gsm.text.trim(),
                            email: email.text.trim(),
                            artikelen: bestaand?.artikelen ?? [],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: groen,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 50),
                      ),
                      child: Text(bestaand == null ? 'Toevoegen' : 'Opslaan'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> leverancierToevoegen() async {
    final resultaat = await _openLeverancierDialog(
      titel: 'Leverancier toevoegen',
    );

    if (resultaat == null) return;

    setState(() {
      leveranciers.add(resultaat);
      leveranciers.sort((a, b) => a.naam.compareTo(b.naam));
    });

    await bewaarLeveranciers();
  }

  Future<void> leverancierWijzigen(Leverancier leverancier) async {
    final resultaat = await _openLeverancierDialog(
      titel: 'Leverancier wijzigen',
      bestaand: leverancier,
    );

    if (resultaat == null) return;

    setState(() {
      leverancier.naam = resultaat.naam;
      leverancier.straat = resultaat.straat;
      leverancier.huisNr = resultaat.huisNr;
      leverancier.postcode = resultaat.postcode;
      leverancier.gemeente = resultaat.gemeente;
      leverancier.telefoon = resultaat.telefoon;
      leverancier.gsm = resultaat.gsm;
      leverancier.email = resultaat.email;
      leveranciers.sort((a, b) => a.naam.compareTo(b.naam));
    });

    await bewaarLeveranciers();
  }

  Future<void> artikelToevoegen(Leverancier leverancier) async {
    final controller = TextEditingController();

    final artikel = await showDialog<String>(
      context: context,
      builder: (context) {
        return _ArtikelDialog(
          titel: 'Artikel toevoegen',
          controller: controller,
          knopTekst: 'Toevoegen',
        );
      },
    );

    if (artikel == null) return;

    setState(() {
      leverancier.artikelen.add(artikel);
      leverancier.artikelen.sort();
    });

    await bewaarLeveranciers();
  }

  Future<void> artikelWijzigen(
    Leverancier leverancier,
    String oudArtikel,
  ) async {
    final controller = TextEditingController(text: oudArtikel);

    final nieuwArtikel = await showDialog<String>(
      context: context,
      builder: (context) {
        return _ArtikelDialog(
          titel: 'Artikel wijzigen',
          controller: controller,
          knopTekst: 'Opslaan',
        );
      },
    );

    if (nieuwArtikel == null) return;

    setState(() {
      final index = leverancier.artikelen.indexOf(oudArtikel);

      if (index != -1) {
        leverancier.artikelen[index] = nieuwArtikel;
        leverancier.artikelen.sort();
      }
    });

    await bewaarLeveranciers();
  }

  Widget _veld(
    TextEditingController controller,
    String label,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: label,
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(0, 8, 0, 6),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: groen,
              width: 1.6,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lijst = gefilterdeLeveranciers;

    return Scaffold(
      backgroundColor: achtergrond,
      appBar: AppBar(
        title: const Text('Leveranciers'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: leverancierToevoegen,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: zoekController,
              onChanged: (waarde) {
                setState(() {
                  zoekTekst = waarde;
                });
              },
              decoration: InputDecoration(
                hintText: 'Zoek leverancier...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: rand),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: rand),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: lijst.isEmpty
                  ? const Center(
                      child: Text(
                        'Nog geen leveranciers',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: lijst.length,
                      itemBuilder: (context, index) {
                        final leverancier = lijst[index];

                        return _LeverancierKaart(
                          leverancier: leverancier,
                          onLeverancierWijzigen: () {
                            leverancierWijzigen(leverancier);
                          },
                          onArtikelToevoegen: () {
                            artikelToevoegen(leverancier);
                          },
                          onArtikelWijzigen: (artikel) {
                            artikelWijzigen(
                              leverancier,
                              artikel,
                            );
                          },
                          onArtikelVerwijderen: (artikel) async {
                            setState(() {
                              leverancier.artikelen.remove(artikel);
                            });
                            await bewaarLeveranciers();
                          },
                          onLeverancierVerwijderen: () async {
                            setState(() {
                              leveranciers.remove(leverancier);
                            });
                            await bewaarLeveranciers();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtikelDialog extends StatelessWidget {
  final String titel;
  final TextEditingController controller;
  final String knopTekst;

  const _ArtikelDialog({
    required this.titel,
    required this.controller,
    required this.knopTekst,
  });

  static const groen = Color(0xFF0B7A3B);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              titel,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Artikelnaam',
                isDense: true,
                contentPadding: const EdgeInsets.fromLTRB(0, 8, 0, 6),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: groen,
                    width: 1.6,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isEmpty) return;
                  Navigator.pop(context, controller.text.trim());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: groen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 50),
                ),
                child: Text(knopTekst),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeverancierKaart extends StatefulWidget {
  final Leverancier leverancier;
  final VoidCallback onLeverancierWijzigen;
  final VoidCallback onArtikelToevoegen;
  final Function(String artikel) onArtikelWijzigen;
  final Function(String artikel) onArtikelVerwijderen;
  final VoidCallback onLeverancierVerwijderen;

  const _LeverancierKaart({
    required this.leverancier,
    required this.onLeverancierWijzigen,
    required this.onArtikelToevoegen,
    required this.onArtikelWijzigen,
    required this.onArtikelVerwijderen,
    required this.onLeverancierVerwijderen,
  });

  @override
  State<_LeverancierKaart> createState() => _LeverancierKaartState();
}

class _LeverancierKaartState extends State<_LeverancierKaart> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _LeveranciersKleuren.rand),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                open = !open;
              });
            },
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
              child: Row(
                children: [
                  Icon(
                    open
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    color: _LeveranciersKleuren.groen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.leverancier.naam,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onLeverancierWijzigen,
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: _LeveranciersKleuren.groen,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  _info(
                    Icons.location_on_outlined,
                    widget.leverancier.adresTekst,
                  ),
                  _info(Icons.phone_outlined, widget.leverancier.telefoon),
                  _info(Icons.smartphone_outlined, widget.leverancier.gsm),
                  _info(Icons.email_outlined, widget.leverancier.email),
                  const SizedBox(height: 10),
                  const Text(
                    'Artikelen',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (widget.leverancier.artikelen.isEmpty)
                    const Text(
                      'Nog geen artikelen',
                      style: TextStyle(
                        color: Colors.black45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ...widget.leverancier.artikelen.map((artikel) {
                    return Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              widget.onArtikelWijzigen(artikel);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 7,
                              ),
                              child: Text(
                                '• $artikel',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            widget.onArtikelVerwijderen(artikel);
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onArtikelToevoegen,
                          icon: const Icon(Icons.add),
                          label: const Text('Artikel toevoegen'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: widget.onLeverancierVerwijderen,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _info(IconData icoon, String tekst) {
    if (tekst.trim().isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(
            icoon,
            size: 17,
            color: _LeveranciersKleuren.groen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tekst,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeveranciersKleuren {
  static const groen = Color(0xFF0B7A3B);
  static const rand = Color(0xFFE5E7EB);
}

class Leverancier {
  String naam;
  String straat;
  String huisNr;
  String postcode;
  String gemeente;
  String telefoon;
  String gsm;
  String email;
  final List<String> artikelen;

  Leverancier({
    required this.naam,
    this.straat = '',
    this.huisNr = '',
    this.postcode = '',
    this.gemeente = '',
    required this.telefoon,
    required this.gsm,
    required this.email,
    required this.artikelen,
  });

  String get adresTekst {
    final straatRegel = '$straat $huisNr'.trim();
    final gemeenteRegel = '$postcode $gemeente'.trim();

    return [
      if (straatRegel.isNotEmpty) straatRegel,
      if (gemeenteRegel.isNotEmpty) gemeenteRegel,
    ].join(', ');
  }

  Map<String, dynamic> toJson() {
    return {
      'naam': naam,
      'straat': straat,
      'huisNr': huisNr,
      'postcode': postcode,
      'gemeente': gemeente,
      'telefoon': telefoon,
      'gsm': gsm,
      'email': email,
      'artikelen': artikelen,
    };
  }

  factory Leverancier.fromJson(Map<String, dynamic> json) {
    return Leverancier(
      naam: json['naam'] ?? '',
      straat: json['straat'] ?? '',
      huisNr: json['huisNr'] ?? '',
      postcode: json['postcode'] ?? '',
      gemeente: json['gemeente'] ?? '',
      telefoon: json['telefoon'] ?? '',
      gsm: json['gsm'] ?? '',
      email: json['email'] ?? '',
      artikelen: List<String>.from(json['artikelen'] ?? []),
    );
  }
}
