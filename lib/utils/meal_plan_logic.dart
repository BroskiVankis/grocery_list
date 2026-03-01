import '../models/meal_slot.dart';
import '../models/recipe_model.dart';

class MealPlanLogic {
  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime startOfWeek(DateTime date) {
    final normalized = dateOnly(date);
    return normalized.subtract(Duration(days: normalized.weekday - 1));
  }

  static bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String monthShort(int month) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  static String weekdayUpper(DateTime date) {
    const days = <String>[
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY',
    ];
    return days[date.weekday - 1];
  }

  static String weekRangeLabel(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final start = '${monthShort(weekStart.month)} ${weekStart.day}';
    final end = '${monthShort(weekEnd.month)} ${weekEnd.day}';
    return '$start – $end';
  }

  static MealSlot? slotFromUnknownKey(Object? key) {
    if (key is MealSlot) return key;
    if (key is int && key >= 0 && key < MealSlot.values.length) {
      return MealSlot.values[key];
    }
    if (key is String) {
      switch (key.toLowerCase()) {
        case 'breakfast':
          return MealSlot.breakfast;
        case 'lunch':
          return MealSlot.lunch;
        case 'dinner':
          return MealSlot.dinner;
      }
    }
    return null;
  }

  static Map<MealSlot, RecipeModel>? readDayMeals({
    required Map<DateTime, Object?> plannedMeals,
    required DateTime day,
  }) {
    final raw = plannedMeals[day];
    if (raw == null) return null;

    if (raw is Map<MealSlot, RecipeModel>) {
      return raw;
    }

    if (raw is RecipeModel) {
      final converted = <MealSlot, RecipeModel>{MealSlot.dinner: raw};
      plannedMeals[day] = converted;
      return converted;
    }

    if (raw is Map) {
      final converted = <MealSlot, RecipeModel>{};
      raw.forEach((key, value) {
        final slot = slotFromUnknownKey(key);
        if (slot == null || value is! RecipeModel) return;
        converted[slot] = value;
      });
      plannedMeals[day] = converted;
      return converted;
    }

    return null;
  }

  static Map<MealSlot, RecipeModel> ensureDayMeals({
    required Map<DateTime, Object?> plannedMeals,
    required DateTime day,
  }) {
    final existing = readDayMeals(plannedMeals: plannedMeals, day: day);
    if (existing != null) return existing;

    final created = <MealSlot, RecipeModel>{};
    plannedMeals[day] = created;
    return created;
  }

  static void removeMealSlot({
    required Map<DateTime, Object?> plannedMeals,
    required Set<DateTime> expandedMealDays,
    required DateTime day,
    required MealSlot slot,
  }) {
    final meals = readDayMeals(plannedMeals: plannedMeals, day: day);
    if (meals == null) return;

    meals.remove(slot);
    if (meals.isEmpty) {
      plannedMeals.remove(day);
      expandedMealDays.remove(day);
    }
  }

  static int visibleWeekPlannedCount({
    required List<DateTime> days,
    required Map<DateTime, Object?> plannedMeals,
  }) {
    return days.where((day) {
      final meals = readDayMeals(
        plannedMeals: plannedMeals,
        day: dateOnly(day),
      );
      return meals != null && meals.isNotEmpty;
    }).length;
  }

  static int visibleWeekMealCount({
    required List<DateTime> days,
    required Map<DateTime, Object?> plannedMeals,
  }) {
    return days.fold<int>(0, (count, day) {
      final meals = readDayMeals(
        plannedMeals: plannedMeals,
        day: dateOnly(day),
      );
      return count + (meals?.length ?? 0);
    });
  }

  static String mealSlotLabel(MealSlot slot) {
    switch (slot) {
      case MealSlot.breakfast:
        return 'Breakfast';
      case MealSlot.lunch:
        return 'Lunch';
      case MealSlot.dinner:
        return 'Dinner';
    }
  }

  static String addMealSlotLabel(MealSlot slot) {
    switch (slot) {
      case MealSlot.breakfast:
        return '+ Add breakfast';
      case MealSlot.lunch:
        return '+ Add lunch';
      case MealSlot.dinner:
        return '+ Add dinner';
    }
  }

  static String dayMealCountLabel(int count) {
    return count == 1 ? '1 meal' : '$count meals';
  }

  static MealSlot suggestMealSlotForDay({
    required DateTime day,
    required Map<DateTime, Object?> plannedMeals,
    MealSlot fallback = MealSlot.dinner,
  }) {
    final meals =
        readDayMeals(plannedMeals: plannedMeals, day: dateOnly(day)) ??
        const <MealSlot, RecipeModel>{};

    if (meals.containsKey(MealSlot.dinner)) {
      if (!meals.containsKey(MealSlot.lunch)) return MealSlot.lunch;
      if (!meals.containsKey(MealSlot.breakfast)) return MealSlot.breakfast;
    }

    if (!meals.containsKey(fallback)) return fallback;
    for (final slot in MealSlot.values) {
      if (!meals.containsKey(slot)) return slot;
    }
    return fallback;
  }

  static RecipeModel pickQuickRecipe({
    required String quickKey,
    required DateTime today,
    required Map<DateTime, Object?> plannedMeals,
  }) {
    RecipeModel? selected;

    if (quickKey == '15-min') {
      selected = sampleRecipes.cast<RecipeModel?>().firstWhere(
        (recipe) =>
            recipe != null && recipe.duration.toLowerCase().contains('15'),
        orElse: () => null,
      );
    }

    if (selected == null && quickKey == 'healthy') {
      selected = sampleRecipes.cast<RecipeModel?>().firstWhere(
        (recipe) =>
            recipe != null &&
            recipe.tags.any((tag) => tag.toLowerCase().contains('healthy')),
        orElse: () => null,
      );
    }

    if (selected == null && quickKey == 'repeat-last-friday') {
      final previousWeekSameDay = dateOnly(
        today.subtract(const Duration(days: 7)),
      );
      selected = readDayMeals(
        plannedMeals: plannedMeals,
        day: previousWeekSameDay,
      )?[MealSlot.dinner];
    }

    return selected ?? sampleRecipes.first;
  }
}
