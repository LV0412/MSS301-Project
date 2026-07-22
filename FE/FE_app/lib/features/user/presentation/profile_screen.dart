part of '../../../app.dart';

class ApiUserProfileScreen extends StatefulWidget {
  const ApiUserProfileScreen({super.key, this.onTabSelected});

  final ValueChanged<HomeTab>? onTabSelected;

  @override
  State<ApiUserProfileScreen> createState() => _ApiUserProfileScreenState();
}

class _ApiUserProfileScreenState extends State<ApiUserProfileScreen> {
  late Future<_ProfileApiState> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  void _reloadProfile() {
    final nextProfile = _loadProfile();
    setState(() {
      _profileFuture = nextProfile;
    });
  }

  Future<void> _editBasicProfile(UserProfile? profile) async {
    if (profile == null) return;
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditBasicProfileScreen(profile: profile),
      ),
    );
    if (updated == true && mounted) _reloadProfile();
  }

  Future<void> _editNutritionGoal(NutritionGoal? goal) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NutritionGoalPlanScreen(initialGoal: goal),
      ),
    );
    if (mounted) _reloadProfile();
  }

  Future<_ProfileApiState> _loadProfile() async {
    final account = await AuthDependencies.instance.repository.me();
    UserProfile? userProfile;
    String? profileMessage;
    Map<String, dynamic>? healthProfile;
    NutritionGoal? nutritionGoal;
    List<Map<String, dynamic>> dietPreferences = const [];
    List<Map<String, dynamic>> allergies = const [];
    List<Map<String, dynamic>> allergenOptions = const [];

    try {
      userProfile = await AuthDependencies.instance.userRepository
          .getCurrentUser();
    } on ApiException catch (error) {
      profileMessage = error.message;
    }

    if (userProfile != null) {
      try {
        final repository = AuthDependencies.instance.userRepository;
        healthProfile = await repository.getHealthProfile();
        nutritionGoal = await repository.getNutritionGoal();
        dietPreferences = await repository.getDietPreferences();
        allergies = await repository.getAllergies();
        allergenOptions = await AuthDependencies.instance.recipeRepository
            .getAllergens();
      } on ApiException catch (error) {
        profileMessage = error.message;
      }
    }

    return _ProfileApiState(
      account: account,
      userProfile: userProfile,
      profileMessage: profileMessage,
      healthProfile: healthProfile,
      nutritionGoal: nutritionGoal,
      dietPreferences: dietPreferences,
      allergies: allergies,
      allergenOptions: allergenOptions,
    );
  }

  Future<void> _logout() async {
    await AuthDependencies.instance.repository.logout();
    AuthDependencies.instance.favoriteStore.clear();
    AuthDependencies.instance.foodLogStore.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ApiLoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            FutureBuilder<_ProfileApiState>(
              future: _profileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.green),
                  );
                }

                if (snapshot.hasError) {
                  final error = snapshot.error;
                  final message = error is ApiException
                      ? error.message
                      : 'Không thể tải hồ sơ từ API Gateway.';
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 112),
                    children: [
                      _ApiProfileHeader(onLogout: _logout),
                      const SizedBox(height: 24),
                      ApiMessageBanner(message: message, isError: true),
                    ],
                  );
                }

                final state = snapshot.data!;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 112),
                  children: [
                    ProfileTopBar(onLogout: _logout),
                    const SizedBox(height: 30),
                    ProfileIdentity(
                      account: state.account,
                      userProfile: state.userProfile,
                      onEdit: () => _editBasicProfile(state.userProfile),
                    ),
                    const SizedBox(height: 24),
                    ProfileInsightCard(
                      profileMessage: state.profileMessage,
                      healthProfile: state.healthProfile,
                    ),
                    const SizedBox(height: 16),
                    ProfileSetupBanner(
                      editing:
                          state.healthProfile != null ||
                          state.nutritionGoal?.isConfigured == true ||
                          state.dietPreferences.isNotEmpty ||
                          state.allergies.isNotEmpty,
                    ),
                    const SizedBox(height: 28),
                    HealthProfileSection(healthProfile: state.healthProfile),
                    const SizedBox(height: 16),
                    NutritionGoalSection(
                      nutritionGoal: state.nutritionGoal,
                      onEdit: () => _editNutritionGoal(state.nutritionGoal),
                    ),
                    const SizedBox(height: 16),
                    DietPreferenceSection(
                      dietPreferences: state.dietPreferences,
                      allergies: state.allergies,
                      allergenOptions: state.allergenOptions,
                    ),
                    const SizedBox(height: 28),
                    SettingsCard(onLogout: _logout),
                  ],
                );
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: HomeBottomNav(
                selected: HomeTab.profile,
                onSelected: widget.onTabSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileApiState {
  const _ProfileApiState({
    required this.account,
    required this.userProfile,
    required this.profileMessage,
    required this.healthProfile,
    required this.nutritionGoal,
    required this.dietPreferences,
    required this.allergies,
    required this.allergenOptions,
  });

  final Account account;
  final UserProfile? userProfile;
  final String? profileMessage;
  final Map<String, dynamic>? healthProfile;
  final NutritionGoal? nutritionGoal;
  final List<Map<String, dynamic>> dietPreferences;
  final List<Map<String, dynamic>> allergies;
  final List<Map<String, dynamic>> allergenOptions;
}

class _ApiProfileHeader extends StatelessWidget {
  const _ApiProfileHeader({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 6),
        const Expanded(
          child: Text(
            'Hồ sơ API',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
        ),
        IconButton(
          tooltip: 'Đăng xuất',
          onPressed: onLogout,
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }
}

double? _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

String _formatNumber(double? value) {
  if (value == null) return '-';
  if (value == value.roundToDouble()) return value.round().toString();
  return value.toStringAsFixed(1);
}

void _openRecipeDetails(BuildContext context, int recipeId, String title) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          RecipeDetailsScreen(recipeId: recipeId, recipeTitle: title),
    ),
  );
}

String _bmiLabel(double bmi) {
  if (bmi < 18.5) return 'Thiếu cân';
  if (bmi < 25) return 'Bình thường';
  if (bmi < 30) return 'Thừa cân';
  return 'Béo phì';
}

String _activityLabel(String? value) {
  return switch (value) {
    'SEDENTARY' => 'Ít vận động',
    'LIGHT' || 'LIGHTLY_ACTIVE' => 'Vận động nhẹ',
    'MODERATE' || 'MODERATELY_ACTIVE' => 'Vừa phải',
    'ACTIVE' || 'VERY_ACTIVE' => 'Năng động',
    'EXTRA_ACTIVE' => 'Rất năng động',
    null || '' => '-',
    _ => value.replaceAll('_', ' '),
  };
}

String _dietLabel(String? value) {
  return switch (value) {
    'MEDITERRANEAN' => 'Địa Trung Hải',
    'VEGETARIAN' => 'Ăn chay',
    'VEGAN' => 'Thuần chay',
    'KETO' => 'Keto',
    'LOW_CARB' => 'Ít tinh bột',
    'HIGH_PROTEIN' => 'Giàu đạm',
    'GLUTEN_FREE' => 'Không gluten',
    null || '' => 'Chưa cập nhật',
    _ => value.replaceAll('_', ' '),
  };
}

String _difficultyLabel(String value) {
  return switch (value) {
    'EASY' => 'Dễ',
    'MEDIUM' => 'Vừa',
    'HARD' => 'Khó',
    _ => value.isEmpty ? 'Chưa rõ' : value,
  };
}

MealPalette _paletteForIndex(int index) {
  return switch (index % 3) {
    0 => MealPalette.breakfast,
    1 => MealPalette.lunch,
    _ => MealPalette.dinner,
  };
}
