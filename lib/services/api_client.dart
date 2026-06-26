import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status Code: $statusCode)';
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // For Android Emulator, localhost maps to 10.0.2.2.
  // For Web or iOS simulator, it is localhost/127.0.0.1.
  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    // Check platform
    try {
      if (Platform.isAndroid) {
        // [USB PHYSICAL DEVICE DEBUGGING (Recommended)]
        // Run: `adb reverse tcp:5000 tcp:5000` on your PC, then use:
        return 'http://localhost:5000/api';

        // [WI-FI PHYSICAL DEVICE DEBUGGING]
        // If you are on the same Wi-Fi network as your PC, use your PC's local IP (e.g. 192.168.0.129):
        // return 'http://192.168.0.129:5000/api';

        // [EMULATOR DEBUGGING]
        // If using Android Emulator, use 10.0.2.2 (which maps to host's localhost):
        // return 'http://10.0.2.2:5000/api';
      }
    } catch (_) {}
    return 'http://localhost:5000/api';
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      return _processResponse(response);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      return _processResponse(response);
    } catch (e) {
      _handleError(e);
    }
  }

  dynamic _processResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      final errorMessage = body['error'] ?? 'Something went wrong';
      throw ApiException(errorMessage, response.statusCode);
    }
  }

  void _handleError(dynamic error) {
    if (error is ApiException) {
      throw error;
    } else if (error is SocketException) {
      throw ApiException('No Internet connection or server is offline', 503);
    } else {
      throw ApiException(error.toString(), 500);
    }
  }
}
