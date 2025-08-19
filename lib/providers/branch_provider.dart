import 'package:flutter/material.dart';
import 'package:innerspace_coworking/models/branchModel.dart';

import '../services/apiServices.dart';

class BranchProvider with ChangeNotifier {
  List<BranchModel> _branches = [];
  bool _isLoading = false;
  String _error = '';

  String _searchQuery = '';
  String? _selectedCity;
  double? _maxPrice;
  bool _showOnlyUnder200 = false;

  List<BranchModel> get branches => _branches;
  bool get isLoading => _isLoading;
  String get error => _error;

  String get searchQuery => _searchQuery;
  String? get selectedCity => _selectedCity;
  double? get maxPrice => _maxPrice;
  bool get showOnlyUnder200 => _showOnlyUnder200;

  List<String> get cities {
    final citySet = _branches.map((b) => b.city).toSet();
    return citySet.toList()..sort();
  }

  List<BranchModel> get filteredBranches {
    return _branches.where((branch) {
      final matchesQuery = _searchQuery.isEmpty ||
          branch.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          branch.city.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          branch.city.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCity = _selectedCity == null || branch.city == _selectedCity;
      final matchesPrice =
          _maxPrice == null || branch.pricePerHour <= _maxPrice!;
      final under200 = !_showOnlyUnder200 || branch.pricePerHour <= 200;

      return matchesQuery && matchesCity && matchesPrice && under200;
    }).toList()
      ..sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
  }

  Future<void> fetchBranches() async {
    _isLoading = true;
    notifyListeners();

    try {
      _branches = await ApiService().getBranches();
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectCity(String? city) {
    _selectedCity = city;
    notifyListeners();
  }

  void setMaxPrice(double? price) {
    _maxPrice = price;
    notifyListeners();
  }

  void toggleUnder200(bool value) {
    _showOnlyUnder200 = value;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCity = null;
    _maxPrice = null;
    _showOnlyUnder200 = false;
    notifyListeners();
  }
}
