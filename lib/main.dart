import 'package:flutter/material.dart';
import 'weather_service.dart';

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherHome(),
    );
  }
}

class WeatherHome extends StatefulWidget {
  @override
  _WeatherHomeState createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? weatherData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    try {
      final data = await _weatherService.fetchWeatherData('Paris'); // Şehri burada değiştirebilirsin.
      setState(() {
        weatherData = data;
        isLoading = false;
      });
    } catch (e) {
      print('Hata: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : weatherData != null
          ? Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'), // Arka plan resmi
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  weatherData!['weather'][0]['main'], // Örn: Clouds
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  weatherData!['name'], // Şehir adı
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '${weatherData!['main']['temp'].toStringAsFixed(0)}°', // Sıcaklık
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'CELSIUS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Icon(Icons.water_drop, color: Colors.white),
                        Text(
                          '${weatherData!['main']['humidity']}%',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Humidity',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Icon(Icons.wind_power, color: Colors.white),
                        Text(
                          '${weatherData!['wind']['speed']} m/s',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Wind',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Icon(Icons.speed, color: Colors.white),
                        Text(
                          '${weatherData!['main']['pressure']} hPa',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Pressure',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      )
          : Center(
        child: Text(
          'Hava durumu verisi alınamadı!',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
