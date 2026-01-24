import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../model/place_details.dart';
import '../../model/place_prediction.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GooglePlacesService {
  final String _apiKey = dotenv.env['API_KEY'] ?? '';
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/place';

  Future<List<PlacePrediction>> getAutocomplete(String input) async {
    if (input.isEmpty) return [];

    final url = Uri.parse(
      '$_baseUrl/autocomplete/json?input=$input&key=$_apiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final predictions = (data['predictions'] as List)
              .map((json) => PlacePrediction.fromJson(json))
              .toList();
          return predictions;
        } else if (data['status'] == 'ZERO_RESULTS') {
          return [];
        } else {
          throw Exception('API Error: ${data['status']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch predictions: $e');
    }
  }

  Future<PlaceDetails> getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      '$_baseUrl/details/json?place_id=$placeId&fields=place_id,name,formatted_address,geometry&key=$_apiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          return PlaceDetails.fromJson(data['result']);
        } else {
          throw Exception('API Error: ${data['status']}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch place details: $e');
    }
  }
}