import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../model/place_details.dart';
import '../../model/place_prediction.dart';
import '../services/google_places_service.dart';

class SearchPlacesProvider extends ChangeNotifier {
  final GooglePlacesService _placesService = GooglePlacesService();

  List<PlacePrediction> _predictions = [];
  bool _isLoading = false;
  PlaceDetails? _selectedPlace;
  String? _errorMessage;

  List<PlacePrediction> get predictions => _predictions;
  bool get isLoading => _isLoading;
  PlaceDetails? get selectedPlace => _selectedPlace;
  String? get errorMessage => _errorMessage;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  TextEditingController get controller => _controller;
  FocusNode get focusNode => _focusNode;

  Future<void> searchPlaces(String query) async {
    if (query.isEmpty) {
      _predictions = [];
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _predictions = await _placesService.getAutocomplete(query);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      _predictions = [];
      notifyListeners();
    }
  }

  Future<void> selectPlace(PlacePrediction prediction) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedPlace = await _placesService.getPlaceDetails(prediction.placeId);
      _predictions = [];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearSelection() {
    _selectedPlace = null;
    _predictions = [];
    _errorMessage = null;
    _controller.dispose();
    notifyListeners();
  }

  @override
  void dispose() {
    clearSelection();
    super.dispose();
  }
}