import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OpmetingRaamBasisMaten extends StatelessWidget {
  const OpmetingRaamBasisMaten({
    super.key,
    required this.dagmaatHoogteController,
    required this.dagmaatBreedteController,
    required this.raammaatHoogteController,
    required this.raammaatBreedteController,
    required this.slagLinksController,
    required this.slagRechtsController,
    required this.slagBovenController,
    required this.slagOnderController,
    required this.binnenTabletController,
    required this.buitenTabletController,
    required this.uitzagenTandController,
    required this.buitensteLipController,
    required this.onderkantSchuifraamController,
    required this.onOnderkantSchuifraamGewijzigd,
    this.isSchuifraam = false,
    required this.raammaatBreedte,
    required this.raammaatHoogte,
    required this.verschilTablet,
    required this.onChanged,
    required this.onDagmaatGewijzigd,
    required this.onRaammaatGewijzigd,
    this.dagmatenVergrendeld = false,
  });

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  final TextEditingController dagmaatHoogteController;
  final TextEditingController dagmaatBreedteController;
  final TextEditingController raammaatHoogteController;
  final TextEditingController raammaatBreedteController;
  final TextEditingController slagLinksController;
  final TextEditingController slagRechtsController;
  final TextEditingController slagBovenController;
  final TextEditingController slagOnderController;
  final TextEditingController binnenTabletController;
  final TextEditingController buitenTabletController;
  final TextEditingController uitzagenTandController;
  final TextEditingController buitensteLipController;
  final TextEditingController onderkantSchuifraamController;
  final VoidCallback onOnderkantSchuifraamGewijzigd;
  final bool isSchuifraam;

  final int raammaatBreedte;
  final int raammaatHoogte;
  final int verschilTablet;
  final VoidCallback onChanged;
  final VoidCallback onDagmaatGewijzigd;
  final VoidCallback onRaammaatGewijzigd;
  final bool dagmatenVergrendeld;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rand),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 7),
            decoration: const BoxDecoration(
              color: _lichtGroen,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                Icon(Icons.straighten_rounded, color: _groen, size: 17),
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Afmetingen',
                    style: TextStyle(
                      color: Color(0xFF064E3B),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _bouwResultaatKaart(),
                const SizedBox(height: 8),
                if (dagmatenVergrendeld) ...[
                  _bouwInfoMelding(),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Expanded(
                      child: _bouwGetalVeld(
                        label: 'Raammaat B',
                        controller: raammaatBreedteController,
                        enabled: !dagmatenVergrendeld,
                        lichtgroenVeld: true,
                        minTekensVoorWijziging: 3,
                        onChanged: onRaammaatGewijzigd,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: _bouwGetalVeld(
                        label: 'Raammaat H',
                        controller: raammaatHoogteController,
                        enabled: !dagmatenVergrendeld,
                        lichtgroenVeld: true,
                        minTekensVoorWijziging: 3,
                        onChanged: onRaammaatGewijzigd,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _bouwGetalVeld(
                        label: 'Dagmaat B',
                        controller: dagmaatBreedteController,
                        enabled: !dagmatenVergrendeld,
                        minTekensVoorWijziging: 3,
                        onChanged: onDagmaatGewijzigd,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: _bouwGetalVeld(
                        label: 'Dagmaat H',
                        controller: dagmaatHoogteController,
                        enabled: !dagmatenVergrendeld,
                        minTekensVoorWijziging: 3,
                        onChanged: onDagmaatGewijzigd,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _bouwGetalVeld(
                        label: 'Slag L',
                        controller: slagLinksController,
                        onChanged: onRaammaatGewijzigd,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: _bouwGetalVeld(
                        label: 'Slag R',
                        controller: slagRechtsController,
                        onChanged: onRaammaatGewijzigd,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _bouwGetalVeld(
                        label: 'Slag B',
                        controller: slagBovenController,
                        onChanged: onRaammaatGewijzigd,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: _bouwGetalVeld(
                        label: 'Slag O',
                        controller: slagOnderController,
                        onChanged: onRaammaatGewijzigd,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                if (isSchuifraam)
                  _bouwPositieOnderkantSchuifraamVeld()
                else ...[
                  Row(
                    children: [
                      Expanded(
                        child: _bouwGetalVeld(
                          label: 'Uitzagen tand',
                          controller: uitzagenTandController,
                          onChanged: onChanged,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: _bouwGetalVeld(
                          label: 'Buitenste lip',
                          controller: buitensteLipController,
                          onChanged: onChanged,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _bouwGetalVeld(
                          label: 'Tablet binnen',
                          controller: binnenTabletController,
                          onChanged: onChanged,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: _bouwGetalVeld(
                          label: 'Tablet buiten',
                          controller: buitenTabletController,
                          onChanged: onChanged,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Verschil tablet: $verschilTablet mm',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: _tekstGrijs,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwPositieOnderkantSchuifraamVeld() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: onderkantSchuifraamController,
      builder: (context, waarde, child) {
        final heeftGetal = waarde.text.trim().isNotEmpty;

        return TextField(
          controller: onderkantSchuifraamController,
          cursorColor: _groen,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) {
            onOnderkantSchuifraamGewijzigd();
          },
          decoration: InputDecoration(
            labelText: 'Positie onder schuifraam',
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: 'gelijk met vloerpas',
            suffixText: heeftGetal ? 'mm onder vloerpas' : null,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            labelStyle: const TextStyle(
              color: _tekstGrijs,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            floatingLabelStyle: const TextStyle(
              color: _groen,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
            hintStyle: const TextStyle(
              color: _tekstGrijs,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
            suffixStyle: const TextStyle(
              color: _tekstGrijs,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            border: const OutlineInputBorder(),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: _rand),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: _groen, width: 1.4),
            ),
          ),
          style: const TextStyle(
            color: _tekstDonker,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        );
      },
    );
  }

  Widget _bouwResultaatKaart() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _rand),
      ),
      child: Row(
        children: [
          const Icon(Icons.aspect_ratio_rounded, size: 17, color: _groen),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Raammaat',
                  style: TextStyle(
                    color: _tekstGrijs,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$raammaatBreedte × $raammaatHoogte mm',
                  style: const TextStyle(
                    color: _tekstDonker,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwInfoMelding() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: _lichtGroen,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _groen.withOpacity(0.35)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline_rounded, color: _groen, size: 16),
          SizedBox(width: 7),
          Expanded(
            child: Text(
              'Meerdere kaders: dagmaten en raammaten worden automatisch berekend op basis van de totale kaderopbouw.',
              style: TextStyle(
                color: Color(0xFF064E3B),
                fontSize: 10.5,
                height: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwGetalVeld({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    bool lichtgroenVeld = false,
    int minTekensVoorWijziging = 0,
    VoidCallback? onChanged,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      cursorColor: _groen,
      keyboardType: const TextInputType.numberWithOptions(
        signed: false,
        decimal: false,
      ),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.center,
      onChanged: (waarde) {
        final netteWaarde = waarde.trim();

        if (minTekensVoorWijziging > 0 &&
            netteWaarde.isNotEmpty &&
            netteWaarde.length < minTekensVoorWijziging) {
          return;
        }

        if (minTekensVoorWijziging > 0 && netteWaarde.isEmpty) {
          return;
        }

        (onChanged ?? this.onChanged)();
      },
      decoration: InputDecoration(
        labelText: label,
        suffixText: 'mm',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        filled: !enabled || lichtgroenVeld,
        fillColor: !enabled
            ? const Color(0xFFF3F4F6)
            : lichtgroenVeld
            ? _lichtGroen
            : Colors.white,
        labelStyle: const TextStyle(
          color: _tekstGrijs,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        floatingLabelStyle: const TextStyle(
          color: _groen,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
        suffixStyle: const TextStyle(
          color: _tekstGrijs,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: _rand),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: _groen, width: 1.4),
        ),
        disabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFD1D5DB)),
        ),
      ),
      style: TextStyle(
        color: enabled ? _tekstDonker : _tekstGrijs,
        fontSize: 12.5,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
