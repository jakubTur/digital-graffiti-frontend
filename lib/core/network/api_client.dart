import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../app/config/config.dart';
import '../errors/api_exception.dart';

class ApiClient {
  final http.Client _client;
  final Future<String?> Function()? tokenProvider;
  final Future<String?> Function()? refreshTokenProvider;
  final Future<void> Function(String, String)? updateTokens;
  ApiClient({
    http.Client? client,
    this.tokenProvider,
    this.refreshTokenProvider,
    this.updateTokens,
  }) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
    if (tokenProvider != null) 'Authorization': 'Bearer $tokenProvider',
  };
  Future<dynamic> get(String path, {Map<String, String>? queryParameters}) =>
      send(
        'GET',
        path,
        queryParameters: queryParameters,
        expectedStatusCode: 200,
      );
  Future<dynamic> post(
    String path, {
    Map<String, String>? queryParameters,
    required Map<String, dynamic> body,
    int expectedStatusCode = 201,
  }) => send(
    'POST',
    path,
    queryParameters: queryParameters,
    body: body,
    expectedStatusCode: expectedStatusCode,
  );
  Future<dynamic> put(
    String path, {
    Map<String, String>? queryParameters,
    required Map<String, dynamic> body,
  }) => send(
    'PUT',
    path,
    queryParameters: queryParameters,
    body: body,
    expectedStatusCode: 200,
  );
  Future<dynamic> delete(String path, {Map<String, String>? queryParameters}) =>
      send(
        'DELETE',
        path,
        queryParameters: queryParameters,
        expectedStatusCode: 200,
      );
  Future<dynamic> patch(
    String path, {
    Map<String, String>? queryParameters,
    required Map<String, dynamic> body,
    int expectedStatusCode = 200,
  }) => send(
    'PATCH',
    path,
    queryParameters: queryParameters,
    body: body,
    expectedStatusCode: expectedStatusCode,
  );

  Future<dynamic> send(
    String method,
    String path, {
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
    required int expectedStatusCode,
    bool refreshed = false,
  }) async {
    final uri = Uri.parse('${Config.baseUrl}$path')
        .replace(queryParameters: queryParameters);
    debugPrint('$method $uri body=$body');
    final headers = await buildHeaders();
    final encodedBody = body == null ? null : jsonEncode(body);
    final http.Response response;
    switch (method) {
      case 'GET':
        response = await _client.get(uri, headers: headers);
      case 'POST':
        response = await _client.post(uri, headers: headers, body: encodedBody);
      case 'PUT':
        response = await _client.put(uri, headers: headers, body: encodedBody);
      case 'DELETE':
        response = await _client.delete(uri, headers: headers);
      case 'PATCH':
        response = await _client.patch(
          uri,
          headers: headers,
          body: encodedBody,
        );

      default:
        throw Exception('Unsupported method: $method');
    }
    final text = utf8.decode(response.bodyBytes);
    debugPrint('response: ${response.statusCode} $text');
    if (text.trim().isNotEmpty) {
      final data = jsonDecode(text);
      debugPrint('data: $data');
      final code = data is Map<String, dynamic> ? data['code'] : null;
      debugPrint(
        'refresh check: code=$code refreshed=$refreshed '
        'provider=${refreshTokenProvider != null}',
      );
    }

    final refreshToken = await refreshTokenProvider?.call();
    debugPrint('refresh token present: ${refreshToken != null}');
    if (response.statusCode != expectedStatusCode) {
      final code = jsonDecode(text) is Map<String, dynamic>
          ? jsonDecode(text)['code']
          : null;
      if (response.statusCode == 401 &&
          code != null &&
          code == 'ACCESS_TOKEN_EXPIRED' &&
          !refreshed &&
          refreshTokenProvider != null) {
        debugPrint('refresh ENTERED');
        final refreshToken = await refreshTokenProvider?.call();
        debugPrint('refresh token present: $refreshToken');
        if (refreshToken == null) {
          throw ApiException(response.statusCode, text);
        }
        final http.Response refreshResponse = await _client.post(
          Uri.parse('${Config.baseUrl}/auth/refresh'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
          },
          body: jsonEncode({'refreshToken': refreshToken}),
        );
        debugPrint(
          'refresh response: ${refreshResponse.statusCode} ${refreshResponse.body}',
        );
        if (refreshResponse.statusCode != 200) {
          throw ApiException(refreshResponse.statusCode, refreshResponse.body);
        }
        final refreshData = jsonDecode(refreshResponse.body);
        final accessToken = refreshData['accessToken'];
        final newRefreshToken = refreshData['refreshToken'];
        debugPrint('new tokens: $accessToken $newRefreshToken');
        if (updateTokens != null) {
          debugPrint('update tokens');
          await updateTokens?.call(accessToken, newRefreshToken);
        }
        return send(
          method,
          path,
          queryParameters: queryParameters,
          body: body,
          expectedStatusCode: expectedStatusCode,
          refreshed: true,
        );
      }
      throw ApiException(response.statusCode, text);
    }
    return text.isEmpty ? null : jsonDecode(text);
  }

  Future<Map<String, String>> buildHeaders() async {
    final token = await tokenProvider?.call();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> uploadFile(
    String path, {
    required String filePath,
    required String fileField,
    Map<String, String> fields = const {},
    int expectedStatusCode = 200,
  }) async {
    final uri = Uri.parse('${Config.baseUrl}$path');
    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('Image file does not exist: $filePath');
    }
    final fileLength = await file.length();
    debugPrint('POST multipart $uri');
    debugPrint('fileField: $fileField');
    debugPrint('filePath: $filePath');
    debugPrint('fileSize: $fileLength bytes');
    final request = http.MultipartRequest('POST', uri);
    final token = await tokenProvider?.call();
    request.headers['Accept'] = 'application/json';
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.fields.addAll(fields);
    request.files.add(
      await http.MultipartFile.fromPath(
        fileField,
        filePath,
        contentType: MediaType('image', 'png'),
      ),
    );
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final text = utf8.decode(response.bodyBytes);
    debugPrint(
      'photo upload response: '
      '${response.statusCode} ${response.body}',
    );
    if (response.statusCode != expectedStatusCode) {
      throw ApiException(response.statusCode, text);
    }
    debugPrint('photo upload response: ${response.statusCode} $text');
    return text.isEmpty ? null : jsonDecode(text);
  }
}
