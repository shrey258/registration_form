import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/form_data.dart';

class ApiService {
  static const String baseUrl = 'https://iotreeminds.com';
  static const String apiKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NmYzZTZjYmRhMTE5ZDAyMTUwYTBlOGMiLCJfcGhvbmVOdW1iZXIiOiI5OTIxMTI5MDI1IiwidXNlclR5cGVJZCI6IjY2ZWQxNzE5Y2EwNGY4MWRjMjM3NTg5NyIsInVzZXJUeXBlIjoibWF0Y2htYWtlciIsImlhdCI6MTcyNzMzMzQwMywiZXhwIjoxNzI3MzU1MDAzfQ.8t33_eVi9hH_-lmKK0i94ISn6NtUvbLf1a8cYHH_AwI';

  Future<bool> submitForm(FormData formData) async {
    try {
      final requestBody = formData.toJson();
      
     
      if (!requestBody['resume'].toString().startsWith('data:application/')) {
        throw Exception('Invalid resume format');
      }

     
      if (requestBody['links'] == null || requestBody['links'].isEmpty) {
        requestBody['links'] = [''];
      }

      print('API Request URL: $baseUrl/form-submissions/hiring-formSubmission-create');
      print('API Request Headers:');
      print('Content-Type: application/json');
      print('X-API-Key: $apiKey');
      print('API Request Body:');
      requestBody.forEach((key, value) {
        if (key == 'resume') {
          print('resume: [Base64 data length: ${value.toString().length}]');
        } else {
          print('$key: $value');
        }
      });

      final response = await http.post(
        Uri.parse('$baseUrl/form-submissions/hiring-formSubmission-create'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': apiKey,
        },
        body: jsonEncode(requestBody),
      );

      print('API Response Status Code: ${response.statusCode}');
      
      if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        throw Exception('Bad Request: ${errorBody['message'] ?? 'Unknown error'}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Form submitted successfully');
        return true;
      } else {
        print('API Response Body: ${response.body}');
        throw Exception('Failed to submit form. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      throw Exception('Error submitting form: $e');
    }
  }
}
