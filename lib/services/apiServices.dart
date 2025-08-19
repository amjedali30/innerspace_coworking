import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:innerspace_coworking/models/branchModel.dart';

class ApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<BranchModel>> getBranches() async {
    try {
      final snapshot = await _firestore.collection('branch').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BranchModel(
          id: doc.id,
          name: data['name'] ?? '',
          city: data['city'] ?? '',
          pricePerHour: (data['pricePerHour'] ?? 0).toDouble(),
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          lat: (data['lat'] ?? 0.0).toDouble(),
          lng: (data['lng'] ?? 0.0).toDouble(),
          amenities: List<String>.from(data['amenities'] ?? []),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch branches: $e');
    }
  }
}
