part of '../../../app.dart';

class _HealthProfileSetupDraft {
  String height = '';
  String weight = '';
  String activityLevel = 'LIGHT';

  String calories = '';
  final Set<String> dietTypes = {};
  final Map<int, String> allergies = {};
  List<Map<String, dynamic>> allergenOptions = const [];

  Future<void> loadFromBackend() async {
    final dependencies = AuthDependencies.instance;

    final health = await dependencies.userRepository.getHealthProfile();
    final nutrition = await dependencies.userRepository.getNutritionGoal();
    final diets = await dependencies.userRepository.getDietPreferences();
    final savedAllergies = await dependencies.userRepository.getAllergies();
    allergenOptions = await dependencies.recipeRepository.getAllergens();

    height = _draftNumber(health?['height']);
    weight = _draftNumber(health?['weight']);
    activityLevel = health?['activityLevel']?.toString() ?? 'LIGHT';
    if (nutrition.isConfigured) {
      calories = _draftNumber(nutrition.dailyCaloriesGoal);
    } else {
      calories = '';
    }

    dietTypes
      ..clear()
      ..addAll(
        diets
            .map((item) => item['dietType']?.toString().toUpperCase())
            .whereType<String>(),
      );
    allergies.clear();
    for (final allergy in savedAllergies) {
      final allergenId = (allergy['allergenId'] as num?)?.toInt();
      if (allergenId != null) {
        allergies[allergenId] =
            allergy['severity']?.toString().toUpperCase() ?? 'MEDIUM';
      }
    }
  }

  static String _draftNumber(Object? value, {String fallback = ''}) {
    if (value is num) {
      return value == value.roundToDouble()
          ? value.toInt().toString()
          : value.toString();
    }
    return value?.toString() ?? fallback;
  }
}

final _healthProfileSetupDraft = _HealthProfileSetupDraft();

class LifestyleScreen extends StatefulWidget {
  const LifestyleScreen({
    super.key,
    this.completeDestination = const MainShell(),
  });

  final Widget completeDestination;

  @override
  State<LifestyleScreen> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends State<LifestyleScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadDraft();
  }

  Future<void> _loadDraft() async {
    await _healthProfileSetupDraft.loadFromBackend();
    _heightController.text = _healthProfileSetupDraft.height;
    _weightController.text = _healthProfileSetupDraft.weight;
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _OnboardingLoadingScreen();
        }
        if (snapshot.hasError) {
          return _OnboardingLoadErrorScreen(
            error: snapshot.error,
            onRetry: () => setState(() => _loadFuture = _loadDraft()),
          );
        }
        return _buildForm();
      },
    );
  }

  Widget _buildForm() {
    return OnboardingScaffold(
      step: 1,
      progress: .25,
      title: 'Chỉ số cơ thể',
      subtitle:
          'Nhập chiều cao và cân nặng để cập nhật hồ sơ sức khỏe trong user-service.',
      next: HealthStatusScreen(completeDestination: widget.completeDestination),
      children: [
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Chiều cao (cm)',
                hint: '170',
                compact: true,
                controller: _heightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (value) => _healthProfileSetupDraft.height = value,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                label: 'Cân nặng (kg)',
                hint: '65',
                compact: true,
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (value) => _healthProfileSetupDraft.weight = value,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const InfoPanel(
          title: 'Field API',
          text:
              'Health profile API chỉ nhận height, weight và activityLevel. Các ô tuổi, giới tính, quốc gia đã được bỏ khỏi flow này.',
        ),
      ],
    );
  }
}

class HealthStatusScreen extends StatefulWidget {
  const HealthStatusScreen({
    super.key,
    this.completeDestination = const MainShell(),
  });

  final Widget completeDestination;

  @override
  State<HealthStatusScreen> createState() => _HealthStatusScreenState();
}

class _HealthStatusScreenState extends State<HealthStatusScreen> {
  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'SEDENTARY',
        Icons.weekend_outlined,
        'Ít vận động',
        'Làm việc văn phòng, ít tập thể dục',
      ),
      (
        'LIGHT',
        Icons.directions_walk,
        'Vận động nhẹ',
        'Đi bộ nhẹ nhàng, 1-2 buổi/tuần',
      ),
      (
        'MODERATE',
        Icons.fitness_center_outlined,
        'Vận động vừa',
        'Tập luyện 3-5 ngày mỗi tuần',
      ),
      (
        'ACTIVE',
        Icons.flash_on_outlined,
        'Vận động nhiều',
        'Tập luyện nặng hoặc làm việc vận động',
      ),
      (
        'VERY_ACTIVE',
        Icons.local_fire_department_outlined,
        'Rất năng động',
        'Vận động viên hoặc lịch tập cường độ cao',
      ),
    ];

    return OnboardingScaffold(
      step: 2,
      progress: .50,
      title: 'Mức vận động',
      subtitle:
          'Chọn activityLevel đúng với enum backend: SEDENTARY, LIGHT, MODERATE, ACTIVE hoặc VERY_ACTIVE.',
      next: GoalsScreen(completeDestination: widget.completeDestination),
      children: [
        for (final item in items)
          ChoiceCard(
            icon: item.$2,
            title: item.$3,
            subtitle: item.$4,
            selected: _healthProfileSetupDraft.activityLevel == item.$1,
            onTap: () => setState(
              () => _healthProfileSetupDraft.activityLevel = item.$1,
            ),
          ),
        const SizedBox(height: 8),
        const InfoPanel(
          title: 'Field API',
          text:
              'Các tình trạng bệnh nền không có trong health-profile API hiện tại nên không còn hiển thị ở bước này.',
        ),
      ],
    );
  }
}

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key, this.completeDestination = const MainShell()});

  final Widget completeDestination;

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  late final TextEditingController _caloriesController = TextEditingController(
    text: _healthProfileSetupDraft.calories,
  );
  @override
  void dispose() {
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 3,
      progress: .75,
      title: 'Mục tiêu dinh dưỡng',
      subtitle:
          'Thiết lập calories mỗi ngày. Các chỉ số macro được hệ thống tự tính.',
      next: PreferencesScreen(completeDestination: widget.completeDestination),
      children: [
        AppTextField(
          label: 'Calories mỗi ngày (kcal)',
          hint: '2000',
          compact: true,
          controller: _caloriesController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) => _healthProfileSetupDraft.calories = value,
        ),
        const SizedBox(height: 16),
        const InfoPanel(
          title: 'Phân bổ macro tự động',
          text:
              'Hệ thống dùng 20% calories cho đạm, 50% cho tinh bột và 30% cho chất béo.',
        ),
      ],
    );
  }
}

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({
    super.key,
    this.completeDestination = const MainShell(),
  });

  final Widget completeDestination;

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  static const _dietOptions = <(String, String)>[
    ('VEGAN', 'Vegan'),
    ('VEGETARIAN', 'Ăn chay'),
    ('KETO', 'Keto'),
    ('HALAL', 'Halal'),
    ('MEDITERRANEAN', 'Địa Trung Hải'),
    ('PALEO', 'Paleo'),
  ];

  Future<void> _saveOnboarding(BuildContext context) async {
    final height = double.tryParse(
      _healthProfileSetupDraft.height.replaceAll(',', '.'),
    );
    final weight = double.tryParse(
      _healthProfileSetupDraft.weight.replaceAll(',', '.'),
    );
    final calories = double.tryParse(
      _healthProfileSetupDraft.calories.replaceAll(',', '.'),
    );

    if (height == null || weight == null || height <= 0 || weight <= 0) {
      throw const ApiException(
        message: 'Nhập chiều cao và cân nặng hợp lệ trước khi hoàn tất.',
      );
    }

    if (calories == null || calories <= 0) {
      throw const ApiException(
        message: 'Nhập mục tiêu calories hợp lệ.',
      );
    }

    final users = AuthDependencies.instance.userRepository;

    await users.saveHealthProfile(
      height: height,
      weight: weight,
      activityLevel: _healthProfileSetupDraft.activityLevel,
    );
    await users.saveNutritionGoal(
      goalType: 'MAINTAIN',
      dailyCaloriesGoal: calories,
    );
    await users.syncDietPreferences(
      dietTypes: _healthProfileSetupDraft.dietTypes,
    );
    await users.syncAllergies(allergies: _healthProfileSetupDraft.allergies);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 4,
      progress: 1,
      title: 'Sở thích và dị ứng',
      subtitle: 'Chọn chế độ ăn và các dị ứng cần loại trừ khỏi gợi ý món.',
      buttonLabel: 'Lưu toàn bộ hồ sơ',
      complete: true,
      completeDestination: widget.completeDestination,
      onComplete: _saveOnboarding,
      children: [
        const SectionLabel('CHẾ ĐỘ ĂN'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final diet in _dietOptions)
              FilterChip(
                label: Text(diet.$2),
                selected: _healthProfileSetupDraft.dietTypes.contains(diet.$1),
                onSelected: (selected) => setState(() {
                  if (selected) {
                    _healthProfileSetupDraft.dietTypes.add(diet.$1);
                  } else {
                    _healthProfileSetupDraft.dietTypes.remove(diet.$1);
                  }
                }),
                selectedColor: AppColors.mint,
                checkmarkColor: AppColors.green,
              ),
          ],
        ),
        const SizedBox(height: 22),
        const SectionLabel('DỊ ỨNG'),
        const SizedBox(height: 8),
        if (_healthProfileSetupDraft.allergenOptions.isEmpty)
          const InfoPanel(
            title: 'Chưa có catalog dị ứng',
            text: 'Recipe Service chưa trả về allergen nào để lựa chọn.',
          )
        else
          for (final allergen in _healthProfileSetupDraft.allergenOptions)
            _AllergenSelectionTile(
              allergen: allergen,
              severity: _healthProfileSetupDraft
                  .allergies[(allergen['allergenId'] as num).toInt()],
              onChanged: (severity) => setState(() {
                final id = (allergen['allergenId'] as num).toInt();
                if (severity == null) {
                  _healthProfileSetupDraft.allergies.remove(id);
                } else {
                  _healthProfileSetupDraft.allergies[id] = severity;
                }
              }),
            ),
        const SizedBox(height: 16),
        const InfoPanel(
          title: 'Đồng bộ backend',
          text:
              'Ứng dụng tạo, cập nhật hoặc xóa nutrition goal, diet preferences và allergies để backend khớp với lựa chọn hiện tại.',
        ),
      ],
    );
  }
}

class _AllergenSelectionTile extends StatelessWidget {
  const _AllergenSelectionTile({
    required this.allergen,
    required this.severity,
    required this.onChanged,
  });

  final Map<String, dynamic> allergen;
  final String? severity;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = severity != null;
    return Card(
      color: selected ? AppColors.mint : AppColors.card,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Checkbox(
              value: selected,
              activeColor: AppColors.green,
              onChanged: (value) => onChanged(value == true ? 'MEDIUM' : null),
            ),
            Expanded(
              child: Text(
                allergen['name']?.toString() ?? 'Allergen',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            if (selected)
              DropdownButton<String>(
                value: severity,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 'LOW', child: Text('Nhẹ')),
                  DropdownMenuItem(value: 'MEDIUM', child: Text('Vừa')),
                  DropdownMenuItem(value: 'HIGH', child: Text('Nặng')),
                ],
                onChanged: onChanged,
              ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingLoadingScreen extends StatelessWidget {
  const _OnboardingLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.cream,
      body: Center(child: CircularProgressIndicator(color: AppColors.green)),
    );
  }
}

class _OnboardingLoadErrorScreen extends StatelessWidget {
  const _OnboardingLoadErrorScreen({
    required this.error,
    required this.onRetry,
  });

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final message = error is ApiException
        ? (error as ApiException).message
        : 'Không thể tải dữ liệu onboarding từ backend.';
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(backgroundColor: AppColors.cream),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
            ],
          ),
        ),
      ),
    );
  }
}
