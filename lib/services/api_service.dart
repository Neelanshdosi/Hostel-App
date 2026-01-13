import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Change this to your Flask server IP address
  static const String baseUrl = 'https://zephyrus.tailff12b3.ts.net/api'; // For Android Emulator
  // Use 'http://YOUR_COMPUTER_IP:5000/api' for physical device

  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  static Future<Map<String, dynamic>> register(
      String username, String password, String name, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'name': name,
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  static Future<void> postLostFound(int userId, String caption, File image) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/lost-found'));
      
      request.fields['user_id'] = userId.toString();
      request.fields['caption'] = caption;
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      var response = await request.send();
      
      if (response.statusCode != 201) {
        throw Exception('Failed to post');
      }
    } catch (e) {
      throw Exception('Error posting: $e');
    }
  }

  static Future<List<dynamic>> getLostFound() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/lost-found'));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load lost and found items');
      }
    } catch (e) {
      throw Exception('Error loading: $e');
    }
  }

  static Future<void> postComplaint(int userId, String caption, File image) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/complaints'));
      
      request.fields['user_id'] = userId.toString();
      request.fields['caption'] = caption;
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      var response = await request.send();
      
      if (response.statusCode != 201) {
        throw Exception('Failed to submit complaint');
      }
    } catch (e) {
      throw Exception('Error submitting complaint: $e');
    }
  }

  static Future<List<dynamic>> getComplaints() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/complaints'));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load complaints');
      }
    } catch (e) {
      throw Exception('Error loading complaints: $e');
    }
  }

  static Future<void> updateMenu(File image, String todayUpdate) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/menu'));
      
      request.fields['today_update'] = todayUpdate;
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      var response = await request.send();
      
      if (response.statusCode != 201) {
        throw Exception('Failed to update menu');
      }
    } catch (e) {
      throw Exception('Error updating menu: $e');
    }
  }

  static Future<Map<String, dynamic>?> getMenu() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/menu'));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load menu');
      }
    } catch (e) {
      throw Exception('Error loading menu: $e');
    }
  }

  static Future<void> updateMenuText(String todayUpdate) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/menu/update-text'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'today_update': todayUpdate}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update text');
      }
    } catch (e) {
      throw Exception('Error updating: $e');
    }
  }
}