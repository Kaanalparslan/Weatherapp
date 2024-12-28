import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
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
      final data = await _weatherService.fetchWeatherData('Kayseri'); // Şehir adı buradan değiştirilebilir.
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

  Widget getWeatherIcon(String weather) {
    switch (weather) {
      case 'Clear':
        return Icon(WeatherIcons.day_sunny, size: 64, color: Colors.white);
      case 'Clouds':
        return Icon(WeatherIcons.cloud, size: 64, color: Colors.white);
      case 'Rain':
        return Icon(WeatherIcons.rain, size: 64, color: Colors.white);
      case 'Snow':
        return Icon(WeatherIcons.snow, size: 64, color: Colors.white);
      case 'Mist':
      case 'Fog':
        return Icon(WeatherIcons.fog, size: 64, color: Colors.white);
      case 'Thunderstorm':
        return Icon(WeatherIcons.thunderstorm, size: 64, color: Colors.white);
      case 'Drizzle':
        return Icon(WeatherIcons.sprinkle, size: 64, color: Colors.white);
      default:
        return Icon(WeatherIcons.cloud, size: 64, color: Colors.white);
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
          // Arka plan resmi
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Siyah şeffaf katman
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // İçerik
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // İkon ve hava durumu açıklaması bir arada
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hava durumu ikonu
                    if (weatherData!['weather'] != null &&
                        weatherData!['weather'].isNotEmpty)
                      getWeatherIcon(weatherData!['weather'][0]['main']),
                    SizedBox(height: 10), // İkon ve metin arasında boşluk
                    // Hava durumu açıklaması (ör. Mist)
                    Text(
                      weatherData!['weather'][0]['main'], // Örn: Mist
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10), // Şehir adı ve sıcaklık arasında boşluk
                // Şehir adı
                Text(
                  weatherData!['name'], // Şehir adı
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 20),
                // Sıcaklık bilgisi
                Text(
                  '${weatherData!['main']['temp'].toStringAsFixed(0)}°',
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
                // Hava durumu detayları
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Nem bilgisi
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
                    // Rüzgar bilgisi
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
                    // Basınç bilgisi
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
