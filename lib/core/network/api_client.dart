import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../app/config/config.dart';
import '../errors/api_exception.dart';

class ApiClient {
  final http.Client _client;
  final Future<String?> Function()? tokenProvider;
  ApiClient({http.Client? client, Future<String?> Function()? tokenProvider}) : _client = client ?? http.Client(), this.tokenProvider = tokenProvider;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
    if (tokenProvider != null) 'Authorization': 'Bearer $tokenProvider'
  };
  Future<dynamic> get(String path, {Map<String, String>? queryParameters}) => send('GET', path, queryParameters: queryParameters, expectedStatusCode: 200);
  Future<dynamic> post(String path, {Map<String, String>? queryParameters, required Map<String, dynamic> body}) => send('POST', path, queryParameters: queryParameters, body: body, expectedStatusCode: 201);
  Future<dynamic> put(String path, {Map<String, String>? queryParameters, required Map<String, dynamic> body}) => send('PUT', path, queryParameters: queryParameters, body: body, expectedStatusCode: 200);
  Future<dynamic> delete(String path, {Map<String, String>? queryParameters}) => send('DELETE', path, queryParameters: queryParameters, expectedStatusCode: 200);


  Future<dynamic> send(String method, String path, {Map<String, String>? queryParameters, Map<String, dynamic>? body, required int expectedStatusCode}) async {
    final uri = Uri.parse('${Config.baseUrl}$path').replace(queryParameters: queryParameters);
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
      default:
        throw Exception('Unsupported method: $method');
    }
    final text = utf8.decode(response.bodyBytes);
    debugPrint('-> ${response.statusCode} $text');
    if (response.statusCode != expectedStatusCode) {
      throw ApiException(response.statusCode, text);
    }
    return text.isEmpty ? null : jsonDecode(text);
  }
  Future<Map<String, String>> buildHeaders() async{
    final token = await tokenProvider?.call();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token'
    };
  }
}
