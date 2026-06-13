import 'package:flutter/material.dart';

class KraanWaarschuwingIcon extends StatelessWidget {
  final bool actief;

  const KraanWaarschuwingIcon({
    super.key,
    required this.actief,
  });

  @override
  Widget build(BuildContext context) {
    if (!actief) return const SizedBox.shrink();

    return const SizedBox(
      width: 32,
      height: 30,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '🏗️',
            style: TextStyle(fontSize: 22),
          ),
          Positioned(
            right: -1,
            top: -2,
            child: Icon(
              Icons.cancel,
              color: Colors.red,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
