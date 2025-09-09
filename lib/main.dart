import 'package:flutter/material.dart';

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
  // Platzhalter für die Wetterdaten. Später wird hier der Wert von der API gespeichert.
  String _weatherData = "Keine Daten geladen.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wetter-App für Jena')),
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
              onPressed: () {
                // TODO: Hier wird später die API-Anfrage eingebaut
                print("Button wurde gedrückt!");
              },
              child: const Text('Wetter laden'),
            ),
          ],
        ),
      ),
    );
  }
}
