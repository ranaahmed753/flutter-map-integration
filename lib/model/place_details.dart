class PlaceDetails {
  final String placeId;
  final String name;
  final String formattedAddress;
  final double? lat;
  final double? lng;

  PlaceDetails({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    this.lat,
    this.lng,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final location = json['geometry']?['location'];
    return PlaceDetails(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? '',
      formattedAddress: json['formatted_address'] ?? '',
      lat: location?['lat']?.toDouble(),
      lng: location?['lng']?.toDouble(),
    );
  }
}
