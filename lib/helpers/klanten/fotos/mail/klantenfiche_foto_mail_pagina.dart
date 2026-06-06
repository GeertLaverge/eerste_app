import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../fiche/klantenfiche_model.dart';
import '../klantenfiche_foto_service.dart';
import 'klantenfiche_foto_mail_service.dart';

class KlantenficheFotoMailPagina extends StatefulWidget {
  final String ficheId;
  final List<KlantenficheFoto> fotos;

  const KlantenficheFotoMailPagina({
    super.key,
    required this.ficheId,
    required this.fotos,
  });

  @override
  State<KlantenficheFotoMailPagina> createState() =>
      _KlantenficheFotoMailPaginaState();
}

class _KlantenficheFotoMailPaginaState
    extends State<KlantenficheFotoMailPagina> {
  static const groen = Color(0xFF0B7A3B);
  static const rand = Color(0xFFE5E7EB);

  final berichtController = TextEditingController();
  final zoekController = TextEditingController();

  final Set<String> geselecteerdeFotos = {};

  List<_MailLeverancier> leveranciers = [];
  String zoekterm = '';
  _MailLeverancier? gekozenLeverancier;

  @override
  void initState() {
    super.initState();
    _laadLeveranciers();
  }

  @override
  void dispose() {
    berichtController.dispose();
    zoekController.dispose();
    super.dispose();
  }

  Future<void> _laadLeveranciers() async {
    final prefs = await SharedPreferences.getInstance();
    final tekst = prefs.getString('leveranciers_lijst') ?? '[]';
    final lijst = jsonDecode(tekst) as List;

    setState(() {
      leveranciers = lijst
          .map((e) => _MailLeverancier.fromJson(e))
          .where((l) => l.email.trim().isNotEmpty)
          .toList()
        ..sort((a, b) => a.naam.compareTo(b.naam));
    });
  }

  List<_MailLeverancier> get gefilterdeLeveranciers {
    final zoek = zoekterm.trim().toLowerCase();

    if (zoek.isEmpty) return leveranciers;

    return leveranciers.where((l) {
      return l.naam.toLowerCase().contains(zoek) ||
          l.email.toLowerCase().contains(zoek);
    }).toList();
  }

  Future<void> _versturen() async {
    if (gekozenLeverancier == null) {
      _melding(
        'Kies eerst een leverancier.',
        fout: true,
      );
      return;
    }

    if (geselecteerdeFotos.isEmpty) {
      _melding(
        'Selecteer minstens één foto.',
        fout: true,
      );
      return;
    }

    final bestanden = <File>[];

    for (final foto in widget.fotos) {
      if (!geselecteerdeFotos.contains(foto.bestandsNaam)) continue;

      final bestand = await KlantenficheFotoService.fotoBestand(
        ficheId: widget.ficheId,
        foto: foto,
      );

      bestanden.add(bestand);
    }

    final resultaat = await KlantenficheFotoMailService().verstuurMail(
      fotos: bestanden,
      ontvanger: gekozenLeverancier!.email,
      onderwerp: 'Foto\'s en werfinstructies',
      bericht: berichtController.text.trim(),
    );

    if (!mounted) return;

    if (resultaat == 'MAIL_OK') {
      _melding('Mail verzonden.');
      Navigator.pop(context);
    } else {
      _melding(
        resultaat,
        fout: true,
      );
    }
  }

  void _melding(
    String tekst, {
    bool fout = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tekst),
        backgroundColor: fout ? Colors.red : groen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lijst = gefilterdeLeveranciers;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Foto\'s mailen'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _versturen,
            child: const Text(
              'Versturen',
              style: TextStyle(
                color: groen,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text(
            'Selecteer foto\'s',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ...widget.fotos.map((foto) {
            final geselecteerd = geselecteerdeFotos.contains(foto.bestandsNaam);

            return FutureBuilder<File>(
              future: KlantenficheFotoService.fotoBestand(
                ficheId: widget.ficheId,
                foto: foto,
              ),
              builder: (context, snapshot) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: rand),
                  ),
                  child: CheckboxListTile(
                    value: geselecteerd,
                    activeColor: groen,
                    onChanged: (waarde) {
                      setState(() {
                        if (waarde == true) {
                          geselecteerdeFotos.add(foto.bestandsNaam);
                        } else {
                          geselecteerdeFotos.remove(foto.bestandsNaam);
                        }
                      });
                    },
                    title: Text(foto.bestandsNaam),
                    subtitle: Text(foto.datum),
                    secondary: snapshot.hasData
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              snapshot.data!,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const SizedBox(
                            width: 52,
                            height: 52,
                          ),
                  ),
                );
              },
            );
          }),
          const SizedBox(height: 14),
          const Text(
            'Bericht',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: berichtController,
            minLines: 4,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: 'Typ uitleg bij de foto\'s...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: rand),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: rand),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: groen,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Leverancier',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: zoekController,
            onChanged: (waarde) {
              setState(() {
                zoekterm = waarde;
              });
            },
            decoration: InputDecoration(
              hintText: 'Zoek leverancier...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: rand),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: rand),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...lijst.map((leverancier) {
            final gekozen = gekozenLeverancier?.email == leverancier.email;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: gekozen ? groen : rand,
                  width: gekozen ? 2 : 1,
                ),
              ),
              child: ListTile(
                onTap: () {
                  setState(() {
                    gekozenLeverancier = leverancier;
                  });
                },
                leading: Icon(
                  gekozen ? Icons.check_circle : Icons.circle_outlined,
                  color: gekozen ? groen : Colors.grey,
                ),
                title: Text(
                  leverancier.naam,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(leverancier.email),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MailLeverancier {
  final String naam;
  final String email;

  const _MailLeverancier({
    required this.naam,
    required this.email,
  });

  factory _MailLeverancier.fromJson(dynamic json) {
    return _MailLeverancier(
      naam: json['naam'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
