import 'opmeting_deurpaneel_model.dart';

class OpmetingDeurpaneelImportHelper {
  const OpmetingDeurpaneelImportHelper._();

  static List<OpmetingDeurpaneel> leesExcelPlakTekst(String tekst) {
    final regels = tekst
        .split(RegExp(r'\r?\n'))
        .map((regel) => regel.trim())
        .where((regel) => regel.isNotEmpty)
        .toList();

    if (regels.isEmpty) {
      return <OpmetingDeurpaneel>[];
    }

    final eersteRij = _splitRegel(regels.first);
    final heeftKop = eersteRij.any((cel) {
      final header = _normaliseerHeader(cel);
      return header == 'id' ||
          header == 'naam' ||
          header == 'tekening' ||
          header == 'type' ||
          header == 'cilinder';
    });

    final kolommen = heeftKop
        ? _kolommenUitHeader(eersteRij)
        : const _PaneelKolommen(
            id: 0,
            naam: 1,
            tekening: 2,
            type: 3,
            cilinder: 4,
          );

    final dataRegels = heeftKop ? regels.skip(1) : regels;
    final resultaat = <OpmetingDeurpaneel>[];
    final gebruikteIds = <String>{};

    for (final regel in dataRegels) {
      final cellen = _splitRegel(regel);

      final id = _cel(cellen, kolommen.id).trim();
      final naam = _cel(cellen, kolommen.naam).trim();
      final tekening = _cel(cellen, kolommen.tekening).trim();
      final type = _cel(cellen, kolommen.type).trim();
      final cilinder = _cel(cellen, kolommen.cilinder).trim();

      if (id.isEmpty || naam.isEmpty || tekening.isEmpty) {
        continue;
      }

      final toegestaan = _toegestaneTypes(type);
      final uniekId = id.toUpperCase();

      if (gebruikteIds.contains(uniekId)) {
        continue;
      }

      gebruikteIds.add(uniekId);

      resultaat.add(
        OpmetingDeurpaneel(
          id: id,
          naam: naam,
          tekeningBestandsnaam: tekening,
          nietVleugelOverdekkendToegelaten: toegestaan.nietVleugel,
          vleugelOverdekkendToegelaten: toegestaan.vleugel,
          cilinderZijde: OpmetingDeurpaneelCilinderZijdeInfo.vanTekst(cilinder),
        ),
      );
    }

    resultaat.sort((eerste, tweede) {
      return eerste.id.toLowerCase().compareTo(tweede.id.toLowerCase());
    });

    return List<OpmetingDeurpaneel>.unmodifiable(resultaat);
  }

  static List<String> _splitRegel(String regel) {
    if (regel.contains('\t')) {
      return regel.split('\t');
    }

    if (regel.contains(';')) {
      return regel.split(';');
    }

    return regel.split(',');
  }

  static String _cel(List<String> cellen, int index) {
    if (index < 0 || index >= cellen.length) {
      return '';
    }

    return cellen[index].trim().replaceAll(RegExp(r'^"|"$'), '');
  }

  static _PaneelKolommen _kolommenUitHeader(List<String> headerCellen) {
    var id = 0;
    var naam = 1;
    var tekening = 2;
    var type = 3;
    var cilinder = 4;

    for (var index = 0; index < headerCellen.length; index++) {
      final header = _normaliseerHeader(headerCellen[index]);

      switch (header) {
        case 'id':
          id = index;
          break;
        case 'naam':
        case 'name':
          naam = index;
          break;
        case 'tekening':
        case 'dxf':
        case 'bestand':
          tekening = index;
          break;
        case 'type':
          type = index;
          break;
        case 'cilinder':
          cilinder = index;
          break;
      }
    }

    return _PaneelKolommen(
      id: id,
      naam: naam,
      tekening: tekening,
      type: type,
      cilinder: cilinder,
    );
  }

  static String _normaliseerHeader(String waarde) {
    return waarde
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('_', '')
        .replaceAll('-', '')
        .trim();
  }

  static _ToegestaneTypes _toegestaneTypes(String waarde) {
    final tekst = waarde.toLowerCase().trim();

    if (tekst.contains('beide')) {
      return const _ToegestaneTypes(nietVleugel: true, vleugel: true);
    }

    if (tekst.contains('niet')) {
      return const _ToegestaneTypes(nietVleugel: true, vleugel: false);
    }

    if (tekst.contains('vleugel')) {
      return const _ToegestaneTypes(nietVleugel: false, vleugel: true);
    }

    return const _ToegestaneTypes(nietVleugel: true, vleugel: true);
  }
}

class _PaneelKolommen {
  const _PaneelKolommen({
    required this.id,
    required this.naam,
    required this.tekening,
    required this.type,
    required this.cilinder,
  });

  final int id;
  final int naam;
  final int tekening;
  final int type;
  final int cilinder;
}

class _ToegestaneTypes {
  const _ToegestaneTypes({required this.nietVleugel, required this.vleugel});

  final bool nietVleugel;
  final bool vleugel;
}
