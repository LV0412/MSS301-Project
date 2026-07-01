           import 'package:flutter/material.dart';

void main() {
  runApp(const NutriChefApp());
}

class NutriChefApp extends StatelessWidget {
  const NutriChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NutriChef AI',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.green,
          primary: AppColors.green,
          surface: AppColors.card,
        ),
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

class AppColors {
  static const green = Color(0xFF516C58);
  static const darkGreen = Color(0xFF263D31);
  static const mint = Color(0xFFE3F1D9);
  static const cream = Color(0xFFF4F8EA);
  static const card = Color(0xFFFFFFFF);
  static const field = Color(0xFFEFF4E7);
  static const sand = Color(0xFFECE8D7);
  static const ink = Color(0xFF111D16);
  static const muted = Color(0xFF6D756F);
  static const line = Color(0xFFDDE4D2);
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _FoodBackdrop(),
          Container(color: AppColors.cream.withValues(alpha: 0.74)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const _LogoMark(size: 74),
                  const SizedBox(height: 22),
                  const Text(
                    'NutriChef AI',
                    style: TextStyle(
                      fontSize: 34,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Bữa ăn cá nhân hóa cho mục tiêu sức khỏe của bạn',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.35,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const Spacer(),
                  PrimaryButton(
                    label: 'Bắt đầu ngay',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, size: 7, color: AppColors.green),
                      SizedBox(width: 8),
                      Text(
                        'PHÂN TÍCH DINH DƯỠNG AI',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: .7,
                          fontWeight: FontWeight.w700,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthFrame(
      child: Column(
        children: [
          const _LogoMark(size: 46),
          const SizedBox(height: 12),
          const Text(
            'NutriChef AI',
            style: TextStyle(fontSize: 20, color: AppColors.darkGreen),
          ),
          const SizedBox(height: 28),
          const Text(
            'Chào mừng trở lại',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const Text(
            'Vui lòng nhập thông tin để tiếp tục.',
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 26),
          const AppTextField(
            label: 'EMAIL',
            hint: 'email@vi-du.com',
            icon: Icons.mail_outline,
          ),
          const SizedBox(height: 14),
          const AppTextField(
            label: 'MẬT KHẨU',
            hint: '••••••••',
            icon: Icons.lock_outline,
            trailing: Icons.visibility_outlined,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Quên mật khẩu?',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
            ),
          ),
          PrimaryButton(
            label: 'Đăng nhập',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LifestyleScreen()),
            ),
          ),
          const OrDivider(),
          const GoogleButton(),
          const SizedBox(height: 28),
          AuthSwitchText(
            normal: 'Chưa có tài khoản? ',
            action: 'Đăng ký ngay',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignUpScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthFrame(
      topLabel: 'NutriChef AI',
      footer: '© 2024 NUTRICHEF AI. TẤT CẢ QUYỀN ĐƯỢC BẢO LƯU.',
      child: Column(
        children: [
          const Text(
            'Bắt đầu hành trình',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          const Text(
            'Khám phá công thức nấu ăn thông minh cùng AI.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 26),
          const AppTextField(
            label: 'FULL NAME',
            hint: 'Nguyễn Văn A',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 14),
          const AppTextField(
            label: 'EMAIL',
            hint: 'example@nutrichef.ai',
            icon: Icons.mail_outline,
          ),
          const SizedBox(height: 14),
          const AppTextField(
            label: 'PASSWORD',
            hint: '••••••••',
            icon: Icons.lock_outline,
          ),
          const SizedBox(height: 14),
          const AppTextField(
            label: 'CONFIRM',
            hint: '••••••••',
            icon: Icons.verified_user_outlined,
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Đăng ký',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LifestyleScreen()),
            ),
          ),
          const OrDivider(),
          const GoogleButton(),
          const SizedBox(height: 20),
          AuthSwitchText(
            normal: 'Đã có tài khoản? ',
            action: 'Đăng nhập',
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class LifestyleScreen extends StatelessWidget {
  const LifestyleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 1,
      progress: .25,
      title: 'Thông tin cơ bản',
      subtitle:
          'Hãy cho NutriChef AI biết một chút về bạn để chúng tôi có thể cá nhân hóa hành trình dinh dưỡng của bạn.',
      next: const HealthStatusScreen(),
      children: [
        const SelectField(label: 'Quốc gia / Khu vực', value: 'Việt Nam'),
        const SizedBox(height: 14),
        const Row(
          children: [
            Expanded(
              child: AppTextField(label: 'Tuổi', hint: '25', compact: true),
            ),
            SizedBox(width: 12),
            Expanded(child: GenderToggle()),
          ],
        ),
        const SizedBox(height: 14),
        const Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Chiều cao (cm)',
                hint: '170',
                compact: true,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                label: 'Cân nặng (kg)',
                hint: '65',
                compact: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const SectionLabel('Lối sống & Vận động'),
        const SizedBox(height: 10),
        ChoiceCard(
          icon: Icons.weekend_outlined,
          title: 'Ít vận động',
          subtitle: 'Làm việc văn phòng, ít tập thể dục',
        ),
        const ChoiceCard(
          icon: Icons.directions_walk,
          title: 'Vận động nhẹ',
          subtitle: 'Đi bộ nhẹ nhàng, 1-2 buổi/tuần',
          selected: true,
        ),
        const ChoiceCard(
          icon: Icons.fitness_center_outlined,
          title: 'Vận động vừa',
          subtitle: 'Tập luyện 3-5 ngày mỗi tuần',
        ),
        const ChoiceCard(
          icon: Icons.flash_on_outlined,
          title: 'Vận động nhiều',
          subtitle: 'Vận động viên hoặc làm việc nặng',
        ),
        const SizedBox(height: 10),
        const PromoImage(),
      ],
    );
  }
}

class HealthStatusScreen extends StatelessWidget {
  const HealthStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.bloodtype_outlined, 'Tiểu đường', 'Kiểm soát chỉ số đường huyết'),
      (Icons.spa_outlined, 'Cao huyết áp', 'Chế độ ăn giảm muối Natri'),
      (
        Icons.monitor_heart_outlined,
        'Cholesterol cao',
        'Ưu tiên chất béo lành mạnh',
      ),
      (
        Icons.favorite_border,
        'Sức khỏe tim mạch',
        'Tăng cường sức mạnh trái tim',
      ),
      (
        Icons.inventory_2_outlined,
        'Vấn đề tiêu hóa',
        'Linh hoạt cho dạ dày nhạy cảm',
      ),
      (Icons.child_friendly_outlined, 'Mang thai', 'Dinh dưỡng cho mẹ và bé'),
      (
        Icons.psychology_outlined,
        'Cải thiện thể hình',
        'Tăng cơ và giảm mỡ thừa',
      ),
      (
        Icons.check_circle_outline,
        'Không có tình trạng đặc biệt',
        'Tôi chỉ muốn ăn uống lành mạnh',
      ),
    ];

    return OnboardingScaffold(
      step: 2,
      progress: .50,
      title: 'Tình trạng sức khỏe',
      subtitle:
          'Chọn bất kỳ tình trạng nào bạn có để NutriChef AI có thể tinh chỉnh các công thức nấu ăn phù hợp nhất với thể trạng của bạn.',
      next: const GoalsScreen(),
      children: [
        for (final item in items)
          ChoiceCard(icon: item.$1, title: item.$2, subtitle: item.$3),
        const SizedBox(height: 10),
        const InfoPanel(
          title: 'Ghi chú từ AI Chef',
          text:
              'Dữ liệu này được mã hóa bảo mật. NutriChef AI sử dụng thông tin này để tự động lọc các thành phần có thể ảnh hưởng tiêu cực đến tình trạng của bạn và đề xuất các siêu thực phẩm thay thế.',
        ),
      ],
    );
  }
}

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 3,
      progress: .75,
      title: 'Mục tiêu ăn uống',
      subtitle:
          'Chọn mục tiêu chính để AI của chúng tôi tối ưu hóa thực đơn cá nhân hóa cho bạn.',
      next: const PreferencesScreen(),
      children: [
        const ChoiceCard(
          icon: Icons.crop_square_outlined,
          title: 'Giảm cân',
          subtitle: 'Đốt mỡ hiệu quả',
          selected: true,
        ),
        const ChoiceCard(
          icon: Icons.fitness_center_outlined,
          title: 'Tăng cơ',
          subtitle: 'Phục hồi và tăng cơ',
        ),
        const ChoiceCard(
          icon: Icons.timelapse_outlined,
          title: 'Duy trì cân nặng',
          subtitle: 'Cân bằng năng lượng',
        ),
        const ChoiceCard(
          icon: Icons.eco_outlined,
          title: 'Ăn uống lành mạnh',
          subtitle: 'Không cần giảm cân',
        ),
        const ChoiceCard(
          icon: Icons.water_drop_outlined,
          title: 'Kiểm soát đường huyết',
          subtitle: 'Ổn định insulin',
        ),
        const ChoiceCard(
          icon: Icons.opacity,
          title: 'Ăn ít muối',
          subtitle: 'Bảo vệ tim mạch',
        ),
        const ChoiceCard(
          icon: Icons.rice_bowl_outlined,
          title: 'Ăn nhiều đạm',
          subtitle: 'High-Protein Goals',
        ),
        const ChoiceCard(
          icon: Icons.restaurant_menu,
          title: 'Cải thiện tiêu hóa',
          subtitle: 'Nhẹ nhàng cho ruột',
        ),
        const SizedBox(height: 10),
        const GoalMetricsCard(),
      ],
    );
  }
}

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 4,
      progress: 1,
      title: 'Dị ứng & Sở thích',
      subtitle:
          'Hãy cho chúng tôi biết thói quen ăn uống của bạn để AI có thể thiết kế thực đơn cân bằng hoàn hảo nhất.',
      buttonLabel: 'Hoàn tất thiết lập',
      complete: true,
      children: const [
        TagPanel(
          title: 'Dị ứng thực phẩm',
          icon: Icons.warning_amber_rounded,
          tags: [
            'Đậu phộng',
            'Hải sản',
            'Trứng',
            'Sữa & Chế phẩm',
            'Gluten',
            'Đậu nành',
          ],
        ),
        SizedBox(height: 16),
        DietPanel(),
        SizedBox(height: 16),
        CuisinePanel(),
        SizedBox(height: 16),
        InfoPanel(
          title: 'AI Insight',
          text:
              'Việc chọn "Địa Trung Hải" là một lựa chọn tuyệt vời cho mục tiêu giảm cân bền vững. Việt Nam sẽ tạo ra những thực đơn giàu chất xơ và Omega-3, giúp cải thiện sức khỏe tim mạch đáng kể.',
        ),
        SizedBox(height: 16),
        SummaryPanel(),
      ],
    );
  }
}

class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.step,
    required this.progress,
    required this.title,
    required this.subtitle,
    required this.children,
    this.next,
    this.buttonLabel = 'Tiếp tục',
    this.complete = false,
  });

  final int step;
  final double progress;
  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? next;
  final String buttonLabel;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leadingWidth: 42,
        leading: IconButton(
          icon: Icon(step == 1 ? Icons.close : Icons.arrow_back, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'NutriChef AI',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        actions: [
          if (step == 4)
            const Padding(
              padding: EdgeInsets.only(right: 14),
              child: CircleAvatar(
                radius: 14,
                child: Icon(Icons.person, size: 16),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () {},
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'BƯỚC $step TRÊN 4',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.green,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(progress * 100).round()}% Hoàn tất',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: AppColors.line,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 25,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 24),
                ...children,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PrimaryButton(
                  label: buttonLabel,
                  icon: Icons.arrow_forward,
                  onPressed: () {
                    if (complete) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    } else if (next != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => next!),
                      );
                    }
                  },
                ),
                if (step > 1) ...[
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Quay lại'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.green,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AuthFrame extends StatelessWidget {
  const AuthFrame({super.key, required this.child, this.topLabel, this.footer});

  final Widget child;
  final String? topLabel;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
          children: [
            if (topLabel != null) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  topLabel!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(height: 58),
            ],
            Container(
              padding: const EdgeInsets.fromLTRB(18, 30, 18, 24),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.line),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                    color: AppColors.darkGreen.withValues(alpha: .08),
                  ),
                ],
              ),
              child: child,
            ),
            if (footer != null) ...[
              const SizedBox(height: 28),
              Text(
                footer!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB8BDAF),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.icon,
    this.trailing,
    this.compact = false,
  });

  final String label;
  final String hint;
  final IconData? icon;
  final IconData? trailing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          height: compact ? 52 : 48,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.muted),
                const SizedBox(width: 9),
              ],
              Expanded(
                child: Text(
                  hint,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 14 : 13,
                    color: compact ? AppColors.darkGreen : AppColors.muted,
                  ),
                ),
              ),
              if (trailing != null)
                Icon(trailing, size: 17, color: AppColors.muted),
            ],
          ),
        ),
      ],
    );
  }
}

class SelectField extends StatelessWidget {
  const SelectField({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: 8),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(value, style: const TextStyle(fontSize: 14)),
              const Spacer(),
              const Icon(Icons.keyboard_arrow_down, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}

class GenderToggle extends StatelessWidget {
  const GenderToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Giới tính'),
        const SizedBox(height: 8),
        Container(
          height: 52,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Text(
                    'Nam',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Nữ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? AppColors.mint : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.green : AppColors.line,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: selected ? Colors.white : AppColors.field,
            child: Icon(icon, size: 19, color: AppColors.green),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.25,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            selected ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 19,
            color: selected ? AppColors.green : const Color(0xFFB9C1B5),
          ),
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkGreen,
          side: const BorderSide(color: AppColors.line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'G',
              style: TextStyle(
                color: Color(0xFF4285F4),
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            SizedBox(width: 12),
            Text('Tiếp tục với Google'),
          ],
        ),
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 22),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.line)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'HOẶC',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.muted,
              ),
            ),
          ),
          Expanded(child: Divider(color: AppColors.line)),
        ],
      ),
    );
  }
}

class AuthSwitchText extends StatelessWidget {
  const AuthSwitchText({
    super.key,
    required this.normal,
    required this.action,
    required this.onTap,
  });

  final String normal;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: AppColors.muted),
          children: [
            TextSpan(text: normal),
            TextSpan(
              text: action,
              style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: AppColors.ink,
      ),
    );
  }
}

class InfoPanel extends StatelessWidget {
  const InfoPanel({super.key, required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.sand,
        borderRadius: BorderRadius.circular(14),
        border: const Border(
          left: BorderSide(color: AppColors.green, width: 3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.tips_and_updates_outlined,
            size: 20,
            color: AppColors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: AppColors.muted,
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

class GoalMetricsCard extends StatelessWidget {
  const GoalMetricsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: AppColors.green),
              SizedBox(width: 8),
              Text(
                'Chỉ số mục tiêu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MetricCircle(value: '2.2k', label: 'CALO'),
              MetricCircle(value: '3.0L', label: 'NƯỚC'),
            ],
          ),
          const SizedBox(height: 22),
          const _MetricField(
            label: 'CALO MỖI NGÀY',
            value: '2200',
            suffix: 'kcal',
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: _MacroBox(label: 'PROTEIN', value: '150g'),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _MacroBox(label: 'CARBS', value: '250g'),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _MacroBox(label: 'FAT', value: '70g'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _MetricField(
            label: 'LƯỢNG NƯỚC MỤC TIÊU',
            value: '3.0',
            suffix: 'Liters',
          ),
          const SizedBox(height: 16),
          const InfoPanel(
            title: 'Gợi ý từ NutriChef AI',
            text:
                'Dựa trên mục tiêu tăng cơ của bạn, chúng tôi sẽ tập trung vào lượng đạm cao trong từng bữa ăn.',
          ),
        ],
      ),
    );
  }
}

class MetricCircle extends StatelessWidget {
  const MetricCircle({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.green, width: 3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.green,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _MetricField extends StatelessWidget {
  const _MetricField({
    required this.label,
    required this.value,
    required this.suffix,
  });

  final String label;
  final String value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: 6),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(suffix, style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ],
    );
  }
}

class _MacroBox extends StatelessWidget {
  const _MacroBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: AppColors.muted),
          ),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class TagPanel extends StatelessWidget {
  const TagPanel({
    super.key,
    required this.title,
    required this.icon,
    required this.tags,
  });

  final String title;
  final IconData icon;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.green),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in tags)
                Chip(
                  avatar: const Icon(Icons.close, size: 14),
                  label: Text(tag),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: AppColors.field,
                  side: BorderSide.none,
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class DietPanel extends StatelessWidget {
  const DietPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final diets = [
      (Icons.block, 'Vegan'),
      (Icons.flash_on, 'Keto'),
      (Icons.star_border, 'Halal'),
      (Icons.table_restaurant_outlined, 'Địa Trung Hải'),
      (Icons.hiking, 'Paleo'),
      (Icons.all_inclusive, 'Ăn chay'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.restaurant, size: 18, color: AppColors.green),
              SizedBox(width: 8),
              Text(
                'Chế độ ăn uống',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: diets.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.25,
            ),
            itemBuilder: (context, index) {
              final diet = diets[index];
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.field,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(diet.$1, size: 17, color: AppColors.darkGreen),
                    const SizedBox(height: 4),
                    Text(
                      diet.$2,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CuisinePanel extends StatelessWidget {
  const CuisinePanel({super.key});

  @override
  Widget build(BuildContext context) {
    const cuisines = ['Việt Nam', 'Nhật Bản', 'Hàn Quốc', 'Ý'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.public, size: 18, color: AppColors.green),
              SizedBox(width: 8),
              Text(
                'Ẩm thực yêu thích',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cuisines.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.85,
            ),
            itemBuilder: (context, index) => Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E2B22), Color(0xFF8A6C37)],
                ),
              ),
              child: Text(
                cuisines[index],
                style: const TextStyle(
                  color: Colors.white,
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

class SummaryPanel extends StatelessWidget {
  const SummaryPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tóm tắt hồ sơ',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 14),
          _SummaryRow(label: 'Dị ứng', value: 'Chưa chọn'),
          _SummaryRow(label: 'Chế độ ăn', value: 'Chưa chọn'),
          _SummaryRow(label: 'Ẩm thực', value: 'Chưa chọn'),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class PromoImage extends StatelessWidget {
  const PromoImage({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 122,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF223729), Color(0xFFC99A39)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: _FoodPattern()),
            Container(color: Colors.black.withValues(alpha: .24)),
            const Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'Việc hiểu rõ cơ thể bạn là bước đầu tiên để AI của chúng tôi kiến tạo thực đơn hoàn hảo.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExploreRecipesScreen extends StatelessWidget {
  const ExploreRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
              children: const [
                HomeHeader(openScanner: true),
                SizedBox(height: 24),
                RecipeSearchBox(),
                SizedBox(height: 18),
                RecipeFilters(),
                SizedBox(height: 28),
                Text(
                  'Hot Picks',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 18),
                HotPickCard(
                  label: "EDITOR'S CHOICE",
                  title:
                      'Món Việt Nam cân bằng\nSự kết hợp hoàn hảo giữa đạm, xơ và tinh bột.',
                  palette: MealPalette.dinner,
                ),
                SizedBox(height: 20),
                HotPickCard(
                  label: 'PROTEIN BOOST',
                  title:
                      'Bowl Hàn Quốc giàu protein\nTiếp thêm năng lượng cho ngày dài bận rộn.',
                  palette: MealPalette.lunch,
                ),
                SizedBox(height: 64),
                RecommendedHeader(),
                SizedBox(height: 14),
                RecipeRecommendationCard(
                  title: 'Salad Địa Trung Hải',
                  subtitle: 'Ẩm thực Hy Lạp • Giàu chất xơ',
                  calories: '320 kcal',
                  time: '15 min',
                  rating: '4.8',
                  palette: MealPalette.lunch,
                  tags: ['Heart healthy', 'Low salt'],
                ),
                SizedBox(height: 20),
                RecipeRecommendationCard(
                  title: 'Súp Nấm Kem Truffle',
                  subtitle: 'Ẩm thực Pháp • Chay (Vegetarian)',
                  calories: '245 kcal',
                  time: '25 min',
                  rating: '4.9',
                  palette: MealPalette.dinner,
                  tags: ['AI Recommended'],
                ),
                SizedBox(height: 78),
                ExploreInsightCard(),
              ],
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: HomeBottomNav(selected: HomeTab.explore),
            ),
          ],
        ),
      ),
    );
  }
}

class RecipeSearchBox extends StatelessWidget {
  const RecipeSearchBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, size: 22, color: AppColors.darkGreen),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tìm theo nguyên liệu, chế độ ăn...',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15, color: Color(0xFFB8BFB1)),
            ),
          ),
        ],
      ),
    );
  }
}

class RecipeFilters extends StatelessWidget {
  const RecipeFilters({super.key});

  @override
  Widget build(BuildContext context) {
    const filters = [
      (Icons.tune, 'Bộ lọc', true),
      (Icons.ramen_dining_outlined, 'Ẩm thực Việt', false),
      (Icons.bolt_outlined, 'Keto', false),
      (Icons.eco_outlined, 'Chay', false),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: filter.$3 ? AppColors.green : AppColors.sand,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              children: [
                Icon(
                  filter.$1,
                  size: 16,
                  color: filter.$3 ? Colors.white : AppColors.darkGreen,
                ),
                const SizedBox(width: 6),
                Text(
                  filter.$2,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: filter.$3 ? Colors.white : AppColors.darkGreen,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class HotPickCard extends StatelessWidget {
  const HotPickCard({
    super.key,
    required this.label,
    required this.title,
    required this.palette,
  });

  final String label;
  final String title;
  final MealPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 286,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 9),
            color: Colors.black.withValues(alpha: .18),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          MealArt(palette: palette),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: .78),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExploreTag(label: label, dark: true),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    height: 1.32,
                    fontWeight: FontWeight.w800,
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

class RecommendedHeader extends StatelessWidget {
  const RecommendedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Gợi ý cho bạn',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {},
          child: const Text(
            'Xem tất cả',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.darkGreen,
            ),
          ),
        ),
      ],
    );
  }
}

class RecipeRecommendationCard extends StatelessWidget {
  const RecipeRecommendationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.calories,
    required this.time,
    required this.rating,
    required this.palette,
    required this.tags,
  });

  final String title;
  final String subtitle;
  final String calories;
  final String time;
  final String rating;
  final MealPalette palette;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 8),
            color: AppColors.darkGreen.withValues(alpha: .04),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 188,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MealArt(palette: palette),
                Positioned(
                  right: 14,
                  top: 14,
                  child: CircleAvatar(
                    radius: 23,
                    backgroundColor: Colors.white.withValues(alpha: .94),
                    child: const Icon(
                      Icons.favorite_border,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 14,
                  child: Wrap(
                    spacing: 8,
                    children: [for (final tag in tags) ExploreTag(label: tag)],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          height: 1.05,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Text(
                      '$rating★',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 15, color: AppColors.ink),
                ),
                const SizedBox(height: 22),
                const Divider(color: AppColors.line, height: 1),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department_outlined,
                      size: 17,
                      color: AppColors.darkGreen,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      calories,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(width: 28),
                    const Icon(
                      Icons.schedule,
                      size: 17,
                      color: AppColors.darkGreen,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExploreTag extends StatelessWidget {
  const ExploreTag({super.key, required this.label, this.dark = false});

  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withValues(alpha: .25)
            : AppColors.field.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!dark) ...[
            const Icon(Icons.favorite_border, size: 13, color: AppColors.green),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              letterSpacing: dark ? .7 : 0,
              fontWeight: FontWeight.w800,
              color: dark ? Colors.white : AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class ExploreInsightCard extends StatelessWidget {
  const ExploreInsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.sand,
        borderRadius: BorderRadius.circular(18),
        border: const Border(
          left: BorderSide(color: AppColors.green, width: 3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: Color(0xFFDDE0CF),
            child: Icon(Icons.auto_awesome, color: AppColors.green),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NutriChef AI Insight',
                  style: TextStyle(fontSize: 16, color: AppColors.muted),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Dựa trên thói quen của bạn, chúng tôi đề xuất tăng thêm 15g protein cho bữa tối hôm nay để hỗ trợ phục hồi sau buổi tập.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  child: const Text(
                    'Xem thực đơn đề xuất',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
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

class PersonalizedSuggestionsScreen extends StatelessWidget {
  const PersonalizedSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 110),
              children: const [
                HomeHeader(),
                SizedBox(height: 30),
                Text(
                  'Gợi ý dành cho bạn',
                  style: TextStyle(
                    fontSize: 28,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Dựa trên hồ sơ sức khỏe và mục tiêu của bạn',
                  style: TextStyle(fontSize: 15, color: AppColors.darkGreen),
                ),
                SizedBox(height: 24),
                FeaturedSuggestionCard(),
                SizedBox(height: 34),
                SuggestionMiniCard(
                  title: 'Salad Quinoa Địa Trung Hải',
                  tags: ['GLUTEN-FREE', 'VEGAN'],
                  calories: '320',
                  time: '15’',
                  match: 'Phù hợp 94%',
                  palette: MealPalette.lunch,
                ),
                SizedBox(height: 22),
                SuggestionMiniCard(
                  title: 'Súp Đậu Lăng Thảo Mộc',
                  tags: ['HIGH-FIBER', 'LOW-FAT'],
                  calories: '280',
                  time: '30’',
                  match: 'Phù hợp 91%',
                  palette: MealPalette.dinner,
                ),
                SizedBox(height: 22),
                SuggestionMiniCard(
                  title: 'Gà Áp Chảo & Măng Tây',
                  tags: ['KETO', 'HIGH-PROTEIN'],
                  calories: '380',
                  time: '20’',
                  match: 'Phù hợp 89%',
                  palette: MealPalette.breakfast,
                ),
                SizedBox(height: 44),
                SuggestionsAnalysisCard(),
              ],
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: HomeBottomNav(selected: HomeTab.recipes),
            ),
          ],
        ),
      ),
    );
  }
}

class FeaturedSuggestionCard extends StatelessWidget {
  const FeaturedSuggestionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: AppColors.darkGreen.withValues(alpha: .06),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 250,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const MealArt(palette: MealPalette.lunch),
                Positioned(
                  left: 18,
                  top: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.psychology_outlined,
                          color: Colors.white,
                          size: 15,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'LỰA CHỌN TỐI ƯU',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: .6,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Phù hợp 98%',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w300,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Salmon Bowl Chống Oxy\nHóa',
                  style: TextStyle(
                    fontSize: 21,
                    height: 1.16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Món ăn này giúp bạn đạt 70% mục tiêu Protein trong ngày mà vẫn giữ mức Natri thấp.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(
                      child: NutritionChip(label: 'CALO', value: '450'),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: NutritionChip(label: 'PRO', value: '32g'),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: NutritionChip(label: 'CARB', value: '24g'),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: NutritionChip(label: 'FAT', value: '18g'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecipeDetailsScreen(),
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'XEM CÔNG THỨC CHI TIẾT',
                      style: TextStyle(
                        fontSize: 13,
                        letterSpacing: .4,
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

class NutritionChip extends StatelessWidget {
  const NutritionChip({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              letterSpacing: .6,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class SuggestionMiniCard extends StatelessWidget {
  const SuggestionMiniCard({
    super.key,
    required this.title,
    required this.tags,
    required this.calories,
    required this.time,
    required this.match,
    required this.palette,
  });

  final String title;
  final List<String> tags;
  final String calories;
  final String time;
  final String match;
  final MealPalette palette;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RecipeDetailsScreen()),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: const Offset(0, 8),
              color: AppColors.darkGreen.withValues(alpha: .04),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 176,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MealArt(palette: palette),
                  Positioned(
                    right: 12,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .86),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        match,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [for (final tag in tags) ExploreTag(label: tag)],
                  ),
                  const SizedBox(height: 18),
                  const Divider(color: AppColors.line, height: 1),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _TinyMetric(label: 'CAL', value: calories),
                      const SizedBox(width: 28),
                      _TinyMetric(label: 'TIME', value: time),
                      const Spacer(),
                      const Icon(Icons.arrow_forward, color: AppColors.green),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TinyMetric extends StatelessWidget {
  const _TinyMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: AppColors.muted,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, color: AppColors.ink)),
      ],
    );
  }
}

class SuggestionsAnalysisCard extends StatelessWidget {
  const SuggestionsAnalysisCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.sand,
        borderRadius: BorderRadius.circular(18),
        border: const Border(
          left: BorderSide(color: AppColors.green, width: 3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.insights, color: AppColors.green),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phân tích từ AI',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Các công thức này được tối ưu hóa để giảm lượng Carbohydrate tinh chế trong thực đơn của bạn, phù hợp với mục tiêu cải thiện độ nhạy Insulin. Bạn sẽ cảm thấy tràn đầy năng lượng hơn vào buổi chiều sau khi dùng các bữa này.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.48,
                    color: AppColors.darkGreen,
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

class RecipeDetailsScreen extends StatelessWidget {
  const RecipeDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 110),
              children: const [
                RecipeDetailsHeader(),
                SizedBox(height: 12),
                RecipeHeroPanel(),
                SizedBox(height: 18),
                RecipeMetaLine(),
                SizedBox(height: 18),
                DetailAiInsightCard(),
                SizedBox(height: 20),
                NutritionFactsCard(),
                SizedBox(height: 22),
                IngredientsCard(),
                SizedBox(height: 26),
                Text(
                  'Cooking Instructions',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 22),
                CookingStep(
                  step: '1',
                  title: 'Prepare the Salmon',
                  body:
                      'Pat the salmon fillets dry and season both sides with salt, black pepper, and a drizzle of lemon juice. AI Tip: For more flavor, add a pinch of smoked paprika.',
                ),
                CookingStep(
                  step: '2',
                  title: 'Sear the Fish',
                  body:
                      'Heat a non-stick pan over medium-high heat. Sear salmon for 4-5 minutes per side until the edges are golden and crispy. Set aside to rest for 3 minutes.',
                ),
                CookingStep(
                  step: '3',
                  title: 'Assemble the Bowl',
                  body:
                      'Divide cooked quinoa into two bowls. Top with the seared salmon, sliced avocado, cucumber, and baby spinach. Drizzle with the lemon-yogurt dressing.',
                ),
                SizedBox(height: 20),
                MealFeedbackCard(),
              ],
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: HomeBottomNav(selected: HomeTab.recipes),
            ),
          ],
        ),
      ),
    );
  }
}

class RecipeDetailsHeader extends StatelessWidget {
  const RecipeDetailsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, size: 18),
        ),
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
        IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.auto_awesome)),
      ],
    );
  }
}

class RecipeHeroPanel extends StatelessWidget {
  const RecipeHeroPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 212,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const MealArt(palette: MealPalette.lunch),
                Positioned(
                  right: 14,
                  top: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .9),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.track_changes,
                          size: 15,
                          color: AppColors.green,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '98% Match',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ExploreTag(label: 'HIGH\nPROTEIN'),
            ExploreTag(label: 'LOW\nCARB'),
            ExploreTag(label: 'KETO-\nFRIENDLY'),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Mediterranean Salmon\n& Avocado Bowl',
          style: TextStyle(
            fontSize: 26,
            height: 1.04,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}

class RecipeMetaLine extends StatelessWidget {
  const RecipeMetaLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Icon(Icons.schedule, size: 16, color: AppColors.darkGreen),
            SizedBox(width: 5),
            Text('25 mins', style: TextStyle(fontSize: 13)),
            SizedBox(width: 14),
            Icon(Icons.restaurant_menu, size: 16, color: AppColors.darkGreen),
            SizedBox(width: 5),
            Text('Intermediate', style: TextStyle(fontSize: 13)),
            SizedBox(width: 14),
            Icon(Icons.star, size: 16, color: AppColors.darkGreen),
            SizedBox(width: 5),
            Text('4.9 (1.2k)', style: TextStyle(fontSize: 13)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_circle_outline, size: 17),
              label: const Text('Add to Plan'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                minimumSize: const Size(0, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.green,
                side: const BorderSide(color: AppColors.line),
                minimumSize: const Size(48, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              child: const Icon(Icons.favorite_border, size: 18),
            ),
          ],
        ),
      ],
    );
  }
}

class DetailAiInsightCard extends StatelessWidget {
  const DetailAiInsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.field.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.green),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.psychology_outlined, color: AppColors.green, size: 18),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Health Insight',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Công thức này phù hợp với mục tiêu ăn nhiều protein của bạn. Chứa hàm lượng Omega-3 cao từ cá hồi và chất béo tốt từ bơ giúp hỗ trợ phục hồi cơ bắp sau buổi tập sáng nay của bạn.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: AppColors.muted,
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

class NutritionFactsCard extends StatelessWidget {
  const NutritionFactsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Nutrition Facts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                'PER SERVING',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: .6,
                  fontWeight: FontWeight.w900,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
          SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: FactBar(
                  label: 'CALORIES',
                  value: '485 kcal',
                  progress: .82,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: FactBar(label: 'PROTEIN', value: '34g', progress: .74),
              ),
            ],
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FactBar(label: 'CARBS', value: '12g', progress: .28),
              ),
              SizedBox(width: 20),
              Expanded(
                child: FactBar(label: 'FAT', value: '28g', progress: .58),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _FactSmall(label: 'Fiber', value: '8g'),
              ),
              Expanded(
                child: _FactSmall(label: 'Sodium', value: '420mg'),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _FactSmall(label: 'Sugar', value: '2g'),
              ),
              Expanded(
                child: _FactSmall(label: 'Cholesterol', value: '65mg'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FactBar extends StatelessWidget {
  const FactBar({
    super.key,
    required this.label,
    required this.value,
    required this.progress,
  });

  final String label;
  final String value;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: AppColors.muted),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            color: AppColors.green,
            backgroundColor: AppColors.line,
          ),
        ),
      ],
    );
  }
}

class _FactSmall extends StatelessWidget {
  const _FactSmall({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class IngredientsCard extends StatelessWidget {
  const IngredientsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ingredients',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              ExploreTag(label: '2 SERVINGS'),
            ],
          ),
          SizedBox(height: 16),
          IngredientRow(
            icon: Icons.restaurant,
            name: 'Fresh Salmon Fillet',
            amount: '300g, skinless',
          ),
          IngredientRow(
            icon: Icons.eco_outlined,
            name: 'Ripe Avocado',
            amount: '1 large, sliced',
          ),
          IngredientRow(
            icon: Icons.local_drink_outlined,
            name: 'Greek Yogurt',
            amount: '1/2 cup (Dressing base)',
            alert: true,
          ),
          AllergyNote(),
          IngredientRow(
            icon: Icons.grain_outlined,
            name: 'Quinoa Mix',
            amount: '1 cup, cooked',
          ),
        ],
      ),
    );
  }
}

class IngredientRow extends StatelessWidget {
  const IngredientRow({
    super.key,
    required this.icon,
    required this.name,
    required this.amount,
    this.alert = false,
  });

  final IconData icon;
  final String name;
  final String amount;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.field,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.green),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  amount,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Icon(
            alert ? Icons.info_outline : Icons.check_circle_outline,
            size: 17,
            color: alert ? const Color(0xFFA36E30) : AppColors.green,
          ),
        ],
      ),
    );
  }
}

class AllergyNote extends StatelessWidget {
  const AllergyNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 48, bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5D0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        '⚠ AI ALT: FOR DAIRY ALLERGY, USE TAHINI OR CASHEW CREAM',
        style: TextStyle(
          fontSize: 9,
          height: 1.25,
          fontWeight: FontWeight.w900,
          color: Color(0xFF774B24),
        ),
      ),
    );
  }
}

class CookingStep extends StatelessWidget {
  const CookingStep({
    super.key,
    required this.step,
    required this.title,
    required this.body,
  });

  final String step;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 34),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: AppColors.green,
            child: Text(
              step,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.52,
                    color: AppColors.muted,
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

class MealFeedbackCard extends StatelessWidget {
  const MealFeedbackCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How was your meal?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your feedback helps NutriChef AI refine your future recommendations.',
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              for (var i = 0; i < 5; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: Colors.white.withValues(alpha: .65),
                    child: const Icon(
                      Icons.star_border,
                      size: 17,
                      color: AppColors.ink,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 72,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Share your experience (Optional)...',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Submit Review',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 112),
              children: const [
                ProfileTopBar(),
                SizedBox(height: 46),
                ProfileIdentity(),
                SizedBox(height: 26),
                HealthScoreCard(),
                SizedBox(height: 18),
                ProfileInsightCard(),
                SizedBox(height: 44),
                HealthProfileSection(),
                SizedBox(height: 16),
                CollapsedProfileSection(
                  icon: Icons.track_changes,
                  title: 'Nutrition Goals',
                  preview: 'Daily Calories',
                  value: '1,850 kcal',
                ),
                SizedBox(height: 16),
                CollapsedProfileSection(
                  icon: Icons.restaurant_menu,
                  title: 'Dietary Preferences',
                  preview: 'Mediterranean',
                  value: 'Gluten-Free',
                ),
                SizedBox(height: 16),
                CollapsedProfileSection(
                  icon: Icons.devices_outlined,
                  title: 'Connected Devices',
                  preview: 'Apple Health',
                  value: 'Connected',
                ),
                SizedBox(height: 38),
                Padding(
                  padding: EdgeInsets.only(left: 18),
                  child: Text(
                    'APP SETTINGS',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w900,
                      color: AppColors.muted,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                SettingsCard(),
              ],
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: HomeBottomNav(selected: HomeTab.profile),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileTopBar extends StatelessWidget {
  const ProfileTopBar({super.key});

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
          onPressed: () {},
          icon: const Icon(Icons.auto_awesome, color: AppColors.darkGreen),
        ),
        const SizedBox(width: 10),
        const CircleAvatar(
          radius: 19,
          backgroundColor: Color(0xFFD9E9CD),
          child: Icon(Icons.person, color: AppColors.green),
        ),
      ],
    );
  }
}

class ProfileIdentity extends StatelessWidget {
  const ProfileIdentity({super.key});

  @override
  Widget build(BuildContext context) {
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
            const CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.green,
              child: Icon(Icons.edit, color: Colors.white, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          'Elena Rodriguez',
          style: TextStyle(
            fontSize: 31,
            height: 1,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on_outlined, size: 18, color: AppColors.ink),
            SizedBox(width: 4),
            Text(
              'Barcelona, Spain',
              style: TextStyle(fontSize: 16, color: AppColors.darkGreen),
            ),
          ],
        ),
      ],
    );
  }
}

class HealthScoreCard extends StatelessWidget {
  const HealthScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      child: Column(
        children: [
          const Text(
            'HEALTH SCORE',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: .9,
              fontWeight: FontWeight.w900,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: const [
                SizedBox(
                  width: 86,
                  height: 86,
                  child: CircularProgressIndicator(
                    value: .85,
                    strokeWidth: 4,
                    strokeCap: StrokeCap.round,
                    color: AppColors.green,
                    backgroundColor: AppColors.line,
                  ),
                ),
                Text(
                  '85',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Optimal',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileInsightCard extends StatelessWidget {
  const ProfileInsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      child: Column(
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: AppColors.field,
                child: Icon(Icons.auto_awesome, color: AppColors.green),
              ),
              SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Health Insight',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Your fiber intake is 15% higher this week than average. Great job!',
                      style: TextStyle(
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
                'VIEW DETAILED REPORT',
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

class HealthProfileSection extends StatelessWidget {
  const HealthProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      child: Column(
        children: const [
          ProfileSectionHeader(
            icon: Icons.medical_information_outlined,
            title: 'Health Profile',
            expanded: true,
          ),
          SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: ProfileMetricTile(
                  label: 'CURRENT\nWEIGHT',
                  value: '64.5',
                  unit: 'kg',
                ),
              ),
              SizedBox(width: 24),
              Expanded(
                child: ProfileMetricTile(
                  label: 'BMI INDEX',
                  value: '21.8',
                  unit: '\n(Normal)',
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ProfileMetricTile(
                  label: 'HEIGHT',
                  value: '172',
                  unit: 'cm',
                ),
              ),
              SizedBox(width: 24),
              Expanded(
                child: ProfileMetricTile(
                  label: 'BODY FAT',
                  value: '22',
                  unit: '%',
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
  const SettingsCard({super.key});

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
        children: const [
          SettingsRow(icon: Icons.notifications_none, title: 'Notifications'),
          Divider(height: 1, color: AppColors.line),
          SettingsRow(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            toggle: true,
          ),
          Divider(height: 1, color: AppColors.line),
          SettingsRow(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy & Data Security',
          ),
          Divider(height: 1, color: AppColors.line),
          SettingsRow(
            icon: Icons.logout,
            title: 'Logout',
            destructive: true,
            showArrow: false,
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
  });

  final IconData icon;
  final String title;
  final bool toggle;
  final bool destructive;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? const Color(0xFFD71920) : AppColors.ink;
    return SizedBox(
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

class WeeklyAnalysisScreen extends StatelessWidget {
  const WeeklyAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 112),
              children: const [
                WeeklyAnalysisTopBar(),
                SizedBox(height: 22),
                Text(
                  'Báo Cáo Phân Tích\nTuần',
                  style: TextStyle(
                    fontSize: 26,
                    height: 1.08,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Phân tích chuyên sâu từ AI cho hành trình\nsức khỏe của bạn.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.darkGreen,
                  ),
                ),
                SizedBox(height: 18),
                WeeklyDateRangePill(),
                SizedBox(height: 28),
                WeeklyGoalCard(),
                SizedBox(height: 16),
                CalorieTrendCard(),
                SizedBox(height: 16),
                WeeklyMacroCard(),
                SizedBox(height: 16),
                WeeklyAiAnalysisCard(),
                SizedBox(height: 16),
                NextWeekSuggestionsCard(),
                SizedBox(height: 36),
                Text(
                  'Món ngon gợi ý cho tuần mới',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 16),
                NewWeekMealCard(),
              ],
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: HomeBottomNav(selected: HomeTab.profile),
            ),
          ],
        ),
      ),
    );
  }
}

class WeeklyAnalysisTopBar extends StatelessWidget {
  const WeeklyAnalysisTopBar({super.key});

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
          onPressed: () {},
          icon: const Icon(Icons.auto_awesome, color: AppColors.darkGreen),
        ),
        const CircleAvatar(
          radius: 14,
          backgroundColor: Color(0xFFD9E9CD),
          child: Icon(Icons.person, size: 16, color: AppColors.green),
        ),
      ],
    );
  }
}

class WeeklyDateRangePill extends StatelessWidget {
  const WeeklyDateRangePill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(99),
      ),
      child: const Row(
        children: [
          Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.green),
          SizedBox(width: 10),
          Text(
            '24 THG 5 - 30 THG 5',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: .8,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class WeeklyGoalCard extends StatelessWidget {
  const WeeklyGoalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return WeeklyCard(
      child: Column(
        children: [
          SizedBox(
            width: 108,
            height: 108,
            child: Stack(
              alignment: Alignment.center,
              children: const [
                SizedBox(
                  width: 94,
                  height: 94,
                  child: CircularProgressIndicator(
                    value: .88,
                    strokeWidth: 5,
                    strokeCap: StrokeCap.round,
                    color: AppColors.green,
                    backgroundColor: AppColors.line,
                  ),
                ),
                Text(
                  '88%\nHOÀN THÀNH',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Mục tiêu Tuần',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bạn đã vượt qua 88% chỉ tiêu dinh dưỡng\nđã đề ra.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              color: AppColors.darkGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class CalorieTrendCard extends StatelessWidget {
  const CalorieTrendCard({super.key});

  @override
  Widget build(BuildContext context) {
    return WeeklyCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Xu hướng Calorie',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Icon(Icons.info_outline, size: 18, color: AppColors.muted),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 140,
            child: CustomPaint(
              painter: _WeeklyTrendPainter(),
              child: Container(),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DayLabel('T2'),
              _DayLabel('T3'),
              _DayLabel('T4'),
              _DayLabel('T5'),
              _DayLabel('T6'),
              _DayLabel('T7'),
              _DayLabel('CN'),
            ],
          ),
        ],
      ),
    );
  }
}

class WeeklyMacroCard extends StatelessWidget {
  const WeeklyMacroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const WeeklyCard(
      padding: EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chỉ số Macro',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 18),
          MacroProgressRow(
            label: 'Protein',
            value: '145g / 150g',
            progress: .96,
            color: AppColors.green,
          ),
          SizedBox(height: 13),
          MacroProgressRow(
            label: 'Carbs',
            value: '210g / 250g',
            progress: .84,
            color: Color(0xFFB8A086),
          ),
          SizedBox(height: 13),
          MacroProgressRow(
            label: 'Fat',
            value: '55g / 70g',
            progress: .79,
            color: Color(0xFF5F6057),
          ),
        ],
      ),
    );
  }
}

class WeeklyAiAnalysisCard extends StatelessWidget {
  const WeeklyAiAnalysisCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.field.withValues(alpha: .42),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.green),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.green,
                child: Icon(
                  Icons.psychology_outlined,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Phân tích từ AI\nNutriChef',
                style: TextStyle(
                  fontSize: 19,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          SizedBox(height: 22),
          WeeklyInsightLine(
            icon: Icons.check_circle_outline,
            title: 'Bạn đã đạt đủ protein:',
            body:
                'Tuần này mức tiêu thụ protein trung bình là 145g/ngày, rất tốt cho quá trình duy trì cơ bắp.',
          ),
          WeeklyInsightLine(
            icon: Icons.warning_amber_outlined,
            title: 'Lượng chất xơ còn thấp:',
            body:
                'Bạn chỉ đạt 65% mục tiêu chất xơ. Hãy bổ sung thêm các loại rau lá xanh trong bữa tối.',
          ),
          WeeklyInsightLine(
            icon: Icons.lightbulb_outline,
            title: '',
            body:
                'Thời gian ăn tối của bạn đang muộn dần về cuối tuần, có thể ảnh hưởng đến chất lượng giấc ngủ.',
          ),
        ],
      ),
    );
  }
}

class WeeklyInsightLine extends StatelessWidget {
  const WeeklyInsightLine({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.darkGreen),
          const SizedBox(width: 14),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: AppColors.ink,
                ),
                children: [
                  if (title.isNotEmpty)
                    TextSpan(
                      text: '$title ',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  TextSpan(text: body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NextWeekSuggestionsCard extends StatelessWidget {
  const NextWeekSuggestionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return WeeklyCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đề xuất tuần tới',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 18),
          const NextSuggestionTile(
            color: Color(0xFFF4D6BA),
            icon: Icons.eco_outlined,
            title: 'Tăng chất xơ',
            subtitle: 'Thêm 10g mỗi ngày',
          ),
          const SizedBox(height: 12),
          const NextSuggestionTile(
            color: Color(0xFFDDEED0),
            icon: Icons.restaurant,
            title: 'Thực đơn Địa Trung Hải',
            subtitle: 'Tối ưu cho sức khỏe tim mạch',
          ),
          const SizedBox(height: 12),
          const NextSuggestionTile(
            color: AppColors.sand,
            icon: Icons.water_drop_outlined,
            title: 'Cấp nước đều đặn',
            subtitle: 'Uống 2.5L nước/ngày',
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text("Create Next Week's Meal Plan"),
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
    );
  }
}

class NextSuggestionTile extends StatelessWidget {
  const NextSuggestionTile({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.green, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NewWeekMealCard extends StatelessWidget {
  const NewWeekMealCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 310,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 8),
            color: AppColors.darkGreen.withValues(alpha: .16),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const MealArt(palette: MealPalette.lunch),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: .78),
                ],
              ),
            ),
          ),
          Positioned(
            left: 28,
            right: 24,
            bottom: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ExploreTag(label: 'HEALTHY CHOICE', dark: true),
                SizedBox(height: 10),
                Text(
                  'Salad Cầu Vồng\nvới Sốt Tahini\nChanh',
                  style: TextStyle(
                    fontSize: 25,
                    height: 1.02,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Sự kết hợp hoàn hảo giữa chất xơ và protein thực vật để khởi đầu tuần mới đầy năng lượng.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: Colors.white,
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

class WeeklyCard extends StatelessWidget {
  const WeeklyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 8),
            color: AppColors.darkGreen.withValues(alpha: .035),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DayLabel extends StatelessWidget {
  const _DayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: AppColors.ink,
      ),
    );
  }
}

class _WeeklyTrendPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.line.withValues(alpha: .45)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = [
      Offset(size.width * .04, size.height * .72),
      Offset(size.width * .18, size.height * .48),
      Offset(size.width * .34, size.height * .55),
      Offset(size.width * .50, size.height * .32),
      Offset(size.width * .66, size.height * .40),
      Offset(size.width * .82, size.height * .25),
      Offset(size.width * .96, size.height * .36),
    ];

    final fill = Path()..moveTo(points.first.dx, size.height);
    for (final point in points) {
      fill.lineTo(point.dx, point.dy);
    }
    fill
      ..lineTo(points.last.dx, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()..color = AppColors.mint.withValues(alpha: .48),
    );

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      line.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = AppColors.green
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    for (final point in points) {
      canvas.drawCircle(point, 4, Paint()..color = AppColors.green);
      canvas.drawCircle(
        point,
        7,
        Paint()..color = AppColors.green.withValues(alpha: .14),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MealPlannerScreen extends StatelessWidget {
  const MealPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 74),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          child: const Icon(Icons.add),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 116),
              children: const [
                MealPlannerHeader(),
                SizedBox(height: 36),
                Text(
                  'Your Weekly Nutrition',
                  style: TextStyle(fontSize: 18, color: AppColors.ink),
                ),
                SizedBox(height: 10),
                Text(
                  'Personalized AI-crafted plan for October 23\n- 29',
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.35,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 28),
                PlannerActionButtons(),
                SizedBox(height: 36),
                CalorieTargetPanel(),
                SizedBox(height: 24),
                MacroBalancePanel(),
                SizedBox(height: 26),
                PlannerInsightPanel(),
                SizedBox(height: 34),
                PlannerDaySelector(),
                SizedBox(height: 22),
                PlannerMealCard(
                  meal: 'BREAKFAST',
                  title: 'Almond Blueberry\nOats',
                  meta: '340 kcal • 12g Protein',
                  palette: MealPalette.breakfast,
                ),
                SizedBox(height: 18),
                PlannerMealCard(
                  meal: 'LUNCH',
                  title: 'Spicy Nut Satay Salad',
                  meta: 'CONTAINS PEANUTS\n(ALLERGY)',
                  palette: MealPalette.lunch,
                  warning: true,
                ),
                SizedBox(height: 18),
                PlannerMealCard(
                  meal: 'DINNER',
                  title: 'Pan-Seared Salmon',
                  meta: '520 kcal • 42g Protein',
                  palette: MealPalette.dinner,
                ),
                SizedBox(height: 18),
                AddSnackButton(),
              ],
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: HomeBottomNav(selected: HomeTab.mealPlan),
            ),
          ],
        ),
      ),
    );
  }
}

class MealPlannerHeader extends StatelessWidget {
  const MealPlannerHeader({super.key});

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
          onPressed: () {},
          icon: const Icon(Icons.auto_awesome, color: AppColors.darkGreen),
        ),
        const SizedBox(width: 10),
        const CircleAvatar(
          radius: 15,
          backgroundColor: Color(0xFFD9E9CD),
          child: Icon(Icons.person, size: 17, color: AppColors.green),
        ),
      ],
    );
  }
}

class PlannerActionButtons extends StatelessWidget {
  const PlannerActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.shopping_basket_outlined, size: 20),
          label: const Text('SHOPPING LIST'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.sand,
            foregroundColor: const Color(0xFF5F6057),
            minimumSize: const Size(214, 54),
            padding: const EdgeInsets.symmetric(horizontal: 28),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(99),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.psychology_outlined, size: 21),
          label: const Text('AI PROPOSE PLAN'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
            minimumSize: const Size(240, 58),
            padding: const EdgeInsets.symmetric(horizontal: 26),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(99),
            ),
            elevation: 7,
            shadowColor: AppColors.darkGreen.withValues(alpha: .36),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class CalorieTargetPanel extends StatelessWidget {
  const CalorieTargetPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'DAILY CALORIE TARGET',
                  style: TextStyle(
                    fontSize: 13,
                    letterSpacing: .8,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Icon(Icons.insert_chart_outlined, color: AppColors.green),
            ],
          ),
          const SizedBox(height: 26),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '2,150',
                style: TextStyle(
                  fontSize: 54,
                  height: .92,
                  fontWeight: FontWeight.w900,
                  color: AppColors.green,
                ),
              ),
              SizedBox(width: 8),
              Padding(
                padding: EdgeInsets.only(bottom: 7),
                child: Text(
                  'kcal',
                  style: TextStyle(fontSize: 17, color: AppColors.ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: const LinearProgressIndicator(
              value: .85,
              minHeight: 7,
              color: AppColors.green,
              backgroundColor: AppColors.line,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '1,820 / 2,150 CONSUMED',
            style: TextStyle(
              fontSize: 13,
              letterSpacing: .7,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class MacroBalancePanel extends StatelessWidget {
  const MacroBalancePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MACRONUTRIENT BALANCE',
            style: TextStyle(
              fontSize: 13,
              letterSpacing: .8,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MacroRing(value: '30%', label: 'PROTEIN', color: AppColors.green),
              MacroRing(value: '45%', label: 'CARBS', color: Color(0xFFB49473)),
              MacroRing(value: '25%', label: 'FAT', color: AppColors.line),
            ],
          ),
        ],
      ),
    );
  }
}

class MacroRing extends StatelessWidget {
  const MacroRing({
    super.key,
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 4),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 9),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            letterSpacing: .7,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}

class PlannerInsightPanel extends StatelessWidget {
  const PlannerInsightPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 28, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.field.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(18),
        border: const Border(
          left: BorderSide(color: AppColors.green, width: 3),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 21, color: AppColors.green),
              SizedBox(width: 8),
              Text(
                'AI INSIGHT',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          Text(
            '"Increasing your protein intake by 15g at breakfast will help stabilize your energy levels for your scheduled Tuesday morning workout."',
            style: TextStyle(fontSize: 17, height: 1.48, color: AppColors.ink),
          ),
          SizedBox(height: 10),
          Text(
            'VIEW RECOMMENDATIONS',
            style: TextStyle(
              fontSize: 13,
              letterSpacing: .7,
              fontWeight: FontWeight.w900,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class PlannerDaySelector extends StatelessWidget {
  const PlannerDaySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          Padding(
            padding: EdgeInsets.only(right: 62, top: 5),
            child: Text(
              'Monday, Oct 23',
              style: TextStyle(fontSize: 18, color: AppColors.ink),
            ),
          ),
          DayPill(label: 'TODAY'),
          SizedBox(width: 36),
          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
              'Tue',
              style: TextStyle(fontSize: 16, color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class DayPill extends StatelessWidget {
  const DayPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF9AAC95),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          letterSpacing: .8,
          fontWeight: FontWeight.w900,
          color: AppColors.darkGreen,
        ),
      ),
    );
  }
}

class PlannerMealCard extends StatelessWidget {
  const PlannerMealCard({
    super.key,
    required this.meal,
    required this.title,
    required this.meta,
    required this.palette,
    this.warning = false,
  });

  final String meal;
  final String title;
  final String meta;
  final MealPalette palette;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: warning
            ? Border.all(color: const Color(0xFFEBA9A9), width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  meal,
                  style: const TextStyle(
                    fontSize: 13,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
              ),
              if (warning)
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFD71920),
                  size: 28,
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: MealArt(palette: palette),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      meta,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.2,
                        fontWeight: warning ? FontWeight.w900 : FontWeight.w700,
                        color: warning
                            ? const Color(0xFFD71920)
                            : AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (warning) ...[
            const SizedBox(height: 22),
            const SwapAlternativeButton(),
          ],
        ],
      ),
    );
  }
}

class SwapAlternativeButton extends StatelessWidget {
  const SwapAlternativeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(radius: 12),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        child: const Text(
          'SWAP FOR SAFE ALTERNATIVE',
          style: TextStyle(
            fontSize: 13,
            letterSpacing: .9,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class AddSnackButton extends StatelessWidget {
  const AddSnackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(radius: 16),
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_circle_outline, color: AppColors.ink),
            SizedBox(width: 8),
            Text(
              'ADD SNACK',
              style: TextStyle(fontSize: 17, color: AppColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.radius});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB8BFB1)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final extract = metric.extractPath(distance, distance + 8);
        canvas.drawPath(extract, paint);
        distance += 14;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.radius != radius;
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
              children: const [
                HomeHeader(),
                SizedBox(height: 28),
                DailyCaloriesCard(),
                SizedBox(height: 18),
                HomeAiInsightCard(),
                SizedBox(height: 18),
                MacroSummaryCard(),
                SizedBox(height: 26),
                TodayMenuHeader(),
                SizedBox(height: 12),
                MealCard(
                  label: 'BỮA SÁNG',
                  title: 'Bơ nghiền & Trứng chần',
                  time: '15 PH',
                  calories: '420 KCAL',
                  palette: MealPalette.breakfast,
                ),
                SizedBox(height: 18),
                MealCard(
                  label: 'BỮA TRƯA',
                  title: 'Salad Quinoa Hy Lạp',
                  time: '20 PH',
                  calories: '510 KCAL',
                  palette: MealPalette.lunch,
                ),
                SizedBox(height: 18),
                MealCard(
                  label: 'BỮA TỐI',
                  title: 'Cá hồi nướng măng tây',
                  time: '30 PH',
                  calories: '380 KCAL',
                  palette: MealPalette.dinner,
                ),
                SizedBox(height: 18),
                EmptyMealPlanCard(),
              ],
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: HomeBottomNav(),
            ),
          ],
        ),
      ),
    );
  }
}

class AiChefIngredientScannerScreen extends StatelessWidget {
  const AiChefIngredientScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 110),
              children: const [
                ScannerHeader(),
                SizedBox(height: 22),
                Text(
                  "What's in your kitchen\ntoday?",
                  style: TextStyle(
                    fontSize: 27,
                    height: 1.02,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Let AI craft the perfect healthy meal\nfrom your ingredients.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.25,
                    color: AppColors.darkGreen,
                  ),
                ),
                SizedBox(height: 18),
                IngredientInputCard(),
                SizedBox(height: 16),
                ScannerProfileCard(),
                SizedBox(height: 16),
                AskChefCard(),
                SizedBox(height: 18),
                ScannerRecommendedHeader(),
                SizedBox(height: 10),
                ScannerRecipeCard(
                  title: 'Tuscan Pan-Seared\nChicken & Greens',
                  meta: '27 minutes   •   34.1 Protein',
                  match: '98%',
                  palette: MealPalette.breakfast,
                ),
                SizedBox(height: 14),
                ScannerRecipeCard(
                  title: 'Zesty Spinach Pasta\n& Honey Vinaigrette',
                  meta: '15 min prep',
                  match: '85% Match',
                  palette: MealPalette.lunch,
                  compact: true,
                ),
              ],
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: HomeBottomNav(selected: HomeTab.home),
            ),
          ],
        ),
      ),
    );
  }
}

class ScannerHeader extends StatelessWidget {
  const ScannerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'NutriChef AI',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGreen,
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.auto_awesome, color: AppColors.darkGreen),
        ),
        const CircleAvatar(
          radius: 17,
          backgroundColor: Color(0xFFD9E9CD),
          child: Icon(Icons.person, size: 18, color: AppColors.green),
        ),
      ],
    );
  }
}

class IngredientInputCard extends StatelessWidget {
  const IngredientInputCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .72),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, size: 16, color: AppColors.muted),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Nhập nguyên liệu bạn đang có',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.photo_camera_outlined, size: 16),
                  label: const Text('Photo\nScan'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.muted,
                    backgroundColor: AppColors.sand,
                    side: BorderSide.none,
                    minimumSize: const Size(0, 42),
                    textStyle: const TextStyle(
                      fontSize: 9,
                      height: 1,
                      fontWeight: FontWeight.w800,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.qr_code_scanner, size: 15),
                  label: const Text('Camera'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 42),
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              IngredientTag('Chicken Breast'),
              IngredientTag('Spinach'),
              IngredientTag('Cherry Tomatoes'),
              IngredientTag('+ Add More'),
            ],
          ),
        ],
      ),
    );
  }
}

class IngredientTag extends StatelessWidget {
  const IngredientTag(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.darkGreen,
        ),
      ),
    );
  }
}

class ScannerProfileCard extends StatelessWidget {
  const ScannerProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Profile',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: ScannerProfileInfo(
                  label: 'CURRENT GOAL',
                  value: 'Weight Loss & Lean\nMuscle',
                  icon: Icons.fitness_center,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: const [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        value: .70,
                        strokeWidth: 4,
                        color: AppColors.green,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    Text(
                      '70%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: ScannerMiniPill(
                  label: 'ALLERGIES & PREFERENCES',
                  value: 'Gluten-Free   No Shellfish',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'DAILY PROTEIN',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: .7,
              fontWeight: FontWeight.w900,
              color: AppColors.muted,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '84g / 120g',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerProfileInfo extends StatelessWidget {
  const ScannerProfileInfo({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.green),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 8,
                  letterSpacing: .7,
                  fontWeight: FontWeight.w900,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ScannerMiniPill extends StatelessWidget {
  const ScannerMiniPill({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .62),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              letterSpacing: .7,
              fontWeight: FontWeight.w900,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 10, color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

class AskChefCard extends StatelessWidget {
  const AskChefCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, size: 17, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Ask Chef AI',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            'Tell me an issue like voice assistant without cooking problem?',
            style: TextStyle(
              fontSize: 10,
              height: 1.3,
              color: Colors.white.withValues(alpha: .78),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'Message...',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ),
                Icon(Icons.send, size: 15, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerRecommendedHeader extends StatelessWidget {
  const ScannerRecommendedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'AI-Recommended\nRecipes',
            style: TextStyle(
              fontSize: 18,
              height: 1.05,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'Save\nResults',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 9,
              height: 1.05,
              fontWeight: FontWeight.w900,
              color: AppColors.green,
            ),
          ),
        ),
      ],
    );
  }
}

class ScannerRecipeCard extends StatelessWidget {
  const ScannerRecipeCard({
    super.key,
    required this.title,
    required this.meta,
    required this.match,
    required this.palette,
    this.compact = false,
  });

  final String title;
  final String meta;
  final String match;
  final MealPalette palette;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 8),
            color: AppColors.darkGreen.withValues(alpha: .04),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: compact ? 138 : 172,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MealArt(palette: palette),
                Positioned(
                  left: 12,
                  top: 10,
                  child: ExploreTag(label: 'AI MATCH', dark: true),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .9),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      match,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.08,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Text(
                      compact ? '' : '98%\nMATCH',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  meta,
                  style: const TextStyle(fontSize: 10, color: AppColors.muted),
                ),
                if (!compact) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.field,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'This recipe perfectly fits your protein goal for today while using 80% of your scanned ingredients.',
                      style: TextStyle(
                        fontSize: 9,
                        height: 1.35,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const IngredientTag('KETO'),
                      const SizedBox(width: 6),
                      const IngredientTag('HIGH PROTEIN'),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Cook Now →',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, this.openScanner = false});

  final bool openScanner;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: Color(0xFFD9E9CD),
          child: Icon(Icons.person, color: AppColors.green),
        ),
        const SizedBox(width: 9),
        const Padding(
          padding: EdgeInsets.only(top: 7),
          child: Text(
            'NutriChef AI',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: openScanner
              ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AiChefIngredientScannerScreen(),
                  ),
                )
              : () {},
          icon: const Icon(Icons.auto_awesome, color: AppColors.darkGreen),
        ),
      ],
    );
  }
}

class DailyCaloriesCard extends StatelessWidget {
  const DailyCaloriesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chào buổi sáng, Vy',
          style: TextStyle(
            fontSize: 30,
            height: 1.05,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Hôm nay bạn cần nạp thêm 1,240 kcal\nđể đạt mục tiêu.',
          style: TextStyle(
            fontSize: 17,
            height: 1.35,
            color: AppColors.darkGreen,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.fromLTRB(26, 22, 26, 24),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CALO HẰNG NGÀY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: SizedBox(
                  width: 198,
                  height: 198,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(
                        width: 168,
                        height: 168,
                        child: CircularProgressIndicator(
                          value: .50,
                          strokeWidth: 8,
                          strokeCap: StrokeCap.round,
                          color: AppColors.green,
                          backgroundColor: AppColors.line,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            '1,254',
                            style: TextStyle(
                              fontSize: 44,
                              height: 1,
                              fontWeight: FontWeight.w900,
                              color: AppColors.ink,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Đã nạp / 2,494',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HomeAiInsightCard extends StatelessWidget {
  const HomeAiInsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.sand,
        borderRadius: BorderRadius.circular(18),
        border: const Border(
          left: BorderSide(color: AppColors.green, width: 3),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_outlined, size: 18, color: AppColors.green),
              SizedBox(width: 8),
              Text(
                'PHÂN TÍCH AI',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: .9,
                  fontWeight: FontWeight.w900,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Tuần này bạn đã đạt 82% mục tiêu protein. Hãy cân nhắc thêm một phần ức gà hoặc đậu phụ cho bữa tối để hoàn thành mục tiêu.',
            style: TextStyle(
              fontSize: 15,
              height: 1.45,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class MacroSummaryCard extends StatelessWidget {
  const MacroSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(26, 20, 26, 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          MacroProgressRow(
            label: 'ĐẠM (PROTEIN)',
            value: '102g / 140g',
            progress: .73,
            color: AppColors.green,
          ),
          SizedBox(height: 14),
          MacroProgressRow(
            label: 'TINH BỘT (CARB)',
            value: '185g / 250g',
            progress: .74,
            color: Color(0xFFB8A086),
          ),
          SizedBox(height: 14),
          MacroProgressRow(
            label: 'CHẤT BÉO (FAT)',
            value: '42g / 70g',
            progress: .60,
            color: Color(0xFF5F6057),
          ),
        ],
      ),
    );
  }
}

class MacroProgressRow extends StatelessWidget {
  const MacroProgressRow({
    super.key,
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  final String label;
  final String value;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            color: color,
            backgroundColor: AppColors.line,
          ),
        ),
      ],
    );
  }
}

class TodayMenuHeader extends StatelessWidget {
  const TodayMenuHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Thực đơn hôm nay',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.edit_outlined, size: 15),
          label: const Text('TÙY CHỈNH'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.darkGreen,
            textStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

enum MealPalette { breakfast, lunch, dinner }

class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.label,
    required this.title,
    required this.time,
    required this.calories,
    required this.palette,
  });

  final String label;
  final String title;
  final String time;
  final String calories;
  final MealPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 8),
            color: AppColors.darkGreen.withValues(alpha: .05),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 156,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MealArt(palette: palette),
                Positioned(
                  left: 18,
                  top: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .9),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 15, color: AppColors.ink),
                    const SizedBox(width: 5),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 18),
                    const Icon(
                      Icons.local_fire_department_outlined,
                      size: 15,
                      color: AppColors.ink,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      calories,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MealArt extends StatelessWidget {
  const MealArt({super.key, required this.palette});

  final MealPalette palette;

  @override
  Widget build(BuildContext context) {
    final gradient = switch (palette) {
      MealPalette.breakfast => const [
        Color(0xFFEEF5DA),
        Color(0xFF8FB65D),
        Color(0xFFFFF9E4),
      ],
      MealPalette.lunch => const [
        Color(0xFFF4D5AD),
        Color(0xFFE7B870),
        Color(0xFFF7E8C6),
      ],
      MealPalette.dinner => const [
        Color(0xFF1D2019),
        Color(0xFF6A4E35),
        Color(0xFFE7B45C),
      ],
    };

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      child: CustomPaint(painter: _MealArtPainter(palette)),
    );
  }
}

class EmptyMealPlanCard extends StatelessWidget {
  const EmptyMealPlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 150,
            width: double.infinity,
            color: AppColors.field,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 44,
                  color: Color(0xFFB5BDB0),
                ),
                SizedBox(height: 18),
                Text(
                  'Thêm bữa nhẹ để bổ sung protein',
                  style: TextStyle(fontSize: 15, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Chưa có kế hoạch',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  child: const Text(
                    'GỢI Ý TỪ AI',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
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

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({super.key, this.selected = HomeTab.home});

  final HomeTab selected;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Home', HomeTab.home),
      (Icons.search, 'Explore', HomeTab.explore),
      (Icons.menu_book_outlined, 'Recipes', HomeTab.recipes),
      (Icons.calendar_month_outlined, 'Meal Plan', HomeTab.mealPlan),
      (Icons.person_outline, 'Profile', HomeTab.profile),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _openTab(context, item.$3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: selected == item.$3 ? 62 : 42,
                      height: 34,
                      decoration: BoxDecoration(
                        color: selected == item.$3
                            ? const Color(0xFFB7C8B6)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Icon(item.$1, size: 20, color: AppColors.ink),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.$2.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.05,
                        fontWeight: selected == item.$3
                            ? FontWeight.w900
                            : FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openTab(BuildContext context, HomeTab tab) {
    if (tab == selected) return;

    final Widget screen = switch (tab) {
      HomeTab.home => const HomeScreen(),
      HomeTab.explore => const ExploreRecipesScreen(),
      HomeTab.recipes => const PersonalizedSuggestionsScreen(),
      HomeTab.mealPlan => const MealPlannerScreen(),
      HomeTab.profile => const UserProfileScreen(),
    };

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

enum HomeTab { home, explore, recipes, mealPlan, profile }

class _MealArtPainter extends CustomPainter {
  _MealArtPainter(this.palette);

  final MealPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    switch (palette) {
      case MealPalette.breakfast:
        _paintBreakfast(canvas, size);
      case MealPalette.lunch:
        _paintLunch(canvas, size);
      case MealPalette.dinner:
        _paintDinner(canvas, size);
    }
  }

  void _paintBreakfast(Canvas canvas, Size size) {
    final plate = Paint()..color = Colors.white.withValues(alpha: .92);
    canvas.drawCircle(Offset(size.width * .62, size.height * .52), 88, plate);
    final avocado = Paint()..color = const Color(0xFF73A64D);
    for (var i = 0; i < 8; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * (.24 + i * .045), size.height * .54),
          width: 42,
          height: 116,
        ),
        avocado
          ..color = Color.lerp(
            const Color(0xFF4F8D38),
            const Color(0xFFA7C96C),
            i / 8,
          )!,
      );
    }
    final eggWhite = Paint()..color = Colors.white;
    final yolk = Paint()..color = const Color(0xFFF2D276);
    canvas.drawCircle(
      Offset(size.width * .58, size.height * .45),
      38,
      eggWhite,
    );
    canvas.drawCircle(
      Offset(size.width * .72, size.height * .48),
      37,
      eggWhite,
    );
    canvas.drawCircle(Offset(size.width * .58, size.height * .45), 14, yolk);
    canvas.drawCircle(Offset(size.width * .72, size.height * .48), 13, yolk);
    final salmon = Paint()..color = const Color(0xFFF06D45);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * .47, size.height * .72, 128, 42),
        const Radius.circular(24),
      ),
      salmon,
    );
  }

  void _paintLunch(Canvas canvas, Size size) {
    final bowl = Paint()..color = const Color(0xFFF5E8CC);
    canvas.drawCircle(Offset(size.width * .52, size.height * .55), 108, bowl);
    final colors = [
      const Color(0xFFE2AA2D),
      const Color(0xFF7A4F33),
      const Color(0xFF7CA163),
      const Color(0xFFDD4935),
      const Color(0xFFF3D7A4),
    ];
    for (var i = 0; i < 45; i++) {
      final x = size.width * (.22 + (i % 9) * .07);
      final y = size.height * (.23 + (i ~/ 9) * .12);
      canvas.drawCircle(
        Offset(x, y),
        10 + (i % 3) * 2,
        Paint()..color = colors[i % colors.length],
      );
    }
    canvas.drawCircle(
      Offset(size.width * .5, size.height * .48),
      34,
      Paint()..color = const Color(0xFFEAD7A8),
    );
  }

  void _paintDinner(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * .58, size.width, size.height * .42),
      Paint()..color = Colors.black.withValues(alpha: .25),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * .25, size.height * .55, 166, 44),
        const Radius.circular(28),
      ),
      Paint()..color = const Color(0xFFE87945),
    );
    for (var i = 0; i < 6; i++) {
      canvas.drawLine(
        Offset(size.width * (.28 + i * .06), size.height * .58),
        Offset(size.width * (.34 + i * .06), size.height * .78),
        Paint()
          ..color = const Color(0xFFFFC081).withValues(alpha: .8)
          ..strokeWidth = 3,
      );
    }
    final asparagus = Paint()..color = const Color(0xFF6EA34E);
    for (var i = 0; i < 8; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * .55,
            size.height * (.58 + i * .025),
            118,
            5,
          ),
          const Radius.circular(4),
        ),
        asparagus,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MealArtPainter oldDelegate) {
    return oldDelegate.palette != palette;
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(size * .22),
      ),
      child: Icon(Icons.restaurant_menu, color: Colors.white, size: size * .44),
    );
  }
}

class _FoodBackdrop extends StatelessWidget {
  const _FoodBackdrop();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE9F4DC), Color(0xFFF9FBF0)],
        ),
      ),
      child: const Center(
        child: SizedBox(width: 360, height: 360, child: _FoodPattern()),
      ),
    );
  }
}

class _FoodPattern extends StatelessWidget {
  const _FoodPattern();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _FoodPatternPainter());
  }
}

class _FoodPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final plate = Paint()..color = Colors.white.withValues(alpha: .82);
    final rim = Paint()
      ..color = const Color(0xFFDDE9CF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawCircle(center, size.shortestSide * .45, plate);
    canvas.drawCircle(center, size.shortestSide * .43, rim);

    final colors = [
      const Color(0xFF82A96B),
      const Color(0xFFEBC35C),
      const Color(0xFFE87954),
      const Color(0xFFB4D18C),
      const Color(0xFFDF9F45),
    ];
    for (var i = 0; i < 34; i++) {
      final angle = i * .62;
      final radius = 42 + (i % 7) * 16;
      final x = center.dx + radius * _cos(angle);
      final y = center.dy + radius * _sin(angle);
      final rect = Rect.fromCenter(
        center: Offset(x, y),
        width: 36 + (i % 3) * 10,
        height: 22 + (i % 4) * 7,
      );
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.translate(-x, -y);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(12)),
        Paint()..color = colors[i % colors.length].withValues(alpha: .78),
      );
      canvas.restore();
    }

    final avocado = Paint()..color = const Color(0xFFF2F1C3);
    final pit = Paint()..color = const Color(0xFFD3B766);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 86, height: 118),
      avocado,
    );
    canvas.drawCircle(center.translate(0, 16), 24, pit);
  }

  double _sin(double value) {
    return switch (value) {
      _ => _fastSin(value),
    };
  }

  double _cos(double value) => _fastSin(value + 1.5707963268);

  double _fastSin(double x) {
    while (x > 3.1415926535) {
      x -= 6.283185307;
    }
    while (x < -3.1415926535) {
      x += 6.283185307;
    }
    return 1.27323954 * x - 0.405284735 * x * x.abs();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
