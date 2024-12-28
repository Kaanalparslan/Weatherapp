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
  List<dynamic>? forecastData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    try {
      final currentWeather = await _weatherService.fetchWeatherData('Kayseri');
      final fiveDayForecast = await _weatherService.fetchFiveDayForecast('Kayseri');
      setState(() {
        weatherData = currentWeather;
        forecastData = fiveDayForecast;
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
        return Icon(WeatherIcons.day_sunny, size: 24, color: Colors.white);
      case 'Clouds':
        return Icon(WeatherIcons.cloud, size: 24, color: Colors.white);
      case 'Rain':
        return Icon(WeatherIcons.rain, size: 24, color: Colors.white);
      case 'Snow':
        return Icon(WeatherIcons.snow, size: 24, color: Colors.white);
      case 'Mist':
      case 'Fog':
        return Icon(WeatherIcons.fog, size: 24, color: Colors.white);
      case 'Thunderstorm':
        return Icon(WeatherIcons.thunderstorm, size: 24, color: Colors.white);
      case 'Drizzle':
        return Icon(WeatherIcons.sprinkle, size: 24, color: Colors.white);
      default:
        return Icon(WeatherIcons.cloud, size: 24, color: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : weatherData != null && forecastData != null
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
          SafeArea(
            child: Column(
              children: [
                // Üst kısım: Mevcut hava durumu
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      getWeatherIcon(weatherData!['weather'][0]['main']),
                      SizedBox(height: 10),
                      Text(
                        weatherData!['weather'][0]['main'], // Örn: Clouds
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        weatherData!['name'], // Şehir adı
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        '${weatherData!['main']['temp'].toStringAsFixed(0)}°',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'CELSIUS',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 20),
                      // Ek hava durumu detayları
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Icon(Icons.water_drop, color: Colors.white, size: 20),
                              Text(
                                '${weatherData!['main']['humidity']}%',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              Text(
                                'Humidity',
                                style: TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(Icons.wind_power, color: Colors.white, size: 20),
                              Text(
                                '${weatherData!['wind']['speed']} m/s',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              Text(
                                'Wind',
                                style: TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Icon(Icons.speed, color: Colors.white, size: 20),
                              Text(
                                '${weatherData!['main']['pressure']} hPa',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              Text(
                                'Pressure',
                                style: TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Alt kısım: 5 günlük tahmin
                Expanded(
                  flex: 2, // Alt kısım için ayrılan alan
                  child: Container(
                    margin: EdgeInsets.only(top: 80), // Kartları yukarıdaki yazılardan uzaklaştır
                    padding: EdgeInsets.symmetric(vertical: 6), // Genel padding
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5, // 5 günlük tahmin
                      itemBuilder: (context, index) {
                        final forecast = forecastData![index * 8];
                        final date = DateTime.parse(forecast['dt_txt']);
                        final temp = forecast['main']['temp'].toStringAsFixed(0);
                        final weather = forecast['weather'][0]['main'];
                        return Container(
                          width: 80, // Daha kompakt kutular
                          margin: EdgeInsets.symmetric(horizontal: 4.0),
                          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                '${date.day}/${date.month}', // Tarih
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                              getWeatherIcon(weather), // Hava durumu ikonu
                              Text(
                                '$temp°', // Sıcaklık
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
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
