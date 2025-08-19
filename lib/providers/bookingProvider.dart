import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/bookingModel.dart';

class BookingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  final List<BookingModel> _bookings = [];
  bool get isLoading => _isLoading;
  List<BookingModel> get bookings => _bookings;
  Future<void> createBooking(BookingModel booking) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (booking.username.isEmpty || booking.phoneNumber.isEmpty) {
        throw Exception('Username and phone number are required');
      }

      await _firestore.collection('bookings').add(booking.toMap());

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  List<BookingModel> getByStatus(BookingStatus status) {
    return _bookings.where((b) => b.status == status).toList();
  }

  /// ✅ Get bookings of current user
  Stream<List<BookingModel>> getUserBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> fetchBookings(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId) // filter by logged in user
          .get();

      _bookings
        ..clear()
        ..addAll(snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id)));
    } catch (e) {
      debugPrint("Error fetching bookings: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
