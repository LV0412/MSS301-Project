part of '../../../app.dart';

enum _SplashState { checking, noSession, connectionError }

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  _SplashState _state = _SplashState.checking;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    setState(() {
      _state = _SplashState.checking;
      _errorMessage = null;
    });

    final dependencies = AuthDependencies.instance;
    final session = await dependencies.sessionStorage.read();
    if (session == null) {
      if (!mounted) return;
      setState(() => _state = _SplashState.noSession);
      return;
    }

    try {
      await dependencies.repository.me();
      final tabName = await dependencies.sessionStorage.readLastHomeTab();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainShell(initialTab: _homeTabFromName(tabName)),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;

      if (error.statusCode == 401) {
        await dependencies.repository.clearSession();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ApiLoginScreen(
              initialMessage:
                  'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
            ),
          ),
        );
        return;
      }

      if (error.statusCode == 403) {
        await dependencies.repository.clearSession();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ApiLoginScreen(
              initialMessage:
                  'Tài khoản đang bị khóa hoặc không còn quyền truy cập.',
            ),
          ),
        );
        return;
      }

      setState(() {
        _state = _SplashState.connectionError;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _state = _SplashState.connectionError;
        _errorMessage =
            'Không thể xác minh phiên đăng nhập. Kiểm tra kết nối rồi thử lại.';
      });
    }
  }

  HomeTab _homeTabFromName(String? tabName) {
    return switch (tabName) {
      'explore' => HomeTab.explore,
      'profile' => HomeTab.profile,
      _ => HomeTab.home,
    };
  }

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
                  _buildAction(),
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

  Widget _buildAction() {
    return switch (_state) {
      _SplashState.checking => const SizedBox(
        width: 42,
        height: 42,
        child: CircularProgressIndicator(color: AppColors.green),
      ),
      _SplashState.noSession => PrimaryButton(
        label: 'Bắt đầu ngay',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ApiLoginScreen()),
        ),
      ),
      _SplashState.connectionError => Column(
        children: [
          if (_errorMessage != null) ...[
            ApiMessageBanner(message: _errorMessage!, isError: true),
            const SizedBox(height: 12),
          ],
          PrimaryButton(
            label: 'Thử lại',
            onPressed: () => unawaited(_bootstrap()),
          ),
        ],
      ),
    };
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
