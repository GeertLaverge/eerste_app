import '../kader_samenstelling/opmeting_kader_samenstelling_model.dart';
import '../raam/opmeting_raam_model.dart';
import 'opmeting_overzicht_model.dart';

class OpmetingArtikelTypeOmschrijvingHelper {
  const OpmetingArtikelTypeOmschrijvingHelper._();

  static String omschrijvingVoor(OpmetingOverzichtRaamItem item) {
    switch (item.formulierTypeGenormaliseerd) {
      case 'pvcRaam':
      case 'aluRaam':
        return _raamOmschrijving(item);
      case 'pvcSchuifraam':
      case 'aluSchuifraam':
        return _schuifraamOmschrijving(item);
      case 'pvcDeur':
      case 'aluDeur':
        return _deurOmschrijvingRegels(item).join(' - ');
      default:
        return '';
    }
  }

  /// Geeft de uitvoering als afzonderlijke zichtbare regels terug.
  ///
  /// Bij deuren staat eerst iedere deurvleugel. Daarna volgen alle overige
  /// raamvakken en vleugels, eerst van links naar rechts en binnen dezelfde
  /// kolom van onder naar boven.
  static List<String> omschrijvingRegelsVoor(OpmetingOverzichtRaamItem item) {
    switch (item.formulierTypeGenormaliseerd) {
      case 'pvcDeur':
      case 'aluDeur':
        return List<String>.unmodifiable(_deurOmschrijvingRegels(item));
      default:
        final omschrijving = omschrijvingVoor(item).trim();
        if (omschrijving.isEmpty) {
          return const <String>[];
        }
        return <String>[omschrijving];
    }
  }

  static bool isVerplaatsteTechnischeRegelTitel(String titel) {
    final genormaliseerd = _normaliseerTitel(titel);
    return genormaliseerd == 'schuifraam' || genormaliseerd == 'deurvleugel';
  }

  static String _raamOmschrijving(OpmetingOverzichtRaamItem item) {
    final kaders = [...item.kaderSamenstelling.kaders]
      ..sort(_vergelijkKadersLinksNaarRechtsBovenNaarOnder);

    if (kaders.isEmpty) {
      return _beschrijfRaamKader(
        vleugels: item.tekeningData.vleugels,
        tStijlen: item.tekeningData.tStijlen,
      ).join(' - ');
    }

    final omschrijvingen = <String>[];

    for (final kader in kaders) {
      final vleugels = _lijstVoorKader(
        kaderId: kader.id,
        aantalKaders: kaders.length,
        basis: item.tekeningData.vleugels,
        perKader: item.tekeningData.vleugelsPerKader,
      );
      final tStijlen = _lijstVoorKader(
        kaderId: kader.id,
        aantalKaders: kaders.length,
        basis: item.tekeningData.tStijlen,
        perKader: item.tekeningData.tStijlenPerKader,
      );

      omschrijvingen.addAll(
        _beschrijfRaamKader(vleugels: vleugels, tStijlen: tStijlen),
      );
    }

    if (omschrijvingen.isEmpty) {
      final oudeOmschrijving = _oudeTechnischeWaarde(item, const <String>{
        'vleugel',
        'raamvleugel',
        'raamvleugels',
      });
      return oudeOmschrijving.isEmpty ? 'Vast' : oudeOmschrijving;
    }

    return omschrijvingen.join(' - ');
  }

  static List<String> _beschrijfRaamKader({
    required List<OpmetingRaamVleugel> vleugels,
    required List<OpmetingRaamTStijl> tStijlen,
    bool deurVlakkenOverslaan = false,
    bool vanOnderNaarBoven = false,
  }) {
    final gewoneVleugels = vleugels.where((vleugel) {
      return !vleugel.isDeurVleugel &&
          vleugel.type != OpmetingRaamVleugelType.geenVleugel;
    }).toList();
    final deurVleugels = vleugels.where((vleugel) {
      return vleugel.isDeurVleugel;
    }).toList();
    final kaderTStijlen = tStijlen.where((tStijl) {
      return tStijl.werkvlakId.trim().isEmpty ||
          tStijl.werkvlakId.trim() == 'kader';
    }).toList();

    if (kaderTStijlen.isEmpty) {
      if (gewoneVleugels.isEmpty) {
        if (deurVlakkenOverslaan && deurVleugels.isNotEmpty) {
          return const <String>[];
        }
        return const <String>['Vast'];
      }

      gewoneVleugels.sort(
        vanOnderNaarBoven
            ? _vergelijkVleugelsVanOnderNaarBoven
            : _vergelijkVleugels,
      );
      return gewoneVleugels
          .map((vleugel) => vleugel.type.naam)
          .toList(growable: false);
    }

    final verticalePosities = _uniekeGesorteerdeWaarden(
      kaderTStijlen
          .where((tStijl) => _isVerticaal(tStijl))
          .map((tStijl) => (tStijl.start.dx + tStijl.einde.dx) / 2),
    );
    final horizontalePerKolom = <int, List<double>>{};

    for (final tStijl in kaderTStijlen.where((tStijl) {
      return !_isVerticaal(tStijl);
    })) {
      final middenX = (tStijl.start.dx + tStijl.einde.dx) / 2;
      final middenY = (tStijl.start.dy + tStijl.einde.dy) / 2;
      final kolom = _vakIndex(middenX, verticalePosities);
      horizontalePerKolom.putIfAbsent(kolom, () => <double>[]).add(middenY);
    }

    final vleugelsPerCel = <String, List<OpmetingRaamVleugel>>{};
    final deurVleugelsPerCel = <String, List<OpmetingRaamVleugel>>{};

    void registreerVleugel(
      OpmetingRaamVleugel vleugel,
      Map<String, List<OpmetingRaamVleugel>> doel,
    ) {
      final kolom = _vakIndex(vleugel.vlak.center.dx, verticalePosities);
      final horizontalePosities = _uniekeGesorteerdeWaarden(
        horizontalePerKolom[kolom] ?? const <double>[],
      );
      final rij = _vakIndex(vleugel.vlak.center.dy, horizontalePosities);
      final sleutel = '$kolom:$rij';
      doel.putIfAbsent(sleutel, () => <OpmetingRaamVleugel>[]).add(vleugel);
    }

    for (final vleugel in gewoneVleugels) {
      registreerVleugel(vleugel, vleugelsPerCel);
    }
    for (final vleugel in deurVleugels) {
      registreerVleugel(vleugel, deurVleugelsPerCel);
    }

    final resultaat = <String>[];
    final aantalKolommen = verticalePosities.length + 1;

    for (var kolom = 0; kolom < aantalKolommen; kolom++) {
      final horizontalePosities = _uniekeGesorteerdeWaarden(
        horizontalePerKolom[kolom] ?? const <double>[],
      );
      final aantalRijen = horizontalePosities.length + 1;
      final eersteRij = vanOnderNaarBoven ? aantalRijen - 1 : 0;
      final rijNaLaatste = vanOnderNaarBoven ? -1 : aantalRijen;
      final rijStap = vanOnderNaarBoven ? -1 : 1;

      for (var rij = eersteRij; rij != rijNaLaatste; rij += rijStap) {
        final sleutel = '$kolom:$rij';

        if (deurVlakkenOverslaan &&
            (deurVleugelsPerCel[sleutel]?.isNotEmpty ?? false)) {
          continue;
        }

        final celVleugels =
            vleugelsPerCel[sleutel] ?? const <OpmetingRaamVleugel>[];

        if (celVleugels.isEmpty) {
          resultaat.add('Vast');
          continue;
        }

        final gesorteerd = [...celVleugels]
          ..sort(
            vanOnderNaarBoven
                ? _vergelijkVleugelsVanOnderNaarBoven
                : _vergelijkVleugels,
          );
        final namen = gesorteerd.map((vleugel) => vleugel.type.naam).toSet();
        resultaat.add(namen.join(' / '));
      }
    }

    if (resultaat.isEmpty &&
        !(deurVlakkenOverslaan && deurVleugels.isNotEmpty)) {
      return const <String>['Vast'];
    }

    return resultaat;
  }

  static String _schuifraamOmschrijving(OpmetingOverzichtRaamItem item) {
    final samenstelling = item.tekeningData.schuifraamSamenstelling;

    if (samenstelling != null && samenstelling.isGeldig) {
      return samenstelling.samenvatting.trim();
    }

    return _oudeTechnischeWaarde(item, const <String>{'schuifraam'});
  }

  static List<String> _deurOmschrijvingRegels(OpmetingOverzichtRaamItem item) {
    final kaders = [...item.kaderSamenstelling.kaders]
      ..sort(_vergelijkKadersLinksNaarRechtsOnderNaarBoven);
    final deurSamenvattingen = <String>[];
    final overigeSamenvattingen = <String>[];
    final gebruikteDeurGroepen = <String>{};

    void verwerkKader({
      required List<OpmetingRaamVleugel> vleugels,
      required List<OpmetingRaamTStijl> tStijlen,
    }) {
      final deurVleugels = vleugels.where((vleugel) {
        return vleugel.isDeurVleugel;
      }).toList()..sort(_vergelijkVleugelsVanOnderNaarBoven);

      for (final vleugel in deurVleugels) {
        final groepSleutel = vleugel.deurVleugelGroepId.trim().isNotEmpty
            ? vleugel.deurVleugelGroepId.trim()
            : vleugel.id;
        if (!gebruikteDeurGroepen.add(groepSleutel)) {
          continue;
        }
        deurSamenvattingen.add(_formatteerDeurVleugel(vleugel));
      }

      overigeSamenvattingen.addAll(
        _beschrijfRaamKader(
          vleugels: vleugels,
          tStijlen: tStijlen,
          deurVlakkenOverslaan: true,
          vanOnderNaarBoven: true,
        ),
      );
    }

    if (kaders.isEmpty) {
      verwerkKader(
        vleugels: item.tekeningData.vleugels,
        tStijlen: item.tekeningData.tStijlen,
      );
    } else {
      for (final kader in kaders) {
        verwerkKader(
          vleugels: _lijstVoorKader(
            kaderId: kader.id,
            aantalKaders: kaders.length,
            basis: item.tekeningData.vleugels,
            perKader: item.tekeningData.vleugelsPerKader,
          ),
          tStijlen: _lijstVoorKader(
            kaderId: kader.id,
            aantalKaders: kaders.length,
            basis: item.tekeningData.tStijlen,
            perKader: item.tekeningData.tStijlenPerKader,
          ),
        );
      }
    }

    if (deurSamenvattingen.isEmpty) {
      final oudeOmschrijving = _oudeTechnischeWaarde(item, const <String>{
        'deurvleugel',
      });
      if (oudeOmschrijving.isNotEmpty) {
        deurSamenvattingen.add(oudeOmschrijving);
      }
    }

    return <String>[...deurSamenvattingen, ...overigeSamenvattingen];
  }

  static String _formatteerDeurVleugel(OpmetingRaamVleugel vleugel) {
    final aantal = vleugel.isDubbeleDeurVleugel
        ? 'Dubbele vleugel'
        : 'Enkele vleugel';
    final richting =
        vleugel.deurDraairichting ==
            OpmetingRaamDeurDraairichting.binnendraaiend
        ? 'binnendraaiend'
        : 'buitendraaiend';
    final isLinks = vleugel.deurVleugelKrukZijde == OpmetingRaamKrukZijde.links;
    final krukNaam =
        vleugel.deurVleugelKrukType ==
            OpmetingRaamDeurVleugelKrukType.rolluikkruk
        ? 'rolluikkruk'
        : 'kruk';
    final zijdeVoluit = isLinks ? 'links' : 'rechts';
    final zijdeKort = isLinks ? 'L' : 'R';
    final krukOmschrijving =
        vleugel.deurKrukPlaatsing ==
            OpmetingRaamDeurKrukPlaatsing.binnenEnBuiten
        ? '$krukNaam binnen en buiten $zijdeKort'
        : '$krukNaam binnen $zijdeVoluit';

    return '$aantal $richting - $krukOmschrijving';
  }

  static String _oudeTechnischeWaarde(
    OpmetingOverzichtRaamItem item,
    Set<String> toegestaneTitels,
  ) {
    for (final regel in item.zichtbareTechnischeRegels) {
      if (toegestaneTitels.contains(_normaliseerTitel(regel.titel)) &&
          regel.waarde.trim().isNotEmpty) {
        return regel.waarde.trim();
      }
    }

    for (final container in item.zichtbareTechnischeContainers) {
      if (toegestaneTitels.contains(_normaliseerTitel(container.titel)) &&
          container.afmeting.trim().isNotEmpty) {
        return container.afmeting.trim();
      }

      for (final regel in container.zichtbareRegels) {
        if (toegestaneTitels.contains(_normaliseerTitel(regel.titel)) &&
            regel.waarde.trim().isNotEmpty) {
          return regel.waarde.trim();
        }
      }
    }

    return '';
  }

  static List<T> _lijstVoorKader<T>({
    required String kaderId,
    required int aantalKaders,
    required List<T> basis,
    required Map<String, List<T>> perKader,
  }) {
    final lijst = perKader[kaderId];
    if (lijst != null) {
      return lijst;
    }
    return aantalKaders <= 1 ? basis : <T>[];
  }

  static int _vergelijkKadersLinksNaarRechtsBovenNaarOnder(
    OpmetingKaderDeel eerste,
    OpmetingKaderDeel tweede,
  ) {
    final xVergelijking = eerste.xMm.compareTo(tweede.xMm);
    if (xVergelijking != 0) {
      return xVergelijking;
    }
    final yVergelijking = eerste.yMm.compareTo(tweede.yMm);
    if (yVergelijking != 0) {
      return yVergelijking;
    }
    return eerste.id.toString().compareTo(tweede.id.toString());
  }

  static int _vergelijkKadersLinksNaarRechtsOnderNaarBoven(
    OpmetingKaderDeel eerste,
    OpmetingKaderDeel tweede,
  ) {
    final xVergelijking = eerste.xMm.compareTo(tweede.xMm);
    if (xVergelijking != 0) {
      return xVergelijking;
    }
    final yVergelijking = tweede.yMm.compareTo(eerste.yMm);
    if (yVergelijking != 0) {
      return yVergelijking;
    }
    return eerste.id.toString().compareTo(tweede.id.toString());
  }

  static bool _isVerticaal(OpmetingRaamTStijl tStijl) {
    final richting = tStijl.richting.trim().toLowerCase();
    if (richting == 'verticaal') {
      return true;
    }
    if (richting == 'horizontaal') {
      return false;
    }
    return (tStijl.start.dx - tStijl.einde.dx).abs() <
        (tStijl.start.dy - tStijl.einde.dy).abs();
  }

  static int _vakIndex(double waarde, List<double> scheidingen) {
    var index = 0;
    for (final scheiding in scheidingen) {
      if (waarde > scheiding) {
        index++;
      }
    }
    return index;
  }

  static List<double> _uniekeGesorteerdeWaarden(Iterable<double> waarden) {
    final resultaat = <double>[];
    final gesorteerd = waarden.where((waarde) => waarde.isFinite).toList()
      ..sort();

    for (final waarde in gesorteerd) {
      if (resultaat.isEmpty || (resultaat.last - waarde).abs() > 0.5) {
        resultaat.add(waarde);
      }
    }

    return resultaat;
  }

  static int _vergelijkVleugels(
    OpmetingRaamVleugel eerste,
    OpmetingRaamVleugel tweede,
  ) {
    final xVergelijking = eerste.vlak.center.dx.compareTo(
      tweede.vlak.center.dx,
    );
    if (xVergelijking != 0) {
      return xVergelijking;
    }
    return eerste.vlak.center.dy.compareTo(tweede.vlak.center.dy);
  }

  static int _vergelijkVleugelsVanOnderNaarBoven(
    OpmetingRaamVleugel eerste,
    OpmetingRaamVleugel tweede,
  ) {
    final xVergelijking = eerste.vlak.center.dx.compareTo(
      tweede.vlak.center.dx,
    );
    if (xVergelijking != 0) {
      return xVergelijking;
    }
    return tweede.vlak.center.dy.compareTo(eerste.vlak.center.dy);
  }

  static String _normaliseerTitel(String titel) {
    return titel.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}
