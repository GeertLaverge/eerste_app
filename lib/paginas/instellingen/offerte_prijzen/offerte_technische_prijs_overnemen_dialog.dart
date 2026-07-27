// THIMACO-CONTROLE: HERSTEL-KOPPELMODUS-FASE-4-20260727
// THIMACO-CONTROLE: GEKOPPELDE-TECHNISCHE-PRIJSREGELS-FASE-4-20260727
// THIMACO-CONTROLE: TECHNISCHE-PRIJS-OVERNEMEN-FASE-3-20260727
import 'package:flutter/material.dart';

import '../../../helpers/offerte/prijzen/offerte_artikel_prijs_koppeling_service.dart';
import '../../../helpers/offerte/prijzen/offerte_prijsregel_model.dart';
import '../../../helpers/offerte/prijzen/offerte_technische_keuze_ref.dart';

enum OfferteTechnischePrijsOvernameConflictmodus {
  alleenOntbrekende,
  bestaandeVervangen,
}

enum OfferteTechnischePrijsOvernameKoppelmodus { gekoppeld, afzonderlijk }

class OfferteTechnischePrijsOvernameKandidaat {
  const OfferteTechnischePrijsOvernameKandidaat({
    required this.doelKeuze,
    required this.bronPrijsregel,
    this.bestaandePrijsregel,
  });

  final OfferteTechnischeKeuzeRef doelKeuze;
  final OffertePrijsregelModel bronPrijsregel;
  final OffertePrijsregelModel? bestaandePrijsregel;

  bool get heeftBestaandePrijs => bestaandePrijsregel != null;
}

class OfferteTechnischePrijsOvernameGroep {
  OfferteTechnischePrijsOvernameGroep({
    required this.titel,
    required List<OfferteTechnischePrijsOvernameKandidaat> kandidaten,
    required this.aantalKeuzes,
    this.aantalMogelijkeTekstOvereenkomsten = 0,
    this.aantalZonderBron = 0,
    this.enkeleKeuze = false,
  }) : kandidaten = List<OfferteTechnischePrijsOvernameKandidaat>.unmodifiable(
         kandidaten,
       );

  final String titel;
  final List<OfferteTechnischePrijsOvernameKandidaat> kandidaten;
  final int aantalKeuzes;
  final int aantalMogelijkeTekstOvereenkomsten;
  final int aantalZonderBron;
  final bool enkeleKeuze;

  int get aantalOntbrekende {
    return kandidaten
        .where((kandidaat) => !kandidaat.heeftBestaandePrijs)
        .length;
  }

  int get aantalBestaande {
    return kandidaten
        .where((kandidaat) => kandidaat.heeftBestaandePrijs)
        .length;
  }
}

class OfferteTechnischePrijsOvernameResultaat {
  const OfferteTechnischePrijsOvernameResultaat({
    required this.conflictmodus,
    required this.koppelmodus,
  });

  final OfferteTechnischePrijsOvernameConflictmodus conflictmodus;
  final OfferteTechnischePrijsOvernameKoppelmodus koppelmodus;
}

Future<OfferteTechnischePrijsOvernameResultaat?>
toonOfferteTechnischePrijsOvernemenDialog({
  required BuildContext context,
  required OfferteTechnischePrijsOvernameGroep groep,
}) {
  return showDialog<OfferteTechnischePrijsOvernameResultaat>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _OfferteTechnischePrijsOvernemenDialog(groep: groep),
  );
}

class _OfferteTechnischePrijsOvernemenDialog extends StatefulWidget {
  const _OfferteTechnischePrijsOvernemenDialog({required this.groep});

  final OfferteTechnischePrijsOvernameGroep groep;

  @override
  State<_OfferteTechnischePrijsOvernemenDialog> createState() {
    return _OfferteTechnischePrijsOvernemenDialogState();
  }
}

class _OfferteTechnischePrijsOvernemenDialogState
    extends State<_OfferteTechnischePrijsOvernemenDialog> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _blauw = Color(0xFF2563EB);
  static const Color _oranje = Color(0xFFB45309);
  static const Color _rood = Color(0xFFDC2626);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  OfferteTechnischePrijsOvernameConflictmodus _conflictmodus =
      OfferteTechnischePrijsOvernameConflictmodus.alleenOntbrekende;
  OfferteTechnischePrijsOvernameKoppelmodus _koppelmodus =
      OfferteTechnischePrijsOvernameKoppelmodus.gekoppeld;

  OfferteTechnischePrijsOvernameGroep get _groep => widget.groep;

  int get _aantalTeVerwerken {
    if (_conflictmodus ==
        OfferteTechnischePrijsOvernameConflictmodus.bestaandeVervangen) {
      return _groep.kandidaten.length;
    }

    return _groep.aantalOntbrekende;
  }

  @override
  Widget build(BuildContext context) {
    final titel = _groep.enkeleKeuze
        ? 'Prijsregel overnemen?'
        : '${_groep.titel} overnemen';

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(22, 20, 18, 0),
      contentPadding: const EdgeInsets.fromLTRB(22, 16, 22, 4),
      actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.call_received_rounded,
              color: _blauw,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  titel,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Prijs beschikbaar vanuit een ander artikeltype',
                  style: TextStyle(
                    color: _tekstGrijs,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Sluiten',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      content: SizedBox(
        width: 590,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (_groep.enkeleKeuze)
                _bouwEnkeleKeuzeVoorbeeld()
              else
                _bouwGroepSamenvatting(),
              const SizedBox(height: 14),
              _bouwKoppelkeuze(),
              if (_groep.aantalBestaande > 0) ...<Widget>[
                const SizedBox(height: 14),
                _bouwConflictkeuze(),
              ],
              const SizedBox(height: 14),
              _bouwOvernameUitleg(),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuleren'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: _groen),
          onPressed: _aantalTeVerwerken <= 0 ? null : _bevestig,
          icon: const Icon(Icons.download_done_rounded, size: 18),
          label: Text(_bevestigTekst()),
        ),
      ],
    );
  }

  Widget _bouwEnkeleKeuzeVoorbeeld() {
    final kandidaat = _groep.kandidaten.first;
    final bron = kandidaat.bronPrijsregel;
    final doel = kandidaat.doelKeuze;
    final bronNaam = OfferteArtikelPrijsKoppelingService.formulierNaamVoor(
      bron.formulierType,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rand),
      ),
      child: Column(
        children: <Widget>[
          _bouwInfoRegel('Bron', bronNaam),
          _bouwInfoRegel('Technische keuze', _keuzeNaam(doel)),
          _bouwInfoRegel('Prijs', _prijsTekst(bron)),
          _bouwInfoRegel('Hoe uitschrijven', bron.uitschrijfmodus.benaming),
        ],
      ),
    );
  }

  Widget _bouwGroepSamenvatting() {
    final voorbeelden = _groep.kandidaten.take(6).toList(growable: false);
    final overige = _groep.kandidaten.length - voorbeelden.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _rand),
          ),
          child: Column(
            children: <Widget>[
              _bouwSamenvattingsRegel(
                icoon: Icons.account_tree_outlined,
                label: 'Technische keuzes in groep',
                waarde: _groep.aantalKeuzes,
              ),
              _bouwSamenvattingsRegel(
                icoon: Icons.call_received_rounded,
                label: 'Exacte prijzen beschikbaar',
                waarde: _groep.kandidaten.length,
                kleur: _blauw,
              ),
              _bouwSamenvattingsRegel(
                icoon: Icons.add_circle_outline_rounded,
                label: 'Nog zonder eigen prijs',
                waarde: _groep.aantalOntbrekende,
                kleur: _groen,
              ),
              _bouwSamenvattingsRegel(
                icoon: Icons.check_circle_outline_rounded,
                label: 'Hebben reeds een eigen prijs',
                waarde: _groep.aantalBestaande,
                kleur: _oranje,
              ),
              if (_groep.aantalMogelijkeTekstOvereenkomsten > 0)
                _bouwSamenvattingsRegel(
                  icoon: Icons.warning_amber_rounded,
                  label: 'Alleen mogelijke tekstovereenkomst',
                  waarde: _groep.aantalMogelijkeTekstOvereenkomsten,
                  kleur: _oranje,
                ),
              if (_groep.aantalZonderBron > 0)
                _bouwSamenvattingsRegel(
                  icoon: Icons.link_off_rounded,
                  label: 'Geen prijsbron gevonden',
                  waarde: _groep.aantalZonderBron,
                  kleur: _tekstGrijs,
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Gevonden prijsregels',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 7),
        ...voorbeelden.map(_bouwKandidaatRij),
        if (overige > 0)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              'En nog $overige prijsregels…',
              style: const TextStyle(
                color: _tekstGrijs,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _bouwKoppelkeuze() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 5, 8, 7),
            child: Text(
              'Manier van overnemen',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
            ),
          ),
          _bouwKoppelOptie(
            waarde: OfferteTechnischePrijsOvernameKoppelmodus.gekoppeld,
            titel: 'Gekoppeld overnemen',
            uitleg:
                'Aanbevolen: prijs, eenheid, uitschrijfwijze en actiefstatus '
                'blijven gelijk bij alle gekoppelde artikeltypes.',
            icoon: Icons.link_rounded,
            kleur: _blauw,
          ),
          const SizedBox(height: 5),
          _bouwKoppelOptie(
            waarde: OfferteTechnischePrijsOvernameKoppelmodus.afzonderlijk,
            titel: 'Als afzonderlijke prijsregel overnemen',
            uitleg:
                'Maakt een onafhankelijke kopie die later apart kan worden '
                'gewijzigd.',
            icoon: Icons.content_copy_rounded,
            kleur: _groen,
          ),
        ],
      ),
    );
  }

  Widget _bouwKoppelOptie({
    required OfferteTechnischePrijsOvernameKoppelmodus waarde,
    required String titel,
    required String uitleg,
    required IconData icoon,
    required Color kleur,
  }) {
    final geselecteerd = _koppelmodus == waarde;

    return Material(
      color: geselecteerd ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: () {
          setState(() {
            _koppelmodus = waarde;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                geselecteerd
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: geselecteerd ? kleur : _tekstGrijs,
                size: 20,
              ),
              const SizedBox(width: 9),
              Icon(icoon, color: geselecteerd ? kleur : _tekstGrijs, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      titel,
                      style: const TextStyle(
                        fontSize: 12.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      uitleg,
                      style: const TextStyle(
                        color: _tekstGrijs,
                        fontSize: 10.8,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bouwConflictkeuze() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        children: <Widget>[
          _bouwConflictOptie(
            waarde:
                OfferteTechnischePrijsOvernameConflictmodus.alleenOntbrekende,
            titel: 'Alleen ontbrekende prijzen overnemen',
            uitleg:
                'Veilige standaard: bestaande prijsregels blijven ongewijzigd.',
            kleur: _groen,
          ),
          const SizedBox(height: 5),
          _bouwConflictOptie(
            waarde:
                OfferteTechnischePrijsOvernameConflictmodus.bestaandeVervangen,
            titel: 'Ook bestaande prijzen vervangen',
            uitleg:
                '${_groep.aantalBestaande} bestaande prijsregel(s) worden '
                'expliciet vervangen.',
            kleur: _rood,
          ),
        ],
      ),
    );
  }

  Widget _bouwConflictOptie({
    required OfferteTechnischePrijsOvernameConflictmodus waarde,
    required String titel,
    required String uitleg,
    required Color kleur,
  }) {
    final geselecteerd = _conflictmodus == waarde;

    return Material(
      color: geselecteerd ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: () {
          setState(() {
            _conflictmodus = waarde;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                geselecteerd
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: geselecteerd ? kleur : _tekstGrijs,
                size: 20,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      titel,
                      style: const TextStyle(
                        fontSize: 12.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      uitleg,
                      style: TextStyle(
                        color:
                            waarde ==
                                OfferteTechnischePrijsOvernameConflictmodus
                                    .bestaandeVervangen
                            ? _rood
                            : _tekstGrijs,
                        fontSize: 10.8,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bouwOvernameUitleg() {
    final gekoppeld =
        _koppelmodus == OfferteTechnischePrijsOvernameKoppelmodus.gekoppeld;

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: gekoppeld ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: gekoppeld ? const Color(0xFFBFDBFE) : const Color(0xFFBBF7D0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            gekoppeld ? Icons.link_rounded : Icons.copy_all_rounded,
            color: gekoppeld ? _blauw : _groen,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              gekoppeld
                  ? 'De technische keuze en omschrijving blijven lokaal per '
                        'artikeltype. Wijzigingen aan prijs, eenheid, '
                        'uitschrijfwijze en actiefstatus worden voortaan '
                        'gesynchroniseerd binnen de gekoppelde groep.'
                  : 'De prijs, berekeningswijze en uitschrijfwijze worden als '
                        'een afzonderlijke prijsregel gekopieerd. Latere '
                        'wijzigingen aan de bronprijs veranderen deze kopie niet.',
              style: TextStyle(
                color: gekoppeld
                    ? const Color(0xFF1D4ED8)
                    : const Color(0xFF166534),
                fontSize: 11.2,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwInfoRegel(String label, String waarde) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(
                color: _tekstGrijs,
                fontSize: 11.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              waarde,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwSamenvattingsRegel({
    required IconData icoon,
    required String label,
    required int waarde,
    Color kleur = const Color(0xFF111827),
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: <Widget>[
          Icon(icoon, size: 17, color: kleur),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _tekstGrijs,
                fontSize: 11.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '$waarde',
            style: TextStyle(
              color: kleur,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwKandidaatRij(OfferteTechnischePrijsOvernameKandidaat kandidaat) {
    final bronNaam = OfferteArtikelPrijsKoppelingService.formulierNaamVoor(
      kandidaat.bronPrijsregel.formulierType,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: kandidaat.heeftBestaandePrijs
            ? const Color(0xFFFFFBEB)
            : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: kandidaat.heeftBestaandePrijs
              ? const Color(0xFFFDE68A)
              : const Color(0xFFBFDBFE),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            kandidaat.heeftBestaandePrijs
                ? Icons.warning_amber_rounded
                : Icons.call_received_rounded,
            color: kandidaat.heeftBestaandePrijs ? _oranje : _blauw,
            size: 17,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _keuzeNaam(kandidaat.doelKeuze),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.2,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$bronNaam · ${_prijsTekst(kandidaat.bronPrijsregel)}',
            style: TextStyle(
              color: kandidaat.heeftBestaandePrijs ? _oranje : _blauw,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  void _bevestig() {
    Navigator.pop(
      context,
      OfferteTechnischePrijsOvernameResultaat(
        conflictmodus: _conflictmodus,
        koppelmodus: _koppelmodus,
      ),
    );
  }

  String _bevestigTekst() {
    if (_aantalTeVerwerken == 1) {
      return '1 prijsregel overnemen';
    }

    return '$_aantalTeVerwerken prijsregels overnemen';
  }

  static String _keuzeNaam(OfferteTechnischeKeuzeRef keuze) {
    final titel = keuze.keuzeTitelMomentopname.trim();
    return titel.isNotEmpty ? titel : keuze.hoeUitschrijven;
  }

  static String _prijsTekst(OffertePrijsregelModel prijsregel) {
    final bedrag = prijsregel.prijsExclBtw
        .toStringAsFixed(2)
        .replaceAll('.', ',');
    return '€ $bedrag · ${prijsregel.eenheid.benaming}';
  }
}
