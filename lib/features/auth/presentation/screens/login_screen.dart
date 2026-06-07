import 'package:flutter/material.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';
import 'package:magicsorafront/features/auth/controllers/login_controller.dart';
import 'package:magicsorafront/features/auth/models/app_user.dart';
import 'package:magicsorafront/features/home/presentation/screens/magic_conch_home_screen.dart';

/// 인증이 완료되면 토론 대시보드로 이동한다.
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
      MaterialPageRoute<void>(
        builder: (_) => MagicConchHomeScreen(
          user:
              result.user ?? AppUser.demo(email: _emailController.text.trim()),
        ),
      ),
    );
  }

  void _openPreview() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => MagicConchHomeScreen(user: AppUser.demo()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: OceanShellBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 430;
            final horizontalPadding = constraints.maxWidth >= 720
                ? 32.0
                : constraints.maxWidth < 360
                ? 16.0
                : 20.0;
            final topPadding = isCompact ? 14.0 : 28.0;
            final bottomPadding = 24.0 + viewInsets.bottom;
            final minHeight =
                constraints.maxHeight - topPadding - bottomPadding;

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                topPadding,
                horizontalPadding,
                bottomPadding,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: minHeight > 0 ? minHeight : 0,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: OceanPanel(
                      padding: EdgeInsets.fromLTRB(
                        isCompact ? 18 : 22,
                        isCompact ? 20 : 24,
                        isCompact ? 18 : 22,
                        22,
                      ),
                      child: Form(
                        key: _formKey,
                        child: AutofillGroup(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const _LoginHeader(),
                              const SizedBox(height: 24),
                              ShellTextField(
                                controller: _emailController,
                                labelText: '이메일',
                                hintText: 'you@example.com',
                                icon: Icons.alternate_email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                autocorrect: false,
                                validator: _loginController.validateEmail,
                              ),
                              const SizedBox(height: 14),
                              ShellTextField(
                                controller: _passwordController,
                                labelText: '비밀번호',
                                hintText: '8자 이상 입력',
                                icon: Icons.lock_rounded,
                                obscureText: true,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _handleLogin(),
                                autofillHints: const [AutofillHints.password],
                                autocorrect: false,
                                enableSuggestions: false,
                                validator: _loginController.validatePassword,
                              ),
                              const SizedBox(height: 24),
                              OceanPillButton(
                                label: '로그인으로 시작',
                                icon: Icons.login_rounded,
                                backgroundColor: AppTheme.shellPurple,
                                isLoading: _isSubmitting,
                                onPressed: _isSubmitting ? null : _handleLogin,
                              ),
                              const SizedBox(height: 12),
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
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 360;
        final conchSize = isTight ? 92.0 : 116.0;

        return SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/brand/magic_conch.png',
                width: conchSize,
                height: conchSize * 0.72,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 12),
              Text(
                '로그인',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(letterSpacing: 0),
              ),
              const SizedBox(height: 4),
              Text(
                '토론 기록과 개인 설정을 이어서 사용합니다.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        );
      },
    );
  }
}
