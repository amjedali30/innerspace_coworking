class BranchModel {
  final String id;
  final String name;
  final String city;
  final double pricePerHour;
  final String description;
  final String imageUrl;
  final double lat;
  final double lng;
  final List<String> amenities;

  BranchModel({
    required this.id,
    required this.name,
    required this.city,
    required this.pricePerHour,
    required this.description,
    required this.imageUrl,
    required this.lat,
    required this.lng,
    required this.amenities,
  });

  factory BranchModel.fromMap(Map<String, dynamic> data, String docId) {
    return BranchModel(
      id: docId,
      name: data['name'] ?? '',
      city: data['city'] ?? '',
      pricePerHour: (data['pricePerHour'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      lat: (data['lat'] ?? 0).toDouble(),
      lng: (data['lng'] ?? 0).toDouble(),
      amenities: List<String>.from(data['amenities'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "city": city,
      "pricePerHour": pricePerHour,
      "description": description,
      "imageUrl": imageUrl,
      "lat": lat,
      "lng": lng,
      "amenities": amenities,
    };
  }
}
