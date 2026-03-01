import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_list/models/meal_slot.dart';
import 'package:grocery_list/models/recipe_model.dart';
import 'package:grocery_list/utils/meal_plan_logic.dart';

void main() {
  group('MealPlanLogic date helpers', () {
    test('dateOnly strips time', () {
      final value = MealPlanLogic.dateOnly(DateTime(2026, 2, 27, 18, 45));
      expect(value, DateTime(2026, 2, 27));
    });

    test('startOfWeek returns Monday', () {
      final value = MealPlanLogic.startOfWeek(DateTime(2026, 2, 27));
      expect(value.weekday, DateTime.monday);
      expect(value, DateTime(2026, 2, 23));
    });

    test('weekRangeLabel formats expected span', () {
      expect(
        MealPlanLogic.weekRangeLabel(DateTime(2026, 2, 23)),
        'Feb 23 – Mar 1',
      );
    });
  });

  group('MealPlanLogic mapping and conversion', () {
    test('readDayMeals converts legacy RecipeModel value to dinner map', () {
      final day = DateTime(2026, 2, 27);
      final plannedMeals = <DateTime, Object?>{day: sampleRecipes.first};

      final result = MealPlanLogic.readDayMeals(
        plannedMeals: plannedMeals,
        day: day,
      );

      expect(result, isNotNull);
      expect(result![MealSlot.dinner], same(sampleRecipes.first));
      expect(plannedMeals[day], isA<Map<MealSlot, RecipeModel>>());
    });

    test('ensureDayMeals creates empty map when missing', () {
      final day = DateTime(2026, 2, 27);
      final plannedMeals = <DateTime, Object?>{};

      final result = MealPlanLogic.ensureDayMeals(
        plannedMeals: plannedMeals,
        day: day,
      );

      expect(result, isEmpty);
      expect(plannedMeals.containsKey(day), isTrue);
    });

    test('removeMealSlot removes day and expanded flag when empty', () {
      final day = DateTime(2026, 2, 27);
      final plannedMeals = <DateTime, Object?>{
        day: <MealSlot, RecipeModel>{MealSlot.dinner: sampleRecipes.first},
      };
      final expanded = <DateTime>{day};

      MealPlanLogic.removeMealSlot(
        plannedMeals: plannedMeals,
        expandedMealDays: expanded,
        day: day,
        slot: MealSlot.dinner,
      );

      expect(plannedMeals.containsKey(day), isFalse);
      expect(expanded.contains(day), isFalse);
    });
  });

  group('MealPlanLogic meal planning behavior', () {
    test('visible counters return planned day count and total meals', () {
      final monday = DateTime(2026, 2, 23);
      final days = List<DateTime>.generate(
        7,
        (index) => monday.add(Duration(days: index)),
      );
      final plannedMeals = <DateTime, Object?>{
        days[1]: <MealSlot, RecipeModel>{MealSlot.dinner: sampleRecipes[0]},
        days[3]: <MealSlot, RecipeModel>{
          MealSlot.breakfast: sampleRecipes[1],
          MealSlot.dinner: sampleRecipes[2],
        },
      };

      final plannedCount = MealPlanLogic.visibleWeekPlannedCount(
        days: days,
        plannedMeals: plannedMeals,
      );
      final mealCount = MealPlanLogic.visibleWeekMealCount(
        days: days,
        plannedMeals: plannedMeals,
      );

      expect(plannedCount, 2);
      expect(mealCount, 3);
    });

    test('suggestMealSlotForDay prefers lunch after dinner exists', () {
      final day = DateTime(2026, 2, 27);
      final plannedMeals = <DateTime, Object?>{
        day: <MealSlot, RecipeModel>{MealSlot.dinner: sampleRecipes.first},
      };

      final suggested = MealPlanLogic.suggestMealSlotForDay(
        day: day,
        plannedMeals: plannedMeals,
      );

      expect(suggested, MealSlot.lunch);
    });

    test(
      'pickQuickRecipe repeat-last-friday returns prior dinner when present',
      () {
        final today = DateTime(2026, 2, 27);
        final previousWeekSameDay = MealPlanLogic.dateOnly(
          today.subtract(const Duration(days: 7)),
        );
        final plannedMeals = <DateTime, Object?>{
          previousWeekSameDay: <MealSlot, RecipeModel>{
            MealSlot.dinner: sampleRecipes[3],
          },
        };

        final selected = MealPlanLogic.pickQuickRecipe(
          quickKey: 'repeat-last-friday',
          today: today,
          plannedMeals: plannedMeals,
        );

        expect(selected.id, sampleRecipes[3].id);
      },
    );
  });
}
