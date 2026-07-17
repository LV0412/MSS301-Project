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

  final Map<String, dynamic>? nutritionGoal;

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
          Row(
            children: [
              Expanded(
                child: ProfileMetricTile(
                  label: 'CALO\nMỖI NGÀY',
                  value: _formatNumber(_asDouble(nutritionGoal?['calories'])),
                  unit: 'kcal',
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: ProfileMetricTile(
                  label: 'CHẤT ĐẠM',
                  value: _formatNumber(_asDouble(nutritionGoal?['protein'])),
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
                  value: _formatNumber(_asDouble(nutritionGoal?['carbs'])),
                  unit: 'g',
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: ProfileMetricTile(
                  label: 'CHẤT BÉO',
                  value: _formatNumber(_asDouble(nutritionGoal?['fat'])),
                  unit: 'g',
                ),
              ),
            ],
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
  });

  final List<Map<String, dynamic>> dietPreferences;
  final List<Map<String, dynamic>> allergies;

  @override
  Widget build(BuildContext context) {
    final dietText = dietPreferences.isEmpty
        ? 'Chưa cập nhật'
        : dietPreferences
              .map((item) => _dietLabel(item['dietType']?.toString()))
              .join(', ');
    final allergyText = allergies.isEmpty
        ? 'Không có dữ liệu'
        : '${allergies.length} dị ứng đã ghi nhận';

    return ProfileCard(
      child: Column(
        children: [
          const ProfileSectionHeader(
            icon: Icons.restaurant_menu,
            title: 'Sở thích ăn uống',
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text(
                'Chế độ ăn',
                style: TextStyle(fontSize: 16, color: AppColors.ink),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  dietText,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Text(
                'Dị ứng',
                style: TextStyle(fontSize: 16, color: AppColors.ink),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  allergyText,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
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
