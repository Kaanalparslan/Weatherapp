import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = '5c0660340a16c1d3397ab05aa4c91b70'; // API Key'inizi buraya ekleyin.
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<Map<String, dynamic>> fetchWeatherData(String city) async {
    final response = await http.get(
      Uri.parse('$baseUrl/weather?q=$city&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Hava durumu verisi alınamadı');
    }
  }

  Future<List<dynamic>> fetchFiveDayForecast(String city) async {
    final response = await http.get(
      Uri.parse('$baseUrl/forecast?q=$city&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['list'];
    } else {
      throw Exception('5 günlük hava durumu verisi alınamadı');
    }
  }
}
