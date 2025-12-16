/// Model for a place prediction from autocomplete
class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;
  final double? latitude;
  final double? longitude;

  const PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
    this.latitude,
    this.longitude,
  });

  /// Parse from Geoapify response
  factory PlacePrediction.fromGeoapify(Map<String, dynamic> json) {
    final lat = json['lat'] as num?;
    final lon = json['lon'] as num?;

    // Build main text from street/name
    String mainText =
        json['name'] ?? json['street'] ?? json['address_line1'] ?? '';

    // Build secondary text from city, state, country
    List<String> secondaryParts = [];
    if (json['city'] != null) secondaryParts.add(json['city']);
    if (json['state'] != null) secondaryParts.add(json['state']);
    if (json['country'] != null) secondaryParts.add(json['country']);
    String secondaryText = secondaryParts.join(', ');

    // Full formatted address
    String description = json['formatted'] ?? '$mainText, $secondaryText';

    // Use lat,lon as placeId since Geoapify gives us coordinates directly
    String placeId = (lat != null && lon != null) ? '$lat,$lon' : '';

    return PlacePrediction(
      placeId: placeId,
      description: description,
      mainText: mainText.isNotEmpty ? mainText : description.split(',').first,
      secondaryText: secondaryText,
      latitude: lat?.toDouble(),
      longitude: lon?.toDouble(),
    );
  }
}

/// Model for place details with coordinates
class PlaceDetails {
  final double latitude;
  final double longitude;
  final String formattedAddress;

  const PlaceDetails({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
  });
}
