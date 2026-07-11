import 'package:flutter/material.dart';

class OpmetingRaamTekenvlakKader extends StatelessWidget {
  const OpmetingRaamTekenvlakKader({super.key, required this.inhoudBuilder});

  final Widget Function(Size size) inhoudBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          return inhoudBuilder(size);
        },
      ),
    );
  }
}
