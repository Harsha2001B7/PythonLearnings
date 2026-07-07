import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppState {
  final List<int> wishlist;
  final List<int> compareList;
  final List<int> recentlyViewed;
  final bool isCompareOpen;
  final bool isCmdkOpen;

  AppState({
    required this.wishlist,
    required this.compareList,
    required this.recentlyViewed,
    required this.isCompareOpen,
    required this.isCmdkOpen,
  });

  AppState copyWith({
    List<int>? wishlist,
    List<int>? compareList,
    List<int>? recentlyViewed,
    bool? isCompareOpen,
    bool? isCmdkOpen,
  }) {
    return AppState(
      wishlist: wishlist ?? this.wishlist,
      compareList: compareList ?? this.compareList,
      recentlyViewed: recentlyViewed ?? this.recentlyViewed,
      isCompareOpen: isCompareOpen ?? this.isCompareOpen,
      isCmdkOpen: isCmdkOpen ?? this.isCmdkOpen,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier()
      : super(AppState(
          wishlist: [],
          compareList: [],
          recentlyViewed: [],
          isCompareOpen: false,
          isCmdkOpen: false,
        ));

  void toggleWishlist(int id) {
    final list = List<int>.from(state.wishlist);
    if (list.contains(id)) {
      list.remove(id);
    } else {
      list.add(id);
    }
    state = state.copyWith(wishlist: list);
  }

  bool toggleCompare(int id) {
    final list = List<int>.from(state.compareList);
    if (list.contains(id)) {
      list.remove(id);
      state = state.copyWith(compareList: list);
      return true;
    } else {
      if (list.length >= 3) {
        return false; // Max 3 items reached
      }
      list.add(id);
      state = state.copyWith(compareList: list);
      return true;
    }
  }

  void addRecentlyViewed(int id) {
    final list = List<int>.from(state.recentlyViewed);
    list.remove(id); // Remove if already exists to push to front
    list.insert(0, id);
    if (list.length > 5) {
      list.removeLast(); // Cap at 5 recently viewed items
    }
    state = state.copyWith(recentlyViewed: list);
  }

  void clearCompare() {
    state = state.copyWith(compareList: []);
  }

  void setCompareOpen(bool open) {
    state = state.copyWith(isCompareOpen: open);
  }

  void setCmdkOpen(bool open) {
    state = state.copyWith(isCmdkOpen: open);
  }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});
