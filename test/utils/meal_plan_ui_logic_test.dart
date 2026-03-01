import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_list/utils/meal_plan_ui_logic.dart';

void main() {
  group('MealPlanUiLogic', () {
    test('resolveScrollUiState computes header/bottom/jump flags', () {
      final state = MealPlanUiLogic.resolveScrollUiState(
        offset: 220,
        maxExtent: 230,
        weekOffset: 0,
        isTodayVisibleInViewport: false,
      );

      expect(state.showHeader, isFalse);
      expect(state.showBottomGroceryButton, isTrue);
      expect(state.showJumpToToday, isTrue);
    });

    test('shouldShowJumpToToday returns false when in non-current week', () {
      final show = MealPlanUiLogic.shouldShowJumpToToday(
        offset: 400,
        weekOffset: 1,
        isTodayVisibleInViewport: false,
      );

      expect(show, isFalse);
    });

    test('shouldShowJumpToToday returns false when near top', () {
      final show = MealPlanUiLogic.shouldShowJumpToToday(
        offset: 120,
        weekOffset: 0,
        isTodayVisibleInViewport: false,
      );

      expect(show, isFalse);
    });

    test('week swipe thresholds are respected', () {
      expect(MealPlanUiLogic.shouldGoToNextWeek(-350), isTrue);
      expect(MealPlanUiLogic.shouldGoToNextWeek(-349), isFalse);
      expect(MealPlanUiLogic.shouldGoToPreviousWeek(350), isTrue);
      expect(MealPlanUiLogic.shouldGoToPreviousWeek(349), isFalse);
    });

    test('week slide offset follows delta direction', () {
      expect(MealPlanUiLogic.weekContentSlideOffsetForDelta(1), 0.06);
      expect(MealPlanUiLogic.weekContentSlideOffsetForDelta(-1), -0.06);
    });
  });
}
