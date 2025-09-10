import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wetter-App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  String _weatherData = "Keine Daten geladen.";
  String _selectedLocation = "Jena";
  late SharedPreferences _prefs;

  // Eine Map, die Städtenamen ihren Koordinaten zuordnet
  final Map<String, List<double>> _locations = {
    "Jena": [50.92, 11.58],
    "Berlin": [52.52, 13.41],
    "München": [48.14, 11.58],
    "Hamburg": [53.55, 9.99],
    "Paris": [48.86, 2.35],
  };

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadWeather();
  }

  void _loadWeather() {
    final lastTemperature = _prefs.getDouble('last_temperature');
    final lastLocation =
        _prefs.getString('last_location') ??
        "Jena"; // Standardwert, falls nichts gespeichert ist

    setState(() {
      _selectedLocation = lastLocation;
    });

    if (lastTemperature != null) {
      setState(() {
        _weatherData = '$lastTemperature °C';
      });
    } else {
      setState(() {
        _weatherData = 'Kein gespeicherter Wert gefunden.';
      });
    }
  }

  Future<void> _saveWeather(double temperature, String location) async {
    await _prefs.setDouble('last_temperature', temperature);
    await _prefs.setString('last_location', location);
  }

  Future<void> _clearWeatherHistory() async {
    await _prefs.clear();
    setState(() {
      _weatherData = 'Historie gelöscht!';
    });
  }

  Future<void> _fetchWeather() async {
    final locationCoords = _locations[_selectedLocation]!;
    final latitude = locationCoords[0];
    final longitude = locationCoords[1];
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final temperature = jsonData['current_weather']['temperature'];

        setState(() {
          _weatherData = '$temperature °C';
        });
        await _saveWeather(temperature, _selectedLocation);
      } else {
        setState(() {
          _weatherData = 'Fehler beim Laden der Daten.';
        });
      }
    } catch (e) {
      setState(() {
        _weatherData = 'Netzwerkfehler: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wetter-App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Wähle einen Ort:', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              dropdownColor: Colors.white,
              value: _selectedLocation,
              icon: const Icon(Icons.arrow_downward),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLocation = newValue!;
                  _fetchWeather();
                });
              },
              items: _locations.keys.map<DropdownMenuItem<String>>((
                String value,
              ) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'Aktuelle Temperatur in $_selectedLocation:',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              _weatherData,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchWeather,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Wetter laden'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _clearWeatherHistory,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Historie löschen'),
            ),
          ],
        ),
      ),
    );
  }
}
