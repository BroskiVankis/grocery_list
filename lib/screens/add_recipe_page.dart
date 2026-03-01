import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../models/recipe_model.dart';
import '../theme/app_colors.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _servingsController = TextEditingController();
  final TextEditingController _tagInputController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _sourceLinkController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _servingsFocusNode = FocusNode();
  final FocusNode _tagInputFocusNode = FocusNode();

  String _difficulty = 'Easy';
  final List<String> _tags = <String>[];
  int _prepTimeMinutes = 20;
  bool _compressHeader = false;
  bool _showIngredientValidation = false;
  int _ingredientShakeTick = 0;
  final Set<TextEditingController> _newIngredientControllers =
      <TextEditingController>{};
  final Set<TextEditingController> _removingIngredientControllers =
      <TextEditingController>{};

  final List<TextEditingController> _ingredientControllers =
      <TextEditingController>[];
  final List<FocusNode> _ingredientFocusNodes = <FocusNode>[];

  final List<TextEditingController> _stepControllers =
      <TextEditingController>[];
  final List<FocusNode> _stepFocusNodes = <FocusNode>[];

  @override
  void initState() {
    super.initState();
    _servingsController.text = '2';
    _nameController.addListener(_onNameChanged);
    _scrollController.addListener(_onScroll);
    _addIngredientRow(requestFocus: false);
    _addStepRow(requestFocus: false);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _nameController.dispose();
    _servingsController.dispose();
    _tagInputController.dispose();
    _notesController.dispose();
    _sourceLinkController.dispose();
    _nameFocusNode.dispose();
    _servingsFocusNode.dispose();
    _tagInputFocusNode.dispose();

    for (final controller in _ingredientControllers) {
      controller.dispose();
    }
    for (final node in _ingredientFocusNodes) {
      node.dispose();
    }

    for (final controller in _stepControllers) {
      controller.dispose();
    }
    for (final node in _stepFocusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  void _onNameChanged() {
    setState(() {});
  }

  void _onScroll() {
    final nextCompress =
        _scrollController.hasClients && _scrollController.offset > 24;
    if (nextCompress == _compressHeader) return;
    setState(() {
      _compressHeader = nextCompress;
    });
  }

  Future<void> _onNameSubmitted() async {
    await _pickPrepTime(
      onDone: () {
        if (!mounted) return;
        _servingsFocusNode.requestFocus();
      },
    );
  }

  void _addIngredientRow({bool requestFocus = true}) {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    setState(() {
      _ingredientControllers.add(controller);
      _ingredientFocusNodes.add(focusNode);
      _newIngredientControllers.add(controller);
      _showIngredientValidation = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_newIngredientControllers.contains(controller)) {
        setState(() {
          _newIngredientControllers.remove(controller);
        });
      }
    });

    if (requestFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        focusNode.requestFocus();
      });
    }
  }

  void _addStepRow({bool requestFocus = true}) {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    setState(() {
      _stepControllers.add(controller);
      _stepFocusNodes.add(focusNode);
    });

    if (requestFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        focusNode.requestFocus();
      });
    }
  }

  void _onIngredientSubmitted(int index) {
    if (index == _ingredientControllers.length - 1) {
      _addIngredientRow();
      return;
    }
    _ingredientFocusNodes[index + 1].requestFocus();
  }

  Future<void> _removeIngredientRow(int index) async {
    if (_ingredientControllers.length == 1) {
      _ingredientControllers[index].clear();
      _ingredientFocusNodes[index].requestFocus();
      return;
    }

    final controller = _ingredientControllers[index];
    final focusNode = _ingredientFocusNodes[index];

    setState(() {
      _removingIngredientControllers.add(controller);
    });

    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    final currentIndex = _ingredientControllers.indexOf(controller);
    if (currentIndex == -1) return;

    setState(() {
      _ingredientControllers.removeAt(currentIndex);
      _ingredientFocusNodes.removeAt(currentIndex);
      _removingIngredientControllers.remove(controller);
      _newIngredientControllers.remove(controller);
    });

    controller.dispose();
    focusNode.dispose();
  }

  void _onStepSubmitted(int index) {
    if (index == _stepControllers.length - 1) {
      _addStepRow();
      return;
    }
    _stepFocusNodes[index + 1].requestFocus();
  }

  void _removeStepRow(int index) {
    if (_stepControllers.length == 1) {
      _stepControllers[index].clear();
      _stepFocusNodes[index].requestFocus();
      return;
    }

    final controller = _stepControllers.removeAt(index);
    final focusNode = _stepFocusNodes.removeAt(index);
    controller.dispose();
    focusNode.dispose();
    setState(() {});
  }

  void _addTagFromInput() {
    final rawTag = _tagInputController.text.trim();
    if (rawTag.isEmpty) return;

    final lower = rawTag.toLowerCase();
    final alreadyExists = _tags.any((tag) => tag.toLowerCase() == lower);
    if (!alreadyExists) {
      setState(() {
        _tags.add(rawTag);
      });
    }
    _tagInputController.clear();
    _tagInputFocusNode.requestFocus();
  }

  void _onTagSubmitted() {
    _addTagFromInput();
    _focusFirstIngredient();
  }

  void _focusFirstIngredient() {
    if (_ingredientFocusNodes.isEmpty) {
      _addIngredientRow();
      return;
    }
    _ingredientFocusNodes.first.requestFocus();
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  bool get _isSaveEnabled => _nameController.text.trim().isNotEmpty;

  int get _prepHours => _prepTimeMinutes ~/ 60;
  int get _prepMinutePart => _prepTimeMinutes % 60;

  int _defaultMinutesForDifficulty() {
    switch (_difficulty) {
      case 'Medium':
        return 35;
      case 'Hard':
        return 60;
      default:
        return 20;
    }
  }

  String get _prepTimeLabel {
    if (_prepHours == 0) {
      return '$_prepMinutePart min';
    }
    if (_prepMinutePart == 0) {
      return '$_prepHours h';
    }
    return '$_prepHours h $_prepMinutePart min';
  }

  Future<void> _pickPrepTime({VoidCallback? onDone}) async {
    const commonMinuteStops = <int>{0, 5, 10, 15, 20, 25, 30, 45};
    const maxHours = 3;
    final previousMinutes = _prepTimeMinutes;
    final defaultMinutes = _defaultMinutesForDifficulty();

    if (defaultMinutes != _prepTimeMinutes) {
      setState(() {
        _prepTimeMinutes = defaultMinutes;
      });
    }

    if (_prepTimeMinutes > maxHours * 60 + 59) {
      setState(() {
        _prepTimeMinutes = maxHours * 60 + 59;
      });
    }

    var draftTotalMinutes = _prepTimeMinutes;
    var wasCancelled = false;

    final minuteWheelValues = List<int>.generate(60, (index) => index);

    final initialHour = (draftTotalMinutes ~/ 60).clamp(0, maxHours);
    final initialMinute = draftTotalMinutes % 60;

    final hourController = FixedExtentScrollController(
      initialItem: initialHour,
    );
    final minuteController = FixedExtentScrollController(
      initialItem: minuteWheelValues.indexOf(initialMinute),
    );

    await showModalBottomSheet<void>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.58,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        wasCancelled = true;
                        setState(() {
                          _prepTimeMinutes = previousMinutes;
                        });
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    const Spacer(),
                    Text(
                      'Prep Time',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 4),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: Text(
                    _prepTimeLabel,
                    key: ValueKey(_prepTimeLabel),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
                child: Row(
                  children: const [
                    Expanded(
                      flex: 35,
                      child: Text(
                        'Hours',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 65,
                      child: Text(
                        'Minutes',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 35,
                        child: CupertinoPicker(
                          scrollController: hourController,
                          itemExtent: 44,
                          selectionOverlay:
                              const CupertinoPickerDefaultSelectionOverlay(),
                          onSelectedItemChanged: (index) {
                            final nextTotal =
                                (index * 60) + (draftTotalMinutes % 60);
                            if (nextTotal == draftTotalMinutes) return;
                            draftTotalMinutes = nextTotal;
                            HapticFeedback.selectionClick();
                            setState(() {
                              _prepTimeMinutes = draftTotalMinutes;
                            });
                          },
                          children: List<Widget>.generate(
                            maxHours + 1,
                            (index) => Center(
                              child: SizedBox(
                                width: double.infinity,
                                child: Text(
                                  '$index h',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 65,
                        child: CupertinoPicker(
                          scrollController: minuteController,
                          itemExtent: 44,
                          selectionOverlay:
                              const CupertinoPickerDefaultSelectionOverlay(),
                          onSelectedItemChanged: (index) {
                            final minuteValue = minuteWheelValues[index];
                            final nextTotal =
                                ((draftTotalMinutes ~/ 60) * 60) + minuteValue;
                            if (nextTotal == draftTotalMinutes) return;
                            draftTotalMinutes = nextTotal;
                            HapticFeedback.selectionClick();
                            setState(() {
                              _prepTimeMinutes = draftTotalMinutes;
                            });
                          },
                          children: minuteWheelValues.map((minute) {
                            final isCommon = commonMinuteStops.contains(minute);
                            return Center(
                              child: SizedBox(
                                width: double.infinity,
                                child: Text(
                                  '$minute min',
                                  style: TextStyle(
                                    fontWeight: isCommon
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    hourController.dispose();
    minuteController.dispose();

    if (!wasCancelled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onDone?.call();
      });
    }
  }

  InputDecoration _inputDecoration(String hint, {Color? enabledBorderColor}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.inputBg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: enabledBorderColor ?? AppColors.inputBorderSoft,
          width: enabledBorderColor == null ? 1 : 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: enabledBorderColor ?? AppColors.brandGreen,
          width: 1.8,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  String? _formatIngredientPreview(String rawText) {
    final value = rawText.trim();
    if (value.isEmpty) return null;

    final parts = value.split(RegExp(r'\s+'));
    final startsWithAmount = RegExp(r'^[\d¼½¾⅓⅔/.,]+$').hasMatch(parts.first);
    if (!startsWithAmount || parts.length < 2) return null;

    if (parts.length >= 3) {
      return '${parts.take(2).join(' ')} • ${parts.skip(2).join(' ')}';
    }
    return '${parts.first} • ${parts.last}';
  }

  void _saveRecipe() {
    final title = _nameController.text.trim();
    final ingredients = _ingredientControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
    final instructions = _stepControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (title.isEmpty) {
      return;
    }

    if (ingredients.isEmpty) {
      setState(() {
        _showIngredientValidation = true;
        _ingredientShakeTick++;
      });
      _focusFirstIngredient();
      return;
    }

    if (instructions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least 1 instruction step')),
      );
      return;
    }

    final servings = int.tryParse(_servingsController.text.trim()) ?? 1;
    final recipe = RecipeModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      duration: _prepTimeLabel,
      difficulty: _difficulty,
      servings: servings,
      tags: _tags,
      ingredients: ingredients,
      instructions: instructions,
      icon: Icons.restaurant_menu,
      notes: _notesController.text.trim(),
    );

    Navigator.of(context).pop(recipe);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.sageTop,
      appBar: AppBar(
        backgroundColor: AppColors.sageTop,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Add Recipe'),
      ),
      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: keyboardInset),
        child: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            opacity: _isSaveEnabled ? 1 : 0.60,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              scale: _isSaveEnabled ? 1 : 0.98,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandGreen,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.disabledBg,
                  disabledForegroundColor: AppColors.disabledFg,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                ),
                onPressed: _isSaveEnabled ? _saveRecipe : null,
                child: const Text('Save Recipe'),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        controller: _scrollController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 108),
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            scale: _compressHeader ? 0.98 : 1,
            alignment: Alignment.topCenter,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.brandGreen.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: AppColors.brandGreen,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _onNameSubmitted(),
                    decoration: _inputDecoration('Recipe name'),
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 420;

                      final timeField = _LabeledField(
                        label: 'Time',
                        child: InkWell(
                          onTap: _pickPrepTime,
                          borderRadius: BorderRadius.circular(14),
                          child: InputDecorator(
                            decoration: _inputDecoration('20 min'),
                            child: Text(
                              _prepTimeLabel,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );

                      final difficultyField = _LabeledField(
                        label: 'Difficulty',
                        child: DropdownButtonFormField<String>(
                          value: _difficulty,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          decoration: _inputDecoration('Difficulty'),
                          items: const [
                            DropdownMenuItem(
                              value: 'Easy',
                              child: Text('Easy'),
                            ),
                            DropdownMenuItem(
                              value: 'Medium',
                              child: Text('Medium'),
                            ),
                            DropdownMenuItem(
                              value: 'Hard',
                              child: Text('Hard'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _difficulty = value;
                            });
                          },
                        ),
                      );

                      final servingsField = _LabeledField(
                        label: 'Servings',
                        child: TextField(
                          controller: _servingsController,
                          focusNode: _servingsFocusNode,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) {
                            _tagInputFocusNode.requestFocus();
                          },
                          decoration: _inputDecoration('2'),
                        ),
                      );

                      if (isCompact) {
                        return Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: timeField),
                                const SizedBox(width: 8),
                                Expanded(child: difficultyField),
                              ],
                            ),
                            const SizedBox(height: 8),
                            servingsField,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: timeField),
                          const SizedBox(width: 8),
                          Expanded(child: difficultyField),
                          const SizedBox(width: 8),
                          Expanded(child: servingsField),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Tags',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      for (final tag in _tags)
                        Chip(
                          label: Text(tag),
                          onDeleted: () => _removeTag(tag),
                          backgroundColor: AppColors.brandGreen.withOpacity(
                            0.10,
                          ),
                          side: BorderSide(
                            color: AppColors.brandGreen.withOpacity(0.18),
                          ),
                          deleteIconColor: AppColors.brandGreen,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 300;

                      final tagInput = TextField(
                        controller: _tagInputController,
                        focusNode: _tagInputFocusNode,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _onTagSubmitted(),
                        decoration: _inputDecoration('Add tag'),
                      );

                      final addTagButton = OutlinedButton.icon(
                        onPressed: _addTagFromInput,
                        icon: const Icon(Icons.add),
                        label: const Text('Add tag'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.brandGreen,
                          side: BorderSide(
                            color: AppColors.brandGreen.withOpacity(0.28),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      );

                      if (isCompact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            tagInput,
                            const SizedBox(height: 8),
                            addTagButton,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: tagInput),
                          const SizedBox(width: 8),
                          addTagButton,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Import Recipe',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Import from URL coming soon'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.link),
                      label: const Text('Import from URL'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.brandGreen,
                        side: BorderSide(
                          color: AppColors.brandGreen.withOpacity(0.28),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Paste Recipe Text coming soon'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.paste),
                          label: const Text('Paste Text'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.brandGreen,
                            side: BorderSide(
                              color: AppColors.brandGreen.withOpacity(0.28),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Scan Photo coming soon'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.document_scanner_outlined),
                          label: const Text('Scan Photo'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.brandGreen,
                            side: BorderSide(
                              color: AppColors.brandGreen.withOpacity(0.28),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Ingredients',
            child: Column(
              children: [
                for (var i = 0; i < _ingredientControllers.length; i++)
                  TweenAnimationBuilder<double>(
                    key: ValueKey(
                      'ingredient-$i-${_ingredientShakeTick}-${_ingredientControllers[i].hashCode}',
                    ),
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      final controller = _ingredientControllers[i];
                      final isRemoving = _removingIngredientControllers
                          .contains(controller);
                      final isNew = _newIngredientControllers.contains(
                        controller,
                      );
                      final isInvalid =
                          _showIngredientValidation &&
                          controller.text.trim().isEmpty;
                      final shake = isInvalid
                          ? math.sin(value * math.pi * 4) * 4 * (1 - value)
                          : 0.0;

                      return AnimatedSlide(
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        offset: isRemoving
                            ? const Offset(0.04, 0)
                            : (isNew ? const Offset(0, 0.08) : Offset.zero),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 160),
                          curve: Curves.easeOut,
                          opacity: isRemoving ? 0 : (isNew ? 0 : 1),
                          child: Transform.translate(
                            offset: Offset(shake, 0),
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 160),
                              curve: Curves.easeOut,
                              scale: isRemoving ? 0.96 : 1,
                              child: child,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _ingredientControllers[i],
                                  focusNode: _ingredientFocusNodes[i],
                                  textInputAction: TextInputAction.next,
                                  onChanged: (_) {
                                    if (_showIngredientValidation) {
                                      setState(() {});
                                    }
                                  },
                                  onSubmitted: (_) => _onIngredientSubmitted(i),
                                  decoration: _inputDecoration(
                                    'Ingredient',
                                    enabledBorderColor:
                                        _showIngredientValidation &&
                                            _ingredientControllers[i].text
                                                .trim()
                                                .isEmpty
                                        ? Colors.red.withOpacity(0.55)
                                        : null,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _removeIngredientRow(i),
                                icon: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                tooltip: 'Remove ingredient',
                              ),
                              const Icon(
                                Icons.drag_indicator,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                            ],
                          ),
                          Builder(
                            builder: (context) {
                              final preview = _formatIngredientPreview(
                                _ingredientControllers[i].text,
                              );
                              if (preview == null) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(top: 4, left: 4),
                                child: Text(
                                  preview,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _addIngredientRow,
                    icon: const Icon(Icons.add),
                    label: const Text('Add ingredient'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.brandGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Instructions',
            child: Column(
              children: [
                for (var i = 0; i < _stepControllers.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8, top: 12),
                          child: Text(
                            '${i + 1}.',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _stepControllers[i],
                            focusNode: _stepFocusNodes[i],
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) => _onStepSubmitted(i),
                            decoration: _inputDecoration('Step instruction'),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeStepRow(i),
                          icon: const Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          tooltip: 'Remove step',
                        ),
                      ],
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _addStepRow,
                    icon: const Icon(Icons.add),
                    label: const Text('Add step'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.brandGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Optional',
            child: Column(
              children: [
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  decoration: _inputDecoration('Notes'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _sourceLinkController,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  decoration: _inputDecoration('Source link'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
