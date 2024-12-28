import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
import 'city_selection.dart';
import 'weather_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String currentCity = "Kayseri"; // Varsayılan şehir
  Map<String, dynamic>? weatherData;
  List<dynamic>? forecastData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLastSelectedCity(); // En son seçilen şehri yükle
  }

  // En son seçilen şehri SharedPreferences'tan yükle
  Future<void> loadLastSelectedCity() async {
    setState(() {
      isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCity = prefs.getString('lastSelectedCity') ?? "Kayseri"; // Varsayılan şehir
      currentCity = savedCity;
      await fetchWeather(currentCity); // Varsayılan şehrin hava durumu bilgilerini çek
    } catch (e) {
      print("Hata: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // En son seçilen şehri SharedPreferences'a kaydet
  Future<void> saveLastSelectedCity(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastSelectedCity', cityName);
  }

  // Hava durumu verisini API'dan çek
  Future<void> fetchWeather(String city) async {
    setState(() {
      isLoading = true;
    });
    try {
      final currentWeather = await _weatherService.fetchWeatherData(city);
      final fiveDayForecast = await _weatherService.fetchFiveDayForecast(city);
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

  // Şehir seçim ekranına git
  Future<void> openCitySelectionPage() async {
    final selectedCity = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CitySelectionPage()),
    );

    if (selectedCity != null && selectedCity != currentCity) {
      setState(() {
        currentCity = selectedCity;
      });
      await saveLastSelectedCity(selectedCity); // Yeni şehri kaydet
      fetchWeather(selectedCity); // Yeni şehrin hava durumu verisini çek
    }
  }

  Widget getWeatherIcon(String weather) {
    switch (weather) {
      case 'Clear':
        return Icon(WeatherIcons.day_sunny, size: 24, color: Colors.white);
      case 'Clouds':
        return Icon(WeatherIcons.cloud, size: 28, color: Colors.white);
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
        return Icon(WeatherIcons.sprinkle, size: 28, color: Colors.white);
      default:
        return Icon(WeatherIcons.cloud, size: 28, color: Colors.white);
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
                // Custom Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.menu, color: Colors.white, size: 28),
                        onPressed: openCitySelectionPage, // Şehir seçim ekranına git
                      ),
                    ],
                  ),
                ),
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
                  flex: 2,
                  child: Container(
                    margin: EdgeInsets.only(top: 80),
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        final forecast = forecastData![index * 8];
                        final date = DateTime.parse(forecast['dt_txt']);
                        final temp = forecast['main']['temp'].toStringAsFixed(0);
                        final weather = forecast['weather'][0]['main'];
                        return Container(
                          width: 80,
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
