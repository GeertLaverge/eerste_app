import 'package:flutter/material.dart';

class AgendaOnderbalkKnoppen {
  static Widget actie({
    required IconData icoon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0xFF0B7A3B),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icoon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  static Widget weergave({
    required String tekst,
    required bool actief,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        width: 88,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: actief ? const Color(0xFF0B7A3B) : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Text(
          tekst,
          style: TextStyle(
            color: actief ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
