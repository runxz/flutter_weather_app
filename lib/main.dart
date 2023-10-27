import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  String _location = '';
  String _temperature = '';
  String _description = '';
  String _weatherCondition = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    var status = await Permission.location.status;

    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _getWeather(position.latitude, position.longitude);
    } else {
      if (status.isDenied) {
        await Permission.location.request();
      }

      if (await Permission.location.isDenied) {
        print('Location permission is denied by the user.');
        // Handle cases where the user denies location permission
        // You can show a message or take appropriate action to inform the user.
      }
    }
  }

  Future<void> _getWeather(double latitude, double longitude) async {
    String apiKey = 'a701ea8c281fda52ac58992321cb0f66';
    String apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey';

    try {
      print('Fetching weather data from API...');
      http.Response response = await http.get(Uri.parse(apiUrl));
      print('API response status code: ${response.statusCode}');
      Map<String, dynamic> weatherData = jsonDecode(response.body);

      String location = weatherData['name'];
      double temperature = weatherData['main']['temp'];
      String description = weatherData['weather'][0]['description'];
      String weatherCondition = weatherData['weather'][0]['main'];

      print('Location: $location');
      print('Temperature: $temperature');
      print('Description: $description');
      print('Weather Condition: $weatherCondition');

      setState(() {
        _location = location;
        _temperature = (temperature - 273.15).toStringAsFixed(1);
        _description = description;
        _weatherCondition = weatherCondition;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching weather data: $e');
      // Handle error cases
      // You can show an error message or take appropriate action.
    }
  }

  Widget _getLottieAnimation() {
    switch (_weatherCondition) {
      case 'Clouds':
      case 'fog':
        return Lottie.asset('assets/cloudy.json');
      case 'Rain':
      case 'Drizzle':
        return Lottie.asset('assets/rain.json');
      case 'Clear':
        return Lottie.asset('assets/sunny.json');
      case 'Thunderstorm':
        return Lottie.asset('assets/thunderstorm.json');
      default:
        return Container();
    }
  }

  Widget _buildWeatherInfo() {
    if (_isLoading) {
      return CircularProgressIndicator();
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _getLottieAnimation(),
          SizedBox(height: 20),
          Text(
            'Location: $_location',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white.withOpacity(0.8)),
          ),
          SizedBox(height: 20),
          Text(
            'Temperature: $_temperature°C',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white.withOpacity(0.6)),
          ),
          SizedBox(height: 20),
          Text(
            'Description: $_description',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white.withOpacity(0.6)),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isDaytime = now.hour >= 6 && now.hour < 18;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Opacity(
                opacity: 0.6,
                child: Lottie.asset(
                  isDaytime ? 'assets/day.json' : 'assets/night.json',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Center(
              child: _buildWeatherInfo(),
            ),
          ],
        ),
      ),
    );
  }
}
