import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../modellen/klant.dart';

class ActiesBlok extends StatelessWidget {
  final Klant klant;

  final Future<void> Function()? onAgenda;
  final Future<void> Function() onProjectAfgewerkt;
  final Future<void> Function() onProjectOpvolgen;
  final Future<void> Function() onExtraWerk;
  final Future<void> Function() onNadienst;
  final Future<void> Function() onKraanReserveren;

  final bool heeftExtraWerk;
  final bool isIngeplandStart;
  final bool isKraanGereserveerd;

  const ActiesBlok({
    super.key,
    required this.klant,
    required this.onAgenda,
    required this.onProjectAfgewerkt,
    required this.onProjectOpvolgen,
    required this.onExtraWerk,
    required this.onNadienst,
    required this.onKraanReserveren,
    required this.heeftExtraWerk,
    required this.isIngeplandStart,
    required this.isKraanGereserveerd,
  });

  String huidigeStatus() {
    if (klant.isProjectAfgewerkt) return 'afgewerkt';
    if (klant.isOpTeVolgen) return 'opvolgen';
    return 'actief';
  }

  int statusVolgorde(String status) {
    if (status == 'actief') return 0;
    if (status == 'opvolgen') return 1;
    if (status == 'afgewerkt') return 2;
    return 0;
  }

  Future<void> wijzigStatus(String? status) async {
    if (status == null) return;

    final huidige = huidigeStatus();

    if (status == huidige) return;

    if (statusVolgorde(status) < statusVolgorde(huidige)) {
      return;
    }

    if (huidige == 'actief' && status == 'afgewerkt') {
      return;
    }

    if (status == 'opvolgen') {
      await onProjectOpvolgen();
    }

    if (status == 'afgewerkt') {
      await onProjectAfgewerkt();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _Tegel(
              icoon: Icons.build,
              titel: heeftExtraWerk ? 'Extra werk toegevoegd' : 'Extra werk',
              kleur: Colors.orange,
              actief: heeftExtraWerk,
              onTap: onExtraWerk,
            ),
            const SizedBox(width: 8),
            _Tegel(
              icoon: Icons.precision_manufacturing,
              titel: isKraanGereserveerd ? 'Kraan gereserveerd' : 'Kraan',
              kleur: Colors.brown,
              actief: isKraanGereserveerd,
              onTap: onKraanReserveren,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Projectstatus',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<String>(
                  groupValue: huidigeStatus(),
                  backgroundColor: Colors.grey.shade200,
                  thumbColor: Colors.green,
                  children: const {
                    'actief': Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      child: Text(
                        'Actief',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    'opvolgen': Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      child: Text(
                        'Opvolgen',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    'afgewerkt': Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      child: Text(
                        'Afgewerkt',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  },
                  onValueChanged: wijzigStatus,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tegel extends StatelessWidget {
  final IconData icoon;
  final String titel;
  final Color kleur;
  final bool actief;
  final Future<void> Function() onTap;

  const _Tegel({
    required this.icoon,
    required this.titel,
    required this.kleur,
    required this.actief,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = actief ? kleur.withValues(alpha: 0.12) : Colors.white;
    final fg = kleur;

    return Expanded(
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            height: 68,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: actief ? kleur : kleur.withValues(alpha: 0.22),
                width: actief ? 1.6 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icoon, color: fg, size: 21),
                const SizedBox(height: 5),
                Text(
                  titel,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: actief ? kleur : Colors.black87,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
