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

  Widget _veld({
    required String label,
    required TextEditingController controller,
    double veldBreedte = 58,
    int maxLength = 4,
  }) {
    return Expanded(
      child: Row(
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: veldBreedte,
            height: 30,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: maxLength,
              onChanged: (_) => onChanged(),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                counterText: '',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 6,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _raammaatRegel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F6EC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFB7E3C3),
        ),
      ),
      child: Text(
        'Raammaat: $raammaatBreedte × $raammaatHoogte mm',
        style: const TextStyle(
          color: groen,
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _verschilRegel() {
    return Expanded(
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE7F6EC),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: const Color(0xFFB7E3C3),
          ),
        ),
        child: Row(
          children: [
            const Text(
              'Verschil',
              maxLines: 1,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: groen,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$verschilTablet',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: groen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
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
          const SizedBox(height: 8),
          Row(
            children: [
              _veld(
                label: 'Dagmaat breedte',
                controller: dagmaatBreedteController,
                veldBreedte: 62,
              ),
              const SizedBox(width: 16),
              _veld(
                label: 'Dagmaat hoogte',
                controller: dagmaatHoogteController,
                veldBreedte: 62,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _veld(
                label: 'Slag Links',
                controller: slagLinksController,
                veldBreedte: 42,
                maxLength: 3,
              ),
              const SizedBox(width: 8),
              _veld(
                label: 'Slag Rechts',
                controller: slagRechtsController,
                veldBreedte: 42,
                maxLength: 3,
              ),
              const SizedBox(width: 8),
              _veld(
                label: 'Slag Boven',
                controller: slagBovenController,
                veldBreedte: 42,
                maxLength: 3,
              ),
              const SizedBox(width: 8),
              _veld(
                label: 'Slag Onder',
                controller: slagOnderController,
                veldBreedte: 42,
                maxLength: 3,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _raammaatRegel(),
          const SizedBox(height: 8),
          Row(
            children: [
              _veld(
                label: 'Binnen tablet',
                controller: binnenTabletController,
                veldBreedte: 46,
                maxLength: 3,
              ),
              const SizedBox(width: 8),
              _veld(
                label: 'Buiten tablet',
                controller: buitenTabletController,
                veldBreedte: 46,
                maxLength: 3,
              ),
              const SizedBox(width: 8),
              _verschilRegel(),
            ],
          ),
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
