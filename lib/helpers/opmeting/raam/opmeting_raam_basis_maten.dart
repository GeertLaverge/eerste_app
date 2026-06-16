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

  Widget _veldCompact(
    String label,
    TextEditingController controller, {
    double breedte = 92,
  }) {
    return SizedBox(
      width: breedte,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          SizedBox(
            height: 32,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              onChanged: (_) => onChanged(),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 7,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultaatRegel() {
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
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _verschilRegel() {
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
        'Verschil tablet: $verschilTablet mm',
        style: const TextStyle(
          color: groen,
          fontSize: 14,
          fontWeight: FontWeight.w900,
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
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _veldCompact(
                  'Dagmaat breedte',
                  dagmaatBreedteController,
                  breedte: double.infinity,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _veldCompact(
                  'Dagmaat hoogte',
                  dagmaatHoogteController,
                  breedte: double.infinity,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _veldCompact(
                  'Slag L',
                  slagLinksController,
                  breedte: double.infinity,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _veldCompact(
                  'Slag R',
                  slagRechtsController,
                  breedte: double.infinity,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _veldCompact(
                  'Slag B',
                  slagBovenController,
                  breedte: double.infinity,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _veldCompact(
                  'Slag O',
                  slagOnderController,
                  breedte: double.infinity,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _resultaatRegel(),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _veldCompact(
                  'Binnen tablet',
                  binnenTabletController,
                  breedte: double.infinity,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _veldCompact(
                  'Buiten tablet',
                  buitenTabletController,
                  breedte: double.infinity,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _verschilRegel(),
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
