import 'package:flutter/material.dart';

import '../models/recipe_model.dart';
import '../theme/app_colors.dart';
import 'recipe_details_page.dart';

class MealPlanPage extends StatefulWidget {
  const MealPlanPage({super.key});

  @override
  State<MealPlanPage> createState() => _MealPlanPageState();
}

class _MealPlanPageState extends State<MealPlanPage> {
  final ScrollController _scrollController = ScrollController();
  final Map<DateTime, RecipeModel> _plannedMeals = <DateTime, RecipeModel>{};
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

  @override
  void initState() {
    super.initState();
    _today = _dateOnly(DateTime.now());
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
    final nextShowHeader = offset <= 36;
    final nextShowBottom = (maxExtent - offset) <= 16;

    if (nextShowHeader == _showHeader &&
        nextShowBottom == _showBottomGroceryButton) {
      return;
    }

    setState(() {
      _showHeader = nextShowHeader;
      _showBottomGroceryButton = nextShowBottom;
    });
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _startOfWeek(DateTime date) {
    final normalized = _dateOnly(date);
    return normalized.subtract(Duration(days: normalized.weekday - 1));
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
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _seedInitialWeekMeals() {
    final start = _startOfWeek(_today);

    RecipeModel recipeById(String id) {
      return sampleRecipes.firstWhere((recipe) => recipe.id == id);
    }

    _plannedMeals[_dateOnly(start.add(const Duration(days: 1)))] = recipeById(
      'garlic-butter-pasta',
    );
    _plannedMeals[_dateOnly(start.add(const Duration(days: 2)))] = recipeById(
      'greek-salad-bowl',
    );
    _plannedMeals[_dateOnly(start.add(const Duration(days: 4)))] = recipeById(
      'chicken-rice-skillet',
    );
  }

  String _monthShort(int month) {
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

  String _weekdayUpper(DateTime date) {
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

  String _weekRangeLabel(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final start = '${_monthShort(weekStart.month)} ${weekStart.day}';
    final end = '${_monthShort(weekEnd.month)} ${weekEnd.day}';
    return '$start – $end';
  }

  int get _visibleWeekPlannedCount {
    return _visibleWeekDays
        .where((day) => _plannedMeals.containsKey(_dateOnly(day)))
        .length;
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
      _weekContentSlideOffsetX = delta > 0 ? 0.06 : -0.06;
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
    if (velocity <= -350) {
      _goToNextWeek();
    } else if (velocity >= 350) {
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

  Future<void> _showAddMealSheet(DateTime date) async {
    final selected = await showModalBottomSheet<RecipeModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.sheetSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final searchController = TextEditingController();
        String query = '';

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = sampleRecipes.where((recipe) {
              if (query.trim().isEmpty) return true;
              final q = query.trim().toLowerCase();
              if (recipe.title.toLowerCase().contains(q)) return true;
              return recipe.ingredients.any(
                (ingredient) => ingredient.toLowerCase().contains(q),
              );
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.sheetHandle,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Add Meal',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: searchController,
                    cursorColor: AppColors.brandGreen,
                    onChanged: (value) {
                      setSheetState(() {
                        query = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search recipes...',
                      hintStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.inputBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.inputBorderSoft,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.brandGreen,
                          width: 1.8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        color: AppColors.inputBorder,
                      ),
                      itemBuilder: (context, index) {
                        final recipe = filtered[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 2,
                          ),
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.brandGreen.withOpacity(0.085),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              recipe.icon,
                              color: AppColors.brandGreen,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            recipe.title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            '⏱ ${recipe.duration} • ${recipe.difficulty}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () => Navigator.of(sheetContext).pop(recipe),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (!mounted || selected == null) return;

    setState(() {
      _plannedMeals[_dateOnly(date)] = selected;
    });
  }

  Future<DateTime?> _showDayPickerSheet({required DateTime currentDay}) async {
    final days = _visibleWeekDays;
    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: AppColors.sheetSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.sheetHandle,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Text(
                'Choose day',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              for (final day in days)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _weekdayUpper(day),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: _isSameDate(day, currentDay)
                      ? const Icon(Icons.check, color: AppColors.brandGreen)
                      : null,
                  onTap: () => Navigator.of(context).pop(day),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showMealActions(DateTime day, RecipeModel recipe) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.sheetSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.sheetHandle,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.open_with),
                title: const Text('Move'),
                onTap: () => Navigator.of(context).pop('move'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_repeat),
                title: const Text('Change day'),
                onTap: () => Navigator.of(context).pop('change_day'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remove'),
                onTap: () => Navigator.of(context).pop('remove'),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) return;

    if (action == 'remove') {
      setState(() {
        _plannedMeals.remove(_dateOnly(day));
      });
      return;
    }

    if (action == 'move' || action == 'change_day') {
      final destination = await _showDayPickerSheet(currentDay: day);
      if (!mounted || destination == null || _isSameDate(destination, day)) {
        return;
      }

      setState(() {
        _plannedMeals.remove(_dateOnly(day));
        _plannedMeals[_dateOnly(destination)] = recipe;
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

    return Scaffold(
      backgroundColor: AppColors.sageTop,
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragEnd: _onHorizontalDragEnd,
          child: CustomScrollView(
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
                      ? _WeekHeader(
                          key: const ValueKey('week-header-visible'),
                          weekRangeLabel: _weekRangeLabel(weekStart),
                          plannedCount: plannedCount,
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.inputBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Plan your week 🍽',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Add meals to generate a grocery list.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                sliver: SliverList.separated(
                  itemCount: days.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final planned = _plannedMeals[_dateOnly(day)];
                    final isToday = _isSameDate(day, _today);

                    return AnimatedSlide(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      offset: Offset(_weekContentSlideOffsetX, 0),
                      child: Container(
                        key: _dayKeys[index],
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isToday
                              ? AppColors.brandGreen.withOpacity(0.035)
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _weekdayUpper(day),
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
                                  Text(
                                    'Today',
                                    style: TextStyle(
                                      color: AppColors.brandGreen.withOpacity(
                                        0.9,
                                      ),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 10),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeOut,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.08),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: planned == null
                                  ? OutlinedButton.icon(
                                      key: ValueKey<String>(
                                        'empty-${day.toIso8601String()}',
                                      ),
                                      onPressed: () => _showAddMealSheet(day),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.brandGreen,
                                        side: BorderSide(
                                          color: AppColors.brandGreen
                                              .withOpacity(0.28),
                                        ),
                                        minimumSize: const Size.fromHeight(44),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add meal'),
                                    )
                                  : _MealCard(
                                      key: ValueKey<String>(
                                        'meal-${day.toIso8601String()}-${planned.id}',
                                      ),
                                      recipe: planned,
                                      onTap: () => _openRecipe(planned),
                                      onLongPress: () =>
                                          _showMealActions(day, planned),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    MediaQuery.of(context).padding.bottom + 18,
                  ),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    opacity: _showBottomGroceryButton ? 1 : 0,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      offset: _showBottomGroceryButton
                          ? Offset.zero
                          : const Offset(0, 0.06),
                      child: IgnorePointer(
                        ignoring: !_showBottomGroceryButton,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _generateGroceryList,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandGreen,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.shopping_cart_outlined),
                            label: const Text(
                              'Generate Grocery List',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({
    super.key,
    required this.weekRangeLabel,
    required this.plannedCount,
    required this.labelDirection,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  final String weekRangeLabel;
  final int plannedCount;
  final int labelDirection;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sageTop,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Week',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeOut,
                    transitionBuilder: (child, animation) {
                      final beginOffset = Offset(
                        labelDirection > 0 ? 0.18 : -0.18,
                        0,
                      );
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: beginOffset,
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      weekRangeLabel,
                      key: ValueKey<String>(weekRangeLabel),
                      style: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.95),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$plannedCount / 7 days planned',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: onPreviousWeek,
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.brandGreen.withOpacity(0.70),
                  ),
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  onPressed: onNextWeek,
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.brandGreen.withOpacity(0.70),
                  ),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.onLongPress,
  });

  final RecipeModel recipe;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.inputBorderSoft),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.brandGreen.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(recipe.icon, color: AppColors.brandGreen, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '⏱ ${recipe.duration} • ${recipe.difficulty}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary.withOpacity(0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
