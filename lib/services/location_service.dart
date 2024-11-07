import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/location_model.dart';
import '../utils/constants_utils.dart';
import '../utils/network_utils.dart';

class LocationService {
  Future<LocationData> getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition();
    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  Future<String> sendLocationToServer(LocationData locationData) async {
    if (await NetworkUtils.hasInternetConnection()) {
      final url = Uri.parse(locationApiUrl);
      final body = json.encode(locationData.toJson());
      final response = await http.post(
        url,
        body: body,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return 'Location sent to server successfully';
      } else {
        throw Exception(
            'Error sending location to server: ${response.statusCode}');
      }
    } else {
      throw Exception('No internet connection');
    }
  }
}
