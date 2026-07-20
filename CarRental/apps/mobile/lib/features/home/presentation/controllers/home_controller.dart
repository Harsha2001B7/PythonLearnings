import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/home_models.dart';
import '../../data/repositories/home_repository.dart';

// ─── State ───────────────────────────────────────────────────────────────────
sealed class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded({required this.data, this.offers = const []});
  final HomeData data;
  final List<OfferModel> offers;
}

class HomeError extends HomeState {
  const HomeError(this.message);
  final String message;
}

// ─── Controller ───────────────────────────────────────────────────────────────
final homeControllerProvider =
    StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController(ref.read(homeRepositoryProvider));
});

class HomeController extends StateNotifier<HomeState> {
  HomeController(this._repo) : super(const HomeInitial()) {
    fetch();
  }

  final HomeRepository _repo;


  Future<void> fetch({bool silent = false}) async {
    if (!silent) {
      state = const HomeLoading();
    }
    try {
      final results = await Future.wait([
        _repo.fetchHomeData(),
        _repo.fetchOffers(),
      ]);
      final homeData = results[0] as HomeData;
      final offers = results[1] as List<OfferModel>;
      state = HomeLoaded(data: homeData, offers: offers);
    } catch (e, stackTrace) {
      debugPrint('====================================================');
      debugPrint('HOME CONTROLLER FETCH ERROR:');
      debugPrint('Exception: $e');
      debugPrint('Stack trace:\n$stackTrace');
      debugPrint('====================================================');
      if (!silent) {
        state = HomeError('Failed to load home data: $e');
      }
    }
  }
}
