import 'package:flutter/material.dart';

class OpmetingRaamNotities extends StatelessWidget {
  const OpmetingRaamNotities({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 94,
      padding: const EdgeInsets.all(10),
      decoration: _kaartDecoratie(),
      child: TextField(
        controller: controller,
        minLines: 2,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Opmerkingen / extra notities...',
          border: InputBorder.none,
        ),
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
