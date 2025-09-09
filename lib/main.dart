import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Future<void> _fetchWeather() async {
    const latitude = 50.92;
    const longitude = 11.58;
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true',
    );

    try {
      // Warten auf die Antwort der API
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Parsen JSON
        final jsonData = jsonDecode(response.body);
        final temperature = jsonData['current_weather']['temperature'];

        // Aktualisieren Temperatur
        setState(() {
          _weatherData = '$temperature °C';
        });
      } else {
        // Bei Fehlern
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
      appBar: AppBar(title: const Text('Wetter in Jena')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Aktuelle Temperatur:', style: TextStyle(fontSize: 24)),
            Text(
              _weatherData,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchWeather,
              child: const Text('Wetter laden'),
            ),
          ],
        ),
      ),
    );
  }
}
