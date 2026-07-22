import '../../opmeting/overzicht/opmeting_overzicht_model.dart';
import 'offerte_artikel_prijs_koppeling_service.dart';

class OfferteProjectPrijsActie {
  const OfferteProjectPrijsActie({
    required this.formulierType,
    required this.formulierNaam,
    required this.knopLabel,
  });

  final String formulierType;
  final String formulierNaam;
  final String knopLabel;
}

/// Centrale registratie van alle opmeetfiches die de gezamenlijke
/// artikelprijsopslag gebruiken. Hierdoor werken vrije en projectbrede
/// prijsacties op exact dezelfde artikeltypes als de offerteberekening.
class OfferteProjectPrijsActieHelper {
  const OfferteProjectPrijsActieHelper._();

  static const List<OfferteProjectPrijsActie> _geregistreerdeActies =
      <OfferteProjectPrijsActie>[
        OfferteProjectPrijsActie(
          formulierType: 'vasteInzethor',
          formulierNaam: 'Vaste inzethor',
          knopLabel: 'Prijs voor alle inzethorren',
        ),
        OfferteProjectPrijsActie(
          formulierType: 'pvcRaam',
          formulierNaam: 'PVC raam',
          knopLabel: 'Prijs voor alle PVC ramen',
        ),
        OfferteProjectPrijsActie(
          formulierType: 'aluRaam',
          formulierNaam: 'ALU raam',
          knopLabel: 'Prijs voor alle ALU ramen',
        ),
        OfferteProjectPrijsActie(
          formulierType: 'pvcSchuifraam',
          formulierNaam: 'PVC schuifraam',
          knopLabel: 'Prijs voor alle PVC schuiframen',
        ),
        OfferteProjectPrijsActie(
          formulierType: 'aluSchuifraam',
          formulierNaam: 'ALU schuifraam',
          knopLabel: 'Prijs voor alle ALU schuiframen',
        ),
        OfferteProjectPrijsActie(
          formulierType: 'pvcDeur',
          formulierNaam: 'PVC deur',
          knopLabel: 'Prijs voor alle PVC deuren',
        ),
        OfferteProjectPrijsActie(
          formulierType: 'aluDeur',
          formulierNaam: 'ALU deur',
          knopLabel: 'Prijs voor alle ALU deuren',
        ),
      ];

  static List<String> get ondersteundeFormulierTypes {
    return List<String>.unmodifiable(
      _geregistreerdeActies.map((actie) => actie.formulierType),
    );
  }

  static List<OfferteProjectPrijsActie> beschikbareProjectPrijsActies(
    Iterable<OpmetingOverzichtRaamItem> opmetingen,
  ) {
    return List<OfferteProjectPrijsActie>.unmodifiable(
      _geregistreerdeActies.where((actie) {
        return opmetingen.any((opmeting) {
          return _isGeldigArtikelVoorActie(
            opmeting: opmeting,
            actie: actie,
            alleenHoofdofferte: true,
          );
        });
      }),
    );
  }

  static OfferteProjectPrijsActie? actieVoorFormulierType(
    String formulierType,
  ) {
    final sleutel = _normaliseerFormulierType(formulierType);
    for (final actie in _geregistreerdeActies) {
      if (_normaliseerFormulierType(actie.formulierType) == sleutel) {
        return actie;
      }
    }
    return null;
  }

  static bool toonVrijePrijsPerArtikelKnop({
    required OpmetingOverzichtRaamItem opmeting,
    required bool berekenPrijzen,
  }) {
    if (!berekenPrijzen || opmeting.isVerwijderd) return false;
    return OfferteArtikelPrijsKoppelingService.isOndersteundArtikel(opmeting);
  }

  static bool _isGeldigArtikelVoorActie({
    required OpmetingOverzichtRaamItem opmeting,
    required OfferteProjectPrijsActie actie,
    required bool alleenHoofdofferte,
  }) {
    if (opmeting.isVerwijderd ||
        (alleenHoofdofferte && !opmeting.teltMeeInHoofdofferte)) {
      return false;
    }

    final koppeling = OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(
      opmeting,
    );
    if (koppeling == null) return false;

    return _normaliseerFormulierType(koppeling.formulierType) ==
        _normaliseerFormulierType(actie.formulierType);
  }

  static String _normaliseerFormulierType(String waarde) {
    return waarde.trim().toLowerCase().replaceAll('_', '').replaceAll(' ', '');
  }
}
