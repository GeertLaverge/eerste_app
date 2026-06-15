import 'package:flutter/material.dart';

class OpmetingRaamBasisMaten extends StatelessWidget {
  const OpmetingRaamBasisMaten({
    super.key,
    required this.dagmaatHoogteController,
    required this.dagmaatBreedteController,
    required this.slagLinksController,
    required this.slagRechtsController,
    required this.slagBovenController,
    required this.slagOnderController,
    required this.binnenTabletController,
    required this.buitenTabletController,
    required this.raammaatBreedte,
    required this.raammaatHoogte,
    required this.verschilTablet,
    required this.onChanged,
  });

  final TextEditingController dagmaatHoogteController;
  final TextEditingController dagmaatBreedteController;
  final TextEditingController slagLinksController;
  final TextEditingController slagRechtsController;
  final TextEditingController slagBovenController;
  final TextEditingController slagOnderController;
  final TextEditingController binnenTabletController;
  final TextEditingController buitenTabletController;

  final int raammaatBreedte;
  final int raammaatHoogte;
  final int verschilTablet;
  final VoidCallback onChanged;

  static const groen = Color(0xFF0B7A3B);

  Widget _veld(
    String label,
    TextEditingController controller,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          width: 74,
          height: 34,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            onChanged: (_) => onChanged(),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'mm',
          style: TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  Widget _resultaat(String label, int waarde) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          '$waarde',
          style: const TextStyle(
            color: groen,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'mm',
          style: TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _kaartDecoratie(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AFMETINGEN',
            style: TextStyle(
              color: groen,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _veld('Dagmaat hoogte', dagmaatHoogteController),
          const SizedBox(height: 8),
          _veld('Dagmaat breedte', dagmaatBreedteController),
          const Divider(height: 20),
          _veld('Slag links', slagLinksController),
          const SizedBox(height: 8),
          _veld('Slag rechts', slagRechtsController),
          const SizedBox(height: 8),
          _veld('Slag boven', slagBovenController),
          const SizedBox(height: 8),
          _veld('Slag onder', slagOnderController),
          const Divider(height: 20),
          _resultaat('Raammaat hoogte', raammaatHoogte),
          const SizedBox(height: 8),
          _resultaat('Raammaat breedte', raammaatBreedte),
          const Divider(height: 20),
          _veld('Binnen tablet', binnenTabletController),
          const SizedBox(height: 8),
          _veld('Buiten tablet', buitenTabletController),
          const SizedBox(height: 8),
          _resultaat('Verschil', verschilTablet),
        ],
      ),
    );
  }

  BoxDecoration _kaartDecoratie() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xFFE5E7EB),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.035),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
