import 'package:flutter/material.dart';

class NotitieDetailPopup extends StatefulWidget {
  const NotitieDetailPopup({
    super.key,
    required this.titel,
    required this.detail,
  });

  final String titel;
  final String detail;

  @override
  State<NotitieDetailPopup> createState() => _NotitieDetailPopupState();
}

class _NotitieDetailPopupState extends State<NotitieDetailPopup> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: widget.detail,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titel),
      content: SizedBox(
        width: 450,
        child: TextField(
          controller: _controller,
          maxLines: 10,
          decoration: const InputDecoration(
            hintText: 'Extra informatie voor deze notitie...',
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Color(0xFF0B7A3B),
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF0B7A3B),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Annuleren'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0B7A3B),
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(
              context,
              _controller.text.trim(),
            );
          },
          child: const Text('Opslaan'),
        ),
      ],
    );
  }
}
