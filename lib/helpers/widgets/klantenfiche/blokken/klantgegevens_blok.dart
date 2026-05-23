import 'package:flutter/material.dart';
import '../invoer_veld.dart';
import '../uitklapbare_sectie.dart';

class KlantgegevensBlok extends StatelessWidget {
  final TextEditingController klantenNrController;
  final TextEditingController klantNaamController;
  final TextEditingController adresController;
  final TextEditingController telefoonController;
  final TextEditingController emailController;
  final Future<void> Function() onChanged;

  const KlantgegevensBlok({
    super.key,
    required this.klantenNrController,
    required this.klantNaamController,
    required this.adresController,
    required this.telefoonController,
    required this.emailController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return UitklapbareSectie(
      titel: 'Klantgegevens',
      icoon: Icons.badge_outlined,
      geopend: true,
      onToggle: () {},
      children: [
        InvoerVeld(
          label: 'Klantennr',
          controller: klantenNrController,
          onChanged: (_) async => await onChanged(),
        ),
        InvoerVeld(
          label: 'Naam klant',
          controller: klantNaamController,
          onChanged: (_) async => await onChanged(),
        ),
        InvoerVeld(
          label: 'Adres gegevens klant',
          controller: adresController,
          maxLines: 2,
          onChanged: (_) async => await onChanged(),
        ),
        InvoerVeld(
          label: 'Telefoonnr',
          controller: telefoonController,
          onChanged: (_) async => await onChanged(),
        ),
        InvoerVeld(
          label: 'Email adres',
          controller: emailController,
          onChanged: (_) async => await onChanged(),
        ),
      ],
    );
  }
}
