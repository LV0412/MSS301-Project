part of '../../../app.dart';

class ApiLoginScreen extends StatefulWidget {
  const ApiLoginScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<ApiLoginScreen> createState() => _ApiLoginScreenState();
}

class _ApiLoginScreenState extends State<ApiLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  StreamSubscription<String>? _googleIdTokenSubscription;
  bool _isSubmitting = false;
  bool _isGoogleSubmitting = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    final initialEmail = widget.initialEmail;
    if (initialEmail != null && initialEmail.isNotEmpty) {
      _emailController.text = initialEmail;
    }
    _initializeGoogleSignIn();
  }

  @override
  void dispose() {
    _googleIdTokenSubscription?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _initializeGoogleSignIn() async {
    if (kIsWeb) return;

    final googleAuthService = AuthDependencies.instance.googleAuthService;
    try {
      await googleAuthService.initialize();
    } catch (error) {
      if (!mounted) return;
      setState(() => _message = googleAuthService.messageFromError(error));
    }
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _message = 'Nhập email và mật khẩu để đăng nhập.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _message = null;
    });

    try {
      await AuthDependencies.instance.repository.login(
        email: email,
        password: password,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.code == 'EMAIL_NOT_VERIFIED') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ApiVerifyEmailScreen(email: email, password: password),
          ),
        );
        return;
      }
      setState(() => _message = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _message = 'Không thể kết nối API Gateway.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    final googleAuthService = AuthDependencies.instance.googleAuthService;
    try {
      final idToken = await googleAuthService.authenticateAndReadIdToken();
      await _completeGoogleLogin(idToken);
    } catch (error) {
      if (!mounted) return;
      setState(() => _message = googleAuthService.messageFromError(error));
    }
  }

  Future<void> _completeGoogleLogin(String idToken) async {
    await _completeGoogleLoginWithPassword(idToken: idToken);
  }

  Future<void> _completeGoogleLoginWithPassword({
    required String idToken,
    String? password,
  }) async {
    if (_isGoogleSubmitting) return;

    setState(() {
      _isGoogleSubmitting = true;
      _message = null;
    });

    try {
      await _loginWithGoogleToken(idToken: idToken, password: password);
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.code == 'GOOGLE_LINK_PASSWORD_REQUIRED' && password == null) {
        setState(() => _message = null);
        await _showGoogleLinkPasswordDialog(idToken, error.message);
        return;
      }
      setState(() => _message = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _message = 'KhÃ´ng thá»ƒ Ä‘Äƒng nháº­p báº±ng Google.');
    } finally {
      if (mounted) setState(() => _isGoogleSubmitting = false);
    }
  }

  Future<void> _loginWithGoogleToken({
    required String idToken,
    String? password,
  }) async {
    await AuthDependencies.instance.repository.googleLogin(
      idToken: idToken,
      password: password,
    );
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  Future<void> _showGoogleLinkPasswordDialog(
    String idToken,
    String message,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: !_isGoogleSubmitting,
      builder: (context) => _GoogleLinkPasswordDialog(
        message: message,
        onSubmit: (password) =>
            _loginWithGoogleToken(idToken: idToken, password: password),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final googleClientId =
        AuthDependencies.instance.googleAuthService.webClientId;
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
            'Đăng nhập',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Kết nối qua API Gateway tại /api/v1/auth/login.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 26),
          _ApiInputField(
            label: 'EMAIL',
            hint: 'email@example.com',
            icon: Icons.mail_outline,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          _ApiInputField(
            label: 'MẬT KHẨU',
            hint: 'Password@123',
            icon: Icons.lock_outline,
            controller: _passwordController,
            obscureText: true,
          ),
          if (_message != null) ...[
            const SizedBox(height: 12),
            ApiMessageBanner(message: _message!, isError: true),
          ],
          const SizedBox(height: 18),
          _ApiSubmitButton(
            label: 'Đăng nhập',
            isLoading: _isSubmitting,
            onPressed: _isSubmitting ? null : _login,
          ),
          const OrDivider(),
          kIsWeb
              ? _ApiGoogleWebButton(
                  clientId: googleClientId,
                  isLoading: _isGoogleSubmitting,
                  onIdToken: (idToken) =>
                      unawaited(_completeGoogleLogin(idToken)),
                  onError: (error) {
                    if (!mounted) return;
                    setState(
                      () => _message = AuthDependencies
                          .instance
                          .googleAuthService
                          .messageFromError(error),
                    );
                  },
                )
              : _ApiGoogleButton(
                  isLoading: _isGoogleSubmitting,
                  onPressed: _isGoogleSubmitting ? null : _loginWithGoogle,
                ),
          const SizedBox(height: 20),
          AuthSwitchText(
            normal: 'Chưa có tài khoản? ',
            action: 'Đăng ký ngay',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ApiSignUpScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class ApiSignUpScreen extends StatefulWidget {
  const ApiSignUpScreen({super.key});

  @override
  State<ApiSignUpScreen> createState() => _ApiSignUpScreenState();
}

class _ApiSignUpScreenState extends State<ApiSignUpScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Nhập đầy đủ họ tên, email và mật khẩu.');
      return;
    }
    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Mật khẩu xác nhận không khớp.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await AuthDependencies.instance.repository.register(
        email: email,
        password: password,
        fullName: fullName,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ApiVerifyEmailScreen(email: email, password: password),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Không thể kết nối API Gateway.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthFrame(
      topLabel: 'NutriChef AI',
      child: Column(
        children: [
          const Text(
            'Tạo tài khoản',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Gọi /api/v1/auth/register qua API Gateway.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 26),
          _ApiInputField(
            label: 'HỌ TÊN',
            hint: 'Nguyễn Văn A',
            icon: Icons.person_outline,
            controller: _fullNameController,
          ),
          const SizedBox(height: 14),
          _ApiInputField(
            label: 'EMAIL',
            hint: 'example@nutrichef.ai',
            icon: Icons.mail_outline,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          _ApiInputField(
            label: 'MẬT KHẨU',
            hint: 'Ít nhất 8 ký tự',
            icon: Icons.lock_outline,
            controller: _passwordController,
            obscureText: true,
          ),
          const SizedBox(height: 14),
          _ApiInputField(
            label: 'XÁC NHẬN',
            hint: 'Nhập lại mật khẩu',
            icon: Icons.verified_user_outlined,
            controller: _confirmPasswordController,
            obscureText: true,
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            ApiMessageBanner(message: _errorMessage!, isError: true),
          ],
          if (_successMessage != null) ...[
            const SizedBox(height: 12),
            ApiMessageBanner(message: _successMessage!),
          ],
          const SizedBox(height: 18),
          _ApiSubmitButton(
            label: 'Đăng ký',
            isLoading: _isSubmitting,
            onPressed: _isSubmitting ? null : _register,
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

class ApiVerifyEmailScreen extends StatefulWidget {
  const ApiVerifyEmailScreen({super.key, required this.email, this.password});

  final String email;
  final String? password;

  @override
  State<ApiVerifyEmailScreen> createState() => _ApiVerifyEmailScreenState();
}

class _ApiVerifyEmailScreenState extends State<ApiVerifyEmailScreen> {
  final _otpController = TextEditingController();
  late String? _passwordForLogin = widget.password;
  bool _isVerifying = false;
  bool _isResending = false;
  String? _message;
  bool _isError = false;

  @override
  void dispose() {
    _passwordForLogin = null;
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() {
        _message = 'Nhập mã OTP gồm 6 số.';
        _isError = true;
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _message = null;
      _isError = false;
    });

    try {
      await AuthDependencies.instance.repository.verifyEmail(
        email: widget.email,
        otp: otp,
      );

      final password = _passwordForLogin;
      if (password != null && password.isNotEmpty) {
        await AuthDependencies.instance.repository.login(
          email: widget.email,
          password: password,
        );
        _passwordForLogin = null;
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
          (_) => false,
        );
        return;
      }

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => ApiLoginScreen(initialEmail: widget.email),
        ),
        (_) => false,
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _message = error.message;
        _isError = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = 'Không thể kết nối API Gateway.';
        _isError = true;
      });
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isResending = true;
      _message = null;
      _isError = false;
    });

    try {
      await AuthDependencies.instance.repository.resendVerification(
        widget.email,
      );
      if (!mounted) return;
      setState(() {
        _message = 'Mã OTP mới đã được gửi. Kiểm tra email hoặc log backend.';
        _isError = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _message = error.message;
        _isError = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = 'Không thể gửi lại OTP. Vui lòng thử lại.';
        _isError = true;
      });
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthFrame(
      topLabel: 'NutriChef AI',
      child: Column(
        children: [
          const Icon(
            Icons.mark_email_read_outlined,
            size: 44,
            color: AppColors.green,
          ),
          const SizedBox(height: 16),
          const Text(
            'Xác thực email',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhập mã OTP 6 số đã gửi tới ${widget.email}.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 26),
          _ApiInputField(
            label: 'MÃ OTP',
            hint: '123456',
            icon: Icons.pin_outlined,
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            onSubmitted: (_) {
              if (!_isVerifying) _verify();
            },
          ),
          if (_message != null) ...[
            const SizedBox(height: 12),
            ApiMessageBanner(message: _message!, isError: _isError),
          ],
          const SizedBox(height: 18),
          _ApiSubmitButton(
            label: 'Xác thực và tiếp tục',
            isLoading: _isVerifying,
            onPressed: _isVerifying ? null : _verify,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _isResending ? null : _resendOtp,
            child: Text(
              _isResending ? 'Đang gửi lại...' : 'Gửi lại mã OTP',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.darkGreen,
              ),
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () {
              _passwordForLogin = null;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => ApiLoginScreen(initialEmail: widget.email),
                ),
                (_) => false,
              );
            },
            child: const Text('Quay lại đăng nhập'),
          ),
        ],
      ),
    );
  }
}
