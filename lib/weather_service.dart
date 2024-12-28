import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = '5c0660340a16c1d3397ab05aa4c91b70'; // Buraya OpenWeatherMap API Key'ini yaz.
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>> fetchWeatherData(String city) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?q=$city&appid=$apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Hava durumu verileri alınamadı!');
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
