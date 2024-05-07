import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/models/weather_model.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String baseUrl = "http://api.openweathermap.org/data/2.5/weather";
  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> getWeather(String cityName) async {
    // Use Uri builder to correctly encode query parameters
    final Uri uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        'q': cityName,
        'appid': apiKey,
        'units': 'metric',
        'lang': 'sl',
      },
    );

    // Fetch the weather data
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data: ${response.statusCode} ${response.body}');
    }
  }

  Future<String> getCurrentCity() async {
    // Check and request location permission if not already granted
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are denied');
      }
    }

    // Obtain the current position with high accuracy
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Retrieve the locality from the geolocation coordinates
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude, position.longitude
    );

    // Extract the city or administrative area as fallback
    String? city = placemarks[0].locality;
    if(city == "") {
      city = placemarks[0].administrativeArea;
    }
    // city ??= placemarks[0].administrativeArea;
    print(placemarks[0].administrativeArea);

    return city ?? "";
  }
}
