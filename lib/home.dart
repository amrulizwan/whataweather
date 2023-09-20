import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Position? currentPosition;
  String apiKey =
      '576f9b22ce6aeeafcb4bcd84ae2ee30e'; // Replace with your OpenWeatherMap API key
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        currentPosition = position;
      });
      getWeather(currentPosition!.latitude, currentPosition!.longitude, apiKey)
          .then((weatherData) {
        setState(() {
          weatherDatas = weatherData;
        });
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<Map<String, dynamic>> getWeather(
      double lat, double lon, String apiKey) async {
    const String apiUrl = 'https://api.openweathermap.org/data/2.5/weather';
    final String url = '$apiUrl?lat=$lat&lon=$lon&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> weatherData = json.decode(response.body);
        return weatherData;
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  Map<String, dynamic> weatherDatas = {};

  @override
  void initState() {
    _getCurrentPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('What a Weather'),
      ),
      body: Column(children: [
        Text('$weatherDatas'),
        Text('Current Weather : ${weatherDatas['weather'][0]['main']}'),
        Text('Current Weather : ${weatherDatas['weather'][0]['description']}'),
      ]),
    );
  }
}
