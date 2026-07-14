part of '../../../app.dart';

class _ApiInputField extends StatelessWidget {
  const _ApiInputField({
    required this.label,
    required this.hint,
    required this.controller,
    this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.maxLength,
    this.inputFormatters,
    this.onSubmitted,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData? icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSubmitted;

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
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            prefixIcon: icon == null ? null : Icon(icon, size: 18),
            filled: true,
            fillColor: AppColors.field,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _ApiSubmitButton extends StatelessWidget {
  const _ApiSubmitButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

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
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}

class _ApiGoogleButton extends StatelessWidget {
  const _ApiGoogleButton({required this.onPressed, required this.isLoading});

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkGreen,
          side: const BorderSide(color: AppColors.line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.darkGreen,
                ),
              )
            : const Row(
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
                  Text('Tiáº¿p tá»¥c vá»›i Google'),
                ],
              ),
      ),
    );
  }
}

class _ApiGoogleWebButton extends StatelessWidget {
  const _ApiGoogleWebButton({
    required this.clientId,
    required this.isLoading,
    required this.onIdToken,
    required this.onError,
  });

  final String? clientId;
  final bool? isLoading;
  final ValueChanged<String> onIdToken;
  final ValueChanged<Object> onError;

  @override
  Widget build(BuildContext context) {
    final effectiveClientId = clientId?.trim() ?? '';
    final effectiveIsLoading = isLoading ?? false;

    if (effectiveClientId.isEmpty) {
      return const SizedBox(
        height: 48,
        child: Center(
          child: Text(
            'Missing GOOGLE_CLIENT_ID.',
            style: TextStyle(color: AppColors.muted),
          ),
        ),
      );
    }

    return IgnorePointer(
      ignoring: effectiveIsLoading,
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: Center(
          child: renderGoogleWebButton(
            clientId: effectiveClientId,
            minimumWidth: 320,
            onIdToken: onIdToken,
            onError: onError,
          ),
        ),
      ),
    );
  }
}

class _GoogleLinkPasswordDialog extends StatefulWidget {
  const _GoogleLinkPasswordDialog({
    required this.message,
    required this.onSubmit,
  });

  final String message;
  final Future<void> Function(String password) onSubmit;

  @override
  State<_GoogleLinkPasswordDialog> createState() =>
      _GoogleLinkPasswordDialogState();
}

class _GoogleLinkPasswordDialogState extends State<_GoogleLinkPasswordDialog> {
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Nhập mật khẩu để liên kết Google.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.onSubmit(password);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Không thể liên kết Google.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.mint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.link,
                      color: AppColors.darkGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Liên kết Google',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Đóng',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ApiMessageBanner(message: widget.message, isError: false),
              const SizedBox(height: 16),
              _ApiInputField(
                label: 'MẬT KHẨU TÀI KHOẢN',
                hint: 'Nhập mật khẩu hiện tại',
                icon: Icons.lock_outline,
                controller: _passwordController,
                obscureText: true,
                onSubmitted: (_) {
                  if (!_isSubmitting) unawaited(_submit());
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                ApiMessageBanner(message: _errorMessage!, isError: true),
              ],
              const SizedBox(height: 18),
              _ApiSubmitButton(
                label: 'Liên kết Google',
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ApiMessageBanner extends StatelessWidget {
  const ApiMessageBanner({
    super.key,
    required this.message,
    this.isError = false,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final bool isError;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFFE8E6) : AppColors.mint,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w700,
                color: isError ? const Color(0xFF9F2D20) : AppColors.darkGreen,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}
