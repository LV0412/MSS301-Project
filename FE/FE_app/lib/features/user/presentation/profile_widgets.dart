part of '../../../app.dart';

class ProfileTopBar extends StatelessWidget {
  const ProfileTopBar({super.key, this.onLogout});

  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'NutriChef AI',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGreen,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Đăng xuất',
          onPressed: onLogout,
          icon: const Icon(Icons.logout, color: AppColors.darkGreen),
        ),
      ],
    );
  }
}

class ProfileIdentity extends StatelessWidget {
  const ProfileIdentity({
    super.key,
    this.account,
    this.userProfile,
    this.onEdit,
  });

  final Account? account;
  final UserProfile? userProfile;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final displayName = userProfile?.fullName.isNotEmpty == true
        ? userProfile!.fullName
        : account?.fullName ?? 'Người dùng';
    final email = account?.email ?? userProfile?.email ?? 'Chưa có email';
    final status = account?.emailVerified == true
        ? 'Đã xác thực'
        : 'Chưa xác thực';

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 132,
              height: 132,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF8EA18C), width: 4),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 16,
                    offset: const Offset(0, 10),
                    color: AppColors.darkGreen.withValues(alpha: .16),
                  ),
                ],
              ),
              child: const CircleAvatar(
                backgroundColor: Color(0xFFD8C2A4),
                child: Icon(Icons.person, size: 76, color: AppColors.darkGreen),
              ),
            ),
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.green,
              child: IconButton(
                tooltip: 'Sửa thông tin cá nhân',
                onPressed: onEdit,
                icon: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          displayName,
          style: TextStyle(
            fontSize: 28,
            height: 1,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mail_outline, size: 18, color: AppColors.ink),
            const SizedBox(width: 4),
            Text(
              email,
              style: const TextStyle(fontSize: 15, color: AppColors.darkGreen),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          status,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.green,
          ),
        ),
      ],
    );
  }
}

class ProfileInsightCard extends StatelessWidget {
  const ProfileInsightCard({
    super.key,
    this.profileMessage,
    this.healthProfile,
  });

  final String? profileMessage;
  final Map<String, dynamic>? healthProfile;

  @override
  Widget build(BuildContext context) {
    final bmi = _asDouble(healthProfile?['bmi']);
    final message =
        profileMessage ??
        (bmi == null
            ? 'Hồ sơ sức khỏe đang chờ cập nhật từ user-service.'
            : 'BMI hiện tại của bạn là ${_formatNumber(bmi)}. Trạng thái: ${_bmiLabel(bmi).toLowerCase()}.');

    return ProfileCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 21,
                backgroundColor: AppColors.field,
                child: Icon(Icons.auto_awesome, color: AppColors.green),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gợi ý sức khỏe',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.35,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: FilledButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WeeklyAnalysisScreen()),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.sand,
                foregroundColor: const Color(0xFF5F6057),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: const Text(
                'XEM BÁO CÁO CHI TIẾT',
                style: TextStyle(
                  fontSize: 13,
                  letterSpacing: .8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileSetupBanner extends StatelessWidget {
  const ProfileSetupBanner({super.key, this.editing = false});

  final bool editing;

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.field,
            child: Icon(Icons.assignment_outlined, color: AppColors.green),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  editing
                      ? 'Chỉnh sửa sức khỏe và dinh dưỡng'
                      : 'Thiết lập hồ sơ cá nhân',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  editing
                      ? 'Mở lại 4 bước với dữ liệu hiện tại để sửa health profile, nutrition goal, dị ứng và chế độ ăn.'
                      : 'Hoàn thành 4 bước để cập nhật sức khỏe, mục tiêu dinh dưỡng, dị ứng và sở thích ăn uống.',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 42,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LifestyleScreen(
                          completeDestination: ApiUserProfileScreen(),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 17),
                    label: Text(editing ? 'Chỉnh sửa hồ sơ' : 'Bắt đầu 4 bước'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HealthProfileSection extends StatelessWidget {
  const HealthProfileSection({super.key, this.healthProfile});

  final Map<String, dynamic>? healthProfile;

  @override
  Widget build(BuildContext context) {
    final height = _asDouble(healthProfile?['height']);
    final weight = _asDouble(healthProfile?['weight']);
    final bmi = _asDouble(healthProfile?['bmi']);
    final activity = _activityLabel(
      healthProfile?['activityLevel']?.toString(),
    );

    return ProfileCard(
      child: Column(
        children: [
          const ProfileSectionHeader(
            icon: Icons.medical_information_outlined,
            title: 'Hồ sơ sức khỏe',
            expanded: true,
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: ProfileMetricTile(
                  label: 'CÂN NẶNG\nHIỆN TẠI',
                  value: _formatNumber(weight),
                  unit: 'kg',
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: ProfileMetricTile(
                  label: 'CHỈ SỐ BMI',
                  value: _formatNumber(bmi),
                  unit: bmi == null ? '' : '\n(${_bmiLabel(bmi)})',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ProfileMetricTile(
                  label: 'CHIỀU CAO',
                  value: _formatNumber(height),
                  unit: 'cm',
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: ProfileMetricTile(
                  label: 'VẬN ĐỘNG',
                  value: activity,
                  unit: '',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NutritionGoalSection extends StatelessWidget {
  const NutritionGoalSection({super.key, this.nutritionGoal});

  final NutritionGoal? nutritionGoal;

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      child: Column(
        children: [
          const ProfileSectionHeader(
            icon: Icons.track_changes,
            title: 'Mục tiêu dinh dưỡng',
          ),
          const SizedBox(height: 24),
          if (nutritionGoal?.isConfigured != true)
            _NutritionGoalSetupCta(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LifestyleScreen(
                    completeDestination: ApiUserProfileScreen(),
                  ),
                ),
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: ProfileMetricTile(
                    label: 'CALO\nMỖI NGÀY',
                    value: _formatNumber(nutritionGoal?.dailyCaloriesGoal),
                    unit: 'kcal',
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ProfileMetricTile(
                    label: 'CHẤT ĐẠM',
                    value: _formatNumber(nutritionGoal?.protein),
                    unit: 'g',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ProfileMetricTile(
                    label: 'TINH BỘT',
                    value: _formatNumber(nutritionGoal?.carbs),
                    unit: 'g',
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ProfileMetricTile(
                    label: 'CHẤT BÉO',
                    value: _formatNumber(nutritionGoal?.fat),
                    unit: 'g',
                  ),
                ),
              ],
            ),
            if (nutritionGoal != null) ...[
              const SizedBox(height: 18),
              _NutritionGoalPlanSummary(goal: nutritionGoal!),
            ],
          ],
        ],
      ),
    );
  }
}

class _NutritionGoalPlanSummary extends StatelessWidget {
  const _NutritionGoalPlanSummary({required this.goal});

  final NutritionGoal goal;

  @override
  Widget build(BuildContext context) {
    final planText = _goalPlanText(goal);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (planText != null) ...[
                Text(
                  planText,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                'Gợi ý hệ thống: ${_formatNumber(goal.recommendedCalories)} kcal/ngày',
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: AppColors.darkGreen,
                ),
              ),
            ],
          ),
        ),
        if (goal.warnings.isNotEmpty) ...[
          const SizedBox(height: 12),
          _NutritionGoalWarningBanner(warnings: goal.warnings),
        ],
      ],
    );
  }
}

class _NutritionGoalWarningBanner extends StatelessWidget {
  const _NutritionGoalWarningBanner({required this.warnings});

  final List<String> warnings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4D7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE6C979)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_outlined,
            size: 18,
            color: Color(0xFF8A6A00),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              warnings.join('\n'),
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String? _goalPlanText(NutritionGoal goal) {
  if (!goal.hasWeightPlan) return null;
  final direction = switch (goal.goalType) {
    'LOSE_WEIGHT' => 'Giảm cân',
    'GAIN_WEIGHT' => 'Tăng cân',
    _ => 'Mục tiêu',
  };
  final parts = <String>[direction];
  if (goal.targetWeight != null) {
    parts.add('${_formatNumber(goal.targetWeight)}kg');
  }
  if (goal.durationWeeks != null) {
    parts.add('trong ${goal.durationWeeks} tuần');
  }
  if (goal.weeklyRateKg != null) {
    parts.add('${_formatNumber(goal.weeklyRateKg)}kg/tuần');
  }
  return 'Mục tiêu: ${parts.join(' · ')}';
}

class _NutritionGoalSetupCta extends StatelessWidget {
  const _NutritionGoalSetupCta({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bạn chưa thiết lập mục tiêu calo',
            style: TextStyle(
              fontSize: 16,
              height: 1.2,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hoàn thành hồ sơ để lưu calories và macro mục tiêu.',
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.arrow_forward, size: 17),
            label: const Text('Thiết lập mục tiêu'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DietPreferenceSection extends StatelessWidget {
  const DietPreferenceSection({
    super.key,
    required this.dietPreferences,
    required this.allergies,
    required this.allergenOptions,
  });

  final List<Map<String, dynamic>> dietPreferences;
  final List<Map<String, dynamic>> allergies;
  final List<Map<String, dynamic>> allergenOptions;

  @override
  Widget build(BuildContext context) {
    final allergenNames = <int, String>{
      for (final item in allergenOptions)
        if (item['allergenId'] is num)
          (item['allergenId'] as num)
              .toInt(): item['name']?.toString().trim().isNotEmpty == true
              ? item['name'].toString()
              : 'Dị ứng #${(item['allergenId'] as num).toInt()}',
    };

    return ProfileCard(
      child: Column(
        children: [
          const ProfileSectionHeader(
            icon: Icons.restaurant_menu,
            title: 'Sở thích ăn uống',
            expanded: true,
          ),
          const SizedBox(height: 24),
          _PreferenceDetailTitle(icon: Icons.eco_outlined, label: 'Chế độ ăn'),
          const SizedBox(height: 12),
          if (dietPreferences.isEmpty)
            const _PreferenceEmptyText('Chưa cập nhật chế độ ăn')
          else
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final preference in dietPreferences)
                    _DietPreferenceTag(
                      label: _dietLabel(preference['dietType']?.toString()),
                    ),
                ],
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1, color: AppColors.line),
          ),
          const _PreferenceDetailTitle(
            icon: Icons.health_and_safety_outlined,
            label: 'Dị ứng',
          ),
          const SizedBox(height: 8),
          if (allergies.isEmpty)
            const _PreferenceEmptyText('Chưa ghi nhận dị ứng')
          else
            for (var index = 0; index < allergies.length; index++) ...[
              _AllergyDetailRow(
                name: _allergyName(allergies[index], allergenNames),
                severity: allergies[index]['severity']?.toString(),
              ),
              if (index < allergies.length - 1)
                const Divider(height: 1, color: AppColors.line),
            ],
        ],
      ),
    );
  }
}

class _PreferenceDetailTitle extends StatelessWidget {
  const _PreferenceDetailTitle({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.darkGreen),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}

class _PreferenceEmptyText extends StatelessWidget {
  const _PreferenceEmptyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: AppColors.muted),
      ),
    );
  }
}

class _DietPreferenceTag extends StatelessWidget {
  const _DietPreferenceTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColors.darkGreen,
        ),
      ),
    );
  }
}

class _AllergyDetailRow extends StatelessWidget {
  const _AllergyDetailRow({required this.name, required this.severity});

  final String name;
  final String? severity;

  @override
  Widget build(BuildContext context) {
    final detail = _severityDetail(severity);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: detail.background,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              detail.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: detail.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _allergyName(
  Map<String, dynamic> allergy,
  Map<int, String> allergenNames,
) {
  final id = (allergy['allergenId'] as num?)?.toInt();
  if (id == null) return 'Dị ứng chưa xác định';
  return allergenNames[id] ?? 'Dị ứng #$id';
}

({String label, Color background, Color foreground}) _severityDetail(
  String? severity,
) {
  return switch (severity?.toUpperCase()) {
    'LOW' => (
      label: 'Nhẹ',
      background: const Color(0xFFE4F2E3),
      foreground: const Color(0xFF35613D),
    ),
    'HIGH' => (
      label: 'Nặng',
      background: const Color(0xFFFFE6E2),
      foreground: const Color(0xFFA43128),
    ),
    _ => (
      label: 'Trung bình',
      background: const Color(0xFFFFF1D6),
      foreground: const Color(0xFF815F12),
    ),
  };
}

class ProfileSectionHeader extends StatelessWidget {
  const ProfileSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.expanded = false,
  });

  final IconData icon;
  final String title;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.darkGreen),
        const SizedBox(width: 18),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
        ),
        Icon(
          expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: AppColors.ink,
        ),
      ],
    );
  }
}

class ProfileMetricTile extends StatelessWidget {
  const ProfileMetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              height: 1.15,
              letterSpacing: 1,
              fontWeight: FontWeight.w900,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: AppColors.ink),
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const TextSpan(text: ' '),
                TextSpan(
                  text: unit,
                  style: const TextStyle(fontSize: 15, height: 1.1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CollapsedProfileSection extends StatelessWidget {
  const CollapsedProfileSection({
    super.key,
    required this.icon,
    required this.title,
    required this.preview,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String preview;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      child: Column(
        children: [
          ProfileSectionHeader(icon: icon, title: title),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                preview,
                style: const TextStyle(fontSize: 16, color: AppColors.ink),
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key, this.onLogout});

  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SettingsRow(
            icon: Icons.logout,
            title: 'Đăng xuất',
            destructive: true,
            showArrow: false,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.toggle = false,
    this.destructive = false,
    this.showArrow = true,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final bool toggle;
  final bool destructive;
  final bool showArrow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? const Color(0xFFD71920) : AppColors.ink;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 68,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: [
              Icon(icon, color: color, size: 21),
              const SizedBox(width: 22),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: destructive ? FontWeight.w900 : FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
              if (toggle)
                Container(
                  width: 48,
                  height: 28,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: CircleAvatar(
                      radius: 11,
                      backgroundColor: Colors.white,
                    ),
                  ),
                )
              else if (showArrow)
                Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 8),
            color: AppColors.darkGreen.withValues(alpha: .03),
          ),
        ],
      ),
      child: child,
    );
  }
}
