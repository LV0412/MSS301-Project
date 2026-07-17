part of '../../../app.dart';

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
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Đăng nhập',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LifestyleScreen()),
            ),
          ),
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
