import 'opmeting_uitvalscherm_model.dart';
import 'opmeting_uitvalscherm_tekening_geometrie.dart';

class OpmetingUitvalschermSvgHelper {
  const OpmetingUitvalschermSvgHelper._();

  static String bouw(OpmetingUitvalschermModel model) {
    final g = OpmetingUitvalschermTekeningGeometrie.voorModel(model);
    final doekKleur = _veiligeKleur(model.doekHex);
    final tekstKleur = _isDonkereKleur(doekKleur) ? '#FFFFFF' : '#22272D';
    final doekCode = _escape(
      model.doekCode.trim().isEmpty ? 'kleur doek' : model.doekCode.trim(),
    );

    final kast = switch (g.kastVorm) {
      OpmetingUitvalschermKastVorm.rechthoekig =>
        '<rect x="${_n(g.kastX)}" y="${_n(g.kastY)}" '
            'width="${_n(g.kastBreedte)}" height="${_n(g.kastHoogte)}" '
            'fill="#FFFFFF" stroke="#22272D" stroke-width="1.65"/>',
      OpmetingUitvalschermKastVorm.schuin500X =>
        '<path d="M ${_n(g.kastX + 3)} ${_n(g.kastY)} '
            'L ${_n(g.kastRechts)} ${_n(g.kastY + 7)} '
            'L ${_n(g.kastRechts - 2)} ${_n(g.kastOnder - 4)} '
            'L ${_n(g.kastX + 3)} ${_n(g.kastOnder)} Z" '
            'fill="#FFFFFF" stroke="#22272D" stroke-width="1.65"/>',
    };

    final volantHoogte = 18 + model.volantHoogteMm.clamp(0, 500) * 0.12;
    final volant = model.volant
        ? '''
  <line x1="${_n(g.voorplaatX + g.voorplaatBreedte - 2)}"
        y1="${_n(g.voorplaatY + g.voorplaatHoogte)}"
        x2="${_n(g.voorplaatX + g.voorplaatBreedte - 2)}"
        y2="${_n(g.voorplaatY + g.voorplaatHoogte + volantHoogte)}"
        stroke="#22272D" stroke-width="1.65"/>
  <text x="${_n(g.voorplaatX - 54)}"
        y="${_n(g.voorplaatY + g.voorplaatHoogte + volantHoogte + 18)}"
        font-size="12" fill="#50565D">volant ${_escape('${model.volantHoogteMm} mm')}</text>
'''
        : '';

    final label500 = g.toon500XLabel
        ? '<text x="${_n((g.frontLinks + g.frontRechts) / 2)}" '
              'y="${_n(g.frontOnder + 44)}" text-anchor="middle" '
              'font-size="20" font-weight="700" fill="#50565D">500 X</text>'
        : '';

    return '''
<svg xmlns="http://www.w3.org/2000/svg"
     width="900" height="600" viewBox="0 0 900 600">
  <defs>
    <pattern id="brick" width="30" height="12" patternUnits="userSpaceOnUse">
      <rect width="30" height="12" fill="#F7F8F9"/>
      <path d="M0 0H30 M0 12H30 M0 0V12 M15 0V6 M30 0V12"
            stroke="#E5E8EC" stroke-width="0.55"/>
    </pattern>
  </defs>

  <rect x="82" y="62" width="34" height="205"
        fill="url(#brick)" stroke="#E5E8EC" stroke-width="0.55"/>
  $kast
  <line x1="${_n(g.kastX - 3)}" y1="${_n(g.kastY + 4)}"
        x2="${_n(g.kastX - 3)}" y2="${_n(g.kastOnder - 4)}"
        stroke="#22272D" stroke-width="1.65"/>

  <line x1="${_n(g.doekStartX)}" y1="${_n(g.doekStartY)}"
        x2="${_n(g.doekEindX)}" y2="${_n(g.doekEindY)}"
        stroke="#22272D" stroke-width="1.65"/>

  ${_arm(g.armStartX, g.armStartY, g.armKnikX, g.armKnikY)}
  ${_arm(g.armKnikX, g.armKnikY, g.armEindX, g.armEindY)}
  ${_scharnier(g.armKnikX, g.armKnikY, 4.2)}
  ${_scharnier(g.armEindX, g.armEindY, 5.2)}

  <rect x="${_n(g.voorplaatX)}" y="${_n(g.voorplaatY)}"
        width="${_n(g.voorplaatBreedte)}" height="${_n(g.voorplaatHoogte)}"
        rx="2" fill="#FFFFFF" stroke="#22272D" stroke-width="1.65"/>
  $volant

  ${_maatHorizontaal(g.doekStartX, g.doekEindX, 45, 'uitval ${model.uitvalMm} mm')}

  <circle cx="770" cy="135" r="62" fill="$doekKleur"
          stroke="#22272D" stroke-width="1.7"/>
  <text x="770" y="139" text-anchor="middle" dominant-baseline="middle"
        font-size="13" font-weight="700" fill="$tekstKleur">$doekCode</text>

  <rect x="${_n(g.frontLinks - 46)}" y="${_n(g.frontBoven - 22)}"
        width="${_n(g.frontBreedte + 92)}" height="${_n(g.frontHoogte + 44)}"
        fill="url(#brick)" stroke="#E5E8EC" stroke-width="0.55"/>
  <rect x="${_n(g.frontLinks)}" y="${_n(g.frontBoven)}"
        width="${_n(g.frontBreedte)}" height="${_n(g.frontHoogte)}"
        rx="${g.kastVorm == OpmetingUitvalschermKastVorm.rechthoekig ? '1.5' : '5'}"
        fill="#FFFFFF" stroke="#22272D" stroke-width="1.65"/>
  <line x1="${_n(g.frontLinks + 10)}"
        y1="${_n(g.frontBoven + g.frontHoogte * 0.20)}"
        x2="${_n(g.frontRechts - 10)}"
        y2="${_n(g.frontBoven + g.frontHoogte * 0.20)}"
        stroke="#7A8086" stroke-width="0.9"/>
  <line x1="${_n(g.frontLinks + 10)}"
        y1="${_n(g.frontOnder - g.frontHoogte * 0.18)}"
        x2="${_n(g.frontRechts - 10)}"
        y2="${_n(g.frontOnder - g.frontHoogte * 0.18)}"
        stroke="#7A8086" stroke-width="0.9"/>

  ${_maatHorizontaal(g.frontLinks, g.frontRechts, g.frontBoven - 48, 'totale breedte ${model.breedteMm} mm')}
  $label500
</svg>
''';
  }

  static String _arm(double x1, double y1, double x2, double y2) {
    return '''
  <line x1="${_n(x1)}" y1="${_n(y1)}" x2="${_n(x2)}" y2="${_n(y2)}"
        stroke="#22272D" stroke-width="8" stroke-linecap="square"/>
  <line x1="${_n(x1)}" y1="${_n(y1)}" x2="${_n(x2)}" y2="${_n(y2)}"
        stroke="#FFFFFF" stroke-width="5.2" stroke-linecap="square"/>
''';
  }

  static String _scharnier(double x, double y, double straal) {
    return '''
  <circle cx="${_n(x)}" cy="${_n(y)}" r="${_n(straal)}"
          fill="#FFFFFF" stroke="#22272D" stroke-width="1.4"/>
  <circle cx="${_n(x)}" cy="${_n(y)}" r="1.4" fill="#22272D"/>
''';
  }

  static String _maatHorizontaal(double x1, double x2, double y, String tekst) {
    return '''
  <line x1="${_n(x1)}" y1="${_n(y)}" x2="${_n(x2)}" y2="${_n(y)}"
        stroke="#50565D" stroke-width="1"/>
  <line x1="${_n(x1 - 5)}" y1="${_n(y + 5)}"
        x2="${_n(x1 + 5)}" y2="${_n(y - 5)}"
        stroke="#50565D" stroke-width="1"/>
  <line x1="${_n(x2 - 5)}" y1="${_n(y + 5)}"
        x2="${_n(x2 + 5)}" y2="${_n(y - 5)}"
        stroke="#50565D" stroke-width="1"/>
  <text x="${_n((x1 + x2) / 2)}" y="${_n(y - 8)}"
        text-anchor="middle" font-size="11" fill="#50565D">${_escape(tekst)}</text>
''';
  }

  static String _veiligeKleur(String waarde) {
    final kleur = waarde.trim().toUpperCase();
    return RegExp(r'^#[0-9A-F]{6}$').hasMatch(kleur) ? kleur : '#8C8C8A';
  }

  static bool _isDonkereKleur(String hex) {
    final waarde = int.tryParse(hex.substring(1), radix: 16) ?? 0x8C8C8A;
    final rood = (waarde >> 16) & 0xFF;
    final groen = (waarde >> 8) & 0xFF;
    final blauw = waarde & 0xFF;
    final luminantie = (0.2126 * rood + 0.7152 * groen + 0.0722 * blauw) / 255;
    return luminantie < 0.45;
  }

  static String _escape(String tekst) {
    return tekst
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  static String _n(num waarde) => waarde.toStringAsFixed(2);
}
