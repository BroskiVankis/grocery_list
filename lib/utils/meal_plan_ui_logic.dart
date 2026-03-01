class MealPlanScrollUiState {
  const MealPlanScrollUiState({
    required this.showHeader,
    required this.showBottomGroceryButton,
    required this.showJumpToToday,
  });

  final bool showHeader;
  final bool showBottomGroceryButton;
  final bool showJumpToToday;
}

class MealPlanUiLogic {
  static MealPlanScrollUiState resolveScrollUiState({
    required double offset,
    required double maxExtent,
    required int weekOffset,
    required bool isTodayVisibleInViewport,
  }) {
    final showHeader = offset <= 36;
    final showBottomGroceryButton = (maxExtent - offset) <= 16;
    final showJumpToToday = shouldShowJumpToToday(
      offset: offset,
      weekOffset: weekOffset,
      isTodayVisibleInViewport: isTodayVisibleInViewport,
    );

    return MealPlanScrollUiState(
      showHeader: showHeader,
      showBottomGroceryButton: showBottomGroceryButton,
      showJumpToToday: showJumpToToday,
    );
  }

  static bool shouldShowJumpToToday({
    required double offset,
    required int weekOffset,
    required bool isTodayVisibleInViewport,
  }) {
    if (weekOffset != 0) return false;
    if (offset < 180) return false;
    return !isTodayVisibleInViewport;
  }

  static bool shouldGoToNextWeek(double velocity) {
    return velocity <= -350;
  }

  static bool shouldGoToPreviousWeek(double velocity) {
    return velocity >= 350;
  }

  static double weekContentSlideOffsetForDelta(int delta) {
    return delta > 0 ? 0.06 : -0.06;
  }
}
