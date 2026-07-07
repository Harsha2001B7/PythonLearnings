import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingState {
  final String pickup;
  final String dropoff;
  final String pickupDate;
  final String returnDate;
  final String vehicleCategory;
  final String? selectedVehicleName;

  BookingState({
    required this.pickup,
    required this.dropoff,
    required this.pickupDate,
    required this.returnDate,
    required this.vehicleCategory,
    this.selectedVehicleName,
  });

  BookingState copyWith({
    String? pickup,
    String? dropoff,
    String? pickupDate,
    String? returnDate,
    String? vehicleCategory,
    String? selectedVehicleName,
    bool clearSelectedVehicle = false,
  }) {
    return BookingState(
      pickup: pickup ?? this.pickup,
      dropoff: dropoff ?? this.dropoff,
      pickupDate: pickupDate ?? this.pickupDate,
      returnDate: returnDate ?? this.returnDate,
      vehicleCategory: vehicleCategory ?? this.vehicleCategory,
      selectedVehicleName: clearSelectedVehicle ? null : (selectedVehicleName ?? this.selectedVehicleName),
    );
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier()
      : super(BookingState(
          pickup: 'Dubai — Downtown Hub',
          dropoff: '',
          pickupDate: DateTime.now().toIso8601String().split('T')[0],
          returnDate: DateTime.now().add(const Duration(days: 3)).toIso8601String().split('T')[0],
          vehicleCategory: 'Sport Coupe',
          selectedVehicleName: null,
        ));

  void setPickup(String val) => state = state.copyWith(pickup: val);
  void setDropoff(String val) => state = state.copyWith(dropoff: val);
  void setPickupDate(String val) => state = state.copyWith(pickupDate: val);
  void setReturnDate(String val) => state = state.copyWith(returnDate: val);
  void setVehicleCategory(String val) => state = state.copyWith(vehicleCategory: val);
  void setSelectedVehicle(String? name) {
    if (name == null) {
      state = state.copyWith(clearSelectedVehicle: true);
    } else {
      state = state.copyWith(selectedVehicleName: name);
    }
  }
}

final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  return BookingNotifier();
});
