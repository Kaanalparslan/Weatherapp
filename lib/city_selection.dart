import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_icons/weather_icons.dart';
import 'weather_service.dart';
import 'dart:convert';

class CitySelectionPage extends StatefulWidget {
  @override
  _CitySelectionPageState createState() => _CitySelectionPageState();
}

class _CitySelectionPageState extends State<CitySelectionPage> {
  final WeatherService _weatherService = WeatherService();
  List<Map<String, dynamic>> cities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCities(); // Kaydedilen şehirleri yükle
  }

  // SharedPreferences'tan şehirleri yükle
  Future<void> loadCities() async {
    setState(() {
      isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCities = prefs.getStringList('cities') ?? [];
      if (savedCities.isNotEmpty) {
        cities = savedCities.map((city) => json.decode(city) as Map<String, dynamic>).toList();
      } else {
        // Varsayılan şehirler
        await fetchDefaultCities();
      }
    } catch (e) {
      print("Hata: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Varsayılan şehirleri API'dan çek
  Future<void> fetchDefaultCities() async {
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
    });
    saveCities(); // Varsayılan şehirleri kaydet
  }

  // SharedPreferences'a şehirleri kaydet
  Future<void> saveCities() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedCities = cities.map((city) => json.encode(city)).toList();
    await prefs.setStringList('cities', encodedCities);
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
      saveCities(); // Şehirleri kaydet
    } catch (e) {
      print('Şehir eklenirken hata: $e');
    }
  }

  // Şehir silme fonksiyonu
  void removeCity(int index) {
    setState(() {
      cities.removeAt(index);
    });
    saveCities(); // Güncellenen şehir listesini kaydet
  }

  // Şehir ekleme için açılan pencere
  void openAddCityDialog() {
    final cityNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add City"),
          content: TextField(
            controller: cityNameController,
            decoration: InputDecoration(labelText: "City Name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (cityNameController.text.isNotEmpty) {
                  await addCity(cityNameController.text);
                  Navigator.pop(context);
                }
              },
              child: Text("Enter"),
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
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${city['temp']}°",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => removeCity(index), // Şehri sil
                              ),
                            ],
                          ),
                          onTap: () {
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
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      ),
    );
  }
}
