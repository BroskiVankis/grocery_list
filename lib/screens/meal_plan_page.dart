import 'package:flutter/material.dart';

import '../models/meal_slot.dart';
import '../models/recipe_model.dart';
import '../theme/app_colors.dart';
import '../utils/meal_plan_logic.dart';
import '../utils/meal_plan_ui_logic.dart';
import '../widgets/meal_plan/add_meal_sheet.dart';
import '../widgets/meal_plan/day_picker_sheet.dart';
import '../widgets/meal_plan/empty_week_banner.dart';
import '../widgets/meal_plan/floating_grocery_button.dart';
import '../widgets/meal_plan/jump_to_today_chip.dart';
import '../widgets/meal_plan/meal_day_card.dart';
import '../widgets/meal_plan/meal_actions_sheet.dart';
import '../widgets/meal_plan/meal_type_picker_sheet.dart';
import '../widgets/meal_plan/week_header.dart';
import 'recipe_details_page.dart';

class MealPlanPage extends StatefulWidget {
  const MealPlanPage({super.key});

  @override
  State<MealPlanPage> createState() => _MealPlanPageState();
}

class _MealPlanPageState extends State<MealPlanPage> {
  final ScrollController _scrollController = ScrollController();
  Map<DateTime, Object?> _plannedMeals = <DateTime, Object?>{};
  final Set<DateTime> _expandedMealDays = <DateTime>{};
  final List<GlobalKey> _dayKeys = List<GlobalKey>.generate(
    7,
    (_) => GlobalKey(),
  );

  late final DateTime _today;
  int _weekOffset = 0;
  int _weekLabelDirection = 1;
  double _weekContentSlideOffsetX = 0;
  bool _showHeader = true;
  bool _showBottomGroceryButton = false;
  bool _showJumpToToday = false;

  @override
  void initState() {
    super.initState();
    _today = _dateOnly(DateTime.now());
    _plannedMeals = <DateTime, Object?>{};
    _seedInitialWeekMeals();
    _scrollController.addListener(_onScrollEffects);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToTodayIfVisible();
      _onScrollEffects();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollEffects);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScrollEffects() {
    if (!_scrollController.hasClients) return;

    final offset = _scrollController.offset;
    final maxExtent = _scrollController.position.maxScrollExtent;
    final resolved = MealPlanUiLogic.resolveScrollUiState(
      offset: offset,
      maxExtent: maxExtent,
      weekOffset: _weekOffset,
      isTodayVisibleInViewport: _isTodayVisibleInViewport(),
    );

    if (resolved.showHeader == _showHeader &&
        resolved.showBottomGroceryButton == _showBottomGroceryButton &&
        resolved.showJumpToToday == _showJumpToToday) {
      return;
    }

    setState(() {
      _showHeader = resolved.showHeader;
      _showBottomGroceryButton = resolved.showBottomGroceryButton;
      _showJumpToToday = resolved.showJumpToToday;
    });
  }

  bool _isTodayVisibleInViewport() {
    if (_weekOffset != 0) return false;

    final days = _visibleWeekDays;
    final index = days.indexWhere((day) => _isSameDate(day, _today));
    if (index == -1) return false;

    final context = _dayKeys[index].currentContext;
    if (context == null) return false;

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return false;

    final topLeft = renderObject.localToGlobal(Offset.zero);
    final bottomY = topLeft.dy + renderObject.size.height;
    final screenHeight = MediaQuery.of(context).size.height;

    return bottomY >= 0 && topLeft.dy <= screenHeight;
  }

  DateTime _dateOnly(DateTime date) => MealPlanLogic.dateOnly(date);

  DateTime _startOfWeek(DateTime date) {
    return MealPlanLogic.startOfWeek(date);
  }

  DateTime get _visibleWeekStart {
    final base = _today.add(Duration(days: _weekOffset * 7));
    return _startOfWeek(base);
  }

  List<DateTime> get _visibleWeekDays {
    final start = _visibleWeekStart;
    return List<DateTime>.generate(
      7,
      (index) => start.add(Duration(days: index)),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return MealPlanLogic.isSameDate(a, b);
  }

  Map<MealSlot, RecipeModel>? _readDayMeals(DateTime day) {
    return MealPlanLogic.readDayMeals(plannedMeals: _plannedMeals, day: day);
  }

  Map<MealSlot, RecipeModel> _ensureDayMeals(DateTime day) {
    return MealPlanLogic.ensureDayMeals(plannedMeals: _plannedMeals, day: day);
  }

  void _removeMealSlot(DateTime day, MealSlot slot) {
    MealPlanLogic.removeMealSlot(
      plannedMeals: _plannedMeals,
      expandedMealDays: _expandedMealDays,
      day: day,
      slot: slot,
    );
  }

  void _seedInitialWeekMeals() {
    final start = _startOfWeek(_today);

    RecipeModel recipeById(String id) {
      return sampleRecipes.firstWhere((recipe) => recipe.id == id);
    }

    _plannedMeals[_dateOnly(start.add(const Duration(days: 1)))] = {
      MealSlot.dinner: recipeById('garlic-butter-pasta'),
    };
    _plannedMeals[_dateOnly(start.add(const Duration(days: 2)))] = {
      MealSlot.dinner: recipeById('greek-salad-bowl'),
    };
    _plannedMeals[_dateOnly(start.add(const Duration(days: 4)))] = {
      MealSlot.dinner: recipeById('chicken-rice-skillet'),
    };
  }

  String _weekdayUpper(DateTime date) {
    return MealPlanLogic.weekdayUpper(date);
  }

  String _weekRangeLabel(DateTime weekStart) {
    return MealPlanLogic.weekRangeLabel(weekStart);
  }

  int get _visibleWeekPlannedCount {
    return MealPlanLogic.visibleWeekPlannedCount(
      days: _visibleWeekDays,
      plannedMeals: _plannedMeals,
    );
  }

  int get _visibleWeekMealCount {
    return MealPlanLogic.visibleWeekMealCount(
      days: _visibleWeekDays,
      plannedMeals: _plannedMeals,
    );
  }

  String _mealSlotLabel(MealSlot slot) {
    return MealPlanLogic.mealSlotLabel(slot);
  }

  String _addMealSlotLabel(MealSlot slot) {
    return MealPlanLogic.addMealSlotLabel(slot);
  }

  String _dayMealCountLabel(int count) {
    return MealPlanLogic.dayMealCountLabel(count);
  }

  void _expandExtraMeals(DateTime day) {
    setState(() {
      _expandedMealDays.add(_dateOnly(day));
    });
  }

  RecipeModel _pickQuickRecipe(String quickKey) {
    return MealPlanLogic.pickQuickRecipe(
      quickKey: quickKey,
      today: _today,
      plannedMeals: _plannedMeals,
    );
  }

  void _applyQuickTodayAction(String quickKey) {
    final day = _dateOnly(_today);
    final recipe = _pickQuickRecipe(quickKey);

    setState(() {
      final meals = _ensureDayMeals(day);
      meals[MealSlot.dinner] = recipe;
    });
  }

  void _goToPreviousWeek() {
    _changeWeek(-1);
  }

  void _goToNextWeek() {
    _changeWeek(1);
  }

  void _changeWeek(int delta) {
    setState(() {
      _weekOffset += delta;
      _weekLabelDirection = delta;
      _weekContentSlideOffsetX = MealPlanUiLogic.weekContentSlideOffsetForDelta(
        delta,
      );
    });
    _afterWeekChanged();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _weekContentSlideOffsetX = 0;
      });
    });
  }

  void _afterWeekChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_weekOffset == 0) {
        _scrollToTodayIfVisible();
      } else {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (MealPlanUiLogic.shouldGoToNextWeek(velocity)) {
      _goToNextWeek();
    } else if (MealPlanUiLogic.shouldGoToPreviousWeek(velocity)) {
      _goToPreviousWeek();
    }
  }

  void _scrollToTodayIfVisible() {
    final days = _visibleWeekDays;
    final index = days.indexWhere((day) => _isSameDate(day, _today));
    if (index == -1) return;

    final context = _dayKeys[index].currentContext;
    if (context == null) return;

    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 260),
      alignment: 0.08,
      curve: Curves.easeOut,
    );
  }

  MealSlot _suggestMealSlotForDay(
    DateTime day, {
    MealSlot fallback = MealSlot.dinner,
  }) {
    return MealPlanLogic.suggestMealSlotForDay(
      day: day,
      plannedMeals: _plannedMeals,
      fallback: fallback,
    );
  }

  Future<MealSlot?> _showMealTypePickerSheet({
    required DateTime day,
    MealSlot preferred = MealSlot.dinner,
  }) {
    final meals =
        _readDayMeals(_dateOnly(day)) ?? const <MealSlot, RecipeModel>{};
    final suggested = _suggestMealSlotForDay(day, fallback: preferred);

    return MealTypePickerSheet.show(
      context: context,
      meals: meals,
      suggested: suggested,
      labelBuilder: _mealSlotLabel,
    );
  }

  Future<void> _showAddMealFlow({
    required DateTime day,
    MealSlot preferredSlot = MealSlot.dinner,
  }) async {
    final slot = await _showMealTypePickerSheet(
      day: day,
      preferred: preferredSlot,
    );
    if (!mounted || slot == null) return;

    await _showAddMealSheet(date: day, slot: slot);
  }

  Future<void> _showAddMealSheet({
    required DateTime date,
    required MealSlot slot,
  }) async {
    final selected = await AddMealSheet.show(
      context: context,
      title: _addMealSlotLabel(slot),
    );

    if (!mounted || selected == null) return;

    setState(() {
      final day = _dateOnly(date);
      final meals = _ensureDayMeals(day);
      meals[slot] = selected;
      if (slot != MealSlot.dinner) {
        _expandedMealDays.add(day);
      }
    });
  }

  Future<DateTime?> _showDayPickerSheet({required DateTime currentDay}) async {
    return DayPickerSheet.show(
      context: context,
      days: _visibleWeekDays,
      currentDay: currentDay,
      weekdayLabel: _weekdayUpper,
      isSameDate: _isSameDate,
    );
  }

  Future<void> _showMealActions(
    DateTime day,
    MealSlot slot,
    RecipeModel recipe,
  ) async {
    final action = await MealActionsSheet.show(context: context);

    if (!mounted || action == null) return;

    if (action == 'remove') {
      setState(() {
        final dateKey = _dateOnly(day);
        _removeMealSlot(dateKey, slot);
      });
      return;
    }

    if (action == 'move' || action == 'change_day') {
      final destination = await _showDayPickerSheet(currentDay: day);
      if (!mounted || destination == null || _isSameDate(destination, day)) {
        return;
      }

      setState(() {
        final origin = _dateOnly(day);
        final target = _dateOnly(destination);

        _removeMealSlot(origin, slot);

        final destinationMeals = _ensureDayMeals(target);
        destinationMeals[slot] = recipe;
        if (slot != MealSlot.dinner) {
          _expandedMealDays.add(target);
        }
      });
    }
  }

  void _openRecipe(RecipeModel recipe) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RecipeDetailsPage(recipe: recipe)),
    );
  }

  void _generateGroceryList() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Grocery list generation is coming soon.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weekStart = _visibleWeekStart;
    final days = _visibleWeekDays;
    final plannedCount = _visibleWeekPlannedCount;
    final totalMeals = _visibleWeekMealCount;

    return Scaffold(
      backgroundColor: AppColors.sageTop,
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragEnd: _onHorizontalDragEnd,
          child: Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeOut,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            axisAlignment: -1,
                            child: child,
                          ),
                        );
                      },
                      child: _showHeader
                          ? WeekHeader(
                              key: const ValueKey('week-header-visible'),
                              weekRangeLabel: _weekRangeLabel(weekStart),
                              plannedCount: plannedCount,
                              totalMeals: totalMeals,
                              labelDirection: _weekLabelDirection,
                              onPreviousWeek: _goToPreviousWeek,
                              onNextWeek: _goToNextWeek,
                            )
                          : const SizedBox.shrink(
                              key: ValueKey('week-header-hidden'),
                            ),
                    ),
                  ),
                  if (plannedCount == 0)
                    const SliverToBoxAdapter(child: EmptyWeekBanner()),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    sliver: SliverList.separated(
                      itemCount: days.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 18),
                      itemBuilder: (context, index) {
                        final day = days[index];
                        final dayKey = _dateOnly(day);
                        final dayMeals =
                            _readDayMeals(dayKey) ??
                            const <MealSlot, RecipeModel>{};
                        final isToday = _isSameDate(day, _today);

                        return MealDayCard(
                          dayKey: _dayKeys[index],
                          day: day,
                          dayMeals: dayMeals,
                          isToday: isToday,
                          isExpanded: _expandedMealDays.contains(dayKey),
                          weekContentSlideOffsetX: _weekContentSlideOffsetX,
                          weekdayLabel: _weekdayUpper,
                          dayMealCountLabel: _dayMealCountLabel,
                          mealSlotLabel: _mealSlotLabel,
                          addMealSlotLabel: _addMealSlotLabel,
                          onExpandExtraMeals: () => _expandExtraMeals(day),
                          onQuickTodayAction: _applyQuickTodayAction,
                          onAddMealFlowDinner: () => _showAddMealFlow(
                            day: day,
                            preferredSlot: MealSlot.dinner,
                          ),
                          onAddMeal: (slot) =>
                              _showAddMealSheet(date: day, slot: slot),
                          onOpenRecipe: _openRecipe,
                          onMealLongPress: (slot, recipe) =>
                              _showMealActions(day, slot, recipe),
                          onRemoveMeal: (slot) {
                            setState(() {
                              _removeMealSlot(dayKey, slot);
                            });
                          },
                          onAddAnotherMeal: () => _showAddMealFlow(
                            day: day,
                            preferredSlot: MealSlot.breakfast,
                          ),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: FloatingGroceryButton(
                      visible: _showBottomGroceryButton,
                      bottomPadding: MediaQuery.of(context).padding.bottom,
                      onPressed: _generateGroceryList,
                    ),
                  ),
                ],
              ),
              JumpToTodayChip(
                visible: _showJumpToToday,
                bottom: MediaQuery.of(context).padding.bottom + 84,
                onPressed: _scrollToTodayIfVisible,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
