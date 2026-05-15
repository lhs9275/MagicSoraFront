import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/ocean_shell_widgets.dart';
import '../../features/auth/controllers/sign_up_controller.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _signUpController = SignUpController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final result = await _signUpController.submitSignUp(
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

    if (result.isSuccess) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _openLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
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
                  alignment: isCompact ? Alignment.topCenter : Alignment.center,
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
                              const _SignUpHeader(),
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
                                validator: _signUpController.validateEmail,
                              ),
                              const SizedBox(height: 14),
                              ShellTextField(
                                controller: _passwordController,
                                labelText: '비밀번호',
                                hintText: '8자 이상 입력',
                                icon: Icons.lock_rounded,
                                obscureText: true,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                autocorrect: false,
                                enableSuggestions: false,
                                validator: _signUpController.validatePassword,
                              ),
                              const SizedBox(height: 14),
                              ShellTextField(
                                controller: _passwordConfirmController,
                                labelText: '비밀번호 확인',
                                hintText: '비밀번호를 한 번 더 입력',
                                icon: Icons.verified_user_rounded,
                                obscureText: true,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _handleSignUp(),
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                autocorrect: false,
                                enableSuggestions: false,
                                validator: (value) =>
                                    _signUpController.validatePasswordConfirm(
                                      value,
                                      _passwordController.text,
                                    ),
                              ),
                              const SizedBox(height: 24),
                              OceanPillButton(
                                label: '회원가입 완료',
                                icon: Icons.favorite_rounded,
                                backgroundColor: AppTheme.shellPink,
                                isLoading: _isSubmitting,
                                onPressed: _isSubmitting ? null : _handleSignUp,
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: TextButton(
                                  onPressed: _openLogin,
                                  child: const Text(
                                    '이미 계정이 있어요. 로그인으로 돌아가기',
                                    textAlign: TextAlign.center,
                                  ),
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

class _SignUpHeader extends StatelessWidget {
  const _SignUpHeader();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 360;
        final badgeSize = isTight ? 50.0 : 54.0;
        final textAlign = isTight ? TextAlign.center : TextAlign.left;

        final badge = Container(
          width: badgeSize,
          height: badgeSize,
          decoration: BoxDecoration(
            color: AppTheme.shellPink,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shellPink.withValues(alpha: 0.32),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.star_rounded, color: Colors.white, size: 34),
        );

        final title = Column(
          crossAxisAlignment: isTight
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Text(
              '회원가입',
              textAlign: textAlign,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Magic Sora 계정을 만들어 이어서 이용해요.',
              textAlign: textAlign,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        );

        if (isTight) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [badge, const SizedBox(height: 12), title],
          );
        }

        return Row(
          children: [
            badge,
            const SizedBox(width: 14),
            Expanded(child: title),
          ],
        );
      },
    );
  }
}
