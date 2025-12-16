import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:homify/core/models/place_models.dart';

/// Service for interacting with Geoapify Geocoding API
class PlacesService {
  static const String _apiKey = '54f9ee89f12d4d91a2625990f07e295b';
  static const String _baseUrl = 'https://api.geoapify.com/v1/geocode';

  /// Get autocomplete predictions for a search query
  /// Filtered to Philippines for better local results
  static Future<List<PlacePrediction>> getAutocompletePredictions(
    String query, {
    String? sessionToken,
  }) async {
    if (query.isEmpty || query.length < 2) return [];

    final uri = Uri.parse('$_baseUrl/autocomplete').replace(
      queryParameters: {
        'text': query,
        'apiKey': _apiKey,
        'filter': 'countrycode:ph',
        'format': 'json',
        'limit': '5',
      },
    );

    try {
      debugPrint(
        'Geoapify Request: ${uri.toString().replaceAll(_apiKey, 'API_KEY')}',
      );
      final response = await http.get(uri);
      debugPrint('Geoapify Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List? ?? [];
        debugPrint('Geoapify Found ${results.length} results');

        return results.map((r) => PlacePrediction.fromGeoapify(r)).toList();
      } else {
        debugPrint('Geoapify Error: ${response.body}');
      }
    } catch (e) {
      debugPrint('Geoapify Exception: $e');
    }
    return [];
  }

  /// Get place details (coordinates) from a place ID
  /// For Geoapify, we already have coordinates in autocomplete results
  static Future<PlaceDetails?> getPlaceDetails(
    String placeId, {
    String? sessionToken,
  }) async {
    try {
      final parts = placeId.split(',');
      if (parts.length == 2) {
        return PlaceDetails(
          latitude: double.parse(parts[0]),
          longitude: double.parse(parts[1]),
          formattedAddress: '',
        );
      }
    } catch (e) {
      debugPrint('PlaceDetails parse error: $e');
    }
    return null;
  }

  /// Get route polyline between two points using Geoapify Routing API
  /// Returns list of coordinates for the route
  static Future<List<RouteCoordinate>> getRoute({
    required double originLat,
    required double originLon,
    required double destLat,
    required double destLon,
    String mode = 'drive', // drive, walk, bicycle
  }) async {
    final uri = Uri.parse('https://api.geoapify.com/v1/routing').replace(
      queryParameters: {
        'waypoints': '$originLat,$originLon|$destLat,$destLon',
        'mode': mode,
        'apiKey': _apiKey,
      },
    );

    try {
      debugPrint('Geoapify Routing Request');
      final response = await http.get(uri);
      debugPrint('Geoapify Routing Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List? ?? [];

        if (features.isNotEmpty) {
          final geometry = features[0]['geometry'];
          final coordinates = geometry['coordinates'] as List? ?? [];

          // Flatten all line segments into a single list
          final List<RouteCoordinate> routePoints = [];
          for (final segment in coordinates) {
            if (segment is List) {
              for (final point in segment) {
                if (point is List && point.length >= 2) {
                  routePoints.add(
                    RouteCoordinate(
                      latitude: (point[1] as num)
                          .toDouble(), // GeoJSON is [lon, lat]
                      longitude: (point[0] as num).toDouble(),
                    ),
                  );
                }
              }
            }
          }

          debugPrint('Geoapify Route found ${routePoints.length} points');
          return routePoints;
        }
      } else {
        debugPrint('Geoapify Routing Error: ${response.body}');
      }
    } catch (e) {
      debugPrint('Geoapify Routing Exception: $e');
    }
    return [];
  }
}

/// Route coordinate model
class RouteCoordinate {
  final double latitude;
  final double longitude;

  const RouteCoordinate({required this.latitude, required this.longitude});
}
