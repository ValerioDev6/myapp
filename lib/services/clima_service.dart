import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String _baseUrl = 'https://www.meteosource.com/api/v1/free/point';
  final String _apiKey = 'kpk5ayfwjgcr1xde92odk8ly4rik0lk6vjv2hneh';
  final String _location = 'Lima';

  Future<Map<String, dynamic>?> fetchWeather() async {
    final url =
        '$_baseUrl?place_id=$_location&sections=all&timezone=UTC&language=en&units=metric&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
