// THIMACO-CONTROLE: ALGEMENE-OPMETING-NIEUWE-HUISSTIJL-20260914
// THIMACO-CONTROLE: ALGEMENE-OPMETING-AFBEELDINGVLAK-20260801
import 'package:flutter/material.dart';

import '../../ui/thimaco_huisstijl.dart';
import '../fotos/opmeting_foto_model.dart';

class OpmetingAlgemeneOpmetingTekenvlak extends StatelessWidget {
  const OpmetingAlgemeneOpmetingTekenvlak({
    super.key,
    required this.fotos,
    this.onOneDrive,
    this.onCamera,
    this.onVerwijderen,
    this.onVerplaatsen,
    this.actiesZichtbaar = true,
  });

  final List<OpmetingFoto> fotos;
  final VoidCallback? onOneDrive;
  final VoidCallback? onCamera;
  final ValueChanged<int>? onVerwijderen;
  final void Function(int index, int richting)? onVerplaatsen;
  final bool actiesZichtbaar;

  static const Color _rand = ThimacoKleuren.rand;
  static const Color _tekstGrijs = ThimacoKleuren.tekstGrijs;

  @override
  Widget build(BuildContext context) {
    final geldigeFotos = fotos.where((foto) => foto.heeftAfbeelding).toList();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rand),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          if (actiesZichtbaar)
            Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: _rand)),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _ActieKnop(
                      icoon: Icons.cloud_download_outlined,
                      tekst: 'Uit OneDrive',
                      onPressed: onOneDrive,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActieKnop(
                      icoon: Icons.photo_camera_outlined,
                      tekst: 'Foto nemen',
                      onPressed: onCamera,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: geldigeFotos.isEmpty
                ? const _LeegAfbeeldingVlak()
                : _Fotogalerij(
                    fotos: geldigeFotos,
                    actiesZichtbaar: actiesZichtbaar,
                    onVerwijderen: onVerwijderen,
                    onVerplaatsen: onVerplaatsen,
                  ),
          ),
        ],
      ),
    );
  }
}

class _ActieKnop extends StatelessWidget {
  const _ActieKnop({
    required this.icoon,
    required this.tekst,
    required this.onPressed,
  });

  final IconData icoon;
  final String tekst;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icoon, size: 17, color: ThimacoKleuren.oranje),
      label: Text(tekst),
      style: OutlinedButton.styleFrom(
        foregroundColor: ThimacoKleuren.antraciet,
        backgroundColor: Colors.white,
        disabledForegroundColor:
            ThimacoKleuren.tekstGrijs.withValues(alpha: 0.45),
        side: const BorderSide(color: ThimacoKleuren.rand),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LeegAfbeeldingVlak extends StatelessWidget {
  const _LeegAfbeeldingVlak();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.image_search_outlined,
              size: 48,
              color: ThimacoKleuren.tekstGrijs,
            ),
            SizedBox(height: 12),
            Text(
              'Voeg een foto of afbeelding toe',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ThimacoKleuren.antraciet,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'De eerste afbeelding wordt de hoofdafbeelding '
              'in het overzicht en de PDF.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: OpmetingAlgemeneOpmetingTekenvlak._tekstGrijs,
                fontSize: 11.5,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Fotogalerij extends StatelessWidget {
  const _Fotogalerij({
    required this.fotos,
    required this.actiesZichtbaar,
    required this.onVerwijderen,
    required this.onVerplaatsen,
  });

  final List<OpmetingFoto> fotos;
  final bool actiesZichtbaar;
  final ValueChanged<int>? onVerwijderen;
  final void Function(int index, int richting)? onVerplaatsen;

  @override
  Widget build(BuildContext context) {
    final hoofdFoto = fotos.first;
    final overige = fotos.skip(1).toList(growable: false);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Expanded(
            child: _FotoTegel(
              foto: hoofdFoto,
              index: 0,
              hoofdFoto: true,
              actiesZichtbaar: actiesZichtbaar,
              onVerwijderen: onVerwijderen,
              onVerplaatsen: onVerplaatsen,
            ),
          ),
          if (overige.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            SizedBox(
              height: 94,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: overige.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final werkelijkeIndex = index + 1;
                  return SizedBox(
                    width: 135,
                    child: _FotoTegel(
                      foto: overige[index],
                      index: werkelijkeIndex,
                      hoofdFoto: false,
                      actiesZichtbaar: actiesZichtbaar,
                      onVerwijderen: onVerwijderen,
                      onVerplaatsen: onVerplaatsen,
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FotoTegel extends StatelessWidget {
  const _FotoTegel({
    required this.foto,
    required this.index,
    required this.hoofdFoto,
    required this.actiesZichtbaar,
    required this.onVerwijderen,
    required this.onVerplaatsen,
  });

  final OpmetingFoto foto;
  final int index;
  final bool hoofdFoto;
  final bool actiesZichtbaar;
  final ValueChanged<int>? onVerwijderen;
  final void Function(int index, int richting)? onVerplaatsen;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Image.memory(
            foto.bytes,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image_outlined, color: Colors.redAccent),
            ),
          ),
        ),
        if (hoofdFoto)
          Positioned(
            left: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ThimacoKleuren.oranje.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Hoofdafbeelding',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        if (actiesZichtbaar)
          Positioned(
            right: 5,
            top: 5,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ThimacoKleuren.rand),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ThimacoIcoonActie(
                    icoon: Icons.arrow_back_rounded,
                    tooltip: 'Naar links',
                    grootte: 17,
                    onPressed:
                        index <= 0 ? null : () => onVerplaatsen?.call(index, -1),
                  ),
                  ThimacoIcoonActie(
                    icoon: Icons.arrow_forward_rounded,
                    tooltip: 'Naar rechts',
                    grootte: 17,
                    onPressed: () => onVerplaatsen?.call(index, 1),
                  ),
                  ThimacoIcoonActie(
                    icoon: Icons.delete_outline,
                    tooltip: 'Verwijderen',
                    grootte: 17,
                    destructief: true,
                    onPressed: () => onVerwijderen?.call(index),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
