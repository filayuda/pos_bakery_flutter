import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl;

  ApiService(
      {this.baseUrl = 'https://pos-ajj-dev-42c2338ddb4c.herokuapp.com/api/'});

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    return await _sendRequest(
        'POST', Uri.parse('$baseUrl$endpoint'), headers, body);
  }

  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
    int perPage = 1000,
    int page = 1,
  }) async {
    final Uri url = Uri.parse('$baseUrl$endpoint').replace(
      queryParameters: {
        'per_page': perPage.toString(),
        'page': page.toString(),
      },
    );

    return await _sendRequest('GET', url, headers);
  }

  Future<http.Response> put(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    return await _sendRequest(
        'PUT', Uri.parse('$baseUrl$endpoint'), headers, body);
  }

  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    return await _sendRequest(
        'DELETE', Uri.parse('$baseUrl$endpoint'), headers);
  }

  Future<http.Response> _sendRequest(
    String method,
    Uri url,
    Map<String, String>? headers, [
    Map<String, dynamic>? body,
  ]) async {
    String? token = await _getToken();
    final defaultHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    try {
      http.Response response;

      switch (method) {
        case 'POST':
          response = await http.post(url,
              headers: defaultHeaders,
              body: body != null ? jsonEncode(body) : null);
          break;
        case 'GET':
          response = await http.get(url, headers: defaultHeaders);
          break;
        case 'PUT':
          response = await http.put(url,
              headers: defaultHeaders,
              body: body != null ? jsonEncode(body) : null);
          break;
        case 'DELETE':
          response = await http.delete(url, headers: defaultHeaders);
          break;
        default:
          throw Exception('HTTP method not supported');
      }

      return response;
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<http.StreamedResponse> uploadMultipart(
    String endpoint, {
    required Map<String, String> fields,
    File? imageFile,
  }) async {
    String? token = await _getToken();
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    // Tambahkan data formulir
    fields.forEach((key, value) {
      request.fields[key] = value;
    });

    // Jika ada gambar, tambahkan ke request
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('thumbnail', imageFile.path),
      );
    }

    return await request.send();
  }
}
