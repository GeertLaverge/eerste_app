// THIMACO-CONTROLE: OFFERTE-MAIL-VERZONDEN-ITEMS-CONTROLE-20260802
// THIMACO-CONTROLE: OFFERTE-MAIL-ZONDER-AUTOMATISCHE-LOGINPOPUP-20260802
// THIMACO-CONTROLE: OFFERTE-MAIL-LEES-EN-ONTVANGSTBEVESTIGING-20260802
// THIMACO-CONTROLE: OFFERTE-MAIL-GRAPH-VERZEND-SERVICE-20260802

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../sync/onedrive_auth_service.dart';

class OfferteMailBijlage {
  const OfferteMailBijlage({
    required this.bestandsnaam,
    required this.bytes,
    this.contentType = 'application/pdf',
  });

  final String bestandsnaam;
  final Uint8List bytes;
  final String contentType;
}

typedef OfferteMailVoortgang = void Function(String status, double voortgang);

class OfferteMailVerzendService {
  OfferteMailVerzendService({OneDriveAuthService? authService})
    : _authService = authService ?? OneDriveAuthService();

  static const String _graphBasis = 'https://graph.microsoft.com/v1.0';
  static const int _kleineBijlageGrens = 3 * 1024 * 1024;
  static const int _maximaleBijlageGrootte = 150 * 1024 * 1024;
  static const int _uploadBlokGrootte = 3932160; // 12 × 320 KiB, onder 4 MiB.
  static const String _immutableIdVoorkeur = 'IdType="ImmutableId"';

  final OneDriveAuthService _authService;
  String? _token;

  Future<void> verstuur({
    required String ontvanger,
    required String onderwerp,
    required String bericht,
    required List<OfferteMailBijlage> bijlagen,
    OfferteMailVoortgang? onVoortgang,
  }) async {
    final schoonAdres = ontvanger.trim();
    if (!_isGeldigEmailadres(schoonAdres)) {
      throw const OfferteMailVerzendException(
        'Geef een geldig e-mailadres van de klant in.',
      );
    }
    if (onderwerp.trim().isEmpty) {
      throw const OfferteMailVerzendException(
        'Geef een onderwerp voor de e-mail in.',
      );
    }
    if (bericht.trim().isEmpty) {
      throw const OfferteMailVerzendException(
        'De e-mailtekst mag niet leeg zijn.',
      );
    }
    for (final bijlage in bijlagen) {
      if (bijlage.bytes.isEmpty) {
        throw OfferteMailVerzendException(
          'De bijlage “${bijlage.bestandsnaam}” is leeg.',
        );
      }
      if (bijlage.bytes.length > _maximaleBijlageGrootte) {
        throw OfferteMailVerzendException(
          'De bijlage “${bijlage.bestandsnaam}” is groter dan 150 MB.',
        );
      }
    }

    // Gewone offerte-mails worden rechtstreeks via /me/sendMail verstuurd.
    // Dit is dezelfde eenvoudige Graph-verzendroute die geen tijdelijk concept
    // achterlaat en expliciet bewaart in Verzonden items.
    final totaleBijlageGrootte = bijlagen.fold<int>(
      0,
      (totaal, bijlage) => totaal + bijlage.bytes.length,
    );
    if (totaleBijlageGrootte < _kleineBijlageGrens) {
      onVoortgang?.call('E-mail versturen…', 0.10);
      await _verstuurRechtstreeks(
        ontvanger: schoonAdres,
        onderwerp: onderwerp.trim(),
        bericht: bericht.trim(),
        bijlagen: bijlagen,
      );
      onVoortgang?.call('E-mail verstuurd', 1.0);
      return;
    }

    // Alleen voor grotere totale bijlagen blijft de uploadsessie via een
    // concept nodig. Dit pad wordt niet gebruikt voor gewone kleine offertes.
    String? conceptId;
    try {
      onVoortgang?.call('E-mail voorbereiden…', 0.05);
      conceptId = await _maakConcept(
        ontvanger: schoonAdres,
        onderwerp: onderwerp.trim(),
        bericht: bericht.trim(),
      );

      for (var index = 0; index < bijlagen.length; index++) {
        final bijlage = bijlagen[index];
        final basis = 0.10 + (index / bijlagen.length) * 0.78;
        final bereik = 0.78 / bijlagen.length;

        onVoortgang?.call(
          'Bijlage ${index + 1} van ${bijlagen.length}: '
          '${bijlage.bestandsnaam}',
          basis,
        );

        if (bijlage.bytes.length < _kleineBijlageGrens) {
          await _voegKleineBijlageToe(conceptId, bijlage);
          onVoortgang?.call(
            'Bijlage ${index + 1} van ${bijlagen.length} toegevoegd',
            basis + bereik,
          );
        } else {
          await _voegGroteBijlageToe(
            conceptId,
            bijlage,
            onDeelVoortgang: (deel) {
              onVoortgang?.call(
                'Bijlage ${index + 1} van ${bijlagen.length}: '
                '${bijlage.bestandsnaam}',
                basis + bereik * deel,
              );
            },
          );
        }
      }

      onVoortgang?.call('E-mail versturen…', 0.94);
      await _verstuurConcept(conceptId);
      onVoortgang?.call('E-mail verstuurd', 1.0);
    } catch (fout) {
      final opdrachtAanvaard =
          fout is OfferteMailVerzendException && fout.verzendOpdrachtAanvaard;
      if (conceptId != null && !opdrachtAanvaard) {
        await _verwijderConceptBestEffort(conceptId);
      }
      rethrow;
    }
  }

  Future<void> _verstuurRechtstreeks({
    required String ontvanger,
    required String onderwerp,
    required String bericht,
    required List<OfferteMailBijlage> bijlagen,
  }) async {
    final response = await _postJsonMetHerlogin(
      Uri.parse('$_graphBasis/me/sendMail'),
      <String, dynamic>{
        'message': <String, dynamic>{
          'subject': onderwerp,
          'body': <String, dynamic>{'contentType': 'Text', 'content': bericht},
          'toRecipients': <Map<String, dynamic>>[
            <String, dynamic>{
              'emailAddress': <String, dynamic>{'address': ontvanger},
            },
          ],
          'isReadReceiptRequested': true,
          'isDeliveryReceiptRequested': true,
          'attachments': bijlagen
              .map((bijlage) {
                return <String, dynamic>{
                  '@odata.type': '#microsoft.graph.fileAttachment',
                  'name': _veiligeBestandsnaam(bijlage.bestandsnaam),
                  'contentType': bijlage.contentType,
                  'contentBytes': base64Encode(bijlage.bytes),
                };
              })
              .toList(growable: false),
        },
        'saveToSentItems': true,
      },
    );

    if (response.statusCode != 202) {
      throw OfferteMailVerzendException(
        _foutmelding(
          response,
          standaard: 'De e-mail kon niet worden verstuurd.',
        ),
      );
    }
  }

  Future<String> _maakConcept({
    required String ontvanger,
    required String onderwerp,
    required String bericht,
  }) async {
    final response = await _postJsonMetHerlogin(
      Uri.parse('$_graphBasis/me/messages'),
      <String, dynamic>{
        'subject': onderwerp,
        'isReadReceiptRequested': true,
        'isDeliveryReceiptRequested': true,
        'body': <String, dynamic>{'contentType': 'Text', 'content': bericht},
        'toRecipients': <Map<String, dynamic>>[
          <String, dynamic>{
            'emailAddress': <String, dynamic>{'address': ontvanger},
          },
        ],
      },
    );

    if (response.statusCode != 201) {
      throw OfferteMailVerzendException(
        _foutmelding(
          response,
          standaard: 'De e-mail kon niet worden voorbereid.',
        ),
      );
    }

    final data = _leesJsonMap(response);
    final id = data['id']?.toString().trim() ?? '';
    if (id.isEmpty) {
      throw const OfferteMailVerzendException(
        'Microsoft gaf geen geldig e-mailconcept terug.',
      );
    }
    return id;
  }

  Future<void> _voegKleineBijlageToe(
    String conceptId,
    OfferteMailBijlage bijlage,
  ) async {
    final response = await _postJsonMetHerlogin(
      Uri.parse(
        '$_graphBasis/me/messages/${Uri.encodeComponent(conceptId)}/attachments',
      ),
      <String, dynamic>{
        '@odata.type': '#microsoft.graph.fileAttachment',
        'name': _veiligeBestandsnaam(bijlage.bestandsnaam),
        'contentType': bijlage.contentType,
        'contentBytes': base64Encode(bijlage.bytes),
      },
    );

    if (response.statusCode != 201) {
      throw OfferteMailVerzendException(
        _foutmelding(
          response,
          standaard:
              'De bijlage “${bijlage.bestandsnaam}” kon niet worden toegevoegd.',
        ),
      );
    }
  }

  Future<void> _voegGroteBijlageToe(
    String conceptId,
    OfferteMailBijlage bijlage, {
    required void Function(double voortgang) onDeelVoortgang,
  }) async {
    final sessieResponse = await _postJsonMetHerlogin(
      Uri.parse(
        '$_graphBasis/me/messages/${Uri.encodeComponent(conceptId)}'
        '/attachments/createUploadSession',
      ),
      <String, dynamic>{
        'AttachmentItem': <String, dynamic>{
          'attachmentType': 'file',
          'name': _veiligeBestandsnaam(bijlage.bestandsnaam),
          'size': bijlage.bytes.length,
          'contentType': bijlage.contentType,
        },
      },
    );

    if (sessieResponse.statusCode != 201) {
      throw OfferteMailVerzendException(
        _foutmelding(
          sessieResponse,
          standaard:
              'De grote bijlage “${bijlage.bestandsnaam}” kon niet worden voorbereid.',
        ),
      );
    }

    final sessieData = _leesJsonMap(sessieResponse);
    final uploadUrl = sessieData['uploadUrl']?.toString().trim() ?? '';
    if (uploadUrl.isEmpty) {
      throw OfferteMailVerzendException(
        'Microsoft gaf geen uploadadres terug voor “${bijlage.bestandsnaam}”.',
      );
    }

    final totaal = bijlage.bytes.length;
    var start = 0;

    while (start < totaal) {
      final eindeExclusief = (start + _uploadBlokGrootte)
          .clamp(0, totaal)
          .toInt();
      final eindeInclusief = eindeExclusief - 1;
      final deel = Uint8List.sublistView(bijlage.bytes, start, eindeExclusief);

      final response = await http.put(
        Uri.parse(uploadUrl),
        headers: <String, String>{
          'Content-Length': deel.length.toString(),
          'Content-Range': 'bytes $start-$eindeInclusief/$totaal',
          'Content-Type': 'application/octet-stream',
        },
        body: deel,
      );

      final isLaatste = eindeExclusief >= totaal;
      final geldig = isLaatste
          ? response.statusCode == 200 || response.statusCode == 201
          : response.statusCode == 202;

      if (!geldig) {
        throw OfferteMailVerzendException(
          _foutmelding(
            response,
            standaard:
                'De bijlage “${bijlage.bestandsnaam}” kon niet volledig worden opgeladen.',
          ),
        );
      }

      start = eindeExclusief;
      onDeelVoortgang(start / totaal);
    }
  }

  Future<void> _verstuurConcept(String conceptId) async {
    final response = await _postLeegMetStilleToken(
      Uri.parse(
        '$_graphBasis/me/messages/${Uri.encodeComponent(conceptId)}/send',
      ),
    );

    if (response.statusCode != 202) {
      throw OfferteMailVerzendException(
        _foutmelding(
          response,
          standaard: 'De e-mail kon niet worden verstuurd.',
        ),
      );
    }

    await _controleerWerkelijkVerzonden(conceptId);
  }

  Future<void> _controleerWerkelijkVerzonden(String conceptId) async {
    final verzondenMapId = await _haalVerzondenMapId();

    for (var poging = 0; poging < 10; poging++) {
      if (poging > 0) {
        await Future<void>.delayed(const Duration(milliseconds: 600));
      }

      final response = await _getMetStilleToken(
        Uri.parse(
          '$_graphBasis/me/messages/${Uri.encodeComponent(conceptId)}?'
          r'$select=id,isDraft,parentFolderId,sentDateTime,subject',
        ),
      );

      if (response.statusCode == 404) {
        continue;
      }
      if (response.statusCode != 200) {
        throw OfferteMailVerzendException(
          _foutmelding(
            response,
            standaard:
                'Microsoft aanvaardde de verzending, maar de controle van Verzonden items mislukte.',
          ),
          verzendOpdrachtAanvaard: true,
        );
      }

      final data = _leesJsonMap(response);
      final isConcept = data['isDraft'] == true;
      final mapId = data['parentFolderId']?.toString().trim() ?? '';
      final verzondenOp = data['sentDateTime']?.toString().trim() ?? '';

      if (!isConcept &&
          verzondenOp.isNotEmpty &&
          mapId.isNotEmpty &&
          mapId == verzondenMapId) {
        return;
      }
    }

    throw const OfferteMailVerzendException(
      'Microsoft heeft de verzendopdracht aanvaard, maar het bericht kon niet '
      'binnen enkele seconden in Verzonden items worden bevestigd. Controleer '
      'de internetverbinding en probeer niet onmiddellijk opnieuw te verzenden.',
      verzendOpdrachtAanvaard: true,
    );
  }

  Future<String> _haalVerzondenMapId() async {
    final response = await _getMetStilleToken(
      Uri.parse('$_graphBasis/me/mailFolders/sentitems?\$select=id'),
    );
    if (response.statusCode != 200) {
      throw OfferteMailVerzendException(
        _foutmelding(
          response,
          standaard: 'De map Verzonden items kon niet worden gecontroleerd.',
        ),
        verzendOpdrachtAanvaard: true,
      );
    }
    final id = _leesJsonMap(response)['id']?.toString().trim() ?? '';
    if (id.isEmpty) {
      throw const OfferteMailVerzendException(
        'Microsoft gaf geen geldige map Verzonden items terug.',
        verzendOpdrachtAanvaard: true,
      );
    }
    return id;
  }

  Future<void> _verwijderConceptBestEffort(String conceptId) async {
    try {
      final token = await _haalStilleToken();
      await http.delete(
        Uri.parse('$_graphBasis/me/messages/${Uri.encodeComponent(conceptId)}'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Prefer': _immutableIdVoorkeur,
        },
      );
    } catch (_) {
      // Een mislukte opruiming mag de oorspronkelijke fout niet vervangen.
    }
  }

  Future<http.Response> _postJsonMetHerlogin(
    Uri url,
    Map<String, dynamic> inhoud,
  ) async {
    var token = await _haalStilleToken();
    var response = await http.post(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Prefer': _immutableIdVoorkeur,
      },
      body: jsonEncode(inhoud),
    );

    if (response.statusCode == 401) {
      token = await _vernieuwStilleToken();
      response = await http.post(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Prefer': _immutableIdVoorkeur,
        },
        body: jsonEncode(inhoud),
      );
    }
    return response;
  }

  Future<http.Response> _postLeegMetStilleToken(Uri url) async {
    var token = await _haalStilleToken();
    var response = await http.post(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Length': '0',
        'Prefer': _immutableIdVoorkeur,
      },
    );

    if (response.statusCode == 401) {
      token = await _vernieuwStilleToken();
      response = await http.post(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Length': '0',
          'Prefer': _immutableIdVoorkeur,
        },
      );
    }
    return response;
  }

  Future<http.Response> _getMetStilleToken(Uri url) async {
    var token = await _haalStilleToken();
    var response = await http.get(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Prefer': _immutableIdVoorkeur,
      },
    );

    if (response.statusCode == 401) {
      token = await _vernieuwStilleToken();
      response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Prefer': _immutableIdVoorkeur,
        },
      );
    }
    return response;
  }

  Future<String> _haalStilleToken() async {
    if (_token?.trim().isNotEmpty == true) {
      return _token!;
    }

    final token = await _authService.tokenSilent();
    if (token.trim().isEmpty || token.startsWith('FOUT')) {
      throw OfferteMailVerzendException(
        'De stille Microsoft-sessie is niet beschikbaar. Open Instellingen en '
        'druk één keer zelf op Aanmelden Microsoft.\n$token',
      );
    }

    _token = token;
    return token;
  }

  Future<String> _vernieuwStilleToken() async {
    _token = null;
    _authService.wisTijdelijkToken();
    return _haalStilleToken();
  }

  Map<String, dynamic> _leesJsonMap(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
    } catch (_) {
      // De aanroeper maakt een duidelijke foutmelding.
    }
    return <String, dynamic>{};
  }

  String _foutmelding(http.Response response, {required String standaard}) {
    String detail = '';
    try {
      final data = jsonDecode(response.body);
      if (data is Map) {
        final error = data['error'];
        if (error is Map) {
          detail = error['message']?.toString().trim() ?? '';
        }
      }
    } catch (_) {
      detail = response.body.trim();
    }

    if (detail.isEmpty) {
      return '$standaard (Microsoft-fout ${response.statusCode})';
    }
    return '$standaard\nMicrosoft-fout ${response.statusCode}: $detail';
  }

  static bool _isGeldigEmailadres(String waarde) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(waarde.trim());
  }

  static String _veiligeBestandsnaam(String waarde) {
    final schoon = waarde.trim().replaceAll(RegExp(r'[\\/:*?"<>|]+'), '_');
    return schoon.isEmpty ? 'document.pdf' : schoon;
  }
}

class OfferteMailVerzendException implements Exception {
  const OfferteMailVerzendException(
    this.bericht, {
    this.verzendOpdrachtAanvaard = false,
  });

  final String bericht;
  final bool verzendOpdrachtAanvaard;

  @override
  String toString() => bericht;
}
