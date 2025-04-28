


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class HttpClient {
  static String _baseUrl = Config.baseUrl;

  static Future<http.Response> get(String endpoint, {Map<String, String>? queryParams}) async {
    final token = await getToken();
    final headers = _createHeaders(token);
  //   final url = Uri.http(_baseUrl.replaceFirst('http://', ''), endpoint, queryParams);
  //   return http.get(url, headers: headers);
  // }
    Uri url;
  if (_baseUrl.startsWith('https://')) {
    url = Uri.https(_baseUrl.replaceFirst('https://', ''), endpoint, queryParams);
  } else {
    url = Uri.http(_baseUrl.replaceFirst('http://', ''), endpoint, queryParams);
  }
  
  return http.get(url, headers: headers);
}

  static Future<http.Response> post(String endpoint, {Map<String, String>? queryParams, Map<String, dynamic>? body}) async {
    final token = await getToken();
    final headers = _createHeaders(token);
  //   final url = Uri.http(_baseUrl.replaceFirst('http://', ''), endpoint, queryParams);
  //   return http.post(url, headers: headers, body: body != null ? jsonEncode(body) : null);
  // }
    // With this code:
  Uri url;
  if (_baseUrl.startsWith('https://')) {
    url = Uri.https(_baseUrl.replaceFirst('https://', ''), endpoint, queryParams);
  } else {
    url = Uri.http(_baseUrl.replaceFirst('http://', ''), endpoint, queryParams);
  }
  
  return http.post(url, headers: headers, body: body != null ? jsonEncode(body) : null);
}

  static Future<http.Response> put(String endpoint, {Map<String, String>? queryParams, Map<String, dynamic>? body}) async {
  final token = await getToken();
  final headers = _createHeaders(token);
//   final url = Uri.http(_baseUrl.replaceFirst('http://', ''), endpoint, queryParams);
//   return http.put(url, headers: headers, body: body != null ? jsonEncode(body) : null);
// }
  // With this code:
  Uri url;
  if (_baseUrl.startsWith('https://')) {
    url = Uri.https(_baseUrl.replaceFirst('https://', ''), endpoint, queryParams);
  } else {
    url = Uri.http(_baseUrl.replaceFirst('http://', ''), endpoint, queryParams);
  }
  
  return http.put(url, headers: headers, body: body != null ? jsonEncode(body) : null);
}

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  static Future<void> storeRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', role);
  }

  static Future<void> storeEmployeeId(String employeeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('employee_id', employeeId);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  
  static Future<String?> getEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    // return prefs.getString('employee_id');
    final employeeId = prefs.getString('employee_id');
    print('Retrieved Employee ID: $employeeId'); // Debug print
    return employeeId;
  }


  

  static Map<String, String> _createHeaders(String? token) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }


  // Add this new method to your HttpClient class:
static Future<http.Response> getWithQueryParams(String path, Map<String, String> queryParams) async {
  // Create a Uri properly with separate query parameters
  final uri = Uri.parse('$_baseUrl/$path');
  
  // Create a new Uri with the same path but with query parameters
  final requestUri = uri.replace(queryParameters: queryParams);
  
  print('Making API request to: ${requestUri.toString()}');
  
  try {
    final response = await http.get(
      requestUri,
      headers: await _createHeaders(await getToken()),
    );
    return response;
  } catch (e) {
    print('HTTP Client Error: $e');
    throw Exception('Failed to make GET request: $e');
  }
}


}