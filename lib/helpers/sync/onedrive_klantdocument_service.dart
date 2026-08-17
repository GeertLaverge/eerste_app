// THIMACO-CONTROLE: ONEDRIVE-UPLOAD-ACCOUNT-DRIVE-HARD-CONTROLE-20260817
// THIMACO-CONTROLE: ONEDRIVE-BESTANDEN-ZICHTBAAR-EN-UPLOAD-CONTROLE-20260817
// THIMACO-CONTROLE: ONEDRIVE-KLANTDOCUMENTEN-MAPPEN-EN-BESTANDSNAAM-20260731
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'onedrive_auth_service.dart';

class OneDriveMapItem {
  const OneDriveMapItem({
    required this.id,
    required this.naam,
    this.isMap = true,
    this.mimeType = '',
    this.grootteBytes = 0,
    this.gewijzigdOp = '',
  });

  final String id;
  final String naam;
  final bool isMap;
  final String mimeType;
  final int grootteBytes;
  final String gewijzigdOp;

  bool get isBestand => !isMap;
}

class OneDriveGekozenMap {
  const OneDriveGekozenMap({
    required this.id,
    required this.pad,
    required this.bestandsnaam,
  });

  final String id;
  final String pad;
  final String bestandsnaam;
}

class OneDriveKlantdocumentResultaat {
  const OneDriveKlantdocumentResultaat({
    required this.documentType,
    required this.mapPad,
    required this.bestandsnaam,
    this.webUrl = '',
    this.accountNaam = '',
    this.accountEmail = '',
    this.accountId = '',
    this.driveId = '',
    this.driveNaam = '',
    this.bestandId = '',
    this.grootteBytes = 0,
  });

  final String documentType;
  final String mapPad;
  final String bestandsnaam;
  final String webUrl;
  final String accountNaam;
  final String accountEmail;
  final String accountId;
  final String driveId;
  final String driveNaam;
  final String bestandId;
  final int grootteBytes;

  String get volledigPad => '$mapPad/$bestandsnaam';
}

class OneDriveKlantdocumentException implements Exception {
  const OneDriveKlantdocumentException(this.bericht);

  final String bericht;

  @override
  String toString() => bericht;
}

class OneDriveKlantdocumentService {
  OneDriveKlantdocumentService({OneDriveAuthService? authService})
    : _authService = authService ?? OneDriveAuthService();

  static const String _graphBasis = 'https://graph.microsoft.com/v1.0';
  static final RegExp _ongeldigeOneDriveTekens = RegExp(r'["*:<>?/\\|]');

  final OneDriveAuthService _authService;

  static String normaliseerPdfBestandsnaam(String waarde) {
    final naam = waarde.trim();
    if (naam.isEmpty) return '';

    return naam.toLowerCase().endsWith('.pdf') ? naam : '$naam.pdf';
  }

  static String? valideerMapNaam(String waarde) {
    final naam = waarde.trim();

    if (naam.isEmpty) {
      return 'Geef een naam in voor de nieuwe map.';
    }
    if (naam == '.' || naam == '..') {
      return 'Deze mapnaam is niet toegestaan.';
    }
    if (_ongeldigeOneDriveTekens.hasMatch(naam)) {
      return 'De mapnaam bevat een teken dat OneDrive niet toestaat.';
    }
    if (naam.endsWith('.') || naam.endsWith(' ')) {
      return 'Een mapnaam mag niet eindigen met een punt of spatie.';
    }

    return null;
  }

  static String? valideerPdfBestandsnaam(String waarde) {
    final naam = normaliseerPdfBestandsnaam(waarde);

    if (naam.isEmpty) {
      return 'Geef een bestandsnaam in voor de PDF.';
    }
    if (_ongeldigeOneDriveTekens.hasMatch(naam)) {
      return 'De bestandsnaam bevat een teken dat OneDrive niet toestaat.';
    }
    if (naam.endsWith('.') || naam.endsWith(' ')) {
      return 'Een bestandsnaam mag niet eindigen met een punt of spatie.';
    }

    return null;
  }

  Future<List<OneDriveMapItem>> laadItems({String? bovenliggendeMapId}) async {
    final eersteUrl = bovenliggendeMapId == null
        ? Uri.parse(
            '$_graphBasis/me/drive/root/children?'
            r'$select=id,name,folder,file,size,lastModifiedDateTime&$top=200',
          )
        : Uri.parse(
            '$_graphBasis/me/drive/items/'
            '${Uri.encodeComponent(bovenliggendeMapId)}/children?'
            r'$select=id,name,folder,file,size,lastModifiedDateTime&$top=200',
          );

    final resultaat = <OneDriveMapItem>[];
    Uri? volgendeUrl = eersteUrl;

    while (volgendeUrl != null) {
      final response = await _getMetHerlogin(volgendeUrl);

      if (response.statusCode != 200) {
        throw OneDriveKlantdocumentException(
          _maakGraphFoutmelding(
            response,
            standaard: 'De OneDrive-map kon niet worden gelezen.',
          ),
        );
      }

      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        throw const OneDriveKlantdocumentException(
          'OneDrive gaf een onverwacht antwoord bij het openen van de map.',
        );
      }

      final items = data['value'];
      if (items is List) {
        for (final item in items) {
          if (item is! Map) continue;

          final id = item['id']?.toString().trim() ?? '';
          final naam = item['name']?.toString().trim() ?? '';
          if (id.isEmpty || naam.isEmpty) continue;

          final isMap = item['folder'] != null;
          final fileData = item['file'];
          final mimeType = fileData is Map
              ? fileData['mimeType']?.toString().trim() ?? ''
              : '';

          final sizeValue = item['size'];
          final grootteBytes = sizeValue is num
              ? sizeValue.toInt()
              : int.tryParse(sizeValue?.toString() ?? '') ?? 0;

          resultaat.add(
            OneDriveMapItem(
              id: id,
              naam: naam,
              isMap: isMap,
              mimeType: mimeType,
              grootteBytes: grootteBytes,
              gewijzigdOp:
                  item['lastModifiedDateTime']?.toString().trim() ?? '',
            ),
          );
        }
      }

      final volgendeLink = data['@odata.nextLink']?.toString().trim() ?? '';
      volgendeUrl = volgendeLink.isEmpty ? null : Uri.tryParse(volgendeLink);
    }

    resultaat.sort((links, rechts) {
      if (links.isMap != rechts.isMap) {
        return links.isMap ? -1 : 1;
      }

      return links.naam.toLowerCase().compareTo(rechts.naam.toLowerCase());
    });

    return List<OneDriveMapItem>.unmodifiable(resultaat);
  }

  /// Bestaande callers die enkel mappen nodig hebben blijven werken.
  Future<List<OneDriveMapItem>> laadMappen({String? bovenliggendeMapId}) async {
    final items = await laadItems(bovenliggendeMapId: bovenliggendeMapId);

    return items.where((item) => item.isMap).toList(growable: false);
  }

  Future<OneDriveMapItem> maakMap({
    String? bovenliggendeMapId,
    required String naam,
  }) async {
    final schoneNaam = naam.trim();
    final validatieFout = valideerMapNaam(schoneNaam);
    if (validatieFout != null) {
      throw OneDriveKlantdocumentException(validatieFout);
    }

    final url = bovenliggendeMapId == null
        ? Uri.parse('$_graphBasis/me/drive/root/children')
        : Uri.parse(
            '$_graphBasis/me/drive/items/'
            '${Uri.encodeComponent(bovenliggendeMapId)}/children',
          );

    final response = await _postJsonMetHerlogin(url, <String, dynamic>{
      'name': schoneNaam,
      'folder': <String, dynamic>{},
      '@microsoft.graph.conflictBehavior': 'fail',
    });

    if (response.statusCode == 409) {
      throw OneDriveKlantdocumentException(
        'Er bestaat al een map met de naam “$schoneNaam” in deze map.',
      );
    }

    if (response.statusCode != 201) {
      throw OneDriveKlantdocumentException(
        _maakGraphFoutmelding(
          response,
          standaard: 'De nieuwe OneDrive-map kon niet worden aangemaakt.',
        ),
      );
    }

    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic>) {
      throw const OneDriveKlantdocumentException(
        'OneDrive gaf geen geldige nieuwe map terug.',
      );
    }

    final id = data['id']?.toString().trim() ?? '';
    final teruggegevenNaam = data['name']?.toString().trim() ?? schoneNaam;

    if (id.isEmpty) {
      throw const OneDriveKlantdocumentException(
        'De nieuwe OneDrive-map heeft geen geldig mapnummer gekregen.',
      );
    }

    return OneDriveMapItem(id: id, naam: teruggegevenNaam);
  }

  Future<OneDriveKlantdocumentResultaat> uploadPdf({
    required OneDriveGekozenMap map,
    required String documentType,
    required String bestandsnaam,
    required Uint8List bytes,
  }) async {
    final schoneBestandsnaam = normaliseerPdfBestandsnaam(bestandsnaam);
    final validatieFout = valideerPdfBestandsnaam(schoneBestandsnaam);
    final gekozenMapId = map.id.trim();

    if (gekozenMapId.isEmpty) {
      throw const OneDriveKlantdocumentException(
        'Er werd geen geldige OneDrive-map gekozen.',
      );
    }

    if (validatieFout != null) {
      throw OneDriveKlantdocumentException(validatieFout);
    }

    if (bytes.isEmpty) {
      throw const OneDriveKlantdocumentException(
        'De PDF is leeg en kan niet naar OneDrive worden verstuurd.',
      );
    }

    // Leg vóór de upload exact vast met welk Microsoft-account en welke
    // OneDrive-drive de app werkt. Vanaf hier gebruiken we bewust de expliciete
    // drive-id en niet langer alleen /me/drive.
    final identiteitVoorUpload = await _haalOneDriveIdentiteit();
    final driveId = identiteitVoorUpload.driveId.trim();

    if (driveId.isEmpty) {
      throw const OneDriveKlantdocumentException(
        'Microsoft gaf geen geldige OneDrive-drive terug.',
      );
    }

    final gecodeerdeDriveId = Uri.encodeComponent(driveId);
    final gecodeerdeMapId = Uri.encodeComponent(gekozenMapId);
    final bestand = Uri.encodeComponent(schoneBestandsnaam);

    // 1. Bevestig dat de gekozen map werkelijk in exact deze drive bestaat.
    final mapControleUrl = Uri.parse(
      '$_graphBasis/drives/$gecodeerdeDriveId/items/$gecodeerdeMapId?'
      r'$select=id,name,folder,parentReference',
    );
    final mapControleResponse = await _getMetHerlogin(mapControleUrl);

    if (mapControleResponse.statusCode != 200) {
      throw OneDriveKlantdocumentException(
        _maakGraphFoutmelding(
          mapControleResponse,
          standaard:
              'De gekozen OneDrive-map bestaat niet meer in de actieve OneDrive-drive.',
        ),
      );
    }

    final mapData = _decodeerJsonMap(
      mapControleResponse,
      foutmelding:
          'OneDrive gaf geen geldige informatie over de gekozen map terug.',
    );

    final mapTerugId = mapData['id']?.toString().trim() ?? '';
    final mapParentReference = mapData['parentReference'];
    final mapDriveId = mapParentReference is Map
        ? mapParentReference['driveId']?.toString().trim() ?? ''
        : '';

    if (mapData['folder'] == null ||
        mapTerugId != gekozenMapId ||
        (mapDriveId.isNotEmpty && mapDriveId != driveId)) {
      throw OneDriveKlantdocumentException(
        'De gekozen map kon niet betrouwbaar aan de actieve OneDrive-drive worden gekoppeld.'
        '\nAccount: ${identiteitVoorUpload.accountEmail}'
        '\nMap: ${map.pad}',
      );
    }

    // 2. Upload expliciet naar dezelfde drive + dezelfde map.
    final uploadUrl = Uri.parse(
      '$_graphBasis/drives/$gecodeerdeDriveId/items/'
      '$gecodeerdeMapId:/$bestand:/content',
    );
    final response = await _putMetHerlogin(uploadUrl, bytes);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw OneDriveKlantdocumentException(
        _maakGraphFoutmelding(
          response,
          standaard: 'De PDF kon niet in OneDrive worden opgeslagen.',
        ),
      );
    }

    final uploadData = _decodeerJsonMap(
      response,
      foutmelding:
          'OneDrive meldde een geslaagde upload, maar gaf geen geldig bestand terug.',
    );

    final uploadId = uploadData['id']?.toString().trim() ?? '';
    final uploadNaam = uploadData['name']?.toString().trim() ?? '';
    final uploadGrootte = _leesInt(uploadData['size']);
    final uploadParentReference = uploadData['parentReference'];
    final uploadParentId = uploadParentReference is Map
        ? uploadParentReference['id']?.toString().trim() ?? ''
        : '';
    final uploadDriveId = uploadParentReference is Map
        ? uploadParentReference['driveId']?.toString().trim() ?? ''
        : '';
    var webUrl = uploadData['webUrl']?.toString().trim() ?? '';

    // De uploadrespons moet minstens een uniek item-id geven. Sommige Graph-
    // antwoorden laten overige velden weg; die worden daarom hieronder via
    // expliciete GET-controles verplicht gecontroleerd. Als een veld hier wel
    // aanwezig is, mag het uiteraard niet tegenspreken wat we verstuurd hebben.
    final uploadNaamWijktAf =
        uploadNaam.isNotEmpty &&
        uploadNaam.toLowerCase() != schoneBestandsnaam.toLowerCase();
    final uploadGrootteWijktAf =
        uploadGrootte >= 0 && uploadGrootte != bytes.length;
    final uploadParentWijktAf =
        uploadParentId.isNotEmpty && uploadParentId != gekozenMapId;
    final uploadDriveWijktAf =
        uploadDriveId.isNotEmpty && uploadDriveId != driveId;

    if (uploadId.isEmpty ||
        uploadNaamWijktAf ||
        uploadGrootteWijktAf ||
        uploadParentWijktAf ||
        uploadDriveWijktAf) {
      throw OneDriveKlantdocumentException(
        'Microsoft meldde dat de PDF werd opgeslagen, maar de uploadgegevens '
        'spreken het verzonden bestand tegen.'
        '\nVerzonden: ${bytes.length} bytes'
        '\nOneDrive: ${uploadGrootte >= 0 ? '$uploadGrootte bytes' : 'nog niet opgegeven'}'
        '\nAccount: ${identiteitVoorUpload.accountEmail}',
      );
    }

    // 3. Lees exact hetzelfde item opnieuw via zijn unieke Microsoft item-id.
    final itemControleUrl = Uri.parse(
      '$_graphBasis/drives/$gecodeerdeDriveId/items/'
      '${Uri.encodeComponent(uploadId)}?'
      r'$select=id,name,parentReference,webUrl,size,file',
    );
    final itemControleResponse = await _getMetHerlogin(itemControleUrl);

    if (itemControleResponse.statusCode != 200) {
      throw OneDriveKlantdocumentException(
        _maakGraphFoutmelding(
          itemControleResponse,
          standaard:
              'De PDF werd geüpload, maar kon niet opnieuw via haar OneDrive-bestandsnummer worden gelezen.',
        ),
      );
    }

    final itemData = _decodeerJsonMap(
      itemControleResponse,
      foutmelding:
          'OneDrive gaf geen geldige controle terug voor de geüploade PDF.',
    );
    _controleerBestandData(
      data: itemData,
      verwachtBestandId: uploadId,
      verwachteNaam: schoneBestandsnaam,
      verwachteMapId: gekozenMapId,
      verwachteDriveId: driveId,
      verwachteGrootte: bytes.length,
      foutmelding:
          'De PDF kon na upload niet betrouwbaar via haar OneDrive-bestandsnummer worden bevestigd.',
    );

    final gecontroleerdeWebUrl = itemData['webUrl']?.toString().trim() ?? '';
    if (gecontroleerdeWebUrl.isNotEmpty) {
      webUrl = gecontroleerdeWebUrl;
    }

    // 4. Lees de inhoud van exact de gekozen map opnieuw en controleer dat
    // hetzelfde item daar ook werkelijk als child zichtbaar is.
    final mapBestand = await _vindBestandInMap(
      driveId: driveId,
      mapId: gekozenMapId,
      bestandId: uploadId,
    );

    if (mapBestand == null) {
      throw OneDriveKlantdocumentException(
        'De PDF werd geüpload, maar staat niet in de inhoudslijst van de gekozen OneDrive-map.'
        '\nAccount: ${identiteitVoorUpload.accountEmail}'
        '\nMap: ${map.pad}',
      );
    }

    _controleerBestandData(
      data: mapBestand,
      verwachtBestandId: uploadId,
      verwachteNaam: schoneBestandsnaam,
      verwachteMapId: gekozenMapId,
      verwachteDriveId: driveId,
      verwachteGrootte: bytes.length,
      foutmelding:
          'De PDF staat in de gekozen map, maar de gecontroleerde bestandsgegevens komen niet overeen.',
    );

    // 5. Controleer ten slotte dat tijdens de hele operatie niet ongemerkt van
    // Microsoft-account of OneDrive-drive is gewisseld.
    final identiteitNaUpload = await _haalOneDriveIdentiteit();

    if (identiteitNaUpload.accountId != identiteitVoorUpload.accountId ||
        identiteitNaUpload.driveId != identiteitVoorUpload.driveId) {
      throw OneDriveKlantdocumentException(
        'Het actieve Microsoft-account of de OneDrive-drive wijzigde tijdens het opslaan. '
        'Daarom wordt geen succesmelding getoond.',
      );
    }

    return OneDriveKlantdocumentResultaat(
      documentType: documentType,
      mapPad: map.pad,
      bestandsnaam: schoneBestandsnaam,
      webUrl: webUrl,
      accountNaam: identiteitVoorUpload.accountNaam,
      accountEmail: identiteitVoorUpload.accountEmail,
      accountId: identiteitVoorUpload.accountId,
      driveId: identiteitVoorUpload.driveId,
      driveNaam: identiteitVoorUpload.driveNaam,
      bestandId: uploadId,
      grootteBytes: bytes.length,
    );
  }

  Future<_OneDriveIdentiteit> _haalOneDriveIdentiteit() async {
    final gebruikerResponse = await _getMetHerlogin(
      Uri.parse(
        '$_graphBasis/me?'
        r'$select=id,displayName,mail,userPrincipalName',
      ),
    );

    if (gebruikerResponse.statusCode != 200) {
      throw OneDriveKlantdocumentException(
        _maakGraphFoutmelding(
          gebruikerResponse,
          standaard:
              'Het actieve Microsoft-account kon niet worden gecontroleerd.',
        ),
      );
    }

    final gebruikerData = _decodeerJsonMap(
      gebruikerResponse,
      foutmelding: 'Microsoft gaf geen geldige accountinformatie terug.',
    );

    final accountId = gebruikerData['id']?.toString().trim() ?? '';
    final accountNaam = gebruikerData['displayName']?.toString().trim() ?? '';
    final mail = gebruikerData['mail']?.toString().trim() ?? '';
    final gebruikersnaam =
        gebruikerData['userPrincipalName']?.toString().trim() ?? '';
    final accountEmail = mail.isNotEmpty ? mail : gebruikersnaam;

    if (accountId.isEmpty) {
      throw const OneDriveKlantdocumentException(
        'Microsoft gaf geen geldig accountnummer terug.',
      );
    }

    final driveResponse = await _getMetHerlogin(
      Uri.parse(
        '$_graphBasis/me/drive?'
        r'$select=id,name,driveType,webUrl,owner',
      ),
    );

    if (driveResponse.statusCode != 200) {
      throw OneDriveKlantdocumentException(
        _maakGraphFoutmelding(
          driveResponse,
          standaard: 'De actieve OneDrive-drive kon niet worden gecontroleerd.',
        ),
      );
    }

    final driveData = _decodeerJsonMap(
      driveResponse,
      foutmelding: 'Microsoft gaf geen geldige OneDrive-drive terug.',
    );

    final driveId = driveData['id']?.toString().trim() ?? '';
    final driveNaam = driveData['name']?.toString().trim() ?? '';

    if (driveId.isEmpty) {
      throw const OneDriveKlantdocumentException(
        'Microsoft gaf geen geldig OneDrive-drive nummer terug.',
      );
    }

    final owner = driveData['owner'];
    final ownerUser = owner is Map ? owner['user'] : null;
    final ownerId = ownerUser is Map
        ? ownerUser['id']?.toString().trim() ?? ''
        : '';

    if (ownerId.isNotEmpty && ownerId != accountId) {
      throw const OneDriveKlantdocumentException(
        'Het actieve Microsoft-account hoort niet bij de gevonden OneDrive-drive.',
      );
    }

    return _OneDriveIdentiteit(
      accountId: accountId,
      accountNaam: accountNaam,
      accountEmail: accountEmail,
      driveId: driveId,
      driveNaam: driveNaam,
    );
  }

  Future<Map<String, dynamic>?> _vindBestandInMap({
    required String driveId,
    required String mapId,
    required String bestandId,
  }) async {
    final gecodeerdeDriveId = Uri.encodeComponent(driveId);
    final gecodeerdeMapId = Uri.encodeComponent(mapId);
    Uri? volgendeUrl = Uri.parse(
      '$_graphBasis/drives/$gecodeerdeDriveId/items/'
      '$gecodeerdeMapId/children?'
      r'$select=id,name,parentReference,webUrl,size,file&$top=200',
    );

    while (volgendeUrl != null) {
      final response = await _getMetHerlogin(volgendeUrl);

      if (response.statusCode != 200) {
        throw OneDriveKlantdocumentException(
          _maakGraphFoutmelding(
            response,
            standaard:
                'De inhoud van de gekozen OneDrive-map kon na de upload niet opnieuw worden gecontroleerd.',
          ),
        );
      }

      final data = _decodeerJsonMap(
        response,
        foutmelding:
            'OneDrive gaf geen geldige inhoudslijst terug voor de gekozen map.',
      );

      final items = data['value'];
      if (items is List) {
        for (final item in items) {
          if (item is! Map) continue;

          final id = item['id']?.toString().trim() ?? '';
          if (id == bestandId) {
            return Map<String, dynamic>.from(item);
          }
        }
      }

      final volgendeLink = data['@odata.nextLink']?.toString().trim() ?? '';
      volgendeUrl = volgendeLink.isEmpty ? null : Uri.tryParse(volgendeLink);
    }

    return null;
  }

  void _controleerBestandData({
    required Map<String, dynamic> data,
    required String verwachtBestandId,
    required String verwachteNaam,
    required String verwachteMapId,
    required String verwachteDriveId,
    required int verwachteGrootte,
    required String foutmelding,
  }) {
    final id = data['id']?.toString().trim() ?? '';
    final naam = data['name']?.toString().trim() ?? '';
    final grootte = _leesInt(data['size']);
    final parentReference = data['parentReference'];
    final parentId = parentReference is Map
        ? parentReference['id']?.toString().trim() ?? ''
        : '';
    final parentDriveId = parentReference is Map
        ? parentReference['driveId']?.toString().trim() ?? ''
        : '';

    if (id != verwachtBestandId ||
        naam.toLowerCase() != verwachteNaam.toLowerCase() ||
        grootte != verwachteGrootte ||
        parentId != verwachteMapId ||
        parentDriveId != verwachteDriveId ||
        data['file'] == null) {
      throw OneDriveKlantdocumentException(
        '$foutmelding\n'
        'Verwacht: $verwachteNaam · $verwachteGrootte bytes',
      );
    }
  }

  Map<String, dynamic> _decodeerJsonMap(
    http.Response response, {
    required String foutmelding,
  }) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      // Onderstaande foutmelding is bewust eenduidig voor de gebruiker.
    }

    throw OneDriveKlantdocumentException(foutmelding);
  }

  int _leesInt(dynamic waarde) {
    if (waarde is int) return waarde;
    if (waarde is num) return waarde.toInt();
    return int.tryParse(waarde?.toString() ?? '') ?? -1;
  }

  Future<http.Response> _getMetHerlogin(Uri url) async {
    var token = await _haalToken();
    var response = await http.get(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 401) {
      token = await _haalToken(forceerVernieuwen: true);
      response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
    }

    return response;
  }

  Future<http.Response> _postJsonMetHerlogin(
    Uri url,
    Map<String, dynamic> inhoud,
  ) async {
    var token = await _haalToken();
    var response = await http.post(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(inhoud),
    );

    if (response.statusCode == 401) {
      token = await _haalToken(forceerVernieuwen: true);
      response = await http.post(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(inhoud),
      );
    }

    return response;
  }

  Future<http.Response> _putMetHerlogin(Uri url, Uint8List bytes) async {
    var token = await _haalToken();
    var response = await http.put(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/pdf',
        'Accept': 'application/json',
      },
      body: bytes,
    );

    if (response.statusCode == 401) {
      token = await _haalToken(forceerVernieuwen: true);
      response = await http.put(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/pdf',
          'Accept': 'application/json',
        },
        body: bytes,
      );
    }

    return response;
  }

  Future<String> _haalToken({bool forceerVernieuwen = false}) async {
    final token = await _authService.tokenVoorGraph(
      forceerVernieuwen: forceerVernieuwen,
    );

    if (token.startsWith('FOUT') || token.trim().isEmpty) {
      throw OneDriveKlantdocumentException(
        'Aanmelden bij OneDrive is niet gelukt.\n$token',
      );
    }

    return token.trim();
  }

  String _maakGraphFoutmelding(
    http.Response response, {
    required String standaard,
  }) {
    String detail = '';

    try {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        final error = data['error'];
        if (error is Map) {
          detail = error['message']?.toString().trim() ?? '';
        }
      }
    } catch (_) {
      detail = response.body.trim();
    }

    final code = response.statusCode;
    if (detail.isEmpty) {
      return '$standaard (OneDrive-fout $code)';
    }

    return '$standaard\nOneDrive-fout $code: $detail';
  }
}

class _OneDriveIdentiteit {
  const _OneDriveIdentiteit({
    required this.accountId,
    required this.accountNaam,
    required this.accountEmail,
    required this.driveId,
    required this.driveNaam,
  });

  final String accountId;
  final String accountNaam;
  final String accountEmail;
  final String driveId;
  final String driveNaam;
}
