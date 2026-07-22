// THIMACO-CONTROLE: DROPDOWN-TOONT-HOE-UITSCHRIJVEN-20260720
import 'package:flutter/material.dart';

import '../../../helpers/offerte/prijzen/offerte_technische_keuze_ref.dart';

class OfferteTechnischeKeuzeDropdown extends StatelessWidget {
  const OfferteTechnischeKeuzeDropdown({
    super.key,
    required this.keuzes,
    required this.waarde,
    required this.onChanged,
    this.toonFout = false,
  });

  /// Alleen keuzes die de gebruiker zelf via "Nieuwe technische keuze"
  /// heeft samengesteld, mogen aan deze lijst worden doorgegeven.
  final List<OfferteTechnischeKeuzeRef> keuzes;
  final OfferteTechnischeKeuzeRef? waarde;
  final ValueChanged<OfferteTechnischeKeuzeRef?> onChanged;
  final bool toonFout;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    final opties = _maakOpties(keuzes);
    final geselecteerdeSleutel = _sleutelVan(waarde);
    final bevatBestaandeWaarde = opties.any(
      (optie) => optie.sleutel == geselecteerdeSleutel,
    );
    final zichtbareOpties = <_TechnischeKeuzeOptie>[
      if (waarde != null &&
          !waarde!.isLeeg &&
          geselecteerdeSleutel.isNotEmpty &&
          !bevatBestaandeWaarde)
        _TechnischeKeuzeOptie(keuze: waarde!),
      ...opties,
    ];

    return DropdownButtonFormField<String>(
      key: ValueKey<String>('technische-keuze-$geselecteerdeSleutel'),
      initialValue: geselecteerdeSleutel.isEmpty ? null : geselecteerdeSleutel,
      isExpanded: true,
      menuMaxHeight: 420,
      decoration: InputDecoration(
        labelText: 'Technische keuze',
        hintText: opties.isEmpty
            ? 'Geen zelfgemaakte technische keuzes beschikbaar'
            : 'Kies de technische keuze die de prijs activeert',
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _rand),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: toonFout ? const Color(0xFFDC2626) : _rand,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _groen, width: 1.5),
        ),
        errorText: toonFout ? 'Kies een technische keuze.' : null,
      ),
      items: zichtbareOpties
          .map((optie) {
            return DropdownMenuItem<String>(
              value: optie.sleutel,
              child: Text(
                optie.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          })
          .toList(growable: false),
      onChanged: zichtbareOpties.isEmpty
          ? null
          : (sleutel) {
              if (sleutel == null) {
                onChanged(null);
                return;
              }

              for (final optie in zichtbareOpties) {
                if (optie.sleutel == sleutel) {
                  onChanged(optie.keuze);
                  return;
                }
              }
            },
    );
  }

  static List<_TechnischeKeuzeOptie> _maakOpties(
    List<OfferteTechnischeKeuzeRef> keuzes,
  ) {
    final optiesPerSleutel = <String, _TechnischeKeuzeOptie>{};

    for (final keuze in keuzes) {
      if (keuze.isLeeg ||
          keuze.formulierType.trim().isEmpty ||
          keuze.menuId.trim().isEmpty ||
          keuze.keuzeId.trim().isEmpty) {
        continue;
      }

      final optie = _TechnischeKeuzeOptie(keuze: keuze);
      optiesPerSleutel[optie.sleutel] = optie;
    }

    final opties = optiesPerSleutel.values.toList(growable: false)
      ..sort((eerste, tweede) {
        return eerste.label.toLowerCase().compareTo(tweede.label.toLowerCase());
      });

    return opties;
  }

  static String _sleutelVan(OfferteTechnischeKeuzeRef? keuze) {
    if (keuze == null || keuze.isLeeg) {
      return '';
    }

    return <String>[
      keuze.formulierType.trim(),
      keuze.menuId.trim(),
      keuze.submenuId.trim(),
      keuze.keuzeId.trim(),
    ].join('|');
  }
}

class _TechnischeKeuzeOptie {
  const _TechnischeKeuzeOptie({required this.keuze});

  final OfferteTechnischeKeuzeRef keuze;

  String get sleutel {
    return <String>[
      keuze.formulierType.trim(),
      keuze.menuId.trim(),
      keuze.submenuId.trim(),
      keuze.keuzeId.trim(),
    ].join('|');
  }

  String get label {
    final delen = <String>[
      keuze.menuTitelMomentopname.trim(),
      keuze.submenuTitelMomentopname.trim(),
      keuze.keuzeTitelMomentopname.trim(),
    ].where((deel) => deel.isNotEmpty).toList(growable: false);
    final pad = delen.join(' · ');
    final hoeUitschrijven = keuze.hoeUitschrijven.trim();

    if (pad.isEmpty) {
      return hoeUitschrijven.isEmpty ? 'Technische keuze' : hoeUitschrijven;
    }

    if (hoeUitschrijven.isEmpty ||
        pad.toLowerCase().contains(hoeUitschrijven.toLowerCase())) {
      return pad;
    }

    return '$pad — $hoeUitschrijven';
  }
}
