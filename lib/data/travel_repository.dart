import '../models/travel_models.dart';

abstract class TravelRepository {
  Future<List<String>> fetchCities();
  Future<List<Place>> fetchPlacesForCity(String city);
}
