import 'package:flutter/material.dart';

import '../../lib/modellen/klant.dart';
import '../../lib/helpers/widgets/onder_navigatie_balk.dart';

enum PuinzakStap { keuze, afmelden, bestellen, controle, succes }

class PuinzakPagina extends StatefulWidget {
  final List<Klant> actieveKlanten;
  final Future<void> Function() onGewijzigd;

  const PuinzakPagina({
    super.key,
    required this.actieveKlanten,
    required this.onGewijzigd,
  });

  @override
  State<PuinzakPagina> createState() => _PuinzakPaginaState();
}

class _PuinzakPaginaState extends State<PuinzakPagina> {
  PuinzakStap stap = PuinzakStap.keuze;

  bool bijKlant = true;
  Klant? gekozenKlant;
  int aantal = 1;
  bool isBestellen = false;

  void toonFout(String tekst) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tekst), backgroundColor: Colors.red),
    );
  }

  Widget groeneBalk() {
    return Container(
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
              'Puinzak afmelden',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget kaart(Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget titelBlok(String titel, String subtitel) {
    return kaart(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titel,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (subtitel.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(subtitel, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ],
      ),
    );
  }

  Widget actieKnop(String tekst, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(tekst),
      ),
    );
  }

  Widget keuzeKnop(String titel, IconData icoon, VoidCallback onTap) {
    return Material(
      color: Colors.green.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(icoon, color: Colors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget aantalSelector() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            if (aantal > 1) setState(() => aantal--);
          },
          icon: const Icon(Icons.remove),
        ),
        Expanded(
          child: Center(
            child: Text(
              '$aantal',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        IconButton(
          onPressed: () => setState(() => aantal++),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget schermKeuze() {
    return Column(
      children: [
        keuzeKnop('Puinzak bestellen', Icons.local_shipping, () {
          setState(() {
            stap = PuinzakStap.bestellen;
            isBestellen = true;
            aantal = 1;
          });
        }),
        const SizedBox(height: 10),
        keuzeKnop('Puinzak afmelden', Icons.delete_outline, () {
          setState(() {
            stap = PuinzakStap.afmelden;
            isBestellen = false;
            aantal = 1;
          });
        }),
      ],
    );
  }

  Widget schermAfmelden() {
    return Column(
      children: [
        titelBlok('Afmelden', 'Waar staat de puinzak?'),
        kaart(
          Column(
            children: [
              RadioListTile<bool>(
                value: false,
                groupValue: bijKlant,
                title: const Text('In atelier'),
                onChanged: (_) {
                  setState(() {
                    bijKlant = false;
                    gekozenKlant = null;
                  });
                },
              ),
              RadioListTile<bool>(
                value: true,
                groupValue: bijKlant,
                title: const Text('Bij klant'),
                onChanged: (_) {
                  setState(() {
                    bijKlant = true;
                  });
                },
              ),
            ],
          ),
        ),
        if (bijKlant)
          kaart(
            DropdownButtonFormField<Klant>(
              value: gekozenKlant,
              hint: const Text('Kies klant'),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              items: widget.actieveKlanten.map((klant) {
                return DropdownMenuItem<Klant>(
                  value: klant,
                  child: Text(
                    klant.klantnaam.isEmpty
                        ? 'Klant zonder naam'
                        : klant.klantnaam,
                  ),
                );
              }).toList(),
              onChanged: (waarde) {
                setState(() {
                  gekozenKlant = waarde;
                });
              },
            ),
          ),
        titelBlok('Aantal', 'Hoeveel puinzakken afmelden'),
        kaart(aantalSelector()),
        actieKnop('Afmelden', () {
          if (aantal <= 0) {
            toonFout('Geef een geldig aantal in');
            return;
          }

          if (bijKlant && gekozenKlant == null) {
            toonFout('Kies eerst een klant');
            return;
          }

          setState(() => stap = PuinzakStap.controle);
        }),
      ],
    );
  }

  Widget schermBestellen() {
    return Column(
      children: [
        titelBlok('Bestellen', 'Aantal puinzakken bestellen'),
        kaart(aantalSelector()),
        actieKnop('Bestellen', () {
          if (aantal <= 0) {
            toonFout('Geef een geldig aantal in');
            return;
          }

          setState(() => stap = PuinzakStap.controle);
        }),
      ],
    );
  }

  Widget schermControle() {
    return Column(
      children: [
        titelBlok('Controle', 'Controleer je gegevens'),
        kaart(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isBestellen
                    ? 'Actie: Puinzak bestellen'
                    : 'Actie: Puinzak afmelden',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (!isBestellen)
                Text('Locatie: ${bijKlant ? "Bij klant" : "In atelier"}'),
              if (!isBestellen && bijKlant && gekozenKlant != null)
                Text('Klant: ${gekozenKlant!.klantnaam}'),
              Text('Aantal: $aantal'),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    stap = isBestellen
                        ? PuinzakStap.bestellen
                        : PuinzakStap.afmelden;
                  });
                },
                child: const Text('Annuleren'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() => stap = PuinzakStap.succes);
                },
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget schermSucces() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.check_circle, color: Colors.green, size: 80),
        const SizedBox(height: 20),
        Text(
          isBestellen ? 'Puinzakken besteld' : 'Puinzakken afgemeld',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text('Aantal: $aantal'),
        const SizedBox(height: 30),
        actieKnop('Terug naar start', () {
          Navigator.pop(context);
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (stap) {
      case PuinzakStap.keuze:
        content = schermKeuze();
        break;
      case PuinzakStap.afmelden:
        content = schermAfmelden();
        break;
      case PuinzakStap.bestellen:
        content = schermBestellen();
        break;
      case PuinzakStap.controle:
        content = schermControle();
        break;
      case PuinzakStap.succes:
        content = schermSucces();
        break;
    }

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
            groeneBalk(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [content],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
