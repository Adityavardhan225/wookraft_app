// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'config.dart';

// class HttpClient {
//   // static const String _baseUrl = 'http://127.0.0.1:8000';
//   static const String _baseUrl = Config.baseUrl;

//   static Future<http.Response> get(String endpoint, {Map<String, String>? queryParams}) async {
//     final token = await getToken();
//     final headers = _createHeaders(token);
//     final url = Uri.http(_baseUrl.replaceFirst('http://', ''), endpoint, queryParams);
//     return http.get(url, headers: headers);
//   }

//   static Future<http.Response> post(String endpoint, {Map<String, String>? queryParams, Map<String, dynamic>? body}) async {
//     final token = await getToken();
//     final headers = _createHeaders(token);
//     final url = Uri.http(_baseUrl.replaceFirst('http://', ''), endpoint, queryParams);
//     return http.post(url, headers: headers, body: body != null ? jsonEncode(body) : null);
//   }

//   static Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('access_token');
//   }

//   static Map<String, String> _createHeaders(String? token) {
//     final headers = {'Content-Type': 'application/json'};
//     if (token != null) {
//       headers['Authorization'] = 'Bearer $token';
//     }
//     return headers;
//   }
// }




















import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class HttpClient {
  static const String _baseUrl = Config.baseUrl;

  static Future<http.Response> get(String endpoint, {Map<String, String>? queryParams}) async {
    final token = await getToken();
    final headers = _createHeaders(token);
    final url = Uri.http(_baseUrl.replaceFirst('http://', ''), endpoint, queryParams);
    return http.get(url, headers: headers);
  }

  static Future<http.Response> post(String endpoint, {Map<String, String>? queryParams, Map<String, dynamic>? body}) async {
    final token = await getToken();
    final headers = _createHeaders(token);
    final url = Uri.http(_baseUrl.replaceFirst('http://', ''), endpoint, queryParams);
    return http.post(url, headers: headers, body: body != null ? jsonEncode(body) : null);
  }

  static Future<http.Response> put(String endpoint, {Map<String, String>? queryParams, Map<String, dynamic>? body}) async {
  final token = await getToken();
  final headers = _createHeaders(token);
  final url = Uri.http(_baseUrl.replaceFirst('http://', ''), endpoint, queryParams);
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
}