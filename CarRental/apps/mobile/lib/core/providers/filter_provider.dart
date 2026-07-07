import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterState {
  final String category;
  final double maxPrice;
  final String transmission;
  final String fuel;
  final String seats;

  FilterState({
    required this.category,
    required this.maxPrice,
    required this.transmission,
    required this.fuel,
    required this.seats,
  });

  FilterState copyWith({
    String? category,
    double? maxPrice,
    String? transmission,
    String? fuel,
    String? seats,
  }) {
    return FilterState(
      category: category ?? this.category,
      maxPrice: maxPrice ?? this.maxPrice,
      transmission: transmission ?? this.transmission,
      fuel: fuel ?? this.fuel,
      seats: seats ?? this.seats,
    );
  }
}

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier()
      : super(FilterState(
          category: 'all',
          maxPrice: 2000.0,
          transmission: 'all',
          fuel: 'all',
          seats: 'all',
        ));

  void setCategory(String val) => state = state.copyWith(category: val);
  void setMaxPrice(double val) => state = state.copyWith(maxPrice: val);
  void setTransmission(String val) => state = state.copyWith(transmission: val);
  void setFuel(String val) => state = state.copyWith(fuel: val);
  void setSeats(String val) => state = state.copyWith(seats: val);
  void resetFilters() {
    state = FilterState(
      category: 'all',
      maxPrice: 2000.0,
      transmission: 'all',
      fuel: 'all',
      seats: 'all',
    );
  }
}

final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  return FilterNotifier();
});
