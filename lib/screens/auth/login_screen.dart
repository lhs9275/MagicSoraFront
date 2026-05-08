import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../features/auth/controllers/login_controller.dart';
import '../home/debate_home_screen.dart';

/// 앱 첫 진입 화면이다. 인증이 완료되면 토론 대시보드로 이동한다.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _loginController = LoginController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 입력값 검증과 임시 인증을 수행한 뒤 다음 화면으로 이동시킨다.
  Future<void> _handleLogin() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final result = await _loginController.submitLogin(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));

    if (!result.isSuccess) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const DebateHomeScreen()),
    );
  }

  /// 인증 없이 화면 구조만 확인하고 싶을 때 데모 홈으로 바로 이동시킨다.
  void _openPreview() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const DebateHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _BrandHeader(),
                    const SizedBox(height: 34),
                    Text(
                      '로그인',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 34,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '토론 기록과 개인 설정을 이어서 사용합니다.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 28),
                    _LoginPanel(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      loginController: _loginController,
                      onPasswordSubmitted: _handleLogin,
                    ),
                    const SizedBox(height: 18),
                    _PrimaryLoginButton(
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _handleLogin,
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: TextButton(
                        onPressed: _openPreview,
                        child: const Text('계정 없이 둘러보기'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _BrandMark(),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Magic Sora',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(letterSpacing: 0.6),
              ),
              const SizedBox(height: 4),
              Text(
                'Debate arena',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 58,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 5,
            top: 7,
            child: Transform.rotate(
              angle: -0.16,
              child: const _MiniCard(color: AppTheme.coral),
            ),
          ),
          Positioned(
            left: 13,
            top: 2,
            child: Transform.rotate(
              angle: 0.1,
              child: const _MiniCard(color: AppTheme.accentGold),
            ),
          ),
          Positioned(
            right: 3,
            bottom: 1,
            child: Transform.rotate(
              angle: 0.22,
              child: const _MiniCard(color: AppTheme.primaryTeal),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.cream,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryDark, width: 2),
                ),
                child: const Text(
                  'S',
                  style: TextStyle(
                    color: AppTheme.primaryDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primaryDark, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({
    required this.emailController,
    required this.passwordController,
    required this.loginController,
    required this.onPasswordSubmitted,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final LoginController loginController;
  final VoidCallback onPasswordSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: loginController.validateEmail,
            decoration: const InputDecoration(
              labelText: '이메일',
              hintText: 'you@example.com',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onPasswordSubmitted(),
            validator: loginController.validatePassword,
            decoration: const InputDecoration(
              labelText: '비밀번호',
              hintText: '8자 이상 입력',
              prefixIcon: Icon(Icons.lock_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryLoginButton extends StatelessWidget {
  const _PrimaryLoginButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: isEnabled ? 1 : 0.72,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isEnabled ? AppTheme.accentGold : const Color(0xFFE7DFBF),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppTheme.accentDark, width: 2),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppTheme.accentGold.withValues(alpha: 0.36),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: isEnabled ? onPressed : null,
            child: SizedBox(
              height: 58,
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: AppTheme.primaryDark,
                        ),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: AppTheme.primaryDark,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '로그인 후 시작하기',
                            style: TextStyle(
                              color: AppTheme.primaryDark,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
