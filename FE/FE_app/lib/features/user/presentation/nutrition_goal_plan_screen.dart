part of '../../../app.dart';

class NutritionGoalPlanScreen extends StatefulWidget {
  const NutritionGoalPlanScreen({super.key, this.initialGoal, this.repository});

  final NutritionGoal? initialGoal;
  final UserRepository? repository;

  @override
  State<NutritionGoalPlanScreen> createState() =>
      _NutritionGoalPlanScreenState();
}

class _NutritionGoalPlanScreenState extends State<NutritionGoalPlanScreen> {
  static const _previewDelay = Duration(milliseconds: 450);

  final _targetWeightController = TextEditingController();
  final _durationController = TextEditingController();
  final _dailyCaloriesController = TextEditingController();

  String _goalType = 'MAINTAIN';
  Map<String, dynamic>? _healthProfile;
  NutritionGoalPreview? _preview;
  NutritionGoal? _savedGoal;
  Timer? _previewTimer;
  CancelToken? _previewCancelToken;
  Map<String, String> _fieldErrors = const {};
  String? _serverError;
  bool _loading = true;
  bool _previewing = false;
  bool _saving = false;
  bool _redirecting = false;
  bool _initializing = true;
  bool _saved = false;
  int _previewGeneration = 0;

  UserRepository get _repository =>
      widget.repository ?? AuthDependencies.instance.userRepository;

  @override
  void initState() {
    super.initState();
    _targetWeightController.addListener(_onInputChanged);
    _durationController.addListener(_onInputChanged);
    _dailyCaloriesController.addListener(_onInputChanged);
    _load();
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    _previewCancelToken?.cancel('Nutrition goal form disposed');
    _targetWeightController.dispose();
    _durationController.dispose();
    _dailyCaloriesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final healthProfile = await _repository.getHealthProfile();
      if (!mounted) return;
      if (healthProfile == null) {
        _redirectToHealthSetup();
        return;
      }

      final goal = widget.initialGoal ?? await _repository.getNutritionGoal();
      _healthProfile = healthProfile;
      _goalType = goal.isConfigured ? goal.goalType ?? 'MAINTAIN' : 'MAINTAIN';
      if (_goalType != 'MAINTAIN') {
        _targetWeightController.text = _editableNumber(goal.targetWeight);
        _durationController.text = goal.durationWeeks?.toString() ?? '';
      }
      final hasOverride =
          goal.dailyCaloriesGoal != null &&
          goal.recommendedCalories != null &&
          (goal.dailyCaloriesGoal! - goal.recommendedCalories!).abs() > .01;
      if (hasOverride) {
        _dailyCaloriesController.text = _editableNumber(goal.dailyCaloriesGoal);
      }
      _initializing = false;
      setState(() => _loading = false);
      _schedulePreview();
    } on ApiException catch (error) {
      if (!mounted) return;
      _initializing = false;
      setState(() {
        _loading = false;
        _serverError = error.message;
      });
    }
  }

  void _redirectToHealthSetup() {
    if (_redirecting || !mounted) return;
    _redirecting = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LifestyleScreen(
            completeDestination: NutritionGoalPlanScreen(),
          ),
        ),
      );
    });
  }

  void _onInputChanged() {
    if (_initializing) return;
    _saved = false;
    _savedGoal = null;
    _schedulePreview();
  }

  void _selectGoalType(Set<String> values) {
    final selected = values.first;
    if (selected == _goalType) return;
    setState(() {
      _goalType = selected;
      _saved = false;
      _savedGoal = null;
      _preview = null;
      _serverError = null;
      if (_goalType == 'MAINTAIN') {
        _targetWeightController.clear();
        _durationController.clear();
      }
    });
    _schedulePreview();
  }

  void _schedulePreview() {
    _previewTimer?.cancel();
    _previewCancelToken?.cancel('Superseded by newer form input');
    final errors = _validate();
    if (mounted) {
      setState(() {
        _fieldErrors = errors;
        _serverError = null;
        if (errors.isNotEmpty) {
          _preview = null;
          _previewing = false;
        }
      });
    }
    if (errors.isNotEmpty || _loading) return;
    _previewTimer = Timer(_previewDelay, _requestPreview);
  }

  Map<String, String> _validate() {
    final errors = <String, String>{};
    final dailyCalories = _optionalDouble(_dailyCaloriesController.text);
    if (_dailyCaloriesController.text.trim().isNotEmpty &&
        (dailyCalories == null || dailyCalories <= 0)) {
      errors['dailyCalories'] = 'Calories phải là số lớn hơn 0.';
    }

    if (_goalType == 'MAINTAIN') return errors;

    final currentWeight = _asDouble(_healthProfile?['weight']);
    final height = _asDouble(_healthProfile?['height']);
    final targetWeight = _optionalDouble(_targetWeightController.text);
    final durationWeeks = int.tryParse(_durationController.text.trim());

    if (targetWeight == null || targetWeight < 10 || targetWeight > 300) {
      errors['targetWeight'] = 'Cân nặng mục tiêu phải từ 10 đến 300 kg.';
    } else if (currentWeight != null) {
      if (_goalType == 'LOSE_WEIGHT' && targetWeight >= currentWeight) {
        errors['targetWeight'] =
            'Mục tiêu giảm cân phải thấp hơn cân nặng hiện tại.';
      }
      if (_goalType == 'GAIN_WEIGHT' && targetWeight <= currentWeight) {
        errors['targetWeight'] =
            'Mục tiêu tăng cân phải cao hơn cân nặng hiện tại.';
      }
      if (height != null && height > 0) {
        final bmi = targetWeight / ((height / 100) * (height / 100));
        if (bmi < 16 || bmi > 35) {
          errors['targetWeight'] =
              'BMI mục tiêu phải nằm trong khoảng 16 đến 35.';
        }
      }
    }

    if (durationWeeks == null || durationWeeks < 1 || durationWeeks > 520) {
      errors['durationWeeks'] = 'Thời gian phải từ 1 đến 520 tuần.';
    } else if (targetWeight != null && currentWeight != null) {
      final weeklyRate = (targetWeight - currentWeight).abs() / durationWeeks;
      if (weeklyRate < .25 || weeklyRate > 1) {
        errors['durationWeeks'] =
            'Điều chỉnh thời gian để tốc độ đạt 0,25-1 kg/tuần.';
      }
    }

    if (dailyCalories != null &&
        _preview?.bmr != null &&
        dailyCalories < _preview!.bmr!) {
      errors['dailyCalories'] =
          'Mục tiêu calories không được thấp hơn BMR (${_formatNumber(_preview!.bmr)} kcal).';
    }
    return errors;
  }

  Future<bool> _requestPreview() async {
    final generation = ++_previewGeneration;
    final cancelToken = CancelToken();
    _previewCancelToken = cancelToken;
    if (mounted) setState(() => _previewing = true);

    try {
      final preview = await _repository.previewNutritionGoal(
        goalType: _goalType,
        targetWeight: _goalType == 'MAINTAIN'
            ? _asDouble(_healthProfile?['weight'])
            : _optionalDouble(_targetWeightController.text),
        durationWeeks: _goalType == 'MAINTAIN'
            ? null
            : int.tryParse(_durationController.text.trim()),
        dailyCaloriesGoal: _optionalDouble(_dailyCaloriesController.text),
        cancelToken: cancelToken,
      );
      if (!mounted || generation != _previewGeneration) return false;
      setState(() {
        _preview = preview;
        _previewing = false;
        _serverError = null;
        _fieldErrors = _validate();
      });
      return true;
    } on DioException catch (error) {
      if (!CancelToken.isCancel(error) && mounted) {
        setState(() {
          _preview = null;
          _previewing = false;
          _serverError = 'Không thể tải bản xem trước.';
        });
      }
      return false;
    } on ApiException catch (error) {
      if (!mounted || generation != _previewGeneration) return false;
      setState(() {
        _preview = null;
        _previewing = false;
        _serverError = error.message;
        _applyServerFieldError(error.message);
      });
      return false;
    }
  }

  void _applyServerFieldError(String message) {
    final next = Map<String, String>.of(_fieldErrors);
    final lower = message.toLowerCase();
    if (lower.contains('bmr') || lower.contains('calories')) {
      next['dailyCalories'] = message;
    } else if (lower.contains('bmi') || lower.contains('target weight')) {
      next['targetWeight'] = message;
    } else if (lower.contains('weekly rate') || lower.contains('duration')) {
      next['durationWeeks'] = message;
    }
    _fieldErrors = next;
  }

  Future<void> _save() async {
    final errors = _validate();
    if (errors.isNotEmpty) {
      setState(() => _fieldErrors = errors);
      return;
    }

    _previewTimer?.cancel();
    final previewSucceeded = await _requestPreview();
    if (!mounted ||
        !previewSucceeded ||
        _preview == null ||
        _fieldErrors.isNotEmpty) {
      return;
    }

    setState(() {
      _saving = true;
      _serverError = null;
    });
    try {
      final goal = await _repository.saveNutritionGoal(
        goalType: _goalType,
        targetWeight: _goalType == 'MAINTAIN'
            ? _asDouble(_healthProfile?['weight'])
            : _optionalDouble(_targetWeightController.text),
        durationWeeks: _goalType == 'MAINTAIN'
            ? null
            : int.tryParse(_durationController.text.trim()),
        dailyCaloriesGoal: _optionalDouble(_dailyCaloriesController.text),
      );
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saved = true;
        _savedGoal = goal;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _serverError = error.message;
        _applyServerFieldError(error.message);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        title: const Text('Kế hoạch mục tiêu'),
        leading: IconButton(
          tooltip: 'Quay lại',
          onPressed: () => Navigator.pop(context, _saved),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: _loading || _redirecting
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.green),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 118),
              children: [
                _buildCurrentProfileSummary(),
                const SizedBox(height: 22),
                const Text(
                  'Loại mục tiêu',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'MAINTAIN',
                      label: Text('Duy trì'),
                      icon: Icon(Icons.balance),
                    ),
                    ButtonSegment(
                      value: 'LOSE_WEIGHT',
                      label: Text('Giảm'),
                      icon: Icon(Icons.trending_down),
                    ),
                    ButtonSegment(
                      value: 'GAIN_WEIGHT',
                      label: Text('Tăng'),
                      icon: Icon(Icons.trending_up),
                    ),
                  ],
                  selected: {_goalType},
                  onSelectionChanged: _saving ? null : _selectGoalType,
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity(vertical: 1),
                  ),
                ),
                if (_goalType != 'MAINTAIN') ...[
                  const SizedBox(height: 22),
                  _numberField(
                    controller: _targetWeightController,
                    label: 'Cân nặng mục tiêu',
                    suffix: 'kg',
                    errorText: _fieldErrors['targetWeight'],
                  ),
                  const SizedBox(height: 14),
                  _numberField(
                    controller: _durationController,
                    label: 'Thời gian thực hiện',
                    suffix: 'tuần',
                    integer: true,
                    errorText: _fieldErrors['durationWeeks'],
                  ),
                ],
                const SizedBox(height: 22),
                _numberField(
                  controller: _dailyCaloriesController,
                  label: 'Mục tiêu calories của bạn (không bắt buộc)',
                  suffix: 'kcal',
                  hint: 'Để trống để dùng mức hệ thống gợi ý',
                  errorText: _fieldErrors['dailyCalories'],
                ),
                const SizedBox(height: 22),
                _buildPreview(),
                if (_serverError != null) ...[
                  const SizedBox(height: 14),
                  ApiMessageBanner(message: _serverError!, isError: true),
                ],
                if (_saved) ...[
                  const SizedBox(height: 14),
                  const ApiMessageBanner(
                    message: 'Đã lưu kế hoạch dinh dưỡng.',
                    isError: false,
                  ),
                ],
                if ((_savedGoal?.warnings ?? _preview?.warnings ?? const [])
                    .isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _NutritionGoalWarningBanner(
                    warnings:
                        _savedGoal?.warnings ?? _preview?.warnings ?? const [],
                  ),
                ],
              ],
            ),
      bottomNavigationBar: _loading || _redirecting
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(18, 10, 18, 18),
              child: SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_saving ? 'Đang lưu...' : 'Lưu mục tiêu'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCurrentProfileSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.monitor_weight_outlined, color: AppColors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Hiện tại: ${_formatNumber(_asDouble(_healthProfile?['weight']))} kg · '
              '${_formatNumber(_asDouble(_healthProfile?['height']))} cm',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    String? hint,
    String? errorText,
    bool integer = false,
  }) {
    return TextField(
      controller: controller,
      enabled: !_saving,
      keyboardType: TextInputType.numberWithOptions(decimal: !integer),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          integer ? RegExp(r'[0-9]') : RegExp(r'[0-9.,]'),
        ),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        errorText: errorText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildPreview() {
    if (_previewing) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(color: AppColors.green)),
      );
    }
    final preview = _preview;
    if (preview == null) {
      return const Text(
        'Nhập kế hoạch hợp lệ để xem tốc độ, calories và macro dự kiến.',
        style: TextStyle(color: AppColors.muted, height: 1.4),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kết quả dự kiến',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 18,
            runSpacing: 14,
            children: [
              _previewMetric('Tốc độ', preview.weeklyRateKg, 'kg/tuần'),
              _previewMetric('BMR', preview.bmr, 'kcal'),
              _previewMetric(
                'Calories gợi ý',
                preview.recommendedCalories,
                'kcal',
              ),
              _previewMetric(
                'Calories áp dụng',
                preview.dailyCaloriesGoal,
                'kcal',
              ),
              _previewMetric('Đạm', preview.protein, 'g'),
              _previewMetric('Tinh bột', preview.carbs, 'g'),
              _previewMetric('Chất béo', preview.fat, 'g'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _previewMetric(String label, double? value, String unit) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 3),
          Text(
            '${_formatNumber(value)} $unit',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

double? _optionalDouble(String value) {
  final normalized = value.trim().replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}

String _editableNumber(double? value) {
  if (value == null) return '';
  return value == value.roundToDouble()
      ? value.round().toString()
      : value
            .toStringAsFixed(2)
            .replaceFirst(RegExp(r'0+$'), '')
            .replaceFirst(RegExp(r'\.$'), '');
}
