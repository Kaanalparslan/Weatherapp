import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
import 'weather_service.dart';

class CitySelectionPage extends StatefulWidget {
  @override
  _CitySelectionPageState createState() => _CitySelectionPageState();
}

class _CitySelectionPageState extends State<CitySelectionPage> {
  final WeatherService _weatherService = WeatherService();

  // Şehir listesi (API'dan güncellenecek)
  List<Map<String, dynamic>> cities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCities();
  }

  // API'dan şehirlerin hava durumu bilgilerini çek
  Future<void> fetchCities() async {
    try {
      List<String> defaultCities = ['London', 'Washington', 'Sydney', 'Ontario'];
      List<Map<String, dynamic>> updatedCities = [];
      for (String city in defaultCities) {
        final weatherData = await _weatherService.fetchWeatherData(city);
        updatedCities.add({
          'name': weatherData['name'],
          'weather': weatherData['weather'][0]['main'],
          'temp': weatherData['main']['temp'].toStringAsFixed(0),
        });
      }
      setState(() {
        cities = updatedCities;
        isLoading = false;
      });
    } catch (e) {
      print('Hata: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Yeni şehir ekleme fonksiyonu
  Future<void> addCity(String cityName) async {
    try {
      final weatherData = await _weatherService.fetchWeatherData(cityName);
      setState(() {
        cities.add({
          'name': weatherData['name'],
          'weather': weatherData['weather'][0]['main'],
          'temp': weatherData['main']['temp'].toStringAsFixed(0),
        });
      });
    } catch (e) {
      print('Şehir eklenirken hata: $e');
    }
  }

  // Şehir ekleme için açılan pencere
  void openAddCityDialog() {
    final cityNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Yeni Şehir Ekle"),
          content: TextField(
            controller: cityNameController,
            decoration: InputDecoration(labelText: "Şehir Adı"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("İptal"),
            ),
            TextButton(
              onPressed: () async {
                if (cityNameController.text.isNotEmpty) {
                  await addCity(cityNameController.text);
                  Navigator.pop(context);
                }
              },
              child: Text("Ekle"),
            ),
          ],
        );
      },
    );
  }

  // Hava durumuna göre ikon döndüren fonksiyon
  Widget getWeatherIcon(String weather) {
    switch (weather) {
      case 'Clear':
        return Icon(WeatherIcons.day_sunny, color: Colors.amber, size: 28);
      case 'Clouds':
        return Icon(WeatherIcons.cloud, color: Colors.grey, size: 28);
      case 'Rain':
        return Icon(WeatherIcons.rain, color: Colors.blue, size: 28);
      case 'Snow':
        return Icon(WeatherIcons.snow, color: Colors.lightBlue, size: 28);
      case 'Mist':
      case 'Fog':
        return Icon(WeatherIcons.fog, color: Colors.grey, size: 28);
      case 'Thunderstorm':
        return Icon(WeatherIcons.thunderstorm, color: Colors.deepPurple, size: 28);
      case 'Drizzle':
        return Icon(WeatherIcons.sprinkle, color: Colors.blueAccent, size: 28);
      default:
        return Icon(WeatherIcons.cloud, color: Colors.grey, size: 28);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // Arka plan rengi
          Container(
            color: Colors.lightBlue.shade100,
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Locations",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Şehir listesi
                Expanded(
                  child: ListView.builder(
                    itemCount: cities.length,
                    itemBuilder: (context, index) {
                      final city = cities[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: getWeatherIcon(city['weather']), // Dinamik ikon
                          title: Text(
                            city['name'],
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(city['weather']),
                          trailing: Text(
                            "${city['temp']}°",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            // Şehir seçildiğinde ana sayfaya geri dön
                            Navigator.pop(context, city['name']);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddCityDialog,
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add),
      ),
    );
  }
}
