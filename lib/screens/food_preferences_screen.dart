import 'package:flutter/material.dart';
import 'package:grocery_list/models/food_preferences_model.dart';
import 'package:grocery_list/repositories/food_preferences_repository.dart';
import 'package:grocery_list/theme/app_colors.dart';

class FoodPreferencesScreen extends StatefulWidget {
  const FoodPreferencesScreen({super.key});

  @override
  State<FoodPreferencesScreen> createState() => _FoodPreferencesScreenState();
}

class _FoodPreferencesScreenState extends State<FoodPreferencesScreen> {
  static const List<String> _dietOptions = [
    'Omnivore',
    'Vegetarian',
    'Vegan',
    'Pescatarian',
    'Keto',
    'Paleo',
    'Halal',
    'Kosher',
  ];

  static const List<String> _allergyOptions = [
    'Peanuts',
    'Tree Nuts',
    'Dairy',
    'Eggs',
    'Gluten',
    'Soy',
    'Shellfish',
    'Fish',
    'Sesame',
  ];

  final FoodPreferencesRepository _repository = FoodPreferencesRepository();
  final TextEditingController _dislikeController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _selectedDietType;
  Set<String> _selectedAllergies = <String>{};
  List<String> _dislikes = <String>[];
  FoodPreferences _lastSavedPreferences = const FoodPreferences();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _dislikeController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final preferences = await _repository.load();
    if (!mounted) return;

    final normalizedDislikes = <String>[];
    final seen = <String>{};
    for (final dislike in preferences.dislikes) {
      final normalized = _normalizeDislike(dislike);
      if (normalized.isEmpty || seen.contains(normalized)) {
        continue;
      }
      seen.add(normalized);
      normalizedDislikes.add(normalized);
    }

    final normalizedPreferences = FoodPreferences(
      dietType: preferences.dietType,
      allergies: List<String>.from(preferences.allergies),
      dislikes: normalizedDislikes,
    );

    setState(() {
      _lastSavedPreferences = normalizedPreferences;
      _selectedDietType = normalizedPreferences.dietType;
      _selectedAllergies = normalizedPreferences.allergies.toSet();
      _dislikes = List<String>.from(normalizedPreferences.dislikes);
      _isLoading = false;
    });
  }

  FoodPreferences _buildCurrentPreferences() {
    final allergies = _selectedAllergies.toList(growable: false)..sort();
    return FoodPreferences(
      dietType: _selectedDietType,
      allergies: allergies,
      dislikes: List<String>.from(_dislikes),
    );
  }

  bool get _isDirty {
    return !_arePreferencesEqual(
      _lastSavedPreferences,
      _buildCurrentPreferences(),
    );
  }

  bool _arePreferencesEqual(FoodPreferences a, FoodPreferences b) {
    if (a.dietType != b.dietType) {
      return false;
    }

    if (a.allergies.length != b.allergies.length) {
      return false;
    }

    final allergiesA = {...a.allergies};
    final allergiesB = {...b.allergies};
    if (allergiesA.length != allergiesB.length ||
        !allergiesA.containsAll(allergiesB)) {
      return false;
    }

    if (a.dislikes.length != b.dislikes.length) {
      return false;
    }

    for (var i = 0; i < a.dislikes.length; i++) {
      if (a.dislikes[i] != b.dislikes[i]) {
        return false;
      }
    }

    return true;
  }

  String _normalizeDislike(String value) => value.trim().toLowerCase();

  String _displayDislike(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  void _addDislike() {
    final dislike = _dislikeController.text.trim();
    if (dislike.isEmpty) {
      return;
    }

    final normalizedDislike = _normalizeDislike(dislike);
    final hasDuplicate = _dislikes.any(
      (existing) => _normalizeDislike(existing) == normalizedDislike,
    );

    if (hasDuplicate) {
      _dislikeController.clear();
      return;
    }

    setState(() {
      _dislikes = [..._dislikes, normalizedDislike];
      _dislikeController.clear();
    });
  }

  void _removeDislike(String dislike) {
    setState(() {
      _dislikes = _dislikes.where((entry) => entry != dislike).toList();
    });
  }

  Future<void> _savePreferences() async {
    if (_isSaving || !_isDirty) return;

    setState(() {
      _isSaving = true;
    });

    final preferences = _buildCurrentPreferences();

    await _repository.save(preferences);
    if (!mounted) return;

    setState(() {
      _lastSavedPreferences = preferences;
      _isSaving = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Preferences saved')));
    Navigator.of(context).pop(true);
  }

  Future<bool> _confirmDiscardIfNeeded() async {
    if (!_isDirty || _isSaving) {
      return true;
    }

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Discard changes?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep Editing'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Discard'),
            ),
          ],
        );
      },
    );

    return shouldDiscard ?? false;
  }

  Future<void> _handleBackPressed() async {
    final canPop = await _confirmDiscardIfNeeded();
    if (!mounted || !canPop) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const primaryColor = AppColors.primary;

    return WillPopScope(
      onWillPop: _confirmDiscardIfNeeded,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 144,
              backgroundColor: AppColors.surface,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              leading: IconButton(
                onPressed: _handleBackPressed,
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    disabledForegroundColor: AppColors.disabledFg,
                  ),
                  onPressed: _isLoading || _isSaving || !_isDirty
                      ? null
                      : _savePreferences,
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        )
                      : const Text('Save'),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 52, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Food Preferences',
                          style: textTheme.headlineSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'We use this to personalize recipes and meal plans.',
                          maxLines: 2,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  24,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Diet Type',
                              style: textTheme.titleMedium?.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (_selectedDietType != null)
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedDietType = null;
                                });
                              },
                              child: const Text('Clear'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final diet in _dietOptions)
                            ChoiceChip(
                              label: Text(diet),
                              selected: _selectedDietType == diet,
                              selectedColor: primaryColor.withOpacity(0.12),
                              showCheckmark: true,
                              checkmarkColor: primaryColor,
                              side: BorderSide(
                                color: _selectedDietType == diet
                                    ? primaryColor
                                    : AppColors.inputBorder,
                              ),
                              labelStyle: TextStyle(
                                color: _selectedDietType == diet
                                    ? primaryColor
                                    : AppColors.textPrimary,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  _selectedDietType = selected ? diet : null;
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Allergies & Intolerances',
                              style: textTheme.titleMedium?.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (_selectedAllergies.isNotEmpty)
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedAllergies.clear();
                                });
                              },
                              child: const Text('Clear'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final allergy in _allergyOptions)
                            FilterChip(
                              label: Text(allergy),
                              selected: _selectedAllergies.contains(allergy),
                              selectedColor: primaryColor.withOpacity(0.12),
                              showCheckmark: true,
                              checkmarkColor: primaryColor,
                              side: BorderSide(
                                color: _selectedAllergies.contains(allergy)
                                    ? primaryColor
                                    : AppColors.inputBorder,
                              ),
                              labelStyle: TextStyle(
                                color: _selectedAllergies.contains(allergy)
                                    ? primaryColor
                                    : AppColors.textPrimary,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedAllergies.add(allergy);
                                  } else {
                                    _selectedAllergies.remove(allergy);
                                  }
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Dislikes',
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _dislikeController,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _addDislike(),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.inputBg,
                                hintText: 'Add a dislike',
                                hintStyle: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.inputBorder,
                                  ),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.inputBorder,
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.focusGreen,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              disabledBackgroundColor: AppColors.disabledBg,
                              disabledForegroundColor: AppColors.disabledFg,
                            ),
                            onPressed: _addDislike,
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_dislikes.isEmpty)
                        Text(
                          'Add ingredients or dishes you want to avoid.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _dislikes
                              .map(
                                (dislike) => Chip(
                                  label: Text(_displayDislike(dislike)),
                                  labelStyle: const TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                  backgroundColor: AppColors.surface,
                                  side: const BorderSide(
                                    color: AppColors.inputBorder,
                                  ),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () => _removeDislike(dislike),
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
