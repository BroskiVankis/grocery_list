import 'package:flutter/material.dart';

import '../../models/meal_slot.dart';
import '../../models/recipe_model.dart';
import '../../theme/app_colors.dart';
import 'meal_slot_section.dart';

class MealDayCard extends StatelessWidget {
  const MealDayCard({
    super.key,
    required this.dayKey,
    required this.day,
    required this.dayMeals,
    required this.isToday,
    required this.isExpanded,
    required this.weekContentSlideOffsetX,
    required this.weekdayLabel,
    required this.dayMealCountLabel,
    required this.mealSlotLabel,
    required this.addMealSlotLabel,
    required this.onExpandExtraMeals,
    required this.onQuickTodayAction,
    required this.onAddMealFlowDinner,
    required this.onAddMeal,
    required this.onOpenRecipe,
    required this.onMealLongPress,
    required this.onRemoveMeal,
    required this.onAddAnotherMeal,
  });

  final GlobalKey dayKey;
  final DateTime day;
  final Map<MealSlot, RecipeModel> dayMeals;
  final bool isToday;
  final bool isExpanded;
  final double weekContentSlideOffsetX;
  final String Function(DateTime day) weekdayLabel;
  final String Function(int count) dayMealCountLabel;
  final String Function(MealSlot slot) mealSlotLabel;
  final String Function(MealSlot slot) addMealSlotLabel;
  final VoidCallback onExpandExtraMeals;
  final ValueChanged<String> onQuickTodayAction;
  final VoidCallback onAddMealFlowDinner;
  final ValueChanged<MealSlot> onAddMeal;
  final ValueChanged<RecipeModel> onOpenRecipe;
  final void Function(MealSlot slot, RecipeModel recipe) onMealLongPress;
  final ValueChanged<MealSlot> onRemoveMeal;
  final VoidCallback onAddAnotherMeal;

  @override
  Widget build(BuildContext context) {
    final breakfast = dayMeals[MealSlot.breakfast];
    final lunch = dayMeals[MealSlot.lunch];
    final dinner = dayMeals[MealSlot.dinner];
    final dayMealCount = dayMeals.length;
    final showExtraSlots = isExpanded || breakfast != null || lunch != null;
    final showTodayEmptyHero = isToday && dayMealCount == 0 && !showExtraSlots;
    final showCompactEmpty = !isToday && dayMealCount == 0 && !showExtraSlots;

    return AnimatedSlide(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      offset: Offset(weekContentSlideOffsetX, 0),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        scale: isToday ? 1 : 0.985,
        child: Container(
          key: dayKey,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.inputBorder.withOpacity(0.35),
              width: 0.6,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandGreen.withOpacity(isToday ? 0.14 : 0.07),
                blurRadius: isToday ? 22 : 16,
                offset: Offset(0, isToday ? 9 : 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DayHeader(
                day: day,
                isToday: isToday,
                dayMealCount: dayMealCount,
                weekdayLabel: weekdayLabel,
                dayMealCountLabel: dayMealCountLabel,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isToday ? 16 : 15,
                  showCompactEmpty ? 10 : 12,
                  isToday ? 16 : 15,
                  showCompactEmpty ? 10 : 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showTodayEmptyHero)
                      _TodayEmptyContent(
                        onAddTodayMeal: () => onAddMeal(MealSlot.dinner),
                        onExpandExtraMeals: onExpandExtraMeals,
                        onQuickTodayAction: onQuickTodayAction,
                      )
                    else if (showCompactEmpty)
                      _CompactAddRow(
                        leftLabel: 'No meals planned',
                        actionLabel: 'Add meal',
                        onTap: onAddMealFlowDinner,
                      )
                    else ...[
                      if (showExtraSlots) ...[
                        MealSlotSection(
                          day: day,
                          slot: MealSlot.breakfast,
                          label: mealSlotLabel(MealSlot.breakfast),
                          addLabel: addMealSlotLabel(MealSlot.breakfast),
                          recipe: breakfast,
                          onAdd: () => onAddMeal(MealSlot.breakfast),
                          onOpen: () {
                            final meal = breakfast;
                            if (meal == null) return;
                            onOpenRecipe(meal);
                          },
                          onLongPress: () {
                            final meal = breakfast;
                            if (meal == null) return;
                            onMealLongPress(MealSlot.breakfast, meal);
                          },
                          onRemove: () => onRemoveMeal(MealSlot.breakfast),
                        ),
                        MealSlotSection(
                          day: day,
                          slot: MealSlot.lunch,
                          label: mealSlotLabel(MealSlot.lunch),
                          addLabel: addMealSlotLabel(MealSlot.lunch),
                          recipe: lunch,
                          onAdd: () => onAddMeal(MealSlot.lunch),
                          onOpen: () {
                            final meal = lunch;
                            if (meal == null) return;
                            onOpenRecipe(meal);
                          },
                          onLongPress: () {
                            final meal = lunch;
                            if (meal == null) return;
                            onMealLongPress(MealSlot.lunch, meal);
                          },
                          onRemove: () => onRemoveMeal(MealSlot.lunch),
                        ),
                      ],
                      MealSlotSection(
                        day: day,
                        slot: MealSlot.dinner,
                        label: mealSlotLabel(MealSlot.dinner),
                        addLabel: addMealSlotLabel(MealSlot.dinner),
                        recipe: dinner,
                        showHeader: showExtraSlots,
                        onAdd: () => onAddMeal(MealSlot.dinner),
                        onOpen: () {
                          final meal = dinner;
                          if (meal == null) return;
                          onOpenRecipe(meal);
                        },
                        onLongPress: () {
                          final meal = dinner;
                          if (meal == null) return;
                          onMealLongPress(MealSlot.dinner, meal);
                        },
                        onRemove: () => onRemoveMeal(MealSlot.dinner),
                      ),
                      if (!showExtraSlots && dinner != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _AddAnotherMealAction(onTap: onAddAnotherMeal),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.day,
    required this.isToday,
    required this.dayMealCount,
    required this.weekdayLabel,
    required this.dayMealCountLabel,
  });

  final DateTime day;
  final bool isToday;
  final int dayMealCount;
  final String Function(DateTime day) weekdayLabel;
  final String Function(int count) dayMealCountLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: isToday
            ? AppColors.brandGreen.withOpacity(0.10)
            : AppColors.brandGreen.withOpacity(0.035),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        border: Border(
          bottom: BorderSide(
            color: AppColors.inputBorder.withOpacity(0.45),
            width: 0.6,
          ),
        ),
      ),
      child: Row(
        children: [
          if (isToday) ...[
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.brandGreen,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            weekdayLabel(day),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          if (isToday) ...[
            const SizedBox(width: 8),
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.brandGreen,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.brandGreen.withOpacity(0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Today',
                style: TextStyle(
                  color: AppColors.brandGreen.withOpacity(0.92),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          if (dayMealCount > 0) ...[
            const Spacer(),
            Text(
              dayMealCountLabel(dayMealCount),
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.70),
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ] else
            const Spacer(),
        ],
      ),
    );
  }
}

class _TodayEmptyContent extends StatelessWidget {
  const _TodayEmptyContent({
    required this.onAddTodayMeal,
    required this.onExpandExtraMeals,
    required this.onQuickTodayAction,
  });

  final VoidCallback onAddTodayMeal;
  final VoidCallback onExpandExtraMeals;
  final ValueChanged<String> onQuickTodayAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onAddTodayMeal,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandGreen,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text(
              'Add today\'s meal',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: onExpandExtraMeals,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
          ),
          child: const Text(
            'Add breakfast or lunch',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Most people plan dinner — add more if you want.',
          style: TextStyle(
            color: AppColors.textSecondary.withOpacity(0.82),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ActionChip(
              label: const Text('15 min'),
              onPressed: () => onQuickTodayAction('15-min'),
              backgroundColor: AppColors.inputBg,
              side: const BorderSide(color: AppColors.inputBorderSoft),
            ),
            ActionChip(
              label: const Text('Healthy'),
              onPressed: () => onQuickTodayAction('healthy'),
              backgroundColor: AppColors.inputBg,
              side: const BorderSide(color: AppColors.inputBorderSoft),
            ),
            ActionChip(
              label: const Text('Repeat last Friday'),
              onPressed: () => onQuickTodayAction('repeat-last-friday'),
              backgroundColor: AppColors.inputBg,
              side: const BorderSide(color: AppColors.inputBorderSoft),
            ),
          ],
        ),
      ],
    );
  }
}

class _CompactAddRow extends StatelessWidget {
  const _CompactAddRow({
    required this.leftLabel,
    required this.actionLabel,
    required this.onTap,
  });

  final String leftLabel;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 44,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.inputBorderSoft),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  leftLabel,
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.88),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.add,
                size: 16,
                color: AppColors.brandGreen.withOpacity(0.96),
              ),
              const SizedBox(width: 4),
              Text(
                actionLabel,
                style: TextStyle(
                  color: AppColors.brandGreen.withOpacity(0.96),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddAnotherMealAction extends StatelessWidget {
  const _AddAnotherMealAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.add,
                size: 16,
                color: AppColors.brandGreen.withOpacity(0.96),
              ),
              const SizedBox(width: 4),
              Text(
                'Add another meal',
                style: TextStyle(
                  color: AppColors.brandGreen.withOpacity(0.96),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
